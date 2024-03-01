local settings = {
	loadingResumeTime = 500,

	loadedVehicles = false,
	startTime = getRealTime().timestamp,
}

VehicleSpawner = {}
VehicleSpawner.__index = VehicleSpawner

function VehicleSpawner:create()
	local instance = {}
	setmetatable(instance, VehicleSpawner)
	if instance:constructor() then
		return instance
	end
	return false
end

function VehicleSpawner:constructor()
	self.count = 0
	self.maxOnce = 20
	self.timeWait = 1000
	self.totalCount = 0

	self.func = {}
	self.func.spawnVehiclesCo = function(...) self:spawnVehiclesCoroutine(...) end

	return true
end

function VehicleSpawner:spawnVehicle(id, model, pos, health, fuel, engineType, mileage, color, paintjob, variant, panelstates, doorstates, plateText, tuning, visualTuning, performanceTuning, owners, ownedOrg, wheelBlock, vehicleDirt)
	local position = split(pos, ",")
	local color = split(color, ",")
	local panelstates = split(panelstates, ",")
	local doorstates = split(doorstates, ",")
	local health = tonumber(health)
	local performanceTuning = performanceTuning and fromJSON(performanceTuning) or false

	local vehicle = createVehicle(model, position[1], position[2], position[3] - 2, position[4], position[5], position[6], plateText and string.format("SA %s", plateText) or string.format("SA %05d", id))
	setVehicleColor(vehicle, color[1], color[2], color[3], color[4], color[5], color[6], color[7], color[8], color[9], color[10], color[11], color[12])
	setVehicleHeadLightColor(vehicle, color[13], color[14], color[15])
	setElementHealth(vehicle, math.max(health, 301))
	if health == 301 then setVehicleDamageProof(vehicle, true) end
	if paintjob then setVehiclePaintjob(vehicle, paintjob) end
	setVehicleOverrideLights(vehicle, 1)
	setElementFrozen(vehicle, true)
	setVehicleLocked(vehicle, true)

	if model ~= 522 then
		local variant = split(variant, ",")
		setVehicleVariant(vehicle, tonumber(variant[1]), tonumber(variant[2]))
	end

	setTimer(function()
		for i = 0, 6 do
			setVehiclePanelState(vehicle, i, panelstates[i + 1])
		end
		for i = 0, 1 do
			setVehicleLightState(vehicle, i, panelstates[i + 7])
		end
		for i = 0, 5 do
			setVehicleDoorState(vehicle, i, doorstates[i + 1])
		end

		self:tuneVehicle(vehicle, tuning)
		setElementPosition(vehicle, position[1], position[2], position[3])
	end, 200, 1)

	setElementID(vehicle, "vehicle"..id)
	setElementData(vehicle, "vehicleID", id)
	setElementData(vehicle, "vehicleData", {
		ID = id,
		fuel = tonumber(fuel),
		mileage = tonumber(mileage),
		engineType = engineType,
	}, false)
	setElementData(vehicle, "vehicleOwners", owners)
	setElementData(vehicle, "vehicleOrganization", ownedOrg)
	setElementData(vehicle, "visualTuning", visualTuning and fromJSON(visualTuning) or false)
	setElementData(vehicle, "performanceTuning", performanceTuning)
	setElementData(vehicle, "vehicleGrunge", tonumber(vehicleDirt))

	if wheelBlock then setElementData(vehicle, "wheelBlock", wheelBlock) end

	self:updateVehicleHandling(vehicle, performanceTuning)
	updateVehicleDriverTime(vehicle)
	return vehicle
end

function VehicleSpawner:updateVehicleHandling(vehicle, performanceTuning)
	local data = getElementData(vehicle, "vehicleData")
	if not data then return end

	local vehicleData = exports.TR_mysql:querry("SELECT engineCapacity FROM tr_vehicles WHERE ID = ?", data.ID)
	if not vehicleData or not vehicleData[1] then return end

	local model = getElementModel(vehicle)
	local handling = getModelHandling(model)
	local engineCapacity, hasTurbo, engineAcceleration = getVehicleEngineCapacity(vehicle, vehicleData[1].engineCapacity, performanceTuning)

	local speedAdd = (engineCapacity - 1.9) * 10 * (handlingVehicles[model][2] or 5)
	if getVehicleType(vehicle) == "Bike" then speedAdd = (engineCapacity - 0.8) * 10 * (handlingVehicles[model][2] or 5) end
	local speed = handlingVehicles[model][1] + speedAdd
	setVehicleHandling(vehicle, "maxVelocity", speed)
	setVehicleHandling(vehicle, "dragCoeff", 1)
	setVehicleHandling(vehicle, "engineAcceleration", handling["engineAcceleration"] + speedAdd/20 + engineAcceleration)

	-- setVehicleHandling(vehicle, "turnMass", handling["turnMass"] + engineCapacity * 1000)
	-- setVehicleHandling(vehicle, "maxVelocity", engineAcceleration * 15)
	-- setElementData(vehicle, "engineCapacity", engineCapacity)

	data.turbo = hasTurbo
	setElementData(vehicle, "vehicleData", data, false)

	exports.TR_quad:onWinerEnter(vehicle)
