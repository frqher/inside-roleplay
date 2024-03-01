local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 700/zoom)/2,
    y = (sy - 475/zoom)/2,
    w = 700/zoom,
    h = 475/zoom,

    colors = {
        ["LS_Zwykly"] = {
            {170, 170, 170}, {0, 0, 0}, {140, 0, 0}, {30, 131, 168}, {21, 117, 28}, {196, 187, 6}, {214, 86, 0}, {50, 18, 122},
        },
        ["cout_and_schout"] = {
            {120, 120, 120}, {70, 70, 70}, {117, 43, 43}, {117, 100, 67}, {105, 117, 96}, {112, 138, 136}, {71, 72, 105}, {105, 71, 97},
        },
    },
}



BuyVehicle = {}
BuyVehicle.__index = BuyVehicle

function BuyVehicle:create(...)
    local instance = {}
    setmetatable(instance, BuyVehicle)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function BuyVehicle:constructor(...)
    self:buildVehicles(arg[1])
    self.shopName = arg[2]
    self.vehicleCount = arg[3]
    self.vehicleLimit = arg[4]
    self.alpha = 0
    self.scroll = 0

    self.icon = dxCreateTexture("files/images/vehicle.png", "argb", true, "clamp")

    self.fonts = {}
    self.fonts.name = exports.TR_dx:getFont(14)
    self.fonts.desc = exports.TR_dx:getFont(11)
    self.fonts.price = exports.TR_dx:getFont(13)
    self.fonts.fuel = exports.TR_dx:getFont(15)

    self.buttons = {}
    self.buttons.close = exports.TR_dx:createButton((sx - 250/zoom)/2, guiInfo.y + guiInfo.h - 50/zoom, 250/zoom, 40/zoom, "Zamknij sklep")
    self.buttons.back = exports.TR_dx:createButton(guiInfo.x + 20/zoom, guiInfo.y + guiInfo.h - 50/zoom, 300/zoom, 40/zoom, "Zamknij konfigurator")
    self.buttons.accept = exports.TR_dx:createButton(guiInfo.x + guiInfo.w - 320/zoom, guiInfo.y + guiInfo.h - 50/zoom, 300/zoom, 40/zoom, "Zakup pojazd")
    exports.TR_dx:setButtonVisible(self.buttons, false)
    exports.TR_dx:showButton(self.buttons.close)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.click = function(...) self:click(...) end
    self.func.buttonClick = function(...) self:buttonClick(...) end
    self.func.scrollButton = function(...) self:scrollButton(...) end
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientClick", root, self.func.click)
    addEventHandler("guiButtonClick", root, self.func.buttonClick)
    addEventHandler("onClientKey", root, self.func.scrollButton)

    self:open()
    return true
end

function BuyVehicle:open()
    self.state = "show"
    self.tick = getTickCount()
    self.tab = "main"

    showCursor(true)
    exports.TR_dx:setOpenGUI(true)
end

function BuyVehicle:close()
    self.state = "hide"
    self.tick = getTickCount()

    exports.TR_dx:hideButton(self.buttons)

    showCursor(false)
    removeEventHandler("guiButtonClick", root, self.func.buttonClick)
    removeEventHandler("onClientClick", root, self.func.click)
    removeEventHandler("onClientKey", root, self.func.scrollButton)
end

function BuyVehicle:destroy()
    removeEventHandler("onClientRender", root, self.func.render)
    destroyElement(self.icon)
    exports.TR_dx:destroyButton(self.buttons)
    exports.TR_dx:setOpenGUI(false)
    guiInfo.window = nil
    self = nil
end


function BuyVehicle:animate()
    if self.state == "show" then
        local progress = (getTickCount() - self.tick)/400
        self.alpha = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "InOutQuad")

        if progress >= 1 then
            self.tick = getTickCount()
            self.alpha = 1
            self.state = "showed"
        end

    elseif self.state == "hide" then
        local progress = (getTickCount() - self.tick)/400
        self.alpha = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "InOutQuad")

        if progress >= 1 then
            self.tick = nil
            self.alpha = 0
            self.state = nil

            self:destroy()
            return true
        end
    end
end

