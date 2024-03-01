local practiceVehicles = {}
local NPCs = {
    {
        skin = 93,
        pos = Vector3(1546.7843017578, -1884.5323486328, 59.006248474121),
        int = 0,
        dim = 5,
        rot = 256,
        name = "Eva Gran",
        role = "Resepsiyon",
        animation = {"ped", "SEAT_idle"},
        licenceType = "vehicle",
    },
    {
        skin = 17,
        pos = Vector3(415, 2537.138671875, 19.1484375),
        int = 0,
        dim = 0,
        rot = 145,
        name = "Pablo Daly",
        role = "LAPL Lisans Eğitmeni",
        licenceType = "lapl",
    },
    {
        skin = 258,
        pos = Vector3(-1661.6138916016, 1320.5501708984, 7.4250001907349),
        int = 0,
        dim = 0,
        rot = 130,
        name = "Orlando Hamer",
        role = "Dalış Eğitmeni",
        licenceType = "water",
    },
    {
        skin = 253,
        pos = Vector3(959.671875, -578.5771484375, 683.01873779297),
        int = 0,
        dim = 3,
        rot = 273,
        name = "Haydon Singh",
        role = "Yelken Eğitmeni",
        licenceType = "boat",
    },
}

function createNPCs()
    local dialogueVehicle = exports.TR_npc:createDialogue()
    exports.TR_npc:addDialogueText(dialogueVehicle, "Günaydın. Bir sınav planlamak istiyorum.", {pedResponse = "Sınav nasıl olacak? Teorik mi pratik mi?"})
    exports.TR_npc:addDialogueText(dialogueVehicle, "Teorik.", {pedResponse = "Ve hangi kategori?", responseTo = "Günaydın. Sınav için randevu almak istiyorum.."})
    exports.TR_npc:addDialogueText(dialogueVehicle, "Pratik.", {pedResponse = "Ve hangi kategori?", responseTo = "Günaydın. Sınav için randevu almak istiyorum.."})
    exports.TR_npc:addDialogueText(dialogueVehicle, "A Sınıfı.", {pedResponse = "", responseTo = "Teorik.", trigger = "buyLicenceExam", triggerData = {"a", "theory"}})
    exports.TR_npc:addDialogueText(dialogueVehicle, "B Sınıfı.", {pedResponse = "", responseTo = "Teorik.", trigger = "buyLicenceExam", triggerData = {"b", "theory"}})
    exports.TR_npc:addDialogueText(dialogueVehicle, "C Sınıfı.", {pedResponse = "", responseTo = "Teorik.", trigger = "buyLicenceExam", triggerData = {"c", "theory"}})
    exports.TR_npc:addDialogueText(dialogueVehicle, "A Sınıfı.", {pedResponse = "", responseTo = "Pratik.", trigger = "buyLicenceExam", triggerData = {"a", "practise"}})
    exports.TR_npc:addDialogueText(dialogueVehicle, "B Sınıfı.", {pedResponse = "", responseTo = "Pratik.", trigger = "buyLicenceExam", triggerData = {"b", "practise"}})
    exports.TR_npc:addDialogueText(dialogueVehicle, "C Sınıfı.", {pedResponse = "", responseTo = "Pratik.", trigger = "buyLicenceExam", triggerData = {"c", "practise"}})
    exports.TR_npc:addDialogueText(dialogueVehicle, "Güle güle.", {pedResponse = "Güle güle."})

    local dialogueLAPL = exports.TR_npc:createDialogue()
    exports.TR_npc:addDialogueText(dialogueLAPL, "Günaydın. Sınav için randevu almak istiyorum..", {pedResponse = "Sınav nasıl olacak? Teorik mi pratik mi?"})
    exports.TR_npc:addDialogueText(dialogueLAPL, "Teorik.", {pedResponse = "", responseTo = "Günaydın. Sınav için randevu almak istiyorum..", trigger = "buyLicenceExam", triggerData = {"LAPL", "theory"}})
    exports.TR_npc:addDialogueText(dialogueLAPL, "Pratik.", {pedResponse = "", responseTo = "Günaydın. Sınav için randevu almak istiyorum.."})
    exports.TR_npc:addDialogueText(dialogueLAPL, "Jednak żaden.", {pedResponse = "Tabii ki, o halde görüşürüz.", responseTo = "Günaydın. Sınav için randevu almak istiyorum.."})
    exports.TR_npc:addDialogueText(dialogueLAPL, "Güle güle.", {pedResponse = "Güle güle."})

    local dialogueWATER = exports.TR_npc:createDialogue()
    exports.TR_npc:addDialogueText(dialogueWATER, "Günaydın. Sınav için randevu almak istiyorum..", {pedResponse = "Sınav nasıl olacak? Teorik mi pratik mi?"})
    exports.TR_npc:addDialogueText(dialogueWATER, "Teorik.", {pedResponse = "", responseTo = "Günaydın. Sınav için randevu almak istiyorum..", trigger = "buyLicenceExam", triggerData = {"WATER", "theory"}})
    exports.TR_npc:addDialogueText(dialogueWATER, "Pratik.", {pedResponse = "", responseTo = "Günaydın. Sınav için randevu almak istiyorum..", trigger = "buyLicenceExam", triggerData = {"WATER", "practise"}})
    exports.TR_npc:addDialogueText(dialogueWATER, "Jednak żaden.", {pedResponse = "Tabii ki, o halde görüşürüz.", responseTo = "Günaydın. Sınav için randevu almak istiyorum.."})
    exports.TR_npc:addDialogueText(dialogueWATER, "Güle güle.", {pedResponse = "Güle güle."})

    local dialogueBoat = exports.TR_npc:createDialogue()
    exports.TR_npc:addDialogueText(dialogueBoat, "Günaydın. Sınav için randevu almak istiyorum..", {pedResponse = "Sınav nasıl olacak? Teorik mi pratik mi?"})
    exports.TR_npc:addDialogueText(dialogueBoat, "Teorik.", {pedResponse = "", responseTo = "Günaydın. Sınav için randevu almak istiyorum..", trigger = "buyLicenceExam", triggerData = {"BOAT", "theory"}})
    exports.TR_npc:addDialogueText(dialogueBoat, "Pratik.", {pedResponse = "", responseTo = "Günaydın. Sınav için randevu almak istiyorum..", trigger = "buyLicenceExam", triggerData = {"BOAT", "practise"}})
    exports.TR_npc:addDialogueText(dialogueBoat, "Jednak żaden.", {pedResponse = "Tabii ki, o halde görüşürüz.", responseTo = "Günaydın. Sınav için randevu almak istiyorum.."})
    exports.TR_npc:addDialogueText(dialogueBoat, "Güle güle.", {pedResponse = "Güle güle."})


    for i, v in pairs(NPCs) do
        local ped = exports.TR_npc:createNPC(v.skin, v.pos.x, v.pos.y, v.pos.z, v.rot, v.name, v.role, "dialogue")
        setElementInterior(ped, v.int)
        setElementDimension(ped, v.dim)
        if v.animation then setElementData(ped, "animation", v.animation) end

        if v.licenceType == "vehicle" then
            exports.TR_npc:setNPCDialogue(ped, dialogueVehicle)

        elseif v.licenceType == "lapl" then
            local blip = createBlip(v.pos.x, v.pos.y, v.pos.z, 0, 2, 22, 119, 222)
            setElementData(blip, "icon", 54)
            setElementData(blip, "blipName", "Flight School LAPL")
            exports.TR_npc:setNPCDialogue(ped, dialogueLAPL)

        elseif v.licenceType == "water" then
            local blip = createBlip(v.pos.x, v.pos.y, v.pos.z, 0, 2, 22, 119, 222)
            setElementData(blip, "icon", 56)
            setElementData(blip, "blipName", "San Andreas Diving School")
            exports.TR_npc:setNPCDialogue(ped, dialogueWATER)

        elseif v.licenceType == "boat" then
            exports.TR_npc:setNPCDialogue(ped, dialogueBoat)
        end
    end

    setGarageOpen(45, true)
