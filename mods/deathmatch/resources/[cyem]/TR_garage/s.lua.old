local garageData = {
	markerColor = {9, 104, 167},
	blipIcon = 35,

	garages = {
		{
			pedPos = {1647.4122314453, -1520.96875, 13.55057144165, 149}, --- ls
			pedSkin = 259,
			pedName = "Andrei Burton",
			enterMarker = {1643.8325195313, -1516.0192871094, 12.566635131836},
			quitMarker = {1637.1369628906, -1524.3497314453, 13.117864608765, 0, 0, 197.7},
			styleID = 1,
		},
		{
			pedPos = {683.40277099609, -1569.9444580078, 14.2421875, 231}, --- LS
			pedSkin = 259,
			pedName = "Hans Merken",
			enterMarker = {691.26788330078, -1568.5784912109, 13.042187},
			quitMarker = {686.57592773438, -1569.5001220703, 14.2421875, 0, 0, 180},
			styleID = 2,
		},
		{
			pedPos = {-1754.232421875, 963.150390625, 24.8828125, 180}, --- SF Financial
			pedSkin = 171,
			pedName = "Jayden Miller",
			enterMarker = {-1743.916015625, 959.7021484375, 23.8828125},
			quitMarker = {-1764.6474609375, 959.7021484375, 24.8828125, 0, 0, 180},
			styleID = 3,
		},
		{
			pedPos = {2498.9111328125, 12.976596832275, 26.496500015259, 180}, --- PC
			pedSkin = 240,
			pedName = "Joseph Garcia",
			enterMarker = {2503.22,  11.02, 26.49},
			quitMarker = {2479.45, 9.71, 26.52, 0, 0, 180},
			styleID = 4,
		},
		{
			pedPos = {-2740.2314453125, 1248.5126953125, 11.765625, 33}, --- SF Palisades
			pedSkin = 15,
			pedName = "Conrad Pritchard",
			enterMarker = {-2744.91, 1246.83, 10.76},
			quitMarker = {-2738.56, 1252.09, 11.76, 0, 0, 32},
			styleID = 5,
		},
		{
			pedPos = {-2392.66796875, -108.2822265625, 35.345500946045, 269}, --- SF Garcia
			pedSkin = 15,
			pedName = "Todd Mackenzie",
			enterMarker = {-2391.91, -102.21, 34.34},
			quitMarker = {-2391.00, -111.18, 35.34, 0, 0, 270},
			styleID = 6,
		},
		{
			pedPos = {1648.5634765625, 2207.1650390625, 10.8203125, 177}, --- LV Radstand
			pedSkin = 15,
			pedName = "John Krack",
			enterMarker = {1654.205078125, 2205.380859375, 9.9203125},
			quitMarker = {1645.3203125, 2204.455078125, 11.8203125, 0, 0, 180},
			styleID = 7,
		},
	},
}

function startGarage()
	createDialogue()
	for i, v in pairs(garageData.garages) do
		local npc = exports.TR_npc:createNPC(v.pedSkin, v.pedPos[1], v.pedPos[2], v.pedPos[3], v.pedPos[4], v.pedName, "Obsługa przechowalni", "dialogue")
		local blip = createBlip(v.pedPos[1], v.pedPos[2], v.pedPos[3], 0, 1, garageData.markerColor[1], garageData.markerColor[2], garageData.markerColor[3], 255)
		setElementData(blip, "icon", garageData.blipIcon)

		exports.TR_npc:setNPCDialogue(npc, garageData.dialogue)

		local enterMarker = createMarker(v.enterMarker[1], v.enterMarker[2], v.enterMarker[3], "cylinder", 3, garageData.markerColor[1], garageData.markerColor[2], garageData.markerColor[3], 0)
		setElementData(npc, "garageData", {quit = v.quitMarker, style = v.styleID}, false)
		setElementData(enterMarker, "markerIcon", "garage")
		setElementData(enterMarker, "garageID", v.styleID, false)
	end
end
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), startGarage)

