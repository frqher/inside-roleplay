local r,g,b,a = nil, nil, nil, nil
local sound = false
local boards = {}
local tickLava = getTickCount()
local enterLava = false
local shakeData = {}
local textura = dxCreateTexture("res/textures/lava.png")
local texturaW = dxCreateTexture("res/textures/white.png")
local texturaB = dxCreateTexture("res/textures/black.png")
local rawData = [[
texture Tex0;

technique simple
{
    pass P0
    {
        Texture[0] = Tex0;
    }
}
]]
local shader = dxCreateShader(rawData)
local shaderBlack = dxCreateShader(rawData)
local shaderWhite = dxCreateShader(rawData)

addEvent("onClientPlayerJoinEvent", true)
addEvent("onClientPlayerQuitEvent", true)

local function setPedOnFire(thePed, bool)
	triggerServerEvent("onPlayerFire", localPlayer, thePed, bool )
end


local function isEventHandlerAdded( sEventName, pElementAttachedTo, func ) -- From wiki
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

local _addEventHandler = addEventHandler
local function addEventHandler( eventName, attachedTo, handlerFunction, getPropagated, priority )
	if not isEventHandlerAdded(eventName, attachedTo, handlerFunction) then
		_addEventHandler(eventName, attachedTo, handlerFunction, getPropagated, priority)
	end
end

local _removeEventHandler = removeEventHandler
local function removeEventHandler( eventName, attachedTo, handlerFunction, getPropagated, priority )
	if isEventHandlerAdded(eventName, attachedTo, handlerFunction) then
		_removeEventHandler(eventName, attachedTo, handlerFunction, getPropagated, priority)
	end
end

function onClientRenderLava()
	onClientRenderShake()
	if isElementInWater(localPlayer) then
		setTime(12, 0)
		if not enterLava then
			enterLava = true
			tickLava = getTickCount()
		end
		setPedOnFire(localPlayer, true)
		setElementHealth(localPlayer, math.max( getElementHealth( localPlayer )-1, 1) )
		if getTickCount()-tickLava > 1000 then
			tickLava = getTickCount()
		end
		if getElementHealth( localPlayer ) <= 1 then
			onClientPlayerQuitEventFallout("fallout")
		end
	end
	if not enterLava then
		local x, y, z = getElementPosition(localPlayer)
		if z <= getWaterLevel ( x, y, z ) + 1 then
			setPedOnFire(localPlayer, true)
		end
		local x, y, z = getCameraMatrix()
		local dist = getDistanceBetweenPoints3D(x, y, z, x, y, getWaterLevel ( x, y, z ) )
		if dist <= 60 then
			if not isElement(sound) then
				sound = playSound("res/sounds/lava.mp3", true)
			end
			if isElement(sound) then
				local volume = 1-(dist/60)
				setSoundVolume(sound, volume)
			end
		elseif sound then
			if isElement(sound) then
				stopSound(sound)
			end
			sound = nil
		end
	end
end

function onClientRenderShake()
	local currentTick = getTickCount()
	for object,originalTick in pairs(shakeData) do
		--print(object, originalTick)
	    local tickDifference = currentTick - originalTick
	    if tickDifference > 2400 then
			shakeData[object] = nil
	    else
	        local newx = tickDifference/125 * 1
	        local newy = tickDifference/125 * 1
	    	if isElement ( object ) then
				setElementRotation ( object, math.deg( 0.555 ), 3 * math.cos(newy + 1), 3 * math.sin(newx + 1) )
	    	end
		end
	end
end

function onClientShakeBoard( fallingPiece )
	if isElement(fallingPiece) then
    	shakeData[fallingPiece] = getTickCount()
	end
end
addEvent("onClientShakeBoard",true)
addEventHandler("onClientShakeBoard", getRootElement(), onClientShakeBoard)

function onClientBoardChasseLoad(tables, rows, columns)
	local counter = 0
	boards = tables
	dxSetShaderValue(shaderBlack, "Tex0", texturaB)
	dxSetShaderValue(shaderWhite, "Tex0", texturaW)
	for i = 1,rows do
		for j = 1, columns do
			counter = counter+1
			if counter%2 == 0 then
				engineApplyShaderToWorldTexture(shaderBlack, "solar_panel_1", boards[counter])
			else
				engineApplyShaderToWorldTexture(shaderWhite, "solar_panel_1", boards[counter])
			end
		end
	end
end
addEvent("onClientBoardChasseLoad",true)
addEventHandler("onClientBoardChasseLoad", getRootElement(), onClientBoardChasseLoad)

function onClientPlayerJoinEventFallout(name)
	if name == "fallout" then
		health = getElementHealth( localPlayer )
		r, g, b, a = getWaterColor(  )
		setWaterColor(255, 255, 255, 255)
		dxSetShaderValue(shader, "Tex0", textura)
		engineApplyShaderToWorldTexture(shader, "waterclear256")
		setWeather( 10 )
		setTime(12, 0)
		setElementHealth(localPlayer, 100)

		for i=0,40 do
			setWorldSoundEnabled(i, -1, false, true)
		end
		setAmbientSoundEnabled( "general", false )
		setAmbientSoundEnabled( "gunfire", false )


		addEventHandler("onClientRender", root, onClientRenderLava)
	end
end
addEventHandler("onClientPlayerJoinEvent", root, onClientPlayerJoinEventFallout)

function onClientPlayerQuitEventFallout(name)
	if name == "fallout" then
		removeEventHandler("onClientRender", root, onClientRenderLava)
		setWaterColor(r, g, b, a)
		engineRemoveShaderFromWorldTexture(shader, "waterclear256")
		dxSetShaderValue(shader, "gTexture", false)
		setPedOnFire(localPlayer, false)
		setElementHealth( localPlayer, health )
		if sound and isElement(sound) then
			stopSound(sound)
			if isElement(sound) then
				destroyElement( sound )
			end
		end
	end
end
addEventHandler("onClientPlayerQuitEvent", root, onClientPlayerQuitEventFallout)