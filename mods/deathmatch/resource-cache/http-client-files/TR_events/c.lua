local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 400/zoom)/2,
    y = 80/zoom,
    w = 400/zoom,
    h = 140/zoom,

    startTime = 61,

    shaderReplace = [[
        texture gTexture;
        technique TexReplace
        {
            pass P0
            {
                Texture[0] = gTexture;
            }
        }
    ]],

    fonts = {
        countdown = exports.TR_dx:getFont(24),
        countdownTime = exports.TR_dx:getFont(50),
    }
}

EventSystem = {}
EventSystem.__index = EventSystem

function EventSystem:create()
    local instance = {}
    setmetatable(instance, EventSystem)
    if instance:constructor() then
        return instance
    end
    return false
end

function EventSystem:constructor()
    self.alpha = 0

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.info = exports.TR_dx:getFont(12)
    self.fonts.start = exports.TR_dx:getFont(10)

    self.textures = {}
    self.textures.cone = dxCreateTexture("files/images/cone.png", "argb", true, "clamp")
    self.textures.confetti = dxCreateTexture("files/images/confetti.png", "argb", true, "clamp")

    self.func = {}
    self.func.render = function() self:render() end

    addEventHandler("onClientRender", root, self.func.render)
    return true
end

function EventSystem:startEvent(...)
    self.state = "opening"
    self.tick = getTickCount()

    self.eventTick = getTickCount()

    self.alpha = 0
    self.cone = 0
    self.coneAlpha = 0
    self.confetti = 1

    -- self.eventName = string.upper(arg[1])
    self.eventName = arg[1]
    self.eventPlaces = arg[2]
end

function EventSystem:startedEvent(...)
    self.state = "closeCone"
    self.tick = getTickCount()

    self.alpha = 1
end



function EventSystem:animate()
    if not self.tick then return end
    local progress = (getTickCount() - self.tick)/500
    if self.state == "opening" then
        self.alpha = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "Linear")
        if progress >= 1 then
            self.alpha = 1
            self.state = "openCone"
            self.tick = getTickCount()
        end

    elseif self.state == "openCone" then
        self.cone = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "OutBack")
        self.coneAlpha = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "Linear")
        if progress >= 1 then
            self.cone = 1
            self.coneAlpha = 1
            self.tick = getTickCount()
            self.state = "confetti"
        end

    elseif self.state == "confetti" then
        local progress = (getTickCount() - self.tick)/2000
        self.confetti = interpolateBetween(1, 0, 0, -1, 0, 0, progress, "Linear")
        if progress >= 1 then
            self.confetti = 1
            self.tick = getTickCount()
        end

    elseif self.state == "closeCone" then
        self.cone = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "OutBack")
        self.coneAlpha = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "Linear")
        if progress >= 1 then
            self.cone = 0
            self.coneAlpha = 0
            self.state = "closing"
            self.tick = getTickCount()
        end

    elseif self.state == "closing" then
        self.alpha = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "Linear")
        if progress >= 1 then
            self.alpha = 0
            self.state = "closed"
            self.tick = nil

            self.eventName = nil
        end
    end
end



