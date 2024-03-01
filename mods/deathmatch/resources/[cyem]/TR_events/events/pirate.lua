local data = {
    fallCol = createColCuboid(-2425.4638671875, 3124.724609375, -4.1455278396606, 150, 110, 6),

    respawns = {
        red = {
            Vector3(-2330.9936523438, 3164.1020507812, 8.7931632995605),
            Vector3(-2327.6635742188, 3161.1411132812, 8.7875003814697),
            Vector3(-2340.0053710938, 3160.5590820312, 6.3421878814697),
            Vector3(-2335.4204101562, 3162.9204101562, 6.3472528457642),
            Vector3(-2338.2358398438, 3165.2612304688, 6.3472528457642),
            Vector3(-2349.5083007812, 3162.3754882812, 5.3109378814697),
            Vector3(-2349.6372070312, 3166.4653320312, 5.3109378814697),
            Vector3(-2361.7856445312, 3167.0668945312, 6.1495246887207),
            Vector3(-2363.4145507812, 3160.6401367188, 6.2106323242188),
            Vector3(-2371.1782226562, 3163.8247070312, 7.0921878814697),
        },
        blue = {
            Vector3(-2371.4892578125, 3191.2014160156, 8.6931629180908),
            Vector3(-2375.1904296875, 3195.1828613281, 8.6875),
            Vector3(-2362.5537109375, 3195.0881347656, 6.2421875),
            Vector3(-2368.443359375, 3192.8312988281, 6.2472524642944),
            Vector3(-2363.2705078125, 3189.3215332031, 6.2421875),
            Vector3(-2353.8603515625, 3193.0344238281, 5.2109375),
            Vector3(-2353.919921875, 3189.7531738281, 5.2109375),
            Vector3(-2341.5234375, 3187.5637207031, 6.0259580612183),
            Vector3(-2339.2119140625, 3195.0861816406, 6.1095752716064),
            Vector3(-2330.080078125, 3191.2189941406, 6.9921875),
        },
    },

    teams = {
        red = createTeam("red", 255, 0, 0),
        blue = createTeam("blue", 0, 0, 255),
    },

    playerInTeam = {
        red = {},
        blue = {},
    }
}
setElementDimension(data.fallCol, 29)

-- for i, v in pairs(data.respawns.red) do
--     createMarker(v, "corona", 1, 255, 0, 0)
-- end

-- for i, v in pairs(data.respawns.blue) do
--     createMarker(v, "corona", 1, 0, 0, 255)
-- end



function createPirateEvent()
    local index = 0
    local respawnIndex = 1
    for i, v in pairs(eventData.playersLeft) do
        if index%2 == 0 then
            setPlayerTeam(i, data.teams.red)
            setElementPosition(i, data.respawns.red[respawnIndex])
            data.playerInTeam.red[i] = i
        else
            setPlayerTeam(i, data.teams.blue)
            setElementPosition(i, data.respawns.blue[respawnIndex])
            respawnIndex = respawnIndex + 1
            data.playerInTeam.blue[i] = i
        end

        setElementModel(i, 203)
        setElementInterior(i, 0)
        setElementDimension(i, 29)
        exports.TR_weaponSlots:giveWeapon(i, 8, 9999, true)

        setElementHealth(i, 100)
        index = index + 1
    end

    triggerClientEvent(root, "updateBandanas", resourceRoot)
end


function checkPirateWin()
    local redTeamCount = 0
    for i, v in pairs(data.playerInTeam.red) do
        if isElement(i) and eventData.playersLeft[i] then
            redTeamCount = redTeamCount + 1
        end
    end

    local blueTeamCount = 0
    for i, v in pairs(data.playerInTeam.blue) do
        if isElement(i) and eventData.playersLeft[i] then
            blueTeamCount = blueTeamCount + 1
        end
    end

    local winningTeam, winningTeamName = false, false
    local winningPrice = false
    if redTeamCount == 0 then
        local count = 0
        for i, v in pairs(data.playerInTeam.blue) do
            if isElement(i) and eventData.players[i] then
                count = count + 1
            end
        end

        winningTeam = "blue"
        winningTeamName = "mavi"
        winningPrice = eventData.winPrice/count

    elseif blueTeamCount == 0 then
        local count = 0
        for i, v in pairs(data.playerInTeam.red) do
            if isElement(i) and eventData.players[i] then
                count = count + 1
            end
        end

        winningTeam = "red"
        winningTeamName = "kırmızı"
        winningPrice = eventData.winPrice/count
    end
    if not winningTeam or not winningPrice or winningPrice < 0 or tonumber(winningPrice) == nil then return end

    for i, v in pairs(data.playerInTeam[winningTeam]) do
        exports.TR_core:giveMoneyToPlayer(i, winningPrice)
    end

    triggerClientEvent(root, "setEventNoti", resourceRoot, "winPirate", {winningTeamName, eventData.events[eventData.selectedEvent].name, winningPrice})

    data.playerInTeam.red = {}
    data.playerInTeam.blue = {}

    triggerEvent("endEvent", resourceRoot)
end