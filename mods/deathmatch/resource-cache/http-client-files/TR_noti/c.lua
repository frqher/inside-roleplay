local createdNotifications = {}

local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local notiSettings = {
  field = {
    w = 400/zoom,

    minW = 60/zoom,

    space = 10/zoom,
    bar = 3/zoom,
    textH = 20/zoom,
    imgSize = 40/zoom,
  },

  images = {},

  fonts = {
    text = exports.TR_dx:getFont(11),
    count = exports.TR_dx:getFont(10),
    title = exports.TR_dx:getBoldFont(12),
  },

  types = {
    ["info"] = {40, 165, 211},
    ["success"] = {41, 157, 28},
    ["error"] = {157, 28, 28},
    ["gps"] = {41, 157, 28},
    ["animate"] = {73, 73, 231},
    ["handshake"] = {0, 175, 128},
    ["heart"] = {251, 82, 82},
    ["trade"] = {251, 212, 82},
    ["system"] = {148, 148, 148},
    ["bike"] = {255, 178, 41},
    ["penalty"] = {171, 31, 29},
    ["repair"] = {255, 178, 41},
    ["money"] = {133, 187, 101},
    ["licence"] = {40, 128, 211},
    ["job"] = {71, 180, 201},
    ["noNetwork"] = {207, 35, 35},
    ["parrot"] = {214, 163, 6},
    ["gift"] = {193, 36, 36},
    ["boat"] = {0, 105, 148},
    ["carwash"] = {38, 169, 224},
  },
}


Notification = {}
Notification.__index = Notification

function Notification:create(...)
  local instance = {}
  setmetatable(instance, Notification)

  if instance:constructor(...) then
    table.insert(createdNotifications, 1, instance)
    return instance
  end
  return false
end

function Notification:constructor(...)
  for i, v in ipairs(createdNotifications) do
    if v:checkNoti(arg[1], arg[2] or "info") then
      v:addRepeated()
      return false
    end
  end

  self:prepareText(arg[1])
  self.type = arg[2] or "info"
  self.time = arg[3] and arg[3] * 1000 or 3000
  self.notHidding = arg[4] or false
  self.img = self:prepareImage(arg[5]) or false
  self.useColor = arg[6] or false

  if type(arg[1]) == "string" then
    outputConsole(string.format("[NOTI] %s", arg[1]))
  end

  --- STATIC VARIABLES ---
  self.element = createElement("dx-noti")
  self.imgSize = self.img and notiSettings.field.imgSize - 10/zoom or 0
  self.textImgMove = self.img and notiSettings.field.imgSize or 0
  self.alpha = 1
  self.count = 1
  self.bar = 1
  self.anim = "show"
  self.tick = getTickCount()
  self.color = notiSettings.types[self.type]
  self.imgColor = {255, 255, 255}

  self.x = -notiSettings.field.w
  self:calculatePosition()
  self:playNotiSound(self.type)

  return true
end

function Notification:drawBackground(x, y, rx, ry, color, radius, post)
  rx = rx - radius * 2
  ry = ry - radius * 2
  x = x + radius
  y = y + radius

  if (rx >= 0) and (ry >= 0) then
    dxDrawRectangle(x - radius, y, rx + radius * 2, ry + radius, color, post)
    dxDrawRectangle(x - radius, y - radius, rx + radius, radius, color, post)

    dxDrawCircle(x + rx, y, radius, 270, 360, color, color, 7, 1, post)
  end
end

function Notification:destroy()
  local index = false
  for i, v in ipairs(createdNotifications) do
    if v:getElement() == self.element then
      index = i
      break
    end
  end

  local _temp = {}
  for i, v in pairs(createdNotifications) do
    if i ~= index then
      table.insert(_temp, v)
    end
  end
  createdNotifications = _temp

  if isElement(self.element) then destroyElement(self.element) end
  self = nil
end

function Notification:hide()
  self.anim = "hide"
  self.tick = getTickCount()

  updatePosition()
end




