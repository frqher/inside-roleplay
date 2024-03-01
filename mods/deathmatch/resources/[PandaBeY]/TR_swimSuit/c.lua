local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {

}

SwimSuit = {}
SwimSuit.__index = SwimSuit

function SwimSuit:create()
    local instance = {}
    setmetatable(instance, SwimSuit)
    if instance:constructor() then
        return instance
    end
    return false
end

function SwimSuit:constructor()
    self.opened = false

    self.func = {}
    self.func.render = function() self:render() end

    addEventHandler("onClientRender", root, self.func.render, false, "high")
    return true
end

function SwimSuit:open()
    if self.opened then return end
    self.opened = true

    exports.TR_firstperson:setFirspersonEnabled(true, true)
end

function SwimSuit:close()
    if not self.opened then return end
    self.opened = nil

    local state = exports.TR_dashboard:getSettings("firstPerson")
    exports.TR_firstperson:setFirspersonEnabled(state, true, true)
end

function SwimSuit:render()
    if getElementModel(localPlayer) ~= 291 or not isElementInWater(localPlayer) then self:close() return end
    self:open()

    dxDrawImage(0, 0, sx, sy, "files/images/goggles.png")
end

SwimSuit:create()