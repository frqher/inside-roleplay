local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 400/zoom)/2,
    y = (sy - 300/zoom)/2,
    w = 400/zoom,
    h = 300/zoom,
}

Exchange = {}
Exchange.__index = Exchange

function Exchange:create(...)
    local instance = {}
    setmetatable(instance, Exchange)
    if instance:constructor(...) then
        return  instance
    end
    return false
end

function Exchange:constructor(...)
    self.alpha = 0

    self.minPrice = arg[1].minPrice
    self.maxPrice = arg[1].maxPrice
    self.marker = arg[2]

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.info = exports.TR_dx:getFont(12)

    self.buttons = {}
    self.edits = {}

    self.func = {}
    self.func.render = function() self:render() end
    self.func.clickButton = function(...) self:clickButton(...) end

    self:open()
    return true
end

function Exchange:open()
    self.state = "opening"
    self.tick = getTickCount()

    exports.TR_dx:setOpenGUI(true)

    self.buttons.cancel = exports.TR_dx:createButton((sx - 250/zoom)/2, guiInfo.y + guiInfo.h - 50/zoom, 250/zoom, 40/zoom, "Anuluj")
    self.buttons.accept = exports.TR_dx:createButton((sx - 250/zoom)/2, guiInfo.y + guiInfo.h - 100/zoom, 250/zoom, 40/zoom, "Wystaw pojazd")
    exports.TR_dx:setButtonVisible(self.buttons, false)
    exports.TR_dx:showButton(self.buttons)

    self.edits.price = exports.TR_dx:createEdit((sx - 250/zoom)/2, guiInfo.y + guiInfo.h - 180/zoom, 250/zoom, 40/zoom, "Cena pojazdu")
    exports.TR_dx:setEditVisible(self.edits.price, false)
    exports.TR_dx:showEdit(self.edits.price)

    showCursor(true)

    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("guiButtonClick", root, self.func.clickButton)
end


function Exchange:close()
    if self.state ~= "opened" then return end
    self.state = "closing"
    self.tick = getTickCount()

    exports.TR_dx:hideButton(self.buttons)
    exports.TR_dx:hideEdit(self.edits)

    showCursor(false)
    removeEventHandler("guiButtonClick", root, self.func.clickButton)
end

function Exchange:destroy()
    exports.TR_dx:setOpenGUI(false)

    removeEventHandler("onClientRender", root, self.func.render)

    exports.TR_dx:destroyButton(self.buttons)
    exports.TR_dx:destroyEdit(self.edits)

    guiInfo.guiInfo = nil
    self = nil
end


function Exchange:animate()
    if not self.tick then return end
    local progress = (getTickCount() - self.tick)/500

    if self.state == "opening" then
      self.alpha = interpolateBetween(self.alpha, 0, 0, 1, 0, 0, progress, "Linear")
      if progress >= 1 then
        self.alpha = 1
        self.state = "opened"
        self.tick = nil
      end

    elseif self.state == "closing" then
      self.alpha = interpolateBetween(self.alpha, 0, 0, 0, 0, 0, progress, "Linear")
      if progress >= 1 then
        self.alpha = 0
        self.state = "closed"
        self.tick = nil

        self:destroy()
        return true
      end
    end
end

function Exchange:render()
    self:animate()
    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 4)
    dxDrawText("Araç Değişimi", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")

    dxDrawText("Aracı pazarda listelemek istediğiniz fiyatı girin.", guiInfo.x + 10/zoom, guiInfo.y + 50/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h - 50/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "top", true, true)

    if self.marker then
        if not isElementWithinMarker(localPlayer, self.marker) then self:close() end
    end
end


function Exchange:clickButton(...)
    if arg[1] == self.buttons.cancel then
        self:close()

    elseif arg[1] == self.buttons.accept then
        self:proceed()
    end
end

function Exchange:proceed()
    if self.state ~= "opened" then return end
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return end

    local text = guiGetText(self.edits.price)
    if tonumber(text) == nil then return exports.TR_noti:create("Girilen fiyat hatalı.", "error") end

    local price = math.floor(tonumber(text) * 100)/100
    if price == 0 then return exports.TR_noti:create("Girilen fiyat çok düşük.", "error") end
    if price < self.minPrice then return exports.TR_noti:create("Girilen fiyat çok düşük.", "error") end
    if price > self.maxPrice then return exports.TR_noti:create("Girilen fiyat çok yüksek.", "error") end

    exports.TR_noti:create("Araç başarıyla listelendi. Boş bir yere park edin.", "success")
    triggerServerEvent("setVehicleOnExchange", resourceRoot, veh, price)
    self:close()
end

function Exchange:drawBackground(x, y, rx, ry, color, radius, post)
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

exports.TR_dx:setOpenGUI(false)
function openExchangeWindow(data, marker)
    if not exports.TR_dx:canOpenGUI() then return end

    if guiInfo.window then return end
    guiInfo.guiInfo = Exchange:create(data, marker)
end
addEvent("openExchangeWindow", true)
addEventHandler("openExchangeWindow", root, openExchangeWindow)