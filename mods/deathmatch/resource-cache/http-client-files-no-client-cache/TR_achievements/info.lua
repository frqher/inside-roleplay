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

ShowAchievement = {}
ShowAchievement.__index = ShowAchievement

function ShowAchievement:create()
    local instance = {}
    setmetatable(instance, ShowAchievement)
    if instance:constructor() then
        return instance
    end
    return false
end

function ShowAchievement:constructor()
    self.rot = 0
    self.alpha = 0
    self.progress = {bg = 0, upper = 0, upperAlpha = 0, down = 0, downAlpha = 0, leftAlpha = 0, textAlpha = 0}
    self.achievements = {}

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(16)
    self.fonts.desc = exports.TR_dx:getFont(11)

    self.func = {}
    self.func.check = function() self:check() end
    self.func.render = function() self:render() end

    setTimer(self.func.check, 1000, 0)
    return true
end

function ShowAchievement:check()
    if #self.achievements < 1 then return end

    if self.achievements[1] and not self.state then
        self:show(self.achievements[1])
        table.remove(self.achievements, 1)
    end
end

function ShowAchievement:show(...)
    self.showingData = arg[1]
    self.progress = {bg = 0, upper = 0, upperAlpha = 0, down = 0, downAlpha = 0, leftAlpha = 0, textAlpha = 0}

    self.tick = getTickCount()
    self.state = "showing"
    self.rot = 0

    playSound("files/sounds/sound.ogg")

    addEventHandler("onClientRender", root, self.func.render)
end

function ShowAchievement:animate()
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
        local progress = (getTickCount() - self.tick)/10000

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

function ShowAchievement:render()
    self:animate()

    -- Bg
    local x = guiInfo.x + guiInfo.popupSize/2 - (guiInfo.popupSize/2 * self.progress.bg)
    local y = guiInfo.y + guiInfo.popupSize/2 - (guiInfo.popupSize/2 * self.progress.bg)
    local w = guiInfo.w - guiInfo.popupSize + (guiInfo.popupSize * self.progress.bg)
    local h = guiInfo.h - guiInfo.popupSize + (guiInfo.popupSize * self.progress.bg)
    self:drawBackground(x, y, w, h, tocolor(17, 17, 17, 255 * self.alpha), 4)

    -- Upper medal
    self.rot = self.rot + 0.3
    if self.rot >= 360 then self.rot = self.rot - 360 end
    local size = (h - 30/zoom) * self.progress.upper
    dxDrawImage((x + w/2) - size/2 - (guiInfo.w - size - 20/zoom)/2 * self.progress.leftAlpha, (y + h/2) - size/2 - 15/zoom, size, size, "files/images/medal.png", self.rot, 0, 0, tocolor(212, 175, 55, 255 * self.progress.upperAlpha * self.alpha))

    local size = (h - 30/zoom) * self.progress.down
    dxDrawImageSection((x + w/2) - (h - 30/zoom)/2 - (guiInfo.w - size - 20/zoom)/2 * self.progress.leftAlpha, (y + h/2) - (h - 30/zoom)/2, (h - 30/zoom), (h - 30/zoom) * self.progress.downAlpha, 0, 0, 128, 128 * self.progress.downAlpha, "files/images/medalD.png", 0, 0, 0, tocolor(212, 55, 55, 255 * self.progress.downAlpha * self.alpha))

    dxDrawText(self.showingData.title, guiInfo.x + 100/zoom, guiInfo.y + 5/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + 20/zoom, tocolor(240, 196, 55, 255 * self.progress.textAlpha * self.alpha), 1/zoom, self.fonts.main, "center", "top")
    dxDrawText(self.showingData.desc, guiInfo.x + 100/zoom, guiInfo.y + 35/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h - 30/zoom, tocolor(220, 220, 220, 255 * self.progress.textAlpha * self.alpha), 1/zoom, self.fonts.desc, "center", "top", true, true)
    dxDrawText(self.showingData.gift or "", guiInfo.x + 100/zoom, guiInfo.y + 40/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h - 10/zoom, tocolor(170, 170, 170, 255 * self.progress.textAlpha * self.alpha), 1/zoom, self.fonts.desc, "center", "bottom")
end




function ShowAchievement:showNewAchievement(...)
    table.insert(self.achievements, {
        title = arg[1],
        desc = arg[2],
        gift = arg[3],
    })
end

function ShowAchievement:drawBackground(x, y, rx, ry, color, radius, post)
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





guiInfo.achievement = ShowAchievement:create()
function openAchievementInfo(...)
    if not guiInfo.achievement then
        guiInfo.achievement = ShowAchievement:create()
    end

    guiInfo.achievement:showNewAchievement(...)
end
addEvent("openAchievementInfo", true)
addEventHandler("openAchievementInfo", root, openAchievementInfo)