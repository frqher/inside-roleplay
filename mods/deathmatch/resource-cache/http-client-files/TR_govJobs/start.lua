local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 500/zoom)/2,
    y = (sy - 525/zoom)/2,
    w = 500/zoom,
    h = 525/zoom,
}

GovJobsStart = {}
GovJobsStart.__index = GovJobsStart

function GovJobsStart:create(...)
    local instance = {}
    setmetatable(instance, GovJobsStart)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function GovJobsStart:constructor(...)
    self.alpha = 0
    self.jobID = arg[1].ID
    self.jobType = arg[1].type
    self.jobPayment = arg[1].payment
    self.jobName = arg[1].name
    self.jobDesc = arg[1].desc
    self.jobRequire = arg[1].requirements
    self.distanceLimit = arg[1].distanceLimit
    self.slots = arg[1].slots
    self.licences = arg[2] and fromJSON(arg[2]) or {}

    local jobID = exports.TR_jobs:getPlayerJob()

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.title = exports.TR_dx:getFont(13)
    self.fonts.info = exports.TR_dx:getFont(12)

    self.buttons = {}
    self.buttons.exit = exports.TR_dx:createButton(guiInfo.x + 10/zoom, guiInfo.y + guiInfo.h - 50/zoom, 235/zoom, 40/zoom, "Zamknij", "red")
    self.buttons.start = exports.TR_dx:createButton(guiInfo.x + guiInfo.w - 245/zoom, guiInfo.y + guiInfo.h - 50/zoom, 235/zoom, 40/zoom, jobID == self.jobID and "Zakończ pracę" or "Rozpocznij pracę", "green")
    exports.TR_dx:setButtonVisible(self.buttons, false)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.buttonClick = function(...) self:buttonClick(...) end

    self:open()
    self:checkJobPlaces()
    return true
end


function GovJobsStart:checkJobPlaces()
    self.freeSlots = 0

    for i, v in pairs(getElementsByType("player")) do
        local govJob = getElementData(v, "govJob")

        if govJob then
            if govJob == self.jobID then
                self.freeSlots = self.freeSlots + 1
            end
        end
    end
end

function GovJobsStart:open()
    self.state = "opening"
    self.tick = getTickCount()

    exports.TR_dx:setOpenGUI(true)
    exports.TR_dx:showButton(self.buttons)

    showCursor(true)
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("guiButtonClick", root, self.func.buttonClick)
end

function GovJobsStart:close()
    self.state = "closing"
    self.tick = getTickCount()

    exports.TR_dx:hideButton(self.buttons)

    showCursor(false)
    removeEventHandler("guiButtonClick", root, self.func.buttonClick)
end

function GovJobsStart:destroy()
    exports.TR_dx:setOpenGUI(false)
    exports.TR_dx:destroyButton(self.buttons)
    removeEventHandler("onClientRender", root, self.func.render)
    guiInfo.job = nil
    self = nil
end


function GovJobsStart:animate()
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
        self.alpha = 0
        self.state = "closed"
        self.tick = nil

        self:destroy()
      end
    end
end

