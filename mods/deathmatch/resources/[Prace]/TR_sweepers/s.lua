local settings = {
    actualPrice = 0,
    priceRandom = {5.00, 6.50},
    sortBonus = 1.1, -- 10%
}

function createNPC()
    local ped = exports.TR_npc:createNPC(17, 2981.3430175781, -1491.4392089844, 88.784866333008, 56, "Saim Wiggins", "Sweeper Şirketi Sahibi", "dialogue")
    setElementInterior(ped, 0)
    setElementDimension(ped, 7)

    local dialogue = exports.TR_npc:createDialogue()
    exports.TR_npc:addDialogueText(dialogue, "Merhaba.", {pedResponse = "Merhaba. Size nasıl yardımcı olabilirim?"})

    exports.TR_npc:addDialogueText(dialogue, "Çöp kilosu için fiyat nedir?", {pedResponse = "", responseTo = "Merhaba.", trigger = "getSweeperNpcInfo", triggerData = {"price"}})
    exports.TR_npc:addDialogueText(dialogue, "Topladığım kiloyu öğrenmek istiyorum.", {pedResponse = "", responseTo = "Merhaba.", trigger = "getSweeperNpcInfo", triggerData = {"count"}})
    exports.TR_npc:addDialogueText(dialogue, "Çöpleri mevcut fiyattan satmak istiyorum.", {pedResponse = "", responseTo = "Merhaba.", trigger = "getSweeperNpcInfo", triggerData = {"sellNow"}})
    exports.TR_npc:addDialogueText(dialogue, "Çöpleri geri dönüşüme vermek istiyorum.", {pedResponse = "", responseTo = "Merhaba.", trigger = "getSweeperNpcInfo", triggerData = {"sellLater"}})
    exports.TR_npc:addDialogueText(dialogue, "Geri dönüşüm merkezinden para almak istiyorum.", {pedResponse = "", responseTo = "Merhaba.", trigger = "getSweeperNpcInfo", triggerData = {"takeoutLater"}})
    exports.TR_npc:addDialogueText(dialogue, "Ancak bir şeye ihtiyacım yok. Hoşça kalın.", {pedResponse = "Hoşça kalın.", responseTo = "Merhaba.", trigger = ""})

    exports.TR_npc:addDialogueText(dialogue, "Hoşça kalın.", {pedResponse = "Hoşça kalın."})

    exports.TR_npc:setNPCDialogue(ped, dialogue)
end
createNPC()

function randomPrice()
    settings.actualPrice = math.random(settings.priceRandom[1] * 100, settings.priceRandom[2] * 100)/100
end
randomPrice()
setTimer(randomPrice, 4 * 60 * 60000, 0)