function BuyVehicle:render()
    if self:animate() then return end

    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 5)
    dxDrawText("Araba galerisi", guiInfo.x, guiInfo.y, guiInfo.w + guiInfo.x, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.name, "center", "center")

    if self.tab == "main" then
        for i = 1, 6 do
            if self.avaliableVehicles[i + self.scroll] then
                self:drawShopVehicle(self.avaliableVehicles[i + self.scroll], i)
            end
        end

        if #self.avaliableVehicles > 6 then
            local b1 = 360/zoom / #self.avaliableVehicles
            local barY = b1 * self.scroll
            local barHeight = b1 * 6
            dxDrawRectangle(guiInfo.x + guiInfo.w - 8/zoom, guiInfo.y + 55/zoom, 4/zoom, 360/zoom, tocolor(37, 37, 37, 255 * self.alpha))
            dxDrawRectangle(guiInfo.x + guiInfo.w - 8/zoom, guiInfo.y + 55/zoom + barY, 4/zoom, barHeight, tocolor(57, 57, 57, 255 * self.alpha))
        else
            dxDrawRectangle(guiInfo.x + guiInfo.w - 8/zoom, guiInfo.y + 55/zoom, 4/zoom, 360/zoom, tocolor(57, 57, 57, 255 * self.alpha))
        end

    elseif self.tab == "fuelType" then
        dxDrawText("Araçta olmasını istediğiniz yakıt türünü seçin.", guiInfo.x, guiInfo.y + 50/zoom, guiInfo.w + guiInfo.x, guiInfo.y + 100/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.price, "center", "center")

        local alpha = 200
        if not self.avaliableFuel[1] then alpha = 100 end
        if self.avaliableFuel[1] and self:isMouseInPosition(guiInfo.x + 140/zoom, guiInfo.y + 155/zoom, 128/zoom, 128/zoom) then alpha = 255 end
        dxDrawImage(guiInfo.x + 140/zoom, guiInfo.y + 155/zoom, 128/zoom, 128/zoom, "files/images/fuel.png", 0, 0, 0, tocolor(200, 200, 200, alpha * self.alpha))
        dxDrawText("Gaz", guiInfo.x + 140/zoom, guiInfo.y + 310/zoom, guiInfo.x + 268/zoom, guiInfo.y + 310/zoom, tocolor(200, 200, 200, alpha * self.alpha), 1/zoom, self.fonts.fuel, "center", "center")

        local alpha = 200
        if not self.avaliableFuel[2] then alpha = 100 end
        if self.avaliableFuel[2] and self:isMouseInPosition(guiInfo.x + guiInfo.w - 268/zoom, guiInfo.y + 155/zoom, 128/zoom, 128/zoom) then alpha = 255 end
        dxDrawImage(guiInfo.x + guiInfo.w - 268/zoom, guiInfo.y + 155/zoom, 128/zoom, 128/zoom, "files/images/fuel.png", 0, 0, 0, tocolor(200, 200, 200, alpha * self.alpha))
        dxDrawText("Dizel", guiInfo.x + guiInfo.w - 268/zoom, guiInfo.y + 310/zoom, guiInfo.x + guiInfo.w - 140/zoom, guiInfo.y + 310/zoom, tocolor(200, 200, 200, alpha * self.alpha), 1/zoom, self.fonts.fuel, "center", "center")

        dxDrawText("Toplam miktar:  $"..self:formatNumber(self.toPay), guiInfo.x, guiInfo.y + guiInfo.h - 10/zoom, guiInfo.w + guiInfo.x - 20/zoom, guiInfo.y + guiInfo.h - 50/zoom, tocolor(200, 200, 200, 200 * self.alpha), 1/zoom, self.fonts.name, "right", "center")

    elseif self.tab == "engineCapacity" then
        dxDrawText("İlgilendiğiniz motoru seçin.", guiInfo.x, guiInfo.y + 50/zoom, guiInfo.w + guiInfo.x, guiInfo.y + 100/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.price, "center", "center")

        for i = 1, 7 do
            if self.avaliableEngines[i + self.scroll] then
                self:drawShopVehicleCapacity(self.avaliableEngines[i + self.scroll], i)
            end
        end
        if #self.avaliableEngines > 7 then
            local b1 = 280/zoom / #self.avaliableEngines
            local barY = b1 * self.scroll
            local barHeight = b1 * 7
            dxDrawRectangle(sx/2 + 200/zoom, guiInfo.y + 100/zoom, 4/zoom, 280/zoom, tocolor(37, 37, 37, 255 * self.alpha))
            dxDrawRectangle(sx/2 + 200/zoom, guiInfo.y + 100/zoom + barY, 4/zoom, barHeight, tocolor(57, 57, 57, 255 * self.alpha))
        end
        dxDrawText("Toplam miktar:  $"..self:formatNumber(self.toPay), guiInfo.x, guiInfo.y + guiInfo.h - 10/zoom, guiInfo.w + guiInfo.x - 20/zoom, guiInfo.y + guiInfo.h - 50/zoom, tocolor(200, 200, 200, 200 * self.alpha), 1/zoom, self.fonts.name, "right", "center")

    elseif self.tab == "selectColor" then
        dxDrawText("İlgilendiğiniz rengi seçin.", guiInfo.x, guiInfo.y + 50/zoom, guiInfo.w + guiInfo.x, guiInfo.y + 100/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.price, "center", "center")

        for i, v in pairs(self.colors) do
            if self:isMouseInPosition(sx/2 - 198/zoom + i * 40/zoom, guiInfo.y + 220/zoom, 35/zoom, 35/zoom) then
                dxDrawRectangle(sx/2 - 198/zoom + i * 40/zoom, guiInfo.y + 220/zoom, 35/zoom, 35/zoom, tocolor(v[1], v[2], v[3], 255 * self.alpha))
            else
                dxDrawRectangle(sx/2 - 198/zoom + i * 40/zoom, guiInfo.y + 220/zoom, 35/zoom, 35/zoom, tocolor(v[1], v[2], v[3], 200 * self.alpha))
            end
        end

        dxDrawText("Toplam miktar:  $"..self:formatNumber(self.toPay), guiInfo.x, guiInfo.y + guiInfo.h - 10/zoom, guiInfo.w + guiInfo.x - 20/zoom, guiInfo.y + guiInfo.h - 50/zoom, tocolor(200, 200, 200, 200 * self.alpha), 1/zoom, self.fonts.name, "right", "center")

    elseif self.tab == "acceptBuy" then
        dxDrawText("Yapılandırma özeti.", guiInfo.x, guiInfo.y + 50/zoom, guiInfo.w + guiInfo.x, guiInfo.y + 100/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.price, "center", "center")

        dxDrawText("Toplam miktar:", guiInfo.x + 200/zoom, guiInfo.y + 110/zoom, guiInfo.w + guiInfo.x, guiInfo.y + 100/zoom, tocolor(200, 200, 200, 200 * self.alpha), 1/zoom, self.fonts.price, "left", "top")
        dxDrawText("Yakıt tipi:", guiInfo.x + 200/zoom, guiInfo.y + 140/zoom, guiInfo.w + guiInfo.x, guiInfo.y + 100/zoom, tocolor(200, 200, 200, 200 * self.alpha), 1/zoom, self.fonts.price, "left", "top")
        dxDrawText("Motor:", guiInfo.x + 200/zoom, guiInfo.y + 170/zoom, guiInfo.w + guiInfo.x, guiInfo.y + 100/zoom, tocolor(200, 200, 200, 200 * self.alpha), 1/zoom, self.fonts.price, "left", "top")
        dxDrawText("Araç rengi:", guiInfo.x + 200/zoom, guiInfo.y + 200/zoom, guiInfo.w + guiInfo.x, guiInfo.y + 100/zoom, tocolor(200, 200, 200, 200 * self.alpha), 1/zoom, self.fonts.price, "left", "top")
        dxDrawText("Tank kapasitesi:", guiInfo.x + 200/zoom, guiInfo.y + 230/zoom, guiInfo.w + guiInfo.x, guiInfo.y + 100/zoom, tocolor(200, 200, 200, 200 * self.alpha), 1/zoom, self.fonts.price, "left", "top")
        dxDrawText("Ortalama yakıt tüketimi:", guiInfo.x + 200/zoom, guiInfo.y + 260/zoom, guiInfo.w + guiInfo.x, guiInfo.y + 100/zoom, tocolor(200, 200, 200, 200 * self.alpha), 1/zoom, self.fonts.price, "left", "top")

        dxDrawText("$"..self:formatNumber(self.toPay), guiInfo.x + guiInfo.w - 200/zoom, guiInfo.y + 110/zoom, guiInfo.x + guiInfo.w - 200/zoom, guiInfo.y + 100/zoom, tocolor(212, 175, 55, 200 * self.alpha), 1/zoom, self.fonts.price, "right", "top")
        dxDrawText(self.selectedFuel == "p" and "Benzi" or "Dizel", guiInfo.x + guiInfo.w - 200/zoom, guiInfo.y + 140/zoom, guiInfo.x + guiInfo.w - 200/zoom, guiInfo.y + 100/zoom, tocolor(212, 175, 55, 200 * self.alpha), 1/zoom, self.fonts.price, "right", "top")
        dxDrawText(string.format("%s", self.selectedCapacity[1]), guiInfo.x + guiInfo.w - 200/zoom, guiInfo.y + 170/zoom, guiInfo.x + guiInfo.w - 200/zoom, guiInfo.y + 100/zoom, tocolor(212, 175, 55, 200 * self.alpha), 1/zoom, self.fonts.price, "right", "top")
        dxDrawRectangle(guiInfo.x + guiInfo.w - 240/zoom, guiInfo.y + 200/zoom, 40/zoom, 20/zoom, tocolor(self.selectedColor[1], self.selectedColor[2], self.selectedColor[3], 255 * self.alpha))
        dxDrawText(string.format("%d l", self.vehicleTankCapacity), guiInfo.x + guiInfo.w - 200/zoom, guiInfo.y + 230/zoom, guiInfo.x + guiInfo.w - 200/zoom, guiInfo.y + 100/zoom, tocolor(212, 175, 55, 200 * self.alpha), 1/zoom, self.fonts.price, "right", "top")
        dxDrawText(string.format("%d l", self.vehicleFuel), guiInfo.x + guiInfo.w - 200/zoom, guiInfo.y + 260/zoom, guiInfo.x + guiInfo.w - 200/zoom, guiInfo.y + 100/zoom, tocolor(212, 175, 55, 200 * self.alpha), 1/zoom, self.fonts.price, "right", "top")
    end
