local informed = {}

local seatWindows = {
	[0] = 4,
	[1] = 2,
	[2] = 5,
	[3] = 3
}

function interactionTrigger(option, sound, index)
	local veh = getPedOccupiedVehicle(client)
	if option then
		if option == 1 then
			if getVehicleOverrideLights(veh) ~= 2 then
				setVehicleOverrideLights(veh, 2)
			else
				setVehicleOverrideLights(veh, 1)
			end

		elseif option == 2 then
			if not exports.TR_vehicles:canUseVehicle(veh, client) then exports.TR_noti:create(client, "Bu aracın anahtarları sizde değil.", "error") return end
			if not getVehicleEngineState(veh) then
				local vehData = getElementData(veh, "vehicleData")
				if not vehData then return end
				if vehData.fuel <= 0.5 then
					exports.TR_noti:create(client, "Yakıtınız bittiği için aracı çalıştıramazsınız.", "error")
					return
				end
				setVehicleEngineState(veh, true)
			else
				setVehicleEngineState(veh, false)
			end

		elseif option == 3 then
			if not getElementData(client, "belt") then
				setElementData(client, "belt", true)
			else
				setElementData(client, "belt", false)
			end

		elseif option == 4 then
			if getElementData(veh, "blockAction") then exports.TR_noti:create(client, "Zaten etkileşimdesiniz.", "error") return end
			if isElement(getElementData(veh, "winchPlayer")) then exports.TR_noti:create(client, "Vince bağlı olduğunuzda bunu yapamazsınız.", "error") return end
			if getElementData(veh, "wheelBlock") then exports.TR_noti:create(client, "Bunu yapamazsınız çünkü tekerlek kilidiniz açık.", "error") return end
			if isElementFrozen(veh) then
				setElementFrozen(veh, false)
				if getElementHealth(veh) > 301 then setVehicleDamageProof(veh, false) end
			else
				if getVehicleType(veh) == "Boat" then
					if getElementSpeedValue(veh, "km/h") > 1 then
						exports.TR_noti:create(client, "Yoldayken demir atamazsınız.", "error")
						return
					end
				else
					if getElementSpeedValue(veh, "km/h") > 0 then
						exports.TR_noti:create(client, "Sürüş sırasında el frenini çekemezsiniz.", "error")
						return
					end
				end

				setElementFrozen(veh, true)
				setVehicleDamageProof(veh, true)
			end

		elseif option == 5 then
			if getElementSpeedValue(veh, "km/h") > 3 then
				exports.TR_noti:create(client, "Araba sürerken kimseyi dışarı atamazsınız. Vicdanında yok mu?!", "error")
				return
			end

			local occupants = getVehicleOccupants(veh)
			occupants[0] = nil
			triggerClientEvent(occupants, "removePedFromVehicle", resourceRoot, index)

		elseif option == 6 then
			local seat = getPedOccupiedVehicleSeat(client)
			if seatWindows[seat] then
				triggerClientEvent(root, "changeWindowState", root, veh, seat)
			end

		elseif option == 7 then
			local isLocked = isVehicleLocked(veh)
			setVehicleLocked(veh, not isLocked)
			if not isLocked then
				for i = 2, 5 do
					setVehicleDoorOpenRatio(veh, i, 0, 500)
				end
			end

		elseif option == 8 then
			local suspensionHeight = getElementData(veh, "suspensionHeight")
			local modelHandling = getModelHandling(getElementModel(veh))
			if suspensionHeight == 1 then setVehicleHandling(veh, "suspensionLowerLimit", modelHandling["suspensionLowerLimit"] + 0.15)
			elseif suspensionHeight == 2 then setVehicleHandling(veh, "suspensionLowerLimit", modelHandling["suspensionLowerLimit"] + 0.1)
			elseif suspensionHeight == 3 then setVehicleHandling(veh, "suspensionLowerLimit", modelHandling["suspensionLowerLimit"] + 0.05)
			elseif suspensionHeight == 4 then setVehicleHandling(veh, "suspensionLowerLimit", nil)
			elseif suspensionHeight == 5 then setVehicleHandling(veh, "suspensionLowerLimit", modelHandling["suspensionLowerLimit"] - 0.05)
			elseif suspensionHeight == 6 then setVehicleHandling(veh, "suspensionLowerLimit", modelHandling["suspensionLowerLimit"] - 0.1)
			elseif suspensionHeight == 7 then setVehicleHandling(veh, "suspensionLowerLimit", modelHandling["suspensionLowerLimit"] - 0.15)
			end

		elseif option == 9 then
			setElementData(veh, "taxiPaySeat", index)
			exports.TR_noti:create(client, "Ücret başarıyla değiştirildi.", "success")

		elseif option == 10 then
			local newState = not getElementData(veh, "neonEnabled")
			setElementData(veh, "neonEnabled", newState)
			exports.TR_noti:create(client, newState and "Neon ışıkları açıldı." or "Neon ışıkları kapatıldı.", "success")
		end

		local x, y, z = getElementPosition(veh)
		if sound then triggerClientEvent(root, "playGlobalSound", resourceRoot, sound, x, y, z) end
	end
