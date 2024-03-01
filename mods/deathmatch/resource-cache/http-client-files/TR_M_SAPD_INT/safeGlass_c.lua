


polygonRangeShoot = createColPolygon(2825.7841796875, -2539.115234375, 2825.7841796875, -2539.115234375, 2827.5078125, -2538.044921875, 2827.9287109375, -2524.271484375, 2800.12890625, -2524.2548828125, 2800.267578125, -2542.703125, 2827.4072265625, -2542.5390625, 2827.568359375, -2540.9345703125, 2825.5830078125, -2541.0693359375)
policeBoard = getElementByID("Police Board Shoot Range (1)")
schema = {
    columns = {
        {name = "Lp.", row = {"1.", "2.", "3.", "4.", "5.", "6.", "7.", "8."} },
        {name = "Pociski", row = {"-", "-", "-", "-", "-", "-", "-", "-"} },
        {name = "Trafienia", row = {"-", "-", "-", "-", "-", "-", "-", "-"} },
        {name = "Celnosc", row = {"-", "-", "-", "-", "-", "-", "-", "-"} },
        {name = "Czas", row = {"-", "-", "-", "-", "-", "-", "-", "-"} },
    },
}

function isEventHandlerAdded( sEventName, pElementAttachedTo, func )
	if type( sEventName ) == 'string' and isElement( pElementAttachedTo ) and type( func ) == 'function' then
	    local aAttachedFunctions = getEventHandlers( sEventName, pElementAttachedTo )
		if type( aAttachedFunctions ) == 'table' and #aAttachedFunctions > 0 then
			for i, v in ipairs( aAttachedFunctions ) do
				if v == func then
					return true
				end
			end
		end
	end
	return false
end



function isPedAiming (thePedToCheck)
	if isElement(thePedToCheck) then
		if getElementType(thePedToCheck) == "player" or getElementType(thePedToCheck) == "ped" then
			if getPedTask(thePedToCheck, "secondary", 0) == "TASK_SIMPLE_USE_GUN" or isPedDoingGangDriveby(thePedToCheck) then
				return true
			end
		end
	end
	return false
end


addEventHandler( "onClientColShapeHit", polygonRangeShoot, function(theElement)
    if getElementDimension(localPlayer) == 6 and getElementInterior(localPlayer) == 4 and theElement == localPlayer then
    	if not isEventHandlerAdded("onClientElementDataChange", policeBoard, updateBoardElement) then
			shaderBoard = dxCreateShader(rawData)
			renderTarget = dxCreateRenderTarget(512, 512)
			texture = dxCreateTexture("board.png");
			shader = dxCreateShader(rawDataFilter);
			dxSetShaderValue(shader, "gTexture", texture)
			dxSetShaderValue(shader, "gBrightness", 1)
			dxSetShaderValue(shader, "gColor", 83/255, (29+40)/255, (20+40)/255, 1)
			dxSetShaderValue(shader, "gAlpha", 1)

			schema = getElementData(policeBoard, "schema")

			addEventHandler("onClientElementDataChange", policeBoard, updateBoardElement)
    		updateBoard()
    	end
    end
end)

addEventHandler( "onClientColShapeLeave", polygonRangeShoot, function(theElement)
    if theElement == localPlayer then
    	if isEventHandlerAdded("onClientElementDataChange", policeBoard, updateBoardElement) then
			destroyElement(shaderBoard)
			destroyElement(renderTarget)
			destroyElement(texture)
			destroyElement(shader)

			removeEventHandler( "onClientElementDataChange", policeBoard, updateBoardElement)
    	end
    end
end)