function getComputerData(type, id)
    if type == "fraction" then
        local uid = getElementData(client, "characterUID")
        local fraction = exports.TR_mysql:querry("SELECT fractionID FROM tr_fractionsPlayers WHERE playerUID = ?", uid)
        if not fraction or not fraction[1] then triggerClientEvent(client, "cantOpenComputer", resourceRoot) return end

        local fractionData = exports.TR_mysql:querry("SELECT name, type FROM tr_fractions WHERE ID = ?", fraction[1].fractionID)
        local fractionRanks = exports.TR_mysql:querry("SELECT * FROM tr_fractionsRanks WHERE fractionID = ? LIMIT 20", fraction[1].fractionID)
        local fractionPlayers = exports.TR_mysql:querry("SELECT UID, rankID, username, skin, lastOnline, added, created FROM tr_fractionsPlayers INNER JOIN tr_accounts ON tr_fractionsPlayers.playerUID = tr_accounts.UID WHERE fractionID = ?", fraction[1].fractionID)
        local fractionVehicles = exports.TR_fractions:getFractionVehicles(fraction[1].fractionID)

        for i, v in pairs(fractionPlayers) do
            local todayDutyTime = exports.TR_mysql:querry("SELECT ID, minutes FROM tr_fractionsDutyTimes WHERE playerUID = ? AND day = CURDATE() LIMIT 1", v.UID)
            v.todayDutyTime = todayDutyTime and todayDutyTime[1] and todayDutyTime[1].minutes or 0

            local weekDutyTime = exports.TR_mysql:querry("SELECT SUM(minutes) as minutes FROM tr_fractionsDutyTimes WHERE playerUID = ? AND day <= CURDATE() AND day >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) LIMIT 1", v.UID)
            v.weekDutyTime = weekDutyTime and weekDutyTime[1] and weekDutyTime[1].minutes or 0
        end

        local computerHistory = exports.TR_mysql:querry("SELECT text, name FROM tr_computerLogs WHERE owner = ? AND type = ? ORDER BY ID DESC LIMIT 18", fraction[1].fractionID, "fraction")

        triggerClientEvent(client, "createComputer", resourceRoot, fraction[1].fractionID, fractionData[1].type, "fraction", fractionRanks, fractionPlayers, fractionVehicles, computerHistory)

    elseif type == "organization" then
        local uid = getElementData(client, "characterUID")
        local org = exports.TR_mysql:querry("SELECT orgID FROM tr_organizationsPlayers WHERE playerUID = ? LIMIT 1", uid)
        if not org or not org[1] then triggerClientEvent(client, "cantOpenComputer", resourceRoot) return end
        if tonumber(org[1].orgID) ~= tonumber(id) then triggerClientEvent(client, "cantOpenComputer", resourceRoot) return end

        local orgData = exports.TR_mysql:querry("SELECT ID, type, tr_accounts.username as owner, name, img, interior, tr_organizations.created as created, tr_organizations.money as money, players, vehicles, moneyBonus, rent FROM tr_organizations LEFT JOIN tr_accounts ON tr_organizations.owner = tr_accounts.UID WHERE ID = ? LIMIT 1", org[1].orgID)
        local orgRanks = exports.TR_mysql:querry("SELECT * FROM tr_organizationsRanks WHERE orgID = ? LIMIT 20", id)
        local orgPlayers = exports.TR_mysql:querry("SELECT UID, rankID, username, skin, lastOnline, added, created, tr_organizationsPlayers.toPay as toPay, tr_organizationsPlayers.allEarn as allEarn, tr_organizationsPlayers.allPaid as allPaid FROM tr_organizationsPlayers INNER JOIN tr_accounts ON tr_organizationsPlayers.playerUID = tr_accounts.UID WHERE orgID = ?", id)
        local orgVehicles = exports.TR_mysql:querry("SELECT ID, model, color, paintjob, tuning, ownedOrg, requestOrg FROM tr_vehicles WHERE ownedOrg = ? OR requestOrg = ? ", id, id)

        local computerHistory = exports.TR_mysql:querry("SELECT text, name FROM tr_computerLogs WHERE owner = ? AND type = ? ORDER BY ID DESC LIMIT 18", id, "org")
        local earnMoneyHistory = exports.TR_mysql:querry("SELECT totalEarn, day FROM tr_organizationsEarnings WHERE orgID = ? AND day >= DATE_SUB(NOW(), INTERVAL 7 DAY) ORDER BY day ASC LIMIT 7", org[1].orgID)

        triggerClientEvent(client, "createComputer", resourceRoot, id, orgData[1].type, "organization", orgRanks, orgPlayers, orgVehicles, computerHistory, orgData[1], earnMoneyHistory)

    else
        triggerClientEvent(client, "cantOpenComputer", resourceRoot)
    end
