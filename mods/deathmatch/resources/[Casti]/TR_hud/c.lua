function createGUI(loading, tutorial)
	if settings.createdGUI then return end
	settings.createdGUI = true

	settings.minimap = Minimap:create()
	settings.indicators = Indicators:create()
	settings.hud = HUD:create()

	settings.tick = getTickCount()
	settings.state = "opening"
	settings.enabled = state
	settings.currAlpha = settings.alpha

	updatePlayerHud()

	exports.TR_features:createFeatures()
	exports.TR_dashboard:createDashboard()
	exports.TR_jobPayments:startCheckingJobPayments()

	if loading then
		local int, dim = getElementInterior(localPlayer), getElementDimension(localPlayer)
		if int ~= 0 or dim ~= 0 then
			local location = exports.TR_interiors:getInteriorData()
			if location then setRadarCustomLocation("Binanın içi | "..(location.title), true) end
		end
	end

	if not loading then exports.TR_models:loadModels(tutorial) end
end
addEvent("createGUI", true)
addEventHandler("createGUI", root, createGUI)

function updatePlayerHud()
	settings.hud:updateData()
end
addEvent("updatePlayerHud", true)
addEventHandler("updatePlayerHud", root, updatePlayerHud)

function updateRadarZones()
	if not settings.minimap then return end
	settings.minimap:renderRadarTextures()
end
addEvent("updateRadarZones", true)
addEventHandler("updateRadarZones", root, updateRadarZones)



function getMapTextures(state)
	return settings.textures
end

-- Exports dasboard settings
function setHudBlocked(state)
	settings.blockHud = state
	exports.TR_dashboard:setDashboardResponseShader()
end

function setFpsBlocked(state)
	settings.blockFPS = state
	exports.TR_dashboard:setDashboardResponseShader()
end

function setNamesBlocked(state)
	settings.blockNames = state
	exports.TR_dashboard:setDashboardResponseShader()
end

function setGpsVoice(state)
	settings.gpsVoice = state
	exports.TR_dashboard:setDashboardResponseShader()
end

function setBlipsMapOrder(state)
	settings.minimapOrder = state
	exports.TR_dashboard:setDashboardResponseShader()
end

function setCharacterDescVisible(state)
	settings.characterDescVisible = state
	exports.TR_dashboard:setDashboardResponseShader()
end

function setWindRoseVisible(state)
	settings.windRoseVisible = state
	exports.TR_dashboard:setDashboardResponseShader()
end

function setHudRaceMode(type)
	settings.hudRaceMode = type
	settings.hudRaceTick = nil
	settings.hudRaceDetails = nil

	exports.TR_chat:showCustomChat(not type and true or false)
end

function startRaceTimer()
	settings.hudRaceTick = getTickCount()
end

function resetRaceTimer()
	settings.hudRaceTick = nil
end

function updateRaceDetails(details)
	settings.hudRaceDetails = details
end

function getRaceTime(type)
	if not settings.hudRaceTick then return false end
	return getTickCount() - settings.hudRaceTick
end


if getElementData(localPlayer, "characterUID") then createGUI(true) end