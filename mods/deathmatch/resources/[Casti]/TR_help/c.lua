local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX / sx)
end

local guiInfo = {
    category = {
        x = (sx - 850/zoom)/2,
        y = (sy - 100/zoom)/2,
        w = 850/zoom,
        h = 160/zoom,
    },

    logo = {
        x = (sx - 200/zoom)/2,
        y = 100/zoom,
        defY = 100/zoom,
        w = 200/zoom,
        h = 200/zoom,
    },

    back = {
        x = (sx - 250/zoom)/2,
        y = sy - 60/zoom,
        w = 250/zoom,
        h = 40/zoom,
    },

    rules = {
        x = (sx - 900/zoom)/2,
        y = (sy - 540/zoom)/2,
        w = 900/zoom,
        h = 735/zoom,
    },

    info = {
        x = (sx - 700/zoom)/2,
        y = sy/2 - 200/zoom,
        w = 700/zoom,
        h = 200/zoom,
    },

    premium = {
        x = (sx - 900/zoom)/2,
        y = sy/2 - 280/zoom,
        w = 900/zoom,
        h = 200/zoom,
    },


    categories = {
        {
            name = "Market",
            type = "premium",
            logo = sy/2 - 530/zoom,
        },
        {
            name = "Güncellemeler",
            type = "updates",
            logo = (sy - 500/zoom)/2 - 250/zoom,
        },
        {
            name = "Bilgi",
            type = "info",
            logo = sy/2 - 450/zoom,
        },
        {
            name = "Kılavuz",
            type = "tutorial",
            logo = (sy - 500/zoom)/2 - 250/zoom,
        },
        {
            name = "Kurallar",
            type = "rules",
            logo = (sy - 500/zoom)/2 - 250/zoom,
        },
    },
}

Help = {}
Help.__index = Help

function Help:create()
    local instance = {}
    setmetatable(instance, Help)
    if instance:constructor() then
        return instance
    end
    return false
end

function Help:constructor()
    self.state = nil
    self.alpha = 0

    self.fonts = {}
    self.fonts.premium = exports.TR_dx:getFont(14)
    self.fonts.info = exports.TR_dx:getFont(13)
    self.fonts.category = exports.TR_dx:getFont(12)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.switch = function() self:switch() end
    self.func.onClick = function(...) self:onClick(...) end
    self.func.buttonClick = function(...) self:buttonClick(...) end
    self.func.updateUpdates = function(...) self:updateUpdates(...) end
    self.func.scrollKeyPremium = function(...) self:scrollKeyPremium(...) end

    bindKey("F1", "down", self.func.switch)
    addEvent("updateHelpUpdates", true)
    addEventHandler("updateHelpUpdates", root, self.func.updateUpdates)
    return true
end

function Help:open()
    local isTutorial = exports.TR_tutorial:isTutorialOpen()
    if isTutorial then
        if isTutorial ~= 10 then return end
        exports.TR_tutorial:setNextState()
    else
        if not exports.TR_dx:canOpenGUI() then return end
    end
    if not getElementData(localPlayer, "characterUID") then return end

    self.alpha = 0
    self.tick = getTickCount()
    self.state = "opening"

    self.category = "main"
    self.alphaCategory = 0
    self.stateCategory = nil
    self.tickCategory = nil

    guiInfo.logo.y = guiInfo.logo.defY

    self:createButtons()

    bindKey("mouse_wheel_down", "down", self.func.scrollKeyPremium)
    bindKey("mouse_wheel_up", "down", self.func.scrollKeyPremium)

    showCursor(true)
    exports.TR_dx:setOpenGUI(true)
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientClick", root, self.func.onClick)
    addEventHandler("guiButtonClick", root, self.func.buttonClick)
end

function Help:close()
    self.alpha = 1
    self.tick = getTickCount()
    self.state = "closing"

    exports.TR_dx:hideButton(self.buttons)
    exports.TR_dx:hideScroll(self.scroll)

    unbindKey("mouse_wheel_down", "down", self.func.scrollKeyPremium)
    unbindKey("mouse_wheel_up", "down", self.func.scrollKeyPremium)

    showCursor(false)
    removeEventHandler("onClientClick", root, self.func.onClick)
    removeEventHandler("guiButtonClick", root, self.func.buttonClick)
end

function Help:destroy()
    if not exports.TR_tutorial:isTutorialOpen() then
        exports.TR_dx:setOpenGUI(false)
    end

    exports.TR_dx:destroyButton(self.buttons)
    exports.TR_dx:destroyScroll(self.scroll)

    removeEventHandler("onClientRender", root, self.func.render)