end
addEvent("getComputerData", true)
addEventHandler("getComputerData", root, getComputerData)

function addComputerWorker(isFraction, fractionID, targetUID, rankID, playerName)
    if isFraction then
        local fractionCheck = exports.TR_mysql:querry("SELECT ID FROM tr_fractionsPlayers WHERE playerUID = ? LIMIT 1", targetUID)
        if fractionCheck[1] then
            triggerClientEvent(client, "responseComputer", resourceRoot, false, "Gracz jest już zatrudniony w jakiejś frakcji.", "error")
            return
        end

        exports.TR_mysql:querry("INSERT INTO tr_computerLogs (text, name, owner, type) VALUES (?, ?, ?, ?)", string.format("Zatrudnił gracza %s.", playerName), getPlayerName(client), fractionID, "fraction")
        exports.TR_mysql:querry("INSERT INTO tr_fractionsPlayers (playerUID, fractionID, rankID, added) VALUES (?, ?, ?, NOW())", targetUID, fractionID, rankID)
        local fractionPlayer = exports.TR_mysql:querry("SELECT UID, rankID, username, skin, lastOnline, added, created FROM tr_fractionsPlayers INNER JOIN tr_accounts ON tr_fractionsPlayers.playerUID = tr_accounts.UID WHERE playerUID = ?", targetUID)

        triggerClientEvent(client, "responseComputer", resourceRoot, true, fractionPlayer[1])

    else
        local orgCheck = exports.TR_mysql:querry("SELECT ID FROM tr_organizationsPlayers WHERE playerUID = ? LIMIT 1", targetUID)
        if orgCheck[1] then
            triggerClientEvent(client, "responseComputer", resourceRoot, false, "Gracz jest już zatrudniony w jakiejś organizacji.", "error")
            return
        end

        local getPlayerCount = exports.TR_mysql:querry("SELECT ID FROM tr_organizationsPlayers WHERE orgID = ?", fractionID)
        local fractionPlayers = exports.TR_mysql:querry("SELECT players FROM tr_organizations WHERE ID = ?", fractionID)

        if #getPlayerCount >= fractionPlayers[1].players * 5 then
            triggerClientEvent(client, "responseComputer", resourceRoot, false, "Limit pracowników został osiągnięty. Ulepsz organizację, aby móc zatrudnić więcej osób.", "error")
            return
        end

        exports.TR_mysql:querry("INSERT INTO tr_computerLogs (text, name, owner, type) VALUES (?, ?, ?, ?)", string.format("Zatrudnił gracza %s.", playerName), getPlayerName(client), fractionID, "org")
        exports.TR_mysql:querry("INSERT INTO tr_organizationsPlayers (playerUID, orgID, rankID, added) VALUES (?, ?, ?, NOW())", targetUID, fractionID, rankID)
        local orgPlayers = exports.TR_mysql:querry("SELECT UID, rankID, username, skin, lastOnline, added, created FROM tr_organizationsPlayers INNER JOIN tr_accounts ON tr_organizationsPlayers.playerUID = tr_accounts.UID WHERE playerUID = ?", targetUID)

        local target = getPlayerFromName(playerName)
        if target then
            exports.TR_login:updatePlayerOrganization(target, targetUID)
        end
        triggerClientEvent(client, "responseComputer", resourceRoot, true, orgPlayers[1])
    end
end
addEvent("addComputerWorker", true)
addEventHandler("addComputerWorker", resourceRoot, addComputerWorker)

