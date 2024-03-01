local settings = {
    path = ":TR_interiorsBuilder/files/textures",

    textureNames = {
        [1868] = {"floor"},
        [1870] = {"floor"},
        [1866] = {"wall1", "wall2"},
        [1902] = {"wall1", "wall2"},
        [1867] = {"wall1", "wall2"},
        [1924] = {"wall1", "wall2"},
    },

    shader = [[
        texture gTexture;
        float XtoOriginal = 0.45;
        float Brightness = 1;

        sampler TextureSampler = sampler_state
        {
            Texture = <gTexture>;
        };

        float4 SetShaderBrightness(float2 TextureCoordinate : TEXCOORD0) : COLOR0
        {
            float4 color = tex2D(TextureSampler, TextureCoordinate);

            color.r *= 0.45 * Brightness;
            color.g *= 0.45 * Brightness;
            color.b *= 0.45 * Brightness;

            return color;
        }

        technique TexReplace
        {
            pass Pass1
            {
                PixelShader = compile ps_2_0 SetShaderBrightness();
                Texture[0] = gTexture;
                LightEnable[1] = false;
                LightEnable[2] = false;
                LightEnable[3] = false;
                LightEnable[4] = false;
            }
        }
    ]],
}

TextureManager = {}
TextureManager.__index = TextureManager

function TextureManager:create()
    local instance = {}
    setmetatable(instance, TextureManager)
    if instance:constructor() then
        return instance
    end
    return false
end

function TextureManager:constructor()
    self.textures = {}
    self.objects = {}

    self.func = {}
    self.func.loadObject = function() self:loadObject(source) end
    self.func.unloadObject = function() self:unloadObject(source) end

    addEventHandler("onClientElementStreamIn", root, self.func.loadObject)
    addEventHandler("onClientElementStreamOut", root, self.func.unloadObject)
    addEventHandler("onClientElementDestroy", root, self.func.unloadObject)

    self:loadObjects()
    return true
end

function TextureManager:loadObjects()
    for i, v in pairs(getElementsByType("object", root, true)) do
        self:loadObject(v)
    end
end

function TextureManager:createTexture(obj, texture)
    if self.textures[texture] then
        self.textures[texture].count = self.textures[texture].count + 1
        return self.textures[texture].texture
    else
        self.textures[texture] = {
            texture = dxCreateTexture(string.format("%s/%s.jpg", settings.path, texture), "argb", true, "clamp"),
            count = 1,
        }
        return self.textures[texture].texture
    end
end

function TextureManager:removeTexture(texture)
    if not self.textures[texture] then return end
    self.textures[texture].count = self.textures[texture].count - 1

    if self.textures[texture].count <= 0 then
        destroyElement(self.textures[texture].texture)
        self.textures[texture] = nil
    end
end

function TextureManager:createObjectShader(obj)
    local model = getElementModel(obj)
    if not settings.textureNames[model] then return end

    self.objects[obj] = {}
    for i, v in pairs(settings.textureNames[model]) do
        local shader = dxCreateShader(settings.shader, 0, 0, false, "object")
        table.insert(self.objects[obj], shader)
    end
end

function TextureManager:loadObject(obj)
    local model = getElementModel(obj)
    if not settings.textureNames[model] then return end

    if not self.objects[obj] then
        self:createObjectShader(obj)
    end

    self:textureObject(obj, model)
end

function TextureManager:unloadObject(obj)
    if not self.objects[obj] then return end
    for i, v in pairs(self.objects[obj]) do
        if isElement(v) then destroyElement(v) end
    end
    self.objects[obj] = nil

    local textures = getElementData(obj, "textures")
    if textures then
        for i, v in pairs(split(textures, ",")) do
            self:removeTexture(v)
        end
    end
end

function TextureManager:textureObject(obj, model)
    local textures = getElementData(obj, "textures")
    if not textures then self:unloadObject(obj) return end

    local texturesTable = split(textures, ",")
    for i, v in pairs(texturesTable) do
        if tostring(v) ~= "0" and self.objects[obj][i] then
            local texture = self:createTexture(obj, v)
            dxSetShaderValue(self.objects[obj][i], "gTexture", texture)
            engineApplyShaderToWorldTexture(self.objects[obj][i], settings.textureNames[model][i], obj)
        end
    end
end

TextureManager:create()