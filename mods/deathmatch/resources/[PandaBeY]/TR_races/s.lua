function getPlayerCreatedRaceTracks()
    local createdRaces = exports.TR_mysql:querry("SELECT ID, track, created, type, laps, vehicleType, vehicleSpeed FROM tr_raceTracks WHERE createdPlayer = ? LIMIT 5", getElementData(client, "characterUID"))
    if createdRaces then
        for i, v in pairs(createdRaces) do
            local popularity = exports.TR_mysql:querry("SELECT COUNT(DISTINCT playerUID) as popularity FROM tr_raceTimes WHERE trackID = ?", v.ID)
            v.trackPopularity = popularity[1].popularity
        end
    end

    triggerClientEvent(client, "onRaceResponsePanel", resourceRoot, createdRaces)
end
addEvent("getPlayerCreatedRaceTracks", true)
addEventHandler("getPlayerCreatedRaceTracks", resourceRoot, getPlayerCreatedRaceTracks)

function addPlayerNewRaceTrack(data)
    local plrUID = getElementData(client, "characterUID")
    exports.TR_mysql:querry("INSERT INTO `tr_raceTracks`(`createdPlayer`, `track`, `type`, `laps`, `vehicleType`, `vehicleSpeed`) VALUES (?, ?, ?, ?, ?, ?)", plrUID, data.track, data.type, data.laps, data.vehicleType, data.vehicleSpeed)

    triggerClientEvent(client, "onTrackCreationSave", resourceRoot)
end
addEvent("addPlayerNewRaceTrack", true)
addEventHandler("addPlayerNewRaceTrack", resourceRoot, addPlayerNewRaceTrack)

function getRaceTrackDetails(trackID, type)
    local data = exports.TR_mysql:querry("SELECT ID, track, created, type, laps, vehicleType, vehicleSpeed FROM tr_raceTracks WHERE ID = ? LIMIT 5", trackID)

    if type == "Drift" then
        data[1].bestTimes = exports.TR_mysql:querry("SELECT DISTINCT playerUID, tr_accounts.username, MAX(playerTime) as playerTime FROM `tr_raceTimes` LEFT JOIN tr_accounts ON tr_raceTimes.playerUID = tr_accounts.UID WHERE trackID = ? GROUP BY playerUID ORDER BY playerTime DESC LIMIT 3", trackID)
    else
        data[1].bestTimes = exports.TR_mysql:querry("SELECT DISTINCT playerUID, tr_accounts.username, MIN(playerTime) as playerTime FROM `tr_raceTimes` LEFT JOIN tr_accounts ON tr_raceTimes.playerUID = tr_accounts.UID WHERE trackID = ? GROUP BY playerUID ORDER BY playerTime ASC LIMIT 3", trackID)
    end

    local popularity = exports.TR_mysql:querry("SELECT COUNT(DISTINCT playerUID) as popularity FROM tr_raceTimes WHERE trackID = ?", trackID)
    data[1].trackPopularity = popularity[1].popularity

    triggerClientEvent(client, "onRaceResponsePanel", resourceRoot, data[1])
end
addEvent("getRaceTrackDetails", true)
addEventHandler("getRaceTrackDetails", resourceRoot, getRaceTrackDetails)

function removePlayerRaceTrack(trackID)
    exports.TR_mysql:querry("DELETE FROM `tr_raceTracks` WHERE ID = ? LIMIT 1", trackID)
    triggerClientEvent(client, "onRaceResponsePanel", resourceRoot)
end
addEvent("removePlayerRaceTrack", true)
addEventHandler("removePlayerRaceTrack", resourceRoot, removePlayerRaceTrack)

function getRaceTrackBest(offset)
    local trackOffset = offset and offset or 0
    local bestRaces = exports.TR_mysql:querry("SELECT ID, track, created, type, laps, vehicleType, vehicleSpeed FROM (SELECT tr_raceTracks.ID as ID, track, created, type, laps, vehicleType, vehicleSpeed, COUNT(DISTINCT tr_raceTimes.playerUID) as Total FROM tr_raceTracks LEFT JOIN tr_raceTimes ON tr_raceTimes.trackID = tr_raceTracks.ID GROUP BY tr_raceTracks.ID) as best ORDER BY Total DESC LIMIT ?, ?", trackOffset, trackOffset + 10)
    if bestRaces then
        for i, v in pairs(bestRaces) do
            local popularity = exports.TR_mysql:querry("SELECT COUNT(DISTINCT playerUID) as popularity FROM tr_raceTimes WHERE trackID = ?", v.ID)
            v.trackPopularity = popularity[1].popularity
        end
    end

    triggerClientEvent(client, "onRaceResponsePanel", resourceRoot, bestRaces, offset)
