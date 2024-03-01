local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    list = {
        x = (sx - 100/zoom)/2,
        y = sy - 170/zoom,
        w = 100/zoom,
        h = 100/zoom,

        defY = sy - 170/zoom,
    },

    perf = {
        x = 0,
        y = (sy - 455/zoom)/2,
        w = 500/zoom,
        h = 455/zoom,

        list = {
            {
                name = "Hızlanma",
                handling = "engineAcceleration",
            },
            {
                name = "Azami hız",
                handling = "maxVelocity",
            },
            {
                name = "Yapışma",
                handling = "tractionMultiplier",
            },
            {
                name = "Fren gücü",
                handling = "brakeDeceleration",
            },
            {
                name = "Direksiyon ayarı",
                handling = "steeringLock",
            },
            {
                name = "Benzin yakımı",
                handling = "fuelTake",
            },
        },
    },

    vehicle = {
        pos = Vector3(1004.4970703125, -1605.4694824219, 13.606250762939),
        rot = Vector3(0, 0, 0),
        int = 1,
        dim = 1,
    },

    camera = {
        distance = 7,
        height = 1,
    },

    speedo = {
		x = (sx - 250/zoom)/2,
		y = (sy - 370/zoom)/2,
		w = 380/zoom,
		h = 380/zoom,

		alpha = 0,
		startRot = -151,
		maxRot = 100,
		speedDowngrade = 0.84,

		mileageHeight = 240,
		mileageInfo = {0,0,0,0,0,0,0},
	},
}

Tuning = {}
Tuning.__index = Tuning

function Tuning:create(...)
    local instance = {}
    setmetatable(instance, Tuning)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function Tuning:constructor(...)
    self.tunerType = arg[1]
    self:setDefaultVehicleTuning(arg[2])

    self.rot = 360

    local x, y = self:getPointFromDistanceRotation(guiInfo.vehicle.pos.x, guiInfo.vehicle.pos.y, guiInfo.camera.distance, self.rot)
    self.cameraPos = Vector3(x, y, guiInfo.vehicle.pos.z + guiInfo.camera.height)
    self.cameraLook = guiInfo.vehicle.pos


    self.fonts = {}
    self.fonts.categoryCenter = exports.TR_dx:getFont(16)
    self.fonts.performance = exports.TR_dx:getFont(14)
    self.fonts.categorySecond = exports.TR_dx:getFont(12)
    self.fonts.categoryThird = exports.TR_dx:getFont(10)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.onClientKey = function(...) self:onClientKey(...) end

    self:buildPlayerVehicle()

    self:selectCategory()

    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientKey", root, self.func.onClientKey)

    exports.TR_dx:hideLoading()
    exports.TR_chat:showCustomChat(false)
    exports.TR_hud:setHudVisible(false)
    exports.TR_dx:setOpenGUI(true)

    setElementData(localPlayer, "blockTune", self.defaultData.ID)
    self.blockKey = true

    exports.TR_weather:setCustomWeather(1, 12, 0, 9999)

    setTimer(function()
        self.blockKey = nil
    end, 600, 1)
    return true
end

function Tuning:close()
    self.blockKey = true

    exports.TR_dx:showLoading(10000, "Dünya yükleniyor")

    setTimer(function()
        self:destroy()
        destroyElement(self.vehiclePreview)
        setElementFrozen(localPlayer, false)

        exports.TR_weather:setCustomWeather(false)
    end, 1000, 1)
end

function Tuning:destroy()
    removeEventHandler("onClientRender", root, self.func.render)
    removeEventHandler("onClientKey", root, self.func.onClientKey)

    setCameraTarget(localPlayer)
    setElementInterior(localPlayer, 0)
    setElementDimension(localPlayer, 0)

    triggerServerEvent("exitVehicleTune", resourceRoot, self.defaultData.ID)

    exports.TR_chat:showCustomChat(true)
    exports.TR_hud:setHudVisible(true)
    exports.TR_dx:setOpenGUI(false)

    setTimer(function()
        exports.TR_dx:hideLoading()
        setElementData(localPlayer, "blockTune", nil)
    end, 5000, 1)

    guiInfo.panel = nil
    self = nil
end

