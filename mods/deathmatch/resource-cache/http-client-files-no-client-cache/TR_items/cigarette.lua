local sx, sy = guiGetScreenSize()

local guiInfo = {
    x = (sx - 450/zoom)/2,
    y = sy - 45/zoom,
    w = 400/zoom,
    h = 35/zoom,
}

Cigarette = {}
Cigarette.__index = Cigarette

function Cigarette:create(...)
    local instance = {}
    setmetatable(instance, Cigarette)
    if instance:constructor(...) then
        return true
    end
    return false
end

function Cigarette:constructor(...)
    self.font = exports.TR_dx:getFont(12)
    self:createCigarette(...)
    self.blockSmoke = nil

    self.func = {}
    self.func.render = function() self:render() end
    self.func.smoke = function() self:smoke() end
    self.func.endSmoke = function() self:endSmoke() end
    self.func.tapSmoke = function() self:tapSmoke() end
    self.func.dropCigarette = function() self:dropCigarette() end
    self.func.startSmoking = function() self:startSmoking() end
    self.func.igniteCigarette = function() self:igniteCigarette() end
    addEventHandler("onClientRender", root, self.func.render)

    setPedAnimation(localPlayer, "smoking", "m_smk_in", -1, true, false, false, true)
    setElementData(localPlayer, "animation", {"smoking", "m_smk_in"})

    setTimer(self.func.igniteCigarette, 2500, 1)
    return true
end

function Cigarette:stopSmoking(...)
    removeEventHandler("onClientRender", root, self.func.render)
    setPedAnimation(localPlayer, nil, nil)
    setElementData(localPlayer, "animation", nil)
    triggerServerEvent("syncAnim", resourceRoot, nil, nil)

    unbindKey("mouse1", "down", self.func.smoke)
    unbindKey("mouse2", "down", self.func.dropCigarette)

    if exports.TR_tutorial:isTutorialOpen() then
        exports.TR_tutorial:setNextState()
    else
        exports.TR_dx:setOpenGUI(false)
    end

    guiInfo.cigarette = nil
    self = nil
end

function Cigarette:igniteCigarette(...)
    if self.blockSmoke then self:stopSmoking() return end
    self.tick = getTickCount()
    self.tickNew = self.tick
    setTimer(self.func.startSmoking, 2500, 1)
end

function Cigarette:startSmoking(...)
    if self.blockSmoke then self:stopSmoking() return end
    setPedAnimation(localPlayer, "smoking", "m_smk_loop", -1, true, false, false, true)
    triggerServerEvent("syncAnim", resourceRoot, "smoking", "m_smk_loop")
    setElementData(localPlayer, "animation", {"smoking", "m_smk_loop"})

    bindKey("mouse1", "down", self.func.smoke)
    bindKey("mouse2", "down", self.func.dropCigarette)
    self.canSmoke = true
end

function Cigarette:smoke(...)
    if self.blockSmoke then self:stopSmoking() return end
    if not self.canSmoke then return end

    setPedAnimation(localPlayer, "smoking", "m_smk_drag", -1, true, false, false, true)
    triggerServerEvent("syncAnim", resourceRoot, "smoking", "m_smk_drag")
    self.canSmoke = nil

    setTimer(function()
        self.tickNew = self.tick - 10000
    end, 1000, 1)

    setTimer(self.func.tapSmoke, 2500, 1)
    setTimer(self.func.endSmoke, 10000, 1)
end

function Cigarette:tapSmoke(...)
    if self.blockSmoke then self:stopSmoking() return end
    setPedAnimation(localPlayer, "smoking", "m_smk_tap", -1, true, false, false, true)
    triggerServerEvent("syncAnim", resourceRoot, "smoking", "m_smk_tap")

    if self.type == "joint" then
        exports.TR_shaders:setMarijuanaEffect(true, self.value, 120)
    end

    setTimer(function()
        setPedAnimation(localPlayer, "smoking", "m_smk_loop", -1, true, false, false, true)
        triggerServerEvent("syncAnim", resourceRoot, "smoking", "m_smk_loop")
    end, 3000, 1)
end

function Cigarette:endSmoke(...)
    if self.blockSmoke then self:stopSmoking() return end
    self.canSmoke = true

    setPedAnimation(localPlayer, "smoking", "m_smk_loop", -1, true, false, false, true)
    triggerServerEvent("syncAnim", resourceRoot, "smoking", "m_smk_loop")
end

function Cigarette:dropCigarette(...)
    if self.blockSmoke then self:stopSmoking() return end
    if not self.canSmoke then return end
    self:stopSmoking()
end

function Cigarette:render()
    if self.tick then
        if self.tickNew < self.tick then
            self.tick = math.max(self.tick - 300, self.tickNew)
        end
        local progress = (getTickCount() - self.tick)/self.smokeTime
        local smoke = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "Linear")

        if self.canSmoke then
            dxDrawText("Balığı almak için sol fare tuşuna bas.\nBalığı atm...diğer alana ekleyebilmek için sağ fare tuşuna bas.", sx/2, guiInfo.y - 40/zoom, sx/2, guiInfo.y - 4/zoom, tocolor(255, 255, 255, 255), 1/zoom, self.font, "center", "bottom", false, false, false, true)
        end
        dxDrawImageSection(guiInfo.x, guiInfo.y, guiInfo.w - (250/zoom * smoke), guiInfo.h, 0, 0, 400 - (250 * smoke), 35, self.cigarette, 0, 0, 0, tocolor(255, 255, 255, 255))
        dxDrawImageSection(guiInfo.x + guiInfo.w - (250/zoom * smoke), guiInfo.y, 40/zoom, guiInfo.h, 410, 0, 40, 35, self.cigarette, 0, 0, 0, tocolor(255, 255, 255, 255))

        if progress >= 1 then
            self.blockSmoke = true
            self:stopSmoking()
        end
    else
        dxDrawImageSection(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, 0, 0, 400, 35, self.cigarette, 0, 0, 0, tocolor(255, 255, 255, 255))
        dxDrawImageSection(guiInfo.x + guiInfo.w, guiInfo.y, 40/zoom, guiInfo.h, 410, 0, 40, 35, self.cigarette, 0, 0, 0, tocolor(255, 255, 255, 255))
    end
end

function Cigarette:createCigarette(...)
    if arg[1] == 1 then
        self.cigarette = dxCreateTexture("files/images/cigarette.png", "argb", true, "clamp")
        self.smokeTime = 300000
        self.type = "cigarette"

    elseif arg[1] == 2 then
        self.cigarette = dxCreateTexture("files/images/joint.png", "argb", true, "clamp")
        self.smokeTime = 180000
        self.type = "joint"
        self.value = arg[2]/20
    end
end

function startSmoking(...)
    if guiInfo.cigarette then return end
    guiInfo.cigarette = Cigarette:create(...)
end
addEvent("startSmoking", true)
addEventHandler("startSmoking", root, startSmoking)