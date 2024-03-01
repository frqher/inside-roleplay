GPS = {
	road = {},
	materials = {},
	lastPosition = {},

	renderMap = false,
}

local gpsSettings = {
	time = 50,
	runs = 2000,
	createRuns = 100,
	materialRuns = 200,

	run = 0,

	destination = {},
}

function onRender()
	if GPS.road then
		for i, node in ipairs(GPS.road) do
			if GPS.road[i+1] then
				dxDrawLine3D(node.posX, node.posY, node.posZ + 1, GPS.road[i+1].posX, GPS.road[i+1].posY, GPS.road[i+1].posZ + 1, tocolor(255, 255, 255, 255), 4)

				local cx, cy = getScreenFromWorldPosition(node.posX, node.posY, node.posZ + 1)
				if cx and cy then
					local rot = findGPSRotation(node.posX, node.posY, GPS.road[i+1].posX, GPS.road[i+1].posY)
					local move, diff = getNextMoveGPS(i)
					dxDrawText(string.format("ID: %d\nRot: %d\nRuch: %s\nRóżnica: %.4f", i, rot, move, diff or 0), cx, cy)
				end
			end
		end
	end
end
addEventHandler("onClientRender", root, onRender)

function getNextMoveGPS(index)
	if not GPS.road[index-2] or not GPS.road[index+1] or not GPS.road[index] then return "Prosto" end

	local rotNow = findGPSRotation(GPS.road[index-2].posX, GPS.road[index-2].posY, GPS.road[index-1].posX, GPS.road[index-1].posY)
	local rotNext = findGPSRotation(GPS.road[index-2].posX, GPS.road[index-2].posY, GPS.road[index].posX, GPS.road[index].posY)
	local rotNow, rotNext = math.rad(rotNow), math.rad(rotNext)


	-- if rotNext < -0.5 then
	-- 	return "W lewo", rotNext
	-- elseif rotNext > 0.5 then
	-- 	return "W prawo", rotNext
	-- end

	-- if math.abs(rotNow) > math.abs(rotNext) then
	-- 	if math.abs(rotNow - rotNext) > 40 then
	-- 		return "Skręć w prawo", math.abs(rotNow - rotNext)
	-- 	end
	-- else
	-- 	if math.abs(rotNow - rotNext) > 40 then
	-- 		return "Skręć w lewo", math.abs(rotNext - rotNow)
	-- 	end
	-- end
	return "Prosto", rotNext
end

function calculateSoundGPS(index)
	if not GPS.road[index-2] or not GPS.road[index+1] or not GPS.road[index] then return "Prosto" end

	local rotNow = findGPSRotation(GPS.road[index-2].posX, GPS.road[index-2].posY, GPS.road[index-1].posX, GPS.road[index-1].posY)
	local rotNext = findGPSRotation(GPS.road[index-1].posX, GPS.road[index-1].posY, GPS.road[index].posX, GPS.road[index].posY)
	if rotNow > rotNext then
		if math.abs(rotNow - rotNext) > 40 then
			playSoundGPS("gps/sounds/turn_left.wav")
		end
	else
		if math.abs(rotNow - rotNext) > 40 then
			playSoundGPS("gps/sounds/turn_right.wav")
		end
	end
end

function findGPSRotation(x1,y1,x2,y2)
	return math.atan2(x2-x1,y2-y1)
end

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

			addEventHandler("onClientMarkerHit", GPS.road[i].marker, function(plr, dim)
				if localPlayer == plr and dim then
					local roadNum = i
					for i,row in ipairs(GPS.road) do
						if row.ID >= roadNum then
							if #GPS.road > 0 then
								exports.TR_noti:create("Dojechałeś na miejsce.", "gps")
								playSoundGPS("gps/sounds/finish.wav")
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

			addEventHandler("onClientColShapeHit", GPS.road[i].marker, function(plr, dim)
				if localPlayer == plr and dim then
					calculateSoundGPS(i-1)
					local roadNum = i
					for i,row in ipairs(GPS.road) do
						if row.ID >= roadNum then
							destroyElement(GPS.road[i].marker)

							GPS.lastPosition.x, GPS.lastPosition.y, GPS.lastPosition.z = GPS.road[i].posX, GPS.road[i].posY, GPS.road[i].posZ

							if GPS.road[i].distance then
								GPS.distance = GPS.distance - GPS.road[i].distance
							end
							GPS.road[i] = nil
						end
					end
				end
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

		gpsSettings.run = gpsSettings.run + 1
		if gpsSettings.run >= gpsSettings.createRuns then
			gpsSettings.run = 0
			setTimer(function()
				coroutine.resume(gpsSettings.createCoroutine)
			end, gpsSettings.time, 1)
			coroutine.yield()
		end
	end
	calculatedGPS()
end

function removeGPS()
	if #GPS.road < 1 then return end
	for i, row in pairs(GPS.road) do
		destroyElement(GPS.road[i].marker)
	end
	GPS.road = {}
	GPS.distance = nil

	if isTimer(GPS.checker) then killTimer(GPS.checker) end
	gpsSettings.destination.x, gpsSettings.destination.y = nil, nil
	gpsSettings.destination.recalculate = nil
end

function findBestWay(x, y, response)
	if GPS.running then return end
	if response then exports.TR_dx:setResponseEnabled(true, "Trwa wyszukiwanie trasy") end
	GPS.running = true
	removeGPS()

	GPS.distance = 0
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
	playSoundGPS("gps/sounds/recomputing.wav")
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
			exports.TR_noti:create("GPS nie mógł odnaleźć trasy do wyznaczonego punktu.", "error")
			GPS.running = nil
			gpsSettings.destination.recalculate = nil
			if not gpsSettings.destination.recalculate then exports.TR_dx:setResponseEnabled(false) end
			removeGPS()
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
		exports.TR_noti:create(string.format("Trasa do %s została odnaleziona.\nDystans do celu: %dm.", zone, GPS.distance), "gps")
	end
	if not gpsSettings.destination.recalculate then exports.TR_dx:setResponseEnabled(false) end

	GPS.running = nil
	if isTimer(GPS.checker) then killTimer(GPS.checker) end
	GPS.checker = setTimer(checkDistance, 2000, 0)
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

function playSoundGPS(url)
	if isElement(gpsSettings.sound) then destroyElement(gpsSettings.sound) end
	gpsSettings.sound = playSound(url)
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

if getPlayerName(localPlayer) == "Xantris" then
	findBestWay(-2604.5634765625, 35.8544921875)
end