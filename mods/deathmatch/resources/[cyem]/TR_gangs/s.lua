local createdZones = {}
local retakeZones = {}

function updateZones()
    setTimer(function()
        triggerClientEvent(root, "updateRadarZones", resourceRoot)
    end, 500, 1)
end

local testZone = 24

function createZones()
    for i, v in pairs(GangZones) do
        local zoneObj = createElement("gangZone", i)
        local zoneCol = createColPolygon(v.zone[1], unpack(v.zone))
        setElementData(zoneObj, "zoneCol", zoneCol, false)
        setElementData(zoneObj, "zoneID", i, false)

        createdZones[i] = zoneObj

        -- setElementData(zoneObj, "ownedGang", {
        --     ownedGang = 1,
        --     color = {math.random(0, 255), math.random(0, 255), math.random(0, 255)},
        -- })
    end

    local gangZones = exports.TR_mysql:querry("SELECT tr_gangZones.ID as zoneID, tr_organizations.ID as gangID, tr_organizations.zoneColor as zoneColor FROM tr_gangZones LEFT JOIN tr_organizations ON tr_organizations.ID = tr_gangZones.ownedGang WHERE ownedGang IS NOT NULL")
    for i, v in pairs(gangZones) do
        local zoneObj = createdZones[tonumber(v.zoneID)]
        if zoneObj then
            local color = split(v.zoneColor and v.zoneColor or "0,0,0", ",")
            setElementData(zoneObj, "ownedGang", {
                ownedGang = tonumber(v.gangID),
                color = {tonumber(color[1]), tonumber(color[2]), tonumber(color[3])},
            })
        end
    end

    updateZones()
end
createZones()


function retakeZone(zoneID, ownedGang, color)
    local zoneObj = createdZones[zoneID]
    local zoneCol = getElementData(zoneObj, "zoneCol")

    local currentData = getElementData(zoneObj, "ownedGang")
    retakeZones[zoneID] = {
        lastData = currentData,
        newData = {
            ownedGang = ownedGang,
            color = {tonumber(color[1]), tonumber(color[2]), tonumber(color[3])},
        },
        col = zoneCol,
        colorText = string.format("%s,%s,%s", color[1], color[2], color[3]),
        timer = setTimer(updateZoneTime, 60000, 62, zoneID),
        points = 0,
        times = 0,
    }

    setElementData(zoneObj, "ownedGang", {
        zoneID = false,
        ownedGang = 0,
        color = {255, 255, 255},
    })

    setElementData(createdZones[zoneID], "gangTimePoint", 0)

    updateZones()
end

function updateZoneTime(zoneID)
    local points = getElementData(createdZones[zoneID], "gangTimePoint")
    retakeZones[zoneID].times = retakeZones[zoneID].times + 1

    local plrs = getElementsWithinColShape(retakeZones[zoneID].col, "player")
    for i, v in pairs(plrs) do
        local gangID = getElementData(v, "characterOrgID")
        if gangID == retakeZones[zoneID].newData.ownedGang and not getElementData(v, "hasBw") then
            retakeZones[zoneID].points = retakeZones[zoneID].points + 1
            points = points + 1
        end
    end

    if retakeZones[zoneID].points >= 180 then
        if isTimer(retakeZones[zoneID].timer) then killTimer(retakeZones[zoneID].timer) end

        local zoneObj = createdZones[zoneID]
        setElementData(zoneObj, "ownedGang", retakeZones[zoneID].newData)

        exports.TR_mysql:querry("UPDATE `tr_gangZones` SET `ownedGang`= ?, `protectTime` = DATE_ADD(NOW(), INTERVAL 1 DAY) WHERE ID = ? LIMIT 1", retakeZones[zoneID].newData.ownedGang, zoneID)

        retakeZones[zoneID] = nil
        updateZones()
        points = nil

    elseif retakeZones[zoneID].times >= 60 then
        if isTimer(retakeZones[zoneID].timer) then killTimer(retakeZones[zoneID].timer) end

        local zoneObj = createdZones[zoneID]
        setElementData(zoneObj, "ownedGang", retakeZones[zoneID].lastData)

        retakeZones[zoneID] = nil
        updateZones()
        points = nil
    end

    setElementData(createdZones[zoneID], "gangTimePoint", points)
