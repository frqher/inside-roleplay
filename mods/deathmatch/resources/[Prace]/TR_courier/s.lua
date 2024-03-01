
function createCourierVehicle(pos, upgraded)
    local veh = createVehicle(499, pos[1], pos[2], pos[3], 0, 0, 270)
    setVehicleColor(veh, 21, 0, 4, 21, 0, 4, 21, 0, 4, 21, 0, 4)
    setVehicleVariant(veh, 255, 255)

    setElementData(veh, "vehicleData", {
		fuel = 70,
		mileage = math.random(350000, 500000),
		engineType = "d",
	}, false)
    setElementData(veh, "vehicleOwner", client)
    -- setElementData(veh, "blockCollisions", true)
    setVehicleVariant(veh, 2, 2)
    setVehicleDamageProof(veh, true)

    if upgraded then
        setVehicleHandling(veh, "maxVelocity", 150)
        setVehicleHandling(veh, "engineAcceleration", getVehicleHandling(veh)["engineAcceleration"] + 2)
    else
        setVehicleHandling(veh, "maxVelocity", 100)
    end

    exports.TR_objectManager:attachObjectToPlayer(client, veh)
end
addEvent("createCourierVehicle", true)
addEventHandler("createCourierVehicle", resourceRoot, createCourierVehicle)

function canEnterVehicle(plr, seat, jacked, door)
    if jacked then cancelEvent() return end
    if seat == 0 then
        if exports.TR_vehicles:canUseVehicle(source, plr) then return end
        cancelEvent()
        exports.TR_noti:create(plr, "Bu araç size ait değil.", "error")
    end
end
addEventHandler("onVehicleStartEnter", resourceRoot, canEnterVehicle)

function setCourierFrozen(veh, value)
    setElementFrozen(client, value)
    if veh then setElementFrozen(veh, value) end
end
addEvent("setCourierFrozen", true)
addEventHandler("setCourierFrozen", resourceRoot, setCourierFrozen)