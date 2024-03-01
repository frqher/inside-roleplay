local settings = {
	driver = {22,23,24,28,29,32},
	passenger = {22,23,24,28,29,32,25,30,31},
	shotdelay = {['22']=300,['23']=300,['24']=800},
	blockedVehicles = {432,601,437,431,592,553,577,488,497,548,563,512,476,447,425,519,520,460,417,469,487,513,441,464,501,465,564,538,449,537,539,570,472,473,493,595,484,430,453,452,446,454,606,591,607,611,610,590,569,611,435,608,584,450},
	steerCars = true,
	steerBikes = true,
	autoEquip = false,

	seatWindows = {
		[0] = 4,
		[1] = 2,
		[2] = 5,
		[3] = 3,
	},

	withoutRoof = {
		[536] = true, -- Blade
		[575] = true, -- Broadway
		[567] = true, -- Savanna
		[533] = true, -- Feltzer
		[480] = true, -- Commet
		[429] = true, -- Banshee
		[555] = true, -- Vindsor
		[506] = true, -- Super-GT
		[531] = true, -- Tractor
		[572] = true, -- Mower
		[485] = true, -- Baggage
		[471] = true, -- Quad
		[571] = true, -- Cart
		[424] = true, -- BF Injector
		[568] = true, -- Bandito
	},
}

local driver = false
local shooting = false
local helpAnimation
local updateTimer
lastSlot = 0


--This function simply sets up the driveby upon vehicle entry
local function setupDriveby( player, seat )
	--If his seat is 0, store the fact that he's a driver
	if seat == 0 then
		driver = true
	else
		driver = false
	end
	--By default, we set the player's equiped weapon to nothing.
	setPedWeaponSlot( localPlayer, 0 )
	if settings.autoEquip then
		toggleDriveby()
	end
end
addEventHandler( "onClientPlayerVehicleEnter", localPlayer, setupDriveby )

--Tell the server the clientside script was downloaded and started
addEventHandler("onClientResourceStart",getResourceRootElement(getThisResource()),
	function()
		bindKey ( "mouse2", "down", "Toggle Driveby", "" )
		bindKey ( "e", "down", "Next driveby weapon", "1" )
		bindKey ( "q", "down", "Previous driveby weapon", "-1" )
		toggleControl ( "vehicle_next_weapon",false )
		toggleControl ( "vehicle_previous_weapon",false )
		-- triggerServerEvent ( "driveby_clientScriptLoaded", localPlayer )
	end
)

addEventHandler("onClientResourceStop",getResourceRootElement(getThisResource()),
	function()
		toggleControl ( "vehicle_next_weapon",true )
		toggleControl ( "vehicle_previous_weapon",true )
	end
)

--Get the settings details from the server, and act appropriately according to them
addEvent ( "doSendDriveBySettings", true )
addEventHandler("doSendDriveBySettings",localPlayer,
	function(newSettings)
		settings = newSettings
		--We change the blocked vehicles into an indexed table that's easier to check
		local newTable = {}
		for key,vehicleID in ipairs(settings.blockedVehicles) do
			newTable[vehicleID] = true
		end
		settings.blockedVehicles = newTable
	end
)