end
addEvent("interactionTrigger", true)
addEventHandler("interactionTrigger", resourceRoot, interactionTrigger)





function interactWithPlayer(target, type)
	if not isElement(target) then triggerClientEvent(client, "updateInteraction", resourceRoot) return end
	local interactionData = getInteractData(type)
	if not interactionData then return end
	local targetInteract = getElementData(target, "action")

	if targetInteract then
		if targetInteract.target == client and targetInteract.type == type then
			if (getTickCount() - targetInteract.time)/10000 >= 1 then
				exports.TR_noti:create(client, string.format("%s adlı oyuncunun teklif süresi doldu.", getPlayerName(target)), "info")
				removeElementData(target, "action")
				triggerClientEvent(client, "updateInteraction", resourceRoot)
				return
			else
				if targetInteract.type == "trade" then
					startPlayerTrading(client, target)
					return
				end

				local targetPos = Vector3(getElementPosition(target))
				local clientPos = Vector3(getElementPosition(client))

				if math.abs(targetPos.z - clientPos.z) > 0.1 then
					exports.TR_noti:create(client, "Boy farkı etkileşim için çok büyük.", "error")
					triggerClientEvent(client, "updateInteraction", resourceRoot)
					return
				end

				local targetRot = findRotation(targetPos.x, targetPos.y, clientPos.x, clientPos.y, "target")
				local clientRot = findRotation(clientPos.x, clientPos.y, targetPos.x, targetPos.y, "client")

				setElementRotation(target, 0, 0, targetRot)
				setElementRotation(client, 0, 0, clientRot)

				local newTargetPos = getPositionInFront(client, 0, interactionData.dist, 0)
				setElementPosition(target, newTargetPos)

				setPedAnimation(target, interactionData.targetAnim[1], interactionData.targetAnim[2], -1, false, false, false, false)
				setPedAnimation(client, interactionData.clientAnim[1], interactionData.clientAnim[2], -1, false, false, false, false)

				setElementData(target, "animation", {interactionData.targetAnim[1], interactionData.targetAnim[2]})
				setElementData(client, "animation", {interactionData.clientAnim[1], interactionData.clientAnim[2]})

				removeElementData(target, "action")
				removeElementData(client, "action")

				setElementData(target, "blockAction", true)
				setElementData(client, "blockAction", true)

				local plr = client
				setTimer(function()
					if isElement(target) then
						removeElementData(target, "blockAction")
						setElementData(target, "animation", false)
						triggerClientEvent(target, "addAchievements", resourceRoot, "playerHello")
					end
					if isElement(plr) then
						removeElementData(plr, "blockAction")
						setElementData(plr, "animation", false)
						triggerClientEvent(plr, "addAchievements", resourceRoot, "playerHello")
					end

				end, interactionData.animTime, 1)
				triggerClientEvent(client, "updateInteraction", resourceRoot)
				return
			end
		end
	end

	local plrInteract = getElementData(client, "action")
	if plrInteract then
		if plrInteract.target == target and (getTickCount() - plrInteract.time)/10000 < 1 then
			exports.TR_noti:create(client, string.format("%s adlı oyuncu sizin teklifinizi değerlendirmekte.", getPlayerName(target)), "error")
			triggerClientEvent(client, "updateInteraction", resourceRoot)
			return
		end
	end
	setElementData(client, "action", {
		time = getTickCount(),
		target = target,
		type = type,
	})
	exports.TR_noti:create(client, string.format(interactionData.clientText, getPlayerName(target)), interactionData.noti)
	exports.TR_noti:create(target, string.format(interactionData.targetText, getPlayerName(client)), interactionData.noti, 10)
	triggerClientEvent(client, "updateInteraction", resourceRoot)
end
addEvent("interactWithPlayer", true)
addEventHandler("interactWithPlayer", resourceRoot, interactWithPlayer)

function startPlayerTrading(client, target)
	triggerClientEvent(client, "createTrade", resourceRoot, target)
	triggerClientEvent(target, "createTrade", resourceRoot, client)
	removeElementData(client, "action")
	removeElementData(target, "action")
	setElementData(client, "blockAction", true)
	setElementData(target, "blockAction", true)
end



