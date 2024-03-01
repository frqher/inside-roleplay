GPS = {
	road = {},
	materials = {},
	lastPosition = {},
	nextPosition = {},

	renderMap = false,

	names = {
		["finish"] = "Varış noktası",
		["turn_left"] = "Sola dön",
		["turn_right"] = "Sağa dön",
		["straight"] = "Düz sür",
		["u_turn"] = "Geri Dön",
	},
}

local gpsSettings = {
	time = 50,
	runs = 2000,
	run = 0,
	createRuns = 100,

	turnTreshold = 40,
	doubleTurn = 10,

	destination = {},
}

function onRender()
	if GPS.road then
		for i, node in ipairs(GPS.road) do
			if GPS.road[i+1] then
				dxDrawLine3D(node.posX, node.posY, node.posZ + 1, GPS.road[i+1].posX, GPS.road[i+1].posY, GPS.road[i+1].posZ + 1, tocolor(255, 255, 255, 255), 4)
			end
		end
	end

	if GPS.waypointTurns then
		dxDrawText(inspect(GPS.waypointTurns), 500, 10)
	end
end
-- addEventHandler("onClientRender", root, onRender)

function createGPS(road)
	local lastNeighbours = false
	for i, node in ipairs(road) do
		if i == 1 then
			GPS.road[i] = {}
			GPS.road[i].marker = createMarker(node.x, node.y, getGroundPosition(node.x, node.y, node.z + 0.3) + 0.2, "cylinder", 5, 255, 0, 0, 0)
			GPS.road[i].posX = node.x
			GPS.road[i].posY = node.y
			GPS.road[i].posZ = node.z
			GPS.road[i].ID = i
			GPS.road[i].neighbours = node.neighbours

			addEventHandler("onClientMarkerHit", GPS.road[i].marker, function(plr, dim)
				if localPlayer == plr and dim then
					local roadNum = i
					for i,row in ipairs(GPS.road) do
						if row.ID >= roadNum then
							if #GPS.road > 0 then
								exports.TR_noti:create("Hedefe vardın.", "gps")
								playSoundGPS("finish")
							end
							removeGPS()
						end
					end
				end
			end)

		else
			GPS.road[i] = {}
			GPS.road[i].marker = createColSphere(node.x, node.y, node.z, 8)
			GPS.road[i].posX = node.x
			GPS.road[i].posY = node.y
			GPS.road[i].posZ = node.z
			GPS.road[i].ID = i
			GPS.road[i].neighbours = node.neighbours

			addEventHandler("onClientColShapeHit", GPS.road[i].marker, function(plr, dim)
				if localPlayer ~= plr or not dim then return end
				if GPS.waypointTurns then
					if i ~= 2 then
						local newRoad = {}
						for k, v in ipairs(GPS.waypointTurns) do
							if v.ID == GPS.road[i-1].ID then
								if v.sound then
									playSoundGPS(v.sound)
								end

							elseif v.ID < GPS.road[i-1].ID then
								table.insert(newRoad, v)
							end
						end
						GPS.waypointTurns = newRoad
					end
				end

				local roadNum = i
				for i, row in ipairs(GPS.road) do
					if row.ID >= roadNum then
						destroyElement(GPS.road[i].marker)

						GPS.lastPosition.x, GPS.lastPosition.y, GPS.lastPosition.z = GPS.road[i].posX, GPS.road[i].posY, GPS.road[i].posZ

						if GPS.road[i].distance then
							GPS.distance = GPS.distance - GPS.road[i].distance

							for _, v in pairs(GPS.waypointTurns) do
								v.dist = v.dist - GPS.road[i].distance
							end
						end

						GPS.road[i] = nil
					end
				end
				GPS.nextPosition.x, GPS.nextPosition.y, GPS.nextPosition.z = GPS.road[roadNum-1].posX, GPS.road[roadNum-1].posY, GPS.road[roadNum-1].posZ
			end)
		end

		-- Calculate distance
		if not lastNeighbours then
			lastNeighbours = node.neighbours
		else
			if lastNeighbours[node.id] then
				GPS.distance = GPS.distance + lastNeighbours[node.id]
				GPS.road[i].distance = lastNeighbours[node.id]
			end
			lastNeighbours = road.neighbours
		end

		-- gpsSettings.run = gpsSettings.run + 1
		-- if gpsSettings.run >= gpsSettings.createRuns then
		-- 	gpsSettings.run = 0
		-- 	-- setTimer(function()
		-- 		coroutine.resume(gpsSettings.createCoroutine)
		-- 	-- end, gpsSettings.time, 1)
		-- 	coroutine.yield()
		-- end
	end
	calculatedGPS()
