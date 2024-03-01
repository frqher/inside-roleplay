local currentSlotID, weaponsTable, swapTimer

function updatePlayerWeapons()
    local weapons = {}

    for i, v in pairs(weaponsTable) do
        table.insert(weapons, tonumber(v[1]))
    end
    setElementData(localPlayer, "weapons", weapons)
    exports.TR_weapons:updateWeapons()
end

function resetWeapons ()
    currentSlotID = 1
    weaponsTable = {{0,1,1,true}}
end

function hasWeapon (weaponID)
    local weaponID = tonumber(weaponID)
    for i,v in ipairs(weaponsTable) do
        if v[1]==weaponID then return i end
    end
    return false
end

function giveWeapon (weapon,ammo,switchTo)
    local slotID = hasWeapon (weapon)
    if slotID then
        local theRow = weaponsTable[slotID]
        if getPedWeapon(localPlayer)==weapon then
            triggerServerEvent("onPlayerAmmoAdd",resourceRoot,tonumber(weapon),tonumber(ammo))
        else
            theRow[2] = theRow[2]+ammo
            if switchTo==true then setWeaponSlot(slotID) end
        end
        return slotID
    else
        table.insert(weaponsTable,{tonumber(weapon),tonumber(ammo),0,false})

        local newSlotID = table.getn(weaponsTable)
        if switchTo==true then setWeaponSlot(newSlotID) end
        return newSlotID
    end
end

function takeWeapon(weaponID, ammo)
    local slotID = hasWeapon (weaponID)
    if slotID then
        local theRow = weaponsTable[slotID]
        local ammo = ammo or theRow[2]
        theRow[2] = theRow[2]-ammo
        if theRow[2] <= 0 then
            table.remove (weaponsTable, slotID)
            setPedWeaponSlot( localPlayer, 0 )
            currentSlotID = 1

        elseif getPedWeapon(localPlayer) == weaponID then
            triggerServerEvent("onPlayerAmmoTake",resourceRoot,weaponID,ammo)
        end

        updatePlayerWeapons()
    end
end

function takeAllWeapon()
    for i=1,13  do takeWeapon(i) end
    for i=14,18 do takeWeapon(i) end
    for i=22,46 do takeWeapon(i) end
end

function setWeaponSlot (newSlotID)
    if isTimer(swapTimer) then killTimer(swapTimer) return false end
    swapTimer = setTimer (function (newSlotID)
        if not getPedTask (localPlayer,"secondary",0) then
            local totalSlots = table.getn(weaponsTable)
            if newSlotID > totalSlots then newSlotID = 1 elseif newSlotID < 1 then newSlotID = totalSlots end

            local wep = weaponsTable[newSlotID]
            -- if tonumber(weaponsTable[currentSlotID][1]) > 1 then
            --     weaponsTable[currentSlotID][2] = getPedTotalAmmo (localPlayer)
            --     weaponsTable[currentSlotID][3] = getPedAmmoInClip (localPlayer)
            -- end

            triggerServerEvent("onPlayerSlotSwitch", resourceRoot, wep[1], wep[2], wep[3])
            currentSlotID = newSlotID
            killTimer(swapTimer)

            setElementData(localPlayer, "weaponSelected", wep[1])
        end
    end, 50, 1, newSlotID)
end

addEvent("onClientPlayerWeaponGive",true)
addEventHandler("onClientPlayerWeaponGive", localPlayer, function(weapon, ammo, switchTo)
   local slotID = giveWeapon(weapon,ammo,switchTo)
   updatePlayerWeapons()
end)

addEvent("onClientPlayerWeaponTake",true)
addEventHandler("onClientPlayerWeaponTake", localPlayer, function(weapon, ammo, switchTo)
    local slotID = takeWeapon(weapon, ammo)
    updatePlayerWeapons()
end)

addEvent("onClientPlayerWeaponTakeAll",true)
addEventHandler("onClientPlayerWeaponTakeAll", localPlayer, function(weapon, ammo, switchTo)
    local slotID = takeAllWeapon(weapon,ammo,switchTo)
    updatePlayerWeapons()
end)


addEventHandler("onClientPlayerWeaponFire", root, function(weapon, ammo, clip)
    if source==localPlayer then
        if ammo == 0 then
            table.remove(weaponsTable, currentSlotID)
            currentSlotID = 1
        else
            weaponsTable[currentSlotID][2] = ammo
            weaponsTable[currentSlotID][3] = clip
        end
    end
end)

addEventHandler ("onClientPlayerWasted", resourceRoot, function()
    if localPlayer == source then resetWeapons() end
end)

addEventHandler ("onClientResourceStart", resourceRoot, function()
    resetWeapons()
    toggleControl("next_weapon", false)
    toggleControl("previous_weapon", false)
end)

addEventHandler ("onClientResourceStop", resourceRoot, function()
    toggleControl("next_weapon", true)
    toggleControl("previous_weapon", true)
end)

function changeWeapon (key)
    if key=="next_weapon" then
        if getKeyState("e") then return end
        if not isControlEnabled("next_weapon") then setWeaponSlot(currentSlotID, currentSlotID) return end
        if exports.TR_fishing:isPlayerFishing() then setWeaponSlot(currentSlotID, currentSlotID) return end

        setWeaponSlot(currentSlotID+1, currentSlotID)

    else
        if not isControlEnabled("previous_weapon") then setWeaponSlot(currentSlotID, currentSlotID) return end
        if exports.TR_fishing:isPlayerFishing() then setWeaponSlot(currentSlotID, currentSlotID) return end

        setWeaponSlot(currentSlotID-1, currentSlotID)
    end
end
bindKey("next_weapon", "down", changeWeapon)
bindKey("previous_weapon", "down", changeWeapon)


function saveAllPlayerWeapons()
    local weapons = convertWeaponsToJSON(localPlayer)
    setElementData(localPlayer, "tempWeapons", weapons)
end
addEventHandler("onClientResourceStop", resourceRoot, saveAllPlayerWeapons)

function convertWeaponsToJSON(player)
    local tempTable = {}
    for weaponID=1,46 do
        local weapon = hasWeapon(weaponID)
        if weapon then
          local theRow = weaponsTable[weapon]
          tempTable[weaponID] = theRow
        end
    end
    return toJSON(tempTable)
end

function getWeaponsTable()
    return weaponsTable, currentSlotID
end

local reloadTimer = nil
function checkReload()
    if isTimer(reloadTimer) then killTimer(reloadTimer) end

    reloadTimer = setTimer(function()
        if isPedReloadingWeapon(localPlayer) then
            local maximum_clip_ammo = getWeaponProperty(weaponsTable[currentSlotID][1], "poor", "maximum_clip_ammo")
            weaponsTable[currentSlotID][2] = getPedTotalAmmo(localPlayer)
            weaponsTable[currentSlotID][3] = maximum_clip_ammo
        end
    end, 800, 1)
end
bindKey("r", "down", checkReload)