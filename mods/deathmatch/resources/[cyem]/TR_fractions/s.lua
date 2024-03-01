
function createFractionDutyStart()
    local fractions = exports.TR_mysql:querry("SELECT ID, fractionID, name, pos, type, color FROM tr_fractions")
    if fractions and fractions[1] then
        for i, v in pairs(fractions) do
            local pos = split(v.pos, ",")
            local color = split(v.color, ",")

            local marker = createMarker(pos[1], pos[2], pos[3] - 0.9, "cylinder", 1.6, color[1], color[2], color[3], 0)
            setElementInterior(marker, pos[4])
            setElementDimension(marker, pos[5])
            setElementData(marker, "markerIcon", v.type)
            setElementData(marker, "fractionData", {ID = v.fractionID, name = v.name, type = v.type, color = color}, false)

            addEventHandler("onMarkerHit", marker, fractionDutyMarkerEnter)
        end
    end

    setTimer(function()
        exports.TR_starter:reloadResources({"TR_multiseat"})
    end, 1000, 1)
end

function fractionDutyMarkerEnter(el, md)
    if not md then return end
    if getElementType(el) ~= "player" then return end
    local _, _, ez = getElementPosition(el)
    local _, _, mz = getElementPosition(source)
    if ez < mz - 0.5 or ez > mz + 2 then return end

    local fractionData = getElementData(source, "fractionData")
    if not fractionData then return end

    local hasJob = exports.TR_mysql:querry("SELECT ID FROM tr_fractionsPlayers WHERE playerUID = ? AND fractionID = ? LIMIT 1", getElementData(el, "characterUID"), fractionData.ID)
    triggerClientEvent(el, "openFractionDutyStart", resourceRoot, fractionData, hasJob[1] and hasJob[1].ID or false)
end


function startPlayerFractionDuty(state, name, type, color, id)
    local data = getElementData(client, "characterData")
    if state then
        removeElementData(client, "characterDuty")
        if tonumber(data.skin) ~= nil then
            setElementModel(client, data.skin)
            setElementData(client, "customModel", nil)
        else
            setElementModel(client, 0)
            setElementData(client, "customModel", data.skin)
        end


        if type == "police" then
            exports.TR_weaponSlots:takeAllWeapons(client)
            setElementData(client, "weapons", {})
        else
            removeAdditionalWeapons(client)
        end

        triggerClientEvent(client, "responseFractionDutyStart", resourceRoot, "end")
    else
        setElementData(client, "characterDuty", {name, color, type, id})
        triggerClientEvent(client, "responseFractionDutyStart", resourceRoot, "start")
    end
end
addEvent("startPlayerFractionDuty", true)
addEventHandler("startPlayerFractionDuty", resourceRoot, startPlayerFractionDuty)


function fractionChatMessage(...)
    local characterDuty = getElementData(client, "characterDuty")
    if not characterDuty then return end

    local msg = table.concat({...}, " ")
    local id = getElementData(client, "characterUID")
    local name = getPlayerName(client)

    local fractionShort = getFractionShortName(characterDuty[1])

    for i, v in pairs(getElementsByType("player")) do
        if getElementData(v, "characterDuty") then
            triggerClientEvent(v, "showCustomMessage", resourceRoot, string.format("#DD3E46[%s] [%d] %s", fractionShort, id, name), msg, "files/images/diathermy.png")
        end
    end

    local time = getRealTime()
    exports.TR_discord:sendChannelMsg("fraction", {
      time = string.format("[%02d:%02d %02d.%02d]", time.hour, time.minute, time.monthday, time.month),
      author = name,
      text = msg,
    })
end
addEvent("fractionChatMessage", true)
addEventHandler("fractionChatMessage", root, fractionChatMessage)

function fractionSingleChatMessage(...)
    local characterDuty = getElementData(client, "characterDuty")
    if not characterDuty then return end

    local msg = table.concat({...}, " ")
    local id = getElementData(client, "characterUID")
    local name = getPlayerName(client)

    for i, v in pairs(getElementsByType("player")) do
        local duty = getElementData(v, "characterDuty")
        if duty then
            if duty[3] == characterDuty[3] then
                triggerClientEvent(v, "showCustomMessage", resourceRoot, string.format("#dd3ed0[FRAKSIYON] [%d] %s", id, name), msg, "files/images/diathermy.png")
            end
        end
    end

    local time = getRealTime()
    exports.TR_discord:sendChannelMsg("fraction", {
      time = string.format("[%02d:%02d %02d.%02d]", time.hour, time.minute, time.monthday, time.month),
      author = name,
      text = msg,
    })
