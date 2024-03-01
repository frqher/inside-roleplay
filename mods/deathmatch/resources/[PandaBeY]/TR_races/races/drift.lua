local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 900/zoom)/2,
    y = sy - 250/zoom,
    w = 900/zoom,
    h = 40/zoom,

    settings = {
        minDriftAngle = 20,
        maxDriftAngle = 85,
        maxDriftCombo = 5,
        backToDriftTime = 2000,
    },
}

Drift = {}
Drift.__index = Drift

function Drift:create()
    local instance = {}
    setmetatable(instance, Drift)
    if instance:constructor() then
        return instance
    end
    return false
end

function Drift:constructor()
    self.driftDirection = false
    self.driftCombo = 1
    self.driftTime = 0
    self.isDrifting = false
    self.continuosDrift = false
    self.totalDriftScore = 0
    self.driftScore = 0

    self.fonts = {}
    self.fonts.score = exports.TR_dx:getFont(40)
    self.fonts.text = exports.TR_dx:getFont(20)
    self.fonts.combo = exports.TR_dx:getFont(20)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.onHit = function(...) self:onHit(source, ...) end

    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientVehicleCollision", root, self.func.onHit)
    return true
end

function Drift:destroy()
    removeEventHandler("onClientRender", root, self.func.render)
    removeEventHandler("onClientVehicleCollision", root, self.func.onHit)
    RaceData.drift = nil
    self = nil
end


function Drift:onHit(source, el, force)
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return end
    if source ~= veh then return end

    if force > 120 then
        self.driftCombo = math.max(self.driftCombo - 1, 1)
    end
end

function Drift:render()
    self:checkDrift()
end

function Drift:renderDriftMeter(angle)
    dxDrawImage(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, "files/images/driftBar.png", 0, 0, 0, tocolor(255, 255, 255, 255))
    dxDrawImage(guiInfo.x + (guiInfo.w - 14/zoom)/2 - (angle/120) * guiInfo.w/2, guiInfo.y, 14/zoom, guiInfo.h, "files/images/driftArrow.png", 0, 0, 0, tocolor(255, 255, 255, 255))

    local width = dxGetTextWidth(self.driftScore, 1/zoom, self.fonts.score)
    dxDrawText(self.driftScore, guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y - 40/zoom, cDriftColour, 1/zoom, self.fonts.score, "center", "bottom")

    if self.driftCombo > 1 then
        dxDrawText("x"..self.driftCombo, guiInfo.x + (guiInfo.w + width)/2 + 7/zoom, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y - 80/zoom, cDriftColour, 1/zoom, self.fonts.combo, "left", "bottom")
    end
    dxDrawText(self:getDriftText(), guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y - 15/zoom, cDriftColour, 1/zoom, self.fonts.text, "center", "bottom")
end

function Drift:getDriftText()
    if self.driftScore < 1 then
        return ""
    elseif self.driftScore < 30000 then
        return "EKSTRA!"
    elseif self.driftScore < 80000 then
        return "SUPER!"
    elseif self.driftScore < 120000 then
        return "HARİKASIN!"
    else
        return "YENİLMEZ!"
    end
end

function Drift:getTotalScore()
    return self.totalDriftScore
end

function Drift:addScoreToTotal()
    self.totalDriftScore = self.totalDriftScore + math.floor(self.driftScore * self.driftCombo)
end

function Drift:onMarkerHit()
    self.driftTick = getTickCount()
end

function Drift:checkPointTime()
    if not self.driftTick then return end

    if (getTickCount() - self.driftTick)/30000 >= 1 then
        RaceData.race:forceEnd()

        setTimer(function()
            exports.TR_noti:create("Kontrol noktalarını tamamlamadan çok fazla zaman geçti.", "error")
        end, 5000, 1)
    end
end

