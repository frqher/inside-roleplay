local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 500/zoom)/2,
    y = (sy - 520/zoom)/2,
    w = 500/zoom,
    h = 520/zoom,
}

Mechanic = {}
Mechanic.__index = Mechanic

function Mechanic:create(...)
    local instance = {}
    setmetatable(instance, Mechanic)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function Mechanic:constructor(...)
    self.alpha = 0
    self.price = 0
    self.scroll = 0
    self.repair = {}

    self.player = arg[1]
    self.vehicle = arg[2]

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.charge = exports.TR_dx:getFont(10)

    self.buttons = {}
    self.buttons.exit = exports.TR_dx:createButton(guiInfo.x + 10/zoom, guiInfo.y + guiInfo.h - 50/zoom, 235/zoom, 40/zoom, "Kapalı")
    self.buttons.repair = exports.TR_dx:createButton(guiInfo.x + guiInfo.w - 245/zoom, guiInfo.y + guiInfo.h - 50/zoom, 235/zoom, 40/zoom, "Düzelt ($0.00)")
    exports.TR_dx:setButtonVisible(self.buttons, false)

    self.edits = {}
    self.edits.charge = exports.TR_dx:createEdit(guiInfo.x + 10/zoom, guiInfo.y + guiInfo.h - 100/zoom, 235/zoom, 40/zoom, "Peşinat  (max $150)")
    exports.TR_dx:setEditVisible(self.edits, false)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.click = function(...) self:click(...) end
    self.func.scrollButton = function(...) self:scrollButton(...) end
    self.func.buttonClick = function(...) self:buttonClick(...) end

    self:prepareList()
    self:open()
    return true
end


function Mechanic:open()
    self.state = "opening"
    self.tick = getTickCount()

    exports.TR_dx:showButton(self.buttons)
    exports.TR_dx:showEdit(self.edits)

    showCursor(true)
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientClick", root, self.func.click)
    addEventHandler("onClientKey", root, self.func.scrollButton)
    addEventHandler("guiButtonClick", root, self.func.buttonClick)
end

function Mechanic:close()
    self.state = "closing"
    self.tick = getTickCount()

    exports.TR_dx:hideButton(self.buttons)
    exports.TR_dx:hideEdit(self.edits)

    showCursor(false)
    removeEventHandler("onClientClick", root, self.func.click)
    removeEventHandler("onClientKey", root, self.func.scrollButton)
    removeEventHandler("guiButtonClick", root, self.func.buttonClick)
end

function Mechanic:destroy()
    exports.TR_dx:setOpenGUI(false)
    exports.TR_dx:destroyButton(self.buttons)
    exports.TR_dx:destroyEdit(self.edits)
    removeEventHandler("onClientRender", root, self.func.render)
    guiInfo.mechanic = nil
    self = nil
end


function Mechanic:animate()
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