end

function useSpayItem(zoneID, itemID)
    if retakeZones[zoneID] then
        exports.TR_noti:create(client, "Bu bölge şu anda ele geçiriliyor.", "error")
        triggerClientEvent(client, "equipmentResponse", resourceRoot)
        return
    end

    local zoneObj = createdZones[zoneID]
    local currentData = getElementData(zoneObj, "ownedGang")
    if currentData then
        if currentData.ownedGang == getElementData(client, "characterOrgID") then
            exports.TR_noti:create(client, "Bu bölge zaten çetenize ait.", "error")
            triggerClientEvent(client, "equipmentResponse", resourceRoot)
            return
        end
    end

    local canTakeZone = exports.TR_mysql:querry("SELECT ID FROM tr_gangZones WHERE protectTime < NOW() AND ID = ? LIMIT 1", zoneID)
    if canTakeZone and canTakeZone[1] then
        local gangData = exports.TR_mysql:querry("SELECT zoneColor FROM tr_organizations WHERE ID = ? LIMIT 1", getElementData(client, "characterOrgID"))
        retakeZone(zoneID, getElementData(client, "characterOrgID"), split(gangData[1].zoneColor and gangData[1].zoneColor or "0, 0, 0", ","))

        triggerClientEvent(client, "spraySuccessResponse", resourceRoot)
        exports.TR_mysql:querry("DELETE FROM tr_items WHERE ID = ? LIMIT 1", itemID)
        exports.TR_noti:create(client, "Bölgeyi ele geçirmek için 180 dakika boyunca bölgede kalın. Bölge beyaz renkle işaretlenmiştir.", "success", 10)
    else
        triggerClientEvent(client, "equipmentResponse", resourceRoot)
        exports.TR_noti:create(client, "Bu bölge yeni ele geçirilmiş ve korumalıdır.", "error")
        return
    end
end
addEvent("useSpayItem", true)
addEventHandler("useSpayItem", root, useSpayItem)




function switchCorners()
    local orgID = getElementData(source, "characterOrgID")
    local orgType = getElementData(source, "characterOrgType")
    if orgType ~= "crime" then return end

    if getElementData(source, "cornerEnabled") then
        triggerClientEvent(source, "disableCorner", resourceRoot)
        return
    end

    local isInZone = false
    local zoneID = false
    for i, v in pairs(createdZones) do
        local col = getElementData(v, "zoneCol")
        if isElementWithinColShape(source, col) then
            local data = getElementData(v, "ownedGang")
            if not data then exports.TR_noti:create(source, "Satışa başlayamazsınız çünkü kendi bölgenizde değilsiniz.", "error", 7) return end
            if data.ownedGang ~= orgID then exports.TR_noti:create(source, "Satışa başlayamazsınız çünkü kendi bölgenizde değilsiniz.", "error", 7) return end
            isInZone = data.ownedGang
            zoneID = getElementData(v, "zoneID")
            break
        end
    end
    if not isInZone then exports.TR_noti:create(source, "Satışa başlayamazsınız çünkü kendi bölgenizde değilsiniz.", "error", 7) return end
    -- local isPolice = false
    -- for i, v in pairs(getElementsByType("player")) do
    --     local characterDuty = getElementData(v, "characterDuty")
    --     if characterDuty then
    --         if characterDuty[3] == "police" then isPolice = true break end
    --     end
    -- end

    -- if not isPolice then
    --     exports.TR_noti:create(source, "Nie możesz rozpocząć sprzedaży, ponieważ nie ma żadnego funkcjonariusza policji na służbie.", "error", 7)
    --     return
    -- end

    local plrUID = getElementData(source, "characterUID")
    local getTodayCorners = exports.TR_mysql:querry("SELECT ID FROM tr_gangCorners WHERE zoneID = ? AND plrUID = ? AND date > CURDATE() LIMIT 1", zoneID, plrUID)
    if #getTodayCorners >= 1 then
        exports.TR_noti:create(source, "Bu bölgede zaten satış yaptığınızdan dolayı satışa başlayamazsınız.", "error", 7)
        return
    end

    triggerClientEvent(source, "enableCorner", resourceRoot, zoneID)
