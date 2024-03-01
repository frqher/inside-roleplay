local NPCs = {
    {
        model = 194,
        pos = {2853.0490722656, -1138.8924560547, 113.27780151367, 0},
        int = 0,
        dim = 50,
        name = "Izabeth Grans",
        govID = 1,
    },
    {
        model = 194,
        pos = {-2016.55859375, -80.968757629395, 85, 279},
        int = 0,
        dim = 9,
        name = "Grace Hasko",
        govID = 2,
    },
}

function createNPC()
    local dialogue = exports.TR_npc:createDialogue()
	exports.TR_npc:addDialogueText(dialogue, "Günaydın.", {pedResponse = "Günaydın. Nasıl yardımcı olabilirim?"})
    exports.TR_npc:addDialogueText(dialogue, "Hoşça kal.", {pedResponse = "Hoşça kal."})
    exports.TR_npc:addDialogueText(dialogue, "Fraksiyon ödemesi almak istiyorum.", {pedResponse = "", responseTo = "Günaydın.", trigger = "getFractionPayments"})

    for i, v in pairs(NPCs) do
        local npc = exports.TR_npc:createNPC(v.model, v.pos[1], v.pos[2], v.pos[3], v.pos[4], v.name, "Fraksiyon ofisi çalışanı", "dialogue")
        setElementInterior(npc, v.int)
        setElementDimension(npc, v.dim)

        exports.TR_npc:setNPCDialogue(npc, dialogue)

        if v.anim then
            setPedAnimation(npc, v.anim[1], v.anim[2])
            setElementData(npc, "animation", v.anim)
        end
    end
end
createNPC()


function getFractionPayments(ped)
    local pedName = getElementData(ped, "name")
    local uid = getElementData(client, "characterUID")

    local payment = exports.TR_mysql:querry("SELECT SUM(count) as count FROM tr_fractionsDutyTimes WHERE playerUID = ? AND day < CURDATE() AND takenMoney IS NULL", uid)
    if payment then
        if payment[1] and payment[1].count then
            if tonumber(payment[1].count) > 0 then
                if exports.TR_core:giveMoneyToPlayer(client, tonumber(payment[1].count)) then
                    triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, string.format("Buyurun. Ödemeniz $%.2f tutarındadır.", tonumber(payment[1].count)), "files/images/npc.png")
                end
                exports.TR_mysql:querry("UPDATE tr_fractionsDutyTimes SET takenMoney = 1 WHERE playerUID = ? AND day < CURDATE() AND takenMoney IS NULL", uid)
            else
                triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Üzgünüm, ancak sistemde alınacak herhangi bir ödeme bulunmamaktadır.", "files/images/npc.png")
            end
        else
            triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Üzgünüm, ancak sistemde alınacak herhangi bir ödeme bulunmamaktadır.", "files/images/npc.png")
        end
    else
        triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Üzgünüm, ancak sistemde alınacak herhangi bir ödeme bulunmamaktadır.", "files/images/npc.png")
    end
end
addEvent("getFractionPayments", true)
addEventHandler("getFractionPayments", root, getFractionPayments)