end

function Help:createButtons()
    self.rules = exports.TR_login:getRules()

    self.buttons = {}
    self.buttons.back = exports.TR_dx:createButton(guiInfo.back.x, guiInfo.back.y, guiInfo.back.w, guiInfo.back.h, "Geri Dön", "red")
    self.buttons.link = exports.TR_dx:createButton(guiInfo.back.x, guiInfo.back.y - 50/zoom, guiInfo.back.w, guiInfo.back.h, "Kopyala")
    exports.TR_dx:setButtonVisible(self.buttons, false)

    self.scroll = exports.TR_dx:createScroll(guiInfo.rules.x, guiInfo.rules.y, guiInfo.rules.w, guiInfo.rules.h, 30, false, self.rules)
    exports.TR_dx:setScrollVisible(self.scroll, false)
    exports.TR_dx:setScrollBackground(self.scroll, false)
end

function Help:animate()
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
        end
    end
end

function Help:animateCategory()
    if not self.tickCategory then return end
    local progress = (getTickCount() - self.tickCategory)/500
    if self.stateCategory == "opening" then
        self.alphaCategory, guiInfo.logo.y = interpolateBetween(0, guiInfo.logo.nowY, 0, 1, guiInfo.logo.nextY, 0, progress, "Linear")
        if progress >= 1 then
            self.alphaCategory = 1
            self.stateCategory = nil
            self.tickCategory = nil
            self.category = self.nextCategory
            self.nextCategory = nil
        end

    elseif self.stateCategory == "closing" then
        self.alphaCategory, guiInfo.logo.y = interpolateBetween(1, guiInfo.logo.nowY, 0, 0, guiInfo.logo.nextY, 0, progress, "Linear")
        if progress >= 1 then
            self.alphaCategory = 0
            self.stateCategory = nil
            self.tickCategory = nil
            self.category = self.nextCategory
            self.nextCategory = nil
        end
    end
end

function Help:render()
    self:animate()
    self:animateCategory()

    dxDrawImage(0, 0, sx, sy, "files/images/bg.jpg", 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))

    self:drawCategories()
    self:drawSelectedCategory()
end

function Help:drawCategories()
    dxDrawImage(guiInfo.logo.x, guiInfo.logo.y, guiInfo.logo.w, guiInfo.logo.h, "files/images/logo.png", 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
    self:drawBackground(guiInfo.category.x, guiInfo.category.y, guiInfo.category.w, guiInfo.category.h, tocolor(22, 22, 22, 255 * self.alpha * (1 - self.alphaCategory)), 4)

    for i, v in pairs(guiInfo.categories) do
        if self:isMouseInPosition(guiInfo.category.x + 30/zoom + (i-1) * 160/zoom, guiInfo.category.y + 20/zoom, 130/zoom, 120/zoom) then
            dxDrawImage(guiInfo.category.x + 50/zoom + (i-1) * 160/zoom, guiInfo.category.y + 20/zoom, 90/zoom, 90/zoom, string.format("files/images/%s.png", v.type), 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha * (1 - self.alphaCategory)))
            dxDrawText(v.name, guiInfo.category.x + 50/zoom + (i-1) * 160/zoom, guiInfo.category.y + 120/zoom, guiInfo.category.x + 140/zoom + (i-1) * 160/zoom, guiInfo.category.y + 120/zoom, tocolor(255, 255, 255, 255 * self.alpha * (1 - self.alphaCategory)), 1/zoom, self.fonts.category, "center", "top")
        else
            dxDrawImage(guiInfo.category.x + 50/zoom + (i-1) * 160/zoom, guiInfo.category.y + 20/zoom, 90/zoom, 90/zoom, string.format("files/images/%s.png", v.type), 0, 0, 0, tocolor(220, 220, 220, 255 * self.alpha * (1 - self.alphaCategory)))
            dxDrawText(v.name, guiInfo.category.x + 50/zoom + (i-1) * 160/zoom, guiInfo.category.y + 120/zoom, guiInfo.category.x + 140/zoom + (i-1) * 160/zoom, guiInfo.category.y, tocolor(220, 220, 220, 255 * self.alpha * (1 - self.alphaCategory)), 1/zoom, self.fonts.category, "center", "top")
        end
    end
end

