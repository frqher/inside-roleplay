local NPCs = {
    {
        skin = 72,
        pos = Vector3(2147.3251953125, -2082.3503417969, 132.01028442383),
        int = 0,
        dim = 7,
        rot = 0,
        name = "Roberth Denim",
    },

    {
        skin = 72,
        pos = Vector3(2147.3251953125, -2082.3503417969, 132.01028442383),
        int = 0,
        dim = 10,
        rot = 0,
        name = "Jhon Hansen",
    },
}

function createDonutsNPC()
    local dialogue = exports.TR_npc:createDialogue()
    exports.TR_npc:addDialogueText(dialogue, "Günaydın. Lütfen...", {pedResponse = "", img = "shop", trigger = "openLiquorShop"})
    exports.TR_npc:addDialogueText(dialogue, "Hoşçakal.", {pedResponse = "Hoşçakal."})

    for i, v in pairs(NPCs) do
        local ped = exports.TR_npc:createNPC(v.skin, v.pos.x, v.pos.y, v.pos.z, v.rot, v.name, "Mağaza Çalışanı", "dialogue")
        setElementInterior(ped, v.int)
        setElementDimension(ped, v.dim)

        exports.TR_npc:setNPCDialogue(ped, dialogue)
    end
end
createDonutsNPC()


function openLiquorShop(ped)
    triggerClientEvent(client, "createShop", resourceRoot, "Sklep Liquor & Deli", {
        {
            type = 2,
            variant = 0,
            variant2 = 5,
            price = 4,
        },
        {
            type = 2,
            variant = 0,
            variant2 = 7,
            price = 3,
        },
        {
            type = 2,
            variant = 0,
            variant2 = 8,
            price = 2.50,
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
            variant2 = 8,
            price = 6.50,
        },
        {
            type = 8,
            variant = 0,
            variant2 = 0,
            price = 40.20,
        },
        {
            type = 8,
            variant = 1,
            variant2 = 0,
            price = 44.70,
        },
        {
            type = 8,
            variant = 2,
            variant2 = 0,
            price = 52.20,
        },
        {
            type = 8,
            variant = 1,
            variant2 = 1,
            price = 7.20,
        },
        {
            type = 8,
            variant = 3,
            variant2 = 1,
            price = 4.40,
        },
        {
            type = 8,
            variant = 4,
            variant2 = 1,
            price = 6.90,
        },
        {
            type = 6,
            variant = 0,
            variant2 = 0,
            price = 15.90,
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
addEvent("openLiquorShop", true)
addEventHandler("openLiquorShop", root, openLiquorShop)
