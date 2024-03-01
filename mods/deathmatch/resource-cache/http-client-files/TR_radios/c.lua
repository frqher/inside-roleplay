local radios = {
    {
        pos = Vector3(1011.3369140625, -1603.7001953125, 13.56201171875),
        url = "http://www.rmfon.pl/n/rmfmaxxx.pls",
    },
    {
        pos = Vector3(-1675.154296875, 437.3935546875, 7.195312),
        url = "http://www.rmfon.pl/n/rmfmaxxx.pls",
        min = 25,
        max = 50,
    },
    {
        pos = Vector3(-2045.0126953125, 161.6513671875, 28.835937),
        url = "http://www.rmfon.pl/n/rmfmaxxx.pls",
        min = 20,
        max = 30,
    },
    {
        pos = Vector3(2275.2517089844, -203.0224609375, 102.96394348145),
        url = "http://www.rmfon.pl/n/rmfmaxxx.pls",
        int = 5,
        dim = 5,
        min = 60,
        max = 60,
        volume = 0.2,
    },


    -- Custom
    {
        pos = Vector3(-2351.6513671875, 3177.7980957031, 23.301010131836),
        url = "files/sounds/pirate.mp3",
        int = 0,
        dim = 29,
        min = 70,
        max = 70,
        volume = 0.3,
        looped = true,
    },
    {
        pos = Vector3(-1960.3173828125, 883.4189453125, 47.129467010498), --- SpawnSF
        url = "files/sounds/birds.mp3",
        int = 0,
        dim = 0,
        min = 40,
        max = 45,
        volume = 0.1,
        looped = true,
    },
    {
        pos = Vector3(-4609.0244140625, 338.8466796875, 6.4824237823486), --- Samouczek ogien
        url = "files/sounds/fire.mp3",
        int = 0,
        dim = 0,
        min = 15,
        max = 15,
        volume = 0.4,
        looped = true,
    },


    -- Church
    {
        pos = Vector3(-2720.43359375, -317.951171875, 26.360710144043), --- dzwony kosciół SF
        url = "files/sounds/bells.mp3",
        int = 0,
        dim = 0,
        min = 220,
        max = 300,
        volume = 1,
        looped = false,
        time = {
            { -- Pojedyncza godzina
                hour = 6, -- Godzina
                minute = 0, -- Minuta
            },
            { -- Pojedyncza godzina
                hour = 12, -- Godzina
                minute = 0, -- Minuta
            },
            { -- Pojedyncza godzina
                hour = 18, -- Godzina
                minute = 0, -- Minuta
            },
        }
    },
    {
        pos = Vector3(-1987.9208984375, 1117.7841796875, 74.007698059082), --- dzwony kosciół SF#2
        url = "files/sounds/bells.mp3",
        int = 0,
        dim = 0,
        min = 50,
        max = 400,
        volume = 5,
        looped = false,
        time = {
            { -- Pojedyncza godzina
                hour = 6, -- Godzina
                minute = 0, -- Minuta
            },
            { -- Pojedyncza godzina
                hour = 12, -- Godzina
                minute = 0, -- Minuta
            },
            { -- Pojedyncza godzina
                hour = 18, -- Godzina
                minute = 0, -- Minuta
            },
        }

    },
    {
        pos = Vector3(2252.6220703125, -1313.4228515625, 51.600330352783), --- dzwony kosciół LS
        url = "files/sounds/bells.mp3",
        int = 0,
        dim = 0,
        min = 50,
        max = 400,
        volume = 5,
        looped = false,
        time = {
            { -- Pojedyncza godzina
                hour = 6, -- Godzina
                minute = 0, -- Minuta
            },
            { -- Pojedyncza godzina
                hour = 12, -- Godzina
                minute = 0, -- Minuta
            },
            { -- Pojedyncza godzina
                hour = 18, -- Godzina
                minute = 0, -- Minuta
            },
        }
    },
    {
        pos = Vector3(2256.7119140625, -47.767578125, 33.064109802246), --- dzwony kosciół PC
        url = "files/sounds/bells.mp3",
        int = 0,
        dim = 0,
        min = 30,
        max = 170,
        volume = 5,
        looped = false,
        time = {
            { -- Pojedyncza godzina
                hour = 6, -- Godzina
                minute = 0, -- Minuta
            },
            { -- Pojedyncza godzina
                hour = 12, -- Godzina
                minute = 0, -- Minuta
            },
            { -- Pojedyncza godzina
                hour = 18, -- Godzina
                minute = 13, -- Minuta
            },
        }
    },
    {
        pos = Vector3(-2476.3046875, 2402.5078125, 28.891479492188), --- dzwony kosciół BS
        url = "files/sounds/bells.mp3",
        int = 0,
        dim = 0,
        min = 30,
        max = 170,
        volume = 5,
        looped = false,
        time = {
            { -- Pojedyncza godzina
                hour = 6, -- Godzina
                minute = 0, -- Minuta
            },
            { -- Pojedyncza godzina
                hour = 12, -- Godzina
                minute = 0, -- Minuta
            },
            { -- Pojedyncza godzina
                hour = 18, -- Godzina
                minute = 0, -- Minuta
            },
        }
    },
    {
        pos = Vector3(-2210.3642578125, -2291.0458984375, 42.913333892822), --- dzwony kosciół AP
        url = "files/sounds/bells.mp3",
        int = 0,
        dim = 0,
        min = 30,
        max = 170,
        volume = 5,
        looped = false,
        time = {
            { -- Pojedyncza godzina
                hour = 6, -- Godzina
                minute = 0, -- Minuta
            },
            { -- Pojedyncza godzina
                hour = 12, -- Godzina
                minute = 0, -- Minuta
            },
            { -- Pojedyncza godzina
                hour = 18, -- Godzina
                minute = 0, -- Minuta
            },
        }
    },
    {
        pos = Vector3(-794.2412109375, 1556.9541015625, 34.795207977295), --- dzwony kosciół LB
        url = "files/sounds/bells.mp3",
        int = 0,
        dim = 0,
        min = 50,
        max = 400,
        volume = 5,
        looped = false,
        time = {
            { -- Pojedyncza godzina
                hour = 6, -- Godzina
                minute = 0, -- Minuta
            },
            { -- Pojedyncza godzina
                hour = 12, -- Godzina
                minute = 0, -- Minuta
            },
            { -- Pojedyncza godzina
                hour = 18, -- Godzina
                minute = 0, -- Minuta
            },
        }
    },
    {
        pos = Vector3(1489.7236328125, 751.009765625, 29.16674041748), --- dzwony kosciół LV
        url = "files/sounds/bells.mp3",
        int = 0,
        dim = 0,
        min = 50,
        max = 400,
        volume = 5,
        looped = false,
        time = {
            { -- Pojedyncza godzina
                hour = 6, -- Godzina
                minute = 0, -- Minuta
            },
            { -- Pojedyncza godzina
                hour = 12, -- Godzina
                minute = 0, -- Minuta
            },
            { -- Pojedyncza godzina
                hour = 18, -- Godzina
                minute = 0, -- Minuta
            },
        }
    },
    {
        pos = Vector3(2492.2890625, 923.1533203125, 29.348077774048), --- dzwony kosciół LV#2
        url = "files/sounds/bells.mp3",
        int = 0,
        dim = 0,
        min = 50,
        max = 400,
        volume = 5,
        looped = false,
        time = {
            { -- Pojedyncza godzina
                hour = 6, -- Godzina
                minute = 0, -- Minuta
            },
            { -- Pojedyncza godzina
                hour = 12, -- Godzina
                minute = 0, -- Minuta
            },
            { -- Pojedyncza godzina
                hour = 18, -- Godzina
                minute = 0, -- Minuta
            },
        }
    },
}


