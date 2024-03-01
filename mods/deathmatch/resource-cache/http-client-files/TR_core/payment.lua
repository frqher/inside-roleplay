local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local settings = {
  x = (sx - 600/zoom)/2,
  y = (sy - 450/zoom)/2,
  w = 600/zoom,
  h = 450/zoom,

  fonts = {
    title = exports.TR_dx:getFont(16),
    amount = exports.TR_dx:getFont(14),
  },
}

Payment = {}
Payment.__index = Payment

function Payment:create(...)
  local instance = {}
  setmetatable(instance, Payment)

  if instance:constructor(...) then
    return instance
  end
  return false
end

function Payment:constructor(amount, bankmoney, trigger, ...)
  self.amount = amount
  self.plrCash = tonumber(getElementData(localPlayer, "characterData").money)
  self.plrBankmoney = bankmoney >= 0 and bankmoney or false
  self.trigger = trigger
  self.data = unpack({...})

  self.cash = dxCreateTexture("files/images/cash.png", "argb", true, "clamp")
  self.credit = dxCreateTexture("files/images/credit.png", "argb", true, "clamp")
  self.back = dxCreateTexture("files/images/close.png", "argb", true, "clamp")

  -- Static
  self.alpha = 0
  self.animState = "opening"
  self.tick = getTickCount()

  showCursor(true)
  self.func = {}
  self.func.render = function() self:render() end
  self.func.click = function(...) self:click(...) end
  addEventHandler("onClientRender", root, self.func.render)
  addEventHandler("onClientClick", root, self.func.click)
  return true
end

function Payment:destroy()
  removeEventHandler("onClientRender", root, self.func.render)
  removeEventHandler("onClientClick", root, self.func.click)

  destroyElement(self.cash)
  destroyElement(self.credit)
  destroyElement(self.back)

  showCursor(false)
  settings.opened = nil
  self = nil
end

function Payment:close()
  self.animState = "closing"
  self.tick = getTickCount()
end


function Payment:render(...)
  dxDrawRectangle(0, 0, sx, sy, tocolor(7, 7, 7, 100 * self.alpha), true)
  self:drawBackground(settings.x, settings.y, settings.w, settings.h, tocolor(17, 17, 17, 255 * self.alpha), 5, true)

  dxDrawText("Ödeme yönteminizi seçin", settings.x, settings.y + 20/zoom, settings.x + settings.w, settings.y + settings.h, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, settings.fonts.title, "center", "top", false, false, true)
  if self.amount == 0 then
    dxDrawText("Ücretsiz", settings.x, settings.y + 50/zoom, settings.x + settings.w, settings.y + settings.h, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, settings.fonts.amount, "center", "top", false, false, true)
  else
    dxDrawText(string.format("$%.2f öde", self.amount), settings.x, settings.y + 50/zoom, settings.x + settings.w, settings.y + settings.h, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, settings.fonts.amount, "center", "top", false, false, true)
  end

  self:renderPayment(settings.x + 20/zoom, "Nakit", self.cash, self.plrCash)
  self:renderPayment(settings.x + settings.w - 290/zoom, "Kart", self.credit, self.plrBankmoney)
  self:renderCancel()

  self:renderAnim()
end

function Payment:renderAnim()
  if self.animState == "opening" then
    local progress = (getTickCount() - self.tick)/300
    self.alpha = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "Linear")
    if progress >= 1 then
      self.tick = nil
      self.animState = "opened"
    end

  elseif self.animState == "closing" then
    local progress = (getTickCount() - self.tick)/300
    self.alpha = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "Linear")
    if progress >= 1 then
      self:destroy()
    end
  end
end

