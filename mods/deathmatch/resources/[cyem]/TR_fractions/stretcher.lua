local settings = {
    -- stretcher = 1936,
    stretcher = 1936,
    stretcherBig = 1938,

    vehicleOffset = Vector3(0, -1.8, 0),
    placeOffset = Vector3(0, 1.4, -0.5),
}

function addVehicleStretcher(veh, plr)
    local stretch = createObject(settings.stretcher, 0, 0, 0)
    setElementDoubleSided(stretch, true)
    setElementCollisionsEnabled(stretch, false)
    attachElements(stretch, veh, settings.vehicleOffset)

    setElementData(veh, "stretch", stretch)
    setElementData(stretch, "stretchVeh", veh)

    if plr then
        local plrOnStretch = getElementData(plr, "plrOnStretch")
        if plrOnStretch then
            detachElements(plrOnStretch, plr)
            setTimer(placePlayerOnStretch, 100, 1, plrOnStretch, stretch)
            removeElementData(plr, "plrOnStretch")
        end
    end
end

function removeVehicleStretch(veh, plr)
    local stretch = getElementData(veh, "stretch")
    if not isElement(stretch) then return end

    pickupStretch(stretch)
    removeElementData(veh, "stretch")

    local weapons = getElementData(plr, "fakeWeapons")
    if weapons then
        table.insert(weapons, "stretch")
    else
        weapons = {"stretch"}
    end
    setElementData(plr, "fakeWeapons", weapons)
end

function pickupStretch(stretch)
    local stretchVeh = getElementData(stretch, "stretchVeh")
    local stretchPlr = getElementData(stretch, "stretchPlr")
    if stretchPlr then
        attachElements(stretchPlr, client, 0, 1.2, 1)
        setElementData(client, "plrOnStretch", stretchPlr)
    end

    setElementData(client, "stretchVeh", stretchVeh)

    destroyElement(stretch)
    bindKey(client, "x", "down", placeStretch)

    local weapons = getElementData(client, "fakeWeapons")
    if weapons then
        table.insert(weapons, "stretch")
    else
        weapons = {"stretch"}
    end
    setElementData(client, "fakeWeapons", weapons)

    triggerClientEvent(client, "updateInteraction", resourceRoot)
    exports.TR_noti:create(client, "Yere sedye bırakmak için X tuşunu kullanın.", "info")
end
addEvent("pickupStretch", true)
addEventHandler("pickupStretch", root, pickupStretch)

function placeStretch(plr)
    unbindKey(plr, "x", "down", placeStretch)

    local stretchVeh = getElementData(plr, "stretchVeh")
    if not stretchVeh then return end

    local x, y, z = getPosition(plr, settings.placeOffset)
    local _, _, rz = getElementRotation(plr)

    local stretch = createObject(settings.stretcherBig, x, y, z)
    setElementDoubleSided(stretch, true)
    setElementRotation(stretch, 0, 0, rz)
    setElementData(stretch, "stretchVeh", stretchVeh)
    removeElementData(plr, "stretchVeh")

    local plrOnStretch = getElementData(plr, "plrOnStretch")
    if plrOnStretch then
        detachElements(plrOnStretch, plr)
        setTimer(placePlayerOnStretch, 100, 1, plrOnStretch, stretch)
        removeElementData(plr, "plrOnStretch")
    end

    setElementInterior(stretch, getElementInterior(plr))
    setElementDimension(stretch, getElementDimension(plr))

    removePlayerStretchModel(plr)
end

function changePlayerStretch(veh)
    if getElementData(veh, "stretch") then
        removeVehicleStretch(veh, client)

    elseif getElementData(client, "stretchVeh") == veh then
        addVehicleStretcher(veh, client)
        removeElementData(client, "stretchVeh")

        unbindKey(client, "x", "down", placeStretch)
        removePlayerStretchModel(client)
    end

    triggerClientEvent(client, "updateInteraction", resourceRoot)
end
addEvent("changePlayerStretch", true)
addEventHandler("changePlayerStretch", root, changePlayerStretch)