function getSweeperNpcInfo(el, data)
    local uid = getElementData(client, "characterUID")

    if data[1] == "price" then
        triggerClientEvent(client, "showCustomMessage", resourceRoot, "Saim Wiggins", string.format("Şu anda çöp kilosu için fiyat $%.2f.", settings.actualPrice), "files/images/npc.png")

    elseif data[1] == "count" then
        local count = exports.TR_mysql:querry("SELECT count FROM tr_sweepers WHERE plrUID = ? LIMIT 1", uid)
        if count and count[1] then
            if count[1].count then
                triggerClientEvent(client, "showCustomMessage", resourceRoot, "Saim Wiggins", string.format("Sistem bana topladığınız %.2fkg çöp olduğunu gösteriyor.", tonumber(count[1].count)), "files/images/npc.png")
            else
                triggerClientEvent(client, "showCustomMessage", resourceRoot, "Saim Wiggins", "Üzgünüm, ancak sistemimizde böyle biri yok.", "files/images/npc.png")
            end
        else
            triggerClientEvent(client, "showCustomMessage", resourceRoot, "Saim Wiggins", "Üzgünüm, ancak sistemimizde böyle biri yok.", "files/images/npc.png")
        end

    elseif data[1] == "sellNow" then
        local count = exports.TR_mysql:querry("SELECT count FROM tr_sweepers WHERE plrUID = ? LIMIT 1", uid)
        if count and count[1] then
            if count[1].count then
                local count = tonumber(count[1].count)
                if count > 0 then
                    if exports.TR_core:giveMoneyToPlayer(client, count * settings.actualPrice) then
                        triggerClientEvent(client, "showCustomMessage", resourceRoot, "Saim Wiggins", string.format("Çöp satışından $%.2f kazanıyorsun.", count * settings.actualPrice), "files/images/npc.png")
                    end
                    exports.TR_mysql:querry("UPDATE tr_sweepers SET count = 0 WHERE plrUID = ? LIMIT 1", uid)
                else
                    triggerClientEvent(client, "showCustomMessage", resourceRoot, "Saim Wiggins", "Üzgünüm, ancak 0kg çöpünüz bulunmaktadır. Satmak için önce çöpleri toplamanız gerekmektedir.", "files/images/npc.png")
                end
            else
                triggerClientEvent(client, "showCustomMessage", resourceRoot, "Saim Wiggins", "Üzgünüm, ancak sistemimizde böyle biri yok.", "files/images/npc.png")
            end
        else
            triggerClientEvent(client, "showCustomMessage", resourceRoot, "Saim Wiggins", "Üzgünüm, ancak sistemimizde böyle biri yok.", "files/images/npc.png")
        end

    elseif data[1] == "sellLater" then
        local count = exports.TR_mysql:querry("SELECT count FROM tr_sweepers WHERE plrUID = ? LIMIT 1", uid)
        if count and count[1] then
            if count[1].count then
                local count = tonumber(count[1].count)
                if count > 0 then
                    exports.TR_mysql:querry("UPDATE tr_sweepers SET count = 0 WHERE plrUID = ? LIMIT 1", uid)
                    exports.TR_mysql:querry("INSERT INTO tr_sweepersSorting (plrUID, money, takeoutTime) VALUES (?, ?, DATE_ADD(NOW(), INTERVAL 1 DAY))", uid, count * (settings.actualPrice * settings.sortBonus))

                    triggerClientEvent(client, "showCustomMessage", resourceRoot, "Saim Wiggins", string.format("O zaman çöpleri geri dönüşüme gönderiyorum. Paranız 24 saat içinde bana ulaşmalı. Yarın gelip hak ettiğiniz ödülü alabilirsiniz.", count * settings.actualPrice), "files/images/npc.png")
                else
                    triggerClientEvent(client, "showCustomMessage", resourceRoot, "Saim Wiggins", "Üzgünüm, ancak 0kg çöpünüz bulunmaktadır. Satmak için önce çöpleri toplamanız gerekmektedir.", "files/images/npc.png")
                end
            else
                triggerClientEvent(client, "showCustomMessage", resourceRoot, "Saim Wiggins", "Üzgünüm, ancak sistemimizde böyle biri yok.", "files/images/npc.png")
            end
        else
            triggerClientEvent(client, "showCustomMessage", resourceRoot, "Saim Wiggins", "Üzgünüm, ancak sistemimizde böyle biri yok.", "files/images/npc.png")
        end

    elseif data[1] == "takeoutLater" then
        local count = exports.TR_mysql:querry("SELECT SUM(money) as count FROM tr_sweepersSorting WHERE plrUID = ? AND taken IS NULL AND takeoutTime <= NOW()", uid)
        if count and count[1] then
            if count[1].count then
                local count = tonumber(count[1].count)
                if count > 0 then
                    if exports.TR_core:giveMoneyToPlayer(client, count) then
                        triggerClientEvent(client, "showCustomMessage", resourceRoot, "Saim Wiggins", string.format("Depolama teslimatınız geldi. Kazancınız $%.2f.", count), "files/images/npc.png")
                    end
                    exports.TR_mysql:querry("UPDATE tr_sweepersSorting SET taken = 1 WHERE plrUID = ? AND taken IS NULL AND takeoutTime <= NOW()", uid)
                else
                    triggerClientEvent(client, "showCustomMessage", resourceRoot, "Saim Wiggins", "Üzgünüm, ancak 0kg çöpünüz bulunmaktadır. Satmak için önce çöpleri toplamanız gerekmektedir.", "files/images/npc.png")
                end
            else
                triggerClientEvent(client, "showCustomMessage", resourceRoot, "Saim Wiggins", "Üzgünüm, ancak sistemimizde böyle biri yok.", "files/images/npc.png")
            end
        else
            triggerClientEvent(client, "showCustomMessage", resourceRoot, "Saim Wiggins", "Üzgünüm, ancak sistemimizde böyle biri yok.", "files/images/npc.png")
        end
    end
end
addEvent("getSweeperNpcInfo", true)
addEventHandler("getSweeperNpcInfo", root, getSweeperNpcInfo)


function onPlayerSweeperJobTakout(count)
    local uid = getElementData(client, "characterUID")
    local hasCount = exports.TR_mysql:querry("SELECT ID FROM tr_sweepers WHERE plrUID = ? LIMIT 1", uid)
    if hasCount and hasCount[1] then
        exports.TR_mysql:querry("UPDATE tr_sweepers SET count = count + ? WHERE plrUID = ? LIMIT 1", count, uid)
    else
        exports.TR_mysql:querry("INSERT INTO tr_sweepers (plrUID, count) VALUES (?, ?)", uid, count)
    end
end
addEvent("onPlayerSweeperJobTakout", true)
addEventHandler("onPlayerSweeperJobTakout", root, onPlayerSweeperJobTakout)


function createSweeperVehicle(pos, upgraded)
    local veh = createVehicle(574, pos[1], pos[2], pos[3], 0, 0, 0)
    setVehicleColor(veh, 60, 60, 60)

    setElementData(veh, "vehicleData", {
		fuel = 70,
		mileage = math.random(350000, 500000),
		engineType = "d",
	}, false)
    setElementData(veh, "vehicleOwner", client)
    setElementData(veh, "blockCollisions", true)
    setVehicleVariant(veh, 2, 2)

    local plr = client
    setTimer(function()
        warpPedIntoVehicle(plr, veh)
        setElementInterior(plr, 0)
        setElementDimension(plr, 0)
        setVehicleEngineState(veh, true)
    end, 100, 1)

    setVehicleHandling(veh, "maxVelocity", 47)

    exports.TR_objectManager:attachObjectToPlayer(client, veh)
end
addEvent("createSweeperVehicle", true)
addEventHandler("createSweeperVehicle", resourceRoot, createSweeperVehicle)

function canEnterVehicle(plr, seat, jacked, door)
    cancelEvent()
end
addEventHandler("onVehicleStartEnter", resourceRoot, canEnterVehicle)

function onVehicleExit(plr, seat, jacked, door)
    if seat == 0 then
        cancelEvent()
        triggerClientEvent(plr, "onJobVehicleExit", resourceRoot)
    end
end
addEventHandler("onVehicleStartExit", resourceRoot, onVehicleExit)