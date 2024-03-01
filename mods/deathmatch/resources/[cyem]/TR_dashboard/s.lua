function getDashboardData()
    local uid = getElementData(client, "characterUID")
    if not uid then return end

    exports.TR_mysql:querryAsyncMultiselect(
        {
            callback = "onGetDashboardData",
            plr = client,
        },
        [[
            SELECT serial, created, ip, createIP, bankmoney, licence, online, cardPlays, referenced, houseLimit, vehicleLimit, referencedPlayer, TIMESTAMPDIFF(SECOND,NOW(),DATE_ADD(cardPlay, INTERVAL 1 DAY)) as cardTime, CASE WHEN `diamond` > NOW() THEN `diamond` WHEN `gold` > NOW() THEN `gold` ELSE NULL END as 'premiumDate' FROM tr_accounts WHERE UID = ? LIMIT 1;
            SELECT cardPlay FROM tr_accounts WHERE UID = ? AND DATE_ADD(cardPlay, INTERVAL 1 DAY) < NOW() LIMIT 1;
            SELECT UID FROM tr_accounts WHERE referencedPlayer = ? AND online >= 10800;
        ]], uid, uid, uid)
end
addEvent("getDashboardData", true)
addEventHandler("getDashboardData", resourceRoot, getDashboardData)

function onGetDashboardData(data, details)
    triggerClientEvent(data.plr, "setDashboardData", resourceRoot, details[1][1][1], details[2][1], details[3])
end
addEvent("onGetDashboardData", true)
addEventHandler("onGetDashboardData", root, onGetDashboardData)


function loadDashboardData(tab)
    if tab == "vehicle" then
        local uid = getElementData(client, "characterUID")
        local orgID = getElementData(client, "characterOrgID")
        local rentVehicle = false

        local vehData = exports.TR_mysql:querry("SELECT ID, model, color, engineCapacity, engineType, plateText, tuning, paintjob, parking, ownedPlayer, boughtDate, variant FROM tr_vehicles WHERE ownedPlayer = ?", uid)
        if orgID then
            rentVehicle = exports.TR_mysql:querry("SELECT tr_vehicles.ID, model, color, engineCapacity, engineType, plateText, tuning, paintjob, parking, ownedPlayer, boughtDate FROM tr_vehicles LEFT JOIN tr_vehiclesRent ON tr_vehicles.ID = tr_vehiclesRent.vehID WHERE tr_vehiclesRent.plrUID = ? OR (tr_vehicles.ownedOrg = ? AND tr_vehicles.ownedPlayer != ?)", uid, orgID, uid)
        else
            rentVehicle = exports.TR_mysql:querry("SELECT tr_vehicles.ID, model, color, engineCapacity, engineType, plateText, tuning, paintjob, parking, ownedPlayer, boughtDate FROM tr_vehicles LEFT JOIN tr_vehiclesRent ON tr_vehicles.ID = tr_vehiclesRent.vehID WHERE tr_vehiclesRent.plrUID = ?", uid)
        end

        triggerClientEvent(client, "setDashboardData", resourceRoot, vehData, rentVehicle)

    elseif tab == "house" then
        local uid = getElementData(client, "characterUID")
        local orgID = getElementData(client, "characterOrgID")
        local rentVehicle = false

        local houseData = exports.TR_mysql:querry("SELECT ID, date, price, owner, interiorSize, pos FROM tr_houses WHERE owner = ? AND date > NOW()", uid)
        if orgID then
            rentHouses = exports.TR_mysql:querry("SELECT tr_houses.ID, date, price, owner, interiorSize, pos FROM tr_houses LEFT JOIN tr_housesRent ON tr_houses.ID = tr_housesRent.houseID WHERE tr_housesRent.plrUID = ? OR tr_houses.ownedOrg = ?", uid, orgID)
        else
            rentHouses = exports.TR_mysql:querry("SELECT tr_houses.ID, date, price, owner, interiorSize, pos FROM tr_houses LEFT JOIN tr_housesRent ON tr_houses.ID = tr_housesRent.houseID WHERE tr_housesRent.plrUID = ?", uid)
        end

        triggerClientEvent(client, "setDashboardData", resourceRoot, houseData, rentHouses)

    elseif tab == "medal" then
        local achievementEarnedCount = exports.TR_mysql:querry("SELECT COUNT(*) as earnedPlayers, achievement FROM tr_achievements GROUP BY achievement")
        local plrCount = exports.TR_mysql:querry("SELECT UID FROM tr_accounts ORDER BY UID DESC LIMIT 1")

        triggerClientEvent(client, "setDashboardData", resourceRoot, achievementEarnedCount, plrCount[1].UID)

    elseif tab == "penalties" then
        local uid = getElementData(client, "characterUID")
        local penalties = exports.TR_mysql:querry("SELECT ID, serial, reason, time, timeEnd, type, admin FROM tr_penalties WHERE plrUID = ? or username = ? ORDER BY ID DESC LIMIT 10", uid, getPlayerName(client))

        triggerClientEvent(client, "setDashboardData", resourceRoot, penalties)

    elseif tab == "logs" then
        local uid = getElementData(client, "characterUID")
        local logs = exports.TR_mysql:querry("SELECT text, type, serial, date, ip FROM tr_logs WHERE player = ? ORDER BY ID DESC LIMIT 10", uid)

        triggerClientEvent(client, "setDashboardData", resourceRoot, logs)

    elseif tab == "logs" then
        local uid = getElementData(client, "characterUID")
        local logs = exports.TR_mysql:querry("SELECT text, type, serial, date, ip FROM tr_logs WHERE player = ? ORDER BY ID DESC LIMIT 10", uid)

        triggerClientEvent(client, "setDashboardData", resourceRoot, logs)

    elseif tab == "friends" then
        loadPlayerFriends(client)
    end
