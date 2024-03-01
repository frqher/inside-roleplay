local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 500/zoom)/2,
    y = sy - 180/zoom,
    h = 110/zoom,
    w = 500/zoom,
}

FuelStation = {}
FuelStation.__index = FuelStation

function FuelStation:create(...)
    local instance = {}
    setmetatable(instance, FuelStation)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function FuelStation:constructor(...)
    self.alpha = 0
    self.fueled = 0
    self.vehicleFuel = 0
    self.fuelPrice = 0
    self.distributor = arg[1]
    self.fuelType = self:getFuelType(arg[2])

    self.fonts = {}
    self.fonts.title = exports.TR_dx:getFont(14)
    self.fonts.small = exports.TR_dx:getFont(10)

    self.hose = dxCreateTexture("files/images/hose.png", "argb", true, "clamp")

    self.func = {}
    self.func.render = function(...) self:render(...) end
    self.func.useStation = function(...) self:useStation(...) end
    self.func.checkVehicle = function(...) self:checkVehicle(...) end
    self.func.autoKey = function() self:autoKey() end

    self.checkVehicleTimer = setTimer(self.func.checkVehicle, 100, 0)
    exports.TR_interaction:updateInteraction("fueling", true)

    triggerServerEvent("bindPlayerFuelPistol", resourceRoot, arg[2])
    self:createSound()

    local pos = self:getHoseStartPosition(arg[1], arg[2])
    exports.TR_objectManager:createHose(localPlayer, pos, "fuel", 10)
    return true
end

function FuelStation:createSound()
    self.sound = playSound3D("files/sounds/fuel.wav", Vector3(getElementPosition(self.distributor)), true)
    setSoundVolume(self.sound, 0)
    setSoundMinDistance(self.sound, 20)
    setSoundMaxDistance(self.sound, 20)

    self.soundTimer = setTimer(function()
        setSoundVolume(self.sound, getSoundVolume(self.sound) + 0.1)
    end, 200, 10)
end

function FuelStation:getHoseStartPosition(...)
    local plrPos = Vector3(getElementPosition(localPlayer))
    local pos = Vector3(getElementPosition(arg[1]))
    local rot = self:findRotation(plrPos.x, plrPos.y, pos.x, pos.y)

    if rot < 180 then
        if arg[2] == "Standard" then return Vector3(self:getPositionFromElementOffset(arg[1], 0.22, -0.46, 0.16)) end
        if arg[2] == "Plus" then return Vector3(self:getPositionFromElementOffset(arg[1], 0.22, -0.27, 0.16)) end
        if arg[2] == "Premium" then return Vector3(self:getPositionFromElementOffset(arg[1], 0.22, -0.1, 0.16)) end
        if arg[2] == "ON" then return Vector3(self:getPositionFromElementOffset(arg[1], 0.22, -0.62, 0.16)) end

    elseif rot >= 180 then
        if arg[2] == "Standard" then return Vector3(self:getPositionFromElementOffset(arg[1], -0.22, -0.27, 0.16)) end
        if arg[2] == "Plus" then return Vector3(self:getPositionFromElementOffset(arg[1], -0.22, -0.46, 0.16)) end
        if arg[2] == "Premium" then return Vector3(self:getPositionFromElementOffset(arg[1], -0.22, -0.68, 0.16)) end
        if arg[2] == "ON" then return Vector3(self:getPositionFromElementOffset(arg[1], -0.22, -0.1, 0.16)) end
    end
    return Vector3(self:getPositionFromElementOffset(arg[1], -0.26, -0.1, 0.16))
end

function FuelStation:open(...)
    if not exports.TR_dx:canOpenGUI() then return end
    if self.opened then return end
    self.opened = true
    exports.TR_dx:setOpenGUI(true)

    self.state = "show"
    self.tick = getTickCount()
    self.lastAlpha = self.alpha
    self.vehicleName = ""

    bindKey("e", "both", self.func.useStation)
    toggleControl("jump", false)
    toggleControl("enter_exit", false)

    if not self.rendered then
        self.rendered = true
        addEventHandler("onClientRender", root, self.func.render)
    else
        self.vehicleUpdated = nil
    end
end

function FuelStation:close()
    if not self.opened then return end
    self.opened = nil
    exports.TR_dx:setOpenGUI(false)

    self.state = "hide"
    self.tick = getTickCount()
    self.lastAlpha = self.alpha

    if isTimer(self.updateKeyTimer) then killTimer(self.updateKeyTimer) end
    unbindKey("e", "both", self.func.useStation)
    exports.TR_interaction:rebuildKey()
end

