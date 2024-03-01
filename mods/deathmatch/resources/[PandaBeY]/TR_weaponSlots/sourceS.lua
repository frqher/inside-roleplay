_giveWeapon = giveWeapon
_takeWeapon = takeWeapon
_takeAllWeapons = takeAllWeapons
thisResourceName = getResourceName( getThisResource(  ) )

function loadAllPlayerWeapons()
    setTimer(function()
    	for i,v in ipairs(getElementsByType("player")) do
    	    _takeAllWeapons(v)
    	    local weapons = getElementData(v, "tempWeapons")
    	    if weapons then
    	    	giveWeaponsFromJSON(v, weapons)
    	    	removeElementData( v, "tempWeapons")
    	    end
    	end
	end, 500, 1)
end
addEventHandler("onResourceStart", resourceRoot, loadAllPlayerWeapons)

addEventHandler("onResourceStop", resourceRoot, function()
     for i,v in ipairs(getElementsByType("player")) do
         _takeAllWeapons(v)
     end
end)


function giveWeaponsFromJSON(player, weapons)
    if (weapons and type(weapons) == "string") then
        for weapon, data in pairs(fromJSON(weapons)) do
        	local maximum_clip_ammo = getWeaponProperty (data[1], "poor", "maximum_clip_ammo")
        	local ammo = data[3]
        	if not ammo or ammo <= 0 then
        		ammo = maximum_clip_ammo
        	end
        	giveWeapon(player, data[1], data[2] - ( maximum_clip_ammo - ammo ), data[4])
        end
    end
end


function setWeaponSlot (weapon, totalAmmo, ammoInClip)
    _takeAllWeapons(client)
    _giveWeapon(client, weapon, totalAmmo, true)
    setWeaponAmmo (client, weapon, totalAmmo, ammoInClip)
end
addEvent( "onPlayerSlotSwitch", true)
addEventHandler( "onPlayerSlotSwitch", resourceRoot, setWeaponSlot)

addEvent( "onPlayerAmmoAdd", true)
addEventHandler( "onPlayerAmmoAdd", resourceRoot, function (weapon,ammo)
    local totalAmmo = getPedTotalAmmo(client)
    local ammoInClip = getPedAmmoInClip(client)
    setWeaponAmmo(client, weapon, totalAmmo+ammo, ammoInClip)
end)

addEvent( "onPlayerAmmoTake", true)
addEventHandler( "onPlayerAmmoTake", resourceRoot, function (weapon,ammo)
    local totalAmmo = getPedTotalAmmo(client)
    local ammoInClip = getPedAmmoInClip(client)
    setWeaponAmmo(client, weapon, totalAmmo-ammo, ammoInClip)
end)

function giveWeapon(thePed, weapon, ammo, switchTo)
    triggerClientEvent ( thePed, "onClientPlayerWeaponGive", thePed, weapon, ammo, switchTo)
end

function takeWeapon(thePed, weapon, ammo)
	triggerClientEvent ( thePed, "onClientPlayerWeaponTake", thePed, weapon, ammo)
end

function takeAllWeapons(thePed)
	triggerClientEvent ( thePed, "onClientPlayerWeaponTakeAll", thePed)
end

function onSyncedWeaponResources( sourceResource, functionName, isAllowedByACL, luaFilename, luaLineNumber, ... )
    local args = { ... }
    local resname = sourceResource and getResourceName(sourceResource)

    if functionName == "giveWeapon" and resname ~= thisResourceName then
        giveWeapon(...)
    elseif functionName == "takeWeapon" and resname ~= thisResourceName then
        takeWeapon(...)
    elseif functionName == "takeAllWeapons" and resname ~= thisResourceName then
       takeAllWeapons(...)
    end
end
addDebugHook("preFunction", onSyncedWeaponResources, {"takeAllWeapons"})