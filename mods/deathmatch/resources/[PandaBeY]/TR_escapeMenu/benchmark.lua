local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

settings = {}
local guiInfo = {
    x = (sx - 500/zoom)/2,
    y = sy - 185/zoom,
    w = 500/zoom,
    h = 185/zoom,

    diagram = {
        x = (sx - 650/zoom)/2 + 350/zoom,
        y = sy - 150/zoom,
        w = 200/zoom,
        h = 100/zoom,
    },

    camera = {
        startPos = Vector3(-1676.6669921875, -183.8720703125, 16.1484375),
        endPos = Vector3(-1105.599609375, 387.0029296875, 16.1484375),
        moveTime = 30,
    },

    objects = {
        vehicles = {602, 496, 401, 518, 527, 589, 419, 587, 533, 526, 474, 545, 517, 410, 600, 436, 439, 549, 491},
        peds = getValidPedModels(),
        effects = {"blood_heli","boat_prop","camflash","carwashspray","cement","cloudfast","coke_puff","coke_trail","cigarette_smoke","explosion_barrel","explosion_crate","explosion_door","exhale","explosion_fuel_car","explosion_large","explosion_medium","explosion_molotov","explosion_small","explosion_tiny","extinguisher","flame","fire","fire_med","fire_large","flamethrower","fire_bike","fire_car","gunflash","gunsmoke","insects","heli_dust","jetpack","jetthrust","nitro","molotov_flame","overheat_car","overheat_car_electric","prt_blood","prt_boatsplash","prt_bubble","prt_cardebris","prt_collisionsmoke","prt_glass","prt_gunshell","prt_sand","prt_sand2","prt_smokeII_3_expand","prt_smoke_huge","prt_spark","prt_spark_2","prt_splash","prt_wake","prt_watersplash","prt_wheeldirt","petrolcan","puke","riot_smoke","spraycan","smoke30lit","smoke30m","smoke50lit","shootlight","smoke_flare","tank_fire","teargas","teargasAD","tree_hit_fir","tree_hit_palm","vent","vent2","water_hydrant","water_ripples","water_speed","water_splash","water_splash_big","water_splsh_sml","water_swim","waterfall_end","water_fnt_tme","water_fountain","wallbust","WS_factorysmoke"},
        markers = {"garage", "house", "cityhall", "beer", "wine", "shop", "clothes", "didier", "prolaps", "zip", "psychologist", "pizza", "burger", "chicken", "seven", "disco", "donut", "bank", "mechanic", "taxi", "police", "medic", "fire", "tv", "licenceTheory", "licencePractise", "noParking", "office", "gun", "exchange", "magazineBox", "truck", "truckTakeOff", "apple"},
    },

    testNames = {
        "Rotayı temizle", "Araç testi", "Karakter testi", "Efekt testi", "Blip testi", "Marker testi"
    },
}

Benchmark = {}
Benchmark.__index = Benchmark

function Benchmark:create()
    local instance = {}
    setmetatable(instance, Benchmark)
    if instance:constructor() then
        return instance
    end
    return false
end

function Benchmark:constructor()
    self.data = {}
    self.fpsData = {}
    self.objects = {}
    self.dxStatus = dxGetStatus()

    self.maxFPS = 60
    self.fps = 0
    self.lowestFPS = 9000
    self.highiestFPS = -10
    self.testTab = 0
    self.nextTick = getTickCount()

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.info = exports.TR_dx:getFont(11)
    self.fonts.fps = exports.TR_dx:getFont(10)

    self.lastPos = Vector3(getElementPosition(localPlayer))
    self.lastInt = getElementInterior(localPlayer)
    self.lastDim = getElementDimension(localPlayer)

    setElementInterior(localPlayer, 0)
    setElementDimension(localPlayer, 4891)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.updateFPS = function(...) self:updateFPS(...) end
    self.func.pedCoroutine = function() self:pedCoroutine() end
    self.func.blipsCoroutine = function() self:blipsCoroutine() end
    self.func.effectsCoroutine = function() self:effectsCoroutine() end
    self.func.markersCoroutine = function() self:markersCoroutine() end

    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientPreRender", root, self.func.updateFPS)

    setElementData(localPlayer, "inv", true)
    self:nextTestTab()
    return true
end

