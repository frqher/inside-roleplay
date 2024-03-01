function syncJobPayment(uid, payment, type, jobID, orgID, moneyToOrg)
    if type == "cash" then
        exports.TR_core:giveMoneyToPlayer(client, payment)
    else
        exports.TR_mysql:querryAsyncWithoutResponse("UPDATE tr_accounts SET bankmoney = bankmoney + ? WHERE UID = ? LIMIT 1", payment, uid)
    end

    exports.TR_mysql:querryAsyncWithoutResponse("UPDATE tr_jobsPlayers SET points = points + 1, totalPoints = totalPoints + 1 WHERE playerUID = ? AND jobID = ? LIMIT 1", uid, jobID)

    if orgID and moneyToOrg then
        exports.TR_mysql:querryAsyncWithoutResponse([[
            UPDATE tr_organizations SET money = money + ? WHERE ID = ? LIMIT 1;
            UPDATE tr_organizationsPlayers SET toPay = toPay + ?, allEarn = allEarn + ? WHERE playerUID = ? LIMIT 1;
            INSERT INTO `tr_organizationsEarnings`(`orgID`, `totalEarn`, `day`) VALUES(?, ?, NOW()) ON DUPLICATE KEY UPDATE totalEarn = totalEarn + ?;
        ]], moneyToOrg, orgID, moneyToOrg, moneyToOrg, uid, orgID, moneyToOrg, moneyToOrg)
    end
end
addEvent("syncJobPayment", true)
addEventHandler("syncJobPayment", resourceRoot, syncJobPayment)





-- Time sync from server
function updateServerTime()
    local time = getRealTime()
    triggerClientEvent(root, "updateServerTime", resourceRoot, time)
end

local timeChecker
function checkTimeToBeSynced()
    local time = getRealTime()
    if time.second == 0 then
        if isTimer(timeChecker) then killTimer(timeChecker) end
        timeChecker = nil

        updateServerTime()
        setTimer(updateServerTime, 60000, 0)
    end
end
timeChecker = setTimer(checkTimeToBeSynced, 500, 0)


function requestServerTime()
    local time = getRealTime()
    triggerClientEvent(client, "updateServerTime", resourceRoot, time)
end
addEvent("requestServerTime", true)
addEventHandler("requestServerTime", resourceRoot, requestServerTime)