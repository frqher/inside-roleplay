function callPlayerFromPhone(player)
    if not isElement(player) then triggerClientEvent(client, "responsePhone", resourceRoot) return end
    if isElement(getElementData(player, "phone")) then
        setElementData(client, "phone", client)
        triggerClientEvent(client, "responsePhone", resourceRoot, "isPhoning")
        return
    end

    setElementData(player, "phone", client)
    setElementData(client, "phone", player)

    triggerClientEvent(player, "phonePlayer", resourceRoot, client)
    triggerClientEvent(client, "responsePhone", resourceRoot)
end
addEvent("callPlayerFromPhone", true)
addEventHandler("callPlayerFromPhone", resourceRoot, callPlayerFromPhone)

function callPhoneNumber(number)
    if not number then triggerClientEvent(client, "responsePhone", resourceRoot) return end
    if not specialNumbers[number] then triggerClientEvent(client, "invalidCall", resourceRoot) return end

    setElementData(client, "phone", client)
    triggerClientEvent(client, "acceptCall", resourceRoot, false, specialNumbers[number])
    triggerClientEvent(client, "responsePhone", resourceRoot)
end
addEvent("callPhoneNumber", true)
addEventHandler("callPhoneNumber", resourceRoot, callPhoneNumber)

function stopPlayerCall(player)
    removeElementData(client, "phone")

    if not isElement(player) then return end
    removeElementData(player, "phone")
    triggerClientEvent(player, "cancelCall", resourceRoot)
end
addEvent("stopPlayerCall", true)
addEventHandler("stopPlayerCall", resourceRoot, stopPlayerCall)

function acceptPlayerCall(player)
    if not isElement(player) then return end
    triggerClientEvent(player, "acceptCall", resourceRoot)

    setPlayerVoiceIgnoreFrom(client, nil)
    setPlayerVoiceIgnoreFrom(player, nil)
    setPlayerVoiceBroadcastTo(client, player)
    setPlayerVoiceBroadcastTo(player, client)
end
addEvent("acceptPlayerCall", true)
addEventHandler("acceptPlayerCall", resourceRoot, acceptPlayerCall)

function declinePlayerCall(player, useEvent)
    removeElementData(client, "phone")

    if not isElement(player) then return end
    removeElementData(player, "phone")
    if useEvent then triggerClientEvent(player, "declineCall", resourceRoot) end
end
addEvent("declinePlayerCall", true)
addEventHandler("declinePlayerCall", resourceRoot, declinePlayerCall)

function endPlayerCall(player)
    removeElementData(client, "phone")
    setPlayerVoiceIgnoreFrom(client, root)
    setPlayerVoiceBroadcastTo(client, nil)

    if isElement(player) then
        removeElementData(player, "phone")
        triggerClientEvent(player, "endCall", resourceRoot)
        setPlayerVoiceIgnoreFrom(player, root)
        setPlayerVoiceBroadcastTo(player, nil)
    end
end
addEvent("endPlayerCall", true)
addEventHandler("endPlayerCall", resourceRoot, endPlayerCall)


function updatePhoneData(data)
    local uid = getElementData(client, "characterUID")
    if not uid then return end
    exports.TR_mysql:querry("UPDATE tr_accounts SET phone = ? WHERE UID = ?", data, uid)
end
addEvent("updatePhoneData", true)
addEventHandler("updatePhoneData", resourceRoot, updatePhoneData)

function updatePhoneBlocked(data)
    local uid = getElementData(client, "characterUID")
    if not uid then return end
    exports.TR_mysql:querry("UPDATE tr_accounts SET phoneBlocked = ? WHERE UID = ?", data, uid)
end
addEvent("updatePhoneBlocked", true)
addEventHandler("updatePhoneBlocked", resourceRoot, updatePhoneBlocked)

function getPhoneData()
    local uid = getElementData(client, "characterUID")
    if not uid then return end
    local plrData = exports.TR_mysql:querry("SELECT phone, phoneBlocked FROM `tr_accounts` WHERE `UID` = ? LIMIT 1", uid)

    triggerClientEvent(client, "setPhoneData", resourceRoot, plrData[1].phone, plrData[1].phoneBlocked)
end
addEvent("getPhoneData", true)
addEventHandler("getPhoneData", resourceRoot, getPhoneData)

function updatePlayerPhone(plr)
    local uid = getElementData(plr, "characterUID")
    if not uid then return end
    local plrData = exports.TR_mysql:querry("SELECT phone, phoneBlocked FROM `tr_accounts` WHERE `UID` = ? LIMIT 1", uid)

    triggerClientEvent(plr, "setPhoneData", resourceRoot, plrData[1].phone, plrData[1].phoneBlocked)
end
addEvent("updatePlayerPhone", true)
addEventHandler("updatePlayerPhone", root, updatePlayerPhone)


function phoneCommandTalk(...)
    local speaker = getElementData(source, "phone")
    if not speaker then return end
    if not isElement(speaker) then
        removeElementData(source, "phone")
        triggerClientEvent(source, "endCall", resourceRoot)
        return
    end

    local msg = table.concat({...}, " ")

    local sourceName = getPlayerName(source)
    local sourceID = getElementData(source, "ID")

    triggerClientEvent(source, "showCustomMessage", resourceRoot, string.format("#009688[%d] %s", sourceID, sourceName), "#2a8c44"..msg, "files/images/call.png")
    triggerClientEvent(speaker, "showCustomMessage", resourceRoot, string.format("#009688[%d] %s", sourceID, sourceName), "#2a8c44"..msg, "files/images/call.png")
end
addEvent("phoneCommandTalk", true)
addEventHandler("phoneCommandTalk", root, phoneCommandTalk)
exports.TR_chat:addCommand("t", "phoneCommandTalk")

function phoneQuitPlayer()
    local target = getElementData(source, "phone")
    if not target then return end

    removeElementData(target, "phone")
    triggerClientEvent(target, "endCall", resourceRoot)
end
addEventHandler("onPlayerQuit", root, phoneQuitPlayer)


for i, v in pairs(getElementsByType("player")) do
    removeElementData(v, "phone")

    setPlayerVoiceIgnoreFrom(v, nil)
    setPlayerVoiceBroadcastTo(v, root)
end

function blockVoiceAll()
    setPlayerVoiceIgnoreFrom(source, root)
    setPlayerVoiceBroadcastTo(source, nil)

    setPlayerNametagShowing(source, false)
end
addEventHandler("onPlayerJoin", root, blockVoiceAll)