function Tuning:selectCategory(category, blockScroll)
    exports.TR_hud:playerSpeedometerOpen(false)

    if not category then
        self.tuningList = categories[self.tunerType]
        self.scroll = self.lastScroll and self.lastScroll or startPoints[self.tunerType]
        self:buildAvaliableData()
        self.selected = "main"
    else
        if not self:canUseOption(self.tuningList[self.scroll]) then exports.TR_noti:create("Bu seçenek yalnızca premium oyuncular içindir.", "error") return end
        local selected = self.tuningList[self.scroll]
        if not blockScroll then self.lastScroll = self.scroll end
        self.selected = category

        if selected.isCustom then
            if selected.type == "lamps" then
                local color = split(self.defaultData.color, ",")
                self.tuningList = customUpgrades[category]
                self:resetTuningList()

                for i, v in pairs(self.tuningList) do
                    if v.element[1] == tonumber(color[13]) and v.element[2] == tonumber(color[14]) and v.element[3] == tonumber(color[15]) then
                        self.scroll = i
                        self.tuningList[i].selected = true
                        self.tuningList[1].selected = nil
                        return
                    end
                end

            elseif selected.type == "neon" then
                self.tuningList = {
                    {
                        name = "Brak",
                        type = "neon",
                        icon = "files/images/neon.png",
                        offset = Vector3(2, 0, 0),
                        element = false,
                        avaliableAll = true,
                    },
                }

                for i, v in pairs(neonColors) do
                    table.insert(self.tuningList, {
                        name = string.format("%s (FR)", v[4]),
                        type = "neon",
                        icon = "files/images/neon.png",
                        offset = Vector3(2, 0, 0),
                        element = {1, v[1], v[2], v[3]},
                        price = 40000,
                        avaliableAll = true,
                    })
                    table.insert(self.tuningList, {
                        name = string.format("%s (LR)", v[4]),
                        type = "neon",
                        icon = "files/images/neon.png",
                        offset = Vector3(2, 0, 0),
                        element = {2, v[1], v[2], v[3]},
                        price = 40000,
                        avaliableAll = true,
                    })
                    table.insert(self.tuningList, {
                        name = string.format("%s (ALL)", v[4]),
                        type = "neon",
                        icon = "files/images/neon.png",
                        offset = Vector3(2, 0, 0),
                        element = {3, v[1], v[2], v[3]},
                        price = 60000,
                        avaliableAll = true,
                    })
                end

                if self.defaultData.customTuning then
                    if self.defaultData.customTuning.neon then
                        local color = self.defaultData.customTuning.neon
                        for i, v in pairs(self.tuningList) do
                            if v.element then
                                if v.element[1] == tonumber(color[1]) and v.element[2] == tonumber(color[2]) and v.element[3] == tonumber(color[3]) and v.element[4] == tonumber(color[4]) then
                                    self.scroll = i
                                    self.tuningList[i].selected = true
                                    self.tuningList[1].selected = nil
                                    return
                                end
                            end
                        end
                    end
                end

            elseif selected.type == "speedoColor" then
                self.tuningList = customUpgrades[category]
                self:resetTuningList()
                exports.TR_hud:playerSpeedometerOpen(self.vehiclePreview, false, true)

                if self.defaultData.customTuning then
                    if self.defaultData.customTuning[category] then
                        local color = self.defaultData.customTuning[category]
                        for i, v in pairs(self.tuningList) do
                            if v.element[1] == tonumber(color[1]) and v.element[2] == tonumber(color[2]) and v.element[3] == tonumber(color[3]) then
                                self.scroll = i
                                self.tuningList[i].selected = true
                                self.tuningList[1].selected = nil
                                return
                            end
                        end
                    end
                end

            -- Performance
            elseif selected.type == "turbo" then
                self.tuningList = customUpgrades[category]
                self:resetTuningList()

                for i, v in pairs(self.tuningList) do
                    if v.element then
                        if string.find(self.defaultData.customTuning.engineCapacity, v.element) then
                            self.scroll = i
                            self.tuningList[i].selected = true
                            self.tuningList[1].selected = nil
                            return
                        end
                    end
                end

            elseif selected.type == "distribution" then
                self.tuningList = customUpgrades[category]
                self:resetTuningList()

                if self.defaultData.customTuning.distribution then
                    for i, v in pairs(self.tuningList) do
                        if v.value then
                            if tonumber(self.defaultData.customTuning.distribution) == v.value then
                                self.scroll = i
                                self.tuningList[i].selected = true
                                self.tuningList[1].selected = nil
                                return
                            end
                        end
                    end
                end

            elseif selected.type == "piston" then
                self.tuningList = customUpgrades[category]
                self:resetTuningList()

                if self.defaultData.customTuning.piston then
                    for i, v in pairs(self.tuningList) do
                        if v.value then
                            if tonumber(self.defaultData.customTuning.piston) == v.value then
                                self.scroll = i
                                self.tuningList[i].selected = true
                                self.tuningList[1].selected = nil
                                return
                            end
                        end
                    end
                end

            elseif selected.type == "injection" then
                self.tuningList = customUpgrades[category]
                self:resetTuningList()

                if self.defaultData.customTuning.injection then
                    for i, v in pairs(self.tuningList) do
                        if v.value then
                            if tonumber(self.defaultData.customTuning.injection) == v.value then
                                self.scroll = i
                                self.tuningList[i].selected = true
                                self.tuningList[1].selected = nil
                                return
                            end
                        end
                    end
                end

            elseif selected.type == "intercooler" then
                self.tuningList = customUpgrades[category]
                self:resetTuningList()

                if self.defaultData.customTuning.intercooler then
                    for i, v in pairs(self.tuningList) do
                        if v.value then
                            if tonumber(self.defaultData.customTuning.intercooler) == v.value then
                                self.scroll = i
                                self.tuningList[i].selected = true
                                self.tuningList[1].selected = nil
                                return
                            end
                        end
                    end
                end

            elseif selected.type == "clutch" then
                self.tuningList = customUpgrades[category]
                self:resetTuningList()

                if self.defaultData.customTuning.clutch then
                    for i, v in pairs(self.tuningList) do
                        if v.value then
                            if tonumber(self.defaultData.customTuning.clutch) == v.value then
                                self.scroll = i
                                self.tuningList[i].selected = true
                                self.tuningList[1].selected = nil
                                return
                            end
                        end
                    end
                end

            elseif selected.type == "breaking" then
                self.tuningList = customUpgrades[category]
                self:resetTuningList()

                if self.defaultData.customTuning.breaking then
                    for i, v in pairs(self.tuningList) do
                        if v.value then
                            if tonumber(self.defaultData.customTuning.breaking) == v.value then
                                self.scroll = i
                                self.tuningList[i].selected = true
                                self.tuningList[1].selected = nil
                                return
                            end
                        end
                    end
                end

            elseif selected.type == "breakpad" then
                self.tuningList = customUpgrades[category]
                self:resetTuningList()

                if self.defaultData.customTuning.breakpad then
                    for i, v in pairs(self.tuningList) do
                        if v.value then
                            if tonumber(self.defaultData.customTuning.breakpad) == v.value then
                                self.scroll = i
                                self.tuningList[i].selected = true
                                self.tuningList[1].selected = nil
                                return
                            end
                        end
                    end
                end

            elseif selected.type == "steering" then
                self.tuningList = customUpgrades[category]
                self:resetTuningList()

                if self.defaultData.customTuning.steering then
                    for i, v in pairs(self.tuningList) do
                        if v.value then
                            if tonumber(self.defaultData.customTuning.steering) == v.value then
                                self.scroll = i
                                self.tuningList[i].selected = true
                                self.tuningList[1].selected = nil
                                return
                            end
                        end
                    end
                end

            elseif selected.type == "suspension" then
                self.tuningList = customUpgrades[category]
                self:resetTuningList()

                if tonumber(self.defaultData.customTuning.suspension) == 1087 then
                    self.scroll = 2
                    self.tuningList[2].selected = true
                    self.tuningList[1].selected = nil
                    return
                elseif self.defaultData.customTuning.suspension == true then
                    self.scroll = 3
                    self.tuningList[3].selected = true
                    self.tuningList[1].selected = nil
                    return
                end

            elseif selected.type == "transmission" then
                self.tuningList = customUpgrades[category]
                self:resetTuningList()

                if self.defaultData.customTuning.transmission then
                    for i, v in pairs(self.tuningList) do
                        if v.value then
                            if tonumber(self.defaultData.customTuning.transmission) == v.value then
                                self.scroll = i
                                self.tuningList[i].selected = true
                                self.tuningList[1].selected = nil
                                return
                            end
                        end
                    end
                end

            elseif selected.type == "drivetype" then
                self.tuningList = customUpgrades[category]
                self:resetTuningList()

                for i, v in pairs(self.tuningList) do
                    if v.value then
                        if string.lower(self.defaultData.handling.driveType) == v.value then
                            self.scroll = i
                            self.tuningList[i].selected = true
                            self.tuningList[1].selected = nil
                            return
                        end
                    end
                end

            -- Standard custom visual
            else
                self.tuningList = customUpgrades[category]
                self:resetTuningList()
                if self.defaultData.customTuning then
                    for i, v in pairs(self.tuningList) do
                        if tonumber(v.element) == tonumber(self.defaultData.customTuning[category]) then
                            self.scroll = i
                            self.tuningList[i].selected = true
                            self.tuningList[1].selected = nil
                            return
                        end
                    end
                end
            end
        else
            self.tuningList = self.avaliableUpgrades[category]
            self:resetTuningList()
            for i, v in pairs(self.tuningList) do
                if v.element then
                    if self.defaultDataIndexed[v.element] then
                        self.scroll = i
                        self.tuningList[1].selected = nil
                        return
                    end
                end
            end
        end
        self.scroll = 1
        self.tuningList[1].selected = true
    end
