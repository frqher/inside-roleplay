--
-- c_detail.lua
--

local renderTarget = {RTColor = nil, RTDepth = nil, RTNormal = nil, isOn = false, distFade = {100, 80}}
local scx, scy = guiGetScreenSize ()
local enableNormal = false

----------------------------------------------------------------
-- enableDetail
----------------------------------------------------------------
function enableDetail()
	if bEffectEnabled then return end
	-- Load textures
	detail22Texture = dxCreateTexture('files/images/details/detail22.png', "dxt3")
	detail58Texture = dxCreateTexture('files/images/details/detail58.png', "dxt3")
	detail68Texture = dxCreateTexture('files/images/details/detail68.png', "dxt1")
	detail63Texture = dxCreateTexture('files/images/details/detail63.png', "dxt3")
	dirtyTexture = dxCreateTexture('files/images/details/dirty.png', "dxt3")
	detail04Texture = dxCreateTexture('files/images/details/detail04.png', "dxt3")
	detail29Texture = dxCreateTexture('files/images/details/detail29.png', "dxt3")
	detail55Texture = dxCreateTexture('files/images/details/detail55.png', "dxt3")
	detail35TTexture = dxCreateTexture('files/images/details/detail35T.png', "dxt3")

	-- Check list of all elements used
	bAllValid = true

	-- Create shaders
	brickWallShader, tec = getBrickWallShader()
	if brickWallShader then
		-- Only create the rest if the first one is OK
		grassShader = getGrassShader()
		roadShader = getRoadShader()
		road2Shader = getRoad2Shader()
		paveDirtyShader = getPaveDirtyShader()
		paveStretchShader = getPaveStretchShader()
		barkShader = getBarkShader()
		rockShader = getRockShader()
		mudShader = getMudShader()
		concreteShader = getBrickWallShader()	-- TODO make this better
		sandShader = getMudShader()				-- TODO make this better
	end

	-- Get list of all elements used
	effectParts = {
						detail22Texture, detail58Texture, detail68Texture, detail63Texture, dirtyTexture,
						detail04Texture, detail29Texture, detail55Texture, detail35TTexture,
						brickWallShader, grassShader, roadShader, road2Shader, paveDirtyShader,
						paveStretchShader, barkShader, rockShader, mudShader,
						concreteShader, sandShader
					}


	for _,part in ipairs(effectParts) do
		bAllValid = part and bAllValid
	end

	bEffectEnabled = true

	if not bAllValid then
		exports.TR_noti:create("Gölgelendirici başlatılamadı. Muhtemelen grafik kartınız bu tür gölgelendirici modelini desteklemiyor veya en son sürücüleri yüklemediniz.", "error", 10)
		disableDetail()
	else
		engineApplyShaderToWorldTexture ( roadShader, "*road*" )
		engineApplyShaderToWorldTexture ( roadShader, "*tar*" )
		engineRemoveShaderFromWorldTexture ( roadShader, "coronastar" )
		engineApplyShaderToWorldTexture ( roadShader, "*asphalt*" )
		engineApplyShaderToWorldTexture ( roadShader, "*freeway*" )
		engineApplyShaderToWorldTexture ( concreteShader, "*wall*" )
		engineApplyShaderToWorldTexture ( concreteShader, "*floor*" )
		engineApplyShaderToWorldTexture ( concreteShader, "*bridge*" )
		engineApplyShaderToWorldTexture ( concreteShader, "*conc*" )
		engineApplyShaderToWorldTexture ( concreteShader, "*drain*" )
		engineApplyShaderToWorldTexture ( paveDirtyShader, "*walk*" )
		engineApplyShaderToWorldTexture ( paveDirtyShader, "*pave*" )
		engineApplyShaderToWorldTexture ( paveDirtyShader, "*cross*" )

		engineApplyShaderToWorldTexture ( mudShader, "*mud*" )
		engineApplyShaderToWorldTexture ( mudShader, "*dirt*" )
		engineApplyShaderToWorldTexture ( rockShader, "*rock*" )
		engineApplyShaderToWorldTexture ( rockShader, "*stone*" )
		engineApplyShaderToWorldTexture ( grassShader, "*grass*" )
		engineApplyShaderToWorldTexture ( grassShader, "desertgryard256" )	-- grass

		engineApplyShaderToWorldTexture ( sandShader, "*sand*" )
		engineApplyShaderToWorldTexture ( barkShader, "*leave*" )
		engineApplyShaderToWorldTexture ( barkShader, "*log*" )
		engineApplyShaderToWorldTexture ( barkShader, "*bark*" )

		-- Roads
		engineApplyShaderToWorldTexture ( roadShader, "*carpark*" )
		engineApplyShaderToWorldTexture ( road2Shader, "*hiway*" )
		engineApplyShaderToWorldTexture ( roadShader, "*junction*" )
		engineApplyShaderToWorldTexture ( paveStretchShader, "snpedtest*" )

		-- Pavement
		engineApplyShaderToWorldTexture ( paveStretchShader, "sidelatino*" )
		engineApplyShaderToWorldTexture ( paveStretchShader, "sjmhoodlawn41" )

		-- Remove detail from LOD models etc.
		for i,part in ipairs(effectParts) do
			if getElementType(part) == "shader" then
				engineRemoveShaderFromWorldTexture ( part, "tx*" )
				engineRemoveShaderFromWorldTexture ( part, "lod*" )
			end
		end
	end

