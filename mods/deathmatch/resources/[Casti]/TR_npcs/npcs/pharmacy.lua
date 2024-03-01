local NPCs = {
    {
        skin = 274,
        pos = Vector3(730.05236816406, -1364.03515625, 30.299999237061),
        int = 0,
        dim = 5,
        rot = 176,
        name = "Noor Gilliam",
    },
    {
        skin = 274,
        pos = Vector3(870.95684814453, -1447.1984863281, 37.64374923706),
        int = 0,
        dim = 5,
        rot = 268,
        name = "Willem Scott",
    },
    {
        skin = 274,
        pos = Vector3(1090.935546875, -1218.8583984375, -92.256256103516),
        int = 0,
        dim = 5,
        rot = 180,
        name = "Freddie Magana",
    },
}

function createPharmacyNPC()
    local dialogue = exports.TR_npc:createDialogue()
    exports.TR_npc:addDialogueText(dialogue, "Merhaba. İyi değilim. ...", {pedResponse = "", img = "shop", trigger = "openShopMenu", triggerData = {"pharmacy"}})
    exports.TR_npc:addDialogueText(dialogue, "Görüşmek üzere.", {pedResponse = "Görüşmek üzere."})

    for i, v in pairs(NPCs) do
        local ped = exports.TR_npc:createNPC(v.skin, v.pos.x, v.pos.y, v.pos.z, v.rot, v.name, "Eczane Çalışanı", "dialogue")
        setElementInterior(ped, v.int)
        setElementDimension(ped, v.dim)
        setElementData(ped, "shopName", v.shopName or "Market", false)

        exports.TR_npc:setNPCDialogue(ped, dialogue)
    end
end
createPharmacyNPC()
