VehicleBlips = {}
VehicleBlips.__index = VehicleBlips

function VehicleBlips:create()
	local instance = {}
	setmetatable(instance, VehicleBlips)
	if instance:constructor() then
		return true
	end
	return false
end

function VehicleBlips:constructor()
	self.vehicles = {}

	self.func = {}
	self.func.update = function() self:updateVehicles() end
	self.func.remove = function() self:removeVehicle(source) end

	addEventHandler("onClientElementDestroy", root, self.func.remove)
	setTimer(self.func.update, 10000, 0)
	return true
end

function VehicleBlips:updateVehicles()
	if not getElementData(localPlayer, "characterUID") then return end
	for i, _ in pairs(self.vehicles) do
		if not isElement(i) then
			if isElement(self.vehicles[i]) then destroyElement(self.vehicles[i]) end
			self.vehicles[i] = nil
		end
	end
	for i, v in ipairs(getElementsByType("vehicle", resourceRoot)) do
		self:addVehicle(v)
	end
end

function VehicleBlips:addVehicle(vehicle)
	if not canShowVehicleBlip(vehicle) then self:removeVehicle(vehicle) return end
	if self.vehicles[vehicle] then return end

	self.vehicles[vehicle] = createBlip(0, 0, 0, 0, 0, 2, 137, 213, 255)
	setElementData(self.vehicles[vehicle], "icon", 2, false)
	attachElements(self.vehicles[vehicle], vehicle)
	setElementData(self.vehicles[vehicle], "vehObject", vehicle, false)
end

function VehicleBlips:removeVehicle(vehicle)
	if not self.vehicles[vehicle] then return end
	if isElement(self.vehicles[vehicle]) then destroyElement(self.vehicles[vehicle]) end
	self.vehicles[vehicle] = nil
end


function canShowVehicleBlip(vehicle)
	local vehData = getElementData(vehicle, "vehicleOwners")
	if not vehData then return end

	local vehOrganization = getElementData(vehicle, "vehicleOrganization")
	if vehOrganization then
		if vehOrganization == getElementData(localPlayer, "characterOrgID") then
			return true
		end
	end

	local uid = getElementData(localPlayer, "characterUID")
	for i, v in ipairs(vehData) do
		if v == uid or v == getPlayerName(localPlayer) then return true end
	end
	return false
end

function isVehicleOwner(vehicle)
	if getElementData(localPlayer, "adminDuty") then return true end
	if getElementData(vehicle, "freeForAll") then return true end

	local jobVehicle = getElementData(vehicle, "vehicleOwner")
	if jobVehicle then
		if jobVehicle == localPlayer then return true end
	end

	local vehicleFraction = getElementData(vehicle, "fractionID")
	local plrFraction = getElementData(localPlayer, "characterDuty")
	if vehicleFraction then
		if plrFraction then
			if vehicleFraction == plrFraction[4] then return true end
		end
		return false
	end

	local vehData = getElementData(vehicle, "vehicleOwners")
	if not vehData then return end

	local vehOrganization = getElementData(vehicle, "vehicleOrganization")
	if vehOrganization then
		if vehOrganization == getElementData(localPlayer, "characterOrgID") then
			return true
		end
	end

	local uid = getElementData(localPlayer, "characterUID")
	for i, v in ipairs(vehData) do
		if v == uid or v == getPlayerName(localPlayer) then return true end
	end
	return false
end


VehicleBlips:create()


local benchmarkVehicles = {}
local benchmarkCoroutine
function destroyBenchmarkVehicles()
	for i, v in pairs(benchmarkVehicles) do
		destroyElement(v)
	end
	benchmarkVehicles = {}
end

function createBenchmarkVehicles(maxVehicles, models)
	benchmarkCoroutine = coroutine.create(createBenchmarkVehiclesCoroutine)
	coroutine.resume(benchmarkCoroutine, maxVehicles, models)
end

function createBenchmarkVehiclesCoroutine(maxVehicles, models)
	local i = 0
	for _ = 0, 50 do
		table.insert(benchmarkVehicles, createBenchmarkVehicle(models[math.random(1, #models)], -1657.5361328125 + i * 6, -158.841796875 + i * 6, 13.834096908569, 0, 0, 223))
		i = i + 1

		if i%5 == 0 then
			setTimer(function()
				coroutine.resume(benchmarkCoroutine, maxVehicles, models)
			end, 100, 1)
			coroutine.yield(benchmarkCoroutine)
		end
	end
	local i = 30
	for _ = 0, 20 do
		table.insert(benchmarkVehicles, createBenchmarkVehicle(models[math.random(1, #models)], -1651.5361328125 + i * 6, -163.841796875 + i * 6, 13.834096908569, 0, 0, 223))
		i = i + 1
		if i%5 == 0 then
			setTimer(function()
				coroutine.resume(benchmarkCoroutine, maxVehicles, models)
			end, 100, 1)
			coroutine.yield(benchmarkCoroutine)
		end
	end

	local i = 102
	for _ = 0, maxVehicles do
		table.insert(benchmarkVehicles, createBenchmarkVehicle(models[math.random(1, #models)], -1663.5361328125 + i * 3, -153.841796875 + i * 3, 13.834096908569, 0, 0, 223))
		table.insert(benchmarkVehicles, createBenchmarkVehicle(models[math.random(1, #models)], -1657.5361328125 + i * 3, -158.841796875 + i * 3, 13.834096908569, 0, 0, 223))
		table.insert(benchmarkVehicles, createBenchmarkVehicle(models[math.random(1, #models)], -1651.5361328125 + i * 3, -163.841796875 + i * 3, 13.834096908569, 0, 0, 223))
		table.insert(benchmarkVehicles, createBenchmarkVehicle(models[math.random(1, #models)], -1645.5361328125 + i * 3, -168.841796875 + i * 3, 13.834096908569, 0, 0, 223))
		i = i + 1
		if i%5 == 0 then
			setTimer(function()
				coroutine.resume(benchmarkCoroutine, maxVehicles, models)
			end, 100, 1)
			coroutine.yield(benchmarkCoroutine)
		end
	end
end

function createBenchmarkVehicle(model, x, y, z, rx, ry, rz)
    local veh = createVehicle(model, x, y, z, rx, ry, rz)
    setElementData(veh, "neonEnabled", true, false)
	setElementDimension(veh, 4891)

    for i= 0, math.random(0, 5) do
        addVehicleUpgrade(veh, math.random(1000, 1193))
    end

	setElementData(veh, "neonEnabled", true, false)
	setElementData(veh, "visualTuning", {
		neon = {math.random(1, 3), math.random(0, 255), math.random(0, 255), math.random(0, 255)},
		glassTint = math.random(0, 100)/100
	}, false)
	return veh
end