local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 600/zoom)/2,
    y = (sy - 540/zoom)/2,
    w = 600/zoom,
    h = 540/zoom,

    time = 1200,
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
    self.hasLongRoads = arg[1]
    self.veh = arg[2]
    self.rot = arg[3]

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.text = exports.TR_dx:getFont(12)
    self.fonts.small = exports.TR_dx:getFont(10)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.onClick = function(...) self:onClick(...) end
    self.func.onScroll = function(...) self:onScroll(...) end

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
    addEventHandler("onClientKey", root, self.func.onScroll)
end

function TargetPanel:close()
    self.state = "closing"
    self.tick = getTickCount()

    showCursor(false)
    removeEventHandler("onClientClick", root, self.func.onClick)
    removeEventHandler("onClientKey", root, self.func.onScroll)
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
    dxDrawText("Transport Seç", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")

    for i = 1, 12 do
        local v = self.roads[i + self.scroll]
        if v then
            local city = getZoneName(v[1], v[2], v[3], true)
            local zone = getZoneName(v[1], v[2], v[3])

            if not self.hasLongRoads and v.isFar then
                -- dxDrawLine(guiInfo.x + 10/zoom, guiInfo.y + 69/zoom + 40/zoom * (i-1), guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + 69/zoom + 40/zoom * (i-1), tocolor(170, 170, 170, 60 * self.alpha), 2)
                dxDrawText(string.format("%s | %s", city, zone), guiInfo.x + 10/zoom, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom + 40/zoom * i, tocolor(170, 170, 170, 60 * self.alpha), 1/zoom, self.fonts.text, "left", "center")

                dxDrawText("İZİN YOK", guiInfo.x + 10/zoom, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.x + guiInfo.w - 16/zoom, guiInfo.y + 50/zoom + 40/zoom * i, tocolor(170, 170, 170, 60 * self.alpha), 1/zoom, self.fonts.small, "right", "center")


            elseif v.taken then
                local time = guiInfo.time - (getTickCount() - v.taken)/1000
                if time <= 0 then
                    if self:isMouseInPosition(guiInfo.x, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.w - 6/zoom, 40/zoom) then
                        dxDrawRectangle(guiInfo.x, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.w - 6/zoom, 40/zoom, tocolor(22, 22, 22, 255 * self.alpha))
                    end
                    dxDrawText(string.format("%s | %s", city, zone), guiInfo.x + 10/zoom, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom + 40/zoom * i, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.text, "left", "center")
                    dxDrawText("YÜK HAZIR", guiInfo.x + 10/zoom, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.x + guiInfo.w - 16/zoom, guiInfo.y + 50/zoom + 40/zoom * i, tocolor(120, 120, 120, 255 * self.alpha), 1/zoom, self.fonts.small, "right", "center")

                else
                    -- dxDrawLine(guiInfo.x + 10/zoom, guiInfo.y + 69/zoom + 40/zoom * (i-1), guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + 69/zoom + 40/zoom * (i-1), tocolor(170, 170, 170, 60 * self.alpha), 2)
                    dxDrawText(string.format("%s | %s", city, zone), guiInfo.x + 10/zoom, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom + 40/zoom * i, tocolor(170, 170, 170, 60 * self.alpha), 1/zoom, self.fonts.text, "left", "center")

                    dxDrawText("YÜK "..self:secondsToClock(time).." KALDI", guiInfo.x + 10/zoom, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.x + guiInfo.w - 16/zoom, guiInfo.y + 50/zoom + 40/zoom * i, tocolor(170, 170, 170, 60 * self.alpha), 1/zoom, self.fonts.small, "right", "center")
                end

            else
                if self:isMouseInPosition(guiInfo.x, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.w - 6/zoom, 40/zoom) then
                    dxDrawRectangle(guiInfo.x, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.w - 6/zoom, 40/zoom, tocolor(22, 22, 22, 255 * self.alpha))
                end

                dxDrawText(string.format("%s | %s", city, zone), guiInfo.x + 10/zoom, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom + 40/zoom * i, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.text, "left", "center")
                dxDrawText("YÜK HAZIR", guiInfo.x + 10/zoom, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.x + guiInfo.w - 16/zoom, guiInfo.y + 50/zoom + 40/zoom * i, tocolor(120, 120, 120, 255 * self.alpha), 1/zoom, self.fonts.small, "right", "center")
            end
        end
    end

    local b1 = (guiInfo.h - 60/zoom) / #self.roads
    local barY = b1 * self.scroll
    local barHeight = b1 * 12
    dxDrawRectangle(guiInfo.x + guiInfo.w - 5/zoom, guiInfo.y + 50/zoom, 4/zoom, (guiInfo.h - 60/zoom), tocolor(37, 37, 37, 255 * self.alpha))
    dxDrawRectangle(guiInfo.x + guiInfo.w - 5/zoom, guiInfo.y + 50/zoom + barY, 4/zoom, barHeight, tocolor(57, 57, 57, 255 * self.alpha))
end

function TargetPanel:getRoads()
    self.roads = {}
    for i, v in pairs(nearPoints) do
        table.insert(self.roads, v)
    end
    for i, v in pairs(farPoints) do
        table.insert(self.roads, v)
        self.roads[#self.roads].isFar = true
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

    for i = 1, 12 do
        local v = self.roads[i + self.scroll]
        if v then
            if self:isMouseInPosition(guiInfo.x, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.w - 6/zoom, 40/zoom) then
                if not self.hasLongRoads and v.isFar then
                    return

                elseif v.taken then
                    local time = guiInfo.time - (getTickCount() - v.taken)/1000
                    if time > 0 then
                        return
                    end
                end

                local index = i + self.scroll
                if index > #nearPoints then
                    farPoints[index - #nearPoints].taken = getTickCount()
                else
                    nearPoints[index].taken = getTickCount()
                end

                jobSettings.work:loadVehicle(v, self.veh, self.rot)
                self:close()
                return
            end
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

-- TargetPanel:create()