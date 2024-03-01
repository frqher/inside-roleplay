local vehicleSeats = {}

function playEnterAnim(plr, doors)
	if doors == 2 then
		setPedAnimation(plr, "TRUCK", "TRUCK_ALIGN_LHS", -1, false, false, false)
		setTimer(setPedAnimation, 500, 1, plr, "TRUCK", "TRUCK_open_LHS", -1, false, false, false)
		setTimer(setPedAnimation, 1000, 1, plr, "TRUCK", "TRUCK_getin_LHS", -1, false, false, false)

	elseif doors == 3 then
		setPedAnimation(plr, "TRUCK", "TRUCK_ALIGN_RHS", -1, false, false, false)
		setTimer(setPedAnimation, 500, 1, plr, "TRUCK", "TRUCK_open_RHS", -1, false, false, false)
		setTimer(setPedAnimation, 1000, 1, plr, "TRUCK", "TRUCK_getin_RHS", -1, false, false, false)

	end
end

function playExitAnim(plr, doors)
	if doors == 2 then
		setPedAnimation(plr, "TRUCK", "TRUCK_GETOUT_LHS", -1, false, true, false)
		setTimer(setPedAnimation, 500, 1, plr, "TRUCK", "TRUCK_CLOSE_LHS", -1, false)
		setTimer(setPedAnimation, 1000, 1, plr, nil, nil)

	elseif doors == 3 then
		setPedAnimation(plr, "TRUCK", "TRUCK_GETOUT_RHS", -1, false, true, false)
		setTimer(setPedAnimation, 500, 1, plr, "TRUCK", "TRUCK_CLOSE_RHS", -1, false)
		setTimer(setPedAnimation, 1000, 1, plr, nil, nil)
	end
end

function enterVehicleBackSeat(veh, doors)
	if not vehicleSeats[veh] then createVehicleSeats(veh) end

	local freeVeh, seat = getFreeVehicle(veh, doors)
	if not seat then exports.TR_noti:create(client, "Aracın bu tarafında boş koltuk yok.", "error") return end

	setElementCollisionsEnabled(client, false)

	playEnterAnim(client, doors)
	setTimer(setVehicleDoorOpenRatio, 700, 1, veh, doors + 2, 1, 250)
	setTimer(warpPedIntoVehicle, 1600, 1, client, freeVeh, seat)
	setTimer(setVehicleDoorOpenRatio, 1600, 1, veh, doors + 2, 0, 250)
	setTimer(setElementData, 1600, 1, client, "inv", true)
end
addEvent("enterVehicleBackSeat", true)
addEventHandler("enterVehicleBackSeat", resourceRoot, enterVehicleBackSeat)


function exitVehicleBackSeat(veh, doors)
	removePedFromVehicle(client)

	playExitAnim(client, doors)
	setVehicleDoorOpenRatio(veh, doors + 2, 1, 250)
	setTimer(setVehicleDoorOpenRatio, 800, 1, veh, doors + 2, 0, 250)
	setTimer(setElementCollisionsEnabled, 1000, 1, client, true)

	setElementData(client, "inv", false)
end
addEvent("exitVehicleBackSeat", true)
addEventHandler("exitVehicleBackSeat", resourceRoot, exitVehicleBackSeat)


function createVehicleSeats(veh, doors)
	if vehicleSeats[veh] then return end
	vehicleSeats[veh] = {}

	local model = getElementModel(veh)
	for i, v in pairs(multiSeatVehicles[model].seatOffsets) do
		local seatVeh = createVehicle(529, 0, 0, 0)

		setElementData(seatVeh, "inv", true)
		setElementAlpha(seatVeh, 0)
		setElementCollisionsEnabled(seatVeh, false)
		attachElements(seatVeh, veh, v.pos, v.rot)
		setVehicleDamageProof(seatVeh, true)

		table.insert(vehicleSeats[veh], {
			veh = seatVeh,
			doors2 = v.doors2,
            doors3 = v.doors3,
		})
	end
end

function getFreeVehicle(veh, doors)
	for i, v in pairs(vehicleSeats[veh]) do
		for seat = 2, 3 do
			if v["doors"..seat] == doors and not getVehicleOccupant(v.veh, seat) then
				return v.veh, seat
			end
		end
	end
	return false, false
end