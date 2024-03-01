local sx, sy = guiGetScreenSize()

local guiInfo = {
    x = (sx - 700/zoom)/2,
    y = (sy - 400/zoom)/2,
    w = 700,
    h = 400,

    text = {
        y = sy - 270/zoom,
        h = 60/zoom,
    }
}

LicencePractise = {}
LicencePractise.__index = LicencePractise

function LicencePractise:create(...)
    local instance = {}
    setmetatable(instance, LicencePractise)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function LicencePractise:constructor(...)
    self.alpha = 0
    self.tick = getTickCount()

    self.licence = arg[1]
    self.startPos = {
        pos = {getElementPosition(localPlayer)},
        int = getElementInterior(localPlayer),
        dim = getElementDimension(localPlayer),
    }

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.title = exports.TR_dx:getFont(13)
    self.fonts.text = exports.TR_dx:getFont(12)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.renderText = function() self:renderText() end
    self.func.clickButton = function(...) self:clickButton(...) end
    self.func.markerHit = function(...) self:markerHit(...) end
    self.func.vehicleDamage = function(...) self:vehicleDamage(...) end

    self:open()
    return true
end

function LicencePractise:open()
    self.state = "opening"
    self.tick = getTickCount()

    exports.TR_dx:setOpenGUI(true)

    self.buttons = {}
    self.buttons.start = exports.TR_dx:createButton((sx - 250/zoom)/2, guiInfo.y + guiInfo.h - 50/zoom, 250/zoom, 40/zoom, "Sınavı başlat")
    exports.TR_dx:setButtonVisible(self.buttons.start, false)
    exports.TR_dx:showButton(self.buttons.start)

    showCursor(true)
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("guiButtonClick", root, self.func.clickButton)
end

function LicencePractise:close()
    exports.TR_dx:setOpenGUI(false)
    exports.TR_dx:destroyButton(self.buttons)

    showCursor(false)
    removeEventHandler("onClientRender", root, self.func.render)
    removeEventHandler("guiButtonClick", root, self.func.clickButton)
end

function LicencePractise:destroy()
    setElementPosition(localPlayer, unpack(self.startPos.pos))
    setElementInterior(localPlayer, self.startPos.int)
    setElementDimension(localPlayer, self.startPos.dim)

    removeEventHandler("onClientVehicleDamage", root, self.func.vehicleDamage)
    removeEventHandler("onClientRender", root, self.func.renderText)

    if self.licence == "WATER" or self.licence == "LAPL" then
        exports.TR_hud:setRadarCustomLocation(false)
    else
        exports.TR_hud:setRadarCustomLocation("San Andreas DMV", true)
    end

    guiInfo.licence = nil
    self = nil
end


function LicencePractise:animate()
    if not self.tick then return end
    local progress = (getTickCount() - self.tick)/500

    if self.state == "opening" then
      self.alpha = interpolateBetween(self.alpha, 0, 0, 1, 0, 0, progress, "Linear")
      if progress >= 1 then
        self.alpha = 1
        self.state = "opened"
        self.tick = nil
      end
    end
end

