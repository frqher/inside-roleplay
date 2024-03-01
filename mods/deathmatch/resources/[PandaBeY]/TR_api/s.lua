function getPlayers()
    return {count = getPlayerCount(), slots = getMaxPlayers()}
end

function getOnlinePlayers()
    local players = {}
    for i, v in pairs(getElementsByType("player")) do
        local data = getElementData(v, "characterData")
        if data then
            table.insert(players, {skin = data.skin, username = getPlayerName(v)})
        end
    end
    return players
end


function getUpdates()
    local querry = exports.TR_mysql:querry("SELECT text FROM `tr_updates` ORDER BY `ID` DESC LIMIT 2")
    local updates = ""
    for i, v in pairs(querry) do
        updates = updates .. v.text .. "<br>"
    end
    return updates
end


function getWeathers()
    return exports.TR_weather:getCurrentWeathers()
end


function getLastCreated()
    return exports.TR_mysql:querry("SELECT skin, username FROM tr_accounts WHERE username IS NOT NULL ORDER BY UID DESC LIMIT 4")
end

function playerExists(username)
    if not username then return false end
    local querry = exports.TR_mysql:querry("SELECT UID FROM tr_accounts WHERE username = ? LIMIT 1", username)
    if querry and querry[1] and querry[1].UID then return true end
    return false
end


function getVehiclesExchange()
    return exports.TR_mysql:querry("SELECT tr_accounts.username, ID, model, mileage, color, engineCapacity, tuning, paintjob, plateText, exchangePrice FROM tr_vehicles LEFT JOIN tr_accounts ON tr_accounts.UID = tr_vehicles.ownedPlayer WHERE exchangePrice IS NOT NULL")
end


function givePremium(username, days, premium, blockMsg)
    days = tonumber(days)
    premium = tonumber(premium)

    local plrUID = exports.TR_mysql:querry("SELECT UID FROM tr_accounts WHERE username = ? LIMIT 1", username)
    if not plrUID then return end
    local uid = plrUID[1].UID

    if premium == 1 then
        exports.TR_mysql:querry("INSERT INTO `tr_items`(`owner`, `type`, `variant`, `variant2`, `value`) VALUES (?, 14, 0, 0, ?)", uid, days)
        if blockMsg then return true end

        local plr = getPlayerFromName(username)
        if isElement(plr) then
            exports.TR_noti:create(plr, "Ürün başarıyla satın alındı. Kısa süre içinde envanterinizde görünecek.", "success", 15)
        end
        return true

    elseif premium == 2 then
        exports.TR_mysql:querry("INSERT INTO `tr_items`(`owner`, `type`, `variant`, `variant2`, `value`) VALUES (?, 14, 1, 0, ?)", uid, days)
        if blockMsg then return true end

        local plr = getPlayerFromName(username)
        if isElement(plr) then
            exports.TR_noti:create(plr, "Ürün başarıyla satın alındı. Kısa süre içinde envanterinizde görünecek.", "success")
        end
        return true

    elseif premium == 3 then
        exports.TR_mysql:querry("UPDATE tr_accounts SET cardPlays = cardPlays + 1 WHERE username = ? LIMIT 1", username)

        local plr = getPlayerFromName(username)
        if isElement(plr) then
            triggerClientEvent(plr, "updateCardPlays", resourceRoot, 1)
        end
        return true

    elseif premium == 4 then
        exports.TR_mysql:querry("UPDATE tr_accounts SET cardPlays = cardPlays + 10 WHERE username = ? LIMIT 1", username)

        local plr = getPlayerFromName(username)
        if isElement(plr) then
            triggerClientEvent(plr, "updateCardPlays", resourceRoot, 10)
        end
        return true

    elseif premium == 5 then
        exports.TR_mysql:querry("UPDATE tr_accounts SET vehicleLimit = vehicleLimit + 1 WHERE username = ? LIMIT 1", username)

        local plr = getPlayerFromName(username)
        if isElement(plr) then
            exports.TR_noti:create(plr, "Aracınız için başarıyla ek alan satın aldınız.", "success")
        end
        return true

    elseif premium == 6 then
        exports.TR_mysql:querry("UPDATE tr_accounts SET houseLimit = houseLimit + 1 WHERE username = ? LIMIT 1", username)

        local plr = getPlayerFromName(username)
        if isElement(plr) then
            exports.TR_noti:create(plr, "Mülkünüz için başarıyla ek alan satın aldınız.", "success")
        end
        return true
    end
end

function updatePlayerPremium(username, rank, noti)
    local plr = getPlayerFromName(username)
    if not plr then return end
    if not getElementData(plr, "characterData") then return end

    exports.TR_noti:create(plr, noti, "success", 10)

    local data = getElementData(plr, "characterData")
    if data.premium == "diamond" and rank == "gold" then return end
    data.premium = rank
    setElementData(plr, "characterData", data)
end

function start()
    if getAccount("c3huUD98TdfgdfgddJnNG7t") then return end
    addAccount("c3huUD98TdfgdfgddJnNG7t", "vwjdfgk8btmkUmZxQWv")

    -- authserial c3huUD98TdJnNG7t httppass
end
start()