--This function handles the driveby toggling key.
function toggleDriveby()
	--If he's not in a vehicle dont bother
	if not isPedInVehicle( localPlayer ) then return end
	--If its a blocked vehicle dont allow it
	local vehicle = getPedOccupiedVehicle ( localPlayer )
	local vehicleID = getElementModel(vehicle)
	if settings.blockedVehicles[vehicleID] then return end
	--Has he got a weapon equiped?
	local equipedWeapon = getPedWeaponSlot( localPlayer )
	if equipedWeapon == 0 then
		if not isControlEnabled("fire") then return end
		if getElementData(localPlayer, "cuffedBy") then return end
		local seat = getPedOccupiedVehicleSeat(localPlayer)
		if getVehicleType(vehicle) ~= "Bike" and getVehicleType(vehicle) ~= "BMX" and not isVehicleWindowOpen(vehicle, settings.seatWindows[seat]) and not settings.withoutRoof[vehicleID] then
			exports.TR_noti:create("Aby móc strzelać z pojazdu musisz najpierw otworzyć szybę.", "info")
			return
		end

		--Decide whether he is a driver or passenger
		if ( driver ) then weaponsTable = settings.driver
		else weaponsTable = settings.passenger end
		--We need to get the switchTo weapon by finding any valid IDs
		local switchTo
		local switchToWeapon
		local lastSlotAmmo = getPedTotalAmmo ( localPlayer, lastSlot )
		if not lastSlotAmmo or lastSlotAmmo == 0 or getSlotFromWeapon(getPedWeapon (localPlayer,lastSlot)) == 0 then
			for key,weaponID in ipairs(weaponsTable) do
				local slot = getSlotFromWeapon ( weaponID )
				local weapon = getPedWeapon ( localPlayer, slot )
				if weapon == 1 then weapon = 0 end --If its a brass knuckle, set it to a fist to avoid confusion
				--if the weapon the player has is valid
				if weapon == weaponID then
					--If the ammo isn't 0
					if getPedTotalAmmo ( localPlayer, slot ) ~= 0 then
						--If no switchTo slot was defined, or the slot was 4 (SMG slot takes priority)
						if not switchTo or slot == 4 then
							switchTo = slot
							switchToWeapon = weaponID
						end
					end
				end
			end
		else
			local lastSlotWeapon = getPedWeapon ( localPlayer, lastSlot )
			for key,weaponID in ipairs(weaponsTable) do --If our last used weapon is a valid weapon
				if weaponID == lastSlotWeapon then
					switchTo = lastSlot
					switchToWeapon = lastSlotWeapon
					break
				end
			end
		end
		--If a valid weapon was not found, dont set anything.
		if not switchTo then return end
		setPedDoingGangDriveby ( localPlayer, true )
		setPedWeaponSlot( localPlayer, switchTo )
		--Setup our driveby limiter
		limitDrivebySpeed ( switchToWeapon )
		--Disable look left/right keys, they seem to become accelerate/decelerate (carried over from PS2 version)
		toggleControl ( "vehicle_look_left",false )
		toggleControl ( "vehicle_look_right",false )
		toggleControl ( "vehicle_secondary_fire",false )
		toggleTurningKeys(vehicleID,false)
		addEventHandler ( "onClientPlayerVehicleExit",localPlayer,removeKeyToggles )
		local prevw,nextw = next(getBoundKeys ( "Previous driveby weapon" )),next(getBoundKeys ( "Next driveby weapon" ))
		if prevw and nextw then
			if animation then Animation:remove() end
		end

		if isTimer(updateTimer) then killTimer(updateTimer) end
		updateTimer = setTimer(checkCanDriveby, 1000, 0)
	else
		if isTimer(updateTimer) then killTimer(updateTimer) end
		updateTimer = nil

		--If so, unequip it
		setPedDoingGangDriveby ( localPlayer, false )
		setPedWeaponSlot( localPlayer, 0 )
		limitDrivebySpeed ( switchToWeapon )
		toggleControl ( "vehicle_look_left",true )
		toggleControl ( "vehicle_look_right",true )
		toggleControl ( "vehicle_secondary_fire",true )
		toggleTurningKeys(vehicleID,true)
		removeEventHandler ( "onClientPlayerVehicleExit",localPlayer,removeKeyToggles )
	end
end
addCommandHandler ( "Toggle Driveby", toggleDriveby )

function removeKeyToggles(vehicle)
	toggleControl ( "vehicle_look_left",true )
	toggleControl ( "vehicle_look_right",true )
	toggleControl ( "vehicle_secondary_fire",true )
	toggleTurningKeys(getElementModel(vehicle),true)
	removeEventHandler ( "onClientPlayerVehicleExit",localPlayer,removeKeyToggles )
end


--This function handles the driveby switch weapon key
function switchDrivebyWeapon(key,progress)
	progress = tonumber(progress)
	if not progress then return end
	--If the fire button is being pressed dont switch
	if shooting then return end
	--If he's not in a vehicle dont bother
	if not isPedInVehicle( localPlayer ) then return end
	--If he's not in driveby mode dont bother either
	local currentWeapon = getPedWeapon( localPlayer )
	if currentWeapon == 1 then currentWeapon = 0 end --If its a brass knuckle, set it to a fist to avoid confusion
	local currentSlot = getPedWeaponSlot(localPlayer)
	if currentSlot == 0 then return end
	if ( driver ) then weaponsTable = settings.driver
	else weaponsTable = settings.passenger end
	--Compile a list of the player's weapons
	local switchTo
	for key,weaponID in ipairs(weaponsTable) do
		if weaponID == currentWeapon then
			local i = key + progress
			--We keep looping the table until we go back to our original key
			while i ~= key do
				nextWeapon = weaponsTable[i]
				if nextWeapon then
					local slot = getSlotFromWeapon ( nextWeapon )
					local weapon = getPedWeapon ( localPlayer, slot )
					if ( weapon == nextWeapon  ) then
						switchToWeapon = weapon
						switchTo = slot
						break
					end
				end
				--Go back to the beginning if there is no valid weapons left in the table
				if not weaponsTable[i+progress] then
					if progress < 0 then
						i = #weaponsTable
					else
						i = 1
					end
				else
					i = i + progress
				end
			end
			break
		end
	end
	--If a valid weapon was not found, dont set anything.
	if not switchTo then return end
	lastSlot = switchTo
	setPedWeaponSlot( localPlayer, switchTo )
	limitDrivebySpeed ( switchToWeapon )
