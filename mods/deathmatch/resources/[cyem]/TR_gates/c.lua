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
    self.func.renderGates = function() self:renderGates() end
    self.func.streamIn = function(...) self:streamIn(source, ...) end
    self.func.streamOut = function(...) self:streamOut(source, ...) end

    addEventHandler("onClientRender", root, self.func.renderGates)
    addEventHandler("onClientElementStreamIn", root, self.func.streamIn)
    addEventHandler("onClientElementStreamOut", root, self.func.streamOut)

    setTimer(function()
        self:createGates()
    end, 1000, 1)
    return true
end

function GateSystem:renderGates()
    for i, v in pairs(self.gates) do
        if isElement(i) then
            local open = getElementData(i, "open")
            if open and v.state ~= "opening" and v.state ~= "opened" then
                self:openGate(i)

            elseif not open and v.state ~= "closing" and v.state ~= "closed" then
                self:closeGate(i)
            end

            self:renderGateAnim(i)
        else
            self.gates[i] = nil
        end
    end
end

function GateSystem:renderGateAnim(gate)
    local gateData = self.gates[gate]
    if not gateData.tick then return end

    if gateData.state == "opening" then
        local progress = (getTickCount() - gateData.tick)/gateInfo[gateData.model].openTime
        local x, y, z = interpolateBetween(gateData.defPos, gateData.openPos, progress, "Linear")
        local rx, ry, rz = interpolateBetween(gateData.defRot, gateData.openRot, progress, "Linear")

        setElementPosition(gate, x, y, z)
        setElementRotation(gate, rx, ry, rz)

        if progress >= 1 then
            gateData.state = "opened"
            gateData.tick = nil
        end

    elseif gateData.state == "closing" then
        local progress = (getTickCount() - gateData.tick)/gateInfo[gateData.model].closeTime
        local x, y, z = interpolateBetween(gateData.openPos, gateData.defPos, progress, "Linear")
        local rx, ry, rz = interpolateBetween(gateData.openRot, gateData.defRot, progress, "Linear")

        setElementPosition(gate, x, y, z)
        setElementRotation(gate, rx, ry, rz)

        if progress >= 1 then
            gateData.state = "closed"
            gateData.tick = nil
        end
    end
end

function GateSystem:openGate(gate)
    self.gates[gate].state = "opening"
    self.gates[gate].tick = getTickCount()
end

function GateSystem:closeGate(gate)
    self.gates[gate].state = "closing"
    self.gates[gate].tick = getTickCount()
end

function GateSystem:streamIn(source, ...)
    local model = getElementModel(source)
    if not gateInfo[model] then return end

    self:createGate(source)
end

function GateSystem:streamOut(source, ...)
    local model = getElementModel(source)
    if not gateInfo[model] then return end

    self.gates[source] = nil
end

function GateSystem:createGates()
    for _, gate in pairs(getElementsByType("object", resourceRoot, true)) do
        self:createGate(gate)
    end
end

function GateSystem:createGate(gate)
    if self.gates[gate] then return end
    if not isElement(gate) then return end
    local gateID = getElementData(gate, "gateID")
    local gateEdata = getElementData(gate, "gateData")

    if not gates[gateID] and not gateEdata then return end
    local gateData = gates[gateID] and gates[gateID] or {}

    if gateEdata then
        gateData.model = gateEdata.model
        gateData.pos = Vector3(gateEdata.defPos.x, gateEdata.defPos.y, gateEdata.defPos.z)
        gateData.rot = Vector3(gateEdata.defRot.x, gateEdata.defRot.y, gateEdata.defRot.z)
    end


    setElementPosition(gate, gateData.pos)
    setElementRotation(gate, gateData.rot)

    local openOffset = self:getPosition(gate, gateInfo[gateData.model].openOffset)
    local openRotOffset = gateInfo[gateData.model].openRotOffset

    self.gates[gate] = {
        state = "closed",
        model = gateData.model,
        defPos = gateData.pos,
        defRot = gateData.rot,
        openPos = openOffset,
        openRot = Vector3(gateData.rot.x + openRotOffset.x, gateData.rot.y + openRotOffset.y, gateData.rot.z + openRotOffset.z),
    }
end

function GateSystem:getPosition(element, vec)
	local rot = Vector3(getElementRotation(element))
	local mat = Matrix(Vector3(getElementPosition(element)), rot)
	local newPos = mat:transformPosition(vec)
	return Vector3(newPos.x, newPos.y, newPos.z), rot.z
end


GateSystem:create()

function getGatesModels()
    local gates = {}
    for i, v in pairs(gateInfo) do
        gates[i] = true
    end
    return gates
end