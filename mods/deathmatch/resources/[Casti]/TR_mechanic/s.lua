function offerVehicleFix(plr, parts, price, addon)
    if not plr or not parts or not price then return end
    local veh = getPedOccupiedVehicle(plr)
    if not veh then return end

    if not getElementData(veh, "blockAction") then
        triggerClientEvent(plr, "openFixAccept", resourceRoot, client, parts, price, addon)

        setElementData(client, "blockAction", true)
        setElementData(veh, "blockAction", client)
    end
end
addEvent("offerVehicleFix", true)
addEventHandler("offerVehicleFix", resourceRoot, offerVehicleFix)


function declineVehicleFix(plr)
    if not plr then return end
    exports.TR_noti:create(plr, string.format("%s onarım teklifini reddetti.", getPlayerName(client)), "error")

    removeElementData(getPedOccupiedVehicle(client), "blockAction")
    removeElementData(plr, "blockAction")
end
addEvent("declineVehicleFix", true)
addEventHandler("declineVehicleFix", resourceRoot, declineVehicleFix)

function playerPayForVehicleFix(state, data)
    if state then
        local veh = getPedOccupiedVehicle(source)
        if not veh then return end

        local earned = (data[2] - data[3]) * 0.05 + data[3]

        setElementFrozen(veh, true)
        vehicleAnimation(veh, source, data[1])

        local vx, vy, vz = getElementPosition(veh)
        triggerClientEvent(root, "playGlobalSound", resourceRoot, ":TR_mechanic/files/sounds/fix.wav", vx, vy, vz, 20, 20)

        if isElement(data[1]) then
            setElementFrozen(data[1], true)
            exports.TR_noti:create(data[1], "Araç tamir ediliyor...", "repair", 7)
        end
        setTimer(vehicleFix, 7000, 1, veh, data[4], data[1], source, earned)
    end
    triggerClientEvent(source, "vehicleFixResponse", resourceRoot, state)
end
addEvent("playerPayForVehicleFix", true)
addEventHandler("playerPayForVehicleFix", root, playerPayForVehicleFix)


function vehicleAnimation(vehicle, source, plr)
    if not isElement(plr) then return end
    local type = getVehicleType(vehicle)
    if type == "Bike" or type == "Quad" then
        local plrPos = Vector3(getElementPosition(plr))

        local _, _, rz = getElementRotation(vehicle)
        local x, y, z = getPositionFromElementOffset(source, -1, 0, 0)
        local x1, y1, z1 = getPositionFromElementOffset(source, 1, 0, 0)

        local dist = getDistanceBetweenPoints3D(plrPos, x, y, z)
        local dist1 = getDistanceBetweenPoints3D(plrPos, x1, y1, z1)
        if dist > dist1 then
            x, y, z = x1, y1, z1
            rz = rz + 90
        else
            rz = rz - 90
        end
        setElementPosition(plr, x, y, z)
        setElementRotation(plr, 0, 0, rz)
        setTimer(function()
            setElementRotation(plr, 0, 0, rz)
            setPedAnimation(plr, "COP_AMBIENT", "Copbrowse_loop", -1, true, false, false, false)
            setElementData(plr, "animation", {"COP_AMBIENT", "Copbrowse_loop"})
        end, 50, 1)

    else
        local plrPos = Vector3(getElementPosition(plr))

        local _, _, rz = getElementRotation(vehicle)
        local x, y, z = getPositionFromElementOffset(source, -2.5, 0, 0)
        local x1, y1, z1 = getPositionFromElementOffset(source, 2.5, 0, 0)

        local dist = getDistanceBetweenPoints3D(plrPos, x, y, z)
        local dist1 = getDistanceBetweenPoints3D(plrPos, x1, y1, z1)
        if dist > dist1 then
            x, y, z = x1, y1, z1
            rz = rz - 90
        else
            rz = rz + 90
        end
        setElementPosition(plr, x, y, z)
        setElementRotation(plr, 0, 0, rz)
        setTimer(function()
            setElementRotation(plr, 0, 0, rz)
            setPedAnimation(plr, "CAR", "Fixn_Car_Loop", -1, true, false, false, false)
            setElementData(plr, "animation", {"CAR", "Fixn_Car_Loop"})
        end, 50, 1)

    end
end


