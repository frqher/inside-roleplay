local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    vehDmg = {
        x = sx - 300/zoom + (300/zoom - 128/zoom)/2,
        y = (sy - 68/zoom)/2 + 30/zoom,
        w = 128/zoom,
        h = 68/zoom,
    },

    marker = {
        size = 2.2,
    },

    containers = {3571, 3572, 3570, 3565},

    loadingPoints = {
        {
            pos = Vector3(-1834.8408203125, 114.69, 15.1171875),
            rot = 0,
        },
        {
            pos = Vector3(-1843.5263671875, 114.69, 15.1171875),
            rot = 0,
        },
        {
            pos = Vector3(-1852.2626953125, 114.69, 15.1171875),
            rot = 0,
        },
        {
            pos = Vector3(-1860.9345703125, 114.69, 15.1171875),
            rot = 0,
        },
    },

    vehicleSpawns = {
        Vector3(-1827, 167.5, 15.1171875),
        Vector3(-1832, 167.5, 15.1171875),
        Vector3(-1837, 167.5, 15.1171875),
        Vector3(-1842, 167.5, 15.1171875),
    },

    baseCol = {-1820.09, 173.34, -1817.57, 114.09, -1817.23, 12.34, -1817.49, -26.02, -1864.50, -26.15, -1863.32, 109.24, -1863.50, 133.04, -1855.26, 172.79},
    hourEarning = {4200, 4350},
    maxEarning = 1180,
}

Containers = {}
Containers.__index = Containers

function Containers:create(...)
    local instance = {}
    setmetatable(instance, Containers)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function Containers:constructor(...)
    self.baseCol = createColPolygon(guiInfo.baseCol[1], guiInfo.baseCol[2], unpack(guiInfo.baseCol))
    self.markers = {}
    self.blips = {}
    self.move = 0
    self.ownedUpgrades = arg[1]

    self.checkTimerTick = getTickCount()

    self.fonts = {}
    self.fonts.percent = exports.TR_dx:getFont(12)

    self.zoneImg = dxCreateTexture("files/images/zone.png", "argb", true, "clamp")
    self.trailerImg = dxCreateTexture("files/images/trailer.png", "argb", true, "clamp")

    self.func = {}
    self.func.render = function() self:render() end

    self.func.createLoadingPoints = function() self:createLoadingPoints() end
    self.func.hitLoadingPoint = function(...) self:hitLoadingPoint(source, ...) end
    self.func.handleVehicleDamage = function(...) self:handleVehicleDamage(source, ...) end
    self.func.onColshapeBackHit = function(...) self:onColshapeBackHit(...) end
    self.func.onColshapeBackLeave = function(...) self:onColshapeBackLeave(...) end

    if self:createJobVehicle() then return end

    exports.TR_jobs:resetPaymentTime()
    exports.TR_noti:create("Konteyner taşıyıcısı olarak işe başladınız.", "job")
    exports.TR_jobs:createInformation(jobSettings.name, "Konteyneri paketleyerek depoya git.")
    exports.TR_weather:setCustomWeather(false)
    exports.TR_hud:setRadarCustomLocation(false)
    exports.TR_jobs:closeJobWindow()

    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientVehicleCollision", root, self.func.handleVehicleDamage)

    addEventHandler("onClientColShapeHit", self.baseCol, self.func.onColshapeBackHit)
    addEventHandler("onClientColShapeLeave", self.baseCol, self.func.onColshapeBackLeave)
    return true
end

function Containers:destroy()
    exports.TR_jobs:resetPaymentTime()
    exports.TR_weather:setCustomWeather(0, 12, 0, 9999)
    exports.TR_hud:setRadarCustomLocation("Bina İçi | Konteyner Teslimatı", true)
    exports.TR_jobs:setPlayerJob(false)
    exports.TR_jobs:removeInformation()
    exports.TR_jobs:setPlayerTargetPos(false)
    exports.TR_noti:create("İşinizi başarıyla tamamladınız.", "job")
    self:removeMarkers()

    removeEventHandler("onClientRender", root, self.func.render)
    removeEventHandler("onClientVehicleCollision", root, self.func.handleVehicleDamage)
    removeEventHandler("onClientColShapeHit", self.baseCol, self.func.onColshapeBackHit)
    removeEventHandler("onClientColShapeLeave", self.baseCol, self.func.onColshapeBackLeave)

    triggerServerEvent("removePlayerFromJobVehicle", resourceRoot, 1929.1437988281, -1109.3912353516, 137.62031555176, 5, 5)
    triggerServerEvent("removeAttachedObject", resourceRoot, 455)
    if self.containerModel then triggerServerEvent("removeAttachedObject", resourceRoot, self.containerModel) end
    if isElement(self.zoneImg) then destroyElement(self.zoneImg) end
    if isElement(self.trailerImg) then destroyElement(self.trailerImg) end
    if isElement(self.baseCol) then destroyElement(self.baseCol) end

    jobSettings.work = nil
    self = nil