end

function Tuning:resetTuningList()
    if not self.tuningList then return end
    for i, v in pairs(self.tuningList) do
        self.tuningList[i].selected = nil
    end
end

function Tuning:buildAvaliableData()
    local _data = {}
    self.avaliableUpgrades = {}

    for i, v in pairs(self.tuningList) do
        self.avaliableUpgrades[v.type] = {}
        _data[v.type] = v

        table.insert(self.avaliableUpgrades[v.type], {
            name = "Brak",
            type = "removeUpgrade",
            offset = v.offset or "files/images/exit.png",
            icon = v.icon or "files/images/exit.png",
            component = v.component or false,
            avaliableAll = true,
            element = v,
        })
    end

    local upgrades = getVehicleCompatibleUpgrades(self.vehiclePreview)
    for i, v in pairs(upgrades) do
        local type = string.lower(getVehicleUpgradeSlotName(v))
        if self.avaliableUpgrades[type] and prices[v] then
            table.insert(self.avaliableUpgrades[type], {
                name = upgradeNames[v-999],
                type = "setUpgrade",
                offset = _data[type] and _data[type].offset or "files/images/exit.png",
                icon = _data[type] and _data[type].icon or "files/images/exit.png",
                component = _data[type] and _data[type].component or false,
                avaliableAll = true,
                element = v,
                price = prices[v]/10,
            })
        end
    end
end

function Tuning:animate()
    if self.freeCameraEnabled then
        if getKeyState("arrow_r") then
            self.rot = self.rot - 1
            if self.rot < 360 then self.rot = self.rot + 360 end
            local x, y = self:getPointFromDistanceRotation(guiInfo.vehicle.pos.x, guiInfo.vehicle.pos.y, guiInfo.camera.distance, self.rot)
            self.cameraPos = Vector3(x, y, guiInfo.vehicle.pos.z + guiInfo.camera.height)

        elseif getKeyState("arrow_l") then
            self.rot = self.rot + 1
            if self.rot > 720 then self.rot = self.rot - 360 end
            local x, y = self:getPointFromDistanceRotation(guiInfo.vehicle.pos.x, guiInfo.vehicle.pos.y, guiInfo.camera.distance, self.rot)
            self.cameraPos = Vector3(x, y, guiInfo.vehicle.pos.z + guiInfo.camera.height)
        end
        return
    end

    if self.state == "move" then
        local progress = (getTickCount() - self.cameraTick)/self.timeToRot

        self.rot = interpolateBetween(self.actualRot, 0, 0, self.nextRot, 0, 0, progress, "OutQuad")
        local cx, cy, cz = interpolateBetween(self.currentCamera, self.targetCamera, progress, "OutQuad")
        local x, y = self:getPointFromDistanceRotation(guiInfo.vehicle.pos.x, guiInfo.vehicle.pos.y, guiInfo.camera.distance, self.rot)
        self.cameraPos = Vector3(x, y, guiInfo.vehicle.pos.z + guiInfo.camera.height)
        self.cameraLook = Vector3(cx, cy, cz)

        if self.freeCamera then
            guiInfo.list.y = interpolateBetween(guiInfo.list.defY, 0, 0, sy, 0, 0, progress, "OutQuad")

        elseif self.freeCameraHide then
            guiInfo.list.y = interpolateBetween(sy, 0, 0, guiInfo.list.defY, 0, 0, progress, "OutQuad")
        end

        if progress >= 1 then
            self.rot = self.nextRot
            self.actualRot = nil
            self.cameraTick = nil
            self.state = nil

            if self.freeCamera then
                self.freeCameraEnabled = true
            else
                self.freeCameraHide = nil
            end
        end
    end
end

function Tuning:render()
    self:animate()

    setCameraMatrix(self.cameraPos, self.cameraLook)

    self:renderList()
    self:renderPerformance()
    -- self:drawSpeedometer()

    -- if self.defaultData then dxDrawText(inspect(self.defaultData), 10, 10) end
end

