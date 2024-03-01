local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    list = {
        x = sx - 300/zoom,
        y = (sy - 68/zoom)/2 + 30/zoom,
        w = 300/zoom,
        h = 68/zoom,
    },

    marker = {
        size = 2.2,
    },

    loadingPoints = {
        {
            pos = Vector3(1428.232421875, 1045.1328125, 10.8203125),
            rot = 88,
        },
        {
            pos = Vector3(1427.4296875, 1067.015625, 10.108030319214),
            rot = 88,
        },
        {
            pos = Vector3(1427.2900390625, 1085.767578125, 10.8203125),
            rot = 88,
        },
        {
            pos = Vector3(1426.9736328125, 1039.220703125, 10.146137237549),
            rot = 88,
        },
        {
            pos = Vector3(1427.1455078125, 1029.6376953125, 10.131774902344),
            rot = 88,
        },
    },

    vehicleSpawns = {
        Vector3(1381.9990234375, 984.498046875, 10.8203125),
        Vector3(1381.9990234375, 988.498046875, 10.8203125),
        Vector3(1381.9990234375, 992.498046875, 10.8203125),
        Vector3(1381.9990234375, 996.498046875, 10.8203125),
        Vector3(1381.9990234375, 1000.498046875, 10.8203125),
    },

    fontHeight = 20,

    hourEarning = {4300, 4500},
    maxEarning = 250,
}

Courier = {}
Courier.__index = Courier

function Courier:create(...)
    local instance = {}
    setmetatable(instance, Courier)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function Courier:constructor(...)
    self.markers = {}
    self.blips = {}
    self.ownedUpgrades = arg[1]

    self.checkTimerTick = getTickCount()

    self.fonts = {}
    self.fonts.list = exports.TR_dx:getFont(11)
    guiInfo.fontHeight = dxGetFontHeight(1/zoom, self.fonts.list)

    self.func = {}
    self.func.render = function() self:render() end

    self.func.createLoadingPoints = function() self:createLoadingPoints() end
    self.func.hitLoadingPoint = function(...) self:hitLoadingPoint(source, ...) end
    self.func.onLoadVehicle = function(...) self:onLoadVehicle(...) end
    self.func.hitUnloadingPoint = function(...) self:hitUnloadingPoint(source, ...) end


    if self:createJobVehicle() then return end

    exports.TR_jobs:resetPaymentTime()
    exports.TR_noti:create("Kurye olarak işe başladınız.", "job")
    exports.TR_jobs:createInformation(jobSettings.name, "Kendi teslimat aracınıza binin ve yüklemeye gitmek için ilerleyin.")
    addEventHandler("onClientRender", root, self.func.render)
    return true
end

function Courier:destroy()
    exports.TR_jobs:resetPaymentTime()
    self:removeMarkers()

    removeEventHandler("onClientRender", root, self.func.render)
    triggerServerEvent("removeAttachedObject", resourceRoot, 499)
    if self.containerModel then triggerServerEvent("removeAttachedObject", resourceRoot, self.containerModel) end
    if isElement(self.zoneImg) then destroyElement(self.zoneImg) end
    if isElement(self.trailerImg) then destroyElement(self.trailerImg) end
    if isElement(self.baseCol) then destroyElement(self.baseCol) end

    jobSettings.work = nil
    self = nil
end

function Courier:removeMarkers()
    for i, v in pairs(self.blips) do
        destroyElement(v)
    end

    for i, v in pairs(self.markers) do
        destroyElement(v)
    end

    self.markers = {}
    self.blips = {}
end