end
createNPCs()



function buyLicenceExam(ped, data)
    local pedName = getElementData(ped, "name")
    local uid = getElementData(client, "characterUID")

    if data[2] == "theory" then
        local hasTheory = exports.TR_mysql:querry("SELECT UID FROM tr_accounts WHERE UID = ? AND licenceTheory LIKE ? LIMIT 1", uid, string.format('%%"%s"%%', data[1]))
        if hasTheory and hasTheory[1] then triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Bu kategori için teori sınavı zaten geçildi.", "files/images/npc.png")return end

        triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Tabii ki. Kartla mı nakit mi ödeme?", "files/images/npc.png")
        triggerClientEvent(client, "buyLicenceExam", resourceRoot, data)

    elseif data[2] == "practise" then
        local hasTheory = exports.TR_mysql:querry("SELECT UID FROM tr_accounts WHERE UID = ? AND licenceTheory LIKE ? LIMIT 1", uid, string.format('%%"%s"%%', data[1]))
        if not hasTheory or not hasTheory[1] then triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Pratik sınava girebilmek için öncelikle teori sınavını geçmeniz gerekir.", "files/images/npc.png") return end

        local hasLicence = exports.TR_mysql:querry("SELECT UID FROM tr_accounts WHERE UID = ? AND licence LIKE ? LIMIT 1", uid, string.format('%%"%s"%%', data[1]))
        if hasLicence and hasLicence[1] then triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Bu kategori sistemde zaten geçildi.", "files/images/npc.png") return end

        triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Tabii ki. Kartla mı nakit mi ödeme?", "files/images/npc.png")
        triggerClientEvent(client, "buyLicenceExam", resourceRoot, data)
    end
end
addEvent("buyLicenceExam", true)
addEventHandler("buyLicenceExam", root, buyLicenceExam)

function payLicenceExam(state, data)
    triggerClientEvent(source, "payLicenceExam", resourceRoot, state, data)
end
addEvent("payLicenceExam", true)
addEventHandler("payLicenceExam", root, payLicenceExam)

