local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 400/zoom)/2,
    y = (sy - 370/zoom)/2,
    w = 400/zoom,
    h = 370/zoom,
}

PoliceJail = {}
PoliceJail.__index = PoliceJail

function PoliceJail:create(...)
    local instance = {}
    setmetatable(instance, PoliceJail)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function PoliceJail:constructor(...)
    self.alpha = 0
    self.prisonIndex = arg[1]

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.info = exports.TR_dx:getFont(12)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.buttonClick = function(...) self:buttonClick(...) end

    self.buttons = {}
    self.buttons.putToJail = exports.TR_dx:createButton((sx - 250/zoom)/2, guiInfo.y + guiInfo.h - 100/zoom, 250/zoom, 40/zoom, "Tutsağı yerleştirin", "green")
    self.buttons.exit = exports.TR_dx:createButton((sx - 250/zoom)/2, guiInfo.y + guiInfo.h - 50/zoom, 250/zoom, 40/zoom, "Kapat", "red")
    exports.TR_dx:setButtonVisible(self.buttons, false)

    self.edits = {}
    self.edits.time = exports.TR_dx:createEdit((sx - 250/zoom)/2, guiInfo.y + 160/zoom, 250/zoom, 40/zoom, "Hapis süresi (dakika)")
    self.edits.reason = exports.TR_dx:createEdit((sx - 250/zoom)/2, guiInfo.y + 205/zoom, 250/zoom, 40/zoom, "Hizmet nedeni")
    exports.TR_dx:setEditVisible(self.edits, false)

    self:open()
    return true
end

function PoliceJail:open()
    self.tick = getTickCount()
    self.state = "opening"

    exports.TR_dx:showButton(self.buttons)
    exports.TR_dx:showEdit(self.edits)
    showCursor(true)
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("guiButtonClick", root, self.func.buttonClick)
end

function PoliceJail:close()
    self.tick = getTickCount()
    self.state = "closing"

    showCursor(false)
    exports.TR_dx:hideButton(self.buttons)
    exports.TR_dx:hideEdit(self.edits)

    removeEventHandler("guiButtonClick", root, self.func.buttonClick)
end

function PoliceJail:destroy()
    exports.TR_dx:destroyButton(self.buttons)
    exports.TR_dx:destroyEdit(self.edits)

    removeEventHandler("onClientRender", root, self.func.render)
    guiInfo.jail = nil
    self = nil
end


function PoliceJail:animate()
    if not self.tick then return end
    local progress = (getTickCount() - self.tick)/500
    if self.state == "opening" then
        self.alpha = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "Linear")
        if progress >= 1 then
            self.alpha = 1
            self.state = "opened"
            self.tick = nil
        end

    elseif self.state == "closing" then
        self.alpha = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "Linear")
        if progress >= 1 then
            self.alpha = nil
            self.state = "closed"
            self.tick = nil

            self:destroy()
            return true
        end
    end
end

function PoliceJail:render()
    if self:animate() then return end

    self:drawOptionsBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 4)
    dxDrawText("Eyalet Hapishanesi", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")
    dxDrawText("Bir oyuncuyu hapse atmak için, işlediği suçun cezaevine gönderilmeye uygun olduğundan emin olun ve ardından aşağıdaki tüm bilgileri doldurun.", guiInfo.x + 10/zoom, guiInfo.y + 50/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "top", true, true)
end


function PoliceJail:buttonClick(btn)
    if btn == self.buttons.exit then
        self:close()

    elseif btn == self.buttons.putToJail then
        local cuffed = getElementData(localPlayer, "cuffed")
        if not cuffed then exports.TR_noti:create("Zincirlenmiş kimsen yok.", "error") return end

        local time = guiGetText(self.edits.time)
        local reason = guiGetText(self.edits.reason)

        if utf8.len(time) < 1 or utf8.len(reason) < 1 then exports.TR_noti:create("Tüm detayları doldurmalısınız.", "error") return end
        local time = tonumber(time)
        if time == nil then exports.TR_noti:create("Zaman yanlış.", "error") return end
        if time < 1 or time > 300 then exports.TR_noti:create("Süre 1-300 dakika arasında olmalıdır.", "error") return end

        if utf8.len(reason) < 5 or utf8.len(reason) > 50 then exports.TR_noti:create("Sebep 5-50 karakter arasında olmalıdır.", "error") return end
        if utf8.len(reason) < 5 or utf8.len(reason) > 50 then exports.TR_noti:create("Sebep 5-50 karakter arasında olmalıdır.", "error") return end

        triggerServerEvent("setPlayerInPrizon", resourceRoot, self.prisonIndex, cuffed, time * 60, reason)
        self:close()
    end
end

function PoliceJail:drawOptionsBackground(x, y, rx, ry, color, radius, post)
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


function openPoliceJail(el, md)
    if el ~= localPlayer or not md then return end
    if not exports.TR_dx:canOpenGUI() then return end
    if guiInfo.jail then return end

    local cuffed = getElementData(localPlayer, "cuffed")
    if not cuffed then exports.TR_noti:create("Zincirlenmiş kimsen yok.", "error") return end

    local prisonIndex = getElementData(source, "prisonIndex")
    local attached = getAttachedElements(localPlayer)
    for i, v in pairs(attached) do
        if v == cuffed then
            guiInfo.jail = PoliceJail:create(prisonIndex)
            return
        end
    end
    exports.TR_noti:create("Zincire vurduğunuz kimse yok.", "error")
end

function createPoliceMarkers()
    for i, v in pairs(PoliceJails) do
        local v = v.marker
        local marker = createMarker(v.pos - Vector3(0, 0, 0.9), "cylinder", 1.6, 66, 197, 245, 0)
        setElementInterior(marker, v.int)
        setElementDimension(marker, v.dim)

        setElementData(marker, "markerIcon", "jail", false)
        setElementData(marker, "markerData", {
            title = "Cezaevi Paneli",
            desc = "Kelepçeli kişiyi parmaklıkların arkasına koymak için markera girin.",
        }, false)
        setElementData(marker, "prisonIndex", i, false)
    end

    addEventHandler("onClientMarkerHit", resourceRoot, openPoliceJail)
end
createPoliceMarkers()