function createDialogue()
	garageData.dialogue = exports.TR_npc:createDialogue()

	exports.TR_npc:addDialogueText(garageData.dialogue, "Dzień dobry.", {pedResponse = "Dzień dobry. Jak mogę pomóc?"})

	exports.TR_npc:addDialogueText(garageData.dialogue, "Chciałbym odebrać zaparkowany pojazd.", {pedResponse = "", img = "garage", trigger = "getVehiclesGarage", responseTo = "Dzień dobry."})
	exports.TR_npc:addDialogueText(garageData.dialogue, "Chciałbym się dowiedzieć czym się zajmujecie.", {pedResponse = "Nie ma problemu. Proszę pytać o cokolwiek. Jak tylko będę w stanie to odpowiem na wszelkie pytania.", responseTo = "Dzień dobry."})
	exports.TR_npc:addDialogueText(garageData.dialogue, "Przepraszam za fatygę. Do widzenia.", {pedResponse = "Nic się nie stało. Do widzenia.", responseTo = "Dzień dobry."})

	exports.TR_npc:addDialogueText(garageData.dialogue, "Co mogę u was przechować?", {pedResponse = "Każdy pojazd, do którego posiada pan klucze. Bez względu na jego stan techniczny.", responseTo = "Chicałbym się dowiedzieć czym się zajmujecie."})
	exports.TR_npc:addDialogueText(garageData.dialogue, "Ile będę musiał zapłacić za usługi?", {pedResponse = "Nasze usługi są całkowicie darmowe, ponieważ jesteśmy dofinansowywani przez państwo.", responseTo = "Chicałbym się dowiedzieć czym się zajmujecie."})
	exports.TR_npc:addDialogueText(garageData.dialogue, "Czy na pewno nic się nie stanie z moim pojazdem?", {pedResponse = "Pojazdy, które zostają nam powierzone są przechowywane w zamkniętym pomieszczeniu, do którego nikt poza pracownikami nie ma dostępu. Bezpieczeństwo jest gwarantowane.", responseTo = "Chicałbym się dowiedzieć czym się zajmujecie."})

	exports.TR_npc:addDialogueText(garageData.dialogue, "Do widzenia.", {pedResponse = "Do widzenia. Miłego życzę."})
end


function getVehiclesGarage(ped)
	local pedName = getElementData(ped, "name")
	if not exports.TR_vehicles:canVehicleEnter(client) then
		triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Nie mogę ci wydać żadnego pojazdu, ponieważ dostałeś zakaz na ich prowadzenie.", "files/images/npc.png")
		return
	end
	triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Jasne. Jaki cię interesuje?", "files/images/npc.png")


	local UID = getElementData(source, "characterUID")
	local name = getPlayerName(source)
	local garageData = getElementData(ped, "garageData")
	local characterOrgID = getElementData(source, "characterOrgID")

	local querry = exports.TR_mysql:querry("SELECT ID, model, color, paintjob, panelstates, doorstates, health, parking FROM tr_vehicles WHERE ownedPlayer = ? AND parking < 100", UID)
	if characterOrgID then
        local rent = exports.TR_mysql:querry("SELECT tr_vehicles.ID as ID, model, color, paintjob, panelstates, doorstates, health, parking FROM tr_vehicles LEFT JOIN tr_vehiclesRent ON tr_vehicles.ID = tr_vehiclesRent.vehID WHERE (tr_vehiclesRent.plrUID = ? OR tr_vehicles.ownedOrg = ?) AND parking < 100", UID, characterOrgID)
		if rent then
			for i, v in pairs(rent) do
				table.insert(querry, v)
			end
		end
	else
        local rent = exports.TR_mysql:querry("SELECT tr_vehicles.ID as ID, model, color, paintjob, panelstates, doorstates, health, parking FROM tr_vehicles LEFT JOIN tr_vehiclesRent ON tr_vehicles.ID = tr_vehiclesRent.vehID WHERE tr_vehiclesRent.plrUID = ? AND parking < 100", UID)
		if rent then
			for i, v in pairs(rent) do
				table.insert(querry, v)
			end
		end
	end

	if querry and #querry > 0 then
		triggerClientEvent(source, "showVehicleGarage", resourceRoot, querry, garageData)

		local x, y, z = getElementPosition(source)
		local int = getElementInterior(source)
		local dim = getElementDimension(source)
		setElementData(source, "characterQuit", {x, y, z, int, dim}, false)

		setElementPosition(source, -1760.5791015625, 993.3740234375, 95.84375)
		setElementInterior(source, 0)
		setElementDimension(source, 1)
	else
		exports.TR_noti:create(source, "Nie posiadasz żadnych pojazdów w przechowywalni.", "error")
	end
