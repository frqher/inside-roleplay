local sx, sy = guiGetScreenSize()

zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 1000/zoom)/2,
    y = (sy - 600/zoom)/2,
    w = 1400/zoom,
    wMain = 1000/zoom,
    h = 600/zoom,

    card = {
        x = (sx - 1000/zoom)/2 + 1085/zoom,
        y = sy - 200/zoom,
        w = 236/zoom,
        h = 364/zoom,
    },

    usedButtons = {
        main = {
            left = {false, false, false, {text = "ATM'yi kapattın", action = "close"}},
            right = {false, false, false, {text = "Bilgi", action = "about"}},
        },
        about = {
            left = {false, false, false, {text = "Geri dön", action = "main"}},
            right = {},
        },
        card = {
            left = {},
            right = {},
        },
        pin = {
            left = {false, false, false, {text = "İptal", action = "close"}},
            right = {false, false, false, {text = "Teyit et", action = "submitPin"}},
        },
        pinWrong = {
            left = {},
            right = {false, false, false, {text = "Tekrar deneyin.", action = "pin"}},
        },
        options = {
            left = {false, false, false, {text = "İşlemleri bitir", action = "close"}},
            right = {false, false, {text = "Depozito", action = "deposit"}, {text = "Para çek", action = "withdraw"}},
        },
        withdraw = {
            left = {{text = "10", action = "withdraw", count = 10}, {text = "20", action = "withdraw", count = 20}, {text = "50", action = "withdraw", count = 50}, {text = "Anuluj", action = "options"}},
            right = {{text = "100", action = "withdraw", count = 100}, {text = "200", action = "withdraw", count = 200}, {text = "500", action = "withdraw", count = 500}, {text = "Własna kwota", action = "withdrawOwn"}},
        },
        withdrawOwn = {
            left = {false, false, false, {text = "İptal", action = "withdraw"}},
            right = {false, false, false, {text = "Para çek", action = "withdrawOwnSubmit"}},
        },
        deposit = {
            left = {{text = "10", action = "deposit", count = 10}, {text = "20", action = "deposit", count = 20}, {text = "50", action = "deposit", count = 50}, {text = "Anuluj", action = "options"}},
            right = {{text = "100", action = "deposit", count = 100}, {text = "200", action = "deposit", count = 200}, {text = "500", action = "deposit", count = 500}, {text = "Własna kwota", action = "depositOwn"}},
        },
        depositOwn = {
            left = {false, false, false, {text = "İptal", action = "deposit"}},
            right = {false, false, false, {text = "Depozito", action = "depositOwnSubmit"}},
        },
    }
}

Atm = {}
Atm.__index = Atm

function Atm:create(...)
    local instance = {}
    setmetatable(instance, Atm)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function Atm:constructor(...)
    local plrData = getElementData(localPlayer, "characterData")

    self.alpha = 0
    self.pin = ""
    self.code = plrData.bankcode
    self.bankmoney = arg[1]
    self.money = plrData.money

    self.card = dxCreateTexture("files/images/card.png", "argb", true, "clamp")
    self.cardY = guiInfo.card.y
    self.cardH = 0

    self.fonts = {}
    self.fonts.screen = exports.TR_dx:getFont(16)
    self.fonts.info = exports.TR_dx:getFont(15)
    self.fonts.fields = exports.TR_dx:getFont(12)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.click = function(...) self:click(...) end
    self.func.clickButton = function(...) self:clickButton(...) end

    self:open()
    return true
end

function Atm:destroy()
    exports.TR_dx:setOpenGUI(false)
    removeEventHandler("onClientRender", root, self.func.render)
    destroyElement(self.card)
    guiInfo.atm = nil
    self = nil
end

function Atm:open()
    exports.TR_hud:setHudVisible(false)
    exports.TR_chat:showCustomChat(false)

    self.tick = getTickCount()
    self.state = "show"
    self.tab = "main"

    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientClick", root, self.func.click)
    addEventHandler("onClientKey", root, self.func.clickButton)
    showCursor(true)
end

function Atm:close()
    exports.TR_hud:setHudVisible(true)
    exports.TR_chat:showCustomChat(true)

    self.tick = getTickCount()
    self.state = "hide"

    removeEventHandler("onClientClick", root, self.func.click)
    removeEventHandler("onClientKey", root, self.func.clickButton)
    showCursor(false)
end

