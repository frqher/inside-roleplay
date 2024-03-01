local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 500/zoom)/2,
    y = sy - 120/zoom,
    h = 100/zoom,
    w = 500/zoom,
}

InteriorSystem = {}
InteriorSystem.__index = InteriorSystem

function InteriorSystem:create()
    local instance = {}
    setmetatable(instance, InteriorSystem)
    if instance:constructor() then
        return instance
    end
    return false
end

function InteriorSystem:constructor()
    self.alpha = 0

    self.fonts = {}
    self.fonts.title = exports.TR_dx:getFont(16)
    self.fonts.desc = exports.TR_dx:getFont(11)
    self.fonts.small = exports.TR_dx:getFont(10)

    self.func = {}
    self.func.markerHit = function(...) self:markerHit(...) end
    self.func.markerLeave = function(...) self:markerLeave(...) end
    self.func.render = function(...) self:render(...) end
    self.func.useInterior = function(...) self:useInterior(...) end

    addEventHandler("onClientMarkerHit", resourceRoot, self.func.markerHit)
    addEventHandler("onClientMarkerLeave", resourceRoot, self.func.markerLeave)
    return true
end

function InteriorSystem:open(...)
    self.opened = true
    exports.TR_dx:setOpenGUI(true)

    self.state = "show"
    self.tick = getTickCount()
    self.alpha = 0

    local icon = getElementData(arg[1], "markerIcon")
    local data = getElementData(arg[1], "markerData")
    self.marker = arg[1]
    self.icon, self.isExit = self:prepareIconText(icon)
    self.data = data and {data.title, data.desc, data.noCollisions} or exports.TR_markers:getMarkerDataByIcon(icon)
    self.noCollisions = self.data[3] or false

    self.time = getElementData(arg[1], "interiorTime")
    self.color = Vector3(getMarkerColor(arg[1]))
    self.hexColor = self:rgbToHex({self.color.x, self.color.y, self.color.z})

    if not self.handler then
        addEventHandler("onClientRender", root, self.func.render)
        self.handler = true
    end
    bindKey("e", "down", self.func.useInterior)
end

function InteriorSystem:close()
    self.opened = false
    if not exports.TR_tutorial:isTutorialOpen() then exports.TR_dx:setOpenGUI(false) end

    self.state = "hide"
    self.tick = getTickCount()
    self.alpha = 1

    unbindKey("e", "down", self.func.useInterior)
    exports.TR_interaction:rebuildKey()
end



function InteriorSystem:animate()
    if self.state == "show" then
        local progress = (getTickCount() - self.tick)/600
        self.alpha = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "InOutQuad")

        if progress >= 1 then
            self.tick = getTickCount()
            self.alpha = 1
            self.state = "showed"
        end

    elseif self.state == "hide" then
        local progress = (getTickCount() - self.tick)/400
        self.alpha = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "InOutQuad")

        if progress >= 1 then
            self.tick = nil
            self.alpha = 0
            self.state = nil

            self.marker, self.icon, self.isExit, self.data, self.color, self.hexColor = nil, nil, nil, nil, nil, nil
            self.handler = false
            removeEventHandler("onClientRender", root, self.func.render)
        end
    end
end

function InteriorSystem:render()
    self:animate()
    if not self.icon then return end
    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 5)
    dxDrawImage(guiInfo.x + 20/zoom, guiInfo.y + 20/zoom, guiInfo.h - 40/zoom, guiInfo.h - 40/zoom, string.format(":TR_markers/files/images/%s.png", self.icon), 0, 0, 0, tocolor(self.color.x, self.color.y, self.color.z, 255 * self.alpha))

    dxDrawText(string.format("#aaaaaaGirmek için #%sE #aaaaaaa tuşuna bas.", self.hexColor, self.isExit and "Dışarı çık" or "İçeri gir"), guiInfo.x + guiInfo.h, guiInfo.y + 20/zoom, guiInfo.h - 40/zoom, guiInfo.y + guiInfo.h - 10/zoom, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.small, "left", "bottom", false, false, false, true)
    if self.data then
        if self.data[1] then dxDrawText(self.data[1], guiInfo.x + guiInfo.h, guiInfo.y + 10/zoom, guiInfo.h - 40/zoom, guiInfo.y + guiInfo.h - 10/zoom, tocolor(self.color.x, self.color.y, self.color.z, 255 * self.alpha), 1/zoom, self.fonts.title, "left", "top") end
        if self.data[2] then dxDrawText(self.data[2], guiInfo.x + guiInfo.h, guiInfo.y + 40/zoom, guiInfo.h - 40/zoom, guiInfo.y + guiInfo.h - 10/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.desc, "left", "top") end
    end
end