end

function VehicleSpawner:tuneVehicle(veh, tuneJSON)
	if tuneJSON then
		local tune = fromJSON(tuneJSON)
		for i, v in pairs(tune) do
			addVehicleUpgrade(veh, v)
		end
	end
end

function VehicleSpawner:spawnVehicles()
	self.courutine = coroutine.create(self.func.spawnVehiclesCo)
	coroutine.resume(self.courutine)
end

function VehicleSpawner:spawnVehiclesCoroutine()
	local vehicles = exports.TR_mysql:querry("SELECT ID, model, pos, health, fuel, engineType, mileage, color, paintjob, variant, panelstates, doorstates, plateText, tuning, visualTuning, performanceTuning, ownedPlayer, ownedOrg, wheelBlock, vehicleDirt FROM tr_vehicles WHERE parking IS NULL")
	if vehicles and #vehicles > 0 then
		self.startTime = getTickCount()

		for i, data in ipairs(vehicles) do
			local owners = self:getVehicleOwners(data.ownedPlayer, data.ID)
			self:spawnVehicle(data.ID, data.model, data.pos, data.health, data.fuel, data.engineType, data.mileage, data.color, data.paintjob, data.variant, data.panelstates, data.doorstates, data.plateText, data.tuning, data.visualTuning, data.performanceTuning, owners, data.ownedOrg, data.wheelBlock, data.vehicleDirt)

			self.totalCount = self.totalCount + 1
			self.count = self.count + 1
			if self.count == self.maxOnce then
				setTimer(function()
					coroutine.resume(self.courutine)
					self.count = 0
				end, settings.loadingResumeTime, 1)
				coroutine.yield()
			end
		end
		print("[TR_vehicles] Aynı anda ".. self.totalCount .." arabaları yüklendi " .. getTickCount() - self.startTime .. "ms.")

		exports.TR_vehicleExchange:updateVehicleExchange()
	else
		print("[TR_vehicles] Araba yok.")
	end
	settings.loadedVehicles = true
end

function VehicleSpawner:saveVehicles()
	for i, v in pairs(getElementsByType("vehicle", resourceRoot)) do
		self:saveVehicle(v)
	end
end

function VehicleSpawner:saveVehicle(vehicle)
	local health = getElementHealth(vehicle)
	local x, y, z = getElementPosition(vehicle)
	local rx, ry, rz = getElementRotation(vehicle)
	local data = getElementData(vehicle, "vehicleData")
	local pos = string.format("%.2f,%.2f,%.2f,%d,%d,%d", x, y, z, rx, ry, rz)

	local doorStateTable = {}
	local panelStateTable = {}
	local lightsStateTable = {}
	for i = 0, 6 do
		table.insert(panelStateTable, getVehiclePanelState(vehicle, i))
	end
	for i = 0, 1 do
		table.insert(lightsStateTable, getVehicleLightState(vehicle, i))
	end
	for i = 0, 5 do
		table.insert(doorStateTable, getVehicleDoorState(vehicle, i))
	end

	local doorStates = table.concat(doorStateTable, ",")
	local panelStates = table.concat(panelStateTable, ",")..","..table.concat(lightsStateTable, ",")
	local dirt = getElementData(vehicle, "vehicleGrunge")

	exports.TR_mysql:querry("UPDATE tr_vehicles SET pos = ?, health = ?, fuel = ?, mileage = ?, panelstates = ?, doorstates = ?, vehicleDirt = ? WHERE ID = ?", pos, health, data.fuel, data.mileage, panelStates, doorStates, dirt, data.ID)
end

function VehicleSpawner:getVehicleOwners(owner, ID)
	local rentData = exports.TR_mysql:querry("SELECT plrUID FROM tr_vehiclesRent WHERE vehID = ? LIMIT 6", ID)
	local rentTable = {owner}
	if rentData then
		for i, v in ipairs(rentData) do
			table.insert(rentTable, v.plrUID)
		end
	end
	return rentTable
