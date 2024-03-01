local settings = {
    vehicleModel = 428,

    states = {
        open = {
            pos = Vector3(0, 0, 0),
            rot = Vector3(0, 0, 0)
        },

        close = {
            pos = Vector3(0, 0, 0),
            rot = Vector3(0, 0, 0)
        },
    },
}

TowTruck = {}
TowTruck.__index = TowTruck

function TowTruck:create()
    local instance = {}
    setmetatable(instance, TowTruck)
    if instance:constructor() then
        return instance
    end
    return false
end

function TowTruck:constructor()
    self.streamed = {}

    self.func = {}
    self.func.render = function() self:render() end
    self.func.onVehicleStreamIn = function(...) self:onVehicleStreamIn(source, ...) end
    self.func.onVehicleStreamOut = function(...) self:onVehicleStreamOut(source, ...) end

    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientElementStreamIn", root, self.func.onVehicleStreamIn)
    addEventHandler("onClientElementStreamOut", root, self.func.onVehicleStreamOut)
    self:loadVehicles()
    return true
end

function TowTruck:onVehicleStreamOut(veh)
    if not self.streamed[veh] then return end
    self.streamed[veh] = nil
end

function TowTruck:onVehicleStreamIn(veh)
    if self.streamed[veh] then return end
    if getElementModel(veh) ~= settings.vehicleModel then return end

    local raidOpen = getElementData(veh, "raidOpen")
    self.streamed[veh] = {
        opened = raidOpen,
    }
end

function TowTruck:render(veh)
    for veh, data in pairs(self.streamed) do
        local winchVeh = getElementData(veh, "winchVeh")
        if winchVeh then
            local x, y, z = self:getPosition(veh, Vector3(0, 0, 0.1))
            local wx, wy, wz = self:getPosition(winchVeh, Vector3(0, 2, 0))
            dxDrawLine3D(x, y, z, wx, wy, wz, tocolor(6, 7, 8, 255), 3)
        end
    end

    self:updateLungs()
end

function TowTruck:updateLungs()
    if not isElementInWater(localPlayer) then return end
    if getElementModel(localPlayer) ~= 291 then return end

    local _, type = exports.TR_jobs:getPlayerJob()
    if type == "ers" or type == "fire" then
        local maxOxygen = math.floor(1000 + getPedStat(localPlayer, 22) * 1.5 + getPedStat(localPlayer, 225) * 1.5)
        setPedOxygenLevel(localPlayer, maxOxygen)
    end
end

function TowTruck:loadVehicles()
    for i, v in pairs(getElementsByType("vehicle", resourceRoot, true)) do
        self:onVehicleStreamIn(v)
    end
end

function TowTruck:getPosition(element, vec)
	local rot = Vector3(getElementRotation(element))
	local mat = Matrix(Vector3(getElementPosition(element)), rot)
	local newPos = mat:transformPosition(vec)
	return newPos.x, newPos.y, newPos.z, rot.z
end

setTimer(function()
    TowTruck:create()
end, 2000, 1)