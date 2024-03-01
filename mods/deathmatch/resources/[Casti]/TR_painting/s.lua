local painting = {}

function requestVehiclePaint(plr, vehicle)
    if not plr then triggerClientEvent(client, "updateInteraction", resourceRoot) return end
    triggerClientEvent(plr, "openPaintingAccept", resourceRoot, client)

    setElementData(client, "blockAction", true)
    setElementData(vehicle, "blockAction", client)
    exports.TR_noti:create(client, "Araç boyama teklifi gönderildi.", "info")
end
addEvent("requestVehiclePaint", true)
addEventHandler("requestVehiclePaint", root, requestVehiclePaint)

function declineVehiclePaint(plr)
    removeElementData(getPedOccupiedVehicle(client), "blockAction")

    if not plr then return end
    exports.TR_noti:create(plr, string.format("%s, araç boyama teklifini reddetti.", getPlayerName(client)), "error")
    removeElementData(plr, "blockAction")
end
addEvent("declineVehiclePaint", true)
addEventHandler("declineVehiclePaint", root, declineVehiclePaint)

function playerPayForVehiclePaint(status, data)
    if status then
        if isElement(data[1]) then
            local veh = getPedOccupiedVehicle(source)

            setElementFrozen(veh, true)
            setVehicleDamageProof(veh, true)
            painting[veh] = setTimer(paintVehicleFinal, 120000, 1, veh, data[2], data[1])

            exports.TR_weaponSlots:giveWeapon(data[1], 41, 9999999, true)
            triggerClientEvent(data[1], "startPaintingVehicle", resourceRoot, source, data[2])
            exports.TR_noti:create(source, "Lakiernik işe başladı. Aracınızın boyanmasını bekleyin.", "info", 5)
            exports.TR_noti:create(data[1], "Aracı boyamak için, her tarafı eşit şekilde boyamalısınız.", "info", 5)
        else
            local veh = getPedOccupiedVehicle(source)
            setElementFrozen(veh, true)

            painting[veh] = setTimer(paintVehicleFinal, 7000, 1, veh, data[2])
            exports.TR_noti:create(source, "Boyama teklifini reddettiniz veya lakiernik görevden ayrıldı. Araç otomatik olarak boyanacak...", "info", 7)
        end
    end
    triggerClientEvent(source, "responsePaintingAccept", resourceRoot, status)
end

addEvent("playerPayForVehiclePaint", true)
addEventHandler("playerPayForVehiclePaint", root, playerPayForVehiclePaint)


function paintVehicle(veh, colors)
    setVehicleColor(veh, unpack(colors))
end
addEvent("paintVehicle", true)
addEventHandler("paintVehicle", root, paintVehicle)


function paintVehicleFinal(veh, colors, mechanic, pay)
    if painting[veh] then
        if isTimer(painting[veh]) then killTimer(painting[veh]) end
    end
    local driver = getVehicleOccupant(veh, 0)

    setVehicleColor(veh, unpack(colors))
    setVehicleDamageProof(veh, false)
    setElementFrozen(veh, false)
    removeElementData(veh, "blockAction")

    if isElement(mechanic) and not pay then
        triggerClientEvent(mechanic, "stopPaintingVehicle", resourceRoot)
        exports.TR_weaponSlots:takeWeapon(mechanic, 41)
        removeElementData(mechanic, "blockAction")
    elseif isElement(mechanic) and pay then
        exports.TR_core:giveMoneyToPlayer(mechanic, 100)
        exports.TR_noti:create(mechanic, string.format("Araç boyandı.\nKazandığınız: $%.2f.", 100), "success")
        exports.TR_weaponSlots:takeWeapon(mechanic, 41)
        removeElementData(mechanic, "blockAction")
    end
    if driver then
        triggerClientEvent(driver, "addAchievements", resourceRoot, "vehicleColor")
        exports.TR_noti:create(driver, "Araç boyandı.", "success")
    end
    


    local vehData = getElementData(veh, "vehicleData")
    if not vehData then return end
    local r, g, b = getVehicleHeadLightColor(veh)

    local color = ""
    for i, v in pairs(colors) do
        color = color .. v .. ","
    end
    color = color .. r .. ",".. g .. ",".. b
    exports.TR_mysql:querry("UPDATE tr_vehicles SET color = ? WHERE ID = ?", color, vehData.ID)
end
addEvent("paintVehicleFinal", true)
addEventHandler("paintVehicleFinal", root, paintVehicleFinal)




function onEnterMechanicPosition(plr, md)
    if not plr or not md then return end

    local mechanic = getElementData(source, "mechanic")
    local paintingPosition = getElementData(mechanic, "paintingPosition")
    if isElement(paintingPosition.mechanic) then
        if getElementModel(paintingPosition.mechanic) ~= 305 then
            if getElementModel(plr) ~= 305 then return end
            if getElementData(plr, "hasPosition") then return end
            paintingPosition.mechanic = plr
            paintingPosition.mechanicName = getPlayerName(plr)
            setElementData(mechanic, "paintingPosition", paintingPosition)
            setElementData(plr, "hasPosition", mechanic)
        end
    else
        if getElementModel(plr) ~= 305 then return end
        if getElementData(plr, "hasPosition") then return end
        paintingPosition.mechanic = plr
        paintingPosition.mechanicName = getPlayerName(plr)
        setElementData(mechanic, "paintingPosition", paintingPosition)
        setElementData(plr, "hasPosition", mechanic)
    end
end

function onExitMechanicPosition(plr, md)
    if not plr or not md then return end

    local mechanic = getElementData(plr, "hasPosition")
    if not mechanic then return end

    local paintingPosition = getElementData(mechanic, "paintingPosition")
    paintingPosition.mechanic = nil
    paintingPosition.mechanicName = nil
    setElementData(mechanic, "paintingPosition", paintingPosition)
    setElementData(plr, "hasPosition", nil)
end

function createMechanicPositions()
    for i, data in pairs(paintPositions) do
        for k, pos in pairs(paintPositions[i].positions) do
            local mechanic = createElement("paintingPosition")
            local col = createColSphere(pos, 5)
            setElementPosition(mechanic, pos)

            setElementData(col, "mechanic", mechanic)
            setElementData(mechanic, "paintingPosition", {
                ID = k,
                jobID = data.jobID,
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