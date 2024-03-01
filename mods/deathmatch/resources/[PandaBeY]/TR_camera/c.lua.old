-- state variables
local speed = 0
local camFov = 70
local camRoll = 0
local strafespeed = 0
local rotX, rotY = 0,0
local isSlowCamHack = true
local velocityX, velocityY, velocityZ

-- configurable parameters
local slowOptions = {
	normalMaxSpeed = 0.05,
	slowMaxSpeed = 0.012,
	fastMaxSpeed = 1,
	acceleration = 0.002,
	decceleration = 0.001,
	mouseSensitivity = 0.006
}

local fastOptions = {
	normalMaxSpeed = 1,
	slowMaxSpeed = 0.1,
	fastMaxSpeed = 5,
	acceleration = 0.3,
	decceleration = 0.15,
	mouseSensitivity = 0.3
}

local camKeys = {
	key_fastMove = "lshift",
	key_slowMove = "lalt",
	key_forward = "forwards",
	key_backward = "backwards",
	key_left = "left",
	key_right = "right",
	key_forward_veh = "accelerate",
	key_backward_veh = "brake_reverse",
	key_left_veh = "vehicle_left",
	key_right_veh = "vehicle_right",
	key_up_fov = "c",
	key_down_fov = "z",
	key_left_roll = "q",
	key_right_roll = "e"
}

local controlToKey = {
	["forwards"] = "w",
	["backwards"] = "s",
	["left"] = "a",
	["right"] = "d",
	["accelerate"] = "w",
	["brake_reverse"] = "s",
	["vehicle_left"] = "a",
	["vehicle_right"] = "d"
}

local mouseFrameDelay = 0

local mta_getKeyState = getKeyState
function getKeyState(key)
	if isMTAWindowActive() then
		return false
	end
	if key == "lshift" or key == "lalt" or key == "arrow_u" or key == "arrow_d" or key == "arrow_l" or key == "arrow_r" or key == "z" or key == "c" or key == "q" or key == "e" then
		return mta_getKeyState(key)
	else
		return mta_getKeyState(controlToKey[key]) or getControlState(key)
	end
end

-- PRIVATE