function Drift:checkDrift()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return end

    self:checkPointTime()

    local currentTick = getTickCount()

    local vVel = DriftVector3:new(getElementVelocity(veh))
    local fVelocity = vVel:length() * 160
    local vVel2 = vVel:mul(2)

    local vVehPos = DriftVector3:new(getElementPosition(veh))
    local fDriveDir = vVel:direction2D()
    local vRot = DriftVector3:new(getElementRotation(veh))
    local fRot = vRot.z

    local vOffset = DriftVector3:elementOffsetPosition(veh, DriftVector3:new( 0, 5, 0))
    vOffset = vOffset:sub(vVehPos)

    local vCross = vOffset:cross(vVel2)
    local fNormal = vCross:dot(DriftVector3:new(0, 0, 4))
    if fNormal > 0 then
        self.driftDirection = "right"
    elseif fNormal < 0 then
        self.driftDirection = "left"
    end

    if fDriveDir < 0 then -- NORTH -> TO WEST -> TO SOUTH
        fDriveDir = fDriveDir * -1;
    elseif fDriveDir > 0 then -- NORTH -> TO EAST -> TO SOUTH
        fDriveDir = 360 - fDriveDir;
    end

    local fDriftAng = math.abs( fRot - fDriveDir );
    if fDriftAng > 140 then
        if fRot < 360 and fRot > 180 and fDriveDir > 0 and fDriveDir < 180 then
            fDriftAng = 360 - fRot + fDriveDir;
        elseif fRot < 180 and fRot > 0 and fDriveDir > 180 and fDriveDir < 360 then
            fDriftAng = ( 360 - fDriveDir ) + fRot;
        end
    end

    if fVelocity < 1 or fDriftAng < 1 then
        self.driftDirection = "";
        fDriftAng = 0;
    end


    -- dxDrawText( "VEH ROT: " .. tostring( fRot ), 10, 300 );
    -- dxDrawText( "DRIVE DIR: " .. tostring( fDriveDir ), 10, 320 );
    -- dxDrawText( "VELOCITY DIR: " .. tostring( vVel:direction2D( ) ), 250, 320 );
    -- dxDrawText( "DRIFT angle: " .. tostring( fDriftAng ), 10, 350 );
    -- dxDrawText( "VELOCITY: " .. tostring( fVelocity ), 10, 380 );
    -- dxDrawText( "DRIFT DIR: " .. self.driftDirection, 10, 400 );


    local r, g, b = 255, 0, 0;
    local fAngPercent = ( fDriftAng / guiInfo.settings.maxDriftAngle ) * 4;
    if fAngPercent > 0 and fAngPercent < 1 then
        r = 255;
        g = 255 * fAngPercent;
    elseif fAngPercent > 1 and fAngPercent < 2 then
        r = 255 * (2 - fAngPercent);
        g = 255;
    elseif fAngPercent > 2 and fAngPercent < 3 then
        r = 255 * (1 - (4 - fAngPercent));
        g = 255;
    elseif fAngPercent > 3 and fAngPercent < 4 then
        r = 255;
        g = 255 * (5 - fAngPercent);
    end

    cDriftColour = tocolor( r, g, b );


    local needleAngle = fDriftAng < guiInfo.settings.maxDriftAngle and fDriftAng or guiInfo.settings.maxDriftAngle;
    needleAngle = self.driftDirection == "right" and needleAngle or needleAngle * -1;
    self:renderDriftMeter(needleAngle, cDriftColour)



    if fVelocity > 40 and fDriftAng > guiInfo.settings.minDriftAngle and fDriftAng < 60 and getVehicleCurrentGear(veh) > 0 and not self.continuosDrift and not self.isDrifting and isVehicleOnGround( veh ) then -- start DRIFT
        self.isDrifting = true
        self.continuosDrift = true
        self.driftStartTick = currentTick
        self.driftTime = 0

    elseif ( ( fVelocity < 40 and fVelocity ~= 0 ) or fDriftAng < guiInfo.settings.minDriftAngle ) and self.isDrifting or not isVehicleOnGround( veh ) then -- valid when stopped meeting requirements (still in drift)
        self.isDrifting = false
        self.endTickDrift = currentTick

    elseif fVelocity > 40 and fDriftAng > guiInfo.settings.minDriftAngle and self.continuosDrift and not self.isDrifting then -- triggered to back on drift (+1 combo)
        self.isDrifting = true
        self.driftStartTick = currentTick
        if self.driftCombo < guiInfo.settings.maxDriftCombo then
            self.driftCombo = self.driftCombo + 0.1
        end

    elseif not self.isDrifting and self.continuosDrift then -- called when stopped 1 drift but has chance for combo
        if currentTick - self.endTickDrift >= guiInfo.settings.backToDriftTime then
            self.totalDriftScore = self.totalDriftScore + math.floor(self.driftScore * self.driftCombo)

            RaceData.race:updateDetails()

            self.continuosDrift = false
            self.isDrifting = false
            self.endTickDrift = 0
            self.driftTime = 0
            self.driftCombo = 1
        end

    elseif self.isDrifting and self.continuosDrift then
        self.driftTime = self.driftTime + (currentTick - self.lastFrameTick);
    end

    self.driftScore = self.driftTime
    self.lastFrameTick = currentTick;
end



function createDriftCounter()
    RaceData.drift = Drift:create()
end