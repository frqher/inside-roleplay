LapRace = {}
LapRace.__index = LapRace

function LapRace:create(...)
    local instance = {}
    setmetatable(instance, LapRace)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function LapRace:constructor(...)
    self.laps = arg[1]
    self.track = arg[2]
    self.raceID = arg[3]
    self.lap = 1
    self.point = 1
    self.markers = {}
    self.blips = {}
    self.lastTimes = 0

    self.func = {}
    self.func.waterCheck = function() self:waterCheck() end
    self.func.onMarkerHit = function(...) self:onMarkerHit(source, ...) end
    self.func.updateCollisions = function() self:updateCollisions() end

    exports.TR_hud:updateRaceDetails({
        lap = 1,
        laps = self.laps,
        percent = 0,
    })

    exports.TR_dx:setOpenGUI(true)
    self:createNextPoints()

    self.waterTimer = setTimer(self.func.waterCheck, 1000, 0)
    addEventHandler("onClientMarkerHit", resourceRoot, self.func.onMarkerHit)
    self.colTimer = setTimer(self.func.updateCollisions, 1000, 1)

    setElementData(localPlayer, "inRace", true, false)
    return true
end

function LapRace:destroyMarkers()
    for i, v in pairs(self.markers) do
        if isElement(v) then destroyElement(v) end
    end
    for i, v in pairs(self.blips) do
        if isElement(v) then destroyElement(v) end
    end
    self.markers = {}
    self.blips = {}
end

function LapRace:startNewLap()
    self.lap = self.lap + 1

    local time = exports.TR_hud:getRaceTime()
    local newBestTime = time - self.lastTimes
    if not self.bestTime then
        self.bestTime = newBestTime

    elseif self.bestTime >= newBestTime then
        self.bestTime = newBestTime
    end
    self.lastTimes = self.lastTimes + time
end

