function createPizzaboyVehicle(pos, upgraded)
    local veh = createVehicle(448, pos[1], pos[2], pos[3], 0, 0, 235.73)
    setVehicleColor(veh, 126, 6, 6, 225, 150, 32, 225, 150, 32, 225, 150, 32)

    setElementData(veh, "vehicleData", {
		fuel = 50,
		mileage = math.random(35000, 50000),
		engineType = "d",
	}, false)
    setElementData(veh, "vehicleOwner", client)
    setElementData(veh, "blockCollisions", true)
    setVehicleVariant(veh, 1, 1)

    if not upgraded then
        setVehicleHandling(veh, "maxVelocity", 80)
    end

    exports.TR_objectManager:attachObjectToPlayer(client, veh)
end
addEvent("createPizzaboyVehicle", true)
addEventHandler("createPizzaboyVehicle", resourceRoot, createPizzaboyVehicle)

function canEnterVehicle(plr, seat, jacked, door)
    if jacked then cancelEvent() return end
    if seat == 0 then
        if exports.TR_vehicles:canUseVehicle(source, plr) then return end
        cancelEvent()
        exports.TR_noti:create(plr, "Bu araç sana ait değil.", "error")
    end
end
addEventHandler("onVehicleStartEnter", resourceRoot, canEnterVehicle)

