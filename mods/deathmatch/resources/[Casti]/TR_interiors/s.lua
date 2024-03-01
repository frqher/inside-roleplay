InteriorSystem = {}
InteriorSystem.__index = InteriorSystem

function InteriorSystem:create()
    local instance = {}
    setmetatable(instance, InteriorSystem)
    if instance:constructor() then
        return instance
    end
    return false
end

function InteriorSystem:constructor()
    self:createMarkers()

    return true
end

function InteriorSystem:createMarkers()
    for i, v in pairs(interiors) do
        if v.enter then
            local pos = v.enter.pos
            local color = v.enter.color
            local enterMarker = createMarker(pos.x, pos.y, pos.z - 1, "cylinder", 1.2, color[1], color[2], color[3], 0)
            setElementInterior(enterMarker, v.enter.int)
            setElementDimension(enterMarker, v.enter.dim)
            setElementData(enterMarker, "markerIcon", v.icon)
            if v.time then setElementData(enterMarker, "interiorTime", v.time) end
            setElementData(enterMarker, "interiorID", i)

            if v.blip then
                local blip = createBlip(pos.x, pos.y, pos.z, 0, 0, color[1], color[2], color[3], 255)
                setElementData(blip, "icon", v.blip)

                if v.data then
                    setElementData(blip, "blipName", v.data.title)
                end
            end
            if v.data then
                setElementData(enterMarker, "markerData", {
                    title = v.data.title and v.data.title or "",
                    desc = v.data.desc and v.data.desc or "",
                    noCollisions = v.data.noCollisions or nil,
                })
            end
        end

        if v.exit then
            local pos = v.exit.pos
            local color = v.exit.color
            local exitMarker = createMarker(pos.x, pos.y, pos.z - 1, "cylinder", 1.2, color[1], color[2], color[3], 0)
            setElementInterior(exitMarker, v.exit.int)
            setElementDimension(exitMarker, v.exit.dim)
            setElementData(exitMarker, "interiorID", i)

            if v.enter then
                if v.enter.int == 0 and v.enter.dim == 0 then
                    setElementData(exitMarker, "markerIcon", v.icon.."-exit")
                else
                    setElementData(exitMarker, "markerIcon", v.icon.."-exitInt")
                end
            end
        end
    end
end

function InteriorSystem:useMarker(...)
    if arg[3] then
        local id = getElementData(arg[2], "interiorID")
        local data = interiors[id].enter
        setElementPosition(arg[1], data.pos.x, data.pos.y, data.pos.z)
        setElementInterior(arg[1], data.int)
        setElementDimension(arg[1], data.dim)
        removeElementData(arg[1], "characterQuit")

        self:updateAttachments(arg[1], data, "Yükleniyor..", arg[5])

    else
        local id = getElementData(arg[2], "interiorID")
        local data = interiors[id].exit
        setElementPosition(arg[1], data.pos.x, data.pos.y, data.pos.z)
        setElementInterior(arg[1], data.int)
        setElementDimension(arg[1], data.dim)

        if arg[4] then
            local enter = interiors[id].enter
            setElementData(arg[1], "characterQuit", {enter.pos.x, enter.pos.y, enter.pos.z, enter.int, enter.dim})
        end

        self:updateAttachments(arg[1], data, "Yükleniyor..", arg[5])
    end
end

function InteriorSystem:updateAttachments(plr, data, text, time)
    local attached = getAttachedElements(plr)
    if attached then
        for i, v in pairs(attached) do
            if getElementType(v) == "player" then triggerClientEvent(v, "setInteriorLoading", resourceRoot, text, time) end
            setElementPosition(v, data.pos.x, data.pos.y, data.pos.z)
            setElementInterior(v, data.int)
            setElementDimension(v, data.dim)
        end
    end
end

local interior = InteriorSystem:create()
function interiorUse(marker, isExit, haveTime, loadTime)
    interior:useMarker(client, marker, isExit, haveTime, loadTime)
end
addEvent("interiorUse", true)
addEventHandler("interiorUse", resourceRoot, interiorUse)