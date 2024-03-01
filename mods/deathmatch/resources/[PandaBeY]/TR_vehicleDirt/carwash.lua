local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 440/zoom)/2,
    y = (sy - 540/zoom)/2,
    w = 440/zoom,
    h = 540/zoom,

    effects = {
        Vector3(2, 2, 0),
        Vector3(2, -2, 0),
        Vector3(-2, 2, 0),
        Vector3(-2, -2, 0),
    },
    washers = {},

    options = {
        {
            text = "Temel Program",
            desc = "Su ile yıkamak",
            img = "files/images/standard.png",
            price = 50,
            cleanAmount = 300,
        },
        {
            text = "Genişletilmiş Program",
            desc = "Su ile yıkamak, fırçalamak",
            img = "files/images/default.png",
            price = 80,
            cleanAmount = 450,
        },
        {
            text = "Premium program",
            desc = "Su ile yıkama, kimyasallarla yıkama, fırçalama",
            img = "files/images/premium.png",
            price = 130,
            cleanAmount = 600,
        },
        {
            text = "Premium Maks Programı",
            desc = "Suyla yıkama, kimyasal yıkama, fırçalama, ağda",
            img = "files/images/max.png",
            longText = true,
            price = 200,
            cleanAmount = 5000,
        },
    },
}

CarWash = {}
CarWash.__index = CarWash

function CarWash:create(...)
    local instance = {}
    setmetatable(instance, CarWash)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function CarWash:constructor(...)
    self.alpha = 0
    self.washerIndex = arg[1]

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.price = exports.TR_dx:getFont(12)
    self.fonts.desc = exports.TR_dx:getFont(9)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.checkOpen = function() self:checkOpen() end
    self.func.onClick = function(...) self:onClick(...) end
    self.func.buttonClick = function(...) self:buttonClick(...) end
    self.func.setupWashing = function(...) self:setupWashing(...) end
    self.func.setVehicleClean = function(...) self:setVehicleClean(...) end

    self.textures = {}
    self.textures.logo = dxCreateTexture("files/images/logo.png", "argb", true, "clamp")

    self:createNoti("Oto yıkama panelini açmak için motoru durdurun, el frenini çekin ve tüm camları kapatın.", 3, true)

    self.checkTimer = setTimer(self.func.checkOpen, 1000, 0)
    addEventHandler("onClientRender", root, self.func.render)
    return true
end

function CarWash:destroy()
    self:destroyNoti()
    exports.TR_dx:setOpenGUI(false)

    if self.exitButton then
        exports.TR_dx:destroyButton(self.exitButton)
    end

    removeEventHandler("onClientRender", root, self.func.render)
    toggleControl("enter_exit", true)

    for i, v in pairs(self.textures) do
        destroyElement(v)
    end
    if isTimer(self.checkTimer) then killTimer(self.checkTimer) end

    guiInfo.panel = nil
    self = nil
end

function CarWash:open()
    self:destroyNoti()
    exports.TR_dx:setOpenGUI(true)

    self.tick = getTickCount()
    self.state = "opening"

    showCursor(true)
    self.exitButton = exports.TR_dx:createButton((sx - 250/zoom)/2, guiInfo.y + guiInfo.h - 55/zoom, 250/zoom, 40/zoom, "Kapat", "red")
    exports.TR_dx:showButton(self.exitButton)

    addEventHandler("guiButtonClick", root, self.func.buttonClick)
    addEventHandler("onClientClick", root, self.func.onClick)

    toggleControl("enter_exit", false)

    if isTimer(self.checkTimer) then killTimer(self.checkTimer) end
end

function CarWash:close()
    if not self.state then
        self:destroy()

    else
        self.tick = getTickCount()
        self.state = "closing"
        exports.TR_dx:hideButton(self.exitButton)
        self.fullClose = true

        removeEventHandler("guiButtonClick", root, self.func.buttonClick)
        removeEventHandler("onClientClick", root, self.func.onClick)
    end
    showCursor(false)
    self:destroyNoti()
end


function CarWash:animate()
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
        self.state = nil
        self.tick = nil

        if self.fullClose then self:destroy() end
        return true
      end
    end
end

