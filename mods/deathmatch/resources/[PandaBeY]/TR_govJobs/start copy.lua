local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 500/zoom)/2,
    y = (sy - 230/zoom)/2,
    w = 500/zoom,
    h = 230/zoom,
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
    self.distanceLimit = arg[1].distanceLimit
    self.currentJob = arg[2]

    local jobID = exports.TR_jobs:getPlayerJob()

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.info = exports.TR_dx:getFont(12)

    self.buttons = {}
    self.buttons.exit = exports.TR_dx:createButton(guiInfo.x + 10/zoom, guiInfo.y + guiInfo.h - 50/zoom, 235/zoom, 40/zoom, "Zamknij")
    self.buttons.start = exports.TR_dx:createButton(guiInfo.x + guiInfo.w - 245/zoom, guiInfo.y + guiInfo.h - 50/zoom, 235/zoom, 40/zoom, jobID == self.jobID and "Zakończ pracę" or "Rozpocznij pracę")
    exports.TR_dx:setButtonVisible(self.buttons, false)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.buttonClick = function(...) self:buttonClick(...) end

    self:open()
    return true
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
    dxDrawText("Resmi iş", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")
    dxDrawText("Burada çalışmaya başlamak için ofise iş başvurusunda bulunmalısınız. İşinizi kaybetmemek için en az 24 saatte bir işyerine gelmeniz gerektiğini unutmayın..", guiInfo.x + 20/zoom, guiInfo.y + 50/zoom, guiInfo.x + guiInfo.w - 20/zoom, guiInfo.y + 110/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "top", true, true)
    dxDrawText("Hizmetinizi tamamladıktan sonra gündelik işe başlayabilmeniz için işinizden ayrılmanız gerekir..", guiInfo.x + 20/zoom, guiInfo.y + 120/zoom, guiInfo.x + guiInfo.w - 20/zoom, guiInfo.y + guiInfo.h - 60/zoom, tocolor(170, 60, 60, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "top", true, true)
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
        local isAdmin = exports.TR_admin:isPlayerOnDuty()
        if self.jobID ~= self.currentJob and not isAdmin then exports.TR_noti:create("Burada çalışmadığınız için burada çalışmaya başlayamazsınız.", "error") return end

        local job = exports.TR_jobs:getPlayerJob()
        if not job then
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

  elseif arg[1] == "end" then
    self:stopWorkExport()

    exports.TR_jobs:setPlayerJob(nil)

    exports.TR_noti:create("İşinizi başarıyla bıraktınız.", "success")
    exports.TR_jobs:removeInformation()

    exports.TR_dx:setButtonText(self.buttons.start, "Başla")
  end
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