local texBall = dxCreateTexture ( "textures/cubebox.dds" )
local shWrd,shVeh,shObj,objBall
local isLightBallOn

-- position of your light ball
local objPos = { 440.20001220703, -1877.8000488281, 12.39999961853 }
local objInt = 0 --interior

local sBallSize = 0 -- size of the ball
local sSpecularPower = 4 -- specular power
local gRotAngle = { 2, 1, 0.5 } -- rotation speed (yaw , roll ,pitch)
local gSelfShadow = 0.35 -- projection normal - the higher value, the more the ball texture "sticks" to the surfaces
local isFakeBump = true -- draw fake bump maps
local maxEffectSwitch = 160 -- max distance between camera and ballCoords form which the effect is switched off
local maxDistance = 160 -- the shader will be applied to textures nearer than maxDistance only
local gLightFade = { 150, 110, 55, 33 }  -- draw distance parameters (max_fade_effect,min_fade_effect,max_fade_light,min_fade_light)

local DBTimerUpdate = 200 -- the effect update time interval

---------------------------------------------------------------------------------------------------------------------------------

local function createSceneLight(pos)
	createMarker(pos, "corona", 1.5, 255, 255, 255, 255)
end

local function createBall( pcam_x, pcam_y, pcam_z, intId )
	objBall = createObject( 2114, pcam_x, pcam_y, pcam_z, 0, 0, 0, true )
	setElementInterior ( objBall, intId )
	setElementFrozen(objBall,true)
	setElementCollisionsEnabled ( objBall, false )
	return objBall
end

local function destroyBall( objBall )
	local isDone = destroyElement( objBall )
	objBall = nil
	return isDone
end

local function createSound( soundStr, pcam_x, pcam_y, pcam_z, s_max_dist, s_min_dist, s_vol )
	local myMusic = playSound3D(soundStr, pcam_x, pcam_y, pcam_z,true)
	setSoundMaxDistance( myMusic, s_max_dist )
	setSoundMinDistance ( myMusic, s_min_dist )
	setSoundVolume ( myMusic, s_vol )
	return myMusic
end

addEventHandler("onClientResourceStart", getResourceRootElement( getThisResource()), function()
	if CoordTimer then return end
	CoordTimer = setTimer(	function()
		if isElementStreamedIn(objBall) and isLightBallOn==true then
			dxSetShaderValue( shWrd, "sLightPosition",objPos )
			dxSetShaderValue( shVeh, "sLightPosition",objPos )
			dxSetShaderValue( shWrd, "isStr", true )
			dxSetShaderValue( shVeh, "isStr", true )
		else
			--outputChatBox('The object is not streamed in')
		end
	end
	,DBTimerUpdate,0 )
end
)

---------------------------------------------------------------------------------------------------------------------------------

-- a list of textures to be removed from applied texture list
local removeList = {
						"",							-- unnamed
						"basketball2","skybox_tex",	"flashlight_*",     -- other
						"muzzle_texture*",								-- guns
						"font*","radar*","sitem16","snipercrosshair",	-- hud
						"siterocket","cameracrosshair",					-- hud
						"fireba*","wjet6",								-- flame
						"vehiclegeneric256","vehicleshatter128", 		-- vehicles
						"*shad*",										-- shadows
						"coronastar","coronamoon","coronaringa",
						"coronaheadlightline",							-- coronas
						"lunar",										-- moon
						"tx*",											-- grass effect
						"lod*",										-- lod models
						"cj_w_grad",									-- checkpoint texture
						"*cloud*",										-- clouds
						"*smoke*",										-- smoke
						"sphere_cj",									-- nitro heat haze mask
						"particle*",									-- particle skid and maybe others
						"water*","newaterfal1_256",
						"boatwake*","splash_up","carsplash_*",			-- splash
						"gensplash","wjet4","bubbles","blood*",			-- splash
						"fist","*icon","headlight*",
						"unnamed",
						"sl_dtwinlights*","nitwin01_la","sfnite*","shad_exp",
						"vgsn_nl_strip","blueshade*",
					}

