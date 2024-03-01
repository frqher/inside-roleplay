local data = {
    ["monsterDerby"] = {
        fallCol = createColCuboid(4108.2841796875, -1683.5920410156, 208.523712158, 210, 160, 15),
        centerPos = Vector2(4215.4467773438, -1601.4320068359),
        distance = 34,
        model = 444,
    },

    ["standardDerby"] = {
        fallCol = createColCuboid(6020.3828125, -706.70111083984, 20.493709564209, 280, 350, 15),
        model = 415,
        pos = {
            Vector3(6065.3466796875, -665.01727294922, 270),
            Vector3(6060.8579101563, -659.32830810547, 0),
            Vector3(6059.9775390625, -417.20843505859, 180),
            Vector3(6065.2724609375, -412.57693481445, 270),
            Vector3(6251.9375, -411.62759399414, 90),
            Vector3(6256.7319335938, -417.33190917969, 180),
            Vector3(6257.7919921875, -659.51733398438, 0),
            Vector3(6252.0263671875, -664.15484619141, 90),
            Vector3(6194.3959960938, -670.53625488281, 0),
            Vector3(6123.80078125, -670.11401367188, 0),
            Vector3(6123.0390625, -406.33178710938, 180),
            Vector3(6193.4145507813, -406.23809814453, 180),
            Vector3(6252.4692382813, -537.95318603516, 90),
            Vector3(6065.4624023438, -538.77435302734, 270),
            Vector3(6065.724609375, -602.06188964844, 270),
            Vector3(6252.1689453125, -601.02056884766, 90),
            Vector3(6251.50390625, -474.82205200195, 90),
            Vector3(6065.7612304688, -475.78598022461, 270),

            Vector3(6060.8491210938, -533.11614990234, 0),
            Vector3(6059.8291015625, -543.93524169922, 180),
            Vector3(6257.6342773438, -532.48663330078, 0),
            Vector3(6256.8227539063, -543.71270751953, 180),

            Vector3(6151.7329101563, -543.68591308594, 130),
            Vector3(6158.5522460938, -547.38067626953, 174),
            Vector3(6164.2778320313, -545.72302246094, 220),
            Vector3(6167.939453125, -538.84222412109, 270),
            Vector3(6165.7705078125, -532.83081054688, 310),
            Vector3(6159.2978515625, -529.83935546875, 0),
            Vector3(6153.2275390625, -531.70135498047, 40),
            Vector3(6148.8969726563, -537.86199951172, 90),
        },
    },

}

function createMonsterDerbyVehicles()
    local angleSwitch = 360 / eventData.playerCount
    local index = 0

    for i, v in pairs(eventData.playersLeft) do
        local x, y = getPointFromDistanceRotation(data.monsterDerby.centerPos.x, data.monsterDerby.centerPos.y, data.monsterDerby.distance, angleSwitch * index)
        local rot = findRotation(x, y, data.monsterDerby.centerPos.x, data.monsterDerby.centerPos.y)

        setElementInterior(i, 0)
        setElementDimension(i, 0)

        local veh = createVehicle(data.monsterDerby.model, x, y, 237, 0, 0, rot)
        setElementData(veh, "vehicleData", {
            fuel = 80,
            mileage = math.random(20000, 50000)
        }, false)
        setElementData(i, "engineState", true, false)
        setElementData(veh, "blockAction", true)
        setVehicleEngineState(veh, true)

        warpPedIntoVehicle(i, veh)
        index = index + 1
    end
end

function createCrossedDerbyVehicles()
    local index = 1

    for i, v in pairs(eventData.playersLeft) do
        local pos = data.standardDerby.pos[index]

        setElementInterior(i, 0)
        setElementDimension(i, 0)

        local veh = createVehicle(data.standardDerby.model, pos.x, pos.y, 41, 0, 0, pos.z)
        setElementData(veh, "vehicleData", {
            fuel = 80,
            mileage = math.random(20000, 50000),
        }, false)
        setElementData(i, "engineState", true, false)
        setElementData(veh, "blockAction", true)
        setVehicleEngineState(veh, true)

        warpPedIntoVehicle(i, veh)
        index = index + 1
    end
end

function createDerbyVehicles()
    if eventData.events[eventData.selectedEvent].type == "monsterDerby" then
        createMonsterDerbyVehicles()

    elseif eventData.events[eventData.selectedEvent].type == "crossedDerby" then
        createCrossedDerbyVehicles()
    end
end


function getPointFromDistanceRotation(x, y, dist, angle)
    local a = math.rad(90 - angle);
    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;
    return x+dx, y+dy;
end

function findRotation( x1, y1, x2, y2 )
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end