function Tuning:renderPerformance()
    if self.tunerType ~= "performance" then return end

    local vehicleHandling = getVehicleHandling(self.vehiclePreview)

    dxDrawRectangle(guiInfo.perf.x, guiInfo.perf.y, guiInfo.perf.w, guiInfo.perf.h, tocolor(17, 17, 17, 255))
    dxDrawText("Araç performansı", guiInfo.perf.x + 10/zoom, guiInfo.perf.y, guiInfo.perf.x + guiInfo.perf.w - 20/zoom, guiInfo.perf.y + 40/zoom, tocolor(220, 220, 220, 255), 1/zoom, self.fonts.performance, "center", "center")

    for i, v in pairs(guiInfo.perf.list) do
        dxDrawText(v.name, guiInfo.perf.x + 10/zoom, guiInfo.perf.y + 40/zoom + (i-1) * 70/zoom, guiInfo.perf.w, guiInfo.perf.h, tocolor(170, 170, 170, 255), 1/zoom, self.fonts.categorySecond, "left", "top")
        dxDrawRectangle(guiInfo.perf.x + 10/zoom, guiInfo.perf.y + 65/zoom + (i-1) * 70/zoom, guiInfo.perf.w - 20/zoom, 30/zoom, tocolor(27, 27, 27, 255))

        if self.defaultData.handling[v.handling] and performanceValuesMax[v.handling] then
            if self.defaultData.handling[v.handling] > vehicleHandling[v.handling] then
                dxDrawRectangle(guiInfo.perf.x + 10/zoom, guiInfo.perf.y + 65/zoom + (i-1) * 70/zoom, (guiInfo.perf.w - 20/zoom) * self.defaultData.handling[v.handling]/performanceValuesMax[v.handling], 30/zoom, tocolor(127, 47, 47, 255))
                dxDrawRectangle(guiInfo.perf.x + 10/zoom, guiInfo.perf.y + 65/zoom + (i-1) * 70/zoom, (guiInfo.perf.w - 20/zoom) * vehicleHandling[v.handling]/performanceValuesMax[v.handling], 30/zoom, tocolor(77, 77, 77, 255))

            elseif self.defaultData.handling[v.handling] < vehicleHandling[v.handling] then
                dxDrawRectangle(guiInfo.perf.x + 10/zoom, guiInfo.perf.y + 65/zoom + (i-1) * 70/zoom, (guiInfo.perf.w - 20/zoom) * vehicleHandling[v.handling]/performanceValuesMax[v.handling], 30/zoom, tocolor(47, 127, 47, 255))
                dxDrawRectangle(guiInfo.perf.x + 10/zoom, guiInfo.perf.y + 65/zoom + (i-1) * 70/zoom, (guiInfo.perf.w - 20/zoom) * self.defaultData.handling[v.handling]/performanceValuesMax[v.handling], 30/zoom, tocolor(77, 77, 77, 255))

            else
                dxDrawRectangle(guiInfo.perf.x + 10/zoom, guiInfo.perf.y + 65/zoom + (i-1) * 70/zoom, (guiInfo.perf.w - 20/zoom) * self.defaultData.handling[v.handling]/performanceValuesMax[v.handling], 30/zoom, tocolor(77, 77, 77, 255))
            end

        elseif v.handling == "fuelTake" then
            local defaultFuel = tonumber(string.format("%.6f", (self.defaultData.handling["engineAcceleration"] * math.sqrt(100))/7000, 0.0001)) * 1000
            local nowFuel = tonumber(string.format("%.6f", (vehicleHandling["engineAcceleration"] * math.sqrt(100))/7000, 0.0001)) * 1000

            if defaultFuel > nowFuel then
                dxDrawRectangle(guiInfo.perf.x + 10/zoom, guiInfo.perf.y + 65/zoom + (i-1) * 70/zoom, (guiInfo.perf.w - 20/zoom) * defaultFuel/performanceValuesMax[v.handling], 30/zoom, tocolor(47, 127, 47, 255))
                dxDrawRectangle(guiInfo.perf.x + 10/zoom, guiInfo.perf.y + 65/zoom + (i-1) * 70/zoom, (guiInfo.perf.w - 20/zoom) * nowFuel/performanceValuesMax[v.handling], 30/zoom, tocolor(77, 77, 77, 255))

            elseif defaultFuel < nowFuel then
                dxDrawRectangle(guiInfo.perf.x + 10/zoom, guiInfo.perf.y + 65/zoom + (i-1) * 70/zoom, (guiInfo.perf.w - 20/zoom) * nowFuel/performanceValuesMax[v.handling], 30/zoom, tocolor(127, 47, 47, 255))
                dxDrawRectangle(guiInfo.perf.x + 10/zoom, guiInfo.perf.y + 65/zoom + (i-1) * 70/zoom, (guiInfo.perf.w - 20/zoom) * defaultFuel/performanceValuesMax[v.handling], 30/zoom, tocolor(77, 77, 77, 255))

            else
                dxDrawRectangle(guiInfo.perf.x + 10/zoom, guiInfo.perf.y + 65/zoom + (i-1) * 70/zoom, (guiInfo.perf.w - 20/zoom) * defaultFuel/performanceValuesMax[v.handling], 30/zoom, tocolor(77, 77, 77, 255))
            end
        end
    end
end

function Tuning:renderList()
    if self.tuningList[self.scroll - 2] then
        self:drawTuningItem(guiInfo.list.x - 320/zoom, guiInfo.list.y + 20/zoom, 60/zoom, 60/zoom, self.tuningList[self.scroll-2], 110, self.fonts.categoryThird, 25/zoom)
    end
    if self.tuningList[self.scroll - 1] then
        self:drawTuningItem(guiInfo.list.x - 180/zoom, guiInfo.list.y + 10/zoom, 80/zoom, 80/zoom, self.tuningList[self.scroll-1], 180, self.fonts.categorySecond, 30/zoom)
    end

    self:drawTuningItem(guiInfo.list.x, guiInfo.list.y, guiInfo.list.w, guiInfo.list.h, self.tuningList[self.scroll], 255, self.fonts.categoryCenter, 35/zoom)

    if self.tuningList[self.scroll + 1] then
        self:drawTuningItem(guiInfo.list.x + 200/zoom, guiInfo.list.y + 10/zoom, 80/zoom, 80/zoom, self.tuningList[self.scroll+1], 180, self.fonts.categorySecond, 30/zoom)
    end
    if self.tuningList[self.scroll + 2] then
        self:drawTuningItem(guiInfo.list.x + 380/zoom, guiInfo.list.y + 20/zoom, 60/zoom, 60/zoom, self.tuningList[self.scroll+2], 110, self.fonts.categoryThird, 25/zoom)
    end
end

function Tuning:drawTuningItem(x, y, w, h, item, alpha, font, lowerPrice)
    if item.selected then
        dxDrawImage(x, y, w, h, item.icon, 0, 0, 0, tocolor(240, 196, 55, alpha))
        dxDrawText(item.name, x, y + h + 10/zoom, x + w, y + h, tocolor(255, 255, 255, alpha), 1/zoom, font, "center", "top")
        dxDrawText("Kurulmuş", x, y + h + lowerPrice, x + w, y + h, tocolor(212, 175, 55, alpha), 1/zoom, font, "center", "top")
        return
    end

    if item.element then
        if self.defaultDataIndexed[item.element] then
            dxDrawImage(x, y, w, h, item.icon, 0, 0, 0, tocolor(240, 196, 55, alpha))
            dxDrawText(item.name, x, y + h + 10/zoom, x + w, y + h, tocolor(255, 255, 255, alpha), 1/zoom, font, "center", "top")
            dxDrawText("Kurulmuş", x, y + h + lowerPrice, x + w, y + h, tocolor(212, 175, 55, alpha), 1/zoom, font, "center", "top")
            return
        end
    end

    if item.avaliableAll then
        dxDrawImage(x, y, w, h, item.icon, 0, 0, 0, tocolor(255, 255, 255, alpha))
        dxDrawText(item.name, x, y + h + 10/zoom, x + w, y + h, tocolor(255, 255, 255, alpha), 1/zoom, font, "center", "top")
        dxDrawText(item.price and string.format("$%d", item.price) or "", x, y + h + lowerPrice, x + w, y + h, tocolor(170, 170, 170, alpha), 1/zoom, font, "center", "top")
        return
    end

    if self.avaliableUpgrades[item.type] then
        if #self.avaliableUpgrades[item.type] > 1 then
            dxDrawImage(x, y, w, h, item.icon, 0, 0, 0, tocolor(255, 255, 255, alpha))
            dxDrawText(item.name, x, y + h + 10/zoom, x + w, y + h, tocolor(255, 255, 255, alpha), 1/zoom, font, "center", "top")
            dxDrawText(item.price and string.format("$%d", item.price) or "", x, y + h + lowerPrice, x + w, y + h, tocolor(170, 170, 170, alpha), 1/zoom, font, "center", "top")
            return
        end
    end
    dxDrawImage(x, y, w, h, item.icon, 0, 0, 0, tocolor(170, 170, 170, alpha))
    dxDrawText(item.name, x, y + h + 10/zoom, x + w, y + h, tocolor(170, 170, 170, alpha), 1/zoom, font, "center", "top")
    dxDrawText(item.price and string.format("$%d", item.price) or "", x, y + h + lowerPrice, x + w, y + h, tocolor(170, 170, 170, alpha), 1/zoom, font, "center", "top")