end
addEvent("switchCorners", true)
addEventHandler("switchCorners", root, switchCorners)
exports.TR_chat:addCommand("corner", "switchCorners")


function onCornerStarted(zoneID)
    exports.TR_mysql:querry("INSERT INTO `tr_gangCorners`(`plrUID`, `zoneID`, `date`) VALUES (?, ?, NOW())", getElementData(client, "characterUID"), zoneID)
end
addEvent("onCornerStarted", true)
addEventHandler("onCornerStarted", root, onCornerStarted)

function payForDrugs(amount)
    exports.TR_core:giveMoneyToPlayer(client, amount)
end
addEvent("payForDrugs", true)
addEventHandler("payForDrugs", resourceRoot, payForDrugs)





-- For now
local messages = {
    "En fazla seni başına alabilirim. Defol buradan!",
    "Sana bir şey satmayacağımın seçeneği yok.",
    "Seni biraz eşelemek istemem mi? Defol buradan.",
    "Adam, sen kimsinle konuştuğunu biliyor musun? Seni yerden yere vurmadan önce uzaklaş.",
}

local drugDealerPos = {
    -- {2276.27, -1696.42, 13.63, 30.19},
    -- {2439.17, -1901.50, 13.54, 323.87},
    -- {2487.91, -1973.99, 15.80, 120.14},
    -- {2477.70, -1366.48, 28.83, 143.70},
    -- {2331.55, -1336.86, 24.06, 224.62},
    -- {2503.74, -1532.64, 23.68, 322.21},
    -- {2511.82, -1712.64, 13.47, 302.92},
    -- {2789.40, -1628.46, 10.92, 31.11},
    -- {2670.72, -1212.15, 63.64, 285.34},
    -- New points
    {2189.5517578125, -2700.8974609375, 13.546875, 221},
    {2198.3720703125, -2629.80859375, 13.546875, 167},
    {2403.7666015625, -2515.2734375, 13.649713516235, 318},
    {2524.013671875, -2207.970703125, 17.357162475586, 0},
    {2746.9130859375, -2110.4619140625, 12.2578125, 339},
    {2425.6220703125, -2066.8798828125, 13.546875, 196},
    {2174.4404296875, -2343.462890625, 13.554685592651, 326},
    {2030.796875, -2090.2021484375, 13.546875, 310},
    {1998.9951171875, -2013.875, 13.546875, 225},
    {2134.990234375, -1786.3828125, 13.5194272995, 131},
    {2243.9755859375, -1626.0830078125, 15.797145843506, 69},
    {2441.4462890625, -1694.0478515625, 13.8046875, 333},
    {2738.9228515625, -1692.931640625, 11.84375, 356},
    {2794.18359375, -1626.9501953125, 10.921875, 34},
    {2785.861328125, -1415.5068359375, 16.25, 229},
    {2616.1259765625, -1391.4140625, 34.747509002686, 133},
    {2481.7490234375, -1324.9990234375, 28.85534286499, 87},
    {2307.7548828125, -1448.52734375, 24, 100},
    {2208.77734375, -1344.869140625, 23.984375, 315},
    {2319.7236328125, -1271.4716796875, 23.969959259033, 108},
    {2351.662109375, -1238.126953125, 22.5, 89},
    {2809.107421875, -1240.0498046875, 46.953125, 264},
    {2842.3095703125, -1343.5751953125, 11.0625, 93},
    {2803.7734375, -1192.54296875, 25.474903106689, 90},
    {2791.5859375, -1079.56640625, 30.71875, 46},
    {2226.66796875, -1058.3359375, 46.0078125, 138},
    {2201.291015625, -1151.11328125, 25.863042831421, 229},
    {2024.9130859375, -1096.1923828125, 24.549926757812, 127},
    {1965.0595703125, -1249.9453125, 20.02781867981, 58},
    {1982.830078125, -1308.6748046875, 20.871171951294, 357},
    {1899.109375, -1293.89453125, 13.511360168457, 178},
    {1954.95703125, -1549.4384765625, 13.6484375, 27},
    {1984.046875, -1780.0390625, 13.554388046265, 208},
    {2064.1669921875, -1785.9921875, 13.552302360535, 96},
    {2553.814453125, -2158.7607421875, -0.21875, 270},
    {2536.130859375, -1446.9375, 24, 270},
    {2021.0302734375, -1034.2568359375, 24.84797668457, 265},
    {2757.9873046875, -1182.791015625, 69.40064239502, 0},
}

