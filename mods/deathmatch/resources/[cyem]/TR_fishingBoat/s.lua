local settings = {
    rentPrice = 550,
    rentTime = 3600,
}

local NPCs = {
    {
        skin = 184,
        pos = Vector3(2104.1948242188, -154.99726867676, 1.470818161964),
        rot = 256,
        name = "Roberth Hatter",
        role = "Tekne sahibi",
        positions = {
            {
                pos = Vector3(2112.1533203125, -164.8642578125, -0.3692665696144),
                rot = 160,
            },
            {
                pos = Vector3(2119.193359375, -167.2978515625, -0.30142658948898),
                rot = 160,
            },
            {
                pos = Vector3(2110.2509765625, -150.697265625, -0.35262677073479),
                rot = 70,
            },
        },
    },
    {
        skin = 236,
        pos = Vector3(-2211.44140625, 2417.81640625, 2.4884510040283),
        rot = 19,
        name = "Sinead Alvarez",
        role = "Tekne sahibi",
        positions = {
            {
                pos = Vector3(-2212.6728515625, 2410.3115234375, 0.16664934158325),
                rot = 44,
            },
            {
                pos = Vector3(-2201.5634765625, 2420.4697265625, 0.14968647062778),
                rot = 43,
            },
        },
    },
}

function createNPCs()
    local dialogue = exports.TR_npc:createDialogue()
    exports.TR_npc:addDialogueText(dialogue, "Merhaba. Bir tekne kiralama ne kadar?", {pedResponse = string.format("Bir teknenin saatlik kiralama maliyeti $%d.", settings.rentPrice)})
    exports.TR_npc:addDialogueText(dialogue, "Harika fiyat. Kabul ediyorum!", {pedResponse = "", responseTo = "Merhaba. Bir tekne kiralama ne kadar?", trigger = "rentFishingBoat"})
    exports.TR_npc:addDialogueText(dialogue, "Belki başka zaman.", {pedResponse = "Sonraki sefere.", responseTo = "Merhaba. Bir tekne kiralama ne kadar?"})
    exports.TR_npc:addDialogueText(dialogue, "Görüşürüz.", {pedResponse = "Güle güle."})
    for i, v in pairs(NPCs) do
        local ped = exports.TR_npc:createNPC(v.skin, v.pos.x, v.pos.y, v.pos.z, v.rot, v.name, v.role, "dialogue")
        exports.TR_npc:setNPCDialogue(ped, dialogue)

        setElementData(ped, "fishingId", i, false)
    end
end
createNPCs()


function rentFishingBoat(ped)
    local pedName = getElementData(ped, "name")
    local plrData = getElementData(client, "characterData")
    if not plrData.licence then triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Deniz ehliyetiniz yok. Size bir tekne kiralayamam.", "files/images/npc.png") return end
    if not plrData.licence["BOAT"] then triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Deniz ehliyetiniz yok. Size bir tekne kiralayamam.", "files/images/npc.png") return end
    triggerClientEvent(client, "rentFishingBoat", resourceRoot, settings.rentPrice, getElementData(ped, "fishingId"))
end
addEvent("rentFishingBoat", true)
addEventHandler("rentFishingBoat", root, rentFishingBoat)

function onFishingBoatRent(state, data)
    if state then
        rentPlayerBoat(source, data.id)
    end
    triggerClientEvent(source, "responseFishingBoat", resourceRoot, state)
end
addEvent("onFishingBoatRent", true)
addEventHandler("onFishingBoatRent", root, onFishingBoatRent)


function rentPlayerBoat(plr, id)
    local x, y, z = getElementPosition(plr)
    local data = NPCs[id].positions[math.random(1, #NPCs[id].positions)]

    local boat = createVehicle(453, data.pos, 0, 0, data.rot)
    setElementData(boat, "vehicleOwner", plr)
    -- setElementData(boat, "freeForAll", true)
    setElementData(boat, "fishBoat", {
        time = settings.rentTime,
        timestamp = getRealTime().timestamp,
        pos = {x, y, z},
        owner = getPlayerName(plr),
    })

    setElementData(boat, "vehicleData", {
		fuel = 70,
		mileage = math.random(350000, 500000),
		engineType = "d",
    }, false)

    warpPedIntoVehicle(plr, boat)
    triggerClientEvent(plr, "addAchievements", resourceRoot, "fishingBoat")
end

function takePlrBoat(boat)
    if isElement(boat) then
        local occ = getVehicleOccupants(boat)
        for i, v in pairs(occ) do
            removePedFromVehicle(v)
        end

        local boatPos = Vector3(getElementPosition(boat))
        local data = getElementData(boat, "fishBoat")
        destroyElement(boat)

        local sphere = createColSphere(boatPos, 5)
        local players = getElementsWithinColShape(sphere, "player")
        destroyElement(sphere)

        if players then
            for i, v in pairs(players) do
                setElementPosition(v, data.pos[1], data.pos[2], data.pos[3])
            end
        end
    end
end

function updateTime()
    local nowTimestamp = getRealTime().timestamp

    for i, v in pairs(getElementsByType("vehicle", resourceRoot)) do
        local data = getElementData(v, "fishBoat")
        if data then
            if (nowTimestamp - data.timestamp) > 3601 then
                takePlrBoat(v)
            end
        end
    end
end
setTimer(updateTime, 1000, 0)


function resourceStop()
    for i, v in pairs(getElementsByType("vehicle", resourceRoot)) do
        local owner = getElementData(v, "vehicleOwner")
        if isElement(owner) then
            exports.TR_core:giveMoneyToPlayer(owner, settings.rentPrice)
            exports.TR_noti:create(owner, "Tekne için ödeme hesabınıza eklendi.", "success")
        end

        takePlrBoat(v)
    end
end
addEventHandler("onResourceStop", resourceRoot, resourceStop)

-- rentPlayerBoat(getPlayerFromName('Xantris'), 2)