settings = {}
settings.Fallout = {
	timer = {},
	speedDefault = 850,
}

function onPlayerFire(player, isOnFire)
	setPedOnFire(player, isOnFire)
end
addEvent("onPlayerFire", true)
addEventHandler("onPlayerFire", root, onPlayerFire)

function createFallout(rows, columns, winningBoards)
	settings.Fallout.boards = {}
	local x, y, z = 3737.62, 694.83, 55.09
	for i = 1,rows do
		for j = 1, columns do
			settings.Fallout.boards[#settings.Fallout.boards+1] = createObject ( 1697, x + (4.466064 * j), y + (5.362793 * i), z, math.deg( 0.555 ), 0, 0 )
			setElementInterior(settings.Fallout.boards[#settings.Fallout.boards], 0)
			setElementDimension(settings.Fallout.boards[#settings.Fallout.boards], 15)
		end
	end
	local fX, fY, fZ = getElementPosition( settings.Fallout.boards[1] )
	local fX2, fY2, fZ2 = getElementPosition( settings.Fallout.boards[table.maxn (settings.Fallout.boards)] )
	local fWidth, fDepth, fHeight = (fX2-fX)+4.46631, (fY2-fY)+5.22539
	settings.Fallout.cuboid = createColCuboid( fX-2.2, fY-2.8, fZ, math.abs(fWidth), fDepth, 10 )
	settings.Fallout.maxBoards = winningBoards
	settings.Fallout.size = table.maxn (settings.Fallout.boards)
	settings.Fallout.speed = settings.Fallout.speedDefault
	for player in pairs(settings.Fallout.players) do
		local spawningBoard = math.random ( 1, settings.Fallout.size )
		local x, y, z = getElementPosition ( settings.Fallout.boards[spawningBoard] )
		local changex = math.random (0,1)
		local changey = math.random (0,1)
		if changex == 0 then
			x = x - math.random (0,200)/100
		elseif changex == 1 then
			x = x + math.random (0,200)/100
		end
		if changey == 0 then
			y = y - math.random (0,200)/100
		elseif changey == 1 then
			y = y + math.random (0,200)/100
		end
		local angel = 360 - math.deg( math.atan2 ( (1557.987182 - x), (-1290.754272 - y) ) )
		setElementPosition(player, x, y, z+1.8)
		setElementRotation(player, angel, angel, angel)
		setElementInterior(player, 0)
		setElementDimension(player, 15)
		triggerClientEvent(player, "onClientPlayerJoinEvent", player, "fallout")
		triggerClientEvent(player, "onClientBoardChasseLoad", player, settings.Fallout.boards, rows, columns)
	end

	setTimer(fallFallout, 12000, 1)
end

function destoryFallout(players)
	if #players > 0 then
		local price = settings.Fallout.toEarn/#players
		for _,player in ipairs(players) do
			exports.TR_core:giveMoneyToPlayer(player, price)
		end
		triggerClientEvent(root, "setEventNoti", resourceRoot, "winsWithoutPlayer", {price})
	else
		exports.TR_core:giveMoneyToPlayer(settings.Fallout.adminHoster, settings.Fallout.toEarn)
	end

	for i,v in ipairs(settings.Fallout.timer) do
		if isTimer(v) then
			killTimer( v )
		end
	end
	for i,v in ipairs(getElementsByType("object", resourceRoot)) do
		if isElement(v) then
			destroyElement( v )
		end
	end
	for player in pairs(settings.Fallout.players) do
		triggerClientEvent(player, "onClientPlayerQuitEvent", player, "fallout")
	end
	destroyElement( settings.Fallout.cuboid )
	triggerEvent("endEvent", resourceRoot)
end

function checkRuleGameFallout()
	local size = table.maxn (settings.Fallout.boards)
	local players = getElementsWithinColShape(settings.Fallout.cuboid, "player")

	if #players < 1 or settings.Fallout.maxBoards >= size then
		destoryFallout(players)
	end
end

function fallFallout()
	local size = table.maxn (settings.Fallout.boards)
	if settings.Fallout.maxBoards < size then
		settings.Fallout.chosen = math.random ( 1, size )
		fallFalloutTrigger ( settings.Fallout.boards[settings.Fallout.chosen] )
		if size >= settings.Fallout.size/2 then
			settings.Fallout.speed = settings.Fallout.speedDefault
		elseif ( size <= settings.Fallout.size-51 ) and ( size > settings.Fallout.size-65 ) then
			settings.Fallout.speed = settings.Fallout.speedDefault - 350
		elseif size < settings.Fallout.size-65 then
			settings.Fallout.speed = settings.Fallout.speedDefault - 100
		end
		table.remove ( settings.Fallout.boards, settings.Fallout.chosen )
		settings.Fallout.timer[#settings.Fallout.timer+1] = setTimer ( fallFallout, settings.Fallout.speed, 1 )
		checkRuleGameFallout()
	else
		checkRuleGameFallout()
	end
end

function fallFalloutTrigger(fallingPiece)
	if isElement(fallingPiece) then
		triggerClientEvent ( "onClientShakeBoard", root, fallingPiece )
		local x, y = getElementPosition ( fallingPiece )
		local rx, ry, rz = math.random( 0, 360 ), math.random( 0, 360 ), math.random( 0, 360 )
		if rx < 245 then rx = -(rx + 245) end --Make the falling pieces with big random spins
		if ry < 245 then ry = -(ry + 245) end
		if rz < 245 then rz = -(rz + 245) end
		settings.Fallout.timer[#settings.Fallout.timer+1] = setTimer ( moveObject, 2500, 1, fallingPiece, 10000, x, y, -58, rx, ry, rz )
		settings.Fallout.timer[#settings.Fallout.timer+1] = setTimer ( destroyElement, 8000, 1, fallingPiece )
	end
end

function createEventFallout(players, toEarn, adminHoster)
	settings.Fallout.players = players
	settings.Fallout.toEarn = toEarn
	settings.Fallout.adminHoster = adminHoster
	local size = 10
	createFallout(size, size-3, math.random(1, 3))
end

-- setTimer(function()
-- local data = {}
-- for i,v in ipairs(getElementsByType("player")) do
-- 	data[v] = true
-- end
-- createEventFallout(data)
-- end, 500, 1)