end

function Containers:removeMarkers()
    for i, v in pairs(self.blips) do
        destroyElement(v)
    end

    for i, v in pairs(self.markers) do
        destroyElement(v)
    end

    self.markers = {}
    self.blips = {}
end

function Containers:createDeliveryPoint()
    local selected = self.nextPointPosition
    guiInfo.marker.angle = selected[4]
    guiInfo.marker.defPos = Vector3(selected[1], selected[2], selected[3])

    local fx, fy = getPointFromDistanceRotation(guiInfo.marker.defPos.x, guiInfo.marker.defPos.y, -guiInfo.marker.size, -guiInfo.marker.angle + 90)
    local bx, by = getPointFromDistanceRotation(guiInfo.marker.defPos.x, guiInfo.marker.defPos.y, guiInfo.marker.size, -guiInfo.marker.angle + 90)
    guiInfo.marker.front = Vector3(fx, fy, guiInfo.marker.defPos.z - 0.9)
    guiInfo.marker.back = Vector3(bx, by, guiInfo.marker.defPos.z - 0.9)

    self.isDelivery = true
    self.containerHealth = 1000
    self.targetDistance = getDistanceBetweenPoints3D(guiInfo.marker.defPos, Vector3(getElementPosition(localPlayer)))

    local blip = createBlip(guiInfo.marker.defPos, 0, 1, 255, 60, 60, 255)
    setElementData(blip, "icon", 22, false)

    table.insert(self.markers, marker)
    table.insert(self.blips, blip)

    exports.TR_jobs:setPaymentTime()
    exports.TR_jobs:createInformation(jobSettings.name, string.format("Konteyneri müşteriye en iyi durumda teslim et.\n Yük hasarı:"), 80/zoom)
    exports.TR_jobs:setPlayerTargetPos(guiInfo.marker.defPos.x, guiInfo.marker.defPos.y, guiInfo.marker.defPos.z - 2, 0, 0, "Konteyneri müşteriye teslim et")
    exports.TR_hud:findBestWay(guiInfo.marker.defPos.x, guiInfo.marker.defPos.y)

    setElementFrozen(localPlayer, false)
    local veh = getPedOccupiedVehicle(localPlayer)
    if veh then setElementFrozen(veh, false) end
    triggerServerEvent("setContainerFrozen", resourceRoot, veh, false)
end

function Containers:createLoadingPoints()
    self.markers = {}
    self.blips = {}

    for i, v in pairs(guiInfo.loadingPoints) do
        local marker = createMarker(v.pos.x, v.pos.y, v.pos.z - 0.9, "cylinder", 2, 255, 60, 60, 0)
        setElementData(marker, "markerData", {
            title = "Yükleme Noktası",
            desc = "Konteynere yüklemek için arka taraftan girin.",
        }, false)
        setElementData(marker, "markerIcon", "truck", false)
        setElementData(marker, "markerRot", v.rot, false)

        addEventHandler("onClientMarkerHit", marker, self.func.hitLoadingPoint)
        table.insert(self.markers, marker)

        local blip = createBlip(v.pos, 0, 1, 255, 60, 60, 255)
        setElementData(blip, "icon", 22, false)

        table.insert(self.blips, blip)
    end

    exports.TR_jobs:setPlayerTargetPos(-1847.65625, 107.9453125, 14.96875, 0, 0, "Depoya konteyner yükle")
    setElementFrozen(localPlayer, false)
    local veh = getPedOccupiedVehicle(localPlayer)
    if veh then setElementFrozen(veh, false) end
    triggerServerEvent("setContainerFrozen", resourceRoot, veh, false)
end