function Benchmark:destroy()
    self:destroyElements()
    setCameraTarget(localPlayer)
    setElementData(localPlayer, "inv", nil)

    setElementPosition(localPlayer, self.lastPos)
    setElementInterior(localPlayer, self.lastInt)
    setElementDimension(localPlayer, self.lastDim)

    removeEventHandler("onClientRender", root, self.func.render)
    removeEventHandler("onClientPreRender", root, self.func.updateFPS)
    settings.benchmark = nil
    self = nil
end

function Benchmark:nextTestTab()
    self.testTab = self.testTab + 1
    self.cameraTick = getTickCount()

    if self.testTab == 2 then
        self.data["Free Test"] = {
            avarageFps = self:getAvarageFPS(),
            lowestFPS = self.lowestFPS,
            highiestFPS = self.highiestFPS,
        }
        exports.TR_vehicles:createBenchmarkVehicles(80, guiInfo.objects.vehicles)

    elseif self.testTab == 3 then
        self.data["Vehicle Test"] = {
            avarageFps = self:getAvarageFPS(),
            lowestFPS = self.lowestFPS,
            highiestFPS = self.highiestFPS,
        }
        exports.TR_vehicles:destroyBenchmarkVehicles()

        self.coroutinePed = coroutine.create(self.func.pedCoroutine)
        coroutine.resume(self.coroutinePed)


    elseif self.testTab == 4 then
        self.data["NPC Test"] = {
            avarageFps = self:getAvarageFPS(),
            lowestFPS = self.lowestFPS,
            highiestFPS = self.highiestFPS,
        }
        self:destroyElements()

        self.coroutineEffects = coroutine.create(self.func.effectsCoroutine)
        coroutine.resume(self.coroutineEffects)

    elseif self.testTab == 5 then
        self.data["Effect Test"] = {
            avarageFps = self:getAvarageFPS(),
            lowestFPS = self.lowestFPS,
            highiestFPS = self.highiestFPS,
        }
        self:destroyElements()

        self.coroutineBlips = coroutine.create(self.func.blipsCoroutine)
        coroutine.resume(self.coroutineBlips)

    elseif self.testTab == 6 then
        self.data["Blip Test"] = {
            avarageFps = self:getAvarageFPS(),
            lowestFPS = self.lowestFPS,
            highiestFPS = self.highiestFPS,
        }
        self:destroyElements()

        self.coroutineMarkers = coroutine.create(self.func.markersCoroutine)
        coroutine.resume(self.coroutineMarkers)

    elseif self.testTab == 7 then
        self.data["Marker Test"] = {
            avarageFps = self:getAvarageFPS(),
            lowestFPS = self.lowestFPS,
            highiestFPS = self.highiestFPS,
        }
        self:destroyElements()

        self:saveDataToFile()
        self:destroy()
    end

    self.lowestFPS = 99999
    self.highiestFPS = -99999
end

