function createVehicleShops()
    for i, _ in pairs(VehicleShops) do
        createVehiclesForShop(i)
    end
    for i, v in pairs(VehicleNPCs) do
        createDealersForShop(i)
    end
end

function createVehiclesForShop(shopName)
    if not VehicleShops[shopName] then return end
    for i, v in pairs(VehicleShops[shopName]) do
        local veh, engines = createVehicleForShop(shopName, i)
        v.engines = engines
        v.vehObject = veh
        v.model = getElementModel(veh)

        if v.sign then
            local sign = createObject(v.price < 15000 and 3927 or 1906, v.sign.pos, v.sign.rot)
            setElementData(sign, "signInfo", {shop = shopName, veh = veh, data = v})
            v.signObject = sign
        end
    end
end

function createVehicleForShop(shopName, index)
    local v = VehicleShops[shopName][index]

    local model = v.model
    if VehicleShops[shopName][index].models then
        -- model = VehicleShops[shopName][index].models[math.random(1, #VehicleShops[shopName][index].models)]
        model = getRandomModel(shopName, index)
    end
    v.price = VehiclePrices[model]

    local veh = createVehicle(model, v.pos, v.rot, "SATIŞ")
    setVehicleColor(veh, v.color[1], v.color[2], v.color[3], v.color[1], v.color[2], v.color[3], v.color[1], v.color[2], v.color[3], v.color[1], v.color[2], v.color[3])
    setTimer(function(pos)
        local posNow = Vector3(getElementPosition(veh))
        local vec = pos - posNow
        setElementPosition(veh, posNow.x + vec.x, posNow.y + vec.y, posNow.z)
        setElementFrozen(veh, true)
    end, 1500, 1, v.pos)

    setVehicleDamageProof(veh, true)
    setElementData(veh, "blockAction", true)
    if model ~= 522 then
        setVehicleVariant(veh, 255, 255)
    end

    local engines = generateRandomEnginesList(model, "p")
    local f = generateRandomEnginesList(model, "d")
    for i, v in pairs(f) do
        table.insert(engines, v)
    end

    return veh, engines
end

function getRandomModel(shopName, index)
    local rand = math.random(1, 100)
    for i, v in pairs(VehicleShops[shopName][index].models) do
        if v[1] <= rand and v[2] >= rand then
            return i
        end
    end
end

function createDealersForShop(shopName)
    local data = VehicleNPCs[shopName]
    local ped = exports.TR_npc:createNPC(data.skin, data.pos.x, data.pos.y, data.pos.z, data.rot, data.name, data.role, "dialogue")
    setElementInterior(ped, data.int)
    setElementDimension(ped, data.dim)

    if data.dialogue then
        local dialogue = exports.TR_npc:createDialogue()
        for _, option in pairs(data.dialogue) do
            exports.TR_npc:addDialogueText(dialogue, option[1], option[2])
        end
        exports.TR_npc:setNPCDialogue(ped, dialogue)
    end
end


function shopBuyVehicle(state, data)
    if state then
        local index = false
        for i, v in pairs(VehicleShops[data.shopName]) do
            if getElementModel(v.vehObject) == data.model then
                index = i
                break
            end
        end

        local respawnPos = VehicleExits[data.shopName]
        if not respawnPos then
            local vehPos = Vector3(getElementPosition(VehicleShops[data.shopName][index].vehObject))
            local vehRot = Vector3(getElementRotation(VehicleShops[data.shopName][index].vehObject))
            respawnPos = string.format("%.2f,%.2f,%.2f,%d,%d,%d", vehPos.x, vehPos.y, vehPos.z, vehRot.x, vehRot.y, vehRot.z)
        end
        if isElement(VehicleShops[data.shopName][index].vehObject) then destroyElement(VehicleShops[data.shopName][index].vehObject) end

        local uid = getElementData(source, "characterUID")
        local variant = data.variant or "0,0"
        local _, _, lastID = exports.TR_mysql:querry("INSERT INTO `tr_vehicles`(`model`, `pos`, `fuel`, `mileage`, `color`, `engineCapacity`, `engineType`, `ownedPlayer`, `parking`, `variant`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1, ?)", data.model, respawnPos, 10, data.mileage, data.color, data.engineCapacity, data.engineType, uid, variant)

        local vehicle = exports.TR_vehicles:spawnVehicle(lastID, respawnPos)
        if not vehicle then return end
        warpPedIntoVehicle(source, vehicle, 0)
        setElementFrozen(vehicle, false)

        exports.TR_mysql:querry("UPDATE tr_vehicles SET parking = NULL WHERE ID = ? LIMIT 1", lastID)
        triggerClientEvent(source, "addAchievements", resourceRoot, "vehicleSaloonBuy")

        local sphere = createColSphere(VehicleNPCs[data.shopName].pos, 15)
        triggerClientEvent(getElementsWithinColShape(sphere, "player"), "updateVehicleDealer", resourceRoot, VehicleShops[data.shopName])
        destroyElement(sphere)

        -- local time = getRealTime()
        -- exports.TR_discord:sendChannelMsg("vehicleBuy", {
          -- time = string.format("[%02d:%02d %02d.%02d]", time.hour, time.minute, time.monthday, time.month),
          -- author = getPlayerName(source),
          -- text = string.format("Bir bayiden %s $%.2f karşılığında bir %s aracı satın aldı.", getVehicleNameFromModel(data.model), data.toPay),
        -- })

        setTimer(addNewShopVehicle, VehicleShops[data.shopName][index].refreshTime * 1000, 1, data.shopName, index)
    end
    triggerClientEvent(source, "vehicleShopResponse", resourceRoot, state)
end
addEvent("shopBuyVehicle", true)
addEventHandler("shopBuyVehicle", root, shopBuyVehicle)


function addNewShopVehicle(shopName, index)
    local data = VehicleShops[shopName][index]
    local veh, engines = createVehicleForShop(shopName, index)

    if data.signObject then
        setElementData(data.signObject, "signInfo", {shop = shopName, veh = veh, data = data})
    end
    data.vehObject = veh
    data.engines = engines

    local sphere = createColSphere(VehicleNPCs[shopName].pos, 15)
    triggerClientEvent(getElementsWithinColShape(sphere, "player"), "updateVehicleDealer", resourceRoot, VehicleShops[shopName])
    destroyElement(sphere)
end


function createVehicleDealer(ped, data)
    local uid = getElementData(client, "characterUID")
    local vehicleLimit = exports.TR_mysql:querry("SELECT vehicleLimit FROM tr_accounts WHERE UID = ? LIMIT 1", uid)
    local vehicleCount = exports.TR_mysql:querry("SELECT ID FROM tr_vehicles WHERE ownedPlayer = ?", uid)

    triggerClientEvent(client, "createVehicleDealer", resourceRoot, VehicleShops[data[1]], data[1], #vehicleCount, vehicleLimit[1].vehicleLimit)
end
addEvent("createVehicleDealer", true)
addEventHandler("createVehicleDealer", root, createVehicleDealer)


function getEngineSizeText(v, model, symbol)
    if v < 1.9 then return string.format("%.1f %s2", v, symbol) end
    if v <= 3 then return string.format("%.1f %s4", v, symbol) end
    if v <= 4 then return string.format("%.1f %s6", v, symbol) end
    return string.format("%.1f %s8", v, symbol)
end

function generateRandomEnginesList(model, type)
    local avaliable = {}
    for i, v in pairs(AvaliableEngines) do
        if v >= VehicleEngines[model][1] and v <= VehicleEngines[model][2] then
            table.insert(avaliable, v)
        end
    end

    local enginesCount = math.random(math.min(1, #avaliable), math.min(#avaliable, 4))
    -- enginesCount = #avaliable
    local selected = {}
    while enginesCount > #selected do
        if #selected == 0 then
            table.insert(selected, avaliable[1])
            table.remove(avaliable, 1)
        else
            local rand = math.random(1, #avaliable)
            table.insert(selected, avaliable[rand])
            table.remove(avaliable, rand)
        end
    end
    table.sort(selected)

    local fullEngines = {}
    for i, v in pairs(selected) do
        if v < 1.9 then
            table.insert(fullEngines, {getEngineSizeText(v, model, VehicleEngines[model][3]), i == 1 and 0 or math.abs(math.floor(VehiclePrices[model] * (v - 0.8)/2)), type})
        else
            if VehiclePrices[model] < 50000 then
                table.insert(fullEngines, {getEngineSizeText(v, model, VehicleEngines[model][3]), i == 1 and 0 or math.abs(math.floor(VehiclePrices[model] * (v - 1.9))), type})
            elseif VehiclePrices[model] < 150000 then
                table.insert(fullEngines, {getEngineSizeText(v, model, VehicleEngines[model][3]), i == 1 and 0 or math.abs(math.floor(VehiclePrices[model] * (v - 1.9)/5)), type})
            else
                table.insert(fullEngines, {getEngineSizeText(v, model, VehicleEngines[model][3]), i == 1 and 0 or math.abs(math.floor(VehiclePrices[model] * (v - 1.9)/10)), type})
            end
        end
    end

    return fullEngines
end

createVehicleShops()


-- local c = 0
-- for i, v in pairs(VehiclePrices) do
--     local veh = createVehicle(i, 2106.6357421875 - (c-1) * 4, -2504.396484375, 13.53911781311)
--     setVehicleDoorState(veh, 0, 4, false)
--     c = c + 1
-- end