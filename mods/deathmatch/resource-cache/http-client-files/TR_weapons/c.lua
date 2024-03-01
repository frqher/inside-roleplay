WeaponManager = {}
WeaponManager.__index = WeaponManager

function WeaponManager:create()
    local instance = {}
    setmetatable(instance, WeaponManager)
    if instance:constructor() then
        return instance
    end
    return false
end

function WeaponManager:constructor()
    self.objects = {}

    self.func = {}
    self.func.renderWeapons = function() self:renderWeapons() end
    self.func.updatePlayers = function() self:updatePlayers() end
    self.func.updateLocalPlayer = function() self:updateLocalPlayer() end

    setTimer(self.func.updatePlayers, 1000, 0)
    addEventHandler("onClientPreRender", root, self.func.renderWeapons)
    addEventHandler("onClientPlayerWeaponSwitch", localPlayer, self.func.updateLocalPlayer)
    return true
end

function WeaponManager:renderWeapons()
    for player, weapons in pairs(self.objects) do
        if isElement(player) then
            local int = getElementInterior(player)
            local dim = getElementDimension(player)
            local playerRot = Vector3(getElementRotation(player))
            local currentWeapon = getElementData(player, "weaponSelected")
            local isInVeh = getPedOccupiedVehicle(player)

            for i, weapon in pairs(weapons) do
                if currentWeapon == i then
                    self:destroyPlayerWeapon(player, currentWeapon)
                else
                    if isPedDucked(player) and weapon.duckedOffset then
                        local x, y, z = self:getPosition(player, weapon.bone, weapon.duckedOffset)
                        setElementPosition(weapon.model, x, y, z)
                    else
                        local x, y, z = self:getPosition(player, weapon.bone, weapon.offset)
                        setElementPosition(weapon.model, x, y, z)
                    end

                    if isPedDucked(player) and weapon.duckedRotation then
                        setElementRotation(weapon.model, playerRot.x + weapon.duckedRotation.x, playerRot.y + weapon.duckedRotation.y, playerRot.z + weapon.duckedRotation.z)
                    else
                        setElementRotation(weapon.model, playerRot.x + weapon.rotation.x, playerRot.y + weapon.rotation.y, playerRot.z + weapon.rotation.z)
                    end

                    setElementInterior(weapon.model, int)
                    setElementDimension(weapon.model, dim)
                    if isInVeh then
                        setElementAlpha(weapon.model, 0)
                    else
                        setElementAlpha(weapon.model, 255)
                    end
                end
            end

        else
            self:destroyPlayerWeapons(player)
            self.objects[player] = nil
        end
    end
end

function WeaponManager:updateLocalPlayer()
    local weapons = self:getPlayerWeapons(localPlayer)

    if weapons then
        if not self.objects[localPlayer] then
            self:createPlayerWeapons(localPlayer, weapons)
        else
            self:updatePlayerWeapons(localPlayer, weapons)
        end

    else
        self:destroyPlayerWeapons(localPlayer)
    end

    if self.lastWeapons ~= weapons then
        self.lastWeapons = weapons
    end
end

function WeaponManager:updatePlayers()
    for i, v in pairs(getElementsByType("player", root, true)) do
        local weapons = self:getPlayerWeapons(v)

        if weapons then
            if not self.objects[v] then
                self:createPlayerWeapons(v, weapons)
            else
                self:updatePlayerWeapons(v, weapons)
            end

        else
            self:destroyPlayerWeapons(v)
        end
    end

    for i, v in pairs(self.objects) do
        if not isElement(i) then
            for _, k in pairs(v) do
                destroyElement(k.model)
                self.objects[i] = nil
            end
        end
    end
end

function WeaponManager:updatePlayerWeapons(player, weapons)
    local hasWeapons = {}
    local currentWeapon = getElementData(player, "weaponSelected")

    for i, v in pairs(getElementData(player, "weapons") or {}) do
        hasWeapons[v] = true
    end
    for i, v in pairs(getElementData(player, "fakeWeapons") or {}) do
        hasWeapons[v] = true
    end

    for i, v in pairs(self.objects[player]) do
        if not hasWeapons[i] then
            self:destroyPlayerWeapon(player, i)
        end
    end

    for v, _ in pairs(hasWeapons) do
        if not self.objects[player][v] and v ~= currentWeapon then
            self:createPlayerWeapon(player, v)
        end
    end
end

function WeaponManager:createPlayerWeapon(player, weaponID)
    if weaponData[weaponID] then
        local data = weaponData[weaponID]
        local weapon = createObject(data.model, 0, 0, 0)
        setElementCollisionsEnabled(weapon, false)
        setElementDoubleSided(weapon, true)

        self.objects[player][weaponID] = {
            model = weapon,
            offset = data.offset,
            rotation = data.rotation,
            duckedOffset = data.duckedOffset,
            duckedRotation = data.duckedRotation,
            bone = data.bone,
        }
    end
end

function WeaponManager:destroyPlayerWeapon(player, weapon)
    if not self.objects[player][weapon] then return end
    destroyElement(self.objects[player][weapon].model)
    self.objects[player][weapon] = nil
end

function WeaponManager:createPlayerWeapons(player, weapons)
    if self.objects[player] then return end
    self.objects[player] = {}

    for i, v in pairs(weapons) do
        if weaponData[v] then
            local data = weaponData[v]

            local weapon = createObject(data.model, 0, 0, 0)
            setElementCollisionsEnabled(weapon, false)
            setElementDoubleSided(weapon, true)

            self.objects[player][v] = {
                model = weapon,
                offset = data.offset,
                rotation = data.rotation,
                duckedOffset = data.duckedOffset,
                duckedRotation = data.duckedRotation,
                bone = data.bone,
            }
        end
    end
end

function WeaponManager:destroyPlayerWeapons(player)
    if not self.objects[player] then return end
    for i, v in pairs(self.objects[player]) do
        destroyElement(v.model)
    end

    self.objects[player] = nil
end


function WeaponManager:getPosition(element, bone, vec)
    local rot = Vector3(getElementRotation(element))
	local mat = Matrix(bone and Vector3(getPedBonePosition(element, bone)) or Vector3(getElementPosition(element)), rot)
	local newPos = mat:transformPosition(vec)
	return newPos.x, newPos.y, newPos.z, rot.z
end

function WeaponManager:getPlayerWeapons(player)
    -- return getElementData(player, "weapons") or {}
    return {unpack(getElementData(player, "weapons") or {}), unpack(getElementData(player, "fakeWeapons") or {})}
end

local changer = WeaponManager:create()
function updateWeapons()
    changer:updateLocalPlayer()
end
addEvent("updateWeapons", true)
addEventHandler("updateWeapons", root, updateWeapons)