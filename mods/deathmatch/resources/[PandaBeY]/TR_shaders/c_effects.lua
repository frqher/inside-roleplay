-------------------------------------
--Resource: Screen FX v0.05        --
--Author: Ren712                   --
--Contact: knoblauch700@o2.pl      --
-------------------------------------

local scx, scy = guiGetScreenSize()
local orderPriority = "-1.8"

Settings = {}
Settings.var = {}
fxScreenEnable = false

----------------------------------------------------------------------------------------------------------------------------
-- Standard settings
----------------------------------------------------------------------------------------------------------------------------
function fxScreenSettings()

	v = Settings.var
	v.effectType = {}
	--Color
	v.effectType[1] = {}
	v.effectType[1].enabled = false
	v.effectType[1].fadeSpeed = 0.015
	v.effectType[1].streng = 0
	v.effectType[1].maxStreng = 0
	v.effectType[1].speed = 0.6
	v.effectType[1].choke = 1
	--Shake
	v.effectType[2] = {}
	v.effectType[2].enabled = false
	v.effectType[2].fadeSpeed = 0.015
	v.effectType[2].streng = 0
	v.effectType[2].maxStreng = 0
	v.effectType[2].speed = 2.0
	--Wobble
	v.effectType[3] = {}
	v.effectType[3].enabled = false
	v.effectType[3].fadeSpeed = 0.015
	v.effectType[3].streng = 0
	v.effectType[3].maxStreng = 0
	v.effectType[3].speed = 0.1
	v.effectType[3].size = 0.005
	v.effectType[3].density = 50
	--Esotropia
	v.effectType[4] = {}
	v.effectType[4].enabled = false
	v.effectType[4].fadeSpeed = 0.015
	v.effectType[4].streng = 0
	v.effectType[4].maxStreng = 0
	v.effectType[4].speed = 0.2
	v.effectType[4].intens = 0.1
	v.effectType[4].blur = 0.5
	v.effectType[4].choke = 0.85
	--Global
	v.maxAlpha = 255
end


----------------------------------------------------------------------------------------------------------------------------
-- onClientResourceStart
----------------------------------------------------------------------------------------------------------------------------
function enableScreenEffects()
	if fxScreenEnable then
		return true
	end
		-- Create things
		colorTex = dxCreateTexture("files/images/color.png")
    myScreenSource = dxCreateScreenSource( scx, scy)

    esotropiaHShader = dxCreateShader( "files/shaders/esotropiaH.fx" )
    esotropiaVShader = dxCreateShader( "files/shaders/esotropiaV.fx" )
		colorsShader = dxCreateShader( "files/shaders/colors.fx" )
		wobbleShader = dxCreateShader( "files/shaders/wobble.fx" )
		shakeShader = dxCreateShader( "files/shaders/shake.fx" )
		-- Check everything is ok
	-- Get list of all elements used
	effectParts = {
						colorTex,
						myScreenSource,
						esotropiaHShader,
						esotropiaVShader,
						colorsShader,
						wobbleShader,
						shakeShader,
					}

	-- Check list of all elements used
	bAllValid = true
	for _,part in ipairs(effectParts) do
		bAllValid = part and bAllValid
	end
	if not bAllValid then
		--outputChatBox( "Screen FX: The resource failed to start.", 255, 0, 0 )
		return false
	end
	fxScreenEnable = true
	fxScreenSettings()
	fxScreenTimer = setTimer (
			function ( )
				changeEffectIntensity()
			end, 100, 0 )
	--outputDebugString('Screen FX: Effects started.')
	return true
end


----------------------------------------------------------------------------------------------------------------------------
-- Switch effect off
----------------------------------------------------------------------------------------------------------------------------
function disableScreenEffects()
	if not fxScreenEnable then
		return
	end
	-- Destroy all shaders
	for _,part in ipairs(effectParts) do
		if part then
			destroyElement( part )
		end
	end

	effectParts = {}
	bAllValid = false
	RTPool.clear()
	killTimer( fxScreenTimer )
	fxScreenTimer = nil

	-- Flag effect as stopped
	fxScreenEnable = false
	--outputDebugString('Screen FX: Effects stopped.')
	return true
