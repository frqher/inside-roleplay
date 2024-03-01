local sx, sy = guiGetScreenSize()

local settings = {
    grungeLevels = {
        ["nogrunge"] = 100,
        ["lowgrunge"] = 300,
        ["defaultgrunge"] = 600,
        ["biggrunge"] = 900,
        ["megagrunge"] = 1500,
    },
    grungeMaterials = {
        ["gravel"] = {6, 85, 101, 134, 140},
        ["grass"] = {9, 10, 11, 12, 13, 14, 15, 16, 17, 20, 80, 81, 82, 115, 116, 117, 118, 119, 120, 121, 122, 125, 146, 147, 148, 149, 150, 151, 152, 153, 160},
        ["tierra"] = {19, 21, 22, 25, 26, 27, 40, 83, 84, 87, 88, 100, 110, 123, 124, 126, 128, 129, 130, 133, 141, 142, 145, 155, 156},
        ["sand"] = {28, 29, 30, 31, 32, 33, 74, 75, 76, 77, 78, 79, 86, 96, 97, 98, 99, 131, 143, 157},
        ["vegetation"] = {23, 41, 111, 112, 113, 114},
        ["mud"] = {24, 132},
    },
    materialDirtness = {
        ["gravel"] = 5, -- Żwir
        ["grass"] = 3,  -- Ziemia
        ["tierra"] = 4, -- Biom
        ["sand"] = 8, -- Piasek
        ["vegetation"] = 3, -- Roślinność (krzaki etc)
        ["mud"] = 6, -- Bagna
    },
    replaceTextures = {"vehiclegrunge256", "*grunge*"},

    minSpeed = 20,
}

VehicleGrunge = {}
VehicleGrunge.__index = VehicleGrunge

function VehicleGrunge:create()
    local instance = {}
    setmetatable(instance, VehicleGrunge)
    if instance:constructor() then
        return instance
    end
    return false
end

function VehicleGrunge:constructor()
    self.streamed = {}

    self.func = {}
    self.func.checkVehicle = function() self:checkVehicle() end
    self.func.onVehicleEnter = function(...) self:onVehicleEnter(source, ...) end
    self.func.onVehicleExit = function(...) self:onVehicleExit(source, ...) end

    self.func.onVehicleStreamIn = function() self:onVehicleStreamIn(source) end
    self.func.onVehicleStreamOut = function() self:onVehicleStreamOut(source) end

    setTimer(self.func.checkVehicle, 1000, 0)

    addEventHandler("onClientVehicleEnter", root, self.func.onVehicleEnter)
    addEventHandler("onClientVehicleStartExit", root, self.func.onVehicleExit)
    addEventHandler("onClientElementStreamIn", root, self.func.onVehicleStreamIn)
    addEventHandler("onClientElementStreamOut", root, self.func.onVehicleStreamOut)
    addEventHandler("onClientElementDestroy", root, self.func.onVehicleStreamOut)

    self:createShaders()
    self:loadVehicles()
    return true
end

function VehicleGrunge:loadVehicles()
    for i, v in pairs(getElementsByType("vehicle", root, true)) do
        self:onVehicleStreamIn(v)
    end

    local veh = getPedOccupiedVehicle(localPlayer)
    if veh then
        self:onVehicleEnter(veh, localPlayer, getPedOccupiedVehicleSeat(localPlayer))
    end
end

function VehicleGrunge:createShaders()
    self.shaders = {}
    self.images = {}

    for i, v in pairs(settings.grungeLevels) do
        self.shaders[i] = dxCreateShader("files/shaders/replace.fx", 0, 300, false, "vehicle")
        self.images[i] = dxCreateTexture(string.format("files/images/%s.png", i), "dxt3", true, "clamp")

        dxSetShaderValue(self.shaders[i], "Grunge", self.images[i])
    end
end

function VehicleGrunge:checkVehicle()
    for i, v in pairs(self.streamed) do
        local grunge = getElementData(i, "vehicleGrunge")
        if grunge ~= v then
            local lastGrunge = self:getTextureByGrungeLevel(v)
            local newGrunge = self:getTextureByGrungeLevel(grunge)

            if lastGrunge ~= newGrunge then
                self:removeTexture(i, lastGrunge)
                self:applyTexture(i, newGrunge)
                self.streamed[i] = grunge
            end
        end
    end

    if not self.vehicle then return end
    local speed = self:getElementSpeed(self.vehicle, 1)

    if speed >= settings.minSpeed then
        local addGrunge = self:calculateGrungeAdd()

        if addGrunge then
            local grunge = getElementData(self.vehicle, "vehicleGrunge") or 0
            if grunge ~= 1500 then
                setElementData(self.vehicle, "vehicleGrunge", math.min(grunge + addGrunge, 1500))
            end
        end
    end
end

function VehicleGrunge:calculateGrungeAdd()
    local vehPos = Vector3(getElementPosition(self.vehicle))
    local hit, _, _, _, _, _, _, _, material = processLineOfSight(vehPos, vehPos - Vector3(0, 0, 4), true, false, false)
    if not hit then return false, false end

    for biome, ids in pairs(settings.grungeMaterials) do
        for _, id in pairs(ids) do
            if material == id then
                return settings.materialDirtness[biome], biome
            end
        end
    end
    return false, material
end

function VehicleGrunge:onVehicleEnter(source, plr, seat)
    if plr ~= localPlayer or seat ~= 0 then return end
    self.vehicle = source
end

function VehicleGrunge:onVehicleExit(source, plr)
    if plr ~= localPlayer then return end
    self.vehicle = nil
end

function VehicleGrunge:onVehicleStreamIn(el)
    if getElementType(el) ~= "vehicle" then return end
    if self.streamed[el] then return end

    local grunge = getElementData(el, "vehicleGrunge") or 0
    local texture = self:getTextureByGrungeLevel(grunge)

    self:applyTexture(el, texture)
    self.streamed[el] = grunge
end

function VehicleGrunge:onVehicleStreamOut(el)
    if not self.streamed[el] then return end
    self.streamed[el] = nil

    local grunge = getElementData(el, "vehicleGrunge") or 0
    local texture = self:getTextureByGrungeLevel(grunge)

    self:removeTexture(el, texture)
end

function VehicleGrunge:applyTexture(el, texture)
    for i, v in pairs(settings.replaceTextures) do
        engineApplyShaderToWorldTexture(self.shaders[texture], v, el, true)
    end
end

function VehicleGrunge:removeTexture(el, texture)
    for i, v in pairs(settings.replaceTextures) do
        engineRemoveShaderFromWorldTexture(self.shaders[texture], v, el)
    end
end

function VehicleGrunge:getTextureByGrungeLevel(grunge)
    if not grunge then return "nogrunge" end
    local texture, val = "megagrunge", 999999
    for i, v in pairs(settings.grungeLevels) do
        if grunge < v and val > v then
            texture = i
            val = v
        end
    end
    return texture
end

function VehicleGrunge:getElementSpeed(theElement, unit)
	if not isElement(theElement) then return 0 end
    local elementType = getElementType(theElement)
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    return (Vector3(getElementVelocity(theElement)) * mult).length
end

VehicleGrunge:create()

addCommandHandler("brud", function(cmd, val)
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then outputChatBox("Araçta değilsiniz.") return end
    if not val or tonumber(val) == nil then outputChatBox("/brud (değer)") return end

    setElementData(veh, "vehicleGrunge", tonumber(val))
    outputConsole("Çalışır "..val)
end)