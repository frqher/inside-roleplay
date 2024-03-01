createdEdits = {}
local editSettings = {
    fonts = {},

    separator = {true, getTickCount()},

    textKeys = {
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
        "num_0", "num_1", "num_2", "num_3", "num_4", "num_5", "num_6", "num_7", "num_8", "num_9",
        "num_mul", "num_add", "num_sep", "num_sub", "num_div", "num_dec", "num_enter",
        "+", "-", "/", "*",
        ",", ".", "<", ">",
        "\\", ";", ":", "[", "]", "_", "-", "=", "!", "@", "#", "$", "%", "^", "&", "(", ")", "=",
        -- Letters
        "q", "w", "e", "r", "t", "y", "u", "i", "o", "p",
        "a", "s", "d", "f", "g", "h", "j", "k", "l",
        "z", "x", "c", "v", "b", "n", "m",
        "space",
    },

    noDiselectInteraction = {
        "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",
        "`", "esc", "pause", "scroll", "insert", "pgup", "pgdn", "enter", "num_enter",
        "lshift", "rshift", "lctrl", "rctrl", "lalt", "ralt", "arrow_u", "arrow_d"
    },

    repeatKeys = {
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
        "num_0", "num_1", "num_2", "num_3", "num_4", "num_5", "num_6", "num_7", "num_8", "num_9",
        "+", "-", "/", "*",
        ",", ".", "<", ">",
        "\\", ";", ":", "[", "]", "_", "-", "=", "!", "@", "#", "$", "%", "^", "&", "(", ")", "=",
        -- Letters
        "q", "w", "e", "r", "t", "y", "u", "i", "o", "p",
        "a", "s", "d", "f", "g", "h", "j", "k", "l",
        "z", "x", "c", "v", "b", "n", "m",
        "space",
        "arrow_l", "arrow_r", "backspace", "delete"
    },
}

local newTable = {}
for i, v in pairs(editSettings.noDiselectInteraction) do
    newTable[v] = true
end
editSettings.noDiselectInteraction = newTable

local newTable = {}
for i, v in pairs(editSettings.textKeys) do
    newTable[tostring(v)] = true
end
editSettings.textKeys = newTable

local newTable = {}
for i, v in pairs(editSettings.repeatKeys) do
    newTable[tostring(v)] = true
end
editSettings.repeatKeys = newTable

Editbox = {}
Editbox.__index = Editbox

function Editbox:create(...)
    local instance = {}
    setmetatable(instance, Editbox)

    if instance:constructor(...) then
        createdEdits[instance.element] = instance
        return instance
    end
    return false
end


function Editbox:constructor(...)
    self.x = arg[1]
    self.y = arg[2]
    self.w = arg[3]
    self.h = arg[4]

    self.rtX = self.x * zoom
    self.rtY = self.y * zoom
    self.rtW = self.w * zoom
    self.rtH = self.h * zoom

    self.placeholder = arg[5] or ""
    self.masked = arg[6] or false
    self.textAlignHorizontal = arg[9] or "left"
    self.textAlignVertical = arg[10] or "bottom"

    self.text = arg[8] or ""

    if zoom ~= 1 or self.h <= 30/zoom then
        self.fontSize = 12
        self.smallFontSize = 12 * self.h
        self.smallTextHeight = 8
    else
        if self.placeholder ~= "" then
            self.fontSize = 12/50 * self.h
            self.smallFontSize = 9/50 * self.h
            self.smallTextHeight = 20/50 * self.h
        else
            self.fontSize = 12
            self.smallFontSize = 9
            self.smallTextHeight = (self.h - 12)/4
        end
    end

    self.caret = utf8.len(self.text)
    self.maxLength = 300

    self.type = "empty"
	self.selectedCaret = false
	self.lastSelectedAnim = 0

    --- STATIC VARIABLES ---
    self.alpha = 1
    self.alphaHover = 0
    self.visible = true
    self.element = guiCreateEdit(self.x, self.y, self.w, self.h, self.text, false)
    guiEditSetMasked(self.element, self.masked)
    guiSetAlpha(self.element, 0)

    self:setImage(arg[7])

    -- guiSetFont(self.element, self:getFont(self.fontSize))

    return true
end

function Editbox:getFont(size)
    if editSettings.fonts[size] then return editSettings.fonts[size] end
    editSettings.fonts[size] = guiCreateFont("files/fonts/font.ttf", size/zoom)
    return editSettings.fonts[size]
end

function Editbox:destroy()
    createdEdits[self.element] = nil
    destroyElement(self.element)
    self = nil

    return true