function Benchmark:pedCoroutine()
    local i = 0
    for _ = 0, 180 do
        table.insert(self.objects, self:createPed(guiInfo.objects.peds[math.random(1, #guiInfo.objects.peds)], -1657.5361328125 + i * 3, -158.841796875 + i * 3, 13.834096908569, 223))
        table.insert(self.objects, self:createPed(guiInfo.objects.peds[math.random(1, #guiInfo.objects.peds)], -1655.5361328125 + i * 3, -160.841796875 + i * 3, 13.834096908569, 223))
        table.insert(self.objects, self:createPed(guiInfo.objects.peds[math.random(1, #guiInfo.objects.peds)], -1653.5361328125 + i * 3, -162.841796875 + i * 3, 13.834096908569, 223))
        table.insert(self.objects, self:createPed(guiInfo.objects.peds[math.random(1, #guiInfo.objects.peds)], -1651.5361328125 + i * 3, -164.841796875 + i * 3, 13.834096908569, 223))
        i = i + 1

        if i%5 == 0 then
            setTimer(function()
                coroutine.resume(self.coroutinePed)
            end, 500, 1)
            coroutine.yield(self.coroutinePed)
        end
    end
end

function Benchmark:effectsCoroutine()
    local i = 0
    for _ = 0, 100 do
        table.insert(self.objects, self:createEffect(guiInfo.objects.effects[math.random(1, #guiInfo.objects.effects)], -1657.5361328125 + i * 6, -158.841796875 + i * 6, 13.834096908569))
        table.insert(self.objects, self:createEffect(guiInfo.objects.effects[math.random(1, #guiInfo.objects.effects)], -1655.5361328125 + i * 6, -160.841796875 + i * 6, 13.834096908569))
        table.insert(self.objects, self:createEffect(guiInfo.objects.effects[math.random(1, #guiInfo.objects.effects)], -1653.5361328125 + i * 6, -162.841796875 + i * 6, 13.834096908569))
        table.insert(self.objects, self:createEffect(guiInfo.objects.effects[math.random(1, #guiInfo.objects.effects)], -1651.5361328125 + i * 6, -164.841796875 + i * 6, 13.834096908569))
        i = i + 1

        if i%5 == 0 then
            setTimer(function()
                coroutine.resume(self.coroutineEffects)
            end, 500, 1)
            coroutine.yield(self.coroutineEffects)
        end
    end
end

function Benchmark:blipsCoroutine()
    local i = 0
    for _ = 0, 100 do
        table.insert(self.objects, self:createBlip(-1657.5361328125 + i * 6, -158.841796875 + i * 6, 13.834096908569))
        table.insert(self.objects, self:createBlip(-1655.5361328125 + i * 6, -160.841796875 + i * 6, 13.834096908569))
        table.insert(self.objects, self:createBlip(-1653.5361328125 + i * 6, -162.841796875 + i * 6, 13.834096908569))
        table.insert(self.objects, self:createBlip(-1651.5361328125 + i * 6, -164.841796875 + i * 6, 13.834096908569))
        i = i + 1

        if i%5 == 0 then
            setTimer(function()
                coroutine.resume(self.coroutineBlips)
            end, 500, 1)
            coroutine.yield(self.coroutineBlips)
        end
    end
end

function Benchmark:markersCoroutine()
    local i = 0
    for _ = 0, 100 do
        table.insert(self.objects, self:createMarker(-1657.5361328125 + i * 6, -158.841796875 + i * 6, 13.834096908569))
        table.insert(self.objects, self:createMarker(-1655.5361328125 + i * 6, -160.841796875 + i * 6, 13.834096908569))
        table.insert(self.objects, self:createMarker(-1653.5361328125 + i * 6, -162.841796875 + i * 6, 13.834096908569))
        table.insert(self.objects, self:createMarker(-1651.5361328125 + i * 6, -164.841796875 + i * 6, 13.834096908569))
        i = i + 1

        if i%5 == 0 then
            setTimer(function()
                coroutine.resume(self.coroutineMarkers)
            end, 500, 1)
            coroutine.yield(self.coroutineMarkers)
        end
    end
end

function Benchmark:createPed(model, x, y, z, rz)
    local ped = createPed(model, x, y, z, rz)
    setElementData(ped, "name", "Testowe imię", false)
    setElementData(ped, "role", "Testowy ped", false)
    setElementDimension(ped, 4891)
    return ped
end

function Benchmark:createEffect(name, x, y, z)
    local effect = createEffect(name, x, y, z)
    setElementDimension(effect, 4891)
    return effect
end

function Benchmark:createBlip(x, y, z)
    local blip = createBlip(x, y, z, 0, 2, math.random(0, 255), math.random(0, 255), math.random(0, 255))
    setElementData(blip, "icon", math.random(0, 50), false)
    setElementDimension(blip, 4891)
    return blip
end

function Benchmark:createMarker(x, y, z)
    local blip = createMarker(x, y, z, "cylinder", 2, math.random(0, 255), math.random(0, 255), math.random(0, 255), 0)
    setElementData(blip, "markerData", {
        title = "Marker testi",
        desc = "Marker testi için yapılmıştır.",
    }, false)
    setElementData(blip, "markerIcon", guiInfo.objects.markers[math.random(1, #guiInfo.objects.markers)], false)
    setElementDimension(blip, 4891)
    return blip
end

function Benchmark:destroyElements()
    for i, v in pairs(self.objects) do
        if isElement(v) then destroyElement(v) end
    end
    self.objects = {}
end

function Benchmark:render()
    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255), 4)
    dxDrawText("Performans Testi", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 40/zoom, tocolor(240, 196, 55, 255), 1/zoom, self.fonts.main, "center", "center")

    dxDrawText("Güncel FPS: #aaaaaa"..self.fps.." kl/s", guiInfo.x + 15/zoom, guiInfo.y + 40/zoom, guiInfo.x + guiInfo.w/2, guiInfo.y + 170/zoom, tocolor(220, 220, 220, 255), 1/zoom, self.fonts.info, "left", "top", false, false, false, true)
    dxDrawText("Ortalama FPS: #aaaaaa"..self:getAvarageFPS().." kl/s", guiInfo.x + 15/zoom, guiInfo.y + 60/zoom, guiInfo.x + guiInfo.w/2, guiInfo.y + 170/zoom, tocolor(220, 220, 220, 255), 1/zoom, self.fonts.info, "left", "top", false, false, false, true)
    dxDrawText("CPU Kullanımı: #aaaaaa"..self:getCpuUsage().."%", guiInfo.x + 15/zoom, guiInfo.y + 80/zoom, guiInfo.x + guiInfo.w/2, guiInfo.y + 170/zoom, tocolor(220, 220, 220, 255), 1/zoom, self.fonts.info, "left", "top", false, false, false, true)
    dxDrawText("Ekran Kartı:\n#aaaaaa"..self.dxStatus.VideoCardName, guiInfo.x + 15/zoom, guiInfo.y + 100/zoom, guiInfo.x + guiInfo.w/2, guiInfo.y + 170/zoom, tocolor(220, 220, 220, 255), 1/zoom, self.fonts.info, "left", "top", false, false, false, true)
    dxDrawText("Ekran Kartı Ram Kullanımı: #aaaaaa"..self.dxStatus.VideoCardRAM.." MB", guiInfo.x + 15/zoom, guiInfo.y + 140/zoom, guiInfo.x + guiInfo.w/2, guiInfo.y + 170/zoom, tocolor(220, 220, 220, 255), 1/zoom, self.fonts.info, "left", "top", false, false, false, true)
	-- dönülecek
    dxDrawText("Test devam ediyor: #aaaaaa"..guiInfo.testNames[self.testTab], guiInfo.x, guiInfo.y + guiInfo.h - 30/zoom, guiInfo.x + guiInfo.w, guiInfo.y + guiInfo.h, tocolor(220, 220, 220, 255), 1/zoom, self.fonts.info, "center", "center", false, false, false, true)

    self:dxCreateDiagram()
    self:renderCamera()
end

function Benchmark:renderCamera()
    local progress = (getTickCount() - self.cameraTick)/(guiInfo.camera.moveTime * 1000)
    local x, y, z = interpolateBetween(guiInfo.camera.startPos.x, guiInfo.camera.startPos.y, guiInfo.camera.startPos.z, guiInfo.camera.endPos.x, guiInfo.camera.endPos.y, guiInfo.camera.endPos.z, progress, "Linear")
    setCameraMatrix(x, y, z, x + 5, y + 5, z)

    setElementPosition(localPlayer, x, y, z)

    if progress >= 1 then
        self:nextTestTab()
    end
end

function Benchmark:getName(...)
    if string.find(arg[1], "TR_") then return string.sub(arg[1], 4) end
    return arg[1]
end

function Benchmark:updateFPS(msSinceLastFrame)
    local now = getTickCount()
    if (now >= self.nextTick) then
        self.fps = math.max(math.min(math.floor((1 / msSinceLastFrame) * 1000), self.maxFPS), 0)
        self.nextTick = now + 200

        if (getTickCount() - self.cameraTick)/1000 > 3 then
            if self.fps > self.highiestFPS then
                self.highiestFPS = self.fps
            end
            if self.fps < self.lowestFPS then
                self.lowestFPS = self.fps
            end
        end

        self:addFPS(self.fps)
    end
end

function Benchmark:addFPS(...)
    table.insert(self.fpsData, #self.fpsData + 1, {
        fps = arg[1],
    })
    if #self.fpsData > 32 then
        table.remove(self.fpsData, 1)
    end
end

function Benchmark:getAvarageFPS(...)
    local sum = 0
    for i, v in pairs(self.fpsData) do
        sum = sum + v.fps
    end
    return string.format("%d", sum/#self.fpsData)
end

function Benchmark:getCpuUsage(...)
    local _, rows = getPerformanceStats("Lua timing")
    local total = 0
    for i, v in pairs(rows) do
        local num = tonumber(string.sub(v[2], 1, string.len(v[2]) - 1))
        total = total + (num and num or 0)
    end
    return string.format("%.2f", total/5)
end

function Benchmark:drawBackground(x, y, rx, ry, color, radius, post)
    rx = rx - radius * 2
    ry = ry - radius * 2
    x = x + radius
    y = y + radius

    if (rx >= 0) and (ry >= 0) then
        dxDrawRectangle(x, y - radius, rx, ry + radius * 2, color, post)
        dxDrawRectangle(x - radius, y, radius, ry + radius, color, post)
        dxDrawRectangle(x + rx, y, radius, ry + radius, color, post)

        dxDrawCircle(x, y, radius, 180, 270, color, color, 7, 1, post)
        dxDrawCircle(x + rx, y, radius, 270, 360, color, color, 7, 1, post)
    end
end

function Benchmark:dxCreateDiagram()
    if #self.fpsData > 0 then
        local addedPrice = {}
        local lastY = 0

        local move = guiInfo.diagram.w/(#self.fpsData + 1)
        for i = 0, self.maxFPS, 10 do
            local y = guiInfo.diagram.y + guiInfo.diagram.h + 30/zoom - (i/self.maxFPS) * guiInfo.diagram.h
            dxDrawLine(guiInfo.diagram.x, y - 15/zoom, guiInfo.diagram.x + guiInfo.diagram.w, y - 15/zoom, tocolor(37, 37, 37, 255), 2)
            dxDrawText(i, guiInfo.diagram.x, y - 15/zoom, guiInfo.diagram.x, y - 15/zoom, tocolor(120, 120, 120, 255), 1/zoom, self.fonts.fps, "center", "center")
        end

        for i, v in pairs(self.fpsData) do
            local y = guiInfo.diagram.y + guiInfo.diagram.h + 30/zoom - (v.fps/self.maxFPS) * guiInfo.diagram.h

            if i == 1 then
                lastY = y - 15/zoom
            else
                dxDrawLine(guiInfo.diagram.x + move * (i-1), lastY, guiInfo.diagram.x + move * i, y - 15/zoom, tocolor(127, 37, 37, 255), 2)
                lastY = y - 15/zoom
            end
        end
    end
end

function Benchmark:saveDataToFile()
    local time = getRealTime()
    local fileName = string.format("tests/%02d.%02d-%02d.%02d.%04d.perftest", time.hour, time.minute, time.monthday, time.month + 1, time.year + 1900)

    local file = fileCreate(fileName)
    self:fileDefaultWrite(file)
    for i, v in pairs(self.data) do
        fileWrite(file, "\n\n")
        fileWrite(file, string.format("---==[ %s ]==---\n", i))

        self:fileWrite(file, "Ortalama FPS", v.avarageFps)
        self:fileWrite(file, "En Düşük FPS", v.lowestFPS)
        self:fileWrite(file, "En Yüksek FPS", v.highiestFPS)
    end
    fileClose(file)

    exports.TR_noti:create("Benchmark tamamlandı. Dosya konumu: TR_escapeMenu/"..fileName, "success")
end

function Benchmark:fileDefaultWrite(file)
    fileWrite(file, "---==[ Tester Data ]==---\n")
    self:fileWrite(file, "Oyuncu Adı", getPlayerName(localPlayer))
    self:fileWrite(file, "Oyuncu UID", getElementData(localPlayer, "characterUID"))
    self:fileWrite(file, "Oyuncu Serial", getPlayerSerial(localPlayer))
    self:fileWrite(file, "MTA Version", "MTA:SA Client "..getVersion().tag)

    fileWrite(file, "\n\n")

    fileWrite(file, "---==[ DX Stats ]==---\n")
    for i, v in pairs(self.dxStatus) do
        if type(v) == "boolean" then
            fileWrite(file, i..": "..(v and "TAK" or "NIE").."\n")
        else
            fileWrite(file, i..": "..v.."\n")
        end
    end
end

function Benchmark:fileWrite(file, desc, data)
    fileWrite(file, string.format("%s: %s\n", desc, tostring(data)))
end





function createBenchmark()
    if settings.benchmark then return end
    settings.benchmark = Benchmark:create()
end

exports.TR_vehicles:destroyBenchmarkVehicles()