end




-- Functions
local spawner = VehicleSpawner:create()
function spawnVehicle(id, pos)
	local querry = exports.TR_mysql:querry("SELECT ID, model, pos, health, fuel, engineType, mileage, color, paintjob, variant, panelstates, doorstates, plateText, tuning, visualTuning, performanceTuning, ownedPlayer, ownedOrg, wheelBlock, vehicleDirt FROM tr_vehicles WHERE ID = ? AND parking IS NOT NULL LIMIT 1", id)
	if not querry or #querry < 1 then return false end
	local data = querry[1]
	local owners = spawner:getVehicleOwners(data.ownedPlayer, data.ID)
	return spawner:spawnVehicle(data.ID, data.model, pos or data.pos, data.health, data.fuel, data.engineType, data.mileage, data.color, data.paintjob, data.variant, data.panelstates, data.doorstates, data.plateText, data.tuning, data.visualTuning, data.performanceTuning, owners, data.ownedOrg, data.wheelBlock, data.vehicleDirt)
end
addEvent("spawnVehicle", true)
addEventHandler("spawnVehicle", root, spawnVehicle)

function saveVehicle(vehicle)
	return spawner:saveVehicle(vehicle)
end
addEvent("saveVehicle", true)
addEventHandler("saveVehicle", root, saveVehicle)

function updateVehicleHandling(vehicle, performanceTuning)
	return spawner:updateVehicleHandling(vehicle, performanceTuning)
end

function updateVehicleTuning(vehicle, tuning)
	return spawner:tuneVehicle(vehicle, tuning)
end

function getVehicleEngineCapacity(vehicle, capacity, performanceTuning)
	local c = ""
	local hasTurbo = nil
    for i = 1, string.len(capacity) do
        local str = string.sub(capacity, i, i)
        if str == " " then break end
        c = c .. str
	end

	local newCapacity = tonumber(c)
	if string.find(capacity, "Turbo") then newCapacity = newCapacity + 0.7; hasTurbo = true end
	if string.find(capacity, "Biturbo") or string.find(capacity, "Twin Turbo") then newCapacity = newCapacity + 1.2; hasTurbo = true end

	if performanceTuning then
		for i, v in pairs(performanceTuning) do
			if i == "distribution" or i == "piston" or i == "injection" or i == "intercooler" or i == "clutch" or i == "transmission" then
				newCapacity = newCapacity + tonumber(v)
			end
		end

		if performanceTuning.drivetype then
			if performanceTuning.drivetype == "awd" then
				setVehicleHandling(vehicle, "tractionLoss", getVehicleHandling(vehicle)["tractionLoss"] + 0.1)
			elseif performanceTuning.drivetype == "rwd" then
				newCapacity = newCapacity + 1
			end
			setVehicleHandling(vehicle, "driveType", performanceTuning.drivetype)
		end
		if performanceTuning.steering then
			setVehicleHandling(vehicle, "steeringLock", getVehicleHandling(vehicle)["steeringLock"] + performanceTuning.steering)
		end
		if performanceTuning.breaking then
			setVehicleHandling(vehicle, "brakeDeceleration", getVehicleHandling(vehicle)["brakeDeceleration"] + performanceTuning.breaking * 100)
		end
		if performanceTuning.breakpad then
			setVehicleHandling(vehicle, "brakeDeceleration", getVehicleHandling(vehicle)["brakeDeceleration"] + performanceTuning.breakpad * 100)
		end
		if performanceTuning.suspension then
			if tonumber(performanceTuning.suspension) == 1087 then
				addVehicleUpgrade(vehicle, 1087)
			end
		end
	end

    return newCapacity, hasTurbo, (newCapacity - tonumber(c))
end

-- Utils
function spawnVehicles()
	spawner:spawnVehicles()
end
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), spawnVehicles)

function saveVehicles()
	spawner:saveVehicles()
end
addEventHandler("onResourceStop", getResourceRootElement(getThisResource()), saveVehicles)

function onVehicleEnter(plr, seat)
	if plr then
		showVehicleSpeedo(plr, source, seat)
		local vehID = getElementData(source, "vehicleID")
		if vehID then
			exports.TR_mysql:querry("INSERT INTO tr_vehiclesDrivers (vehID, driverUID, driveDate) VALUES (?, ?, NOW())", vehID, getElementData(plr, "characterUID"))
		end
	end
end
addEventHandler("onVehicleEnter", root, onVehicleEnter)

