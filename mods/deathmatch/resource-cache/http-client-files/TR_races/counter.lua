local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = 0,
    y = 250/zoom,
    w = sx,
    h = 0,
}

Counter = {}
Counter.__index = Counter

function Counter:create(...)
    local instance = {}
    setmetatable(instance, Counter)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function Counter:constructor(...)
    self.alpha = 1
    self.raceType = arg[1]

    self.fonts = {}
    self.fonts.text = exports.TR_dx:getFont(150)
    self.fonts.help = exports.TR_dx:getFont(40)

    self.func = {}
    self.func.render = function() self:render() end

    self:open()
    setElementFrozen(getPedOccupiedVehicle(localPlayer), true)
    return true
end

function Counter:open()
    self.state = 0

    self:next()
    addEventHandler("onClientRender", root, self.func.render)
end

function Counter:start()
    exports.TR_hud:startRaceTimer()

    setElementFrozen(getPedOccupiedVehicle(localPlayer), false)
    bindKey("f", "down", rotateVehicle)
    bindKey("backspace", "down", forceEndRace)
end

function Counter:close()
    if RaceData.drift then
        RaceData.drift:onMarkerHit()
    end

    removeEventHandler("onClientRender", root, self.func.render)
    self = nil
end

function Counter:next()
    self.state = self.state + 1
    if self.state == 1 then
        self.time = 5500
    else
        self.time = self.state < 3 and 3000 or 1000
    end

    self.tick = getTickCount()

    if self.state == 6 then
        playSound("files/sounds/start.mp3")
        self:start()
    elseif self.state == 7 then
        self:close()
    else
        playSound("files/sounds/ready.mp3")
    end
end

function Counter:animate()
    if not self.tick then return end
    local progress = (getTickCount() - self.tick)/self.time
    self.alpha = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "InQuad")

    if progress >= 1 then
        if self.state == 6 then
            self:close()
            return true
        else
            self:next()
        end
    end
end

function Counter:render()
    if self:animate() then return end

    if self.state == 1 then
        dxDrawText(self.raceType == "Drag" and "TUŞLAR:\n#f0c437F #ffffff- aracı döndür\n#f0c437BACKSPACE #ffffff- yarışı iptal et\n#f0c437LSHIFT #ffffff- vitesi yükselt\n#f0c437LCTRL #ffffff- vitesi düşür" or "TUŞLAR:\n#f0c437F # ffffff- aracı döndür\n#f0c437BACKSPACE #ffffff- yarışı iptal et", guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.help, "center", "top", false, false, false, true)

    elseif self.state == 2 then
        dxDrawText("HAZIR?", guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.text, "center", "top")

    elseif self.state == 3 then
        dxDrawText("3", guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.text, "center", "top")

    elseif self.state == 4 then
        dxDrawText("2", guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.text, "center", "top")

    elseif self.state == 5 then
        dxDrawText("1", guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.text, "center", "top")

    elseif self.state == 6 then
        dxDrawText("BAŞLAAAA!", guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.text, "center", "top")

    end
end



function setVehicleFrozenOnRaceStart()
    setTimer(function()
        local veh = getPedOccupiedVehicle(localPlayer)
        setElementFrozen(veh, true)
    end, 1000, 1)
end
addEvent("setVehicleFrozenOnRaceStart", true)
addEventHandler("setVehicleFrozenOnRaceStart", root, setVehicleFrozenOnRaceStart)

function startRaceCountdown(type)
    setTimer(function()
        exports.TR_dx:hideLoading()
        setTimer(function()
            Counter:create(type)
        end, 2000, 1)
    end, 2000, 1)
end




function rotateVehicle()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return end

    local _, _, rot = getElementRotation(veh)
    setElementRotation(veh, 0, 0, rot)
end

function forceEndRace()
    if not RaceData.race then return end
    RaceData.race:forceEnd()
end

function unbindRaceKeys()
    unbindKey("f", "down", rotateVehicle)
    unbindKey("backspace", "down", forceEndRace)
end