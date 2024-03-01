function setPlayerCamHackEnabled(plr, state)
	return triggerClientEvent(plr, "onClientEnableCamMode", root, state)
end

function setPlayerCamHackDisabled(plr)
	return triggerClientEvent(plr, "onClientDisableCamMode", root)
end

function onStop()
	for i, plr in pairs(getElementsByType("player")) do
		if getElementData(plr, "isPlayerInCamHackMode") then
			setElementAlpha(plr, 255)
			setElementFrozen(plr, false)
		end
	end
end
addEventHandler("onResourceStop", resourceRoot, onStop)

function startCameraScript(...)
    if isPedInVehicle(source) then
		if getPedOccupiedVehicle(source) then
			exports.TR_noti:create(source, "Film kamerasını araçta ateşleyemezsiniz.", "error")
			return
		end
	else
		if getElementData(source, "isPlayerInCamHackMode") then
			setElementAlpha(source, 255)
			setPlayerCamHackDisabled(source)
			setElementFrozen(source, false)
		else
			setElementAlpha(source, 0 )
			setPlayerCamHackEnabled(source, true)
			setElementFrozen(source, true)
		end
	end
end
addEvent("startCameraScript", true)
addEventHandler("startCameraScript", root, startCameraScript)
exports.TR_chat:addCommand("camera", "startCameraScript")