function updateCuffedRotation()
    for i, v in pairs(getElementsByType("player", root, true)) do
        local cuffed = getElementData(v, "cuffedBy")
        local plrOnStretch = getElementData(v, "plrOnStretch")
        if isElement(cuffed) then
            setElementRotation(v, Vector3(getElementRotation(cuffed)))
        end
        if isElement(plrOnStretch) then
            local rot =  Vector3(getElementRotation(v))
            setElementRotation(plrOnStretch, rot.x, rot.y, rot.z + 90)
        end
    end
end
addEventHandler("onClientRender", root, updateCuffedRotation)