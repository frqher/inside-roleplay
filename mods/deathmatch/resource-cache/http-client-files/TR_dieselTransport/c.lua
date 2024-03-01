local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    vehDmg = {
        x = sx - 300/zoom + (300/zoom - 192/zoom)/2,
        y = (sy - 102/zoom)/2 + 30/zoom,
        w = 192/zoom,
        h = 102/zoom,
    },

    fuelDelivery = {
        Vector3(-2446.1899, 988.861, 44.622),
        Vector3(-1451.405, 1876.139, 31.958),
        Vector3(-1326.432, 2699.504, 49.388),
        Vector3(660.445, 1698.168, 6.513),
        Vector3(2099.314, 945.320, 10.145),
        Vector3(2655.48, 1081.186, 10.145),
        Vector3(1385.078, 473.40201, 19.422),
        Vector3(999.04102, -911.57599, 41.653),
        Vector3(-71.558, -1177.44, 1.139),
        Vector3(-2231.4131, -2568.062, 31.247),
    },

    vehicleSpawns = {
        Vector3(2706.6787109375, 2710.642578125, 10.8203125),
        Vector3(2712.6787109375, 2710.642578125, 10.8203125),
        Vector3(2718.6787109375, 2710.642578125, 10.8203125),
        Vector3(2724.6787109375, 2710.642578125, 10.8203125),
        Vector3(2730.6787109375, 2710.642578125, 10.8203125),
        Vector3(2736.6787109375, 2710.642578125, 10.8203125),
        Vector3(2742.6787109375, 2710.642578125, 10.8203125),
    },

    oilPositions = {
        Vector3(639.54296875, 1470.8193359375, 20.802816390991),
        Vector3(615.013671875, 1353.8525390625, 24.156204223633),
        Vector3(434.08203125, 1549.22265625, 23.556205749512),
        Vector3(526.2314453125, 1488.1796875, 15.74167633056),
        Vector3(491.74688720703, 1403.513671875, 16.856204986572),
    },

    hourEarning = {4600, 4700},
    maxEarning = 2400,
}

FuelDelivery = {}
FuelDelivery.__index = FuelDelivery

function FuelDelivery:create(...)
    local instance = {}
    setmetatable(instance, FuelDelivery)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function FuelDelivery:constructor(...)
    -- self.baseCol = createColPolygon(guiInfo.baseCol[1], guiInfo.baseCol[2], unpack(guiInfo.baseCol))
    self.markers = {}
    self.blips = {}
    self.ownedUpgrades = arg[1]

    self.inTank = 0
    self.pumpSpeed = self.ownedUpgrades[1] and 0.003 or 0.001
    self.maxInTank = self.ownedUpgrades[3] and 20 or 10

    self.fonts = {}
    self.fonts.percent = exports.TR_dx:getFont(11)

    self.trailerImg = dxCreateTexture("files/images/trailer.png", "argb", true, "clamp")

    self.func = {}
    self.func.render = function() self:render() end
    self.func.onRestore = function() self:onRestore() end
    self.func.onMinimalize = function() self:onMinimalize() end

    if self:createJobVehicle() then return end
    exports.TR_noti:create("Akaryakıt taşıyıcı olarak işe başladınız.", "job")
    exports.TR_weather:setCustomWeather(false)
    exports.TR_hud:setRadarCustomLocation(false)
    exports.TR_jobs:closeJobWindow()

    self:startJob()

    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientRestore", root, self.func.onRestore)
    addEventHandler("onClientMinimize", root, self.func.onMinimalize)
    return true
end

function FuelDelivery:onRestore()
    self.minimalize = nil
end

function FuelDelivery:onMinimalize()
    self.minimalize = true
end

