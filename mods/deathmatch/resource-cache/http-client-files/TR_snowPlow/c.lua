local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = sx - 300/zoom + (300/zoom - 128/zoom)/2,
    y = (sy - 68/zoom)/2 + 50/zoom,
    w = 128/zoom,
    h = 68/zoom,

    hourEarning = {3850, 3950},
}

SantaJob = {}
SantaJob.__index = SantaJob

function SantaJob:create(...)
    local instance = {}
    setmetatable(instance, SantaJob)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function SantaJob:constructor(...)
    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(12)
    self.ownedUpgrades = arg[1]
    self.selectedState = arg[2]
    self.teamFull = arg[3]

    self.takeSand = getTickCount()
    self.maxSand = self.ownedUpgrades[3] and 1500 or 1000
    self.sand = self.maxSand
    self.lastSand = self.sand

    self.marker = createMarker(-2239.900390625, -2307.9052734375, 30.344724655151, "cylinder", 2, 136, 125, 90, 0)
    setElementData(self.marker, "markerData", {
        title = "Kum Yükleme Noktası",
        desc = "Kamyona kum yüklemek için işaretçiye girin.",
    }, false)
    setElementData(self.marker, "markerIcon", "sanddune", false)

    self.trailerImg = dxCreateTexture("files/images/sand.png", "argb", true, "clamp")

    self.fonts = {}
    self.fonts.percent = exports.TR_dx:getFont(12)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.resetSand = function(...) self:resetSand(...) end
    self.func.onStartExit = function(...) self:onStartExit(...) end

    addEventHandler("onClientMarkerHit", self.marker, self.func.resetSand)
    addEventHandler("onClientVehicleStartExit", root, self.func.onStartExit)

    exports.TR_noti:create("Karda Yolları Temizlemeye Başladın.", "iş", 5)
    self.otherDriver = {}
    local plrName = getPlayerName(localPlayer)
    for i, v in pairs(self.teamFull) do
        if v.name ~= plrName then
            self.otherDriver.player = v.plr
            self.otherDriver.name = v.name
        end
    end

    if self.selectedState == "snowPlow" then
        exports.TR_jobs:createInformation(jobSettings.name, string.format("Angel Pine ve çevresindeki sokaklarda kar temizlemek için sürün. Arkadaşının senin arkanda olduğundan emin ol.\n İş Ortak: %s", self.otherDriver.name or ""))

    elseif self.selectedState == "sand" then
        exports.TR_jobs:createInformation(jobSettings.name, string.format("Tuz serpmek için iş ortağınızdan uygun mesafeyi koruyun. Tuzunuz biter bitmez onu bilgilendirin.\n İş Ortak: %s", self.otherDriver.name or ""), guiInfo.h + 30/zoom)
    end
    exports.TR_jobs:setPaymentTime()
    exports.TR_hud:setRadarCustomLocation(false)

    addEventHandler("onClientRender", root, self.func.render)
    triggerServerEvent("createSnowPlowJobVehicle", resourceRoot, self.selectedState, self.ownedUpgrades[2])

    toggleControl("special_control_left", false)
    toggleControl("special_control_right", false)
    toggleControl("special_control_down", false)
    toggleControl("special_control_up", false)
    return true
end

function SantaJob:onStartExit(plr)
    if plr ~= localPlayer then return end
    if getDistanceBetweenPoints3D(Vector3(getElementPosition(localPlayer)), -2219.28515625, -2326.21875, 30.625) < 30 then return end
    exports.TR_noti:create("Araçtan sadece şirket alanında inebilirsiniz. İş arkadaşınızı iş başında yalnız bırakmak istemezsiniz değil mi?", "error")
end

function SantaJob:resetSand(el, md)
    if el ~= localPlayer or not md then return end
    if self.selectedState == "sand" then
        if self.sand > 0 then
            exports.TR_noti:create("Römorkta hala kum kaldı.", "error")
            return
        end

        triggerServerEvent("giveGroupSnowPlowPayment", resourceRoot, self.teamFull)

        self.sand = self.maxSand
        self.lastSand = self.sand
    else
        exports.TR_noti:create("Traktöre kum yükleyemezsiniz.", "error")
    end
end

function SantaJob:destroy()
    removeEventHandler("onClientRender", root, self.func.render)
    removeEventHandler("onClientMarkerHit", self.marker, self.func.resetSand)
    removeEventHandler("onClientVehicleStartExit", root, self.func.onStartExit)

    triggerServerEvent("removeAttachedObject", resourceRoot, 531)
    triggerServerEvent("removeAttachedObject", resourceRoot, 422)

    toggleControl("enter_exit", true)
    toggleControl("special_control_left", true)
    toggleControl("special_control_right", true)
    toggleControl("special_control_down", true)
    toggleControl("special_control_up", true)

    if isElement(self.trailerImg) then destroyElement(self.trailerImg) end
    if isElement(self.marker) then destroyElement(self.marker) end

    guiInfo.work = nil
    self = nil
end

