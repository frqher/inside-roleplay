local sx, sy = guiGetScreenSize()
local guiInfo = {}

Events = {}
Events.__index = Events

function Events:create()
    local instance = {}
    setmetatable(instance, Events)
    if instance:constructor() then
        return instance
    end
    return false
end

function Events:constructor()
    self.objects = {}

    self.func = {}
    self.func.checkObjects = function() self:checkObjects() end

    setTimer(self.func.checkObjects, 1000, 0)
    self:checkObjects()
    return true
end

function Events:removeObjects()
    for i, v in pairs(self.objects) do
        if isElement(v) then destroyElement(v) end
    end
end

function Events:checkObjects()
    for i, v in pairs(getElementsByType("fire")) do
        if not self.objects[v] then
            self.objects[v] = {
                fire = createEffect("fire_large", Vector3(getElementPosition(v)), 0, 0, 0, 1000),
                smoke = i%20 == 0 and createEffect("smoke50lit", Vector3(getElementPosition(v)), 0, 0, 0, 1000) or nil,
                hp = 15,
            }
        end
    end


    local plrModel = getElementModel(localPlayer)
    local targetPos = Vector3(getPedTargetEnd(localPlayer))
    local playerPos = Vector3(getElementPosition(localPlayer))
    local nearWater = {}

    for i, v in pairs(self.objects) do
        if not isElement(i) and self.objects[i] then
            if isElement(v.fire) then destroyElement(v.fire) end
            if isElement(v.smoke) then destroyElement(v.smoke) end
        else
            if plrModel ~= 277 and plrModel ~= 278 then
                if getDistanceBetweenPoints3D(playerPos, Vector3(getElementPosition(v.fire))) < 2 then
                    setPedOnFire(localPlayer, true)
                end
            end

            if getDistanceBetweenPoints3D(targetPos, Vector3(getElementPosition(v.fire))) < 5 then
                nearWater[i] = v
            end
        end
    end

    if getElementData(localPlayer, "firehose") then
        if getElementData(localPlayer, "fireButton") then
            for i, v in pairs(nearWater) do
                v.hp = v.hp - 1

                if v.hp <= 0 then
                    if isElement(v.fire) then destroyElement(v.fire) end
                    if isElement(v.smoke) then destroyElement(v.smoke) end

                    self.objects[i] = nil
                    triggerServerEvent("extinguishFire", resourceRoot, i)
                end
            end
        end
    end
end

function Events:updateEvents(...)

end




guiInfo.system = Events:create()

function updateFractionEvents(...)
    guiInfo.system:updateEvents(...)
end
addEvent("updateFractionEvents", true)
addEventHandler("updateFractionEvents", root, updateFractionEvents)