function FuelStation:destroy(...)
    if self.fueled > 0 then self:createPayment() end

    if isTimer(self.checkVehicleTimer) then killTimer(self.checkVehicleTimer) end
    if isTimer(self.updateKeyTimer) then killTimer(self.updateKeyTimer) end
    if isTimer(self.soundTimer) then killTimer(self.soundTimer) end
    if self.rendered then removeEventHandler("onClientRender", root, self.func.render) end
    if isElement(self.hose) then destroyElement(self.hose) end

    if isElement(self.pistolTexture) then destroyElement(self.pistolTexture) end
    if isElement(self.pistolShader) then destroyElement(self.pistolShader) end
    if isElement(self.pistolTextureSign) then destroyElement(self.pistolTextureSign) end
    if isElement(self.pistolShaderSign) then destroyElement(self.pistolShaderSign) end
    -- if isElement(self.sound) then destroyElement(self.sound) end
    triggerServerEvent("removePlayerFuelPistol", resourceRoot)

    if not arg[1] then exports.TR_objectManager:removeHose(localPlayer) end

    unbindKey("e", "both", self.func.useStation)
    toggleControl("enter_exit", true)
    toggleControl("jump", true)

    local sound = self.sound
    setTimer(function()
        if not sound or not isElement(sound) then return end
        setSoundVolume(sound, getSoundVolume(sound) - 0.1)
        if getSoundVolume(sound) <= 0 then
            destroyElement(sound)
        end
    end, 100, 10)

    exports.TR_interaction:updateInteraction("fueling", nil)
    exports.TR_interaction:rebuildKey()
    guiInfo.fuel = nil
    self = nil
end

function FuelStation:createPayment()
    if self.vehicleFuel + self.fueled >= self.vehicleMaxFuel - 1 then
        triggerServerEvent("createPayment", resourceRoot, self:getPriceToPay(), "fuelVehicle", {vehicle = self.vehicleSelected, fuel = self.fueled, maxFuel = self.vehicleMaxFuel, full = true})
    else
        triggerServerEvent("createPayment", resourceRoot, self:getPriceToPay(), "fuelVehicle", {vehicle = self.vehicleSelected, fuel = self.fueled, maxFuel = self.vehicleMaxFuel})
    end
end

function FuelStation:getPriceToPay()
    local data = getElementData(localPlayer, "characterData")
    local multiplayer = 1

    if data.premium == "diamond" then multiplayer = multiplayer - 0.05
    elseif data.premium == "gold" then multiplayer = multiplayer + 0.02 end

    return self.fuelPrice * self.fueled * multiplayer
end





function FuelStation:checkVehicle()
    if getDistanceBetweenPoints3D(Vector3(getElementPosition(self.distributor)), Vector3(getElementPosition(localPlayer))) > 10 then
        self.fueled = 0
        self:destroy()
        exports.TR_noti:create("Distribütörden çok uzaklaştınız.", "error", 6)
        return
    end

    local x, y, z = self:getPositionFromElementOffset(localPlayer, 0, 1.5, 0)
    local closestDist, closestVehicle = 1000, nil
    for _, v in pairs(getElementsByType("vehicle", true)) do
        local dist = getDistanceBetweenPoints3D(x, y, z, Vector3(getElementPosition(v)))
        if closestDist > dist and dist < 1 then
            closestDist = dist
            closestVehicle = v
        end
    end
    if self.vehicle == closestVehicle then return end

    self.vehicle = closestVehicle
    if self.vehicle then
        self.vehicleMaxFuel = exports.TR_hud:getVehicleCapacity(self:getElementModel(closestVehicle))
        if not self.vehicleMaxFuel then return end

        self:open()
        self.vehicleName = self:getVehicleName(closestVehicle)

        triggerServerEvent("getVehicleFuel", resourceRoot, closestVehicle)
    else
        self:close()
    end
end


function FuelStation:animate()
    if self.state == "show" then
        local progress = (getTickCount() - self.tick)/400
        self.alpha = interpolateBetween(self.lastAlpha, 0, 0, 1, 0, 0, progress, "InOutQuad")

        if progress >= 1 then
            self.tick = getTickCount()
            self.alpha = 1
            self.state = "showed"
        end

    elseif self.state == "hide" then
        local progress = (getTickCount() - self.tick)/400
        self.alpha = interpolateBetween(self.lastAlpha, 0, 0, 0, 0, 0, progress, "InOutQuad")

        if progress >= 1 then
            self.tick = nil
            self.alpha = 0
            self.state = nil

            self.rendered = nil
            self.vehicleUpdated = nil
            removeEventHandler("onClientRender", root, self.func.render)
        end
    end
end