end
addEvent("loadDashboardData", true)
addEventHandler("loadDashboardData", resourceRoot, loadDashboardData)

function changePlayerPassword(password, newPassword)
    local uid = getElementData(client, "characterUID")
    if not uid then return end

    local passwordCheck = exports.TR_mysql:querry("SELECT password FROM `tr_accounts` WHERE `UID` = ? LIMIT 1", uid)
    if passwordCheck and passwordCheck[1] then
        if passwordVerify(password, passwordCheck[1]["password"]) then
            exports.TR_mysql:querry("UPDATE `tr_accounts` SET password = ? WHERE `UID` = ? LIMIT 1", passwordHash(newPassword, "bcrypt", {"salt"}), uid)
            exports.TR_mysql:querry("INSERT INTO `tr_logs` (player, text, serial, ip, type) VALUES (?, ?, ?, ?, ?)", uid, "Hasło zostało pomyślnie zmienione.", getPlayerSerial(client), getPlayerIP(client), "password")

            triggerClientEvent(client, "setDashboardResponse", resourceRoot, "Şifre başarıyla değiştirildi.", "success", {serial = getPlayerSerial(client), ip = getPlayerIP(client), type = "password", text = "Şifre başarıyla değiştirildi."})
        else
            triggerClientEvent(client, "setDashboardResponse", resourceRoot, "Mevcut şifre yanlış.", "error")
        end
    else
        triggerClientEvent(client, "setDashboardResponse", resourceRoot, "Şifre değiştirme başarısız.", "error")
    end
end
addEvent("changePlayerPassword", true)
addEventHandler("changePlayerPassword", resourceRoot, changePlayerPassword)

function getLastVehicleDrivers(vehID)
    local lastDrivers = exports.TR_mysql:querry("SELECT username, driveDate FROM tr_vehiclesDrivers LEFT JOIN tr_accounts ON tr_vehiclesDrivers.driverUID = tr_accounts.UID WHERE vehID = ? ORDER BY ID DESC LIMIT 12", vehID)
    triggerClientEvent(client, "loadVehicleDashboardInspect", resourceRoot, lastDrivers)
end
addEvent("getLastVehicleDrivers", true)
addEventHandler("getLastVehicleDrivers", resourceRoot, getLastVehicleDrivers)

function changePlayerEmail(email, newEmail)
    local uid = getElementData(client, "characterUID")
    if not uid then return end

    local emailCheck = exports.TR_mysql:querry("SELECT email FROM `tr_accounts` WHERE `UID` = ? LIMIT 1", uid)
    if emailCheck and emailCheck[1] then
        if email == emailCheck[1]["email"] then
            exports.TR_mysql:querry("UPDATE `tr_accounts` SET email = ? WHERE `UID` = ? LIMIT 1", newEmail, uid)
            exports.TR_mysql:querry("INSERT INTO `tr_logs` (player, text, serial, ip, type) VALUES (?, ?, ?, ?, ?)", uid, "Adres email został pomyślnie zmieniony.", getPlayerSerial(client), getPlayerIP(client), "email")

            triggerClientEvent(client, "setDashboardResponse", resourceRoot, "E-posta adresi başarıyla değiştirildi.", "success", {serial = getPlayerSerial(client), ip = getPlayerIP(client), type = "email", text = "E-posta adresi başarıyla değiştirildi."})
        else
            triggerClientEvent(client, "setDashboardResponse", resourceRoot, "Geçerli e-posta adresi yanlış.", "error")
        end
    else
        triggerClientEvent(client, "setDashboardResponse", resourceRoot, "E-posta adresi değiştirilemedi.", "error")
    end
