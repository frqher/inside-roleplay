local settings = {
    maxDistance = 150,

    shader = [[
        #include "files/shaders/mta-helper.fx"
        float tint_level = 0;
        sampler Sampler0 = sampler_state
        {
            Texture = (gTexture0);
        };
        float4 colorize(float4 tex : TEXCOORD0, float4 Position : POSITION, float4 Diffuse : COLOR0) : COLOR0
        {
            float4 output = tex2D(Sampler0, tex);
            output *= Diffuse;
            if(output.a < 0.99) {
                output = lerp(output,float4(0,0,0,1),(tint_level-15)/100);
            }
            return output;
        }
        technique VehicleTune
        {
            pass P0
            {
                PixelShader = compile ps_2_0 colorize();
            }
        }
    ]],
}

GlassTint = {}
GlassTint.__index = GlassTint

function GlassTint:create()
    local instance = {}
    setmetatable(instance, GlassTint)
    if instance:constructor() then
        return instance
    end
    return false
end

function GlassTint:constructor()
    self.objects = {}

    self.func = {}
    self.func.loadVehicles = function() self:loadVehicles() end

    self.textures = {}
    self.textures.glass = dxCreateTexture("files/images/glass.png", "dxt3", true, "clamp")

    addEventHandler("onClientPreRender", root, self.func.loadVehicles)
    return true
end

function GlassTint:createShaders(veh)
    if self.objects[veh].shader then return end

    local visualTuning = getElementData(veh, "visualTuning")
    if not visualTuning then return end
    if not visualTuning.glassTint then return end

    self.objects[veh].shader = dxCreateShader(settings.shader, 0, 0, false, "vehicle")
end

function GlassTint:updateShader(veh)
    self:createShaders(veh)
    if not self.objects[veh].shader then return end

    local visualTuning = getElementData(veh, "visualTuning")
    if not visualTuning then return end
    if visualTuning.glassTint ~= self.objects[veh].glassTint then
        self.objects[veh].glassTint = visualTuning.glassTint
        local value = self.objects[veh].glassTint
        if not value then value = 0 end
        dxSetShaderValue(self.objects[veh].shader, "tint_level", value * 110)
        engineApplyShaderToWorldTexture(self.objects[veh].shader, "vehiclegeneric256", veh)
        engineApplyShaderToWorldTexture(self.objects[veh].shader, "vehicleshatter128", veh)
    end
end

function GlassTint:onStreamIn(veh)
    if self.objects[veh] then self:updateShader(veh) return end

    local visualTuning = getElementData(veh, "visualTuning")
    self.objects[veh] = {
        glassTint = false,
    }

    self:updateShader(veh)
end

function GlassTint:onStreamOut(veh)
    if not self.objects[veh] then return end

    if isElement(self.objects[veh].shader) then destroyElement(self.objects[veh].shader) end
    self.objects[veh] = nil
end

function GlassTint:loadVehicles()
    local plrPos = Vector2(getElementPosition(localPlayer))
    for i, v in pairs(getElementsByType("vehicle", resourceRoot, true)) do
        if isElement(v) then
            if isElementStreamedIn(v) and getDistanceBetweenPoints2D(plrPos, Vector2(getElementPosition(v))) < settings.maxDistance then
                self:onStreamIn(v)
            else
                self:onStreamOut(v)
            end
        else
            self:onStreamOut(v)
        end
    end
end



GlassTint:create()