local gangSkins = {28,25,24,29}

local drugDealerNPC = exports.TR_npc:createNPC(292, drugDealerPos[1][1], drugDealerPos[1][2], drugDealerPos[1][3], drugDealerPos[1][4], "Leen Coates", "Szemrany typ", "dialogue")

local dialogueDealer = exports.TR_npc:createDialogue()
exports.TR_npc:addDialogueText(dialogueDealer, "Silah almak istiyorum.", {pedResponse = "", trigger = "onGangStoreOpen", triggerData = "weapon"})
exports.TR_npc:addDialogueText(dialogueDealer, "Hafif uyuşturucu almak istiyorum.", {pedResponse = "", trigger = "onGangStoreOpen", triggerData = "drugsLow"})
exports.TR_npc:addDialogueText(dialogueDealer, "Ağır uyuşturucu almak istiyorum.", {pedResponse = "", trigger = "onGangStoreOpen", triggerData = "drugsHigh"})
exports.TR_npc:addDialogueText(dialogueDealer, "Maske almak istiyorum.", {pedResponse = "", trigger = "onGangStoreOpen", triggerData = "mask"})

exports.TR_npc:addDialogueText(dialogueDealer, "Görüşürüz.", {pedResponse = "Görüşürüz."})
exports.TR_npc:setNPCDialogue(drugDealerNPC, dialogueDealer)

