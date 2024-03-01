local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 500/zoom)/2,
    y = 70/zoom,
    w = 500/zoom,
    h = 120/zoom,

    popupSize = 100/zoom,
}

ShowInfo = {}
ShowInfo.__index = ShowInfo

function ShowInfo:create()
    local instance = {}
    setmetatable(instance, ShowInfo)
    if instance:constructor() then
        return instance
    end
    return false
end

function ShowInfo:constructor()
    self.rot = 0
    self.alpha = 0
    self.progress = {bg = 0, upper = 0, upperAlpha = 0, down = 0, downAlpha = 0, leftAlpha = 0, textAlpha = 0}

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(16)
    self.fonts.desc = exports.TR_dx:getFont(11)

    self.textures = {}
    self.textures.calendar = dxCreateTexture("files/images/calendar.png", "argb", false, "clamp")
    self.textures.calendar_clock = dxCreateTexture("files/images/calendar_clock.png", "argb", true, "clamp")
    self.textures.sad = dxCreateTexture("files/images/sad.png", "argb", true, "clamp")

    self.func = {}
    self.func.render = function() self:render() end

    return true
end

function ShowInfo:show(...)
    if self.tick then return end
    self.showingData = arg[1]
    settings.lastEventTitle = arg[1].title
    self.progress = {bg = 0, upper = 0, upperAlpha = 0, down = 0, downAlpha = 0, leftAlpha = 0, textAlpha = 0}

    self.tick = getTickCount()
    self.state = "showing"
    self.rot = 0

    addEventHandler("onClientRender", root, self.func.render)
end

function ShowInfo:animate()
    if not self.tick then return end
    if self.state == "showing" then
        local progress = (getTickCount() - self.tick)/200
        self.alpha = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "Linear")
        self.progress.bg = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "OutBack")

        if progress >= 1 then
            self.alpha = 1
            self.state = "animateUpper"
            self.tick = getTickCount()
        end

    elseif self.state == "animateUpper" then
        local progress = (getTickCount() - self.tick)/500
        self.progress.upperAlpha = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "Linear")
        self.progress.upper = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "OutBack")

        if progress >= 1 then
            self.alpha = 1
            self.state = "animateDown"
            self.tick = getTickCount()
        end

    elseif self.state == "animateDown" then
        local progress = (getTickCount() - self.tick)/500
        self.progress.downAlpha = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "Linear")
        self.progress.down = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "OutBack")

        if progress >= 1 then
            self.alpha = 1
            self.state = "animateBeforeLeft"
            self.tick = getTickCount()
        end

    elseif self.state == "animateBeforeLeft" then
        local progress = (getTickCount() - self.tick)/200

        if progress >= 1 then
            self.alpha = 1
            self.state = "animateLeft"
            self.tick = getTickCount()
        end

    elseif self.state == "animateLeft" then
        local progress = (getTickCount() - self.tick)/800
        self.progress.leftAlpha = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "Linear")
        self.progress.left = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "OutBack")

        if (getTickCount() - self.tick) >= 300 then
            local progressText = (getTickCount() - (self.tick + 300))/500
            self.progress.textAlpha = interpolateBetween(0, 0, 0, 1, 0, 0, progressText, "Linear")
        end

        if progress >= 1 then
            self.alpha = 1
            self.state = "waiting"
            self.tick = getTickCount()
        end

    elseif self.state == "waiting" then
        local progress = (getTickCount() - self.tick)/15000

        if progress >= 1 then
            self.alpha = 1
            self.state = "hidding"
            self.tick = getTickCount()
        end

    elseif self.state == "hidding" then
        local progress = (getTickCount() - self.tick)/500

        self.alpha = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "Linear")

        if progress >= 1 then
            self.alpha = 0
            self.state = nil
            self.tick = nil

            removeEventHandler("onClientRender", root, self.func.render)
        end
    end
end

function ShowInfo:render()
    self:animate()

    -- Bg
    local x = guiInfo.x + guiInfo.popupSize/2 - (guiInfo.popupSize/2 * self.progress.bg)
    local y = guiInfo.y + guiInfo.popupSize/2 - (guiInfo.popupSize/2 * self.progress.bg)
    local w = guiInfo.w - guiInfo.popupSize + (guiInfo.popupSize * self.progress.bg)
    local h = guiInfo.h - guiInfo.popupSize + (guiInfo.popupSize * self.progress.bg)
    self:drawBackground(x, y, w, h, tocolor(17, 17, 17, 255 * self.alpha), 4)

    if self.showingData.type == "constant" then
        local size = (h - 30/zoom) * self.progress.upper
        dxDrawImage((x + w/2) - size/2 - (guiInfo.w - size - 20/zoom)/2 * self.progress.leftAlpha, (y + h/2) - size/2, size, size, self.textures.calendar, 0, 0, 0, tocolor(212, 175, 55, 255 * self.progress.upperAlpha * self.alpha))

        self.rot = self.rot + 1
        local sizeArrow = 25/zoom * self.progress.upper
        dxDrawImage((x + w/2) - size/2 - (guiInfo.w - size - 20/zoom)/2 * self.progress.leftAlpha + 59/zoom, (y + h/2) - size/2 + 60/zoom, sizeArrow, sizeArrow, self.textures.calendar_clock, self.rot/10, 0, 0, tocolor(17, 17, 17, 255 * self.progress.upperAlpha * self.alpha))
        dxDrawImage((x + w/2) - size/2 - (guiInfo.w - size - 20/zoom)/2 * self.progress.leftAlpha + 59/zoom, (y + h/2) - size/2 + 60/zoom, sizeArrow, sizeArrow, self.textures.calendar_clock, self.rot, 0, 0, tocolor(17, 17, 17, 255 * self.progress.upperAlpha * self.alpha))

    elseif self.showingData.type == "end" then
        local size = (h - 36/zoom) * self.progress.upper
        dxDrawImage((x + w/2) - size/2 - (guiInfo.w - size - 20/zoom)/2 * self.progress.leftAlpha, (y + h/2) - size/2, size, size, self.textures.sad, 0, 0, 0, tocolor(212, 175, 55, 255 * self.progress.upperAlpha * self.alpha))
    end

    dxDrawText(self.showingData.title, guiInfo.x + 100/zoom, guiInfo.y + 5/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + 20/zoom, tocolor(240, 196, 55, 255 * self.progress.textAlpha * self.alpha), 1/zoom, self.fonts.main, "center", "top")
    dxDrawText(self.showingData.desc, guiInfo.x + 100/zoom, guiInfo.y + 35/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h - 30/zoom, tocolor(220, 220, 220, 255 * self.progress.textAlpha * self.alpha), 1/zoom, self.fonts.desc, "center", "top", true, true)

    if self.showingData.type == "end" then
        dxDrawText(self.showingData.gift or "", guiInfo.x + 100/zoom, guiInfo.y + 40/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h - 10/zoom, tocolor(204, 53, 53, 255 * self.progress.textAlpha * self.alpha), 1/zoom, self.fonts.desc, "center", "bottom")
    else
        dxDrawText(self.showingData.gift or "", guiInfo.x + 100/zoom, guiInfo.y + 40/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h - 10/zoom, tocolor(98, 204, 53, 255 * self.progress.textAlpha * self.alpha), 1/zoom, self.fonts.desc, "center", "bottom")
    end
end

function ShowInfo:drawBackground(x, y, rx, ry, color, radius, post)
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

settings.info = ShowInfo:create()