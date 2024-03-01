local sx, sy = guiGetScreenSize()

local settings = {
    gui = {
        [1906] = {
            w = 126,
            h = 256,
        },
        [3927] = {
            w = 256,
            h = 128,
        },
    },


    signModels = {[1906] = true, [3927] = true},

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

SignSystem = {}
SignSystem.__index = SignSystem

function SignSystem:create(...)
    local instance = {}
    setmetatable(instance, SignSystem)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function SignSystem:constructor(...)
    self.signs = {}

    self.fonts = {}
    self.fonts.big = exports.TR_dx:getFont(20)
    self.fonts.medium = exports.TR_dx:getFont(18)
    self.fonts.price = exports.TR_dx:getFont(14)
    self.fonts.model = exports.TR_dx:getFont(12)
    self.fonts.seller = exports.TR_dx:getFont(8)

    self.func = {}
    self.func.check = function() self:check() end
    self.func.restore = function() self:restore() end
    addEventHandler("onClientRestore", root, self.func.restore)
    setTimer(self.func.check, 5000, 0)

    self:check()
    return true
end

function SignSystem:createSign(...)
    if self.signs[arg[1]] then self:render(arg[1], getElementModel(arg[1])) return end
    local gui = settings.gui[arg[2]]
    self.signs[arg[1]] = {
        shader = dxCreateShader(settings.shader, 0, 0, false, "object"),
        texture = dxCreateRenderTarget(gui.w, gui.h),
    }
    self:render(arg[1], arg[2])
end

function SignSystem:destroySign(...)
    if not self.signs[arg[1]] then return end
    if isElement(self.signs[arg[1]].shader) then destroyElement(self.signs[arg[1]].shader) end
    if isElement(self.signs[arg[1]].texture) then destroyElement(self.signs[arg[1]].texture) end
    self.signs[arg[1]] = nil
end

function SignSystem:check()
    local plrPos = Vector3(getElementPosition(localPlayer))
    for i, v in pairs(getElementsByType("object", resourceRoot)) do
        local model = getElementModel(v)
        if settings.signModels[model] then
            local pos = Vector3(getElementPosition(v))
            local dist = getDistanceBetweenPoints3D(plrPos, pos)
            if dist < 50 then
                self:createSign(v, model)
            else
                self:destroySign(v)
            end
        end
    end
end

function SignSystem:restore()
    for i, v in pairs(self.signs) do
        self:render(i, getElementModel(i))
    end
    self:check()
end

function SignSystem:render(...)
    local data, veh = self:getVehicleData(arg[1])
    if not data then
        self:renderNoVehicle(arg[1], arg[2])
        return
    end

    if arg[2] == 1906 then
        self:renderStandardSign(arg[1], arg[2], data, veh)

    elseif arg[2] == 3927 then
        -- self:renderNoVehicle(arg[1], arg[2])
        self:renderOldSign(arg[1], arg[2], data, veh)
    end
end

function SignSystem:renderNoVehicle(...)
    local gui = settings.gui[arg[2]]

    dxSetRenderTarget(self.signs[arg[1]].texture)
    if arg[2] == 3927 then
        dxDrawImage(0, 0, gui.w, gui.h, "files/images/banner.png")
        dxDrawText("Brak pojazdu\nna stanie!", 5, 5, gui.w - 5, gui.h - 5, tocolor(20, 20, 20, 255), 1, self.fonts.big, "center", "center", true, true)
    else
        dxDrawRectangle(0, 0, gui.w, gui.h, tocolor(31, 78, 153, 255))
        dxDrawText("Brak pojazdu\nna stanie.", 5, 5, gui.w - 5, gui.h - 5, tocolor(217, 28, 28, 255), 1, self.fonts.price, "center", "top", true, true)
        dxDrawText("Za jakiś czas na pewno pojawi się tutaj nowy egzemplarz.", 5, 88, gui.w - 5, gui.h - 5, tocolor(220, 220, 220, 255), 1, self.fonts.model, "center", "top", true, true)
        dxDrawText("Za wszelkie\nutrudnienia\nprzepraszamy!", 5, 5, gui.w - 5, gui.h - 10, tocolor(220, 220, 220, 255), 1, self.fonts.seller, "center", "bottom", true, true)
    end

    dxSetRenderTarget()
    dxSetShaderValue(self.signs[arg[1]].shader, "gTexture", self.signs[arg[1]].texture)
    engineApplyShaderToWorldTexture(self.signs[arg[1]].shader, "banner", arg[1])
end

function SignSystem:renderOldSign(sign, signModel, data, veh)
    local gui = settings.gui[signModel]
    local model = getElementModel(veh)

    dxSetRenderTarget(self.signs[sign].texture)
    dxDrawImage(0, 0, gui.w, gui.h, "files/images/banner.png")
    dxDrawText(self:getVehicleName(model), 5, 20, gui.w - 5, 60, tocolor(20, 20, 20, 255), 1, self.fonts.big, "center", "top", true, true)
    dxDrawText("Cena:", 5, 60, gui.w - 5, gui.h - 5, tocolor(20, 20, 20, 255), 1, self.fonts.price, "center", "top", true, true)
    dxDrawText("$"..data.price, 5, 76, gui.w - 5, gui.h - 5, tocolor(20, 20, 20, 255), 1, self.fonts.big, "center", "top", true, true)

    dxSetRenderTarget()

    dxSetShaderValue(self.signs[sign].shader, "gTexture", self.signs[sign].texture)
    engineApplyShaderToWorldTexture(self.signs[sign].shader, "banner", sign)
end

function SignSystem:renderStandardSign(sign, signModel, data, veh)
    local gui = settings.gui[signModel]
    local model = getElementModel(veh)
    local capacity, petrolType = self:getVehicleDetails(model)
    local engineCapacity = self:formatCapacity(data.engines[1][1])

    local consumption, vmax = self:getVehicleInfo(model, data.engines[1][1])
    if petrolType == "p" then petrolType = "Benzyna" end
    if petrolType == "d" then petrolType = "Diesel" end
    if petrolType == "b" then petrolType = "Do wyboru" end

    dxSetRenderTarget(self.signs[sign].texture)
    dxDrawRectangle(0, 0, gui.w, gui.h, tocolor(31, 78, 153, 255))
    dxDrawText(self:getVehicleName(model), 5, 2, gui.w - 5, 40, tocolor(255, 255, 255, 255), 1, self.fonts.model, "center", "center", true, true)

    dxDrawText("Bak:", 5, 40, gui.w - 5, gui.h, tocolor(255, 255, 255, 255), 1, self.fonts.seller, "left", "top", true, true)
    dxDrawText("Silnik:", 5, 55, gui.w - 5, gui.h, tocolor(255, 255, 255, 255), 1, self.fonts.seller, "left", "top", true, true)
    dxDrawText("V-max:", 5, 70, gui.w - 5, gui.h, tocolor(255, 255, 255, 255), 1, self.fonts.seller, "left", "top", true, true)
    dxDrawText("Paliwo:", 5, 85, gui.w - 5, gui.h, tocolor(255, 255, 255, 255), 1, self.fonts.seller, "left", "top", true, true)
    dxDrawText("Spalanie:", 5, 100, gui.w - 5, gui.h, tocolor(255, 255, 255, 255), 1, self.fonts.seller, "left", "top", true, true)
    dxDrawText("Malowanie:", 5, 115, gui.w - 5, gui.h, tocolor(255, 255, 255, 255), 1, self.fonts.seller, "left", "top", true, true)
    dxDrawText("Kolor lamp:", 5, 130, gui.w - 5, gui.h, tocolor(255, 255, 255, 255), 1, self.fonts.seller, "left", "top", true, true)
    dxDrawText("P. stylistyczny:", 5, 145, gui.w - 5, gui.h, tocolor(255, 255, 255, 255), 1, self.fonts.seller, "left", "top", true, true)

    dxDrawText(capacity.." l", 5, 40, gui.w - 5, gui.h, tocolor(255, 255, 255, 255), 1, self.fonts.seller, "right", "top", true, true)
    dxDrawText(string.format("%.1f l", engineCapacity), 5, 55, gui.w - 5, gui.h, tocolor(255, 255, 255, 255), 1, self.fonts.seller, "right", "top", true, true)
    dxDrawText(vmax.." km/h", 5, 70, gui.w - 5, gui.h, tocolor(255, 255, 255, 255), 1, self.fonts.seller, "right", "top", true, true)
    dxDrawText(petrolType, 5, 85, gui.w - 5, gui.h, tocolor(255, 255, 255, 255), 1, self.fonts.seller, "right", "top", true, true)
    dxDrawText(consumption.." l/100km", 5, 100, gui.w - 5, gui.h, tocolor(255, 255, 255, 255), 1, self.fonts.seller, "right", "top", true, true)
    dxDrawText("Standard", 5, 115, gui.w - 5, gui.h, tocolor(255, 255, 255, 255), 1, self.fonts.seller, "right", "top", true, true)
    dxDrawText("Białe", 5, 130, gui.w - 5, gui.h, tocolor(255, 255, 255, 255), 1, self.fonts.seller, "right", "top", true, true)
    dxDrawText("Brak", 5, 145, gui.w - 5, gui.h, tocolor(255, 255, 255, 255), 1, self.fonts.seller, "right", "top", true, true)

    dxDrawText("Cena za pojazd:", 5, 5, gui.w - 5, gui.h - 75, tocolor(255, 255, 255, 255), 1, self.fonts.seller, "center", "bottom", true, true)
    dxDrawText("$"..data.price, 5, 5, gui.w - 5, gui.h - 55, tocolor(255, 255, 255, 255), 1, self.fonts.price, "center", "bottom", true, true)

    dxDrawText("Jeżeli jesteś", 5, 205, gui.w - 5, gui.h, tocolor(255, 255, 255, 255), 1, self.fonts.seller, "center", "top", true, true)
    dxDrawText("zainteresowany", 5, 215, gui.w - 5, gui.h, tocolor(255, 255, 255, 255), 1, self.fonts.seller, "center", "top", true, true)
    dxDrawText("kupnem, porozmawiaj", 5, 225, gui.w - 5, gui.h, tocolor(255, 255, 255, 255), 1, self.fonts.seller, "center", "top", true, true)
    dxDrawText("ze sprzedawcą.", 5, 235, gui.w - 5, gui.h, tocolor(255, 255, 255, 255), 1, self.fonts.seller, "center", "top", true, true)
    dxSetRenderTarget()

    dxSetShaderValue(self.signs[sign].shader, "gTexture", self.signs[sign].texture)
    engineApplyShaderToWorldTexture(self.signs[sign].shader, "banner", sign)
end

function SignSystem:getVehicleName(model)
    if model == 471 then return "Snowmobile" end
    if model == 604 then return "Christmas Manana" end
    return getVehicleNameFromID(model)
end

function SignSystem:getVehicleData(...)
    local v = getElementData(arg[1], "signInfo")
    if isElement(v.veh) then
        return v.data, v.veh
    end
    return false, false
end

function SignSystem:getVehicleDetails(...)
    return exports.TR_hud:getVehicleCapacity(arg[1]), exports.TR_hud:getVehiclePetrolType(arg[1])
end

function SignSystem:getVehicleInfo(...)
    local capacity = self:formatCapacity(arg[2])
    local maxVelocity = exports.TR_vehicles:getVehicleMaxSpeed(arg[1], capacity)
    return math.ceil((maxVelocity * math.sqrt(50))/60), maxVelocity
end

function SignSystem:formatCapacity(capacity)
    local c = ""
	local hasTurbo = nil
    for i = 1, string.len(capacity) do
        local str = string.sub(capacity, i, i)
        if str == " " then break end
        c = c .. str
	end

	local newCapacity = tonumber(c)
	if string.find(capacity, "Turbo") then newCapacity = newCapacity + 0.5; hasTurbo = true end
	if string.find(capacity, "Biturbo") or string.find(capacity, "Twin Turbo") then newCapacity = newCapacity + 1; hasTurbo = true end
    return newCapacity
end

SignSystem:create()


function blockEnter()
    cancelEvent()
end
addEventHandler("onClientVehicleStartEnter", resourceRoot, blockEnter)