function vehicleFix(veh, data, mechanic, plr, earned)
    local wheelStates = {getVehicleWheelStates(veh)}
    for i, v in pairs(data) do
        if v.data.type == "engine" then
            setElementHealth(veh, 1000)
            setVehicleDamageProof(veh, false)
        elseif v.data.type == "panel" then
            setVehiclePanelState(veh, v.data.value, 0)
        elseif v.data.type == "door" then
            setVehicleDoorState(veh, v.data.value, 0)
        elseif v.data.type == "light" then
            setVehicleLightState(veh, v.data.value, 0)
        elseif v.data.type == "wheel" then
            wheelStates[v.data.value] = 0
        end
    end
    setVehicleWheelStates(veh, wheelStates[1], wheelStates[2], wheelStates[3], wheelStates[4])
    for i = 0, 4 do
        setVehiclePanelState(veh, i, 0)
    end
    setElementFrozen(veh, false)
    removeElementData(veh, "blockAction")

    triggerClientEvent(plr, "updateVehicleDamage", resourceRoot, veh)
    triggerClientEvent(plr, "addAchievements", resourceRoot, "fixVehicle")

    if isElement(mechanic) then
        setElementFrozen(mechanic, false)
        setPedAnimation(mechanic, nil, nil)
        setElementData(mechanic, "animation", false)
        removeElementData(mechanic, "blockAction")
        exports.TR_noti:create(mechanic, string.format("Araç tamir edildi.\nPara kazandınız: $%.2f.", earned), "success")

        exports.TR_core:giveMoneyToPlayer(mechanic, earned)
    end
end

-- function removeOnQuit()
--     if plrOffers[source] then
--         if isElement(plrOffers[source][1]) then removeElementData(plrOffers[source][1], "blockAction") end
--         if isElement(plrOffers[source][2]) then removeElementData(plrOffers[source][2], "blockAction") end
--         plrOffers[source] = nil

--     else
--         for i, v in pairs(plrOffers) do
--             if v[1] == source and plrOffers[source] then
--                 if isElement(plrOffers[source][2]) then removeElementData(plrOffers[source][2], "blockAction") end
--                 plrOffers[i] = nil
--                 break
--             end
--         end
--     end
-- end
-- addEventHandler("onPlayerQuit", root, removeOnQuit)

function getPositionFromElementOffset(element, offX, offY, offZ)
    local m = getElementMatrix(element)
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z
end








function onEnterMechanicPosition(plr, md)
    if not plr or not md then return end

    local mechanic = getElementData(source, "mechanic")
    local mechanicPosition = getElementData(mechanic, "mechanicPosition")
    if isElement(mechanicPosition.mechanic) then
        if getElementModel(mechanicPosition.mechanic) ~= 50 then
            if getElementModel(plr) ~= 50 then return end
            if getElementData(plr, "hasPosition") then return end
            mechanicPosition.mechanic = plr
            mechanicPosition.mechanicName = getPlayerName(plr)
            setElementData(mechanic, "mechanicPosition", mechanicPosition)
            setElementData(plr, "hasPosition", mechanic)
        end
    else
        if getElementModel(plr) ~= 50 then return end
        if getElementData(plr, "hasPosition") then return end
        mechanicPosition.mechanic = plr
        mechanicPosition.mechanicName = getPlayerName(plr)
        setElementData(mechanic, "mechanicPosition", mechanicPosition)
        setElementData(plr, "hasPosition", mechanic)
    end
end

function onExitMechanicPosition(plr, md)
    if not plr or not md then return end

    local mechanic = getElementData(plr, "hasPosition")
    if not mechanic then return end

    local mechanicPosition = getElementData(mechanic, "mechanicPosition")
    mechanicPosition.mechanic = nil
    mechanicPosition.mechanicName = nil
    setElementData(mechanic, "mechanicPosition", mechanicPosition)
    setElementData(plr, "hasPosition", nil)
end

function createMechanicPositions()
    for i, _ in pairs(fixPositions) do
        for k, pos in pairs(fixPositions[i].positions) do
            local mechanic = createElement("mechanicPosition")
            local col = createColSphere(pos, 4)
            setElementPosition(mechanic, pos)

            setElementData(col, "mechanic", mechanic)
            setElementData(mechanic, "mechanicPosition", {
                ID = k,
                jobID = fixPositions[i].jobID,
            })

            addEventHandler("onColShapeHit", col, onEnterMechanicPosition)
            addEventHandler("onColShapeLeave", col, onExitMechanicPosition)
        end
    end
end
createMechanicPositions()


for i, v in pairs(getElementsByType("player")) do
    setElementData(v, "hasPosition", nil)
end