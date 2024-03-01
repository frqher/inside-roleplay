local mechanicPositions = {
    Vector3(-2052.4072265625, 158.33203125, 28.842931747437),
    Vector3(-14.419921875, -260.1826171875, 5.4296875),
}

function enterFractionMechanic(el, md)
    if getElementType(el) ~= "player" or not md then return end

    local veh = getPedOccupiedVehicle(el)
    if not veh then return end
    if getPedOccupiedVehicleSeat(el) ~= 0 then return end

    if not getElementData(veh, "fractionID") then
        exports.TR_noti:create(el, "Bu araç hiçbir fraksiyona ait değil.", "error")
        return
    end

    setElementFrozen(veh, true)
    setElementData(veh, "blockAction", true)
    setTimer(fixFractionVehicle, 10000, 1, veh)
    exports.TR_noti:create(el, "Araç tamiri devam ediyor...", "repair", 10)
end

function fixFractionVehicle(veh)
    fixVehicle(veh)
    setElementFrozen(veh, false)
    setElementData(veh, "blockAction", nil)
end

function createMechanicPositions()
    for i, v in pairs(mechanicPositions) do
        local marker = createMarker(v - Vector3(0, 0, 0.9), "cylinder", 1, 88, 168, 50, 0)
        setElementData(marker, "markerIcon", "mechanic")
        setElementData(marker, "markerData", {
            title = "Fraksiyon Mekaniği",
            desc = "Araç tamiri için işaretçiye girin.",
        })

        local col = createColSphere(v, 2)
        addEventHandler("onColShapeHit", col, enterFractionMechanic)
    end
end
createMechanicPositions()