function drugStore(npc, type)
    local orgType = getElementData(source, "characterOrgType")
    local orgID = getElementData(source, "characterOrgID")
    local pedName = getElementData(npc, "name")
    if orgType ~= "crime" then triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, messages[math.random(1, #messages)], "files/images/npc.png") return end

    local multiplayer = 1

    if type == "weapon" then
        local canBuyWeapon = exports.TR_mysql:querry("SELECT ID FROM tr_organizations WHERE ID = ? AND gangType = ? LIMIT 1", orgID, "weapon")
        if not canBuyWeapon or not canBuyWeapon[1] then triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Ty i broń... Hahaha!", "files/images/npc.png") return end

        triggerClientEvent(client, "createShop", resourceRoot, "Towary Leen'a", {
            {
                type = 1,
                variant = 2,
                variant2 = 0,
                price = 7500 * multiplayer,
                value = 22,
            },
            {
                type = 1,
                variant = 2,
                variant2 = 1,
                price = 13500 * multiplayer,
                value = 24,
            },
            {
                type = 1,
                variant = 3,
                variant2 = 0,
                price = 22990 * multiplayer,
                value = 25,
            },
            {
                type = 1,
                variant = 4,
                variant2 = 2,
                price = 15000 * multiplayer,
                value = 32,
            },


            {
                type = 10,
                variant = 0,
                variant2 = 0,
                price = 263 * multiplayer,
                value = 50,
            },
            {
                type = 10,
                variant = 1,
                variant2 = 0,
                price = 200 * multiplayer,
                value = 10,
            },
            {
                type = 10,
                variant = 2,
                variant2 = 0,
                price = 241 * multiplayer,
                value = 30,
            },
            {
                type = 10,
                variant = 3,
                variant2 = 0,
                price = 190 * multiplayer,
                value = 50,
            },
            {
                type = 10,
                variant = 4,
                variant2 = 0,
                price = 120,
                value = 20,
            },
            {
                type = 10,
                variant = 5,
                variant2 = 0,
                price = 210 * multiplayer,
                value = 20,
            },
            {
                type = 10,
                variant = 6,
                variant2 = 0,
                price = 170 * multiplayer,
                value = 10,
            },
        })

    elseif type == "drugsLow" then
        local canBuyWeapon = exports.TR_mysql:querry("SELECT ID FROM tr_organizations WHERE ID = ? AND gangType = ? LIMIT 1", orgID, "gang")
        if not canBuyWeapon or not canBuyWeapon[1] then triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Tobie to co najwyżej mogę cukierki sprzedać!", "files/images/npc.png") return end

        triggerClientEvent(client, "createShop", resourceRoot, "Towary Leen'a", {
            { -- LSD
                type = 18,
                variant = 1,
                variant2 = 1,
                price = 50 * multiplayer,
            },
            { -- MDMA
                type = 18,
                variant = 1,
                variant2 = 2,
                price = 50 * multiplayer,
            },
            { -- DMT
                type = 18,
                variant = 1,
                variant2 = 3,
                price = 140 * multiplayer,
            },
            { -- Haszysz
                type = 18,
                variant = 0,
                variant2 = 0,
                price = 60 * multiplayer,
            },
            { -- Marihuana
                type = 18,
                variant = 0,
                variant2 = 1,
                price = 60 * multiplayer,
            },
            { -- Xanax
                type = 18,
                variant = 3,
                variant2 = 0,
                price = 30 * multiplayer,
            },
            { -- Adderal
                type = 18,
                variant = 3,
                variant2 = 1,
                price = 40 * multiplayer,
            },
        })

    elseif type == "drugsHigh" then
        local canBuyWeapon = exports.TR_mysql:querry("SELECT ID FROM tr_organizations WHERE ID = ? AND gangType = ? LIMIT 1", orgID, "mafia")
        if not canBuyWeapon or not canBuyWeapon[1] then triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Tobie to co najwyżej mogę cukierki sprzedać!", "files/images/npc.png") return end

        triggerClientEvent(client, "createShop", resourceRoot, "Towary Leen'a", {
            { -- Heroina
                type = 18,
                variant = 1,
                variant2 = 0,
                price = 180 * multiplayer,
            },
            { -- Kokaina
                type = 18,
                variant = 2,
                variant2 = 0,
                price = 200 * multiplayer,
            },
            { -- Amfetamina
                type = 18,
                variant = 2,
                variant2 = 1,
                price = 180 * multiplayer,
            },
            { -- Metaamfetamina
                type = 18,
                variant = 2,
                variant2 = 2,
                price = 190 * multiplayer,
            },
        })

    elseif type == "mask" then
        triggerClientEvent(client, "createShop", resourceRoot, "Towary Leen'a", {
            { -- Mask
                type = 9,
                variant = 0,
                variant2 = 0,
                price = 500 * multiplayer,
            },
        })
    end
end
addEvent("onGangStoreOpen", true)
addEventHandler("onGangStoreOpen", root, drugStore)

function switchDrugStorePos()
    local pos = drugDealerPos[math.random(1, #drugDealerPos)]
    setElementModel(drugDealerNPC, gangSkins[math.random(1, #gangSkins)])
    setElementPosition(drugDealerNPC, pos[1], pos[2], pos[3])
    setElementRotation(drugDealerNPC, 0, 0, pos[4])
end
switchDrugStorePos()
setTimer(switchDrugStorePos, 10800000, 0)