function removeComputerWorker(isFraction, fractionID, targetUID, playerName)
    if isFraction then
        local fractionCheck = exports.TR_mysql:querry("SELECT ID FROM tr_fractionsPlayers WHERE playerUID = ? AND fractionID = ? LIMIT 1", targetUID, fractionID)
        if not fractionCheck[1] then
            triggerClientEvent(client, "responseComputer", resourceRoot, false, "Gracz nie jest zatrudniony w tej frakcji.", "error")
            return
        end

        exports.TR_mysql:querry("INSERT INTO tr_computerLogs (text, name, owner, type) VALUES (?, ?, ?, ?)", string.format("Zwolnił gracza %s.", playerName), getPlayerName(client), fractionID, "fraction")
        exports.TR_mysql:querry("DELETE FROM tr_fractionsPlayers WHERE playerUID = ? AND fractionID = ? LIMIT 1", targetUID, fractionID)

        triggerClientEvent(client, "responseComputer", resourceRoot, true)

    else
        local orgCheck = exports.TR_mysql:querry("SELECT ID FROM tr_organizationsPlayers WHERE playerUID = ? AND orgID = ? LIMIT 1", targetUID, fractionID)
        if not orgCheck[1] then
            triggerClientEvent(client, "responseComputer", resourceRoot, false, "Gracz nie jest zatrudniony w tej organizacji.", "error")
            return
        end

        exports.TR_mysql:querry("UPDATE tr_accounts INNER JOIN tr_organizationsPlayers ON tr_accounts.UID = tr_organizationsPlayers.playerUID SET tr_accounts.bankMoney = tr_accounts.bankMoney + tr_organizationsPlayers.toPay, tr_organizationsPlayers.toPay = 0 WHERE tr_accounts.bankCode IS NOT NULL AND tr_accounts.UID = ? AND tr_organizationsPlayers.orgID = ?", targetUID, fractionID)
        exports.TR_mysql:querry("INSERT INTO tr_computerLogs (text, name, owner, type) VALUES (?, ?, ?, ?)", string.format("Zwolnił gracza %s.", playerName), getPlayerName(client), fractionID, "org")
        exports.TR_mysql:querry("DELETE FROM tr_organizationsPlayers WHERE playerUID = ? AND orgID = ? LIMIT 1", targetUID, fractionID)
        exports.TR_mysql:querry("UPDATE tr_vehicles SET ownedOrg = NULL, requestOrg = NULL WHERE ownedPlayer = ?", targetUID)

        local target = getPlayerFromName(playerName)
        if target then
            exports.TR_login:updatePlayerOrganization(target, targetUID)
        end

        triggerClientEvent(client, "responseComputer", resourceRoot, true)
    end
end
addEvent("removeComputerWorker", true)
addEventHandler("removeComputerWorker", resourceRoot, removeComputerWorker)

function changeComputerWorkerRank(isFraction, fractionID, targetUID, playerName, rankID, fractionRankName)
    if isFraction then
        local fractionCheck = exports.TR_mysql:querry("SELECT ID FROM tr_fractionsPlayers WHERE playerUID = ? AND fractionID = ? LIMIT 1", targetUID, fractionID)
        if not fractionCheck[1] then
            triggerClientEvent(client, "responseComputer", resourceRoot, false, "Gracz nie jest zatrudniony w tej frakcji.", "error")
            return
        end

        exports.TR_mysql:querry("INSERT INTO tr_computerLogs (text, name, owner, type) VALUES (?, ?, ?, ?)", string.format("Zmienił rangę gracza %s na %s.", playerName, fractionRankName), getPlayerName(client), fractionID, "fraction")
        exports.TR_mysql:querry("UPDATE tr_fractionsPlayers SET rankID = ? WHERE playerUID = ? AND fractionID = ? LIMIT 1", rankID, targetUID, fractionID)

        triggerClientEvent(client, "responseComputer", resourceRoot, true)

    else
        local orgCheck = exports.TR_mysql:querry("SELECT ID FROM tr_organizationsPlayers WHERE playerUID = ? AND orgID = ? LIMIT 1", targetUID, fractionID)
        if not orgCheck[1] then
            triggerClientEvent(client, "responseComputer", resourceRoot, false, "Gracz nie jest zatrudniony w tej organizacji.", "error")
            return
        end

        exports.TR_mysql:querry("INSERT INTO tr_computerLogs (text, name, owner, type) VALUES (?, ?, ?, ?)", string.format("Zmienił rangę gracza %s na %s.", playerName, fractionRankName), getPlayerName(client), fractionID, "org")
        exports.TR_mysql:querry("UPDATE tr_organizationsPlayers SET rankID = ? WHERE playerUID = ? AND orgID = ? LIMIT 1", rankID, targetUID, fractionID)

        triggerClientEvent(client, "responseComputer", resourceRoot, true)
    end
