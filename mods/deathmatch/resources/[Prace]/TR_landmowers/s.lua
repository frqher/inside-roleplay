local vehs = {
    {
        model = 554,
        pos = Vector3(-2404.494140625, 685.2060546875, 35.163566589355),
        rot = Vector3(1, -1, 244),
    },
    {
        model = 422,
        pos = Vector3(-2404.0478515625, 694.6533203125, 35.164688110352),
        rot = Vector3(0, 0, 339),
    },
    {
        model = 572,
        pos = Vector3(-2406.8388671875, 695.7685546875, 34.721875),
        rot = Vector3(0, 0, 157),
    },
    {
        model = 572,
        pos = Vector3(-2407.4921875, 683.2109375, 34.721875),
        rot = Vector3(0, 0, 60),
    },
    {
        model = 572,
        pos = Vector3(-2405.4248046875, 691.166015625, 34.721875),
        rot = Vector3(0, 0, 67),
    },
    {
        model = 572,
        pos = Vector3(-2409.615234375, 696.234375, 34.721875),
        rot = Vector3(0, 0, 180),
    },
}

function createVehs()
    for i, v in pairs(vehs) do
        local veh = createVehicle(v.model, v.pos, v.rot)
        setElementFrozen(veh, true)
        setVehicleLocked(veh, true)
        setVehicleColor(veh, 1, 67, 0, 245, 245, 245, 0, 0, 0, 0, 0, 0)

        setElementData(veh, "blockAction", true)

        if i == 1 then
            setTimer(setVehicleDoorOpenRatio, 1000, 1, veh, 1, 1, 0)
        end
    end

    local dialogue = exports.TR_npc:createDialogue()
    exports.TR_npc:addDialogueText(dialogue, "Merhaba. Nasıl gidiyor?", {pedResponse = "Sana söyleyeyim, harika. Sen neden öyle duruyorsun? Bu traktörleri boşalttıktan sonra işe başlayabilirsin. Bu parkın güzel görünmesi gerekiyor."})
    exports.TR_npc:addDialogueText(dialogue, "Hoşça kal.", {pedResponse = "Tabii, hoşça kal."})

    local ped = exports.TR_npc:createNPC(206, -2406.220703125, 686.0478515625, 35.872165679932, 62, "Jim Lahely", "Bahçıvan", "dialogue")
    setElementData(ped, "animation", {"beach", "ParkSit_M_loop"})
    exports.TR_npc:setNPCDialogue(ped, dialogue)
end
createVehs()

function createLandmowerVehicle(upgraded)
    local veh = createVehicle(572, -2412.2587890625, 696.4501953125, 35.171875, 0, 0, 180)
    setVehicleColor(veh, 1, 67, 0, 245, 245, 245, 0, 0, 0, 0, 0, 0)

    setElementData(veh, "vehicleData", {
		fuel = 70,
		mileage = math.random(300, 1000),
        engineType = "p",
        turbo = false,
	}, false)
    setElementData(veh, "vehicleOwner", client)
    setElementData(veh, "blockCollisions", true)
    setVehicleEngineState(veh, true)

    if not upgraded then
        setVehicleHandling(veh, "maxVelocity", 40)
    end

    warpPedIntoVehicle(client, veh)

    exports.TR_objectManager:attachObjectToPlayer(client, veh)
end
addEvent("createLandmowerVehicle", true)
addEventHandler("createLandmowerVehicle", resourceRoot, createLandmowerVehicle)


function canEnterVehicle(plr, seat, jacked, door)
	if jacked then cancelEvent() return end
    if getElementData(source, "vehicleOwner") ~= plr then
        cancelEvent()
    end
end
addEventHandler("onVehicleStartEnter", resourceRoot, canEnterVehicle)