local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 500/zoom)/2,
    y = sy - 150/zoom,
    w = 500/zoom,
    h = 150/zoom,

    workDiff = 0.5,

    walkDown = 0.001,
    jogDown = 0.003,
    sprintDown = 0.005,

    workUp = 0.05,

    workTimeTotal = 0,

    workStates = {"walking", "jogging", "sprinting"}
}

Bike = {}
Bike.__index = Bike

function Bike:create(...)
    local instance = {}
    setmetatable(instance, Bike)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function Bike:constructor(...)
    guiInfo.workDiff = 0.5

    self.alpha = 0
    self.work = 0
    self.workIndex = 1

    self.workTotalTick = getTickCount()

    self.element = arg[1]
    self.cameraTarget = Vector3(getElementPosition(self.element)) + Vector3(0, 0, 1)

    local x, y, z = getPosition(self.element, Vector3(-3, 4, 2.5))
    self.cameraPos = Vector3(x, y, z)

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.info = exports.TR_dx:getFont(11)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.onPlayerPrepare = function() self:onPlayerPrepare() end
    self.func.setPlayerWalking = function() self:setPlayerWalking() end
    self.func.setPlayerJogging = function() self:setPlayerJogging() end
    self.func.setPlayerSprinting = function() self:setPlayerSprinting() end
    self.func.onSprintKey = function() self:onSprintKey() end
    self.func.onChangeSpeedKey = function(...) self:onChangeSpeedKey(...) end

    self:enterThreadmill()

    bindKey("sprint", "down", self.func.onSprintKey)
    bindKey("mouse1", "down", self.func.onChangeSpeedKey)
    bindKey("mouse2", "down", self.func.onChangeSpeedKey)

    setElementData(localPlayer, "isWorkouting", true)
    addEventHandler("onClientRender", root, self.func.render)
    return true
end

function Bike:destroy()
    removeEventHandler("onClientRender", root, self.func.render)

    setCameraTarget(localPlayer)
    setElementData(localPlayer, "isWorkouting", nil)

    exports.TR_dx:setOpenGUI(false)

    guiInfo.workout = nil
    self = nil
end

function Bike:animate()
    if not self.tick then return end
    if self.state == "opening" then
        local progress = (getTickCount() - self.tick)/500
        self.alpha = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "Linear")
        self.work = self.alpha/2

        if progress >= 1 then
            self.tick = nil
            self.state = "opened"
        end


    elseif self.state == "closing" then
        local progress = (getTickCount() - self.tick)/500
        self.alpha = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "Linear")

        if progress >= 1 then
            self:destroy()
            return true
        end
    end
end