end
addEvent("changeComputerWorkerRank", true)
addEventHandler("changeComputerWorkerRank", resourceRoot, changeComputerWorkerRank)


function changeComputerRankName(isFraction, fractionID, rankID, fractionRankNameOld, fractionRankName)
    if isFraction then
        exports.TR_mysql:querry("INSERT INTO tr_computerLogs (text, name, owner, type) VALUES (?, ?, ?, ?)", string.format("Zmienił nazwę rangi %s na %s.", fractionRankNameOld, fractionRankName), getPlayerName(client), fractionID, "fraction")
        exports.TR_mysql:querry("UPDATE tr_fractionsRanks SET rankName = ? WHERE ID = ? LIMIT 1", fractionRankName, rankID)

        triggerClientEvent(client, "responseComputer", resourceRoot, true)

    else
        exports.TR_mysql:querry("INSERT INTO tr_computerLogs (text, name, owner, type) VALUES (?, ?, ?, ?)", string.format("Zmienił nazwę rangi %s na %s.", fractionRankNameOld, fractionRankName), getPlayerName(client), fractionID, "org")
        exports.TR_mysql:querry("UPDATE tr_organizationsRanks SET rankName = ? WHERE ID = ? LIMIT 1", fractionRankName, rankID)

        triggerClientEvent(client, "responseComputer", resourceRoot, true)
    end
end
addEvent("changeComputerRankName", true)
addEventHandler("changeComputerRankName", resourceRoot, changeComputerRankName)

function removeComputerRank(isFraction, fractionID, fractionRankID, fractionRankName, defaultRankID, rankLevel)
    if isFraction then
        exports.TR_mysql:querry("INSERT INTO tr_computerLogs (text, name, owner, type) VALUES (?, ?, ?, ?)", string.format("Usunął rangę %s.", fractionRankName), getPlayerName(client), fractionID, "fraction")
        exports.TR_mysql:querry("DELETE FROM tr_fractionsRanks WHERE ID = ? LIMIT 1", fractionRankID)
        exports.TR_mysql:querry("UPDATE tr_fractionsPlayers SET rankID = ? WHERE rankID = ?", defaultRankID, fractionRankID)

        exports.TR_mysql:querry("UPDATE tr_fractionsRanks SET level = level - 1 WHERE level >= ? AND fractionID = ?", rankLevel, fractionID)

        local fractionRanks = exports.TR_mysql:querry("SELECT * FROM tr_fractionsRanks WHERE fractionID = ? LIMIT 20", fractionID)

        triggerClientEvent(client, "responseComputer", resourceRoot, true, fractionRanks)

    else
        exports.TR_mysql:querry("INSERT INTO tr_computerLogs (text, name, owner, type) VALUES (?, ?, ?, ?)", string.format("Usunął rangę %s.", fractionRankName), getPlayerName(client), fractionID, "org")
        exports.TR_mysql:querry("DELETE FROM tr_organizationsRanks WHERE ID = ? LIMIT 1", fractionRankID)
        exports.TR_mysql:querry("UPDATE tr_organizationsPlayers SET rankID = ? WHERE rankID = ?", defaultRankID, fractionRankID)

        exports.TR_mysql:querry("UPDATE tr_organizationsRanks SET level = level - 1 WHERE level >= ? AND orgID = ?", rankLevel, fractionID)

        local orgRanks = exports.TR_mysql:querry("SELECT * FROM tr_organizationsRanks WHERE orgID = ? LIMIT 20", fractionID)

        triggerClientEvent(client, "responseComputer", resourceRoot, true, orgRanks)
    end
end
addEvent("removeComputerRank", true)
addEventHandler("removeComputerRank", resourceRoot, removeComputerRank)

