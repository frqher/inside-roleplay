Voice = {}
Voice.__index = Voice

function Voice:create()
    local instance = {}
    setmetatable(instance, Voice)
    if instance:constructor() then
        return instance
    end
    return false
end

function Voice:constructor()
    self.speaking = false

    self.func = {}
    self.func.onStart = function() self:onStart() end
    self.func.updateSounds = function() self:updateSounds() end
    self.func.updateSoundsPlayers = function() self:updateSoundsPlayers(source) end

    addEventHandler("onClientPreRender", root, self.func.updateSounds)
    addEventHandler("onClientResourceStart", root, self.func.onStart)
    -- addEventHandler("onClientElementStreamIn", root, self.func.updateSoundsPlayers)
    -- addEventHandler("onClientElementStreamOut", root, self.func.updateSoundsPlayers)
    return true
end

function Voice:updateSounds()
    local players = getElementsByType("player", root, true)
    local vecCamPos = Camera.position
    local vecLook = Camera.matrix.forward.normalized
    local phoneSpeaking = getElementData(localPlayer, "phone")

    for i, v in ipairs(players) do
        setSoundVolume(v, 0)

        -- local vecSoundPos = v.position
        -- local fDistance = (vecSoundPos - vecCamPos).length
        -- local fMaxVol = v:getData("maxVol") or 10
        -- local fMinDistance = v:getData("minDist") or 5
        -- local fMaxDistance = v:getData("maxDist") or 25

        -- -- Limit panning when getting close to the min distance
        -- local fPanSharpness = 1.0
        -- if (fMinDistance ~= fMinDistance * 2) then
        --     fPanSharpness = math.max(0, math.min(1, (fDistance - fMinDistance) / ((fMinDistance * 2) - fMinDistance)))
        -- end
        -- local fPanLimit = (0.65 * fPanSharpness + 0.35)

        -- -- Pan
        -- local vecSound = (vecSoundPos - vecCamPos).normalized
        -- local cross = vecLook:cross(vecSound)
        -- local fPan = math.max(-fPanLimit, math.min(-cross.z, fPanLimit))

        -- local fDistDiff = fMaxDistance - fMinDistance;

        -- -- Transform e^-x to suit our sound
        -- local fVolume
        -- if (fDistance <= fMinDistance) then
        --     fVolume = fMaxVol
        -- elseif (fDistance >= fMaxDistance) then
        --     fVolume = 0.0
        -- else
        --     fVolume = math.exp(-(fDistance - fMinDistance) * (5.0 / fDistDiff)) * fMaxVol
        -- end
        -- setSoundPan(v, fPan)
        -- setSoundVolume(v, fVolume)
    end

    if isElement(phoneSpeaking) then
        setSoundVolume(phoneSpeaking, 1)
    end

    if self.lastVoice ~= phoneSpeaking then
        self.lastVoice = phoneSpeaking
        triggerServerEvent("proximity-voice::broadcastUpdate", localPlayer, phoneSpeaking)
    end
end

function Voice:updateSoundsPlayers(source)
    if getElementType(source) == "player" then
        triggerServerEvent("proximity-voice::broadcastUpdate", localPlayer, getElementsByType("player", root, true))
        setSoundPan(source, 0)
        setSoundVolume(source, 0)
    end
end

function Voice:onStart()
    triggerServerEvent("proximity-voice::broadcastUpdate", localPlayer, getElementsByType("player", root, true))
end

Voice:create()