function EventSystem:render()
    if not self.eventName then return end
    self:animate()

    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 4)
    dxDrawImageSection(guiInfo.x + 20/zoom, guiInfo.y + 20/zoom, guiInfo.h - 40/zoom, guiInfo.h - 40/zoom, self.confetti * 128, -self.confetti * 128, 128, 128, self.textures.confetti, 0, 0, 0, tocolor(255, 255, 255, 255 * self.coneAlpha))
    dxDrawImage(guiInfo.x + 30/zoom - self.cone * 10/zoom, guiInfo.y + 30/zoom - self.cone * 10/zoom, guiInfo.h - 60/zoom + self.cone * 20/zoom, guiInfo.h - 60/zoom + self.cone * 20/zoom, self.textures.cone, 0, 0, 0, tocolor(255, 255, 255, 255 * self.coneAlpha))

    dxDrawText("YAKLAŞAN ETKİNLİKT", guiInfo.x + guiInfo.h, guiInfo.y + 10/zoom, guiInfo.x + guiInfo.w - 20/zoom, guiInfo.y + guiInfo.h, tocolor(240, 196, 55, 255 * self.alpha * self.coneAlpha), 1/zoom, self.fonts.main, "center", "top")
    dxDrawText(self.eventName and self.eventName or "", guiInfo.x + guiInfo.h, guiInfo.y + 32/zoom, guiInfo.x + guiInfo.w - 20/zoom, guiInfo.y + guiInfo.h - 10/zoom, tocolor(170, 170, 170, 255 * self.alpha * self.coneAlpha), 1/zoom, self.fonts.info, "center", "top")

    dxDrawText(string.format("Koltukların sayısı: %d", self.eventPlaces and self.eventPlaces or "0"), guiInfo.x + guiInfo.h, guiInfo.y + 60/zoom, guiInfo.x + guiInfo.w - 20/zoom, guiInfo.y + guiInfo.h - 10/zoom, tocolor(220, 220, 220, 255 * self.alpha * self.coneAlpha), 1/zoom, self.fonts.main, "center", "top")

    dxDrawText(string.format("Etkinlik %ds tarihinde başlayacak.\nKatılmak için /event yazabilirsiniz.", self:getStartTime()), guiInfo.x + guiInfo.h, guiInfo.y + 10/zoom, guiInfo.x + guiInfo.w - 20/zoom, guiInfo.y + guiInfo.h - 10/zoom, tocolor(170, 170, 170, 255 * self.alpha * self.coneAlpha), 1/zoom, self.fonts.start, "center", "bottom")

    if self:getStartTime() <= 0 and self.state ~= "closing" and self.state ~= "closeCone" then
        self:startedEvent()
    end
end





function EventSystem:getStartTime()
    return math.floor(guiInfo.startTime - (getTickCount() - self.eventTick)/1000)
end


function EventSystem:updatePlaces(...)
    self.eventPlaces = arg[1]
end


function EventSystem:drawBackground(x, y, rx, ry, color, radius, post)
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


guiInfo.system = EventSystem:create()

function startEvent(...)
    if not guiInfo.system then return end
    if not getElementData(localPlayer, "characterUID") then return end
    guiInfo.system:startEvent(...)
end
addEvent("startEvent", true)
addEventHandler("startEvent", root, startEvent)


function updateEventPlaces(...)
    guiInfo.system:updatePlaces(...)
end
addEvent("updateEventPlaces", true)
addEventHandler("updateEventPlaces", root, updateEventPlaces)


function setEventNoti(state, data)
    if not getElementData(localPlayer, "characterUID") then return end

    if state == "start" then
        exports.TR_noti:create(string.format("%s etkinliği yeni başladı.", unpack(data)), "success")
        if getElementData(localPlayer, "isOnEvent") then
            setEventCountdown()
        end

    elseif state == "notStarted" then
        exports.TR_noti:create("Çok az kişi kaydolduğu için etkinlik başlamadı.", "error")

    elseif state == "win" then
        exports.TR_noti:create(string.format("Tebrikler!\n%s, %s etkinliğini kazandı ve $%.2f kazandı.", unpack(data)), "success", 5)

    elseif state == "nooneWins" then
        exports.TR_noti:create("Kimse etkinliği kazanmayı başaramadı!", "success", 5)

    elseif state == "winsWithoutPlayer" then
        exports.TR_noti:create(string.format("Tebrikler! Etkinlik galibiyetle sona erdi! Kazananların her biri $%.2f alır.", unpack(data)), "success", 5)

    elseif state == "winPirate" then
        exports.TR_noti:create(string.format("Tebrikler!\n%s Takımı %s etkinliğini kazandı ve her biri %%.2f $ kazandı.", unpack(data)), "success", 10)
        removeBandanas()
    end
