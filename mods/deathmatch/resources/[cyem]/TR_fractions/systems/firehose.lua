local sx, sy = guiGetScreenSize()

local guiInfo = {}

FireHose = {}
FireHose.__index = FireHose

function FireHose:create()
    local instance = {}
    setmetatable(instance, FireHose)
    if instance:constructor() then
        return instance
    end
    return false
end

function FireHose:constructor()
    self.state = false
    self.hoseVeh = false

    self.players = {}

    self.func = {}
    self.func.update = function() self:update() end
    self.func.render = function() self:render() end

    setTimer(self.func.update, 1000, 0)
    addEventHandler("onClientRender", root, self.func.render)
    return true
end

function FireHose:render()
    for plr, data in pairs(self.players) do
        if isElement(plr) then
            if getElementData(plr, "fireButton") then
                setPedControlState(data.ped, "vehicle_fire", true)
                setElementCollisionsEnabled(plr, false)
            else
                setPedControlState(data.ped, "vehicle_fire", false)
                setElementCollisionsEnabled(plr, true)
            end
        else
            self:destroyFireTurret(plr)
            setElementCollisionsEnabled(plr, true)
        end
    end

    if self.hoseType == "fire" then
        self:renderFireHose()

    elseif self.hoseType == "water" then
        self:renderWaterHose()
    end

end

function FireHose:renderFireHose()
    if not getElementData(localPlayer, "firehose") then
        if self.state then
            self.state = nil
            setElementData(localPlayer, "fireButton", nil)
        end
        return
    end

    setPedWeaponSlot(localPlayer, 7)

    local water = self:getWaterInTank()
    if water <= 0 then
        if self.state then
            self.state = nil
            setElementData(localPlayer, "fireButton", nil)
        end
        return
    end

    if getKeyState("mouse1") then
        if not self.state then
            self.state = true
            setElementData(localPlayer, "fireButton", true)
        end
    else
        if self.state then
            self.state = nil
            setElementData(localPlayer, "fireButton", nil)
        end
    end

    if self.state then self:updateWaterInTank(water, -2) end
end

function FireHose:renderWaterHose()
    if getElementData(localPlayer, "hoseEndPos") then
        local water = self:getWaterInTank()
        self:updateWaterInTank(water, 1)
    end
end

function FireHose:update()
    for i, v in pairs(getElementsByType("player", root, true)) do
        if getElementData(v, "firehose") == "fire" then
            self:createFireTurret(v)
        end
    end

    for i, v in pairs(self.players) do
        if not isElementStreamedIn(i) or not isElement(i) or not getElementData(i, "firehose") then
            self:destroyFireTurret(i)
        end
    end
end

function FireHose:createFireTurret(plr)
    if self.players[plr] then return end
    self.players[plr] = {
        veh = createVehicle(601, 0, 0, 0),
        ped = createPed(0, 0, 0, 0)
    }

    setVehicleOverrideLights(self.players[plr].veh, 1)
    warpPedIntoVehicle(self.players[plr].ped, self.players[plr].veh)
    setElementCollisionsEnabled(self.players[plr].veh, false)
    setElementCollisionsEnabled(self.players[plr].ped, false)

    setElementAlpha(self.players[plr].veh, 0)
    setElementAlpha(self.players[plr].ped, 0)

    setElementData(self.players[plr].veh, "inv", true, false)
    setElementData(self.players[plr].ped, "inv", true, false)

    setElementData(self.players[plr].veh, "blockAction", true, false)
    setElementData(self.players[plr].ped, "blockAction", true, false)

    exports.bone_attach:attachElementToBone(self.players[plr].veh, plr, 12, 2.1, 0.1, -0.6, 68, 180, 90)
end

function FireHose:destroyFireTurret(plr)
    if not self.players[plr] then return end

    destroyElement(self.players[plr].veh)
    destroyElement(self.players[plr].ped)

    self.players[plr] = nil
end