end

function Tuning:drawSpeedometer()
    if self.selected ~= "speedoColor" then return end
    local color = {255, 255, 255}
    local visualTuning = getElementData(self.vehiclePreview, "visualTuning")
	if visualTuning then
		if visualTuning.speedoColor then
			color = {tonumber(visualTuning.speedoColor[1]), tonumber(visualTuning.speedoColor[2]), tonumber(visualTuning.speedoColor[3])}
		end
	end
	dxDrawText("KM/H", guiInfo.speedo.x + guiInfo.speedo.w/2, 0, guiInfo.speedo.x + guiInfo.speedo.w/2, guiInfo.speedo.y + guiInfo.speedo.h/2 - 30/zoom, tocolor(255, 255, 255, 255), 1/zoom, self.fonts.categoryThird, "center", "bottom")

	dxDrawImage(guiInfo.speedo.x, guiInfo.speedo.y, guiInfo.speedo.w, guiInfo.speedo.h, ":TR_hud/files/images/speedo/speedo.png", 0, 0, 0, tocolor(color[1], color[2], color[3], 255))
	dxDrawImage(guiInfo.speedo.x, guiInfo.speedo.y, guiInfo.speedo.w, guiInfo.speedo.h, ":TR_hud/files/images/speedo/speedoRed.png", 0, 0, 0, tocolor(255, 255, 255, 255))
	dxDrawImage(guiInfo.speedo.x, guiInfo.speedo.y, guiInfo.speedo.w, guiInfo.speedo.h, ":TR_hud/files/images/speedo/needle.png", 0, 0, 0, tocolor(255, 255, 255, 255))

	for i = 0, 5 do
		dxDrawRectangle(guiInfo.speedo.x + 130/zoom + i * 20/zoom, guiInfo.speedo.y + guiInfo.speedo.h/2 + 55/zoom, 18/zoom, 18/zoom, tocolor(17, 17, 17, 255))
		dxDrawImageSection(guiInfo.speedo.x + 130/zoom + i * 20/zoom, guiInfo.speedo.y + guiInfo.speedo.h/2 + 55/zoom, 18/zoom, 18/zoom, 0, guiInfo.speedo.mileageHeight - 24 - (guiInfo.speedo.mileageInfo[i+1] * 24), 24, 24, ":TR_hud/files/images/speedo/mileage.png", 0, 0, 0, tocolor(255, 255, 255, 255))
	end
	dxDrawText("KM", guiInfo.speedo.x + guiInfo.speedo.w/2, 0, guiInfo.speedo.x + guiInfo.speedo.w/2, guiInfo.speedo.y + guiInfo.speedo.h/2 + 50/zoom, tocolor(255, 255, 255, 255), 1/zoom, self.fonts.categoryThird, "center", "bottom")

	dxDrawText("FUEL", guiInfo.speedo.x - 8/zoom, 0, guiInfo.speedo.x - 8/zoom, guiInfo.speedo.y + guiInfo.speedo.h - 64/zoom, tocolor(255, 255, 255, 255), 1/zoom, self.fonts.categoryThird, "center", "bottom")
	dxDrawImage(guiInfo.speedo.x - 100/zoom, guiInfo.speedo.y + guiInfo.speedo.h - 130/zoom, 110/zoom, 110/zoom, ":TR_hud/files/images/speedo/fuel.png", 0, 0, 0, tocolor(color[1], color[2], color[3], 255))
	dxDrawImage(guiInfo.speedo.x - 100/zoom, guiInfo.speedo.y + guiInfo.speedo.h - 130/zoom, 110/zoom, 110/zoom, ":TR_hud/files/images/speedo/fuelRed.png", 0, 0, 0, tocolor(255, 255, 255, 255))
	dxDrawImage(guiInfo.speedo.x - 78/zoom, guiInfo.speedo.y + guiInfo.speedo.h - 108/zoom, 140/zoom, 140/zoom, ":TR_hud/files/images/speedo/fuelNeedle.png", 0, 0, 0, tocolor(255, 255, 255, 255))
end

function Tuning:onClientKey(key, state)
    if self.blockKey then return end
    if exports.TR_dx:isResponseEnabled() then return end

    if state then
        if self.freeCameraEnabled then
            if key == "r" then
                self.freeCamera = nil
                self.freeCameraEnabled = nil
                self.freeCameraHide = true
                self:moveToPart()
            end
            return

        elseif self.freeCamera or self.freeCameraHide then return end

        if key == "esc" then
            cancelEvent()

        elseif key == "r" then
            self.freeCamera = true
            self:moveToPart()

        elseif key == "arrow_l" then
            if self.scroll == 1 then return end
            self.scroll = self.scroll - 1
            self:moveToPart()
            self:updateVehicleOnMove()

        elseif key == "arrow_r" then
            if self.scroll == #self.tuningList then return end
            self.scroll = self.scroll + 1
            self:moveToPart()
            self:updateVehicleOnMove()

        elseif key == "enter" then
            local item = self.tuningList[self.scroll]

            if item.type == "exit" then
                self:close()
                return
            end

            if self.selected == "main" then
                if not item.avaliableAll then
                    if not self.avaliableUpgrades[item.type] then
                        exports.TR_noti:create("Bu kategoride bu araç için yükseltme mevcut değil.", "error")
                        return
                    end

                    if #self.avaliableUpgrades[item.type] < 1 then
                        exports.TR_noti:create("Bu kategoride bu araç için yükseltme mevcut değil.", "error")
                        return
                    end
                end

                if item.isCustom then
                    self:selectCategory(item.type)
                    return
                else
                    if #self.avaliableUpgrades[item.type] > 1 then
                        self:selectCategory(item.type)
                        return
                    end
                end

                exports.TR_noti:create("Bu kategoride bu araç için yükseltme mevcut değil.", "error")
                return
            else
                self:buyItem(item)
            end

        elseif key == "escape" or key == "backspace" then
            cancelEvent()

            if self.selected ~= "main" then
                self:selectCategory()
                self:resetVehicleTune()
            end
        end
    end
