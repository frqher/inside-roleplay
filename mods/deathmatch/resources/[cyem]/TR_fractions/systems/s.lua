local moverObjects = {2359, 2039, 2040, 2041, 2042, 2043, 2358, 2038, 3082}

function getPlayerLicences(plr)
    if getElementType(plr) == "vehicle" then
        local driver = getVehicleOccupant(plr)
        if not driver then
            triggerClientEvent(client, "openPlayerLicence", resourceRoot, "veh")
            exports.TR_noti:create(plr, "W pojeździe nie ma kierowcy.", "error")
            return
        end
        plr = driver
    end
    local uid = getElementData(plr, "characterUID")
    local data = exports.TR_mysql:querry("SELECT UID, username, created, licence, licenceCreated FROM tr_accounts WHERE UID = ? LIMIT 1", uid)
    if data and data[1] then
        if data[1].licence then
            triggerClientEvent(client, "openPlayerLicence", resourceRoot, true, data)
        else
            triggerClientEvent(client, "openPlayerLicence", resourceRoot, "plr")
        end
        exports.TR_noti:create(plr, string.format("Funkcjonariusz %s sprawdza twoje prawo jazdy.", getPlayerName(client)), "licence")
    end
end
addEvent("getPlayerLicences", true)
addEventHandler("getPlayerLicences", root, getPlayerLicences)

function updateLadderPos(veh, platformRot, ladderRot)
    triggerLatentClientEvent(root, "updateLadderPos", 5000, false, resourceRoot, veh, platformRot, ladderRot)
end
addEvent("updateLadderPos", true)
addEventHandler("updateLadderPos", root, updateLadderPos)

