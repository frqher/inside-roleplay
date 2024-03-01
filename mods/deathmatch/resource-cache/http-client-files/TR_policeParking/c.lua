local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 550/zoom)/2,
    y = (sy - 350/zoom)/2,
    w = 550/zoom,
    h = 350/zoom,
}

PoliceParking = {}
PoliceParking.__index = PoliceParking

function PoliceParking:create(...)
    local instance = {}
    setmetatable(instance, PoliceParking)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function PoliceParking:constructor(...)
    self.alpha = 0
    self.vehicle = arg[1]
    self.vehicleData = {
        ID = getElementData(self.vehicle, "vehicleID"),
        name = self:getVehicleName(self.vehicle),
    }

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.veh = exports.TR_dx:getFont(12)
    self.fonts.info = exports.TR_dx:getFont(10)

    self.edits = {}
    self.edits.reason = exports.TR_dx:createEdit(guiInfo.x + (guiInfo.w - 400/zoom)/2, guiInfo.y + 120/zoom, 400/zoom, 40/zoom, "Çekme nedenini girin")
    self.edits.price = exports.TR_dx:createEdit(guiInfo.x + (guiInfo.w - 250/zoom)/2, guiInfo.y + 170/zoom, 250/zoom, 40/zoom, "Fiyatını girin")
    exports.TR_dx:setEditVisible(self.edits, false)
    exports.TR_dx:showEdit(self.edits)

    self.buttons = {}
    self.buttons.close = exports.TR_dx:createButton(guiInfo.x + 10/zoom, guiInfo.y + guiInfo.h - 50/zoom, 250/zoom, 40/zoom, "Zamknij")
    self.buttons.accept = exports.TR_dx:createButton(guiInfo.x + guiInfo.w - 260/zoom, guiInfo.y + guiInfo.h - 50/zoom, 250/zoom, 40/zoom, "Otoparka koyun")
    exports.TR_dx:setButtonVisible(self.buttons, false)
    exports.TR_dx:showButton(self.buttons)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.buttonClick = function(...) self:buttonClick(...) end

    self:open()
    return true
end

function PoliceParking:open()
    self.alpha = 0
    self.state = "opening"
    self.tick = getTickCount()

    showCursor(true)
    toggleControl("enter_exit", false)
    setElementFrozen(getPedOccupiedVehicle(localPlayer), true)

    exports.TR_dx:setOpenGUI(true)
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("guiButtonClick", root, self.func.buttonClick)
end

function PoliceParking:close()
    self.alpha = 1
    self.state = "closing"
    self.tick = getTickCount()

    exports.TR_dx:hideButton(self.buttons)
    exports.TR_dx:hideEdit(self.edits)

    showCursor(false)
    toggleControl("enter_exit", true)
    setElementFrozen(getPedOccupiedVehicle(localPlayer), false)
end

function PoliceParking:destroy()
    removeEventHandler("onClientRender", root, self.func.render)

    exports.TR_dx:destroyEdit(self.edits)
    exports.TR_dx:destroyButton(self.buttons)

    exports.TR_dx:setOpenGUI(false)
    guiInfo.window = nil
    self = nil
end

function PoliceParking:animate()
    if not self.tick then return end
    if self.state == "opening" then
        local progress = (getTickCount() - self.tick)/500
        self.alpha = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "Linear")

        if progress >= 1 then
            self.alpha = 1
            self.state = "opened"
            self.tick = nil
        end

    elseif self.state == "closing" then
        local progress = (getTickCount() - self.tick)/500
        self.alpha = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "Linear")

        if progress >= 1 then
            self.alpha = 0
            self.state = nil
            self.tick = nil

            self:destroy()
            return true
        end
    end
end