function changeStretchHeight(stretch)
    if getElementModel(stretch) == settings.stretcher then
        local pos = Vector3(getElementPosition(stretch))
        setElementModel(stretch, settings.stretcherBig)
        setElementPosition(stretch, pos + Vector3(0, 0, 0.26))

        local stretchPlr = getElementData(stretch, "stretchPlr")
        if stretchPlr then
            attachElements(stretchPlr, stretch, 0, 0, 1.4)
        end
    else
        local pos = Vector3(getElementPosition(stretch))
        setElementModel(stretch, settings.stretcher)
        setElementPosition(stretch, pos - Vector3(0, 0, 0.26))

        local stretchPlr = getElementData(stretch, "stretchPlr")
        if stretchPlr then
            attachElements(stretchPlr, stretch, 0, 0, 1.1)
        end
    end

    triggerClientEvent(client, "updateInteraction", resourceRoot)
end
addEvent("changeStretchHeight", true)
addEventHandler("changeStretchHeight", root, changeStretchHeight)

function removePlayerStretchModel(plr)
    local weapons = getElementData(plr, "fakeWeapons")
    local newWeapons = {}
    if weapons then
        for i, v in pairs(weapons) do
            if v ~= "stretch" then
                table.insert(newWeapons, v)
            end
        end
        setElementData(plr, "fakeWeapons", newWeapons)
    end
    triggerClientEvent(plr, "updateWeapons", resourceRoot)
end

function resetVehicleStretch()
    local stretchVeh = getElementData(source, "stretchVeh")
    if not stretchVeh then return end
    addVehicleStretcher(stretchVeh)

    local stretchPlr = getElementData(stretch, "stretchPlr")
    if isElement(stretchPlr) then
        detachElements(stretchPlr, source)

        setElementFrozen(stretchPlr, false)
        removeElementData(stretchPlr, "plrStretch")
    end
end
addEventHandler("onPlayerQuit", root, resetVehicleStretch)

function getPosition(element, vec)
	local rot = Vector3(getElementRotation(element))
	local mat = Matrix(Vector3(getElementPosition(element)), rot)
	local newPos = mat:transformPosition(vec)
	return newPos.x, newPos.y, newPos.z, rot.z
end


function placePlayerOnStretch(plr, stretch)
    if not stretch then triggerClientEvent(client, "updateInteraction", resourceRoot) return end

    local stretchPos = Vector3(getElementPosition(stretch))
    local _, _, rz = getElementRotation(stretch)

    setElementPosition(plr, stretchPos)
    setElementRotation(plr, 0, 0, rz + 90)
    setTimer(setPedAnimation, 100, 1, plr, "Crack", "crckidle4")
    setElementData(plr, "animation", {"Crack", "crckidle4"})

    attachElements(plr, stretch, 0, 0, getElementModel(stretch) == settings.stretcher and 1.1 or 1.4)
    setElementFrozen(plr, true)
    setElementData(stretch, "stretchPlr", plr)
    setElementData(plr, "plrStretch", stretch)

    if not client then triggerClientEvent(client, "updateInteraction", resourceRoot) return end
    triggerClientEvent(client, "updateInteraction", resourceRoot)
end
addEvent("placePlayerOnStretch", true)
addEventHandler("placePlayerOnStretch", root, placePlayerOnStretch)

function takePlayerFromStretch(plr, stretch)
    if not stretch then triggerClientEvent(client, "updateInteraction", resourceRoot) return end

    local stretchPos = Vector3(getElementPosition(stretch))

    setElementPosition(plr, stretchPos)
    setPedAnimation(plr, nil, nil)

    removeElementData(plr, "animation")

    detachElements(plr, stretch)
    setElementFrozen(plr, false)
    removeElementData(plr, "plrStretch")
    removeElementData(stretch, "stretchPlr")
    removeElementData(client, "plrOnStretch")

    if not client then triggerClientEvent(client, "updateInteraction", resourceRoot) return end
    triggerClientEvent(client, "updateInteraction", resourceRoot)
end
addEvent("takePlayerFromStretch", true)
addEventHandler("takePlayerFromStretch", root, takePlayerFromStretch)