end

function removeGPS()
	if #GPS.road < 1 then return end
	for i, row in pairs(GPS.road) do
		destroyElement(GPS.road[i].marker)
	end
	GPS.road = {}
	GPS.waypointTurns = nil
	GPS.distance = nil

	if isTimer(GPS.checker) then killTimer(GPS.checker) end
	gpsSettings.destination.x, gpsSettings.destination.y = nil, nil
	gpsSettings.destination.recalculate = nil
end

function findBestWay(x, y, response)
	if GPS.running then return end
	if response then exports.TR_dx:setResponseEnabled(true, "Rota aranıyor..") end
	local recalc = gpsSettings.destination.recalculate

	GPS.running = true
	removeGPS()

	GPS.distance = 0
	gpsSettings.destination.recalculate = recalc
	gpsSettings.destination.x, gpsSettings.destination.y = x, y

	GPS.lastPosition.x, GPS.lastPosition.y, GPS.lastPosition.z = getElementPosition(localPlayer)
	GPS.lastPosition.z = GPS.lastPosition.z - 1

	local startNode = findNodePosition(GPS.lastPosition.x, GPS.lastPosition.y, GPS.lastPosition.z)
	local endNode = findNodePosition(x, y, 0)

	gpsSettings.pathCoroutine = coroutine.create(function() getPath(startNode, endNode) end)
	coroutine.resume(gpsSettings.pathCoroutine)
end
addEvent("findBestWay", true)
addEventHandler("findBestWay", root, findBestWay)

function recalculateGPS()
	if getElementInterior(localPlayer) ~= 0 and getElementDimension(localPlayer) ~= 0 then
		removeGPS()
		return
	end

	gpsSettings.destination.recalculate = true
	findBestWay(gpsSettings.destination.x, gpsSettings.destination.y)
end

