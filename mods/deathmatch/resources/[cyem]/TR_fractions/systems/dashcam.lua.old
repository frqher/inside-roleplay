local sx, sy = guiGetScreenSize()

local guiInfo = {
    x = (sx - 350/zoom)/2,
    y = sy - 210/zoom,
    w = 350/zoom,
    h = 100/zoom,
}

Dashcam = {}
Dashcam.__index = Dashcam

function Dashcam:create(...)
    local instance = {}
    setmetatable(instance, Dashcam)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function Dashcam:constructor(...)
    self.alpha = 0

    self.fonts = {}
    self.fonts.speed = exports.TR_dx:getFont(40)
    self.fonts.km = exports.TR_dx:getFont(14)
    self.fonts.category = exports.TR_dx:getFont(12)

    self.func = {}
    self.func.render = function() self:render() end

    self:open()
    return true
end


function Dashcam:open()
    self.state = "opening"
    self.tick = getTickCount()

    local veh = getPedOccupiedVehicle(localPlayer)

    self.sphere = createColSphere(0, 0, 0, 20)
    attachElements(self.sphere, veh, 0, 22, 7)

    addEventHandler("onClientRender", root, self.func.render)
end


function Dashcam:close()
    if self.state ~= "opening" and self.state ~= "opened" then return end
    self.state = "closing"
    self.tick = getTickCount()
end


function Dashcam:destroy()
    removeEventHandler("onClientRender", root, self.func.render)
    destroyElement(self.sphere)

    guiInfo.dashcam = nil
    self = nil
end

function Dashcam:updateVehicleInFront()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then self:close() return end

    if not self.sphere then
        self.vehicleData = nil
        return
    end

    local vehicles = getElementsWithinColShape(self.sphere, "vehicle")
    if vehicles then
        local vehicle = false
        local pos = Vector3(getElementPosition(veh))
        local dist = 9999999
        for i, v in pairs(vehicles) do
            local distance = getDistanceBetweenPoints3D(pos, Vector3(getElementPosition(v)))
            if distance < dist and v ~= veh then
                vehicle = v
                dist = distance
            end
        end

        if not vehicle then self.vehicleData = nil return end

        local driver = getVehicleOccupant(vehicle)
        self.vehicleData = {
            name = self:getVehicleName(getElementModel(vehicle)),
            speed = self:getElementSpeed(vehicle, 1) * 0.84,
            driver = driver and getPlayerName(driver) or "Brak",
            passangers = #getVehicleOccupants(vehicle),
            plate = getVehiclePlateText(vehicle),
        }

    else
        self.vehicleData = nil
    end
end

function Dashcam:getVehicleName(model)
    if model == 471 then return "Snowmobile" end
    if model == 604 then return "Christmas Manana" end
    return getVehicleNameFromID(model)
end

function Dashcam:animate()
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
            return true
        end
    end
end

function Dashcam:render()
    self:updateVehicleInFront()

    self:animate()
    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 5)

    if self.vehicleData then
        dxDrawText(string.format("%02d", self.vehicleData.speed), guiInfo.x + 22/zoom, guiInfo.y + 2/zoom, guiInfo.x + 107/zoom, guiInfo.y + guiInfo.h - 10/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.speed, "center", "top")
        dxDrawText("KM/H", guiInfo.x + 22/zoom, guiInfo.y + 60/zoom, guiInfo.x + 107/zoom, guiInfo.y + guiInfo.h - 10/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.km, "center", "top")

        dxDrawText(string.format("Pojazd: #828282%s", self.vehicleData.name), guiInfo.x + 129/zoom, guiInfo.y + 8/zoom, guiInfo.x + 100/zoom, guiInfo.y + guiInfo.h - 10/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText(string.format("Kierowca: #828282%s", self.vehicleData.driver), guiInfo.x + 129/zoom, guiInfo.y + 28/zoom, guiInfo.x + 100/zoom, guiInfo.y + guiInfo.h - 10/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText(string.format("Rejestracja: #828282%s", self.vehicleData.plate), guiInfo.x + 129/zoom, guiInfo.y + 48/zoom, guiInfo.x + 100/zoom, guiInfo.y + guiInfo.h - 10/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText(string.format("Ilość pasażerów: #828282%d", self.vehicleData.passangers), guiInfo.x + 129/zoom, guiInfo.y + 68/zoom, guiInfo.x + 100/zoom, guiInfo.y + guiInfo.h - 10/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
    else
        dxDrawText("00", guiInfo.x + 22/zoom, guiInfo.y + 2/zoom, guiInfo.x + 107/zoom, guiInfo.y + guiInfo.h - 10/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.speed, "center", "top")
        dxDrawText("KM/H", guiInfo.x + 22/zoom, guiInfo.y + 60/zoom, guiInfo.x + 107/zoom, guiInfo.y + guiInfo.h - 10/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.km, "center", "top")

        dxDrawText("Pojazd: #828282Brak", guiInfo.x + 129/zoom, guiInfo.y + 8/zoom, guiInfo.x + 100/zoom, guiInfo.y + guiInfo.h - 10/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText("Kierowca: #828282Brak", guiInfo.x + 129/zoom, guiInfo.y + 28/zoom, guiInfo.x + 100/zoom, guiInfo.y + guiInfo.h - 10/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText("Rejestracja: #828282Brak", guiInfo.x + 129/zoom, guiInfo.y + 48/zoom, guiInfo.x + 100/zoom, guiInfo.y + guiInfo.h - 10/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText("Ilość pasażerów: #828282Brak", guiInfo.x + 129/zoom, guiInfo.y + 68/zoom, guiInfo.x + 100/zoom, guiInfo.y + guiInfo.h - 10/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
    end
end




function Dashcam:drawBackground(x, y, w, h, color, radius, post)
    dxDrawRectangle(x, y, w, h, color, post)
    dxDrawRectangle(x + radius, y - radius, w - radius * 2, radius, color, post)
    dxDrawRectangle(x + radius, y + h, w - radius * 2, radius, color, post)
    dxDrawCircle(x + radius, y, radius, 180, 270, color, color, 7, 1, post)
    dxDrawCircle(x + radius, y + h, radius, 90, 180, color, color, 7, 1, post)

    dxDrawCircle(x + w - radius, y, radius, 270, 360, color, color, 7, 1, post)
    dxDrawCircle(x + w - radius, y + h, radius, 0, 90, color, color, 7, 1, post)
end

function Dashcam:getPosition(element, vec)
	local rot = Vector3(getElementRotation(element))
	local mat = Matrix(Vector3(getElementPosition(element)), rot)
	local newPos = mat:transformPosition(vec)
	return newPos.x, newPos.y, newPos.z, rot.z
end

function Dashcam:getElementSpeed(theElement, unit)
	if not isElement(theElement) then return 0 end
    local elementType = getElementType(theElement)
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    return (Vector3(getElementVelocity(theElement)) * mult).length
end


function changeDashcam()
    if guiInfo.dashcam then
        guiInfo.dashcam:close()
        return
    end

    guiInfo.dashcam = Dashcam:create()
end