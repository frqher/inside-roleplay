function playerPayForWasher(state, data)
    triggerClientEvent(source, "responseCarWash", resourceRoot, state)

    if state then
        triggerClientEvent(root, "setWasherEffect", resourceRoot, data[1], data[2])
    end
end
addEvent("playerPayForWasher", true)
addEventHandler("playerPayForWasher", root, playerPayForWasher)
