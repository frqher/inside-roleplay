local Timer = 10000
addEvent("onVehicleDestroy", true)
PublicVehicles = {}
PublicVehicles.__index = PublicVehicles

function PublicVehicles:new(...)
	local instance = {}
	setmetatable(instance, PublicVehicles)
	if PublicVehicles:constructor(...) then
		return instance
	end
	return false
end

function PublicVehicles:constructor(...)
	self.func = {}
	self.timer = {}
	self.place = {}
	self.rent = {}
	self.func.onVehicleStartEnter = function(player, seat) self:onVehicleStartEnter(player, source, seat) end
	self.func.onPlayerQuit = function() self:onPlayerQuit(source) end
	self.func.isEmptyPlace = function() self:isEmptyPlace() end
	self.func.loadCoroutine = function() self:coroutineEmpty() end
	self.func.onVehicleDestroy = function() self:destroyElement(client) end

	setTimer(self.func.isEmptyPlace, Timer, 1)
	addEventHandler("onPlayerQuit", getRootElement(), self.func.onPlayerQuit)
	addEventHandler("onVehicleStartEnter", resourceRoot, self.func.onVehicleStartEnter)
	addEventHandler("onVehicleDestroy", root, self.func.onVehicleDestroy)

	return true
end

function PublicVehicles:onVehicleStartEnter(player, source, seat)
	if (seat == 0 and self.rent[player] and self.rent[player] ~= source) then
		exports.TR_noti:create(player, "Zaten kiraladığınız bir aracınız var.", "error")
		cancelEvent()
	elseif seat == 0 and getElementData(source, "publicOwner") and getElementData(source, "publicOwner") ~= getPlayerName(player) then
		exports.TR_noti:create(player, "Bu araç sizin tarafınızdan kiralanmadı.", "error")
		cancelEvent()
	elseif seat == 0 and not self.rent[player] then
		self.rent[player] = source
		setElementData(source, "publicOwner", getPlayerName(player))
		source:setFrozen(false)
	end
end


function PublicVehicles:destroyElement(player)
	if self.rent[player] and isElement( self.rent[player] ) then
		destroyElement(self.rent[player])
	end
	self.rent[player] = nil
end

function PublicVehicles:createVehicle(...)
	local veh = createVehicle(arg[1], arg[2], arg[3], arg[4]-0.4, 0, 0, arg[5])
	setElementInterior(veh, arg[7] or 0)
	setElementDimension(veh, arg[8] or 0)
	setElementFrozen(veh, true)
end

function PublicVehicles:isEmptyPlace()
	if self.coroutine == nil or coroutine.status(self.coroutine) == "dead" then
		self.coroutine = coroutine.create(self.func.loadCoroutine)
		coroutine.resume(self.coroutine)
	end
end


function PublicVehicles:coroutineEmpty()
	for i,v in ipairs(self.place) do
		local sphere = createColSphere(v.x, v.y, v.z, 1)
		if #getElementsWithinColShape(sphere) < 1 then
			self:createVehicle(v.model, v.x, v.y, v.z, v.angle, v.interior, v.dimension)
		end
		destroyElement(sphere)
		if i%5 == 0 then
			setTimer(function() coroutine.resume(self.coroutine) end, 1000, 1)
			coroutine.yield()
		end
	end
	self.coroutine = nil
	if self.coroutine == nil or coroutine.status(self.coroutine) == "dead" then
		if isTimer(self.func.isEmptyPlace) then killTimer( self.func.isEmptyPlace ) end
		setTimer(self.func.isEmptyPlace, Timer, 1)
		collectgarbage()
	end
end


function PublicVehicles:createPlace(model, x, y, z, angle, interior, dimension, showBlip)
	PublicVehicles:createVehicle(model, x, y, z, angle, interior, dimension)
	table.insert(self.place, {model = model, x = x, y = y, z = z, angle = angle, interior = interior, dimension = dimension})
    if showBlip then
        local blip = createBlip(x, y, z, 0, 2, 255, 153, 153, 255)
        setElementData(blip, "icon", 37)
    end
end

function PublicVehicles:onPlayerQuit()
	if self.rent[source] and isElement(self.rent[source]) then
		destroyElement(self.rent[source])
		self.rent[source] = nil
	end
	if isTimer(self.timer[source]) then
		killTimer(self.timer[source])
	end
end



vehicles = PublicVehicles:new()
vehicles:createPlace(481, 1735, -1723.5, 13.546875, 180.8, 0, 0) -- LS Spawn
vehicles:createPlace(481, 1733, -1723.5, 13.546875, 180.8, 0, 0, true)
vehicles:createPlace(481, 1730, -1723.5, 13.546875, 180.8, 0, 0)

vehicles:createPlace(481, -1910.16, 901.0, 35.17, 270, 0, 0) -- SF Spawn
vehicles:createPlace(481, -1910.16, 899.0, 35.17, 270, 0, 0, true)
vehicles:createPlace(481, -1910.16, 897.0, 35.17, 270, 0, 0)