function GovJobsStart:render()
    self:animate()
    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 5)

    local img = string.format("files/images/%s.png", self.jobType)
    if fileExists(img) then
        dxDrawImage(guiInfo.x + (guiInfo.w - 128/zoom)/2, guiInfo.y + 50/zoom, 128/zoom, 128/zoom, img, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
    end

    dxDrawText(self.jobName, guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")
    dxDrawText("İş tanımı:", guiInfo.x + 20/zoom, guiInfo.y + 190/zoom, guiInfo.x + guiInfo.w - 20/zoom, guiInfo.y + guiInfo.h - 60/zoom, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.title, "center", "top", true, true, false, true)
    dxDrawText(self.jobDesc, guiInfo.x + 20/zoom, guiInfo.y + 215/zoom, guiInfo.x + guiInfo.w - 20/zoom, guiInfo.y + 110/zoom, tocolor(204, 204, 204, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "top", false, true)

    dxDrawText("ücret:", guiInfo.x + 20/zoom, guiInfo.y + 290/zoom, guiInfo.x + guiInfo.w - 20/zoom, guiInfo.y + guiInfo.h - 60/zoom, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.title, "center", "top", true, true, false, true)
    dxDrawText(self.jobPayment or "Nie sprecyzowano", guiInfo.x + 20/zoom, guiInfo.y + 315/zoom, guiInfo.x + guiInfo.w - 20/zoom, guiInfo.y + guiInfo.h - 60/zoom, tocolor(204, 204, 204, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "top", true, true, false, true)

    dxDrawText("Gereksinimler:", guiInfo.x + 20/zoom, guiInfo.y + 350/zoom, guiInfo.x + guiInfo.w - 20/zoom, guiInfo.y + guiInfo.h - 60/zoom, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.title, "center", "top", true, true, false, true)
    dxDrawText(self.jobRequire or "Brak wymagań", guiInfo.x + 20/zoom, guiInfo.y + 375/zoom, guiInfo.x + guiInfo.w - 20/zoom, guiInfo.y + guiInfo.h - 60/zoom, tocolor(204, 204, 204, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "top", true, true, false, true)

    dxDrawText("koltukların sayısı:", guiInfo.x + 20/zoom, guiInfo.y + 410/zoom, guiInfo.x + guiInfo.w - 20/zoom, guiInfo.y + guiInfo.h - 60/zoom, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.title, "center", "top", true, true, false, true)
    dxDrawText(string.format("%d/%d", self.freeSlots and self.freeSlots or 0, self.slots), guiInfo.x + 20/zoom, guiInfo.y + 435/zoom, guiInfo.x + guiInfo.w - 20/zoom, guiInfo.y + guiInfo.h - 60/zoom, tocolor(204, 204, 204, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "top", true, true, false, true)
end


function GovJobsStart:buttonClick(...)
    if arg[1] == self.buttons.exit then
        self:close()

    elseif arg[1] == self.buttons.start then
        if self.tickStart then
            if (getTickCount() - self.tickStart)/2000 <= 1 then
                exports.TR_noti:create("Durumu değiştirmeden önce 2 saniye beklemelisiniz.", "error")
                return
            end
        end
        self.tickStart = getTickCount()

        local job = exports.TR_jobs:getPlayerJob()
        if not job then
            self:checkJobPlaces()

            if getElementData(localPlayer, "waitingEvent") then
                exports.TR_noti:create("Kayıtlı olduğunuz etkinliği beklerken çalışmaya başlayamazsınız.", "error", 8)
                return
            end

            if self.jobRequire then
                if string.find(self.jobRequire, "kat. A") then
                    if not self.licences["a"] then exports.TR_noti:create("Tüm şartları karşılamadığınız için bu işi alamıyorsunuz.", "error") return end

                elseif string.find(self.jobRequire, "kat. B") then
                    if not self.licences["b"] then exports.TR_noti:create("Tüm şartları karşılamadığınız için bu işi alamıyorsunuz.", "error") return end

                elseif string.find(self.jobRequire, "kat. C") then
                    if not self.licences["c"] then exports.TR_noti:create("Tüm şartları karşılamadığınız için bu işi alamıyorsunuz.", "error") return end

                elseif string.find(self.jobRequire, "Licencja Lotnicza") then
                    if not self.licences["fly"] then exports.TR_noti:create("Tüm şartları karşılamadığınız için bu işi alamıyorsunuz.", "error") return end
                end

                if string.find(self.jobRequire, "Doświadczenie:") then
                    local text = string.match(self.jobRequire, "Doświadczenie: %d+")
                    local pointsNeeded = tonumber(string.sub(text, 17, string.len(text)))
                    local plrPoints = getElementData(localPlayer, "characterPoints") or 0

                    if tonumber(plrPoints) < pointsNeeded then
                        exports.TR_noti:create("Tüm şartları karşılamadığınız için bu işi alamıyorsunuz.", "error", 8)
                        return
                    end
                end
            end

            if (self.freeSlots and self.freeSlots or 0) >= self.slots then
                exports.TR_noti:create("Tüm yerler zaten dolu olduğundan işe başlayamazsınız.", "error")
                return
            end

            triggerServerEvent("startPlayerGovJob", resourceRoot, job)
            exports.TR_dx:setResponseEnabled(true)

        elseif job and job == self.jobID then
            triggerServerEvent("startPlayerGovJob", resourceRoot, job)
            exports.TR_dx:setResponseEnabled(true)

        else
            exports.TR_noti:create("Burada çalışmaya başlayamazsınız çünkü zaten bir yerde çalışıyorsunuz.", "error")
        end
    end
end

function GovJobsStart:reponse(...)
  exports.TR_dx:setResponseEnabled(false)

  if arg[1] == "start" then
    local payment = self.jobPayment
    if type(self.jobPayment) == "string" then
        payment = split(payment, " ")[1]
    end

    exports.TR_jobs:setPlayerJob(self.jobID, self.jobType, payment, self.distanceLimit and {markerPos = Vector2(getElementPosition(localPlayer)), limit = self.distanceLimit} or false)

    exports.TR_noti:create("Çalışmaya başarıyla başladınız.", "success")

    exports.TR_dx:setButtonText(self.buttons.start, "İşini bitir")
    setElementData(localPlayer, "govJob", self.jobID)
    setElementData(localPlayer, "inJob", self.jobType)

  elseif arg[1] == "end" then
    self:stopWorkExport()

    exports.TR_jobs:setPlayerJob(nil)

    exports.TR_noti:create("İşinizi başarıyla bıraktınız.", "success")
    exports.TR_jobs:removeInformation()

    exports.TR_dx:setButtonText(self.buttons.start, "Başla")
    setElementData(localPlayer, "govJob", nil)
    setElementData(localPlayer, "inJob", nil)
  end

  self:checkJobPlaces()
end

function GovJobsStart:stopWorkExport()
    if self.jobType == "taxi" then
        exports.TR_taxi:stopTaxiWork()
    end
end


function GovJobsStart:drawBackground(x, y, rx, ry, color, radius, post)
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


function openGovJobStart(...)
    if guiInfo.job then return end
    guiInfo.job = GovJobsStart:create(...)
end
addEvent("openGovJobStart", true)
addEventHandler("openGovJobStart", root, openGovJobStart)

function responseGovJobStart(...)
    if not guiInfo.job then return end
    guiInfo.job:reponse(...)
end
addEvent("responseGovJobStart", true)
addEventHandler("responseGovJobStart", root, responseGovJobStart)