local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    tickets = {
        x = (sx - 420/zoom)/2,
        y = (sy - 400/zoom)/2,
        w = 420/zoom,
        h = 400/zoom,

        studentsTexts = {"Öğrenci bileti almak istiyorum."},
        standardTexts = {"Yetişkin bileti almak istiyorum."},
    },

    hourEarning = {3350, 3400},
    pedSkins = {1,2,7,9,12,13,14,15,20,21,22,23,24,25,35,36,37,40,41,46,47,48,55,56,60,76,69,91,88,93,98,150,151,169,195,193,192,214},

    maxEarning = 75,
}

Tram = {}
Tram.__index = Tram

function Tram:create(...)
    local instance = {}
    setmetatable(instance, Tram)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function Tram:constructor(...)
    self.ownedUpgrades = arg[1]
    self.route = 0
    self.skinsInside = {}
    self.ticketsToGive = 0

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.text = exports.TR_dx:getFont(12)

    self.func = {}
    self.func.render = function(...) self:render(...) end
    self.func.checkStop = function(...) self:checkStop(...) end
    self.func.onMarkerHit = function(...) self:onMarkerHit(...) end
    self.func.onMarkerLeave = function(...) self:onMarkerLeave(...) end
    self.func.blockSpeed = function(...) self:blockSpeed(...) end
    self.func.onMouseClick = function(...) self:onMouseClick(...) end
    self.func.moveNpcsToEnter = function() self:moveNpcsToEnter() end
    self.func.moveAllNpcsInside = function() self:moveAllNpcsInside() end

    exports.TR_noti:create("Tramvay şoförü olarak işe başladınız.", "job")
    exports.TR_weather:setCustomWeather(false)
    exports.TR_hud:setRadarCustomLocation(false)

    self:createNextMarker()

    setTimer(function()
        addEventHandler("onClientRender", root, self.func.blockSpeed)
    end, 1000, 1)
    triggerServerEvent("createTramJobVehicle", resourceRoot)
    return true
end

function Tram:destroy()
    exports.TR_jobs:resetPaymentTime()

    exports.TR_weather:setCustomWeather(0, 12, 0, 9999)
    exports.TR_hud:setRadarCustomLocation("Bina İçi | San Fierro Tram Merkezi", true)

    exports.TR_jobs:setPlayerJob(false)
    exports.TR_jobs:removeInformation()
    exports.TR_jobs:setPlayerTargetPos(false)
    exports.TR_noti:create("İşinizi başarıyla tamamladınız.", "job")
    triggerServerEvent("endJob", resourceRoot)

    if self:isEventHandlerAdded("onClientRender", root, self.func.moveNpcsToEnter) then
        removeEventHandler("onClientRender", root, self.func.moveNpcsToEnter)
    end

    for i, v in pairs(self.npcs) do destroyElement(v) end
    if isTimer(self.timer) then killTimer(self.timer) end
    self:removeMarker()

    exports.TR_jobs:setPlayerTargetPos(false)

    removeEventHandler("onClientRender", root, self.func.blockSpeed)
    triggerServerEvent("removeAttachedObject", resourceRoot, 449)
    guiInfo.work = nil
    self = nil
end

function Tram:removeMarker()
    if isElement(self.marker) then
        removeEventHandler("onClientMarkerHit", self.marker, self.func.onMarkerHit)
        removeEventHandler("onClientMarkerHit", self.marker, self.func.onMarkerLeave)
        destroyElement(self.marker)
    end

    if isElement(self.blip) then destroyElement(self.blip) end
    if isTimer(self.checker) then killTimer(self.checker) end

    if self.noti then exports.TR_noti:destroy(self.noti) end
end