function FuelDelivery:destroy()
    exports.TR_jobs:resetPaymentTime()
    exports.TR_jobs:setPlayerJob(false)
    exports.TR_jobs:removeInformation()
    exports.TR_jobs:setPlayerTargetPos(false)
    exports.TR_noti:create("İşinizi başarıyla tamamladınız.", "job")
    self:removeMarkers()

    setElementData(localPlayer, "inJob", nil)
    removeEventHandler("onClientRender", root, self.func.render)
    removeEventHandler("onClientRestore", root, self.func.onRestore)
    removeEventHandler("onClientMinimize", root, self.func.onMinimalize)

    triggerServerEvent("removeAttachedObject", resourceRoot, 456)

    if isElement(self.trailerImg) then destroyElement(self.trailerImg) end

    jobSettings.work = nil
    self = nil
end

function FuelDelivery:removeMarkers()
    for i, v in pairs(self.blips) do
        destroyElement(v)
    end

    for i, v in pairs(self.markers) do
        destroyElement(v)
    end

    self.markers = {}
    self.blips = {}
end

function FuelDelivery:startJob()
    self:removeMarkers()

    for i, v in pairs(guiInfo.oilPositions) do
        local blip = createBlip(v, 0, 1, 255, 60, 60, 255)
        setElementData(blip, "icon", 22, false)
        table.insert(self.blips, blip)
    end

    self.state = "loadOil"

    guiInfo.vehDmg.y = (sy - 102/zoom)/2 + 30/zoom
    exports.TR_jobs:resetPaymentTime()
    exports.TR_jobs:createInformation(jobSettings.name, "Drive to the oil well, pull out the hose from your tanker, and connect to the refinery to fill your tank.", guiInfo.vehDmg.h)
    exports.TR_jobs:setPlayerTargetPos(495.7109375, 1421.2158203125, 3.7537870407104, 0, 0, "Fill the tanker")
    exports.TR_hud:findBestWay(495.7109375, 1421.2158203125)

    exports.TR_jobs:setPaymentTime()
end

function FuelDelivery:insertFuel()
    if self.minimalize then return end
    if getElementData(localPlayer, "hoseEndPos") then
        if self.state == "loadOil" then
            if isElement(self.valve) then
                if getElementData(self.valve, "removeValve") or getElementData(self.valve, "fuelValve") then return end
            end
            self.inTank = math.min(self.inTank + self.pumpSpeed, self.maxInTank)

            if self.inTank == self.maxInTank then
                self.state = "unloadOil"

                guiInfo.vehDmg.y = (sy - 102/zoom)/2 + 20/zoom
                self:removeMarkers()
                exports.TR_jobs:createInformation(jobSettings.name, "Depoya dönerek toplanan petrolü boşaltın ve benzin yükleyin.", guiInfo.vehDmg.h)
                exports.TR_jobs:setPlayerTargetPos(2695.478515625, 2743.9921875, 11.5203125, 0, 0, "Tankeri boşalt")
                exports.TR_hud:findBestWay(2492.8544921875, 2773.298828125)

                local blip = createBlip(2695.478515625, 2743.9921875, 11.5203125, 0, 1, 255, 60, 60, 255)
                setElementData(blip, "icon", 22, false)
                table.insert(self.blips, blip)
            end

        elseif self.state == "unloadOil" then
            if not isElement(self.valve) then return end
            if not getElementData(self.valve, "removeValve") then return end

            self.inTank = math.max(self.inTank - self.pumpSpeed, 0)

            if self.inTank == 0 then
                self.state = "loadingFuel"
                guiInfo.vehDmg.y = (sy - 102/zoom)/2 + 13/zoom
                exports.TR_jobs:createInformation(jobSettings.name, "Benzin dolumu devam ediyor...", guiInfo.vehDmg.h)
                exports.TR_jobs:setPlayerTargetPos(false)
            end

        elseif self.state == "loadingFuel" then
            if not isElement(self.valve) then return end
            if not getElementData(self.valve, "removeValve") then return end

            self.inTank = math.min(self.inTank + self.pumpSpeed, self.maxInTank)

            if self.inTank == self.maxInTank then
                self:findNextDeliveryPoint()
            end

        elseif self.state == "deliveryFuel" then
            if not isElement(self.valve) then return end
            if not getElementData(self.valve, "fuelValve") then return end

            self.inTank = math.max(self.inTank - self.pumpSpeed, 0)

            if self.inTank == 0 then
                self:payForDrive()
                self:startJob()
            end
        end
    end
