local benchInfo = {
	[1280] = {
		positions = {
			Vector3(0, -0.8, 0),
			Vector3(0, 0, 0),
			Vector3(0, 0.8, 0),
		},
		position = Vector3(-0.5, 0, 0.6),
		rotation = 90,
	},
	[1711] = {
		positions = {
			Vector3(0.2, -0.3, 1),
		},
		position = Vector3(0, -0.4, 0),
		rotation = 180,
	},
	[2309] = {
		positions = {
			Vector3(-0.02, 0.65, 1.1),
		},
		position = Vector3(0, 0, 0),
		rotation = 0,
	},
	[1714] = {
		positions = {
			Vector3(0, -0.5, 1.1),
		},
		position = Vector3(0, 0, 0),
		rotation = 180,
	},
	[2310] = {
		positions = {
			Vector3(-0.5, 0, 0.6),
		},
		position = Vector3(0, 0, 0),
		rotation = 90,
	},
	[2356] = {
		positions = {
			Vector3(-0.02, 0.65, 1.1),
		},
		position = Vector3(0, 0, 0),
		rotation = 0,
	},
	[2121] = {
		positions = {
			Vector3(0, -0.6, 0.6),
		},
		position = Vector3(0, 0, 0),
		rotation = 180,
	},
	[1753] = {
		positions = {
			Vector3(0.2, 0, 0),
			Vector3(1.0, 0, 0),
			Vector3(1.8, 0, 0),
		},
		position = Vector3(0, -0.6, 1.1),
		rotation = 180,
	},
	[2120] = {
		positions = {
			Vector3(-0.5, 0, 0.55),
		},
		position = Vector3(0, 0, 0),
		rotation = 90,
	},
	[1721] = {
		positions = {
			Vector3(0, 0.55, 1),
		},
		position = Vector3(0, 0, 0),
		rotation = 0,
	},
}

Benches = {}
Benches.__index = Benches

function Benches:create(...)
	local instance = {}
	setmetatable(instance, Benches)
	if instance:constructor(...) then
		return instance
	end
	return false
end

function Benches:constructor(...)
	self.isSeating = false
	self.sphere = createColSphere(Vector3(getElementPosition(localPlayer)), 4)
	attachElements(self.sphere, localPlayer)

	return true
end


function Benches:sitPlayer(obj)
	local seat, pos, rot = self:getNearestSeat(obj)
	if not seat then return end

	if self.isSeating then
		self.isSeating = nil
		self:sitPlayerAnim(localPlayer, obj, false)
		exports.TR_interaction:updateInteraction("bench", nil)
		return
	else
		self.isSeating = true
		self:sitPlayerAnim(localPlayer, obj, rot, seat)
		exports.TR_interaction:updateInteraction("bench", obj)

		exports.TR_achievements:addAchievements("benchSit")
		return
	end
	exports.TR_interaction:updateInteraction()
end

function Benches:getNearestSeat(element)
	local px, py, pz = getElementPosition(localPlayer)
	local x, y, z = getElementPosition(element)
	local model = getElementModel(element)

	local closestDist = 1000
	local closestIndex, closestPos, closestRot = nil, nil, nil
	for i, v in ipairs(benchInfo[model].positions) do
		local bx, by, bz, rot = self:getPosition(element, v)
		local fixPos = benchInfo[model].position
		local dist = getDistanceBetweenPoints3D(px, py, pz, bx, by, bz)
		if closestDist > dist then
			closestDist = dist
			closestIndex = i
			closestPos = Vector3(bx + fixPos.x, by + fixPos.y, bz + fixPos.z)
			closestRot = rot + benchInfo[model].rotation
		end
	end
	if not closestIndex then return false end
	if not self.isSeating then
		if not self:checkIsFree(closestPos) then return false end
	end

	return closestIndex, closestPos, closestRot
end

function Benches:checkIsFree(pos)
	if not pos then return false end
	local players = getElementsWithinColShape(self.sphere, "player")

	for i, v in pairs(players) do
		if getDistanceBetweenPoints3D(Vector3(getElementPosition(v)), pos) < 1.2 and v ~= localPlayer then return false end
	end

	return true
end

function Benches:getPosition(element, vec)
	local rot = Vector3(getElementRotation(element))
	local mat = Matrix(Vector3(getElementPosition(element)), rot)
	local newPos = mat:transformPosition(vec)
	return newPos.x, newPos.y, newPos.z, rot.z
end

function Benches:sitPlayerAnim(...)
	if arg[3] then
		self:canMove(arg[1], false)

		local model = getElementModel(arg[2])
		local vec = benchInfo[model].positions[arg[4]]
		local fix = benchInfo[model].position
		local x, y, z = self:getPosition(arg[2], vec + fix)
		setElementPosition(arg[1], x, y, z)

		-- setTimer(function()
		-- 	setElementRotation(arg[1], 0, 0, arg[3])
		-- 	setElementData(arg[1], "blockAction", true)
		-- 	setElementCollisionsEnabled(arg[1], false)

		-- 	setTimer(function()
		-- 		if not arg[1] then return end
		-- 		setPedAnimation(arg[1], "ped", "SEAT_idle", -1, true, false, false, false)
		-- 		setElementData(arg[1], "animation", {"ped", "SEAT_idle"})
		-- 	end, 100, 1)
		-- end, 50, 1)
		triggerServerEvent("playerSitOnBench", resourceRoot, {x, y, z, arg[3]})

	else
		self:canMove(arg[1], true)

		setPedAnimation(arg[1], nil, nil)
		setElementData(arg[1], "animation", nil)
		setElementData(arg[1], "blockAction", nil)
		setElementFrozen(arg[1], false)
		setElementCollisionsEnabled(arg[1], true)

		triggerServerEvent("syncAnim", resourceRoot, false)

		local pos = Vector3(getElementPosition(arg[1]))
		setElementPosition(arg[1], pos.x, pos.y, pos.z)
	end
end

function Benches:canMove(...)
	toggleControl("forwards", arg[2])
	toggleControl("backwards", arg[2])
	toggleControl("left", arg[2])
	toggleControl("right", arg[2])
end


local system = Benches:create()
function benchSit(...)
	system:sitPlayer(...)
end