end

function BuyVehicle:drawShopVehicle(vehicle, i)
    local move = 60/zoom * i
    if self:isMouseInPosition(guiInfo.x, guiInfo.y + move - 4/zoom, guiInfo.w - 9/zoom, 60/zoom) then
        dxDrawRectangle(guiInfo.x, guiInfo.y + move - 5/zoom, guiInfo.w - 9/zoom, 60/zoom, tocolor(27, 27, 27, 255 * self.alpha))
    end

    dxDrawImage(guiInfo.x + 15/zoom, guiInfo.y + move + 2/zoom, 46/zoom, 46/zoom, self.icon, 0, 0, 0, tocolor(220, 220, 220, 200 * self.alpha))
    dxDrawText(self:getVehicleName(vehicle.vehObject), guiInfo.x + 80/zoom, guiInfo.y + 3/zoom + move, guiInfo.x + guiInfo.w, guiInfo.y + 40/zoom, tocolor(220, 220, 220, 200 * self.alpha), 1/zoom, self.fonts.name, "left", "top")
    dxDrawText("Yapılandırıcıya gitmek için basın.", guiInfo.x + 80/zoom, guiInfo.y + 26/zoom + move, guiInfo.x + guiInfo.w, guiInfo.y + 40/zoom, tocolor(150, 150, 150, 200 * self.alpha), 1/zoom, self.fonts.desc, "left", "top")
    dxDrawText("$"..self:formatNumber(vehicle.price), guiInfo.x + guiInfo.w - 30/zoom, guiInfo.y + move, guiInfo.x + guiInfo.w - 30/zoom, guiInfo.y + 50/zoom + move, tocolor(212, 175, 55, 200 * self.alpha), 1/zoom, self.fonts.price, "right", "center")