function Containers:onColshapeBackLeave(el, md)
    if getElementType(el) ~= "vehicle" or not md then return end
    if getElementModel(el) ~= 455 then return end
    local driver = getVehicleOccupant(el, 0)
    if not driver then return end
    if driver ~= localPlayer then return end
end

function Containers:onColshapeBackHit(el, md)
    if getElementType(el) ~= "vehicle" or not md then return end
    if getElementModel(el) ~= 455 then return end
    local driver = getVehicleOccupant(el, 0)
    if not driver then return end
    if driver ~= localPlayer then return end

    if not self.goBack then return end

    self:payForDrive()
    self.goBack = nil
end

function Containers:hitLoadingPoint(source, ...)
    if arg[1] ~= localPlayer then return end

    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return end
    if getElementModel(veh) ~= 455 then return end

    local _, _, vehRot = getElementRotation(veh)
    -- local rot = getElementData(source, "markerRot")

    if vehRot >= 355 or vehRot < 5 then
        if self.panel then return end
        if not exports.TR_dx:canOpenGUI() then return end

        setElementFrozen(localPlayer, true)
        setElementFrozen(veh, true)
        triggerServerEvent("setContainerFrozen", resourceRoot, veh, true)

        self.panel = TargetPanel:create(self.ownedUpgrades[2], veh, rot)
        return
    end
    exports.TR_noti:create("Konteynerleri yüklemek için aracınızı kapıya doğru çevirin.", "error")
end

function Containers:loadVehicle(nextPoint, veh, rot)
    self.nextPointPosition = nextPoint

    self.panel = nil
    self:setLoadingAnim(veh, rot)
end


function Containers:isInPlace()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return false end
    if getElementModel(veh) ~= 455 then return end

    local _, _, vehRot = getElementRotation(veh)

    if guiInfo.marker.angle == 0 then
        if vehRot < 4 or vehRot > 356 then
            return true
        end
        return false
    end

    local minRot = guiInfo.marker.angle - 4
    local maxRot = guiInfo.marker.angle + 4
    minRot = minRot < 0 and minRot + 360 or minRot
    maxRot = maxRot > 360 and maxRot - 360 or maxRot

    local _, _, vehRot = getElementRotation(veh)

    if minRot < maxRot then
        if vehRot >= minRot and vehRot <= maxRot then
            return true
        end

    elseif minRot > maxRot then
        if vehRot <= minRot and vehRot >= maxRot then
            return true
        end
    end
    return false
end

function Containers:hitUnloadingPoint()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return end
    if getElementModel(veh) ~= 455 then return end

    if self:isInPlace() then
        if not isElementFrozen(veh) then
            exports.TR_noti:create("Yükü bırakmak için el frenini çekin.", "info")
            return
        end

        self:setUnloadingAnim(veh)
        guiInfo.marker.angle = nil
        return
    end

    exports.TR_noti:create("Kamyonu boşaltmak için konteyneri vincin kancasının altına yerleştirmeniz gerekmektedir.", "error")
end