function addComputerRank(isFraction, fractionID, rankLevel, fractionRankName)
    if isFraction then
        exports.TR_mysql:querry("INSERT INTO tr_computerLogs (text, name, owner, type) VALUES (?, ?, ?, ?)", string.format("Dodał rangę %s.", fractionRankName), getPlayerName(client), fractionID, "fraction")
        exports.TR_mysql:querry("UPDATE tr_fractionsRanks SET level = level + 1 WHERE level >= ? AND fractionID = ? LIMIT 1", rankLevel, fractionID)

        exports.TR_mysql:querry("INSERT INTO tr_fractionsRanks (level, fractionID, rankName) VALUES (?, ?, ?)", rankLevel, fractionID, fractionRankName)

        local fractionRanks = exports.TR_mysql:querry("SELECT * FROM tr_fractionsRanks WHERE fractionID = ? LIMIT 20", fractionID)

        triggerClientEvent(client, "responseComputer", resourceRoot, true, fractionRanks)

    else
        exports.TR_mysql:querry("INSERT INTO tr_computerLogs (text, name, owner, type) VALUES (?, ?, ?, ?)", string.format("Dodał rangę %s.", fractionRankName), getPlayerName(client), fractionID, "org")
        exports.TR_mysql:querry("UPDATE tr_organizationsRanks SET level = level + 1 WHERE level >= ? AND orgID = ? LIMIT 1", rankLevel, fractionID)

        exports.TR_mysql:querry("INSERT INTO tr_organizationsRanks (level, orgID, rankName) VALUES (?, ?, ?)", rankLevel, fractionID, fractionRankName)

        local orgRanks = exports.TR_mysql:querry("SELECT * FROM tr_organizationsRanks WHERE orgID = ? LIMIT 20", fractionID)

        triggerClientEvent(client, "responseComputer", resourceRoot, true, orgRanks)
    end
end
addEvent("addComputerRank", true)
addEventHandler("addComputerRank", resourceRoot, addComputerRank)

function setComputerRankPermission(isFraction, fractionID, rankID, fractionRankName, permission, state)
    if isFraction then
        exports.TR_mysql:querry("INSERT INTO tr_computerLogs (text, name, owner, type) VALUES (?, ?, ?, ?)", string.format("Zmienił uprawnienia rangi %s.", fractionRankName), getPlayerName(client), fractionID, "fraction")
        exports.TR_mysql:querry(string.format("UPDATE tr_fractionsRanks SET %s = %s WHERE ID = ? LIMIT 1", permission, state and "1" or "NULL"), rankID)

        triggerClientEvent(client, "responseComputer", resourceRoot, true)

    else
        exports.TR_mysql:querry("INSERT INTO tr_computerLogs (text, name, owner, type) VALUES (?, ?, ?, ?)", string.format("Zmienił uprawnienia rangi %s.", fractionRankName), getPlayerName(client), fractionID, "org")
        exports.TR_mysql:querry(string.format("UPDATE tr_organizationsRanks SET %s = %s WHERE ID = ? LIMIT 1", permission, state and "1" or "NULL"), rankID)

        triggerClientEvent(client, "responseComputer", resourceRoot, true)
    end
end
addEvent("setComputerRankPermission", true)
addEventHandler("setComputerRankPermission", resourceRoot, setComputerRankPermission)



function declineComputerVehicle(fractionID, vehicleID, vehicleName)
    exports.TR_mysql:querry("INSERT INTO tr_computerLogs (text, name, owner, type) VALUES (?, ?, ?, ?)", string.format("Odrzucił propozycję przyjęcia pojazdu %s.", vehicleName), getPlayerName(client), fractionID, "org")
    exports.TR_mysql:querry("UPDATE tr_vehicles SET ownedOrg = NULL, requestOrg = NULL WHERE ID = ? LIMIT 1", vehicleID)

    triggerClientEvent(client, "responseComputer", resourceRoot, true)
end
addEvent("declineComputerVehicle", true)
addEventHandler("declineComputerVehicle", resourceRoot, declineComputerVehicle)