function Bike:render()
    if self:animate() then return end
    setCameraMatrix(self.cameraPos, self.cameraTarget)

    drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 4)
    dxDrawText("Trenowanie wytrzymałości", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 40/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")

    local barW = guiInfo.w - 20/zoom
    dxDrawRectangle(sx/2 - barW/2, guiInfo.y + guiInfo.h - 100/zoom, barW, 30/zoom, tocolor(87, 7, 7, 255 * self.alpha))
    dxDrawRectangle(sx/2 - barW * guiInfo.workDiff/2, guiInfo.y + guiInfo.h - 100/zoom, barW * guiInfo.workDiff, 30/zoom, tocolor(7, 107, 7, 255 * self.alpha))

    dxDrawRectangle(sx/2 - barW/2 + barW * self.work, guiInfo.y + guiInfo.h - 105/zoom, 4/zoom, 40/zoom, tocolor(120, 120, 120, 255 * self.alpha))

    dxDrawText("Naciskaj przycisk sprintu aby przesuwać znacznik w prawo. Możesz regulować prędkość pedałowania naciskając LPM i PPM.", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + guiInfo.h - 15/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "bottom", false, true)

    if (getTickCount() - self.workTotalTick)/1000 > 1 then
        self.workTotalTick = getTickCount()
        guiInfo.workTimeTotal = guiInfo.workTimeTotal + self.workIndex

        if guiInfo.workTimeTotal >= 180 then
            guiInfo.workTimeTotal = 0
            exports.TR_features:updateState("lungs", 2)
            exports.TR_features:updateState("fat", -3)
        end
    end

    if self.workState then
        local lower = 0
        if self.workState == "walking" then
            lower = guiInfo.walkDown

        elseif self.workState == "jogging" then
            lower = guiInfo.jogDown

        elseif self.workState == "sprinting" then
            lower = guiInfo.sprintDown
        end

        self.work = math.max(math.min(self.work - lower, 1), 0)

        if self.work < (1 - guiInfo.workDiff)/2 or self.work > 1 - (1 - guiInfo.workDiff)/2 then
            if self.workState ~= "falling" then
                self:setPlayerFallOff()
            end
        end
    end
end

function Bike:onSprintKey()
    if not self.workState then return end

    self.work = self.work + guiInfo.workUp
end

function Bike:onChangeSpeedKey(key)
    if not self.workState then return end
    local move = key == "mouse1" and -1 or 1

    local newIndex = self.workIndex + move
    if newIndex > #guiInfo.workStates then newIndex = #guiInfo.workStates end
    if newIndex < 1 then newIndex = 1 end
    if newIndex == self.workIndex then return end

    self.workIndex = newIndex
    local state = guiInfo.workStates[self.workIndex]
    if state == self.workState then return end

    self.workState = state
    if self.workState == "sprinting" then
        self:setPlayerSprinting()
        guiInfo.workDiff = 0.3

    elseif self.workState == "jogging" then
        self:setPlayerJogging()
        guiInfo.workDiff = 0.4

    elseif self.workState == "walking" then
        self:setPlayerWalking()
        guiInfo.workDiff = 0.5
    end
end


-- States
function Bike:setPlayerFallOff()
    setPedAnimation(localPlayer, "gymnasium", "gym_bike_getoff", -1, false, false, false, false, 500)
    setElementData(localPlayer, "animation", {"gymnasium", "gym_bike_getoff", false, true})

    setTimer(function()
        setElementData(localPlayer, "animation", nil)
    end, 1500, 1)

    self.tick = getTickCount()
    self.state = "closing"
    self.workState = "falling"

    unbindKey("sprint", "down", self.func.onSprintKey)
    unbindKey("mouse1", "down", self.func.onChangeSpeedKey)
    unbindKey("mouse2", "down", self.func.onChangeSpeedKey)
end

function Bike:setPlayerSprinting()
    setPedAnimation(localPlayer, "gymnasium", "gym_bike_fast", -1, true, false, false, false, 500)
    setElementData(localPlayer, "animation", {"gymnasium", "gym_bike_fast", false, true})
    self.workState = "sprinting"
end

function Bike:setPlayerJogging()
    setPedAnimation(localPlayer, "gymnasium", "gym_bike_pedal", -1, true, false, false, false, 500)
    setElementData(localPlayer, "animation", {"gymnasium", "gym_bike_pedal", false, true})
    self.workState = "jogging"
end

function Bike:setPlayerWalking()
    setPedAnimation(localPlayer, "gymnasium", "gym_bike_slow", -1, true, false, false, false, 500)
    setElementData(localPlayer, "animation", {"gymnasium", "gym_bike_slow", false, true})
    self.workState = "walking"
end

function Bike:enterThreadmill()
    local x, y, z = getPosition(self.element, Vector3(0.5, 0.51, 1))
    local _, _, rot = getElementRotation(self.element)

    setElementPosition(localPlayer, x, y, z)
    setElementRotation(localPlayer, 0, 0, rot - 180)

    setPedAnimation(localPlayer, "gymnasium", "gym_bike_geton", 1300, false, false, false, false)
    setElementData(localPlayer, "animation", {"gymnasium", "gym_bike_geton", false, true})
    self.timer = setTimer(self.func.setPlayerWalking, 1300, 1)

    self.tick = getTickCount()
    self.state = "opening"
end



function startBikeWorkout(element)
    if guiInfo.workout then return end
    guiInfo.workout = Bike:create(element)
end