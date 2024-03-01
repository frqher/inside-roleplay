local data = {
    pricePerKG = 3.2,

    updateCost = {
        [2] = 80,
        [3] = 200,
        [4] = 400,
        [5] = 660,
        [6] = 900,
        [7] = 1300,
        [8] = 1800,
        [9] = 2500,
    },
}

local NPCs = {
    {
        skin = 132,
        pos = Vector3(2157.9306640625, -109.140625, 2.8475728034973),
        int = 0,
        dim = 0,
        rot = 102,
        name = "Stephan Klark",
    },
    {
        skin = 182,
        pos = Vector3(-2246.4228515625, 2384.109375, 5.07666015625),
        int = 0,
        dim = 0,
        rot = 310,
        name = "Wesley Donnelly",
    },
}

local Vehs = {
    {
        model = 453,
        pos = Vector3(2103.90039, -162.09961, -0.5),
        rot = Vector3(0, 0, 160),
    },
    {
        model = 472,
        pos = Vector3(2167.2, -171, 0),
        rot = Vector3(0, 0, 160),
    },
}

function createNPCs()
    local dialogue = exports.TR_npc:createDialogue()
    exports.TR_npc:addDialogueText(dialogue, "Good day.", {pedResponse = "Good day. Nasıl yardımcı olabilirim?"})
    exports.TR_npc:addDialogueText(dialogue, "1kg balık kaç para?", {pedResponse = "", responseTo = "Good day.", trigger = "getFishPrice"})

    exports.TR_npc:addDialogueText(dialogue, "Olta yükseltmek istiyorum.", {pedResponse = "Olta yükseltirken yakaladığın balıkların bir kısmını kaybedersin. Bu işlem her zaman plana göre gitmez. Emin misin yapmak istediğine?", responseTo = "Good day."})
    exports.TR_npc:addDialogueText(dialogue, "Evet. Oltamı yükselt.", {pedResponse = "", responseTo = "Olta yükseltmek istiyorum.", trigger = "tryUpgradeFishingrod"})
    exports.TR_npc:addDialogueText(dialogue, "Hayır. Henüz değil.", {pedResponse = "Anladım. Bu senin kararın.", responseTo = "Olta yükseltmek istiyorum."})

    exports.TR_npc:addDialogueText(dialogue, "Yakaladığım balıkları satmak istiyorum.", {pedResponse = "Bu konuda emin misin?", responseTo = "Good day."})
    exports.TR_npc:addDialogueText(dialogue, "Evet. Yakaladığım balıkları satmak istiyorum.", {pedResponse = "", responseTo = "Yakaladığım balıkları satmak istiyorum.", trigger = "sellFishes"})
    exports.TR_npc:addDialogueText(dialogue, "Hayır. Ancak şimdilik değil.", {pedResponse = "Anladım. Bu senin kararın.", responseTo = "Yakaladığım balıkları satmak istiyorum."})

    exports.TR_npc:addDialogueText(dialogue, "Balıkçılık ekipmanı satın almak istiyorum.", {pedResponse = "", responseTo = "Good day.", img = "shop", trigger = "openFishingShop"})

    exports.TR_npc:addDialogueText(dialogue, "Görüşürüz.", {pedResponse = "Görüşürüz."})

    for i, v in pairs(NPCs) do
        local ped = exports.TR_npc:createNPC(v.skin, v.pos.x, v.pos.y, v.pos.z, v.rot, v.name, "Pracownik sklepu wędkarskiego", "dialogue")
        setElementInterior(ped, v.int)
        setElementDimension(ped, v.dim)
        setElementData(ped, "name", v.name)

        if v.animation then setElementData(ped, "animation", v.animation) end

        local blip = createBlip(v.pos.x, v.pos.y, v.pos.z, 0, 2, 77, 184, 175)
        setElementData(blip, "icon", 38)

        exports.TR_npc:setNPCDialogue(ped, dialogue)
    end

    for i, v in pairs(Vehs) do
        local veh = createVehicle(v.model, v.pos, v.rot)
        setElementFrozen(veh, true)

        addEventHandler("onVehicleStartEnter", veh, function()
            cancelEvent()
        end)
    end
end
createNPCs()


function getFishPrice(ped)
    local pedName = getElementData(ped, "name")
    triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, string.format("Cena akutalnie wynosi $%.2f za kilogram.", data.pricePerKG), "files/images/npc.png")
end
addEvent("getFishPrice", true)
addEventHandler("getFishPrice", root, getFishPrice)