end

----------------------------------------------------------------
-- disableDetail
----------------------------------------------------------------
function disableDetail()
	if not bEffectEnabled then return end

	-- Destroy all parts
	for _,part in ipairs(effectParts) do
		if part then
			destroyElement( part )
		end
	end
	effectParts = {}
	bAllValid = false

	-- Flag effect as stopped
	bEffectEnabled = false
end


----------------------------------------------------------------
-- All the shaders
----------------------------------------------------------------
function getBrickWallShader()
	return getMakeShader( getBrickWallSettings () )
end

function getGrassShader()
	return getMakeShader( getGrassSettings () )
end

function getRoadShader()
	return getMakeShader( getRoadSettings () )
end

function getRoad2Shader()
	return getMakeShader( getRoad2Settings () )
end

function getPaveDirtyShader()
	return getMakeShader( getPaveDirtySettings () )
end

function getPaveStretchShader()
	return getMakeShader( getPaveStretchSettings () )
end

function getBarkShader()
	return getMakeShader( getBarkSettings () )
end

function getRockShader()
	return getMakeShader( getRockSettings () )
end

function getMudShader()
	return getMakeShader( getMudSettings () )
end

function getMakeShader(v)
	--  Create shader with a draw range of 100 units
	local shader, tec = nil, nil
	if renderTarget.isOn then
		if enableNormal then
			shader,tec = dxCreateShader ( "files/shaders/detail_dr_n.fx", 2, renderTarget.distFade[1] )
		else
			shader,tec = dxCreateShader ( "files/shaders/detail_dr.fx", 2, renderTarget.distFade[1] )
		end
	else
		shader,tec = dxCreateShader ( "files/shaders/detail.fx", 1, 100 )
	end

	if shader then
		dxSetShaderValue( shader, "sDetailTexture", v.texture )
		dxSetShaderValue( shader, "sDetailScale", v.detailScale )
		dxSetShaderValue( shader, "sFadeStart", v.sFadeStart )
		dxSetShaderValue( shader, "sFadeEnd", v.sFadeEnd )
		dxSetShaderValue( shader, "sStrength", v.sStrength )
		dxSetShaderValue( shader, "sAnisotropy", v.sAnisotropy )
		if renderTarget.isOn then
			dxSetShaderValue( shader, "sHalfPixel", 1/(scx * 2), 1/(scy * 2) )
			dxSetShaderValue( shader, "ColorRT", renderTarget.RTColor )
			dxSetShaderValue( shader, "DepthRT", renderTarget.RTDepth )
			dxSetShaderValue( shader, "NormalRT", renderTarget.RTNormal )
		end
	end
	return shader,tec
end


-- brick wall type thing
---------------------------------
function getBrickWallSettings ()
	local v = {}
	v.texture=detail22Texture
	v.detailScale=3
	v.sFadeStart=60
	v.sFadeEnd=math.min(100, renderTarget.distFade[1])
	v.sStrength=0.6
	v.sAnisotropy=1
	return v
end
---------------------------------

-- grass
---------------------------------
function getGrassSettings ()
	local v = {}
	v.texture=detail58Texture
	v.detailScale=2
	v.sFadeStart=60
	v.sFadeEnd=math.min(100, renderTarget.distFade[1])
	v.sStrength=0.6
	v.sAnisotropy=1
	return v
end
---------------------------------

-- road
---------------------------------
function getRoadSettings ()
	local v = {}
	v.texture=detail68Texture
	v.detailScale=1
	v.sFadeStart=60
	v.sFadeEnd=math.min(100, renderTarget.distFade[1])
	v.sStrength=0.6
	v.sAnisotropy=1
	return v
end
---------------------------------

