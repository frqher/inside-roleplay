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

AddVehicle = {}
AddVehicle.__index = AddVehicle

function AddVehicle:create(...)
    local instance = {}
    setmetatable(instance, AddVehicle)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function AddVehicle:constructor(...)
    self.alpha = 0
    self.vehicles = arg[1]
    self.scroll = 0

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.parts = exports.TR_dx:getFont(12)
    self.fonts.small = exports.TR_dx:getFont(10)

    self.buttons = {}
    self.buttons.exit = exports.TR_dx:createButton(guiInfo.x + 10/zoom, guiInfo.y + guiInfo.h - 50/zoom, 235/zoom, 40/zoom, "İptal")
    self.buttons.submit = exports.TR_dx:createButton(guiInfo.x + guiInfo.w - 245/zoom, guiInfo.y + guiInfo.h - 50/zoom, 235/zoom, 40/zoom, "Araç ekle")
    exports.TR_dx:setButtonVisible(self.buttons, false)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.buttonClick = function(...) self:buttonClick(...) end
    self.func.mouseClick = function(...) self:mouseClick(...) end
    self.func.scrollKey = function(...) self:scrollKey(...) end

    self:performData()
    self:open()
    return true
end


function AddVehicle:performData()
    for i, v in pairs(self.vehicles) do
        self.vehicles[i].name = string.format("%s (%d)", self:getVehicleName(v.model), v.ID)
        self.vehicles[i].plate = v.plateText or string.format("%05d", v.ID)
    end
end


function AddVehicle:getVehicleName(_model)
    local model = tonumber(_model)
    if model == 471 then return "Kar arabası" end
    if model == 604 then return "Noel arabası" end
    return getVehicleNameFromModel(model)
end


function AddVehicle:open()
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

function AddVehicle:close()
    self.state = "closing"
    self.tick = getTickCount()

    exports.TR_dx:hideButton(self.buttons)

    showCursor(false)
    unbindKey("mouse_wheel_up", "down", self.func.scrollKey)
    unbindKey("mouse_wheel_down", "down", self.func.scrollKey)
    removeEventHandler("onClientClick", root, self.func.mouseClick)
    removeEventHandler("guiButtonClick", root, self.func.buttonClick)
end

function AddVehicle:destroy()
    exports.TR_dx:setOpenGUI(false)
    exports.TR_dx:destroyButton(self.buttons)
    removeEventHandler("onClientRender", root, self.func.render)
    guiInfo.window = nil
    self = nil
end


function AddVehicle:animate()
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