function Atm:animate()
    if self.state == "show" then
        local progress = (getTickCount() - self.tick)/600
        self.alpha = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "InOutQuad")

        if progress >= 1 then
            self.tick = getTickCount()
            self.alpha = 1
            self.state = "showed"
        end

    elseif self.state == "hide" then
        local progress = (getTickCount() - self.tick)/400
        self.alpha = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "InOutQuad")

        if progress >= 1 then
            self.tick = nil
            self.alpha = 0
            self.state = nil

            self:destroy()
        end
    end
end

function Atm:render()
    self:animate()
    dxDrawRectangle(0, 0, sx, sy, tocolor(17, 17, 17, 150 * self.alpha))
    dxDrawImage(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, "files/images/bg.jpg", 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
    -- dxDrawText("Potwierdzenie", guiInfo.x + 1062/zoom, guiInfo.y + 100/zoom, guiInfo.x + 150/zoom, guiInfo.y + 100/zoom, tocolor(42, 42, 42, 220 * self.alpha), 1/zoom, self.fonts.fields, "left", "bottom")
    -- dxDrawText("Karta płatnicza", guiInfo.x + 1062/zoom, guiInfo.y + 184/zoom, guiInfo.x + 150/zoom, guiInfo.y + 184/zoom, tocolor(42, 42, 42, 220 * self.alpha), 1/zoom, self.fonts.fields, "left", "bottom")

    self:renderTabText()
    self:renderButtons()
    self:renderPinPad()

    if self.code then self:renderCard() end
end

function Atm:renderTabText()
    if self.tab == "main" then
        dxDrawText("İnside Bank ATM'sine hoş geldiniz.\nKartınızı takın ve ekranda gösterilen talimatları izleyin.", guiInfo.x + 150/zoom, guiInfo.y + 150/zoom, guiInfo.x + guiInfo.wMain - 150/zoom, guiInfo.y + guiInfo.h - 150/zoom, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.screen, "center", "top")

    elseif self.tab == "about" then
        dxDrawText("İnside BBO Bank.\nBu ATM'de istediğiniz miktarda para yatırabilir ve çekebilirsiniz. ATM'lerimiz paranızı güvende tutmak için 7/24 izlenmektedir.\n\nUnutmayın!\nParolanızı girerken elinizle kapatın ki kimse görmesin ve kartınız kaybolursa veya çalınırsa para çekemezler.", guiInfo.x + 150/zoom, guiInfo.y + 130/zoom, guiInfo.x + guiInfo.wMain - 150/zoom, guiInfo.y + guiInfo.h - 150/zoom, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "top", true, true)

    elseif self.tab == "options" then
        dxDrawText(string.format("BBO Bank ATM'sine %s hoş geldiniz.\nİlgilendiğiniz seçeneği seçin.\n\nMevcut fon: $%.2f", getPlayerName(localPlayer), self.bankmoney), guiInfo.x + 150/zoom, guiInfo.y + 130/zoom, guiInfo.x + guiInfo.wMain - 150/zoom, guiInfo.y + guiInfo.h - 150/zoom, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "top", true, true)

    elseif self.tab == "deposit" then
        dxDrawText(string.format("İlgilendiğiniz tutarı seçin.\n\nOlası depozito: $%.2f", self.money), guiInfo.x + 150/zoom, guiInfo.y + 130/zoom, guiInfo.x + guiInfo.wMain - 150/zoom, guiInfo.y + guiInfo.h - 150/zoom, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "top", true, true)

    elseif self.tab == "depositOwn" then
        dxDrawText(string.format("Yatırmak istediğiniz tutarı girin.\n\nMevcut depozito: $%.2f", self.money), guiInfo.x + 150/zoom, guiInfo.y + 130/zoom, guiInfo.x + guiInfo.wMain - 150/zoom, guiInfo.y + guiInfo.h - 150/zoom, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "top", true, true)

        dxDrawRectangle((sx - 200/zoom)/2, (sy - 40/zoom)/2, 200/zoom, 40/zoom, tocolor(9, 95, 65, 255 * self.alpha))
        dxDrawText(string.format("%.2f", tonumber((self.pin or 0).."0")), (sx - 200/zoom)/2, (sy - 40/zoom)/2, (sx + 200/zoom)/2, (sy + 40/zoom)/2, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "center")

    elseif self.tab == "withdraw" then
        dxDrawText(string.format("İlgilendiğiniz tutarı seçin.\n\nKullanılabilir fon: $%.2f", self.bankmoney), guiInfo.x + 150/zoom, guiInfo.y + 130/zoom, guiInfo.x + guiInfo.wMain - 150/zoom, guiInfo.y + guiInfo.h - 150/zoom, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "top", true, true)

    elseif self.tab == "withdrawOwn" then
        dxDrawText(string.format("Çekmek istediğiniz tutarı girin.\n\nKullanılabilir para miktarı: $%.2f", self.bankmoney), guiInfo.x + 150/zoom, guiInfo.y + 130/zoom, guiInfo.x + guiInfo.wMain - 150/zoom, guiInfo.y + guiInfo.h - 150/zoom, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "top", true, true)

        dxDrawRectangle((sx - 200/zoom)/2, (sy - 40/zoom)/2, 200/zoom, 40/zoom, tocolor(9, 95, 65, 255 * self.alpha))
        dxDrawText(string.format("%.2f", tonumber((self.pin or 0).."0")), (sx - 200/zoom)/2, (sy - 40/zoom)/2, (sx + 200/zoom)/2, (sy + 40/zoom)/2, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "center")

    elseif self.tab == "card" then
        dxDrawText("Ödeme kartı okunuyor...\nLütfen biraz bekleyin.", guiInfo.x + 150/zoom, guiInfo.y + 150/zoom, guiInfo.x + guiInfo.wMain - 150/zoom, guiInfo.y + guiInfo.h - 150/zoom, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "center", true, true)

    elseif self.tab == "pinWrong" then
        dxDrawText("Ödeme kartı yetkilendirmesi reddedildi.\nKart PIN'i geçersiz.", guiInfo.x + 150/zoom, guiInfo.y + 200/zoom, guiInfo.x + guiInfo.wMain - 150/zoom, guiInfo.y + guiInfo.h - 150/zoom, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "top", true, true)

    elseif self.tab == "pin" then
        dxDrawText("Ödeme kartı başarıyla okundu.\nLütfen PIN'i girin ve düğmesiyle onaylayın.", guiInfo.x + 150/zoom, guiInfo.y + 200/zoom, guiInfo.x + guiInfo.wMain - 150/zoom, guiInfo.y + guiInfo.h - 150/zoom, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "top", true, true)

        dxDrawRectangle((sx - 200/zoom)/2, (sy - 40/zoom)/2, 200/zoom, 40/zoom, tocolor(9, 95, 65, 255 * self.alpha))
        dxDrawText(string.rep("*", string.len(self.pin)), (sx - 200/zoom)/2, (sy - 40/zoom)/2, (sx + 200/zoom)/2, (sy + 40/zoom)/2, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "center")
    end
end

function Atm:renderCard()
    if not isElement(self.card) then return end
    if self.tab ~= "main" and self.tab ~= "about" and self.tab ~= "card" then return end
    if guiInfo.card.sy or self.tab == "card" then
        local cx, cy = getCursorPosition()
        if self.tab == "card" then
            self.cardY = self.cardY - 5
        else
            self.cardY = (cy * sy) - guiInfo.card.sy
        end

        if self.cardY <= guiInfo.y + 198/zoom - guiInfo.card.h then
            self.tab = "pin"
            guiInfo.card.sy = nil
            self.cardH = 364

        elseif self.cardY <= guiInfo.y + 198/zoom - guiInfo.card.h/2 and self.tab ~= "card" then
            self.tab = "card"
            self.cardH = (self.cardY - guiInfo.y - 198/zoom)

        elseif self.cardY <= guiInfo.y + 198/zoom or self.tab == "card" then
            self.cardH = (self.cardY - guiInfo.y - 198/zoom)

        elseif self.cardY >= sy - 200/zoom then
            self.cardY = sy - 200/zoom

        else
            self.cardH = 0
        end
    end

    dxDrawImageSection(guiInfo.card.x, self.cardY - self.cardH, guiInfo.card.w, guiInfo.card.h, 0, -self.cardH, 236, 364, self.card, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
end

function Atm:renderButtons()
    for i = 0, 3 do
        if self:isMouseInPosition(guiInfo.x + 19/zoom, guiInfo.y + 123/zoom + 100/zoom * i, 90/zoom, 54/zoom) and guiInfo.usedButtons[self.tab].left[i + 1] then
            dxDrawImage(guiInfo.x + 19/zoom, guiInfo.y + 123/zoom + 100/zoom * i, 90/zoom, 54/zoom, "files/images/button_l.png", 0, 0, 0, tocolor(230, 230, 230, 255 * self.alpha))
        else
            dxDrawImage(guiInfo.x + 19/zoom, guiInfo.y + 123/zoom + 100/zoom * i, 90/zoom, 54/zoom, "files/images/button_l.png", 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
        end
    end
    for i = 0, 3 do
        if self:isMouseInPosition(guiInfo.x + guiInfo.wMain - 109/zoom, guiInfo.y + 123/zoom + 100/zoom * i, 90/zoom, 54/zoom) and guiInfo.usedButtons[self.tab].right[i + 1] then
            dxDrawImage(guiInfo.x + guiInfo.wMain - 109/zoom, guiInfo.y + 123/zoom + 100/zoom * i, 90/zoom, 54/zoom, "files/images/button_r.png", 0, 0, 0, tocolor(230, 230, 230, 255 * self.alpha))
        else
            dxDrawImage(guiInfo.x + guiInfo.wMain - 109/zoom, guiInfo.y + 123/zoom + 100/zoom * i, 90/zoom, 54/zoom, "files/images/button_r.png", 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
        end
    end
    self:renderTexts()
end

function Atm:renderPinPad()
    local r, c = 0, 0
    for i = 1, 12 do
        if self:isMouseInPosition(guiInfo.x + guiInfo.wMain + 99/zoom + r, guiInfo.y + 280/zoom + c, 64/zoom, 64/zoom) then
            dxDrawImage(guiInfo.x + guiInfo.wMain + 99/zoom + r, guiInfo.y + 280/zoom + c, 64/zoom, 64/zoom, "files/images/button_pad.png", 0, 0, 0, tocolor(230, 230, 230, 255 * self.alpha))
        else
            dxDrawImage(guiInfo.x + guiInfo.wMain + 99/zoom + r, guiInfo.y + 280/zoom + c, 64/zoom, 64/zoom, "files/images/button_pad.png", 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
        end
        dxDrawText(self:getPinNumber(i), guiInfo.x + guiInfo.wMain + 99/zoom + r, guiInfo.y + 280/zoom + c, guiInfo.x + guiInfo.wMain + 163/zoom + r,guiInfo.y + 344/zoom + c, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.screen, "center", "center")
        r = r + 70/zoom
        if i%3 == 0 then
            r = 0
            c = c + 70/zoom
        end
    end
end

function Atm:getPinNumber(...)
    if arg[2] then
        for i = 0, 9 do
            if arg[1] == tostring(i) or arg[1] == tostring("num_"..i) then
                return i
            end
        end
        if arg[1] == "backspace" then return "←" end
        if arg[1] == "delete" then return "C" end
    else
        if arg[1] < 10 then return arg[1] end
        if arg[1] == 10 then return "←" end
        if arg[1] == 11 then return 0 end
        if arg[1] == 12 then return "C" end
    end
    return false
end

function Atm:renderTexts()
    if not guiInfo.usedButtons[self.tab] then return end
    for i = 0, 3 do
        if guiInfo.usedButtons[self.tab].left[i + 1] then
            dxDrawText(guiInfo.usedButtons[self.tab].left[i + 1].text, guiInfo.x + 150/zoom, guiInfo.y + 123/zoom + 100/zoom * i, guiInfo.x + 150/zoom, guiInfo.y + 177/zoom + 100/zoom * i, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.screen, "left", "center")
        end
    end
    for i = 0, 3 do
        if guiInfo.usedButtons[self.tab].right[i + 1] then
            dxDrawText(guiInfo.usedButtons[self.tab].right[i + 1].text, guiInfo.x + guiInfo.wMain - 150/zoom, guiInfo.y + 123/zoom + 100/zoom * i, guiInfo.x + guiInfo.wMain - 150/zoom, guiInfo.y + 177/zoom + 100/zoom * i, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.screen, "right", "center")
        end
    end
end


function Atm:click(...)
    if arg[1] == "left" and arg[2] == "down" then
        if self.tab == "main" or self.tab == "about" then
            if self:isMouseInPosition(guiInfo.card.x, self.cardY - self.cardH, guiInfo.card.w, guiInfo.card.h + self.cardH) and self.code then
                local cx, cy = getCursorPosition()
                guiInfo.card.sy = (cy * sy) - self.cardY
                return
            end
        end

        for i = 0, 3 do
            if self:isMouseInPosition(guiInfo.x + 19/zoom, guiInfo.y + 123/zoom + 100/zoom * i, 90/zoom, 54/zoom) and guiInfo.usedButtons[self.tab].left[i + 1] then
                local option = guiInfo.usedButtons[self.tab].left[i + 1]
                if option.action == "close" then
                    self:close()
                elseif option.action == "withdraw" and option.count then
                    triggerServerEvent("withdrawAtm", resourceRoot, tonumber(option.count))
                elseif option.action == "deposit" and option.count then
                    triggerServerEvent("depositAtm", resourceRoot, tonumber(option.count))
                else
                    self.tab = option.action
                end
                return
            end
        end
        for i = 0, 3 do
            if self:isMouseInPosition(guiInfo.x + guiInfo.wMain - 109/zoom, guiInfo.y + 123/zoom + 100/zoom * i, 90/zoom, 54/zoom) and guiInfo.usedButtons[self.tab].right[i + 1] then
                local option = guiInfo.usedButtons[self.tab].right[i + 1]
                if option.action == "submitPin" then
                    self:submitPin()
                elseif option.action == "withdraw" and option.count then
                    if not self:checkSlow() then return end
                    triggerServerEvent("withdrawAtm", resourceRoot, tonumber(option.count))

                elseif option.action == "withdrawOwnSubmit" then
                    if tonumber(self.pin) == nil or tonumber(self.pin) < 1 then exports.TR_noti:create("Lütfen doğru tutarı girin.", "error") return end
                    if not self:checkSlow() then return end
                    triggerServerEvent("withdrawAtm", resourceRoot, tonumber(self.pin.."0"))

                elseif option.action == "deposit" and option.count then
                    if not self:checkSlow() then return end
                    triggerServerEvent("depositAtm", resourceRoot, tonumber(option.count))

                elseif option.action == "depositOwnSubmit" then
                    if tonumber(self.pin) == nil or tonumber(self.pin) < 1 then exports.TR_noti:create("Lütfen doğru tutarı girin.", "error") return end
                    if not self:checkSlow() then return end
                    triggerServerEvent("depositAtm", resourceRoot, tonumber(self.pin.."0"))
                else
                    self.tab = option.action
                end
                return
            end
        end

        if self.tab == "pin" or self.tab == "withdrawOwn" or self.tab == "depositOwn" then
            local r, c = 0, 0
            for i = 1, 12 do
                if self:isMouseInPosition(guiInfo.x + guiInfo.wMain + 99/zoom + r, guiInfo.y + 280/zoom + c, 64/zoom, 64/zoom) then
                    local number = self:getPinNumber(i)
                    if number == "←" then
                        if string.len(self.pin) <= 0 then return end
                        if self.tab == "pin" then
                            self.pin = string.sub(self.pin, 1, -2)
                        else
                            self.pin = string.sub(self.pin, 1, -2)
                        end
                        return
                    elseif number == "C" then
                        self.pin = ""
                        return
                    end

                    if string.len(self.pin) >= 8 then return end
                    self.pin = self.pin .. number
                    break
                end
                r = r + 70/zoom
                if i%3 == 0 then
                    r = 0
                    c = c + 70/zoom
                end
            end
        end

    elseif arg[1] == "left" and arg[2] == "up" and self.tab ~= "card" then
        guiInfo.card.sy = nil
    end
end

function Atm:checkSlow()
    if self.slowDown then
        if (getTickCount() - self.slowDown)/1000 < 1 then exports.TR_noti:create("Bir sonraki operasyondan önce bir süre beklemeniz gerekir.", "error") return false end
    end
    self.slowDown = getTickCount()
    return true
end

function Atm:clickButton(...)
    if arg[2] then
        local number = self:getPinNumber(arg[1], true)
        if not number then return end

        if number == "←" then
            if string.len(self.pin) <= 0 then return end
            if self.tab == "pin" then
                self.pin = string.sub(self.pin, 1, -2)
            else
                self.pin = string.sub(self.pin, 1, -2)
            end
            return
        elseif number == "C" then
            self.pin = ""
            return
        end

        if string.len(self.pin) >= 8 then return end
        self.pin = self.pin .. number
    end
end

function Atm:submitPin()
    if tonumber(self.code) ~= tonumber(self.pin) then
        self.tab = "pinWrong"
    else
        self.tab = "options"
        self.pin = "0"
    end
end

function Atm:response(...)
    if arg[1] then
        if arg[2] then exports.TR_noti:create(arg[2], arg[3]) end
        self.bankmoney = self.bankmoney + arg[4]
        self.money = self.money - arg[4]

        exports.TR_achievements:addAchievements("useATM")
    else
        if arg[2] then exports.TR_noti:create(arg[2], arg[3]) end
    end
end

function Atm:isMouseInPosition(x, y, width, height)
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


function createAtm(...)
    if guiInfo.atm then return end
    guiInfo.atm = Atm:create(...)
end
addEvent("createAtm", true)
addEventHandler("createAtm", root, createAtm)

function responseAtm(...)
    if not guiInfo.atm then return end
    guiInfo.atm:response(...)
end
addEvent("responseAtm", true)
addEventHandler("responseAtm", root, responseAtm)