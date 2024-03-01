function createTramJobVehicle()
    local veh = createVehicle(449, -2264.7626953125, 548.990234375, 35.015625, 0, 0, 312)
    setVehicleDamageProof(veh, true)
    setTrainDerailable(veh, false)

    setElementData(veh, "vehicleData", {
		fuel = 70,
		mileage = math.random(350000, 500000),
		engineType = "d",
	}, false)
    setElementData(veh, "vehicleOwner", client)
    setElementData(veh, "blockCollisions", true)
    setTrainDirection(veh, true)
    setVehicleOverrideLights(veh, 1)
    setTimer(setVehicleEngineState, 1500, 1, veh, true)

    local plr = client
    setTimer(function()
        warpPedIntoVehicle(plr, veh)
        setElementInterior(plr, 0)
        setElementDimension(plr, 0)
        setVehicleEngineState(veh, true)
    end, 100, 1)

    local veh2 = createVehicle(449, -2264.931640625, 897.931640625, 66.5, 0, 0, 312)
    attachTrailerToVehicle(veh, veh2)
    setTrainDerailable(veh2, false)
    setElementData(veh2, "blockCollisions", true)

    exports.TR_objectManager:attachObjectToPlayer(client, veh)
    exports.TR_objectManager:attachObjectToPlayer(client, veh2)
end
addEvent("createTramJobVehicle", true)
addEventHandler("createTramJobVehicle", resourceRoot, createTramJobVehicle)

function onVehicleStartExit(plr)
    removePedFromVehicle(plr)
    setElementDimension(plr, 9)
    triggerClientEvent(plr, "endTramWork", resourceRoot)

    setTimer(setElementPosition, 100, 1, plr, -2254.6611328125, 221.52383422852, 67.400001525879)
end
addEventHandler("onVehicleStartExit", resourceRoot, onVehicleStartExit)