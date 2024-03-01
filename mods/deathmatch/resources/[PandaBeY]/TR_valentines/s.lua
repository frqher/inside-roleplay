function playerSelectEventPrize(prize)
    local uid = getElementData(client, "characterUID")
    if prize == "money" then
        exports.TR_core:giveMoneyToPlayer(client, 5000)
        exports.TR_mysql:querry("UPDATE tr_santaGifts SET takenTime = NOW(), money = money + 1 WHERE playerUID = ? LIMIT 1", uid)

    elseif prize == "gold" then
        local _, rows = exports.TR_mysql:querry(string.format("UPDATE tr_accounts SET gold = DATE_ADD(gold, INTERVAL %d DAY) WHERE username = ? AND gold >= NOW() LIMIT 1", 3), getPlayerName(client))
        if rows > 0 then
            updatePlayerPremium(client, "gold")

        else
            local _, rows = exports.TR_mysql:querry(string.format("UPDATE tr_accounts SET gold = DATE_ADD(NOW(), INTERVAL %d DAY) WHERE username = ? AND (gold <= NOW() OR gold IS NULL) LIMIT 1", 3), getPlayerName(client))
            if rows > 0 then
                updatePlayerPremium(client, "gold")
            end
        end
        exports.TR_mysql:querry("UPDATE tr_santaGifts SET takenTime = NOW(), gold = gold + 1 WHERE playerUID = ? LIMIT 1", uid)


    elseif prize == "diamond" then
        local _, rows = exports.TR_mysql:querry(string.format("UPDATE tr_accounts SET diamond = DATE_ADD(diamond, INTERVAL %d DAY) WHERE username = ? AND diamond >= NOW() LIMIT 1", 1), getPlayerName(client))
        if rows > 0 then
            updatePlayerPremium(client, "diamond")

        else
            local _, rows = exports.TR_mysql:querry(string.format("UPDATE tr_accounts SET diamond = DATE_ADD(NOW(), INTERVAL %d DAY) WHERE username = ? AND (diamond <= NOW() OR diamond IS NULL) LIMIT 1", 1), getPlayerName(client))
            if rows > 0 then
                updatePlayerPremium(client, "diamond")
            end
        end
        exports.TR_mysql:querry("UPDATE tr_santaGifts SET takenTime = NOW(), diamond = diamond + 1 WHERE playerUID = ? LIMIT 1", uid)

    elseif prize == "garage" then
        local uid = getElementData(client, "characterUID")
        exports.TR_mysql:querry("UPDATE tr_accounts SET vehicleLimit = vehicleLimit + 1 WHERE UID = ? LIMIT 1", uid)
        exports.TR_mysql:querry("UPDATE tr_santaGifts SET takenTime = NOW(), vehicle = vehicle + 1 WHERE playerUID = ? LIMIT 1", uid)

    elseif prize == "houses" then
        local uid = getElementData(client, "characterUID")
        exports.TR_mysql:querry("UPDATE tr_accounts SET houseLimit = houseLimit + 1 WHERE UID = ? LIMIT 1", uid)
        exports.TR_mysql:querry("UPDATE tr_santaGifts SET takenTime = NOW(), house = house + 1 WHERE playerUID = ? LIMIT 1", uid)

    end

    triggerClientEvent(client, "playerSelectEventPrize", resourceRoot, prize)
end
addEvent("playerSelectEventPrize", true)
addEventHandler("playerSelectEventPrize", root, playerSelectEventPrize)

function updatePlayerPremium(plr, rank)
    if not getElementData(plr, "characterData") then return end

    local data = getElementData(plr, "characterData")
    if data.premium == "diamond" and rank == "gold" then return end
    data.premium = rank
    setElementData(plr, "characterData", data)
end