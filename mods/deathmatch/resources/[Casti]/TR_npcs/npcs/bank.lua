local NPCs = {
    -- LS
    {
        skin = 76,
        pos = Vector3(1422.3033447266, -2552.0017089844, 70.645309448242),
        int = 0,
        dim = 2,
        rot = 88,
        name = "Emily Tracko",
        role = "Banka çalışanı",
    },
    {
        skin = 141,
        pos = Vector3(1422.2052001953, -2556.8645019531, 70.645309448242),
        int = 0,
        dim = 2,
        rot = 88,
        name = "Ana Harten",
        role = "Banka çalışanı",
    },
    {
        skin = 150,
        pos = Vector3(1422.1984863281, -2561.9626464844, 70.645309448242),
        int = 0,
        dim = 2,
        rot = 88,
        name = "Lillia Trah",
        role = "Banka çalışanı",
    },
    {
        skin = 17,
        pos = Vector3(1422.1047363281, -2567.0715332031, 70.645309448242),
        int = 0,
        dim = 2,
        rot = 88,
        name = "Walter Gart",
        role = "Banka çalışanı",
    },

    -- SF
    {
        skin = 148,
        pos = Vector3(1422.3033447266, -2552.0017089844, 70.645309448242),
        int = 0,
        dim = 3,
        rot = 88,
        name = "Janna Gert",
        role = "Banka çalışanı",
    },
    {
        skin = 216,
        pos = Vector3(1422.2052001953, -2556.8645019531, 70.645309448242),
        int = 0,
        dim = 3,
        rot = 88,
        name = "Ana Klain",
        role = "Banka çalışanı",
    },
    {
        skin = 187,
        pos = Vector3(1422.1984863281, -2561.9626464844, 70.645309448242),
        int = 0,
        dim = 3,
        rot = 88,
        name = "Joseph Lart",
        role = "Banka çalışanı",
    },
    {
        skin = 46,
        pos = Vector3(1422.1047363281, -2567.0715332031, 70.645309448242),
        int = 0,
        dim = 3,
        rot = 88,
        name = "Henry Ters",
        role = "Banka çalışanı",
    },

    -- FC
    {
        skin = 46,
        pos = Vector3(2031.9924316406, -1987.9986572266, 90.800003051758),
        int = 0,
        dim = 3,
        rot = 270,
        name = "Thomas Ters",
        role = "Banka çalışanı",
    },
    {
        skin = 216,
        pos = Vector3(2031.8850097656, -1984.7047119141, 90.800003051758),
        int = 0,
        dim = 3,
        rot = 270,
        name = "Kayle Jenson",
        role = "Banka çalışanı",
    },
}


function createBankNPC()
    local dialogue = exports.TR_npc:createDialogue()
    exports.TR_npc:addDialogueText(dialogue, "Bankada hesap açmak istiyorum.", {pedResponse = "Ne yapabileceğimize bakalım.", img = "bank", trigger = "createBankAccount"})
    exports.TR_npc:addDialogueText(dialogue, "Güle güle.", {pedResponse = "Güle güle."})

    for i, v in pairs(NPCs) do
        local ped = exports.TR_npc:createNPC(v.skin, v.pos.x, v.pos.y, v.pos.z, v.rot, v.name, v.role, "dialogue")
        setElementInterior(ped, v.int)
        setElementDimension(ped, v.dim)

        exports.TR_npc:setNPCDialogue(ped, dialogue)
    end
end
createBankNPC()


function createBankAccount()
    local uid = getElementData(client, "characterUID")
    if not uid then return end

    local plrData = getElementData(client, "characterData")
    if plrData.bankcode then
        exports.TR_noti:create(client, "Zaten bir banka hesabınız var ve başka bir tane açamazsınız.", "error")
        return
    end

    triggerClientEvent(client, "createBankAccount", resourceRoot)
end
addEvent("createBankAccount", true)
addEventHandler("createBankAccount", root, createBankAccount)
