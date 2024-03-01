local settings = {
    paymentBonus = 1,
    jobRooms = {},

    prizes = {
        50000, 35000, 15000, 5000, 5000, 5000, 5000
    },
}

function giveJobPayment(amount, isTime, paymentType, jobID, blockPoints)
    local uid = getElementData(client, "characterUID")
    local payment, ticket, ticketFull = calculatePlayerPayment(client, amount)

    if not paymentType or paymentType == "cash" then
        exports.TR_core:giveMoneyToPlayer(client, payment)
    else
        exports.TR_mysql:querry("UPDATE tr_accounts SET bankmoney = bankmoney + ? WHERE UID = ? LIMIT 1", payment, uid)
    end

    giveMoneyToOrganization(client, amount)

    local pointsAdd = nil
    if math.random(1, 10) <= 2 and not blockPoints then
        pointsAdd = math.random(1, 3)
        setElementData(client, "characterPoints", getElementData(client, "characterPoints") + pointsAdd)
    end

    if jobID then
        exports.TR_mysql:querry("UPDATE tr_jobsPlayers SET points = points + 1, totalPoints = totalPoints + 1 WHERE playerUID = ? AND jobID = ? LIMIT 1", uid, jobID)
    end

    if isTime then
        exports.TR_noti:create(client, string.format("10 dakika çalıştığınız için $%.2f kazandınız.", payment), "money")
    else
        if pointsAdd then
            exports.TR_noti:create(client, string.format("Çalışmanız için $%.2f ve %d deneyim puanı kazandınız.", payment, pointsAdd), "money")
        else
            exports.TR_noti:create(client, string.format("Çalışmanız için $%.2f kazandınız.", payment), "money")
        end
    end
    if ticket then exports.TR_noti:create(client, string.format("Ödenmemiş cezalarınızdan dolayı $%.2f kesinti yapıldı. Ödenmemiş cezalarınız için $%.2f kaldı.", ticket, ticketFull), "info", 5) end
    

    triggerClientEvent(client, "addAchievements", resourceRoot, "firstMoney")
end
addEvent("giveJobPayment", true)
addEventHandler("giveJobPayment", root, giveJobPayment)

function giveMoneyToOrganization(plr, amount)
    local uid = getElementData(plr, "characterUID")
    local orgID = getElementData(plr, "characterOrgID")
    local orgType = getElementData(plr, "characterOrgType")
    if not orgID or orgType == "crime" then return end

    local moneyPercent = getElementData(plr, "characterOrgMoneyPercent") or 0
    local percent = tonumber(moneyPercent)/100 + 0.05
    local money = math.floor(amount * percent * 100)/100

    local orgMoneyAdd = getElementData(plr, "orgMoneyAdd")
    if not orgMoneyAdd then
        setElementData(plr, "orgMoneyAdd", {
            total = money,
            count = 1,
        }, false)
        return
    end
    if orgMoneyAdd.count < 5 then
        setElementData(plr, "orgMoneyAdd", {
            total = orgMoneyAdd.total + money,
            count = orgMoneyAdd.count + 1,
        }, false)
        return
    end

    exports.TR_mysql:querry([[
        UPDATE tr_organizations SET money = money + ? WHERE ID = ? LIMIT 1;
        UPDATE tr_organizationsPlayers SET toPay = toPay + ?, allEarn = allEarn + ? WHERE playerUID = ? LIMIT 1;
        INSERT INTO `tr_organizationsEarnings`(`orgID`, `totalEarn`, `day`) VALUES(?, ?, NOW()) ON DUPLICATE KEY UPDATE totalEarn = totalEarn + ?;
    ]], orgMoneyAdd.total, orgID, orgMoneyAdd.total, orgMoneyAdd.total, uid, orgID, orgMoneyAdd.total, orgMoneyAdd.total)

    setElementData(plr, "orgMoneyAdd", {
        total = money,
        count = 1,
    }, false)
