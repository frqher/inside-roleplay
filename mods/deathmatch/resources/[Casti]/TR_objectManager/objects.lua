createdObjects = {}

function attachObjectToPlayer(plr, object)
    if not plr or not object then return false end
    if not createdObjects[plr] then createdObjects[plr] = {} end

    table.insert(createdObjects[plr], object)

    return true
end

function attachObjectToBone(plr, model, scale, ...)
    if not plr or not model then return end
    if not createdObjects[plr] then createdObjects[plr] = {} end

    local int = getElementInterior(plr)
    local dim = getElementDimension(plr)

    local object = createObject(model, 0, 0, 0)
    setElementInterior(object, int)
    setElementDimension(object, dim)
    setElementCollisionsEnabled(object, false)
    setObjectScale(object, scale)

    table.insert(createdObjects[plr], object)

    exports.bone_attach:attachElementToBone(object, plr, ...)
    return object
end

function removeObject(plr, model)
    if not createdObjects[plr] then return end

    local newObjects = {}
    for i, v in ipairs(createdObjects[plr]) do
        if isElement(v) then
            if getElementModel(v) == model then
                destroyElement(v)
            else
                table.insert(newObjects, v)
            end
        end
    end
    createdObjects[plr] = newObjects
    if #createdObjects[plr] < 1 then createdObjects[plr] = nil end
end


-- Triggers
function attachObjectToBoneTrigger(...)
    attachObjectToBone(client, ...)
end
addEvent("attachObjectToBone", true)
addEventHandler("attachObjectToBone", root, attachObjectToBoneTrigger)

function removeAttachedObjectTrigger(...)
    removeObject(client, ...)
end
addEvent("removeAttachedObject", true)
addEventHandler("removeAttachedObject", root, removeAttachedObjectTrigger)