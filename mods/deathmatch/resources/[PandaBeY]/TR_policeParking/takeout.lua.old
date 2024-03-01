local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 550/zoom)/2,
    y = (sy - 310/zoom)/2,
    w = 550/zoom,
    h = 310/zoom,
}

ParkingTakeout = {}
ParkingTakeout.__index = ParkingTakeout

function ParkingTakeout:create(...)
    local instance = {}
    setmetatable(instance, ParkingTakeout)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function ParkingTakeout:constructor(...)
    self.alpha = 0
    self.vehSpawn = arg[1]
    self.vehicles = arg[2] or {}

    if arg[3] then
        for i, v in pairs(arg[3]) do
            table.insert(self.vehicles, v)
        end
    end

    self.scroll = 0

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.parts = exports.TR_dx:getFont(12)
    self.fonts.small = exports.TR_dx:getFont(10)

    self.buttons = {}
    self.buttons.exit = exports.TR_dx:createButton(guiInfo.x + 10/zoom, guiInfo.y + guiInfo.h - 50/zoom, 235/zoom, 40/zoom, "Anuluj")
    self.buttons.submit = exports.TR_dx:createButton(guiInfo.x + guiInfo.w - 245/zoom, guiInfo.y + guiInfo.h - 50/zoom, 235/zoom, 40/zoom, "Potwierdź")
    exports.TR_dx:setButtonVisible(self.buttons, false)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.buttonClick = function(...) self:buttonClick(...) end
    self.func.mouseClick = function(...) self:mouseClick(...) end
    self.func.scrollKey = function(...) self:scrollKey(...) end

    self:performData()
    -- self:selectVehicle(1)
    self:open()
    return true
end


function ParkingTakeout:performData()
    for i, v in pairs(self.vehicles) do
        local data = split(v.policeParkingInfo, ",")
        self.vehicles[i].name = string.format("%s (%d)", self:getVehicleName(v.model), v.ID)
        self.vehicles[i].price = tonumber(data[1])
        self.vehicles[i].reason = data[2]
        self.vehicles[i].police = data[3]
    end
end

function ParkingTakeout:getVehicleName(_model)
    local model = tonumber(_model)
    if model == 471 then return "Snowmobile" end
    if model == 604 then return "Christmas Manana" end
    return getVehicleNameFromID(model)
end


function ParkingTakeout:open()
    self.state = "opening"
    self.tick = getTickCount()

    exports.TR_dx:showButton(self.buttons)
    exports.TR_dx:setOpenGUI(true)

    showCursor(true)
    bindKey("mouse_wheel_up", "down", self.func.scrollKey)
    bindKey("mouse_wheel_down", "down", self.func.scrollKey)
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientClick", root, self.func.mouseClick)
    addEventHandler("guiButtonClick", root, self.func.buttonClick)
end

function ParkingTakeout:close()
    self.state = "closing"
    self.tick = getTickCount()

    exports.TR_dx:hideButton(self.buttons)

    showCursor(false)
    unbindKey("mouse_wheel_up", "down", self.func.scrollKey)
    unbindKey("mouse_wheel_down", "down", self.func.scrollKey)
    removeEventHandler("onClientClick", root, self.func.mouseClick)
    removeEventHandler("guiButtonClick", root, self.func.buttonClick)
end

function ParkingTakeout:destroy()
    exports.TR_dx:setOpenGUI(false)
    exports.TR_dx:destroyButton(self.buttons)
    removeEventHandler("onClientRender", root, self.func.render)
    guiInfo.window = nil
    self = nil
end


function ParkingTakeout:animate()
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