end

function Editbox:animatePlaceholder()
	if not self.lastSelectedTick then return end
    local progress = (getTickCount() - self.lastSelectedTick) / 100
    self.lastSelectedAnim, _, _ = interpolateBetween(self.lastSelectedFromAnim, 0, 0, self.lastSelectedToAnim, 0, 0, progress, "Linear")
    if progress >= 1 then
		self.lastSelectedAnim = self.lastSelectedToAnim

		self.lastSelectedFromAnim = nil
		self.lastSelectedToAnim = nil
		self.lastSelectedTick = nil
    end
end

function Editbox:draw()
    if not self.visible then return end
    if self.hidding then self:hiddingDraw() end
    if self.showing then self:showingDraw() end
	self:hoverDraw()
	self:animatePlaceholder()

    if self.selected then
        self:drawBackground(self.x, self.y, self.w, self.h, tocolor(42, 42, 42, 255 * self.alpha), 5, true)
    else
        self:drawBackground(self.x, self.y, self.w, self.h, tocolor(37, 37, 37, 255 * self.alpha), 5, true)
        self:drawBackground(self.x, self.y, self.w, self.h, tocolor(47, 47, 47, 255 * self.alpha * self.alphaHover), 5, true)
	end

	if self.selected ~= self.lastSelected then
		self.lastSelected = self.selected
		self.lastSelectedTick = getTickCount()
		self.lastSelectedFromAnim = self.lastSelectedAnim
		self.lastSelectedToAnim = self.selected and 1 or 0
		self.caret = utf8.len(self.text)
	end

    local text = self:getViewText()
    guiSetText(self.element, self.text)
    guiEditSetCaretIndex(self.element, self.caret)

    local textLength = dxGetTextWidth(text, 1/zoom, getFont(self.fontSize))
    local posX = self:getPosForText()

    -- dxDrawText(inspect(editSettings.textKeys), 100, 100, 100, 100, tocolor(255, 255, 255, 255), 1/zoom, "default", "left", "top", false, false, true)

	dxSetRenderTarget(self.renderTarget, true)
	dxSetBlendMode("modulate_add")

    if self.selected then
        dxDrawRectangle(0, 0, self.rtW, self.rtH, tocolor(42, 42, 42, 255))
    else
        dxDrawRectangle(0, 0, self.rtW, self.rtH, tocolor(37, 37, 37, 255))
        dxDrawRectangle(0, 0, self.rtW, self.rtH, tocolor(47, 47, 47, 255 * self.alphaHover))
    end

	if self.selectedCaret then
		if getKeyState("mouse1") then
			self.caret = self:getEditCaretFromMouse()
		end
		if self.selectedCaret == self.caret and not getKeyState("mouse1") then
			self.selectedCaret = nil

		elseif self.selectedCaret > self.caret then
			local caretStart = dxGetTextWidth(utf8.sub(text, 1, self.caret), 1, getFont(self.fontSize))
			local caretEnd = dxGetTextWidth(utf8.sub(text, 1, self.selectedCaret), 1, getFont(self.fontSize))
			local caretSize = caretEnd - caretStart
			dxDrawRectangle(posX + caretStart, self.smallTextHeight, caretSize, self.rtH - (self.smallTextHeight + 8), tocolor(184, 153, 53, self.selected and 60 or 30))

		elseif self.selectedCaret < self.caret then
			local caretStart = dxGetTextWidth(utf8.sub(text, 1, self.selectedCaret), 1, getFont(self.fontSize))
			local caretEnd = dxGetTextWidth(utf8.sub(text, 1, self.caret), 1, getFont(self.fontSize))
			local caretSize = caretEnd - caretStart
			dxDrawRectangle(posX + caretStart, self.smallTextHeight, caretSize, self.rtH - (self.smallTextHeight + 8), tocolor(184, 153, 53, self.selected and 60 or 30))
		end
	end

    if self.placeholder ~= "" then
        if zoom ~= 1 or self.h <= 30/zoom then
            if text == "" then
                dxDrawText(utf8.upper(self.placeholder), posX, 0, self.rtW, self.rtH, tocolor(200, 200, 200, 255), 1, getFont(self.fontSize), self.textAlignHorizontal, "center", true, false, false)
            else
                dxDrawText(text or "", posX, 0, self.rtW, self.rtH, tocolor(200, 200, 200, 255), 1, getFont(self.fontSize), self.textAlignHorizontal, "center", true, false, false)
            end
        else
            if text == "" then
                dxDrawText(utf8.upper(self.placeholder), 0, 0, self.rtW, self.smallTextHeight + (self.rtH - (self.smallTextHeight + 4)) * (1-self.lastSelectedAnim), tocolor(150, 150, 150, 255 * self.lastSelectedAnim), 1, getFont(self.smallFontSize), "left", "center", true, false, false)
                dxDrawText(utf8.upper(self.placeholder), 0, 0, self.rtW, self.smallTextHeight + (self.rtH - (self.smallTextHeight + 4)) * (1-self.lastSelectedAnim), tocolor(150, 150, 150, 255 * (1-self.lastSelectedAnim)), 1 - 0.25 * self.lastSelectedAnim, getFont(self.fontSize), "left", "center", true, false, false)
            else
                dxDrawText(utf8.upper(self.placeholder), 0, 0, self.rtW, self.smallTextHeight, tocolor(150, 150, 150, 255), 1, getFont(self.smallFontSize), "left", "center", true, false, false)
                dxDrawText(text or "", posX, 0, self.rtW, self.rtH - 9, tocolor(200, 200, 200, 255), 1, getFont(self.fontSize), self.textAlignHorizontal, self.textAlignVertical, true, false, false)
            end
        end
    else
        dxDrawText(text or "", posX, 0, self.rtW, self.rtH - 9, tocolor(200, 200, 200, 255), 1, getFont(self.fontSize), self.textAlignHorizontal, self.textAlignVertical, true, false, false)
    end

    if self.selected then
        if editSettings.separator[1] then
            local toCarethLength = dxGetTextWidth(utf8.sub(text, 0, self.caret), 1, getFont(self.fontSize))

            dxDrawRectangle(math.max(math.min(posX + toCarethLength - 2, self.rW - 4), 0), self.smallTextHeight, 2, self.rtH - (self.smallTextHeight + 8), tocolor(200, 200, 200, 200))
        end
	end
	dxSetBlendMode("blend")
    dxSetRenderTarget()

    if self.image then
        if self.selected then
            self:drawBackground(self.x, self.y, self.h, self.h, tocolor(52, 52, 52, 255 * self.alpha), 5, true)
        else
            self:drawBackground(self.x, self.y, self.h, self.h, tocolor(47, 47, 47, 255 * self.alpha), 5, true)
            self:drawBackground(self.x, self.y, self.h, self.h, tocolor(57, 57, 57, 255 * self.alpha * self.alphaHover), 5, true)
        end

        dxDrawImage(self.x + self.h + 10/zoom, self.y + 2/zoom, self.w - self.h - 20/zoom, self.h - 4/zoom, self.renderTarget, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha), true)
        self:clickDraw()
    else
        dxDrawImage(self.x + 10/zoom, self.y + 2/zoom, self.w - 20/zoom, self.h - 4/zoom, self.renderTarget, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha), true)
	end

	if self.masked then
		if self.selected then
			if isMouseInPosition(self.x + self.w - self.h + 15/zoom, self.y + 15/zoom, self.h - 30/zoom, self.h - 30/zoom) then
				dxDrawImage(self.x + self.w - self.h + 15/zoom, self.y + 15/zoom, self.h - 30/zoom, self.h - 30/zoom, self.showHidden and "files/images/show.png" or "files/images/hide.png", 0, 0, 0, tocolor(220, 220, 220, 255 * self.alpha), true)
			else
				dxDrawImage(self.x + self.w - self.h + 15/zoom, self.y + 15/zoom, self.h - 30/zoom, self.h - 30/zoom, self.showHidden and "files/images/show.png" or "files/images/hide.png", 0, 0, 0, tocolor(170, 170, 170, 255 * self.alpha), true)
			end

			if guiData.capsOn then
				dxDrawImage(self.x + self.w - self.h + 10/zoom - (self.h - 34/zoom), self.y + 17/zoom, self.h - 34/zoom, self.h - 34/zoom, "files/images/caps.png", 0, 0, 0, tocolor(170, 170, 170, 255 * self.alpha), true)
			end
		else
			if guiData.capsOn then
				dxDrawImage(self.x + self.w - self.h + 17/zoom, self.y + 17/zoom, self.h - 34/zoom, self.h - 34/zoom, "files/images/caps.png", 0, 0, 0, tocolor(170, 170, 170, 255 * self.alpha), true)
			end
		end
    end

    if self.selected then
        if editSettings.key then
            if editSettings.state == "start" then
                if (getTickCount() - editSettings.tick)/500 >= 1 then
                    editSettings.state = "repeat"
                    editSettings.tick = getTickCount()
                    self:editEnterKey(editSettings.key, true, true)
                end

            elseif editSettings.state == "repeat" then
                if (getTickCount() - editSettings.tick)/50 >= 1 then
                    editSettings.tick = getTickCount()
                    self:editEnterKey(editSettings.key, true, true)
                end
            end
        end
    end