end


function changeJobSkin(obj, skin)
    setElementModel(client, skin)
    removeAdditionalWeapons(client)

    triggerClientEvent(client, "updateInteraction", resourceRoot, "jobInfo")
end
addEvent("changeJobSkin", true)
addEventHandler("changeJobSkin", root, changeJobSkin)

function endJob()
    local data = getElementData(client, "characterData")

    if tonumber(data.skin) ~= nil then
        setElementModel(client, data.skin)
        setElementData(client, "customModel", nil)
    else
        setElementModel(client, 0)
        setElementData(client, "customModel", data.skin)
    end

    removeElementData(client, "govJob")
end
addEvent("endJob", true)
addEventHandler("endJob", root, endJob)



function calculatePlayerPayment(plr, amount)
    local data = getElementData(plr, "characterData")
    local multiplayer = settings.paymentBonus

    if data.premium == "diamond" then multiplayer = multiplayer + 0.1
    elseif data.premium == "gold" then multiplayer = multiplayer + 0.05 end

    local totalPrice = amount * multiplayer
    local forTicket = false
    local ticketPrice = false

    local ticketPrice = getElementData(plr, "ticketPrice")
    if ticketPrice then
        if ticketPrice > 0 then
            forTicket = math.min(totalPrice * 0.25, ticketPrice)

            totalPrice = totalPrice - forTicket
            ticketPrice = ticketPrice - forTicket

            setElementData(plr, "ticketPrice", ticketPrice)
        end
    end

    return totalPrice, forTicket, ticketPrice
end

function removeAdditionalWeapons(plr)
    local weapons = getElementData(plr, "fakeWeapons")
    if not weapons then return end
    local newWeapons = {}

    for i, v in pairs(weapons) do
        if type(v) == "number" then
            table.insert(newWeapons, v)
        end
    end

    setElementData(plr, "fakeWeapons", newWeapons)
end



function getPlayerJobData(jobID)
    local uid = getElementData(client, "characterUID")
    if not uid then return end

    local jobData = exports.TR_mysql:querry("SELECT points, totalPoints, upgrades FROM tr_jobsPlayers WHERE playerUID = ? AND jobID = ? LIMIT 1", uid, jobID)
    if not jobData or not jobData[1] then
        exports.TR_mysql:querry("INSERT INTO `tr_jobsPlayers`(`playerUID`, `jobID`, `points`, `totalPoints`, `upgrades`) VALUES (?, ?, 0, 0, ?)", uid, jobID, "[]")
        jobData = {{points = 0, totalPoints = 0, upgrades = "[]"}}
    end

    local muteData = exports.TR_mysql:querry("SELECT ID FROM `tr_penalties` WHERE serial = ? AND timeEnd > NOW() AND type = 'license' AND takenBy IS NULL LIMIT 1", getPlayerSerial(client))
    triggerClientEvent(client, "createJobWindow", resourceRoot, jobID, jobData[1], muteData)
end
addEvent("getPlayerJobData", true)
addEventHandler("getPlayerJobData", root, getPlayerJobData)

function getPlayerJobTabData(jobID, type)
    if type == "getJobPrizes" then
        local uid = getElementData(client, "characterUID")
        local playerPrize = exports.TR_mysql:querry("SELECT SUM(amount) as prize FROM tr_jobsPlayersPrizes WHERE playerUID = ? AND jobID = ?", uid, jobID)

        triggerClientEvent(client, "updatePlayerJobTabData", resourceRoot, playerPrize[1])

    elseif type == "rank" then
        local topPlayers = exports.TR_mysql:querry("SELECT username, totalPoints FROM tr_accounts LEFT JOIN tr_jobsPlayers ON tr_jobsPlayers.playerUID = tr_accounts.UID WHERE tr_jobsPlayers.jobID = ? ORDER BY tr_jobsPlayers.totalPoints DESC LIMIT 7", jobID)
        triggerClientEvent(client, "updatePlayerJobTabData", resourceRoot, topPlayers)
    end