end
addEvent("fractionSingleChatMessage", true)
addEventHandler("fractionSingleChatMessage", root, fractionSingleChatMessage)

function getFractionShortName(name)
    local nameTable = split(name, " ")
    local fractionShort = ""
    for i, v in pairs(nameTable) do
        fractionShort = fractionShort .. string.sub(v, 0, 1)
    end
    return fractionShort
end

function removeAdditionalWeapons(plr)
    local weapons = getElementData(plr, "fakeWeapons")
    if not weapons then return end
    local newWeapons = {}

    for i, v in pairs(weapons) do
        if type(v) == "number" then
            table.insert(newWeapons, v)
        end
    end

    setElementData(plr, "fakeWeapons", newWeapons)
end

function setPlayerReanimation(plr)
    local player = client
    local x, y, z = getPosition(plr, Vector3(0.5, 1.4, 0))
    local _, _, rot = getElementRotation(plr)

    setElementPosition(player, x, y, z)
    setElementRotation(player, 0, 0, rot + 90)

    setElementData(plr, "blockAction", player)
    setElementData(player, "blockAction", plr)

    setTimer(setPedAnimation, 100, 1, player, "medic", "cpr")

    setElementFrozen(player, true)

    setTimer(function()
        if isElement(plr) then
            setElementData(plr, "blockAction", nil)
            triggerClientEvent(plr, "endBW", resourceRoot)
        end
    end, 6000, 1)

    setTimer(function()
        if isElement(player) then
            setElementFrozen(player, false)
            setElementData(player, "blockAction", nil)
            setPedAnimation(player, nil, nil)
        end
    end, 8000, 1)

    triggerClientEvent(player, "updateInteraction", resourceRoot)
end
addEvent("setPlayerReanimation", true)
addEventHandler("setPlayerReanimation", root, setPlayerReanimation)



function getPosition(element, vec)
	local rot = Vector3(getElementRotation(element))
	local mat = Matrix(Vector3(getElementPosition(element)), rot)
	local newPos = mat:transformPosition(vec)
	return newPos.x, newPos.y, newPos.z, rot.z
end

createFractionDutyStart()



function syncPlayerFractionMinutes(time)
    local uid = getElementData(client, "characterUID")
    local characterDuty = getElementData(client, "characterDuty")
    if not characterDuty then return end

    local time = exports.TR_mysql:querry("SELECT ID, minutes FROM tr_fractionsDutyTimes WHERE playerUID = ? AND day = CURDATE() LIMIT 1", uid)
    local plrRank = exports.TR_mysql:querry("SELECT level FROM tr_fractionsRanks LEFT JOIN tr_fractionsPlayers ON tr_fractionsPlayers.rankID = tr_fractionsRanks.ID WHERE playerUID = ? LIMIT 1", uid)
    local maxRank = exports.TR_mysql:querry("SELECT MAX(level) as level FROM tr_fractionsRanks WHERE fractionID = ? LIMIT 1", characterDuty[4])

    if time and time[1] then
        exports.TR_mysql:querry("UPDATE tr_fractionsDutyTimes SET minutes = minutes + 1, count = ? WHERE ID = ?", calculatePlayerMoney(tonumber(time[1].minutes) + 1, tonumber(plrRank[1].level), tonumber(maxRank[1].level), 3300, 6800, 1), time[1].ID)
    else
        exports.TR_mysql:querry("INSERT INTO tr_fractionsDutyTimes (playerUID, minutes, count, day) VALUES (?, 1, ?, CURDATE())", uid, calculatePlayerMoney(1, tonumber(plrRank[1].level), tonumber(maxRank[1].level), 3300, 6800, 1))
    end
end
addEvent("syncPlayerFractionMinutes", true)
addEventHandler("syncPlayerFractionMinutes", resourceRoot, syncPlayerFractionMinutes)

function calculatePlayerMoney(playerMinutes, playerRank, playerRanks, minimalPayment, maximalPayment, fullHours)
    local fullPayment = minimalPayment + (playerRank-1)/(playerRanks-1) * (maximalPayment-minimalPayment)
    return string.format("%.2f", math.floor(((playerMinutes/60) * fullPayment/fullHours)*100)/100)
end