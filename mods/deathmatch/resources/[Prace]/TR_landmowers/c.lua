local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    map = {
        x = (sx - 300/zoom),
        y = (sy - 200/zoom)/2 + 30/zoom,
        w = 300/zoom,
        h = 200/zoom,

        oW = 469,
        oH = 469,

        mower = 30/zoom,
        segmentSize = 17,

        defPos = Vector2(-2538, 718.2412109375),
        scale = 166/469,
    },

    emptyPoint = Vector3(-2408.08203125, 680.0498046875, 35.163108825684),

    mowerCapacity = 10,
    hourEarning = {2950, 3000},
    maxEarning = 105,

    zone = {-2516.2861328125, 698.1142578125, -2399.291015625, 698.3681640625, -2399.103515625, 578.5859375, -2516.4765625, 578.404296875}
}



Landmowers = {}
Landmowers.__index = Landmowers

function Landmowers:create(...)
    local instance = {}
    setmetatable(instance, Landmowers)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function Landmowers:constructor(...)
    self.capacity = 0
    self.emptyTimes = 0
    self.blockGetting = true
    self.ownedUpgrades = arg[1]

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(12)

    self.colider = createColPolygon(guiInfo.zone[1], guiInfo.zone[2], unpack(guiInfo.zone))

    self.textures = {}
    self.textures.map = dxCreateTexture("files/images/map.png", "argb", true, "clamp")
    self.textures.mower = dxCreateTexture("files/images/mower.png", "argb", true, "clamp")

    self.func = {}
    self.func.render = function() self:render() end
    self.func.emptyMarkerHit = function(...) self:emptyMarkerHit(...) end
    self.func.shapeLeave = function(...) self:shapeLeave(...) end
    self.func.onExitLandmower = function(...) self:onExitLandmower(...) end
    self.func.onEnterLandmower = function(...) self:onEnterLandmower(source, ...) end

    exports.TR_noti:create("Bahçıvan olarak işe başladınız.", "job")

    guiInfo.map.y = (sy - 200/zoom)/2 + 30/zoom
    exports.TR_jobs:createInformation(jobSettings.name, string.format("Parkta çimleri doğru yüksekliğe kesmek için çim biçme makinesiyle gezin.\n Çim kutusunun doluluğu: 0/%dl", guiInfo.mowerCapacity), guiInfo.map.h + 40/zoom)
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientColShapeLeave", self.colider, self.func.shapeLeave)
    addEventHandler("onClientVehicleStartExit", root, self.func.onExitLandmower)
    addEventHandler("onClientVehicleEnter", root, self.func.onEnterLandmower)

    triggerServerEvent("createLandmowerVehicle", resourceRoot, self.ownedUpgrades[3])

    setTimer(function()
        self.blockGetting= nil
    end, 1000, 1)
    self:createMap()
    exports.TR_jobs:setPaymentTime()
    return true
end

function Landmowers:destroy()
    exports.TR_jobs:resetPaymentTime()

    for i, v in pairs(self.textures) do
        destroyElement(v)
    end

    removeEventHandler("onClientRender", root, self.func.render)
    removeEventHandler("onClientColShapeLeave", self.colider, self.func.shapeLeave)
    removeEventHandler("onClientVehicleStartExit", root, self.func.onExitLandmower)
    removeEventHandler("onClientVehicleEnter", root, self.func.onEnterLandmower)

    triggerServerEvent("removeAttachedObject", resourceRoot, 572)

    setElementData(localPlayer, "inJob", nil)

    if isElement(self.mapTarget) then destroyElement(self.mapTarget) end
    if isElement(self.colider) then destroyElement(self.colider) end

    guiInfo.work = nil
    self = nil
end

function Landmowers:endJobForce()
    self:destroy()
    exports.TR_jobs:setPlayerJob(false)
    exports.TR_jobs:removeInformation()
    exports.TR_jobs:setPlayerTargetPos(false)
    exports.TR_noti:create("İş yerini terk ettiniz. Otomatik olarak işten çıkarıldınız.", "info")
end

function Landmowers:createMap()
    self.mapTarget = dxCreateRenderTarget(guiInfo.map.w, guiInfo.map.h, true)

    self:clearMap()
end

function Landmowers:clearMap()
    self.cols = 36
    self.rows = math.ceil(guiInfo.map.oH/guiInfo.map.segmentSize)

    self.grid = {}
    for col = 1, self.cols do
        self.grid[col] = {}
        for row = 1, self.rows do
            self.grid[col][row] = true
        end
    end
end

