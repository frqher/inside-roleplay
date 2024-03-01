local NPCs = {
    {
        skin = 167,
        pos = Vector3(368.65399169922, -4.492769241333, 1001.8515625),
        int = 9,
        dim = 1,
        rot = 181,
        name = "Roman Marks",
    },
    {
        skin = 167,
        pos = Vector3(368.65399169922, -4.492769241333, 1001.8515625),
        int = 9,
        dim = 2,
        rot = 181,
        name = "Max Daber",
    },
    {
        skin = 167,
        pos = Vector3(368.65399169922, -4.492769241333, 1001.8515625),
        int = 9,
        dim = 3,
        rot = 181,
        name = "Elliot Fanres",
    },
    {
        skin = 167,
        pos = Vector3(368.65399169922, -4.492769241333, 1001.8515625),
        int = 9,
        dim = 4,
        rot = 181,
        name = "Austin Boben",
    },
    {
        skin = 167,
        pos = Vector3(368.65399169922, -4.492769241333, 1001.8515625),
        int = 9,
        dim = 5,
        rot = 181,
        name = "Cooper Grants",
    },
    {
        skin = 167,
        pos = Vector3(368.65399169922, -4.492769241333, 1001.8515625),
        int = 9,
        dim = 6,
        rot = 181,
        name = "Jonathan Newber",
    },
    {
        skin = 167,
        pos = Vector3(368.65399169922, -4.492769241333, 1001.8515625),
        int = 9,
        dim = 7,
        rot = 181,
        name = "Adrian Halys",
    },
    {
        skin = 167,
        pos = Vector3(368.65399169922, -4.492769241333, 1001.8515625),
        int = 9,
        dim = 8,
        rot = 181,
        name = "Connor Dran",
    },
    {
        skin = 167,
        pos = Vector3(368.65399169922, -4.492769241333, 1001.8515625),
        int = 9,
        dim = 9,
        rot = 181,
        name = "Oliver Knott",
    },
    {
        skin = 167,
        pos = Vector3(368.65399169922, -4.492769241333, 1001.8515625),
        int = 9,
        dim = 10,
        rot = 181,
        name = "Mateo Bans",
    },
    {
        skin = 167,
        pos = Vector3(368.65399169922, -4.492769241333, 1001.8515625),
        int = 9,
        dim = 11,
        rot = 181,
        name = "Jackob Frans",
    },
    {
        skin = 167,
        pos = Vector3(368.65399169922, -4.492769241333, 1001.8515625),
        int = 9,
        dim = 12,
        rot = 181,
        name = "Lukas Graven",
    },
    {
        skin = 167,
        pos = Vector3(368.65399169922, -4.492769241333, 1001.8515625),
        int = 9,
        dim = 13,
        rot = 181,
        name = "Sebastian Orren",
    },
}

function createCluckinNPC()
    local dialogue = exports.TR_npc:createDialogue()
    exports.TR_npc:addDialogueText(dialogue, "Günaydın. Lütfen...", {pedResponse = "", img = "shop", trigger = "openShopMenu", triggerData = {"cluckin"}})
    exports.TR_npc:addDialogueText(dialogue, "Hoşçakal.", {pedResponse = "Hoşçakal."})

    for i, v in pairs(NPCs) do
        local ped = exports.TR_npc:createNPC(v.skin, v.pos.x, v.pos.y, v.pos.z, v.rot, v.name, "Cluckin' Bell Çalışanı", "dialogue")
        setElementInterior(ped, v.int)
        setElementDimension(ped, v.dim)

        exports.TR_npc:setNPCDialogue(ped, dialogue)
    end
end
createCluckinNPC()