function Courier:createLoadingPoints(blockGPS)
    self.renderDestinations = nil
    self.markers = {}
    self.blips = {}

    for i, v in pairs(guiInfo.loadingPoints) do
        local marker = createMarker(v.pos.x, v.pos.y, v.pos.z - 0.9, "cylinder", 2, 255, 60, 60, 0)
        setElementData(marker, "markerData", {
            title = "Yükleme Noktası",
            desc = "Aracı yüklemek için arka taraftan girin.",
        }, false)
        setElementData(marker, "markerIcon", "truck", false)
        setElementData(marker, "markerRot", v.rot, false)

        addEventHandler("onClientMarkerHit", marker, self.func.hitLoadingPoint)
        table.insert(self.markers, marker)

        local blip = createBlip(v.pos, 0, 1, 255, 60, 60, 255)
        setElementData(blip, "icon", 22, false)

        table.insert(self.blips, blip)
    end

    if not blockGPS then
        exports.TR_hud:findBestWay(1448.3427734375, 1054.9501953125)
    end
    exports.TR_jobs:setPlayerTargetPos(1448.3427734375, 1054.9501953125, 11.759575843811, 0, 0, "Aracı paketlerle doldurmak için bazaya gidin")
    setElementFrozen(localPlayer, false)
    local veh = getPedOccupiedVehicle(localPlayer)
    if veh then setElementFrozen(veh, false) end
    triggerServerEvent("setCourierFrozen", resourceRoot, veh, false)
end

function Courier:hitLoadingPoint(source, ...)
    if arg[1] ~= localPlayer then return end

    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return end
    if getElementModel(veh) ~= 499 then return end

    local _, _, vehRot = getElementRotation(veh)
    local rot = getElementData(source, "markerRot")

    if vehRot >= rot - 5 and vehRot <= rot + 5 then
        if self.panel then return end
        if not exports.TR_dx:canOpenGUI() then return end

        setElementFrozen(localPlayer, true)
        setElementFrozen(veh, true)
        triggerServerEvent("setCourierFrozen", resourceRoot, veh, true)

        exports.TR_jobs:setPlayerTargetPos(false)
        self.panel = TargetPanel:create(self.ownedUpgrades[2])
        return
    end
    exports.TR_noti:create("Aracı yüklemek için arka taraftan girin.", "error")
end

function Courier:hitUnloadingPoint(source, ...)
    if arg[1] ~= localPlayer or not arg[2] then return end
    if not self.carryingBox then return end

    local veh = getPedOccupiedVehicle(localPlayer)
    if veh then return end

    self.roadTable[self.deliveryPoint].delivered = true

    self:payForDrive()
    self:destroyBox()

    self:createNextDeliveryPoint()
end

function Courier:loadVehicle(road)
    local roadTable = self:getBestRoad(road)
    self.roadTable = self:generateZones(roadTable)
    self.panel = nil

    toggleControl("enter_exit", false)
    setElementData(getPedOccupiedVehicle(localPlayer), "blockAction", true)

    exports.TR_jobs:createInformation(jobSettings.name, "Araç paketlerle yükleniyor.")
    self.loadingTimer = setTimer(self.func.onLoadVehicle, 10000, 1)
end

function Courier:createNextDeliveryPoint()
    self:removeMarkers()

    self.deliveryPoint = self.deliveryPoint + 1
    if self.deliveryPoint > #self.roadTable then
        self:createLoadingPoints()
        exports.TR_jobs:createInformation(jobSettings.name, "Tüm paketleri teslim ettiniz. Üsse dönerek yüklenin.")
        return
    end

    exports.TR_jobs:setPaymentTime()
    local v = self.roadTable[self.deliveryPoint]

    local marker = createMarker(v.pos.x, v.pos.y, v.pos.z - 0.9, "cylinder", 2, 255, 60, 60, 0)
    setElementData(marker, "markerData", {
        title = "Teslimat Noktası",
        desc = "Paketi bırakmak için markere girin.",
    }, false)
    setElementData(marker, "markerIcon", "magazineBox", false)

    addEventHandler("onClientMarkerHit", marker, self.func.hitUnloadingPoint)
    self.markers.deliveryBox = marker

    local blip = createBlip(v.pos, 0, 1, 255, 60, 60, 255)
    setElementData(blip, "icon", 22, false)

    table.insert(self.blips, blip)

    exports.TR_jobs:setPlayerTargetPos(v.pos.x, v.pos.y, v.pos.z, 0, 0, "Alıcıya paket teslim et")
    exports.TR_hud:findBestWay(v.pos.x, v.pos.y)
