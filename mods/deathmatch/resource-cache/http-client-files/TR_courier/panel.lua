local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 600/zoom)/2,
    y = (sy - 510/zoom)/2,
    w = 600/zoom,
    h = 510/zoom,

    time = 1800,
}

TargetPanel = {}
TargetPanel.__index = TargetPanel

function TargetPanel:create(...)
    local instance = {}
    setmetatable(instance, TargetPanel)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function TargetPanel:constructor(...)
    self.alpha = 0
    self.scroll = 0
    self.maxPackages = arg[1] and 20 or 10
    self.selectedPackages = 0

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.text = exports.TR_dx:getFont(12)
    self.fonts.small = exports.TR_dx:getFont(10)

    self.buttons = {}
    self.buttons.startJob = exports.TR_dx:createButton(guiInfo.x + guiInfo.w - 260/zoom, guiInfo.y + guiInfo.h - 50/zoom, 250/zoom, 40/zoom, "Paketleri Yükle", "green")
    exports.TR_dx:setButtonVisible(self.buttons, false)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.onClick = function(...) self:onClick(...) end
    self.func.onScroll = function(...) self:onScroll(...) end
    self.func.buttonClick = function(...) self:buttonClick(...) end

    self:getRoads()
    self:open()
    return true
end

function TargetPanel:open()
    self.state = "opening"
    self.tick = getTickCount()

    exports.TR_dx:setOpenGUI(true)
    exports.TR_dx:showButton(self.buttons)

    showCursor(true)
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientClick", root, self.func.onClick)
    addEventHandler("onClientKey", root, self.func.onScroll)
    addEventHandler("guiButtonClick", root, self.func.buttonClick)
end

function TargetPanel:close()
    self.state = "closing"
    self.tick = getTickCount()

    exports.TR_dx:hideButton(self.buttons)

    showCursor(false)
    removeEventHandler("onClientClick", root, self.func.onClick)
    removeEventHandler("onClientKey", root, self.func.onScroll)
    removeEventHandler("guiButtonClick", root, self.func.buttonClick)
end

function TargetPanel:destroy()
    exports.TR_dx:setOpenGUI(false)

    exports.TR_dx:destroyButton(self.buttons)

    removeEventHandler("onClientRender", root, self.func.render)
    self = nil
end

function TargetPanel:animate()
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
            self.state = nil
            self.tick = nil

            self:destroy()
            return true
        end
    end
end

