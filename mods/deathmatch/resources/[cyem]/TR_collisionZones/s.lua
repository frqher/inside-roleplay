local colZones = {
}


function disableCollision(el, md)
    local data = colZones[getElementData(source, "colID")]
    if data.int ~= getElementInterior(el) or data.dim ~= getElementDimension(el) then return end

    if getElementType(el) == "player" then
        setElementData(el, "blockCollisions", true)
        setElementData(el, "OX", false)
    end
end

function enableCollision(el)
    if getElementType(el) == "player" then
        setElementData(el, "blockCollisions", false)
        setElementData(el, "OX", false)
    end
end

function createCols()
    for i, v in pairs(colZones) do
        local col = createColCuboid(v.pos, v.width, v.depth, v.height)
        setElementData(col, "colID", i, false)
    end

    addEventHandler("onColShapeHit", resourceRoot, disableCollision)
    addEventHandler("onColShapeLeave", resourceRoot, enableCollision)
end


createCols()