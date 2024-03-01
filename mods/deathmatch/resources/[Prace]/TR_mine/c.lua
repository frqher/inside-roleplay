local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    wall = {
        x = (sx - 1141/zoom)/2,
        y = (sy - 873/zoom)/2,
        w = 1141/zoom,
        h = 873/zoom,
    },
    holes = {
        x = (sx - 1141/zoom)/2 + 200/zoom,
        y = (sy - 873/zoom)/2 + 200/zoom,
        w = 700/zoom,
        h = 500/zoom,
    },
    hole = {
        w = 89/zoom,
        h = 94/zoom,
    },
    dynamite = {
        w = 100/zoom,
        h = 107/zoom,
    },

    hourEarning = {4450, 4520},
    maxEarning = 300,
}

Mine = {}
Mine.__index = Mine

function Mine:create(...)
    local instance = {}
    setmetatable(instance, Mine)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function Mine:constructor(...)
    self.ownedUpgrades = arg[1]
    self.holesCount = self.ownedUpgrades[1] and 3 or 5
    self.rocksCount = self.ownedUpgrades[2] and 3 or 5

    self.alpha = 0

    self.markers = {}
    self.markers.rockDrop = createMarker(562.787109375, 822.814453125, -23.027143859863, "cylinder", 2, 90, 77, 65, 0)
    setElementData(self.markers.rockDrop, "markerData", {
        title = "Taş Dökümü",
        desc = "Taş bandına taş atmak için işaretçiye girin.",
    }, false)
    setElementData(self.markers.rockDrop, "markerIcon", "pickaxe", false)

    self.blips = {}
    self.holes = {}


    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(12)

    self.textures = {}
    self.textures.wall = dxCreateTexture("files/images/wall.png", "argb", true, "clamp")
    self.textures.hole = dxCreateTexture("files/images/hole.png", "argb", true, "clamp")
    self.textures.dynamite = dxCreateTexture("files/images/dynamite.png", "argb", true, "clamp")

    self.func = {}
    self.func.render = function() self:render() end
    self.func.onClick = function(...) self:onClick(...) end
    self.func.leaveZoneHit = function(...) self:leaveZoneHit(...) end
    self.func.onRockDrop = function(...) self:onRockDrop(source, ...) end

    self:setStage("getDynamite")

    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientMarkerHit", self.markers.rockDrop, self.func.onRockDrop)

    exports.TR_noti:create("Madenci olarak işe başladınız.", "job")
    return true
end

function Mine:destroyMarkers()
    for i, v in pairs(self.markers) do
        if isElement(v) then destroyElement(v) end
    end
    for i, v in pairs(self.blips) do
        if isElement(v) then destroyElement(v) end
    end
end

function Mine:destroy()
    exports.TR_jobs:resetPaymentTime()
    exports.TR_jobs:setPlayerJob(false)
    exports.TR_jobs:removeInformation()
    exports.TR_jobs:setPlayerTargetPos(false)

    self:destroyMarkers()

    for i, v in pairs(self.textures) do
        destroyElement(v)
    end

    setElementData(localPlayer, "inJob", nil)
    removeEventHandler("onClientRender", root, self.func.render)


    exports.TR_jobs:setPlayerJob(false)

    guiInfo.work = nil
    self = nil
end

function Mine:animate()
    if not self.tick then return end
    local progress = (getTickCount() - self.tick)/500
    if self.animState == "opening" then
        self.alpha = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "Linear")
        if progress >= 1 then
            self.alpha = 1
            self.animState = "opened"
            self.tick = nil
        end

    elseif self.animState == "closing" then
        self.alpha = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "Linear")
        if progress >= 1 then
            self.alpha = 0
            self.animState = "closed"
            self.tick = nil
        end
    end
end

function Mine:render()
    self:animate()

    dxDrawImage(guiInfo.wall.x, guiInfo.wall.y, guiInfo.wall.w, guiInfo.wall.h, self.textures.wall, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))

    for i, v in pairs(self.holes) do
        dxDrawImage(v.pos.x, v.pos.y, guiInfo.hole.w, guiInfo.hole.h, self.textures.hole, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))

        if v.dynamite then
            dxDrawImage(v.pos.x + 33/zoom, v.pos.y - 28/zoom, guiInfo.dynamite.w, guiInfo.dynamite.h, self.textures.dynamite, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha), true)
        end
    end
