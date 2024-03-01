
function createContainerVehicle(pos, upgraded)
    local veh = createVehicle(455, pos[1], pos[2], pos[3], 0, 0, 180)
    setVehicleColor(veh, 60, 60, 60)

    setElementData(veh, "vehicleData", {
		fuel = 70,
		mileage = math.random(350000, 500000),
		engineType = "d",
	}, false)
    setElementData(veh, "vehicleOwner", client)
    setElementData(veh, "blockCollisions", true)
    setVehicleVariant(veh, 2, 2)

    local plr = client
    setTimer(function()
        warpPedIntoVehicle(plr, veh)
        setElementInterior(plr, 0)
        setElementDimension(plr, 0)
        setVehicleEngineState(veh, true)
    end, 100, 1)

    if upgraded then
        setVehicleHandling(veh, "maxVelocity", 130)
        setVehicleHandling(veh, "engineAcceleration", getVehicleHandling(veh)["engineAcceleration"] + 2)
    else
        setVehicleHandling(veh, "maxVelocity", 80)
    end

    setVehicleHandling(veh, "modelFlags", 2092209)

    exports.TR_objectManager:attachObjectToPlayer(client, veh)
end
addEvent("createContainerVehicle", true)
addEventHandler("createContainerVehicle", resourceRoot, createContainerVehicle)

function attachContainerToVehicle(veh, model)
    local object = createObject(model, 0, 0, 0)
    setObjectScale(object, 0.63, 1.1, 0.9)
    attachElements(object, veh, -0.01, -2.15, 1.3, 0, 0, 90)
    setElementCollisionsEnabled(object, false)

    exports.TR_objectManager:attachObjectToPlayer(client, object)
end
addEvent("attachContainerToVehicle", true)
addEventHandler("attachContainerToVehicle", resourceRoot, attachContainerToVehicle)

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

function setContainerFrozen(veh, value)
    setElementFrozen(client, value)
    if veh then setElementFrozen(veh, value) end
end
addEvent("setContainerFrozen", true)
addEventHandler("setContainerFrozen", resourceRoot, setContainerFrozen)