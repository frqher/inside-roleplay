local fuelPrice = {}

function getVehicleFuel(vehicle)
    local data = getElementData(vehicle, "vehicleData")
    if not data then return end

    triggerClientEvent(client, "setVehicleFuel", resourceRoot, data.fuel, data.engineType)
end
addEvent("getVehicleFuel", true)
addEventHandler("getVehicleFuel", resourceRoot, getVehicleFuel)

function getFuelPrice(fuelType)
    triggerClientEvent(client, "setFuelPrice", resourceRoot, fuelPrice[fuelType])
end
addEvent("getFuelPrice", true)
addEventHandler("getFuelPrice", resourceRoot, getFuelPrice)

function getFuelPrices()
    triggerClientEvent(client, "updateFuelSings", resourceRoot, fuelPrice)
end
addEvent("getFuelPrices", true)
addEventHandler("getFuelPrices", resourceRoot, getFuelPrices)

function fuelVehicle(state, data)
    if state then
        local occupants = getVehicleOccupants(data.vehicle)
        local vehicleData = getElementData(data.vehicle, "vehicleData")
        vehicleData.fuel = math.min(vehicleData.fuel + data.fuel, data.maxFuel)
        setElementData(data.vehicle, "vehicleData", vehicleData, false)

        triggerClientEvent(source, "fuelResponse", resourceRoot, data.fuel, data.full)

        if #occupants > 0 then
            for i, v in pairs(occupants) do
                triggerClientEvent(v, "playerSpeedometerOpen", resourceRoot, data.vehicle, vehicleData)
            end
        end
        return
    end
    triggerClientEvent(source, "fuelResponse", resourceRoot)
end
addEvent("fuelVehicle", true)
addEventHandler("fuelVehicle", root, fuelVehicle)


function bindPlayerFuelPistol(data)
    local obj = exports.TR_objectManager:attachObjectToBone(client, 1909, 1, 12, -0.08, 0.03, 0.15, 0, 260, 0)
    setElementData(obj, "texture", data)
end
addEvent("bindPlayerFuelPistol", true)
addEventHandler("bindPlayerFuelPistol", resourceRoot, bindPlayerFuelPistol)

function removePlayerFuelPistol()
    exports.TR_objectManager:removeObject(client, 1909)
end
addEvent("removePlayerFuelPistol", true)
addEventHandler("removePlayerFuelPistol", resourceRoot, removePlayerFuelPistol)

function randomizeFuel(force)
    if force then
        fuelPrice["Standard"] = math.floor(math.random(175, 205))/100
        fuelPrice["Plus"] = math.floor(math.random(210, 240))/100
        fuelPrice["Premium"] = math.floor(math.random(250, 280))/100
        fuelPrice["ON"] = math.floor(math.random(225, 255))/100
        return
    end

    local time = getRealTime()
    if time.hour == 0 and time.minute == 0 then
        fuelPrice["Standard"] = math.floor(math.random(175, 205))/100
        fuelPrice["Plus"] = math.floor(math.random(210, 240))/100
        fuelPrice["Premium"] = math.floor(math.random(250, 280))/100
        fuelPrice["ON"] = math.floor(math.random(225, 255))/100

        triggerClientEvent(root, "updateFuelSings", resourceRoot, fuelPrice)
    end
end
randomizeFuel(true)
setTimer(randomizeFuel, 60000, 0)