function playerPassedTheory(licence)
    local uid = getElementData(client, "characterUID")
    local theories = exports.TR_mysql:querry("SELECT licenceTheory FROM tr_accounts WHERE UID = ? LIMIT 1", uid)
    theories = theories[1].licenceTheory and fromJSON(theories[1].licenceTheory) or {}

    theories[licence] = true

    exports.TR_mysql:querry("UPDATE `tr_accounts` SET licenceTheory = ? WHERE UID = ? LIMIT 1", toJSON(theories), uid)
end
addEvent("playerPassedTheory", true)
addEventHandler("playerPassedTheory", root, playerPassedTheory)

function playerPassedPractise(licence, posData)
    local uid = getElementData(client, "characterUID")
    local plrData = getElementData(client, "characterData")

    if plrData.licence then
        plrData.licence[licence] = true
        setElementData(client, "characterData", plrData)

        exports.TR_mysql:querry("UPDATE `tr_accounts` SET licence = ? WHERE UID = ? LIMIT 1", toJSON(plrData.licence), uid)
    else
        plrData.licence = {}
        plrData.licence[licence] = true
        setElementData(client, "characterData", plrData)

        exports.TR_mysql:querry("UPDATE `tr_accounts` SET licence = ? WHERE UID = ? LIMIT 1", toJSON(plrData.licence), uid)
    end

    destroyPractiseVehicle(posData, client)
end
addEvent("playerPassedPractise", true)
addEventHandler("playerPassedPractise", root, playerPassedPractise)

function createLicencePracticeVehicle(category)
    local licenceData = licences[category]
    local road = licenceData.practiseRoad[1]

    if licenceData.playerSkin then
        setElementData(client, "lastSkin", getElementModel(client), false)
        setElementData(client, "lastCustomSkin", getElementData(client, "customModel"), false)
        setElementModel(client, licenceData.playerSkin)
        setElementData(client, "customModel", nil)
    end

    local veh = false
    if licenceData.vehicleModel then
        veh = createVehicle(licenceData.vehicleModel, road[1], road[2], road[3], 0, 0, licenceData.vehicleRot)
    else
        setElementHealth(client, 100)
        setElementPosition(client, road[1], road[2], road[3])
    end

    if licenceData.pedModel then
        local ped = createPed(licenceData.pedModel, road[1], road[2], road[3])
        setElementData(ped, "name", licenceData.pedName)
        setElementData(ped, "role", "Egzaminator")

        warpPedIntoVehicle(ped, veh, 1)
        exports.TR_objectManager:attachObjectToPlayer(client, ped)
    end

    setElementInterior(client, 0)
    setElementDimension(client, 0)

    if veh then
        warpPedIntoVehicle(client, veh, 0)

        setElementData(veh, "blockCollisions", true)
        setVehicleEngineState(veh, false)
        setElementFrozen(veh, true)
        setVehicleOverrideLights(veh, 1)
        setVehicleColor(veh, 22, 119, 222, 22, 119, 222, 22, 119, 222, 22, 119, 222)

        setElementData(veh, "vehicleData", {
            fuel = 50,
            mileage = math.random(5000, 15000),
            engineType = "p",
        }, false)
        setElementData(veh, "vehicleOwner", client)
    end

    if licenceData.vehicleSpeed and veh then
        local handling = getVehicleHandling(veh)
        setVehicleHandling(veh, "maxVelocity", licenceData.vehicleSpeed)
        setVehicleHandling(veh, "engineAcceleration", handling["engineAcceleration"] + 2)
    end

    setElementData(client, "licenceModels", {licenceData.vehicleModel, licenceData.pedModel}, false)

    exports.TR_objectManager:attachObjectToPlayer(client, veh)
end
addEvent("createLicencePracticeVehicle", true)
addEventHandler("createLicencePracticeVehicle", root, createLicencePracticeVehicle)

function destroyPractiseVehicle(posData, player)
    local plr = client and client or player
    local data = getElementData(plr, "licenceModels")

    if data then
        if data[1] then exports.TR_objectManager:removeObject(plr, data[1]) end
        if data[2] then exports.TR_objectManager:removeObject(plr, data[2]) end
    end

    local lastSkin = getElementData(client, "lastSkin")
    local customSkin = getElementData(client, "lastCustomSkin")
    if customSkin then
        setElementModel(client, 0)
        setElementModel(client, "customModel", customSkin)
        removeElementData(client, "lastSkin")
        removeElementData(client, "lastCustomSkin")

    elseif lastSkin then
        setElementModel(client, lastSkin)
        setElementModel(client, "customModel", nil)
        removeElementData(client, "lastSkin")
        removeElementData(client, "lastCustomSkin")
    end

    setTimer(function()
        setElementPosition(plr, posData.pos[1], posData.pos[2], posData.pos[3])
        setElementInterior(plr, posData.int)
        setElementDimension(plr, posData.dim)
    end, 1000, 1)
end
addEvent("destroyPractiseVehicle", true)
addEventHandler("destroyPractiseVehicle", resourceRoot, destroyPractiseVehicle)


function blockEnter()
    cancelEvent()
end
addEventHandler("onVehicleStartEnter", resourceRoot, blockEnter)
addEventHandler("onVehicleStartExit", resourceRoot, blockEnter)