function removeComputerVehicle(fractionID, vehicleID, vehicleName)
    exports.TR_mysql:querry("INSERT INTO tr_computerLogs (text, name, owner, type) VALUES (?, ?, ?, ?)", string.format("Odpisał pojazd %s z organizacji.", vehicleName), getPlayerName(client), fractionID, "org")
    exports.TR_mysql:querry("UPDATE tr_vehicles SET ownedOrg = NULL, requestOrg = NULL WHERE ID = ? LIMIT 1", vehicleID)

    local veh = getElementByID("vehicle"..vehicleID)
    if veh then
        setElementData(veh, "vehicleOrganization", nil)
    end

    triggerClientEvent(client, "responseComputer", resourceRoot, true)
end
addEvent("removeComputerVehicle", true)
addEventHandler("removeComputerVehicle", resourceRoot, removeComputerVehicle)

function addComputerVehicle(fractionID, vehicleID, vehicleName)
    local getVehicleCount = exports.TR_mysql:querry("SELECT ID FROM tr_vehicles WHERE ownedOrg = ?", fractionID)
    local fractionVehicle = exports.TR_mysql:querry("SELECT vehicles FROM tr_organizations WHERE ID = ?", fractionID)

    if #getVehicleCount >= fractionVehicle[1].vehicles * 3 then
        triggerClientEvent(client, "responseComputer", resourceRoot, false, "Limit pojazdów został osiągnięty. Ulepsz organizację, aby móc dodawać więcej pojazdów.", "error")
        return
    end

    local veh = getElementByID("vehicle"..vehicleID)
    if veh then
        setElementData(veh, "vehicleOrganization", fractionID)
    end

    exports.TR_mysql:querry("INSERT INTO tr_computerLogs (text, name, owner, type) VALUES (?, ?, ?, ?)", string.format("Przypisał pojazd %s do organizacji.", vehicleName), getPlayerName(client), fractionID, "org")
    exports.TR_mysql:querry("UPDATE tr_vehicles SET ownedOrg = ?, requestOrg = NULL WHERE ID = ? LIMIT 1", fractionID, vehicleID)

    triggerClientEvent(client, "responseComputer", resourceRoot, true)
end
addEvent("addComputerVehicle", true)
addEventHandler("addComputerVehicle", resourceRoot, addComputerVehicle)

function changeComputerOffice(fractionID, officeID, officePrice, officeName)
    local orgInfo = exports.TR_mysql:querry("SELECT money FROM tr_organizations WHERE ID = ? LIMIT 1", fractionID)
    local money = tonumber(orgInfo[1].money)

    if officePrice > money then
        triggerClientEvent(client, "responseComputer", resourceRoot, false, "Organizacja nie posiada tyle pieniędzy aby opłacić nową siedzibę.", "error")
        return
    end

    exports.TR_mysql:querry("UPDATE tr_organizations SET interior = ?, money = money - ?, rent = DATE_ADD(NOW(), INTERVAL 1 DAY) WHERE ID = ? LIMIT 1", officeID, officePrice, fractionID)
    exports.TR_mysql:querry("INSERT INTO tr_computerLogs (text, name, owner, type) VALUES (?, ?, ?, ?)", string.format("Przeniósł siedzibę organizacji do %s.", officeName), getPlayerName(client), fractionID, "org")

    local orgInfo = exports.TR_mysql:querry("SELECT rent FROM tr_organizations WHERE ID = ? LIMIT 1", fractionID)
    triggerClientEvent(client, "responseComputerData", resourceRoot, "info", orgInfo[1].rent)
end
addEvent("changeComputerOffice", true)
addEventHandler("changeComputerOffice", resourceRoot, changeComputerOffice)

function payComputerRent(fractionID, rentPrice)
    local orgInfo = exports.TR_mysql:querry("SELECT money FROM tr_organizations WHERE ID = ? LIMIT 1", fractionID)
    local money = tonumber(orgInfo[1].money)

    if rentPrice > money then
        triggerClientEvent(client, "responseComputer", resourceRoot, false, "Organizacja nie posiada tyle pieniędzy aby uiścić tę opłatę.", "error")
        return
    end

    exports.TR_mysql:querry("UPDATE tr_organizations SET money = money - ?, rent = DATE_ADD(rent, INTERVAL 7 DAY) WHERE ID = ? LIMIT 1", rentPrice, fractionID)
    exports.TR_mysql:querry("INSERT INTO tr_computerLogs (text, name, owner, type) VALUES (?, ?, ?, ?)", "Opłacił organizację na 7 dni.", getPlayerName(client), fractionID, "org")

    local orgInfo = exports.TR_mysql:querry("SELECT rent FROM tr_organizations WHERE ID = ? LIMIT 1", fractionID)
    triggerClientEvent(client, "responseComputerData", resourceRoot, "info_rent", orgInfo[1].rent)
