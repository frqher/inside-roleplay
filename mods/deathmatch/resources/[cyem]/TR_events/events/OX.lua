addEvent("onPlayerQuitEvent", true)

local settingsOX = {colshapes = {}}

local function getSeconds(num)
    if num == 1 then return "sekunda" end
    if num < 5 then return "sekundy" end
    return "sekund"
end

local function table_copy(tab, recursive)
    local ret = {}
    for key, value in pairs(tab) do
        if (type(value) == "table") and recursive then ret[key] = table.copy(value)
        else ret[key] = value end
    end
    return ret
end


settingsOX.counter = createElement("Counter", "Counter (OX)")
settingsOX.GateA = createObject(988, 3619.48, 322.8, 12.75)
settingsOX.BarrierA = createObject(3850, 3619.48, 322.8, 12.75, 0, 0, 90)
setElementID(settingsOX.GateA, "OX INT (GATE) (A)")
setElementID(settingsOX.BarrierA, "OX INT (BARRIER) (A)")
setObjectScale( settingsOX.BarrierA, 1.65 )
setElementAlpha(settingsOX.GateA, 0)
setElementDimension(settingsOX.GateA, 10)
setElementDimension(settingsOX.BarrierA, 10)

settingsOX.GateB = createObject(988, 3619.48, 315.77, 12.75)
settingsOX.BarrierB = createObject(3850, 3619.48, 315.77, 12.75, 0, 0, 90)
setElementID(settingsOX.GateB, "OX INT (GATE) (B)")
setElementID(settingsOX.BarrierB, "OX INT (BARRIER) (B)")
setObjectScale(settingsOX.BarrierB, 1.65 )
setElementAlpha(settingsOX.GateB, 0)
setElementDimension(settingsOX.GateB, 10)
setElementDimension(settingsOX.BarrierB, 10)



function toggleGate(toggle, blockQuestion)
	if toggle then
		local x, y, z = getElementPosition( settingsOX.GateA )
		moveObject(settingsOX.GateA, 1000, x, y, z-5)
		local x, y, z = getElementPosition( settingsOX.BarrierA )
		setTimer(moveObject, 650, 1, settingsOX.BarrierA, 1000, x, y, z-5)

		local x, y, z = getElementPosition( settingsOX.GateB )
		moveObject(settingsOX.GateB, 1000, x, y, z-5)
		local x, y, z = getElementPosition( settingsOX.BarrierB )
		setTimer(moveObject, 650, 1, settingsOX.BarrierB, 1000, x, y, z-5)

		setElementData(settingsOX.counter, "text", "Lütfen bir sonraki soruyu bekleyin")
		if not blockQuestion then setAdminOXQuestion() end

	elseif not toggle then
		local x, y, z = getElementPosition( settingsOX.GateA )
		moveObject(settingsOX.GateA, 1000, x, y, z+5)
		local x, y, z = getElementPosition( settingsOX.BarrierA )
		moveObject(settingsOX.BarrierA, 650, x, y, z+5)

		local x, y, z = getElementPosition( settingsOX.GateB )
		moveObject(settingsOX.GateB, 1000, x, y, z+5)
		local x, y, z = getElementPosition( settingsOX.BarrierB )
		moveObject(settingsOX.BarrierB, 650, x, y, z+5)

		setTimer(getElementsWithinColShapeOX, 2500, 1)
	end
end

function setAdminOXQuestion()
	triggerClientEvent(eventData.createdAdmin, "setAdminOXQuestion", resourceRoot)
end

function destroyOX(backMoney)
	for player in pairs(eventData.playersLeft) do
		triggerClientEvent(player, "onClientPlayerQuitEvent", player, "OX")
		setElementData(player, "OX", nil)
	end
	triggerEvent("endEvent", resourceRoot)

	if backMoney then
		exports.TR_core:giveMoneyToPlayer(eventData.createdAdmin, eventData.winPrice)
	end

	settingsOX.players = {}
	settingsOX.observer = nil
   	destroyElement( settingsOX.colshapes["true"] )
   	destroyElement( settingsOX.colshapes["false"] )
   	settingsOX.colshapesGood = false