function Landmowers:updateMap()
    local plrPos = Vector2(getElementPosition(localPlayer))
    local posDiff = plrPos - guiInfo.map.defPos
    local mapPos = Vector2(-(posDiff.x / guiInfo.map.scale) + guiInfo.map.w/2, (posDiff.y / guiInfo.map.scale) + guiInfo.map.h/2)

    dxSetRenderTarget(self.mapTarget, true)
    dxSetBlendMode("modulate_add")
    dxDrawRectangle(mapPos.x - guiInfo.map.w, mapPos.y - guiInfo.map.h, guiInfo.map.oW + guiInfo.map.w * 2, guiInfo.map.h, tocolor(17, 17, 17, 100))
    dxDrawRectangle(mapPos.x - guiInfo.map.w, mapPos.y + guiInfo.map.oH, guiInfo.map.oW + guiInfo.map.w * 2, guiInfo.map.h, tocolor(17, 17, 17, 100))
    dxDrawRectangle(mapPos.x - guiInfo.map.w, mapPos.y, guiInfo.map.w, guiInfo.map.oH, tocolor(17, 17, 17, 100))
    dxDrawRectangle(mapPos.x + guiInfo.map.oW, mapPos.y, guiInfo.map.w, guiInfo.map.oH, tocolor(17, 17, 17, 100))

    dxDrawImage(mapPos.x, mapPos.y, guiInfo.map.oW, guiInfo.map.oH, self.textures.map)

    local nearCol, nearRow = math.ceil((plrPos.x - guiInfo.map.defPos.x)/guiInfo.map.scale/guiInfo.map.segmentSize), math.ceil((guiInfo.map.defPos.y - plrPos.y)/guiInfo.map.scale/guiInfo.map.segmentSize)
    for col = math.max(nearCol - 1, 1), nearCol + 1 do
        for row = math.max(nearRow - 1, 1), nearRow + 1 do
            if self.grid[col][row] then
                if self.capacity + 0.1 < guiInfo.mowerCapacity and not self.emptyMower and not self.blockGetting then
                    if getDistanceBetweenPoints2D(guiInfo.map.w/2, guiInfo.map.h/2, mapPos.x + (col - 1) * guiInfo.map.segmentSize + guiInfo.map.segmentSize/2, mapPos.y + (row - 1) * guiInfo.map.segmentSize + guiInfo.map.segmentSize/2) < 8 then
                        self.grid[col][row] = nil
                        self.capacity = math.min(self.capacity + (self.ownedUpgrades[1] and 0.2 or 0.1), guiInfo.mowerCapacity)

                        exports.TR_jobs:createInformation(jobSettings.name, string.format("Parkta çimleri doğru yüksekliğe biçmek için çim biçme makinesiyle gezin.\n Kapasite Doluluğu: %.1f/%dl", self.capacity, guiInfo.mowerCapacity), guiInfo.map.h + 40/zoom)
                    end
                end
            end
        end
    end

    local nearCol, nearRow = math.ceil((plrPos.x - guiInfo.map.defPos.x)/guiInfo.map.scale/guiInfo.map.segmentSize), math.ceil((guiInfo.map.defPos.y - plrPos.y)/guiInfo.map.scale/guiInfo.map.segmentSize)
    for col = math.max(nearCol - 9, 1), nearCol + 9 do
        for row = math.max(nearRow - 6, 1), nearRow + 6 do
            if self.grid[col][row] then
                dxDrawRectangle(mapPos.x + (col - 1) * guiInfo.map.segmentSize, mapPos.y + (row - 1) * guiInfo.map.segmentSize, guiInfo.map.segmentSize, guiInfo.map.segmentSize, tocolor(17, 17, 17, 100))
            end
        end
    end

    if self.capacity + 0.1 >= guiInfo.mowerCapacity and not self.emptyMower then
        self.emptyMower = true
        self:createEmptyPoint()

        guiInfo.map.y = (sy - 200/zoom)/2 + 30/zoom
        exports.TR_jobs:createInformation(jobSettings.name, "Sepet tamamen dolu. Biçilen çimi boşaltma noktasına git.", guiInfo.map.h + 40/zoom)
    end

    dxSetBlendMode("blend")
    dxSetRenderTarget()
end

function Landmowers:render()
    if self.blockMap then return end
    local _, _, rot = getElementRotation(localPlayer)
    self:updateMap()

    dxDrawImage(guiInfo.map.x, guiInfo.map.y, guiInfo.map.w, guiInfo.map.h, self.mapTarget)
    dxDrawImage(guiInfo.map.x + (guiInfo.map.w - guiInfo.map.mower)/2, guiInfo.map.y + (guiInfo.map.h - guiInfo.map.mower)/2, guiInfo.map.mower, guiInfo.map.mower, self.textures.mower, -rot, 0, 0)
end

function Landmowers:createEmptyPoint()
    self.marker = createMarker(guiInfo.emptyPoint - Vector3(0, 0, 0.9), "cylinder", 1, 255, 255, 255, 0)
    setElementData(self.marker, "markerData", {
        title = "Boşaltma Noktası",
        desc = "Boşaltmak için işaretleyiciye girin.",
    }, false)
    setElementData(self.marker, "markerIcon", "landmower", false)

    exports.TR_jobs:setPlayerTargetPos(guiInfo.emptyPoint.x, guiInfo.emptyPoint.y, guiInfo.emptyPoint.z, 0, 0, "Sepeti Boşalt")
    addEventHandler("onClientMarkerHit", self.marker, self.func.emptyMarkerHit)