function Help:drawSelectedCategory()
    if self.category == "info" or self.nextCategory == "info" then
        dxDrawText(InfoText, guiInfo.info.x, guiInfo.info.y, guiInfo.info.x + guiInfo.info.w, guiInfo.info.y, tocolor(200, 200, 200, 255 * self.alpha * self.alphaCategory), 1/zoom, self.fonts.info, "center", "top", false, false, false, true)

    elseif self.category == "premium" or self.nextCategory == "premium" then
        -- dxDrawText("Aby zakupić Konto Premium lub inne ciekawe rzeczy jak np. Gry w Karty\nwejdź na stronę naszego sklepu (https://www.insidemta.pl/shop).", sx/2, guiInfo.info.y, sx/2, sy - 160/zoom, tocolor(200, 200, 200, 255 * self.alpha * self.alphaCategory), 1/zoom, self.fonts.category, "center", "bottom", false, false, false, true)

        dxDrawText("VIP Üyeliğin Özellikleri", guiInfo.premium.x, guiInfo.premium.y - 30/zoom, guiInfo.premium.x + guiInfo.premium.w/2, guiInfo.premium.y + 40/zoom, tocolor(170, 170, 170, 255 * self.alpha * self.alphaCategory), 1/zoom, self.fonts.premium, "center", "center", false, false, false, true)

        dxDrawImage(guiInfo.premium.x + guiInfo.premium.w/2 + (guiInfo.premium.w/6 - 50/zoom)/2, guiInfo.premium.y - 30/zoom, 50/zoom, 50/zoom, "files/images/man.png", 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha * self.alphaCategory))
        dxDrawText("STANDART", guiInfo.premium.x + guiInfo.premium.w/2, guiInfo.premium.y + 20/zoom, guiInfo.premium.x + guiInfo.premium.w/2 + guiInfo.premium.w/6, guiInfo.premium.y + 40/zoom, tocolor(221, 221, 221, 255 * self.alpha * self.alphaCategory), 1/zoom, self.fonts.category, "center", "top", false, false, false, true)

        dxDrawImage(guiInfo.premium.x + guiInfo.premium.w/2 + guiInfo.premium.w/6 + (guiInfo.premium.w/6 - 64/zoom)/2, guiInfo.premium.y - 40/zoom, 64/zoom, 64/zoom, "files/images/crown.png", 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha * self.alphaCategory))
        dxDrawText("GOLD", guiInfo.premium.x + guiInfo.premium.w/2 + guiInfo.premium.w/6, guiInfo.premium.y + 20/zoom, guiInfo.premium.x + guiInfo.premium.w/2 + guiInfo.premium.w/6 * 2, guiInfo.premium.y + 40/zoom, tocolor(214, 163, 6, 255 * self.alpha * self.alphaCategory), 1/zoom, self.fonts.category, "center", "top", false, false, false, true)

        dxDrawImage(guiInfo.premium.x + guiInfo.premium.w/2 + guiInfo.premium.w/6 * 2 + (guiInfo.premium.w/6 - 50/zoom)/2, guiInfo.premium.y - 30/zoom, 50/zoom, 50/zoom, "files/images/diamond.png", 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha * self.alphaCategory))
        dxDrawText("DIAMOND", guiInfo.premium.x + guiInfo.premium.w/2 + guiInfo.premium.w/6 * 2, guiInfo.premium.y + 20/zoom, guiInfo.premium.x + guiInfo.premium.w/2 + guiInfo.premium.w/6 * 3, guiInfo.premium.y + 40/zoom, tocolor(49, 202, 255, 255 * self.alpha * self.alphaCategory), 1/zoom, self.fonts.category, "center", "top", false, false, false, true)

        dxDrawLine(guiInfo.premium.x, guiInfo.premium.y + 50/zoom, guiInfo.premium.x + guiInfo.premium.w, guiInfo.premium.y + 50/zoom, tocolor(70, 70, 70, 255 * self.alpha * self.alphaCategory), 1)

        dxDrawLine(guiInfo.premium.x, guiInfo.premium.y - 40/zoom, guiInfo.premium.x, guiInfo.premium.y + 50/zoom + 16 * 40/zoom, tocolor(70, 70, 70, 255 * self.alpha * self.alphaCategory), 1)
        dxDrawLine(guiInfo.premium.x + guiInfo.premium.w/2, guiInfo.premium.y - 40/zoom, guiInfo.premium.x + guiInfo.premium.w/2, guiInfo.premium.y + 50/zoom + 16 * 40/zoom, tocolor(70, 70, 70, 255 * self.alpha * self.alphaCategory), 1)
        dxDrawLine(guiInfo.premium.x + guiInfo.premium.w/2 + guiInfo.premium.w/6, guiInfo.premium.y - 40/zoom, guiInfo.premium.x + guiInfo.premium.w/2 + guiInfo.premium.w/6, guiInfo.premium.y + 50/zoom + 16 * 40/zoom, tocolor(70, 70, 70, 255 * self.alpha * self.alphaCategory), 1)
        dxDrawLine(guiInfo.premium.x + guiInfo.premium.w/2 + guiInfo.premium.w/3, guiInfo.premium.y - 40/zoom, guiInfo.premium.x + guiInfo.premium.w/2 + guiInfo.premium.w/3, guiInfo.premium.y + 50/zoom + 16 * 40/zoom, tocolor(70, 70, 70, 255 * self.alpha * self.alphaCategory), 1)
        dxDrawLine(guiInfo.premium.x + guiInfo.premium.w, guiInfo.premium.y - 40/zoom, guiInfo.premium.x + guiInfo.premium.w, guiInfo.premium.y + 50/zoom + 16 * 40/zoom, tocolor(70, 70, 70, 255 * self.alpha * self.alphaCategory), 1)
        dxDrawLine(guiInfo.premium.x, guiInfo.premium.y - 40/zoom, guiInfo.premium.x + guiInfo.premium.w, guiInfo.premium.y - 40/zoom, tocolor(70, 70, 70, 255 * self.alpha * self.alphaCategory), 1)


        for i = 1, 16 do
            local v = Premium[i + self.scrollPremium]
            if v then
                dxDrawText(v[1], guiInfo.premium.x + 20/zoom, guiInfo.premium.y + 50/zoom + (i-1) * 40/zoom, guiInfo.premium.x + guiInfo.premium.w/2, guiInfo.premium.y + 50/zoom + i * 40/zoom, tocolor(170, 170, 170, 255 * self.alpha * self.alphaCategory), 1/zoom, self.fonts.category, "left", "center", false, false, false, true)

                self:renderPremiumAnswer(guiInfo.premium.x + guiInfo.premium.w/2, guiInfo.premium.y + 50/zoom + (i-1) * 40/zoom, guiInfo.premium.w/6, 40/zoom, v[2])
                self:renderPremiumAnswer(guiInfo.premium.x + guiInfo.premium.w/2 + guiInfo.premium.w/6, guiInfo.premium.y + 50/zoom + (i-1) * 40/zoom, guiInfo.premium.w/6, 40/zoom, v[3])
                self:renderPremiumAnswer(guiInfo.premium.x + guiInfo.premium.w/2 + guiInfo.premium.w/3, guiInfo.premium.y + 50/zoom + (i-1) * 40/zoom, guiInfo.premium.w/6, 40/zoom, v[4])

                dxDrawLine(guiInfo.premium.x, guiInfo.premium.y + 50/zoom + i * 40/zoom, guiInfo.premium.x + guiInfo.premium.w, guiInfo.premium.y + 50/zoom + i * 40/zoom, tocolor(70, 70, 70, 255 * self.alpha * self.alphaCategory), 1)
            end
        end

        if #Premium > 16 then
            local b1 = (guiInfo.premium.h + 440/zoom) / #Premium
            local barY = b1 * self.scrollPremium
            local barHeight = b1 * 16
            -- dxDrawRectangle(guiInfo.premium.x + guiInfo.premium.w, guiInfo.premium.y + 40/zoom, 4/zoom, 290/zoom, tocolor(37, 37, 37, 255 * self.alpha))
            dxDrawRectangle(guiInfo.premium.x + guiInfo.premium.w, guiInfo.premium.y + 50/zoom, 4/zoom, guiInfo.premium.h + 440/zoom, tocolor(57, 57, 57, 255 * self.alpha))
            dxDrawRectangle(guiInfo.premium.x + guiInfo.premium.w, guiInfo.premium.y + 50/zoom + barY, 4/zoom, barHeight, tocolor(87, 87, 87, 255 * self.alpha))
        end
    end
