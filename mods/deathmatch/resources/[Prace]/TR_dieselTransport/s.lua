function createDieselTransportVehicle(pos, upgraded)
    local veh = createVehicle(456, pos[1], pos[2], pos[3], 0, 0, 0)
    setVehicleColor(veh, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

    setElementData(veh, "vehicleData", {
		fuel = 70,
		mileage = math.random(350000, 500000),
		engineType = "d",
	}, false)
    setElementData(veh, "vehicleOwner", client)
    -- setElementData(veh, "blockCollisions", true)
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

    exports.TR_objectManager:attachObjectToPlayer(client, veh)
end
addEvent("createDieselTransportVehicle", true)
addEventHandler("createDieselTransportVehicle", resourceRoot, createDieselTransportVehicle)

function canEnterVehicle(plr, seat, jacked, door)
	if jacked then cancelEvent() return end
    if getElementData(source, "vehicleOwner") ~= plr then
        cancelEvent()
    end
end
addEventHandler("onVehicleStartEnter", resourceRoot, canEnterVehicle)


local valve = createObject(1880, 2696.5646484375, 2748.209921875, 11.4053125, 0, 0, 180)
setObjectScale(valve, 1.15)
setElementData(valve, "removeValve", true)

local valve2 = createObject(1880, 2696.5646484375, 2739.619921875, 11.4053125, 0, 0, 180)
setObjectScale(valve2, 1.15)
setElementData(valve2, "removeValve", true)







local stationValves = {
    Vector3(-2447.1899, 988.875, 44.622),
    Vector3(-2446.1899, 988.861, 44.622),
    Vector3(-2445.1899, 988.849, 44.622),

    Vector3(-1451.327, 1875.066, 31.958),
    Vector3(-1451.405, 1876.139, 31.958),
    Vector3(-1451.483, 1877.211, 31.958),

    Vector3(-1326.955, 2700.387, 49.388),
    Vector3(-1326.432, 2699.504, 49.388),
    Vector3(-1325.909, 2698.623, 49.388),

    Vector3(659.745, 1697.527, 6.513),
    Vector3(660.445, 1698.168, 6.513),
    Vector3(661.149, 1698.806, 6.513),

    Vector3(2098.340, 945.289, 10.145),
    Vector3(2099.314, 945.320, 10.145),
    Vector3(2100.314, 945.341, 10.145),

    Vector3(2656.45, 1081.166, 10.145),
    Vector3(2655.48, 1081.186, 10.145),
    Vector3(2654.58, 1081.205, 10.145),

    Vector3(1386.034, 472.96899, 19.422),
    Vector3(1385.078, 473.40201, 19.422),
    Vector3(1384.145, 473.82599, 19.422),

    Vector3(998.87598, -910.43597, 41.653),
    Vector3(999.04102, -911.57599, 41.653),
    Vector3(999.19531, -912.76465, 41.653),

    Vector3(-71.981, -1178.38, 1.139),
    Vector3(-71.558, -1177.44, 1.139),
    Vector3(-71.144, -1176.53, 1.139),

    Vector3(-2230.4819, -2568.561, 31.247),
    Vector3(-2231.4131, -2568.062, 31.247),
    Vector3(-2232.3101, -2567.523, 31.247),
}

local c = 0
local k = 1
for i, v in pairs(stationValves) do
    local valve = createObject(1880, v - Vector3(0, 0, 0.16), 0, 90, 0)
    setElementData(valve, "fuelValve", k)

    c = c + 1
    if c == 3 then
        c = 0
        k = k + 1
    end
end