-- Vehicle interaction
function vehicleOpen(vehicle)
	if not isElement(vehicle) then triggerClientEvent(client, "updateInteraction", resourceRoot) return end
	if exports.TR_vehicles:canUseVehicle(vehicle, client) then
		setTimer(function()
			removeElementData(vehicle, "i:right", nil)
			removeElementData(vehicle, "i:left", nil)
			removeElementData(vehicle, "blockAction")
		end, 2000, 1)
		setElementData(vehicle, "i:right", true)
		setElementData(vehicle, "i:left", true)
		setElementData(vehicle, "blockAction", true)

		local isLocked = isVehicleLocked(vehicle)
		setVehicleLocked(vehicle, not isLocked)

		if not isLocked then
			for i = 2, 5 do
				setVehicleDoorOpenRatio(vehicle, i, 0, 500)
			end
		end

		triggerClientEvent(root, "playGlobalSound", resourceRoot, "files/sounds/lock.mp3", getElementPosition(vehicle))
		triggerClientEvent(client, "updateInteraction", resourceRoot)
		return
	end
	triggerClientEvent(client, "updateInteraction", resourceRoot, false, false, "Bu araç için uzaktan kumandanız yok.")
end
addEvent("vehicleOpen", true)
addEventHandler("vehicleOpen", resourceRoot, vehicleOpen)


function openVehicleDoor(vehicle, type)
	if not isElement(vehicle) then triggerClientEvent(client, "updateInteraction", resourceRoot) return end
	if exports.TR_vehicles:canUseVehicle(vehicle, client) then
		if type == "trunk" then
			if getVehicleDoorOpenRatio(vehicle, 1) == 0 then
				setVehicleDoorOpenRatio(vehicle, 1, 1, 1000)
			else
				setVehicleDoorOpenRatio(vehicle, 1, 0, 1000)
			end
		elseif type == "hood" then
			if getVehicleDoorOpenRatio(vehicle, 0) == 0 then
				setVehicleDoorOpenRatio(vehicle, 0, 1, 1000)
			else
				setVehicleDoorOpenRatio(vehicle, 0, 0, 1000)
			end
		end
		setElementData(vehicle, "blockAction", true)
		setTimer(removeElementData, 1000, 1, vehicle, "blockAction")
		triggerClientEvent(client, "updateInteraction", resourceRoot)
		return
	end
	triggerClientEvent(client, "updateInteraction", resourceRoot, false, false, "Bu aracın anahtarları sizde değil.")
end
addEvent("openVehicleDoor", true)
addEventHandler("openVehicleDoor", resourceRoot, openVehicleDoor)


function flipVehicle(veh)
	if getElementData(veh, "blockAction") then return end
	local plr = client

	if exports.TR_admin:isPlayerOnDuty(plr) then
		local rot = Vector3(getElementRotation(veh))
		setElementRotation(veh, 0, 0, rot.z)

		exports.TR_noti:create(plr, "Araç başarıyla döndürüldü.", "success")
		return
	end

	setElementData(veh, "blockAction", true)
	setElementData(plr, "blockAction", true)

	setElementFrozen(veh, true)
	setElementFrozen(plr, true)

	exports.TR_noti:create(plr, "Aracı döndürmeye başlıyorsunuz. 30 saniyenizi alacak.", "info")

	setTimer(function()
		local rot = Vector3(getElementRotation(veh))
		setElementRotation(veh, 0, 0, rot.z)

		setElementData(veh, "blockAction", nil)
		setElementData(plr, "blockAction", nil)

		setElementFrozen(veh, false)
		setElementFrozen(plr, false)

		exports.TR_noti:create(plr, "Araç başarıyla döndürüldü.", "success")
	end, 30000, 1)
end
addEvent("flipVehicle", true)
addEventHandler("flipVehicle", root, flipVehicle)


-- Utils
function getElementSpeedValue(element, typ)
    assert(isElement(element), "Kötü değer " .. type(element) .. ")")
    assert(getElementType(element) == "player" or getElementType(element) == "ped" or getElementType(element) == "object" or getElementType(element) == "vehicle", "(player/ped/object/vehicle" .. getElementType(element) .. ")")
    assert((typ == nil or type(typ) == "string" or type(typ) == "number") and ((tonumber(typ) and (tonumber(typ) == 0 or typ == tonumber(typ) == 1 or tonumber(typ) == 2)) or typ == "m/s" or typ == "km/h" or typ == "mph"), "Yanlış hız")
    typ = typ == nil and 0 or ((not tonumber(typ)) and typ or tonumber(typ))
    local mult = (typ == 0 or typ == "m/s") and 50 or ((typ == 1 or typ == "km/h") and 180 or 111.84681456)
    return (Vector3.create(getElementVelocity(element)) * mult).length
end

function findRotation( x1, y1, x2, y2 , data)
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end

function getPositionInFront(element,offX,offY,offZ)
    local m = getElementMatrix(element)
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return Vector3(x, y, z)
end

