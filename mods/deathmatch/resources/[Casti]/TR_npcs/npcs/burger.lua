local NPCs = {
    {
        skin = 205,
        pos = Vector3(377.16528320313, -65.84757232666, 1001.5078125),
        int = 10,
        dim = 1,
        rot = 182,
        name = "Caroline Debers",
    },
    {
        skin = 205,
        pos = Vector3(377.16528320313, -65.84757232666, 1001.5078125),
        int = 10,
        dim = 2,
        rot = 182,
        name = "Alice Frank",
    },
    {
        skin = 205,
        pos = Vector3(377.16528320313, -65.84757232666, 1001.5078125),
        int = 10,
        dim = 3,
        rot = 182,
        name = "Ellen Dranke",
    },
    {
        skin = 205,
        pos = Vector3(377.16528320313, -65.84757232666, 1001.5078125),
        int = 10,
        dim = 4,
        rot = 182,
        name = "Catarine Hlost",
    },
    {
        skin = 205,
        pos = Vector3(377.16528320313, -65.84757232666, 1001.5078125),
        int = 10,
        dim = 5,
        rot = 182,
        name = "Joan Bran",
    },
    {
        skin = 205,
        pos = Vector3(377.16528320313, -65.84757232666, 1001.5078125),
        int = 10,
        dim = 6,
        rot = 182,
        name = "Elizabeth Adren",
    },
    {
        skin = 205,
        pos = Vector3(377.16528320313, -65.84757232666, 1001.5078125),
        int = 10,
        dim = 7,
        rot = 182,
        name = "Ann Mark",
    },
    {
        skin = 205,
        pos = Vector3(377.16528320313, -65.84757232666, 1001.5078125),
        int = 10,
        dim = 8,
        rot = 182,
        name = "Priscilla Dobber",
    },
    {
        skin = 205,
        pos = Vector3(377.16528320313, -65.84757232666, 1001.5078125),
        int = 10,
        dim = 9,
        rot = 182,
        name = "Luna Tune",
    },
    {
        skin = 205,
        pos = Vector3(377.16528320313, -65.84757232666, 1001.5078125),
        int = 10,
        dim = 10,
        rot = 182,
        name = "Isabella Johns",
    },
}

function createBurgerNPC()
    local dialogue = exports.TR_npc:createDialogue()
    exports.TR_npc:addDialogueText(dialogue, "Merhaba. Sipariş vermek istiyorum...", {pedResponse = "", img = "shop", trigger = "openShopMenu", triggerData = {"burger"}})
    exports.TR_npc:addDialogueText(dialogue, "Görüşmek üzere.", {pedResponse = "Görüşmek üzere."})

    for i, v in pairs(NPCs) do
        local ped = exports.TR_npc:createNPC(v.skin, v.pos.x, v.pos.y, v.pos.z, v.rot, v.name, "Burger Shot Çalışanı", "dialogue")
        setElementInterior(ped, v.int)
        setElementDimension(ped, v.dim)

        exports.TR_npc:setNPCDialogue(ped, dialogue)
    end
end
createBurgerNPC()