end
addEvent("getRaceTrackBest", true)
addEventHandler("getRaceTrackBest", resourceRoot, getRaceTrackBest)

function getPlayerWinRacePrices()
    local playerRaceWin = exports.TR_mysql:querry("SELECT raceWin FROM tr_accounts WHERE UID = ? LIMIT 1", getElementData(client, "characterUID"))

    triggerClientEvent(client, "onRaceResponsePanel", resourceRoot, playerRaceWin[1].raceWin)
end
addEvent("getPlayerWinRacePrices", true)
addEventHandler("getPlayerWinRacePrices", resourceRoot, getPlayerWinRacePrices)

function getPlayerRaceWinMoney()
    local uid = getElementData(client, "characterUID")
    local playerRaceWin = exports.TR_mysql:querry("SELECT raceWin FROM tr_accounts WHERE UID = ? LIMIT 1", uid)

    if exports.TR_core:giveMoneyToPlayer(client, playerRaceWin[1].raceWin) then
        exports.TR_mysql:querry("UPDATE tr_accounts SET raceWin = 0 WHERE UID = ? LIMIT 1", uid)
        triggerClientEvent(client, "onRaceResponsePanel", resourceRoot, 0, true)
    end
end
addEvent("getPlayerRaceWinMoney", true)
addEventHandler("getPlayerRaceWinMoney", resourceRoot, getPlayerRaceWinMoney)


function getRaceTrackSearch(searchType, value)
    local results = false

    if searchType == "trackID" then
        results = exports.TR_mysql:querry("SELECT ID, track, created, type, laps, vehicleType, vehicleSpeed FROM tr_raceTracks WHERE ID = ? LIMIT 4", value)

    elseif searchType == "playerName" then
        local plrUID = exports.TR_mysql:querry("SELECT UID FROM tr_accounts WHERE username = ? LIMIT 1", value)
        if plrUID and plrUID[1] then
            results = exports.TR_mysql:querry("SELECT ID, track, created, type, laps, vehicleType, vehicleSpeed FROM tr_raceTracks WHERE createdPlayer = ? LIMIT 4", plrUID[1].UID)
        end
    end

    if results then
        for i, v in pairs(results) do
            local popularity = exports.TR_mysql:querry("SELECT COUNT(DISTINCT playerUID) as popularity FROM tr_raceTimes WHERE trackID = ?", v.ID)
            v.trackPopularity = popularity[1].popularity
        end
        triggerClientEvent(client, "onRaceResponsePanel", resourceRoot, results)
        return
    end

    triggerClientEvent(client, "onRaceResponsePanel", resourceRoot, results, "playerNotFound")
end
addEvent("getRaceTrackSearch", true)
addEventHandler("getRaceTrackSearch", resourceRoot, getRaceTrackSearch)


function getPlayerAvaliableRaceVehicles()
    local vehicles = exports.TR_mysql:querry("SELECT ID, model, engineCapacity FROM tr_vehicles WHERE ownedPlayer = ?", getElementData(client, "characterUID"))
    triggerClientEvent(client, "onRaceResponsePanel", resourceRoot, vehicles)
end
addEvent("getPlayerAvaliableRaceVehicles", true)
addEventHandler("getPlayerAvaliableRaceVehicles", resourceRoot, getPlayerAvaliableRaceVehicles)


function createVehicleTrackCreation(mapX, mapY, mapZ)
    local veh = createVehicle(500, mapX, mapY, mapZ, 0, 0, 0)
    setVehicleDamageProof(veh, true)

    setElementData(veh, "vehicleData", {
		fuel = 70,
		mileage = math.random(350000, 500000),
		engineType = "d",
	}, false)
    setElementData(veh, "vehicleOwner", client)
    setElementData(veh, "blockCollisions", true)
    setElementData(veh, "inv", true)
    setElementDimension(veh, 9530)

    setTimer(warpPedIntoVehicle, 500, 1, client, veh)
    setTimer(setElementFrozen, 1000, 1, veh, true)
    setElementInterior(client, 0)
    setElementDimension(client, 9530)

    exports.TR_objectManager:attachObjectToPlayer(client, veh)
end
addEvent("createVehicleTrackCreation", true)
addEventHandler("createVehicleTrackCreation", resourceRoot, createVehicleTrackCreation)

function onPlayerVehicleCreationeEnd()
    local veh = getPedOccupiedVehicle(client)
    if veh then destroyElement(veh) end

    local pos = getElementData(client, "characterQuit")
    setTimer(setElementPosition, 1000, 1, client, pos[1], pos[2], pos[3])
    setTimer(setElementInterior, 1000, 1, client, pos[4])
    setTimer(setElementDimension, 1000, 1, client, pos[5])
    setElementData(client, "characterQuit", nil)
