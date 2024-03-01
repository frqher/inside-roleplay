ENGINE_DATA = {
	-- heavy vehicles
	["Truck"] = {
		["6.0"] = {
			idleRPM=600,
			maxRPM=4000,
			soundPack="truck3",
		},

		["7.0"] = {
			idleRPM=600,
			maxRPM=4000,
			soundPack="truck2",
		},

		["8.0"] = {
			idleRPM=600,
			maxRPM=4000,
			soundPack="truck1",
		},
	},

	["Bus"] = {
		["3.0"] = {
			idleRPM=600,
			maxRPM=3000,
			soundPack="bus1",

			shiftDownRPM=800,
			shiftUpRPM=2500,
		},

		["4.0"] = {
			idleRPM=700,
			maxRPM=4000,
			soundPack="bus2",

			shiftDownRPM=1300,
			shiftUpRPM=3300,
		},
	},

	-- motorcycles
	["Motorbike"] = {
		["0.5"] = { -- 1.0
			idleRPM=700,
			maxRPM=7000,
			soundPack="motorbike1",
		},

		["0.6"] = { -- 1.4
			idleRPM=700,
			maxRPM=8000,
			soundPack="motorbike5",
		},

		["0.7"] = { -- 1.5
			idleRPM=700,
			maxRPM=8000,
			soundPack="motorbike4",
		},

		["0.8"] = { -- 2.0
			idleRPM=700,
			maxRPM=8000,
			soundPack="motorbike2",
		},

		["0.9"] = { -- 3.0
			idleRPM=700,
			maxRPM=8000,
			soundPack="motorbike3",
		},
	},

	-- casual vehicles
	["Casual"] = {
		["1.5"] = {
			idleRPM=700,
			maxRPM=6000,
			soundPack="casual6",
		},

		["1.6"] = {
			idleRPM=900,
			maxRPM=6000,
			soundPack="muscle2",
		},

		["1.7"] = {
			idleRPM=900,
			maxRPM=6000,
			soundPack="casual1",
		},

		["1.8"] = {
			idleRPM=900,
			maxRPM=6800,
			soundPack="casual4",
		},

		["1.9"] = {
			idleRPM=900,
			maxRPM=6800,
			soundPack="casual2",
		},

		["2.0"] = {
			idleRPM=900,
			maxRPM=6800,
			soundPack="casual5",
		},

		["2.1"] = {
			idleRPM=900,
			maxRPM=7500,
			soundPack="casual7",
		},

		["2.2"] = {
			idleRPM=900,
			maxRPM=7500,
			soundPack="casual7",
		},
	},

	-- muscle vehicles
	["Muscle"] = {
		["2.0"] = {
			idleRPM=700,
			maxRPM=6500,
			soundPack="muscle1",
		},

		["2.5"] = {
			idleRPM=700,
			maxRPM=6500,
			soundPack="muscle2",
		},

		["3.0"] = {
			idleRPM=1000,
			maxRPM=7000,
			soundPack="muscle3",
		},

		["3.5"] = {
			idleRPM=1000,
			maxRPM=7000,
			soundPack="muscle4",
		},
	},

	-- sport vehicles
	["Sport"] = {
		["3.0"] = {
			idleRPM=900,
			maxRPM=8000,
			soundPack="sport7",
		},

		["3.3"] = {
			idleRPM=900,
			maxRPM=8000,
			soundPack="sport1",
		},

		["3.5"] = {
			idleRPM=900,
			maxRPM=8000,
			soundPack="sport5",
		},

		["3.6"] = {
			idleRPM=900,
			maxRPM=8000,
			soundPack="sport9",
		},

		["3.9"] = {
			idleRPM=900,
			maxRPM=8000,
			soundPack="sport8",
		},

		["4.2"] = {
			idleRPM=900,
			maxRPM=8000,
			soundPack="sport4",
		},

		["4.5"] = {
			idleRPM=900,
			maxRPM=8000,
			soundPack="sport2",
		},

		["5.0"] = {
			idleRPM=900,
			maxRPM=8000,
			soundPack="sport3",
		},
	}
}

-- override default engines
VEHICLE_ENGINES = {
	-- bikes
	[463] = "0.6", -- harley
	[581] = "0.8", -- bf-400
	[523] = "0.9", -- sapd

	-- casual
	[414] = "1.2", -- mule

	-- sport
	[596] = "2.0", -- police LS
	[598] = "3.9",
}

-- soundpack volume boosting
SOUNDPACK_VOLUME = {
	["motorbike2"] = 1.5,
	["motorbike3"] = 1.5,
	["motorbike4"] = 1.5,
	["motorbike5"] = 2,
}

function calculateVehicleEngine(vehicle)
	local model = getElementModel(vehicle)
	local type = getElementData(vehicle, "vehicle:type")

	if VEHICLE_ENGINES[model] then
		return VEHICLE_ENGINES[model]
	end

	if ENGINE_DATA[type] then
		local engines = {}
		for name, data in pairs(ENGINE_DATA[type]) do
			table.insert(engines, {name, data})
		end

		table.sort(engines, function(a, b)
			return a[1] < b[1]
		end)

		local class = math.floor((calculateVehicleClass(vehicle) / calculateVehicleClass(getBestVehicleClassByType(type))) * #engines)
		if type == "Sport" then
			class = class-2
		end

		class = math.max(1, math.min(class, #engines))

		return engines[class][1] -- name of engine
	end

	return false
end

function addVehicleEngine(vehicle)
	local vehType = getVehicleType(vehicle)
	if vehType == "BMX" or vehType == "Train" or vehType == "Trailer" or vehType == "Helicopter" or vehType == "Plane" then return end
	local data = calculateVehicleEngine(vehicle)
	local type = getElementData(vehicle, "vehicle:type")
	local model = getElementModel(vehicle)
	if data then
		local vehData = getElementData(vehicle, "vehicleData") or {turbo = false}
		local engine = ENGINE_DATA[type][data]
		if not engine then return end
		engine.name = data
		engine.volMult = SOUNDPACK_VOLUME[engine.soundPack] or 1
		engine.turbo = vehData.turbo or false
		engine.turbo_shifts = engine.turbo
		engine.fuel = vehData.engineType

		setElementData(vehicle, "vehicle:engine", engine)

		-- refresh for players nearby
		local x, y, z = getElementPosition(vehicle)
		local col = createColSphere(x, y, z, 20)
		for k, v in ipairs(getElementsWithinColShape(col, "player")) do
			triggerClientEvent(v, "onClientRefreshEngineSounds", v)
		end
		destroyElement(col)
	end
end

function onResourceStart()
	for k, v in ipairs(getElementsByType("vehicle")) do
		local type = getElementData(v, "vehicle:type")
		if not type then
			type = getVehicleTypeByModel(getElementModel(v))
			setElementData(v, "vehicle:type", type)
		end

		addVehicleEngine(v)
	end
end
addEventHandler("onResourceStart", resourceRoot, onResourceStart)

function onVehicleEnter(player, seat, jacked)
	if seat == 0 then
		local type = getElementData(source, "vehicle:type")
		if not type then
			type = getVehicleTypeByModel(getElementModel(source))
			setElementData(source, "vehicle:type", type)
		end

		addVehicleEngine(source)
	end
end
addEventHandler("onVehicleEnter", root, onVehicleEnter)