local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local bx, by, bz, ax, ay, az = 168, 135, 84, 136, 91, 61
local guiInfo = {
    x = (sx - 350/zoom)/2,
    y = 100/zoom,
    w = 350/zoom,
    h = 84/zoom,

    weatherDetails = {
        {"Açık hava", "sun"}, -- LS
        {"Kapalı hava", "sun"},
        {"Kapalı hava", "cloud"},
        {"Dağınık bulutlar", "cloud"}, -- LS
        {"Kapalı hava", "cloud"},
        {"Dağınık bulutlar", "cloud"}, -- SF
        {"Açık hava", "sun"}, -- SF
        {"Ağır bulut örtüsü", "fullCloud"}, -- LS SF
        {"Yağmurlu", "rain"}, -- LS
        {"Çok sisli", "fullCloud"}, -- SF
        {"Kapalı hava", "cloud"},
        {"Kapalı hava", "sun"},
        {"Ağır bulut örtüsü", "fullCloud"}, -- LV
        {"Kapalı hava", "sun"},
        {"Kapalı hava", "sun"},
        {"Kar yağışı", "snow"},
        {"Fırtına", "lightning"}, -- LS
        {"Açık hava", "sun"}, -- LV
        {"Dağınık bulutlar", "cloud"}, -- LV
        {"Bir kum fırtınası", "lightning"}, -- LV
    },

    nightIntense = 100,
}

WeatherSystem = {}
WeatherSystem.__index = WeatherSystem

function WeatherSystem:create(...)
    local instance = {}
    setmetatable(instance, WeatherSystem)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function WeatherSystem:constructor(...)
    self.currentWeather = false
    self.alpha = 0
    self.lastZone = false

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(20)
    self.fonts.text = exports.TR_dx:getFont(14)

    self.func = {}
    self.func.check = function() self:setWeather() end
    self.func.render = function() self:render() end

    addEventHandler("onClientRender", root, self.func.render)
    setTimer(function() self:update() end, 1000, 0)

    self:update()

    self.renderTarget = dxCreateRenderTarget(84, 64, true)
    self.mask = dxCreateShader("files/shaders/hud_mask.fx")
    self.maskImg = dxCreateTexture("files/images/bg.png", "argb", true, "clamp")
    dxSetShaderValue(self.mask, "sPicTexture", self.renderTarget)
    dxSetShaderValue(self.mask, "sMaskTexture", self.maskImg)

    -- Snow
    exports.TR_mountChiliad:loadCustom()
    createChristmassTrees()
    return true
end

function WeatherSystem:getWeatherInZone(...)
    -- if exports.TR_shaders:isShaderActive() then
    --     local time = getRealTime()
    --     if time.hour
    --     retrun
    -- end
    if self.weathers then
        if self.weathers[arg[1]] then
            return self.weathers[arg[1]]
        end
    end
    return false
end

