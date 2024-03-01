local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 200/zoom),
    y = (sy - 320/zoom),
    w = 200/zoom,
    h = 300/zoom,
}

Painting = {}
Painting.__index = Painting

function Painting:create(...)
    local instance = {}
    setmetatable(instance, Painting)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function Painting:constructor(...)
    self.alpha = 0

    self.player = arg[1]
    self.colors = arg[2]
    self.vehicle = getPedOccupiedVehicle(self.player)
    -- self.vehicle = getElementByID("vehicle1")
    self.currentColors = {getVehicleColor(self.vehicle, true)}
    self.defaultColors = {getVehicleColor(self.vehicle, true)}

    self.closestPlace, self.index = self:getClosestPlace()
    self.paintingProgress = {front = 0, back = 0, left = 0, right = 0}

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(12)
    self.fonts.status = exports.TR_dx:getFont(12)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.useCan = function(...) self:useCan(...) end

    self:open()
    return true
end

function Painting:open(...)
    self.state = "opening"
    self.tick = getTickCount()

    exports.TR_weapons:blockUpdate(true)

    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientPlayerWeaponFire", root, self.func.useCan)
end

function Painting:close(...)
    self.state = "closing"
    self.tick = getTickCount()

    exports.TR_weapons:blockUpdate(false)
    setElementData(localPlayer, "blockAction", nil)

    removeEventHandler("onClientPlayerWeaponFire", root, self.func.useCan)
end

function Painting:destroy()
    removeEventHandler("onClientRender", root, self.func.render)

    guiInfo.painting = nil
    self = nil

    setTimer(function()
        toggleControl("fire", false)
        toggleControl("aim_weapon", false)
    end, 50, 1)
end


function Painting:animate()
    if not self.tick then return end
    local progress = (getTickCount() - self.tick)/500
    if self.state == "opening" then
      self.alpha = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "Linear")
      if progress >= 1 then
        self.alpha = 1
        self.state = "opened"
        self.tick = nil
      end

    elseif self.state == "closing" then
      self.alpha = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "Linear")
      if progress >= 1 then
        self.alpha = 0
        self.state = "closed"
        self.tick = nil

        self:destroy()
      end
    end
end