function startVehicleWinch(winchVeh, veh)
    local plr = client

    local winchVehRot = Vector3(getElementRotation(winchVeh))
    local winchVehPos = Vector3(getElementPosition(winchVeh))
    local mover = createObject(moverObjects[math.random(1, #moverObjects)], Vector3(getElementPosition(veh)), winchVehRot)
    attachElements(veh, mover)
    setElementAlpha(mover, 0)
    setElementCollisionsEnabled(mover, false)
    setElementCollisionsEnabled(veh, false)

    setElementData(plr, "hoseEndPos", nil)
    triggerClientEvent(plr, "removeHose", resourceRoot, plr)

    local x, y, z = getPosition(winchVeh, Vector3(0, -10, -0.4))
    local time = getDistanceBetweenPoints2D(winchVehPos.x, winchVehPos.y, x, y) * 1000

    setTimer(function()
        local x, y, z = getPosition(winchVeh, Vector3(0, -10, -0.4))
        local rot = findRotation(x, y, winchVehPos.x, winchVehPos.y)
        moveObject(mover, time, x, y, z, 0, 0, 0, "Linear")
    end, 100, 1)

    setTimer(function()
        local x, y, z = getPosition(winchVeh, Vector3(0, -6.2, 0.4))
        moveObject(mover, 2000, x, y, z, 15, 0, 0, "Linear")
    end, time + 100, 1)

    setTimer(function()
        local x, y, z = getPosition(winchVeh, Vector3(0, -2.8, 0.6))
        moveObject(mover, 2000, x, y, z, -15, 0, 0, "Linear")
    end, time + 2100, 1)

    setTimer(function(winchVeh, veh, mover)
        detachElements(veh, mover)
        destroyElement(mover)

        setTimer(function()
            removeElementData(winchVeh, "blockAction")
            setElementData(winchVeh, "winchPlayer", nil)
            setElementData(winchVeh, "winchedByPlayer", nil)

            setElementData(veh, "winchedByPlayer", nil)
            attachElements(veh, winchVeh, Vector3(0, -2.8, 0.6))

            setElementData(winchVeh, "towedVeh", veh)
        end, 100, 1)
    end, time + 4100, 1, winchVeh, veh, mover)
end
addEvent("startVehicleWinch", true)
addEventHandler("startVehicleWinch", root, startVehicleWinch)


function startVehicleDewinch(winchVeh)
    local plr = client
    local veh = getElementData(winchVeh, "towedVeh")
    if not veh then return end
    detachElements(veh, winchVeh)

    setTimer(function()
        local winchVehRot = Vector3(getElementRotation(winchVeh))
        local winchVehPos = Vector3(getElementPosition(winchVeh))
        local mover = createObject(moverObjects[math.random(1, #moverObjects)], Vector3(getElementPosition(veh)), winchVehRot)
        setElementAlpha(mover, 0)
        setElementCollisionsEnabled(mover, false)
        setElementCollisionsEnabled(veh, false)

        setTimer(function()
            attachElements(veh, mover)
            setTimer(function()
                local x, y, z = getPosition(winchVeh, Vector3(0, -6.2, 0.4))
                moveObject(mover, 2000, x, y, z, 15, 0, 0, "Linear")
            end, 100, 1)

            setTimer(function()
                local x, y, z = getPosition(winchVeh, Vector3(0, -10, -0.4))
                moveObject(mover, 2000, x, y, z, -15, 0, 0, "Linear")
            end, 2100, 1)

            setTimer(function(winchVeh, veh, mover)
                detachElements(veh, mover)
                destroyElement(mover)

                setTimer(function()
                    local x, y, z = getPosition(winchVeh, Vector3(0, -10, -0.4))
                    setElementData(winchVeh, "blockAction", nil)
                    setElementData(winchVeh, "towedVeh", nil)
                    setElementData(winchVeh, "winchVeh", nil)

                    setElementCollisionsEnabled(veh, true)

                    setTimer(function()
                        setElementPosition(veh, x, y, z)
                    end, 100, 1)
                end, 100, 1)
            end, 4100, 1, winchVeh, veh, mover)
        end, 100, 1)
    end, 100, 1)
end
addEvent("startVehicleDewinch", true)
addEventHandler("startVehicleDewinch", root, startVehicleDewinch)



function setPlayerCuffed(player)
    local cuffed = getElementData(client, "cuffed")
    local cuffedBy = getElementData(player, "cuffedBy")
    if isElement(cuffedBy) then
        if cuffedBy ~= client then
            exports.TR_noti:create(client, "Ten gracz ma już założone kajdanki.", "error")
            return
        end
    end

    if isElement(cuffed) then
        if cuffed ~= player then
            exports.TR_noti:create(client, "Nie możesz skuć tego gracza, ponieważ masz już zakutą jedną osobę.", "error")
            return
        end

        removeElementData(player, "cuffedBy")
        removeElementData(player, "animation")
        setPedAnimation(player, nil, nil)

        removeElementData(client, "cuffed")
        detachElements(player, client)

        exports.TR_noti:create(client, "Gracz został pomyślnie rozkuty z kajdanek.", "success")
        exports.TR_noti:create(player, string.format("Gracz %s zdejmuje ci kajdanki.", getPlayerName(client)), "success")
    else
        -- if getElementData(player, "hasBw") then exports.TR_noti:create(client, "Ta osoba jest nieprzytomna i nie możesz jej zakuć w kajdanki.", "success") return end
        setPedAnimation(player, nil, nil)
        removeElementData(player, "tazer")

        setElementData(player, "cuffedBy", client)
        setElementData(client, "cuffed", player)
        setElementData(player, "animation", {"policeCuffs", "dealer_idle"})
        attachElements(player, client, 0, 0.5, 0)

        exports.TR_noti:create(client, "Gracz został pomyślnie zakuty w kajdanki.", "success")
        exports.TR_noti:create(player, string.format("Gracz %s zakłada ci kajdanki.", getPlayerName(client)), "success")
    end
end
addEvent("setPlayerCuffed", true)
addEventHandler("setPlayerCuffed", root, setPlayerCuffed)

function insertCuffedVehicle(vehicle)
    local cuffed = getElementData(client, "cuffed")
    if not cuffed then return end
    local seat2 = getVehicleOccupant(vehicle, 2)
    local seat3 = getVehicleOccupant(vehicle, 3)

    if not isElementAttached(cuffed) then
        removePedFromVehicle(cuffed)
        attachElements(cuffed, client, 0, 0.5, 0)
    else
        if seat2 and seat3 then
            exports.TR_noti:create(client, "W pojeździe nie ma miejsca z tyłu.", "error")
            return
        end

        if not seat2 then
            detachElements(cuffed, client)
            warpPedIntoVehicle(cuffed, vehicle, 2)
            return
        end

        detachElements(cuffed, client)
        warpPedIntoVehicle(cuffed, vehicle, 3)
    end
end
addEvent("insertCuffedVehicle", true)
addEventHandler("insertCuffedVehicle", root, insertCuffedVehicle)



function setPlayerTazered(player)
    if getElementData(player, "tazer") then
        setPedAnimation(player, "crack", "crckdeth2", -1, true, false, false, true)
        return
    end

    setPedAnimation(player, "crack", "crckdeth2", -1, true, false, false, true)
    setElementData(player, "animation", {"crack", "crckdeth2"})
    setElementData(player, "tazer", true)

    setTimer(function()
        if not isElement(player) then return end
        if not getElementData(player, "tazer") then return end
        setPedAnimation(player, nil, nil)
        removeElementData(player, "tazer")
        setElementData(player, "animation", nil)
    end, tazerTime * 1000, 1)
end
addEvent("setPlayerTazered", true)
addEventHandler("setPlayerTazered", root, setPlayerTazered)




function placeObjectSystem(model, x, y, z, rx, ry, rz)
    local objects = getElementData(client, "objectSystem")
    if not objects then objects = {} end

    local obj = createObject(model, x, y, z, rx, ry, rz)
    setElementInterior(obj, getElementInterior(client))
    setElementDimension(obj, getElementDimension(client))
    setElementFrozen(obj, true)

    table.insert(objects, obj)

    setElementData(client, "objectSystem", objects, false)
end
addEvent("placeObjectSystem", true)
addEventHandler("placeObjectSystem", resourceRoot, placeObjectSystem)

function clearObjectsSystem()
    local objects = getElementData(client, "objectSystem")
    if not objects then return end

    destroyElement(objects[#objects])
    table.remove(objects, #objects)
    setElementData(client, "objectSystem", objects)
end
addEvent("clearObjectsSystem", true)
addEventHandler("clearObjectsSystem", resourceRoot, clearObjectsSystem)

function quiverDestroyWheel(wheel)
    local veh = getPedOccupiedVehicle(client)
    if not veh then return end

    if wheel == 1 then
        setVehicleWheelStates(veh, 1)
    elseif wheel == 2 then
        setVehicleWheelStates(veh, -1, 1)
    elseif wheel == 3 then
        setVehicleWheelStates(veh, -1, -1, 1)
    elseif wheel == 4 then
        setVehicleWheelStates(veh, -1, -1, -1, 1)
    end
end
addEvent("quiverDestroyWheel", true)
addEventHandler("quiverDestroyWheel", resourceRoot, quiverDestroyWheel)

function removeObjectsOnQuit()
    local cuffedBy = getElementData(source, "cuffedBy")
    if cuffedBy then
        local policeName = getPlayerName(cuffedBy)
        if not policeName then return end

        local data = {
            prisonIndex = 1,
            time = 1200,
            reason = "Relog podczas zakucia kajdankami.",
            police = policeName,
        }
        exports.TR_mysql:querry("UPDATE tr_accounts SET prisonData = ? WHERE UID = ? LIMIT 1", toJSON(data), getElementData(source, "characterUID"))
    end

    local objects = getElementData(source, "objectSystem")
    if not objects then return end

    for i, v in pairs(objects) do
        if isElement(v) then destroyElement(v) end
    end
end
addEventHandler("onPlayerQuit", root, removeObjectsOnQuit)




function givePlayerTicket(plr, price)
    local uid = getElementData(plr, "characterUID")

    if exports.TR_core:takeMoneyFromPlayer(plr, price) then
        exports.TR_noti:create(plr, string.format("Gracz %s nałożył na ciebie mandat w wysokości $%.2f, który został opłacony na miejscu.", getPlayerName(client), price), "money", 5)
        triggerClientEvent(plr, "addAchievements", resourceRoot, "policeTicket")
    else
        local hasTicket = exports.TR_mysql:querry("SELECT ticketPrice FROM tr_accounts WHERE UID = ? LIMIT 1", uid)
        if hasTicket and hasTicket[1] then
            if hasTicket[1].ticketPrice then
                exports.TR_mysql:querry("UPDATE tr_accounts SET ticketPrice = ticketPrice + ? WHERE UID = ? LIMIT 1", price, uid)
            else
                exports.TR_mysql:querry("UPDATE tr_accounts SET ticketPrice = ? WHERE UID = ? LIMIT 1", price, uid)
            end
        else
            exports.TR_mysql:querry("UPDATE tr_accounts SET ticketPrice = ? WHERE UID = ? LIMIT 1", price, uid)
        end

        exports.TR_noti:create(plr, string.format("Gracz %s nałożył na ciebie mandat w wysokości $%.2f. Został on dodany do systemu, ponieważ nie byłeś w stanie opłacić go na miejscu.", getPlayerName(client), price), "money", 10)
        triggerClientEvent(plr, "addAchievements", resourceRoot, "policeTicket")
    end
    triggerClientEvent(client, "ticketResponse", resourceRoot)
end
addEvent("givePlayerTicket", true)
addEventHandler("givePlayerTicket", resourceRoot, givePlayerTicket)



function givePlayerFireHose(veh)
    exports.TR_weaponSlots:giveWeapon(client, 37, 999999, true)
end
addEvent("givePlayerFireHose", true)
addEventHandler("givePlayerFireHose", resourceRoot, givePlayerFireHose)


function takePlayerFireHose()
    exports.TR_weaponSlots:takeWeapon(client, 37)
end
addEvent("takePlayerFireHose", true)
addEventHandler("takePlayerFireHose", resourceRoot, takePlayerFireHose)


function changePlayerAODO()
    local weapons = getElementData(client, "fakeWeapons")
    local aodo = getElementModel(client) == 278 and "aodoF" or "aodo"

    if weapons then
        local action = "add"
        local newWeapons = {}

        for i, v in pairs(weapons) do
            if v == "aodo" or v == "aodoF" or v == "oxygen" then
                action = "remove"
            else
                table.insert(newWeapons, v)
            end
        end

        if action == "add" then
            table.insert(newWeapons, "oxygen")
            table.insert(newWeapons, aodo)
        end
        setElementData(client, "fakeWeapons", newWeapons)
    else
        setElementData(client, "fakeWeapons", {"oxygen", aodo})
    end
    triggerClientEvent(client, "updateInteraction", resourceRoot)
end
addEvent("changePlayerAODO", true)
addEventHandler("changePlayerAODO", root, changePlayerAODO)

function changePlayerDoorRemover()
    local weapons = getElementData(client, "fakeWeapons")

    if weapons then
        local action = "add"
        local newWeapons = {}

        for i, v in pairs(weapons) do
            if v == "dRemove" then
                action = "remove"
            else
                table.insert(newWeapons, v)
            end
        end

        if action == "add" then
            table.insert(newWeapons, "dRemove")
            exports.TR_noti:create(client, "Podejdź do drzwi samochodu i naciśnij X aby rozpocząć rozpieranie.", "info")
        end
        setElementData(client, "fakeWeapons", newWeapons)
    else
        setElementData(client, "fakeWeapons", {"dRemove"})
        exports.TR_noti:create(client, "Podejdź do drzwi samochodu i naciśnij X aby rozpocząć rozpieranie.", "info")
    end
    triggerClientEvent(client, "updateInteraction", resourceRoot)
end
addEvent("changePlayerDoorRemover", true)
addEventHandler("changePlayerDoorRemover", root, changePlayerDoorRemover)



local eventObjects = {}

function randomizeFireEvent()
    if #eventObjects > 0 then return end

    local num = math.random(1, #eventPositions["f"])
    local event = eventPositions["f"][num]

    if addFractionCustomRequest("f", "Nieznajomy", event.text, event.zone) then
        for i, v in pairs(event.pos) do
            local fire = createElement("fire")
            setElementPosition(fire, v.x, v.y, v.z)
            table.insert(eventObjects, fire)
        end
    end
end
randomizeFireEvent()
setTimer(randomizeFireEvent, 20 * 60 * 1000, 0)



function getPosition(element, vec)
	local rot = Vector3(getElementRotation(element))
	local mat = Matrix(Vector3(getElementPosition(element)), rot)
	local newPos = mat:transformPosition(vec)
	return newPos.x, newPos.y, newPos.z, rot.z
end

function findRotation( x1, y1, x2, y2 )
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end

function extinguishFire(obj)
    for i, v in pairs(eventObjects) do
        if v == obj then
            destroyElement(obj)
            table.remove(eventObjects, i)
            break
        end
    end
end
addEvent("extinguishFire", true)
addEventHandler("extinguishFire", root, extinguishFire)

function givePoliceHandcamMoney()
    exports.TR_core:giveMoneyToPlayer(client, 50)
end
addEvent("givePoliceHandcamMoney", true)
addEventHandler("givePoliceHandcamMoney", resourceRoot, givePoliceHandcamMoney)


function onTrailerAttach(truck)
    if getElementData(source, "blockAction") then
        setTimer(detachTrailer, 50, 1, truck, source)
        return
    end

    setElementFrozen(source, false)
end
addEventHandler("onTrailerAttach", root, onTrailerAttach)

function detachTrailer(truck, trailer)
    if isElement(truck) and isElement(trailer) then
        detachTrailerFromVehicle(truck, trailer)
    end
end


setWeaponProperty(23, "pro", "maximum_clip_ammo", 1)
setWeaponProperty(23, "std", "maximum_clip_ammo", 1)
setWeaponProperty(23, "poor", "maximum_clip_ammo", 1)
setWeaponProperty(26, "poor", "weapon_range", 75)
setWeaponProperty(26, "std", "weapon_range", 75)
setWeaponProperty(26, "pro", "weapon_range", 75)