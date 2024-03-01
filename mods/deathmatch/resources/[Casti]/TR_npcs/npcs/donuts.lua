local NPCs = {
    {
        skin = 209,
        pos = Vector3(380.65881347656, -189.09280395508, 1000.6328125),
        int = 17,
        dim = 1,
        rot = 83,
        name = "Ray Doner",
    },
    {
        skin = 209,
        pos = Vector3(380.65881347656, -189.09280395508, 1000.6328125),
        int = 17,
        dim = 2,
        rot = 83,
        name = "Remy Klone",
    },
    {
        skin = 209,
        pos = Vector3(380.65881347656, -189.09280395508, 1000.6328125),
        int = 17,
        dim = 3,
        rot = 83,
        name = "Franklin Groves",
    },
}
function createDonutsNPC()
    local dialogue = exports.TR_npc:createDialogue()
    exports.TR_npc:addDialogueText(dialogue, "Günaydın. Lütfen...", {pedResponse = "", img = "shop", trigger = "openShopMenu", triggerData = {"donuts"}})
    exports.TR_npc:addDialogueText(dialogue, "Hoşçakal.", {pedResponse = "Hoşçakal."})

    for i, v in pairs(NPCs) do
        local ped = exports.TR_npc:createNPC(v.skin, v.pos.x, v.pos.y, v.pos.z, v.rot, v.name, "Ring Donuts Çalışanı", "dialogue")
        setElementInterior(ped, v.int)
        setElementDimension(ped, v.dim)

        exports.TR_npc:setNPCDialogue(ped, dialogue)
    end
end
createDonutsNPC()