end

function Mine:onClick(...)
    if arg[1] ~= "left" or arg[2] ~= "down" or self.state ~= "placingDynamite" then return end

    for i, v in pairs(self.holes) do
        if not v.dynamite then
            if self:isMouseInPosition(v.pos.x, v.pos.y, guiInfo.hole.w, guiInfo.hole.h) then
                v.dynamite = true

                for i, v in pairs(self.holes) do
                    if not v.dynamite then return end
                end

                self:setStage("detonate")
                return
            end
        end
    end
end

function Mine:onRockDrop(source, el)
    if el ~= localPlayer then return end
    if self.state ~= "throwRock" then return end
    if getPedOccupiedVehicle(el) then return end

    local markerPos = Vector3(getElementPosition(source))
    local playerPos = Vector3(getElementPosition(localPlayer))
    if playerPos.z < markerPos.z - 0.5 or playerPos.z > markerPos.z + 2 then return end

    self:checkRocks()
end

function Mine:getJobState()
    return self.state
end

function Mine:leaveZoneHit(...)
    if arg[1] ~= localPlayer then return end
    self:setStage("onDetonate")
end

function Mine:setStage(...)
    self.state = arg[1]

    if self.state == "getDynamite" then
        exports.TR_jobs:setPlayerTargetPos(567.42248535156, 818.82946777344, -29.482440948486, 0, 0, "Dinamitleri al")
        exports.TR_jobs:createInformation(jobSettings.name, "Patlayıcı malzeme deposuna giderek dinamitleri al.")
        exports.TR_jobs:setPaymentTime()

    elseif self.state == "placeDynamite" then
        exports.TR_jobs:setPlayerTargetPos(489.6328125, 779.7353515625, -21.5938247680, 0, 0, "Yerleştirme işlemi")
        exports.TR_jobs:createInformation(jobSettings.name, "Patlayıcıları yerleştirmek için maden duvarına yaklaş.")

    elseif self.state == "placingDynamite" then
        exports.TR_jobs:setPlayerTargetPos(false)
        exports.TR_jobs:createInformation(jobSettings.name, "Dinamitleri maden duvarındaki çatlaklara yerleştir.")
        self.alpha = 0
        self.tick = getTickCount()
        self.animState = "opening"
        showCursor(true)
        self:randomizeHoles()
        addEventHandler("onClientClick", root, self.func.onClick)

    elseif self.state == "detonate" then
        exports.TR_jobs:setPlayerTargetPos(513.1025390625, 817.7216796875, -23.931089401245, 0, 0, "Duvarlardan uzaklaş")
        exports.TR_jobs:createInformation(jobSettings.name, "Patlayıcıları infilak ettirmek için duvarlardan uzaklaş.")
        exports.TR_dx:setOpenGUI(false)

        self.tick = getTickCount()
        self.animState = "closing"

        showCursor(false)
        removeEventHandler("onClientClick", root, self.func.onClick)

        self.markers.leave = createColSphere(512.9873046875, 821.11328125, -24.31741333007, 4)
        addEventHandler("onClientColShapeHit", self.markers.leave, self.func.leaveZoneHit)

    elseif self.state == "onDetonate" then
        if isElement(self.markers.leave) then destroyElement(self.markers.leave) end

        createEffect("explosion_medium", 490.1591796875, 780.3759765625, -22.03198242187)
        setTimer(function()
            createEffect("explosion_medium", 490.1591796875, 780.3759765625, -22.03198242187)
        end, 100, self.holesCount - 1)

        setCameraShakeLevel(255)
        setTimer(setCameraShakeLevel, 100 * self.holesCount, 1, 0)

        self:randomizeRocks()
        self:setStage("getRock")

    elseif self.state == "getRock" then
        if not self.createdRocks then
            if not self.pickedRock then
                self.pickedRock = true
            end
        end
        if self.pickedRock then
            return self:setStage("throwRock")
        end
        self.createdRocks = nil

        exports.TR_jobs:setPlayerTargetPos(491.921875, 781.9775390625, -22.074180603027, 0, 0, "Taşı Kaldır")
        exports.TR_jobs:createInformation(jobSettings.name, "Duvarlardan kırılmış taşı al.")

    elseif self.state == "throwRock" then
        self.pickedRock = nil
        self.createdRocks = true
        exports.TR_jobs:setPlayerTargetPos(562.787109375, 822.814453125, -22.727143859863, 0, 0, "Taşı At")
        exports.TR_jobs:createInformation(jobSettings.name, "Taşı konveyöre at.")
    end