end

function Tuning:buyItem(item)
    if item.selected then return end
    if item.element then
        if self.defaultDataIndexed[item.element] then return end
    end

    -- if item.custom
    if item.type == "setUpgrade" or item.type == "removeUpgrade" then
        local upgrades = getVehicleUpgrades(self.vehiclePreview)
        triggerServerEvent("createPayment", resourceRoot, item.price or 0, "buyVehicleTuneItem", {
            ID = self.defaultData.ID,
            type = item.type,
            newData = toJSON(upgrades),
            tuneType = self.tunerType,
        })

    elseif item.type == "lamps" then
        local r, g, b = getVehicleHeadLightColor(self.vehiclePreview)
        local color = ""
        for i, v in pairs({getVehicleColor(self.vehiclePreview, true)}) do
            color = color .. v .. ","
        end
        color = color .. r .. ",".. g .. ",".. b

        triggerServerEvent("createPayment", resourceRoot, item.price or 0, "buyVehicleTuneItem", {
            ID = self.defaultData.ID,
            type = item.type,
            newData = color,
            tuneType = self.tunerType,
        })

    elseif item.type == "speedoColor" or item.type == "glassTint" or item.type == "wheelResize" or item.type == "wheelTilt" or item.type == "neon" then
        local data = getElementData(self.vehiclePreview, "visualTuning")

        triggerServerEvent("createPayment", resourceRoot, item.price or 0, "buyVehicleTuneItem", {
            ID = self.defaultData.ID,
            type = item.type,
            newData = toJSON(data),
            tuneType = self.tunerType,
        })

    elseif item.type == "turbo" then
        local c = ""
        local hasTurbo = nil
        for i = 1, string.len(self.defaultData.customTuning.engineCapacity) do
            local str = string.sub(self.defaultData.customTuning.engineCapacity, i, i)
            if str == " " then break end
            c = c .. str
        end

        local name = split(self.defaultData.customTuning.engineCapacity, " ")
        local cform = string.format("%.1f %s", tonumber(c), name[2])

        triggerServerEvent("createPayment", resourceRoot, item.price or 0, "buyVehicleTuneItem", {
            ID = self.defaultData.ID,
            type = item.type,
            newData = cform..(item.element and " "..item.element or ""),
            tuneType = self.tunerType,
        })

    elseif item.type == "distribution" or item.type == "piston" or item.type == "injection" or item.type == "intercooler" or item.type == "clutch" or item.type == "breaking" or item.type == "breakpad" or item.type == "steering" or item.type == "transmission" or item.type == "drivetype" or item.type == "suspension" then
        local data = self.defaultData.customTuning
        data[item.type] = item.value

        triggerServerEvent("createPayment", resourceRoot, item.price or 0, "buyVehicleTuneItem", {
            ID = self.defaultData.ID,
            type = item.type,
            newData = toJSON(data),
            tuneType = self.tunerType,
        })
    end
end

function Tuning:canUseOption(option)
    if option.isPremium then
        local data = getElementData(localPlayer, "characterData")
        if data.premium ~= "diamond" and data.premium ~= "gold" then return false end
        return true
    end
    return true
end

function Tuning:moveToPart()
    local data = self.tuningList[self.scroll]
    if not data.offset then return end

    if self.freeCamera then
        local x, y, z = self:getPosition(self.vehiclePreview, data.offset)
        self.nextRot = self:findRotation(guiInfo.vehicle.pos.x, guiInfo.vehicle.pos.y, x, y)
        if self.nextRot == 0 then self.nextRot = 360 end

        self.state = "move"
        self.actualRot = self.rot
        self.cameraTick = getTickCount()
        self.timeToRot = 200
        self.currentCamera = self.cameraLook
        self.targetCamera = guiInfo.vehicle.pos
        return
    end

    if data.offset then
        local x, y, z = self:getPosition(self.vehiclePreview, data.offset)
        self.nextRot = self:findRotation(guiInfo.vehicle.pos.x, guiInfo.vehicle.pos.y, x, y)
        if self.nextRot == 0 then self.nextRot = 360 end

        self.state = "move"
        self.actualRot = self.rot
        self.cameraTick = getTickCount()
        self.timeToRot = math.max(math.abs(self.nextRot - self.actualRot) * 10, 200)

        if data.component then
            local cx, cy, cz = getVehicleComponentPosition(self.vehiclePreview, data.component, "world")
            if cx then
                self.currentCamera = self.cameraLook
                self.targetCamera = Vector3(cx, cy, cz)
            else
                self.currentCamera = self.cameraLook
                self.targetCamera = guiInfo.vehicle.pos
            end
        else
            self.currentCamera = self.cameraLook
            self.targetCamera = guiInfo.vehicle.pos
        end
    end
end

function Tuning:setDefaultVehicleTuning(data)
    self.defaultData = data

    self.defaultDataIndexed = {}
    local tuning = self.defaultData.tuning and fromJSON(self.defaultData.tuning) or {}
    for i, v in pairs(tuning) do
        self.defaultDataIndexed[tonumber(v)] = true
    end

    self.defaultData.customTuning = data.customTuning and fromJSON(data.customTuning) or {}

    if data.engineCapacity then
        self.defaultData.customTuning.engineCapacity = data.engineCapacity
    end
end

