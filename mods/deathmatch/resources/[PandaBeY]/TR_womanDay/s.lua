local skins = {9, 10, 11, 12, 13, 40, 41, 55, 56, 93, 150, 148, 169, 193, 192, 226}
local NPCs = {
    {
        pos = Vector3(-1915.12109375, 898.1484375, 35.4140625),
        rot = 129,
        name = "Asia Lister",
    },
    {
        pos = Vector3(-1590.41015625, 866.138671875, 7.6953125),
        rot = 175,
        name = "Ivy-Rose Needham",
    },
    {
        pos = Vector3(-1616.728515625, 1149.4912109375, 7.1875),
        rot = 273,
        name = "Wren Blake",
    },
    {
        pos = Vector3(-1721.2578125, 1362.4423828125, 7.1875),
        rot = 123,
        name = "Joann Benjamin",
    },
    {
        pos = Vector3(-1914.2421875, 1190.1328125, 45.452735900879),
        rot = 183,
        name = "Romany Forrest",
    },
    {
        pos = Vector3(-1729.0234375, 584.6953125, 24.867401123047),
        rot = 40,
        name = "Juniper Rubio",
    },
    {
        pos = Vector3(-1962.4375, 300.6923828125, 35.473926544189),
        rot = 308,
        name = "Stefanie Frey",
    },
    {
        pos = Vector3(-2523.318359375, 1214.283203125, 37.42832946777),
        rot = 284,
        name = "Malika Schneider",
    },
    {
        pos = Vector3(-2872.5986328125, 975.3681640625, 40.7187),
        rot = 309,
        name = "Antonina Hess",
    },
    {
        pos = Vector3(-2712.158203125, 375.8544921875, 4.3785185813904),
        rot = 267,
        name = "Emmeline Akhtar",
    },
    {
        pos = Vector3(-2440.6875, 754.1064453125, 35.171875),
        rot = 23,
        name = "Amelia-Mae Villa",
    },
    {
        pos = Vector3(-1987.57421875, 700.4521484375, 46.5625),
        rot = 308,
        name = "Kane Rosales",
    },
    {
        pos = Vector3(-2230.001953125, -79.73828125, 35.3203125),
        rot = 0,
        name = "Rachelle Stokes",
    },
    {
        pos = Vector3(-2262.3193359375, 652.28125, 49.387950897217),
        rot = 93,
        name = "Dayna Esquivel",
    },
    {
        pos = Vector3(-2491.8642578125, -27.501953125, 25.765625),
        rot = 93,
        name = "Evelyn Park",
    },
    {
        pos = Vector3(-2269.2744140625, -157.6025390625, 35.3203125),
        rot = 266,
        name = "Marissa Burton",
    },
    {
        pos = Vector3(-2017.244140625, -988.8115234375, 32.1879501342775),
        rot = 48,
        name = "Sianna Shelton",
    },
    {
        pos = Vector3(-2020.095703125, -986.8359375, 32.18795013427),
        rot = 232,
        name = "Gabriel Noble",
    },
    {
        pos = Vector3(-2514.357421875, -623.931640625, 132.776947021487),
        rot = 2,
        name = "Fariha Keith",
    },
    {
        pos = Vector3(-2034.6240234375, 130.115234375, 28.8359375),
        rot = 352,
        name = "Loki Mullins",
    },
    {
        pos = Vector3(-2698.427734375, 820.44140625, 49.984375),
        rot = 179,
        name = "Courteney Shepherd",
    },
    {
        pos = Vector3(-2787.6298828125, -275.216796875, 7.1875),
        rot = 204,
        name = "Carlie Lucero",
    },
    {
        pos = Vector3(-1623.9501953125, 717.5302734375, 14.609375),
        rot = 325,
        name = "Isabell Mackie",
    },
    {
        pos = Vector3(-1829.6513671875, 63.5986328125, 15.122790336609),
        rot = 324,
        name = "Meadow Sanderson",
    },
    {
        pos = Vector3(-1711.408203125, 398.2099609375, 7.1872444152832),
        rot = 278,
        name = "Iylah Swanson",
    },
    {
        pos = Vector3(-1755.3896484375, 963.078125, 24.8828125),
        rot = 180,
        name = "Margot Keeling",
    },
    {
        pos = Vector3(-2159.8916015625, 1065.3125, 80.0078125),
        rot = 273,
        name = "Teresa Blankenship",
    },
    {
        pos = Vector3(-2374.5732421875, 912.3232421875, 45.445312),
        rot = 87,
        name = "Hajrah Yates",
    },
    {
        pos = Vector3(-2718.166015625, 52.31640625, 4.3359375),
        rot = 269,
        name = "Aleesha Irving",
    },
    {
        pos = Vector3(-2536.1142578125, 306.591796875, 35.1171875),
        rot = 109,
        name = "Michaela Curtis",
    },
}