end
addEvent("payComputerRent", true)
addEventHandler("payComputerRent", resourceRoot, payComputerRent)

function payComputerPlayers(fractionID)
    local canPayPlayers = exports.TR_mysql:querry("SELECT ID FROM tr_organizations WHERE DATE_SUB(NOW(), INTERVAL 1 DAY) > lastPayment AND ID = ? LIMIT 1", fractionID)
    if canPayPlayers and canPayPlayers[1] then
        exports.TR_mysql:querry("UPDATE tr_organizations SET lastPayment = NOW() WHERE ID = ? LIMIT 1", fractionID)
        exports.TR_mysql:querry("UPDATE tr_accounts INNER JOIN tr_organizationsPlayers ON tr_accounts.UID = tr_organizationsPlayers.playerUID SET tr_accounts.bankMoney = tr_accounts.bankMoney + tr_organizationsPlayers.toPay, tr_organizationsPlayers.toPay = 0 WHERE tr_accounts.bankCode IS NOT NULL AND tr_organizationsPlayers.orgID = ?", fractionID)
        exports.TR_mysql:querry("INSERT INTO tr_computerLogs (text, name, owner, type) VALUES (?, ?, ?, ?)", "Wypłacił wynagrodzenia pracownikom.", getPlayerName(client), fractionID, "org")

        triggerClientEvent(client, "responseComputer", resourceRoot, true)

    else
        triggerClientEvent(client, "responseComputer", resourceRoot, false, "Çalışanlara henüz ödeme yapamazsınız. Bunun için 24 saat beklemeniz gerekmektedir.", "error")
    end
end
addEvent("payComputerPlayers", true)
addEventHandler("payComputerPlayers", resourceRoot, payComputerPlayers)

function payComputerUpgrade(fractionID, upgrade)
    local upgradeName = false
    if upgrade == 1 then upgradeName = "players" end
    if upgrade == 2 then upgradeName = "vehicles" end
    if upgrade == 3 then upgradeName = "moneyBonus" end

    local upgradeCount = exports.TR_mysql:querry(string.format("SELECT %s, money FROM tr_organizations WHERE ID = ? LIMIT 1", upgradeName), fractionID)
    if upgradeCount and upgradeCount[1] then
        local toPay = 0
        local money = tonumber(upgradeCount[1].money)
        local count = tonumber(upgradeCount[1][upgradeName])
        local upgradeText = ""
        if upgrade == 1 then toPay = count * 15000; upgradeText = "Çalışan sayısını artırdı." end
        if upgrade == 2 then toPay = count * 20000; upgradeText = "Araç sayısını artırdı." end
        if upgrade == 3 then toPay = (count * 50000) + 50000; upgradeText = "Kazanç miktarını artırdı." end

        if toPay > money then
            triggerClientEvent(client, "responseComputer", resourceRoot, false, "Organizasyon bu yükseltmeyi alacak kadar paraya sahip değil.", "error")
            return
        end

        exports.TR_mysql:querry("UPDATE tr_organizations SET money = money - ?, ?? = ?? + 1 WHERE ID = ? LIMIT 1", toPay, upgradeName, upgradeName, fractionID)
        exports.TR_mysql:querry("INSERT INTO tr_computerLogs (text, name, owner, type) VALUES (?, ?, ?, ?)", upgradeText, getPlayerName(client), fractionID, "org")

        triggerClientEvent(client, "responseComputer", resourceRoot, true)

    else
        triggerClientEvent(client, "responseComputer", resourceRoot, false)
    end
end
addEvent("payComputerUpgrade", true)
addEventHandler("payComputerUpgrade", resourceRoot, payComputerUpgrade)