function PoliceParking:render()
    self:animate()

    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 4)
    dxDrawText("Polis otoparkı", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")
    dxDrawText(string.format("Çekilmiş araçlar :\n%s (%d)", self.vehicleData.name, self.vehicleData.ID), guiInfo.x, guiInfo.y + 60/zoom, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.veh, "center", "top")
    dxDrawText("Aracı çıkarmak için oyuncunun yukarıda girilen tutarı ödemesi gerekecektir. Cezaların tarifeyle tutarlı olması gerektiğini unutmayın!", guiInfo.x + 30/zoom, guiInfo.y + 210/zoom, guiInfo.x + guiInfo.w - 30/zoom, guiInfo.y + guiInfo.h - 50/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "center", true, true)
end

function PoliceParking:buttonClick(btn)
    if exports.TR_dx:isResponseEnabled() then return end
    if btn == self.buttons.close then
        self:close()

    elseif btn == self.buttons.accept then
        local reason = guiGetText(self.edits.reason)
        local price = tonumber(guiGetText(self.edits.price))
        if string.len(reason) < 2 or string.len(reason) > 100 then exports.TR_noti:create("Çekme nedeni 2 ila 40 karakter uzunluğunda olmalıdır.", "error") return end
        if not price then exports.TR_noti:create("Fiyat hatalı.", "error") return end
        if price < 0 then exports.TR_noti:create("Minimum tutar 0$'dır.", "error") return end
        if price > 7000 then exports.TR_noti:create("Tutar aşılamaz $7000.", "error") return end

        exports.TR_dx:setResponseEnabled(true)
        triggerServerEvent("moveVehicleToPoliceParking", resourceRoot, self.vehicle, tonumber(string.format("%.2f", price)), reason)
    end
end

function PoliceParking:drawBackground(x, y, rx, ry, color, radius, post)
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

function PoliceParking:getVehicleName(veh)
    local model = getElementModel(veh)
    if model == 471 then return "Snowmobile" end
    if model == 604 then return "Christmas Manana" end
    return getVehicleNameFromModel(model)
end

function PoliceParking:response(success)
    if success then
        exports.TR_noti:create("Araç polis otoparkına bırakıldı.", "success")
        self:close()
    end
    exports.TR_dx:setResponseEnabled(false)
end


function openPoliceParking(el, md)
    if not el or not md then return end
    if el ~= localPlayer then return end

    local canParking = canPlaceInParking(el)
    if not canParking then return end
    if guiInfo.window then return end
    if not exports.TR_dx:canOpenGUI() then return end

    guiInfo.window = PoliceParking:create(canParking)
end

function responsePoliceParking(...)
    if not guiInfo.window then return end
    guiInfo.window:response(...)
end
addEvent("responsePoliceParking", true)
addEventHandler("responsePoliceParking", root, responsePoliceParking)

function canPlaceInParking(plr)
    local veh = getPedOccupiedVehicle(plr)
    if not veh then return false end
    if getElementModel(veh) ~= 525 and getElementModel(veh) ~= 428 then return false end
    if getPedOccupiedVehicleSeat(localPlayer) ~= 0 then return end

    local towedVeh = getVehicleTowedByVehicle(veh) or getElementData(veh, "towedVeh")
    if not towedVeh then return false end

    local id = getElementData(towedVeh, "vehicleID")
    if not id then exports.TR_noti:create("Yalnızca özel aracınızı park edebilirsiniz.", "error") return false end

    return towedVeh
end






-- Utils at all
function createPoliceParkingMarkers()
    for i, v in pairs(policeParkings) do
        local marker = createMarker(v.pos.x, v.pos.y, v.pos.z - 0.9, "cylinder", 2, 212, 146, 32, 0)
        setElementData(marker, "markerIcon", "towtruck")
        setElementData(marker, "markerData", {
            title = "Polis otoparkı",
            desc = "Aracı polis otoparkına götürmek için çekerken işaretleyiciye doğru sürün."
        }, false)
        addEventHandler("onClientMarkerHit", marker, openPoliceParking)
    end
end
createPoliceParkingMarkers()

exports.TR_dx:setOpenGUI(false)
exports.TR_dx:setResponseEnabled(false)
-- setElementFrozen(getPedOccupiedVehicle(localPlayer), false)