function LapRace:updateDetails()
    local driftScore = 0
    if RaceData.drift then
        RaceData.drift:addScoreToTotal()
        driftScore = RaceData.drift:getTotalScore()
    end

    exports.TR_hud:updateRaceDetails({
        lap = self.lap,
        laps = self.laps,
        bestTime = self.bestTime,
        percent = math.floor(((self.point-1)/(#self.track))*100),
        driftScore = driftScore,
    })
end

function LapRace:endRace()
    triggerServerEvent("removeAttachedObject", resourceRoot, getElementModel(getPedOccupiedVehicle(localPlayer)))

    exports.TR_dx:showLoading(5000, "Yarışın sonuçlandırılması")
    local raceTime = exports.TR_hud:getRaceTime()

    if RaceData.drift then
        local driftScore = RaceData.drift:getTotalScore()
        triggerServerEvent("onPlayerRaceEnd", resourceRoot, self.raceID, driftScore - raceTime/2)
    else
        triggerServerEvent("onPlayerRaceEnd", resourceRoot, self.raceID, raceTime)
    end

    if self.lap == 1 then exports.TR_achievements:addAchievements("raceSprint")
    elseif RaceData.drift then exports.TR_achievements:addAchievements("raceDrift")
    elseif RaceData.drag then exports.TR_achievements:addAchievements("raceDrag")
    else exports.TR_achievements:addAchievements("raceLaps")
    end
    exports.TR_achievements:addAchievements("raceEnd")

    exports.TR_hud:setHudRaceMode(false)
    self:destroy()
end

function LapRace:forceEnd()
    triggerServerEvent("removeAttachedObject", resourceRoot, getElementModel(getPedOccupiedVehicle(localPlayer)))

    exports.TR_dx:showLoading(5000, "Yarıştan ayrıl")
    triggerServerEvent("onPlayerRaceEnd", resourceRoot)

    exports.TR_hud:setHudRaceMode(false)
    self:destroy()
end

function LapRace:onMarkerHit(source, el, md)
    if el ~= localPlayer or not md then return end
    if self.markers[1] ~= source then return end

    if getMarkerIcon(source) == "finish" then
        self:updateDetails()
        self:destroyMarkers()
        self:endRace()
        return
    end

    if RaceData.drift then
        RaceData.drift:onMarkerHit()
    end
    self:createNextPoints()
    self:updateDetails()
end

function LapRace:createNextPoints()
    self:destroyMarkers()
    self.point = self.point + 1
    if self.point > #self.track then
        self.point = 1
        self:startNewLap()
    end

    if self.lap == self.laps then
        for i = 0, 1 do
            local pos, nextPos = false, false
            if self.track[self.point+i] then
                pos = self.track[self.point+i].pos

                local index = self.point+i+1
                if index > #self.track then index = 1 end
                nextPos = self.track[index].pos
            end

            if pos then
                if self.point == #self.track then
                    local marker = createMarker(pos[1], pos[2], pos[3], "checkpoint", 5, 255, 255, 255, 255)
                    setMarkerIcon(marker, "finish")
                    setElementDimension(marker, 9531)
                    table.insert(self.markers, marker)

                    local blip = createBlip(pos[1], pos[2], pos[3], 0, 1, 255, 60, 60, 255)
                    setElementData(blip, "icon", 22, false)
                    table.insert(self.blips, blip)
                else
                    local marker = createMarker(pos[1], pos[2], pos[3], "checkpoint", 5, 255, 255, 255, 255)
                    setMarkerIcon(marker, "arrow")
                    setMarkerTarget(marker, nextPos[1], nextPos[2], nextPos[3])
                    setElementDimension(marker, 9531)
                    table.insert(self.markers, marker)

                    local blip = createBlip(pos[1], pos[2], pos[3], 0, 1, 255, 60, 60, 255)
                    setElementData(blip, "icon", 22, false)
                    table.insert(self.blips, blip)
                end
            end
        end
        return
    end
    for i = 0, 1 do
        local pos, nextPos = false, false
        if not self.track[self.point+i] then
            pos = self.track[1].pos
            nextPos = self.track[2].pos
        else
            pos = self.track[self.point+i].pos

            local index = self.point+i+1
            if index > #self.track then index = 1 end
            nextPos = self.track[index].pos
        end

        local marker = createMarker(pos[1], pos[2], pos[3], "checkpoint", 3, 255, 255, 255, 255)
        setMarkerIcon(marker, "arrow")
        setMarkerTarget(marker, nextPos[1], nextPos[2], nextPos[3])
        setElementDimension(marker, 9531)
        table.insert(self.markers, marker)

        local blip = createBlip(pos[1], pos[2], pos[3], 0, 1, 255, 60, 60, 255)
        setElementData(blip, "icon", 22, false)
        table.insert(self.blips, blip)
    end
end

function LapRace:waterCheck()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return end

    if isElementInWater(veh) then
        self:forceEnd()
        setTimer(function()
            exports.TR_noti:create("Suya düşme nedeniyle yarış yarıda kesildi.", "info")
        end, 5000, 1)
    end
end

function LapRace:destroy()
    if isTimer(self.colTimer) then killTimer(self.colTimer) end
    if isTimer(self.waterTimer) then killTimer(self.waterTimer) end

    for i, v in pairs(getElementsByType("player", root, true)) do
        if v ~= localPlayer then
            setElementCollisionsEnabled(v, true)
            setElementAlpha(v, 255)
        end
    end

    if RaceData.drift then
        RaceData.drift:destroy()
    end
    if RaceData.drag then
        RaceData.drag:destroy()
    end

    self:destroyMarkers()
    exports.TR_dx:setOpenGUI(false)
    exports.TR_races:unbindRaceKeys()

    setElementData(localPlayer, "inRace", nil, false)

    RaceData.race = nil
    self = nil
end

function LapRace:updateCollisions()
    local veh = getPedOccupiedVehicle(localPlayer)
    for i, v in pairs(getElementsByType("player", root, true)) do
        if v ~= localPlayer then
            setElementCollisionsEnabled(v, false)
            setElementAlpha(v, 0)
        end
    end

    for i, v in pairs(getElementsByType("vehicle", resourceRoot, true)) do
        if v ~= veh then
            setElementCollisionsEnabled(v, false)
            setElementAlpha(v, 0)
        end
    end
end

function createLapRace(...)
    RaceData.race = LapRace:create(...)
end