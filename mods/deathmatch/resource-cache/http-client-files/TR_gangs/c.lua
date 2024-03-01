local data = {
    points = {},
    markers = {},
}



function getNum(num)
    return tonumber(string.format("%.2f", num))
end

function addPoint()
    local pos = Vector3(getElementPosition(localPlayer))

    if #data.points == 0 then
        table.insert(data.points, Vector2(getNum(pos.x), getNum(pos.y)))
        table.insert(data.points, Vector2(getNum(pos.x), getNum(pos.y)))
    else
        table.insert(data.points, Vector2(getNum(pos.x), getNum(pos.y)))
    end

    outputConsole(string.format("Vector3(%.2f, %.2f, %.2f),", pos.x, pos.y, pos.z))

    -- local marker = createMarker(pos.x, pos.y, pos.z, "checkpoint", 1.2, 255, 255, 255, 255)
    -- table.insert(data.markers, marker)
    updateCol()
end
addCommandHandler("ap", addPoint)

function updateCol()
    if #data.points < 5 then return end
    if isElement(data.col) then destroyElement(data.col) end

    data.col = createColPolygon(unpack(data.points))
end

function clear()
    for i, v in pairs(data.markers) do
        destroyElement(v)
    end
    if isElement(data.col) then destroyElement(data.col) end
    data.points = {}
    outputConsole("==========================")
end
addCommandHandler("end", clear)