end
addEvent("onPlayerVehicleCreationeEnd", true)
addEventHandler("onPlayerVehicleCreationeEnd", resourceRoot, onPlayerVehicleCreationeEnd)


function setVehicleDriftHandling(veh)
    local handling = "22500 26500 2 0 -0.18 -0.2 120 0.565 0.565 0.415 5 225 26.2 5 r p 4.2 0.365 false 55 1.6 0.12 0 0.35 -0.14 0.5 0.3 0.72 0 19000 0 0 1 3 0"
    local handlingTable = split(handling, " ")
    local handlingProperties = {"mass", "turnMass", "dragCoeff", "centerOfMassX", "centerOfMassY", "centerOfMassZ", "percentSubmerged", "tractionMultiplier", "tractionLoss", "tractionBias", "numberOfGears", "maxVelocity", "engineAcceleration", "engineInertia", "driveType", "engineType", "brakeDeceleration", "brakeBias", "ABS", "steeringLock", "suspensionForceLevel", "suspensionDamping", "suspensionHighSpeedDamping", "suspensionUpperLimit", "suspensionLowerLimit", "suspensionFrontRearBias", "suspensionAntiDiveMultiplier", "seatOffsetDistance", "collisionDamageMultiplier", "monetary", "modelFlags", "handlingFlags", "headLight", "tailLight", "animGroup", "identifier", "mass", "turnMass", "dragCoeff", "centerOfMassX", "centerOfMassY", "centerOfMassZ", "percentSubmerged", "tractionMultiplier", "tractionLoss", "tractionBias", "numberOfGears", "maxVelocity", "engineAcceleration", "engineInertia", "driveType", "engineType", "brakeDeceleration", "brakeBias", "ABS", "steeringLock", "suspensionForceLevel", "suspensionDamping", "suspensionHighSpeedDamping", "suspensionUpperLimit", "suspensionLowerLimit", "suspensionFrontRearBias", "suspensionAntiDiveMultiplier", "seatOffsetDistance", "collisionDamageMultiplier", "monetary"}
    for k, v in pairs(handlingTable) do
        if handlingProperties[k] then
            setVehicleHandling(veh, handlingProperties[k], v, false)
        end
    end
end

function createVehicleRace(pos, model, raceType)
    local veh = createVehicle(model, pos[1], pos[2], pos[3], 0, 0, pos[4])
    setVehicleDamageProof(veh, true)

    setElementData(veh, "vehicleData", {
		fuel = 70,
		mileage = math.random(350000, 500000),
		engineType = "d",
	}, false)
    setElementDimension(veh, 9531)
    setElementData(veh, "blockAction", true)
    setElementData(veh, "vehicleOwner", client)
    setElementData(veh, "raceVehicle", true)

    setTimer(warpPedIntoVehicle, 500, 1, client, veh)
    setTimer(setVehicleEngineState, 1000, 1, veh, true)
    setElementInterior(client, 0)
    setElementDimension(client, 9531)

    if raceType == "Drift" then
        setVehicleDriftHandling(veh)
    end

    exports.TR_objectManager:attachObjectToPlayer(client, veh)
    triggerClientEvent(client, "setVehicleFrozenOnRaceStart", resourceRoot)
end
addEvent("createVehicleRace", true)
addEventHandler("createVehicleRace", resourceRoot, createVehicleRace)

function onPlayerRaceEnd(raceID, time)
    local veh = getPedOccupiedVehicle(client)
    if veh then destroyElement(veh) end

    local pos = getElementData(client, "characterQuit")
    if pos then
        setTimer(setElementPosition, 1000, 1, client, pos[1], pos[2], pos[3])
        setTimer(setElementInterior, 1000, 1, client, pos[4])
        setTimer(setElementDimension, 1000, 1, client, pos[5])
        setElementData(client, "characterQuit", nil)
    end

    if not raceID or not time then return end
    exports.TR_mysql:querry("INSERT INTO `tr_raceTimes`(`playerUID`, `playerTime`, `trackID`) VALUES (?, ?, ?)", getElementData(client, "characterUID"), time, raceID)
end
addEvent("onPlayerRaceEnd", true)
addEventHandler("onPlayerRaceEnd", resourceRoot, onPlayerRaceEnd)