local reApplyList = {
					"ws_tunnelwall2smoked", "shadover_law",
					"greenshade_64", "greenshade2_64", "venshade*",
					"blueshade2_64",
					}

local lights = {
	Vector3(448.7, -1869.9, 10.6),
	Vector3(445.0, -1876.7, 10.8),
	Vector3(433.4, -1873.7, 10.6),
	Vector3(434.5, -1875.9, 10.6),
	Vector3(448.1, -1874.4, 10.6),
	Vector3(441.2, -1876.2, 10.7),
	Vector3(433.2, -1870.4, 10.5),
	Vector3(438.1, -1875.9, 10.6),
}

local smokes = {
	Vector3(451.20001, -1878.2, 4.5),
	Vector3(431.29999, -1880.3, 4.5),
}

local spaghetti = {
	Vector3(446.89999, -1877.9, 12.2),
	Vector3(438.89999, -1877.9, 12.2),
}

local speakers = {
	Vector3(428.3616027832, -1868.171875, 5.5462217330933),
	Vector3(452.6946411132, -1867.756469, 5.5462217330933),
}

---------------------------------------------------------------------------------------------------------------------------------

local function createDiscoballEffect()
	shWrd = dxCreateShader ( "fx/shader_light.fx" ,1 , maxDistance,true, "world,object,ped" )
	shObj = dxCreateShader ( "fx/shader_ball.fx" ,1 , maxDistance,false, "object" )
	shVeh = dxCreateShader ( "fx/shader_light.fx" ,1 , maxDistance,true, "vehicle" )
	-- apply shader
	if not shWrd or not shVeh or not shObj then
		--outputChatBox('Could not start the disco_ball effect!')
		return false
	else
		--outputChatBox('starting the discoball shader...')
	end
	-- world
	dxSetShaderValue ( shWrd, "gBallTexture", texBall )
	dxSetShaderValue ( shWrd, "gRotAngle", gRotAngle )
	-- is veh (is the texture a vehicle texture) leave as it is
	dxSetShaderValue ( shWrd, "isVeh", false )
	dxSetShaderValue ( shWrd, "gLightFade", gLightFade )
	-- obscures the vertexes that are not meant to be seen (useless when applying to rotated objects)
	dxSetShaderValue ( shWrd, "gSelfShad", gSelfShadow )
	dxSetShaderValue ( shWrd, "isFakeBump", isFakeBump )
	-- vehicle
	dxSetShaderValue ( shVeh, "gBallTexture", texBall )
	dxSetShaderValue ( shVeh, "gRotAngle", gRotAngle )
	dxSetShaderValue ( shVeh, "isVeh", true)
	dxSetShaderValue ( shVeh, "gLightFade", gLightFade )
	dxSetShaderValue ( shVeh, "gSelfShad", gSelfShadow )
	dxSetShaderValue ( shVeh, "isFakeBump", false )
	-- ball object
	dxSetShaderValue ( shObj, "gBallTexture", texBall )
	dxSetShaderValue ( shObj, "gRotAngle", gRotAngle )
	dxSetShaderValue ( shObj, "sSpecularPower", sSpecularPower )
	dxSetShaderValue ( shObj, "sBallSize", sBallSize )

	-- creates a ball object
	if not objBall then
		createBall( objPos[1], objPos[2], objPos[3], objInt )
	end
	engineApplyShaderToWorldTexture ( shObj, "*",objBall)
	-- you might apply this effect to an entity (a model, a group of models maybe) because of framerate issues on stone-age graphics cards
	-- if you apply the shader to an entity - have in mind that you have to add the entity name here (after.. the "*",entity_name)
	engineApplyShaderToWorldTexture ( shWrd, "*" )

	for _,removeMatch in ipairs(removeList) do
		-- if you apply the shader to an entity - have in mind that you have to add the entity name here (after.. the "*",entity_name)
		engineRemoveShaderFromWorldTexture ( shWrd, removeMatch )
	end
	for _,applyMatch in ipairs(reApplyList) do
		engineApplyShaderToWorldTexture ( shWrd, applyMatch )
	end
	engineApplyShaderToWorldTexture ( shVeh, "*" )
	engineRemoveShaderFromWorldTexture ( shVeh, "unnamed" )

	for i, v in pairs(lights) do
		createSceneLight(v)
	end

	for i, v in pairs(smokes) do
		createObject(2780, v)
	end

	for i, v in pairs(spaghetti) do
		createObject(18102, v)
	end

	for i, v in pairs(speakers) do
		createSpeaker(v)
	end

	return true
