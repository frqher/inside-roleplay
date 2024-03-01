function endTutorial(uid)
    exports.TR_mysql:querry("UPDATE tr_accounts SET tutorial = NULL WHERE UID = ? LIMIT 1", uid)
end
addEvent("endTutorial", true)
addEventHandler("endTutorial", resourceRoot, endTutorial)


function createScenery()
    local boat = createVehicle(454, -4569, 289.7, 0, 0, 0, 247)
    setElementFrozen(boat, true)
    setVehicleColor(boat, 144,42,25,254,254,254,144,42,25,144,42,25)

    addEventHandler("onVehicleStartEnter", boat, function() cancelEvent() end)

    -- Dawn brother
    local dialogue = exports.TR_npc:createDialogue()
    exports.TR_npc:addDialogueText(dialogue, "Merhaba.", {pedResponse = "Merhaba. Seni buraya ne getirdi?"})
    exports.TR_npc:addDialogueText(dialogue, "Hiçbir şey, buraya yeni geldim.", {pedResponse = "O halde kardeşimin evine hoş geldiniz. Bir şey istersen masadan kendine yardım et.", responseTo = "Merhaba."})
    exports.TR_npc:addDialogueText(dialogue, "Ben söyleyemem.", {pedResponse = "Federal misin? Eğer öyleyse, dışarı çık!", responseTo = "Merhaba."})
    exports.TR_npc:addDialogueText(dialogue, "Şehre nasıl gideceğimi bilmek istiyorum.", {pedResponse = "Ve bu seferki sensin. Neyse geri dönüş yok.", responseTo = "Merhaba."})
    exports.TR_npc:addDialogueText(dialogue, "Nasıl yani?! [Push Eğitimi]", {pedResponse = "Evet, bu o! Kasabaya geri döndüğünüz tek an, masanın üzerindekilerden alabileceğiniz neşe anıdır! Al ve tereddüt etme. Sana söylüyorum, pişman olmayacaksın! Neyse, eğer bana inanmıyorsan kardeşim Dawn'ı ara. O sana her şeyi açıklayacak.", responseTo = "Şehre nasıl gideceğimi bilmek istiyorum."})
    exports.TR_npc:addDialogueText(dialogue, "En azından bana numarasını verebilir misin?", {pedResponse = "İyi peki! 800-57-83", responseTo = "Nasıl yani?! [Push Eğitimi]"})
    exports.TR_npc:addDialogueText(dialogue, "Yalan söyleme!", {pedResponse = "İstediğiniz kadar dikkatli olun. Benim fikrim var, seninki de var.", responseTo = "Şehre nasıl gideceğimi bilmek istiyorum."})

    exports.TR_npc:addDialogueText(dialogue, "Sizi ilgilendirmez.", {pedResponse = "Bu kadar sıra dışı olan ne? Sadece benim dairemde değilsin, aynı zamanda böyle davranıyorsun.", responseTo = "Merhaba."})

    exports.TR_npc:addDialogueText(dialogue, "Dikkatli ol.", {pedResponse = "Sen de."})

    local ped = exports.TR_npc:createNPC(142, 2703.6733398438, -1427.5433349609, 63.031028747559, 90, "Joseph Hort", "Mieszkaniec wyspy", "dialogue")
    setElementInterior(ped, 0)
    setElementDimension(ped, 5)
    setElementData(ped, "animation", {"beach", "Lay_Bac_Loop"})

    exports.TR_npc:setNPCDialogue(ped, dialogue)


    -- Boat
    local dialogue = exports.TR_npc:createDialogue()
    exports.TR_npc:addDialogueText(dialogue, "kıyıya varmak isterim.", {pedResponse = "Bedava yüzmüyorum. Bu yolculuğun bana maliyeti 5.000 dolar."})
    exports.TR_npc:addDialogueText(dialogue, "Belki başka bir şekilde anlaşmaya varırız?", {pedResponse = "", responseTo = "kıyıya varmak isterim.", trigger = "tutorialTrade"})
    exports.TR_npc:addDialogueText(dialogue, "o kadar param yok.", {pedResponse = "Peki, bu konuda yapabileceğim hiçbir şey yok.", responseTo = "Kıyıya varmak isterim."})

    exports.TR_npc:addDialogueText(dialogue, "Güzel yat.", {pedResponse = "Teşekkür ederim, teşekkür ederim."})

    local ped = exports.TR_npc:createNPC(142, -4573.20703125, 290.2080078125, 1.218750953674, 316, "Matthew McGort", "Przewoźnik", "dialogue")
    exports.TR_npc:setNPCDialogue(ped, dialogue)
end
createScenery()


function tutorialTrade()
    triggerClientEvent(client, "tutorialTrade", resourceRoot)
end
addEvent("tutorialTrade", true)
addEventHandler("tutorialTrade", root, tutorialTrade)