end

function Help:renderPremiumAnswer(x, y, w, h, data)
    if data == "X" then
        dxDrawImage(x + (w - 20/zoom)/2, y + (h - 20/zoom)/2, 20/zoom, 20/zoom, "files/images/cross.png", 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha * self.alphaCategory))
    elseif data == "Y" then
        dxDrawImage(x + (w - 32/zoom)/2, y + (h - 32/zoom)/2, 32/zoom, 32/zoom, "files/images/check.png", 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha * self.alphaCategory))
    else
        dxDrawText(data, x, y, x + w, y + h, tocolor(221, 221, 221, 255 * self.alpha * self.alphaCategory), 1/zoom, self.fonts.category, "center", "center", false, false, false, true)
    end
end

function Help:scrollKeyPremium(btn)
    if btn == "mouse_wheel_up" then
        self.scrollPremium = math.max(self.scrollPremium - 1, 0)

    elseif btn == "mouse_wheel_down" then
        self.scrollPremium = math.min(self.scrollPremium + 1, #Premium - 16)
    end
end

function Help:selectCategory(category, logoY)
    self.nextCategory = category
    exports.TR_dx:hideScroll(self.scroll)

    if category == "main" then
        self.stateCategory = "closing"
        self.tickCategory = getTickCount()

        exports.TR_dx:hideButton(self.buttons)

        guiInfo.logo.nowY = guiInfo.logo.y
        guiInfo.logo.nextY = guiInfo.logo.defY
        return
    end

    if category == "rules" then
        exports.TR_dx:showScroll(self.scroll)
        exports.TR_dx:setScrollText(self.scroll, self.rules)

    elseif category == "tutorial" then
        exports.TR_dx:showScroll(self.scroll)
        exports.TR_dx:setScrollText(self.scroll, TutorialInfo)

    elseif category == "updates" then
        exports.TR_dx:showScroll(self.scroll)
        exports.TR_dx:setScrollText(self.scroll, "Haberler yükleniyor...")
        exports.TR_dx:setResponseEnabled(true)
        triggerServerEvent("getHelpUpdates", resourceRoot)

    elseif category == "info" then
        exports.TR_dx:showButton(self.buttons.link)
        exports.TR_dx:setButtonText(self.buttons.link, "Forum linkini kopyala")

    elseif category == "premium" then
        self.scrollPremium = 0
        exports.TR_dx:showButton(self.buttons.link)
        exports.TR_dx:setButtonText(self.buttons.link, "Market linkini kopyala")
    end

    self.stateCategory = "opening"
    self.tickCategory = getTickCount()
    exports.TR_dx:showButton(self.buttons.back)

    guiInfo.logo.nowY = guiInfo.logo.y
    guiInfo.logo.nextY = logoY or -200
end

function Help:switch()
    if not self.state then
        self:open()

    elseif self.state == "opened" and not self.stateCategory then
        self:close()
    end
end

function Help:onClick(...)
    if arg[1] == "left" and arg[2] == "down" then
        if self.category == "main" and self.state == "opened" and not self.nextCategory then
            for i, v in pairs(guiInfo.categories) do
                if self:isMouseInPosition(guiInfo.category.x + 30/zoom + (i-1) * 160/zoom, guiInfo.category.y + 20/zoom, 130/zoom, 120/zoom) then
                    self:selectCategory(v.type, v.logo)
                    break
                end
            end
        end
    end
end

function Help:buttonClick(...)
    if arg[1] == self.buttons.back then
        if self.stateCategory or self.nextCategory then return end
        self:selectCategory("main")

    elseif arg[1] == self.buttons.link then
        if self.category == "info" then setClipboard("https://forum.insidemta.pl") end
        if self.category == "premium" then setClipboard("https://www.insidemta.pl/shop") end
        exports.TR_noti:create("Bağlantı panoya kopyalandı. Tarayıcınızı açın ve tarayıcı adresine yapıştırın.", "success", 5)
    end
end

function Help:updateUpdates(updates)
    local text = ""
    local count = 0
    for i, v in ipairs(updates) do
      text = text .. v.text .. (i ~= #updates and "\n\n" or "")
      count = count + 1
    end

    setTimer(function()
      exports.TR_dx:setScrollText(self.scroll, text)
      exports.TR_dx:setResponseEnabled(false)
    end, 1000, 1)
  end


function Help:drawBackground(x, y, rx, ry, color, radius, post)
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

function Help:isMouseInPosition(x, y, width, height)
    if (not isCursorShowing()) then return false end
    local cx, cy = getCursorPosition()
    local cx, cy = (cx * sx), (cy * sy)
    if (cx >= x and cx <= x + width) and (cy >= y and cy <= y + height) then return true end
    return false
end

Help:create()