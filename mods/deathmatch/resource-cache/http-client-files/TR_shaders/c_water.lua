WaterShader = {}
WaterShader.__index = WaterShader

function WaterShader:create()
	local instance = {}
	setmetatable(instance, WaterShader)
	if instance:constructor() then
		return instance
	end
	return false
end

function WaterShader:constructor()
	self.shader = dxCreateShader("files/shaders/water.fx")

	self.textureVol = dxCreateTexture("files/images/smallnoise3d.dds")
	self.textureCube = dxCreateTexture("files/images/cube_env256.dds")

	dxSetShaderValue(self.shader, "sRandomTexture", self.textureVol)
	dxSetShaderValue(self.shader, "sReflectionTexture", self.textureCube)

	local r,g,b,a = getWaterColor()
	dxSetShaderValue(self.shader, "sWaterColor", r/255, g/255, b/255, a/255);
	engineApplyShaderToWorldTexture(self.shader, "waterclear256")

	if not self.shader or not self.textureVol or not self.textureCube then
		exports.TR_noti:create("Gölgelendirici başlatılamadı. Muhtemelen grafik kartınız bu tür gölgelendirici modelini desteklemiyor veya en son sürücüleri yüklemediniz.", "error", 10)
		self:destroy()
		return
	end

	return true
end

function WaterShader:destroy()
	if isElement(self.shader) then
		engineRemoveShaderFromWorldTexture(self.shader, "waterclear256")
		destroyElement(self.shader)
	end
	if isElement(self.textureVol) then destroyElement(self.textureVol) end
	if isElement(self.textureCube) then destroyElement(self.textureCube) end

	self = nil
end