function checkDistance()
	if #GPS.road < 1 then killTimer(GPS.checker) end
	local x, y, z = getElementPosition(localPlayer)
	local lastDist = getDistanceBetweenPoints2D(x, y, GPS.lastPosition.x, GPS.lastPosition.y)
	local nearDist = getDistanceBetweenPoints2D(x, y, GPS.road[#GPS.road].posX, GPS.road[#GPS.road].posY)
	if lastDist >= 50 and nearDist >= 50 then
		recalculateGPS()
	end
end

function getPath(startNode, endNode)
	local nodes = {}
	nodes[startNode.id] = true
	local actualNodes = {}
	local road = {}

	for id, distance in pairs(startNode.neighbours) do
		nodes[id] = true
		actualNodes[id] = distance
		road[id] = {startNode.id}
	end

	while true do
		local bestNode = false
		local remover = 15000

		for id, dist in pairs(actualNodes) do
			if dist < remover then
				bestNode = id
				remover = dist
			end
		end

		if not bestNode then
			if getElementInterior(localPlayer) == 0 and getElementDimension(localPlayer) == 0 then
				exports.TR_noti:create("GPS belirlenen noktaya giden rotayı bulamadı.", "error")
			end

			GPS.running = nil
			gpsSettings.destination.recalculate = nil
			if not gpsSettings.destination.recalculate then exports.TR_dx:setResponseEnabled(false) end
			removeGPS()
			playSoundGPS("lost")
			return
		end

		if endNode.id == bestNode then
			local node = bestNode
			local waypoints = {}
			local waypointID = 1
			while (tonumber(node) ~= nil) do
				local roadNode = getNodeByID(vehicleNodes, node)
				waypoints[waypointID] = roadNode
				waypointID = waypointID + 1
				node = road[node]
			end

			gpsSettings.run = 0
			gpsSettings.createCoroutine = coroutine.create(createGPS)
			coroutine.resume(gpsSettings.createCoroutine, waypoints)
			return
		end

		for neighborID, neighborDist in pairs(getNodeByID(vehicleNodes, bestNode).neighbours) do
			if not nodes[neighborID] then
				road[neighborID] = bestNode
				actualNodes[neighborID] = remover + neighborDist
				nodes[neighborID] = true
			end
		end
		actualNodes[bestNode] = nil

		gpsSettings.run = gpsSettings.run + 1
		if gpsSettings.run >= gpsSettings.runs then
			gpsSettings.run = 0
			setTimer(function()
				coroutine.resume(gpsSettings.pathCoroutine)
			end, gpsSettings.time, 1)
			coroutine.yield()
		end
	end
end

function calculatedGPS()
	if GPS.road[1] then
		local zone = getZoneName(GPS.road[1].posX, GPS.road[1].posY, GPS.road[1].posZ)

		if getElementInterior(localPlayer) == 0 and getElementDimension(localPlayer) == 0 then
			exports.TR_noti:create(string.format("Bölge: %s\nKalan mesafe: %dm.", zone, GPS.distance * 4), "gps")
		end

		calculateTurnsGPS()
	end

	local checkElement = localPlayer
	local veh = getPedOccupiedVehicle(localPlayer)
	if veh then checkElement = veh end
	local currentNode = #GPS.road

	local vehiclePosX, vehiclePosY = getElementPosition(checkElement)
	local vehicleOffsetX, vehicleOffsetY = getPositionFromElementOffset(checkElement, -1, 0, 0)

	if GPS.road then
		if #GPS.road > 1 then
			if GPS.road[#GPS.road - 1] then
				local vehicleAngle = math.deg(getAngle(GPS.road[currentNode - 1].posX - GPS.road[currentNode].posX, GPS.road[currentNode - 1].posY - GPS.road[currentNode].posY, vehicleOffsetX - vehiclePosX, vehicleOffsetY - vehiclePosY))

				if vehicleAngle > 0 then
					playSoundGPS("u_turn")
					table.insert(GPS.waypointTurns, {
						ID = #GPS.road + 1,
						icon = "u_turn",
						pos = Vector2(GPS.road[#GPS.road].posX, GPS.road[#GPS.road].posY),
						dist = GPS.road[#GPS.road].distance or 0,
					})
				else
					playSoundGPS("straight")
				end
			end
		end
	end

	if not gpsSettings.destination.recalculate then
		exports.TR_dx:setResponseEnabled(false)
	end

	GPS.running = nil
	if isTimer(GPS.checker) then killTimer(GPS.checker) end
	GPS.checker = setTimer(checkDistance, 2000, 0)
end

function calculateTurnsGPS()
	GPS.waypointTurns = {}

	local lastDist = GPS.distance
	for i, node in ipairs(GPS.road) do
		local nextNode = GPS.road[i + 1]
		local previousNode = GPS.road[i - 1]

		if i > 1 and i < #GPS.road then
			for k in pairs(node.neighbours) do
				if previousNode and nextNode and k ~= previousNode.id and k ~= nextNode.id then
					local turnAngle = math.deg(getAngle(nextNode.posX - node.posX, nextNode.posY - node.posY, node.posX - previousNode.posX, node.posY - previousNode.posY))

					lastDist = lastDist - (GPS.road[i].distance or 0)
					if turnAngle > gpsSettings.turnTreshold then
						table.insert(GPS.waypointTurns, {
							ID = i,
							icon = "turn_right",
							sound = "turn_right",
							pos = Vector2(node.posX, node.posY),
							dist = lastDist,
						})
						break
					end

					if turnAngle < -gpsSettings.turnTreshold then
						table.insert(GPS.waypointTurns, {
							ID = i,
							icon = "turn_left",
							sound = "turn_left",
							pos = Vector2(node.posX, node.posY),
							dist = lastDist,
						})
					end
					break
				end
			end
		end
	end
	table.insert(GPS.waypointTurns, 1, {
		ID = 1,
		icon = "finish",
		sound = "finish",
		pos = Vector2(GPS.road[1].posX, GPS.road[1].posY),
		dist = GPS.distance,
	})

	local newTable = {}
	for i, v in pairs(GPS.waypointTurns) do
		if GPS.waypointTurns[i+1] then
			if GPS.waypointTurns[i+1].ID - v.ID <= gpsSettings.doubleTurn then
				if v.icon == "turn_left" then
					GPS.waypointTurns[i+1].sound = string.format("%s;%s", GPS.waypointTurns[i+1].sound, "then_turn_left")

				elseif v.icon == "turn_right" then
					GPS.waypointTurns[i+1].sound = string.format("%s;%s", GPS.waypointTurns[i+1].sound, "then_turn_right")
				end
			end
		end
		table.insert(newTable, v)
	end

	if GPS.road then
		if #GPS.road > 1 then
			if GPS.road[#GPS.road - 1] then
				GPS.waypointTurns = newTable
				GPS.nextPosition.x, GPS.nextPosition.y, GPS.nextPosition.z = GPS.road[#GPS.road - 1].posX, GPS.road[#GPS.road - 1].posY, GPS.road[#GPS.road - 1].posZ
			end
		end
	end
end


-- Utils
function getAreaID(x, y)
	return math.floor((y + 3000)/750)*8 + math.floor((x + 3000)/750)
end

function getNodeByID(db, nodeID)
	local areaID = math.floor(nodeID / 65536)
	if areaID<=63 and areaID>=0 then
		return db[areaID][nodeID]
	end
end

function findNodePosition(x, y, z)
	local startNode = -1
	local remover = 15000
	local areaID = getAreaID(x, y)
	for _, row in pairs(vehicleNodes[areaID]) do
		local dist = getDistanceBetweenPoints3D(x, y, z, row.x, row.y, row.z)
		if remover > dist then
			remover = dist
			startNode = row
		end
	end
	return startNode
end

function playSoundGPS(sounds)
	if not settings.gpsVoice then return end
	if isElement(gpsSettings.sound) then
		destroyElement(gpsSettings.sound)
	end

	if isTimer(gpsSettings.soundTimer) then
		killTimer(gpsSettings.soundTimer)
	end

	if getElementInterior(localPlayer) == 0 and getElementDimension(localPlayer) == 0 then
		gpsSettings.sound = playSound("gps/sounds/noti.mp3")

		gpsSettings.soundTimer = setTimer(playNextSoundGPS, getSoundLength(gpsSettings.sound) * 0.9 * 1000, 1, split(sounds, ";"), 1)
	end
end

function playNextSoundGPS(sounds, count)
	if getElementInterior(localPlayer) == 0 and getElementDimension(localPlayer) == 0 then
		gpsSettings.sound = playSound(string.format("gps/sounds/%s.wav", sounds[count]))

		if count < #sounds then
			gpsSettings.soundTimer = setTimer(playNextSoundGPS, getSoundLength(gpsSettings.sound) * 0.9 * 1000, 1, sounds, count + 1)
		end
	end
end

function getAngle(x1, y1, x2, y2)
	local angle = math.atan2(x2, y2) - math.atan2(x1, y1)

	if angle <= -math.pi then
		angle = angle + math.pi * 2
	elseif angle > math.pi then
		angle = angle - math.pi * 2
	end

	return angle
end

function getPositionFromElementOffset(element, x, y, z)
	local elementMatrix = getElementMatrix(element)

	local offsetX = x * elementMatrix[1][1] + y * elementMatrix[2][1] + z * elementMatrix[3][1] + elementMatrix[4][1]
	local offsetY = x * elementMatrix[1][2] + y * elementMatrix[2][2] + z * elementMatrix[3][2] + elementMatrix[4][2]
	local offsetZ = x * elementMatrix[1][3] + y * elementMatrix[2][3] + z * elementMatrix[3][3] + elementMatrix[4][3]

	return offsetX, offsetY, offsetZ
end


-- function renderNodes()
-- 	local pack = 14
-- 	local nodes = vehicleNodes[pack]

-- 	for i, v in pairs(nodes) do
-- 		local sx, sy = getScreenFromWorldPosition(v.x, v.y, v.z + 2.4)
-- 		if sx and sy then
-- 			dxDrawText(v.id, sx, sy)

-- 			if v.neighbours then
-- 				for k, _ in pairs(v.neighbours) do
-- 					local node = nodes[k]
-- 					if node then
-- 						if sx and sy then
-- 							dxDrawLine3D(v.x, v.y, v.z + 2, node.x, node.y, node.z + 2, tocolor(255, 0, 0, 255), 4)
-- 						end
-- 					end
-- 				end
-- 			end
-- 		end
-- 	end
-- end

-- addEventHandler("onClientRender", root, renderNodes)