function Payment:renderCancel()
  local alpha = 170
  if self:isMouseInPosition(settings.x + 203/zoom, settings.y + settings.h - 47/zoom, 195/zoom, 26/zoom) then
    alpha = 220
  end
  dxDrawImage(settings.x + 203/zoom, settings.y + settings.h - 47/zoom, 26/zoom, 26/zoom, self.back, 0, 0, 0, tocolor(200, 200, 200, alpha * self.alpha), true)
  dxDrawText("İşlemleri iptal et", settings.x + 238/zoom, settings.y + settings.h - 50/zoom, settings.x + settings.w, settings.y + settings.h - 18/zoom, tocolor(231, 110, 84, alpha * self.alpha), 1/zoom, settings.fonts.amount, "left", "center", false, false, true)
end

function Payment:renderPayment(x, name, img, amount)
  local alpha = 255
  if not amount or amount < self.amount then alpha = 150 end
  if self:isMouseInPosition(x, settings.y + 90/zoom, 270/zoom, 290/zoom) and amount and amount >= self.amount then
    self:drawBackground(x, settings.y + 90/zoom, 270/zoom, 290/zoom, tocolor(37, 37, 37, alpha * self.alpha), 5, true)
  else
    self:drawBackground(x, settings.y + 90/zoom, 270/zoom, 290/zoom, tocolor(27, 27, 27, alpha * self.alpha), 5, true)
  end
  dxDrawImage(x + 71/zoom, settings.y + 120/zoom, 128/zoom, 128/zoom, img, 0, 0, 0, tocolor(255, 255, 255, alpha * self.alpha), true)

  dxDrawText(name, x, settings.y + 300/zoom, x + 270/zoom, settings.y + settings.h - 20/zoom, tocolor(200, 200, 200, alpha * self.alpha), 1/zoom, settings.fonts.title, "center", "top", false, false, true)
  if amount then
    dxDrawText(string.format("$%.2f", amount), x, settings.y + 330/zoom, x + 270/zoom, settings.y + settings.h - 20/zoom, tocolor(212, 175, 55, alpha * self.alpha), 1/zoom, settings.fonts.amount, "center", "top", false, false, true)
  else
    dxDrawText("Kart yok", x, settings.y + 330/zoom, x + 270/zoom, settings.y + settings.h - 20/zoom, tocolor(212, 175, 55, alpha * self.alpha), 1/zoom, settings.fonts.amount, "center", "top", false, false, true)
  end
end

function Payment:click(...)
  if arg[1] == "left" and arg[2] == "down" and self.animState == "opened" then
    if self:isMouseInPosition(settings.x + 20/zoom, settings.y + 90/zoom, 270/zoom, 290/zoom) then
      if self.plrCash < self.amount then return end
      self:performClick("cash")

    elseif self:isMouseInPosition(settings.x + settings.w - 290/zoom, settings.y + 90/zoom, 270/zoom, 290/zoom) then
      if not self.plrBankmoney then return end
      if self.plrBankmoney < self.amount then return end
      self:performClick("card")

    elseif self:isMouseInPosition(settings.x + 203/zoom, settings.y + settings.h - 47/zoom, 195/zoom, 26/zoom) then
      self:performCancel()
    end
  end
end

function Payment:performClick(...)
  if arg[1] == "cash" then
    self.plrCash = self.plrCash - self.amount
  elseif arg[1] == "card" then
    self.plrBankmoney = self.plrBankmoney - self.amount
  end
  triggerServerEvent("performPayment", resourceRoot, arg[1], self.amount, self.trigger, self.data)
  self:close()
end

function Payment:performCancel(...)
  triggerServerEvent("cancelPayment", resourceRoot, self.trigger, self.data)
  self:close()
end

function Payment:drawBackground(x, y, rx, ry, color, radius, post)
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


function Payment:isMouseInPosition(x, y, width, height)
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

function createPaymentScreen(...)
  if settings.opened then return end
  settings.opened = true

  settings.payment = Payment:create(...)
  exports.TR_dx:setResponseEnabled(true, "İşlem kabul ediliyor")
end
addEvent("createPaymentScreen", true)
addEventHandler("createPaymentScreen", root, createPaymentScreen)

function isPaymentOpened()
  return settings.opened
end