vehicles:createPlace(481, 2435.87, 2357.9, 10.82, 90, 0, 0) -- LV Spawn
vehicles:createPlace(481, 2435.87, 2359.9, 10.82, 90, 0, 0, true)
vehicles:createPlace(481, 2435.87, 2355.9, 10.82, 90, 0, 0)

vehicles:createPlace(481, -1829.40, 78.7, 15.11, 270, 0, 0) -- SF kontenery
vehicles:createPlace(481, -1829.40, 80.7, 15.11, 270, 0, 0, true)
vehicles:createPlace(481, -1829.40, 76.7, 15.11, 270, 0, 0)

vehicles:createPlace(481, -2275.11, 534.10, 35.07, 270, 0, 0) -- SF tramwaje
vehicles:createPlace(481, -2275.11, 536.10, 35.07, 270, 0, 0, true)
vehicles:createPlace(481, -2275.11, 532.10, 35.07, 270, 0, 0)

vehicles:createPlace(481, -2406.43, 699.57, 35.17, 0, 0, 0) -- SF kosiarki
vehicles:createPlace(481, -2408.43, 699.57, 35.17, 0, 0, 0, true)
vehicles:createPlace(481, -2404.43, 699.57, 35.17, 0, 0, 0)

vehicles:createPlace(481, -2279.47, 2295.43, 4.96, 270, 0, 0) -- SF magazyn
vehicles:createPlace(481, -2279.47, 2297.43, 4.96, 270, 0, 0, true)
vehicles:createPlace(481, -2279.47, 2293.43, 4.96, 270, 0, 0)

vehicles:createPlace(481, -1981.28, 131.01, 27.68, 90, 0, 0) -- SF station
vehicles:createPlace(481, -1981.28, 133.01, 27.68, 90, 0, 0, true)
vehicles:createPlace(481, -1981.28, 129.01, 27.68, 90, 0, 0)

vehicles:createPlace(481, -2018.38, -97.75, 35.16, 90, 0, 0) -- SF Prawko
vehicles:createPlace(481, -2018.38, -99.75, 35.16, 90, 0, 0, true)
vehicles:createPlace(481, -2018.38, -95.75, 35.16, 90, 0, 0)

vehicles:createPlace(481, -2631.87, 209.32, 4.46, 0, 0, 0) -- SF ammonation
vehicles:createPlace(481, -2633.87, 209.32, 4.46, 0, 0, 0, true)
vehicles:createPlace(481, -2629.87, 209.32, 4.46, 0, 0, 0)

vehicles:createPlace(481, -2741.74, 400.99, 4.36, 90, 0, 0) -- SF urząd
vehicles:createPlace(481, -2741.74, 398.99, 4.36, 90, 0, 0, true)
vehicles:createPlace(481, -2741.74, 402.99, 4.36, 90, 0, 0)

vehicles:createPlace(481, 2029.12, 998.91, 10.81, 270, 0, 0) -- LV kasyno
vehicles:createPlace(481, 2029.12, 1000.91, 10.81, 270, 0, 0, true)
vehicles:createPlace(481, 2029.12, 996.91, 10.81, 270, 0, 0)

vehicles:createPlace(481, 241.32, -259.75, 1.57, 90, 0, 0) -- BB szrot
vehicles:createPlace(481, 241.32, -257.75, 1.57, 90, 0, 0, true)
vehicles:createPlace(481, 241.32, -261.75, 1.57, 90, 0, 0)

vehicles:createPlace(481, 687.74, -476.41, 16.33, 180, 0, 0) -- Dillimore bar
vehicles:createPlace(481, 685.74, -476.41, 16.33, 180, 0, 0, true)
vehicles:createPlace(481, 689.74, -476.41, 16.33, 180, 0, 0)

vehicles:createPlace(481, 54.23, 1210.73, 18.88, 180, 0, 0) -- FC
vehicles:createPlace(481, 52.23, 1210.73, 18.88, 180, 0, 0, true)
vehicles:createPlace(481, 56.23, 1210.73, 18.88, 180, 0, 0)

vehicles:createPlace(481, -821.22, 1500.66, 19.65, 180, 0, 0) -- LB
vehicles:createPlace(481, -823.22, 1500.66, 19.65, 180, 0, 0, true)
vehicles:createPlace(481, -819.22, 1500.66, 19.65, 180, 0, 0)

vehicles:createPlace(481, -1487.57, 2646.25, 55.83, 90, 0, 0) -- ElQ
vehicles:createPlace(481, -1487.57, 2648.25, 55.83, 90, 0, 0, true)
vehicles:createPlace(481, -1487.57, 2644.25, 55.83, 90, 0, 0)

vehicles:createPlace(481, -234.54, 2692.59, 62.68, 0, 0, 0) -- LP
vehicles:createPlace(481, -236.54, 2692.59, 62.68, 0, 0, 0, true)
vehicles:createPlace(481, -232.54, 2692.59, 62.68, 0, 0, 0)

vehicles:createPlace(481, 2276.87, -72.94, 26.56, 270, 0, 0) -- PC
vehicles:createPlace(481, 2276.87, -74.94, 26.56, 270, 0, 0, true)
vehicles:createPlace(481, 2276.87, -70.94, 26.56, 270, 0, 0)
