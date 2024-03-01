local createdVehicles = {}

function getRandomVehicleColor()
    local colors = {{170, 170, 170}, {0, 0, 0}, {140, 0, 0}, {30, 131, 168}, {21, 117, 28}, {196, 187, 6}, {214, 86, 0}, {50, 18, 122}}
    local random = math.random(1, #colors)
    return {colors[random][1], colors[random][2],colors[random][3], colors[random][1], colors[random][2],colors[random][3], colors[random][1], colors[random][2],colors[random][3], colors[random][1], colors[random][2],colors[random][3]}
end

function setHandling(veh, handling)
    local model = getElementModel(veh)
    if vehicleHandling[model] then
        if vehicleHandling[model].handlingEditor then
            local id = 1
            for value in string.gmatch(vehicleHandling[model].handlingEditor, "[^%s]+" ) do
                id = id + 1
                local property = getHandlingPropertyNameFromID(id)

                if property then
                    local val = stringToValue(property, value)
                    setVehicleHandling(veh, property, val)
                end
            end
        else
            for i, v in pairs(vehicleHandling[model]) do
                setVehicleHandling(veh, v.property, v.value)
            end
        end

    elseif handling then
        local id = 1
        for value in string.gmatch(handling, "[^%s]+" ) do
            id = id + 1
            local property = getHandlingPropertyNameFromID(id)

            if property then
                local val = stringToValue(property, value)
                setVehicleHandling(veh, property, val)
            end
        end
    end
end

function createVehicles()
    for i, v in pairs(vehicleData) do
        local veh = createVehicle(v.model, v.pos, v.rot, v.plate and v.plate or nil)
        -- setVehicleRespawnPosition(veh, v.pos, v.rot)
        -- toggleVehicleRespawn(veh, true)
        -- setVehicleIdleRespawnDelay(veh, 2 * 60 * 60000)
        setVehicleDamageProof(veh, true)

        if not v.color then
            local color = getRandomVehicleColor()
            setVehicleColor(veh, unpack(color))
        else
            setVehicleColor(veh, unpack(v.color))
        end
        if v.isAcademy then setElementData(veh, "academy", true, false) end
        if v.customModel then setElementData(veh, "customModel", v.customModel) end
        if v.variant then setVehicleVariant(veh, v.variant[1], v.variant[2]) end

        setElementData(veh, "fractionID", v.fractionID)
        removeVehicleSirens(veh)

        if v.number then setElementData(veh, "fractionNumber", v.number) end
        if v.numberNoImg then setElementData(veh, "fractionNumberNoImg", v.numberNoImg) end
        if not blockHandbrake[v.model] then setElementFrozen(veh, true) end
        if v.model == 407 then setElementData(veh, "waterTank", 40000) end
        if v.model == 416 then addVehicleStretcher(veh) end

        local data = fuelData[v.model]
        if not data then print(v.model) end
        setElementData(veh, "vehicleData", {
            fuel = tonumber(data.capacity),
            mileage = math.random(1500, 5000),
            engineType = data.petrol,
        }, false)

        if not createdVehicles[v.fractionID] then createdVehicles[v.fractionID] = {} end
        table.insert(createdVehicles[v.fractionID], veh)

        if v.tuning then
            for i, v in pairs(v.tuning) do
                addVehicleUpgrade(veh, v)
            end
        end

        setVehicleOverrideLights(veh, 1)

        setHandling(veh, v.handling)
    end

    vehicleData = nil
    blockHandbrake = nil
    fuelData = nil
end
createVehicles()

function getVehicleLicenceType(veh)
    return licenceType[getElementModel(veh)]
end

function getVehiclePermissionType(veh)
    if getElementData(veh, "academy") then return "veh1" end
    return permissionType[getElementModel(veh)]
end

function getFractionVehicles(fractionID)
    return createdVehicles[fractionID] or {}
end

function onEnterFractionVehicle(plr, seat, jacked)
    if jacked then cancelEvent() return end
    if seat ~= 0 then return end
    if exports.TR_admin:hasPlayerPermission(plr, "isDev") then return end

    local uid = getElementData(plr, "characterUID")
    local plrFraction = getElementData(plr, "characterDuty")
    local fractionID = getElementData(source, "fractionID")
    local licenceType = getVehicleLicenceType(source)

    if not plrFraction then exports.TR_noti:create(plr, "Bu araca binmek için fraksiyon görevinde olmanız gerekmektedir.", "error"); cancelEvent() return end
    if plrFraction[4] ~= fractionID then exports.TR_noti:create(plr, "Bu araca binmek için fraksiyon görevinde olmanız gerekmektedir.", "error"); cancelEvent() return end

    local hasLicence = exports.TR_mysql:querry("SELECT UID FROM tr_accounts WHERE UID = ? AND licence LIKE ? LIMIT 1", uid, string.format("%%%s%%", licenceType))
    if not hasLicence or not hasLicence[1] then exports.TR_noti:create(plr, "Bu aracı kullanabilmek için gerekli ehliyete sahip olmalısınız.", "error"); cancelEvent() return end

    local rankID = exports.TR_mysql:querry("SELECT rankID FROM tr_fractionsPlayers WHERE playerUID = ? LIMIT 1", uid)
    if not rankID or not rankID[1] then exports.TR_noti:create(plr, "Bu araca binmek için fraksiyon görevinde olmanız gerekmektedir.", "error"); cancelEvent() return end

    local permissionType = getVehiclePermissionType(source)
    local hasPermission = exports.TR_mysql:querry("SELECT true FROM tr_fractionsRanks WHERE ID = ? AND ?? IS NOT NULL LIMIT 1", rankID[1].rankID, permissionType)

    if not hasPermission or not hasPermission[1] then exports.TR_noti:create(plr, "Bu aracı kullanma izniniz bulunmamaktadır.", "error"); cancelEvent() return end
end
addEventHandler("onVehicleStartEnter", resourceRoot, onEnterFractionVehicle)


function blockExitWithCuffs(plr)
    if isElement(getElementData(plr, "cuffedBy")) then cancelEvent() end
end
addEventHandler("onVehicleStartExit", resourceRoot, blockExitWithCuffs)

function blockEnterWithCuffs(plr)
    local cuffed = getElementData(plr, "cuffed")
    if cuffed then
        if isElementAttached(cuffed) then cancelEvent() return end
    end
    if getElementData(plr, "cuffedBy") then cancelEvent() return end
end
addEventHandler("onVehicleStartEnter", root, blockEnterWithCuffs)