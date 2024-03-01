local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = sx - 250/zoom,
    y = sy - 430/zoom,
    w = 180/zoom,
    h = 379/zoom,
}

DragShifter = {}
DragShifter.__index = DragShifter

function DragShifter:create()
    local instance = {}
    setmetatable(instance, DragShifter)
    if instance:constructor() then
        return instance
    end
    return false
end

function DragShifter:constructor()
    self.accelerateProgress = 0
    self.currentGear = 1
    self.tick = getTickCount()
    self.state = "up"

    self.textures = {}
    self.textures.dragBar = dxCreateTexture("files/images/dragBar.png", "argb", true, "clamp")

    self.fonts = {}
    self.fonts.gear = exports.TR_dx:getFont(110)

    self.func = {}
    self.func.switchGear = function(...) self:switchGear(...) end
    self.func.render = function() self:render() end

    addEventHandler("onClientRender", root, self.func.render)
    bindKey("lshift", "down", self.func.switchGear)
    bindKey("lctrl", "down", self.func.switchGear)
    return true
end

function DragShifter:destroy()
    removeEventHandler("onClientRender", root, self.func.render)
    unbindKey("lshift", "down", self.func.switchGear)
    unbindKey("lctrl", "down", self.func.switchGear)

    for i, v in pairs(self.textures) do
        if isElement(v) then destroyElement(v) end
    end
    RaceData.drag = nil
    self = nil
end

function DragShifter:animate()
    if not self.tick then return end
    local progress = (getTickCount() - self.tick)/100
    if self.state == "up" then
        self.alpha = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "Linear")
        if progress >= 1 then
            self.tick = getTickCount()
            self.state = "down"
        end

    elseif self.state == "down" then
        self.alpha = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "Linear")
        if progress >= 1 then
            self.tick = getTickCount()
            self.state = "up"
        end
    end
end

function DragShifter:render()
    self:animate()
    self:updateHandling()
    self:drawShifter()
end

function DragShifter:drawShifter()
    dxDrawImage(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, "files/images/dragBg.png", 0, 0, 0, tocolor(255, 255, 255, 200))
    dxDrawText(self.currentGear, guiInfo.x, guiInfo.y + 75/zoom, guiInfo.x + 102/zoom, guiInfo.y, tocolor(255, 255, 255, 200), 1/zoom, self.fonts.gear, "center", "top")

    local progress = math.max(math.min(self.accelerateProgress, 1), 0)
    dxDrawImageSection(guiInfo.x, guiInfo.y + guiInfo.h - (guiInfo.h * progress), guiInfo.w, guiInfo.h * progress, 0, 379 - 379 * progress, 180, 379 * progress, self.textures.dragBar, 0, 0, 0, tocolor(255, 255, 255, 200))
    self:renderShifting()
end

function DragShifter:renderShifting()
    dxDrawImage(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, "files/images/dragUpshift.png", 0, 0, 0, tocolor(255, 255, 255, 60))
    dxDrawImage(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, "files/images/dragDownshift.png", 0, 0, 0, tocolor(255, 255, 255, 60))

    if self.defaultHandling["numberOfGears"] > self.currentGear then
        if self.accelerateProgress >= 0.7 then
            dxDrawImage(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, "files/images/dragUpshift.png", 0, 0, 0, tocolor(234, 41, 28, 200 * self.alpha))
        end
    end
    if self.currentGear ~= 1 then
        if self.accelerateProgress <= 0.4 then
            dxDrawImage(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, "files/images/dragDownshift.png", 0, 0, 0, tocolor(22, 224, 74, 200 * self.alpha))
        end
    end
end

function DragShifter:getDefaultHandling()
    self.veh = getPedOccupiedVehicle(localPlayer)
    if not self.veh then return end
    if self.defaultHandling then return end
    self.defaultHandling = getVehicleHandling(self.veh)
end

function DragShifter:updateHandling()
    if not self.defaultHandling then self:getDefaultHandling() return end
    if not isElement(self.veh) then return end

    local velocity = self:getElementSpeed(self.veh, 1)

    self.accelerationPerGear = self.defaultHandling["engineAcceleration"]/self.defaultHandling["numberOfGears"]/10
    self.maxSpeedPerGear = self.defaultHandling["maxVelocity"]/self.defaultHandling["numberOfGears"]

    if self.currentGear == 1 then
        self.accelerateProgress = velocity/(self.maxSpeedPerGear*self.currentGear)
        self.changeProgress = math.max(self.accelerateProgress, 0.3)
    else
        self.accelerateProgress = velocity/(self.maxSpeedPerGear*self.currentGear)
        self.changeProgress = self.accelerateProgress
    end

    if velocity > (self.maxSpeedPerGear * self.currentGear) then
        self:setElementSpeed(self.veh, 1, velocity - 1)

    elseif velocity ~= self.lastVelocity and self.lastVelocity and getControlState("accelerate") then
        if velocity > self.lastVelocity + self.changeProgress * self.accelerationPerGear then
            velocity = self.lastVelocity + self.changeProgress * self.accelerationPerGear
            self:setElementSpeed(self.veh, 1, velocity)
        end
    end

    self.lastVelocity = velocity
end

function DragShifter:switchGear(btn)
    if btn == "lshift" then
        self.currentGear = math.min(self.currentGear + 1, self.defaultHandling["numberOfGears"])

    elseif btn == "lctrl" then
        self.currentGear = math.max(self.currentGear - 1, 1)

    end
end

function DragShifter:getElementSpeed(theElement, unit)
    local elementType = getElementType(theElement)
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    return (Vector3(getElementVelocity(theElement)) * mult).length
end

function DragShifter:setElementSpeed(element, unit, speed)
    local unit    = unit or 0
    local speed   = tonumber(speed) or 0
	local acSpeed = self:getElementSpeed(element, unit)
	if acSpeed and acSpeed~=0 then -- if true - element is valid, no need to check again
		local diff = speed/acSpeed
		if diff ~= diff then return false end -- if the number is a 'NaN' return false.
        	local x, y, z = getElementVelocity(element)
		return setElementVelocity(element, x*diff, y*diff, z*diff)
	end
	return false
end

function createDragShifter()
    RaceData.drag = DragShifter:create()
end