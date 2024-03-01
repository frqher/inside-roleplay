function moveVehicleToPoliceParking(veh, price, reason)
    if not veh or not price or not reason then triggerClientEvent(client, "responsePoliceParking", resourceRoot) return end

    local data = getElementData(veh, "vehicleData")
	if data then
		exports.TR_vehicles:saveVehicle(veh)
		exports.TR_mysql:querry("UPDATE tr_vehicles SET parking = 100, policeParkingInfo = ? WHERE ID = ? LIMIT 1", string.format("%s,%s,%s", price, reason, getPlayerName(client)), data.ID)
        destroyElement(veh)

        local winchVeh = getPedOccupiedVehicle(client)
        setElementData(winchVeh, "towedVeh", nil)
        setElementData(winchVeh, "winchVeh", nil)

        triggerClientEvent(client, "responsePoliceParking", resourceRoot, true)
        return
    end
    triggerClientEvent(client, "responsePoliceParking", resourceRoot)
end
addEvent("moveVehicleToPoliceParking", true)
addEventHandler("moveVehicleToPoliceParking", resourceRoot, moveVehicleToPoliceParking)


function policeParkingTakeoutVehicle(status, data)
    if status then
        local vehicle = exports.TR_vehicles:spawnVehicle(data[1], data[2])
        warpPedIntoVehicle(source, vehicle, 0)
        exports.TR_mysql:querry("UPDATE tr_vehicles SET parking = NULL, policeParkingInfo = NULL WHERE ID = ? LIMIT 1", data[1])
        setVehicleEngineState(vehicle, true)
        setVehicleFrozen(vehicle, false)
        setVehicleOverrideLights(vehicle, 2)
    end
    triggerClientEvent(source, "policeParkingTakeoutResponse", resourceRoot, status)
end
addEvent("policeParkingTakeoutVehicle", true)
addEventHandler("policeParkingTakeoutVehicle", root, policeParkingTakeoutVehicle)


function openPoliceParkingTakeout(el, md)
    if not el or not md then return end
    if getElementType(el) ~= "player" then return end
    if getPedOccupiedVehicle(el) then return end
    if not exports.TR_vehicles:canVehicleEnter(el) then return end

    local uid = getElementData(el, "characterUID")
    if not uid then return end
	local data = exports.TR_mysql:querry("SELECT ID, model, policeParkingInfo FROM tr_vehicles WHERE parking >= 100 AND policeParkingInfo IS NOT NULL AND ownedPlayer = ?", uid)

    local orgID = getElementData(el, "characterOrgID")
    local rentVehicle = false
    if orgID then
        rentVehicle = exports.TR_mysql:querry("SELECT tr_vehicles.ID as ID, model, policeParkingInfo FROM tr_vehicles LEFT JOIN tr_vehiclesRent ON tr_vehicles.ID = tr_vehiclesRent.vehID WHERE (tr_vehiclesRent.plrUID = ? OR (tr_vehicles.ownedOrg = ? AND tr_vehicles.ownedPlayer != ?)) AND parking >= 100 AND policeParkingInfo IS NOT NULL", uid, orgID, uid)
    else
        rentVehicle = exports.TR_mysql:querry("SELECT tr_vehicles.ID as ID, model, policeParkingInfo FROM tr_vehicles LEFT JOIN tr_vehiclesRent ON tr_vehicles.ID = tr_vehiclesRent.vehID WHERE tr_vehiclesRent.plrUID = ? AND parking >= 100 AND policeParkingInfo IS NOT NULL", uid)
    end

    if (data and data[1]) or (rentVehicle and rentVehicle[1]) then
        local vehSpawn = getElementData(source, "vehPos")
        triggerClientEvent(el, "openPoliceParkingTakeout", resourceRoot, vehSpawn, data, rentVehicle)
        return
    end
    exports.TR_noti:create(el, "Nie posiadasz żadnych pojazdów na parkingu policyjnym.", "error")
end

function createTakeoutMarkers()
    for i, v in pairs(policeParkings) do
        if not v.blockBlip then
            local blip = createBlip(v.exit.marker.x, v.exit.marker.y, v.exit.marker.z, 0, 1, 212, 146, 32)
            setElementData(blip, "icon", 42)
        end

        local markerTakeout = createMarker(v.exit.marker.x, v.exit.marker.y, v.exit.marker.z - 0.9, "cylinder", 1, 212, 146, 32, 0)
        setElementData(markerTakeout, "vehPos", v.exit, false)
        setElementData(markerTakeout, "markerIcon", "towtruck")
        setElementData(markerTakeout, "markerData", {
            title = "Odbiór pojazdów",
            desc = "Jeśli twój pojazd został odholowany przez policję, możesz go wykupić w tym miejscu."
        })

        addEventHandler("onMarkerHit", markerTakeout, openPoliceParkingTakeout)
    end
end
createTakeoutMarkers()