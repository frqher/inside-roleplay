local haveReverseSound = {
    [416] = true,
    [427] = true,
    [544] = true,
    [456] = true,
    [578] = true,
}

Indicators = {}
Indicators.__index = Indicators

function Indicators:create(...)
    local instance = {}
    setmetatable(instance, Indicators)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function Indicators:constructor(...)
    self.streamed = {}
    self.lastSwitch = getTickCount()

    self.textures = {}
    self.textures.indicator = dxCreateTexture("files/images/indicators/indicator.png", "argb", true, "clamp")
    self.textures.reverse = dxCreateTexture("files/images/indicators/reverse.png", "argb", true, "clamp")

    self.shaders = {}
    self.shaders.left = dxCreateShader("files/shaders/replace.fx")
    self.shaders.right = dxCreateShader("files/shaders/replace.fx")
    self.shaders.reverse = dxCreateShader("files/shaders/replace.fx")
    dxSetShaderValue(self.shaders.left, "gTexture", self.textures.indicator)
    dxSetShaderValue(self.shaders.right, "gTexture", self.textures.indicator)
    dxSetShaderValue(self.shaders.reverse, "gTexture", self.textures.reverse)

    self.func = {}
    self.func.switcher = function(...) self:switch(...) end
    self.func.renderer = function(...) self:render(...) end
    self.func.streamerIn = function(...) self:streamIn(...) end
    self.func.streamerOut = function(...) self:streamOut(...) end

    bindKey("[", "down", self.func.switcher)
    bindKey("]", "down", self.func.switcher)
    bindKey("\\", "down", self.func.switcher)

    addEventHandler("onClientElementStreamIn", root, self.func.streamerIn)
    addEventHandler("onClientElementStreamOut", root, self.func.streamerOut)
    addEventHandler("onClientRender", root, self.func.renderer)

    self:streamStartup()
    return true
end


function Indicators:switch(...)
    if arg[1] == "[" then
        self:switchIndicator("left")

    elseif arg[1] == "]" then
        self:switchIndicator("right")

    elseif arg[1] == "\\" then
        self:switchIndicator("all")

    end
end

function Indicators:switchIndicator(...)
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return end
    if getPedOccupiedVehicleSeat(localPlayer) ~= 0 then return end
    local vehType = getVehicleType(veh)
    if vehType == "Plane" or vehType == "Helicopter" or vehType == "Boat" or vehType == "Train" or vehType == "Trailer" or vehType == "BMX" then return end

    if arg[1] == "left" then
        if self.all then return end
        self.left = not self.left
        setElementData(veh, "i:left", self.left)
        setElementData(veh, "i:right", nil)
        self.right = false

    elseif arg[1] == "right" then
        if self.all then return end
        self.right = not self.right
        setElementData(veh, "i:right", self.right)
        setElementData(veh, "i:left", nil)
        self.left = false

    elseif arg[1] == "all" then
        if self.left or self.right then return end
        self.all = not self.all
        setElementData(veh, "i:right", self.all)
        setElementData(veh, "i:left", self.all)

        self:clearIndicators(veh)
    end
end


function Indicators:render()
    for veh, _ in pairs(self.streamed) do
        if isElement(veh) and isElementStreamedIn(veh) then
            self:updateReverse(veh)
            self:updateIndicators(veh)
        else
            self:clearIndicators(veh)
            self:clearIndicatorsSound(veh)
            self.streamed[veh] = nil
        end
    end

    if (getTickCount() - self.lastSwitch)/500 >= 1 then
        self.state = not self.state
        self.lastSwitch = getTickCount()
        self:playIndicatorSound()
    end
end

function Indicators:playIndicatorSound()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return end

    local left, right = getElementData(veh, "i:left"), getElementData(veh, "i:right")
    if not left and not right then return end

    if not self.state then
        playSound("files/sounds/blinker_off.wav")
    else
        playSound("files/sounds/blinker_on.wav")
    end
end

function Indicators:updateReverse(veh)
    local gear = getVehicleCurrentGear(veh)
    if getVehicleEngineState(veh) and gear <= 0 then
        engineApplyShaderToWorldTexture(self.shaders.reverse, "reverse", veh)

        if not isElement(self.streamed[veh].sound) and haveReverseSound[getElementModel(veh)] then
            self.streamed[veh].sound = playSound3D("files/sounds/reverse.wav", 0, 0, 0, true)
            setSoundMinDistance(self.streamed[veh].sound, 0)
            setSoundMaxDistance(self.streamed[veh].sound, 25)
            attachElements(self.streamed[veh].sound, veh)
        end
    else
        engineRemoveShaderFromWorldTexture(self.shaders.reverse, "reverse", veh)
        if isElement(self.streamed[veh].sound) then destroyElement(self.streamed[veh].sound) end
    end
end

function Indicators:updateIndicators(veh)
    local left, right = getElementData(veh, "i:left"), getElementData(veh, "i:right")
    if left or right then
        if left then
            if self.state then
                engineApplyShaderToWorldTexture(self.shaders.left, "indicator_l", veh)
            else
                engineRemoveShaderFromWorldTexture(self.shaders.left, "indicator_l", veh)
            end
        else
            engineRemoveShaderFromWorldTexture(self.shaders.left, "indicator_l", veh)
        end
        if right then
            if self.state then
                engineApplyShaderToWorldTexture(self.shaders.right, "indicator_r", veh)
            else
                engineRemoveShaderFromWorldTexture(self.shaders.right, "indicator_r", veh)
            end
        else
            engineRemoveShaderFromWorldTexture(self.shaders.right, "indicator_r", veh)
        end

    else
        engineRemoveShaderFromWorldTexture(self.shaders.left, "indicator_l", veh)
        engineRemoveShaderFromWorldTexture(self.shaders.right, "indicator_r", veh)
    end
end

function Indicators:updateNewState(veh)
    local left, right = getElementData(veh, "i:left"), getElementData(veh, "i:right")
    if left and right then
        self.left = false
        self.right = false
        self.all = true

    elseif left then
        self.left = true
        self.right = false
        self.all = false

    elseif right then
        self.left = false
        self.right = true
        self.all = false
    end
end

function Indicators:clearIndicators(veh)
    if not self.streamed[veh] then return end
    if not isElement(veh) then return end

    engineRemoveShaderFromWorldTexture(self.shaders.left, "indicator_l", veh)
    engineRemoveShaderFromWorldTexture(self.shaders.right, "indicator_r", veh)
end

function Indicators:clearIndicatorsSound(veh)
    if not self.streamed[veh] then return end
    if isElement(self.streamed[veh].sound) then destroyElement(self.streamed[veh].sound) end
    if not isElement(veh) then return end

    engineRemoveShaderFromWorldTexture(self.shaders.reverse, "reverse", veh)
end

function Indicators:getVehicleState(veh)
    if not veh then return false end
    if not self.state then return false end
    local left, right = getElementData(veh, "i:left"), getElementData(veh, "i:right")
    if not left and not right then return false end

    if left and right then return "all"
    elseif left then return "left"
    elseif right then return "right"
    end
end

function Indicators:streamStartup(...)
    for _, veh in ipairs(getElementsByType("vehicle", root, true)) do
        if not self.streamed[veh] then self.streamed[veh] = {} end
    end
end

function Indicators:streamIn(...)
    if getElementType(source) == "vehicle" then
        if not self.streamed[source] then self.streamed[source] = {} end
    end
end

function Indicators:streamOut(...)
    if getElementType(source) == "vehicle" then
        if self.streamed[source] then
            self:clearIndicators(source)
            self:clearIndicatorsSound(source)
            self.streamed[source] = nil
        end
    end
end