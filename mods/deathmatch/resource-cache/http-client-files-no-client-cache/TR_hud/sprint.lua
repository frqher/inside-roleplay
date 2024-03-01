SprintData = {}
SprintData.__index = SprintData

function SprintData:create()
    local instance = {}
    setmetatable(instance, SprintData)
    if instance:constructor() then
        return instance
    end
    return false
end

function SprintData:constructor()
    self.sprintKeys = {}
    self.jumpKeys = {}

    self.jumpCost = 5
    self.minRecovery = 50

    self.func = {}
    self.func.sprint = function(...) self:sprintKey(...) end
    self.func.jump = function(...) self:jumpKey(...) end
    self.func.checker = function(...) self:check(...) end
    setTimer(self.func.checker, 100, 0)

    self:bindKeys()
    return true
end

function SprintData:bindKeys()
    for key, _ in pairs(getBoundKeys("sprint")) do
        if not self.sprintKeys[key] then
            bindKey(key, "both", self.func.sprint)
            self.sprintKeys[key] = true
        end
    end

    for key, _ in pairs(getBoundKeys("jump")) do
        if not self.jumpKeys[key] then
            bindKey(key, "both", self.func.jump)
            self.jumpKeys[key] = true
        end
    end
end

function SprintData:sprintKey(...)
    if isPedWearingJetpack(localPlayer) then return end
    if arg[2] == "down" and not self.blocked then
        if getPedOccupiedVehicle(localPlayer) then setPedControlState(localPlayer, "sprint", false) return end
        if self:isCuffed() then setPedControlState(localPlayer, "sprint", false) return end
        if exports.TR_items:isPlayerOverloaded() then setPedControlState(localPlayer, "sprint", false) return end
        if exports.TR_features:getFeatureValue("fat") > 80 then setPedControlState(localPlayer, "sprint", false) return end
        setPedControlState(localPlayer, "sprint", true)
    else
        setPedControlState(localPlayer, "sprint", false)
    end
end

function SprintData:jumpKey(...)
    if arg[2] == "down" and not self.blocked then
        if getPedOccupiedVehicle(localPlayer) then setPedControlState(localPlayer, "jump", false) return end
        if self:isCuffed() then setPedControlState(localPlayer, "jump", false) return end
        if exports.TR_items:isPlayerOverloaded() then setPedControlState(localPlayer, "jump", false) return end
        if exports.TR_features:getFeatureValue("fat") > 80 then setPedControlState(localPlayer, "jump", false) return end
        setPedControlState(localPlayer, "jump", true)
    else
        setPedControlState(localPlayer, "jump", false)
    end
end

function SprintData:checkDrunk()
    if self.drunkTime then
        if (getTickCount() - self.drunkTime)/(self.drunkStateTime * 1000) >= 1 then
            self.drunkTime = getTickCount()

            if self.drunkState then
                toggleControl(self.drunkState == 1 and "left" or "right", true)
                setPedControlState(self.drunkState == 1 and "left" or "right", false)
                toggleControl(self.drunkState == 1 and "vehicle_left" or "vehicle_right", true)
                setPedControlState(self.drunkState == 1 and "vehicle_left" or "vehicle_right", false)
                self.drunkState = nil
                self.drunkStateTime = math.random(10, 40)/10
            else
                self.drunkState = math.random(1, 2)
                self.drunkStateTime = math.random(10, 40)/100
                toggleControl(self.drunkState == 1 and "left" or "right", false)
                setPedControlState(self.drunkState == 1 and "left" or "right", true)
                toggleControl(self.drunkState == 1 and "vehicle_left" or "vehicle_right", false)
                setPedControlState(self.drunkState == 1 and "vehicle_left" or "vehicle_right", true)
            end
        end
    end
end

function SprintData:check()
    self:updateVehicleFire()

    if self.isDrunk then
        self:checkDrunk()
        self:disableSprint(true)
        setPedControlState("walk", true)
        toggleControl("walk", false)

    elseif not self.wasCuffed and self:isCuffed() then
        self:disableSprint(true)
        self.wasCuffed = true

    elseif self.wasCuffed and not self:isCuffed() then
        self:disableSprint(false)
        self.wasCuffed = nil
    end

    self:bindKeys()
end

function SprintData:disableSprint(...)
    self.blocked = arg[1]

    if self.blocked then
        toggleControl("sprint", false)
        toggleControl("jump", false)
    else
        toggleControl("sprint", true)
        toggleControl("jump", true)
    end
end

function SprintData:setPlayerDrunk(...)
    if arg[1] and not self.isDrunk then
        triggerServerEvent("setPlayerWalkingStyle", resourceRoot, 126)

    elseif not arg[1] and self.isDrunk then
        triggerServerEvent("setPlayerWalkingStyle", resourceRoot, 0)
    end

    self:disableSprint(arg[1])
    self.isDrunk = arg[1]
    self.drunkTime = self.isDrunk and getTickCount() or nil
    self.drunkStateTime = self.isDrunk and math.random(3, 5) or nil
    toggleControl("walk", not arg[1])

    toggleControl("left", true)
    toggleControl("right", true)
    setPedControlState("left", false)
    setPedControlState("right", false)
    toggleControl("vehicle_left", true)
    toggleControl("vehicle_right", true)
    setPedControlState("vehicle_left", false)
    setPedControlState("vehicle_right", false)
end

function SprintData:isCuffed()
    local cuffed = getElementData(localPlayer, "cuffed")
    if isElement(cuffed) then
        if isElementAttached(cuffed) then
            return true
        end
    end
    return false
end

function SprintData:updateVehicleFire()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return end

    if getElementModel(veh) == 407 then
        toggleControl("vehicle_fire", false)
        toggleControl("vehicle_secondary_fire", false)
    else
        toggleControl("vehicle_fire", true)
        toggleControl("vehicle_secondary_fire", true)
    end
end

local sprint = SprintData:create()

function blockPlayerSprint(...)
    sprint:disableSprint(...)
end

function setPlayerDrunk(...)
    sprint:setPlayerDrunk(...)
end