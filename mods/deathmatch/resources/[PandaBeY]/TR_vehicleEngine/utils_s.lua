--[[
	##########################################################
	# @project: bengines
	# @author: brzys <brzysiekdev@gmail.com>
	# @filename: utils_s.lua
	# @description: utils to calculate proper engines for vehicles
	# All rights reserved.
	##########################################################
--]]

VEHICLES_TYPES = {
	["Bus"] = {431, 437},
	["Truck"] = {403, 406, 407, 408, 413, 414, 427, 432, 433, 443, 444, 455, 456,
				 498, 499, 514, 515, 524, 531, 544, 556, 557, 573, 578, 601, 609},
	["Sport"] = {411, 415, 424, 429, 451, 477, 480, 494, 495, 502, 503, 504, 506, 541, 555, 558, 559, 560,
						 562, 565, 568, 587, 602, 598},
	["Casual"] = {400, 401, 404, 405, 410, 416, 418, 420, 421, 422,
						  426, 436, 438, 440, 445, 458, 459, 470,
						  478, 479, 482, 489, 490, 491, 492, 496, 500, 505, 507, 516, 517, 518,
						  526, 527, 528, 529, 533, 540, 543, 546, 547, 549, 550, 551,
						  554, 561, 566, 579, 580, 585, 589, 597, 596, 599, 600, 604, 605,
						  536, 575, 534, 567, 535, 576, 412},
	["Muscle"] = {474, 545, 466, 467, 439, 542, 603, 475, 419, 402},
	["Plane"] = {592, 577, 511, 548, 512, 593, 425, 520, 417, 487, 553, 488, 497, 563, 476, 447, 519, 460, 469, 513},
	["Boat"] = {472, 473, 493, 595, 484, 430, 453, 452, 446, 454},
	["Motorbike"] = {481, 462, 521, 463, 522, 461, 448, 468, 586, 471, 581}
}

function getVehicleTypeByModel(model)
	for type, models in pairs(VEHICLES_TYPES) do
		for _, mdl in pairs(models) do
			if mdl == model then
				return type
			end
		end
	end

	return "Casual"
end

function calculateVehicleClass(vehicle)
	local handling = nil
	local v_type = nil
	if type(vehicle) == "number" then
		handling = getOriginalHandling(vehicle)
		v_type = getVehicleTypeByModel(vehicle)
	else
		handling = getVehicleHandling(vehicle)
		v_type = getElementData(vehicle, "vehicle:type")
	end

	-- engine
	local acc = handling.engineAcceleration
	local vel = handling.maxVelocity
	local drag = handling.dragCoeff
	local c = (acc / drag / vel)
	if v_type == "Casual" then
		c = c-0.010
	elseif v_type == "Sport" then
		c =c-0.005
	elseif v_type == "Muscle" then
		c = c-0.02
	elseif v_type == "Truck" then
		c =c+0.01
	end

	-- steering
	local turnMass = handling.turnMass
	local mass = handling.mass
	local traction = handling.tractionLoss
	c = c - (turnMass/mass/traction)*0.001

	return math.ceil(c*(10^4.54))
end

if getModelHandling then
	for name, models in pairs(VEHICLES_TYPES) do
		table.sort(models, function(a, b)
			return calculateVehicleClass(a) > calculateVehicleClass(b)
		end)
	end

	function getBestVehicleClassByType(type)
		if type then
			return VEHICLES_TYPES[type][1]
		end
	end
end
