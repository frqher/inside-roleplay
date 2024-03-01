GlobalSounds = {}
GlobalSounds.__index = GlobalSounds

function GlobalSounds:create()
    local instance = {}
    setmetatable(instance, GlobalSounds)
    if instance:constructor() then
        return instance
    end
    return false
end

function GlobalSounds:constructor()
    self.func = {}
    self.func.play = function(...) self:playGlobalSound(...) end

    addEvent("playGlobalSound", true)
    addEventHandler("playGlobalSound", root, self.func.play)
    return true
end

function GlobalSounds:playGlobalSound(url, x, y, z, dist, maxDist)
    if not url or not x or not y or not z then return end
    dist = dist or 1
    maxDist = maxDist or 20

    local sound = playSound3D(url, x, y, z)
    setSoundMinDistance(sound, dist)
    setSoundMaxDistance(sound, maxDist)
end

GlobalSounds:create()