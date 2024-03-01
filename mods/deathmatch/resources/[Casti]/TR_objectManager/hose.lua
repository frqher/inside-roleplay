hoseData = {}

function createHose(...)
    triggerClientEvent(root, "createHose", resourceRoot, ...)
end
addEvent("createHose", true)
addEventHandler("createHose", root, createHose)

function getHoseData()
    triggerClientEvent(root, "updateHoseData", resourceRoot, hoseData)
end
addEvent("getHoseData", true)
addEventHandler("getHoseData", resourceRoot, getHoseData)

function updatePlayerHose(...)
    hoseData[client] = arg[1]
    triggerClientEvent(root, "updatePlayerHose", resourceRoot, client, arg[1])
end
addEvent("updatePlayerHose", true)
addEventHandler("updatePlayerHose", resourceRoot, updatePlayerHose)

function removePlayerHose()
    hoseData[client] = nil
    triggerClientEvent(root, "removeHose", resourceRoot, client)
end
addEvent("removePlayerHose", true)
addEventHandler("removePlayerHose", resourceRoot, removePlayerHose)