function Containers:setLoadingAnim(veh, rot)
    if self.tick then return end

    self.animType = "loading"
    self.tick = getTickCount()

    self.vehPos = Vector3(getElementPosition(veh))
    self.vehRot = Vector3(getElementRotation(veh))
    self.containerModel = guiInfo.containers[math.random(1, #guiInfo.containers)]
    self.containerPos = Vector3(getVehicleComponentPosition(veh, "container", "world"))
    self.cameraPos = Vector3(self:getPosition(veh, Vector3(3, -5, 1.5)))
    self.cameraTarget = Vector3(self.vehPos.x, self.vehPos.y, self.vehPos.z + 1)
    self.movement = -10

    setPedControlState(localPlayer, "accelerate", true)
    setPedControlState(localPlayer, "brake_reverse", false)
    toggleControl("accelerate", false)
    toggleControl("brake_reverse", false)
    toggleControl("enter_exit", false)
    setTimer(setPedControlState, 100, 1, localPlayer, "accelerate", false)

    local x, y = self:getPointFromDistanceRotation(self.containerPos.x, self.containerPos.y, self.movement, self.vehRot.z)
    self.container = createObject(self.containerModel, self.vehPos.x, self.vehPos.y, self.vehPos.z + 15, self.vehRot.y, self.vehRot.x, self.vehRot.z - 90)
    setObjectScale(self.container, 0.63, 1.1, 0.9)
    setElementCollisionsEnabled(self.container, false)

    self:removeMarkers()

    exports.TR_jobs:createInformation(jobSettings.name, "Araç üzerine konteyner yükleniyor.")
end

function Containers:setUnloadingAnim(veh)
    if self.tick then return end
    self.blockDmgRender = true

    triggerServerEvent("removeAttachedObject", resourceRoot, self.containerModel)

    setElementFrozen(localPlayer, true)
    setElementFrozen(veh, true)
    triggerServerEvent("setContainerFrozen", resourceRoot, veh, true)

    self.animType = "unloading"
    self.tick = getTickCount()

    self.vehPos = Vector3(getElementPosition(veh))
    self.vehRot = Vector3(getElementRotation(veh))
    self.containerModel = guiInfo.containers[math.random(1, #guiInfo.containers)]
    self.containerPos = Vector3(getVehicleComponentPosition(veh, "container", "world"))
    self.cameraPos = Vector3(self:getPosition(veh, Vector3(3, -7, 1.5)))
    self.cameraTarget = Vector3(self.vehPos.x, self.vehPos.y, self.vehPos.z + 1)

    setPedControlState(localPlayer, "accelerate", true)
    setPedControlState(localPlayer, "brake_reverse", false)
    toggleControl("accelerate", false)
    toggleControl("brake_reverse", false)
    toggleControl("enter_exit", false)
    setTimer(setPedControlState, 100, 1, localPlayer, "accelerate", false)

    self.container = createObject(self.containerModel, self.containerPos.x, self.containerPos.y, self.containerPos.z, self.vehRot.y + 180, self.vehRot.x, self.vehRot.z + 90)
    setObjectScale(self.container, 0.63, 1.1, 0.9)
    setElementCollisionsEnabled(self.container, false)

    self:removeMarkers()
    exports.TR_jobs:createInformation(jobSettings.name, "Aracın konteynerinden boşaltma işlemi devam ediyor.")
    self.goBack = true
end

function Containers:stopAnim()
    local veh = getPedOccupiedVehicle(localPlayer)

    if self.animType == "loading" then
        triggerServerEvent("attachContainerToVehicle", resourceRoot, veh, self.containerModel)
        self:createDeliveryPoint()

    elseif self.animType == "unloading" then
        self:createLoadingPoints()
        exports.TR_jobs:createInformation(jobSettings.name, "Rotayı tamamlamak ve ödülünü almak için üsse geri dön.")
        exports.TR_hud:findBestWay(-1815.716796875, 163.4716796875)

        self.isDelivery = nil
        self.containerHealth = nil
        self.targetDistance = nil
    end

    self.tick = nil
    self.animType = nil

    self.blockDmgRender = nil

    toggleControl("accelerate", true)
    toggleControl("brake_reverse", true)
    toggleControl("enter_exit", true)

    setCameraTarget(localPlayer)

    if isElement(self.container) then
        destroyElement(self.container)
    end
end




function Containers:animate()
    if not self.tick then return true end

    if self.animType == "loading" then
        local progress = (getTickCount() - self.tick)/10000
        self.move = interpolateBetween(self.movement, 0, 0, 0, 0, 0, progress, "Linear")

        local x, y = self:getPointFromDistanceRotation(self.containerPos.x, self.containerPos.y, self.move, self.vehRot.z)
        setElementPosition(self.container, x, y, self.containerPos.z)
        if progress >= 1 then
            self:stopAnim()
            return true
        end

    elseif self.animType == "unloading" then
        local progress = (getTickCount() - self.tick)/10000
        self.move = interpolateBetween(0, 0, 0, 10, 0, 0, progress, "Linear")

        setElementPosition(self.container, self.containerPos.x, self.containerPos.y, self.containerPos.z + self.move)
        if progress >= 1 then
            self:stopAnim()
            return true
        end
    end
end


function Containers:renderVehicleDamage()
    if not self.containerHealth or self.blockDmgRender then return end
    local percent = (1000 - self.containerHealth)/1000

    dxDrawImage(guiInfo.vehDmg.x, guiInfo.vehDmg.y, guiInfo.vehDmg.w, guiInfo.vehDmg.h, self.trailerImg, 0, 0, 0, tocolor(47, 47, 47, 255))
    dxDrawImageSection(guiInfo.vehDmg.x, guiInfo.vehDmg.y + guiInfo.vehDmg.h - guiInfo.vehDmg.h * percent, guiInfo.vehDmg.w, guiInfo.vehDmg.h * percent, 0, 68 - 68 * percent, 128, 68 * percent, self.trailerImg, 0, 0, 0, tocolor(124, 0, 0, 255))
    dxDrawText(string.format("%.1f%%", 100 * percent), guiInfo.vehDmg.x, guiInfo.vehDmg.y, guiInfo.vehDmg.x + guiInfo.vehDmg.w, guiInfo.vehDmg.y + guiInfo.vehDmg.h - 20/zoom, tocolor(170, 170, 170, 255), 1/zoom, self.fonts.percent, "center", "center")
end

function Containers:render()
    self:renderVehicleDamage()
    self:renderMarker()

    if self:animate() then return end
    setCameraMatrix(self.cameraPos, self.cameraTarget)
end

function Containers:renderMarker()
    if not guiInfo.marker.angle then return end

    local color = {255, 255, 255}
    if getDistanceBetweenPoints3D(Vector3(getElementPosition(localPlayer)), guiInfo.marker.defPos) < 3 then
        if self:isInPlace() then
            color = {54, 173, 58}
        end

        if (getTickCount() - self.checkTimerTick)/5000 > 1 then
            self:hitUnloadingPoint()

            self.checkTimerTick = getTickCount()
        end
    end

    dxDrawMaterialLine3D(guiInfo.marker.front, guiInfo.marker.back, self.zoneImg, guiInfo.marker.size * 4.5, tocolor(color[1], color[2], color[3], 200), false, guiInfo.marker.defPos.x, guiInfo.marker.defPos.y, guiInfo.marker.defPos.z + 1)
end


function Containers:handleVehicleDamage(source, hitEl, dmg)
    if not self.isDelivery then return end
    if dmg < 280 then return end

    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return end

    if source ~= veh then return end
    if getElementModel(veh) ~= 455 then return end

    if self.hitTick then
        if (getTickCount() - self.hitTick)/1000 < 1 then return end
    end
    self.hitTick = getTickCount()

    local takeOutDmg = self.ownedUpgrades[1] and dmg/20 or dmg/10
    self.containerHealth = math.max(math.ceil(self.containerHealth - takeOutDmg), 0)
end

function Containers:createJobVehicle()
    local respIndex = self:getFreeRespawn()
    if not respIndex then
        exports.TR_noti:create("Girişte boş bir yer yok. Bir boşalana kadar bekle.", "error")
        exports.TR_jobs:responseJobWindow(true)
        self:destroy()
        return true
    end

    local pos = guiInfo.vehicleSpawns[respIndex]
    triggerServerEvent("createContainerVehicle", resourceRoot, {pos.x, pos.y, pos.z}, self.ownedUpgrades[3])
    exports.TR_jobs:responseJobWindow()

    self:createLoadingPoints()
end

function Containers:getFreeRespawn()
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
function Containers:payForDrive()
    if not self.goBack then return end
    local payment = self:calculatePayment()
    local paymentType = exports.TR_jobs:getPlayerJobPaymentType()

    exports.TR_jobPayments:giveJobPayment(payment, paymentType, getResourceName(getThisResource()))
end

function Containers:calculatePayment()
    local addMin, addMax = 0, 0
    for i, v in pairs(jobSettings.upgrades) do
        if self.ownedUpgrades[i] and v.additionalMoney then
            addMin = addMin + v.additionalMoney[1]
            addMax = addMax + v.additionalMoney[2]
        end
    end
    return math.min(exports.TR_jobs:getPaymentCount(guiInfo.hourEarning[1] + addMin, guiInfo.hourEarning[2] + addMax), guiInfo.maxEarning + (addMin + addMax)/2)
end

function Containers:getPointFromDistanceRotation(x, y, dist, angle)
    local a = math.rad(90 - angle);
    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;
    return x+dx, y+dy;
end

function Containers:getPosition(element, vec)
	local rot = Vector3(getElementRotation(element))
	local mat = Matrix(Vector3(getElementPosition(element)), rot)
	local newPos = mat:transformPosition(vec)
	return newPos.x, newPos.y, newPos.z
end



function startJob(...)
    if jobSettings.work then return end
    jobSettings.work = Containers:create(...)
end

function endJob()
    exports.TR_jobs:responseJobWindow()

    if not jobSettings.work then return end
    jobSettings.work:destroy()
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