function quitHandler()
    if hoseData[source] then
        hoseData[source] = nil
        triggerClientEvent(root, "removeHose", resourceRoot, source)
    end

    if createdObjects[source] then
        for i, v in pairs(createdObjects[source]) do
            if isElement(v) then destroyElement(v) end
        end
    end
    createdObjects[source] = nil
end
addEventHandler("onPlayerQuit", root, quitHandler)