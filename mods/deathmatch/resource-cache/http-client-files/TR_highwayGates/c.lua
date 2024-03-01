local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 530/zoom)/2,
    y = (sy - 210/zoom)/2,
    w = 530/zoom,
    h = 210/zoom,

    texts = {
        private = "Karşıya geçmek için ödeme yapmanız gerekiyor.\n#d4af37$50.",
        public = "San Andreas Şehirlerarası Otoyoluna hoş geldiniz.",
    },
}

HighwayGate = {}
HighwayGate.__index = HighwayGate

function HighwayGate:create()
    local instance = {}
    setmetatable(instance, HighwayGate)
    if instance:constructor() then
        return instance
    end
    return false
end

function HighwayGate:constructor()
    self.func = {}
    self.func.open = function() self:open() end
    self.func.render = function() self:render() end
    self.func.colShapeHit = function(...) self:colShapeHit(source, ...) end
    self.func.colShapeLeave = function(...) self:colShapeLeave(...) end
    self.func.onButtonClick = function(...) self:onButtonClick(...) end
    self.func.onReponse = function(...) self:onReponse(...) end

    self:createCols()
    addEvent("responseTollGate", true)
    addEventHandler("responseTollGate", root, self.func.onReponse)
    return true
end

function HighwayGate:createCols()
    self.cols = {}
    for i, v in pairs(positions) do
        local x, y, z = self:getPosition(v.positions.gate, Vector3(v.positions.gate[4], v.positions.gate[5], v.positions.gate[6]), (v.flipped and Vector3(0, 4.5, 4) or Vector3(0, -4.5, 4)))
        local sphere = createColSphere(x, y, z, 3)
        setElementData(sphere, "tollID", i, false)

        local marker = createMarker(x, y, z - 0.55, "cylinder", 1, 249, 161, 91, 0)
        setElementData(marker, "markerIcon", "tollRoad", false)
        setElementData(marker, "markerData", {
            title = "Otoyol kapıları",
            desc = "Kapılardan geçmek için dur.",
        }, false)
    end

    addEventHandler("onClientColShapeHit", resourceRoot, self.func.colShapeHit)
    addEventHandler("onClientColShapeLeave", resourceRoot, self.func.colShapeLeave)
end

function HighwayGate:colShapeHit(source, el, md)
    if el ~= localPlayer or not md then return end

    self.tollID = getElementData(source, "tollID")
    self:open()
end

function HighwayGate:colShapeLeave(el, md)
    if el ~= localPlayer or not md then return end

    if self.state then return end
    if isTimer(self.timer) then killTimer(self.timer) end
    self.timer = nil
end


function HighwayGate:open()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return end
    if getPedOccupiedVehicleSeat(localPlayer) ~= 0 then return end

    setElementFrozen(veh, true)
    if not exports.TR_dx:canOpenGUI() or self:getElementSpeed(veh) > 0 then
        self.timer = setTimer(self.func.open, 500, 1)
        return
    end

    self.isPrivate = getElementData(veh, "vehicleID")
	self.tick = getTickCount()
    self.state = "show"
    self.alpha = 0

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.text = exports.TR_dx:getFont(12)

    self.buttons = {} 
    self.buttons.cancel = exports.TR_dx:createButton(guiInfo.x + guiInfo.w - 260/zoom, guiInfo.y + guiInfo.h - 50/zoom, 250/zoom, 40/zoom, "Yolculuğu iptal et", "red")
    self.buttons.open = exports.TR_dx:createButton(guiInfo.x + 10/zoom, guiInfo.y + guiInfo.h - 50/zoom, 250/zoom, 40/zoom, self.isPrivate and "Yolculuk için ödeme yap" or "Bariyeri aç", "green")
    exports.TR_dx:setButtonVisible(self.buttons, false)
    exports.TR_dx:showButton(self.buttons)

    showCursor(true)
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("guiButtonClick", root, self.func.onButtonClick)
    exports.TR_dx:setOpenGUI(true)
end

function HighwayGate:close()
	self.tick = getTickCount()
    self.state = "hide"
    self.alpha = 1

    local veh = getPedOccupiedVehicle(localPlayer)
    setElementFrozen(veh, false)

    showCursor(false)
    exports.TR_dx:hideButton(self.buttons)
end


function HighwayGate:animate()
    if self.state == "show" then
        local progress = (getTickCount() - self.tick)/500
        self.alpha = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "InOutQuad")

        if progress >= 1 then
            self.tick = getTickCount()
            self.alpha = 1
            self.state = nil
        end

    elseif self.state == "hide" then
        local progress = (getTickCount() - self.tick)/500
        self.alpha = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "InOutQuad")

        if progress >= 1 then
            self.tick = nil
            self.alpha = 0
            self.state = nil

			removeEventHandler("onClientRender", root, self.func.render)
            removeEventHandler("guiButtonClick", root, self.func.onButtonClick)
            exports.TR_dx:setOpenGUI(false)
            exports.TR_dx:destroyButton(self.buttons)
            self.fonts = nil
			return true
        end
    end
end

function HighwayGate:render()
    if self:animate() then return end

    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 4)
    dxDrawText("Otoyol kapıları", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(240, 195, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")
    dxDrawText(self.isPrivate and guiInfo.texts.private or guiInfo.texts.public, guiInfo.x, guiInfo.y + 50/zoom, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.text, "center", "top", false, false, false, true)
end

function HighwayGate:onButtonClick(btn)
    if self.state then return end

    if btn == self.buttons.cancel then
        self:close()
        triggerServerEvent("declineTollGate", resourceRoot, self.tollID)

    elseif btn == self.buttons.open then
        exports.TR_dx:setResponseEnabled(true)
        triggerServerEvent("tryOpenTollGate", resourceRoot, self.tollID, self.isPrivate)

    end
end


function HighwayGate:onReponse(state)
    exports.TR_dx:setResponseEnabled(false)

    if state then
        self:close()
        exports.TR_achievements:addAchievements("vehicleHighwayGate")
    else
        exports.TR_noti:create("Bariyerin kapanmasını bekleyin..", "error")
    end
end

function HighwayGate:drawBackground(x, y, w, h, color, radius, post)
    dxDrawRectangle(x, y, w, h, color, post)
    dxDrawRectangle(x + radius, y - radius, w - radius * 2, radius, color, post)
    dxDrawRectangle(x + radius, y + h, w - radius * 2, radius, color, post)
    dxDrawCircle(x + radius, y, radius, 180, 270, color, color, 7, 1, post)
    dxDrawCircle(x + radius, y + h, radius, 90, 180, color, color, 7, 1, post)

    dxDrawCircle(x + w - radius, y, radius, 270, 360, color, color, 7, 1, post)
    dxDrawCircle(x + w - radius, y + h, radius, 0, 90, color, color, 7, 1, post)
end

function HighwayGate:getElementSpeed(theElement, unit)
    local elementType = getElementType(theElement)
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    return (Vector3(getElementVelocity(theElement)) * mult).length
end

function HighwayGate:getPosition(pos, rot, vec)
	local rot = Vector3(rot)
	local mat = Matrix(Vector3(unpack(pos)), rot)
	local newPos = mat:transformPosition(vec)
	return newPos.x, newPos.y, newPos.z, rot.z
end

HighwayGate:create()

exports.TR_dx:setOpenGUI(false)
exports.TR_dx:setResponseEnabled(false)