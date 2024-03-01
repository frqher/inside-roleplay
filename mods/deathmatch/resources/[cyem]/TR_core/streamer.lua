Streamer = {}
Streamer.__index = Streamer

function Streamer:create()
    local instance = {}
    setmetatable(instance, Streamer)
    if instance:constructor() then
        return instance
    end
    return false
end

function Streamer:constructor()
    self.streamedObjects = {}
    self.streamedVehicles = {}
    self.cigarettes = {}
    self.barbells = {}
    self.objects = {}

    self.func = {}
    self.func.inStreamer = function() self:streamIn(source) end
    self.func.outStreamer = function() self:streamOut(source) end
    self.func.update = function() self:update() end
    -- self.func.render = function() self:render() end

    addEventHandler("onClientElementStreamIn", root, self.func.inStreamer)
    addEventHandler("onClientElementStreamOut", root, self.func.outStreamer)
    -- addEventHandler("onClientRender", root, self.func.render)

    self:stream()
    return true
end

-- function Streamer:render()
--     dxDrawText(inspect(self.streamedObjects), 1000, 0)
-- end

function Streamer:stream()
    for _, v in pairs(getElementsByType("player"), getRootElement(), true) do
        self:streamIn(v)
    end
    for _, v in pairs(getElementsByType("ped"), getRootElement(), true) do
        self:streamIn(v)
    end
    for _, v in pairs(getElementsByType("vehicle"), getRootElement(), true) do
        self:streamIn(v)
    end

    setTimer(self.func.update, 1000, 0)
end

function Streamer:streamIn(element)
    if source then element = source end

    if not isElement(element) then
        self:streamOut(element)
        return
    end

    local type = getElementType(element)
    if type == "player" or type == "ped" then
        local anim = getElementData(element, "animation")
        if not anim then
            if self.streamedObjects[element] then
                if self.streamedObjects[element][1] == "carry" and self.streamedObjects[element][2] == "crry_prtial" then
                    setPedAnimation(element, "ped", "idle_gang1")
                else
                    setPedAnimation(element, nil, nil)
                end
            else
                setPedAnimation(element, nil, nil)
            end

            self.streamedObjects[element] = {}
            return
        end

        local anim = {string.lower(anim[1]), string.lower(anim[2]), anim[3], anim[4], anim[5]}
        local currBlock, currAnim = getPedAnimation(element)
        if currBlock and currAnim then
            currBlock, currAnim = string.lower(currBlock), string.lower(currAnim)
        end

        if type == "player" and not currBlock and not currAnim and not anim then
            setPedAnimation(element, nil, nil)
            self.streamedObjects[element] = {}
            return
        end

        if currBlock ~= anim[1] or currAnim ~= anim[2] then
            if anim[1] == "carry" and anim[2] == "crry_prtial" then
                setPedAnimation(element, "carry", "crry_prtial", 1, true)
            else
                setPedAnimation(element, anim[1], anim[2], -1, not anim[3], anim[4], true, anim[5])
            end
        end
        self.streamedObjects[element] = {anim[1], anim[2]}

        if anim[1] == "smoking" then self:createCigarette(element) end
        if anim[1] == "benchpress" then
            if anim[2] == "gym_bp_up_smooth" or anim[2] == "gym_bp_down" then
                self:createBenchPress(element)
            end
        end

    elseif type == "vehicle" then
        self.streamedVehicles[element] = element
    end
end

function Streamer:checkTowedVehicle(veh)
    local trailer = getVehicleTowedByVehicle(veh)
    if not trailer then return end

    if getDistanceBetweenPoints3D(Vector3(getElementPosition(localPlayer)), Vector3(getElementPosition(veh))) > 100 then
        detachTrailerFromVehicle(veh, trailer)
        setTimer(attachTrailerToVehicle, 100, 1, veh, trailer)
    end
end

function Streamer:streamOut(element)
    if self.streamedObjects[element] then
        self.streamedObjects[element] = nil

        if isElement(element) then
            setPedAnimation(element, nil, nil)
            self:removeCigarette(element)
            self:removeBenchPress(element)
        end
    end
    if self.streamedVehicles[element] then
        self.streamedVehicles[element] = nil
    end
end

function Streamer:update()
    for i, v in pairs(self.streamedObjects) do
        self:removeCigarette(i)
        self:removeBenchPress(i)
        self:streamIn(i)
    end
    for i, v in pairs(self.streamedVehicles) do
        if not isElement(v) then
            self.streamedVehicles[v] = nil
        else
            self:checkTowedVehicle(v)
        end
    end
end

function Streamer:createCigarette(element)
    if self.cigarettes[element] then return end
    local pos = Vector3(getElementPosition(element))
    local int = getElementInterior(element)
    local dim = getElementDimension(element)

    self.cigarettes[element] = {
        cigarette = createObject(3027, pos.x, pos.y, pos.z),
        smoke = createObject(1485, pos.x, pos.y, pos.z),
    }
    setElementInterior(self.cigarettes[element].smoke, int)
    setElementDimension(self.cigarettes[element].smoke, dim)
    setElementInterior(self.cigarettes[element].cigarette, int)
    setElementDimension(self.cigarettes[element].cigarette, dim)

    attachElements(self.cigarettes[element].smoke, self.cigarettes[element].cigarette, -0.19, 0.02, 0.1)
    setElementAlpha(self.cigarettes[element].smoke, 0)

    exports.bone_attach:attachElementToBone(self.cigarettes[element].cigarette, element, 12, -0.06, 0.025, 0.09, 0, 120, 0)
end

function Streamer:removeCigarette(element)
    if not self.cigarettes[element] then return end
    local toRemove = false
    if not isElement(element) then
        toRemove = true
    else
        local anim = getElementData(element, "animation")
        if not anim or anim[1] ~= "smoking" then toRemove = true end
    end

    if not toRemove then return end
    exports.bone_attach:detachElementFromBone(self.cigarettes[element].cigarette)
    destroyElement(self.cigarettes[element].cigarette)
    destroyElement(self.cigarettes[element].smoke)
    self.cigarettes[element] = nil
    return
end

function Streamer:createBenchPress(element)
    if self.barbells[element] then return end
    local pos = Vector3(getElementPosition(element))
    local int = getElementInterior(element)
    local dim = getElementDimension(element)

    self.barbells[element] = {
        barbell = createObject(2913, pos.x, pos.y, pos.z),
    }
    setElementInterior(self.barbells[element].barbell, int)
    setElementDimension(self.barbells[element].barbell, dim)

    exports.bone_attach:attachElementToBone(self.barbells[element].barbell, element, 12, 0.1, 0, 0, 0, 270, 0)
    return
end

function Streamer:removeBenchPress(element)
    if not self.barbells[element] then return end
    local toRemove = false
    if not isElement(element) then
        toRemove = true
    else
        local anim = getElementData(element, "animation")
        if not anim or anim[1] ~= "benchpress" or (anim[2] ~= "gym_bp_up_smooth" and anim[2] ~= "gym_bp_down") then toRemove = true end
    end

    if not toRemove then return end
    exports.bone_attach:detachElementFromBone(self.barbells[element].barbell)
    destroyElement(self.barbells[element].barbell)
    self.barbells[element] = nil
    return
end

Streamer:create()