end
addEvent("getPlayerJobTabData", true)
addEventHandler("getPlayerJobTabData", root, getPlayerJobTabData)

function payoutJobPrizes(jobID)
    local uid = getElementData(client, "characterUID")
    if not uid then return end

    local playerPrize = exports.TR_mysql:querry("SELECT SUM(amount) as prize FROM tr_jobsPlayersPrizes WHERE playerUID = ? AND jobID = ?", uid, jobID)
    if playerPrize and playerPrize[1] then
        if exports.TR_core:giveMoneyToPlayer(client, playerPrize[1].prize) then
            exports.TR_mysql:querry("DELETE FROM tr_jobsPlayersPrizes WHERE playerUID = ? AND jobID = ?", uid, jobID)
            triggerClientEvent(client, "responseJobPrizes", resourceRoot)
        end
    end
end
addEvent("payoutJobPrizes", true)
addEventHandler("payoutJobPrizes", resourceRoot, payoutJobPrizes)


function buyJobUpgrade(jobID, cost, upgrades)
    local uid = getElementData(client, "characterUID")
    if not uid then return end

    exports.TR_mysql:querry("UPDATE tr_jobsPlayers SET points = points - ?, upgrades = ? WHERE playerUID = ? AND jobID = ? LIMIT 1", cost, upgrades, uid, jobID)

    triggerClientEvent(client, "updateJobUpgrade", resourceRoot)
end
addEvent("buyJobUpgrade", true)
addEventHandler("buyJobUpgrade", root, buyJobUpgrade)

function givePlayerJobPoints(jobID, points, plural)
    local uid = getElementData(client, "characterUID")
    if not uid then return end

    exports.TR_noti:create(client, string.format("Kazandınız: %d %s. Kazandığınız puanlarla işte yükseltmeler satın alabilirsiniz.", points and tonumber(points) or 1, plural and plural or "puan"), "success")
    exports.TR_mysql:querry(string.format("UPDATE tr_jobsPlayers SET points = points + %d, totalPoints = totalPoints + %d WHERE playerUID = ? AND jobID = ? LIMIT 1", points and tonumber(points) or 1, points and tonumber(points) or 1), uid, jobID)
end
addEvent("givePlayerJobPoints", true)
addEventHandler("givePlayerJobPoints", root, givePlayerJobPoints)

function removePlayerFromJobVehicle(x, y, z, int, dim)
    removePedFromVehicle(client)

    if x and y and z then
        setTimer(function(client)
            setElementPosition(client, x, y, z)
            setElementInterior(client, int or 0)
            setElementDimension(client, dim or 0)
        end, 100, 1, client)
    end
end
addEvent("removePlayerFromJobVehicle", true)
addEventHandler("removePlayerFromJobVehicle", root, removePlayerFromJobVehicle)


addCommandHandler("zarobki", function(plr, cmd, value)
    if not exports.TR_admin:hasPlayerPermission(plr, "isDev") then return end

    local val = tonumber(value)
    if not val then exports.TR_noti:create(plr, string.format("Mevcut kazanç çarpanı %.1f dir", settings.paymentBonus), "info") return end

    settings.paymentBonus = val
    exports.TR_noti:create(plr, string.format("Çekirdek çarpanı %.1f olarak ayarlandı", settings.paymentBonus), "info")
end)





function addJobRoom(jobID)
    if not settings.jobRooms[jobID] then settings.jobRooms[jobID] = {} end

    local ownerName = getPlayerName(client)
    table.insert(settings.jobRooms[jobID], {
        owner = ownerName,
        players = {
            {
                player = client,
                name = ownerName,
                ready = false,
                id = getElementData(client, "ID"),
                color = getPlayerColor(client),
            },
        },
        messages = {},
    })
    updateNearRooms(client, jobID)