end

function changeEffectIntensity()
local v = Settings.var
	for i,this in ipairs(v.effectType) do
		v.effectType[i].streng = effectFade( v.effectType[i].enabled, v.effectType[i].streng, v.effectType[i].fadeSpeed, v.effectType[i].maxStreng )
	end
end

function effectFade( effectOn, value, eSpeed, eMax )
	local efVal = value
	if (( effectOn == true ) and (efVal < eMax )) then
		efVal = efVal + ( eSpeed )
	end
	if (( effectOn == false ) and (efVal > 0 )) then
		efVal = efVal - ( eSpeed )
	end
	if efVal <= 0 then
		efVal = 0
	end
	if efVal >= eMax then
		efVal = eMax
	end
	return efVal
end

----------------------------------------------------------------------------------------------------------------------------
-- onClientHUDRender
----------------------------------------------------------------------------------------------------------------------------
addEventHandler( "onClientHUDRender", root,
    function()
	if not fxScreenEnable or not bAllValid or not Settings.var then
		return
	end

	local v = Settings.var
	-- Reset render target pool
	RTPool.frameStart()
	-- Update screen
	dxUpdateScreenSource( myScreenSource, true )

	-- Start with screen
	local current = myScreenSource

	-- Apply all the effects, bouncing from one render target to another
	if v.effectType[4].streng > 0 then
		current = applyEsotropiaH( current, v.effectType[4].maxStreng * v.effectType[4].blur, 0, v.effectType[4].intens / 100, v.effectType[4].speed, v.effectType[4].choke, v.effectType[4].streng )
		current = applyEsotropiaV( current, v.effectType[4].maxStreng * v.effectType[4].blur, v.effectType[4].intens, 0, v.effectType[4].speed, v.effectType[4].choke, v.effectType[4].streng )
	end
	if v.effectType[3].streng > 0 then
		current = applyWobble( current, v.effectType[3].maxStreng * v.effectType[3].speed, v.effectType[3].size, v.effectType[3].density, v.effectType[3].streng )
	end
	if v.effectType[1].streng > 0 then
		current = applyColors( current, colorTex, v.effectType[1].speed, v.effectType[1].choke, v.effectType[1].streng )
	end
	if v.effectType[2].streng > 0 then
		current = applyShake( current, v.effectType[2].speed, v.effectType[2].maxStreng, v.effectType[2].streng )
	end
	-- When we're done, turn the render target back to default
	dxSetRenderTarget()

	local scrAlpha = math.max( v.effectType[4].streng, v.effectType[3].streng, v.effectType[1].streng, v.effectType[2].streng ) * 255
	local col = tocolor( 255, 255, 255, scrAlpha * v.maxAlpha/255 )
	if current and scrAlpha > 0 then
		dxDrawImage( 0, 0, scx, scy, current, 0, 0, 0, col )
	end
end
,true ,"low" .. orderPriority )

----------------------------------------------------------------------------------------------------------------------------
-- Apply the different stages
----------------------------------------------------------------------------------------------------------------------------

function applyShake( Src, wSpeed, wStrenght, strenght )
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused( mx, my )
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true )
	dxSetShaderValue( shakeShader, "TEX0", Src )
	dxSetShaderValue( shakeShader, "TEX0SIZE", mx,my )
	dxSetShaderValue( shakeShader, "wSpeed", wSpeed )
	dxSetShaderValue( shakeShader, "wStrenght", wStrenght * 0.1, wStrenght * 0.1 )
	dxSetShaderValue( shakeShader, "strenght", strenght )
	dxDrawImage( 0, 0, mx, my, shakeShader )
	return newRT
end

function applyWobble( Src, wSpeed, wSize, wDensity, strenght )
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused( mx, my )
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true )
	dxSetShaderValue( wobbleShader, "TEX0", Src )
	dxSetShaderValue( wobbleShader, "TEX0SIZE", mx,my )
	dxSetShaderValue( wobbleShader, "wSpeed", wSpeed )
	dxSetShaderValue( wobbleShader, "wSize", wSize )
	dxSetShaderValue( wobbleShader, "wDensity", wDensity )
	dxSetShaderValue( wobbleShader, "strenght", strenght, strenght )
	dxDrawImage( 0, 0, mx, my, wobbleShader )
	return newRT