end

function Editbox:drawBackground(x, y, rx, ry, color, radius, post)
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

function Editbox:hoverDraw()
    if isMouseInPosition(self.x, self.y, self.w, self.h) then
        if (not self.hoverAnim or self.hoverAnim == "hidding") and not isResponseEnabled() and not isEscapeOpen() then
            self.hoverAnim = "hovering"
            self.alphaHoverS = self.alphaHover
            self.hTick = getTickCount()
        end
    else
        if self.hoverAnim == "hovering" or self.hoverAnim == "hovered" then
            self.alphaHoverS = self.alphaHover
            self.hoverAnim = "hidding"
            self.hTick = getTickCount()
        end
    end

    if self.hoverAnim == "hovering" then
        local progress = (getTickCount() - self.hTick) / 300
        self.alphaHover, _, _ = interpolateBetween(self.alphaHoverS, 0, 0, 1, 0, 0, progress, "OutQuad")
        if progress >= 1 then
            self.hoverAnim = "hovered"
            self.alphaHover = 1
            self.alphaHoverS = nil
            self.hTick = nil
        end

    elseif self.hoverAnim == "hidding" then
        local progress = (getTickCount() - self.hTick) / 300
        self.alphaHover, _, _ = interpolateBetween(self.alphaHoverS, 0, 0, 0, 0, 0, progress, "OutQuad")
        if progress >= 1 then
            self.hoverAnim = nil
            self.alphaHover = 0
            self.alphaHoverS = nil
            self.hTick = nil
        end
    end