function Tuning:updateVehicleOnMove()
    self:resetVehicleTune()

    local item = self.tuningList[self.scroll]

    if item.type == "lamps" then
        setVehicleOverrideLights(self.vehiclePreview, 2)
    else
        setVehicleOverrideLights(self.vehiclePreview, 1)
    end

    if self.selected == "main" then return end
    if item.type == "setUpgrade" then
        addVehicleUpgrade(self.vehiclePreview, item.element)

    elseif item.type == "removeUpgrade" then
        local upgrades = getVehicleUpgrades(self.vehiclePreview)
        for i, v in pairs(upgrades) do
            removeVehicleUpgrade(self.vehiclePreview, v)
        end

        local tuning = self.defaultData.tuning and fromJSON(self.defaultData.tuning) or {}
        for i, v in pairs(tuning) do
            local type = string.lower(getVehicleUpgradeSlotName(v))
            if type ~= self.selected then
                addVehicleUpgrade(self.vehiclePreview, v)
            end
        end

    elseif item.type == "wheelResize" then
        local visualUpgrades = table.copy(self.defaultData.customTuning or {})

        visualUpgrades.wheelResize = item.element
        setElementData(self.vehiclePreview, "visualTuning", visualUpgrades, false)

    elseif item.type == "wheelTilt" then
        local visualUpgrades = table.copy(self.defaultData.customTuning or {})

        visualUpgrades.wheelTilt = item.element
        setElementData(self.vehiclePreview, "visualTuning", visualUpgrades, false)

    elseif item.type == "glassTint" then
        local visualUpgrades = table.copy(self.defaultData.customTuning or {})

        visualUpgrades.glassTint = item.element
        setElementData(self.vehiclePreview, "visualTuning", visualUpgrades, false)

    elseif item.type == "neon" then
        local visualUpgrades = table.copy(self.defaultData.customTuning or {})

        visualUpgrades.neon = item.element
        setElementData(self.vehiclePreview, "visualTuning", visualUpgrades, false)

    elseif item.type == "speedoColor" then
        local visualUpgrades = table.copy(self.defaultData.customTuning or {})

        visualUpgrades.speedoColor = item.element
        setElementData(self.vehiclePreview, "visualTuning", visualUpgrades, false)

    elseif item.type == "lamps" then
        setVehicleHeadLightColor(self.vehiclePreview, item.element[1], item.element[2], item.element[3])

    elseif item.type == "turbo" then
        local c = ""
        local hasTurbo = nil
        for i = 1, string.len(self.defaultData.customTuning.engineCapacity) do
            local str = string.sub(self.defaultData.customTuning.engineCapacity, i, i)
            if str == " " then break end
            c = c .. str
        end

        local engineCapacity = self:getVehicleEngineCapacity(tonumber(c).." "..(item.element or ""))
        local engineAcceleration = self:getVehicleAcceleration(self.vehiclePreview, engineCapacity)

        setVehicleHandling(self.vehiclePreview, "engineAcceleration", engineAcceleration)
        setVehicleHandling(self.vehiclePreview, "maxVelocity", engineAcceleration * 15)

    elseif item.type == "distribution" then
        local amount = item.value
        if self.defaultData.customTuning.distribution then
            amount = item.value - tonumber(self.defaultData.customTuning.distribution)
        end

        setVehicleHandling(self.vehiclePreview, "engineAcceleration", self.defaultData.handling.engineAcceleration + amount)
        setVehicleHandling(self.vehiclePreview, "maxVelocity", (self.defaultData.handling.engineAcceleration + amount) * 15)

    elseif item.type == "piston" then
        local amount = item.value
        if self.defaultData.customTuning.piston then
            amount = item.value - tonumber(self.defaultData.customTuning.piston)
        end

        setVehicleHandling(self.vehiclePreview, "engineAcceleration", self.defaultData.handling.engineAcceleration + amount)
        setVehicleHandling(self.vehiclePreview, "maxVelocity", (self.defaultData.handling.engineAcceleration + amount) * 15)

    elseif item.type == "injection" then
        local amount = item.value
        if self.defaultData.customTuning.injection then
            amount = item.value - tonumber(self.defaultData.customTuning.injection)
        end

        setVehicleHandling(self.vehiclePreview, "engineAcceleration", self.defaultData.handling.engineAcceleration + amount)
        setVehicleHandling(self.vehiclePreview, "maxVelocity", (self.defaultData.handling.engineAcceleration + amount) * 15)

    elseif item.type == "intercooler" then
        local amount = item.value
        if self.defaultData.customTuning.intercooler then
            amount = item.value - tonumber(self.defaultData.customTuning.intercooler)
        end

        setVehicleHandling(self.vehiclePreview, "engineAcceleration", self.defaultData.handling.engineAcceleration + amount)
        setVehicleHandling(self.vehiclePreview, "maxVelocity", (self.defaultData.handling.engineAcceleration + amount) * 15)

    elseif item.type == "clutch" then
        local amount = item.value
        if self.defaultData.customTuning.clutch then
            amount = item.value - tonumber(self.defaultData.customTuning.clutch)
        end

        setVehicleHandling(self.vehiclePreview, "engineAcceleration", self.defaultData.handling.engineAcceleration + amount)
        setVehicleHandling(self.vehiclePreview, "maxVelocity", (self.defaultData.handling.engineAcceleration + amount) * 15)

    elseif item.type == "breaking" then
        local amount = item.value
        if self.defaultData.customTuning.breaking then
            amount = item.value - tonumber(self.defaultData.customTuning.breaking)
        end

        setVehicleHandling(self.vehiclePreview, "brakeDeceleration", self.defaultData.handling.brakeDeceleration + amount)

    elseif item.type == "breakpad" then
        local amount = item.value
        if self.defaultData.customTuning.breakpad then
            amount = item.value - tonumber(self.defaultData.customTuning.breakpad)
        end

        setVehicleHandling(self.vehiclePreview, "brakeDeceleration", self.defaultData.handling.brakeDeceleration + amount)

    elseif item.type == "steering" then
        local amount = item.value
        if self.defaultData.customTuning.steering then
            amount = item.value - tonumber(self.defaultData.customTuning.steering)
        end

        setVehicleHandling(self.vehiclePreview, "steeringLock", self.defaultData.handling.steeringLock + amount)

    elseif item.type == "steering" then
        local amount = item.value
        if self.defaultData.customTuning.steering then
            amount = item.value - tonumber(self.defaultData.customTuning.steering)
        end

        setVehicleHandling(self.vehiclePreview, "steeringLock", self.defaultData.handling.steeringLock + amount)

    elseif item.type == "transmission" then
        local amount = item.value
        if self.defaultData.customTuning.transmission then
            amount = item.value - tonumber(self.defaultData.customTuning.transmission)
        end

        setVehicleHandling(self.vehiclePreview, "engineAcceleration", self.defaultData.handling.engineAcceleration + amount)
        setVehicleHandling(self.vehiclePreview, "maxVelocity", (self.defaultData.handling.engineAcceleration + amount) * 15)

    elseif item.type == "drivetype" then
        setVehicleHandling(self.vehiclePreview, "driveType", item.value)
    end
end

function Tuning:buildPlayerVehicle()
    if not isElement(self.vehiclePreview) then
        setElementPosition(localPlayer, 1013.94921875, -1597.9870605469, 13.60625076293)
        setElementInterior(localPlayer, guiInfo.vehicle.int)
        setElementDimension(localPlayer, guiInfo.vehicle.dim)

        self.vehiclePreview = createVehicle(self.defaultData.model, guiInfo.vehicle.pos, guiInfo.vehicle.rot, "TUNING")
        setElementInterior(self.vehiclePreview, guiInfo.vehicle.int)
        setElementDimension(self.vehiclePreview, guiInfo.vehicle.dim)
        setElementData(self.vehiclePreview, "neonEnabled", true, false)

        setVehicleOverrideLights(self.vehiclePreview, 1)
    end

    if self.defaultData.customTuning.engineCapacity then
        local engineCapacity = self:getVehicleEngineCapacity(self.defaultData.customTuning.engineCapacity)
        local engineAcceleration = self:getVehicleAcceleration(self.vehiclePreview, engineCapacity)

        setVehicleHandling(self.vehiclePreview, "engineAcceleration", engineAcceleration)
        setVehicleHandling(self.vehiclePreview, "maxVelocity", engineAcceleration * 15)

        self.defaultData.handling = getVehicleHandling(self.vehiclePreview)
    end

    self:resetVehicleTune()
