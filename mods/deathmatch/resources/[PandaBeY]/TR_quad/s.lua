local snowZone = createColPolygon(
    -1117.8629150391, -2999.2360839844,
    -1119.4138183594, -2779.8234863281,
    -1181.2243652344, -2620.2238769531,
    -1235.8570556641, -2547.7507324219,
    -1235.7335205078, -2367.8312988281,
    -1167.5152587891, -2218.8381347656,
    -1177.0996093754, -2033.0169677734,
    -1376.1442871094, -1725.3400878906,
    -1478.2474365234, -1674.8654785156,
    -1621.4177246094, -1678.3270263672,
    -1755.0541992188, -1550.5257568359,
    -1861.9069824219, -1468.9160156224,
    -1962.2117919922, -1380.2987060547,
    -2091.1298828125, -1204.8487548828,
    -2196.2414550781, -1049.5141601563,
    -2476.7658691406, -874.11907958984,
    -2619.1918945313, -877.48168945314,
    -2967.5217285156, -1082.4569091797,
    -3008.1679687550, -1885.4948730469,
    -2768.4157714844, -2170.0004882813,
    -2857.8542480469, -2317.6906738281,
    -2859.6621093756, -2545.0917968758,
    -2693.8879394531, -2874.0056152344,
    -1993.5410156256, -2909.4738769532,
    -1740.5479736328, -2803.1982421875,
    -1541.7954101563, -2994.8566894531,
    -1113.9154052734, -2997.0651855469)


function onWinerEnter(col)
    if col ~= snowZone then return end
    if getElementType(source) ~= "vehicle" then return end

    local handling = getVehicleHandling(source)
    if getElementModel(source) == 471 then
        setVehicleHandling(source, "tractionMultiplier", 3)
        setVehicleHandling(source, "engineAcceleration", 8)
        setVehicleHandling(source, "steeringLock", 10)

    elseif getVehicleUpgradeOnSlot(source, 12) ~= 1025 then
        setVehicleHandling(source, "tractionMultiplier", handling.tractionMultiplier - 0.2)
        setVehicleHandling(source, "engineAcceleration", handling.engineAcceleration - 3)
        setVehicleHandling(source, "brakeDeceleration", 3)
    end
end
addEventHandler("onElementColShapeHit", root, onWinerEnter)

function onWinerLeave(col)
    if col ~= snowZone then return end
    if getElementType(source) ~= "vehicle" then return end

    local originalHandling = getModelHandling(getElementModel(source))
    local handling = getVehicleHandling(source)
    if getElementModel(source) == 471 then
        setVehicleHandling(source, "engineAcceleration", 1.5)
        setVehicleHandling(source, "steeringLock", 3)

    elseif getVehicleUpgradeOnSlot(source, 12) ~= 1025 then
        setVehicleHandling(source, "tractionMultiplier", originalHandling.tractionMultiplier)
        setVehicleHandling(source, "engineAcceleration", handling.engineAcceleration + 3)
        setVehicleHandling(source, "brakeDeceleration", originalHandling.engineAcceleration)
    end
end
addEventHandler("onElementColShapeLeave", root, onWinerLeave)

function setHandling()
    setModelHandling(471, "steeringLock", 3)
    setModelHandling(471, "maxVelocity", 140)
    setModelHandling(471, "engineAcceleration", 9)
end
setHandling()