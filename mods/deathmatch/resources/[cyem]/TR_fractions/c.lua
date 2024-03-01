local sx, sy = guiGetScreenSize()
zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

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

    paymentSeconds = 0,
}

FractionJobStart = {}
FractionJobStart.__index = FractionJobStart

function FractionJobStart:create(...)
    local instance = {}
    setmetatable(instance, FractionJobStart)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function FractionJobStart:constructor(...)
    self.alpha = 0
    self.fractionName = arg[1].name
	self.fractionType = arg[1].type
	self.fractionColor = arg[1].color
    self.fractionID = arg[1].ID
	self.jobID = arg[2] and string.format("fraction_%s", arg[1].ID) or false

	local jobID = exports.TR_jobs:getPlayerJob()

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.info = exports.TR_dx:getFont(12)

    self.buttons = {}
    self.buttons.exit = exports.TR_dx:createButton(guiInfo.x + 10/zoom, guiInfo.y + guiInfo.h - 50/zoom, 235/zoom, 40/zoom, "Kapat")
    self.buttons.start = exports.TR_dx:createButton(guiInfo.x + guiInfo.w - 245/zoom, guiInfo.y + guiInfo.h - 50/zoom, 235/zoom, 40/zoom, jobID == self.jobID and "Görevi Bitir" or "Göreve Başla")
    exports.TR_dx:setButtonVisible(self.buttons, false)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.buttonClick = function(...) self:buttonClick(...) end

    self:open()
    return true
end


function FractionJobStart:open()
    self.state = "opening"
    self.tick = getTickCount()

    exports.TR_dx:setOpenGUI(true)
    exports.TR_dx:showButton(self.buttons)

    showCursor(true)
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("guiButtonClick", root, self.func.buttonClick)
end

function FractionJobStart:close()
    self.state = "closing"
    self.tick = getTickCount()

    exports.TR_dx:hideButton(self.buttons)

    showCursor(false)
    removeEventHandler("guiButtonClick", root, self.func.buttonClick)
end

function FractionJobStart:destroy()
    exports.TR_dx:setOpenGUI(false)
    exports.TR_dx:destroyButton(self.buttons)
    removeEventHandler("onClientRender", root, self.func.render)
    guiInfo.job = nil
    self = nil
end


function FractionJobStart:animate()
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

function FractionJobStart:render()
    self:animate()
    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 5)
    dxDrawText(self.fractionName, guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")
    dxDrawText("Bir işe başlamak için bir fraksiyona katılmanız gerekmektedir. Katılmak için sunucu forumunda lider tarafından yürütülen bir alım sürecinden geçmelisiniz.", guiInfo.x + 20/zoom, guiInfo.y + 50/zoom, guiInfo.x + guiInfo.w - 20/zoom, guiInfo.y + 110/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "top", true, true)
    dxDrawText("İşiniz bittikten sonra serbest çalışmaya başlamak için ayrılmanız gerekmektedir.", guiInfo.x + 20/zoom, guiInfo.y + 120/zoom, guiInfo.x + guiInfo.w - 20/zoom, guiInfo.y + guiInfo.h - 60/zoom, tocolor(170, 60, 60, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "top", true, true)
end


function FractionJobStart:buttonClick(...)
    if arg[1] == self.buttons.exit then
        self:close()

    elseif arg[1] == self.buttons.start then
        if self.tickStart then
            if (getTickCount() - self.tickStart)/2000 <= 1 then
                exports.TR_noti:create("Durumu değiştirmeden önce 2 saniye beklemelisin.", "error")
                return
            end
        end
        self.tickStart = getTickCount()
        if not self.jobID then exports.TR_noti:create("Bu konumda görevi başlatamazsınız, çünkü bu fraksiyonun üyesi değilsiniz.", "error") return end

		local job = exports.TR_jobs:getPlayerJob()
        if not job then
            local slots = {1, 2, 3, 4, 5, 6, 7}
            for i, v in pairs(slots) do
                if getPedWeapon(localPlayer, v) > 0 then
                    exports.TR_noti:create("Özel silahınızı donattığınız için göreve başlayamazsınız.", "error")
                    return
                end
            end
            triggerServerEvent("startPlayerFractionDuty", resourceRoot, job, self.fractionName, self.fractionType, self.fractionColor, self.fractionID)
            exports.TR_dx:setResponseEnabled(true)

        elseif job and job == self.jobID then
            triggerServerEvent("startPlayerFractionDuty", resourceRoot, job, self.fractionName, self.fractionType)
            exports.TR_dx:setResponseEnabled(true)

        else
            exports.TR_noti:create("Bu konumda görevi başlatamazsınız, çünkü bu fraksiyonun üyesi değilsiniz.", "error")
        end
    end
end

function FractionJobStart:reponse(...)
  exports.TR_dx:setResponseEnabled(false)

  if arg[1] == "start" then
    exports.TR_jobs:setPlayerJob(self.jobID, self.fractionType)
    exports.TR_dx:setButtonText(self.buttons.start, "Görevi Bitir")

    local info = self.fractionType == "police" and "Gişeye gidin ve uygun kıyafeti giyin veya hemen atış poligonuna gidin ve ekipmanınızı alın." or "Gişeye gidin ve uygun kıyafeti giyin."
	exports.TR_jobs:createInformation(self.fractionName, info)

	exports.TR_noti:create("Göreve başarıyla başladınız.", "success")

    guiInfo.paymentTimer = setTimer(calculateTimeForPayment, 1000, 0)


  elseif arg[1] == "end" then
    exports.TR_jobs:setPlayerJob(nil)
	exports.TR_jobs:removeInformation()

	exports.TR_dx:setButtonText(self.buttons.start, "Göreve Başla")

    exports.TR_noti:create("Görevi başarıyla tamamladınız.", "success")

    exports.TR_weapons:updateWeapons()

    if isTimer(guiInfo.paymentTimer) then killTimer(guiInfo.paymentTimer) end
  end
end
function FractionJobStart:drawBackground(x, y, rx, ry, color, radius, post)
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


function openFractionDutyStart(...)
    if guiInfo.job then return end
    guiInfo.job = FractionJobStart:create(...)
end
addEvent("openFractionDutyStart", true)
addEventHandler("openFractionDutyStart", root, openFractionDutyStart)

function responseFractionDutyStart(...)
    if not guiInfo.job then return end
    guiInfo.job:reponse(...)
end
addEvent("responseFractionDutyStart", true)
addEventHandler("responseFractionDutyStart", root, responseFractionDutyStart)



function calculateTimeForPayment()
    if getElementData(localPlayer, "afk") then return end
    guiInfo.paymentSeconds = guiInfo.paymentSeconds + 1

    if guiInfo.paymentSeconds >= 60 then
        guiInfo.paymentSeconds = 0
        triggerServerEvent("syncPlayerFractionMinutes", resourceRoot)
    end
end

function addedFractionReport(fraction)
    local jobID, jobType = exports.TR_jobs:getPlayerJob()

    if not jobID or not jobType then return end
    if fraction == "m" and jobType ~= "medic" then return end
    if fraction == "p" and jobType ~= "police" then return end
    if fraction == "f" and jobType ~= "fire" then return end
    if fraction == "ers" and jobType ~= "ers" then return end

    exports.TR_noti:create("Yeni fraksiyon raporu geldi.", "info")
end
addEvent("addedFractionReport", true)
addEventHandler("addedFractionReport", root, addedFractionReport)