end
addEvent("addJobRoom", true)
addEventHandler("addJobRoom", resourceRoot, addJobRoom)

function joinJobRoom(jobID, roomOwner, maxPlayers)
    if not settings.jobRooms[jobID] then
        triggerClientEvent(client, "responseJobWindow", resourceRoot, true)
        exports.TR_noti:create(client, "Böyle bir barış yok.", "error")
        return
    end

    for i, v in pairs(settings.jobRooms[jobID]) do
        if roomOwner == v.owner then
            if #v.players >= maxPlayers then
                triggerClientEvent(client, "responseJobWindow", resourceRoot, true)
                exports.TR_noti:create(client, "Bu oda dolu.", "error")
                return
            end

            table.insert(v.players, {
                player = client,
                name = getPlayerName(client),
                id = getElementData(client, "ID"),
                ready = false,
                color = getPlayerColor(client),
            })

            updateNearRooms(client, jobID)
            break
        end
    end
end
addEvent("joinJobRoom", true)
addEventHandler("joinJobRoom", resourceRoot, joinJobRoom)

function leaveJobRoom(jobID, roomOwner, plrName)
    if not settings.jobRooms[jobID] then
        triggerClientEvent(client, "responseJobWindow", resourceRoot, true)
        exports.TR_noti:create(client, "Böyle bir barış yok.", "error")
        return
    end

    for i, v in pairs(settings.jobRooms[jobID]) do
        if roomOwner == v.owner then
            if v.owner == plrName then
                settings.jobRooms[jobID][i] = nil
            else
                for k, plr in pairs(v.players) do
                    if plr.name == plrName then
                        settings.jobRooms[jobID][i].players[k] = nil
                    end
                end
            end
            updateNearRooms(client, jobID)
            break
        end
    end
end
addEvent("leaveJobRoom", true)
addEventHandler("leaveJobRoom", resourceRoot, leaveJobRoom)

function setJobReadyStatus(jobID, roomOwner)
    if not settings.jobRooms[jobID] then
        triggerClientEvent(client, "responseJobWindow", resourceRoot, true)
        exports.TR_noti:create(client, "Böyle bir barış yok.", "error")
        return
    end

    local plrName = getPlayerName(client)
    for i, v in pairs(settings.jobRooms[jobID]) do
        if roomOwner == v.owner then
            for k, plr in pairs(v.players) do
                if plr.name == plrName then
                    settings.jobRooms[jobID][i].players[k].ready = not settings.jobRooms[jobID][i].players[k].ready
                end
            end
            updateNearRooms(client, jobID)
            break
        end
    end
end
addEvent("setJobReadyStatus", true)
addEventHandler("setJobReadyStatus", resourceRoot, setJobReadyStatus)

function getJobRooms(jobID)
    triggerLatentClientEvent(client, "updateJobGroups", resourceRoot, settings.jobRooms[jobID])
end
addEvent("getJobRooms", true)
addEventHandler("getJobRooms", resourceRoot, getJobRooms)

function updateNearRooms(plr, jobID)
    local sphere = createColSphere(Vector3(getElementPosition(plr)), 3)
    setElementInterior(sphere, getElementInterior(plr))
    setElementDimension(sphere, getElementDimension(plr))
    local players = getElementsWithinColShape(sphere, "player")
    destroyElement(sphere)

    triggerLatentClientEvent(players, "updateJobGroups", resourceRoot, settings.jobRooms[jobID])
end

function addJobRoomMessage(jobID, roomOwner, message)
    if not settings.jobRooms[jobID] then
        triggerClientEvent(client, "responseJobWindow", resourceRoot, true)
        exports.TR_noti:create(client, "Böyle bir barış yok.", "error")
        return
    end

    for i, v in pairs(settings.jobRooms[jobID]) do
        if roomOwner == v.owner then
            if #v.messages >= 4 then
                table.remove(v.messages, 4)
            end

            table.insert(v.messages, 1, {
                name = getPlayerName(client),
                id = getElementData(client, "ID"),
                text = message,
                color = getPlayerColor(client),
            })

            updateNearRooms(client, jobID)
            break
        end
    end