end

function Editbox:hiddingDraw()
    if not self.actionTime then return end
    local progress = (getTickCount() - self.hidding) / self.actionTime
    self.alpha, _, _ = interpolateBetween(self.alphaCurrent, 0, 0, 0, 0, 0, progress, self.easing)
    if progress >= 1 then
        self.alphaCurrent = nil
        self.easing = nil
        self.hidding = nil
        self.actionTime = nil
        self.visible = nil
    end
end

function Editbox:showingDraw()
    if not self.actionTime then return end
    local progress = (getTickCount() - self.showing) / self.actionTime
    self.alpha = interpolateBetween(self.alphaCurrent, 0, 0, 1, 0, 0, progress, self.easing)
    if progress >= 1 then
        self.alphaCurrent = nil
        self.easing = nil
        self.showing = nil
        self.actionTime = nil
        guiSetVisible(self.element, true)
    end
end

function Editbox:clickDraw()
    if self.clickAnim == "increase" then
        local progress = (getTickCount() - self.tick) / 100
        local scale = interpolateBetween(0, 0, 0, 10/zoom, 0, 0, progress, "OutQuad")

        dxDrawImage(self.x + 10/zoom - scale / 2, self.y + 10/zoom - scale / 2, self.h - 20/zoom + scale, self.h - 20/zoom + scale, self.image, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha), true)

        if progress >= 1 then
            self.tick = getTickCount()
            self.clickAnim = "decrease"
        end

    elseif self.clickAnim == "decrease" then
        local progress = (getTickCount() - self.tick) / 200
        local scale = interpolateBetween(10/zoom, 0, 0, 0, 0, 0, progress, "OutQuad")

        dxDrawImage(self.x + 10/zoom - scale / 2, self.y + 10/zoom - scale / 2, self.h - 20/zoom + scale, self.h - 20/zoom + scale, self.image, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha), true)

        if progress >= 1 then
            self.clickAnim = "ended"
            self.tick = nil
        end

    else
        dxDrawImage(self.x + 10/zoom, self.y + 10/zoom, self.h - 20/zoom, self.h - 20/zoom, self.image, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha), true)
    end
end

function Editbox:getViewText()
	local text = self.text
	if self.masked and not self.showHidden then
        text = utf8.gsub(text, ".", "*")
    end

    if self.maxLength then
        local textLen = utf8.len(text)
        if textLen > self.maxLength then
            text = utf8.sub(text, 1/zoom, self.maxLength)

            if self.caret > textLen then
                self.caret = self.maxLength
            end
        end
	end

	return text
end



function Editbox:setText(...)
    self.text = arg[1]
    self.caret = utf8.len(arg[1])
    return true
end