local dialogueFlowers = exports.TR_npc:createDialogue()
exports.TR_npc:addDialogueText(dialogueFlowers, "Çiçek almak istiyorum.", {pedResponse = "", trigger = "buyFlowersToWoman"})
exports.TR_npc:addDialogueText(dialogueFlowers, "Güle güle.", {pedResponse = "Güle güle."})

local ped = exports.TR_npc:createNPC(12, -2576.583984375, 309.349609375, 22.6499996185, 0, "Amelie Post", "Çiçek satıcısı", "dialogue")
setElementInterior(ped, 0)
setElementDimension(ped, 5)
exports.TR_npc:setNPCDialogue(ped, dialogueFlowers)


function createNpcs()
    local dialogue = exports.TR_npc:createDialogue()
    exports.TR_npc:addDialogueText(dialogue, "Lütfen. senin için çiçeklerim var", {pedResponse = "", trigger = "giveFlowersToWoman"})
    exports.TR_npc:addDialogueText(dialogue, "Güle güle.", {pedResponse = "Güle güle."})

    for i, v in pairs(NPCs) do
        local ped = exports.TR_npc:createNPC(skins[math.random(1, #skins)], v.pos.x, v.pos.y, v.pos.z, v.rot, v.name, "Niewinna Kobieta", "dialogue")

        setElementData(ped, "womanID", i, false)
        exports.TR_npc:setNPCDialogue(ped, dialogue)
    end
end
createNpcs()

function giveFlowersToWoman(ped)
    local womanID = getElementData(ped, "womanID")
    local pedName = getElementData(ped, "name")
    local plrUID = getElementData(client, "characterUID")

    local flowersID = exports.TR_mysql:querry("SELECT ID FROM tr_items WHERE owner = ? AND type = 21 AND ownedType = 0 LIMIT 1", plrUID)
    if flowersID and flowersID[1] then
        local flowersGiven = exports.TR_mysql:querry("SELECT ID FROM tr_flowers WHERE womanID = ? AND plrUID = ? LIMIT 1", womanID, plrUID)
        if flowersGiven and flowersGiven[1] then
            triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Bugün bana çiçek verdin! Artık istemiyorum.", "files/images/npc.png")
        else
            givePrize(client, pedName)

            triggerClientEvent(client, "takePlayerItem", resourceRoot, tonumber(flowersID[1].ID))
            exports.TR_mysql:querry("INSERT INTO tr_flowers (plrUID, womanID) VALUES (?, ?)", plrUID, womanID)
            exports.TR_mysql:querry("DELETE FROM tr_items WHERE ID = ? LIMIT 1", flowersID[1].ID)
        end
    else
        triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Ben zaten mutluydum ve sen bana yalan söyledin! Benim için hiç çiçeğin yok!", "files/images/npc.png")
    end
end
addEvent("giveFlowersToWoman", true)
addEventHandler("giveFlowersToWoman", root, giveFlowersToWoman)


function buyFlowersToWoman()
    triggerClientEvent(client, "createShop", resourceRoot, "Kwiaciarnia", {
        {
            type = 21,
            variant = 0,
            variant2 = 0,
            price = 100,
        },
    })
end
addEvent("buyFlowersToWoman", true)
addEventHandler("buyFlowersToWoman", root, buyFlowersToWoman)

function givePrize(plr, pedName)
    local rand = math.random(1, 100)
    if rand < 1 then
        exports.TR_core:giveMoneyToPlayer(plr, 5000)
        triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Ama güzel bir buket. Teşekkür ederim! #C2A2DA*Bir buket için 5000$ verir*", "files/images/npc.png")

    elseif rand < 5 then
        exports.TR_core:giveMoneyToPlayer(plr, 1000)
        triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Ama güzel bir buket. Teşekkür ederim! #C2A2DA*Bir buket için 1000$ verir*", "files/images/npc.png")

    elseif rand < 35 then
        exports.TR_core:giveMoneyToPlayer(plr, 500)
        triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Ama güzel bir buket. Teşekkür ederim! #C2A2DA*Bir buket için 500$ verir*", "files/images/npc.png")

    elseif rand < 85 then
        exports.TR_core:giveMoneyToPlayer(plr, 100)
        triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Ama güzel bir buket. Teşekkür ederim! #C2A2DA*Bir buket için 100$ verir*", "files/images/npc.png")

    else
        triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Ama güzel bir buket. Teşekkür ederim! #C2A2DA*yanağa bir öpücük kondurur*", "files/images/npc.png")
    end
end