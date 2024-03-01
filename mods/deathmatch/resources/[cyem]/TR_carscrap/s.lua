local data = {
    pricePerKG = 1,
}

local NPCs = {
    {
        skin = 242,
        pos = Vector3(300.7734375, -222.9501953125, 1.5078125),
        int = 0,
        dim = 0,
        rot = 147,
        name = "Marek Krzykacz",
        role = "Hurdalığın sahibi",
    },
}

local staticNPCs = {
    {
        skin = 44,
        pos = Vector3(307.3974609375, -249.0087890625, 1.578125),
        int = 0,
        dim = 0,
        rot = 120,
        anim = {"MISC", "Hiker_Pose_L"},
        name = "Edek Holier",
        role = "Hurda kamyon şoförü",
    },
    {
        skin = 241,
        pos = Vector3(309.548828125, -254.1083984375, 1.5835752487183),
        int = 0,
        dim = 0,
        rot = 295,
        anim = {"COP_AMBIENT", "Coplook_think"},
        name = "Januszek Krzykacz",
        role = "Sahibinin oğlu",
    },
}

function changePrice()
    data.pricePerKG = math.random(42, 260)/100
end
changePrice()
setTimer(changePrice, 21600000, 0)



function getScrapPrice(ped)
    local pedName = getElementData(ped, "name")
    triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, string.format("Fiyat aslında kilo başına $%.2f. Oldukça iyi gibi görünüyor.", data.pricePerKG), "files/images/npc.png")
end
addEvent("getScrapPrice", true)
addEventHandler("getScrapPrice", root, getScrapPrice)

function getScrapVehicles(ped)
    local pedName = getElementData(ped, "name")
    triggerClientEvent(client, "checkVehiclesOnWeight", resourceRoot, pedName)
end
addEvent("getScrapVehicles", true)
addEventHandler("getScrapVehicles", root, getScrapVehicles)


function sellVehiclesOnScrap(pedName, vehicles)
    local plrUID = getElementData(client, "characterUID")
    local totalPrice = 0

    for i, v in pairs(vehicles) do
        local isOwned = exports.TR_mysql:querry("SELECT ID FROM tr_vehicles WHERE ID = ? AND ownedPlayer = ? LIMIT 1", v, plrUID)
        if isOwned and isOwned[1] then
            local veh = getElementByID("vehicle"..v)
            totalPrice = totalPrice + tonumber(getVehicleHandling(veh)["mass"] * data.pricePerKG)

            destroyElement(veh)
            exports.TR_mysql:querry("DELETE FROM `tr_vehicles` WHERE ID = ? LIMIT 1", v)
        end
    end

    if totalPrice == 0 then triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Bana burada yalan söyleme! Arabaların hiçbiri senin değil!", "files/images/npc.png") return end
    if exports.TR_core:giveMoneyToPlayer(client, totalPrice) then
        triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, string.format("Her şey için $%.2f alıyorsunuz. Sizinle iş yapmak güzel! Vay canına!!!!", totalPrice), "files/images/npc.png")
        triggerClientEvent(client, "addAchievements", resourceRoot, "vehicleScrap")
    end
end
addEvent("sellVehiclesOnScrap", true)
addEventHandler("sellVehiclesOnScrap", root, sellVehiclesOnScrap)


function createNPCs()
    local dialogue = exports.TR_npc:createDialogue()
    exports.TR_npc:addDialogueText(dialogue, "Merhaba. Hurda alıyor musunuz?", {pedResponse = "Evet!! Evet!! Al gitsin Edka'ya o gri yaratığa!"})
    exports.TR_npc:addDialogueText(dialogue, "Ama ben aracı hurdaya getirmek istiyorum.", {pedResponse = "Unutma, aracını hurdaya çevirdiğinde, artık onu parçalarına ayırmam. Hurdaya çevirmek istediğinden emin misin?", responseTo = "Merhaba. Hurda alıyor musunuz?"})
    exports.TR_npc:addDialogueText(dialogue, "Evet. Hurdaya çevir!", {pedResponse = "", responseTo = "Ama ben aracı hurdaya getirmek istiyorum.", trigger = "getScrapVehicles", img = "car"})
    exports.TR_npc:addDialogueText(dialogue, "Hayır. Ancak hurdayla biraz daha gez", {pedResponse = "Tabiiii.. Ne kadar zor.. Oğlum! Bugün akşam yemeği yok!", responseTo = "Ama ben aracı hurdaya getirmek istiyorum."})
    exports.TR_npc:addDialogueText(dialogue, "Fiyat nedir?", {pedResponse = "", responseTo = "Merhaba. Hurda alıyor musunuz?", trigger = "getScrapPrice"})
    exports.TR_npc:addDialogueText(dialogue, "Görüşürüz.", {pedResponse = "Hoşça kal."})


    for i, v in pairs(NPCs) do
        local ped = exports.TR_npc:createNPC(v.skin, v.pos.x, v.pos.y, v.pos.z, v.rot, v.name, v.role, "dialogue")
        setElementInterior(ped, v.int)
        setElementDimension(ped, v.dim)
        exports.TR_npc:setNPCDialogue(ped, dialogue)
    end

    createStaticNPCs()
    createVehicles()
end

function createStaticNPCs()
    local dialogue = exports.TR_npc:createDialogue()
    exports.TR_npc:addDialogueText(dialogue, "Günaydın.", {pedResponse = "Ne istiyorsun? Zamanım yok! Yöneticiye git, Marek'e!"})
    exports.TR_npc:addDialogueText(dialogue, "Hurda metal nereye boşaltılır?", {pedResponse = "Buraya atın. Hurdalığa!"})

    local dialogueJ = exports.TR_npc:createDialogue()
    exports.TR_npc:addDialogueText(dialogueJ, "Günaydın.", {pedResponse = "Burada kıçımı havaya uçurma. Oraya, Marek'e git. Baba! Bir müşterin var!"})

    for i, v in pairs(staticNPCs) do
        local ped = exports.TR_npc:createNPC(v.skin, v.pos.x, v.pos.y, v.pos.z, v.rot, v.name, v.role, "dialogue")
        setElementInterior(ped, v.int)
        setElementDimension(ped, v.dim)
        if v.anim then setElementData(ped, "animation", v.anim) end
        exports.TR_npc:setNPCDialogue(ped, i == 1 and dialogue or dialogueJ)
    end
end

function createVehicles()
    local veh = createVehicle(413, 311, -250.865234375, 1.5835752487183, 0, 0, 266)
    setElementData(veh, "blockAction", true)
    setVehicleColor(veh, 255, 255, 255)
    setElementFrozen(veh, true)
    setVehicleLocked(veh, true)
    setVehicleDoorOpenRatio(veh, 4, 1)
    setVehicleDoorOpenRatio(veh, 5, 1)
    setVehicleVariant(veh, 255, 255)

    addEventHandler("onVehicleStartEnter", resourceRoot, function() cancelEvent() end)
end
createNPCs()
