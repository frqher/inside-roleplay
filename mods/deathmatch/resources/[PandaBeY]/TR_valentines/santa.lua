function createSanta()
    local dialogue = exports.TR_npc:createDialogue()
    exports.TR_npc:addDialogueText(dialogue, "Mutlu sevgililer günü!", {pedResponse = "Ve aşık... Ve aşık..."})
    exports.TR_npc:addDialogueText(dialogue, "Benim için bir şeyin var mı?", {pedResponse = "", trigger = "tryGet3dayGift", img = "giftbox"})

    exports.TR_npc:addDialogueText(dialogue, "Żegnaj.", {pedResponse = "Do zobaczenia."})

    local santa = exports.TR_npc:createNPC(200, -1915.369140625, 897.736328125, 35.4140625, 126, "Święty Walenty", "Etkinlik Rehberi", "dialogue")
    exports.TR_npc:setNPCDialogue(santa, dialogue)
    setTimer(setPedAnimation, 100, 1, santa, "ON_LOOKERS", "wave_loop")
    setElementData(santa, "animation", {"ON_LOOKERS", "wave_loop"})
end
createSanta()

function tryGet3dayGift()
    local uid = getElementData(client, "characterUID")
    local prize = exports.TR_mysql:querry("SELECT * FROM tr_santaGifts WHERE playerUID = ? LIMIT 1", uid)

    if prize and prize[1] then
        triggerClientEvent(client, "showCustomMessage", resourceRoot, "Święty Walenty", "Başkalarına biraz sevgi bırakın! Hediyenizi zaten aldınız.", "files/images/npc.png")
    else
        exports.TR_mysql:querry("INSERT INTO `tr_santaGifts`(`playerUID`) VALUES (?)", uid)
        triggerClientEvent(client, "openSantaPrizePicker", resourceRoot, {money = 0, gold = 0, diamond = 0, vehicle = 0, house = 0}, true)
    end
end
addEvent("tryGet3dayGift", true)
addEventHandler("tryGet3dayGift", root, tryGet3dayGift)