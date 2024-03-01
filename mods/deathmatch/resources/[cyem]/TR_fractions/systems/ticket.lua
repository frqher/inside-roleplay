local sx, sy = guiGetScreenSize()

local guiInfo = {
    x = (sx - 530/zoom)/2,
    y = (sy - 510/zoom)/2,
    w = 530/zoom,
    h = 510/zoom,

    options = {
        {
            name = "D-01",
            price = 400,
        },
        {
            name = "D-02",
            price = 400,
        },
        {
            name = "D-03",
            price = 1200,
        },
        {
            name = "D-04",
            price = 1000,
        },
        {
            name = "D-05",
            price = 400,
        },
        {
            name = "D-06",
            price = 1000,
        },
        {
            name = "D-07",
            price = 700,
        },
        {
            name = "D-08",
            price = 500,
        },
        {
            name = "D-09",
            price = 300,
        },
        {
            name = "D-10",
            price = 400,
        },
        {
            name = "D-11",
            price = 900,
        },
        {
            name = "D-12",
            price = 700,
        },
        {
            name = "D-13",
            price = 900,
        },
        {
            name = "D-14",
            price = 400,
        },
        {
            name = "D-15",
            price = 3500,
        },
        {
            name = "D-16",
            price = 2000,
        },
        {
            name = "D-17",
            price = 1100,
        },
        {
            name = "D-18",
            price = 1000,
        },
        {
            name = "D-19",
            price = 500,
        },
        {
            name = "S-20",
            price = 200,
        },
        {
            name = "S-21",
            price = 500,
        },
        {
            name = "S-22",
            price = 400,
        },
        {
            name = "S-23",
            price = 3500,
        },
        {
            name = "S-24",
            price = 500,
        },
        {
            name = "S-25",
            price = 500,
        },
        {
            name = "S-26",
            price = 500,
        },
        {
            name = "S-27",
            price = 700,
        },
        {
            name = "S-28",
            price = 600,
        },
        {
            name = "S-29",
            price = 500,
        },
        {
            name = "S-30",
            price = 1000,
        },
        {
            name = "S-31",
            price = 700,
        },
        {
            name = "S-32",
            price = 500,
        },
        {
            name = "S-33",
            price = 1500,
        },
        {
            name = "S-34",
            price = 600,
        },
        {
            name = "S-35",
            price = 1000,
        },
        {
            name = "S-36",
            price = 2000,
        },
        {
            name = "S-37",
            price = 2500,
        },
        {
            name = "S-38",
            price = 500,
        },
        {
            name = "S-39",
            price = 700,
        },
        {
            name = "P-40",
            price = 4000,
        },
        {
            name = "P-41",
            price = 300,
        },
        {
            name = "P-42",
            price = 500,
        },
        {
            name = "P-43",
            price = 1000,
        },
        {
            name = "P-44",
            price = 1000,
        },
        {
            name = "P-45",
            price = 200,
        },
        {
            name = "P-46",
            price = 400,
        },
        {
            name = "P-48",
            price = 2500,
        },
    }
}

Ticket = {}
Ticket.__index = Ticket

function Ticket:create(...)
    local instance = {}
    setmetatable(instance, Ticket)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function Ticket:constructor(...)
    self.alpha = 0

    self.player = arg[1]
    self.playerName = getPlayerName(arg[1])
    self.toPay = 0
    self.options = guiInfo.options
    self.scroll = 0

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.info = exports.TR_dx:getFont(12)

    self.buttons = {}
    self.buttons.exit = exports.TR_dx:createButton(guiInfo.x + 10/zoom, guiInfo.y + guiInfo.h - 50/zoom, 250/zoom, 40/zoom, "Anuluj")
    self.buttons.submit = exports.TR_dx:createButton(guiInfo.x + guiInfo.w - 260/zoom, guiInfo.y + guiInfo.h - 50/zoom, 250/zoom, 40/zoom, "Wystaw mandat")
    exports.TR_dx:setButtonVisible(self.buttons, false)
    exports.TR_dx:showButton(self.buttons)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.scrollKey = function(...) self:scrollKey(...) end
    self.func.clickKey = function(...) self:clickKey(...) end
    self.func.buttonClick = function(...) self:buttonClick(...) end

    self:open()
    return true
