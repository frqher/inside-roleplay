local NPCs = {
    {
        skin = 217,
        pos = Vector3(1532.9587158203, -2229.1955175781, 92.678314208984),
        int = 0,
        dim = 15,
        rot = 96,
        name = "Mark Grone",
        animation = {"ped", "SEAT_idle"},
    },
}

function createRadioNPC()
    local dialogue = exports.TR_npc:createDialogue()
    exports.TR_npc:addDialogueText(dialogue, "Merhaba. Birkaç sorum var.", {pedResponse = "Buyurun, sorularınızı bekliyorum. Bildiğim tüm sorulara cevap vermeye çalışacağım."})
    exports.TR_npc:addDialogueText(dialogue, "Televizyon binasında radyo merkezi nerede?", {pedResponse = "Interglobal Television firması programlarıyla o kadar popüler oldu ki kendi radyomuzu da oluşturmaya karar verdik. İnsanlar bizi izlemek istiyorlarsa, neden işe giderken bizi dinlemesinler ki?", responseTo = "Merhaba. Birkaç sorum var."})
    exports.TR_npc:addDialogueText(dialogue, "Reklam ne kadar?", {pedResponse = "Televizyonumuz insanların tüm güncel olaylarla ilgili olmalarını istediği için radyomuzdaki reklamlar tamamen ücretsizdir.", responseTo = "Merhaba. Birkaç sorum var."})
    exports.TR_npc:addDialogueText(dialogue, "Nasıl reklam yapabilirim?", {pedResponse = "Bu çok zor değil! Lütfen bu odaya gelin, mikrofonun yanına geçin ve bir şeyler söyleyin. Ben tüm konuşmayı kaydedeceğim ve uygun zamanı geldiğinde oynatacağım.", responseTo = "Merhaba. Birkaç sorum var."})
    exports.TR_npc:addDialogueText(dialogue, "Kendi plaklarımı kaydetmek istiyorum.", {pedResponse = "Müzik yapmak zor değil, ama hit yapmak ve beğenilmek çok zor. İşlerim biraz daha sakinleştiğinde gel ve yeteneklerini göstereyim, sonra düşünürüz.", responseTo = "Merhaba. Birkaç sorum var."})
    exports.TR_npc:addDialogueText(dialogue, "Konuşamayacağım konular var mı?", {pedResponse = "Genel olarak istediğiniz her şeyi duyurabilirsiniz, ancak uyuşturucular veya silahlar gibi konulardan bahsedemezsiniz.", responseTo = "Merhaba. Birkaç sorum var."})
    exports.TR_npc:addDialogueText(dialogue, "Hoşça kalın.", {pedResponse = "Hoşça kalın."})

    for i, v in pairs(NPCs) do
        local ped = exports.TR_npc:createNPC(v.skin, v.pos.x, v.pos.y, v.pos.z, v.rot, v.name, "Radyo Çalışanı", "dialogue")
        setElementInterior(ped, v.int)
        setElementDimension(ped, v.dim)
        if v.animation then setElementData(ped, "animation", v.animation) end

        exports.TR_npc:setNPCDialogue(ped, dialogue)
    end
end
createRadioNPC()