function FuelStation:render()
    if not self.vehicleMaxFuel then return end
    self:animate()
    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 5)
    self:drawBackground(guiInfo.x + 20/zoom, guiInfo.y + 35/zoom, guiInfo.w - 40/zoom, 20/zoom, tocolor(27, 27, 27, 255 * self.alpha), 5)

    if self.vehicleUpdated then
        if self.vehicleSelected then
            if self.vehicleSelected ~= self.vehicle then
                self:drawBackground(guiInfo.x + 20/zoom, guiInfo.y + 35/zoom, (guiInfo.w - 40/zoom) * (self.vehicleFuel)/self.vehicleMaxFuel, 20/zoom, tocolor(37, 37, 37, 255 * self.alpha), 5)
                dxDrawText(string.format("%.2f%%", (self.vehicleFuel)/self.vehicleMaxFuel * 100), guiInfo.x + 20/zoom, guiInfo.y + 35/zoom, guiInfo.x + guiInfo.w - 20/zoom, guiInfo.y + 55/zoom, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.small, "center", "center", false, false, false, true)
            else
                self:drawBackground(guiInfo.x + 20/zoom, guiInfo.y + 35/zoom, (guiInfo.w - 40/zoom) * (self.vehicleFuel + self.fueled)/self.vehicleMaxFuel, 20/zoom, tocolor(37, 37, 37, 255 * self.alpha), 5)
                dxDrawText(string.format("%.2f%%", (self.vehicleFuel + self.fueled)/self.vehicleMaxFuel * 100), guiInfo.x + 20/zoom, guiInfo.y + 35/zoom, guiInfo.x + guiInfo.w - 20/zoom, guiInfo.y + 55/zoom, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.small, "center", "center", false, false, false, true)
            end
        else
            self:drawBackground(guiInfo.x + 20/zoom, guiInfo.y + 35/zoom, (guiInfo.w - 40/zoom) * (self.vehicleFuel + self.fueled)/self.vehicleMaxFuel, 20/zoom, tocolor(37, 37, 37, 255 * self.alpha), 5)
            dxDrawText(string.format("%.2f%%", (self.vehicleFuel + self.fueled)/self.vehicleMaxFuel * 100), guiInfo.x + 20/zoom, guiInfo.y + 35/zoom, guiInfo.x + guiInfo.w - 20/zoom, guiInfo.y + 55/zoom, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.small, "center", "center", false, false, false, true)
        end
    else
        dxDrawText("Wczytywanie...", guiInfo.x + 20/zoom, guiInfo.y + 35/zoom, guiInfo.x + guiInfo.w - 20/zoom, guiInfo.y + 55/zoom, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.small, "center", "center", false, false, false, true)
    end

    dxDrawText(self.vehicleName, guiInfo.x, guiInfo.y + 5/zoom, guiInfo.x + guiInfo.w, guiInfo.y + guiInfo.h - 5/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.title, "center", "top", false, false, false, true)

    dxDrawText(string.format("Cena: #d4af37$%.2f #ffffffÖdenecek: #d4af37$%.2f", self.fuelPrice, self.fuelPrice * self.fueled), guiInfo.x, guiInfo.y + 63/zoom, guiInfo.x + guiInfo.w, guiInfo.y + guiInfo.h - 5/zoom, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.small, "center", "top", false, false, false, true)
    if self.vehicleEngineType == self.fuelType then
        dxDrawText("#aaaaaaYakıt ikmali yapmak için E #aaaaaaa tuşuna basın.", guiInfo.x, guiInfo.y + 20/zoom, guiInfo.x + guiInfo.w, guiInfo.y + guiInfo.h - 5/zoom, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.small, "center", "bottom", false, false, false, true)
    else
        dxDrawText("#aaaaaaBu yakıt türü bu araca uygun değil.", guiInfo.x, guiInfo.y + 20/zoom, guiInfo.x + guiInfo.w, guiInfo.y + guiInfo.h - 5/zoom, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.small, "center", "bottom", false, false, false, true)
    end
end

function FuelStation:useStation(...)
    if arg[2] == "up" then
        if isTimer(self.updateKeyTimer) then killTimer(self.updateKeyTimer) end
        return
    end

    if self.vehicleEngineType ~= self.fuelType then return end
    if not self.vehicle then return end
    if self.vehicleSelected then
        if self.vehicleSelected ~= self.vehicle then exports.TR_noti:create("Hortumu yere koyun ve bir sonraki arabaya yakıt ikmali yapmak için tekrar alın.", "info", 6) return end
    end

    if arg[2] == "down" and not isTimer(self.updateKeyTimer) then
        self.updateKeyTimer = setTimer(self.func.autoKey, 400, 0)
    end

    if self.slowFueling then
        if (getTickCount() - self.slowFueling)/400 < 1 then return end
    end
    self.slowFueling = getTickCount()

    self.vehicleSelected = self.vehicle
    self.fueled = self.fueled + 1

    if self.vehicleFuel + self.fueled >= self.vehicleMaxFuel then
        self.fueled = self.vehicleMaxFuel - self.vehicleFuel
    end