function createVehiclePrivateRace(pos, raceType, vehID)
    local vehData = exports.TR_mysql:querry("SELECT model, color, performanceTuning, visualTuning, paintjob, variant, tuning FROM tr_vehicles WHERE ID = ?", vehID)
	local color = split(vehData[1].color, ",")
	local performanceTuning = vehData[1].performanceTuning and fromJSON(vehData[1].performanceTuning) or false

    local veh = createVehicle(vehData[1].model, pos[1], pos[2], pos[3], 0, 0, pos[4])
    setVehicleDamageProof(veh, true)
    setVehicleColor(veh, color[1], color[2], color[3], color[4], color[5], color[6], color[7], color[8], color[9], color[10], color[11], color[12])
	setVehicleHeadLightColor(veh, color[13], color[14], color[15])

	if paintjob then setVehiclePaintjob(veh, paintjob) end
	setVehicleOverrideLights(veh, 2)

	local variant = split(vehData[1].variant, ",")
	setVehicleVariant(veh, tonumber(variant[1]), tonumber(variant[2]))

	setTimer(function()
        if vehData[1].tuning then
            exports.TR_vehicles:updateVehicleTuning(veh, vehData[1].tuning)
        end
	end, 200, 1)

    setElementData(veh, "vehicleData", {
        ID = vehID,
		fuel = 70,
		mileage = math.random(350000, 500000),
		engineType = "d",
	}, false)
    setElementDimension(veh, 9531)
    setElementData(veh, "blockAction", true)
    setElementData(veh, "vehicleOwner", client)
    setElementData(veh, "inv", true)
	setElementData(veh, "visualTuning", vehData[1].visualTuning and fromJSON(vehData[1].visualTuning) or false)

    setTimer(warpPedIntoVehicle, 500, 1, client, veh)
    setTimer(setVehicleEngineState, 1000, 1, veh, true)
    setElementInterior(client, 0)
    setElementDimension(client, 9531)

    if raceType == "Drift" then
        setVehicleDriftHandling(veh)
    else
        local performanceTuning = vehData[1].performanceTuning and fromJSON(vehData[1].performanceTuning) or false
        if performanceTuning then
            exports.TR_vehicles:updateVehicleHandling(veh, performanceTuning)
        end
    end

    exports.TR_objectManager:attachObjectToPlayer(client, veh)
    triggerClientEvent(client, "setVehicleFrozenOnRaceStart", resourceRoot)
end
addEvent("createVehiclePrivateRace", true)
addEventHandler("createVehiclePrivateRace", resourceRoot, createVehiclePrivateRace)


function blockExit()
    cancelEvent()
end
addEventHandler("onVehicleStartExit", resourceRoot, blockExit)

function givePrizes()
    local bestRaces = exports.TR_mysql:querry("SELECT trackID, type, createdPlayer FROM (SELECT trackID, createdPlayer, type, COUNT(DISTINCT playerUID) as Total FROM tr_raceTimes LEFT JOIN tr_raceTracks ON tr_raceTimes.trackID = tr_raceTracks.ID GROUP BY tr_raceTimes.trackID) as best WHERE Total >= ?", RaceData.minPopularity)

    if bestRaces and bestRaces[1] then
        for _, v in pairs(bestRaces) do
            local bestTimes
            if v.type == "Drift" then
                bestTimes = exports.TR_mysql:querry("SELECT DISTINCT playerUID, tr_accounts.username, MAX(playerTime) as playerTime FROM `tr_raceTimes` LEFT JOIN tr_accounts ON tr_raceTimes.playerUID = tr_accounts.UID WHERE trackID = ? GROUP BY playerUID ORDER BY playerTime DESC LIMIT 3", v.trackID)
            else
                bestTimes = exports.TR_mysql:querry("SELECT DISTINCT playerUID, tr_accounts.username, MIN(playerTime) as playerTime FROM `tr_raceTimes` LEFT JOIN tr_accounts ON tr_raceTimes.playerUID = tr_accounts.UID WHERE trackID = ? GROUP BY playerUID ORDER BY playerTime ASC LIMIT 3", v.trackID)
            end

            if bestTimes then
                for pos, plr in pairs(bestTimes) do
                    exports.TR_mysql:querry("UPDATE tr_accounts SET raceWin = raceWin + ? WHERE UID = ? LIMIT 1", RaceData.posPrices[pos], plr.playerUID)
                end
            end

            exports.TR_mysql:querry("UPDATE tr_accounts SET raceWin = raceWin + ? WHERE UID = ? LIMIT 1", RaceData.priceForCreator, v.createdPlayer)
        end
    end
    exports.TR_mysql:querry("DELETE FROM `tr_raceTimes`")
end

function checkTime()
    local time = getRealTime()
    if time.minute == 0 and time.hour == 0 and time.weekday == 1 then
        givePrizes()
    end
end
checkTime()
setTimer(checkTime, 60000, 0)