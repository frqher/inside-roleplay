removeWorldModel(2627, 100, 766.3720703125, -39.470703125, 1000.6864624023, 6)
removeWorldModel(2629, 100, 766.3720703125, -39.470703125, 1000.6864624023, 6)
removeWorldModel(2630, 100, 766.3720703125, -39.470703125, 1000.6864624023, 6)

local NPCs = {
    {
        skin = 122,
        pos = Vector3(-1548.6949462891, 873.4296875, 25.265625),
        rot = 265,
        name = "Mark Hart",
        role = "Spor salonu çalışanı",
        int = 0,
        dim = 4,
    },
    {
        skin = 122,
        pos = Vector3(-1555.0872802734, 805.06658935547, 26.688190460205),
        rot = 0,
        name = "John Tarner",
        role = "Spor salonu çalışanı",
        int = 0,
        dim = 4,
    },
    {
        skin = 122,
        pos = Vector3(-1505.2224121094, 803.01190185547, 26.67812538147),
        rot = 0,
        name = "Thomas Harner",
        role = "Spor salonu çalışanı",
        int = 0,
        dim = 4,
    },
}

function createNpcs()
    local dialogue = exports.TR_npc:createDialogue()
    exports.TR_npc:addDialogueText(dialogue, "Merhaba.", {pedResponse = "Merhaba. Size nasıl yardımcı olabilirim?"})
    exports.TR_npc:addDialogueText(dialogue, "Bir abonelik satın almak istiyorum.", {pedResponse = "", responseTo = "Merhaba.", trigger = "speakToBuyWorkoutTicket"})
    exports.TR_npc:addDialogueText(dialogue, "Abonelik ne kadar süreyle geçerli?", {pedResponse = "Spor salonumuzdaki abonelikler bir saat boyunca geçerlidir.", responseTo = "Merhaba."})

    exports.TR_npc:addDialogueText(dialogue, "Hoşçakal.", {pedResponse = "Hoşçakal."})

    for i, v in pairs(NPCs) do
        local ped = exports.TR_npc:createNPC(v.skin, v.pos.x, v.pos.y, v.pos.z, v.rot, v.name, v.role, "dialogue")
        setElementInterior(ped, v.int)
        setElementDimension(ped, v.dim)

        exports.TR_npc:setNPCDialogue(ped, dialogue)
    end
end

function speakToBuyWorkoutTicket()
    triggerClientEvent(client, "buyWorkoutTicket", resourceRoot)
end
addEvent("speakToBuyWorkoutTicket", true)
addEventHandler("speakToBuyWorkoutTicket", root, speakToBuyWorkoutTicket)

function playerPayForGymTicket(state)
    triggerClientEvent(source, "playerPayForGymTicket", resourceRoot, state)
end
addEvent("playerPayForGymTicket", true)
addEventHandler("playerPayForGymTicket", root, playerPayForGymTicket)

createNpcs()
