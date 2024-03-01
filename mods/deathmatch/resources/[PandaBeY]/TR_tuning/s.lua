local tunePositions = {
    {
        pos = Vector3(-1786.87890625, 1206.4326171875, 25.125),
        type = "visual",
        marker = "bulb",
        icon = 40,
        color = {145, 237, 24},
    },
    {
        pos = Vector3(-1697.6962890625, 1035.552734375, 45.2109375),
        type = "performance",
        marker = "piston",
        icon = 41,
        color = {24, 237, 38},
    },
}

function createMarkers()
    for i, v in pairs(tunePositions) do
        local marker = createMarker(v.pos.x, v.pos.y, v.pos.z - 0.9, "cylinder", 2, v.color[1], v.color[2], v.color[3], 0)
        setElementData(marker, "tunerData", {
            type = v.type,
            exit = v.exit,
        }, false)
        setElementData(marker, "markerIcon", v.marker)

        local blip = createBlip(v.pos.x, v.pos.y, v.pos.z, 0, 2, v.color[1], v.color[2], v.color[3])
        setElementData(blip, "icon", v.icon)
    end

    addEventHandler("onMarkerHit", resourceRoot, onMarkerHit)
end

function onMarkerHit(el, md)
    if not el or not md then return end
    if getElementType(el) ~= "vehicle" then return end

    local vehData = getElementData(el, "vehicleData")
    if not vehData then return end
    if not vehData.ID then return end

    local owners = getElementData(el, "vehicleOwners")
    if not owners then return end

    local plr = getVehicleOccupant(el)
    if not plr then return end
    if getElementData(plr, "blockTune") then return end

    local inVeh = getVehicleOccupants(el)
    if #inVeh > 1 then exports.TR_noti:create(plr, "Araçta yalnızca sürücü oturabilir.", "error") return end


    local plrUID = getElementData(plr, "characterUID")
    if owners[1] ~= plrUID then exports.TR_noti:create(plr, "Aracı yalnızca sahibi ayarlayabilir.", "error") return end

    local tunerData = getElementData(source, "tunerData")
    if tunerData.type == "visual" then
        if getVehicleType(el) ~= "Automobile" then exports.TR_noti:create(plr, "Bu araçla tuning'e giremezsiniz.", "error") return end
        local tuneData = exports.TR_mysql:querry("SELECT ID, model, color, tuning, visualTuning as customTuning FROM tr_vehicles WHERE ID = ? LIMIT 1", vehData.ID)
        if tuneData and tuneData[1] then
            triggerClientEvent(plr, "createTuneWindow", resourceRoot, tunerData.type, tuneData[1])
        else
            exports.TR_noti:create(plr, "Bu araçla tuning'e giremezsiniz.", "error")
            return
        end

    elseif tunerData.type == "performance" then
        if getVehicleType(el) ~= "Automobile" then exports.TR_noti:create(plr, "Bu araçla tuning'e giremezsiniz.", "error") return end
        local tuneData = exports.TR_mysql:querry("SELECT ID, model, color, engineCapacity, tuning, performanceTuning as customTuning FROM tr_vehicles WHERE ID = ? LIMIT 1", vehData.ID)
        if tuneData and tuneData[1] then
            triggerClientEvent(plr, "createTuneWindow", resourceRoot, tunerData.type, tuneData[1])
        else
            exports.TR_noti:create(plr, "Bu araçla tuning'e giremezsiniz.", "error")
            return
        end
    end
end

function buyVehicleTuneItem(state, data)
    local tuneData = {}

    if state then
        if data.type == "setUpgrade" or data.type == "removeUpgrade" then
            exports.TR_mysql:querry("UPDATE tr_vehicles SET tuning = ? WHERE ID = ? LIMIT 1", data.newData, data.ID)

        elseif data.type == "lamps" then
            exports.TR_mysql:querry("UPDATE tr_vehicles SET color = ? WHERE ID = ? LIMIT 1", data.newData, data.ID)

        elseif data.type == "speedoColor" or data.type == "glassTint" or data.type == "wheelResize" or data.type == "wheelTilt" or data.type == "neon" then
            exports.TR_mysql:querry("UPDATE tr_vehicles SET visualTuning = ? WHERE ID = ? LIMIT 1", data.newData, data.ID)

        elseif data.type == "turbo" then
            exports.TR_mysql:querry("UPDATE tr_vehicles SET engineCapacity = ? WHERE ID = ? LIMIT 1", data.newData, data.ID)

        elseif data.type == "distribution" or data.type == "piston" or data.type == "injection" or data.type == "intercooler" or data.type == "clutch" or data.type == "breaking" or data.type == "breakpad" or data.type == "steering" or data.type == "transmission" or data.type == "drivetype" or data.type == "suspension" then
            exports.TR_mysql:querry("UPDATE tr_vehicles SET performanceTuning = ? WHERE ID = ? LIMIT 1", data.newData, data.ID)
        end
    end

    if data.tuneType == "visual" then
        tuneData = exports.TR_mysql:querry("SELECT ID, model, color, engineCapacity, tuning, visualTuning as customTuning FROM tr_vehicles WHERE ID = ? LIMIT 1", data.ID)
    elseif data.tuneType == "performance" then
        tuneData = exports.TR_mysql:querry("SELECT ID, model, color, engineCapacity, tuning, performanceTuning as customTuning FROM tr_vehicles WHERE ID = ? LIMIT 1", data.ID)
    end

    triggerClientEvent(source, "vehicleTuneResponse", resourceRoot, state, tuneData[1])

    if state then
        triggerClientEvent(source, "addAchievements", resourceRoot, data.type.."Tuning")
    end
end
addEvent("buyVehicleTuneItem", true)
addEventHandler("buyVehicleTuneItem", root, buyVehicleTuneItem)

function exitVehicleTune(ID)
    local vehicle = exports.TR_vehicles:spawnVehicle(ID)
    exports.TR_mysql:querry("UPDATE tr_vehicles SET parking = NULL WHERE ID = ? LIMIT 1", ID)

    setElementInterior(client, 0)
    setElementDimension(client, 0)

    local plr = client
    setTimer(function()
        warpPedIntoVehicle(plr, vehicle, 0)
        setVehicleEngineState(vehicle, true)
        setElementFrozen(vehicle, false)
        setVehicleOverrideLights(vehicle, 2)
    end, 100, 1)
end
addEvent("exitVehicleTune", true)
addEventHandler("exitVehicleTune", root, exitVehicleTune)

function removeVehOnStartTune()
    local veh = getPedOccupiedVehicle(client)
    if not veh then return end
    local vehData = getElementData(veh, "vehicleData")

    exports.TR_vehicles:saveVehicle(veh)
    exports.TR_mysql:querry("UPDATE tr_vehicles SET parking = ? WHERE ID = ? LIMIT 1", 40, vehData.ID)
    destroyElement(veh)

    setElementInterior(client, 1)
    setElementDimension(client, 1)
end
addEvent("removeVehOnStartTune", true)
addEventHandler("removeVehOnStartTune", root, removeVehOnStartTune)



createMarkers()