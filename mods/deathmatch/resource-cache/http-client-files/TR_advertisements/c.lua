local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 900/zoom)/2,
    y = 0,
    w = 900/zoom,
    h = 70/zoom,

    radioPositions = {
        {
            pos = Vector3(1525.7585449219, -2228.9177246094, 92.678314208984),
            int = 0,
            dim = 15,
        },
    },
}

Advertisements = {}
Advertisements.__index = Advertisements

function Advertisements:create()
    local instance = {}
    setmetatable(instance, Advertisements)
    if instance:constructor() then
        return instance
    end
    return false
end

function Advertisements:constructor()
    self.alpha = 0

    self.fonts = {}
    self.fonts.sender = exports.TR_dx:getFont(12)
    self.fonts.text = exports.TR_dx:getFont(12)

    self.func = {}
    self.func.render = function() self:render() end
    addEventHandler("onClientRender", root, self.func.render, false, "low-9")

    return true
end

function Advertisements:open(sender, text)
    if self.blocked then return end
    if not getElementData(localPlayer, "characterUID") then return end

    self.alpha = 0
    self.tick = getTickCount()
    self.state = "opening"

    self.messageTick = getTickCount()

    self.senderPlayer = getPlayerFromName(sender)
    if self.senderPlayer then
        local id = getElementData(self.senderPlayer, "ID")
        if id then
            self.sender = string.format("[%d] %s duyurur:", id, sender)
        else
            self.sender = sender .. " duyurur:"
        end
    else
        self.sender = sender .. " duyurur:"
    end
    self.text = text

    local sender = dxGetTextWidth(self.sender, 1/zoom, self.fonts.text) + 20/zoom
    guiInfo.w = math.min(dxGetTextWidth(text, 1/zoom, self.fonts.text) + 20/zoom, 900/zoom)
    guiInfo.w = math.max(sender, guiInfo.w)
    guiInfo.x = (sx - guiInfo.w)/2

    local h = self:calculateRows(self.text, self.fonts.text, 1/zoom, guiInfo.w)
    guiInfo.h = h * 20/zoom + 30/zoom
end

function Advertisements:close()
    self.alpha = 1
    self.tick = getTickCount()
    self.state = "closing"

    self.messageTick = nil
end

function Advertisements:animate()
    if not self.tick then return end
    local progress = (getTickCount() - self.tick)/500

    if self.state == "opening" then
      self.alpha = interpolateBetween(self.alpha, 0, 0, 1, 0, 0, progress, "Linear")
      if progress >= 1 then
        self.alpha = 1
        self.state = "opened"
        self.tick = nil
      end

    elseif self.state == "closing" then
      self.alpha = interpolateBetween(self.alpha, 0, 0, 0, 0, 0, progress, "Linear")
      if progress >= 1 then
        self.alpha = 0
        self.state = "closed"
        self.tick = nil

        self.sender = nil
        return true
      end
    end
end

function Advertisements:checkTime()
    if not self.messageTick then return end
    local progress = (getTickCount() - self.messageTick)/10000

    if progress >= 1 then
        self:close()
    end
end

function Advertisements:render()
    if not self.sender then return end
    if self:animate() then return end
    self:checkTime()
    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 4)
    dxDrawText(self.sender, guiInfo.x + 10/zoom, guiInfo.y + 2/zoom, guiInfo.x + guiInfo.w, guiInfo.h, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.sender, "left", "top")
    dxDrawText(self.text, guiInfo.x + 10/zoom, guiInfo.y + 22/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.text, "left", "top", true, true)
end


function Advertisements:block(state)
    self.blocked = state
    exports.TR_dashboard:setDashboardResponseShader()
end


function Advertisements:drawBackground(x, y, rx, ry, color, radius, post)
    rx = rx - radius * 2
    ry = ry - radius * 2
    x = x + radius
    y = y + radius

    if (rx >= 0) and (ry >= 0) then
        dxDrawRectangle(x - radius, y - radius, rx + radius * 2, ry + radius, color, post)
        dxDrawRectangle(x, y + ry, rx, radius, color, post)

        dxDrawCircle(x + rx, y + ry, radius, 0, 90, color, color, 7, 1, post)
        dxDrawCircle(x, y + ry, radius, 90, 180, color, color, 7, 1, post)
    end
end

function Advertisements:calculateRows(text, font, fontSize, rectangeWidth)
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

	return line_count
end


local system = Advertisements:create()

function openAdvert(...)
    system:open(...)
end
addEvent("openAdvert", true)
addEventHandler("openAdvert", root, openAdvert)

function block(state)
    system:block(state)
end

function isPlayerInRadio()
    local pos = Vector3(getElementPosition(localPlayer))
    local int = getElementInterior(localPlayer)
    local dim = getElementDimension(localPlayer)

    for i, v in pairs(guiInfo.radioPositions) do
        if v.int == int and v.dim == dim then
            if getDistanceBetweenPoints3D(pos, v.pos) <= 5 then
                return true
            end
        end
    end
    return false
end