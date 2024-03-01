local sx, sy = guiGetScreenSize()

local guiInfo = {
    x = sx - 500/zoom,
    y = (sy - 150/zoom)/2,
    w = 500/zoom,
    h = 150/zoom,
}

WarnSystem = {}
WarnSystem.__index = WarnSystem

function WarnSystem:create(...)
    local instance = {}
    setmetatable(instance, WarnSystem)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function WarnSystem:constructor(...)
    self.alpha = 0
    self.queue = {}

    self.fonts = {}
    self.fonts.warn = exports.TR_dx:getFont(28)
    self.fonts.reason = exports.TR_dx:getFont(18)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.addWarn = function(...) self:addWarn(...) end

    addEvent("showWarn", true)
    addEventHandler("showWarn", root, self.func.addWarn)
    return true
end

function WarnSystem:addWarn(plr, admin, reason)
    if not self.showed then
        addEventHandler("onClientRender", root, self.func.render)
        self:show(plr, admin, reason)
    else
        table.insert(self.queue, {plr, admin, reason})
    end
end

function WarnSystem:show(plr, admin, reason)
    self.showed = true
    self.tick = getTickCount()
    self.state = "showing"

    if getPlayerName(localPlayer) == plr then
        self.reason = reason
        self.victim = true
        playSound("files/sounds/warn.mp3")
    else
        self.reason = nil
        self.victim = nil
        exports.TR_noti:create(string.format("%s, %s tarafından uyarıldı.\nSebep: %s", plr, admin, reason), "penalty", 16)
    end
end

function WarnSystem:destroy()
    if #self.queue > 0 then
        local data = self.queue[1]
        self:show(data[1], data[2], data[3])
        table.remove(self.queue, 1)
    else
        self.showed = nil
        self.reason = nil
        removeEventHandler("onClientRender", root, self.func.render)
    end
end

function WarnSystem:animate()
    if not self.tick then return end
    local progress = (getTickCount() - self.tick)/500
    if self.state == "showing" then
        self.alpha = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "Linear")
        if progress >= 1 then
            self.alpha = 1
            self.state = "showed"
            self.tick = getTickCount()
        end

    elseif self.state == "showed" then
        local progress = (getTickCount() - self.tick)/16000
        if progress >= 1 then
            self.state = "hiding"
            self.tick = getTickCount()
        end

    elseif self.state == "hiding" then
        self.alpha = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "Linear")
        if progress >= 1 then
            self.alpha = 0
            self.state = "hidden"
            self.tick = nil

            self:destroy()
        end
    end
end

function WarnSystem:render()
    self:animate()

    if self.victim then
        dxDrawRectangle(0, 0, sx, sy, tocolor(17, 17, 17, 120 * self.alpha))
        dxDrawText("UYARI ALDINIZ!", 0, 0, sx, 300/zoom, tocolor(245, 47, 47, 255 * self.alpha), 1/zoom, self.fonts.warn, "center", "center")
        dxDrawText(self.reason, 0, 200/zoom, sx, sy, tocolor(250, 250, 250, 255 * self.alpha), 1/zoom, self.fonts.reason, "center", "top")
    end
end

WarnSystem:create()