Signs = {}
Signs.__index = Signs

function Signs:create()
    local instance = {}
    setmetatable(instance, Signs)
    if instance:constructor() then
        return instance
    end
    return false
end

function Signs:constructor()
    self.w = 400
    self.h = 600
    self.target = dxCreateRenderTarget(self.w, self.h)
    self.shader = dxCreateShader([[
        texture gTexture;
        technique TexReplace
        {
            pass P0
            {
                Texture[0] = gTexture;
            }
        }
    ]])

    self.fonts = {}
    self.fonts.info = exports.TR_dx:getFont(26)
    self.fonts.type = exports.TR_dx:getFont(20)
    self.fonts.unleaded = exports.TR_dx:getFont(14)
    self.fonts.price = dxCreateFont("files/fonts/font.ttf", 30)
    self.renderFunc = function() self:render() end

    self.func = {}
    self.func.restore = function() self:restore() end

    addEventHandler("onClientRender", root, self.renderFunc)
    addEventHandler("onClientRestore", root, self.func.restore)
    triggerServerEvent("getFuelPrices", resourceRoot)
    return true
end

function Signs:update(...)
    if not arg[1] then return end
    dxSetRenderTarget(self.target)
    dxDrawRectangle(0, 0, self.w, self.h, tocolor(230, 230, 230, 255))
    dxDrawRectangle(0, 0, self.w, 30, tocolor(230, 230, 230, 255))
    dxDrawImage(10, 25, self.w - 20, 70, "files/images/logo.png")
    dxDrawImage(0, 500, self.w, 70, "files/images/info.png")

    dxDrawRectangle(0, 120, self.w, 70, tocolor(86, 41, 2, 255))
    dxDrawRectangle(0, 120 + 70 * 2, self.w, 70, tocolor(86, 41, 2, 255))

    dxDrawText("STANDARD", 20, 129, self.w - 20, 190, tocolor(255, 255, 255, 255), 1, self.fonts.type, "left", "top")
    dxDrawText("PLUS", 20, 199, self.w - 20, 190, tocolor(0, 0, 0, 255), 1, self.fonts.type, "left", "top")
    dxDrawText("PREMIUM", 20, 269, self.w - 20, 190, tocolor(255, 255, 255, 255), 1, self.fonts.type, "left", "top")
    dxDrawText("DIESEL", 20, 330, self.w - 20, 400, tocolor(0, 0, 0, 255), 1, self.fonts.type, "left", "center")

    dxDrawText("UNLEADED", 20, 154, self.w - 20, 190, tocolor(255, 255, 255, 255), 1, self.fonts.unleaded, "left", "top")
    dxDrawText("UNLEADED", 20, 224, self.w - 20, 190, tocolor(0, 0, 0, 255), 1, self.fonts.unleaded, "left", "top")
    dxDrawText("UNLEADED", 20, 294, self.w - 20, 190, tocolor(255, 255, 255, 255), 1, self.fonts.unleaded, "left", "top")

    dxDrawText(string.format("$%.2f", arg[1]["Standard"]), 0, 120, self.w - 40, 190, tocolor(255, 255, 255, 255), 1, self.fonts.price, "right", "center")
    dxDrawText(string.format("$%.2f", arg[1]["Plus"]), 0, 190, self.w - 40, 260, tocolor(0, 0, 0, 255), 1, self.fonts.price, "right", "center")
    dxDrawText(string.format("$%.2f", arg[1]["Premium"]), 0, 260, self.w - 40, 330, tocolor(255, 255, 255, 255), 1, self.fonts.price, "right", "center")
    dxDrawText(string.format("$%.2f", arg[1]["ON"]), 0, 330, self.w - 40, 400, tocolor(0, 0, 0, 255), 1, self.fonts.price, "right", "center")

    dxDrawText("24 Hours    7 Days", 0, 400, self.w, 500, tocolor(0, 0, 0, 255), 1, self.fonts.info, "center", "center")
    dxSetRenderTarget()

    engineApplyShaderToWorldTexture(self.shader, "gassign1_256")
    dxSetShaderValue(self.shader, "gTexture", self.target)

    self.data = arg[1]
end

function Signs:render()
    -- dxDrawImage(0, 50, self.w, self.h, self.target)
end

function Signs:restore()
    self:update(self.data)
end


local sign = Signs:create()
function updateFuelSings(prices)
    sign:update(prices)
end
addEvent("updateFuelSings", true)
addEventHandler("updateFuelSings", root, updateFuelSings)