function sellFishes(ped)
    local uid = getElementData(client, "characterUID")
    local pedName = getElementData(ped, "name")

    local fishingSell = getElementData(client, "sellFish")
    if fishingSell then
        if (getTickCount() - fishingSell)/30000 < 1 then
            exports.TR_noti:create(client, "Balıkları sadece 60 saniyede bir satabilirsin.", "error")
            return
        end
    end
    setElementData(client, "sellFish", getTickCount())

    local kg = exports.TR_mysql:querry("SELECT value as kg FROM tr_items WHERE type = 1 AND variant = 1 AND (variant2 >= 4 AND variant2 <= 12) AND owner = ? AND ownedType = 0 AND used IS NOT NULL LIMIT 1", uid)
    if kg and kg[1] then
        local mass = tonumber(kg[1].kg) and tonumber(kg[1].kg) or 0
        if not mass then
            triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Satmak için hiç balığınız yok veya hiç olta takmadınız.", "files/images/npc.png")
            return
        end

        if mass == 0 then
            triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Satmak için hiç balığınız yok.", "files/images/npc.png")
            return
        end

        exports.TR_mysql:querry("UPDATE tr_items SET value = 0 WHERE type = 1 AND variant = 1 AND (variant2 >= 4 AND variant2 <= 12) AND owner = ? AND ownedType = 0 AND used IS NOT NULL LIMIT 1", uid)

        local totalPrice = mass * data.pricePerKG

        if exports.TR_core:giveMoneyToPlayer(client, totalPrice) then
            triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, string.format("Ze sprzedaży %.2fkg ryb, otrzymujesz $%.2f.", mass, totalPrice), "files/images/npc.png")
            triggerClientEvent(client, "upgradeRod", resourceRoot, 0, false, true)
            triggerClientEvent(client, "addAchievements", resourceRoot, "fishingSell")
        end
    else
        triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Nie posiadasz wyekwipowanej żadnej wędki.", "files/images/npc.png")
    end
end
addEvent("sellFishes", true)
addEventHandler("sellFishes", root, sellFishes)


function changePrice()
    data.pricePerKG = math.random(200, 325)/100
end
changePrice()
setTimer(changePrice, 10800000, 0)


function catchFish(mass)
    local uid = getElementData(client, "characterUID")
    exports.TR_mysql:querry("UPDATE tr_items SET value = value + ? WHERE type = 1 AND variant = 1 AND (variant2 >= 4 AND variant2 <= 12) AND owner = ? AND ownedType = 0 AND used IS NOT NULL LIMIT 1", mass, uid)
end
addEvent("catchFish", true)
addEventHandler("catchFish", root, catchFish)

function tryUpgradeFishingrod()
    local uid = getElementData(client, "characterUID")

    local kg = exports.TR_mysql:querry("SELECT ID, value as kg, variant2 FROM tr_items WHERE type = 1 AND variant = 1 AND (variant2 >= 4 AND variant2 <= 12) AND ownedType = 0 AND owner = ? AND used IS NOT NULL LIMIT 1", uid)
    if kg and kg[1] then
        local mass = tonumber(kg[1].kg) and tonumber(kg[1].kg) or 0
        if not mass then
            exports.TR_noti:create(client, "Olta yükseltmek için yeterli balığınız yok veya hiç olta takmadınız.", "error")
            return
        end
        if mass == 0 then
            exports.TR_noti:create(client, "Olta yükseltmek için yeterli balığınız yok.", "error")
            return
        end

        local nextLvl = tonumber(kg[1].variant2) - 2
        if nextLvl == 10 then exports.TR_noti:create(client, "Bu olta zaten en yüksek seviyede.", "error") return end

        if mass <= data.updateCost[nextLvl] then
            exports.TR_noti:create(client, "Olta yükseltmek için yeterli balığınız yok.", "error")
            return
        end

        local successfull = math.random(1, 1000) >= (nextLvl * 100) and true or false
        if successfull then
            exports.TR_mysql:querry("UPDATE tr_items SET value = value - ?, variant2 = variant2 + 1 WHERE type = 1 AND variant = 1 AND (variant2 >= 4 AND variant2 <= 12) AND ownedType = 0 AND owner = ? AND used IS NOT NULL LIMIT 1", data.updateCost[nextLvl], uid)
            exports.TR_noti:create(client, string.format("Olta +%d seviyeye yükseltildi.", nextLvl), "success")
            triggerClientEvent(client, "upgradeRod", resourceRoot, data.updateCost[nextLvl], nextLvl)

        else
            exports.TR_mysql:querry("UPDATE tr_items SET value = value - ? WHERE type = 1 AND variant = 1 AND (variant2 >= 4 AND variant2 <= 12) AND owner = ? AND ownedType = 0 AND used IS NOT NULL LIMIT 1", data.updateCost[nextLvl], uid)
            triggerClientEvent(client, "upgradeRod", resourceRoot, data.updateCost[nextLvl], false)
            exports.TR_noti:create(client, "Ulepszanie nie powiodło się.", "error")
        end
    else
        exports.TR_noti:create(client, "Hiç donanımlı olta yok.", "error")
    end
end
addEvent("tryUpgradeFishingrod", true)
addEventHandler("tryUpgradeFishingrod", root, tryUpgradeFishingrod)


function openFishingShop()
    triggerClientEvent(client, "createShop", resourceRoot, "Sklep wędkarski", {
        {
            type = 1,
            variant = 1,
            variant2 = 4,
            price = 420,
            value = 0,
        },
        {
            type = 13,
            variant = 0,
            variant2 = 0,
            price = 50,
            value = 30,
        },
        {
            type = 13,
            variant = 3,
            variant2 = 0,
            price = 70,
            value = 30,
        },
        {
            type = 13,
            variant = 2,
            variant2 = 0,
            price = 90,
            value = 30,
        },
        {
            type = 13,
            variant = 1,
            variant2 = 0,
            price = 100,
            value = 30,
        },
        {
            type = 13,
            variant = 4,
            variant2 = 0,
            price = 550,
            value = 15,
        },
    })
end
addEvent("openFishingShop", true)
addEventHandler("openFishingShop", root, openFishingShop)