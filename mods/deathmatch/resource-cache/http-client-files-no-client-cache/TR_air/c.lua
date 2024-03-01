local sx, sy = guiGetScreenSize()
local timerCheck = false

local logInfo = {}

function putPlayerInPosition(timeslice)
    local canMove = not isCursorShowing()

    local cx,cy,cz,ctx,cty,ctz = getCameraMatrix()
    ctx,cty = ctx-cx,cty-cy
    timeslice = timeslice*0.1
    local tx, ty, tz = getWorldFromScreenPosition(sx / 2, sy / 2, 10)
    if isChatBoxInputActive() or isConsoleActive() or isMainMenuActive () or isTransferBoxActive () then return end
    if getKeyState("lctrl") and canMove then timeslice = timeslice*4 end
    if getKeyState("lalt") and canMove then timeslice = timeslice*0.15 end
    local mult = timeslice/math.sqrt(ctx*ctx+cty*cty)
    ctx,cty = ctx*mult,cty*mult
    if getKeyState("w") and canMove then abx,aby = abx+ctx,aby+cty end
    if getKeyState("s") and canMove then abx,aby = abx-ctx,aby-cty end
    if getKeyState("a") and canMove then  abx,aby = abx-cty,aby+ctx end
    if getKeyState("d") and canMove then abx,aby = abx+cty,aby-ctx end
    if getKeyState("space") and canMove then  abz = abz+timeslice end
    if getKeyState("lshift") and canMove then   abz = abz-timeslice end
    local x,y = 100,200


    if isPedInVehicle ( getLocalPlayer( ) ) then
    local vehicle = getPedOccupiedVehicle( getLocalPlayer( ) )
    local angle = getPedCameraRotation(getLocalPlayer ( ))
    setElementPosition(vehicle,abx,aby,abz)
    setElementRotation(vehicle,0,0,-angle)
    else
    local angle = getPedCameraRotation(getLocalPlayer ( ))
    setElementRotation(getLocalPlayer ( ),0,0,angle)
    setElementPosition(getLocalPlayer ( ),abx,aby,abz)
    end

    dxDrawText(("%.2f %.2f %.2f"):format(abx,aby,abz), 50, 20, 50, 50)
end

function toggleAirBrakec(plr)
    local isAdmin, permissions = exports.TR_admin:isPlayerOnDuty()
    if not isAdmin then return end
    if not permissions.air then return end

    if not exports.TR_admin:isPlayerDeveloper() then
        if not exports.TR_jobs:canStartJob() then return end
        if exports.TR_hud:getRaceTime() then return end
        if getElementData(localPlayer, "inRace") then return end
    end

	toggleAirBrake()
end

function toggleAirBrake()
    air_brake = not air_brake or nil
    if air_brake then
        if isPedInVehicle ( getLocalPlayer( ) ) then
            local vehicle = getPedOccupiedVehicle( getLocalPlayer( ) )
            abx,aby,abz = getElementPosition(vehicle)
            Speed,AlingSpeedX,AlingSpeedY = 0,1,1
            OldX,OldY,OldZ = 0
            setElementCollisionsEnabled ( vehicle, false )
            setElementFrozen(vehicle,true)
            setElementAlpha(getLocalPlayer(),0)
            addEventHandler("onClientPreRender",root,putPlayerInPosition)

            logInfo.inVeh = true

        else
            abx,aby,abz = getElementPosition(localPlayer)
            Speed,AlingSpeedX,AlingSpeedY = 0,1,1
            OldX,OldY,OldZ = 0
            setElementCollisionsEnabled ( localPlayer, false )
            addEventHandler("onClientPreRender",root,putPlayerInPosition)

            logInfo.inVeh = false
        end

        local pos = Vector3(getElementPosition(localPlayer))
        logInfo.start = getZoneName(pos)
        logInfo.startPos = pos

        if isTimer(timerCheck) then killTimer(timerCheck) end
        timerCheck = setTimer(function()
            local isInJob = exports.TR_jobs:canStartJob()
            local isAdmin, permissions = exports.TR_admin:isPlayerOnDuty()
            if not isAdmin then
                if air_brake then
                    toggleAirBrake()
                end
                if isTimer(timerCheck) then killTimer(timerCheck) end

            elseif not isInJob then
                if not exports.TR_admin:isPlayerDeveloper() then
                    if air_brake then
                        toggleAirBrake()
                    end
                    if isTimer(timerCheck) then killTimer(timerCheck) end
                end

            elseif getElementData(localPlayer, "inRace") then
                if not exports.TR_admin:isPlayerDeveloper()  then
                    if air_brake then
                        toggleAirBrake()
                    end
                    if isTimer(timerCheck) then killTimer(timerCheck) end
                end
            end
        end, 1000, 0)
        setElementData(localPlayer, "onAir", true)

    else
        if isPedInVehicle ( getLocalPlayer( ) ) then
            local vehicle = getPedOccupiedVehicle( getLocalPlayer( ) )
            abx,aby,abz = nil
            setElementFrozen(vehicle,false)
            setElementCollisionsEnabled ( vehicle, true )
            setElementAlpha(getLocalPlayer(),255)
            removeEventHandler("onClientPreRender",root,putPlayerInPosition)
        else
            abx,aby,abz = nil
            setElementCollisionsEnabled ( localPlayer, true )
            removeEventHandler("onClientPreRender",root,putPlayerInPosition)
        end

        local isDev = exports.TR_admin:isPlayerDeveloper()
        local pos = Vector3(getElementPosition(localPlayer))
        local nearCollectible = exports.TR_collectibles:isNearCollectible()
        local dist = getDistanceBetweenPoints2D(pos.x, pos.y, logInfo.startPos.x, logInfo.startPos.y)
        if (dist > 20 or nearCollectible) and not isDev then
            triggerServerEvent("addAdminLogFlight", resourceRoot, logInfo.inVeh, logInfo.start, getZoneName(pos), dist, nearCollectible)
        end

        if isTimer(timerCheck) then killTimer(timerCheck) end

        setElementData(localPlayer, "onAir", false)
        logInfo = {}
    end
end
bindKey("0","down",toggleAirBrakec)