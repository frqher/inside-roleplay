local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end


local guiInfo = {
    x = (sx - 300/zoom)/2,
    y = sy - 110/zoom,
    w = 300/zoom,
    h = 90/zoom,
}

SpecSystem = {}
SpecSystem.__index = SpecSystem

function SpecSystem:create(...)
    local instance = {}
    setmetatable(instance, SpecSystem)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function SpecSystem:constructor(...)
    if not arg[1] then return false end
    self:setPlayer(arg[1])
    self:savePos()

    self.font = {}
    self.font.main = exports.TR_dx:getFont(14)
    self.font.info = exports.TR_dx:getFont(10)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.onKey = function(...) self:onKey(...) end

    addEventHandler("onClientRender", root, self.func.render)
    bindKey("enter", "down", self.func.onKey)
    bindKey("arrow_l", "down", self.func.onKey)
    bindKey("arrow_r", "down", self.func.onKey)

    toggleControl("left", false)
    toggleControl("right", false)
    toggleControl("forwards", false)
    toggleControl("backwards", false)

    setElementFrozen(localPlayer, true)
    setElementAlpha(localPlayer, 0)
    setElementData(localPlayer, "inv", true)
    return true
end

function SpecSystem:destroy()
    self:loadPos()

    removeEventHandler("onClientRender", root, self.func.render)
    unbindKey("enter", "down", self.func.onKey)
    unbindKey("arrow_l", "down", self.func.onKey)
    unbindKey("arrow_r", "down", self.func.onKey)

    setCameraTarget(localPlayer)
    toggleControl("left", true)
    toggleControl("right", true)
    toggleControl("forwards", true)
    toggleControl("backwards", true)

    setElementFrozen(localPlayer, false)
    setElementAlpha(localPlayer, 255)

    setElementData(localPlayer, "inv", nil)
    guiInfo.spec = nil
    self = nil
end

function SpecSystem:savePos()
    self.startPos = Vector3(getElementPosition(localPlayer))
    self.startInt = getElementInterior(localPlayer)
    self.startDim = getElementDimension(localPlayer)
end

function SpecSystem:loadPos()
    setElementPosition(localPlayer, self.startPos)
    setElementInterior(localPlayer, self.startInt)
    setElementDimension(localPlayer, self.startDim)
end

function SpecSystem:setPlayer(player)
    if not player then return end

    local uid = getElementData(player, "characterUID")
    self.selectedPlayer = player
    self.selectedName = string.format("%s (UID: %d)", getPlayerName(player), uid)
    setCameraTarget(player)

    for i, v in pairs(getElementsByType("player")) do
        if v == player then
            self.selectedIndex = i
            break
        end
    end
end

function SpecSystem:render()
    if not isElement(self.selectedPlayer) then self:destroy() return end

    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255), 4)
    dxDrawText(self.selectedName, guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(220, 220, 220, 255), 1/zoom, self.font.main, "center", "center")
    dxDrawText("Kişiyi değiştirmek için OK tuşlarını kullanın\nÇıkmak için ENTER tuşunu kullanın", guiInfo.x, guiInfo.y + 50/zoom, guiInfo.x + guiInfo.w, guiInfo.y + guiInfo.h - 10/zoom, tocolor(170, 170, 170, 255), 1/zoom, self.font.info, "center", "bottom", true, true)

    if self.selectedPlayer == localPlayer then return end
    local pos = Vector3(getElementPosition(self.selectedPlayer))
    setElementPosition(localPlayer, pos + Vector3(0, 0, 100))
    setElementInterior(localPlayer, getElementInterior(self.selectedPlayer))
    setElementDimension(localPlayer, getElementDimension(self.selectedPlayer))
end

function SpecSystem:onKey(key, state)
    if state == "down" then
        if key == "enter" then
            self:destroy()

        elseif key == "arrow_l" then
            self.selectedIndex = self.selectedIndex - 1

            local players = getElementsByType("player")
            if self.selectedIndex < 1 then
                self.selectedIndex = #players
            end
            self:setPlayer(players[self.selectedIndex])

        elseif key == "arrow_r" then
            self.selectedIndex = self.selectedIndex + 1

            local players = getElementsByType("player")
            if self.selectedIndex > #players then
                self.selectedIndex = 1
            end
            self:setPlayer(players[self.selectedIndex])
        end
    end
end

function SpecSystem:drawBackground(x, y, rx, ry, color, radius, post)
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

function createSpecWindow(...)
    if guiInfo.spec then
        guiInfo.spec:setPlayer(...)
        return
    end
    guiInfo.spec = SpecSystem:create(...)
end
addEvent("createSpecWindow", true)
addEventHandler("createSpecWindow", root, createSpecWindow)