function FireHose:plrTakeFireHose(veh, hoseType)
    if self.hoseVeh then return end

    local hoses = getElementData(veh, "hoses") or {}
    if self:getCount(hoses) >= 4 then exports.TR_noti:create("W pojeździe nie ma więcej węży.", "error") return end

    local index, hosePos = self:getHoseStartPosition(veh, hoses)
    if not index then return end

    self.hoseVeh = veh
    self.hoseType = hoseType

    if self.hoseType == "water" then
        exports.TR_interaction:updateInteraction("waterHose", true)
        exports.TR_objectManager:createHose(localPlayer, hosePos, "fire", 15)
    else
        exports.TR_interaction:updateInteraction("fireHose", true)
        exports.TR_objectManager:createHose(localPlayer, hosePos, "fire", 100)
        triggerServerEvent("givePlayerFireHose", resourceRoot)
    end

    setElementData(localPlayer, "blockAction", true)

    setElementData(localPlayer, "fireButton", nil)
    setElementData(localPlayer, "firehose", self.hoseType)

    hoses[index] = localPlayer
    setElementData(veh, "hoses", hoses)
end

function FireHose:plrTakeoutFireHose(veh)
    if not veh then return end

    if self.hoseType == "water" then
        exports.TR_interaction:updateInteraction("waterHose", nil)
    else
        exports.TR_interaction:updateInteraction("fireHose", nil)
        triggerServerEvent("takePlayerFireHose", resourceRoot)
    end

    setElementData(localPlayer, "blockAction", nil)

    setElementData(localPlayer, "fireButton", nil)
    setElementData(localPlayer, "firehose", nil)

    exports.TR_objectManager:removeHose(localPlayer)

    local hoses = getElementData(veh, "hoses") or {}
    for i, v in pairs(hoses) do
        if not isElement(v) or v == localPlayer then
            hoses[i] = nil
        end
    end
    setElementData(veh, "hoses", hoses)

    self.hoseVeh = nil
    self.hoseType = nil
end

function FireHose:getHoseStartPosition(veh, hoses)
    local vehPos = Vector3(getElementPosition(veh))
    local plrPos = Vector3(getElementPosition(localPlayer))

    local rot = self:findRotation(vehPos.x, vehPos.y, plrPos.x, plrPos.y)
    local _, _, vrot = getElementRotation(veh)
    rot = vrot - rot
    rot = rot < 0 and rot + 360 or rot
    if rot < 335 and rot >= 210 then
        if not isElement(hoses[1]) then return 1, self:getPosition(veh, Vector3(-0.9, -0.06, 0.2)) end
        if not isElement(hoses[2]) then return 2, self:getPosition(veh, Vector3(-0.9, -0.06, 0.4)) end

        exports.TR_noti:create("Wszystkie prądownice z tej strony są zajęte.", "error")
        return false, false

    elseif rot < 150 and rot >= 30 then
        if not isElement(hoses[3]) then return 3, self:getPosition(veh, Vector3(0.9, 0.15, 0.25)) end
        if not isElement(hoses[4]) then return 4, self:getPosition(veh, Vector3(0.9, -0.1, 0.25)) end

        exports.TR_noti:create("Wszystkie prądownice z tej strony są zajęte.", "error")
        return false, false
    end

    exports.TR_noti:create("Aby założyć wąż strażacki musisz stać przy prądownicy.", "info")
    return false, false
end

function FireHose:getPosition(element, vec)
	local rot = Vector3(getElementRotation(element))
	local mat = Matrix(Vector3(getElementPosition(element)), rot)
	local newPos = mat:transformPosition(vec)
	return Vector3(newPos.x, newPos.y, newPos.z)
end

function FireHose:findRotation(x1, y1, x2, y2)
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end

function FireHose:getCount(tb)
    local count = 0
    for i, v in pairs(tb) do
        if isElement(v) then
            count = count + 1
        else
            tb[i] = nil
        end
    end
    return count
end

function FireHose:getWaterInTank()
    if not self.hoseVeh then return 0 end
    local water = getElementData(self.hoseVeh, "waterTank")
    return water or 0
end

function FireHose:updateWaterInTank(water, num)
    if not self.hoseVeh or not water then return end
    setElementData(self.hoseVeh, "waterTank", math.max(math.min(water + num, 40000), 0))
end

guiInfo.hose = FireHose:create()




function plrTakeFireHose(veh, hoseType)
    guiInfo.hose:plrTakeFireHose(veh, hoseType)
end

function plrTakeoutFireHose(veh, blockHose)
    guiInfo.hose:plrTakeoutFireHose(veh)
end