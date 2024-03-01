local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 500/zoom)/2,
    y = (sy - 200/zoom)/2,
    w = 500/zoom,
    h = 200/zoom,
}

FixAccept = {}
FixAccept.__index = FixAccept

function FixAccept:create(...)
    local instance = {}
    setmetatable(instance, FixAccept)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function FixAccept:constructor(...)
    self.alpha = 0
    self.mechanic = arg[1]
    self.toFix = arg[2]
    self.price = arg[3] + arg[4]
    self.addon = arg[4]

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.parts = exports.TR_dx:getFont(12)

    self.buttons = {}
    self.buttons.exit = exports.TR_dx:createButton(guiInfo.x + 10/zoom, guiInfo.y + guiInfo.h - 50/zoom, 235/zoom, 40/zoom, "Anuluj")
    self.buttons.repair = exports.TR_dx:createButton(guiInfo.x + guiInfo.w - 245/zoom, guiInfo.y + guiInfo.h - 50/zoom, 235/zoom, 40/zoom, string.format("Onayla ($%.2f)", self.price))
    exports.TR_dx:setButtonVisible(self.buttons, false)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.buttonClick = function(...) self:buttonClick(...) end

    self.timer = setTimer(function()
      self:close()
      triggerServerEvent("declineVehicleFix", resourceRoot, self.mechanic)
    end, 15000, 1)

    self:prepareFixText()
    self:open()
    return true
end

function FixAccept:prepareFixText()
  self.parts = ""
  for i, v in pairs(self.toFix) do
    self.parts = self.parts .. v.name .. ", "
  end
  self.parts = self.parts .. string.format("Peşinat: $%.2f.", self.addon)
end


function FixAccept:open()
    self.state = "opening"
    self.tick = getTickCount()

    exports.TR_dx:showButton(self.buttons)

    showCursor(true)
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("guiButtonClick", root, self.func.buttonClick)
end

function FixAccept:close()
    self.state = "closing"
    self.tick = getTickCount()

    exports.TR_dx:hideButton(self.buttons)

    if isTimer(self.timer) then killTimer(self.timer) end
    showCursor(false)
    removeEventHandler("guiButtonClick", root, self.func.buttonClick)
end

function FixAccept:destroy()
    exports.TR_dx:setOpenGUI(false)
    exports.TR_dx:destroyButton(self.buttons)
    removeEventHandler("onClientRender", root, self.func.render)
    guiInfo.accept = nil
    self = nil
end


function FixAccept:animate()
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

function FixAccept:render()
    self:animate()
    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 5)
    dxDrawText("Onarım ücreti", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")
    dxDrawText(self.parts, guiInfo.x + 10/zoom, guiInfo.y + 50/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h - 60/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.parts, "center", "top", true, true)
end

function FixAccept:buttonClick(...)
  if arg[1] == self.buttons.exit then
    self:close()
    triggerServerEvent("declineVehicleFix", resourceRoot, self.mechanic)

  elseif arg[1] == self.buttons.repair then
    triggerServerEvent("createPayment", resourceRoot, self.price, "playerPayForVehicleFix", {self.mechanic, self.price, self.addon, self.toFix})
    if isTimer(self.timer) then killTimer(self.timer) end
  end
end

function FixAccept:reponse(...)
  if arg[1] then
    self:close()
  else
    self.timer = setTimer(function()
      self:close()
      triggerServerEvent("declineVehicleFix", resourceRoot, self.mechanic)
    end, 15000, 1)
  end
  exports.TR_dx:setResponseEnabled(false)
end

function FixAccept:drawBackground(x, y, rx, ry, color, radius, post)
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

function openFixAccept(...)
    if guiInfo.accept then return end
    guiInfo.accept = FixAccept:create(...)
end
addEvent("openFixAccept", true)
addEventHandler("openFixAccept", root, openFixAccept)

function vehicleFixResponse(...)
    if not guiInfo.accept then return end
    guiInfo.accept:reponse(...)
end
addEvent("vehicleFixResponse", true)
addEventHandler("vehicleFixResponse", root, vehicleFixResponse)



function canBeFixed(vehicle)
  local jobID = exports.TR_jobs:getPlayerJob()
  local vehPos = Vector3(getElementPosition(vehicle))
  local selectedPosition = false

  for i, v in pairs(getElementsByType("mechanicPosition", resourceRoot, true)) do
    local mechanicPosition = getElementData(v, "mechanicPosition")
    if mechanicPosition.jobID == jobID and mechanicPosition.mechanic == localPlayer then
      local dist = getDistanceBetweenPoints3D(vehPos, Vector3(getElementPosition(v)))
      if dist < 2 then
        return true
      end
      return false
    end
  end
  return false
end