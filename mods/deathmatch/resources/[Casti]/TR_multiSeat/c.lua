MultiSeat = {}
MultiSeat.__index = MultiSeat


function MultiSeat:create()
    local instance = {}
    setmetatable(instance, MultiSeat)
    if instance:constructor() then
        return instance
    end
    return true
end

function MultiSeat:constructor()
    self.vehicles = {}

    self.func = {}
    self.func.update = function() self:update() end
    self.func.onKey = function() self:onKey() end
    self.func.enterMarker = function(...) self:enterMarker(source, ...) end
    self.func.exitMarker = function(...) self:exitMarker(source, ...) end
    self.func.cancelVehicleEnter = function(...) self:cancelVehicleEnter(source, ...) end
    self.func.onVehicleExit = function(...) self:exitVehicle(source, ...) end

    setTimer(self.func.update, 10000, 0)
    self:update()

    bindKey("enter_exit", "down", self.func.onKey)
    bindKey("g", "down", self.func.onKey)
    addEventHandler("onClientMarkerHit", resourceRoot, self.func.enterMarker)
    addEventHandler("onClientMarkerLeave", resourceRoot, self.func.exitMarker)
    addEventHandler("onClientVehicleStartEnter", resourceRoot, self.func.cancelVehicleEnter)
    addEventHandler("onClientVehicleStartExit", resourceRoot, self.func.onVehicleExit)
    return true
end

function MultiSeat:update()
    for i, v in pairs(getElementsByType("vehicle", root, true)) do
        local model = getElementModel(v)

        if multiSeatVehicles[model] then
            self:createVehicleMultiSeat(v)
            setVehicleDoorOpenRatio(v, 4, 0, 1)
            setVehicleDoorOpenRatio(v, 5, 0, 1)
        end
    end

    for i, v in pairs(self.vehicles) do
        if not isElement(i) or not isElementStreamedIn(i) then
            self:removeVehicleMultiSeat(i)
        end
    end
end

function MultiSeat:createVehicleMultiSeat(veh)
    if self.vehicles[veh] or not veh then return end
    local model = getElementModel(veh)
    self.vehicles[veh] = {}

    for i, v in pairs(multiSeatVehicles[model].enterPos) do
        local marker = createMarker(0, 0, 0, "cylinder", 0.8, 255, 0, 0, 0)
        setElementData(marker, "veh", veh, false)
        setElementData(marker, "pos", v.pos, false)
        setElementData(marker, "doors", v.doors, false)
        attachElements(marker, veh, v.pos)
    end
end

function MultiSeat:removeVehicleMultiSeat(veh)
    if not self.vehicles[veh] then return end
end

function MultiSeat:enterVehicle(veh)
    if not self.blockEnter or not veh then return end

    local pos = Vector3(getElementPosition(veh))
    local posOffset = getElementData(self.blockEnter, "pos")
    local doors = getElementData(self.blockEnter, "doors")

    local x, y, z = self:getPosition(veh, posOffset)
    local _, _, rot = getElementRotation(veh)

    setElementPosition(localPlayer, x, y, z)
    setElementRotation(localPlayer, 0, 0, rot)

    triggerServerEvent("enterVehicleBackSeat", resourceRoot, veh, doors)
    setCameraClip(true, false)

    self.enteredVeh = self.blockEnter
    self.blockEnter = nil
end

function MultiSeat:exitVehicle(veh, plr)
    if plr ~= localPlayer then return end
    if not self.enteredVeh then return end

    local veh = getElementData(self.enteredVeh, "veh")
    local doors = getElementData(self.enteredVeh, "doors")

    triggerServerEvent("exitVehicleBackSeat", resourceRoot, veh, doors)

    setTimer(setCameraClip, 2000, 1, true, true)

    self.enteredVeh = nil
end

function MultiSeat:exitMarker(source, plr)
    if plr ~= localPlayer then return end

    self.blockEnter = nil
end

function MultiSeat:enterMarker(source, plr)
    if plr ~= localPlayer then return end
    if getPedOccupiedVehicle(localPlayer) then return end
    if self.blockEnter then return end

    self.blockEnter = source
end

function MultiSeat:onKey()
    if not self.blockEnter then return end
    local veh = getElementData(self.blockEnter, "veh")

    self:enterVehicle(veh)
    setCameraTarget(veh)

    self.blockEnter = nil
end

function MultiSeat:cancelVehicleEnter(source, plr)
    if plr ~= localPlayer then return end
    cancelEvent()
end

function MultiSeat:getPosition(element, vec)
	local rot = Vector3(getElementRotation(element))
	local mat = Matrix(Vector3(getElementPosition(element)), rot)
	local newPos = mat:transformPosition(vec)
	return newPos.x, newPos.y, newPos.z, rot.z
end

function MultiSeat:getElementSpeed(theElement, unit)
    assert(isElement(theElement), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(theElement) .. ")")
    local elementType = getElementType(theElement)
    assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "Invalid element type @ getElementSpeed (player/ped/object/vehicle/projectile expected, got " .. elementType .. ")")
    assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)")
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    return (Vector3(getElementVelocity(theElement)) * mult).length
end

MultiSeat:create()

-- function onVehicleEnter(plr, seat, door)
--   if plr ~= localPlayer then return end

--   local model = getElementModel(source)
--   if not multiSeat[model] then return end


-- end
-- addEventHandler("onClientVehicleEnter", root, onVehicleEnter)

-- function setFireCol(veh)
--   setElementCollidableWith(veh, localPlayer, false)
--   setElementCollisionsEnabled(veh, false)
-- end
-- addEvent("setFireCol", true)
-- addEventHandler("setFireCol", root, setFireCol)