end

function BuyVehicle:getVehicleName(veh)
    local model = getElementModel(veh)
    if model == 471 then return "Snowmobile" end
    if model == 604 then return "Christmas Manana" end
    return getVehicleNameFromModel(model)
end

function BuyVehicle:drawShopVehicleCapacity(data, i)
    local move = 60/zoom + 40/zoom * i
    local center = sx/2

    if i == self.selectedCapacity then
        dxDrawRectangle(sx/2 - 200/zoom, guiInfo.y + move, 400/zoom, 40/zoom, tocolor(47, 47, 47, 255 * self.alpha))
    elseif self:isMouseInPosition(sx/2 - 180/zoom, guiInfo.y + move, 400/zoom, 40/zoom) then
        dxDrawRectangle(sx/2 - 200/zoom, guiInfo.y + move, 400/zoom, 40/zoom, tocolor(37, 37, 37, 255 * self.alpha))
    else
        dxDrawRectangle(sx/2 - 200/zoom, guiInfo.y + move, 400/zoom, 40/zoom, tocolor(27, 27, 27, 255 * self.alpha))
    end

    dxDrawText(string.format("Motor %s", data[1]), sx/2 - 190/zoom, guiInfo.y + move, guiInfo.x + guiInfo.w, guiInfo.y + move + 40/zoom, tocolor(220, 220, 220, 200 * self.alpha), 1/zoom, self.fonts.name, "left", "center")
    if data[2] >= 0 then
        dxDrawText("+ $"..self:formatNumber(data[2]), guiInfo.x + 200/zoom, guiInfo.y + move, sx/2 + 190/zoom, guiInfo.y + move + 40/zoom, tocolor(220, 220, 220, 200 * self.alpha), 1/zoom, self.fonts.name, "right", "center")
    else
        dxDrawText("- $"..self:formatNumber(math.abs(data[2])), guiInfo.x + 200/zoom, guiInfo.y + move, sx/2 + 190/zoom, guiInfo.y + move + 40/zoom, tocolor(220, 220, 220, 200 * self.alpha), 1/zoom, self.fonts.name, "right", "center")
    end