-- road2
---------------------------------
function getRoad2Settings ()
	local v = {}
	v.texture=detail63Texture
	v.detailScale=1
	v.sFadeStart=math.min(90, renderTarget.distFade[2])
	v.sFadeEnd=math.min(100, renderTarget.distFade[1])
	v.sStrength=0.7
	v.sAnisotropy=0.9
	return v
end
---------------------------------

-- dirty pave
---------------------------------
function getPaveDirtySettings ()
	local v = {}
	v.texture=dirtyTexture
	v.detailScale=1
	v.sFadeStart=math.min(60, renderTarget.distFade[2])
	v.sFadeEnd=math.min(100, renderTarget.distFade[1])
	v.sStrength=0.4
	v.sAnisotropy=1
	return v
end
---------------------------------

-- stretch pave
---------------------------------
function getPaveStretchSettings ()
	local v = {}
	v.texture=detail04Texture
	v.detailScale=1
	v.sFadeStart=math.min(80, renderTarget.distFade[2])
	v.sFadeEnd=math.min(100, renderTarget.distFade[1])
	v.sStrength=0.3
	v.sAnisotropy=1
	return v
end
---------------------------------

-- tree bark
---------------------------------
function getBarkSettings ()
	local v = {}
	v.texture=detail29Texture
	v.detailScale=1
	v.sFadeStart=math.min(80, renderTarget.distFade[2])
	v.sFadeEnd=math.min(100, renderTarget.distFade[1])
	v.sStrength=0.6
	v.sAnisotropy=1
	return v
end
---------------------------------

-- rock
---------------------------------
function getRockSettings ()
	local v = {}
	v.texture=detail55Texture
	v.detailScale=1
	v.sFadeStart=math.min(80, renderTarget.distFade[2])
	v.sFadeEnd=math.min(100, renderTarget.distFade[1])
	v.sStrength=0.5
	v.sAnisotropy=1
	return v
end
---------------------------------

-- mud
---------------------------------
function getMudSettings ()
	local v = {}
	v.texture=detail35TTexture
	v.detailScale=2
	v.sFadeStart=math.min(80, renderTarget.distFade[2])
	v.sFadeEnd=math.min(100, renderTarget.distFade[1])
	v.sStrength=0.6
	v.sAnisotropy=1
	return v
end

----------------------------------------------------------------------------------------------------------------------------
-- onClientResourceStart/Stop
----------------------------------------------------------------------------------------------------------------------------
addEventHandler ( "onClientResourceStart", root, function(startedRes)
	switchDREffect(getResourceName(startedRes), true)
end
)

addEventHandler ( "onClientResourceStop", root, function(stoppedRes)
	switchDREffect(getResourceName(stoppedRes), false)
end
)

function switchDREffect(resName, isStarted)
	if isStarted then
		if resName == "dr_rendertarget" then
			renderTarget.isOn = getElementData ( localPlayer, "dr_renderTarget.on", false )
			if renderTarget.isOn then
				renderTarget.RTColor, renderTarget.RTDepth, renderTarget.RTNormal = exports.dr_rendertarget:getRenderTargets()
				renderTarget.distFade[1], renderTarget.distFade[2] = exports.dr_rendertarget:getShaderDistanceFade()
			end
			if renderTarget.RTColor and renderTarget.RTDepth and renderTarget.RTNormal then
				if bEffectEnabled then
					disableDetail()
					enableDetail()
				end
				renderTarget.isOn = true
			end
		end
	else
		if not renderTarget.isOn then return end
		if resName == "dr_rendertarget" then
			if bEffectEnabled then
				disableDetail()
				renderTarget.isOn = false
				enableDetail()
			end
		end
	end
end

addEventHandler ( "onClientResourceStart", resourceRoot, function()
	renderTarget.isOn = getElementData ( localPlayer, "dr_renderTarget.on", false )
	if renderTarget.isOn then
		renderTarget.RTColor, renderTarget.RTDepth, renderTarget.RTNormal = exports.dr_rendertarget:getRenderTargets()
		renderTarget.distFade[1], renderTarget.distFade[2] = exports.dr_rendertarget:getShaderDistanceFade()
		if renderTarget.RTColor and renderTarget.RTDepth and renderTarget.RTNormal then
			renderTarget.isOn = true
		end
	end
	triggerEvent( "onClientSwitchDetail", resourceRoot, true )
end
)

addEvent( "switchDR_renderTarget", true )
addEventHandler( "switchDR_renderTarget", root, function(isOn) switchDREffect("dr_rendertarget", isOn) end)