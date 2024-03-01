function MDTSearchPlayer(username)
    if not username then return end

    local playerData = exports.TR_mysql:querry("SELECT UID, username, usernameRP, ticketPrice, prisonData FROM tr_accounts WHERE username = ? LIMIT 1", username)
    if playerData and playerData[1] then
        local playerNotes = exports.TR_mysql:querry("SELECT ID, text, username FROM tr_mdtPlayers LEFT JOIN tr_accounts ON tr_mdtPlayers.policeUID = tr_accounts.UID WHERE plrUID = ? AND added >= DATE_SUB(NOW(), INTERVAL 14 DAY) ORDER BY ID DESC LIMIT 6", playerData[1].UID)
        local isWanted = exports.TR_mysql:querry("SELECT ID, wantedTime FROM tr_mdtWanted WHERE plrUID = ? LIMIT 1", playerData[1].UID)

        triggerClientEvent(client, "MDTResponse", resourceRoot, playerData[1], playerNotes, isWanted)

    else
        triggerClientEvent(client, "MDTResponse", resourceRoot, "noPlayer")
    end
end
addEvent("MDTSearchPlayer", true)
addEventHandler("MDTSearchPlayer", resourceRoot, MDTSearchPlayer)

function MDTSearchVehicle(plate)
    if not plate then return end

    local vehicleByPlate = exports.TR_mysql:querry("SELECT ID, model, plateText, username FROM tr_vehicles LEFT JOIN tr_accounts ON tr_vehicles.ownedPlayer = tr_accounts.UID WHERE plateText = ? LIMIT 1", plate)
    if vehicleByPlate and vehicleByPlate[1] then
        triggerClientEvent(client, "MDTResponse", resourceRoot, vehicleByPlate[1])

    else
        if tonumber(plate) == nil then
            triggerClientEvent(client, "MDTResponse", resourceRoot, "noVehicle")

        else
            local vehicleByID = exports.TR_mysql:querry("SELECT ID, model, plateText, username FROM tr_vehicles LEFT JOIN tr_accounts ON tr_vehicles.ownedPlayer = tr_accounts.UID WHERE ID = ? LIMIT 1", plate)
            if vehicleByID and vehicleByID[1] then
                triggerClientEvent(client, "MDTResponse", resourceRoot, vehicleByID[1])
            else
                triggerClientEvent(client, "MDTResponse", resourceRoot, "noVehicle")
            end
        end
    end
end
addEvent("MDTSearchVehicle", true)
addEventHandler("MDTSearchVehicle", resourceRoot, MDTSearchVehicle)

function MDTSetPlayerUnwanted(playerUID)
    if not playerUID then return end
    exports.TR_mysql:querry("DELETE FROM tr_mdtWanted WHERE plrUID = ?", playerUID)

    triggerClientEvent(client, "MDTResponse", resourceRoot, "setUnwanted")
end
addEvent("MDTSetPlayerUnwanted", true)
addEventHandler("MDTSetPlayerUnwanted", resourceRoot, MDTSetPlayerUnwanted)

function MDTSetPlayerWanted(playerUID)
    if not playerUID then return end
    exports.TR_mysql:querry("INSERT INTO tr_mdtWanted (plrUID, wantedTime) VALUES (?, NOW())", playerUID)

    triggerClientEvent(client, "MDTResponse", resourceRoot, "setWated")
end
addEvent("MDTSetPlayerWanted", true)
addEventHandler("MDTSetPlayerWanted", resourceRoot, MDTSetPlayerWanted)

function MDTAddPlayerNote(playerUID, text)
    if not playerUID or not text then return end
    local policeUID = getElementData(client, "characterUID")
    exports.TR_mysql:querry("INSERT INTO tr_mdtPlayers (plrUID, text, policeUID) VALUES (?, ?, ?)", playerUID, text, policeUID)

    triggerClientEvent(client, "MDTResponse", resourceRoot, "noteAdded")
end
addEvent("MDTAddPlayerNote", true)
addEventHandler("MDTAddPlayerNote", resourceRoot, MDTAddPlayerNote)

function MDTGetWantedPlayers()
    local wantedPlayers = exports.TR_mysql:querry("SELECT UID, username, wantedTime FROM tr_mdtWanted LEFT JOIN tr_accounts ON tr_mdtWanted.plrUID = tr_accounts.UID")

    triggerClientEvent(client, "MDTResponse", resourceRoot, wantedPlayers)
end
addEvent("MDTGetWantedPlayers", true)
addEventHandler("MDTGetWantedPlayers", resourceRoot, MDTGetWantedPlayers)

function openMDT()
    local plrDuty = getElementData(source, "characterDuty")
    if not plrDuty then return end

    if plrDuty[4] == 1 then
        triggerClientEvent(source, "MDTOpen", resourceRoot)
    end
end
addEvent("openMDT", true)
addEventHandler("openMDT", root, openMDT)
exports.TR_chat:addCommand("mdt", "openMDT")