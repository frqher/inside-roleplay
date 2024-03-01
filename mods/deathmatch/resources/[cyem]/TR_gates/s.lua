GateSystem = {}
GateSystem.__index = GateSystem

function GateSystem:create()
    local instance = {}
    setmetatable(instance, GateSystem)
    if instance:constructor() then
        return instance
    end
    return false
end

function GateSystem:constructor()
    self.gates = {}

    self.func = {}
    self.func.enterCol = function(...) self:enterCol(source, ...) end

    addEventHandler("onColShapeHit", resourceRoot, self.func.enterCol)
    self:createGates()
    return true
end

function GateSystem:createGates()
    for i, v in pairs(gates) do
        local gate = createObject(v.model, v.pos.x, v.pos.y, v.pos.z, v.rot.x, v.rot.y, v.rot.z)
        self.gates[gate] = {}
        setElementData(gate, "gateID", i)
        if v.scale then setObjectScale(gate, v.scale) end
        if v.customModel then setElementData(gate, "customModel", v.customModel) end
    end
end

function GateSystem:createGate(model, pos, rot, scale, gateID)
    local gate = createObject(model, pos.x, pos.y, pos.z, rot.x, rot.y, rot.z)
    self.gates[gate] = {}
    setElementData(gate, "gateID", gateID)
    return gate
end

function GateSystem:switchGate(plr, gate, state)
    if not self.gates[gate] then return end
    if not self:canInteractGate(gate, plr) then
        exports.TR_noti:create(plr, "Bu kapıya anahtarınız yok.", "error")
        return
    end

    if self.gates[gate].tick then
        if (getTickCount() - self.gates[gate].tick)/self.gates[gate].blockTime <= 1 then return end
    end
    self.gates[gate].tick = getTickCount()

    if state == "open" then
        setElementData(gate, "open", true)
        self.gates[gate].blockTime = gateInfo[getElementModel(gate)].openTime
    else
        removeElementData(gate, "open")
        self.gates[gate].blockTime = gateInfo[getElementModel(gate)].closeTime
    end
end

function GateSystem:canInteractGate(gate, plr)
    local gateID = getElementData(gate, "gateID")
    local permission = gates[gateID].permission
    if not permission then return true end

    if permission.type == "fraction" then
        local characterDuty = getElementData(plr, "characterDuty")
        if not characterDuty then return false end
        if characterDuty[4] == permission.value then return true end
        return true
    end
    return false
end

local system = GateSystem:create()

function switchGate(plr, gate, state)
    system:switchGate(plr, gate, state)
end

function createGate(...)
    return system:createGate(...)
end



function switchGateTrigger(gate, state)
    switchGate(client, gate, state)
    triggerClientEvent(client, "updateInteraction", resourceRoot)
end
addEvent("switchGate", true)
addEventHandler("switchGate", root, switchGateTrigger)