function Tram:createNextMarker()
    self:removeMarker()

    self.route = self.route + 1
    if self.route > #targetPoints then self.route = 1 end

    local pos = targetPoints[self.route]
    self.marker = createMarker(pos.marker - Vector3(0, 0, 0.9), "cylinder", 3, 255, 255, 255, 0)
    setElementData(self.marker, "markerIcon", "busStop", false)
    setElementData(self.marker, "markerData", {
        title = "Durak",
        desc = "Yolcuları almak için durağa uğrayın.",
    }, false)

    self.blip = createBlip(pos.marker, 0, 2, 255, 60, 60, 255)
    setElementData(self.blip, "icon", 22, false)

    exports.TR_jobs:setPlayerTargetPos(pos.marker.x, pos.marker.y, pos.marker.z - 0.2, 0, 0, "Durakta durun.")
    exports.TR_jobs:createInformation(jobSettings.name, "Yolcuları almak için bir sonraki durak noktasına gidin.")
    addEventHandler("onClientMarkerHit", self.marker, self.func.onMarkerHit)
    addEventHandler("onClientMarkerLeave", self.marker, self.func.onMarkerLeave)

    self.npcs = {}
    local poses = table.clone(pos.npcs)
    local npcCount = math.random(1, math.min(#pos.npcs, self.ownedUpgrades[1] and #pos.npcs or 2))
    while npcCount >= 1 do
        npcCount = npcCount - 1
        local posIndex = math.random(1, #poses)
        local pos = poses[posIndex]
        table.remove(poses, posIndex)

        local skin = guiInfo.pedSkins[math.random(1, #guiInfo.pedSkins)]
        local ped = createPed(skin, pos.pos, pos.rot)
        setElementCollisionsEnabled(ped, false)
        if pos.anim then setElementData(ped, "animation", pos.anim, false) end

        table.insert(self.npcs, ped)
    end
    self.npcCount = #self.npcs

    for _, v in pairs(self.npcs) do
        for _, k in pairs(self.npcs) do
            setElementCollidableWith(v, k, false)
        end
    end

    exports.TR_jobs:setPaymentTime()
end

function Tram:onMarkerHit(plr, md)
    if plr ~= localPlayer or not md then return end

    self.noti = exports.TR_noti:create("Durakta durup insanları almak için durun.", "info", 10, true)
    self.checker = setTimer(self.func.checkStop, 100, 0)
end

function Tram:onMarkerLeave(plr, md)
    if plr ~= localPlayer or not md then return end
    if isTimer(self.checker) then killTimer(self.checker) end
    if not self.noti then return end
    exports.TR_noti:destroy(self.noti)
end

function Tram:checkStop()
    local speed = self:getElementSpeed(getPedOccupiedVehicle(localPlayer), 1)
    if speed < 2 then
        self.blockMove = true
        self:removeMarker()
        self:setNpcGoOut()

        local x, y, z = self:getPosition(getPedOccupiedVehicle(localPlayer), Vector3(0, 2, 0))
        for i, v in pairs(self.npcs) do
            local pos = Vector3(getElementPosition(v))
            local rot = self:findRotation(pos.x, pos.y, x, y)
            setElementRotation(v, 0, 0, rot)

            setElementData(v, "animation", {"ped", "walk_player", false, true}, false)
            setPedAnimation(v, "ped", "walk_player", -1, true, true, false)
            setElementCollisionsEnabled(v, true)
        end
        addEventHandler("onClientRender", root, self.func.moveNpcsToEnter)
        exports.TR_jobs:createInformation(jobSettings.name, "Yolcuların binip inmesini bekleyin.")
        self.timer = setTimer(self.func.moveAllNpcsInside, 10000, 1)
    end
end

function Tram:setNpcGoOut()
    local veh = getPedOccupiedVehicle(localPlayer)
    local _, _, rot = getElementRotation(veh)
    local x, y, z = self:getPosition(veh, Vector3(2, 2, 0))

    if #self.skinsInside > 0 then
        local goOut = math.min(math.random(0, 4), #self.skinsInside)
        if goOut > 0 then

            for i = 1, goOut do
                local skinIndex = math.random(1, #self.skinsInside)
                local skin = self.skinsInside[skinIndex]
                table.remove(self.skinsInside, skinIndex)

                setTimer(function()
                    local ped = createPed(skin, x, y, z, rot - math.random(80, 120))
                    setElementData(ped, "animation", {"ped", "walk_player", false, true}, false)
                    setPedAnimation(ped, "ped", "walk_player", -1, true, true, false)

                    for _, v in pairs(self.npcs) do
                        setElementCollidableWith(v, ped, false)
                    end
                    setTimer(destroyElement, 4500, 1, ped)
                end, 1000 * i, 1)
            end
        end
    end
end

function Tram:moveAllNpcsInside()
    for i, v in pairs(self.npcs) do
        table.insert(self.skinsInside, getElementModel(v))
        destroyElement(v)
        self:openTicketGui()
        self.npcs[i] = nil
    end
end

function Tram:openTicketGui()
    self.ticketsToGive = self.ticketsToGive + 1

    if self.state then return end
    self.alpha = 0
    self.state = "opening"
    self.tick = getTickCount()
    self.goodTickets = 0
    self.badTickets = 0

    self:setTicketRequest()

    showCursor(true)
    addEventHandler("onClientClick", root, self.func.onMouseClick)
    addEventHandler("onClientRender", root, self.func.render)
    exports.TR_jobs:createInformation(jobSettings.name, "Yolculara uygun biletleri verin.")
end

function Tram:closeTicketGui()
    self.alpha = 1
    self.state = "closing"
    self.tick = getTickCount()
    self.blockMove = nil

    self:createNextMarker()

    showCursor(false)
    removeEventHandler("onClientClick", root, self.func.onMouseClick)
    removeEventHandler("onClientRender", root, self.func.moveNpcsToEnter)
end

function Tram:blockSpeed()
    if self.state or self.blockMove then
        setTrainSpeed(getPedOccupiedVehicle(localPlayer), 0)
    else
        local speed = self:getElementSpeed(getPedOccupiedVehicle(localPlayer), 1)
        if self.ownedUpgrades[2] then
            if speed > 70 then
                setTrainSpeed(getPedOccupiedVehicle(localPlayer), 60/160)
            end
        else
            if speed > 50 then
                setTrainSpeed(getPedOccupiedVehicle(localPlayer), 43/160)
            end
        end
    end
end

function Tram:animate()
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
            self.state = nil
            self.tick = nil

            removeEventHandler("onClientRender", root, self.func.render)
            return true
        end
    end
end

function Tram:render()
    if self:animate() then return end

    self:drawBackground(guiInfo.tickets.x, guiInfo.tickets.y, guiInfo.tickets.w, guiInfo.tickets.h, tocolor(17, 17, 17, 255 * self.alpha), 4)
    dxDrawText("Uygun bilet seçin", guiInfo.tickets.x, guiInfo.tickets.y, guiInfo.tickets.x + guiInfo.tickets.w, guiInfo.tickets.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")
    if self:isMouseInPosition((sx - 330/zoom)/2, guiInfo.tickets.y + 50/zoom, 330/zoom, 112/zoom) then
        dxDrawImage((sx - 330/zoom)/2, guiInfo.tickets.y + 50/zoom, 330/zoom, 112/zoom, "files/images/ticket1.png", 0, 0, 0, tocolor(255, 255, 255, 230 * self.alpha))
    else
        dxDrawImage((sx - 330/zoom)/2, guiInfo.tickets.y + 50/zoom, 330/zoom, 112/zoom, "files/images/ticket1.png", 0, 0, 0, tocolor(255, 255, 255, 200 * self.alpha))
    end
    if self:isMouseInPosition((sx - 330/zoom)/2, guiInfo.tickets.y + 167/zoom, 330/zoom, 112/zoom) then
        dxDrawImage((sx - 330/zoom)/2, guiInfo.tickets.y + 167/zoom, 330/zoom, 112/zoom, "files/images/ticket2.png", 0, 0, 0, tocolor(255, 255, 255, 230 * self.alpha))
    else
        dxDrawImage((sx - 330/zoom)/2, guiInfo.tickets.y + 167/zoom, 330/zoom, 112/zoom, "files/images/ticket2.png", 0, 0, 0, tocolor(255, 255, 255, 200 * self.alpha))
    end

    if not self.ticketRequest or self.ticketsToGive == 0 then
        dxDrawText("Araçtaki bir sonraki yolcunun binmesini bekleyin.", guiInfo.tickets.x + 10/zoom, guiInfo.tickets.y + 275/zoom, guiInfo.tickets.x + guiInfo.tickets.w - 10/zoom, guiInfo.tickets.y + guiInfo.tickets.h, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.text, "center", "center", true, true)
    else
        dxDrawText(string.format("Yolcu:\n%s", self.ticketRequest.text), guiInfo.tickets.x + 10/zoom, guiInfo.tickets.y + 275/zoom, guiInfo.tickets.x + guiInfo.tickets.w - 10/zoom, guiInfo.tickets.y + guiInfo.tickets.h, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.text, "center", "center", true, true)
    end
end

function Tram:moveNpcsToEnter()
    local x, y, z = self:getPosition(getPedOccupiedVehicle(localPlayer), Vector3(0, 2, 0))
    local count = 0
    for i, v in pairs(self.npcs) do
        local pos = Vector3(getElementPosition(v))
        count = count + 1

        if getDistanceBetweenPoints2D(x, y, pos.x, pos.y) < 2 then
            table.insert(self.skinsInside, getElementModel(v))
            self:openTicketGui()
            destroyElement(v)
            self.npcs[i] = nil
            count = count - 1
        end
    end

    if count == 0 then
        if isTimer(self.timer) then killTimer(self.timer) end
    end
end




function Tram:onMouseClick(...)
    if arg[1] ~= "left" or arg[2] ~= "down" or self.ticketsToGive <= 0 then return end
    local usedTicket = false
    if self:isMouseInPosition((sx - 330/zoom)/2, guiInfo.tickets.y + 50/zoom, 330/zoom, 112/zoom) then
        if self.ticketRequest.type == "student" then
            exports.TR_noti:create("Doğru bileti verdiniz.", "success")
            self.goodTickets = self.goodTickets + 1
            usedTicket = true
        else
            exports.TR_noti:create("Yanlış bileti verdiniz.", "error")
            self.badTickets = self.badTickets + 1
            usedTicket = true
        end
    end

    if self:isMouseInPosition((sx - 330/zoom)/2, guiInfo.tickets.y + 167/zoom, 330/zoom, 112/zoom) then
        if self.ticketRequest.type == "standard" then
            exports.TR_noti:create("Doğru bileti verdiniz.", "success")
            self.goodTickets = self.goodTickets + 1
            usedTicket = true
        else
            exports.TR_noti:create("Yanlış bileti verdiniz.", "error")
            self.badTickets = self.badTickets + 1
            usedTicket = true
        end
    end
    if not usedTicket then return end

    self.ticketsToGive = self.ticketsToGive - 1

    if self.ticketsToGive == 0 then
        local count = 0
        for i, v in pairs(self.npcs) do
            count = count + 1
        end
        if count == 0 then
            self:payForDrive()
            self:closeTicketGui()
        end

    else
        self:setTicketRequest()
    end
end

function Tram:setTicketRequest()
    if math.random(0, 1) == 0 then
        self.ticketRequest = {
            text = guiInfo.tickets.studentsTexts[math.random(1, #guiInfo.tickets.studentsTexts)],
            type = "student",
        }
    else
        self.ticketRequest = {
            text = guiInfo.tickets.standardTexts[math.random(1, #guiInfo.tickets.standardTexts)],
            type = "standard",
        }
    end
end


-- Payment
function Tram:payForDrive()
    local payment = self:calculatePayment()
    local paymentType = exports.TR_jobs:getPlayerJobPaymentType()

    if self.badTickets == 0 then
        payment = payment + (self.goodTickets * math.random(95, 150)/100)
    end

    exports.TR_jobPayments:giveJobPayment(payment, paymentType, getResourceName(getThisResource()))
end

function Tram:calculatePayment()
    local addMin, addMax = 0, 0
    for i, v in pairs(jobSettings.upgrades) do
        if self.ownedUpgrades[i] and v.additionalMoney then
            addMin = addMin + v.additionalMoney[1]
            addMax = addMax + v.additionalMoney[2]
        end
    end
    return math.min(exports.TR_jobs:getPaymentCount(guiInfo.hourEarning[1] + addMin, guiInfo.hourEarning[2] + addMax), guiInfo.maxEarning + (addMin + addMax)/2)
end


-- Utils
function Tram:drawBackground(x, y, rx, ry, color, radius, post)
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

function Tram:getPosition(element, vec)
	local rot = Vector3(getElementRotation(element))
	local mat = Matrix(Vector3(getElementPosition(element)), rot)
	local newPos = mat:transformPosition(vec)
	return newPos.x, newPos.y, newPos.z, rot.z
end

function Tram:setElementSpeed(element, unit, speed)
    local unit    = unit or 0
    local speed   = tonumber(speed) or 0
	local acSpeed = self:getElementSpeed(element, unit)
	if (acSpeed) then
		local diff = speed/acSpeed
		if diff ~= diff then return false end
        local x, y, z = getElementVelocity(element)
		return setElementVelocity(element, x*diff, y*diff, z*diff)
	end

	return false
end

function Tram:getElementSpeed(theElement, unit)
	if not isElement(theElement) then return 0 end
    local elementType = getElementType(theElement)
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    return (Vector3(getElementVelocity(theElement)) * mult).length
end

function Tram:getPointFromDistanceRotation(x, y, dist, angle)
    local a = math.rad(90 - angle);
    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;
    return x+dx, y+dy;
end

function Tram:findRotation( x1, y1, x2, y2 )
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end

function Tram:isMouseInPosition(x, y, width, height)
    if (not isCursorShowing()) then
        return false
    end
    local cx, cy = getCursorPosition()
    local cx, cy = (cx*sx), (cy*sy)
    if (cx >= x and cx <= x + width) and (cy >= y and cy <= y + height) then
        return true
    else
        return false
    end
end

function Tram:isEventHandlerAdded( sEventName, pElementAttachedTo, func )
    if type( sEventName ) == 'string' and isElement( pElementAttachedTo ) and type( func ) == 'function' then
        local aAttachedFunctions = getEventHandlers( sEventName, pElementAttachedTo )
        if type( aAttachedFunctions ) == 'table' and #aAttachedFunctions > 0 then
            for i, v in ipairs( aAttachedFunctions ) do
                if v == func then
                    return true
                end
            end
        end
    end
    return false
end

function table.clone(org)
    local new = {}
    for i, v in pairs(org) do
        new[i] = v
    end
    return new
end



function startJob(...)
    if guiInfo.work then return end
    guiInfo.work = Tram:create(...)

    exports.TR_jobs:closeJobWindow()
    exports.TR_jobs:responseJobWindow()
end

function endJob()
    exports.TR_jobs:responseJobWindow()

    if not guiInfo.work then return end
    guiInfo.work:destroy()
end
addEvent("endTramWork", true)
addEventHandler("endTramWork", root, endJob)

-- triggerServerEvent("removeAttachedObject", resourceRoot, 917)

-- if getPlayerName(localPlayer) == "Xantris" then
    -- startJob({})
--     setTimer(endJob, 5000, 1)
-- end