end

function Ticket:open()
    for i, v in pairs(self.options) do
        v.selected = nil
    end

    self.tick = getTickCount()
    self.state = "opening"

    showCursor(true)

    bindKey("mouse_wheel_up", "down", self.func.scrollKey)
    bindKey("mouse_wheel_down", "down", self.func.scrollKey)

    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientClick", root, self.func.clickKey)
    addEventHandler("guiButtonClick", root, self.func.buttonClick)
end

function Ticket:close()
    self.tick = getTickCount()
    self.state = "closing"

    exports.TR_dx:hideButton(self.buttons)

    showCursor(false)

    unbindKey("mouse_wheel_up", "down", self.func.scrollKey)
    unbindKey("mouse_wheel_down", "down", self.func.scrollKey)

    removeEventHandler("onClientClick", root, self.func.clickKey)
    removeEventHandler("guiButtonClick", root, self.func.buttonClick)
end

function Ticket:destroy()
    removeEventHandler("onClientRender", root, self.func.render)

    exports.TR_dx:destroyButton(self.buttons)
    exports.TR_dx:setOpenGUI(false)

    guiInfo.ticket = nil
    self = nil
end


function Ticket:animate()
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

function Ticket:render()
    self:animate()

    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 4)
    dxDrawText("Wystawianie mandatu", guiInfo.x + 10/zoom, guiInfo.y + 10/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h - 10/zoom, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "top", true, true)
    dxDrawText(string.format("Gracz: %s\nKwota mandatu: $%.2f", self.playerName, self.toPay), guiInfo.x + 10/zoom, guiInfo.y + 40/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h - 10/zoom, tocolor(220, 220, 200, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "top", true, true)

    for i = 1, 9 do
        local v = self.options[i + self.scroll]
        if v then
            if self:isMouseInPosition(guiInfo.x + 10/zoom, guiInfo.y + 90/zoom + (i-1) * 40/zoom, guiInfo.w - 24/zoom, 40/zoom) then
                dxDrawRectangle(guiInfo.x + 10/zoom, guiInfo.y + 90/zoom + (i-1) * 40/zoom, guiInfo.w - 24/zoom, 40/zoom, tocolor(37, 37, 37, 255 * self.alpha))
            else
                dxDrawRectangle(guiInfo.x + 10/zoom, guiInfo.y + 90/zoom + (i-1) * 40/zoom, guiInfo.w - 24/zoom, 40/zoom, tocolor(27, 27, 27, 255 * self.alpha))
            end

            if v.selected then
                dxDrawText(v.name, guiInfo.x + 20/zoom, guiInfo.y + 90/zoom + (i-1) * 40/zoom, guiInfo.x + 10/zoom, guiInfo.y + 90/zoom + i * 40/zoom, tocolor(184, 153, 53, 255 * self.alpha), 1/zoom, self.fonts.info, "left", "center")
                dxDrawText(string.format("$%.2f", v.price), guiInfo.x + 20/zoom, guiInfo.y + 90/zoom + (i-1) * 40/zoom, guiInfo.x + guiInfo.w - 24/zoom, guiInfo.y + 90/zoom + i * 40/zoom, tocolor(184, 153, 53, 255 * self.alpha), 1/zoom, self.fonts.info, "right", "center")

            else
                dxDrawText(v.name, guiInfo.x + 20/zoom, guiInfo.y + 90/zoom + (i-1) * 40/zoom, guiInfo.x + 10/zoom, guiInfo.y + 90/zoom + i * 40/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.info, "left", "center")
                dxDrawText(string.format("$%.2f", v.price), guiInfo.x + 20/zoom, guiInfo.y + 90/zoom + (i-1) * 40/zoom, guiInfo.x + guiInfo.w - 24/zoom, guiInfo.y + 90/zoom + i * 40/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.info, "right", "center")
            end
        end
    end

    if #self.options > 9 then
        local b1 = 360/zoom / #self.options
        local barY = b1 * self.scroll
        local barHeight = b1 * 9
        dxDrawRectangle(guiInfo.x + guiInfo.w - 14/zoom, guiInfo.y + 90/zoom, 4/zoom, 360/zoom, tocolor(47, 47, 47, 255 * self.alpha))
        dxDrawRectangle(guiInfo.x + guiInfo.w - 14/zoom, guiInfo.y + 90/zoom + barY, 4/zoom, barHeight, tocolor(67, 67, 67, 255 * self.alpha))
    else
        dxDrawRectangle(guiInfo.x + guiInfo.w - 14/zoom, guiInfo.y + 90/zoom, 4/zoom, 360/zoom, tocolor(67, 67, 67, 255 * self.alpha))
    end
end




function Ticket:buttonClick(...)
    if arg[1] == self.buttons.exit then
        self:close()

    elseif arg[1] == self.buttons.submit then
        if self.toPay == 0 then exports.TR_noti:create("Musisz wybrać chociaż jeden powód wystawienia mandatu.", "error") return end
        if self.selectedCount > 6 then exports.TR_noti:create("Możesz wybrać maksymalnie 6 wykroczeń.", "error") return end

        exports.TR_dx:setResponseEnabled(true)
        triggerServerEvent("givePlayerTicket", resourceRoot, self.player, self.toPay)
    end
end


function Ticket:recalculatePrice()
    self.toPay = 0
    self.selectedCount = 0

    for i, v in pairs(self.options) do
        if v.selected then
            self.toPay = self.toPay + v.price
            self.selectedCount = self.selectedCount + 1
        end
    end
end

function Ticket:clickKey(...)
    if not self:isMouseInPosition(guiInfo.x + 10/zoom, guiInfo.y + 90/zoom, guiInfo.w - 20/zoom, 360/zoom) or arg[1] ~= "left" or arg[2] ~= "down" then return end

    for i = 1, 9 do
        local v = self.options[i + self.scroll]
        if v then
            if self:isMouseInPosition(guiInfo.x + 10/zoom, guiInfo.y + 90/zoom + (i-1) * 40/zoom, guiInfo.w - 24/zoom, 40/zoom) then
                v.selected = not v.selected
                self:recalculatePrice()
            end
        end
    end
end

function Ticket:scrollKey(...)
    if not self:isMouseInPosition(guiInfo.x + 10/zoom, guiInfo.y + 90/zoom, guiInfo.w - 20/zoom, 360/zoom) then return end

    if arg[1] == "mouse_wheel_up" then
        if self.scroll == 0 then return end
        self.scroll = self.scroll - 1

    elseif arg[1] == "mouse_wheel_down" then
        if self.scroll >= #self.options - 9 then return end
        self.scroll = self.scroll + 1
    end
end

function Ticket:response()
    exports.TR_dx:setResponseEnabled(false)
    self:close()
    exports.TR_noti:create(string.format("Pomyślnie nałożono mandat na gracza %s.", getPlayerName(self.player)), "success")
end

function Ticket:drawBackground(x, y, rx, ry, color, radius, post)
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

function Ticket:isMouseInPosition(x, y, width, height)
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


function openTicketWindow(player)
    if guiInfo.ticket then return end
    guiInfo.ticket = Ticket:create(player)
end

function ticketResponse(player)
    if not guiInfo.ticket then return end
    guiInfo.ticket:response()
end
addEvent("ticketResponse", true)
addEventHandler("ticketResponse", root, ticketResponse)