function InteriorSystem:useInterior()
    if isElement(getElementData(localPlayer, "cuffedBy")) then return end

    if self.time then
        local time = getRealTime()
        if time.hour <= self.time[1] and time.hour >= self.time[2] then
            exports.TR_noti:create("Kapı kilitli.", "error")
            return
        end
    end
    local time = math.random(3, 5)
    if self.isExit then
        exports.TR_dx:showLoading(time * 1000, "Yükleniyor..")
    else
        exports.TR_dx:showLoading(time * 1000, "Mekan yükleniyor..")
    end

    setTimer(function()
        setElementFrozen(localPlayer, false)
    end, time * 1000, 1)

    setElementFrozen(localPlayer, true)
    unbindKey("e", "down", self.func.useInterior)

    setTimer(function()
        if isTimer(self.blockCollisionTimer) then killTimer(self.blockCollisionTimer) end
        self:setCollisions(false)

        exports.TR_tutorial:setNextState()

        local checkCustomInside = false

        if self.isExit then
            local id = getElementData(self.marker, "interiorID")
            local data = interiors[id].exit

            if data.int == 0 and data.dim == 0 then
                exports.TR_weather:setCustomWeather(0, 12, 0, 9999)
                exports.TR_hud:setRadarCustomLocation("Bina | "..data.title, true)
            else
                checkCustomInside = true
            end
        else
            exports.TR_weather:setCustomWeather(0, 12, 0, 9999)
            exports.TR_hud:setRadarCustomLocation("Bina | "..self.data[1], true)
        end
        triggerServerEvent("interiorUse", resourceRoot, self.marker, self.isExit, self.time and true or false, time)

        if not self.isExit and self.noCollisions then
            self:setCollisions(false)
        else
            self:setCollisions(true)
        end

        setTimer(function()
            if checkCustomInside then
                local data = getInteriorData()
                if data then
                    exports.TR_weather:setCustomWeather(0, 12, 0, 9999)
                    exports.TR_hud:setRadarCustomLocation("Bina | "..data.title, true)
                else
                    exports.TR_weather:setCustomWeather(false)
                    exports.TR_hud:setRadarCustomLocation(false)
                end
            end
        end, (time * 1000) - 1000, 1)
    end, 500, 1)
end

function InteriorSystem:setCollisions(state)
    setElementData(localPlayer, "blockCollisions", not state)
end

function InteriorSystem:markerHit(...)
    if not arg[1] or not arg[2] then return end
    if arg[1] ~= localPlayer then return end
    if not getElementData(localPlayer, "characterUID") then return end
    if self.opened then return end

    local isTutorial = exports.TR_tutorial:isTutorialOpen()
    if isTutorial then
        if isTutorial ~= 13 and isTutorial ~= 18 then return end
    else
        if not exports.TR_dx:canOpenGUI() then return end
    end

    if getPedOccupiedVehicle(localPlayer) then return end
    local markerPos = Vector3(getElementPosition(source))
    local playerPos = Vector3(getElementPosition(localPlayer))
    if playerPos.z < markerPos.z - 0.5 or playerPos.z > markerPos.z + 2 then return end

    if isElement(getElementData(localPlayer, "cuffedBy")) then return end
    self:open(source)
end

function InteriorSystem:markerLeave(...)
    if not arg[1] or not arg[2] then return end
    if arg[1] ~= localPlayer then return end
    if not self.opened then return end

    self:close()
end

-- Utils
function InteriorSystem:drawBackground(x, y, rx, ry, color, radius, post)
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

function InteriorSystem:prepareIconText(...)
    if string.find(arg[1], "-") then
        local icon = split(arg[1], "-")
        return icon[1], self:isMarkerExit(icon[2])
    end
    return arg[1], false
end

function InteriorSystem:isMarkerExit(icon)
    if icon == "exit" or icon == "exitInt" then return true end
    return false
end

function InteriorSystem:rgbToHex(rgb)
	local hexadecimal = ''
	for key, value in pairs(rgb) do
		local hex = ''
		while(value > 0)do
			local index = math.fmod(value, 16) + 1
			value = math.floor(value / 16)
			hex = string.sub('0123456789ABCDEF', index, index) .. hex
		end
		if(string.len(hex) == 0)then
			hex = '00'
		elseif(string.len(hex) == 1)then
			hex = '0' .. hex
		end
		hexadecimal = hexadecimal .. hex
	end
	return hexadecimal
end

guiInfo.interiors = InteriorSystem:create()



function setInteriorLoading(text, time)
    exports.TR_dx:showLoading(time * 1000, text)
end
addEvent("setInteriorLoading", true)
addEventHandler("setInteriorLoading", root, setInteriorLoading)


function getInteriorData(x, y, z, i, d)
    local cDist, data = 100000, false
    local pos = x and Vector3(x, y, z) or Vector3(getElementPosition(localPlayer))
    local int = i and i or getElementInterior(localPlayer)
    local dim = d and d or getElementDimension(localPlayer)

    for i, v in pairs(interiors) do
        if(not v.exit) then iprint("Hatalı Interior !", v) end
        if int == v.exit.int and dim == v.exit.dim then
            local dist = getDistanceBetweenPoints3D(pos, v.exit.pos)
            if dist < cDist then
                local markerData = exports.TR_markers:getMarkerDataByIcon(v.icon)

                cDist = dist
                data = v.data and v.data or {title = markerData[1], desc = markerData[2]}
            end
        end
    end

    if not data then return false end
    if data then
        exports.TR_weather:setCustomWeather(0, 12, 0, 9999)
    end
    return data
end

function getExitPosFromNearestInterior(x, y, z, i, d)
    local cDist, data = 100000, false
    local pos = x and Vector3(x, y, z) or Vector3(getElementPosition(localPlayer))
    local int = i and i or getElementInterior(localPlayer)
    local dim = d and d or getElementDimension(localPlayer)

    for i, v in pairs(interiors) do
        if int == v.exit.int and dim == v.exit.dim then
            local dist = getDistanceBetweenPoints3D(pos, v.exit.pos)
            if dist < cDist then
                data = {v.enter.pos.x, v.enter.pos.y, v.enter.pos.z}
            end
        end
    end
    return data
end