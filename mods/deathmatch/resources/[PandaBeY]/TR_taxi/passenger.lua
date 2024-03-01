local sx, sy = guiGetScreenSize()
zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = 0,
    y = (sy - 90/zoom)/2,
    w = 260/zoom,
    h = 90/zoom,
}

Passenger = {}
Passenger.__index = Passenger

function Passenger:create(...)
    local instance = {}
    setmetatable(instance, Passenger)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function Passenger:constructor(...)
    self.alpha = 0
    self.toPayPerKM = 12

    self.isTravelMan = getPedOccupiedVehicleSeat(localPlayer) > 0
    self.travelTime = getTickCount()
    self.distanceTick = getTickCount()
    self.distance = 0
    self.lastDistance = 0
    self.toPayTotal = 0

    self.vehicle = getPedOccupiedVehicle(localPlayer)

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(13)
    self.fonts.info = exports.TR_dx:getFont(11)

    self.func = {}
    self.func.render = function() self:render() end

    self:open()
    return true
end

function Passenger:open()
    self.state = "opening"
    self.tick = getTickCount()

    addEventHandler("onClientRender", root, self.func.render)
end

function Passenger:close()
    self.state = "closing"
    self.tick = getTickCount()
end

function Passenger:destroy()
    removeEventHandler("onClientRender", root, self.func.render)
    guiInfo.info = nil
    self = nil
end


function Passenger:animate()
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

function Passenger:render()
    self:animate()
    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 5)
    dxDrawText(self.isTravelMan and "Taksi ile seyahat" or "Taksimetre göstergeleri", guiInfo.x + 10/zoom, guiInfo.y, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + 25/zoom, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")
    dxDrawText(string.format("Km başına maliyet: #787878$%.2f\n#aaaaaaSeyahat süresi: #787878%s\n#aaaaaaKat edilen mesafe: #787878%.2fkm", self.toPayPerKM, self:getTimeInSeconds((getTickCount() - self.travelTime)/1000), self.distance), guiInfo.x + 10/zoom, guiInfo.y + 25/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "top", false, false, false, true)

    self:checkDistance()
    self:checkPayment()
end

function Passenger:checkDistance()
    if (getTickCount() - self.distanceTick)/1000 >= 1 then
        local speed = self:getElementSpeed(self.vehicle, 1)
		local mileage = speed / 3600

        self.distance = tonumber(string.format("%.6f", self.distance + mileage * 2))
        self.distanceTick = getTickCount()
    end
end

function Passenger:checkPayment()
    local driver = getVehicleOccupant(self.vehicle, 0)
    if not driver then self:close() return end

    if self.lastDistance + 1 < self.distance then
        self.lastDistance = self.distance

        if self.isTravelMan then
            if not self.blockMoneyEarn then
                triggerServerEvent("payForTaxi", resourceRoot, driver, self.toPayPerKM)

            elseif not self.notiSend then
                exports.TR_noti:create("Başka bir kurs için ödeme yapamazsınız.", "error", 10)
                self.notiSend = true
            end

        else
            if not self.blockMoneyEarn then
                self.toPayTotal = self.toPayTotal + self.toPayPerKM/2

            elseif not self.notiSend then
                exports.TR_noti:create("Müşteri daha sonraki kurs için ödeme yapamaz.", "error", 10)
                self.notiSend = true
            end
        end
    end
end

function Passenger:checkPassenger()
    if self.isTravelMan then return end
    self:triggerPayment()
end

function Passenger:triggerPayment()
    if self.isTravelMan or self.paid then return end
    self.paid = true
    triggerServerEvent("giveJobPayment", resourceRoot, self.toPayTotal, false, false, false, true)
    exports.TR_jobs:createInformation("Taksi Sürücüsü", "Başvuruyu bekleyin veya müşteri çekmek için sık ziyaret edilen bir yere gidin. Rapor panelini F4 butonunun altında bulabilirsiniz.")
    removeTravelInfo()
end

function Passenger:blockMoney()
    self.blockMoneyEarn = true
end

function Passenger:getTimeInSeconds(seconds)
    local seconds = tonumber(seconds)

    if seconds <= 0 then
      return "00:00:00";
    else
      hours = string.format("%02.f", math.floor(seconds/3600));
      mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
      secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
      return hours..":"..mins..":"..secs
    end
end

function Passenger:drawBackground(x, y, w, h, color, radius, post)
    dxDrawRectangle(x, y - radius, w, h + radius * 2, color, post)
    dxDrawRectangle(x + w, y, radius, h, color, post)
    dxDrawCircle(x + w, y + h, radius, 0, 90, color, color, 7, 1, post)
    dxDrawCircle(x + w, y, radius, 270, 360, color, color, 7, 1, post)
end

function Passenger:getElementSpeed(theElement, unit)
	if not isElement(theElement) then return 0 end
    local elementType = getElementType(theElement)
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    return (Vector3(getElementVelocity(theElement)) * mult).length
end

function createTravelInfo(...)
    if guiInfo.info then return end
    guiInfo.info = Passenger:create(...)
end

function blockTaxiMoney(...)
    if not guiInfo.info then return end
    guiInfo.info:blockMoney(...)
end
addEvent("blockTaxiMoney", true)
addEventHandler("blockTaxiMoney", root, blockTaxiMoney)

function triggerPayment()
    if not guiInfo.info then return end
    guiInfo.info:triggerPayment()
end

function removeTravelInfo(...)
    if not guiInfo.info then return end
    guiInfo.info:close(...)
end