function Painting:render()
    self:animate()
    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 5)
    dxDrawText("Araç Boyama", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 30/zoom, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")

    self:renderData()
    self:enableSpray()
end


function Painting:enableSpray()
    local jobID = exports.TR_jobs:getPlayerJob()
    if getDistanceBetweenPoints3D(Vector3(getElementPosition(localPlayer)), paintPositions[self.closestPlace].positions[self.index]) > 5 and jobID == paintPositions[self.closestPlace].jobID then
        toggleControl("fire", false)
        toggleControl("aim_weapon", false)
        return
    end

    local weapon = getPedWeapon(localPlayer)
    if weapon == 41 then
        toggleControl("fire", true)
        toggleControl("aim_weapon", true)
    else
        toggleControl("fire", false)
        toggleControl("aim_weapon", false)
    end
end

function Painting:renderData()
    local y = 0
    for i, v in pairs(self.paintingProgress) do
        dxDrawText(self:getSideName(i), guiInfo.x + 10/zoom, guiInfo.y + 56/zoom + 66/zoom * y, guiInfo.x + 10/zoom, guiInfo.y + 60/zoom + 66/zoom * y, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.status, "left", "bottom")
        self:dxDrawProgressBar(guiInfo.x + 10/zoom, guiInfo.y + 64/zoom + 66/zoom * y, guiInfo.w - 20/zoom, 30/zoom, v)
        y = y + 1
    end
end

function Painting:useCan(...)
    if self.blockSpeed then
        if (getTickCount() - self.blockSpeed)/10 < 1 then return end
    end

    if arg[1] == 41 then
        local plrPos = Vector3(getElementPosition(localPlayer))
        local vehPos = Vector3(getElementPosition(self.vehicle))
        local dist = getDistanceBetweenPoints3D(plrPos, vehPos)
        if dist > 5 then return end
        if not getPedTargetStart(localPlayer) then return end

        local x, y, z = getPedTargetStart(localPlayer)
        local tx, ty, tz = getPedTargetEnd(localPlayer)
        local hit, _, _, _, element = processLineOfSight(x, y, z, tx, ty, tz)
        if not hit or element ~= self.vehicle then return end

        local rot = self:findRotation(vehPos.x, vehPos.y, plrPos.x, plrPos.y)
        local _, _, vrot = getElementRotation(self.vehicle)
        rot = vrot - rot
        rot = rot < 0 and rot + 360 or rot
        if rot < 335 and rot >= 210 then
            self.paintingProgress.left = math.min(self.paintingProgress.left + 0.3, 100)

        elseif (rot < 30 and rot >= 0) or (rot <= 360 and rot >= 335) then
            self.paintingProgress.front = math.min(self.paintingProgress.front + 0.3, 100)

        elseif rot < 150 and rot >= 30 then
            self.paintingProgress.right = math.min(self.paintingProgress.right + 0.3, 100)

        elseif rot < 210 and rot >= 150 then
            self.paintingProgress.back = math.min(self.paintingProgress.back + 0.3, 100)
        end
        self.blockSpeed = getTickCount()

        local progress = self.paintingProgress.back/400 + self.paintingProgress.right/400 + self.paintingProgress.front/400 + self.paintingProgress.left/400
        if progress < 1 then
            for i = 1, 12 do
                local diff = self.colors[i] - self.defaultColors[i]
                self.currentColors[i] = math.max(math.min(self.defaultColors[i] + (diff * progress), 255), 0)
            end

            triggerServerEvent("paintVehicle", resourceRoot, self.vehicle, self.currentColors)
        else
            self:close()
            triggerServerEvent("paintVehicleFinal", resourceRoot, self.vehicle, self.colors, localPlayer, true)
        end
    end
end

function Painting:dxDrawProgressBar(x, y, w, h, progress)
    dxDrawRectangle(x, y, w * progress/100, h, tocolor(184, 153, 53, 255 * self.alpha))

    dxDrawRectangle(x - 1, y - 1, 2, h + 2, tocolor(57, 57, 57, 255 * self.alpha))
    dxDrawRectangle(x + w - 1, y - 1, 2, h + 2, tocolor(57, 57, 57, 255 * self.alpha))
    dxDrawRectangle(x - 1, y - 1, w, 2, tocolor(57, 57, 57, 255 * self.alpha))
    dxDrawRectangle(x - 1, y + h - 1, w, 2, tocolor(57, 57, 57, 255 * self.alpha))

    dxDrawText(string.format("%d%%", progress), x, y, x + w, y + h, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.status, "center", "center")
end

function Painting:drawBackground(x, y, w, h, color, radius, post)
    dxDrawRectangle(x, y - radius, w, h + radius * 2, color, post)
    dxDrawRectangle(x - radius, y, radius, h, color, post)
    dxDrawCircle(x, y, radius, 180, 270, color, color, 7, 1, post)
    dxDrawCircle(x, y + h, radius, 90, 180, color, color, 7, 1, post)
end

function Painting:getSideName(side)
    if side == "front" then return "Ön" end
    if side == "back" then return "Arka" end
    if side == "left" then return "Sol taraf" end
    if side == "right" then return "Sağ taraf" end
end

function Painting:findRotation(x1, y1, x2, y2)
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end

function Painting:getClosestPlace()
    local plrPos = Vector3(getElementPosition(localPlayer))
    local closestDist = 1000
    local closestPlace = false
    local closestIndex = false

    for i, data in pairs(paintPositions) do
        for k, v in pairs(data.positions) do
            local dist = getDistanceBetweenPoints3D(plrPos, v)

            if dist < closestDist then
                closestDist = dist
                closestPlace = i
                closestIndex = k
            end
        end
    end
    return closestPlace, closestIndex
end


function startPaintingVehicle(...)
    if guiInfo.painting then return end
    guiInfo.painting = Painting:create(...)
end
addEvent("startPaintingVehicle", true)
addEventHandler("startPaintingVehicle", root, startPaintingVehicle)

function stopPaintingVehicle(...)
    if not guiInfo.painting then return end
    guiInfo.painting:close(...)
end
addEvent("stopPaintingVehicle", true)
addEventHandler("stopPaintingVehicle", root, stopPaintingVehicle)

function blockSpray(attacker, weapon)
    if weapon == 41 then cancelEvent() end
end
addEventHandler("onClientPlayerDamage", localPlayer, blockSpray)


function canBePainted(vehicle)
    if not getElementData(vehicle, "vehicleID") then return false end
    local jobID = exports.TR_jobs:getPlayerJob()
    local vehPos = Vector3(getElementPosition(vehicle))

    local vehID = getElementID(vehicle)
    if vehID then
        if string.len(vehID) < 4 then
            return false
        end
    end

    for i, v in pairs(getElementsByType("paintingPosition", resourceRoot, true)) do
        local paintingPosition = getElementData(v, "paintingPosition")
        if paintingPosition.jobID == jobID and paintingPosition.mechanic == localPlayer then
          local dist = getDistanceBetweenPoints3D(vehPos, Vector3(getElementPosition(v)))
          if dist < 2 then
            return true
          end
          return false
        end
    end
    return false
end

setVehicleModelWheelSize(531, "rear_axle", 1.4)



local positionsFont = exports.TR_dx:getFont(12)
function renderMechanicPositions()
    if getElementInterior(localPlayer) ~= 0 or getElementDimension(localPlayer) ~= 0 then return end
    local plrPos = Vector3(getCameraMatrix())
    local plrInt = getElementInterior(localPlayer)
    local plrDim = getElementDimension(localPlayer)

    for i, v in pairs(getElementsByType("paintingPosition", resourceRoot, true)) do
        local paintingPosition = getElementData(v, "paintingPosition")

        local pos = Vector3(getElementPosition(v))
        local clear = isLineOfSightClear(plrPos, pos, true, false, false, true, true, true)
        if clear then
            local dist = getDistanceBetweenPoints3D(plrPos, pos)
            local scx, scy = getScreenFromWorldPosition(pos + Vector3(0, 0, 0.5))

            if scx and scy and dist < 20 then
                if isElement(paintingPosition.mechanic) then
                    drawTextShadowed(string.format("#2ff539[BOYA İŞLEMİ POZİSYONU]\n#ffffffPozisyon Numarası: #888888%d\n#ffffffMekanik: #888888%s", paintingPosition.ID, paintingPosition.mechanicName), scx, scy, scx, scy, tocolor(255, 255, 255, 255), 1 * (1 - dist/20), positionsFont, "center", "center", false, false, false, true)

                else
                    drawTextShadowed(string.format("#2ff539[BOYA İŞLEMİ POZİSYONU]\n#ffffffPozisyon Numarası: #888888%d\n#ffffffMekanik: #888888%s", paintingPosition.ID, "Yok"), scx, scy, scx, scy, tocolor(255, 255, 255, 255), 1 * (1 - dist/20), positionsFont, "center", "center", false, false, false, true)
                end
            end
        end
    end
end

function removeColor(text)
    while string.find(text, "#%x%x%x%x%x%x") do
      text = string.gsub(text, "#%x%x%x%x%x%x", "")
    end
    return text
end

function drawTextShadowed(text, x, y, w, h, color, scale, font, vert, hori, clip, brake, post, colored)
	local withoutColor = removeColor(text)
	dxDrawText(withoutColor, x + 1, y + 1, w + 1, h + 1, tocolor(0, 0, 0, 100), scale, font, vert, hori, clip, brake, post)
	dxDrawText(text, x, y, w, h, color, scale, font, vert, hori, clip, brake, post, colored)
end
addEventHandler("onClientRender", root, renderMechanicPositions)