end


function BuyVehicle:click(...)
    if exports.TR_dx:isResponseEnabled() then return false end
    if arg[1] == "left" and arg[2] == "down" then
        if self.tab == "main" then
            for i = 1, 6 do
                if self.avaliableVehicles[i + self.scroll] then
                    local move = 60/zoom * i
                    if self:isMouseInPosition(guiInfo.x, guiInfo.y + move - 4/zoom, guiInfo.w - 9/zoom, 60/zoom) then
                        self.tab = "fuelType"
                        self.selected = self.avaliableVehicles[i + self.scroll]
                        self.selected.model = getElementModel(self.selected.vehObject)
                        self.toPay = self.selected.price
                        self.avaliableFuel = exports.TR_hud:getVehiclePetrolType(self.selected.model)
                        if self.avaliableFuel == "p" then self.avaliableFuel = {true, false} end
                        if self.avaliableFuel == "d" then self.avaliableFuel = {false, true} end
                        if self.avaliableFuel == "b" then self.avaliableFuel = {true, true} end

                        exports.TR_dx:setButtonVisible(self.buttons.close, false)
                        exports.TR_dx:setButtonVisible(self.buttons.back, true)
                        break
                    end
                end
            end

        elseif self.tab == "fuelType" then
            if self.avaliableFuel[1] and self:isMouseInPosition(guiInfo.x + 140/zoom, guiInfo.y + 155/zoom, 128/zoom, 128/zoom) then
                self.tab = "engineCapacity"
                self.selectedFuel = "p"
                self.avaliableEngines = self:getVehicleEngines()
                self.scroll = 0

            elseif self.avaliableFuel[2] and self:isMouseInPosition(guiInfo.x + guiInfo.w - 268/zoom, guiInfo.y + 155/zoom, 128/zoom, 128/zoom) then
                self.tab = "engineCapacity"
                self.selectedFuel = "d"
                self.avaliableEngines = self:getVehicleEngines()
                self.scroll = 0
            end

        elseif self.tab == "engineCapacity" then
            for i = 0, 7 do
                if self.avaliableEngines[i + self.scroll] then
                    local move = 60/zoom + 40/zoom * i
                    local center = sx/2
                    if self:isMouseInPosition(sx/2 - 180/zoom, guiInfo.y + move, 400/zoom, 40/zoom) then
                        self.selectedCapacity = self.avaliableEngines[i + self.scroll]
                        self.selectedCapacity[1] = tostring(self.selectedCapacity[1])

                        self.toPay = self.toPay + self.selectedCapacity[2]
                        self.tab = "selectColor"
                        self.colors = guiInfo.colors[self.shopName] and guiInfo.colors[self.shopName] or guiInfo.colors["LS_Zwykly"]
                        break
                    end
                end
            end

        elseif self.tab == "selectColor" then
            for i, v in pairs(self.colors) do
                if self:isMouseInPosition(sx/2 - 198/zoom + i * 40/zoom, guiInfo.y + 220/zoom, 35/zoom, 35/zoom) then
                    self.tab = "acceptBuy"
                    self.selectedColor = v
                    self.vehicleFuel = self:getVehicleInfo(self.selected.model, self.selectedCapacity[1])
                    self.vehicleTankCapacity = exports.TR_hud:getVehicleCapacity(self.selected.model)

                    exports.TR_dx:setButtonVisible(self.buttons.accept, true)
                    break
                end
            end
        end
    end
