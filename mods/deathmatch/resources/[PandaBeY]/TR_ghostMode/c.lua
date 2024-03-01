GhostMode = {}
GhostMode.__index = GhostMode

function GhostMode:create()
    local instance = {}
    setmetatable(instance, GhostMode)
    if instance:constructor() then
        return instance
    end
    return false
end

function GhostMode:constructor()
    self.streamed = {
        players = {
            all = {},
            col = {},
            noCol = {},
        },

        vehicles = {
            all = {},
            col = {},
            noCol = {},
        },
    }

    self.func = {}
    self.func.render = function() self:render() end
    self.func.onChange = function(...) self:onChange(source, ...) end
    self.func.streamObject = function(...) self:streamObject(source, ...) end
    self.func.unstreamObject = function(...) self:unstreamObject(source, ...) end
    self.func.destroyObject = function(...) self:destroyObject(source, ...) end

    self:streamObjects()
    -- addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientElementDestroy", root, self.func.destroyObject)
    addEventHandler("onClientElementStreamIn", root, self.func.streamObject)
    addEventHandler("onClientElementStreamOut", root, self.func.unstreamObject)
    addEventHandler("onClientElementDataChange", root, self.func.onChange)
    return true
end

function GhostMode:destroyObject(el)
    self.streamed.players.all[el] = nil
    self.streamed.players.col[el] = nil
    self.streamed.players.noCol[el] = nil

    self.streamed.vehicles.all[el] = nil
    self.streamed.vehicles.col[el] = nil
    self.streamed.vehicles.noCol[el] = nil
end

function GhostMode:onChange(el)
    local type = getElementType(el)
    if type == "player" then
        self:checkPlayerColisions(el)
        self:updateCollisions(el, "player")

    elseif type == "vehicle" then
        self:checkVehicleColisions(el)
        self:updateCollisions(el, "vehicle")
    end
end

function GhostMode:streamObjects()
    for i, v in pairs(getElementsByType("player", root, true)) do
        self:streamObject(v, true)
    end
    for i, v in pairs(getElementsByType("vehicle", root, true)) do
        self:streamObject(v, true)
    end
end

function GhostMode:streamObject(el, blockUpdate)
    local type = getElementType(el)
    if type == "player" then
        if self.streamed.players.all[el] then return end
        self.streamed.players.all[el] = el
        self:checkPlayerColisions(el)

        self:updateCollisions(el, "player")
        -- addEventHandler("onClientElementDataChange", el, self.func.onChange)

    elseif type == "vehicle" then
        if self.streamed.vehicles.all[el] then return end
        self.streamed.vehicles.all[el] = el
        self:checkVehicleColisions(el)

        self:updateCollisions(el, "vehicle")
        -- addEventHandler("onClientElementDataChange", el, self.func.onChange)
    end
end

function GhostMode:unstreamObject(el)
    local type = getElementType(el)
    if type == "player" then
        if not self.streamed.players.all[el] then return end
        self.streamed.players.all[el] = nil
        self.streamed.players.col[el] = nil
        self.streamed.players.noCol[el] = nil
        -- removeEventHandler("onClientElementDataChange", el, self.func.onChange)

    elseif type == "vehicle" then
        if not self.streamed.vehicles.all[el] then return end
        self.streamed.vehicles.all[el] = nil
        self.streamed.vehicles.col[el] = nil
        self.streamed.vehicles.noCol[el] = nil
        -- removeEventHandler("onClientElementDataChange", el, self.func.onChange)
    end
end

function GhostMode:checkPlayerColisions(el)
    local plrStretch = getElementData(el, "plrStretch")

    if getElementData(el, "inv") then
        self.streamed.players.noCol[el] = true
        self.streamed.players.col[el] = nil
        setElementAlpha(el, 0)

    elseif getElementData(el, "OX") or getElementData(el, "blockCollisions") then
        self.streamed.players.noCol[el] = true
        self.streamed.players.col[el] = nil
        setElementAlpha(el, 150)

    elseif getElementData(el, "isWorkouting") then
        self.streamed.players.noCol[el] = true
        self.streamed.players.col[el] = nil

    elseif isElement(plrStretch) and isElementAttached(plrStretch) then
        setElementCollisionsEnabled(el, false)
        self.streamed.players.noCol[el] = true
        self.streamed.players.col[el] = nil
        setElementAlpha(el, 255)

    else
        setElementCollisionsEnabled(el, true)
        self.streamed.players.noCol[el] = nil
        self.streamed.players.col[el] = true
        setElementAlpha(el, 255)
    end
end

function GhostMode:checkVehicleColisions(el)
    if getElementData(el, "blockCollisions") then
        self.streamed.vehicles.noCol[el] = true
        self.streamed.vehicles.col[el] = nil
        setElementAlpha(el, 200)

    elseif getElementData(el, "raceVehicle") then
        self.streamed.vehicles.noCol[el] = true
        self.streamed.vehicles.col[el] = nil

    elseif getElementData(el, "inv") then
        setElementCollisionsEnabled(el, false)
        self.streamed.vehicles.noCol[el] = true
        self.streamed.vehicles.col[el] = nil
        setElementAlpha(el, 0)

    else
        self.streamed.vehicles.noCol[el] = nil
        self.streamed.vehicles.col[el] = true
        setElementAlpha(el, 255)
    end
end

function GhostMode:updateCollisions(el, type)
    if type == "player" then
        if self.streamed.players.noCol[el] then
            for plr, _ in pairs(self.streamed.players.all) do
                if isElement(plr) then
                    setElementCollidableWith(el, plr, false)
                else
                    self:destroyObject(plr)
                end
            end

        elseif self.streamed.players.col[el] then
            for plr, _ in pairs(self.streamed.players.col) do
                if isElement(plr) then
                    setElementCollidableWith(el, plr, true)
                else
                    self:destroyObject(plr)
                end
            end
            for plr, _ in pairs(self.streamed.players.noCol) do
                if isElement(plr) then
                    setElementCollidableWith(el, plr, false)
                else
                    self:destroyObject(plr)
                end
            end
        end

    elseif type == "vehicle" then
        if self.streamed.vehicles.noCol[el] then
            for veh, _ in pairs(self.streamed.vehicles.all) do
                if isElement(veh) then
                    setElementCollidableWith(el, veh, false)
                else
                    self:destroyObject(veh)
                end
            end

        elseif self.streamed.vehicles.col[el] then
            for veh, _ in pairs(self.streamed.vehicles.col) do
                if isElement(veh) then
                    setElementCollidableWith(el, veh, true)
                else
                    self:destroyObject(veh)
                end
            end
            for veh, _ in pairs(self.streamed.vehicles.noCol) do
                if isElement(veh) then
                    setElementCollidableWith(el, veh, false)
                else
                    self:destroyObject(veh)
                end
            end
        end
    end
end

function GhostMode:render()
    dxDrawText(inspect(self.streamed), 500, 10)
end

GhostMode:create()