function Mechanic:render()
    self:animate()
    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 5)
    dxDrawText("Araç tamiri", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")
    dxDrawText("Araç tamirlerinden ekstra kazanacağınız tutarı girin.", guiInfo.x + guiInfo.w/2 + 10/zoom, guiInfo.y + guiInfo.h - 100/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h - 60/zoom, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.charge, "left", "center", true, true)

    self:drawList()
    if #self.repair > 7 then
        local b1 = 350/zoom / #self.repair
        local barY = b1 * self.scroll
        local barHeight = b1 * 7
        dxDrawRectangle(guiInfo.x + guiInfo.w - 8/zoom, guiInfo.y + 50/zoom, 4/zoom, 350/zoom, tocolor(37, 37, 37, 255 * self.alpha))
        dxDrawRectangle(guiInfo.x + guiInfo.w - 8/zoom, guiInfo.y + 50/zoom + barY, 4/zoom, barHeight, tocolor(57, 57, 57, 255 * self.alpha))
    else
        dxDrawRectangle(guiInfo.x + guiInfo.w - 8/zoom, guiInfo.y + 50/zoom, 4/zoom, 350/zoom, tocolor(57, 57, 57, 255 * self.alpha))
    end
end

function Mechanic:drawList()
    for i = 1, 7 do
        if self.repair[i + self.scroll] then
            local alpha = 200
            if self:isMouseInPosition(guiInfo.x, guiInfo.y + 50/zoom + 50/zoom * (i - 1), guiInfo.w - 10/zoom, 50/zoom) then alpha = 255 end
            if self.repair[i + self.scroll].selected then
                dxDrawText(self.repair[i + self.scroll].name, guiInfo.x + 72/zoom, guiInfo.y + 50/zoom + 50/zoom * (i - 1), guiInfo.x, guiInfo.y + 50/zoom + 50/zoom * i, tocolor(212, 175, 55, alpha * self.alpha), 1/zoom, self.fonts.main, "left", "center")
                dxDrawText(string.format("$%.2f", self.repair[i + self.scroll].price), guiInfo.x + 80/zoom, guiInfo.y + 50/zoom + 50/zoom * (i - 1), guiInfo.x + guiInfo.w - 50/zoom, guiInfo.y + 50/zoom + 50/zoom * i, tocolor(212, 175, 55, alpha * self.alpha), 1/zoom, self.fonts.main, "right", "center")
                if self.repair[i + self.scroll].img then
                    dxDrawImage(guiInfo.x + 20/zoom, guiInfo.y + 59/zoom + 50/zoom * (i - 1), 32/zoom, 32/zoom, self.repair[i + self.scroll].img, 0, 0, 0, tocolor(212, 175, 55, alpha * self.alpha))
                end
            else
                dxDrawText(self.repair[i + self.scroll].name, guiInfo.x + 72/zoom, guiInfo.y + 50/zoom + 50/zoom * (i - 1), guiInfo.x, guiInfo.y + 50/zoom + 50/zoom * i, tocolor(255, 255, 255, alpha * self.alpha), 1/zoom, self.fonts.main, "left", "center")
                dxDrawText(string.format("$%.2f", self.repair[i + self.scroll].price), guiInfo.x + 80/zoom, guiInfo.y + 50/zoom + 50/zoom * (i - 1), guiInfo.x + guiInfo.w - 50/zoom, guiInfo.y + 50/zoom + 50/zoom * i, tocolor(200, 200, 200, alpha * self.alpha), 1/zoom, self.fonts.main, "right", "center")
                if self.repair[i + self.scroll].img then
                    dxDrawImage(guiInfo.x + 20/zoom, guiInfo.y + 59/zoom + 50/zoom * (i - 1), 32/zoom, 32/zoom, self.repair[i + self.scroll].img, 0, 0, 0, tocolor(255, 255, 255, alpha * self.alpha))
                end
            end
        end
    end
end

function Mechanic:click(...)
    if arg[1] == "left" and arg[2] == "down" then
        for i = 1, 7 do
            if self.repair[i + self.scroll] then
                if self:isMouseInPosition(guiInfo.x, guiInfo.y + 50/zoom + 50/zoom * (i - 1), guiInfo.w - 10/zoom, 50/zoom) then
                    self.repair[i + self.scroll].selected = not self.repair[i + self.scroll].selected
                    self:updateList()
                    break
                end
            end
        end
    end
end

function Mechanic:scrollButton(...)
    if arg[1] == "mouse_wheel_up" and arg[2] then
        if self.scroll == 0 then return end
        self.scroll = self.scroll - 1

    elseif arg[1] == "mouse_wheel_down" and arg[2] then
        if #self.repair < 7 then return end
        if self.scroll + 7 >= #self.repair then return end
        self.scroll = self.scroll + 1
    end
end

function Mechanic:buttonClick(...)
    if arg[1] == self.buttons.exit then
        self:close()

    elseif arg[1] == self.buttons.repair then
        if getDistanceBetweenPoints3D(Vector3(getElementPosition(localPlayer)), Vector3(getElementPosition(self.player))) > 10 then exports.TR_noti:create("Oyuncu sizden çok uzaklaştı.", "error") return end
        if self.price <= 0 then exports.TR_noti:create("Onarım için bir parça seçmeniz gerekiyor.", "error") return end
        local text = guiGetText(self.edits.charge)
        if string.len(text) < 1 then text = 0 end
        if tonumber(text) == nil then return exports.TR_noti:create("Onarıma eklenen tutar hatalı.", "error") end
        if tonumber(text) < 0 then return exports.TR_noti:create("Onarıma eklenen tutar hatalı.", "error") end
        if tonumber(text) > 150 then return exports.TR_noti:create("Onarıma eklenen miktar, birden fazla olamaz. $150.", "error") end

        exports.TR_noti:create(string.format("Oyuncuya onarım teklifi gönderildi %s.", getPlayerName(self.player)), "info")

        local parts = {}
        for i, v in pairs(self.repair) do
            if v.selected then
                table.insert(parts, {
                    name = v.name,
                    data = v.data,
                })
            end
        end
        triggerServerEvent("offerVehicleFix", resourceRoot, self.player, parts, self.price, tonumber(text))
        self:close()
    end
end

function Mechanic:updateList()
    self.price = 0
    for i, v in pairs(self.repair) do
        if v.selected then
            self.price = self.price + v.price
        end
    end
    exports.TR_dx:setButtonText(self.buttons.repair, string.format("Düzelt ($%.2f)", self.price))
end

function Mechanic:prepareList()
    if not self.vehicle then return end
    local monetary = getVehicleHandling(self.vehicle).monetary
    local health = getElementHealth(self.vehicle)
    if health < 1000 then
        table.insert(self.repair, {
            name = "Motor",
            price = (1000 - health)/1000 * monetary * 0.007,
            data = {type = "engine"},
            img = "files/images/engine.png",
        })
    end

    for i = 5, 6 do
        if getVehiclePanelState(self.vehicle, i) > 0 then
            local name, price, img = self:getPanelData(i)
            table.insert(self.repair, {
                name = name,
                price = price * monetary * 0.0005,
                data = {type = "panel", value = i},
                img = img,
            })
        end
    end

    for i = 0, 5 do
        if getVehicleDoorState(self.vehicle, i) > 0 then
            local name, price, img = self:getDoorData(i)
            table.insert(self.repair, {
                name = name,
                price = price * monetary * 0.0005,
                data = {type = "door", value = i},
                img = img,
            })
        end
    end

    for i = 0, 1 do
        if getVehicleLightState(self.vehicle, i) > 0 then
            local name, price, img = self:getLightData(i)
            table.insert(self.repair, {
                name = name,
                price = price * monetary * 0.0005,
                data = {type = "light", value = i},
                img = img,
            })
        end
    end

    local wheelStates = {getVehicleWheelStates(self.vehicle)}
    for i, v in pairs(wheelStates) do
        if v ~= 0 then
            local name, price, img = self:getWheelData(i)
            table.insert(self.repair, {
                name = name,
                price = price * monetary * 0.0005,
                data = {type = "wheel", value = i},
                img = img,
            })
        end
    end
end

function Mechanic:getDoorData(...)
    if arg[1] == 0 then return "Kaput", 2, "files/images/hood.png" end
    if arg[1] == 1 then return "Bagaj", 2, "files/images/hood.png" end
    if arg[1] == 2 then return "Ön Sol Kapı", 1, "files/images/door.png" end
    if arg[1] == 3 then return "Ön Sağ Kapı", 1, "files/images/door.png" end
    if arg[1] == 4 then return "Arka Sol Kapı", 1, "files/images/door.png" end
    if arg[1] == 5 then return "Arka Sağ Kapı", 1, "files/images/door.png" end
end

function Mechanic:getPanelData(...)
    if arg[1] == 5 then return "Ön Tampon", 2, "files/images/bumper.png" end
    if arg[1] == 6 then return "Arka Tampon", 2, "files/images/bumper.png" end
end

function Mechanic:getLightData(...)
    if arg[1] == 0 then return "Ön Sol Far", 0.5, "files/images/lights.png" end
    if arg[1] == 1 then return "Ön Sağ Far", 0.5, "files/images/lights.png" end
end

function Mechanic:getWheelData(...)
    if arg[1] == 1 then return "Sol Ön Tekerlek", 0.8, "files/images/wheel.png" end
    if arg[1] == 2 then return "Sol Arka Tekerlek", 0.8, "files/images/wheel.png" end
    if arg[1] == 3 then return "Sağ Ön Tekerlek", 0.8, "files/images/wheel.png" end
    if arg[1] == 4 then return "Sağ Arka Tekerlek", 0.8, "files/images/wheel.png" end
end


function Mechanic:drawBackground(x, y, rx, ry, color, radius, post)
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

function Mechanic:isMouseInPosition(x, y, width, height)
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


function createMechanic(...)
    if guiInfo.mechanic then return end
    guiInfo.mechanic = Mechanic:create(...)
end






local positionsFont = exports.TR_dx:getFont(12)
function renderMechanicPositions()
    if getElementInterior(localPlayer) ~= 0 or getElementDimension(localPlayer) ~= 0 then return end
    local plrPos = Vector3(getCameraMatrix())
    local plrInt = getElementInterior(localPlayer)
    local plrDim = getElementDimension(localPlayer)

    for i, v in pairs(getElementsByType("mechanicPosition", resourceRoot, true)) do
        local mechanicPosition = getElementData(v, "mechanicPosition")

        local pos = Vector3(getElementPosition(v))
        local clear = isLineOfSightClear(plrPos, pos, true, false, false, true, true, true)
        if clear then
            local dist = getDistanceBetweenPoints3D(plrPos, pos)
            local scx, scy = getScreenFromWorldPosition(pos + Vector3(0, 0, 0.5))

            if scx and scy and dist < 20 then
                if isElement(mechanicPosition.mechanic) then
                    drawTextShadowed(string.format("#c02ff5[MEKANİK POZİSYONU]\n#ffffffPozisyon Numarası: #888888%d\n#ffffffMekanik: #888888%s", mechanicPosition.ID, mechanicPosition.mechanicName), scx, scy, scx, scy, tocolor(255, 255, 255, 255), 1 * (1 - dist/20), positionsFont, "center", "center", false, false, false, true)
                else
                    drawTextShadowed(string.format("#c02ff5[MEKANİK POZİSYONU]\n#ffffffPozisyon Numarası: #888888%d\n#ffffffMekanik: #888888%s", mechanicPosition.ID, "Yok"), scx, scy, scx, scy, tocolor(255, 255, 255, 255), 1 * (1 - dist/20), positionsFont, "center", "center", false, false, false, true)
                end
                
            end
        end
    end
end

function removeColor(text)
    while string.find(text, "#%x%x%x%x%x%x") do
      text = string.gsub(text, "#%x%x%x%x%x%x", "")
    end
    return text
end

function drawTextShadowed(text, x, y, w, h, color, scale, font, vert, hori, clip, brake, post, colored)
	local withoutColor = removeColor(text)
	dxDrawText(withoutColor, x + 1, y + 1, w + 1, h + 1, tocolor(0, 0, 0, 100), scale, font, vert, hori, clip, brake, post)
	dxDrawText(text, x, y, w, h, color, scale, font, vert, hori, clip, brake, post, colored)
end
addEventHandler("onClientRender", root, renderMechanicPositions)