end

function applyColors( Src, Col, pSpeed, pChoke, strenght)
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused( mx, my )
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true )
	dxSetShaderValue( colorsShader, "TEX0", Src )
	dxSetShaderValue( colorsShader, "TEX0SIZE", mx,my )
	dxSetShaderValue( colorsShader, "TEX1", Col )
	dxSetShaderValue( colorsShader, "pendulumSpeed", pSpeed )
	dxSetShaderValue( colorsShader, "pendulumChoke", pChoke )
	dxSetShaderValue( colorsShader, "strenght", strenght )
	dxDrawImage( 0, 0, mx, my, colorsShader )
	return newRT
end

function applyEsotropiaH( Src, blur, propX, propY, pSpeed, pChoke, strenght )
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused( mx, my )
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true )
    local prop = { propX, propY }
	dxSetShaderValue( esotropiaHShader, "TEX0", Src )
	dxSetShaderValue( esotropiaHShader, "TEX0SIZE", mx,my )
	dxSetShaderValue( esotropiaHShader, "pendulumSpeed", pSpeed )
	dxSetShaderValue( esotropiaHShader, "pendulumChoke", pChoke )
	dxSetShaderValue( esotropiaHShader, "Prop", prop )
	dxSetShaderValue( esotropiaHShader, "sBlur", blur )
	dxSetShaderValue( esotropiaHShader, "strenght", strenght )
	dxDrawImage( 0, 0, mx, my, esotropiaHShader )
	return newRT
end

function applyEsotropiaV( Src, blur, propX, propY, pSpeed, pChoke, strenght )
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool.GetUnused( mx, my )
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true )
    local prop = { propX, propY }
	dxSetShaderValue( esotropiaVShader, "TEX0", Src )
	dxSetShaderValue( esotropiaVShader, "TEX0SIZE", mx,my )
	dxSetShaderValue( esotropiaVShader, "pendulumSpeed", pSpeed )
	dxSetShaderValue( esotropiaVShader, "pendulumChoke", pChoke )
	dxSetShaderValue( esotropiaVShader, "Prop", prop )
	dxSetShaderValue( esotropiaVShader, "sBlur", blur )
	dxSetShaderValue( esotropiaVShader, "strenght", strenght )
	dxDrawImage( 0, 0, mx,my, esotropiaVShader )
	return newRT
end

enableScreenEffects()

function enableEffect(effectNo,isEnabled)
	if not fxScreenEnable then return false end
	if (type(effectNo)=="number" and type(isEnabled)=='boolean') then
		if (effectNo >= 1 and effectNo <= 4) then
			local v = Settings.var
			v.effectType[math.floor(effectNo)].enabled = isEnabled

			return true
		else
			return false
		end
	else
		return false
	end
end

function setEffectMaxStrength(effectNo,maxStreng,add)
	if not fxScreenEnable then return false end
	if (type(effectNo)=='number' and type(maxStreng)=='number') then
		if (maxStreng > 1 or maxStreng < 0) then return false end
		if (effectNo >= 1 and effectNo <= 4) then
			local v = Settings.var
			local newValue = add and math.min(v.effectType[math.floor(effectNo)].maxStreng + add, 1) or maxStreng
			if newValue == v.effectType[math.floor(effectNo)].maxStreng then return end

			v.effectType[math.floor(effectNo)].maxStreng = newValue

			if math.floor(effectNo) == 4 and v.effectType[math.floor(effectNo)].maxStreng > 0.4 then
				exports.TR_hud:setPlayerDrunk(true)

			elseif math.floor(effectNo) == 4 and v.effectType[math.floor(effectNo)].maxStreng < 0.4 then
				exports.TR_hud:setPlayerDrunk(false)
			end
			return true
		else
			return false
		end
	else
		return false
	end
end