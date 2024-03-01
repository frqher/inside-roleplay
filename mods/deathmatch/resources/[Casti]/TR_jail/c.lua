local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 500/zoom)/2,
    y = sy - 190/zoom,
    w = 500/zoom,
    h = 145/zoom
}

JailInfo = {}
JailInfo.__index = JailInfo

function JailInfo:create(...)
    local instance = {}
    setmetatable(instance, JailInfo)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function JailInfo:constructor(...)
    self.data = arg[1]
    self.jailTick = getTickCount()
    self.alpha = 0

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.info = exports.TR_dx:getFont(12)

    self.func = {}
    self.func.render = function() self:render() end

    self:open()
    return true
end

function JailInfo:open()
    self.tick = getTickCount()
    self.state = "opening"

    addEventHandler("onClientRender", root, self.func.render)
end

function JailInfo:close()
    self.tick = getTickCount()
    self.state = "closing"
end

function JailInfo:destroy()
    removeEventHandler("onClientRender", root, self.func.render)
    guiInfo.info = nil
    self = nil
end


function JailInfo:animate()
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
            self.alpha = nil
            self.state = "closed"
            self.tick = nil

            self:destroy()
            return true
        end
    end
end

function JailInfo:render()
    if self:animate() then return end

    self:drawOptionsBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 4)
    dxDrawImage(guiInfo.x + 15/zoom, guiInfo.y + 44/zoom, 80/zoom, 80/zoom, "files/images/jail.png", 0, 0, 0, tocolor(170, 170, 170, 255 * self.alpha))

    dxDrawText("Eyalet Hapishanesi", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 40/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")


    if getElementData(localPlayer, "afk", true) then self.jailTick = getTickCount() end
    if not self.data.time then
        dxDrawText(string.format("Officer: %s\nKapatma nedeni: %s\nKalan süre: %s", self.data.police, self.data.reason, self:secondsToClock(0)), guiInfo.x + 110/zoom, guiInfo.y + 40/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.info, "left", "top", true, true)
    else
        dxDrawText(string.format("Officer: %s\nKapatma nedeni: %s\nKalan süre: %s", self.data.police, self.data.reason, self:secondsToClock(self.data.time - (getTickCount() - self.jailTick)/1000)), guiInfo.x + 110/zoom, guiInfo.y + 40/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.info, "left", "top", true, true)

        if (self.data.time - (getTickCount() - self.jailTick)/1000) < 0 then
            self.data.time = nil

            self:close()
            triggerServerEvent("updatePlayerJailTime", resourceRoot, false)
            return
        end

        if (getTickCount() - self.jailTick)/10000 >= 1 then
            self.data.time = self.data.time - 10
            self.jailTick = getTickCount()
            triggerServerEvent("updatePlayerJailTime", resourceRoot, toJSON(self.data))
        end
    end
end

function JailInfo:drawOptionsBackground(x, y, rx, ry, color, radius, post)
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

function JailInfo:secondsToClock(seconds)
    local seconds = tonumber(seconds)

    if seconds <= 0 then
         return "00:00:00";
    else
        hours = string.format("%02.f", math.floor(seconds/3600));
        mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
        secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
        return hours..":"..mins..":"..secs
    end
end

function openPrisonTimer(...)
    if guiInfo.info then return end
    guiInfo.info = JailInfo:create(...)

    exports.TR_achievements:addAchievements("policeJail")
end
addEvent("openPrisonTimer", true)
addEventHandler("openPrisonTimer", root, openPrisonTimer)

function isPlayerInPrizon(...)
    if guiInfo.info then return true end
    return false
end