end

function BuyVehicle:buttonClick(...)
    if exports.TR_dx:isResponseEnabled() then return false end
    if arg[1] == self.buttons.close then
        self:close()

    elseif arg[1] == self.buttons.back then
        self.tab = "main"
        self.scroll = 0

        self.selectedFuel = nil
        self.avaliableFuel = nil
        self.selected = nil
        self.toPay = nil

        exports.TR_dx:setButtonVisible(self.buttons.close, true)
        exports.TR_dx:setButtonVisible(self.buttons.back, false)
        exports.TR_dx:setButtonVisible(self.buttons.accept, false)

    elseif arg[1] == self.buttons.accept then
        if not self:canBuyVehicle() then return end

        local variant = self.selected.variant and table.concat(self.selected.variant, ",") or "255,255"
        triggerServerEvent("createPayment", resourceRoot, self.toPay, "shopBuyVehicle", {
            shopName = self.shopName,
            model = self.selected.model,
            engineType = self.selectedFuel,
            engineCapacity = self.selectedCapacity[1],
            toPay = self.toPay,
            mileage = math.random(self.selected.mileage[1], self.selected.mileage[2]),
            color = string.format("%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,255,255,255", self.selectedColor[1], self.selectedColor[2], self.selectedColor[3], self.selectedColor[1], self.selectedColor[2], self.selectedColor[3], self.selectedColor[1], self.selectedColor[2], self.selectedColor[3], self.selectedColor[1], self.selectedColor[2], self.selectedColor[3]),
            variant = variant,
        })
    end
end

function BuyVehicle:scrollButton(...)
    if exports.TR_dx:isResponseEnabled() then return false end
    if self.tab == "main" then
        if arg[1] == "mouse_wheel_up" then
            if self.scroll == 0 then return end
            self.scroll = self.scroll - 1

        elseif arg[1] == "mouse_wheel_down" then
            if self.scroll + 6 >= #self.avaliableVehicles then return end
            self.scroll = self.scroll + 1
        end

    elseif self.tab == "engineCapacity" then
        if arg[1] == "mouse_wheel_up" then
            if self.scroll == 0 then return end
            self.scroll = self.scroll - 1

        elseif arg[1] == "mouse_wheel_down" then
            if self.scroll + 7 >= #self.avaliableEngines then return end
            self.scroll = self.scroll + 1
        end
    end
end

function BuyVehicle:getVehicleEngines(...)
    local engines = {}
    for i, v in pairs(self.selected.engines) do
        if v[3] == self.selectedFuel then
            table.insert(engines, {v[1], v[2]})
        end
    end

    return engines
end


function BuyVehicle:drawBackground(x, y, rx, ry, color, radius, post)
    rx = rx - radius * 2
    ry = ry - radius * 2
    x = x + radius
    y = y + radius

    if (rx >= 0) and (ry >= 0) then
        dxDrawRectangle(x, y, rx, ry, color, post)
        dxDrawRectangle(x, y - radius, rx, radius, color, post)
        dxDrawRectangle(x, y + ry, rx, radius, color, post)
        dxDrawRectangle(x - radius, y, radius, ry, color, post)
        dxDrawRectangle(x + rx, y, radius, ry, color, post)

        dxDrawCircle(x, y, radius, 180, 270, color, color, 7, 1, post)
        dxDrawCircle(x + rx, y, radius, 270, 360, color, color, 7, 1, post)
        dxDrawCircle(x + rx, y + ry, radius, 0, 90, color, color, 7, 1, post)
        dxDrawCircle(x, y + ry, radius, 90, 180, color, color, 7, 1, post)
    end
end