end
addEvent("addJobRoomMessage", true)
addEventHandler("addJobRoomMessage", resourceRoot, addJobRoomMessage)

function setJobRoomStartWork(jobID, roomOwner, workPlaces)
    if not settings.jobRooms[jobID] then
        triggerClientEvent(client, "responseJobWindow", resourceRoot, true)
        exports.TR_noti:create(client, "Böyle bir barış yok.", "error")
        return
    end

    local workers = {}
    for i, v in pairs(settings.jobRooms[jobID]) do
        if roomOwner == v.owner then
            for _, plr in pairs(v.players) do
                table.insert(workers, plr.player)
            end
            settings.jobRooms[jobID][i] = nil
            break
        end
    end

    table.sort(workers, function()
        return math.random(1, 10) > math.random(1, 10) and true or false
    end)

    local team = {}
    local index = 1
    for _, jobState in pairs(workPlaces) do
        if workers[index] then
            table.insert(team, {
                plr = workers[index],
                name = getPlayerName(workers[index]),
                role = jobState,
            })
        end
        index = index + 1
    end

    for i, v in pairs(team) do
        setElementData(v.plr, "inJob", true)
        triggerClientEvent(v.plr, "startMultipleWork", resourceRoot, v.role, team)
    end
end
addEvent("setJobRoomStartWork", true)
addEventHandler("setJobRoomStartWork", resourceRoot, setJobRoomStartWork)

function getPlayerColor(plr)
    local data = getElementData(plr, "characterData")
    if data.premium == "diamond" then return {49, 202, 255} end
    if data.premium == "gold" then return {214, 163, 6} end
    return {221, 221, 221}
end

function clearJobRooms(res)
    local resName = getResourceName(res)
    if not settings.jobRooms[resName] then return end
    settings.jobRooms[resName] = nil
end
addEventHandler("onResourceStart", getRootElement(), clearJobRooms)



function givePrizes()
    local jobs = exports.TR_mysql:querry("SELECT DISTINCT jobID as jobID FROM tr_jobsPlayers")
    for _, v in pairs(jobs) do
        local bestPlayers = exports.TR_mysql:querry("SELECT playerUID FROM tr_jobsPlayers WHERE jobID = ? ORDER BY totalPoints DESC LIMIT 7", v.jobID)
        for k, plr in pairs(bestPlayers) do
            exports.TR_mysql:querry("INSERT INTO tr_jobsPlayersPrizes (playerUID, jobID, amount) VALUES (?, ?, ?)", plr.playerUID, v.jobID, settings.prizes[k])
        end
    end
    exports.TR_mysql:querry("UPDATE tr_jobsPlayers SET totalPoints = 0")
end


function checkJobMultiplayerEvents(time)
    if time.weekday == 0 then
        if time.hour >= 17 and time.hour < 21 then
            settings.paymentBonus = 1.5
            return
        end
    end

    settings.paymentBonus = 1
end

function checkTime()
    local time = getRealTime()
    if time.minute == 0 and time.hour == 0 and time.monthday == 15 then
        givePrizes()
    end

    checkJobMultiplayerEvents(time)
end
checkTime()
setTimer(checkTime, 60000, 0)

-- local client = getPlayerFromName("Xantris")
-- local ownerName = "Xantris"
-- settings.jobRooms["TR_snowPlow"] = {}
-- table.insert(settings.jobRooms["TR_snowPlow"], {
--     owner = "Wilku",
--     players = {
--         {
--             player = client,
--             name = "Wilku",
--             ready = false,
--             id = 2,
--             color = getPlayerColor(client),
--         },
--     },
--     messages = {},
-- })