function showVehicleSpeedo(plr, veh, seat)
	if bikes[getElementModel(veh)] then return end
	local data = getElementData(veh, "vehicleData")
	triggerClientEvent(plr, "playerSpeedometerOpen", resourceRoot, veh, data)

	if seat == 0 then
		if getElementData(veh, "wheelBlock") then
			setTimer(setVehicleEngineState, 100, 1, veh, false)
		else
			if getElementData(plr, "engineState") then
				setTimer(setVehicleEngineState, 100, 1, veh, true)
			else
				setTimer(setVehicleEngineState, 100, 1, veh, false)
			end
		end
		removeElementData(plr, "engineState")

		setElementData(veh, "lastDriver", getPlayerName(plr))
		updateVehicleDriverTime(veh)
	end
end
addEvent("getVehicleSpeedoData", true)
addEventHandler("getVehicleSpeedoData", root, showVehicleSpeedo)

function canEnterVehicle(plr, seat, jacked, door)
	if jacked then cancelEvent() return end

	if seat == 0 and not canUseVehicle(source, plr) then
		exports.TR_noti:create(plr, "Bu araç size ait değil.", "error")
		cancelEvent()
		return
	end
end
addEventHandler("onVehicleStartEnter", resourceRoot, canEnterVehicle)

function updateVehicleDriverTime(veh)
	local time = settings.loadedVehicles and settings.startTime or getRealTime().timestamp
	setElementData(veh, "lastDriverTime", time)
end


function updateEngineState(plr, seat, jacked)
	if getElementData(plr, "boombox") then cancelEvent() return end
	if not canVehicleEnter(plr, source, jacked) and seat == 0 then
		cancelEvent()
		return
	end
	setElementData(plr, "engineState", getVehicleEngineState(source) and true or false, false)
end
addEventHandler("onVehicleStartEnter", root, updateEngineState)


function blockBlowUp(loss)
	local hp = getElementHealth(source)
	if (hp - loss) <= 301 then
		setElementHealth(source, 301)
		setVehicleDamageProof(source, true)
	end
end
addEventHandler("onVehicleDamage", root, blockBlowUp)

-- Vehicle sync events
function updateVehicleData(data)
	setElementData(source, "vehicleData", data, false)
end
addEvent("updateVehicleData", true)
addEventHandler("updateVehicleData", root, updateVehicleData)



-- Check owner
function canUseVehicle(vehicle, plr)
	if exports.TR_admin:hasPlayerPermission(plr, "isDev") then return true end -- All devs
	if getElementData(vehicle, "freeForAll") then return true end

	local vehicleOwner = getElementData(vehicle, "vehicleOwner")
	if vehicleOwner and vehicleOwner == plr then return true end

	local fraction = getElementData(vehicle, "fractionID")
	local fractionPlr = getElementData(plr, "characterDuty")
	if fraction and fractionPlr then
		if fraction == fractionPlr[4] then return true end
	end

	if not getElementID(vehicle) then return true end
	local vehData = getElementData(vehicle, "vehicleOwners")
	if not vehData then return false end

	local vehOrganization = getElementData(vehicle, "vehicleOrganization")
	if vehOrganization then
		if vehOrganization == getElementData(plr, "characterOrgID") then
			return true
		end
	end

	local uid = getElementData(plr, "characterUID")
	for i, v in ipairs(vehData) do
		if v == uid then return true end
	end
	return false
end



function setVehicleWheelBlock(veh, wheel)
	local vehData = getElementData(veh, "vehicleData")

	setVehicleEngineState(veh, false)
	setElementFrozen(veh, true)

	setElementData(veh, "wheelBlock", wheel)

	if wheel then
		exports.TR_noti:create(client, "Tekerlek kilidi takıldı.", "success")
		exports.TR_mysql:querry("UPDATE tr_vehicles SET wheelBlock = ? WHERE ID = ? LIMIT 1", wheel, vehData.ID)
	else
		exports.TR_noti:create(client, "Tekerlek kilidi kaldırıldı.", "success")
		exports.TR_mysql:querry("UPDATE tr_vehicles SET wheelBlock = NULL WHERE ID = ? LIMIT 1", vehData.ID)
	end
	triggerClientEvent(client, "updateBlockWheel", resourceRoot, veh)
end
addEvent("setVehicleWheelBlock", true)
addEventHandler("setVehicleWheelBlock", root, setVehicleWheelBlock)

