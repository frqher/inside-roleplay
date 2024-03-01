local componentNames = {
    {"wheel_rf_dummy", 0},
    {"wheel_lf_dummy", 180},
    {"wheel_rb_dummy", 0},
    {"wheel_lb_dummy", 180},
}

WheelBlock = {}
WheelBlock.__index = WheelBlock

function WheelBlock:create()
    local instance = {}
    setmetatable(instance, WheelBlock)
    if instance:constructor() then
        return instance
    end
    return false
end

function WheelBlock:constructor()
    self.vehicles = {}

    self.func = {}
    self.func.updateVehicles = function() self:updateVehicles() end

    setTimer(self.func.updateVehicles, 10000, 0)

    self:updateVehicles()
    return true
end

function WheelBlock:updateVehicles()
    for i, v in pairs(getElementsByType("vehicle", resourceRoot, true)) do
        if self.vehicles[v] then
            if not getElementData(v, "wheelBlock") then
                self:destroyVehicleBlock(v)
            end
        else
            local wheel = getElementData(v, "wheelBlock")
            if wheel then
                self:createVehicleBlock(v, wheel)
            end
        end
    end

    for i, v in pairs(self.vehicles) do
        if not getElementData(v, "wheelBlock") or not isElement(v) then
            self:destroyVehicleBlock(v)
        end
    end
end

function WheelBlock:updateVehicle(veh)
    if self.vehicles[veh] then
        if not getElementData(veh, "wheelBlock") then
            self:destroyVehicleBlock(veh)
        end
    else
        local wheel = getElementData(veh, "wheelBlock")
        if wheel then
            self:createVehicleBlock(veh, wheel)
        end
    end
end

function WheelBlock:createVehicleBlock(veh, wheel)
    if self.vehicles[veh] then return end

    self.vehicles[veh] = createObject(1875, 0, 0, 0)
    setObjectScale(self.vehicles[veh], 0.8)

    self:setBlockPosition(veh, wheel)
end

function WheelBlock:destroyVehicleBlock(veh)
    if not self.vehicles[veh] then return end
    destroyElement(self.vehicles[veh])

    self.vehicles[veh] = nil
end

function WheelBlock:setBlockPosition(veh, wheel)
    local rot = Vector3(getElementRotation(veh))
    local name, rotY = self:getWheelName(wheel)

    setElementRotation(self.vehicles[veh], rotY == 0 and rot.x + 320 or rot.x + 200, rot.y + rotY, rot.z)
    local wheelPos = Vector3(getVehicleComponentPosition(veh, name, "world"))

    setElementPosition(self.vehicles[veh], wheelPos)
end

function WheelBlock:getWheelName(wheel)
    local data = componentNames[wheel]
    return data[1], data[2]
end


local blockWheel = WheelBlock:create()

function updateBlockWheel(veh)
    blockWheel:updateVehicle(veh)
end
addEvent("updateBlockWheel", true)
addEventHandler("updateBlockWheel", root, updateBlockWheel)



function getNearestWhellID(veh)
    local plrPos = Vector3(getElementPosition(localPlayer))
    local nearestDist = 3000
    local wheel = false

    for i, v in pairs(componentNames) do
        local pos = Vector3(getVehicleComponentPosition(veh, v[1], "world"))
        local dist = getDistanceBetweenPoints3D(plrPos, pos)
        if nearestDist >= dist then
            wheel = i
            nearestDist = dist
        end
    end

    return wheel
end