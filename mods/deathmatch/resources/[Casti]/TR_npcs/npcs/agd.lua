local NPCs = {
    {
        skin = 25,
        pos = Vector3(2777.6513671875, -1320.0494384766, -88.546493530273),
        int = 0,
        dim = 5,
        rot = 1,
        name = "Austen Graves",
    },
}

function createAGDNPC()
    local dialogue = exports.TR_npc:createDialogue()
    exports.TR_npc:addDialogueText(dialogue, "Bir ses sistemi satın almak istiyorum.", {pedResponse = "", img = "shop", trigger = "openShopMenu", triggerData = {"agd"}})
    exports.TR_npc:addDialogueText(dialogue, "Görüşürüz.", {pedResponse = "Görüşürüz."})

    for i, v in pairs(NPCs) do
        local ped = exports.TR_npc:createNPC(v.skin, v.pos.x, v.pos.y, v.pos.z, v.rot, v.name, "AGD Mağazası Çalışanı", "dialogue")
        setElementInterior(ped, v.int)
        setElementDimension(ped, v.dim)

        exports.TR_npc:setNPCDialogue(ped, dialogue)
    end
end

createAGDNPC()



