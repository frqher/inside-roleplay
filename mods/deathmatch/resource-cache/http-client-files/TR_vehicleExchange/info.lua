local sx, sy = guiGetScreenSize()


local guiInfo = {
    w = 400,
    h = 165,

    distance = 10,
    size = 220,

    high = 1.5,

    tuningNames = {
        ["visual"] = {
            ["speedoColor"] = "Kolor licznika",
            ["glassTint"] = "Przyciemniane szyby",
            ["wheelResize"] = "Poszerzone opony",
            ["wheelTilt"] = "Negatyw",
            ["neon"] = "Neony",
        },

        ["performance"] = {
            ["turbo"] = "Turbo",
            ["distribution"] = "Wałek rozrządu",
            ["piston"] = "Tłoki",
            ["injection"] = "Wtryski paliwa",
            ["intercooler"] = "Intercooler",
            ["clutch"] = "Sprzęgło",
            ["breaking"] = "Tarcze hamulcowe",
            ["breakpad"] = "Klocki hamulcowe",
            ["steering"] = "Układ kierowniczy",
            ["suspension"] = "Zawieszenie",
            ["drivetype"] = "Przełożenie napędu",
        },
    },
}

Info = {}
Info.__index = Info

function Info:create()
    local instance = {}
    setmetatable(instance, Info)
    if instance:constructor() then
        return instance
    end
    return false
end

function Info:constructor()
    self.infos = {}

    self.fonts = {}
    self.fonts.name = exports.TR_dx:getFont(14)
    self.fonts.info = exports.TR_dx:getFont(10)

    self.fontHeight = dxGetFontHeight(1, self.fonts.info)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.updateInfos = function() self:updateInfos() end
    self.func.onRestore = function(...) self:onRestore(...) end

    self:updateInfos()
    setTimer(self.func.updateInfos, 1000, 0)
    addEventHandler("onClientRestore", root, self.func.onRestore)
    addEventHandler("onClientPreRender", root, self.func.render)
    return true
end



function Info:updateInfos()
    local plrPos = Vector3(getElementPosition(localPlayer))

    for i, v in pairs(getElementsByType("vehicle", root, true)) do
        if getDistanceBetweenPoints3D(plrPos, Vector3(getElementPosition(v))) < guiInfo.distance then
            self:createInfo(v)
        else
            self:removeInfo(v)
        end
    end

    for i, v in pairs(self.infos) do
        if not isElement(i) or not isElementStreamedIn(i) or not getElementData(i, "exchangeData") then
            self:removeInfo(i)
        end
    end
end

function Info:createInfo(veh)
    self.infos[veh] = {}
    self:renderTarget(veh)
end

function Info:removeInfo(veh)
    if not self.infos[veh] then return end

    if isElement(self.infos[veh].target) then destroyElement(self.infos[veh].target) end
    self.infos[veh] = nil
end

function Info:renderTarget(veh)
    local id = getElementID(veh) or "vehicle0"
    if not id then return end
    local vehID = tonumber(string.sub(id, 8, string.len(id)))
    if not vehID then return end

    local vehName = self:getVehicleName(veh)
    local exchangeData = getElementData(veh, "exchangeData") or {}
    if exchangeData.price == "nabıyon bilader" then
        self:removeInfo(veh)
        setElementData(veh, "exchangeData", nil)
        return
    end

    local lights = Vector3(getVehicleHeadLightColor(veh))
    local color = {getVehicleColor(veh, true)}
    local upgrades = self:getVehicleUpgrades(veh)
    self.infos[veh].height = self:calculateTextHeight(upgrades, self.fonts.info, 1, guiInfo.w - 20) + guiInfo.h

    if not self.infos[veh].target then
        self.infos[veh].target = dxCreateRenderTarget(guiInfo.w, self.infos[veh].height, true)
    end

    dxSetRenderTarget(self.infos[veh].target)
    self:drawBackground(0, 0, guiInfo.w, self.infos[veh].height, tocolor(17, 17, 17, 255), 4)

    dxDrawText(vehName or "", 0, 5, guiInfo.w, self.infos[veh].height, tocolor(240, 196, 55, 255), 1, self.fonts.name, "center", "top")

    dxDrawText(string.format("Araç UID'si: %d", vehID or ""), 10, 30, guiInfo.w, self.infos[veh].height, tocolor(170, 170, 170, 255), 1, self.fonts.info, "left", "top")
    dxDrawText(string.format("Kurs: %.2fkm", exchangeData.mileage or 0.26), 10, 45, guiInfo.w, self.infos[veh].height, tocolor(170, 170, 170, 255), 1, self.fonts.info, "left", "top")
    dxDrawText(string.format("Motor: %s", exchangeData.engineCapacity or "ERROR"), 10, 60, guiInfo.w, self.infos[veh].height, tocolor(170, 170, 170, 255), 1, self.fonts.info, "left", "top")

    dxDrawText("Kolor:", 10, 75, guiInfo.w, self.infos[veh].height, tocolor(170, 170, 170, 255), 1, self.fonts.info, "left", "top")
    dxDrawRectangle(55, 79, 10, 10, tocolor(color[1], color[2], color[3], 255))
    dxDrawRectangle(67, 79, 10, 10, tocolor(color[4], color[5], color[6], 255))
    dxDrawRectangle(79, 79, 10, 10, tocolor(color[7], color[8], color[9], 255))
    dxDrawRectangle(91, 79, 10, 10, tocolor(color[10], color[11], color[12], 255))

    dxDrawText("Światła:", 10, 90, guiInfo.w, self.infos[veh].height, tocolor(170, 170, 170, 255), 1, self.fonts.info, "left", "top")
    dxDrawRectangle(67, 94, 10, 10, tocolor(lights.x, lights.y, lights.z, 255))

    dxDrawText(string.format("İyileştirme: %s", upgrades), 10, 105, guiInfo.w - 10, self.infos[veh].height - 10, tocolor(170, 170, 170, 255), 1, self.fonts.info, "left", "top", true, true)


    dxDrawText(string.format("$%.2f", exchangeData.price or 0), 10, 45, guiInfo.w - 10, self.infos[veh].height - 30, tocolor(240, 196, 55, 255), 1, self.fonts.name, "center", "bottom")
    dxDrawText(string.format("Satıcı: %s", exchangeData.owner or "Ktoś"), 10, 45, guiInfo.w - 10, self.infos[veh].height - 10, tocolor(170, 170, 170, 255), 1, self.fonts.info, "center", "bottom")

    dxSetRenderTarget()
