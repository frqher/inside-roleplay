local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 128/zoom)/2,
    y = (sy - 128/zoom)/2,
    w = 128/zoom,
    h = 128/zoom,
}

EggOpener = {}
EggOpener.__index = EggOpener

function EggOpener:create(...)
    local instance = {}
    setmetatable(instance, EggOpener)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function EggOpener:constructor(...)
    self.selectedEgg = nil
    self.itemID = arg[1]

    self.fonts = {}
    self.fonts.title = exports.TR_dx:getFont(14)
    self.fonts.info = exports.TR_dx:getFont(10)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.click = function(...) self:click(...) end

    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientClick", root, self.func.click)
    return true
end

function EggOpener:render()
    self:drawBackground(guiInfo.x - guiInfo.w - 30/zoom, guiInfo.y - 50/zoom, guiInfo.w * 3 + 60/zoom, guiInfo.h + 95/zoom, tocolor(17, 17, 17, 255), 4)
    dxDrawText("Yumurta Seç", guiInfo.x - guiInfo.w - 30/zoom, guiInfo.y - 50/zoom, guiInfo.x - guiInfo.w - 30/zoom + guiInfo.w * 3 + 60/zoom, guiInfo.y - 10/zoom, tocolor(212, 175, 55, 255), 1/zoom, self.fonts.title, "center", "center", false, false, false)
    dxDrawText("Ödül almak için bir yumurta seçin ve içinden çıkan ödülü alın.", guiInfo.x - guiInfo.w - 30/zoom, guiInfo.y - 50/zoom, guiInfo.x - guiInfo.w - 30/zoom + guiInfo.w * 3 + 60/zoom, guiInfo.y + guiInfo.h + 35/zoom, tocolor(170, 170, 170, 255), 1/zoom, self.fonts.info, "center", "bottom", true, true, false)

    self:renderEgg(guiInfo.x - guiInfo.w - 20/zoom, 1)
    self:renderEgg(guiInfo.x, 2)
    self:renderEgg(guiInfo.x + guiInfo.w + 20/zoom, 3)
end



function EggOpener:renderEgg(x, eggID)
    if self:isMouseInPosition(x, guiInfo.y, guiInfo.w, guiInfo.h) and not self.selectedEgg then
        dxDrawImage(x, guiInfo.y, guiInfo.w, guiInfo.h, "files/images/egg.png", 0, 0, 0, tocolor(255, 255, 255, 255))

    elseif self.selectedEgg == eggID then
        dxDrawImage(x, guiInfo.y, guiInfo.w, guiInfo.h, "files/images/egg.png", 0, 0, 0, tocolor(255, 255, 255, 255))

    else
        dxDrawImage(x, guiInfo.y, guiInfo.w, guiInfo.h, "files/images/egg.png", 0, 0, 0, tocolor(255, 255, 255, 180))
    end
end


function EggOpener:click(...)
    if arg[1] ~= "left" or not arg[2] or self.selectedEgg then return end

    self:checkEggClick(guiInfo.x - guiInfo.w - 20/zoom, 1)
    self:checkEggClick(guiInfo.x, 2)
    self:checkEggClick(guiInfo.x + guiInfo.w + 20/zoom, 3)

    if self.selectedEgg then
        local type, value = self:getEggPrize()
        triggerServerEvent("giveEggPrize", resourceRoot, self.itemID, type, value)

        removeEventHandler("onClientRender", root, self.func.render)
        removeEventHandler("onClientClick", root, self.func.click)

        GUI.egg = nil
        self = nil
    end
end

function EggOpener:checkEggClick(x, eggID)
    if self:isMouseInPosition(x, guiInfo.y, guiInfo.w, guiInfo.h) and not self.selectedEgg then
        self.selectedEgg = eggID
    end
end

function EggOpener:getEggPrize()
    local rand = math.random(1, 1000)
    if rand == 1 then
        exports.TR_noti:create("Yumurtadan eşsiz neonlar çıktı.", "success")
        return "neon", 0

    elseif rand <= 51 then
        exports.TR_noti:create("Yumurtadan 1 günlük Diamond hesabı çıktı.", "success")
        return "diamond", 1

    elseif rand <= 201 then
        exports.TR_noti:create("Yumurtadan 3 günlük Gold hesabı çıktı.", "success")
        return "gold", 1
    else
        local value = math.random(50, 200)
        exports.TR_noti:create(string.format("Yumurtadan $%d çıktı.", value), "success")
        return "money", value
    end
end


function EggOpener:drawBackground(x, y, rx, ry, color, radius, post)
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

function EggOpener:isMouseInPosition(x, y, width, height)
    if (not isCursorShowing()) then return false end
    local cx, cy = getCursorPosition()
    local cx, cy = (cx*sx), (cy*sy)
    if (cx >= x and cx <= x + width) and (cy >= y and cy <= y + height) then return true end
    return false
end

function openEggItems(...)
    if GUI.egg then return end
    GUI.egg = EggOpener:create(...)

    exports.TR_dx:setResponseEnabled(false)
end
addEvent("openEggsSelect", true)
addEventHandler("openEggsSelect", root, openEggItems)