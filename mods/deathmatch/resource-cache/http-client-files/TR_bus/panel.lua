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
    self.maxPackages = arg[1] and 20 or 10
    self.selectedPackages = 0

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.text = exports.TR_dx:getFont(12)
    self.fonts.small = exports.TR_dx:getFont(10)


    self.func = {}
    self.func.render = function() self:render() end
    self.func.onClick = function(...) self:onClick(...) end

    self:getRoads()
    self:open()
    return true
end

function TargetPanel:open()
    self.state = "opening"
    self.tick = getTickCount()

    exports.TR_dx:setOpenGUI(true)

    showCursor(true)
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientClick", root, self.func.onClick)
end

function TargetPanel:close()
    self.state = "closing"
    self.tick = getTickCount()

    showCursor(false)
    removeEventHandler("onClientClick", root, self.func.onClick)
end

function TargetPanel:destroy()
    exports.TR_dx:setOpenGUI(false)

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
    dxDrawText("Otobüs hattını seç", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")

    for i = 1, 10 do
        local v = self.roads[i]
        if v then
            if self:isMouseInPosition(guiInfo.x, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.w - 6/zoom, 40/zoom) then
                dxDrawRectangle(guiInfo.x, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.w - 6/zoom, 40/zoom, tocolor(22, 22, 22, 255 * self.alpha))
            end

            dxDrawText("Hat numarası "..v.number, guiInfo.x + 10/zoom, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom + 40/zoom * i, color, 1/zoom, self.fonts.text, "left", "center")
        end
    end
end

function TargetPanel:getRoads()
    self.roads = avliableCourses
end




function TargetPanel:onClick(btn, state)
    if btn ~= "left" or state ~= "down" then return end

    for i = 1, 10 do
        local v = self.roads[i]
        if v then
            if self:isMouseInPosition(guiInfo.x, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.w - 6/zoom, 40/zoom) then
                targetPoints = avliableCourses[i].road
                jobSettings.work:onBusSelectedRoad()

                exports.TR_noti:create(string.format("Rota hattı %d seçildi.", avliableCourses[i].number), "success")
                self:close()
            end
        end
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