end
addCommandHandler ( "Next driveby weapon", switchDrivebyWeapon )
addCommandHandler ( "Previous driveby weapon", switchDrivebyWeapon )

--Here lies the stuff that limits shooting speed (so slow weapons dont shoot ridiculously fast)
local limiterTimer
function limitDrivebySpeed ( weaponID )
	local speed = settings.shotdelay[tostring(weaponID)]
	if not speed then
		if not isControlEnabled ( "vehicle_fire" ) then
			toggleControl ( "vehicle_fire", true )
		end
		removeEventHandler("onClientPlayerVehicleExit",localPlayer,unbindFire)
		removeEventHandler("onClientPlayerWasted",localPlayer,unbindFire)
		unbindKey ( "vehicle_fire", "both", limitedKeyPress )
	else
		if isControlEnabled ( "vehicle_fire" ) then
			toggleControl ( "vehicle_fire", false )
			addEventHandler("onClientPlayerVehicleExit",localPlayer,unbindFire)
			addEventHandler("onClientPlayerWasted",localPlayer,unbindFire)
			bindKey ( "vehicle_fire","both",limitedKeyPress,speed)
		end
	end
end

function unbindFire()
	shooting = false
	setPedControlState("vehicle_fire", false)
	unbindKey ( "vehicle_fire", "both", limitedKeyPress )
	if not isControlEnabled ( "vehicle_fire" ) then
			toggleControl ( "vehicle_fire", true )
	end
	removeEventHandler("onClientPlayerVehicleExit",localPlayer,unbindFire)
	removeEventHandler("onClientPlayerWasted",localPlayer,unbindFire)
end

local block
function limitedKeyPress (key,keyState,speed)
	if keyState == "down" then
		if block == true then return end
		shooting = true
		pressKey ( "vehicle_fire" )
		block = true
		setTimer ( function() block = false end, speed, 1 )
		limiterTimer = setTimer ( pressKey,speed, 0, "vehicle_fire" )
	else
		shooting = false
		for k,timer in ipairs(getTimers()) do
			if timer == limiterTimer then
				killTimer ( limiterTimer )
			end
		end
	end
end

function pressKey ( controlName )
	setPedControlState ( controlName, true )
	setTimer ( setPedControlState, 150, 1, controlName, false )
end

function checkCanDriveby()
	local veh = getPedOccupiedVehicle(localPlayer)
	if not veh then return end

	local vehSpeed = getElementSpeed(veh, 1)
	if not isControlEnabled("fire") or getElementData(localPlayer, "cuffedBy") or vehSpeed >= 50 then
		if isTimer(updateTimer) then killTimer(updateTimer) end
		updateTimer = nil

		--If so, unequip it
		setPedDoingGangDriveby ( localPlayer, false )
		setPedWeaponSlot( localPlayer, 0 )
		limitDrivebySpeed ( switchToWeapon )
		toggleControl ( "vehicle_look_left",true )
		toggleControl ( "vehicle_look_right",true )
		toggleControl ( "vehicle_secondary_fire",true )
		toggleTurningKeys(vehicleID,true)
		removeEventHandler ( "onClientPlayerVehicleExit",localPlayer,removeKeyToggles )
	end
end

function getElementSpeed(theElement, unit)
	if not isElement(theElement) then return 0 end
    local elementType = getElementType(theElement)
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    return (Vector3(getElementVelocity(theElement)) * mult).length
end

---Left/right toggling
local bikes = { [581]=true,[509]=true,[481]=true,[462]=true,[521]=true,[463]=true,
	[510]=true,[522]=true,[461]=true,[448]=true,[468]=true,[586]=true }
function toggleTurningKeys(vehicleID, state)
	if bikes[vehicleID] then
		if not settings.steerBikes then
			toggleControl ( "vehicle_left", state )
			toggleControl ( "vehicle_right", state )
		end
	else
		if not settings.steerCars then
			toggleControl ( "vehicle_left", state )
			toggleControl ( "vehicle_right", state )
		end
	end
end

local function onWeaponSwitchWhileDriveby (prevSlot, curSlot)
	if isPedDoingGangDriveby(source) then
		limitDrivebySpeed(getPedWeapon(source, curSlot))
	end
end
addEventHandler ("onClientPlayerWeaponSwitch", localPlayer, onWeaponSwitchWhileDriveby)