function SantaJob:render()
    if not isElement(self.otherDriver.player) or not getElementData(self.otherDriver.player, "inJob") then
        exports.TR_jobs:setPlayerJob(nil, nil, nil)
        exports.TR_jobs:removeInformation()

        self:destroy()
        exports.TR_noti:create("İş arkadaşınız işten çıktığı için iş sonlandırıldı.")
        return
    end

    if getDistanceBetweenPoints3D(Vector3(getElementPosition(localPlayer)), -2219.28515625, -2326.21875, 30.625) < 30 then
        toggleControl("enter_exit", true)
    else
        toggleControl("enter_exit", false)
    end

    if self.selectedState == "sand" then
        local veh = getPedOccupiedVehicle(localPlayer)
        if veh then
            if isElement(self.otherDriver.player) and not self.tractor then
                self.tractor = getPedOccupiedVehicle(self.otherDriver.player)
            end

            if self.tractor then
                local dist = getDistanceBetweenPoints3D(Vector3(getElementPosition(veh)), Vector3(getElementPosition(self.tractor)))
                if dist < (self.ownedUpgrades[1] and 25 or 15) then
                    self.isFar = nil

                elseif not self.isFar then
                    self.isFar = true
                    exports.TR_noti:create("İş arkadaşınızdan çok uzaklaştınız. İşe devam etmek için daha yaklaşın.", "error")
                end
            end
        end

        local percent = self.sand/1000
        if self.lastSand > self.sand then
            self.lastSand = math.max(self.lastSand - 100, self.sand)
            percent = self.lastSand/1000
        end

        dxDrawImage(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, self.trailerImg, 0, 0, 0, tocolor(47, 47, 47, 255))
        dxDrawImageSection(guiInfo.x, guiInfo.y + guiInfo.h - guiInfo.h * percent, guiInfo.w, guiInfo.h * percent, 0, 68 - 68 * percent, 128, 68 * percent, self.trailerImg, 0, 0, 0, tocolor(136, 125, 90, 255))

        dxDrawText(string.format("%.1f%%", 100 * percent), guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + guiInfo.h - 5/zoom, tocolor(200, 200, 200, 255), 1/zoom, self.fonts.percent, "center", "bottom")

        if self.sand <= 0 then return end
        if (getTickCount() - self.takeSand)/5000 > 1 and not self.isFar then
            if not veh then return end

            local gear = getVehicleCurrentGear(veh)
            if not gear or  gear < 1 then return end

            self.sand = self.sand - math.min(self:getElementSpeed(veh, 1), 10)

            if self.sand <= 0 then
                self.sand = 0
                exports.TR_noti:create("Aracınızdaki kum bitti. Ortak iş arkadaşınıza haber verin ve yük almak için üsse geri dönün. Birlikte dönebilirsiniz veya sizi bu noktada bekleyebilir.", "info", 15)
                return
            end
            self.takeSand = getTickCount()
        end
    end
end

function SantaJob:givePayment(forced)
    local paymentType = exports.TR_jobs:getPlayerJobPaymentType()
    local payment = self:calculatePayment()
    exports.TR_jobPayments:giveJobPayment(payment, paymentType)

    exports.TR_jobs:setPaymentTime()

    if forced then return end
    triggerServerEvent("givePlayerJobPoints", resourceRoot, getResourceName(getThisResource()))
end

function SantaJob:setElementSpeed(element, unit, speed)
    local unit    = unit or 0
    local speed   = tonumber(speed) or 0
	local acSpeed = getElementSpeed(element, unit)
	if (acSpeed) then
		local diff = speed/acSpeed
		if diff ~= diff then return false end
        local x, y, z = getElementVelocity(element)
		return setElementVelocity(element, x*diff, y*diff, z*diff)
	end

	return false
end

function SantaJob:getElementSpeed(theElement, unit)
	if not isElement(theElement) then return 0 end
    local elementType = getElementType(theElement)
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    return (Vector3(getElementVelocity(theElement)) * mult).length
end

function SantaJob:calculatePayment()
    local addMin, addMax = 0, 0
    for i, v in pairs(jobSettings.upgrades) do
        if self.ownedUpgrades[i] and v.additionalMoney then
            addMin = addMin + v.additionalMoney[1]
            addMax = addMax + v.additionalMoney[2]
        end
    end
    return exports.TR_jobs:getPaymentCount(guiInfo.hourEarning[1] + addMin, guiInfo.hourEarning[2] + addMax)
end

function startJob(...)
    if guiInfo.work then return end
    guiInfo.work = SantaJob:create(...)

    exports.TR_jobs:responseJobWindow()
    exports.TR_jobs:closeJobWindow()
end

function endJob()
    exports.TR_jobs:responseJobWindow()

    if not guiInfo.work then return end
    guiInfo.work:destroy()
end

function giveGroupSnowPlowPayment()
    if not guiInfo.work then return end
    guiInfo.work:givePayment()
end
addEvent("giveGroupSnowPlowPayment", true)
addEventHandler("giveGroupSnowPlowPayment", root, giveGroupSnowPlowPayment)

setVehicleModelWheelSize(531, "rear_axle", 0.8)