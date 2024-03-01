policeBoard = createElement("Board", "Police Board Shoot Range (1)")
local schema = {
    columns = {
        {name = "Lp.", row = {"1.", "2.", "3.", "4.", "5.", "6.", "7.", "8."} },
        {name = "Pociski", row = {"-", "-", "-", "-", "-", "-", "-", "-"} },
        {name = "Trafienia", row = {"-", "-", "-", "-", "-", "-", "-", "-"} },
        {name = "Celnosc", row = {"-", "-", "-", "-", "-", "-", "-", "-"} },
        {name = "Czas", row = {"-", "-", "-", "-", "-", "-", "-", "-"} },
    },
}
setElementData(policeBoard, "schema", schema)


_createObject = createObject
local range = {}
local pos = {}

local function createObject(model, x, y, z, rx, ry, rz, interior, dimension)
	local this = _createObject(model, x, y, z, rx, ry, rz)
	setElementDimension(this, dimension)
	setElementInterior(this, interior)
	return this
end


function createRange(x, y, z, rz, interior, dimension, endX, endY, endZ, rand, colshape)
	local static_x = x
	x = x+rand
	local body = createObject(3025, x, y, z, 90, 0, rz, interior, dimension)
	local head = createObject(3024, x, y, z, 0, 0, rz, interior, dimension)
	local left_arm = createObject(3023, x, y, z, 0, 0, rz, interior, dimension)
	local right_arm = createObject(3022, x, y, z, 0, 0, rz, interior, dimension)
	local right_torso = createObject(3021, x, y, z, 0, 0, rz, interior, dimension)
	local left_torso = createObject(3020, x, y, z, 0, 0, rz, interior, dimension)
	local left_leg = createObject(3019, x, y, z, 0, 0, rz, interior, dimension)
	local right_leg = createObject(3018, x, y, z, 0, 0, rz, interior, dimension)
	attachElements( head, body, 0, 0, 0 )
	attachElements( left_arm, body, 0, 0, 0 )
	attachElements( right_arm, body, 0, 0, 0 )
	attachElements( right_torso, body, 0, 0, 0 )
	attachElements( left_torso, body, 0, 0, 0 )
	attachElements( left_leg, body, 0, 0, 0 )
	attachElements( right_leg, body, 0, 0, 0 )
	setElementParent(head, body)
	setElementParent(left_arm, body)
	setElementParent(right_arm, body)
	setElementParent(right_torso, body)
	setElementParent(left_torso, body)
	setElementParent(left_leg, body)
	setElementParent(right_leg, body)
	local distanced = getDistanceBetweenPoints2D(x, y, z, endX, endY, endZ)
	local moveX, moveY, moveZ = endX-x, endY-y, endZ-z
	moveObject( body, 1500, x, y, z, -90, 0, 0 )
	setTimer(function(body, x, y, z)
		moveObject( body, distanced, x+moveX, y+moveY, z+moveZ)
	end, 1550, 1, body, x, y, z, moveX, moveY, moveZ)
	setTimer(function(body, x, y, z)
		moveObject( body, 1500, x, y, z, 90, 0, 0 )
	end, 7050, 1, body, x+moveX, y+moveY, z+moveZ)
	setTimer(function(body, x, y, z, rz, interior, dimension, endX, endY, endZ, colshape)
		destroyElement( body )
		if #getElementsWithinColShape( colshape, "player" ) > 0 then
			local rand = math.random(1,5)
			createRange(static_x, y, z, rz, interior, dimension, endX, endY, endZ, rand, colshape)
		else
			range[colshape] = nil
		end
	end, 7050+1500, 1, body, x, y, z, rz, interior, dimension, endX, endY, endZ, colshape)
	return true
end


for i=1,8 do
	local this = createColSphere(2821.99, -2536.95+1.52*(i-1), 81, 0.5)
	setElementDimension(this, 6)
	setElementInterior(this, 4)
	setElementData(this, "ID", i)
	addEventHandler( "onColShapeHit", this, function(player, md)
		if not getElementData(source, "use") then
			triggerClientEvent(player, "onClientPlayerHitShootRange", player, source)
		end
		if not range[source] and getElementType(player) == "player" and md and getElementInterior(source) == getElementInterior(player) then
			local x, y, z = getElementPosition( source )
			local rand = math.random(1, 5)
			range[source] = createRange(x-19, y, z+3.2, 90, 4, 6, x-9.5, y, z+3.2, rand, source)
			setElementData(source, "use", player)
		end
	end)
end