function AddVehicle:render()
    self:animate()
    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 5)
    dxDrawText("Organizasyona Araç Ekleme", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")

    dxDrawText("Organizasyona eklemek istediğiniz aracı seçin. Lider veya organizasyonu yönetme yetkisine sahip başka bir kişi, aracınızı kabul edip etmeyeceğine karar verecektir. Kabul edildikten sonra, organizasyonun her üyesi bu aracı kullanabilecektir.", guiInfo.x + guiInfo.w - 245/zoom, guiInfo.y + 50/zoom, guiInfo.x + guiInfo.w - 15/zoom, guiInfo.y + guiInfo.h - 50/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.small, "center", "top", false, true)
    -- dxDrawText("Kilometre taşı değişikliği için maliyet\n#d4af37$3000#aaaaaa.", guiInfo.x + guiInfo.w - 245/zoom, guiInfo.y + guiInfo.h/2, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h - 55/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.small, "center", "bottom", false, false, false, true)
    self:renderAddVehicle()
end


function AddVehicle:renderAddVehicle()
    for i = 1, 5 do
        local v = self.vehicles[i + self.scroll]
        if v then
            if i + self.scroll == self.selected then
                dxDrawRectangle(guiInfo.x, guiInfo.y + 50/zoom + 40/zoom * (i-1), 275/zoom, 40/zoom, tocolor(184, 153, 53, 200 * self.alpha))
                dxDrawText(v.name, guiInfo.x + 10/zoom, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.x + 275/zoom, guiInfo.y + 90/zoom + 40/zoom * (i-1), tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.parts, "center", "center", true, true)
            elseif self:isMouseInPosition(guiInfo.x, guiInfo.y + 50/zoom + 40/zoom * (i-1), 275/zoom, 40/zoom) then
                dxDrawRectangle(guiInfo.x, guiInfo.y + 50/zoom + 40/zoom * (i-1), 275/zoom, 40/zoom, tocolor(37, 37, 37, 255 * self.alpha))
                dxDrawText(v.name, guiInfo.x + 10/zoom, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.x + 275/zoom, guiInfo.y + 90/zoom + 40/zoom * (i-1), tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.parts, "center", "center", true, true)
            else
                dxDrawRectangle(guiInfo.x, guiInfo.y + 50/zoom + 40/zoom * (i-1), 275/zoom, 40/zoom, tocolor(27, 27, 27, 255 * self.alpha))
                dxDrawText(v.name, guiInfo.x + 10/zoom, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.x + 275/zoom, guiInfo.y + 90/zoom + 40/zoom * (i-1), tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.parts, "center", "center", true, true)
            end
        end
    end

    if #self.vehicles > 5 then
        local b1 = 200/zoom / #self.vehicles
        local barY = b1 * self.scroll
        local barHeight = b1 * 5
        dxDrawRectangle(guiInfo.x + 275/zoom, guiInfo.y + 50/zoom, 4/zoom, 200/zoom, tocolor(37, 37, 37, 255 * self.alpha))
        dxDrawRectangle(guiInfo.x + 275/zoom, guiInfo.y + 50/zoom + barY, 4/zoom, barHeight, tocolor(57, 57, 57, 255 * self.alpha))
    else
        dxDrawRectangle(guiInfo.x + 275/zoom, guiInfo.y + 50/zoom, 4/zoom, 200/zoom, tocolor(57, 57, 57, 255 * self.alpha))
    end
end


function AddVehicle:buttonClick(...)
    if exports.TR_dx:isResponseEnabled() then return false end
    if arg[1] == self.buttons.exit then
        self:close()

    elseif arg[1] == self.buttons.submit then
        if not self.selected then exports.TR_noti:create("Bir araç seçmeniz gerekiyor.", "error") return end
        local data = self.vehicles[self.selected]

        exports.TR_dx:setResponseEnabled(true)
        triggerServerEvent("requestVehicleOrgAdd", resourceRoot, data.ID)
    end
end

function AddVehicle:mouseClick(...)
    if exports.TR_dx:isResponseEnabled() then return false end
    if arg[1] == "left" then
        for i = 1, 5 do
            local v = self.vehicles[i + self.scroll]
            if v then
                if self:isMouseInPosition(guiInfo.x, guiInfo.y + 50/zoom + 40/zoom * (i-1), 275/zoom, 40/zoom) then
                    self:selectVehicle(i + self.scroll)
                    break
                end
            end
        end
    end
end

function AddVehicle:selectVehicle(index)
    self.selected = index
end

function AddVehicle:scrollKey(...)
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

function AddVehicle:response(state)
    if state then
        self.scroll = 0
        table.remove(self.vehicles, self.selected)
        exports.TR_noti:create("Araç organizasyon kabul listesine eklendi.", "success")
    else
        exports.TR_noti:create("Araç organizasyona eklenemedi.", "error")
    end
    exports.TR_dx:setResponseEnabled(false)
end


function AddVehicle:drawBackground(x, y, rx, ry, color, radius, post)
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

function AddVehicle:isMouseInPosition(x, y, width, height)
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




exports.TR_dx:setResponseEnabled(false)

function createVehicleOrgAdd(...)
    if guiInfo.window then return end
    guiInfo.window = AddVehicle:create(...)
end
addEvent("createVehicleOrgAdd", true)
addEventHandler("createVehicleOrgAdd", root, createVehicleOrgAdd)

-- createVehicleOrgAdd({{model = 411, ID = 1}})

function responseVehicleOrgAdd(...)
    if not guiInfo.window then return end
    guiInfo.window:response(...)
end
addEvent("responseVehicleOrgAdd", true)
addEventHandler("responseVehicleOrgAdd", root, responseVehicleOrgAdd)