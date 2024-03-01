local settings = {
    destroyDamage = {
        panelStates = {
            [0] = 15, -- Front-left panel
            [1] = 15, -- Front-right panel
            [2] = 15, -- Rear-left panel
            [3] = 15, -- Rear-right panel
            [4] = 15, -- Windscreen
            [5] = 30, -- Front bumper
            [6] = 30, -- Rear bumper
        },
        doors = {
            [0] = 25, -- Hood
            [1] = 25, -- Trunk
            [2] = 15, -- Front left
            [3] = 15, -- Front right
            [4] = 15, -- Rear left
            [5] = 15, -- Rear right
        },
        lamps = {
            [0] = 2, -- Front left
            [1] = 2, -- Front right
            [2] = 2, -- Rear right
            [3] = 2, -- Rear left
        },
    }
}

VehicleDamage = {}
VehicleDamage.__index = VehicleDamage

function VehicleDamage:create()
    local instance = {}
    setmetatable(instance, VehicleDamage)
    if instance:constructor() then
        return instance
    end
    return false
end

function VehicleDamage:constructor()

    self.func = {}
    -- self.func.renderDebug = function() self:renderDebug() end
    self.func.checkVehicle = function() self:checkVehicle() end
    self.func.selectVehicle = function(...) self:selectVehicle(...) end
    self.func.onCollision = function(...) self:onCollision(source, ...) end

    setTimer(self.func.checkVehicle, 1000, 0)
    -- addEventHandler("onClientRender", root, self.func.renderDebug)
    addEventHandler("onClientVehicleDamage", root, self.func.onCollision)

    addEvent("updateVehicleDamage", true)
    addEventHandler("updateVehicleDamage", root, self.func.selectVehicle)
    return true
end

function VehicleDamage:checkVehicle()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then self:clearVehicle() return end
    local seat = getPedOccupiedVehicleSeat(localPlayer)
    if not seat then self:clearVehicle() end
    if seat ~= 0 then self:clearVehicle() return end

    if self.lastVeh == veh then return end
    self:selectVehicle(veh)
end

-- function VehicleDamage:renderDebug()
--     if not self.lastDmg then
--         dxDrawText("Ostatnie obrażenia pojazdu: Brak odczytu", 10, 10)
--     else
--         dxDrawText("Ostatnie obrażenia pojazdu: " .. self.lastDmg, 10, 10)
--     end
-- end


function VehicleDamage:selectVehicle(veh)
    self.vehicle = veh
    self.panelStates = self:getPanelStates()
    self.doorStates = self:getDoorStates()
    self.lamps = self:getLampStates()
end

function VehicleDamage:clearVehicle()
    self.vehicle = nil
end


function VehicleDamage:onCollision(source, att, weapon, loss, dmgX, dmgY, dmgZ, tireID)
    if not self.vehicle then return end
    if self.vehicle ~= source then return end
    if isElementFrozen(source) then return end

    self.lastDmg = loss

    local panelStates = self:getPanelStates()
    local doorStates = self:getDoorStates()
    local lamps = self:getLampStates()

    local toSync = {}
    local change = false

    for i, v in pairs(panelStates) do
        if self.panelStates[i] ~= v then
            if loss < settings.destroyDamage.panelStates[i] then
                panelStates[i] = self.panelStates[i]
                table.insert(toSync, {i = i, state = self.panelStates[i], type = "panel"})
                setVehiclePanelState(self.vehicle, i, self.panelStates[i])
            end
        end
    end

    for i, v in pairs(doorStates) do
        if self.doorStates[i] ~= v then
            if loss < settings.destroyDamage.doors[i] then
                doorStates[i] = self.doorStates[i]
                table.insert(toSync, {i = i, state = self.doorStates[i], type = "door"})
                setVehicleDoorState(self.vehicle, i, self.doorStates[i])
            end
        end
    end

    for i, v in pairs(lamps) do
        if self.lamps[i] ~= v then
            if loss < settings.destroyDamage.lamps[i] then
                lamps[i] = self.lamps[i]
                table.insert(toSync, {i = i, state = self.lamps[i], type = "light"})
                setVehicleLightState(self.vehicle, i, self.lamps[i])
            else
                self.lamps[i] = lamps[i]
                table.insert(toSync, {i = i, state = self.lamps[i], type = "light"})
                setVehicleLightState(self.vehicle, i, self.lamps[i])
            end
        end
    end

    if #toSync > 0 then
        self.panelStates = panelStates
        self.doorStates = doorStates
        self.lamps = lamps

        triggerServerEvent("vehicleDamageSync", resourceRoot, self.vehicle, toSync)
    end
    cancelEvent()

    local multiplayer = 1 - exports.TR_features:getFeatureValue("steer")/1000
    local dmg = loss * multiplayer
    local hp = math.max(getElementHealth(self.vehicle) - dmg, 301)
    setElementHealth(self.vehicle, hp)

    if hp == 301 then
        setVehicleDamageProof(self.vehicle, true)
    end
end



function VehicleDamage:getPanelStates()
    local panels = {}
    for i = 0, 6 do
        panels[i] = getVehiclePanelState(self.vehicle, i)
    end
    return panels
end

function VehicleDamage:getDoorStates()
    local doors = {}
    for i = 0, 5 do
        doors[i] = getVehicleDoorState(self.vehicle, i)
    end
    return doors
end

function VehicleDamage:getLampStates()
    local lights = {}
    for i = 0, 3 do
        lights[i] = getVehicleLightState(self.vehicle, i)
    end
    return lights
end


VehicleDamage:create()