function LicencePractise:render()
    self:animate()
    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 4)
    dxDrawText("Hazırlık sınavı", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")

    dxDrawText("SINAV NASIL GÖRÜNÜYOR", guiInfo.x + 10/zoom, guiInfo.y + 80/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h - 50/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.title, "center", "top", true, true)
    dxDrawText("Uygulamalı sınav, sınav merkezi tarafından belirlenen sınav rotasının hatasız olarak tamamlanmasını içerir..", guiInfo.x + 10/zoom, guiInfo.y + 110/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h - 50/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.text, "center", "top", true, true)

    dxDrawText("SINAV GÜZERGAH", guiInfo.x + 10/zoom, guiInfo.y + 200/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h - 50/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.title, "center", "top", true, true)
    dxDrawText("Sınava giren kişi rota üzerinde çeşitli türde engellerle karşılaşabilir. Yolda doğru kararları vermek onun sorumluluğundadır. Herhangi bir ciddi suç işlemediği takdirde sınav başarıyla geçilecektir..", guiInfo.x + 10/zoom, guiInfo.y + 230/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h - 50/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.text, "center", "top", true, true)
end

function LicencePractise:renderText()
    if getElementHealth(localPlayer) <= 90 then
        self:endExam("Bilinç kaybı nedeniyle sınava ara verildi.")
        setElementHealth(localPlayer, 100)
        removeEventHandler("onClientRender", root, self.func.renderText)
        return
    end
    if not self.text then return end

    self:drawBackground(guiInfo.text.x, guiInfo.text.y, guiInfo.text.w, guiInfo.text.h, tocolor(17, 17, 17, 255 * self.alpha), 4)
    dxDrawText("Muayene eden:", guiInfo.text.x, guiInfo.text.y, guiInfo.text.x + guiInfo.text.w, guiInfo.text.y + 30/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")
    dxDrawText(self.text, guiInfo.text.x + 10/zoom, guiInfo.text.y + 30/zoom, guiInfo.text.x + guiInfo.text.w - 10/zoom, guiInfo.text.y + guiInfo.text.h - 10/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.text, "center", "top", true, true)
end


function LicencePractise:startExam()
    setElementHealth(localPlayer, 100)
    exports.TR_dx:showLoading(3000, "Sınav yükleniyor")

    setTimer(function()
        showCursor(false)
        triggerServerEvent("createLicencePracticeVehicle", resourceRoot, self.licence)

        exports.TR_hud:setRadarCustomLocation(false)
    end, 500, 1)

    setTimer(function()
        self:close()
    end, 2000, 1)


    self.road = licences[self.licence].practiseRoad
    self.roadState = 1

    self:createNextPoint()

    addEventHandler("onClientRender", root, self.func.renderText)

    setTimer(function()
        addEventHandler("onClientVehicleDamage", root, self.func.vehicleDamage)
    end, 5000, 1)
end


function LicencePractise:createNextPoint()
    if self.marker then destroyElement(self.marker) end
    if self.blip then destroyElement(self.blip) end

    self.roadState = self.roadState + 1

    if self.roadState > #self.road then
        exports.TR_dx:showLoading(3000, "İç mekan yükleniyor")
        triggerServerEvent("playerPassedPractise", resourceRoot, self.licence, self.startPos)

        setTimer(function()
            exports.TR_noti:create("Sınav başarıyla geçildi.", "success")

            self:destroy()
        end, 3000, 1)
        return
    end

    local pos = self.road[self.roadState]
    self.blip = createBlip(pos[1], pos[2], pos[3], 0, 1, 200, 0, 0, 255)
    self.marker = createMarker(pos[1], pos[2], pos[3], licences[self.licence].practiseMarker or "checkpoint", 2, 0, 0, 255, 255)

    setElementData(self.blip, "icon", 22, false)

    local nextMarker = self.road[self.roadState + 1]
    if nextMarker then
        setMarkerTarget(self.marker, nextMarker[1], nextMarker[2], nextMarker[3])
    else
        setMarkerIcon(self.marker, "finish")
    end


    self.text = pos[4]
    if self.text then
        guiInfo.text.w = math.max(dxGetTextWidth(self.text, 1/zoom, self.fonts.text) + 20/zoom, 160/zoom)
        guiInfo.text.x = (sx - guiInfo.text.w)/2
    end

    addEventHandler("onClientMarkerHit", self.marker, self.func.markerHit)
end

function LicencePractise:endExam(text)
    if isElement(self.marker) then destroyElement(self.marker) end
    if isElement(self.blip) then destroyElement(self.blip) end

    exports.TR_dx:showLoading(3000, "İç mekan yükleniyor")
    setTimer(function()
        exports.TR_noti:create(text, "error")

        self:destroy()
    end, 3000, 1)

    triggerServerEvent("destroyPractiseVehicle", resourceRoot, self.startPos)
end


function LicencePractise:markerHit(...)
    if arg[1] ~= localPlayer then return end

    local veh = getPedOccupiedVehicle(localPlayer)
    if veh then
        if getElementModel(veh) ~= 473 then
            if getVehicleOverrideLights(veh) ~= 2 then
                self:endExam("Işıklar açılmadığı için sınav yarıda kesildi.")
                return

            elseif not getElementData(localPlayer, "belt") and getVehicleType(veh) == "Automobile" then
                self:endExam("Emniyet kemeri takılmadığı için sınava ara verildi.")
                return
            end
        end
    end

    self:createNextPoint()
end

function LicencePractise:vehicleDamage(...)
    local veh = getPedOccupiedVehicle(localPlayer)
    if source == veh then
        if getElementHealth(veh) - arg[3] < 950 then
            self:endExam("Çarpışma nedeniyle sınava ara verildi.")
        end
    end
end

function LicencePractise:clickButton(...)
    if arg[1] == self.buttons.start then
        if self.started then return end
        boughtExams.practise[self.licence] = nil

        self:startExam()
        self.started = true
    end
end

function LicencePractise:drawBackground(x, y, rx, ry, color, radius, post)
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


function startLicencePractise(plr, md)
    if not md then return end
    if plr ~= localPlayer then return end

    if not exports.TR_dx:canOpenGUI() then return end
    if guiInfo.licence then return end

    local licence = getElementData(source, "licence")
    if not boughtExams.practise[licence] then exports.TR_noti:create("Bu sınava başlamak için öncelikle masada ödeme yapmanız gerekmektedir..", "error") return end
    guiInfo.licence = LicencePractise:create(licence)
end

function createLicencePractisePositions()
    for licence, k in pairs(licences) do
        if k.practisePositions then
            for _, v in pairs(k.practisePositions) do
                local marker = createMarker(v.pos.x, v.pos.y, v.pos.z - 0.9, "cylinder", 0.6, 22, 119, 222, 0)
                setElementInterior(marker, v.int)
                setElementDimension(marker, v.dim)
                setElementData(marker, "licence", licence, false)
                setElementData(marker, "markerIcon", "licencePractise", false)
                setElementData(marker, "markerData", {
                    title = "Hazırlık sınavı",
                    desc = string.format("Kategori sınavının başlangıcı %s.", string.upper(licence)),
                }, false)
                addEventHandler("onClientMarkerHit", marker, startLicencePractise)
            end
        end
    end
end
createLicencePractisePositions()


-- guiInfo.licence = LicencePractise:create("WATER")