function Notification:draw()
  self:drawBackground(self.x, self.y, notiSettings.field.w, self.h, tocolor(17, 17, 17, 255 * self.alpha), 5, true)
  dxDrawRectangle(self.x, self.y + self.h - notiSettings.field.bar, notiSettings.field.w, notiSettings.field.bar, tocolor(self.color[1], self.color[2], self.color[3], 100 * self.alpha), true)
  dxDrawRectangle(self.x, self.y + self.h - notiSettings.field.bar, notiSettings.field.w * self.bar, notiSettings.field.bar, tocolor(self.color[1], self.color[2], self.color[3], 255 * self.alpha), true)

  if self.img then
    dxDrawImage(self.x + 10/zoom, self.y + (self.h - notiSettings.field.bar - self.imgSize)/2, self.imgSize, self.imgSize, self.img, 0, 0, 0, tocolor(self.imgColor[1], self.imgColor[2], self.imgColor[3], 255 * self.alpha), true)
  end

  if self.title then
    dxDrawText(self.title, self.x + 10/zoom + self.textImgMove, self.y + 5/zoom, self.x + notiSettings.field.w - 10/zoom, self.y + self.h/2, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, notiSettings.fonts.title, "left", "bottom", true, true, true, self.useColor)
    dxDrawText(self.text, self.x + 10/zoom + self.textImgMove, self.y + self.h/2, self.x + notiSettings.field.w - 10/zoom, self.y + self.h - notiSettings.field.bar - 5/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, notiSettings.fonts.text, "left", "top", true, true, true, self.useColor)
  else
    dxDrawText(self.text, self.x + 10/zoom + self.textImgMove, self.y + 5/zoom, self.x + notiSettings.field.w - 10/zoom, self.y + self.h - notiSettings.field.bar - 5/zoom, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, notiSettings.fonts.text, "left", "center", true, true, true, self.useColor)
  end

  if self.count > 1 then
    dxDrawText("x"..self.count, self.x, self.y, self.x + notiSettings.field.w - 5/zoom, self.y + self.h - notiSettings.field.bar - 2/zoom, tocolor(160, 160, 160, 255 * self.alpha), 1/zoom, notiSettings.fonts.count, "right", "bottom", false, false, true)
  end

  self:animate()
  if not self.notHidding and self.anim == "showing" then self:hidding() end
  if self.lastY then self:reposition() end
end

function Notification:animate()
  if self.anim == "show" then
    local progress = (getTickCount() - self.tick)/400
    self.x, self.alpha = interpolateBetween(-notiSettings.field.w, 0, 0, 0, 1, 0, progress, "OutQuad")

    if progress >= 1 then
      self.x = 0
      self.anim = "showing"
      self.tick = nil

      if not self.barAnim then
        self.barAnim = "decreasing"
        self.bTick = getTickCount()
      end
    end

  elseif self.anim == "hide" then
    local progress = (getTickCount() - self.tick)/400
    self.x, self.alpha = interpolateBetween(0, 1, 0, -notiSettings.field.w, 0, 0, progress, "OutQuad")

    if progress >= 1 then
      self:destroy()
    end
  end

  if self.barAnim == "custom" then
    local progress = (getTickCount() - self.bTick)/self.barTime
    self.bar = interpolateBetween(self.barFrom, 0, 0, self.barTo, 0, 0, progress, "Linear")

    if progress >= 1 then
      self.bar = self.barTo
      self.barAnim = "hideCustom"
      self.bTick = getTickCount()
    end

  elseif self.barAnim == "hideCustom" then
    local progress = (getTickCount() - self.bTick)/self.showTime

    if progress >= 1 then
      self:hide()
      self.barAnim = nil
    end
  end
end

function Notification:reposition()
  local progress = (getTickCount() - self.rTick)/300
  self.y = interpolateBetween(self.lastY, 0, 0, self.toY, 0, 0, progress, "Linear")

  if progress >= 1 then
    self.y = self.toY
    self.lastY = nil
    self.toY = nil
    self.rTick = nil
  end
end

function Notification:hidding()
  if self.barAnim == "decreasing" then
    local progress = (getTickCount() - self.bTick)/self.time
    self.bar = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "Linear")

    if progress >= 1 then
      self:hide()
    end

  elseif self.barAnim == "increasing" then
    local progress = (getTickCount() - self.bTick)/300
    self.bar = interpolateBetween(self.lastBar, 0, 0, 1, 0, 0, progress, "Linear")

    if progress >= 1 then
      self.bar = 1
      self.lastBar = nil
      self.barAnim = "decreasing"
      self.bTick = getTickCount()
    end
  end
end



function Notification:addRepeated()
  self.count = self.count + 1
  self.barAnim = "increasing"

  self.lastBar = self.bar
  self.bTick = getTickCount()

  self:playNotiSound(self.type)
end

function Notification:prepareText(...)
  if type(arg[1]) == "table" then
    self.title = arg[1][1] and arg[1][1] or ""
    self.text = arg[1][2] and arg[1][2] or ""
  else
    self.text = arg[1] and arg[1] or ""
  end
end

function Notification:prepareImage(...)
  if type(arg[1]) == "string" then
    if isElement(arg[1]) then
      return arg[1]

    elseif string.find(arg[1], "/") then
      return arg[1]

    elseif notiSettings.images[arg[1]] then
      return notiSettings.images[arg[1]]

    else
      return self:getImage(arg[1])
    end

  elseif type(arg[1]) == "boolean" or type(arg[1]) == "nil" then
    return self:getImage(self.type)
  end
end

function Notification:getImage(...)
  if fileExists(string.format("files/images/%s.png", arg[1])) then
    notiSettings.images[arg[1]] = dxCreateTexture(string.format("files/images/%s.png", arg[1]), "argb", true, "clamp")
    return notiSettings.images[arg[1]]
  else
    return false
  end
end