end

function createOX()
	if eventData.playersLeft and type(eventData.playersLeft) == "table" then
		settingsOX.players = table_copy(eventData.playersLeft)
    	for player in pairs(settingsOX.players) do
    		setElementPosition(player, 3619.77, 319.22, 13.24)
			setElementInterior(player, 0)
			setElementDimension(player, 10)

    		setElementData(player, "OX", true)
    		triggerClientEvent(player, "onClientPlayerJoinEvent", player, "OX")
    	end
	end
	if isElement(eventData.createdAdmin) then
		setElementPosition(eventData.createdAdmin, 3611.2568359375, 329.326171875, 14.884062767029)
		setElementInterior(eventData.createdAdmin, 0)
		setElementDimension(eventData.createdAdmin, 10)
	end

	settingsOX.observer = { {3627.72, 319.57, 14.88, 90}, {3611.22, 319.04, 14.88, 0}, {3619.44, 305.56, 14.88, 0}, {3619.17, 332.49, 14.72, 180}   }
   	settingsOX.colshapes["true"] = createColCuboid(3614.05, 309.02, 12, 10.85, 6.7, 5.6 )
   	settingsOX.colshapes["false"] = createColCuboid(3614.05, 322.85, 12, 10.85, 6.7, 5.6  )
   	settingsOX.colshapesGood = false

   	toggleGate(true, true)
	setTimer(setAdminOXQuestion, 11000, 1)
end

function getElementsWithinColShapeOX()
	for player in pairs(settingsOX.players) do
		if not isElementWithinColShape(player, settingsOX.colshapesGood) then
			local position = settingsOX.observer[math.random(1, #settingsOX.observer)]
			settingsOX.players[player] = nil
			setElementPosition(player, position[1], position[2], position[3])
			setElementRotation(player, 0, 0, position[4])
			eventData.players[player].onTribune = true
		end
	end
	local counter = 0
	local firstPlayer = false
	for player in pairs(settingsOX.players) do
		counter = counter+1
		if not firstPlayer then
			firstPlayer = player
		end
	end
	if counter > 1 then
		setTimer(toggleGate, 5000, 1, true)
	else
		setTimer(function()
			if counter == 1 and firstPlayer then
				triggerClientEvent(root, "setEventNoti", resourceRoot, "win", {getPlayerName(firstPlayer), eventData.events[eventData.selectedEvent].name, eventData.winPrice})
				setElementData(settingsOX.counter, "text", "")
				destroyOX(false)
				exports.TR_core:giveMoneyToPlayer(firstPlayer, eventData.winPrice)
			else
				triggerClientEvent(root, "setEventNoti", resourceRoot, "nooneWins")
				setElementData(settingsOX.counter, "text", "")
				destroyOX(true)
			end
		end, 5000, 1)
	end
end

function setQuestion(text, isTrue)
	settingsOX.Question = text
	settingsOX.colshapesGood = isTrue and settingsOX.colshapes["true"] or settingsOX.colshapes["false"]
	setElementData(settingsOX.counter, "text", "Soru:\n"..settingsOX.Question)
	setTimer(setCounter, 5000, 1, 10)
end
addEvent("OX:setQuestion", true)
addEventHandler("OX:setQuestion", root, setQuestion)

function setCounter(time)
	settingsOX.time = time+1
	setTimer(function()
		if settingsOX.time > 1 then
			settingsOX.time = settingsOX.time-1
			setElementData(settingsOX.counter, "text", string.format("Cevap zamanı:\n%d %s", settingsOX.time, getSeconds(settingsOX.time) ) )
		else
			toggleGate(false)
			setElementData(settingsOX.counter, "text", false)
		end
	end, 1000, time+1)
end