end

engineSetModelLODDistance(14391, 3000)

local function destroyDiscoballEffect()
	if shWrd then
		engineRemoveShaderFromWorldTexture ( shWrd, "*" )
		destroyElement(shWrd)
		shWrd=nil
	end
	if shVeh then
		engineRemoveShaderFromWorldTexture ( shVeh, "*" )
		destroyElement(shVeh)
		shVeh=nil
	end
	if shObj then
		engineRemoveShaderFromWorldTexture ( shObj, "*",objBall )
		destroyElement(shObj)
		shObj=nil
	end
	if not shWrd then
	--outputChatBox('stoping the discoball shader...')
		return true
	else
		return false
	end
end

function createSpeaker(pos)
	local sound = playSound3D("http://ice.onestreaming.com/athenspartyrnb", pos)
	setSoundMinDistance(sound, 50)
	setSoundMaxDistance(sound, 100)
end


--isBallStreamedIn()
addEventHandler("onClientResourceStart", getResourceRootElement( getThisResource()), function()
	if DBenTimer then return end
	DBenTimer = setTimer(	function()
		local cam_x, cam_y, cam_z, _, _, _ = getCameraMatrix()
		local getDist = getDistanceBetweenPoints3D(cam_x,cam_y,cam_z,objPos[1],objPos[2],objPos[3])
		if isElementStreamedIn(objBall) and not shVeh and not shWrd and isLightBallOn==false and getDist<=maxEffectSwitch then
			if createDiscoballEffect() then
				dxSetShaderValue(shWrd,"isStr",true)
				dxSetShaderValue(shVeh,"isStr",true)
				isLightBallOn=true;
				--outputChatBox('Streaming in a lightball')
			end
		end
		if (not isElementStreamedIn(objBall) or getDist>maxEffectSwitch) and shVeh and shWrd and isLightBallOn==true then
			dxSetShaderValue(shWrd,"isStr",false)
			dxSetShaderValue(shVeh,"isStr",false)
			if destroyDiscoballEffect() then
				isLightBallOn=false;
				--outputChatBox('Streaming out a lightball')
			end
		end
	end
	,DBTimerUpdate,0 )

	setTimer(switchLights, 500, 0)
end
)

addEventHandler("onClientResourceStart", getResourceRootElement( getThisResource()), function()
	isLightBallOn=true
	local ver = getVersion ().sortable
	local build = string.sub( ver, 9, 13 )

	if build<"04938" or ver < "1.3.1" then
		return
	end

	createDiscoballEffect()
end)

addEventHandler("onClientResourceStop", getResourceRootElement( getThisResource()), function()
	if objBall then destroyBall( objBall ) objBall = nil end
	if DBBlip then destroyElement( DBBlip ) DBBlip = nil end
	destroyDiscoballEffect()
	if texBall then destroyElement( texBall ) texBall = nil end
end
)

function switchLights()
	for i, v in pairs(getElementsByType("marker", resourceRoot, true)) do
		setMarkerColor(v, math.random(0, 255), math.random(0, 255), math.random(0, 255))
	end
end