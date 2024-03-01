local damageTypes = {
	[19] = "roket tarafından öldürüldü",
	[37] = "yandı",
	[49] = "çaprıldı",
	[50] = "bir gülümsemeyle kesildi",
	[51] = "patladı",
	[52] = "araba sürmenin sonucunda",
	[53] = "boğuldu",
	[54] = "yüksekten düştü",
	[55] = "??",
	[56] = "göğüs göğüse çarpışmada öldü",
	[57] = "silahla öldü",
	[59] = "tank patlamasında öldü",
	[63] = "patladı"
}

function onPlayerDied(ammo, killer, weapon)
    exports.TR_weaponSlots:takeAllWeapons(source)
    setElementData(source, "weapons", false)
    setElementData(source, "fakeWeapons", false)

    local skin = getElementModel(source)
    local int = getElementInterior(source)
    local dim = getElementDimension(source)
    local pos = Vector3(getElementPosition(source))

    spawnPlayer(source, pos, 0, skin, int, dim)
    setElementHealth(source, 1)

    setPlayerInBW(source)

    if not source then return end

    local time = getRealTime()
    if isElement(killer) then
        if getElementType(killer) == "player" then
            exports.TR_discord:sendChannelMsg("onPlayerDeath", {
                time = string.format("[%02d:%02d %02d.%02d]", time.hour, time.minute, time.monthday, time.month),
                author = string.format("%s", getPlayerName(source)),
                text = string.format("%s tarafından öldürüldü.", getPlayerName(killer)),
            })
            outputConsole(string.format("%s tarafından öldürüldünüz.", getPlayerName(killer)), source)

        elseif getElementType(killer) == "vehicle" then
            local driver = getVehicleOccupant(killer, 0)
            if driver then
                exports.TR_discord:sendChannelMsg("onPlayerDeath", {
                    time = string.format("[%02d:%02d %02d.%02d]", time.hour, time.minute, time.monthday, time.month),
                    author = string.format("%s", getPlayerName(source)),
                    text = string.format("%s tarafından ezildi.", getPlayerName(driver)),
                })
                outputConsole(string.format("%s tarafından ezildiniz.", getPlayerName(driver)), source)

            else
                exports.TR_discord:sendChannelMsg("onPlayerDeath", {
                    time = string.format("[%02d:%02d %02d.%02d]", time.hour, time.minute, time.monthday, time.month),
                    author = string.format("%s", getPlayerName(source)),
                    text = string.format("Kendisi tarafından ezildi."),
                })
            end
        end

    elseif damageTypes[weapon] then
        exports.TR_discord:sendChannelMsg("onPlayerDeath", {
            time = string.format("[%02d:%02d %02d.%02d]", time.hour, time.minute, time.monthday, time.month),
            author = string.format("%s", getPlayerName(source)),
            text = damageTypes[weapon]..".",
        })
    end
end
addEventHandler("onPlayerWasted", root, onPlayerDied)

function setPlayerInBW(plr)
    local uid = getElementData(plr, "characterUID")
    if not uid then return end

    if exports.TR_events:isPlayerOnEvent(plr) then
        exports.TR_events:playerLoseEvent(plr, true)
        triggerClientEvent(plr, "endBW", resourceRoot)
        return
    end

    local time = 300
    -- if not isElementWithinColShape(plr, DMzone) then
    --     time = 300
    -- end

    exports.TR_fractions:addFractionCustomRequest("m", plr, "Bilincini kaybetti.", {getElementPosition(plr)})

    exports.TR_mysql:querry("UPDATE tr_accounts SET bwTime = ? WHERE bwTime IS NULL AND UID = ? LIMIT 1", time, uid)

    setPedAnimation(source, "PED", "KO_shot_front", -1, false, false, false, true)
    setElementData(source, "animation", {"PED", "KO_shot_front", true})

    local cuffed = getElementData(plr, "cuffed")
    local cuffedBy = getElementData(plr, "cuffedBy")
    if cuffed then
        detachElements(cuffed, plr)
        removeElementData(plr, "cuffed")
        removeElementData(cuffed, "cuffedBy")
        removeElementData(cuffed, "animation")

    elseif cuffedBy then
        detachElements(plr, cuffedBy)
        removeElementData(plr, "cuffedBy")
        removeElementData(cuffedBy, "cuffed")
        removeElementData(cuffedBy, "animation")
    end
end
addEvent("setPlayerInBW", true)
addEventHandler("setPlayerInBW", resourceRoot, setPlayerInBW)

function updatePlayerBwTime(time, blockAnim)
    local uid = getElementData(client, "characterUID")
    if not uid then return end

    if time == 0 then
        exports.TR_mysql:querry("UPDATE tr_accounts SET bwTime = NULL WHERE bwTime IS NOT NULL AND UID = ? LIMIT 1", uid)
        if not getPedOccupiedVehicle(client) then
            if not getElementData(client, "cuffedBy") and not blockAnim then
                setPedAnimation(client, "PED", "getup_front", -1, false, false, false, false)
            end
        end
    else
        exports.TR_mysql:querry("UPDATE tr_accounts SET bwTime = ? WHERE bwTime IS NOT NULL AND UID = ? LIMIT 1", time, uid)
    end
end
addEvent("updatePlayerBwTime", true)
addEventHandler("updatePlayerBwTime", resourceRoot, updatePlayerBwTime)

function removePlayerBW(targetID)
    if not exports.TR_admin:hasPlayerPermission(source, "bwOff") then return end
    if not targetID then triggerClientEvent(source, "showCustomMessage", resourceRoot, "#008a2eKomut kullanımı", "#438f5c/bwoff (id)", "files/images/command.png") return end

    local target = getElementByID("ID"..targetID)
    if not target then exports.TR_noti:create(source, "Belirtilen oyuncu bulunamadı.", "error") return end

    triggerClientEvent(target, "endBW", resourceRoot)
    exports.TR_noti:create(source, string.format("%s canlandırıldı.", getPlayerName(target)), "system")
    exports.TR_noti:create(target, string.format("%s isimli yetkili sizi canlandırdı.", getPlayerName(source)), "system")
end
addEvent("removePlayerBW", true)
addEventHandler("removePlayerBW", root, removePlayerBW)
exports.TR_chat:addCommand("bwoff", "removePlayerBW")

addCommandHandler("bwoff", function(source, cmd, targetID)
    if not exports.TR_admin:hasPlayerPermission(source, "bwOff") then return end
    if not targetID then triggerClientEvent(source, "showCustomMessage", resourceRoot, "#008a2eKomut kullanımı", "#438f5c/bwoff (id)", "files/images/command.png") return end

    local target = getElementByID("ID"..targetID)
    if not target then exports.TR_noti:create(source, "Belirtilen oyuncu bulunamadı.", "error") return end

    triggerClientEvent(target, "endBW", resourceRoot)
    exports.TR_noti:create(source, string.format("%s canlandırıldı.", getPlayerName(target)), "system")
    exports.TR_noti:create(target, string.format("%s isimli yetkili sizi canlandırdı.", getPlayerName(source)), "system")
end)

function getNearestHospital(plr)
    local nearestHospital, closestDist = false, 99999999
    local plrPos = Vector3(getElementPosition(plr))
    for i, v in pairs(hospitals) do
        local dist = getDistanceBetweenPoints3D(plrPos, v.pos)
        if dist < closestDist then
            closestDist = dist
            nearestHospital = v.pos
        end
    end
    return nearestHospital
end