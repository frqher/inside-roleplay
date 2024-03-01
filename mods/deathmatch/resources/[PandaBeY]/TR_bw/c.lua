local sx, sy = guiGetScreenSize()

local zoom = 1
local baseX = 1900
local minZoom = 2

if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
	x = (sx - 500/zoom)/2,
	y = sy - 200/zoom,
	w = 500/zoom,
    h = 190/zoom,

    hearth = {
        originalW = 500,
        originalH = 280,
    },

    time = 300,
    blurStrength = 0.001,
    noiseStrength = 0.001,
}

BWSystem = {}
BWSystem.__index = BWSystem

function BWSystem:create()
    local instance = {}
    setmetatable(instance, BWSystem)
    if instance:constructor() then
        return instance
    end
    return false
end

function BWSystem:constructor()
    self.alpha = 0
    self.heartX = 0

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.info = exports.TR_dx:getFont(10)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.onDeath = function() self:onDeath(source, guiInfo.time) end
    self.func.blockGUI = function() self:blockGUI() end

    addEventHandler("onClientPlayerWasted", root, self.func.onDeath)
    return true
end

function BWSystem:createTextures()
    self.textures = {}
    self.textures.heartBeat = dxCreateTexture("files/images/heartbeat.png", "argb", true, "wrap")

    self.shader = dxCreateShader("files/shaders/death.fx")
    self.screenSource = dxCreateScreenSource(sx, sy)
end

function BWSystem:destroy()
    if isTimer(self.blockTimer) then killTimer(self.blockTimer) end

    if self.textures then
        for i, v in pairs(self.textures) do
            if isElement(v) then destroyElement(v) end
        end
    end

    self.startTime = nil
    self.heartBeatTick = nil
    self.tick = nil
    self.state = nil

    if isElement(self.shader) then destroyElement(self.shader) end
    if isElement(self.screenSource) then destroyElement(self.screenSource) end
    if isElement(self.sound) then destroyElement(self.sound) end

    if self.type == "onBw" then
        setPedAnimation(localPlayer, "PED", "getup_front", -1, false, false, false, false)
        setTimer(setPedAnimation, 2500, 1, localPlayer, nil, nil)
    end

    setElementData(localPlayer, "animation", nil)
    setElementData(localPlayer, "hasBw", nil)

    setElementFrozen(localPlayer, false)
    removeEventHandler("onClientRender", root, self.func.render)

    exports.TR_dx:setOpenGUI(false)
    exports.TR_weapons:updateWeapons()

    self.opened = nil
    setCameraTarget(localPlayer)
end

function BWSystem:onDeath(plr, time)
    if plr ~= localPlayer then return end
    if self.opened then return end
    -- if not isElementWithinColShape(localPlayer, DMzone) then
    --     self.type = "noBW"
    --     self.time = 10

    --     self.img = nil
    --     self.imgTick = getTickCount()

    --     self.hospital = self:getNearestHospital()
    -- end

    self.type = "onBw"
    self.time = time and time or 300

    setElementData(localPlayer, "hasBw", true)

    self.opened = true

    self:createTextures()

    self.startTime = getTickCount()
    self.heartBeatTick = getTickCount()
    self.tick = getTickCount()
    self.tickRot = getTickCount()
    self.updateTimeTick = getTickCount()
    self.state = "opening"
    self.rot = 0

    self.sound = playSound("files/sounds/heartbeat.mp3", true)

    exports.TR_weapons:updateWeapons()

    addEventHandler("onClientRender", root, self.func.render, false, "high")

    setElementFrozen(localPlayer, true)
    setPedAnimation(localPlayer, "PED", "KO_shot_front", -1, false, false, false, true)
    setElementData(localPlayer, "animation", {"PED", "KO_shot_front", true, false, true})

    exports.TR_achievements:addAchievements("playerDied")

    if exports.TR_dx:canOpenGUI() then
        self:blockGUI()
    else
        self.blockTimer = setTimer(self.func.blockGUI, 1000, 1)
    end
end

function BWSystem:onEndBW()
    if not self.opened then return end
    if isTimer(self.blockTimer) then killTimer(self.blockTimer) end
    self.blockTimer = nil

    exports.TR_hud:setHudVisible(true)
    -- exports.TR_chat:showCustomChat(true)

    self.blocked = nil
    self.updateTimeTick = nil

    self.tick = getTickCount()
    self.state = "closing"

    triggerServerEvent("updatePlayerBwTime", resourceRoot, 0, self.type ~= "onBw")
end

function BWSystem:blockGUI()
    if exports.TR_dx:canOpenGUI() and not self.blocked then
        exports.TR_dx:setOpenGUI(true)
        exports.TR_hud:setHudVisible(false)
        -- exports.TR_chat:showCustomChat(false)
        self.blocked = true

    elseif not self.blocked then
        self.blockTimer = setTimer(self.func.blockGUI, 1000, 1)
    end
end

function BWSystem:animate()
    if not self.tick then return end
    if self.state == "opening" then
        local progress = (getTickCount() - self.tick)/500
        self.alpha = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "Linear")

        if progress >= 1 then
            self.alpha = 1
            self.state = "opened"
            self.tick = nil
        end

    elseif self.state == "closing" then
        local progress = (getTickCount() - self.tick)/500
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