end
addEvent("getVehiclesGarage", true)
addEventHandler("getVehiclesGarage", root, getVehiclesGarage)

function exitGarageWindow()
	local pos = getElementData(client, "characterQuit")
	setElementPosition(client, pos[1], pos[2], pos[3])
	setElementInterior(client, pos[4])
	setElementDimension(client, pos[5])

	removeElementData(client, "characterQuit")
end
addEvent("exitGarageWindow", true)
addEventHandler("exitGarageWindow", root, exitGarageWindow)

function spawnGarageVehicle(data)
	local vehicle = exports.TR_vehicles:spawnVehicle(data.id, data.position)
	if not vehicle then triggerClientEvent(source, "closeVehicleGarage", resourceRoot, false) return end
	setElementData(vehicle, "blockCollisions", true)

	local pos = split(data.position, ",")
	setTimer(setVehicleFrozen, 2000, 1, vehicle, false)

	setElementInterior(source, 0)
	setElementDimension(source, 0)
	removeElementData(source, "characterQuit")

	warpPedIntoVehicle(source, vehicle, 0)
	exports.TR_mysql:querry("UPDATE tr_vehicles SET parking = NULL WHERE ID = ? LIMIT 1", data.id)
	setVehicleEngineState(vehicle, true)
	setVehicleOverrideLights(vehicle, 2)

	local plr = source
	setTimer(function()
		if not isElement(vehicle) then return end
		local garagePos = split(data.position, ",")
		if not garagePos then return end

		local x, y, z = getElementPosition(vehicle)

		if getDistanceBetweenPoints3D(x, y, z, tonumber(garagePos[1]), tonumber(garagePos[2]), tonumber(garagePos[3])) < 5 then
			hideGarageVehicle(data.garageID, plr)
			exports.TR_noti:create(plr, "Pojazd został oddany do przechowywalni, ponieważ nie odjechałeś z miejsca odbioru.", "info", 5)
		else
			removeElementData(vehicle, "blockCollisions")
		end
	end, 30000, 1)

	triggerClientEvent(source, "closeVehicleGarage", resourceRoot, true)
end
addEvent("spawnGarageVehicle", true)
addEventHandler("spawnGarageVehicle", root, spawnGarageVehicle)

function hideGarageVehicle(parkingID, player)
	local plr = player and player or client
	local veh = getPedOccupiedVehicle(plr)
	if not veh then return end

	local data = getElementData(veh, "vehicleData")
	if data then
		exports.TR_vehicles:saveVehicle(veh)
		exports.TR_mysql:querry("UPDATE tr_vehicles SET parking = ? WHERE ID = ? LIMIT 1", parkingID, data.ID)
		destroyElement(veh)
	end
end
addEvent("hideGarageVehicle", true)
addEventHandler("hideGarageVehicle", resourceRoot, hideGarageVehicle)

function markerEnter(plr, md)
	if not md then return end
	if getElementType(plr) ~= "player" then return end
	local veh = getPedOccupiedVehicle(plr)
	if not veh then return end
	if getPedOccupiedVehicleSeat(plr) ~= 0 then return end

	if not getElementID(veh) then return end
	if string.len(getElementID(veh)) < 3 then return end

	local garageID = getElementData(source, "garageID")
	triggerClientEvent(plr, "garageHideVehicle", resourceRoot, garageID, source)
end
addEventHandler("onMarkerHit", resourceRoot, markerEnter)



-- Utils
function getPositionInfrontOfElement(element, meters)
    if (not element or not isElement(element)) then return false end
    local meters = (type(meters) == "number" and meters) or 3
    local posX, posY, posZ = getElementPosition(element)
    local _, _, rotation = getElementRotation(element)
    posX = posX - math.sin(math.rad(rotation)) * meters
    posY = posY + math.cos(math.rad(rotation)) * meters
    rot = rotation + math.cos(math.rad(rotation))
    return posX, posY, posZ , rot
end
