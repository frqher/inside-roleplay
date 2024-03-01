local settings = {
    maxDistance = 10,
    camera = getCamera(),
}

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
    self.func = {}
    self.func.render = function() self:render() end

    self.sphere = createColSphere(0, 0, 0, 20)
    attachElements(self.sphere, localPlayer)

    addEventHandler("onClientRender", root, self.func.render)
    return true
end

function GhostMode:updateCollisions(el, dist)
    if not el or not dist then return end
    local blockCollisions = getElementData(el, "blockCollisions")
    local owner = getElementData(el, "vehicleOwner")
    if el == self.plrVeh or owner == localPlayer then
        setElementAlpha(el, 255)
        setElementCollidableWith(el, localPlayer, true)
        return

    elseif not self.plrVeh then
        setElementAlpha(el, 255)
        return
    end

    if dist and (blockCollisions or self.isVehUncollidable) then
        if dist < settings.maxDistance then
            setElementAlpha(el, 255 * dist/settings.maxDistance)

            if getElementType(el) == "vehicle" then
                local occupants = getVehicleOccupants(el)
                if occupants then
                    for k, plr in pairs(occupants) do
                        setElementAlpha(plr, math.min(255 * dist/settings.maxDistance, 255))

                        setElementCollidableWith(localPlayer, plr, false)
                        if self.plrVeh then setElementCollidableWith(self.plrVeh, plr, false) end
                    end
                    if self.plrVeh then setElementCollidableWith(self.plrVeh, el, false) end
                else
                    if self.plrVeh then setElementCollidableWith(self.plrVeh, el, false) end
                end
            end
        else
            self:enableCollisions(el)
            return
        end
    end
end

function GhostMode:enableCollisions(el)
    setElementAlpha(el, 255)

    if getElementType(el) == "vehicle" then
        local occupants = getVehicleOccupants(el)
        if occupants then
            for k, plr in pairs(occupants) do
                setElementAlpha(plr, 255)

                setElementCollidableWith(localPlayer, plr, true)
                if self.plrVeh then setElementCollidableWith(self.plrVeh, plr, true) end
            end
            if self.plrVeh then setElementCollidableWith(self.plrVeh, el, true) end
        else
            if self.plrVeh then setElementCollidableWith(self.plrVeh, el, true) end
        end
    end
end

function GhostMode:getPlayerVehicle()
    self.plrVeh = getPedOccupiedVehicle(localPlayer)
    self.isVehUncollidable = nil
    if self.plrVeh then
        self.isVehUncollidable = getElementData(self.plrVeh, "blockCollisions")
    end
    setCameraClip(true, not (self.plrVeh and true or false))
end

function GhostMode:render()
    local plrs = getElementsWithinColShape(self.sphere, "player")
    local vehs = getElementsWithinColShape(self.sphere, "vehicle")
    self:getPlayerVehicle()

    local plrPos = Vector3(getElementPosition(localPlayer))
    for i, v in pairs(vehs) do
        if getElementData(v, "fullInv") then
            setElementAlpha(v, 0)
            setElementCollisionsEnabled(v, false)

            local occupants = getVehicleOccupants(v)
            if occupants then
                for k, plr in pairs(occupants) do
                    setElementAlpha(plr, 0)
                    setElementCollidableWith(localPlayer, plr, false)
                end
            end

        elseif getElementData(v, "inv") then
            if self.plrVeh ~= v then
                setElementAlpha(v, 0)
                setElementCollisionsEnabled(v, false)

                local occupants = getVehicleOccupants(v)
                if occupants then
                    for k, plr in pairs(occupants) do
                        setElementAlpha(plr, 0)
                        setElementCollidableWith(localPlayer, plr, false)
                    end
                end
            else
                setElementAlpha(v, 255)
                setElementCollisionsEnabled(v, true)
            end

        else
            local dist = getDistanceBetweenPoints3D(plrPos, Vector3(getElementPosition(v)))

            if self.plrVeh ~= v then
                self:updateCollisions(v, dist)
            end

            for _, k in pairs(vehs) do
                if getElementData(v, "blockCollisions") or getElementData(k, "blockCollisions") then
                    setElementCollidableWith(v, k, false)
                    setElementCollidableWith(k, v, false)
                else
                    setElementCollidableWith(v, k, true)
                    setElementCollidableWith(k, v, true)
                end
            end

            -- for _, k in pairs(plrs) do
            --     if getElementData(v, "blockCollisions") or getElementData(k, "blockCollisions") then
            --         if dist < settings.maxDistance then
            --             local occupants = getVehicleOccupants(v)
            --             if occupants then
            --                 for _, plr in pairs(occupants) do
            --                     setElementAlpha(plr, 255 * dist/settings.maxDistance)
            --                 end
            --             end

            --             setElementCollidableWith(v, k, false)
            --             setElementAlpha(v, 255 * dist/settings.maxDistance)
            --         else
            --             self:enableCollisions(v)
            --         end
            --     end
            -- end
        end
    end

    if self.plrVeh then
        if not getElementData(self.plrVeh, "fullInv") then
            setElementAlpha(self.plrVeh, 255)
            setElementAlpha(localPlayer, 255)
        end
    end

    for i, v in pairs(plrs) do
        if not getPedOccupiedVehicle(v) then
            if getElementData(v, "inv") then
                setElementAlpha(v, 0)
                setElementCollisionsEnabled(v, false)

            elseif getElementData(v, "OX") then
                setElementAlpha(v, 150)
                setElementCollidableWith(v, localPlayer, false)
                setElementCollisionsEnabled(v, false)

            elseif getElementData(v, "blockCollisions") then
                if v == localPlayer then
                    setElementAlpha(v, 255)
                    setElementCollidableWith(v, localPlayer, false)
                    setElementCollisionsEnabled(v, false)
                else
                    setElementAlpha(v, 150)
                    setElementCollidableWith(v, localPlayer, false)
                    setElementCollisionsEnabled(v, false)
                end

            else
                setElementAlpha(v, 255)

                if not getPedOccupiedVehicle(v) then
                    setElementFrozen(v, false)
                    setElementCollidableWith(v, localPlayer, true)
                    setElementCollisionsEnabled(v, true)
                end
            end
        end
    end
end

GhostMode:create()