function BuyVehicle:canBuyVehicle()
    local plrData = getElementData(localPlayer, "characterData")

    local limit = self.vehicleLimit
    if plrData.premium == "gold" then
        limit = limit + 10

    elseif plrData.premium == "diamond" then
        limit = limit + 30
    end

    if self.vehicleCount >= limit then
        exports.TR_noti:create("Limitinize ulaştığınız için bu aracı satın alamazsınız. Hesabınızı yükseltin veya ek mağaza alanı satın alın.", "error")
        return false
    end

    for i, v in pairs(self.avaliableVehicles) do
        if v.model == self.selected.model then
            return true
        end
    end

    exports.TR_noti:create("Bu araç zaten satın alındı.", "error")
    return false
end

function BuyVehicle:formatNumber(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1 '):reverse())..right
end

function BuyVehicle:isMouseInPosition(x, y, width, height)
	if (not isCursorShowing()) then
		return false
	end
    local cx, cy = getCursorPosition()
    local cx, cy = (cx*sx), (cy*sy)
    if (cx >= x and cx <= x + width) and (cy >= y and cy <= y + height) then
        return true
    else
        return false
    end
end

function BuyVehicle:buildVehicles(...)
    self.avaliableVehicles = {}
    for i, v in pairs(arg[1]) do
        if isElement(v.vehObject) then
            table.insert(self.avaliableVehicles, v)
        end
    end
end

function BuyVehicle:updateData(...)
    self:buildVehicles(arg[1])
end

function BuyVehicle:getVehicleInfo(...)
    local veh = createVehicle(arg[1], 0, 0, 0)
    local handling = getVehicleHandling(veh)
    destroyElement(veh)

    local capacity = ""
    for i = 1, string.len(arg[2]) do
        local str = string.sub(arg[2], i, i)
        if str == " " then break end
        capacity = capacity .. str
    end
    capacity = tonumber(capacity)

	if string.find(arg[2], "Turbo") then capacity = capacity + 0.5 end
    if string.find(arg[2], "Biturbo") or string.find(arg[2], "Twin Turbo") then capacity = capacity + 1 end

    handling.engineAcceleration = handling.engineAcceleration + (capacity - 2) * 2
    return math.ceil((handling.engineAcceleration) * math.sqrt(100)/10)
end


function createVehicleDealer(...)
    if guiInfo.window then return end
    guiInfo.window = BuyVehicle:create(...)
end
addEvent("createVehicleDealer", true)
addEventHandler("createVehicleDealer", root, createVehicleDealer)

function updateVehicleDealer(...)
    if not guiInfo.window then return end
    guiInfo.window:updateData(...)
end
addEvent("updateVehicleDealer", true)
addEventHandler("updateVehicleDealer", root, updateVehicleDealer)

function vehicleShopResponse(...)
    exports.TR_dx:setResponseEnabled(false)

    if arg[1] then
        guiInfo.window:close()
        exports.TR_noti:create("Araç başarıyla satın alındı.", "success")
        return
    end
    exports.TR_noti:create("İşlem reddedildi.", "error")
end
addEvent("vehicleShopResponse", true)
addEventHandler("vehicleShopResponse", root, vehicleShopResponse)



function updateNoCollisionsOnRespawn()
    for i, v in pairs(VehicleExits) do
        local pos = split(v, ",")
        local sphere = createColSphere( pos[1], pos[2], pos[3], 6)
        addEventHandler("onClientColShapeHit", sphere, turnOffCollision)
        addEventHandler("onClientColShapeLeave", sphere, turnOnCollision)
    end
end

function turnOffCollision(el, md)
    if not el or not md then return end
    if getElementType(el) ~= "vehicle" then return end

    for i, v in pairs(getElementsByType("vehicle")) do
        setElementCollidableWith(el, v, false)
    end
end

function turnOnCollision(el, md)
    if not el or not md then return end
    if getElementType(el) ~= "vehicle" then return end

    for i, v in pairs(getElementsByType("vehicle")) do
        setElementCollidableWith(el, v, true)
    end
end
updateNoCollisionsOnRespawn()


exports.TR_dx:setResponseEnabled(false)









-- addEventHandler("onClientRender", root, function()
--     for i, v in pairs(getElementsByType("vehicle", resourceRoot, true)) do
--         local pos = Vector3(getElementPosition(v))
--         local sx, sy = getScreenFromWorldPosition(pos)

--         if sx and sy then
--             dxDrawText(getElementModel(v), sx, sy)
--         end
--     end
-- end)