end

function FuelStation:autoKey()
    if getKeyState("e") then
        self:useStation()
    end
end

function FuelStation:findRotation( x1, y1, x2, y2 )
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end

function FuelStation:getFuelType(...)
    if arg[1] == "Standard" or arg[1] == "Plus" or arg[1] == "Premium" then return "p" end
    if arg[1] == "ON" then return "d" end
end

function FuelStation:setFuel(...)
    self.vehicleFuel = arg[1]
    self.vehicleEngineType = arg[2]

    self.vehicleUpdated = true
end

function FuelStation:setFuelPrice(...)
    self.fuelPrice = arg[1]
end



-- Utils
function FuelStation:drawBackground(x, y, rx, ry, color, radius, post)
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

function FuelStation:getPositionFromElementOffset(element, offX, offY, offZ)
    local m = getElementMatrix(element)
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z
end



function FuelStation:getVehicleName(veh)
    local model = getElementModel(veh)
    if model == 471 then return "Snowmobile" end
    if model == 604 then return "Christmas Manana" end
    return getVehicleName(veh)
end

function FuelStation:getElementModel(veh)
    return getElementData(veh, "oryginalModel") or getElementModel(veh)
end



function openFuelStation(...)
    if arg[2] == "remove" and guiInfo.fuel then
        guiInfo.fuel:destroy()
        return
    end

    if guiInfo.fuel then return end
    guiInfo.fuel = FuelStation:create(unpack(arg))
    triggerServerEvent("getFuelPrice", resourceRoot, arg[2])
end

function hoseFuelEnd(...)
    if not guiInfo.fuel then return end
    guiInfo.fuel:close()
    guiInfo.fuel:destroy(true)
end

function setVehicleFuel(...)
    if not guiInfo.fuel then return end
    guiInfo.fuel:setFuel(...)
end
addEvent("setVehicleFuel", true)
addEventHandler("setVehicleFuel", root, setVehicleFuel)

function setFuelPrice(...)
    if not guiInfo.fuel then return end
    guiInfo.fuel:setFuelPrice(...)
end
addEvent("setFuelPrice", true)
addEventHandler("setFuelPrice", root, setFuelPrice)

function fuelResponse(...)
    exports.TR_dx:setResponseEnabled(false)
    if arg[1] then
        if arg[2] then
            exports.TR_achievements:addAchievements("vehicleRefuel")
        end

        exports.TR_noti:create("İşlem başarıyla tamamlandı.", "success")
    else
        exports.TR_noti:create("İşlem reddedildi.", "error")
    end
end
addEvent("fuelResponse", true)
addEventHandler("fuelResponse", root, fuelResponse)


local pistols = {}
function updateFuelPistol()
    local texture = getElementData(source, "texture")
    if not texture then return end

    pistols[source] = {}
    if texture == "ON" then
        pistols[source].pistolTexture = dxCreateTexture("files/images/diesel.png", "argb", true, "clamp")
        pistols[source].pistolShader = dxCreateShader([[
        texture gTexture;
        technique TexReplace
        {
            pass P0
            {
                Texture[0] = gTexture;
            }
        }
        ]], 0, 0, false, "object")

        engineApplyShaderToWorldTexture(pistols[source].pistolShader, "PetrolColor", source)
        dxSetShaderValue(pistols[source].pistolShader, "gTexture", pistols[source].pistolTexture)
    end

    if texture ~= "Premium" then
        pistols[source].pistolTextureSign = dxCreateTexture("files/images/"..getPetrolTextureName(texture)..".png", "argb", true, "clamp")
        pistols[source].pistolShaderSign = dxCreateShader([[
        texture gTexture;
        technique TexReplace
        {
            pass P0
            {
                Texture[0] = gTexture;
            }
        }
        ]], 0, 0, false, "object")

        engineApplyShaderToWorldTexture(pistols[source].pistolShaderSign, "93", source)
        dxSetShaderValue(pistols[source].pistolShaderSign, "gTexture", pistols[source].pistolTextureSign)
    end

    addEventHandler("onClientElementDestroy", source, removeFuelPistol)
end
addEventHandler("onClientElementStreamIn", root, updateFuelPistol)

function removeFuelPistol()
    if pistols[source] then
        for i, v in pairs(pistols[source]) do
            destroyElement(v)
        end
        pistols[source] = nil
    end
end
addEventHandler("onClientElementStreamOut", root, removeFuelPistol)


function getPetrolTextureName(...)
    if arg[1] == "Standard" then return "87" end
    if arg[1] == "Plus" then return "89" end
    if arg[1] == "ON" then return "ON" end
end