function CarWash:render()
    if self:animate() then return end

    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 4)
    dxDrawImage((sx - 148/zoom)/2, guiInfo.y + 20/zoom, 148/zoom, 130/zoom, self.textures.logo, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))

    for i, v in pairs(guiInfo.options) do
        if self:isMouseInPosition(guiInfo.x + 20/zoom, guiInfo.y + 170/zoom + 75/zoom * (i-1), guiInfo.w - 40/zoom, 70/zoom) then
            self:drawBackground(guiInfo.x + 20/zoom, guiInfo.y + 170/zoom + 75/zoom * (i-1), guiInfo.w - 40/zoom, 70/zoom, tocolor(57, 57, 57, 255 * self.alpha), 4)
        else
            self:drawBackground(guiInfo.x + 20/zoom, guiInfo.y + 170/zoom + 75/zoom * (i-1), guiInfo.w - 40/zoom, 70/zoom, tocolor(47, 47, 47, 255 * self.alpha), 4)
        end

        if v.img then
            dxDrawImage(guiInfo.x + 30/zoom, guiInfo.y + 173/zoom + 75/zoom * (i-1), 64/zoom, 64/zoom, v.img, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
        end
        if v.longText then
            dxDrawText(v.text, guiInfo.x + 110/zoom, guiInfo.y + 173/zoom + 75/zoom * (i-1), guiInfo.x + guiInfo.w - 40/zoom, guiInfo.y + 200/zoom + 75/zoom * (i-1), tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.main, "left", "top")

        else
            dxDrawText(v.text, guiInfo.x + 110/zoom, guiInfo.y + 183/zoom + 75/zoom * (i-1), guiInfo.x + guiInfo.w - 40/zoom, guiInfo.y + 200/zoom + 75/zoom * (i-1), tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.main, "left", "top")
        end

        dxDrawText(v.desc, guiInfo.x + 110/zoom, guiInfo.y + 200/zoom + 75/zoom * (i-1), guiInfo.x + guiInfo.w - 40/zoom, guiInfo.y + 230/zoom + 75/zoom * (i-1), tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.desc, "left", "center", true, true)
        dxDrawText(string.format("$%d", v.price), guiInfo.x + 110/zoom, guiInfo.y + 200/zoom + 75/zoom * (i-1), guiInfo.x + guiInfo.w - 30/zoom, guiInfo.y + 235/zoom + 75/zoom * (i-1), tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.price, "right", "bottom", true, true)
    end
end



function CarWash:buttonClick(btn)
    if self.state ~= "opened" then return end
    if btn == self.exitButton then
        self:close()
    end
end

function CarWash:destroyNoti()
    if not self.noti then return end
    exports.TR_noti:destroy(self.noti)
    self.noti = nil
end

function CarWash:createNoti(text, time, static)
    if self.noti then self:destroyNoti() return end
    self.noti = exports.TR_noti:create(text, "carwash", time, static)
end

function CarWash:onClick(...)
    if exports.TR_dx:isResponseEnabled() then return end
    if self.state ~= "opened" then return end
    if arg[1] ~= "left" or arg[2] ~= "down" then return end

    for i, v in pairs(guiInfo.options) do
        if self:isMouseInPosition(guiInfo.x + 20/zoom, guiInfo.y + 170/zoom + 75/zoom * (i-1), guiInfo.w - 40/zoom, 70/zoom) then
            local veh = getPedOccupiedVehicle(localPlayer)
            triggerServerEvent("createPayment", resourceRoot, v.price, "playerPayForWasher", {self.washerIndex, veh})
            self.selected = v
            break
        end
    end
end

function CarWash:checkOpen()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then self:close() return end
    if getPedOccupiedVehicleSeat(localPlayer) ~= 0 then self:close() return end

    if not isElementFrozen(veh) then return end
    if getVehicleEngineState(veh) then return end

    if not exports.TR_dx:canOpenGUI() then return end

    self:open()
end

function CarWash:response(state)
    exports.TR_dx:setResponseEnabled(false)

    if state then
        local veh = getPedOccupiedVehicle(localPlayer)
        local parts = split(self.selected.desc, ",")
        self:setupWashing(1, parts)

        self.tick = getTickCount()
        self.state = "closing"

        exports.TR_dx:hideButton(self.exitButton)
        removeEventHandler("guiButtonClick", root, self.func.buttonClick)
        removeEventHandler("onClientClick", root, self.func.onClick)

        showCursor(false)

        setTimer(self.func.setVehicleClean, 52000, 1)

        exports.TR_achievements:addAchievements("vehicleClean")
    end
end

function CarWash:setVehicleClean()
    self:destroy()
    showCursor(false)

    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return end
    local grunge = getElementData(veh, "vehicleGrunge") or 0
    local newGrunge = grunge - self.selected.cleanAmount
    setElementData(veh, "vehicleGrunge", math.max(newGrunge, 0))
end

function CarWash:setupWashing(current, texts)
    if not self.noti then
        self.noti = exports.TR_noti:create({self.selected.text, texts[1]}, "carwash", 52)
    else
        exports.TR_noti:setText(self.noti, self:firstToUpper(string.sub(texts[current], 2, string.len(texts[current]))))
    end
    if current >= #texts then return end
    setTimer(self.func.setupWashing, 52000/#texts, 1, current + 1, texts)
end

function CarWash:firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

function CarWash:drawBackground(x, y, rx, ry, color, radius, post)
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

function CarWash:isMouseInPosition(x, y, width, height)
    if (not isCursorShowing()) then return false end
    local cx, cy = getCursorPosition()
    local cx, cy = (cx*sx), (cy*sy)
    if (cx >= x and cx <= x + width) and (cy >= y and cy <= y + height) then return true end
    return false
end

function openCarWash(...)
    if guiInfo.panel then return end
    guiInfo.panel = CarWash:create(...)
end

function closeCarWash()
    if not guiInfo.panel then return end
    guiInfo.panel:close()
end

function responseCarWash(...)
    if not guiInfo.panel then return end
    guiInfo.panel:response(...)
end
addEvent("responseCarWash", true)
addEventHandler("responseCarWash", root, responseCarWash)

function setWasherEffect(index, veh)
    if not index or not veh or not isElement(veh) then return end
    if not isElementStreamedIn(veh) then return end
    guiInfo.washers[index] = {}
    for i, v in pairs(guiInfo.effects) do
        local x, y, z = getPosition(veh, v)
        guiInfo.washers[index][i] = createEffect('carwashspray', x, y, z)
    end
    playSound3D("files/sounds/carwash.mp3", Vector3(getElementPosition(veh)))

    setTimer(destroyWasherEffect, 52000, 1, index)
end
addEvent("setWasherEffect", true)
addEventHandler("setWasherEffect", root, setWasherEffect)

function destroyWasherEffect(index)
    if not guiInfo.washers[index] then return end
    for i, v in pairs(guiInfo.washers[index]) do
        destroyElement(v)
    end
end


function onColShapeHit(plr, md)
    if plr ~= localPlayer or not md then return end
    if not getPedOccupiedVehicle(localPlayer) then return end
    if getPedOccupiedVehicleSeat(localPlayer) ~= 0 then return end

    local index = getElementData(source, "index")
    openCarWash(index)
end

function onColShapeLeave(plr, md)
    if plr ~= localPlayer or not md then return end
    closeCarWash()
end

function createWashers()
    for i, v in pairs(settings.washers) do
        local sphere = createColSphere(v.pos, 2)
        local marker = createMarker(v.pos - Vector3(0, 0, 1), "cylinder", 1, 38, 169, 224, 0)
        local blip = createBlip(v.pos, 0, 2, 38, 169, 224)
        setElementData(marker, "markerIcon", "carwash", false)
        setElementData(blip, "icon", 47, false)
        setElementData(sphere, "index", i, false)
    end

    addEventHandler("onClientColShapeHit", resourceRoot, onColShapeHit)
    addEventHandler("onClientColShapeLeave", resourceRoot, onColShapeLeave)
end
createWashers()

function getPosition(element, vec)
	local rot = Vector3(getElementRotation(element))
	local mat = Matrix(Vector3(getElementPosition(element)), rot)
	local newPos = mat:transformPosition(vec)
	return newPos.x, newPos.y, newPos.z
end

-- createEffect('carwashspray', getElementPosition( getLocalPlayer() ) )

-- setElementAlpha(localPlayer, 0)


exports.TR_dx:setOpenGUI(false)