local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (1018/zoom - 32/zoom),
    y = (431/zoom - 32/zoom),

    size = 64/zoom,

    noCrosshair = {
        [0] = true,
        [1] = true,
        [2] = true,
        [3] = true,
        [4] = true,
        [5] = true,
        [6] = true,
        [7] = true,
        [8] = true,
        [9] = true,
        [33] = true,
        [34] = true,
    },

    replaceShader = [[
        texture gTexture;
        technique TexReplace
        {
            pass P0
            {
                Texture[0] = gTexture;
            }
        }
    ]],
}

Crosshair = {}
Crosshair.__index = Crosshair


function Crosshair:create()
    local instance = {}
    setmetatable(instance, Crosshair)
    if instance:constructor() then
        return instance
    end
    return false
end

function Crosshair:constructor()
    self.isCustom = false

    self.func = {}
    self.func.update = function() self:update() end

    setTimer(self.func.update, 10000, 0)
    return true
end

function Crosshair:update()
    if not fileExists("files/crosshair.png") then self:setDefault() return end
    self:setCustom()
end

function Crosshair:setCustom()
    if self.isCustom then self:checkIsNew() return end
    self.isCustom = true

    self.shader = dxCreateShader(guiInfo.replaceShader)
    self.texture = dxCreateTexture("files/crosshair.png", "argb", true, "clamp")

    local hFile = fileOpen("files/crosshair.png", true)
    self.fileSize = fileGetSize(hFile)
    fileClose(hFile)

    engineApplyShaderToWorldTexture(self.shader, "sitem16")
    dxSetShaderValue(self.shader, "gTexture", self.texture)
end

function Crosshair:checkIsNew()
    local hFile = fileOpen("files/crosshair.png", true)
    if fileGetSize(hFile) ~= self.fileSize then
        self:setDefault()
        self:setCustom()
    end
    fileClose(hFile)
end

function Crosshair:setDefault()
    if not self.isCustom then return end
    self.isCustom = nil

    if isElement(self.shader) then destroyElement(self.shader) end
    if isElement(self.texture) then destroyElement(self.texture) end
end


Crosshair:create()