end
addEvent("changePlayerEmail", true)
addEventHandler("changePlayerEmail", resourceRoot, changePlayerEmail)

function playPlayerCards(dayCards)
    local uid = getElementData(client, "characterUID")
    if not uid then return end

    if dayCards then
        exports.TR_mysql:querry("UPDATE `tr_accounts` SET cardPlay = NOW() WHERE `UID` = ? LIMIT 1", uid)
    else
        exports.TR_mysql:querry("UPDATE `tr_accounts` SET cardPlays = cardPlays - 1 WHERE `UID` = ? LIMIT 1", uid)
    end
end
addEvent("playPlayerCards", true)
addEventHandler("playPlayerCards", resourceRoot, playPlayerCards)

function playerPickCard(type, amount)
    local uid = getElementData(client, "characterUID")
    if not uid then return end

    if type == "repeat" then
        exports.TR_mysql:querry("UPDATE `tr_accounts` SET cardPlays = cardPlays + 1 WHERE `UID` = ? LIMIT 1", uid)
    elseif type == "money" then
        exports.TR_core:giveMoneyToPlayer(client, amount)
    elseif type == "money" then
        exports.TR_core:giveMoneyToPlayer(client, amount)
    elseif type == "drugs" then
        -- exports.TR_core:giveMoneyToPlayer(client, amount)
    elseif type == "beer" then
        -- exports.TR_core:giveMoneyToPlayer(client, amount)
    elseif type == "gold" then
        exports.TR_api:givePremium(getPlayerName(client), amount, 1)
    elseif type == "diamond" then
        exports.TR_api:givePremium(getPlayerName(client), amount, 2)
    end
end
addEvent("playerPickCard", true)
addEventHandler("playerPickCard", resourceRoot, playerPickCard)


function switchSMS(setOn)
    if setOn then
        removeElementData(client, "smsOff")
    else
        setElementData(client, "smsOff", true, false)
    end
end
addEvent("switchSMS", true)
addEventHandler("switchSMS", resourceRoot, switchSMS)

function getPlayerReference()
    local uid = getElementData(client, "characterUID")
    exports.TR_mysql:querry("UPDATE tr_accounts SET referenced = referenced + 1 WHERE UID = ?", uid)

    exports.TR_api:givePremium(getPlayerName(client), 3, 1)
    exports.TR_core:giveMoneyToPlayer(client, 5000)
    triggerClientEvent(client, "setDashboardResponse", resourceRoot, "reference")
end
addEvent("getPlayerReference", true)
addEventHandler("getPlayerReference", resourceRoot, getPlayerReference)

function useDashboardReferenceCode(reference)
    local uid = getElementData(client, "characterUID")

    if reference then
        local referenceUID = teaDecodeBinary(reference, "XayDpN36bGKGvfbD")
        if tonumber(referenceUID) == nil or string.len(referenceUID) < 1 then
            exports.TR_noti:create(client, "Kod yanlış.", "error")
            return
        end
        if referenceUID == uid then
            exports.TR_noti:create(client, "Kendi kodunuzu kullanamazsınız.", "error")
            return
        end

        exports.TR_core:giveMoneyToPlayer(client, 500)
        exports.TR_mysql:querry("UPDATE tr_accounts SET referencedPlayer = ? WHERE UID = ? LIMIT 1", referenceUID, uid)

        exports.TR_noti:create(client, "Kod başarıyla kullanıldı.", "success")

        triggerClientEvent(client, "setDashboardResponse", resourceRoot, "referenceAdded")
    end
end
addEvent("useDashboardReferenceCode", true)
addEventHandler("useDashboardReferenceCode", resourceRoot, useDashboardReferenceCode)

function teaDecodeBinary(data, key)
    return base64Decode(teaDecode(data, key))
end


