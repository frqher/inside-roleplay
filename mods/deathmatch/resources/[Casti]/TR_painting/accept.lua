local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 500/zoom)/2,
    y = (sy - 320/zoom),
    w = 500/zoom,
    h = 300/zoom,
}

PaintAccept = {}
PaintAccept.__index = PaintAccept

function PaintAccept:create(...)
    local instance = {}
    setmetatable(instance, PaintAccept)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function PaintAccept:constructor(...)
  self.alpha = 0
  self.mechanic = arg[1]

  self.colorSlide = 0
  self.colorPicker = Vector2(0, 0)
  self.colorCurrent = {255, 0, 0}
  self.selectedTab = 0

  self.defaultColors = {getVehicleColor(getPedOccupiedVehicle(localPlayer), true)}
  self.vehColors = {getVehicleColor(getPedOccupiedVehicle(localPlayer), true)}

  self.edit = exports.TR_dx:createEdit(guiInfo.x + guiInfo.w - 110/zoom, guiInfo.y + guiInfo.h - 110/zoom, 100/zoom, 40/zoom, "HEX koloru")
  exports.TR_dx:setEditLimit(self.edit, 7)
  exports.TR_dx:setEditVisible(self.edit, false)
  exports.TR_dx:showEdit(self.edit)

  self.fonts = {}
  self.fonts.main = exports.TR_dx:getFont(14)
  self.fonts.color = exports.TR_dx:getFont(12)
  self.fonts.category = exports.TR_dx:getFont(11)
  self.fonts.info = exports.TR_dx:getFont(9)

  self.sv = dxCreateTexture("files/images/sv.png", "argb", true, "clamp")
  self.h = dxCreateTexture("files/images/h.png", "argb", true, "clamp")

  self.buttons = {}
  self.buttons.exit = exports.TR_dx:createButton(guiInfo.x + 10/zoom, guiInfo.y + guiInfo.h - 50/zoom, 235/zoom, 40/zoom, "İptal")
  self.buttons.repair = exports.TR_dx:createButton(guiInfo.x + guiInfo.w - 245/zoom, guiInfo.y + guiInfo.h - 50/zoom, 235/zoom, 40/zoom, "Boya onayla")
  exports.TR_dx:setButtonVisible(self.buttons, false)

  self.func = {}
  self.func.render = function() self:render() end
  self.func.mouseClick = function(...) self:mouseClick(...) end
  self.func.buttonClick = function(...) self:buttonClick(...) end
  self.func.mouseRotator = function(...) self:mouseRotator(...) end

  self:open()
  self:selectTab(0)
  return true
end


function PaintAccept:open()
    self.state = "opening"
    self.tick = getTickCount()

    exports.TR_dx:showButton(self.buttons)

    bindKey("mouse2", "both", self.func.mouseRotator)

    showCursor(true)
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientClick", root, self.func.mouseClick)
    addEventHandler("guiButtonClick", root, self.func.buttonClick)
end

function PaintAccept:close()
    self.state = "closing"
    self.tick = getTickCount()

    exports.TR_dx:hideButton(self.buttons)
    exports.TR_dx:hideEdit(self.edit)

    unbindKey("mouse2", "both", self.func.mouseRotator)

    if isTimer(self.timer) then killTimer(self.timer) end
    showCursor(false)
    removeEventHandler("onClientClick", root, self.func.mouseClick)
    removeEventHandler("guiButtonClick", root, self.func.buttonClick)
end

function PaintAccept:destroy()
    exports.TR_dx:setOpenGUI(false)
    exports.TR_dx:destroyButton(self.buttons)
    exports.TR_dx:destroyEdit(self.edit)
    removeEventHandler("onClientRender", root, self.func.render)

    guiInfo.accept = nil
    self = nil
end


function PaintAccept:animate()
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