end
addEvent("setEventNoti", true)
addEventHandler("setEventNoti", root, setEventNoti)


function updateBandanas()
    guiInfo.bandanaTexture = dxCreateTexture("files/images/bandama.png", "dxt3", true, "clamp")
    guiInfo.bandanaShader = dxCreateShader(guiInfo.shaderReplace, 0, 0, false, "ped")
    dxSetShaderValue(guiInfo.bandanaShader, "gTexture", guiInfo.bandanaTexture)

    for i, v in pairs(getElementsByType("player"), root, true) do
        local team = getPlayerTeam(v)
        if team then
            if getTeamName(team) == "blue" then
                engineApplyShaderToWorldTexture(guiInfo.bandanaShader, "bandama", v)
            end
        end
    end
end
addEvent("updateBandanas", true)
addEventHandler("updateBandanas", root, updateBandanas)

function removeBandanas()
    if not guiInfo.bandanaShader then return end
    engineRemoveShaderFromWorldTexture(guiInfo.bandanaShader, "gTexture")

    if isTimer() then killTimer() end
    if isElement(guiInfo.bandanaTexture) then destroyElement(guiInfo.bandanaTexture) end
    if isElement(guiInfo.bandanaShader) then destroyElement(guiInfo.bandanaShader) end
end

function payForAdminEvent(type, price)
    if not price or not type then return end

    triggerServerEvent("createPayment", resourceRoot, price, "startAdminEvent", {type, price})
end
addEvent("payForAdminEvent", true)
addEventHandler("payForAdminEvent", root, payForAdminEvent)

function paidForAdminEvent()
    exports.TR_dx:setResponseEnabled(false)
end
addEvent("paidForAdminEvent", true)
addEventHandler("paidForAdminEvent", root, paidForAdminEvent)


function setEventCountdown()
    guiInfo.countDownTick = getTickCount()

    addEventHandler("onClientRender", root, renderCountdown)
end

function stopEventCountdown()
    removeEventHandler("onClientRender", root, renderCountdown)
    guiInfo.countDownTick = nil

    local veh = getPedOccupiedVehicle(localPlayer)
    if veh then
        setElementFrozen(veh, false)
    end
    setElementFrozen(localPlayer, false)
    setGameSpeed(1)
end

function renderCountdown()
    local time = 10 - (getTickCount() - guiInfo.countDownTick)/1000

    drawTextHardShadowed("ETKİNLİK 2025 YILINDA BAŞLAYACAK", sx/2, 150/zoom, sx/2, 150/zoom, tocolor(220, 220, 220, 255), 1/zoom, guiInfo.fonts.countdown, "center", "center")

    if time < 1 then
        dxDrawText("BAŞLA", sx/2, 200/zoom, sx/2, 200/zoom, tocolor(80, 255, 80, 255), 1/zoom, guiInfo.fonts.countdownTime, "center", "center")
    else
        dxDrawText(string.format("%d", time), sx/2, 200/zoom, sx/2, 200/zoom, tocolor(255, 80, 80, 255), 1/zoom, guiInfo.fonts.countdownTime, "center", "center")
    end

    if time <= 0 then
        stopEventCountdown()
    else
        local veh = getPedOccupiedVehicle(localPlayer)
        if veh then setElementFrozen(veh, true) end
        setElementFrozen(localPlayer, true)
    end
end

function drawTextHardShadowed(text, x, y, w, h, color, scale, font, vert, hori, clip, brake, post, colored)
	dxDrawText(text, x + 1, y + 1, w + 1, h + 1, tocolor(0, 0, 0, 200), scale, font, vert, hori, clip, brake, post)
	dxDrawText(text, x, y, w, h, color, scale, font, vert, hori, clip, brake, post, colored)
end
setElementData(localPlayer, "waitingEvent", nil)
setElementData(localPlayer, "isOnEvent", false)