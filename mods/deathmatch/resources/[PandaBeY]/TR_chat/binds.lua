local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 800/zoom)/2,
    y = (sy - 510/zoom)/2,
    w = 800/zoom,
    h = 510/zoom,

    maxBinds = 10,

    blockedKeys = {
        ["mouse1"] = true,
        ["mouse2"] = true,
        ["mouse3"] = true,
        ["mouse_wheel_up"] = true,
        ["mouse_wheel_down"] = true,

        ["t"] = true,
        ["i"] = true,
        ["r"] = true,
        ["e"] = true,
        ["q"] = true,
        ["f"] = true,
        ["g"] = true,
        ["w"] = true,
        ["a"] = true,
        ["s"] = true,
        ["d"] = true,

        ["["] = true,
        ["]"] = true,
        ["`"] = true,
        ["\\"] = true,

        ["escape"] = true,
        ["backspace"] = true,
        ["tab"] = true,
        ["lalt"] = true,
        ["ralt"] = true,
        ["enter"] = true,
        ["space"] = true,
        ["pgup"] = true,
        ["pgdn"] = true,
        ["end"] = true,
        ["home"] = true,
        ["delete"] = true,
        ["insert"] = true,
        ["lshift"] = true,
        ["rshift"] = true,
        ["lctrl"] = true,
        ["rctrl"] = true,
        ["pause"] = true,
        ["capslock"] = true,
        ["scroll"] = true,

        ["num_enter"] = true,
        ["num_dec"] = true,

        ["F1"] = true,
        ["F2"] = true,
        ["F3"] = true,
        ["F4"] = true,
        ["F5"] = true,
        ["F6"] = true,
        ["F7"] = true,
        ["F8"] = true,
        ["F9"] = true,
        ["F10"] = true,
        ["F11"] = true,
        ["F12"] = true,
    },

    numpad = {
        ["num_0"] = "num0",
        ["num_1"] = "num1",
        ["num_2"] = "num2",
        ["num_3"] = "num3",
        ["num_4"] = "num4",
        ["num_5"] = "num5",
        ["num_6"] = "num6",
        ["num_7"] = "num7",
        ["num_8"] = "num8",
        ["num_9"] = "num9",
        ["num_mul"] = "*",
        ["num_add"] = "+",
        ["num_sep"] = "sep",
        ["num_sub"] = "-",
        ["num_div"] = "/",

    }
}

BindManager = {}
BindManager.__index = BindManager

function BindManager:create()
    local instance = {}
    setmetatable(instance, BindManager)
    if instance:constructor() then
        return instance
    end
    return true
end

function BindManager:constructor()
    self.binds = {}

    self.func = {}
    self.func.render = function() self:render() end
    self.func.mouseClick = function(...) self:mouseClick(...) end
    self.func.buttonClick = function(...) self:buttonClick(...) end
    self.func.keyClick = function(...) self:keyClick(...) end

    self:loadBinds()

    addEventHandler("onClientKey", root, self.func.keyClick)
    return true
end

function BindManager:open()
    if not exports.TR_dx:canOpenGUI() then return end
    exports.TR_dx:setOpenGUI(true)
    setChatBlocked(true)

    self.fonts = {}
    self.fonts.title = exports.TR_dx:getFont(14)
    self.fonts.small = exports.TR_dx:getFont(10)

    self.alpha = 0
    self.tick = getTickCount()
    self.state = "opening"

    self:updateEdits(true)

    self.buttons = {}
    self.buttons.close = exports.TR_dx:createButton(guiInfo.x + (guiInfo.w - 250/zoom)/2, guiInfo.y + guiInfo.h - 50/zoom, 250/zoom, 40/zoom, "Zapisz i zamknij")
    exports.TR_dx:setButtonVisible(self.buttons.close, false)
    exports.TR_dx:showButton(self.buttons.close)

    setTimer(function()
        showCursor(true)
    end, 100, 1)
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientClick", root, self.func.mouseClick)
    addEventHandler("guiButtonClick", root, self.func.buttonClick)
end

function BindManager:close()
    setChatBlocked(false)
    exports.TR_dx:hideButton(self.buttons)
    exports.TR_dx:hideEdit(self.edits)

    self.tick = getTickCount()
    self.state = "closing"

    showCursor(false)
    removeEventHandler("onClientClick", root, self.func.mouseClick)
    removeEventHandler("guiButtonClick", root, self.func.buttonClick)
end

function BindManager:destroy()
    exports.TR_dx:setOpenGUI(false)
    exports.TR_dx:destroyButton(self.buttons)
    exports.TR_dx:destroyEdit(self.edits)
    self.edits = nil

    self.fonts = nil
    removeEventHandler("onClientRender", root, self.func.render)
end


function BindManager:animate()
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

        self:destroy()
        return true
      end
    end
end

function BindManager:render()
    self:animate()
    if not self.fonts then return end

    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 5)
    dxDrawText("Edytor bindów", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.title, "center", "center")

    self:drawBindsList()
    self:renderProperty()
end