-- Friends
function loadPlayerFriends(plr, onLogin)
    local uid = getElementData(plr, "characterUID")
    local friends = exports.TR_mysql:querry("SELECT UID, username, friendsFor, lastOnline, skin FROM tr_friends LEFT JOIN tr_accounts ON tr_accounts.UID = tr_friends.target WHERE sender = ?", uid)
    local friends2 = exports.TR_mysql:querry("SELECT UID, username, friendsFor, lastOnline, skin FROM tr_friends LEFT JOIN tr_accounts ON tr_accounts.UID = tr_friends.sender WHERE target = ?", uid)

    triggerClientEvent(plr, "loadPlayerFriends", resourceRoot, friends, friends2)
    if onLogin then
        triggerClientEvent(root, "onFriendLogin", resourceRoot, plr, getPlayerName(plr))
    end
end
addEvent("loadPlayerFriends", true)
addEventHandler("loadPlayerFriends", resourceRoot, loadPlayerFriends)

function requestPlayerToFriends(name)
    local uid = getElementData(client, "characterUID")

    local target = exports.TR_mysql:querry("SELECT UID FROM tr_accounts WHERE username = ? LIMIT 1", name)
    if target and target[1] then
        local send = exports.TR_mysql:querry("SELECT ID, friendsFor FROM tr_friends WHERE sender = ? AND target = ? LIMIT 1", uid, target[1].UID)
        if send and send[1] then
            if send[1].friendsFor then
                triggerClientEvent(client, "setDashboardResponse", resourceRoot, "Zaten arkadaşsınız.", "info")
            else
                triggerClientEvent(client, "setDashboardResponse", resourceRoot, "Bu oyuncuya zaten davet gönderdiniz.", "info")
            end
            return
        end

        local recieved = exports.TR_mysql:querry("SELECT ID, friendsFor FROM tr_friends WHERE sender = ? AND target = ? LIMIT 1", target[1].UID, uid)
        if recieved and recieved[1] then
            if recieved[1].friendsFor then
                triggerClientEvent(client, "setDashboardResponse", resourceRoot, "Zaten arkadaşsınız.", "info")
            else
                triggerClientEvent(client, "setDashboardResponse", resourceRoot, "Bu oyuncudan bekleyen bir davetiniz var.", "info")
            end
            return
        end

        exports.TR_mysql:querry("INSERT INTO tr_friends (sender, target) VALUES (?, ?)", uid, target[1].UID)
        loadPlayerFriends(client)
        triggerClientEvent(client, "setDashboardResponse", resourceRoot, string.format("Oyuncu %s başarıyla arkadaşınıza davet edildi.", name), "success")

        local target = getPlayerFromName(name)
        if isElement(target) then
            if getElementData(target, "characterUID") then
                exports.TR_noti:create(target, string.format("Oyuncu %s sizi arkadaş olarak eklemek istiyor.", getPlayerName(client)), "info")
            end
        end
    else
        triggerClientEvent(client, "setDashboardResponse", resourceRoot, "Gracz nie został znaleziony.", "error")
    end
end
addEvent("requestPlayerToFriends", true)
addEventHandler("requestPlayerToFriends", resourceRoot, requestPlayerToFriends)

function acceptPlayerFriend(targetUID, username)
    local uid = getElementData(client, "characterUID")

    exports.TR_mysql:querry("UPDATE tr_friends SET friendsFor = CURDATE() WHERE sender = ? AND target = ? LIMIT 1", targetUID, uid)
    loadPlayerFriends(client)
    triggerClientEvent(client, "setDashboardResponse", resourceRoot, string.format("%s arkadaşınıza eklendi.", username), "success")
end
addEvent("acceptPlayerFriend", true)
addEventHandler("acceptPlayerFriend", resourceRoot, acceptPlayerFriend)

function removePlayerFriend(targetUID, username, canceled)
    local uid = getElementData(client, "characterUID")
    exports.TR_mysql:querry("DELETE FROM tr_friends WHERE (sender = ? AND target = ?) OR (sender = ? AND target = ?) LIMIT 1", targetUID, uid, uid, targetUID)
    loadPlayerFriends(client)

    if not canceled then
        triggerClientEvent(client, "setDashboardResponse", resourceRoot, string.format("%s arkadaşınızdan çıkarıldı.", username), "success")
    else
        triggerClientEvent(client, "setDashboardResponse", resourceRoot, string.format("%s listeden çıkarıldı.", username), "success")
    end
end
addEvent("removePlayerFriend", true)
addEventHandler("removePlayerFriend", resourceRoot, removePlayerFriend)