function BWSystem:animateHeartBeat()
    if not self.heartBeatTick then return end

    local progress = (getTickCount() - self.heartBeatTick)/970
    self.heartX = interpolateBetween(0, 0, 0, guiInfo.hearth.originalW, 0, 0, progress, "Linear")

    if progress >= 1 then
        self.heartX = 0
        self.heartBeatTick = getTickCount()
    end
end

function BWSystem:renderBlackScreen()
    dxUpdateScreenSource(self.screenSource)

    dxSetShaderValue(self.shader, "ScreenSource", self.screenSource);
    dxSetShaderValue(self.shader, "Flickering", 1);
    dxSetShaderValue(self.shader, "Blurring", guiInfo.blurStrength);
    dxSetShaderValue(self.shader, "Noise", guiInfo.noiseStrength);
    dxDrawImage(0, 0, sx, sy, self.shader, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
end

function BWSystem:render()
    if self:animate() then return end
    self.pos = Vector3(getElementPosition(localPlayer))
    self:animateHeartBeat()

    if self.type == "onBw" then
        self:animateCamera()
        self:renderBlackScreen()
        self:updateTime()

    else
        if (getTickCount() - self.imgTick)/500 >= 1 then
            self.img = not self.img
            self.imgTick = getTickCount()
        end
        dxDrawImage(0, 0, sx, sy, string.format("files/images/hospital_%s%s.jpg", self.hospital, self.img and "1" or ""), 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
        dxDrawRectangle(0, 0, sx, sy, tocolor(0, 0, 0, 100 * self.alpha))
    end

    local time = self.time - (getTickCount() - self.startTime)/1000
    dxDrawText("BİLİNÇSİZSİN", guiInfo.x, guiInfo.y + 10/zoom, guiInfo.x + guiInfo.w, guiInfo.h, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "top")
    dxDrawImageSection(guiInfo.x + 20/zoom, guiInfo.y + 40/zoom, guiInfo.w - 40/zoom, 98/zoom, self.heartX, 0, guiInfo.hearth.originalW, guiInfo.hearth.originalH, self.textures.heartBeat, 0, 0, 0, tocolor(220, 220, 220, 255 * self.alpha))

    if self.type == "onBw" then
        dxDrawText(string.format("Yavaş yavaş eski halinize geri dönüyorsunuz.\n%ss içinde uyanacaksınız.", self:secondsToClock(time)), guiInfo.x, guiInfo.y + 10/zoom, guiInfo.x + guiInfo.w, guiInfo.y + guiInfo.h - 10/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "bottom")
    else
        dxDrawText(string.format("Tedavi göreceğiniz hastaneye götürülüyorsunuz.\n%ss içinde tam gücünüze kavuşacaksınız.", self:secondsToClock(time)), guiInfo.x, guiInfo.y + 10/zoom, guiInfo.x + guiInfo.w, guiInfo.y + guiInfo.h - 10/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "bottom")
    end

    if time <= 1 and self.state == "opened" then
        self:onEndBW()
    end
end

function BWSystem:updateTime()
    if not self.updateTimeTick then return end
    local time = self.time - (getTickCount() - self.startTime)/1000

    if (getTickCount() - self.updateTimeTick)/10000 >= 1 and time > 0 then
        self.updateTimeTick = getTickCount()
        triggerServerEvent("updatePlayerBwTime", resourceRoot, time)
        -- setPedAnimation(localPlayer, "PED", "getup_front", -1, false, false, false, false)
    end
end

function BWSystem:animateCamera()
    local rot = 360 * (getTickCount() - self.tickRot)/60000
    if rot >= 360 then self.tickRot = getTickCount() end

    local x, y = self:getPointFromDistanceRotation(self.pos.x, self.pos.y, 10, rot)
    setCameraMatrix(x, y, self.pos.z + 20, self.pos)
end

function BWSystem:getPointFromDistanceRotation(x, y, dist, angle)
    local a = math.rad(90 - angle);
    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;
    return x+dx, y+dy;
end

function BWSystem:secondsToClock(seconds)
    local seconds = tonumber(seconds)

    if seconds <= 0 then
         return "00:00";
    else
        hours = string.format("%02.f", math.floor(seconds/3600));
        mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
        secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
        return mins..":"..secs
    end
end

function BWSystem:getNearestHospital()
    local nearestHospital, closestDist = false, 99999999
    local plrPos = Vector3(getElementPosition(localPlayer))
    for i, v in pairs(hospitals) do
        local dist = getDistanceBetweenPoints3D(plrPos, v.pos)
        if dist < closestDist then
            closestDist = dist
            nearestHospital = v.name
        end
    end
    return nearestHospital
end



function startBW()
    if guiInfo.system then return end
    guiInfo.system = BWSystem:create()
end

function openBW(time)
    if not guiInfo.system then return end
    guiInfo.system:onDeath(localPlayer, time)
end
addEvent("openBW", true)
addEventHandler("openBW", root, openBW)

function endBW()
    if not guiInfo.system then return end
    guiInfo.system:onEndBW()
end
addEvent("endBW", true)
addEventHandler("endBW", root, endBW)

function hasBW()
    if not guiInfo.system then return false end
    return guiInfo.system.opened
end

if getElementData(localPlayer, "characterUID") then
    startBW()
end

setCameraTarget(localPlayer)