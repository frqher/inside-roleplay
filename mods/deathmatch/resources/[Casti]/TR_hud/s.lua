function giveHourGift(type)
    if type == "gold" or type == "diamond" then
        exports.TR_core:giveMoneyToPlayer(client, type == "diamond" and 500 or 200)
    end
end
addEvent("giveHourGift", true)
addEventHandler("giveHourGift", resourceRoot, giveHourGift)

function getPlayerCasinoCount()
    local casinoCount = exports.TR_mysql:querry("SELECT casinoChips FROM tr_accounts WHERE UID = ? LIMIT 1", getElementData(client, "characterUID"))
    if not casinoCount or not casinoCount[1] then return end
    triggerClientEvent(client, "updateCasinoCount", resourceRoot, casinoCount[1].casinoChips)
end
addEvent("getPlayerCasinoCount", true)
addEventHandler("getPlayerCasinoCount", resourceRoot, getPlayerCasinoCount)

function setPlayerWalkingStyle(style)
    setPedWalkingStyle(client, style)
end
addEvent("setPlayerWalkingStyle", true)
addEventHandler("setPlayerWalkingStyle", resourceRoot, setPlayerWalkingStyle)