function TargetPanel:render()
    if self:animate() then return end

    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 4)
    dxDrawText("Teslim edilecek paketleri seçin", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")

    dxDrawText(string.format("Alınan paket sayısı: %d/%d", self.selectedPackages, self.maxPackages), guiInfo.x + 10/zoom, guiInfo.y + guiInfo.h - 50/zoom, guiInfo.x + guiInfo.w, guiInfo.y + guiInfo.h - 10/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.text, "left", "center")
    for i = 1, 10 do
        local v = self.roads[i + self.scroll]
        if v then
            if v.tick then
                local time = guiInfo.time - (getTickCount() - v.tick)/1000

                local city = getZoneName(v.pos, true)
                local zone = getZoneName(v.pos)
                if self:isMouseInPosition(guiInfo.x, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.w - 6/zoom, 40/zoom) then
                    dxDrawRectangle(guiInfo.x, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.w - 6/zoom, 40/zoom, tocolor(22, 22, 22, 255 * self.alpha))
                end

                dxDrawText(string.format("%s | %s", city, zone), guiInfo.x + 10/zoom, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom + 40/zoom * i, tocolor(170, 170, 170, 100 * self.alpha), 1/zoom, self.fonts.text, "left", "center")
                dxDrawText("YÜK İÇİN "..self:secondsToClock(time), guiInfo.x + 10/zoom, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.x + guiInfo.w - 16/zoom, guiInfo.y + 50/zoom + 40/zoom * i, tocolor(120, 120, 120, 100 * self.alpha), 1/zoom, self.fonts.small, "right", "center")
            else
                local color = v.selected and tocolor(184, 153, 53, 255 * self.alpha) or tocolor(140, 140, 140, 255 * self.alpha)
                local city = getZoneName(v.pos, true)
                local zone = getZoneName(v.pos)
                if self:isMouseInPosition(guiInfo.x, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.w - 6/zoom, 40/zoom) then
                    dxDrawRectangle(guiInfo.x, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.w - 6/zoom, 40/zoom, tocolor(22, 22, 22, 255 * self.alpha))
                end

                dxDrawText(string.format("%s | %s", city, zone), guiInfo.x + 10/zoom, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom + 40/zoom * i, color, 1/zoom, self.fonts.text, "left", "center")
                dxDrawText("YÜK HAZIR", guiInfo.x + 10/zoom, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.x + guiInfo.w - 16/zoom, guiInfo.y + 50/zoom + 40/zoom * i, color, 1/zoom, self.fonts.small, "right", "center")
            end
        end
    end

    local b1 = 400/zoom / #self.roads
    local barY = b1 * self.scroll
    local barHeight = b1 * 12
    dxDrawRectangle(guiInfo.x + guiInfo.w - 5/zoom, guiInfo.y + 50/zoom, 4/zoom, 400/zoom, tocolor(37, 37, 37, 255 * self.alpha))
    dxDrawRectangle(guiInfo.x + guiInfo.w - 5/zoom, guiInfo.y + 50/zoom + barY, 4/zoom, barHeight, tocolor(57, 57, 57, 255 * self.alpha))
end

function TargetPanel:getRoads()
    self.roads = destinationPoints
    self:updateSelectedCount()
end

function TargetPanel:buttonClick(btn)
    if btn == self.buttons.startJob then
        self:updateSelectedCount()

        if self.selectedPackages <= 0 then exports.TR_noti:create("Hiç paket olmadan ayrılamazsınız.", "error") return end
        if self.selectedPackages > self.maxPackages then exports.TR_noti:create("Teslim edilecek çok fazla paket seçtiniz.", "error") return end
        local cloned = table.clone(self.roads)
        local buildedTable = {}
        for i, v in pairs(cloned) do
            if v.selected then
                table.insert(buildedTable, v)
                destinationPoints[i].tick = getTickCount()
                v.selected = nil
            end
        end

        jobSettings.work:loadVehicle(buildedTable)
        self:close()
    end
end




function TargetPanel:onScroll(btn, state)
    if not state then return end
    if btn == "mouse_wheel_down" or btn == "arrow_d" then
        self.scroll = math.min(self.scroll + 1, #self.roads - 12)

    elseif btn == "mouse_wheel_up" or btn == "arrow_u" then
        self.scroll = math.max(self.scroll - 1, 0)
    end
end

function TargetPanel:onClick(btn, state)
    if btn ~= "left" or state ~= "down" then return end

    for i = 1, 10 do
        local v = self.roads[i + self.scroll]
        if v then
            if self:isMouseInPosition(guiInfo.x, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.w - 6/zoom, 40/zoom) then
                if v.tick then
                    local time = guiInfo.time - (getTickCount() - v.tick)/1000
                    if time > 0 then return end
                end

                self.roads[i + self.scroll].selected = not self.roads[i + self.scroll].selected
                self:updateSelectedCount()
                return
            end
        end
    end
end

function TargetPanel:updateSelectedCount()
    self.selectedPackages = 0
    for i, v in pairs(destinationPoints) do
        if v.selected then
            v.delivered = nil
            v.delayed = nil
            self.selectedPackages = self.selectedPackages + 1
        end
    end
end


function TargetPanel:secondsToClock(seconds)
    local seconds = tonumber(seconds)

    if seconds <= 0 then
      return "00:00";
    else
      mins = string.format("%02.f", math.floor(seconds/60));
      secs = string.format("%02.f", math.floor(seconds - mins *60));
      return mins..":"..secs
    end
end

function TargetPanel:drawBackground(x, y, rx, ry, color, radius, post)
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

function TargetPanel:isMouseInPosition(x, y, width, height)
    if (not isCursorShowing()) then return false end
    local cx, cy = getCursorPosition()
    local cx, cy = (cx*sx), (cy*sy)
    if (cx >= x and cx <= x + width) and (cy >= y and cy <= y + height) then return true end
    return false
end

function table.clone(org)
    local new = {}
    for i, v in pairs(org) do table.insert(new, v) end
    return new
end