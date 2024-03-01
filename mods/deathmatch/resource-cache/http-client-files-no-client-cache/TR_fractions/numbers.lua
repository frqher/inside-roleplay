local sx, sy = guiGetScreenSize()

local textColors = {
    [599] = {0, 0, 0},
    [523] = {0, 0, 0},
    [428] = {255, 255, 255},
}

local settings = {
    w = 128,
    h = 128,

    shader = [[
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

Numbers = {}
Numbers.__index = Numbers

function Numbers:create(...)
    local instance = {}
    setmetatable(instance, Numbers)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function Numbers:constructor(...)
    self.numbers = {}

    self.fonts = {}
    self.fonts.number = exports.TR_dx:getFont(60)

    self.func = {}
    self.func.check = function() self:check() end
    self.func.restore = function() self:restore() end

    addEventHandler("onClientRestore", root, self.func.restore)
    setTimer(self.func.check, 5000, 0)

    self:check()
    return true
end

function Numbers:createSign(...)
    if self.numbers[arg[1]] then return end
    self.numbers[arg[1]] = {
        shader = dxCreateShader(settings.shader, 0, 0, false, "vehicle"),
        texture = dxCreateRenderTarget(settings.w, settings.h, true),
    }
    self:render(arg[1])
end

function Numbers:destroySign(...)
    if not self.numbers[arg[1]] then return end
    if isElement(self.numbers[arg[1]].shader) then destroyElement(self.numbers[arg[1]].shader) end
    if isElement(self.numbers[arg[1]].texture) then destroyElement(self.numbers[arg[1]].texture) end
    self.numbers[arg[1]] = nil
end

function Numbers:check()
    local plrPos = Vector3(getElementPosition(localPlayer))

    for i, v in pairs(getElementsByType("vehicle", resourceRoot)) do
        local pos = Vector3(getElementPosition(v))
        if getElementData(v, "fractionNumber") then
            local dist = getDistanceBetweenPoints3D(plrPos, pos)
            if dist < 50 then
                self:createSign(v)
            else
                self:destroySign(v)
            end
        end
    end
end

function Numbers:restore()
    for i, v in pairs(self.numbers) do
        self:render(i)
    end
    self:check()
end

function Numbers:render(...)
    local plateText = getElementData(arg[1], "fractionNumber")
    local color = textColors[getElementModel(arg[1])] or {255, 255, 255}

    dxSetRenderTarget(self.numbers[arg[1]].texture, true)
    dxSetBlendMode("modulate_add")
    dxDrawText(plateText, 0, 0, settings.w, settings.h, tocolor(color[1], color[2], color[3], 255), 1, self.fonts.number, "center", "center", true, true)

    dxSetRenderTarget()
    dxSetBlendMode("blend")

    dxSetShaderValue(self.numbers[arg[1]].shader, "gTexture", self.numbers[arg[1]].texture)
    engineApplyShaderToWorldTexture(self.numbers[arg[1]].shader, "numberstrunkpd", arg[1])
end

Numbers:create()