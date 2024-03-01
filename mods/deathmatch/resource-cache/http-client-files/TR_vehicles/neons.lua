local settings = {
    maxDistance = 60,
    groundOffset = 0.02,
}

Neons = {}
Neons.__index = Neons

function Neons:create()
    local instance = {}
    setmetatable(instance, Neons)
    if instance:constructor() then
        return instance
    end
    return false
end

function Neons:constructor()
    self.percentTick = getTickCount()
    self.neonCol = createColSphere(0, 0, 0, settings.maxDistance)
    attachElements(self.neonCol, localPlayer)

    self.func = {}
    self.func.preRender = function() self:preRender() end

    self.textures = {}
    self.textures.neon = dxCreateTexture("files/images/neon.png", "dxt3", true, "clamp")
    self.textures.valentine = dxCreateTexture("files/images/valentineNeon.png", "dxt3", true, "clamp")
    self.textures.easter = dxCreateTexture("files/images/easter.png", "dxt3", true, "clamp")

    addEventHandler("onClientPreRender", root, self.func.preRender)
    return true
end

function Neons:preRender()
    local x, y = getCameraMatrix()
    local plrPos = Vector2(x, y)
    local vehs = getElementsWithinColShape(self.neonCol, "vehicle")

    for i, v in pairs(vehs) do
        if isElement(v) then
            local vehPos = Vector3(getElementPosition(v))
            if isElementStreamedIn(v) and getDistanceBetweenPoints2D(plrPos, vehPos) < settings.maxDistance then
                local visualTuning = getElementData(v, "visualTuning")

                if getElementData(v, "neonEnabled") then
                    self:renderNeon(visualTuning, v, vehPos)
                    self:takeNeonPercent(visualTuning, v)
                end
            end
        end
    end
end

function Neons:takeNeonPercent(visualTuning, veh)
    if getPedOccupiedVehicle(localPlayer) ~= veh then self.percentTick = nil return end
    if getPedOccupiedVehicleSeat(localPlayer) ~= 0 then self.percentTick = nil return end

    if not self.percentTick then
        self.percentTick = getTickCount()
        return
    end

    if (getTickCount() - self.percentTick)/60000 >= 1 then
        local percent = visualTuning.neon[5] or 100
        visualTuning.neon[4] = percent - 0.5
        triggerServerEvent("removeNeonFromVehicle", resourceRoot, veh, visualTuning.neon[4])

        self.percentTick = getTickCount()
    end
end

function Neons:renderNeon(visualTuning, veh, pos)
    if not visualTuning then return end
    if not visualTuning.neon then return end

    local x, y, z, w, l, h = getElementBoundingBox(veh)

    if visualTuning.neon[1] == 1 then
        self:drawFrontBackNeons("neon", veh, pos, visualTuning, x, y, z, w, l, h)

    elseif visualTuning.neon[1] == 2 then
        self:drawSideNeons("neon", veh, pos, visualTuning, x, y, z, w, l, h)

    elseif visualTuning.neon[1] == 3 then
        self:drawSideNeons("neon", veh, pos, visualTuning, x, y, z, w, l, h)
        self:drawFrontBackNeons("neon", veh, pos, visualTuning, x, y, z, w, l, h)

    elseif visualTuning.neon[1] == 4 then
        self:drawSideNeons("valentine", veh, pos, {neon={4, 255, 255, 255}}, x, y, z, w, l, h)

    elseif visualTuning.neon[1] == 5 then
        self:drawSideNeons("easter", veh, pos, {neon={5, 255, 255, 255}}, x, y, z, w, l, h)
    end
end

function Neons:drawSideNeons(graphic, veh, pos, visualTuning, x, y, z, w, l, h)
    self:drawSideNeon(graphic, veh, pos, visualTuning, (h-y)/4, Vector3((h-y)/5, -(w-x)/3 * 2, 0), Vector3((h-y)/5, (w-x)/3 * 2, 0))
    self:drawSideNeon(graphic, veh, pos, visualTuning, (h-y)/4, Vector3(-(h-y)/5, -(w-x)/3 * 2, 0), Vector3(-(h-y)/5, (w-x)/3 * 2, 0))
end

function Neons:drawFrontBackNeons(graphic, veh, pos, visualTuning, x, y, z, w, l, h)
    self:drawSideNeon(graphic, veh, pos, visualTuning, (w-x)/3, Vector3((w-x)/2, (h-y)/2, 0), Vector3(-(w-x)/2, (h-y)/2, 0))
    self:drawSideNeon(graphic, veh, pos, visualTuning, (w-x)/3, Vector3((w-x)/2, -(h-y)/2, 0), Vector3(-(w-x)/2, -(h-y)/2, 0))
end

function Neons:drawSideNeon(graphic, veh, pos, visualTuning, size, vec, vecMin)
    local fx, fy = self:getPosition(veh, vec)
    local fz = getGroundPosition(fx, fy, pos.z) + settings.groundOffset

    local bx, by = self:getPosition(veh, vecMin)
    local bz = getGroundPosition(bx, by, pos.z) + settings.groundOffset

    local mg = (fz + bz)/2
    local dist = pos.z - mg
    local alpha = 1 - math.min(math.max(dist - 1, 0)/5, 1)

    dxDrawMaterialLine3D(fx, fy, fz, bx, by, bz, self.textures[graphic], size * 1.2, tocolor(visualTuning.neon[2], visualTuning.neon[3], visualTuning.neon[4], 180 * alpha), fx, fy, fz + 1)
end

function Neons:getPosition(element, vec)
	local rot = Vector3(getElementRotation(element))
	local mat = Matrix(Vector3(getElementPosition(element)), rot)
	local newPos = mat:transformPosition(vec)
	return newPos.x, newPos.y, newPos.z, rot.z
end



Neons:create()