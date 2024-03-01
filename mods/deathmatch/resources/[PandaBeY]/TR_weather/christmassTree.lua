local settings = {
    switchTime = 600,

    lights = 12,
    lightsOn = 4,

    shader = [[
        float Brightness = 0.6;
        float4 sLightColor = float4(1,1,1,1);
        texture sTex0;

        sampler Sampler0 = sampler_state
        {
            Texture = (sTex0);
        };

        float4 PixelShaderPS(float4 TexCoord : TEXCOORD0, float4 Position : POSITION, float4 Diffuse : COLOR0) : COLOR0
        {
            float4 tex = tex2D(Sampler0, TexCoord);
            float4 output = saturate(tex * sLightColor);
            output.r *= 0.45 * Brightness;
            output.g *= 0.45 * Brightness;
            output.b *= 0.45 * Brightness;
            return output;
        }

        technique shader_tex_replace
        {
            pass P0
            {
                PixelShader = compile ps_2_0 PixelShaderPS();
                LightEnable[1] = false;
                LightEnable[2] = false;
                LightEnable[3] = false;
                LightEnable[4] = false;
            }
        }

        technique fallback
        {
            pass P0
            {
            }
        }
    ]],
}

ChristmassTree = {}
ChristmassTree.__index = ChristmassTree

function ChristmassTree:create()
    local instance = {}
    setmetatable(instance, ChristmassTree)
    if instance:constructor() then
        return instance
    end
    return false
end

function ChristmassTree:constructor()
    self.shaders = {}
    self.textures = {}
    self.lightState = 1

    self.func = {}
    self.func.switchLights = function() self:switchLights() end

    setTimer(self.func.switchLights, settings.switchTime, 0)

    self:createShaders()
    return true
end

function ChristmassTree:createShaders()
    self.shaders.star = dxCreateShader(settings.shader, 0, 0, false, "object")
    self.textures.star = dxCreateTexture("files/images/goldstar.png", "dxt3", false, "clamp")
    dxSetShaderValue(self.shaders.star, "sTex0", self.textures.star)
    dxSetShaderValue(self.shaders.star, "Brightness", 1.4)
    engineApplyShaderToWorldTexture(self.shaders.star, "goldplated1")

    for i = 1, settings.lights do
        self.shaders[i] = dxCreateShader(settings.shader, 0, 0, false, "object")
        self.textures[i] = dxCreateTexture(string.format("files/images/lights/light%d.png", i), "dxt3", false, "clamp")
        dxSetShaderValue(self.shaders[i], "sTex0", self.textures[i])
        engineApplyShaderToWorldTexture(self.shaders[i], string.format("light%d", i))
    end
end

function ChristmassTree:switchLights()
    for i = 1, settings.lights do
        engineApplyShaderToWorldTexture(self.shaders[i], string.format("light%d", i))
    end

    local spacer = settings.lights/settings.lightsOn
    for i = 1, settings.lightsOn do
        local lampID = self.lightState + (spacer * i)
        if lampID > settings.lights then lampID = lampID - settings.lights end
        engineRemoveShaderFromWorldTexture(self.shaders[lampID], string.format("light%d", lampID))
    end

    self.lightState = self.lightState + 1
    if self.lightState > settings.lights then self.lightState = 1 end
end

function createChristmassTrees()
    if settings.tree then return end
    settings.tree = ChristmassTree:create()
end
createChristmassTrees()