function WeatherSystem:render()
    if self.blendWeather then
        local curHour, curMinute = self:getDayTime()

        self.blendWeather[2] = self.blendWeather[2] + 1
        if self.blendWeather[2] >= 60 then
            self.blendWeather[2] = self.blendWeather[2] - 60
            self.blendWeather[1] = self.blendWeather[1] + 1
        end
        self.blendWeather[3] = self.blendWeather[3] + 1

        if self.blendWeather[3] >= 60 then
            self.blendWeather = nil
            setTime(curHour, curMinute)
            setWeather(self.currentWeather)
            if self.currentWeather == 8 then
                setRainLevel(0.2)
            else
                setRainLevel(0)
            end
        else
            setTime(self.blendWeather[1] > 24 and self.blendWeather[1] - 24 or self.blendWeather[1], self.blendWeather[2])
        end
    end

    if self.state then
        local progress = (getTickCount() - self.tick)/500
        if self.state == "showing" then
            self.alpha = interpolateBetween(self.lastAlpha, 0, 0, 1, 0, 0, progress, "Linear")

            if progress >= 1 then
                self.alpha = 1
                self.tick = getTickCount()
                self.state = "showed"
            end

        elseif self.state == "showed" then
            progress = (getTickCount() - self.tick)/5000
            if progress >= 1 then
                self.tick = getTickCount()
                self.state = "hidding"
                self.lastAlpha = 1
                progress = 0
            end

        elseif self.state == "hidding" then
            self.alpha = interpolateBetween(self.lastAlpha, 0, 0, 0, 0, 0, progress, "Linear")

            if progress >= 1 then
                self.alpha = 0
                self.tick = nil
                self.state = nil
                self.info = nil
                return
            end
        end

        if self.state == "showing" then
            dxSetRenderTarget(self.renderTarget, true)
            dxDrawImage(85 - progress * 74, 1, 64, 64, string.format("files/images/%s.png", self.info.texture), 0, 0, 0, tocolor(0, 0, 0, 255))
            dxDrawImage(84 - progress * 74, 0, 64, 64, string.format("files/images/%s.png", self.info.texture))
            dxSetRenderTarget()

            dxDrawImage(guiInfo.x, guiInfo.y + 10/zoom, 84/zoom, 64/zoom, self.mask, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))

        elseif self.state == "showed" then
            dxSetRenderTarget(self.renderTarget, true)
            dxDrawImage(11, 1, 64, 64, string.format("files/images/%s.png", self.info.texture), 0, 0, 0, tocolor(0, 0, 0, 255))
            dxDrawImage(10, 0, 64, 64, string.format("files/images/%s.png", self.info.texture))
            dxSetRenderTarget()

            dxDrawImage(guiInfo.x, guiInfo.y + 10/zoom, 84/zoom, 64/zoom, self.mask, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))

        elseif self.state == "hidding" then
            dxSetRenderTarget(self.renderTarget, true)
            dxDrawImage(11 - progress * 74, 1, 64, 64, string.format("files/images/%s.png", self.info.texture), 0, 0, 0, tocolor(0, 0, 0, 255))
            dxDrawImage(10 - progress * 74, 0, 64, 64, string.format("files/images/%s.png", self.info.texture))
            dxSetRenderTarget()

            dxDrawImage(guiInfo.x, guiInfo.y + 10/zoom, 84/zoom, 64/zoom, self.mask, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
        end

        dxDrawText(self.info.zone, guiInfo.x + guiInfo.h + 6/zoom, guiInfo.y + 14/zoom, guiInfo.x + guiInfo.w, guiInfo.y, tocolor(0, 0, 0, 150 * self.alpha), 1/zoom, self.fonts.main, "left", "top")
        dxDrawText(self.info.zone, guiInfo.x + guiInfo.h + 5/zoom, guiInfo.y + 13/zoom, guiInfo.x + guiInfo.w, guiInfo.y, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "left", "top")

        dxDrawText(self.info.text, guiInfo.x + guiInfo.h + 6/zoom, guiInfo.y + 6/zoom, guiInfo.x + guiInfo.w, guiInfo.y + guiInfo.h - 17/zoom, tocolor(0, 0, 0, 150 * self.alpha), 1/zoom, self.fonts.text, "left", "bottom")
        dxDrawText(self.info.text, guiInfo.x + guiInfo.h + 5/zoom, guiInfo.y + 5/zoom, guiInfo.x + guiInfo.w, guiInfo.y + guiInfo.h - 18/zoom, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.text, "left", "bottom")
    end
end

function WeatherSystem:update()
    if self.customWeather then return end
    local h, m = getTime()
    local curHour, curMinute = self:getDayTime()

    local zone = getZoneName(Vector3(getElementPosition(localPlayer)), true)

    local weatherID = self:getWeatherInZone(zone)
    if not weatherID then return end

    local forceInfo = false
    if self.currentWeather ~= weatherID and not self.info then
        local hb, hl = self:getHourBefore()

        setTime(hb, curMinute)
        setWeatherBlended(weatherID)
        setTime(hl, curMinute)

        self.blendWeather = {hl, curMinute, 0}
        self.currentWeather = weatherID
        forceInfo = true
    end

    if ((zone ~= self.lastZone or self.currentWeather ~= weatherID) and not self.info) or forceInfo then
        self:animateWeatherChange(weatherID, zone)
        self.lastZone = zone

    elseif ((zone ~= self.lastZone or self.currentWeather ~= weatherID) and self.info) or forceInfo then
        if self.state ~= "hidding" then
            self.tick = getTickCount()
            self.state = "hidding"
            self.lastAlpha = self.alpha
        end
    end

    if not self.blendWeather then
        if h ~= curHour or m ~= curMinute then
            setTime(curHour, curMinute)
        end
    end

    self:updateNight()

    if self.currentWeather ~= weatherID then end
    self:setSnow()
end

function WeatherSystem:getHourBefore()
    local curHour, curMinute = self:getDayTime()
    if curHour < 1 then return math.abs(curHour - 24) - 2, math.abs(curHour - 24) - 1 end
    if curHour < 2 then return 0, 1 end
    return curHour - 2, curHour - 1
end

function WeatherSystem:getDayTime()
    local time = getRealTime()
    return time.hour, time.minute
end

function WeatherSystem:setSnow(...)
    if isInsideColShape(snowZone, Vector3(getElementPosition(localPlayer))) and getElementInterior(localPlayer) == 0 and getElementDimension(localPlayer) == 0 then
        if not self.snow then
            self.snow = true
            createSnow()
            exports.TR_mountChiliad:loadCustom()
        end
    else
        self.snow = nil
        removeSnow()
        exports.TR_mountChiliad:unloadCustom()
    end
end

function WeatherSystem:animateWeatherChange(weatherID, zone)
    if self.info then
        if isElement(self.info.maskImg) then destroyElement(self.info.maskImg) end
        if isElement(self.info.mask) then destroyElement(self.info.mask) end
    end

    self.state = "showing"
    self.tick = getTickCount()
    self.lastAlpha = self.alpha

    local text, texture = self:getWeatherDetails(weatherID)
    self.info = {
        text = text,
        zone = zone,
        texture = texture,
    }

    local zoneW = dxGetTextWidth(zone, 1/zoom, self.fonts.main) + 84/zoom
    local textW = dxGetTextWidth(text, 1/zoom, self.fonts.text) + 84/zoom
    guiInfo.w = (textW > zoneW and textW or zoneW) + 15/zoom
    guiInfo.x = (sx - guiInfo.w)/2
end

function WeatherSystem:setCustomWeather(...)
    self.customWeather = arg[1]
    if self.customWeather then
        setWeather(self.customWeather)
        self.currentWeather = arg[1]
        if arg[2] and arg[3] then setTime(arg[2], arg[3]) end
        if arg[4] then setMinuteDuration(arg[4]) end
    else
        self:update()
    end
end

function WeatherSystem:updateTime(...)
    setTime(arg[1], arg[2])
end

function WeatherSystem:updateWeather(...)
    self.weathers = arg[1]
end

function WeatherSystem:getWeatherDetails(weatherID)
    return unpack(guiInfo.weatherDetails[weatherID + 1])
end

function WeatherSystem:drawBackground(x, y, rx, ry, color, radius, post)
    rx = rx - radius * 2
    ry = ry - radius * 2
    x = x + radius
    y = y + radius

    if (rx >= 0) and (ry >= 0) then
        dxDrawRectangle(x, y, rx, ry, color, post)
        dxDrawRectangle(x, y - radius, rx, radius, color, post)
        dxDrawRectangle(x, y + ry, rx, radius, color, post)
        dxDrawRectangle(x - radius, y, radius, ry, color, post)
        dxDrawRectangle(x + rx, y, radius, ry, color, post)

        dxDrawCircle(x, y, radius, 180, 270, color, color, 7, 1, post)
        dxDrawCircle(x + rx, y, radius, 270, 360, color, color, 7, 1, post)
        dxDrawCircle(x + rx, y + ry, radius, 0, 90, color, color, 7, 1, post)
        dxDrawCircle(x, y + ry, radius, 90, 180, color, color, 7, 1, post)
    end
end

function WeatherSystem:updateNight()
    if not self.realisticNight then return end
    local h, m = getTime()
	local th = h + (m /60)
	local tm = m + (h * 60)
	if ((th >= 20) and (th <=23)) then
		if (th <=23) then
			setSkyGradient(clr(bx, th), clr(by, th), clr(bz, th), clr(ax, th), clr(ay, th), clr(az, th))
		end
		if ((th >= 21) and (th <=23)) then
			setFogDistance(-guiInfo.nightIntense + (guiInfo.nightIntense/120 * (1380 - tm)))
		end
	elseif (((th > 23) and (th <=24)) or ((th >= 0) and (th <2))) then
		setFogDistance(-guiInfo.nightIntense)
		setSkyGradient(0, 0, 0, 0, 0, 0)
	elseif ((th >=2) and (th <= 5)) then
		setSkyGradient(uclr(bx/10, h), uclr(by/10, th), uclr(bz/10, th), uclr(ax/10, th), uclr(ay/10, th), uclr(az/10, th))
		setFogDistance(-guiInfo.nightIntense + (guiInfo.nightIntense/180 * (tm-120)))
	end
	if ((th > 5) and (th < 20)) then
        resetSkyGradient()
        resetFogDistance()
	end
end

function WeatherSystem:setRealisticNight(state)
    self.realisticNight = state

    if self.realisticNight then
        self:updateNight()
    else
        resetSkyGradient()
        resetFogDistance()
    end
end



local weather
function createWeather(data)
    weather = WeatherSystem:create(data)
end

function updateWeather(data, hour, minute, interval)
    if not weather then
        weather = WeatherSystem:create()
    end
    weather:updateWeather(data)

    if hour then weather:updateTime(hour, minute, interval) end
end
addEvent("updateWeatherData", true)
addEventHandler("updateWeatherData", root, updateWeather)

function setCustomWeather(weatherID, hour, minute)
    if not weather then return end
    weather:setCustomWeather(weatherID, hour, minute)
end

function setRealisticNight(enabled)
    exports.TR_dashboard:setDashboardResponseShader()

    if not weather then return end
    weather:setRealisticNight(enabled)
    return true
end

function clr(a, t)
	return (a - (a*(t-20)/3))
end

function uclr(a, t)
	return (a*(t-2)/3)
end

setWeather(0)
setFogDistance(0)
resetSkyGradient()

if getElementData(localPlayer, "characterUID") then createWeather() end