end

function Courier:onLoadVehicle()
    self.renderDestinations = true

    toggleControl("enter_exit", true)
    local veh = getPedOccupiedVehicle(localPlayer)

    setElementData(veh, "blockAction", false)
    setElementFrozen(localPlayer, false)
    setElementFrozen(veh, false)
    triggerServerEvent("setCourierFrozen", resourceRoot, veh, false)

    self.deliveryPoint = 0
    self:buildDestinationText()
    self:createNextDeliveryPoint()
end

function Courier:buildDestinationText()
    local text = ""
    for i, v in pairs(self.roadTable) do
        text = string.format("%s\n %s | %02d:%02d", text, v.zone, v.delvieryTime[1], v.delvieryTime[2])
    end

    guiInfo.list.y = exports.TR_jobs:createInformation(jobSettings.name, "Taşınacak Paketler:\n ", #self.roadTable * guiInfo.fontHeight + 5/zoom)
end

function Courier:render()
    if self.carryingBox then
        if not self.ownedUpgrades[1] then
            toggleControl("walk", false)
            setPedControlState(localPlayer, "walk", true)
        end
    end

    if not self.renderDestinations then return end
    if not self.roadTable then return end
    if #self.roadTable < 1 then return end

    local time = getRealTime()
    for i, v in pairs(self.roadTable) do
        if time.hour >= v.delvieryTime[1] and time.minute > v.delvieryTime[2] and not v.delivered then
            v.delayed = true
        end

        if v.delivered then
            local color = v.delayed and tocolor(158, 51, 51, 255) or tocolor(51, 158, 51, 255)

            dxDrawText((v.delayed and "✕  " or "✓  ")..v.zone, guiInfo.list.x + 10/zoom, guiInfo.list.y + guiInfo.fontHeight * (i-1), guiInfo.list.x + guiInfo.list.w - 50/zoom, guiInfo.list.y + guiInfo.fontHeight * i, color, 1/zoom, self.fonts.list, "left", "center")
            dxDrawText(string.format("%02d:%02d", v.delvieryTime[1], v.delvieryTime[2]), guiInfo.list.x + 10/zoom, guiInfo.list.y + guiInfo.fontHeight * (i-1), guiInfo.list.x + guiInfo.list.w - 10/zoom, guiInfo.list.y + guiInfo.fontHeight * i, color, 1/zoom, self.fonts.list, "right", "center")

        else
            local color = v.delayed and tocolor(158, 51, 51, 255) or tocolor(170, 170, 170, 255)
            if (time.hour >= v.delvieryTime[1] and time.minute >= v.delvieryTime[2] and math.abs(time.hour - v.delvieryTime[1]) == 0) or v.delayed then
                color = v.delayed and tocolor(158, 51, 51, 255) or tocolor(181, 168, 25, 255)
                dxDrawText("½  "..v.zone, guiInfo.list.x + 10/zoom, guiInfo.list.y + guiInfo.fontHeight * (i-1), guiInfo.list.x + guiInfo.list.w - 50/zoom, guiInfo.list.y + guiInfo.fontHeight * i, color, 1/zoom, self.fonts.list, "left", "center")
            else
                dxDrawText((v.delayed and "½  " or "⛟ ")..v.zone, guiInfo.list.x + 10/zoom, guiInfo.list.y + guiInfo.fontHeight * (i-1), guiInfo.list.x + guiInfo.list.w - 50/zoom, guiInfo.list.y + guiInfo.fontHeight * i, color, 1/zoom, self.fonts.list, "left", "center")
            end

            dxDrawText(string.format("%02d:%02d", v.delvieryTime[1], v.delvieryTime[2]), guiInfo.list.x + 10/zoom, guiInfo.list.y + guiInfo.fontHeight * (i-1), guiInfo.list.x + guiInfo.list.w - 10/zoom, guiInfo.list.y + guiInfo.fontHeight * i, color, 1/zoom, self.fonts.list, "right", "center")
        end
    end
end

function Courier:createJobVehicle()
    local respIndex = self:getFreeRespawn()
    if not respIndex then
        exports.TR_noti:create("Otoparkta boş bir yer yok. Boş bir yer açılana kadar bekleyin.", "error")
        exports.TR_jobs:responseJobWindow(true)
        self:destroy()
        return true
    end

    local pos = guiInfo.vehicleSpawns[respIndex]
    triggerServerEvent("createCourierVehicle", resourceRoot, {pos.x, pos.y, pos.z}, self.ownedUpgrades[3])
    exports.TR_jobs:responseJobWindow()

    self:createLoadingPoints(true)
end

function Courier:getFreeRespawn()
    local freeResp = false

    for i, spawnPos in pairs(guiInfo.vehicleSpawns) do
        local clear = true
        for _, v in pairs(getElementsByType("vehicle", root)) do
            local pos = Vector3(getElementPosition(v))
            if getDistanceBetweenPoints3D(spawnPos, pos) < 5 then clear = false break end
        end
        if clear then freeResp = i end
    end

    return freeResp
end

-- Payment
function Courier:payForDrive()
    local payment = self:calculatePayment()
    local paymentType = exports.TR_jobs:getPlayerJobPaymentType()

    exports.TR_jobPayments:giveJobPayment(payment, paymentType, getResourceName(getThisResource()))
end

function Courier:calculatePayment()
    local addMin, addMax = 0, 0
    for i, v in pairs(jobSettings.upgrades) do
        if self.ownedUpgrades[i] and v.additionalMoney then
            addMin = addMin + v.additionalMoney[1]
            addMax = addMax + v.additionalMoney[2]
        end
    end
    local toPay = math.min(exports.TR_jobs:getPaymentCount(guiInfo.hourEarning[1] + addMin, guiInfo.hourEarning[2] + addMax), guiInfo.maxEarning + (addMin + addMax)/2)
    return self.roadTable[self.deliveryPoint].delayed and (toPay/2) or toPay
end

function Courier:getPointFromDistanceRotation(x, y, dist, angle)
    local a = math.rad(90 - angle);
    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;
    return x+dx, y+dy;
end

function Courier:getPosition(element, vec)
	local rot = Vector3(getElementRotation(element))
	local mat = Matrix(Vector3(getElementPosition(element)), rot)
	local newPos = mat:transformPosition(vec)
	return newPos.x, newPos.y, newPos.z
end

function Courier:generateZones(roadTable)
    local time = getRealTime()

    local timeAdd = 1
    for i, v in pairs(roadTable) do
        timeAdd = timeAdd + math.ceil(v.dist/500)

        local delvieryTime = self:getDeliveryTime(time, timeAdd)
        v.zone = getZoneName(v.pos)
        v.delvieryTime = delvieryTime
    end

    return roadTable
end

function Courier:destroyBox()
    if not self.carryingBox then return end

    setPedAnimation(localPlayer, "carry", "putdwn")
    triggerServerEvent("syncAnim", resourceRoot, "carry", "putdwn")
    setElementData(localPlayer, "blockAnim", false, false)

    setTimer(setPedAnimation, 1100, 1, localPlayer, nil, nil)
    setTimer(triggerServerEvent, 1100, 1, "syncAnim", resourceRoot, nil, nil)
    setTimer(triggerServerEvent, 500, 1, "removeAttachedObject", resourceRoot, 1271)
    self:setControls(true)

    self.carryingBox = nil
end

function Courier:getBoxFromVehicle()
    if self.carryingBox then return end
    self.carryingBox = true
    triggerServerEvent("attachObjectToBone", resourceRoot, 1271, 0.7, 11, -0.2, 0.2, 0.2, 280, 80, 90)

    -- triggerServerEvent("syncAnim", resourceRoot, "CARRY", "crry_prtial", 1, true)
    setPedAnimation(localPlayer, "CARRY", "crry_prtial", 1, true)
    setElementData(localPlayer, "blockAnim", true, false)

    self:setControls(false)

    return true
end

function Courier:setControls(state)
    toggleControl("crouch", state)
    toggleControl("sprint", state)
    toggleControl("jump", state)

    if not self.ownedUpgrades[1] then
        toggleControl("walk", state)
        setPedControlState(localPlayer, "walk", not state)
    end
    exports.TR_hud:blockPlayerSprint(not state)

    exports.TR_dx:setOpenGUI(not state)
end

function Courier:canTakeBoxFromVehicle(vehicle)
    if not self.markers then return false end
    if not self.markers.deliveryBox then return false end

    local plrPos = Vector3(getElementPosition(localPlayer))
    local vehPos = Vector3(getElementPosition(vehicle))
    local _, _, rot = getElementRotation(vehicle)
    local x, y = self:getPointFromDistanceRotation(vehPos.x, vehPos.y, -4, -rot)

    if getDistanceBetweenPoints2D(plrPos.x, plrPos.y, x, y) > 2 then
        return false
    end
    if getDistanceBetweenPoints3D(plrPos, Vector3(getElementPosition(self.markers.deliveryBox))) >= 30 then
        return false
    end
    return true
end

function Courier:getDeliveryTime(time, add)
    local minute, hour = time.minute + add, time.hour
    if minute >= 60 then
        minute = minute - 60
        hour = hour + 1
    end
    if hour >= 24 then
        hour = hour - 24
    end
    return {hour, minute}
end

function Courier:getPointFromDistanceRotation(x, y, dist, angle)
    local a = math.rad(90 - angle);
    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;
    return x+dx, y+dy;
end

function Courier:getBestRoad(roadTable)
    local bestRoad = {}
    local startPos = Vector3(getElementPosition(localPlayer))

    while #roadTable ~= 0 do
        local closestDist, closestIndex = 9999999, false

        for i, v in pairs(roadTable) do
            local dist = getDistanceBetweenPoints2D(v.pos.x, v.pos.y, startPos.x, startPos.y)
            if dist <= closestDist then
                closestDist = dist
                closestIndex = i
            end
        end

        if closestIndex then
            startPos = roadTable[closestIndex].pos

            table.insert(bestRoad, roadTable[closestIndex])
            bestRoad[#bestRoad].dist = closestDist

            table.remove(roadTable, closestIndex)
            closestDist = 9999999
            closestIndex = false
        end
    end

    return bestRoad
end



function startJob(...)
    if jobSettings.work then return end
    jobSettings.work = Courier:create(...)
end

function endJob()
    exports.TR_jobs:responseJobWindow()

    if not jobSettings.work then return end
    jobSettings.work:destroy()
end

function canTakeBoxFromVehicle(...)
    if not jobSettings.work then return false end
    return jobSettings.work:canTakeBoxFromVehicle(...)
end

function getBoxFromVehicle(...)
    if not jobSettings.work then return false end
    return jobSettings.work:getBoxFromVehicle(...)
end

-- startJob({})

-- Shortest way
-- local positions = {
--     Vector3(153, 0, 1),
--     Vector3(27, 0, 1),
--     Vector3(1894, 0, 1),
--     Vector3(876, 0, 1),
--     Vector3(678, 0, 1),
--     Vector3(74834, 0, 1),
--     Vector3(1894, 0, 1),
--     Vector3(87678, 0, 1),
-- }



-- local bestRoad = getBestRoad(positions)

-- print(inspect(bestRoad))


local roadTable = {
    {
        pos = Vector3(1338.109375, 1932.1484375, 11.4609375),
        delvieryTime = {14, 0},
        zone = "Test Konumu",
    },
    {
        pos = Vector3(1364.619140625, 1933.5595703125, 11.468292236328),
        delvieryTime = {14, 0},
        zone = "Test Konumu",
        delivered = true,
    },
    {
        pos = Vector3(1408.4658203125, 1918.2138671875, 11.46875),
        delvieryTime = {14, 0},
        zone = "Test Konumu",
        delayed = true,
        delivered = true,
    },
    {
        pos = Vector3(1407.4130859375, 1899.1376953125, 11.4609375),
        delvieryTime = {1, 29},
        zone = "Test Konumu",
    },
}