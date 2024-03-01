local validDrivebyWeapons = { [22]=true,[23]=true,[24]=true,[25]=true,
[26]=true,[27]=true,[28]=true,[29]=true,[32]=true,[30]=true,[31]=true,
[32]=true,[33]=true,[38]=true }


function setDriverDrivebyAbility ( ... )
	local newTable = {...}
	for key,weaponID in ipairs(newTable) do
		if not validDrivebyWeapons[weaponID] then
			table.remove ( newTable, key )
		end
	end
	settings.driver = newTable
	lastSlot = 0
	return true
end

function setPassengerDrivebyAbility ( ... )
	local newTable = {...}
	for key,weaponID in ipairs(newTable) do
		if not validDrivebyWeapons[weaponID] then
			table.remove ( newTable, key )
		end
	end
	settings.passenger = newTable
	lastSlot = 0
	return true
end

function getDriverDrivebyAbility()
	return settings.driver
end

function getPassengerDrivebyAbility()
	return settings.passenger
end


function setWeaponShotDelay ( weaponID, delay )
	if not validDrivebyWeapons[weaponID] then
		outputDebugString ("setWeaponShotDelay: 'silahID' geçerli bir driveby silahı değil",0,255,255,0)
		return false
	end
	local delay = tonumber(delay)
	if not delay then
		outputDebugString ("setWeaponShotDelay: Bad 'delay' specified.",0,255,255,0)
		return false
	end
	settings.shotdelay[tostring(weaponID)] = delay
	return true
end

function getWeaponShotDelay(weaponID)
	if not validDrivebyWeapons[weaponID] then
		outputDebugString ("getWeaponShotDelay: 'weaponID' geçerli bir driveby silahı seçin",0,255,255,0)
		return false
	end
	return settings.shotdelay[tostring(weaponID)] or 0
end

function setDrivebySteeringAbility ( vehicles, bikes )
	if ( vehicles ) == nil then
		outputDebugString ("setDrivebySteeringAbility: Geçerli argümanlar geçilmedi.",0,255,255,0)
		return false
	end
	settings.steerCars = vehicles
	settings.steerBikes = type(bikes) ~= "boolean" and true or bikes
end

function getDrivebySteeringAbility ( dbType )
	if dbType == "car" then
		return settings.steerCars
	elseif dbType == "bike" then
		return settings.steerBikes
	else
		outputDebugString ("getDrivebySteeringAbility: Hatalı arabaya geçiş türü belirtildi. 'Araba' ya da 'bisiklet' olmalı.",0,255,255,0)
		return false
	end
end

function setDrivebyAutoEquip ( enabled )
	if type(enabled) ~= "boolean" then
		outputDebugString ("setDrivebyAutoEquip: Bad argument, should be a boolean.",0,255,255,0)
		return false
	end
	settings.autoEquip = enabled
	return true
end

function getDrivebyAutoEquip ()
	return settings.autoEquip
end