function BindManager:drawBindsList()
    for i = 1, guiInfo.maxBinds do
        if self.binds[i] then
            local key = self:getKeyName(self.binds[i].key)
            dxDrawText(string.format("Tuş #%d", i), guiInfo.x + 20/zoom, guiInfo.y + 50/zoom + (i-1) * 40/zoom, guiInfo.x + guiInfo.w, guiInfo.y + 90/zoom + (i-1) * 40/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.title, "left", "center")
            dxDrawText(string.format("Anahtar: %s", key), guiInfo.x + 130/zoom, guiInfo.y + 50/zoom + (i-1) * 40/zoom, guiInfo.x + guiInfo.w, guiInfo.y + 90/zoom + (i-1) * 40/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.title, "left", "center")

            if self:isMouseInPosition(guiInfo.x + guiInfo.w - 40/zoom, guiInfo.y + 58/zoom + (i-1) * 40/zoom, 24/zoom, 24/zoom) then
                dxDrawImage(guiInfo.x + guiInfo.w - 40/zoom, guiInfo.y + 58/zoom + (i-1) * 40/zoom, 24/zoom, 24/zoom, "files/images/delete.png", 0, 0, 0, tocolor(220, 220, 220, 255 * self.alpha))
            else
                dxDrawImage(guiInfo.x + guiInfo.w - 40/zoom, guiInfo.y + 58/zoom + (i-1) * 40/zoom, 24/zoom, 24/zoom, "files/images/delete.png", 0, 0, 0, tocolor(170, 170, 170, 255 * self.alpha))
            end

            local text = guiGetText(self.edits[i])
            self.binds[i].value = text
        end
    end

    if guiInfo.maxBinds > #self.binds then
        if self:isMouseInPosition(guiInfo.x + (guiInfo.w - 32/zoom)/2, guiInfo.y + 54/zoom + #self.binds * 40/zoom, 32/zoom, 32/zoom) and not self.property then
            dxDrawImage(guiInfo.x + (guiInfo.w - 32/zoom)/2, guiInfo.y + 54/zoom + #self.binds * 40/zoom, 32/zoom, 32/zoom, "files/images/plus.png", 0, 0, 0, tocolor(200, 200, 200, 255 * self.alpha))
        else
            dxDrawImage(guiInfo.x + (guiInfo.w - 32/zoom)/2, guiInfo.y + 54/zoom + #self.binds * 40/zoom, 32/zoom, 32/zoom, "files/images/plus.png", 0, 0, 0, tocolor(170, 170, 170, 255 * self.alpha))
        end
    end
end

function BindManager:renderProperty()
    if not self.property then return end
    self:drawBackground(self.property.x, self.property.y, self.property.w, self.property.h, tocolor(27, 27, 27, 255 * self.alpha), 5, true)
    dxDrawText(self.property.title, self.property.x, self.property.y, self.property.x + self.property.w, self.property.y + 50/zoom, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.title, "center", "center", false, false, true)

    if self.property.type == "detectKey" then
        local pressed = self:getKeyPressed()
        dxDrawText(string.format("%s", pressed and string.format("%s +", pressed) or "Okuma..."), self.property.x, self.property.y + 50/zoom, self.property.x + self.property.w, self.property.y + 40/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.title, "center", "top", false, false, true)
        dxDrawText("Klavyenizden eklemek istediğiniz düğmeyi seçin yoksa ESCAPE tuşuna basın.", self.property.x + 10/zoom, self.property.y + 80/zoom, self.property.x + self.property.w - 10/zoom, self.property.y + 150/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.small, "center", "top", true, true, true)
    end
end


function BindManager:mouseClick(...)
    if arg[1] == "left" and arg[2] == "down" then
        if guiInfo.maxBinds > #self.binds then
            if self:isMouseInPosition(guiInfo.x + (guiInfo.w - 32/zoom)/2, guiInfo.y + 54/zoom + #self.binds * 40/zoom, 32/zoom, 32/zoom) and not self.property then
                local plrData = getElementData(localPlayer, "characterData")
                -- if not self:canUseBind(#self.binds + 1) then
                --     exports.TR_noti:create("Aby móc dodać więcej bindów ulepsz swoje konto.", "error")
                --     return
                -- end
                self:openProperty((sx - 300/zoom)/2, (sy - 150/zoom)/2, 300/zoom, 150/zoom, "Tuş Seçimi", "detectKey")
            end
        end

        for i = 1, guiInfo.maxBinds do
            if self.binds[i] then
                if self:isMouseInPosition(guiInfo.x + guiInfo.w - 40/zoom, guiInfo.y + 58/zoom + (i-1) * 40/zoom, 24/zoom, 24/zoom) then

                    table.remove(self.binds, i)
                    self:updateEdits()
                    break
                end
            end
        end
    end
end

function BindManager:updateEdits(show)
    if self.edits then exports.TR_dx:destroyEdit(self.edits) end
    self.edits = {}
    for i = 1, guiInfo.maxBinds do
        if self.binds[i] then
            self.edits[i] = exports.TR_dx:createEdit(guiInfo.x + 350/zoom, guiInfo.y + 55/zoom + (i-1) * 40/zoom, guiInfo.w - 406/zoom, 30/zoom, "Wiadomość / komenda")
            exports.TR_dx:setEditText(self.edits[i], self.binds[i].value)
        end
    end

    if show then
        exports.TR_dx:setEditVisible(self.edits, false)
        exports.TR_dx:showEdit(self.edits)
    end
end

function BindManager:getKeyPressed()
    if getKeyState("lalt") or getKeyState("ralt") then return "alt" end
    if getKeyState("lshift") or getKeyState("rshift") then return "shift" end
    if getKeyState("lctrl") or getKeyState("rctrl") then return "ctrl" end
    return false
end

function BindManager:openProperty(x, y, w, h, title, type)
    self.property = {
        x = x,
        y = y,
        w = w,
        h = h,
        title = title,
        type = type,
    }

    exports.TR_dx:setResponseEnabled(true, "Dodawanie binda")
end

function BindManager:closeProperty()
    self.property = nil
    exports.TR_dx:setResponseEnabled(false)
end


function BindManager:keyClick(...)
    if arg[2] then
        if self.property then
            if self.property.type == "detectKey" then
                if arg[1] == "escape" then self:closeProperty(); cancelEvent() end
                if guiInfo.blockedKeys[arg[1]] then return end
                if guiInfo.numpad[arg[1]] then arg[1] = guiInfo.numpad[arg[1]] end

                local pressed = self:getKeyPressed()
                local key = pressed and string.format("%s_%s", pressed, arg[1]) or arg[1]

                if not self:canAddBind(key) then return end

                table.insert(self.binds, {
                    value = "",
                    key = key,
                })

                self:closeProperty()
                self:updateEdits()
            end
            return
        end

        -- Use binds
        if not self.state then
            if not exports.TR_dx:canOpenGUI() then return end
            if exports.TR_dx:isResponseEnabled() then return end
            if guiInfo.blockedKeys[arg[1]] then return end
            if guiInfo.numpad[arg[1]] then arg[1] = guiInfo.numpad[arg[1]] end

            local pressed = self:getKeyPressed()
            local key = pressed and string.format("%s_%s", pressed, arg[1]) or arg[1]

            for i, v in pairs(self.binds) do
                if v.key == key then
                    if not self:canUseBind() then return end
                    writeChat(v.value)
                    self.slowBind = getTickCount()
                end
            end
        end
    end
end

function BindManager:canUseBind()
    if isCursorShowing() then return false end
    if self.slowBind then
        if (getTickCount() - self.slowBind)/5000 < 1 then
            exports.TR_noti:create("Biraz daha yavaş haraket etmelisin.", "info")
            return false
        end
    end

    return true
end

function BindManager:buttonClick(...)
    if arg[1] == self.buttons.close then
        self:saveBinds()
        self:close()
    end
end

function BindManager:getKeyName(key)
    if string.find(key, "_") then
        local keys = split(key, "_")
        return string.format("%s + %s", keys[1], keys[2])
    end
    return key
end

function BindManager:canAddBind(key)
    for i, v in pairs(self.binds) do
        if v.key == key then
            exports.TR_noti:create("Bir tuşa ikinci bir tuş ekleyemezsiniz", "error")
            return false
        end
    end
    return true
end

function BindManager:drawBackground(x, y, rx, ry, color, radius, post)
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

function BindManager:isMouseInPosition(psx,psy,pssx,pssy)
    if not isCursorShowing() then return end
    cx,cy=getCursorPosition()
    cx,cy=cx*sx,cy*sy
    if cx >= psx and cx <= psx+pssx and cy >= psy and cy <= psy+pssy then
        return true,cx,cy
    else
      return false
    end
end

function BindManager:loadBinds()
    local xml = xmlLoadFile("binds.xml")
    if not xml then
        xml = xmlCreateFile("binds.xml", "binds")
        xmlSaveFile(xml)
        xmlUnloadFile(xml)
        return
    end

    local bindedKeys = {}
    local bindedCount = 0

    for _, node in pairs(xmlNodeGetChildren(xml)) do
        local value = xmlNodeGetValue(node)
        local key = xmlNodeGetAttribute(node, "key")

        if value and key then
            if not guiInfo.blockedKeys[key] and string.len(value) <= 450 and not bindedKeys[key] and bindedCount < guiInfo.maxBinds then
                table.insert(self.binds, {
                    key = key,
                    value = value,
                })
                bindedKeys[key] = true
                bindedCount = bindedCount + 1
            end
        end
    end

    xmlSaveFile(xml)
    xmlUnloadFile(xml)
end

function BindManager:saveBinds()
    if fileExists("binds.xml") then fileDelete("binds.xml") end

    local xml = xmlCreateFile("binds.xml", "binds")

    for _, v in pairs(self.binds) do
        local node = xmlCreateChild(xml, "bind")
        xmlNodeSetValue(node, v.value)
        xmlNodeSetAttribute(node, "key", v.key)
    end

    xmlSaveFile(xml)
    xmlUnloadFile(xml)
end

function createBindManager()
    guiInfo.manager:open()
end
addEvent("createBindManager", true)
addEventHandler("createBindManager", root, createBindManager)

guiInfo.manager = BindManager:create()

exports.TR_dx:setOpenGUI(false)