function Editbox:setFontSize(...)
    local fontDif = 12 - arg[1]
    self.fontSize = arg[1]/50 * self.h
    self.smallFontSize = (9 - fontDif)/50 * self.h
    self.smallTextHeight = 20/50 * self.h

    return true
end

function Editbox:setMaxLength(...)
    self.maxLength = arg[1]
    return true
end

function Editbox:setPlaceholder(...)
    self.placeholder = arg[1]
    return true
end

function Editbox:setFocus(...)
	self.selected = arg[1]
	self.showHidden = nil
	guiData.showHiddenDelay = getTickCount()

    if self.selected then
        resetSeparator()
        self.tick = getTickCount()
        self.clickAnim = "increase"
    else
        self.selectedCaret = nil
    end
    return true
end

function Editbox:hide(...)
    if not self.visible then return end
    self.alphaCurrent = self.alpha
    self.hidding = getTickCount()
    self.actionTime = arg[1] or 500
    self.easing = arg[2] or "OutQuad"
    guiSetVisible(self.element, false)

    if self.hover and #self.hoverEffects > 0 then
        self.hoverEffects[#self.hoverEffects].tick = getTickCount()
        self.hoverEffects[#self.hoverEffects].animState = "hidding"
    end
    return true
end

function Editbox:show(...)
    if self.visible then return end
    self.alphaCurrent = self.alpha
    self.showing = getTickCount()
    self.actionTime = arg[1] or 500
    self.easing = arg[2] or "OutQuad"
    self.visible = true
    return true
end

function Editbox:setVisible(...)
    self.visible = arg[1]
    if self.visible then
        self.alpha = 1
        guiSetVisible(self.element, true)
    else
        self.alpha = 0
        guiSetVisible(self.element, false)
    end
end

function Editbox:setOwner(...)
    self.owner = arg[1]
end

function Editbox:getOwner()
    return self.owner
end

function Editbox:setImage(img)
    self.image = img or false

    if isElement(self.renderTarget) then destroyElement(self.renderTarget) end
    if self.image then
        self.renderTarget = dxCreateRenderTarget(self.rtW - 20/zoom - self.rtH, self.rtH - 4/zoom, true)
        self.rW = self.rtW - 20/zoom - self.rtH
    else
        self.renderTarget = dxCreateRenderTarget(self.rtW - 20/zoom, self.rtH - 4/zoom, true)
        self.rW = self.rtW - 20/zoom
    end
end

function Editbox:editEnterKey(...)
    if utf8.find(arg[1], "mouse") then return end
    if editSettings.noDiselectInteraction[arg[1]] then return end
    if not self.selected then return end

    -- if utf8.find(arg[1], )
	if arg[2] then
		local hasCtrl = getKeyState("lctrl") or getKeyState("rctrl")
        local hasShift = getKeyState("lshift") or getKeyState("rshift")
        local hasCtrl = hasCtrl and not getKeyState("ralt") or false

		if arg[1] == "a" and hasCtrl then
			self.caret = utf8.len(self.text)
			self.selectedCaret = 0
			return

		elseif arg[1] == "v" and hasCtrl then
			return

		elseif arg[1] == "c" and hasCtrl then
			if self.selectedCaret then
				local beforeSelection = self.caret < self.selectedCaret and self.caret or self.selectedCaret
				local afterSelection = self.caret < self.selectedCaret and self.selectedCaret or self.caret
                local copyText = utf8.sub(self.text, beforeSelection + 1, afterSelection)

				setClipboard(copyText)
			end
			return

        elseif arg[1] == "arrow_l" then
			if self.selectedCaret and not hasShift then
				self.caret = self.caret < self.selectedCaret and self.caret or self.selectedCaret
				self.selectedCaret = nil
				return
            end
            if self.caret == 0 then return end

            self.caret = math.max(self.caret - 1, 0)
            resetSeparator()

        elseif arg[1] == "arrow_r" then
			if self.selectedCaret and not hasShift then
				self.caret = self.caret < self.selectedCaret and self.selectedCaret or self.caret
				self.selectedCaret = nil
				return
            end

            if self.caret == utf8.len(self.text) then return end

            self.caret = math.min(self.caret + 1, utf8.len(self.text))
            resetSeparator()

		elseif arg[1] == "backspace" then
            if self.caret == 0 and not self.selectedCaret then return end
			if self.selectedCaret then
				local beforeSelection = self.caret < self.selectedCaret and self.caret or self.selectedCaret
				local afterSelection = self.caret < self.selectedCaret and self.selectedCaret or self.caret

				local before = utf8.sub(self.text, 1, beforeSelection)
				local after = utf8.sub(self.text, afterSelection + 1, utf8.len(self.text))
                self.text = before .. after
                self.caret = math.max(math.min(self.caret, self.selectedCaret), 0)

			else
				local before = utf8.sub(self.text, 1, self.caret - 1)
				local after = utf8.sub(self.text, self.caret + 1, utf8.len(self.text))
				self.text = before .. after
				self.caret = math.max(self.caret - 1, 0)
			end
            resetSeparator()

        elseif arg[1] == "delete" then
			if self.caret == utf8.len(self.text) then return end
			if self.selectedCaret then
				local beforeSelection = self.caret < self.selectedCaret and self.caret or self.selectedCaret
				local afterSelection = self.caret < self.selectedCaret and self.selectedCaret or self.caret

				local before = utf8.sub(self.text, 1, beforeSelection)
				local after = utf8.sub(self.text, afterSelection + 1, utf8.len(self.text))
				self.text = before .. after
				self.caret = math.max(math.min(self.caret, self.selectedCaret), 0)

			else
				local before = utf8.sub(self.text, 1, self.caret)
				local after = utf8.sub(self.text, self.caret + 2, utf8.len(self.text))
				self.text = before .. after
			end
            resetSeparator()
        end

        if editSettings.textKeys[arg[1]] then
            if utf8.len(self.text) >= self.maxLength then return end

			local symbol = self:getSymbol(arg[1])
			if self.selectedCaret then
				local beforeSelection = self.caret < self.selectedCaret and self.caret or self.selectedCaret
				local afterSelection = self.caret < self.selectedCaret and self.selectedCaret or self.caret

				local before = utf8.sub(self.text, 1, beforeSelection)
				local after = utf8.sub(self.text, afterSelection + 1, utf8.len(self.text))
				self.text = before .. symbol .. after

			else
				local before = utf8.sub(self.text, 1, self.caret)
				local after = utf8.sub(self.text, self.caret + 1, utf8.len(self.text))
				self.text = before .. symbol .. after
			end

            self.caret = math.min(self.caret + 1, utf8.len(self.text))
        end

        if hasShift then
            if arg[1] == "arrow_l" then
                if self.caret == 0 then return end
                if not self.selectedCaret then
                    self.selectedCaret = self.caret + 1
				end

            elseif arg[1] == "arrow_r" then
                if self.caret == utf8.len(self.text) then return end
				if not self.selectedCaret then
                    self.selectedCaret = self.caret - 1
				end
            else
                self.selectedCaret = nil
            end
        else
            self.selectedCaret = nil
        end

        if not arg[3] and editSettings.repeatKeys[arg[1]] then
            editSettings.key = arg[1]
            editSettings.state = "start"
            editSettings.tick = getTickCount()
        end
    end
end

function Editbox:pasteValue(paste)
	if not self.selected then return end
	if self.selectedCaret then
		local beforeSelection = self.caret < self.selectedCaret and self.caret or self.selectedCaret
		local afterSelection = self.caret < self.selectedCaret and self.selectedCaret or self.caret

		local before = utf8.sub(self.text, 1, beforeSelection)
		local after = utf8.sub(self.text, afterSelection + 1, utf8.len(self.text))
		self.text = before .. paste .. after

	else
		local before = utf8.sub(self.text, 1, self.caret)
		local after = utf8.sub(self.text, self.caret + 1, utf8.len(self.text))
		self.text = before .. paste .. after
	end

	self.caret = self.caret + utf8.len(paste)
    self.selectedCaret = nil

    if utf8.len(self.text) > self.maxLength then
        self.text = utf8.sub(self.text, 1, self.maxLength)
        self.caret = self.maxLength
    end
end

function Editbox:getPosForText()
	local text = self:getViewText()

	local toCarethLength = dxGetTextWidth(utf8.sub(text, 0, self.caret), 1, getFont(self.fontSize))
	local fieldW = self.rW

	if self.masked then
		if self.selected then
			if guiData.capsOn then
				fieldW = fieldW - (self.rtH - 27) - (self.rtH - 29)
			else
				fieldW = fieldW - (self.rtH - 27)
			end
		else
			if guiData.capsOn then fieldW = fieldW - (self.rtH - 27) end
		end
	end

	if self.posX then
        local posX = toCarethLength >= fieldW and -(toCarethLength - fieldW) or 0
        -- local posX = self.image and posX - (self.rtH - 4) or posX

		if utf8.len(self.text) == 0 or self.caret == 0 then
			self.posX = 0

		elseif toCarethLength >= fieldW and self.posX > posX then
			self.posX = -(toCarethLength - fieldW) or 0

		elseif -(self.posX - posX) >= (fieldW/4 * 3) then
			local current = dxGetTextWidth(utf8.sub(text, 0, self.caret), 1, getFont(self.fontSize))
			local oneBefore = dxGetTextWidth(utf8.sub(text, 0, self.caret - 1), 1, getFont(self.fontSize))

			self.posX = self.posX + (current - oneBefore)

		elseif -(toCarethLength - self.posX) <= fieldW and self.posX ~= 0 and toCarethLength <= fieldW then
			if self.lastTextCaret ~= self.caret then
				local current = dxGetTextWidth(utf8.sub(text, 0, self.caret), 1, getFont(self.fontSize))
				local oneBefore = dxGetTextWidth(utf8.sub(text, 0, self.caret - 1), 1, getFont(self.fontSize))

				self.posX = self.posX + (current - oneBefore)
				if self.posX > 0 then self.posX = 0 end
			end
		end
	else
		self.posX = toCarethLength >= fieldW and -(toCarethLength - fieldW) or 0
	end
	self.lastTextCaret = self.caret
	return self.posX
end

function Editbox:onMouseClick(...)
	if not self.selected then return end
	if arg[2] == "down" then
		if isMouseInPosition(self.x, self.y, self.w, self.h) then
			self.selectedCaret = self:getEditCaretFromMouse()
		end
	else
		if self.mouseCaret then
			self.caret = self.mouseCaret
			self.mouseCaret = nil
		end
	end

	if not self.masked or arg[2] ~= "down" then return end
	if isMouseInPosition(self.x + self.w - self.h + 15/zoom, self.y + 15/zoom, self.h - 30/zoom, self.h - 30/zoom) then
		if not self.showHidden and guiData.showHiddenDelay and (getTickCount() - guiData.showHiddenDelay)/100 < 1 then return end
		self.showHidden = not self.showHidden
	end
end

function Editbox:getEditCaretFromMouse()
    if utf8.len(self.text) == 0 then return 0, 0 end
	local cx, cy = getCursorPosition()
    local cx, cy = cx * sx, cy * sy

    local viewText = self:getViewText()
    local posX = self:getPosForText()/zoom
    local posX = self.image and posX + (self.h + 6/zoom) or posX

    local text = ""
    for v in utf8.gmatch(self.text, ".") do
        text = text .. v

		local testLen = dxGetTextWidth(text, 1/zoom, getFont(self.fontSize))
		if posX + testLen >= cx - self.x then
			return math.max((utf8.len(text) - 1) or 0, 0), math.max(textLen or 0, 0)
		else
            textLen = testLen
		end
    end
    if posX + textLen <= cx - self.x and posX + textLen >= 0 then
        return utf8.len(text), textLen
    else
        return 0, 0
    end
end

function Editbox:getSymbol(...)
    if arg[1] == "num_div" then return "/" end
    if arg[1] == "num_mul" then return "*" end
    if arg[1] == "num_sub" then return "-" end
    if arg[1] == "num_add" then return "+" end
	if arg[1] == "space" then return " " end

    local key = utf8.find(arg[1], "num") and utf8.sub(arg[1], 5, 5) or arg[1]

    local hasShift = getKeyState("lshift") or getKeyState("rshift")

    if key == "#" then key = "'" end
    if getKeyState("ralt") then
		if key == "a" then key = "ą" end
		if key == "c" then key = "ć" end
		if key == "e" then key = "ę" end
		if key == "l" then key = "ł" end
		if key == "n" then key = "ń" end
		if key == "o" then key = "ó" end
		if key == "s" then key = "ś" end
		if key == "z" then key = "ż" end
		if key == "x" then key = "ź" end

    elseif hasShift then
		if key == "1" then return "!" end
		if key == "2" then return "@" end
		if key == "3" then return "#" end
		if key == "4" then return "$" end
		if key == "5" then return "%" end
		if key == "6" then return "^" end
		if key == "7" then return "&" end
		if key == "8" then return "*" end
		if key == "9" then return "(" end
		if key == "0" then return ")" end
		if key == ";" then return ":" end
		if key == "#" then return "\"" end
		if key == "/" then return "?" end
		if key == "." then return ">" end
		if key == "," then return "<" end
		if key == "[" then return "{" end
		if key == "]" then return "}" end
		if key == "\\" then return "|" end
		if key == "-" then return "_" end
		if key == "=" then return "+" end
	end

    if hasShift or guiData.capsOn then
        return utf8.upper(key)
    end
    return key
end



function createEdit(...)
    local edit = Editbox:create(...)
    edit:setOwner(getResourceName(sourceResource))

    return edit.element
end

function destroyEdit(...)
    if type(arg[1]) == "table" then
        for _, v in pairs(arg[1]) do
            createdEdits[v]:destroy()
        end
    else
        createdEdits[arg[1]]:destroy()
    end
    return true
end

function showEdit(...)
    if type(arg[1]) == "table" then
        for _, v in pairs(arg[1]) do
            createdEdits[v]:show(arg[2], arg[3])
        end
    else
        createdEdits[arg[1]]:show(arg[2], arg[3])
    end
    return true
end

function hideEdit(...)
    if type(arg[1]) == "table" then
        for _, v in pairs(arg[1]) do
            createdEdits[v]:hide(arg[2], arg[3])
        end
    else
        createdEdits[arg[1]]:hide(arg[2], arg[3])
    end
    return true
end

function setEditVisible(...)
    if type(arg[1]) == "table" then
        for _, v in pairs(arg[1]) do
            createdEdits[v]:setVisible(arg[2])
        end
    else
        createdEdits[arg[1]]:setVisible(arg[2])
    end
    return true
end

function setEditText(...)
    if type(arg[1]) == "table" then
        for _, v in pairs(arg[1]) do
            createdEdits[v]:setText(arg[2])
        end
    else
        createdEdits[arg[1]]:setText(arg[2])
    end
    return true
end

function setEditFontSize(...)
    if type(arg[1]) == "table" then
        for _, v in pairs(arg[1]) do
            createdEdits[v]:setFontSize(arg[2])
        end
    else
        createdEdits[arg[1]]:setFontSize(arg[2])
    end
    return true
end

function setEditLimit(...)
    if type(arg[1]) == "table" then
        for _, v in pairs(arg[1]) do
            createdEdits[v]:setMaxLength(arg[2])
        end
    else
        createdEdits[arg[1]]:setMaxLength(arg[2])
    end
    return true
end

function setEditImage(...)
    if type(arg[1]) == "table" then
        for _, v in pairs(arg[1]) do
            createdEdits[v]:setImage(arg[2])
        end
    else
        createdEdits[arg[1]]:setImage(arg[2])
    end
    return true
end

function isEditEnabled(...)
    return createdEdits[arg[1]].selected
end



--- RENDER EDITBOXES ---
function renderEdits()
    for i, v in pairs(createdEdits) do
        v:draw()
    end
    changeSeparator()
end
addEventHandler("onClientRender", root, renderEdits)

function editboxSetFocus()
    if isResponseEnabled() then guiBlur(createdEdits[source].element) return end
    if isEscapeOpen() then guiBlur(createdEdits[source].element) return end
    createdEdits[source]:setFocus(true)
end
addEventHandler("onClientGUIFocus", resourceRoot, editboxSetFocus)

function editboxRemoveFocus()
    for i, _ in pairs(createdEdits) do
        createdEdits[i]:setFocus(nil)
    end
end
addEventHandler("onClientGUIBlur", resourceRoot, editboxRemoveFocus)

function switchButtonShowing(...)
    for i, _ in pairs(createdEdits) do
        createdEdits[i]:onMouseClick(...)
    end
end
addEventHandler("onClientClick", root, switchButtonShowing)

function editEnterKey(...)
    for i, _ in pairs(createdEdits) do
        createdEdits[i]:editEnterKey(arg[1], arg[2], arg[3])
    end

    if editSettings.key == arg[1] and not arg[2] then
        editSettings.key = nil
        editSettings.state = nil
        editSettings.tick = nil
    end
end
addEventHandler("onClientKey", root, editEnterKey)

function pasteValue(...)
    for i, _ in pairs(createdEdits) do
        createdEdits[i]:pasteValue(...)
    end
end
addEvent("returnClipBoard", true)
addEventHandler("returnClipBoard", root, pasteValue)

function changeSeparator()
    if not editSettings.separator[1] then
        if (getTickCount() - editSettings.separator[2]) / 500 >= 1 then
            editSettings.separator[1] = true
            editSettings.separator[2] = getTickCount()
        end

    elseif editSettings.separator[1] then
        if (getTickCount() - editSettings.separator[2]) / 500 >= 1 then
            editSettings.separator[1] = false
            editSettings.separator[2] = getTickCount()
        end
    end
end

function resetSeparator()
    editSettings.separator[1] = true
    editSettings.separator[2] = getTickCount()
end
