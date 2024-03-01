local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    jobEnd = {
        x = (sx - 530/zoom)/2,
        y = (sy - 150/zoom)/2,
        w = 530/zoom,
        h = 200/zoom,
    },
}

VehicleExitJobEnd = {}
VehicleExitJobEnd.__index = VehicleExitJobEnd

function VehicleExitJobEnd:create()
    local instance = {}
    setmetatable(instance, VehicleExitJobEnd)
    if instance:constructor() then
        return instance
    end
    return false
end

function VehicleExitJobEnd:constructor()
    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.accept = exports.TR_dx:getFont(11)
    self.fonts.info = exports.TR_dx:getFont(11)

    self.buttons = {}
    self.buttons.accept = exports.TR_dx:createButton(guiInfo.jobEnd.x + guiInfo.jobEnd.w - 260/zoom, guiInfo.jobEnd.y + guiInfo.jobEnd.h - 50/zoom, 250/zoom, 40/zoom, "Zakończ pracę", "green")
    self.buttons.reject = exports.TR_dx:createButton(guiInfo.jobEnd.x + 10/zoom, guiInfo.jobEnd.y + guiInfo.jobEnd.h - 50/zoom, 250/zoom, 40/zoom, "Anuluj", "red")
    self.jobEndAccept = true

    self.func = {}
    self.func.render = function() self:render() end
    self.func.guiJobEndClick = function(...) self:guiJobEndClick(...) end

    showCursor(true)
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("guiButtonClick", root, self.func.guiJobEndClick)
    return true
end

function VehicleExitJobEnd:render()
    self:drawBackground(guiInfo.jobEnd.x, guiInfo.jobEnd.y, guiInfo.jobEnd.w, guiInfo.jobEnd.h, tocolor(17, 17, 17, 255), 4)
    dxDrawText("İş Bitirme", guiInfo.jobEnd.x, guiInfo.jobEnd.y, guiInfo.jobEnd.x + guiInfo.jobEnd.w, guiInfo.jobEnd.y + 50/zoom, tocolor(240, 196, 55, 255), 1/zoom, self.fonts.main, "center", "center")
    dxDrawText("İşinizi gerçekten bitirmek istediğinizden emin misiniz?", guiInfo.jobEnd.x + 10/zoom, guiInfo.jobEnd.y + 50/zoom, guiInfo.jobEnd.x + guiInfo.jobEnd.w - 10/zoom, guiInfo.jobEnd.y + guiInfo.jobEnd.h - 50/zoom, tocolor(220, 220, 220, 255), 1/zoom, self.fonts.accept, "center", "top", true, true)
    dxDrawText("İşten ödemenizi aldığınızdan emin olmadan işi bitirmeyi onaylamayın. Eğer ödemenizi almadan işi bitirirseniz, ilerleme otomatik olarak sıfırlanacaktır.", guiInfo.jobEnd.x + 10/zoom, guiInfo.jobEnd.y + 74/zoom, guiInfo.jobEnd.x + guiInfo.jobEnd.w - 10/zoom, guiInfo.jobEnd.y + guiInfo.jobEnd.h - 50/zoom, tocolor(170, 60, 60, 255), 1/zoom, self.fonts.info, "center", "top", true, true)
    
end

function VehicleExitJobEnd:destroy()
    showCursor(false)
    exports.TR_dx:destroyButton(self.buttons)
    removeEventHandler("onClientRender", root, self.func.render)
    removeEventHandler("guiButtonClick", root, self.func.guiJobEndClick)

    guiInfo.gui = nil
    self = nil
end

function VehicleExitJobEnd:guiJobEndClick(btn)
    if btn == self.buttons.accept then
        local job = getPlayerJob()
        if job then
            exports[job]:endJob()
        end
        self:destroy()

    elseif btn == self.buttons.reject then
        self:destroy()
    end
end

function VehicleExitJobEnd:drawBackground(x, y, rx, ry, color, radius, post)
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



function onJobVehicleExit()
    if guiInfo.gui then return end
    guiInfo.gui = VehicleExitJobEnd:create()
end
addEvent("onJobVehicleExit", true)
addEventHandler("onJobVehicleExit", root, onJobVehicleExit)