function PaintAccept:render()
  if self:animate() then return end
  self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 5)
  dxDrawText("Araç Boyama", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")

  self:drawColorPicker()
  self:drawColors()
end

function PaintAccept:drawColors()
  for color = 0, 3 do
      if color == self.selectedTab then
          dxDrawRectangle(guiInfo.x + guiInfo.w - 105/zoom, guiInfo.y + 50/zoom + 32/zoom * color, 95/zoom, 32/zoom, tocolor(32, 32, 32, 255 * self.alpha))
      elseif self:isMouseInPosition(guiInfo.x + guiInfo.w - 105/zoom, guiInfo.y + 50/zoom + 32/zoom * color, 95/zoom, 32/zoom) then
          dxDrawRectangle(guiInfo.x + guiInfo.w - 105/zoom, guiInfo.y + 50/zoom + 32/zoom * color, 95/zoom, 32/zoom, tocolor(27, 27, 27, 255 * self.alpha))
      end
      if color == 2 then
          dxDrawText("Rantlar", guiInfo.x + guiInfo.w - 25/zoom, guiInfo.y + 55/zoom + 32/zoom * color, guiInfo.x + guiInfo.w - 20/zoom, guiInfo.y + 75/zoom + 32/zoom * color, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.category, "right", "center")
      elseif color == 3 then
          dxDrawText("Jantlar", guiInfo.x + guiInfo.w - 25/zoom, guiInfo.y + 55/zoom + 32/zoom * color, guiInfo.x + guiInfo.w - 20/zoom, guiInfo.y + 75/zoom + 32/zoom * color, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.category, "right", "center")
      else
          dxDrawText("Renk "..(color + 1), guiInfo.x + guiInfo.w - 25/zoom, guiInfo.y + 55/zoom + 32/zoom * color, guiInfo.x + guiInfo.w - 20/zoom, guiInfo.y + 75/zoom + 32/zoom * color, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.category, "right", "center")
      end
      dxDrawRectangle(guiInfo.x + guiInfo.w - 100/zoom, guiInfo.y + 55/zoom + 32/zoom * color, 22/zoom, 22/zoom, tocolor(self.vehColors[color * 3 + 1], self.vehColors[color * 3 + 2], self.vehColors[color * 3 + 3], 255 * self.alpha))
  end
end


function PaintAccept:drawColorPicker()
    dxDrawRectangle(guiInfo.x + 20/zoom, guiInfo.y + 55/zoom, 180/zoom, 180/zoom, tocolor(self.colorCurrent[1], self.colorCurrent[2], self.colorCurrent[3], 255 * self.alpha))
    dxDrawImage(guiInfo.x + 20/zoom, guiInfo.y + 55/zoom, 180/zoom, 180/zoom, self.sv, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
    -- dxDrawText("Koszt malowania jednego koloru wynosi $200.", guiInfo.x + guiInfo.w - 170/zoom, guiInfo.y + guiInfo.h - 120/zoom, guiInfo.x + guiInfo.w - 14/zoom, guiInfo.y + guiInfo.h - 70/zoom, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.info, "right", "bottom", true, true)

    self:calculateMouse()
    dxDrawImage(guiInfo.x + 213/zoom, guiInfo.y + 55/zoom, 22/zoom, 180/zoom, self.h, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
    dxDrawImageSection(guiInfo.x + 200/zoom, guiInfo.y + 49/zoom + self.colorSlide, 48/zoom, 16/zoom, 16, 0, 48, 16, "files/images/cursor.png", 0, 0, 0, tocolor(self.colorCurrent[1], self.colorCurrent[2], self.colorCurrent[3], 255 * self.alpha))
    dxDrawImageSection(guiInfo.x + 12/zoom + self.colorPicker.x, guiInfo.y + 47/zoom + self.colorPicker.y, 16/zoom, 16/zoom, 0, 16, 16, 16, "files/images/cursor.png", 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))

    local h, s, v = (176/zoom - self.colorSlide)/(176/zoom), (self.colorPicker.x)/(180/zoom), (180/zoom - self.colorPicker.y)/(180/zoom)
    local r, g, b = self:hsv2rgb(h, s, v)

    if self.selectedColor then
      local text = guiGetText(self.edit)

      if r ~= self.selectedColor[1] or g ~= self.selectedColor[2] or b ~= self.selectedColor[3] then
        exports.TR_dx:setEditText(self.edit, self:RGBToHex(r, g, b))

      else
        if string.len(text) == 7 then
          local nR, nG, nB = self:hex2rgb(text)
          if nR and nG and nB then
            r, g, b = nR, nG, nB

            local h, s, v = self:rgbToHsv(r, g, b)
            self.colorSlide = (1 - h) * 176/zoom
            self.colorPicker = Vector2(s * (180/zoom), (180/zoom) - v * (180/zoom))

            local r, g, b = self:hsv2rgb(h, 1, 1)
            self.colorCurrent = {r, g, b}
          end
        end
      end
    end

    self.selectedColor = {r, g, b}
    self.vehColors[self.selectedTab * 3 + 1] = r
    self.vehColors[self.selectedTab * 3 + 2] = g
    self.vehColors[self.selectedTab * 3 + 3] = b

    dxDrawRectangle(guiInfo.x + 250/zoom, guiInfo.y + 55/zoom, 40/zoom, 40/zoom, tocolor(r, g, b, 255 * self.alpha))

    dxDrawText("R: ", guiInfo.x + 250/zoom, guiInfo.y + 100/zoom, guiInfo.x + 250/zoom, guiInfo.y + 100/zoom, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.color, "left", "top")
    dxDrawText("G: ", guiInfo.x + 250/zoom, guiInfo.y + 120/zoom, guiInfo.x + 250/zoom, guiInfo.y + 100/zoom, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.color, "left", "top")
    dxDrawText("B: ", guiInfo.x + 250/zoom, guiInfo.y + 140/zoom, guiInfo.x + 250/zoom, guiInfo.y + 100/zoom, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.color, "left", "top")
    dxDrawText(r, guiInfo.x + 270/zoom, guiInfo.y + 100/zoom, guiInfo.x + 250/zoom, guiInfo.y + 100/zoom, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.color, "left", "top")
    dxDrawText(g, guiInfo.x + 270/zoom, guiInfo.y + 120/zoom, guiInfo.x + 250/zoom, guiInfo.y + 100/zoom, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.color, "left", "top")
    dxDrawText(b, guiInfo.x + 270/zoom, guiInfo.y + 140/zoom, guiInfo.x + 250/zoom, guiInfo.y + 100/zoom, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.color, "left", "top")

    dxDrawText("H:", guiInfo.x + 250/zoom, guiInfo.y + 170/zoom, guiInfo.x + 250/zoom, guiInfo.y + 100/zoom, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.color, "left", "top")
    dxDrawText("S:", guiInfo.x + 250/zoom, guiInfo.y + 190/zoom, guiInfo.x + 250/zoom, guiInfo.y + 100/zoom, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.color, "left", "top")
    dxDrawText("V:", guiInfo.x + 250/zoom, guiInfo.y + 210/zoom, guiInfo.x + 250/zoom, guiInfo.y + 100/zoom, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.color, "left", "top")
    dxDrawText(math.floor(h*100).."%", guiInfo.x + 270/zoom, guiInfo.y + 170/zoom, guiInfo.x + 250/zoom, guiInfo.y + 100/zoom, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.color, "left", "top")
    dxDrawText(math.floor(s*100).."%", guiInfo.x + 270/zoom, guiInfo.y + 190/zoom, guiInfo.x + 250/zoom, guiInfo.y + 100/zoom, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.color, "left", "top")
    dxDrawText(math.floor(v*100).."%", guiInfo.x + 270/zoom, guiInfo.y + 210/zoom, guiInfo.x + 250/zoom, guiInfo.y + 100/zoom, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.color, "left", "top")

    if self.state == "closing" or self.state == "closed" then
      setVehicleColor(getPedOccupiedVehicle(localPlayer), unpack(self.defaultColors))
    else
      setVehicleColor(getPedOccupiedVehicle(localPlayer), unpack(self.vehColors))
    end
end

function PaintAccept:calculateMouse()
    if self.mouseSelected == "hue" then
        local cx, cy = getCursorPosition()
        cx, cy = cx * sx, cy * sy

        self.colorSlide = math.max(math.min(cy - (guiInfo.y + 55/zoom), 176/zoom), 0)

        local r, g, b = self:hsv2rgb((176/zoom - self.colorSlide)/(176/zoom), 1, 1)
        self.colorCurrent = {r, g, b}

    elseif self.mouseSelected == "color" then
        local cx, cy = getCursorPosition()
        cx, cy = cx * sx, cy * sy

        self.colorPicker = Vector2(
            math.max(math.min(cx - (guiInfo.x + 20/zoom), 180/zoom), 0),
            math.max(math.min(cy - (guiInfo.y + 55/zoom), 180/zoom), 0)
        )
    end
end

function PaintAccept:mouseRotator(btn, state)
  if state == "up" then
    showCursor(true)
    setElementFrozen(getPedOccupiedVehicle(localPlayer), false)
    toggleControl("enter_exit", true)

  elseif state == "down" then
    showCursor(false)
    setElementFrozen(getPedOccupiedVehicle(localPlayer), true)
    toggleControl("enter_exit", false)
  end
end

function PaintAccept:mouseClick(...)
    if arg[1] == "left" and arg[2] == "down" then
        if self:isMouseInPosition(guiInfo.x + 213/zoom, guiInfo.y + 55/zoom, 22/zoom, 180/zoom) then
            self.mouseSelected = "hue"

        elseif self:isMouseInPosition(guiInfo.x + 20/zoom, guiInfo.y + 55/zoom, 180/zoom, 180/zoom) then
            self.mouseSelected = "color"

        else
            for color = 0, 3 do
                if self:isMouseInPosition(guiInfo.x + guiInfo.w - 105/zoom, guiInfo.y + 50/zoom + 32/zoom * color, 95/zoom, 32/zoom) then
                    self:selectTab(color)
                    break
                end
            end
        end

    elseif arg[1] == "left" and arg[2] == "up" then
        self.mouseSelected = nil
    end
end

function PaintAccept:selectTab(tab)
    self.selectedTab = tab

    local h, s, v = self:rgb2hsv(self.vehColors[tab * 3 + 1], self.vehColors[tab * 3 + 2], self.vehColors[tab * 3 + 3])
    local r, g, b = self:hsv2rgb(h, 1, 1)

    self.colorCurrent = {r, g, b}
    self.colorSlide = math.max(math.min((1 - h) * 176/zoom, 176/zoom), 0)
    self.colorPicker = Vector2(
        math.max(math.min(s * 180/zoom, 180/zoom), 0),
        math.max(math.min(180/zoom - v * 180/zoom, 180/zoom), 0)
    )
end

function PaintAccept:buttonClick(...)
  if arg[1] == self.buttons.exit then
      self:close()
      triggerServerEvent("declineVehiclePaint", resourceRoot, self.mechanic)
  elseif arg[1] == self.buttons.repair then
      local changedColors = 0
      for color = 0, 3 do
          if self.vehColors[color * 3 + 1] ~= self.defaultColors[color * 3 + 1] or self.vehColors[color * 3 + 2] ~= self.defaultColors[color * 3 + 2] or self.vehColors[color * 3 + 3] ~= self.defaultColors[color * 3 + 3] then
              changedColors = changedColors + 1
          end
      end
      if changedColors == 0 then
          exports.TR_noti:create("Değiştirmek istediğiniz bir renk seçiniz.", "error")
          return
      end
      triggerServerEvent("createPayment", resourceRoot, changedColors * 200, "playerPayForVehiclePaint", {self.mechanic, self.vehColors})
  end
end


function PaintAccept:response(...)
  if arg[1] then
    self:close()
  end
  exports.TR_dx:setResponseEnabled(false)
end

function PaintAccept:drawBackground(x, y, rx, ry, color, radius, post)
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

function PaintAccept:rgb2hsv(r, g, b)
    r, g, b = r/255, g/255, b/255
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s
    local v = max
    local d = max - min
    s = max == 0 and 0 or d/max
    if max == min then
      h = 0
    elseif max == r then
      h = (g - b) / d + (g < b and 6 or 0)
    elseif max == g then
      h = (b - r) / d + 2
    elseif max == b then
      h = (r - g) / d + 4
    end
    h = h/6
    return h, s, v
  end

function PaintAccept:hsv2rgb(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    local switch = i % 6
    if switch == 0 then
      r = v g = t b = p
    elseif switch == 1 then
      r = q g = v b = p
    elseif switch == 2 then
      r = p g = v b = t
    elseif switch == 3 then
      r = p g = q b = v
    elseif switch == 4 then
      r = t g = p b = v
    elseif switch == 5 then
      r = v g = p b = q
    end
    return math.floor(r*255), math.floor(g*255), math.floor(b*255)
end

function PaintAccept:rgbToHsv(r, g, b)
  r, g, b = r / 255, g / 255, b / 255
  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s, v
  v = max

  local d = max - min
  if max == 0 then s = 0 else s = d / max end

  if max == min then
    h = 0 -- achromatic
  else
    if max == r then
    h = (g - b) / d
    if g < b then h = h + 6 end
    elseif max == g then h = (b - r) / d + 2
    elseif max == b then h = (r - g) / d + 4
    end
    h = h / 6
  end

  return h, s, v
end

function PaintAccept:RGBToHex(red, green, blue)
	if( ( red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255 ) or ( alpha and ( alpha < 0 or alpha > 255 ) ) ) then
		return nil
	end
	return string.format("#%.2X%.2X%.2X", red, green, blue)
end

function PaintAccept:hex2rgb(hex)
  hex = hex:gsub("#","")
  return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

function PaintAccept:isMouseInPosition(x, y, width, height)
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


function openPaintingAccept(...)
    if guiInfo.accept then return end
    guiInfo.accept = PaintAccept:create(...)
end
addEvent("openPaintingAccept", true)
addEventHandler("openPaintingAccept", root, openPaintingAccept)

function responsePaintingAccept(...)
    if not guiInfo.accept then return end
    guiInfo.accept:response(...)
end
addEvent("responsePaintingAccept", true)
addEventHandler("responsePaintingAccept", root, responsePaintingAccept)

-- exports.TR_dx:setResponseEnabled(false)
-- exports.TR_dx:setOpenGUI(false)
-- openPaintingAccept(localPlayer)
-- setElementData(localPlayer, "blockAction", nil)