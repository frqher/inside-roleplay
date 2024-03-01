local NPCs = {
    {
        skin = 9,
        pos = Vector3(-2428.1064453125, 829.07946777344, 66.400001525879),
        int = 0,
        dim = 4,
        rot = 182,
        name = "Liyana Dyer",
    },
}

function speakToTherapist(ped, data)
    triggerClientEvent(client, "onTherapistSelect", resourceRoot, data)
end
addEvent("speakToTherapist", true)
addEventHandler("speakToTherapist", root, speakToTherapist)

function onTherapistPay(state, data)
    triggerClientEvent(source, "therapistResponse", resourceRoot, data, state)
end
addEvent("onTherapistPay", true)
addEventHandler("onTherapistPay", root, onTherapistPay)

function createTherapists()
    local dialogue = exports.TR_npc:createDialogue()
    exports.TR_npc:addDialogueText(dialogue, "Merhaba. tedavi olmak istiyorum.", {pedResponse = "Merhaba. Tedavi ucuz değil ama yardımcı olacak. Şu anda boş bir randevum var. Sorun ne?"})

    exports.TR_npc:addDialogueText(dialogue, "Kumardan kurtulmak istiyorum.", {pedResponse = "Ne yapabileceğimizi göreceğiz.", responseTo = "Merhaba. tedavi olmak istiyorum.", img = "quest", trigger = "speakToTherapist", triggerData = "casino"})
    exports.TR_npc:addDialogueText(dialogue, "Alkolden kurtulmak istiyorum.", {pedResponse = "Ne yapabileceğimizi göreceğiz.", responseTo = "Merhaba. tedavi olmak istiyorum.", img = "quest", trigger = "speakToTherapist", triggerData = "cheers"})
    exports.TR_npc:addDialogueText(dialogue, "Nikotinden kurtulmak istiyorum.", {pedResponse = "Ne yapabileceğimizi göreceğiz.", responseTo = "Merhaba. tedavi olmak istiyorum.", img = "quest", trigger = "speakToTherapist", triggerData = "smoking"})
    exports.TR_npc:addDialogueText(dialogue, "Uyuşturucu bağımlılığından kurtulmak istiyorum.", {pedResponse = "Ne yapabileceğimizi göreceğiz.", responseTo = "Merhaba. tedavi olmak istiyorum.", img = "quest", trigger = "speakToTherapist", triggerData = "pills"})

    exports.TR_npc:addDialogueText(dialogue, "Ne kadar pahalı teşekkür edecek.", {pedResponse = "Sorun değil. Lütfen daha sonraki zamanların uygun olmayabileceğini unutmayın.", responseTo = "Merhaba. tedavi olmak istiyorum."})
    exports.TR_npc:addDialogueText(dialogue, "Güle güle.", {pedResponse = "Güle güle."})

    for i, v in pairs(NPCs) do
        local ped = exports.TR_npc:createNPC(v.skin, v.pos.x, v.pos.y, v.pos.z, v.rot, v.name, "Psikolog", "dialogue")
        setElementInterior(ped, v.int)
        setElementDimension(ped, v.dim)

        exports.TR_npc:setNPCDialogue(ped, dialogue)
    end
end
createTherapists()


-- Features
function updateFeatures(lungs, weapon)
    setPedStat(client, 22, lungs * 10)
    setPedStat(client, 225, lungs * 10)

    weapon= 90
    if weapon >= 90 then
        setPedStat(client, 70, 1000)
        setPedStat(client, 71, 1000)
        setPedStat(client, 76, 1000)
        setPedStat(client, 77, 1000)
        setPedStat(client, 78, 1000)
    end
end
addEvent("updateFeatures", true)
addEventHandler("updateFeatures", resourceRoot, updateFeatures)