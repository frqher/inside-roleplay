local markerData = {
    pos = Vector3(-2406.0478515625, 688.6640625, 35.163604736328),
    icon = "landmower",
    int = 0,
    dim = 0,
    blip = true,
    data = {
        title = "Çim Biçme İşi",
        desc = "İşe başlamak için işaretleyiciye girin.",
    },
}

function onMarkerHit(el, md)
    if not el or not md then return end
    if el ~= localPlayer then return end
    if getElementType(el) ~= "player" then return end
    if getPedOccupiedVehicle(el) then return end

    local markerPos = Vector3(getElementPosition(source))
    local playerPos = Vector3(getElementPosition(localPlayer))
    if playerPos.z < markerPos.z - 0.5 or playerPos.z > markerPos.z + 2 then return end

    local resourceName = getResourceName(getThisResource())
    triggerServerEvent("getPlayerJobData", resourceRoot, resourceName)
end

function createStartMarker()
    local marker = createMarker(markerData.pos.x, markerData.pos.y, markerData.pos.z - 0.9, "cylinder", 1.2, 71, 180, 201, 0)
    setElementData(marker, "markerData", markerData.data, false)
    setElementData(marker, "markerIcon", markerData.icon, false)

    setElementInterior(marker, markerData.int)
    setElementDimension(marker, markerData.dim)

    if markerData.blip then
        local blip = createBlip(markerData.pos, 0, 2, 71, 180, 201)
        setElementData(blip, "icon", 30, false)
        setElementData(blip, "blipName", markerData.data.title, false)
    end

    addEventHandler("onClientMarkerHit", marker, onMarkerHit)
end

createStartMarker()