end

function FuelDelivery:findNextDeliveryPoint()
    self:removeMarkers()
    self.state = "deliveryFuel"

    local randomID = math.random(1, #guiInfo.fuelDelivery)
    while self.fuelStationID == randomID do
        randomID = math.random(1, #guiInfo.fuelDelivery)
    end
    self.fuelStationID = randomID
    local pos = guiInfo.fuelDelivery[randomID]

    local blip = createBlip(pos, 0, 1, 255, 60, 60, 255)
    setElementData(blip, "icon", 22, false)
    table.insert(self.blips, blip)

    guiInfo.vehDmg.y = (sy - 102/zoom)/2 + 30/zoom
    exports.TR_jobs:createInformation(jobSettings.name, "İstasyona gidin ve yükü boşaltın, böylece pompalardan taze benzin akabilir.", guiInfo.vehDmg.h)
    exports.TR_jobs:setPlayerTargetPos(pos.x, pos.y, pos.z + 1, 0, 0, "Benzin Teslim Et")
    exports.TR_hud:findBestWay(pos.x, pos.y)
end

function FuelDelivery:render()
    self:insertFuel()

    local percent = math.max(self.inTank/self.maxInTank, 0)
    dxDrawImage(guiInfo.vehDmg.x, guiInfo.vehDmg.y, guiInfo.vehDmg.w, guiInfo.vehDmg.h, self.trailerImg, 0, 0, 0, tocolor(47, 47, 47, 255))
    dxDrawImageSection(guiInfo.vehDmg.x, guiInfo.vehDmg.y + guiInfo.vehDmg.h - guiInfo.vehDmg.h * percent, guiInfo.vehDmg.w, guiInfo.vehDmg.h * percent, 0, 102 - 102 * percent, 192, 102 * percent, self.trailerImg, 0, 0, 0, tocolor(117, 111, 49, 255))
    dxDrawText(string.format("%.1f%%", 100 * percent), guiInfo.vehDmg.x, guiInfo.vehDmg.y, guiInfo.vehDmg.x + guiInfo.vehDmg.w - 15/zoom, guiInfo.vehDmg.y + guiInfo.vehDmg.h - 20/zoom, tocolor(170, 170, 170, 255), 1/zoom, self.fonts.percent, "center", "center")
end

function FuelDelivery:createJobVehicle()
    local respIndex = self:getFreeRespawn()
    if not respIndex then
        exports.TR_noti:create("Park yerinde boş bir alan yok. Boş bir alan açılmasını bekleyin.", "error")
        exports.TR_jobs:responseJobWindow(true)
        self:destroy()
        return true
    end

    local pos = guiInfo.vehicleSpawns[respIndex]
    triggerServerEvent("createDieselTransportVehicle", resourceRoot, {pos.x, pos.y, pos.z}, self.ownedUpgrades[2])
    exports.TR_jobs:responseJobWindow()

    -- self:createLoadingPoints()
end

function FuelDelivery:getFreeRespawn()
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
function FuelDelivery:payForDrive()
    local payment = self:calculatePayment()
    local paymentType = exports.TR_jobs:getPlayerJobPaymentType()

    exports.TR_jobPayments:giveJobPayment(payment, paymentType, getResourceName(getThisResource()))
end

function FuelDelivery:calculatePayment()
    local addMin, addMax = 0, 0
    for i, v in pairs(jobSettings.upgrades) do
        if self.ownedUpgrades[i] and v.additionalMoney then
            addMin = addMin + v.additionalMoney[1]
            addMax = addMax + v.additionalMoney[2]
        end
    end
    return math.min(exports.TR_jobs:getPaymentCount(guiInfo.hourEarning[1] + addMin, guiInfo.hourEarning[2] + addMax), guiInfo.maxEarning + (addMin + addMax)/2)
end

function FuelDelivery:canUnloadOil(...)
    self.valve = arg[1]
    return self.state == "unloadOil" or self.state == "loadingFuel" or self.state == "deliveryFuel"
end

function FuelDelivery:canLoadFuel(...)
    self.valve = arg[1]
    if self.state ~= "deliveryFuel" then return false end
    local valveID = getElementData(arg[1], "fuelValve")
    if not valveID then return false end

    if valveID == self.fuelStationID then return true end
end

function FuelDelivery:getPointFromDistanceRotation(x, y, dist, angle)
    local a = math.rad(90 - angle);
    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;
    return x+dx, y+dy;
end

function FuelDelivery:getPosition(element, vec)
	local rot = Vector3(getElementRotation(element))
	local mat = Matrix(Vector3(getElementPosition(element)), rot)
	local newPos = mat:transformPosition(vec)
	return newPos.x, newPos.y, newPos.z
end



function startJob(...)
    if jobSettings.work then return end
    jobSettings.work = FuelDelivery:create(...)
end

function endJob()
    exports.TR_jobs:responseJobWindow()

    if not jobSettings.work then return end
    jobSettings.work:destroy()
end

function canUnloadOil(...)
    if not jobSettings.work then return false end
    return jobSettings.work:canUnloadOil(...)
end

function canLoadFuel(...)
    if not jobSettings.work then return false end
    return jobSettings.work:canLoadFuel(...)
end

function getPointFromDistanceRotation(x, y, dist, angle)
	local a = math.rad(90 - angle)
	local dx = math.cos(a) * dist
	local dy = math.sin(a) * dist
	return x + dx, y + dy
end

-- startJob({})
-- exports.TR_jobs:createInformation(jobSettings.name, string.format("Udaj się do %s aby dostarczyć kontener.\nUszkodzenia ładunku:", "Market Vinience Station"), guiInfo.vehDmg.h)
-- local trailer = dxCreateTexture("files/images/trailer.png", "argb", true, "clamp")
-- local percentFont = exports.TR_dx:getFont(12)
-- local testHP = 1000
-- function render()
--     testHP = testHP - 1
--     local percent = math.min((1000 - testHP)/1000, 1)

--     dxDrawImage(guiInfo.vehDmg.x, guiInfo.vehDmg.y, guiInfo.vehDmg.w, guiInfo.vehDmg.h, trailer, 0, 0, 0, tocolor(47, 47, 47, 255))
--     dxDrawImageSection(guiInfo.vehDmg.x, guiInfo.vehDmg.y + guiInfo.vehDmg.h - guiInfo.vehDmg.h * percent, guiInfo.vehDmg.w, guiInfo.vehDmg.h * percent, 0, 68 - 68 * percent, 128, 68 * percent, trailer, 0, 0, 0, tocolor(124, 0, 0, 255))
--     dxDrawText(string.format("%.1f%%", 100 * percent), guiInfo.vehDmg.x, guiInfo.vehDmg.y, guiInfo.vehDmg.x + guiInfo.vehDmg.w, guiInfo.vehDmg.y + guiInfo.vehDmg.h - 20/zoom, tocolor(170, 170, 170, 255), 1/zoom, percentFont, "center", "center")
-- end
-- addEventHandler("onClientRender", root, render)

-- setCameraTarget(localPlayer)
-- setElementFrozen(localPlayer, false)
-- triggerServerEvent("setContainerFrozen", resourceRoot, veh, false)
-- toggleControl("accelerate", true)
-- toggleControl("brake_reverse", true)
-- toggleControl("enter_exit", true)