function camFrame()
	setPedWeaponSlot(localPlayer, 0 )

	-- Edit the camera angle within 0.5 degrees.
	if getKeyState( camKeys.key_right_roll ) then
		if camRoll - 1 < -45 then
			return
		else
			camRoll = camRoll - 0.5
		end
	elseif getKeyState( camKeys.key_left_roll ) then
		if camRoll + 1 > 45 then
			return
		else
			camRoll = camRoll + 0.5
		end
	end

	if getKeyState( camKeys.key_down_fov ) then
		if camFov - 1 < 0 then
			return
		else
			camFov = camFov - 0.5
		end
	elseif getKeyState( camKeys.key_up_fov ) then
		if camFov + 1 > 180 then
			return
		else
			camFov = camFov + 0.5
		end
	end

	if isSlowCamHack then
		-- Calculate what the maximum speed that the camera should be able to move at.
		local mspeed = slowOptions.normalMaxSpeed
		if getKeyState ( camKeys.key_fastMove ) then
			mspeed = slowOptions.fastMaxSpeed
		elseif getKeyState ( camKeys.key_slowMove ) then
			mspeed = slowOptions.slowMaxSpeed
		end

		local acceleration = slowOptions.acceleration
		local decceleration = slowOptions.decceleration

	    -- Check to see if the forwards/backwards camKeys are pressed
	    local speedKeyPressed = false
	    if ( getKeyState ( camKeys.key_forward ) or getKeyState ( camKeys.key_forward_veh ) ) and not getKeyState("arrow_u") then
			speed = speed + acceleration
	        speedKeyPressed = true
	    end
		if ( getKeyState ( camKeys.key_backward ) or getControlState ( camKeys.key_backward_veh ) ) and not getKeyState("arrow_d") then
			speed = speed - acceleration
	        speedKeyPressed = true
	    end

	    -- Check to see if the strafe camKeys are pressed
	    local strafeSpeedKeyPressed = false
		if ( getKeyState ( camKeys.key_right ) or getKeyState ( camKeys.key_right_veh ) ) and not getKeyState("arrow_r") then
	        if strafespeed > 0 then -- for instance response
	            strafespeed = 0
	        end
	        strafespeed = strafespeed - acceleration / 2
	        strafeSpeedKeyPressed = true
	    end
		if ( getKeyState ( camKeys.key_left ) or getKeyState ( camKeys.key_left_veh ) ) and not getKeyState("arrow_l") then
	        if strafespeed < 0 then -- for instance response
	            strafespeed = 0
	        end
	        strafespeed = strafespeed + acceleration / 2
	        strafeSpeedKeyPressed = true
	    end

	    -- If no forwards/backwards camKeys were pressed, then gradually slow down the movement towards 0
	    if speedKeyPressed ~= true then
			if speed > 0 then
				speed = speed - decceleration
			elseif speed < 0 then
				speed = speed + decceleration
			end
	    end

	    -- If no strafe camKeys were pressed, then gradually slow down the movement towards 0
	    if strafeSpeedKeyPressed ~= true then
			if strafespeed > 0 then
				strafespeed = strafespeed - decceleration
			elseif strafespeed < 0 then
				strafespeed = strafespeed + decceleration
			end
	    end

	    -- Check the ranges of values - set the speed to 0 if its very close to 0 (stops jittering), and limit to the maximum speed
	    if speed > -decceleration and speed < decceleration then
	        speed = 0
	    elseif speed > mspeed then
	        speed = mspeed
	    elseif speed < -mspeed then
	        speed = -mspeed
	    end

	    if strafespeed > -(acceleration / 2) and strafespeed < (acceleration / 2) then
	        strafespeed = 0
	    elseif strafespeed > mspeed then
	        strafespeed = mspeed
	    elseif strafespeed < -mspeed then
	        strafespeed = -mspeed
	    end
	else
		-- Calculate what the maximum speed that the camera should be able to move at.
		local mspeed = fastOptions.normalMaxSpeed
		if getKeyState ( camKeys.key_fastMove ) then
			mspeed = fastOptions.fastMaxSpeed
		elseif getKeyState ( camKeys.key_slowMove ) then
			mspeed = fastOptions.slowMaxSpeed
		end

		local acceleration = fastOptions.acceleration
		local decceleration = fastOptions.decceleration

	    -- Check to see if the forwards/backwards camKeys are pressed
	    local speedKeyPressed = false
	    if ( getKeyState ( camKeys.key_forward ) or getKeyState ( camKeys.key_forward_veh ) ) and not getKeyState("arrow_u") then
			speed = speed + acceleration
	        speedKeyPressed = true
	    end
		if ( getKeyState ( camKeys.key_backward ) or getControlState ( camKeys.key_backward_veh ) ) and not getKeyState("arrow_d") then
			speed = speed - acceleration
	        speedKeyPressed = true
	    end

	    -- Check to see if the strafe camKeys are pressed
	    local strafeSpeedKeyPressed = false
		if ( getKeyState ( camKeys.key_right ) or getKeyState ( camKeys.key_right_veh ) ) and not getKeyState("arrow_r") then
	        if strafespeed > 0 then -- for instance response
	            strafespeed = 0
	        end
	        strafespeed = strafespeed - acceleration / 2
	        strafeSpeedKeyPressed = true
	    end
		if ( getKeyState ( camKeys.key_left ) or getKeyState ( camKeys.key_left_veh ) ) and not getKeyState("arrow_l") then
	        if strafespeed < 0 then -- for instance response
	            strafespeed = 0
	        end
	        strafespeed = strafespeed + acceleration / 2
	        strafeSpeedKeyPressed = true
	    end

	    -- If no forwards/backwards camKeys were pressed, then gradually slow down the movement towards 0
	    if speedKeyPressed ~= true then
			if speed > 0 then
				speed = speed - decceleration
			elseif speed < 0 then
				speed = speed + decceleration
			end
	    end

	    -- If no strafe camKeys were pressed, then gradually slow down the movement towards 0
	    if strafeSpeedKeyPressed ~= true then
			if strafespeed > 0 then
				strafespeed = strafespeed - decceleration
			elseif strafespeed < 0 then
				strafespeed = strafespeed + decceleration
			end
	    end

	    -- Check the ranges of values - set the speed to 0 if its very close to 0 (stops jittering), and limit to the maximum speed
	    if speed > -decceleration and speed < decceleration then
	        speed = 0
	    elseif speed > mspeed then
	        speed = mspeed
	    elseif speed < -mspeed then
	        speed = -mspeed
	    end

	    if strafespeed > -(acceleration / 2) and strafespeed < (acceleration / 2) then
	        strafespeed = 0
	    elseif strafespeed > mspeed then
	        strafespeed = mspeed
	    elseif strafespeed < -mspeed then
	        strafespeed = -mspeed
	    end
	end
    -- work out an angle in radians based on the number of pixels the cursor has moved (ever)
    local cameraAngleX = rotX
    local cameraAngleY = rotY

    local freeModeAngleZ = math.sin(cameraAngleY)
    local freeModeAngleY = math.cos(cameraAngleY) * math.cos(cameraAngleX)
    local freeModeAngleX = math.cos(cameraAngleY) * math.sin(cameraAngleX)
    local camPosX, camPosY, camPosZ = getCameraMatrix()

    -- calculate a target based on the current position and an offset based on the angle
    local camTargetX = camPosX + freeModeAngleX * 100
    local camTargetY = camPosY + freeModeAngleY * 100
    local camTargetZ = camPosZ + freeModeAngleZ * 100

    -- Work out the distance between the target and the camera (should be 100 units)
    local camAngleX = camPosX - camTargetX
    local camAngleY = camPosY - camTargetY
    local camAngleZ = 0 -- we ignore this otherwise our vertical angle affects how fast you can strafe

    -- Calulcate the length of the vector
    local angleLength = math.sqrt(camAngleX*camAngleX+camAngleY*camAngleY+camAngleZ*camAngleZ)

    -- Normalize the vector, ignoring the Z axis, as the camera is stuck to the XY plane (it can't roll)
    local camNormalizedAngleX = camAngleX / angleLength
    local camNormalizedAngleY = camAngleY / angleLength
    local camNormalizedAngleZ = 0

    -- We use this as our rotation vector
    local normalAngleX = 0
    local normalAngleY = 0
    local normalAngleZ = 1

    -- Perform a cross product with the rotation vector and the normalzied angle
    local normalX = (camNormalizedAngleY * normalAngleZ - camNormalizedAngleZ * normalAngleY)
    local normalY = (camNormalizedAngleZ * normalAngleX - camNormalizedAngleX * normalAngleZ)
    local normalZ = (camNormalizedAngleX * normalAngleY - camNormalizedAngleY * normalAngleX)

    -- Update the camera position based on the forwards/backwards speed
    camPosX = camPosX + freeModeAngleX * speed
    camPosY = camPosY + freeModeAngleY * speed
    camPosZ = camPosZ + freeModeAngleZ * speed

    -- Update the camera position based on the strafe speed
    camPosX = camPosX + normalX * strafespeed
    camPosY = camPosY + normalY * strafespeed
	camPosZ = camPosZ + normalZ * strafespeed



	--Store the velocity
	velocityX = (freeModeAngleX * speed) + (normalX * strafespeed)
	velocityY = (freeModeAngleY * speed) + (normalY * strafespeed)
	velocityZ = (freeModeAngleZ * speed) + (normalZ * strafespeed)

    -- Update the target based on the new camera position (again, otherwise the camera kind of sways as the target is out by a frame)
    camTargetX = camPosX + freeModeAngleX * 100
    camTargetY = camPosY + freeModeAngleY * 100
	camTargetZ = camPosZ + freeModeAngleZ * 100

	if getDistanceBetweenPoints3D(Vector3(getElementPosition(localPlayer)), camPosX, camPosY, camPosZ) > 30 and lastCamPos then
		setCameraMatrix(lastCamPos, camTargetX, camTargetY, camTargetZ, camRoll, camFov)
		return
	end
	lastCamPos = Vector3(camPosX, camPosY, camPosZ)

    -- Set the new camera position and target
    setCameraMatrix(camPosX, camPosY, camPosZ, camTargetX, camTargetY, camTargetZ, camRoll, camFov)
end

function camMouse (cX,cY,aX,aY)
	--ignore mouse movement if the cursor or MTA window is on
	--and do not resume it until at least 5 frames after it is toggled off
	--(prevents cursor mousemove data from reaching this handler)
	if isCursorShowing() or isMTAWindowActive() then
		mouseFrameDelay = 5
		return
	elseif mouseFrameDelay > 0 then
		mouseFrameDelay = mouseFrameDelay - 1
		return
	end

	-- how far have we moved the mouse from the screen center?
    local width, height = guiGetScreenSize()
    aX = aX - width / 2
    aY = aY - height / 2

	if isSlowCamHack then
		rotX = rotX + aX * slowOptions.mouseSensitivity * 0.01745
		rotY = rotY - aY * slowOptions.mouseSensitivity * 0.01745
	else
		rotX = rotX + aX * fastOptions.mouseSensitivity * 0.01745
		rotY = rotY - aY * fastOptions.mouseSensitivity * 0.01745
	end

	local PI = math.pi
	if rotX > PI then
		rotX = rotX - 2 * PI
	elseif rotX < -PI then
		rotX = rotX + 2 * PI
	end

	if rotY > PI then
		rotY = rotY - 2 * PI
	elseif rotY < -PI then
		rotY = rotY + 2 * PI
	end
    -- limit the camera to stop it going too far up or down - PI/2 is the limit, but we can't let it quite reach that or it will lock up
	-- and strafeing will break entirely as the camera loses any concept of what is 'up'
    if rotY < -PI / 2.05 then
       rotY = -PI / 2.05
    elseif rotY > PI / 2.05 then
        rotY = PI / 2.05
    end
end

addEvent( "onClientEnableCamMode", true )
addEventHandler( "onClientEnableCamMode", root,
	function( state )
		if getElementData( localPlayer, "isPlayerInCamHackMode" ) then
			return false
		end
		addEventHandler( "onClientPreRender", root, camFrame )
		addEventHandler( "onClientCursorMove", root, camMouse )
		setElementData( localPlayer, "isPlayerInCamHackMode", true )
		isSlowCamHack = state
		setElementFrozen(localPlayer, true)
		toggleControl("enter_exit", false)
		return true
	end
)

addEvent( "onClientDisableCamMode", true )
addEventHandler( "onClientDisableCamMode", root,
	function( )
		if not getElementData( localPlayer, "isPlayerInCamHackMode" ) then
			return false
		end
		velocityX,velocityY,velocityZ = 0,0,0
		speed = 0
		camFov = 70
		camRoll = 0
		strafespeed = 0
		removeEventHandler( "onClientPreRender", root, camFrame )
		removeEventHandler( "onClientCursorMove",root, camMouse )
		setElementData( localPlayer, "isPlayerInCamHackMode", false )
		setCameraTarget( localPlayer )
		setElementFrozen(localPlayer, false)
		toggleControl("enter_exit", true)
		return true
	end
)

addEventHandler( "onClientResourceStop", resourceRoot,
	function( )
		if not getElementData( localPlayer,"isPlayerInCamHackMode" ) then
			return
		end
		velocityX,velocityY,velocityZ = 0,0,0
		speed = 0
		camFov = 70
		camRoll = 0
		strafespeed = 0
		removeEventHandler( "onClientPreRender", root, camFrame )
		removeEventHandler( "onClientCursorMove",root, camMouse )
		setElementData( localPlayer, "isPlayerInCamHackMode", false )
		setCameraTarget( localPlayer )
	end
)

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		setElementData(localPlayer, "isPlayerInCamHackMode", false)
	end
)