function ParkingTakeout:render()
    self:animate()
    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 5)
    dxDrawText("Opłacanie mandatu", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")

    if self.vehicles[self.selected] then
        dxDrawText(string.format("Policjant: %s\nKoszt wyjęcia: $%.2f\nPowód: %s", self.vehicles[self.selected].police, self.vehicles[self.selected].price, self.vehicles[self.selected].reason), guiInfo.x + guiInfo.w - 245/zoom, guiInfo.y + 50/zoom, guiInfo.x + guiInfo.w - 15/zoom, guiInfo.y + guiInfo.h - 15/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.parts, "center", "top", true, true, false)
    else
        dxDrawText("Wybierz pojazd z listy.", guiInfo.x + guiInfo.w - 245/zoom, guiInfo.y + guiInfo.h/2, guiInfo.x + guiInfo.w - 15/zoom, guiInfo.y + guiInfo.h/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.parts, "center", "center", false, false, false, true)
    end

    self:renderParkingTakeout()
end

function ParkingTakeout:renderParkingTakeout()
    for i = 1, 5 do
        local v = self.vehicles[i + self.scroll]
        if v then
            if i + self.scroll == self.selected then
                dxDrawRectangle(guiInfo.x, guiInfo.y + 50/zoom + 40/zoom * (i-1), 250/zoom, 40/zoom, tocolor(184, 153, 53, 200 * self.alpha))
                dxDrawText(v.name, guiInfo.x + 10/zoom, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.x + 240/zoom, guiInfo.y + 90/zoom + 40/zoom * (i-1), tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.parts, "center", "center", true, true)
            elseif self:isMouseInPosition(guiInfo.x, guiInfo.y + 50/zoom + 40/zoom * (i-1), 250/zoom, 40/zoom) then
                dxDrawRectangle(guiInfo.x, guiInfo.y + 50/zoom + 40/zoom * (i-1), 250/zoom, 40/zoom, tocolor(37, 37, 37, 255 * self.alpha))
                dxDrawText(v.name, guiInfo.x + 10/zoom, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.x + 240/zoom, guiInfo.y + 90/zoom + 40/zoom * (i-1), tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.parts, "center", "center", true, true)
            else
                dxDrawRectangle(guiInfo.x, guiInfo.y + 50/zoom + 40/zoom * (i-1), 250/zoom, 40/zoom, tocolor(27, 27, 27, 255 * self.alpha))
                dxDrawText(v.name, guiInfo.x + 10/zoom, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.x + 240/zoom, guiInfo.y + 90/zoom + 40/zoom * (i-1), tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.parts, "center", "center", true, true)
            end
        end
    end

    if #self.vehicles > 5 then
        local b1 = 200/zoom / #self.vehicles
        local barY = b1 * self.scroll
        local barHeight = b1 * 5
        dxDrawRectangle(guiInfo.x + 250/zoom, guiInfo.y + 50/zoom, 4/zoom, 200/zoom, tocolor(37, 37, 37, 255 * self.alpha))
        dxDrawRectangle(guiInfo.x + 250/zoom, guiInfo.y + 50/zoom + barY, 4/zoom, barHeight, tocolor(57, 57, 57, 255 * self.alpha))
    else
        dxDrawRectangle(guiInfo.x + 250/zoom, guiInfo.y + 50/zoom, 4/zoom, 200/zoom, tocolor(57, 57, 57, 255 * self.alpha))
    end
end


function ParkingTakeout:buttonClick(...)
    if exports.TR_dx:isResponseEnabled() then return false end
    if arg[1] == self.buttons.exit then
        self:close()

    elseif arg[1] == self.buttons.submit then
        local data = self.vehicles[self.selected]
        if not data then exports.TR_noti:create("Musisz najpierw wybrać pojazd.", "error") return end

        exports.TR_dx:setResponseEnabled(true)
        triggerServerEvent("createPayment", resourceRoot, data.price, "policeParkingTakeoutVehicle", {data.ID, self.vehSpawn.pos})
    end
end

function ParkingTakeout:mouseClick(...)
    if exports.TR_dx:isResponseEnabled() then return false end
    if arg[1] == "left" then
        for i = 1, 5 do
            local v = self.vehicles[i + self.scroll]
            if v then
                if self:isMouseInPosition(guiInfo.x, guiInfo.y + 50/zoom + 40/zoom * (i-1), 250/zoom, 40/zoom) then
                    self:selectVehicle(i + self.scroll)
                    break
                end
            end
        end
    end
end

function ParkingTakeout:selectVehicle(index)
    self.selected = index
end

function ParkingTakeout:scrollKey(...)
    if exports.TR_dx:isResponseEnabled() then return false end
    if arg[1] == "mouse_wheel_up" then
        if self.scroll == 0 then return end
        self.scroll = self.scroll - 1

    elseif arg[1] == "mouse_wheel_down" then
        if #self.vehicles < 5 then return end
        if self.scroll == #self.vehicles - 5 then return end
        self.scroll = self.scroll + 1
    end
end

function ParkingTakeout:response(success)
    if success then
        exports.TR_noti:create("Pojazd został pomyślnie wykupiony z parkingu policyjnego.", "success")
        self:close()

        exports.TR_achievements:addAchievements("vehiclePoliceParking")
    end
    exports.TR_dx:setResponseEnabled(false)
end


function ParkingTakeout:drawBackground(x, y, rx, ry, color, radius, post)
    rx = rx - radius * 2
    ry = ry - radius * 2
    x = x + radius
    y = y + radius

    if (rx >= 0) and (ry >= 0) then
      dxDrawRectangle(x, y, rx, ry, color, post)
      dxDrawRectangle(x, y - radius, rx, radius, color, post)
      dxDrawRectangle(x, y + ry, rx, radius, color, post)
      dxDrawRectangle(x - radius, y, radius, ry, color, post)
      dxDrawRectangle(x + rx, y, radius, ry, color, post)

      dxDrawCircle(x, y, radius, 180, 270, color, color, 7, 1, post)
      dxDrawCircle(x + rx, y, radius, 270, 360, color, color, 7, 1, post)
      dxDrawCircle(x + rx, y + ry, radius, 0, 90, color, color, 7, 1, post)
      dxDrawCircle(x, y + ry, radius, 90, 180, color, color, 7, 1, post)
    end
end

function ParkingTakeout:isMouseInPosition(x, y, width, height)
	if (not isCursorShowing()) then
		return false
	end
  local cx, cy = getCursorPosition()
  local cx, cy = (cx*sx), (cy*sy)
  if (cx >= x and cx <= x + width) and (cy >= y and cy <= y + height) then
    return true
  else
    return false
  end
end






function openPoliceParkingTakeout(...)
    if guiInfo.window then return end
    guiInfo.window = ParkingTakeout:create(...)
end
addEvent("openPoliceParkingTakeout", true)
addEventHandler("openPoliceParkingTakeout", root, openPoliceParkingTakeout)

function policeParkingTakeoutResponse(...)
    if not guiInfo.window then return end
    guiInfo.window:response(...)
end
addEvent("policeParkingTakeoutResponse", true)
addEventHandler("policeParkingTakeoutResponse", root, policeParkingTakeoutResponse)