end

function Tuning:resetVehicleTune()
    local color = split(self.defaultData.color, ",")
	setVehicleColor(self.vehiclePreview, color[1], color[2], color[3], color[4], color[5], color[6], color[7], color[8], color[9], color[10], color[11], color[12])
    setVehicleHeadLightColor(self.vehiclePreview, color[13], color[14], color[15])

    local upgrades = getVehicleUpgrades(self.vehiclePreview)
    for i, v in pairs(upgrades) do
        removeVehicleUpgrade(self.vehiclePreview, v)
    end

    local tuning = self.defaultData.tuning and fromJSON(self.defaultData.tuning) or {}
    for i, v in pairs(tuning) do
        addVehicleUpgrade(self.vehiclePreview, v)
    end

    setElementData(self.vehiclePreview, "visualTuning", self.defaultData.customTuning, false)

    if self.defaultData.handling then
        for i, v in pairs(self.defaultData.handling) do
            setVehicleHandling(self.vehiclePreview, i, v)
        end
    end
end


function Tuning:response(...)
    exports.TR_dx:setResponseEnabled(false)

    if arg[1] then
        exports.TR_noti:create("Parça başarıyla satın alındı.", "success")

        if arg[2] then
            self:setDefaultVehicleTuning(arg[2])
            self:resetVehicleTune()
            self:buildPlayerVehicle()
            self:selectCategory(self.selected, true)
        end

    elseif arg[2] then
        self:setDefaultVehicleTuning(arg[2])
        self:resetVehicleTune()
        self:buildPlayerVehicle()
        self:selectCategory(self.selected, true)
    end
end

function Tuning:getVehicleEngineCapacity(capacity)
	local c = ""
	local hasTurbo = nil
    for i = 1, string.len(capacity) do
        local str = string.sub(capacity, i, i)
        if str == " " then break end
        c = c .. str
	end

	local newCapacity = tonumber(c)
	if string.find(capacity, "Turbo") then newCapacity = newCapacity + 0.5; hasTurbo = true end
	if string.find(capacity, "Biturbo") or string.find(capacity, "Twin Turbo") then newCapacity = newCapacity + 1; hasTurbo = true end

    local performanceTuning = self.defaultData.customTuning
	if performanceTuning then
		for i, v in pairs(performanceTuning) do
			if i == "distribution" or i == "piston" or i == "injection" or i == "intercooler" or i == "clutch" or i == "transmission" then
				newCapacity = newCapacity + v
			end
        end

        setVehicleHandling(self.vehiclePreview, "steeringLock", nil)
        setVehicleHandling(self.vehiclePreview, "brakeDeceleration", nil)

		if performanceTuning.drivetype then
			setVehicleHandling(self.vehiclePreview, "driveType", performanceTuning.drivetype)
		end
		if performanceTuning.steering then
			setVehicleHandling(self.vehiclePreview, "steeringLock", getVehicleHandling(self.vehiclePreview)["steeringLock"] + performanceTuning.steering)
		end
		if performanceTuning.breaking then
			setVehicleHandling(self.vehiclePreview, "brakeDeceleration", getVehicleHandling(self.vehiclePreview)["brakeDeceleration"] + performanceTuning.breaking)
		end
		if performanceTuning.breakpad then
			setVehicleHandling(self.vehiclePreview, "brakeDeceleration", getVehicleHandling(self.vehiclePreview)["brakeDeceleration"] + performanceTuning.breakpad)
		end
	end
    return newCapacity, hasTurbo
end

function Tuning:getVehicleAcceleration(veh, capacity)
	if getVehicleType(veh) == "Bike" then
		return capacity * 27
	else
		return capacity * 3.3 -- 1 do 1 silnik
	end
end

function Tuning:findRotation( x1, y1, x2, y2 )
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end

function Tuning:getPointFromDistanceRotation(x, y, dist, angle)
    local a = math.rad(90 - angle);
    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;
    return x+dx, y+dy;
end

function Tuning:getPosition(element, vec)
	local rot = Vector3(getElementRotation(element))
	local mat = Matrix(Vector3(getElementPosition(element)), rot)
	local newPos = mat:transformPosition(vec)
	return newPos.x, newPos.y, newPos.z, rot.z
end



function createTuneWindow(type, data)
    if guiInfo.panel then return end
    if not exports.TR_dx:canOpenGUI() then return end

    exports.TR_dx:showLoading(10000, "Ayarlayıcı yükleniyor")
    local veh = getPedOccupiedVehicle(localPlayer)
    if veh then
        setElementFrozen(localPlayer, true)
        setElementFrozen(veh, true)
    end

    setTimer(function()
        triggerServerEvent("removeVehOnStartTune", resourceRoot)
    end, 1000, 1)

    setTimer(function()
        guiInfo.panel = Tuning:create(type, data)
    end, 5000, 1)
end
addEvent("createTuneWindow", true)
addEventHandler("createTuneWindow", root, createTuneWindow)


function vehicleTuneResponse(...)
    if not guiInfo.panel then return end
    guiInfo.panel:response(...)
end
addEvent("vehicleTuneResponse", true)
addEventHandler("vehicleTuneResponse", root, vehicleTuneResponse)

setCameraTarget(localPlayer)
setElementInterior(localPlayer, 0)
setElementDimension(localPlayer, 0)
setElementData(localPlayer, "blockTune", nil)
setElementFrozen(localPlayer, false)
exports.TR_dx:setOpenGUI(false)

-- if getPlayerName(localPlayer) == "panda" then
    -- createTuneWindow("performance", {
    --     model = 562,
    --     color = "0,0,0,0,0,0,0,0,0,60,0,0,0,255,0",
    --     -- tuning = "[[1078, 1087]]",
    --     engineCapacity = "2.0",
    --     -- customTuning = '[ { "wheelResize": 1.5, "wheelTilt": -5 , "glassTint": 0.9, "neon": [3, 255,0,255], "distribution": 0.4, "piston": 0.4} ]',
    -- })
-- end

-- Utils
function table.copy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else
        copy = orig
    end
    return copy
end