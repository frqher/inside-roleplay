local NPCs = {
    {
        skin = 41,
        pos = Vector3(-23.149248123169, -57.347965240479, 1003.546875),
        int = 6,
        dim = 1,
        rot = 351,
        name = "Julliet Jonter",
        shopName = "Roboi's Food Mart",
    },
    {
        skin = 25,
        pos = Vector3(-23.149248123169, -57.347965240479, 1003.546875),
        int = 6,
        dim = 2,
        rot = 351,
        name = "Rayan Granter",
        shopName = "Roboi's Food Mart",
    },
    {
        skin = 25,
        pos = Vector3(2255.4580078125, -1414.5152587891, 109.02599334717),
        int = 0,
        dim = 8,
        rot = 270,
        name = "Thomas Frank",
        shopName = "Roboi's Food Mart",
    },
    {
        skin = 41,
        pos = Vector3(-22.159936904907, -140.31468200684, 1003.546875),
        int = 16,
        dim = 1,
        rot = 351,
        name = "Zuza Dron",
        shopName = "69¢ Store",
    },
}

function createDonutsNPC()
    local dialogue = exports.TR_npc:createDialogue()
    exports.TR_npc:addDialogueText(dialogue, "Günaydın. Lütfen...", {pedResponse = "", img = "shop", trigger = "openShopMenu", triggerData = {"market"}})
    exports.TR_npc:addDialogueText(dialogue, "Hoşçakal.", {pedResponse = "Hoşçakal."})

    for i, v in pairs(NPCs) do
        local ped = exports.TR_npc:createNPC(v.skin, v.pos.x, v.pos.y, v.pos.z, v.rot, v.name, "Mağaza Çalışanı", "dialogue")
        setElementInterior(ped, v.int)
        setElementDimension(ped, v.dim)
        setElementData(ped, "shopName", v.shopName or "Market", false)

        exports.TR_npc:setNPCDialogue(ped, dialogue)
    end
end
createDonutsNPC()