end

function Mine:randomizeRocks()
    self.rocks = {}

    for i = 1, self.rocksCount do
        local x, y = self:getPointFromDistanceRotation(491.921875, 781.9775390625, math.random(1, 30)/10, math.random(0, 359))

        local rock = createObject(3931, x, y, -22.8, math.random(0, 359), math.random(0, 359), math.random(0, 359))
        setElementData(rock, "rock", true, false)
        setObjectScale(rock, 0.5)
        table.insert(self.rocks, rock)
    end

    self.createdRocks = true
end

function Mine:checkRocks()
    for i, v in pairs(self.rocks) do
        if isElement(v) then
            self:setStage("getRock")
            return
        end
    end

    self:givePayment()
    self:setStage("getDynamite")
    self.rocks = {}
end

function Mine:randomizeHoles()
    self.holes = {}

    for i = 1, self.holesCount do
        local x = math.random(guiInfo.holes.x, guiInfo.holes.x + guiInfo.holes.w - guiInfo.hole.w)
        local y = math.random(guiInfo.holes.y, guiInfo.holes.y + guiInfo.holes.h - guiInfo.hole.h)
        table.insert(self.holes, {
            pos = Vector2(x, y),
        })
    end
end

function Mine:givePayment()
    local payment = self:calculatePayment()
    local paymentType = exports.TR_jobs:getPlayerJobPaymentType()

    exports.TR_jobPayments:giveJobPayment(payment, paymentType, getResourceName(getThisResource()))
end

function Mine:calculatePayment()
    local addMin, addMax = 0, 0
    for i, v in pairs(jobSettings.upgrades) do
        if self.ownedUpgrades[i] and v.additionalMoney then
            addMin = addMin + v.additionalMoney[1]
            addMax = addMax + v.additionalMoney[2]
        end
    end
    return math.min(exports.TR_jobs:getPaymentCount(guiInfo.hourEarning[1] + addMin, guiInfo.hourEarning[2] + addMax), guiInfo.maxEarning + (addMin + addMax)/2)
end

function Mine:isMouseInPosition(x, y, width, height)
    if (not isCursorShowing()) then return false end
    local cx, cy = getCursorPosition()
    local cx, cy = (cx*sx), (cy*sy)
    if (cx >= x and cx <= x + width) and (cy >= y and cy <= y + height) then return true end
    return false
end

function Mine:getPointFromDistanceRotation(x, y, dist, angle)
    local a = math.rad(90 - angle);
    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;
    return x+dx, y+dy;
end


function startJob(...)
    if guiInfo.work then return end
    guiInfo.work = Mine:create(...)

    exports.TR_jobs:responseJobWindow()
end

function endJob()
    exports.TR_jobs:responseJobWindow()

    if not guiInfo.work then return end
    guiInfo.work:destroy()
end

function getJobState()
    if not guiInfo.work then return false end
    return guiInfo.work:getJobState()
end

function setStage(...)
    if not guiInfo.work then return end
    return guiInfo.work:setStage(...)
end

createObject(3931, 489.6328125, 779.7353515625, -21.5938247680, 0, 0, 0) -- Starting wall



local col = createColCuboid(386.81640625, 730.951171875, -45.78107452392, 420, 420, 45) -- Col
addEventHandler("onClientColShapeHit", col, function(plr)
    if plr ~= localPlayer then return end
    if getElementInterior(plr) ~= 0 or getElementDimension(plr) ~= 0 then return end
    setElementData(plr, "OX", true)
end)
addEventHandler("onClientColShapeLeave", col, function(plr)
    if plr ~= localPlayer then return end
    if getElementInterior(plr) ~= 0 or getElementDimension(plr) ~= 0 then return end
    setElementData(plr, "OX", nil)
end)