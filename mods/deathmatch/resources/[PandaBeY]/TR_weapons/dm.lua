local sx, sy = guiGetScreenSize()

DeathMatch = {}
DeathMatch.__index = DeathMatch

function DeathMatch:create()
    local instance = {}
    setmetatable(instance, DeathMatch)
    if instance:constructor() then
        return instance
    end
    return false
end

function DeathMatch:constructor()
    self.zone = createColPolygon(unpack(borderPos))
    self.pirateEventZone = createColPolygon(unpack(pirateEventZone))
    self.wasInZone = false
    self.alpha = 0

    self.func = {}
    self.func.update = function() self:update() end
    self.func.render = function() self:render() end
    self.func.pedDamage = function() self:pedDamage(source) end
    self.func.weaponSwitch = function(...) self:weaponSwitch(...) end

    setTimer(self.func.update, 50, 0)
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientPedDamage", root, self.func.pedDamage)
    addEventHandler("onClientPlayerWeaponSwitch", localPlayer, self.func.weaponSwitch)
    return true
end

function DeathMatch:animate()
    if not self.tick then return end
    local progress = (getTickCount() - self.tick)/500
    if self.state == "opening" then
        self.alpha = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "Linear")
        if progress >= 1 then
            self.alpha = 1
            self.state = "blinking_up"
            self.tick = getTickCount()
            self.blinked = 0
        end

    elseif self.state == "blinking_up" then
        local progress = (getTickCount() - self.tick)/500
        self.alpha = interpolateBetween(1, 0, 0, 0.5, 0, 0, progress, "Linear")
        if progress >= 1 then
            self.alpha = 0.5
            self.state = "blinking_down"
            self.tick = getTickCount()
            self.blinked = self.blinked + 1
        end

    elseif self.state == "blinking_down" then
        local progress = (getTickCount() - self.tick)/500
        self.alpha = interpolateBetween(0.5, 0, 0, 1, 0, 0, progress, "Linear")
        if progress >= 1 then
            self.alpha = 1
            self.state = self.blinked < 3 and "blinking_up" or "closing"
            self.tick = getTickCount()
            self.blinked = self.blinked + 1
        end

    elseif self.state == "closing" then
        self.alpha = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "Linear")
        if progress >= 1 then
            self.alpha = 0
            self.state = "closed"
            self.tick = nil
        end
    end
end

function DeathMatch:render()
    self:animate()

    local color = self.inZone and tocolor(255, 60, 60, 255 * self.alpha) or tocolor(60, 255, 60, 255 * self.alpha)
    dxDrawImage(0, 0, sx, sy, "files/images/zone.png", 0, 0, 0, color)
end

function DeathMatch:update()
    if self.blocked then self:checkSpecialWeapons() return end
    if isElementInWater(localPlayer) then self:setControl(true) return end

    if self:canFight() then
        self:setControl(true)
    else
        self:setControl(false)
    end

    if self.inZone and not self.wasInZone then
        self.wasInZone = true

        self.tick = getTickCount()
        self.state = "opening"

    elseif not self.inZone and self.wasInZone then
        self.wasInZone = nil

        self.tick = getTickCount()
        self.state = "opening"
    end
end

function DeathMatch:setControl(state)
    toggleControl("fire", state)
    toggleControl("action", state)
    toggleControl("aim_weapon", state)

    self:checkSpecialWeapons()
end

function DeathMatch:checkSpecialWeapons()
    local weapon = getPedWeapon(localPlayer)

    if weapon == 37 or weapon == 38 then
        toggleControl("fire", false)
        toggleControl("action", false)
        toggleControl("aim_weapon", true)

    elseif weapon == 26 then
        toggleControl("fire", false)
        toggleControl("action", false)
    end
end

function DeathMatch:canFight()
    if not getElementData(localPlayer, "characterUID") then return end
    if not exports.TR_dx:canOpenGUI() then return false end
    local _, jobType = exports.TR_jobs:getPlayerJob()
    if jobType == "police" then return true end

    local int = getElementInterior(localPlayer)
    local dim =getElementDimension(localPlayer)

    if isElementWithinColShape(localPlayer, self.pirateEventZone) and int == 0 and dim == 29 then return true end

    if int ~= 0 or dim ~= 0 then return false end
    if isElementWithinColShape(localPlayer, self.zone) then self.inZone = true return true end
    self.inZone = false
    return false
end

function DeathMatch:blockUpdate(state)
    self.blocked = state
end

function DeathMatch:weaponSwitch(...)
    if getKeyState("e") then cancelEvent() return end
    -- if getKeyState("q") then cancelEvent() return end

    local team = getPlayerTeam(localPlayer)
    if team then
        local teamName = getTeamName(team)
        if teamName == "blue" or teamName == "red" then
            if arg[2] ~= 1 then
                cancelEvent()
            end
        end
    end

    self:checkSpecialWeapons()
end

function DeathMatch:pedDamage(source)
    cancelEvent()
    setElementHealth(source, 100)
end



local dm = DeathMatch:create()

function blockUpdate(state)
    dm:blockUpdate(state)
end

-- blockUpdate(true)
-- toggleControl("fire", false)
-- toggleControl("action", false)
-- toggleControl("aim_weapon", false)