function canVehicleEnter(plr, vehicle, jacked)
	local muteData = exports.TR_mysql:querry("SELECT ID FROM `tr_penalties` WHERE serial = ? AND timeEnd > NOW() AND type = 'license' AND takenBy IS NULL LIMIT 1", getPlayerSerial(plr))
	if muteData and muteData[1] then
		exports.TR_noti:create(plr, "Yönetici tarafından araç kullanmanız yasaklandığı için direksiyona geçemezsiniz..", "error", 5)
	  	return false
	end

	if isElement(vehicle) then
		if getElementData(vehicle, "freeForAll") then
			if jacked then
				local vehicleOwner = getElementData(vehicle, "vehicleOwner")
				if vehicleOwner ~= plr then return false end
			end
		end
	end
	return true
end

function removeVehicleFromWater(veh)
	local data = getElementData(veh, "vehicleData")
	if data then
		saveVehicle(veh)
		exports.TR_mysql:querry("UPDATE tr_vehicles SET parking = ? WHERE ID = ? LIMIT 1", 50, data.ID)
		destroyElement(veh)
	end
end

function vr()
	local vehicles = getElementsByType("vehicle", resourceRoot)
	if (#vehicles < 1) then return end

	local vehiclesInWater = 0
	for _, veh in ipairs(vehicles) do
		if isElementInWater(veh) and not getVehicleController(veh) then
			local pos = Vector3(getElementPosition(veh))
			if (pos.z < -1) then
				vehiclesInWater = vehiclesInWater + 1
				removeVehicleFromWater(veh)
			end
		end
	end

	outputDebugString("[TR_vehicles] Su altındaki araçlar: " ..vehiclesInWater)
end
setTimer(vr, 3600000, 0)

function vehicleDamageSync(veh, toSync)
	if not isElement(veh) then return end
	for i, v in pairs(toSync) do
		if v.type == "panel" then
			setVehiclePanelState(veh, v.i, v.state)

		elseif v.type == "door" then
			setVehicleDoorState(veh, v.i, v.state)

		elseif v.type == "light" then
			setVehicleLightState(veh, v.i, v.state)
		end
	end
end
addEvent("vehicleDamageSync", true)
addEventHandler("vehicleDamageSync", resourceRoot, vehicleDamageSync)

function removeNeonFromVehicle(veh, neonState)
	local visualTuning = getElementData(veh, "visualTuning")
	visualTuning.neon[5] = neonState
	setElementData(veh, "visualTuning", visualTuning)
	exports.TR_mysql:querry("UPDATE tr_vehicles SET visualTuning = ? WHERE ID = ? LIMIT 1", toJSON(visualTuning), getElementData(veh, "vehicleID"))
end
addEvent("removeNeonFromVehicle", true)
addEventHandler("removeNeonFromVehicle", resourceRoot, removeNeonFromVehicle)



-- addCommandHandler("fura", function(plr, cmd, model, engine)
-- 	if not model or not engine then exports.TR_noti:create(plr, "/fura [model] [engine]", "error") return end
-- 	local model = tonumber(model)
-- 	local engine = tonumber(engine)

-- 	local pos = Vector3(getElementPosition(plr))
-- 	local rot = Vector3(getElementRotation(plr))
-- 	local vehicle = createVehicle(model, pos, rot, "Testowy")

-- 	setElementData(vehicle, "vehicleData", {
-- 		ID = id,
-- 		fuel = 100,
-- 		mileage = 0,
-- 		engineType = "d",
-- 	}, false)


-- 	local model = getElementModel(vehicle)
-- 	local handling = getModelHandling(model)
-- 	local engineCapacity, hasTurbo, engineAcceleration = getVehicleEngineCapacity(vehicle, engine, {})

-- 	local speedAdd = (engineCapacity - 1.9) * 10 * (handlingVehicles[model][2] or 5)
-- 	if getVehicleType(vehicle) == "Bike" then speedAdd = (engineCapacity - 0.8) * 10 * (handlingVehicles[model][2] or 5) end
-- 	local speed = handlingVehicles[model][1] + speedAdd
-- 	setVehicleHandling(vehicle, "maxVelocity", speed)
-- 	setVehicleHandling(vehicle, "dragCoeff", 1)
-- 	setVehicleHandling(vehicle, "engineAcceleration", getModelHandling(model)["engineAcceleration"] + speedAdd/20 + engineAcceleration)

-- 	setElementData(vehicle, "freeForAll", true)

-- 	exports.TR_noti:create(plr, string.format("Stworzono pojazd o modelu %d z silnikiem %.1f", model, engine), "info")
-- end)