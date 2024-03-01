function createSnowPlowJobVehicle(type, upgraded)
    if type == "snowPlow" then
        local veh = createVehicle(531, -2224.87109375, -2327.1630859375, 30.625, 0, 0, 230)
        setVehicleColor(veh, 220, 65, 32, 255, 255, 255)

        setElementData(veh, "vehicleData", {
            fuel = 70,
            mileage = math.random(350000, 500000),
            engineType = "d",
        }, false)
        setElementData(veh, "vehicleOwner", client)
        setElementData(veh, "blockCollisions", true)
        warpPedIntoVehicle(client, veh)

        if upgraded then
            setVehicleHandling(veh, "maxVelocity", 45)
        else
            setVehicleHandling(veh, "maxVelocity", 30)
        end

        setVehicleHandling(veh, "engineAcceleration", 22)

        exports.TR_objectManager:attachObjectToPlayer(client, veh)

    elseif type == "sand" then
        local veh = createVehicle(422, -2234.19921875, -2319.3095703125, 30.607608795166, 0, 0, 230)
        setVehicleColor(veh, 220, 65, 32, 255, 255, 255)

        setElementData(veh, "vehicleData", {
            fuel = 70,
            mileage = math.random(350000, 500000),
            engineType = "d",
        }, false)
        setElementData(veh, "vehicleOwner", client)
        setElementData(veh, "blockCollisions", true)
        warpPedIntoVehicle(client, veh)

        exports.TR_objectManager:attachObjectToPlayer(client, veh)
    end

    setElementInterior(client, 0)
    setElementDimension(client, 0)
end
addEvent("createSnowPlowJobVehicle", true)
addEventHandler("createSnowPlowJobVehicle", resourceRoot, createSnowPlowJobVehicle)

function giveGroupSnowPlowPayment(group)
    for i, v in pairs(group) do
        triggerClientEvent(v.plr, "giveGroupSnowPlowPayment", resourceRoot)
    end
end
addEvent("giveGroupSnowPlowPayment", true)
addEventHandler("giveGroupSnowPlowPayment", resourceRoot, giveGroupSnowPlowPayment)

function canEnterVehicle(plr, seat, jacked, door)
    if jacked then cancelEvent() return end
    if seat == 0 then
        if exports.TR_vehicles:canUseVehicle(source, plr) then return end
        cancelEvent()
        exports.TR_noti:create(plr, "Bu araç size ait değil.", "error")
    end
end
addEventHandler("onVehicleStartEnter", resourceRoot, canEnterVehicle)



function detachTrailer(theTruck)
    if getElementModel(theTruck) == 531 then
        setTimer(detachTrailer2, 50, 1, theTruck, source)
        setElementData(source, "beforeAttach", {
            pos = Vector3(getElementPosition(source)),
            rot = Vector3(getElementRotation(source)),
        }, false)
    end
end
addEventHandler("onTrailerAttach", root, detachTrailer)

function detachTrailer2(theTruck, trailer)
    if (isElement(theTruck) and isElement(trailer)) then
        local beforeAttach = getElementData(trailer, "beforeAttach")
        if beforeAttach then
            setElementPosition(trailer, beforeAttach.pos)
            setElementRotation(trailer, beforeAttach.rot)
            removeElementData(trailer, "beforeAttach")
        end

        detachTrailerFromVehicle(theTruck, trailer)
    end
end