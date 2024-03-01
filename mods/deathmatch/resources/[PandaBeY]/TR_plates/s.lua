local NPCs = {
    {
        model = 172,
        pos = {2845.9543457031, -1128.9752197266, 113.32746124268, 285},
        int = 0,
        dim = 50,
        name = "Jessica Trone",
    },
    {
        model = 57,
        pos = {2846.0588378906, -1125.001953125, 113.32707977295, 285},
        int = 0,
        dim = 50,
        name = "Wang Omori",
    },
    {
        model = 57,
        pos = {-2015.4873046875, -84.404495239258, 85, 349},
        int = 0,
        dim = 9,
        name = "Okuro Hasink",
    },
}

function createNPC()
    local dialogue = exports.TR_npc:createDialogue()
	exports.TR_npc:addDialogueText(dialogue, "Günaydın.", {pedResponse = "Nasıl yardımcı olabilirim?"})
    exports.TR_npc:addDialogueText(dialogue, "Görüşürüz bro.", {pedResponse = "Güle güle."})
    exports.TR_npc:addDialogueText(dialogue, "Aracımı yeniden kaydettirmek istiyorum.", {pedResponse = "Lütfen başvuruyu tamamlayın.", responseTo = "Günaydın.", img = "plate", trigger = "changeVehiclePlate"})

    for i, v in pairs(NPCs) do
        local npc = exports.TR_npc:createNPC(v.model, v.pos[1], v.pos[2], v.pos[3], v.pos[4], v.name, "Rejestracja pojazdów", "dialogue")
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

function changeVehiclePlate()
    local uid = getElementData(source, "characterUID")
    local vehicles = exports.TR_mysql:querry("SELECT ID, model, plateText FROM tr_vehicles WHERE ownedPlayer = ?", uid)
    if not vehicles or #vehicles < 1 then exports.TR_noti:create(source, "Yeniden kayıt ettirebileceğiniz aracınız yok.", "error") return end

    triggerClientEvent(source, "createPlateChange", resourceRoot, vehicles)
end
addEvent("changeVehiclePlate", true)
addEventHandler("changeVehiclePlate", root, changeVehiclePlate)


function playerChangePlateVehicle(state, data)
    if state then
        exports.TR_mysql:querry("UPDATE tr_vehicles SET plateText = ? WHERE ID = ? LIMIT 1", data[2], data[1])

        local vehicle = getElementByID("vehicle"..data[1])
        if vehicle then
            setVehiclePlateText(vehicle, string.format("SA %s", data[2]))
        end
        triggerClientEvent(source, "plateChangeResponse", resourceRoot, "Araç başarıyla yeniden kaydedildi.", "success")
        return
    end
    triggerClientEvent(source, "plateChangeResponse", resourceRoot)
end
addEvent("playerChangePlateVehicle", true)
addEventHandler("playerChangePlateVehicle", root, playerChangePlateVehicle)