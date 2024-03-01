local sx, sy = guiGetScreenSize ()

local effectData = {
	color = {1,1,1,1},
	specularPower = 1.3,

	isMrt = dxGetStatus().VideoCardNumRenderTargets > 1 and true or false,

	shaders = {},
	objects = {},
}

function enableWallEffect()
	if effectData.created then return end
	if effectData.isMrt then
		effectData.RT = dxCreateRenderTarget(sx, sy, true)
		effectData.shaders.shader = dxCreateShader("files/shaders/post_edge.fx", 0, 0, true, "object")

		if not effectData.RT or not effectData.shaders.shader then
			effectData.isMrtEnabled = nil
			return
		else
			dxSetShaderValue(effectData.shaders.shader, "sTex0", effectData.RT)
			dxSetShaderValue(effectData.shaders.shader, "sRes", sx, sy)
			effectData.isMrtEnabled = true
		end
	else
		effectData.isMrtEnabled = nil
	end

	effectData.created = true
	addEventHandler("onClientPreRender", root, renderObjects, true, "high")
	addEventHandler("onClientHUDRender", root, renderHud)
end

function disableWallEffect()
	if not effectData.created then return end

	if isElement(effectData.RT) then destroyElement(effectData.RT) end
	if isElement(effectData.shaders.shader) then destroyElement(effectData.shaders.shader) end
	if isElement(effectData.shaders.shaderObject) then destroyElement(effectData.shaders.shaderObject) end

	effectData.created = nil
	effectData.shaders = {}

	removeEventHandler("onClientPreRender", root, renderObjects, true, "high")
	removeEventHandler("onClientHUDRender", root, renderHud)
end



function createWallEffectForObject(object, color)
	if not effectData.created then return end
	if effectData.objects[object] then return end

	if not effectData.shaders.shaderObject then
		if effectData.isMrt then
			effectData.shaders.shaderObject = dxCreateShader("files/shaders/ped_wall_mrt.fx", 0, 0, true, "object")
		else
			effectData.shaders.shaderObject = dxCreateShader("files/shaders/ped_wall.fx", 0, 0, true, "object")
		end

		if effectData.RT then dxSetShaderValue(effectData.shaders.shaderObject, "secondRT", effectData.RT) end
		dxSetShaderValue(effectData.shaders.shaderObject, "sColorizePed", color and color or effectData.color)
		dxSetShaderValue(effectData.shaders.shaderObject, "sSpecularPower", effectData.specularPower)
	end

	-- if not effectData.shaders.object then
	-- 	if effectData.RT then dxSetShaderValue(effectData.shaders.shaderObject, "secondRT", effectData.RT) end
	-- 	dxSetShaderValue(effectData.shaders.shaderObject, "sColorizePed", color and color or effectData.color)
	-- 	dxSetShaderValue(effectData.shaders.shaderObject, "sSpecularPower", effectData.specularPower)
	-- end

	applyShaderWallEffect(object)

	-- if getElementAlpha(thisPlayer) == 255 then setElementAlpha(thisPlayer, 254) end
end

function removeWallEffects()
	for i, v in pairs(effectData.objects) do
		if isElement(i) then
			engineRemoveShaderFromWorldTexture(effectData.shaders.shaderObject, "*", i)
		end
	end
	effectData.objects = {}
end

function applyShaderWallEffect(object)
	effectData.objects[object] = true

	engineApplyShaderToWorldTexture(effectData.shaders.shaderObject, "*", object)
end


--- RENDER ---
function renderObjects()
	if not effectData.created or not effectData.isMrtEnabled then return end
	dxSetRenderTarget(effectData.RT, true)
	dxSetRenderTarget()
end

function renderHud()
	if not effectData.created or not effectData.isMrtEnabled then return end
	dxDrawImage(0, 0, sx, sy, effectData.shaders.shader)
end