end

function Info:render(target)
    local camPos = Vector3(getCameraMatrix())
    for i, v in pairs(self.infos) do
        local pos = Vector3(getElementPosition(i))
        local x0, y0, z0, x1, y1, z1 = getElementBoundingBox(i)
        pos.z = pos.z + z1/3

        if isLineOfSightClear(camPos, pos, true, false, false, true, true, false, false) and getElementData(i, "exchangeData")  then
            dxDrawMaterialLine3D(pos.x, pos.y, pos.z + guiInfo.high + v.height/guiInfo.size/2, pos.x, pos.y, pos.z + guiInfo.high - v.height/guiInfo.size/2, v.target, guiInfo.w/guiInfo.size)
        end
    end
end

function Info:getVisualUpgrades(veh)
    local visualTuning = getElementData(veh, "visualTuning")
    if not visualTuning then return "" end
    if type(visualTuning) ~= "table" then return "" end

    local upgrades = ""
    for i, v in pairs(visualTuning) do
        if i ~= "engineCapacity" then
            upgrades = string.format("%s%s, ", upgrades, guiInfo.tuningNames.visual[i])
        end
    end
    return upgrades
end

function Info:getPerformanceUpgrades(veh)
    local performanceTuning = getElementData(veh, "performanceTuning")
    if not performanceTuning then return "" end
    if type(performanceTuning) ~= "table" then return "" end

    local upgrades = ""
    for i, v in pairs(performanceTuning) do
        if i ~= "engineCapacity" then
            upgrades = string.format("%s%s (%s), ", upgrades, guiInfo.tuningNames.performance[i], self:getUpgradeName(i, v))
        end
    end

    return upgrades
end

function Info:getUpgradeName(name, value)
    local customUpgrades = exports.TR_tuning:getCustomUpgrades()
    local newName = name

    for i, v in pairs(customUpgrades[name]) do
        if tostring(v.value) == tostring(value) then
            newName = v.name
            break
        end
    end

    return newName
end

function Info:getVehicleUpgrades(veh)
    local upgrades = ""
    for i, v in pairs(getVehicleUpgrades(veh)) do
        upgrades = string.format("%s%s, ", upgrades, VehicleUpgrades[v-999])
    end

    local fullUpgrades = upgrades
    local visualUpgrades = self:getVisualUpgrades(veh)
    fullUpgrades = fullUpgrades .. visualUpgrades
    local performanceUpgrades = self:getPerformanceUpgrades(veh)
    fullUpgrades = fullUpgrades .. performanceUpgrades
    return string.sub(fullUpgrades, 0, string.len(fullUpgrades) - 2)
end



function Info:getVehicleName(veh)
    local model = getElementModel(veh)
    if model == 471 then return "Snowmobile" end
    if model == 604 then return "Christmas Manana" end
    return getVehicleNameFromModel(model)
end

function Info:onRestore(cleared)
    for i, v in pairs(self.infos) do
        self:renderTarget(i)
    end
end

function Info:drawBackground(x, y, rx, ry, color, radius, post)
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

function Info:calculateTextHeight(text, font, fontSize, rectangeWidth)
	local line_text = ""
	local line_count = 1

	for word in text:gmatch("%S+") do
		local temp_line_text = line_text .. " " .. word

		local temp_line_width = dxGetTextWidth(temp_line_text, fontSize, font)
		if temp_line_width >= rectangeWidth then
			line_text = word
			line_count = line_count + 1
		else
			line_text = temp_line_text
		end
	end

	return line_count * self.fontHeight
end


guiInfo.info = Info:create()