function getInteractData(type)
	local data = {
		["welcome"] = {
			dist = 1.15,
			animTime = 3500,
			noti = "handshake",

			targetAnim = {"GANGS", "hndshkba"},
			clientAnim = {"GANGS", "hndshkba"},

			targetText = "%s sana merhaba demek istiyor. Kabul etmek için etkileşimi kullanın.",
			clientText = "%s oyuncusunun selamını kabul ettin.",
		},
		["kiss"] = {
			dist = 1.08,
			animTime = 6500,
			noti = "heart",

			targetAnim = {"kissing", "grlfrd_kiss_02"},
			clientAnim = {"kissing", "playa_kiss_02"},

			targetText = "%s seni öpmek istiyor. Kabul etmek için etkileşimi kullanın.",
			clientText = "%s oyuncusunun teklifini kabul ettin.",
		},
		["trade"] = {
			noti = "trade",

			targetText = "%s sizinle ticaret yapmak istiyor. Kabul etmek için etkileşimi kullanın.",
			clientText = "%s oyuncusunun ticaret teklifini kabul ettin.",
		},
	}
	return data[type]
end



function giveLoudoutWeapons(type)
	if type == "remove" then
		exports.TR_weaponSlots:takeAllWeapons(client)

	elseif type == "armor" then
		setPedArmor(client, 100)

	else
		exports.TR_weaponSlots:giveWeapon(client, type[1], 9999, false)
	end
	triggerClientEvent(client, "updateInteraction", resourceRoot)
end
addEvent("giveLoudoutWeapons", true)
addEventHandler("giveLoudoutWeapons", root, giveLoudoutWeapons)


function removePedFromVehicle(veh, index)
	local plr = getVehicleOccupant(veh, index)
	if plr then
		triggerClientEvent(plr, "removePedFromVehicle", resourceRoot, index)
	end
	triggerClientEvent(client, "updateInteraction", resourceRoot)
end
addEvent("removePedFromVehicle", true)
addEventHandler("removePedFromVehicle", resourceRoot, removePedFromVehicle)

function giveVehicleGasoline(veh)
	local data = getElementData(veh, "vehicleData")
	data.fuel = math.min(data.fuel + 10, 10)
	setElementData(veh, "vehicleData", data)

	exports.TR_noti:create(client, "Araca başarıyla yakıt ikmali yapıldı.", "success")
	triggerClientEvent(client, "updateInteraction", resourceRoot)
end
addEvent("giveVehicleGasoline", true)
addEventHandler("giveVehicleGasoline", resourceRoot, giveVehicleGasoline)


function setVehicleUnfrozen(veh)
	if getElementHealth(veh) > 301 then
		setVehicleDamageProof(veh, false)
	end
	setElementFrozen(veh, false)

	exports.TR_noti:create(client, "El freni başarıyla kaldırıldı.", "success")
	triggerClientEvent(client, "updateInteraction", resourceRoot)
end
addEvent("setVehicleUnfrozen", true)
addEventHandler("setVehicleUnfrozen", resourceRoot, setVehicleUnfrozen)


function healMedicPlayer(plr)
	setElementHealth(plr, 100)
	exports.TR_noti:create(plr, string.format("%s seni iyleştirdi.", getPlayerName(client)), "success")
	exports.TR_noti:create(client, string.format("%s oyuncusunu iyleştirdin.", getPlayerName(plr)), "success")
end
addEvent("healMedicPlayer", true)
addEventHandler("healMedicPlayer", resourceRoot, healMedicPlayer)






-- Interiors drugs
function removeInteriorDrug(houseID, index)
	exports.TR_mysql:querry("DELETE FROM tr_gangHouseDrugs WHERE homeID = ? AND objectIndex = ?", houseID, index)
end
addEvent("removeInteriorDrug", true)
addEventHandler("removeInteriorDrug", resourceRoot, removeInteriorDrug)

function plantInteriorDrugs(houseID, index, plantType)
	exports.TR_mysql:querry("INSERT INTO tr_gangHouseDrugs (homeID, objectIndex, plantType, fertilizer, growth) VALUES (?, ?, ?, DATE_ADD(NOW(), INTERVAL 6 HOUR), DATE_ADD(NOW(), INTERVAL 1 DAY))", houseID, index, plantType)
end
addEvent("plantInteriorDrugs", true)
addEventHandler("plantInteriorDrugs", resourceRoot, plantInteriorDrugs)

function refilFertilizerInteriorDrugs(houseID, index, plantType)
	exports.TR_mysql:querry("UPDATE tr_gangHouseDrugs SET fertilizer = DATE_ADD(NOW(), INTERVAL 6 HOUR) WHERE homeID = ? AND objectIndex = ? LIMIT 1", houseID, index)
end
addEvent("refilFertilizerInteriorDrugs", true)
addEventHandler("refilFertilizerInteriorDrugs", resourceRoot, refilFertilizerInteriorDrugs)