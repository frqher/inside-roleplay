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

    workDiff = 0.8,

    tilt = 0.003,

    workTimeTotal = 0,

    workStates = {"walking", "jogging", "sprinting"}
}

BenchPress = {}
BenchPress.__index = BenchPress

function BenchPress:create(...)
    local instance = {}
    setmetatable(instance, BenchPress)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function BenchPress:constructor(...)
    self.alpha = 0
    self.work = 0

    self.workTotalTick = getTickCount()

    self.element = arg[1]
    self.cameraTarget = Vector3(getElementPosition(self.element)) + Vector3(0, 0, 1)

    local x, y, z = getPosition(self.element, Vector3(3, -4, 2.5))
    self.cameraPos = Vector3(x, y, z)

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.info = exports.TR_dx:getFont(11)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.setPlayerPushup = function() self:setPlayerPushup() end
    self.func.setPlayerPushdown = function() self:setPlayerPushdown() end

    self.func.onChangeSpeedKey = function(...) self:onChangeSpeedKey(...) end

    self:enterBench()
    bindKey("mouse1", "down", self.func.onChangeSpeedKey)
    bindKey("mouse2", "down", self.func.onChangeSpeedKey)

    setElementData(localPlayer, "isWorkouting", true)
    addEventHandler("onClientRender", root, self.func.render)
    return true
end

function BenchPress:destroy()
    removeEventHandler("onClientRender", root, self.func.render)

    setCameraTarget(localPlayer)
    setElementData(localPlayer, "isWorkouting", nil)

    exports.TR_dx:setOpenGUI(false)

    guiInfo.workout = nil
    self = nil
end

function BenchPress:animate()
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

function BenchPress:render()
    if self:animate() then return end
    setCameraMatrix(self.cameraPos, self.cameraTarget)

    drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 4)
    dxDrawText("Trenowanie wytrzymałości", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 40/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")

    local barW = guiInfo.w - 20/zoom
    dxDrawRectangle(sx/2 - barW/2, guiInfo.y + guiInfo.h - 100/zoom, barW, 30/zoom, tocolor(87, 7, 7, 255 * self.alpha))
    dxDrawRectangle(sx/2 - barW * guiInfo.workDiff/2, guiInfo.y + guiInfo.h - 100/zoom, barW * guiInfo.workDiff, 30/zoom, tocolor(7, 107, 7, 255 * self.alpha))

    dxDrawRectangle(sx/2 - barW/2 + barW * self.work, guiInfo.y + guiInfo.h - 105/zoom, 4/zoom, 40/zoom, tocolor(120, 120, 120, 255 * self.alpha))

    dxDrawText("Naciskaj przyciski LPM i PPM aby balansować sztangą nad swoją głową. Jeślni zbyt bardzo się przechyli zakończysz ćwiczenie.", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + guiInfo.h - 15/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "bottom", false, true)

    if (getTickCount() - self.workTotalTick)/1000 > 1 then
        self.workTotalTick = getTickCount()
        guiInfo.workTimeTotal = guiInfo.workTimeTotal + 1

        if guiInfo.workTimeTotal >= 120 then
            guiInfo.workTimeTotal = 0
            exports.TR_features:updateState("strenght", 3)
            exports.TR_features:updateState("fat", -2)
        end
    end

    if self.workState then
        local lower = -guiInfo.tilt
        if self.work <= 0.5 then
            lower = guiInfo.tilt
        end
        self.work = math.max(math.min(self.work - lower, 1), 0)

        if self.work < (1 - guiInfo.workDiff)/2 or self.work > 1 - (1 - guiInfo.workDiff)/2 then
            if self.workState ~= "falling" then
                self:setPlayerFallOff()
            end
        end
    end
end

function BenchPress:onChangeSpeedKey(key)
    if not self.workState then return end
    local move = key == "mouse1" and -0.08 or 0.08

    self.work = self.work + move
end


-- States
function BenchPress:setPlayerFallOff()
    if isTimer(self.timer) then killTimer(self.timer) end
    setPedAnimation(localPlayer, "benchpress", "gym_bp_getoff", -1, false, false, false, false, 250)
    setElementData(localPlayer, "animation", {"benchpress", "gym_bp_getoff", false, true})

    setTimer(function()
        setElementData(localPlayer, "animation", nil)
    end, 8000, 1)

    self.tick = getTickCount()
    self.state = "closing"
    self.workState = "falling"
    unbindKey("mouse1", "down", self.func.onChangeSpeedKey)
    unbindKey("mouse2", "down", self.func.onChangeSpeedKey)
end

function BenchPress:setPlayerPushup()
    setPedAnimation(localPlayer, "benchpress", "gym_bp_up_smooth", -1, false, false, false, true, 1000)
    setElementData(localPlayer, "animation", {"benchpress", "gym_bp_up_smooth", false, true})
    self.workState = "sprinting"

    self.timer = setTimer(self.func.setPlayerPushdown, 1200, 1)
end

function BenchPress:setPlayerPushdown()
    setPedAnimation(localPlayer, "benchpress", "gym_bp_down", -1, false, false, false, true, 1000)
    setElementData(localPlayer, "animation", {"benchpress", "gym_bp_down", false, true})

    self.timer = setTimer(self.func.setPlayerPushup, 1200, 1)
end

function BenchPress:enterBench()
    local x, y, z = getPosition(self.element, Vector3(0, -0.9, 1))
    local _, _, rot = getElementRotation(self.element)

    setElementPosition(localPlayer, x, y, z)
    setElementRotation(localPlayer, 0, 0, rot)

    setPedAnimation(localPlayer, "benchpress", "gym_bp_geton", -1, false, false, false, false)
    setElementData(localPlayer, "animation", {"benchpress", "gym_bp_geton", false, true})

    self.timer = setTimer(self.func.setPlayerPushup, 4200, 1)

    self.tick = getTickCount()
    self.state = "opening"
end

function startBenchPressWorkout(element)
    if guiInfo.workout then return end
    guiInfo.workout = BenchPress:create(element)
end