function Notification:playNotiSound(...)
  if arg[1] == "gps" then return end

  if arg[1] == "error" then
    playSound("files/sounds/error.mp3")
  else
    playSound("files/sounds/noti.mp3")
  end
end

function Notification:getText()
  return self.text
end

function Notification:setText(...)
  self:prepareText(arg[1])
  self.useColor = arg[2] or false
  return true
end

function Notification:setColor(...)
  self.color = arg[1]
end

function Notification:setBarAnimation(...)
  self.barAnim = "custom"
  self.bTick = getTickCount()

  self.barFrom = arg[1] and arg[1] or 0
  self.barTo = arg[2] and arg[2] or 1
  self.barTime = arg[3] and arg[3] * 1000 * self.barTo or 1000 * self.barTo
  self.showTime = arg[4] and arg[4] * 1000 or 3000

  self.bar = self.barFrom
end

function Notification:setIconColor(...)
  self.imgColor = arg[1]
end

function Notification:getHeight()
  return self.h
end

function Notification:getTextRows()
  local enters = string.gsub(self.text, "\n", "\n ")
  local sentences = split(enters, "\n")
  local textRows = 0

  for i, v in pairs(sentences) do
    local words = split(v, " ")
    local word = 1
    local text = words[1]
    local lastText = ""

    if #words > 0 then
      while (#words > 0) do
        local textLong = dxGetTextWidth(text, 1/zoom, notiSettings.fonts.text)
        if textLong >= (notiSettings.field.w - 20/zoom - self.imgSize) then
          textRows = textRows + 1
          for i = 2, (word + 1) do
            table.remove(words, word - i)
          end
          table.remove(words, 1)
          word = 1
          text = words[1]
          lastText = ""

        else
          word = word + 1
          if not words[word] then textRows = textRows + 1 break end

          lastText = text
          text = text.. " " ..words[word]
        end
      end
    else
      if i ~= #sentences then
        textRows = textRows + 1
      end
    end
  end

  return textRows
end

function Notification:checkNoti(...)
  if self.text == arg[1] and self.type == arg[2] then
    return true
  else
    return false
  end
end

function Notification:getElement()
  return self.element
end

function Notification:calculatePosition()
  self.h = math.max((self:getTextRows() * notiSettings.field.textH) + notiSettings.field.bar + 10/zoom, notiSettings.field.minW)


  local position = sy - 300/zoom
  if getElementInterior(localPlayer) ~= 0 and getElementDimension(localPlayer) ~= 0 or not getElementData(localPlayer, "characterUID") then
    position = sy - 45/zoom - self.h
  end

  local index = false

  if self.anim == "hide" then
    self.y = self.y
    index = self.index
    return
  else
    local k = 1
    for i, v in ipairs(createdNotifications) do
      if v.anim and v.anim ~= "hide" then
        if self.element == v:getElement() then
          index = k
          break

        else
          position = position - v:getHeight()
        end
        k = k + 1
      end
    end
  end

  self.index = index and index or 0
  if self.y then
    self.lastY = self.y
    self.toY = position - notiSettings.field.space * self.index
    self.rTick = getTickCount()
  else
    local y = sy - 300/zoom
    if getElementInterior(localPlayer) ~= 0 or getElementDimension(localPlayer) ~= 0 or not getElementData(localPlayer, "characterUID") then
      y = sy - 45/zoom - self.h
    end
    self.y = y

    self.lastY = self.y
    self.toY = self.y
  end
end



function create(...)
  local noti = Notification:create(...)
  updatePosition()

  return noti and noti.element
end
addEvent("createNoti", true)
addEventHandler("createNoti", root, create)

function destroy(...)
  for i, v in ipairs(createdNotifications) do
    if v:getElement() == arg[1] then
      v:hide(arg[2])
      return true
    end
  end
  return false
end

function setText(...)
  for i, v in ipairs(createdNotifications) do
    if v:getElement() == arg[1] then
      v:setText(arg[2], arg[3])
      return true
    end
  end
  return false
end

function setColor(...)
  for i, v in ipairs(createdNotifications) do
    if v:getElement() == arg[1] then
      v:setColor(arg[2])
      return true
    end
  end
  return false
end

function setBarAnimation(...)
  for i, v in ipairs(createdNotifications) do
    if v:getElement() == arg[1] then
      v:setBarAnimation(arg[2], arg[3], arg[4], arg[5])
      return true
    end
  end
  return false
end


function setIconColor(...)
  for i, v in ipairs(createdNotifications) do
    if v:getElement() == arg[1] then
      v:setIconColor(arg[2])
      return true
    end
  end
  return false
end






function updatePosition()
  for i, v in ipairs(createdNotifications) do
    v:calculatePosition()
  end
end

--- RENDER NOTIFICATIONS ---
function renderNotifications()
  for i, v in pairs(createdNotifications) do
    v:draw()
  end
end
addEventHandler("onClientRender", root, renderNotifications, false, "low-1")