end

function Landmowers:emptyMarkerHit(el, md)
    if not el or not md then return end
    if el ~= localPlayer then return end
    if not self.emptyMower then return end
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return false end

    toggleControl("enter_exit", false)

    self.capacity = 0
    self.emptyTimes = self.emptyTimes + 1
    if self.emptyTimes == 3 then
        self.emptyTimes = 0
        self:clearMap()
    end

    setElementFrozen(veh, true)
    setElementData(veh, "blockAction", true)
    setTimer(function()
        setElementFrozen(veh, false)
        self.emptyMower = nil
        guiInfo.map.y = (sy - 200/zoom)/2 + 30/zoom

        exports.TR_jobs:createInformation(jobSettings.name, string.format("Parkta çimleri doğru yüksekliğe kesmek için çim biçme makinesiyle gezin.\n Sepet doluluğu: 0/%dl", guiInfo.mowerCapacity), guiInfo.map.h + 40/zoom)
        toggleControl("enter_exit", true)
        setElementData(veh, "blockAction", nil)

        self:payForWork()
        exports.TR_jobs:setPaymentTime()
    end, (self.ownedUpgrades[2] and math.random(4, 7) or math.random(7, 12)) * 1000, 1)

    guiInfo.map.y = (sy - 200/zoom)/2 + 10/zoom
    exports.TR_jobs:createInformation(jobSettings.name, string.format("Çim dökülüyor...", guiInfo.mowerCapacity), guiInfo.map.h + 10/zoom)
    exports.TR_jobs:setPlayerTargetPos(false)

    removeEventHandler("onClientMarkerHit", self.marker, self.func.emptyMarkerHit)
    destroyElement(self.marker)
end

function Landmowers:onExitLandmower(plr)
    if plr ~= localPlayer then return end

    self.blockMap = true
    exports.TR_jobs:createInformation(jobSettings.name, "İşe devam etmek için çim biçme makinesine geri dön.")
end

function Landmowers:onEnterLandmower(source, plr)
    if plr ~= localPlayer then return end
    if getElementModel(source) == 572 then
        self.blockMap = nil
        exports.TR_jobs:createInformation(jobSettings.name, string.format("Parkta çimleri doğru yüksekliğe kesmek için çim biçme makinesiyle gezin.\n Sepet doluluğu: %.1f/%dl", self.capacity, guiInfo.mowerCapacity), guiInfo.map.h + 40/zoom)
    end
end

-- Payment
function Landmowers:payForWork()
    local payment = self:calculatePayment()
    local paymentType = exports.TR_jobs:getPlayerJobPaymentType()

    exports.TR_jobPayments:giveJobPayment(payment, paymentType, getResourceName(getThisResource()))
end

function Landmowers:calculatePayment()
    local addMin, addMax = 0, 0
    for i, v in pairs(jobSettings.upgrades) do
        if self.ownedUpgrades[i] and v.additionalMoney then
            addMin = addMin + v.additionalMoney[1]
            addMax = addMax + v.additionalMoney[2]
        end
    end
    return math.min(exports.TR_jobs:getPaymentCount(guiInfo.hourEarning[1] + addMin, guiInfo.hourEarning[2] + addMax), guiInfo.maxEarning + (addMin + addMax)/2)
end

function Landmowers:shapeLeave(...)
    if arg[1] ~= localPlayer then return end
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then self:endJobForce() return end
    if getElementModel(veh) ~= 572 then self:endJobForce() return end

    local x, y, z = getElementPosition(veh)
    local rot = self:findRotation(x, y, -2458.4189453125, 631.7080078125)
    local nx, ny = self:getPointFromDistanceRotation(x, y, 5, -rot)

    setElementPosition(veh, nx, ny, z + 2)
    setElementVelocity(veh, 0, 0, 0)
    exports.TR_noti:create("Biçme alanı dışına çıkamazsınız.", "error")
end

function Landmowers:findRotation( x1, y1, x2, y2 )
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end

function Landmowers:getPointFromDistanceRotation(x, y, dist, angle)
    local a = math.rad(90 - angle);
    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;
    return x+dx, y+dy;
end



function startJob(...)
    if guiInfo.work then return end
    guiInfo.work = Landmowers:create(...)

    exports.TR_jobs:responseJobWindow()
    exports.TR_jobs:closeJobWindow()
end

function endJob()
    exports.TR_jobs:responseJobWindow()

    if not guiInfo.work then return end
    guiInfo.work:destroy()
end

-- if getPlayerName(localPlayer) == "Xantris" then
--     startJob({})
-- end

-- if getPlayerName(localPlayer) == "Xantris" or getPlayerName(localPlayer) == "Wilku" then
--     startJob()
-- end