function createBusJobVehicle(pos, upgraded)
    local veh = createVehicle(431, pos[1], pos[2], pos[3], 0, 0, 0)
    setVehicleDamageProof(veh, true)
    setVehicleColor(veh, 240, 196, 55, 0, 0, 0, 0, 0, 0, 0, 0, 0)

    setElementData(veh, "vehicleData", {
		fuel = 125,
		mileage = math.random(350000, 500000),
		engineType = "d",
	}, false)
    setElementData(veh, "vehicleOwner", client)
    setElementData(veh, "blockCollisions", true)
    setVehicleOverrideLights(veh, 1)

    if upgraded then
        setVehicleHandling(veh, "maxVelocity", 150)
        setVehicleHandling(veh, "engineAcceleration", getVehicleHandling(veh)["engineAcceleration"] + 2)
    else
        setVehicleHandling(veh, "maxVelocity", 80)
    end

    local plr = client
    setTimer(function()
        warpPedIntoVehicle(plr, veh)
        setElementInterior(plr, 0)
        setElementDimension(plr, 0)
    end, 100, 1)

    exports.TR_objectManager:attachObjectToPlayer(client, veh)
end
addEvent("createBusJobVehicle", true)
addEventHandler("createBusJobVehicle", resourceRoot, createBusJobVehicle)

function canEnterVehicle(plr, seat, jacked, door)
    cancelEvent()
end
addEventHandler("onVehicleStartEnter", resourceRoot, canEnterVehicle)

function onVehicleExit(plr, seat, jacked, door)
    if seat == 0 then
        cancelEvent()
        triggerClientEvent(plr, "onJobVehicleExit", resourceRoot)
    end
end
addEventHandler("onVehicleStartExit", resourceRoot, onVehicleExit)