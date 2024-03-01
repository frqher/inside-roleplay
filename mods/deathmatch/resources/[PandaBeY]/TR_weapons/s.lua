function addPlayerWeaponLicence(data, pos)
    exports.TR_weaponSlots:takeAllWeapons(client)
    exports.TR_weaponSlots:giveWeapon(client, data.weapon, data.ammo, true)

    if pos then setElementData(client, "characterQuit", pos, false) end
end
addEvent("addPlayerWeaponLicence", true)
addEventHandler("addPlayerWeaponLicence", resourceRoot, addPlayerWeaponLicence)

function takePlayerWeaponLicence(passed)
    exports.TR_weaponSlots:takeAllWeapons(client)
    removeElementData(client, "characterQuit")

    if passed then
        local uid = getElementData(client, "characterUID")
        local licences = exports.TR_mysql:querry("SELECT licence FROM tr_accounts WHERE UID = ? LIMIT 1", uid)
        licences = licences[1].licence and fromJSON(licences[1].licence) or {}

        licences["weapon"] = true

        exports.TR_mysql:querry("UPDATE `tr_accounts` SET licence = ? WHERE UID = ? LIMIT 1", toJSON(licences), uid)
    end
end
addEvent("takePlayerWeaponLicence", true)
addEventHandler("takePlayerWeaponLicence", resourceRoot, takePlayerWeaponLicence)

function checkDamage(att, weap, body, loss)
    setCustomDamage(source, att, weap, body, loss)
    local armorID = getElementData(source, "armorID")
    if not armorID then return end

    local armor = getPedArmor(source)
    exports.TR_mysql:querry("UPDATE tr_items SET value = ? WHERE ID = ? LIMIT 1", armor, armorID)
end
addEventHandler("onPlayerDamage", root, checkDamage)

function setCustomDamage(plr, att, weapon, body, loss)
    if body == 9 then
        killPed(plr)
        cancelEvent()
    end
    if weapon == 8 then
        setElementHealth(plr, getElementHealth(plr) - 20)
        cancelEvent()
    end
end



-- local veh = createVehicle(433, 2081.208984375, -1811.8837890625, 13.3828125)
-- print(getVehicleHandling(veh)["modelFlags"])

-- setVehicleHandling(veh, "modelFlags", 2092209)