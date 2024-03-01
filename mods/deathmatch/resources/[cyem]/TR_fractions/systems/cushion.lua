local settings = {
    model = 1856,

    riseTime = 30000,
    maxSize = 4,
}

CushionSystem = {}
CushionSystem.__index = CushionSystem

function CushionSystem:create()
    local instance = {}
    setmetatable(instance, CushionSystem)
    if instance:constructor() then
        return instance
    end
    return false
end

function CushionSystem:constructor()
    self.objects = {}

    self.func = {}
    self.func.update = function() self:update() end
    self.func.render = function() self:render() end
    self.func.blockFallDmg = function(...) self:blockFallDmg(...) end

    self:update()
    setTimer(self.func.update, 1000, 0)
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientPlayerDamage", localPlayer, self.func.blockFallDmg)
    return true
end

function CushionSystem:animate(obj, v)
    if v.state == "opening" then
        local progress = (getTickCount() - v.tick)/settings.riseTime
        local scale, pos = interpolateBetween(1, 0, 0, settings.maxSize, 0.58, 0, progress, "Linear")

        if progress >= 1 then
            scale = settings.maxSize

            v.state = "opened"
            v.tick = nil

            setElementCollisionsEnabled(obj, true)
        else
            setElementCollisionsEnabled(obj, false)
        end
        setObjectScale(obj, scale)
        setElementPosition(obj, v.pos.x, v.pos.y, v.pos.z + pos)
    end
end

function CushionSystem:render()
    for i, v in pairs(self.objects) do
        if isElement(i) then
            self:animate(i, v)
        end
    end
end

function CushionSystem:update()
    for i, v in pairs(getElementsByType("object", resourceRoot, true)) do
        local model = getElementModel(v)
        if model == settings.model and not getElementData(v, "action") and not self.objects[v] then
            self.objects[v] = {
                tick = getTickCount(),
                state = "opening",
                pos = Vector3(getElementPosition(v))
            }
        end
    end

    for i, v in pairs(self.objects) do
        if not isElement(i) then
            self.objects[i] = nil
        end
    end
end

function CushionSystem:blockFallDmg(att, weap, body)
    if weap == 54 then
        local pos = Vector3(getElementPosition(localPlayer))
        local hit, _, _, _, element = processLineOfSight(pos, pos.x, pos.y, pos.z - 5, true, true, true, true, true, false, false, false, localPlayer)
        if hit then
            if isElement(element) then
                if getElementModel(element) == settings.model then
                    setPedAnimation(localPlayer, "ped", "ko_skid_back", -1, false, false, false, true, 250)
                    setTimer(setPedAnimation, 800, 1, localPlayer, "ped", "getup_front", -1, false, false, false, false, 250)
                    cancelEvent()
                end
            end
        end
    end
end

CushionSystem:create()