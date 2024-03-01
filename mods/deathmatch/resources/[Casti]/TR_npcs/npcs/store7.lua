local NPCs = {
    {
        skin = 7,
        pos = Vector3(-30.722280502319, -30.695669174194, 1003.5572509766),
        int = 4,
        dim = 3,
        rot = 2,
        name = "Gregory Klit",
    },
    {
        skin = 7,
        pos = Vector3(-30.722280502319, -30.695669174194, 1003.5572509766),
        int = 4,
        dim = 4,
        rot = 2,
        name = "Matthiew Drain",
    },
    {
        skin = 7,
        pos = Vector3(-30.722280502319, -30.695669174194, 1003.5572509766),
        int = 4,
        dim = 2,
        rot = 2,
        name = "Phillip Gernot",
    },
    {
        skin = 7,
        pos = Vector3(-30.722280502319, -30.695669174194, 1003.5572509766),
        int = 4,
        dim = 1,
        rot = 2,
        name = "Thomas Helliger",
    },
    {
        skin = 9,
        pos = Vector3(-30.722280502319, -30.695669174194, 1003.5572509766),
        int = 4,
        dim = 5,
        rot = 2,
        name = "Jane Berkins",
    },
    {
        skin = 9,
        pos = Vector3(-30.722280502319, -30.695669174194, 1003.5572509766),
        int = 4,
        dim = 6,
        rot = 2,
        name = "Katrine Hanker",
    },
    {
        skin = 9,
        pos = Vector3(-30.722280502319, -30.695669174194, 1003.5572509766),
        int = 4,
        dim = 7,
        rot = 2,
        name = "Isabelle Kelly",
    },
}

function createDonutsNPC()
    local dialogue = exports.TR_npc:createDialogue()
    exports.TR_npc:addDialogueText(dialogue, "Günaydın. Alabilir miyim...", {pedResponse = "", img = "shop", trigger = "openSevenStoreShop"})
    exports.TR_npc:addDialogueText(dialogue, "Hoşça kalın.", {pedResponse = "Hoşça kalın."})

    for i, v in pairs(NPCs) do
        local ped = exports.TR_npc:createNPC(v.skin, v.pos.x, v.pos.y, v.pos.z, v.rot, v.name, "Mağaza Çalışanı", "dialogue")
        setElementInterior(ped, v.int)
        setElementDimension(ped, v.dim)
        setElementData(ped, "shopName", v.shopName or "Market", false)

        exports.TR_npc:setNPCDialogue(ped, dialogue)
    end
end
createDonutsNPC()




function openSevenStoreShop(ped)
    triggerClientEvent(client, "createShop", resourceRoot, "Sklep 7 Store", {
        {
            type = 2,
            variant = 0,
            variant2 = 0,
            price = 3.50,
        },
        {
            type = 2,
            variant = 0,
            variant2 = 2,
            price = 3,
        },
        {
            type = 2,
            variant = 0,
            variant2 = 4,
            price = 3.50,
        },
        {
            type = 2,
            variant = 0,
            variant2 = 5,
            price = 4,
        },
        {
            type = 2,
            variant = 0,
            variant2 = 6,
            price = 5.50,
        },

        {
            type = 2,
            variant = 0,
            variant2 = 8,
            price = 2.50,
        },
        {
            type = 2,
            variant = 0,
            variant2 = 9,
            price = 3.60,
        },
        {
            type = 2,
            variant = 0,
            variant2 = 10,
            price = 4.50,
        },
        {
            type = 2,
            variant = 1,
            variant2 = 0,
            price = 3.50,
        },
        {
            type = 2,
            variant = 1,
            variant2 = 1,
            price = 3,
        },
        {
            type = 2,
            variant = 1,
            variant2 = 2,
            price = 5,
        },
        {
            type = 2,
            variant = 1,
            variant2 = 5,
            price = 6,
        },
        {
            type = 2,
            variant = 1,
            variant2 = 7,
            price = 7,
        },
        {
            type = 2,
            variant = 1,
            variant2 = 8,
            price = 6.50,
        },
        {
            type = 2,
            variant = 4,
            variant2 = 0,
            price = 8,
        },
        {
            type = 2,
            variant = 4,
            variant2 = 1,
            price = 8.30,
        },
        {
            type = 2,
            variant = 4,
            variant2 = 2,
            price = 8.50,
        },
        {
            type = 8,
            variant = 0,
            variant2 = 1,
            price = 7.20,
        },
        {
            type = 8,
            variant = 1,
            variant2 = 1,
            price = 8.20,
        },
        {
            type = 8,
            variant = 4,
            variant2 = 1,
            price = 8.90,
        },
        {
            type = 6,
            variant = 0,
            variant2 = 0,
            price = 26.10,
            value = 20,
        },
        {
            type = 19,
            variant = 0,
            variant2 = 0,
            price = 10,
            value = 20,
        },
        {
            type = 19,
            variant = 0,
            variant2 = 1,
            price = 10,
            value = 20,
        },
    })
end
addEvent("openSevenStoreShop", true)
addEventHandler("openSevenStoreShop", root, openSevenStoreShop)