RadioStreamer = {}
RadioStreamer.__index = RadioStreamer

function RadioStreamer:create()
    local instance = {}
    setmetatable(instance, RadioStreamer)
    if instance:constructor() then
        return instance
    end
    return false
end

function RadioStreamer:constructor()
    self.spheres = {}
    self.sounds = {}
    self.timers = {}

    self.func = {}
    self.func.playSound = function(...) self:playSound(...) end
    self.func.onColShapeHit = function(...) self:onColShapeHit(source, ...) end
    self.func.onColShapeLeave = function(...) self:onColShapeLeave(source, ...) end

    self:createRadios()
    return true
end

function RadioStreamer:createRadios()
    for i, v in pairs(radios) do
        local sphere = createColSphere(v.pos, v.max or 30)
        self.spheres[sphere] = v
    end

    addEventHandler("onClientColShapeHit", resourceRoot, self.func.onColShapeHit)
    addEventHandler("onClientColShapeLeave", resourceRoot, self.func.onColShapeLeave)
end

function RadioStreamer:onColShapeHit(source, el)
    if el ~= localPlayer then return end
    self:playSound(source)
end

function RadioStreamer:onColShapeLeave(source, el)
    if el ~= localPlayer then return end
    self:destroySound(source)
end

function RadioStreamer:playSound(source)
    if self.sounds[source] then return end

    local v = self.spheres[source]
    if v.time then
        local realTime = getRealTime()
        if realTime.hour == v.time.hour and realTime.minute == v.time.minute and realTime.second == 0 then
            self.sounds[source] = playSound3D(v.url, v.pos, v.looped)
            setSoundMinDistance(self.sounds[source], v.min or 10)
            setSoundMaxDistance(self.sounds[source], v.max or 30)
            if v.volume then setSoundVolume(self.sounds[source], v.volume) end
            if v.int then setElementInterior(self.sounds[source], v.int) end
            if v.dim then setElementDimension(self.sounds[source], v.dim) end

        elseif not self.timers[source] and isElementWithinColShape(localPlayer, source) then
            setTimer(self.func.playSound, 1000, 1, source)
        end
    else
        self.sounds[source] = playSound3D(v.url, v.pos, v.looped)
        setSoundMinDistance(self.sounds[source], v.min or 10)
        setSoundMaxDistance(self.sounds[source], v.max or 30)
        if v.volume then setSoundVolume(self.sounds[source], v.volume) end
        if v.int then setElementInterior(self.sounds[source], v.int) end
        if v.dim then setElementDimension(self.sounds[source], v.dim) end
    end
end

function RadioStreamer:destroySound(source)
    if not self.sounds[source] then return end

    destroyElement(self.sounds[source])
    self.sounds[source] = nil
end

RadioStreamer:create()

-- function playRadio(v)
--     local sound = playSound3D(v.url, v.pos, v.looped)
--     setSoundMinDistance(sound, v.min or 10)
--     setSoundMaxDistance(sound, v.max or 30)
--     if v.volume then setSoundVolume(sound, v.volume) end
--     if v.int then setElementInterior(sound, v.int) end
--     if v.dim then setElementDimension(sound, v.dim) end
-- end

-- function createRadios()
--     for i, v in pairs(radios) do
--         if not v.time then
--             playRadio(v)
--         end
--     end
-- end
-- createRadios()

-- function checkRadioTime()
--     local realTime = getRealTime()
--     for i, v in pairs(radios) do
--         if v.time then
--             for _, time in pairs(v.time) do
--                 if realTime.hour == time.hour and realTime.minute == time.minute and realTime.second == 0 then
--                     playRadio(v)
--                 end
--             end
--         end
--     end
-- end
-- setTimer(checkRadioTime, 1000, 0)