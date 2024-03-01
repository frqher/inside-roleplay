local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    logo = {
        x = (720/zoom - 230/zoom)/2,
        y = 100/zoom,
        w = 230/zoom,
        h = 230/zoom,
    },

    button = {
        x = (720/zoom - 300/zoom)/2,
        y = 100/zoom,
        w = 300/zoom,
        h = 50/zoom,
    },

    info = {
        x = 50/zoom,
        y = sy - 80/zoom,
        w = 39/zoom,
        h = 39/zoom,
    },

    faq = {
        x = 720/zoom,
        y = (sy - 640/zoom)/2,
        w = sx - 200/zoom,
        h = 5000/zoom,

        questions = {
            {
                question = "Premium hizmetle ilgili bir sorunum olursa ne olur?",
                answer = "If you purchased the DIAMOND/GOLD premium service and did not receive it in your inventory (category: other) or you have a problem with purchasing the service, report the problem in the help section on the forum or write a private message to someone from the Guardian group or the Management Board in a private message on the forum or Discord.",
                height = 110,
            },
            {
                question = "Ya sunucuda yardıma ihtiyacınız olursa?",
                answer = "Jeżeli masz jakiś problem związany z rozgrywką na serwerze możesz skorzystać z komendy /report. Jeśli dostępny będzie jakiś Administrator, to niezwłocznie odpowie na twoje zgłoszenie i postara się pomóc jak tylko będzie w stanie. Jeżeli problem wynika z kwestii technicznych \n(np. błąd w pracy dorywczej), utwórz wątek w dziale błędów na forum, a my postaramy się go poprawić jak najszybciej.",
                height = 110,
            },
            {
                question = "İlk paramı nerede kazanacağım?",
                answer = "Jeżeli jesteś nowym graczem i dopiero zaczynasz swoją przygodę z InsideMTA zapewne interesuje cię to, gdzie mógłbyś zarobić swoje pierwsze pieniądze. W końcu możesz je wydać na przykład na swoją pierwszą brykę. Na start zarobki w każdej pracy będą zbliżone do siebie w taki sposób, abyście mogli wypróbować każdą z dostępnych prac i wybrać waszą ulubioną. Gdy już znajdziecie swojego faworyta będziecie mogli wydawać punkty na ulepszenia, które krok po kroku zwiększą wasze możliwości zarobkowe.",
                height = 130,
            },
            {
                question = "Deneyim puanları nedir?",
                answer = "Punkty doświadczenia są podstawowym elementem stawiającym na rozwój twojej rozgrywki. Przykładowo niektóre prace wymagają większych ilości punktów ze względu na większe wymagania, np. taksówki wymagają prawie 200 punktów doświadczenia abyś nie miał problemu z topografią mapy, której na pewno nauczysz się podczas rozgrywki.",
                height = 110,
            },
            {
                question = "www.insidemta.pl paneline nasıl giriş yapılır?",
                answer = "Panel gracza znajdujący się na stronie internetowej serwera jest połączony przez baze danych z serwerem. Oznacza to, że aby poprawnie zalogować się do panelu musisz użyć tych samych danych logowania, którymi logujesz się w grze. W panelu znajdziesz informacje o graczach, organizacjach, a także sklep premium z różnymi usługami, czy informacje ogólne o twoim koncie w grze.",
                height = 0,
            },
        },
    },

    saving = {
        x = sx - 330/zoom,
        y = sy - 80/zoom,
        w = 39/zoom,
        h = 39/zoom,
    },

    avaliableOptions = {
        {
            text = "Oyuna devam et",
            desc = "Pencereyi kapatır ve oyuna geri döner.",
            type = "close",
        },
        {
            text = "İlerlemeyi kaydet",
            desc = "Geçerli oyunun durumunu kaydeder.",
            type = "save",
        },
        {
            text = "Benchmark",
            desc = "Performans testini etkinleştirir.",
            type = "benchmark",
        },
        {
            text = "Çıkış",
            desc = "Hesapdan Çıkar",
            type = "logout",
        },
        {
            text = "Bağlantıyı Kes",
            desc = "Sunucudan çıkar",
            type = "quit",
        },
    },

    saveDelay = 600000,
}

Menu = {}
Menu.__index = Menu

function Menu:create()
    local instance = {}
    setmetatable(instance, Menu)
    if instance:constructor() then
        return instance
    end
    return false
end

function Menu:constructor()
    self.alpha = 0
    self.postGUI = true
    self.saving = nil

    self.fonts = {}
    self.fonts.faq = exports.TR_dx:getFont(24)
    self.fonts.question = exports.TR_dx:getFont(16)
    self.fonts.answer = exports.TR_dx:getFont(12, "myriadLight")
    self.fonts.info = exports.TR_dx:getFont(15, "myriadLight")
    self.fonts.btn = exports.TR_dx:getFont(13)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.keyClick = function(...) self:keyClick(...) end
    self.func.mouseClick = function(...) self:mouseClick(...) end
    self.func.mouseClick = function(...) self:mouseClick(...) end

    addEventHandler("onClientKey", root, self.func.keyClick)
    return true
end

function Menu:open()
    if self.opened then return end
    self.opened = true

    self.state = "show"
    self.tick = getTickCount()

    exports.TR_dx:setEscapeOpen(true)

    showCursor(true)
    addEventHandler("onClientRender", root, self.func.render, false, "low")
    addEventHandler("onClientClick", root, self.func.mouseClick)
end

function Menu:close()
    if self.saving then return end
    if not self.opened then return end

    self.state = "hide"
    self.tick = getTickCount()

    showCursor(false)
    removeEventHandler("onClientClick", root, self.func.mouseClick)
end

function Menu:destroy()

    exports.TR_dx:setEscapeOpen(false)

    self.opened = nil
    removeEventHandler("onClientRender", root, self.func.render, false, "low")
end

function Menu:animate()
    if not self.tick then return end
    if self.state == "show" then
        local progress = (getTickCount() - self.tick)/500
        self.alpha = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "Linear")

        if progress >= 1 then
            self.alpha = 1
            self.tick = nil
            self.state = nil
        end

    elseif self.state == "hide" then
        local progress = (getTickCount() - self.tick)/500
        self.alpha = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "Linear")

        if progress >= 1 then
            self.alpha = 0
            self.tick = nil
            self.state = nil
            self:destroy()
        end
    end
end

function Menu:render()
    self:animate()
    dxDrawImage(0, 0, sx, sy, "files/images/bg.png", 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha), self.postGUI)
    dxDrawImage(guiInfo.logo.x, guiInfo.logo.y, guiInfo.logo.w, guiInfo.logo.h, "files/images/logo.png", 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha), self.postGUI)
    dxDrawImage(guiInfo.info.x, guiInfo.info.y, guiInfo.info.w, guiInfo.info.h, "files/images/info.png", 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha), self.postGUI)

    dxDrawText("Temel MTA menüsünü açmak için ESC tuşuna basabilirsiniz.", guiInfo.info.x + guiInfo.info.w + 10/zoom, 30/zoom, sx - 40/zoom, 0, tocolor(77, 77, 77, 255 * self.alpha), 1/zoom, self.fonts.info, "right", "top", false, false, self.postGUI)

    self:renderButtons()
    self:renderSaving()
    self:renderFAQ()
end

function Menu:renderFAQ()
    dxDrawText("Sıkça sorulan sorular ve cevaplar:", guiInfo.faq.x, guiInfo.faq.y, guiInfo.faq.w, guiInfo.faq.h, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.faq, "left", "top", false, false, self.postGUI)

    local height = 0
    for i, v in pairs(guiInfo.faq.questions) do
        dxDrawText(v.question, guiInfo.faq.x, guiInfo.faq.y + 60/zoom + height, guiInfo.faq.w, guiInfo.faq.h, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.question, "left", "top", true, true, self.postGUI)
        dxDrawText(v.answer, guiInfo.faq.x, guiInfo.faq.y + 88/zoom + height, guiInfo.faq.w, guiInfo.faq.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.answer, "left", "top", true, true, self.postGUI)
        height = height + v.height
    end
end

function Menu:renderSaving()
    if not self.saving then return end
    if (getTickCount() - self.saving[2])/300 >= 1 then
        self.saving[1] = self.saving[1] .. "."
        self.saving[2] = getTickCount()
        if self.saving[1] == "...." then
            self.saving[1] = "."
        end
    end

    dxDrawImage(guiInfo.saving.x, guiInfo.saving.y, guiInfo.saving.w, guiInfo.saving.h, "files/images/save.png", 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha), self.postGUI)
    dxDrawText("Oyun Kaydediliyor"..self.saving[1], guiInfo.saving.x + guiInfo.saving.w + 10/zoom, guiInfo.saving.y, guiInfo.saving.x, guiInfo.saving.y + guiInfo.saving.h, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.info, "left", "center", false, false, self.postGUI)
end

function Menu:renderButtons()
    local description = "Daha fazla bilgi edinmek için bir seçeneğin üzerine gelin."
    for i, v in pairs(guiInfo.avaliableOptions) do
        if v.type == "save" then
            if self.lastSave then
                local time = self:formatTime((guiInfo.saveDelay - (getTickCount() - self.lastSave)))
                if (getTickCount() - self.lastSave)/guiInfo.saveDelay >= 1 then
                    self.lastSave = nil
                    time = "00:00"
                end
                self:drawBackground(guiInfo.button.x, guiInfo.logo.y + guiInfo.logo.h + 40/zoom + (i-1) * (guiInfo.button.h + 10/zoom), 300/zoom, guiInfo.button.h, tocolor(24, 24, 24, 50 * self.alpha), 4, self.postGUI)
                dxDrawText(time, guiInfo.button.x, guiInfo.logo.y + guiInfo.logo.h + 40/zoom + (i-1) * (guiInfo.button.h + 10/zoom), guiInfo.button.x + guiInfo.button.w, guiInfo.logo.y + guiInfo.logo.h + 40/zoom + (i-1) * (guiInfo.button.h + 10/zoom) + guiInfo.button.h, tocolor(130, 130, 130, 150 * self.alpha), 1/zoom, self.fonts.btn, "center", "center", false, false, self.postGUI)

                if self:isMouseInPosition(guiInfo.button.x, guiInfo.logo.y + guiInfo.logo.h + 40/zoom + (i-1) * (guiInfo.button.h + 10/zoom), guiInfo.button.w, guiInfo.button.h) and not self.saving and not self.blockClick then
                    description = v.desc
                end
            else
                description = self:drawButton(i, v) or description
            end
        else
            description = self:drawButton(i, v) or description
        end
    end
    dxDrawText(description, guiInfo.info.x + guiInfo.info.w + 10/zoom, guiInfo.info.y, guiInfo.info.x, guiInfo.info.y + guiInfo.info.h, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.info, "left", "center", false, false, self.postGUI)
end

function Menu:drawButton(i, v)
    if self:isMouseInPosition(guiInfo.button.x, guiInfo.logo.y + guiInfo.logo.h + 40/zoom + (i-1) * (guiInfo.button.h + 10/zoom), guiInfo.button.w, guiInfo.button.h) and not self.saving and not self.blockClick then
        self:drawBackground(guiInfo.button.x, guiInfo.logo.y + guiInfo.logo.h + 40/zoom + (i-1) * (guiInfo.button.h + 10/zoom), 300/zoom, guiInfo.button.h, tocolor(57, 57, 57, 200 * self.alpha), 4, self.postGUI)
        dxDrawText(v.text, guiInfo.button.x, guiInfo.logo.y + guiInfo.logo.h + 40/zoom + (i-1) * (guiInfo.button.h + 10/zoom), guiInfo.button.x + guiInfo.button.w, guiInfo.logo.y + guiInfo.logo.h + 40/zoom + (i-1) * (guiInfo.button.h + 10/zoom) + guiInfo.button.h, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.btn, "center", "center", false, false, self.postGUI)
        return v.desc
    else
        self:drawBackground(guiInfo.button.x, guiInfo.logo.y + guiInfo.logo.h + 40/zoom + (i-1) * (guiInfo.button.h + 10/zoom), 300/zoom, guiInfo.button.h, tocolor(24, 24, 24, 100 * self.alpha), 4, self.postGUI)
        dxDrawText(v.text, guiInfo.button.x, guiInfo.logo.y + guiInfo.logo.h + 40/zoom + (i-1) * (guiInfo.button.h + 10/zoom), guiInfo.button.x + guiInfo.button.w, guiInfo.logo.y + guiInfo.logo.h + 40/zoom + (i-1) * (guiInfo.button.h + 10/zoom) + guiInfo.button.h, tocolor(130, 130, 130, 255 * self.alpha), 1/zoom, self.fonts.btn, "center", "center", false, false, self.postGUI)
    end
    return nil
end

function Menu:keyClick(...)
    if not arg[2] then return end
    if not getElementData(localPlayer, "characterUID") then return end
    if exports.TR_chat:isChatOpened() then return end
    if arg[1] == "escape" and not self.opened then
        cancelEvent()
        self:open()
    end
end

function Menu:mouseClick(...)
    if arg[1] ~= "left" or arg[2] ~= "down" then return end
    for i, v in pairs(guiInfo.avaliableOptions) do
        if self:isMouseInPosition(guiInfo.button.x, guiInfo.logo.y + guiInfo.logo.h + 40/zoom + (i-1) * (guiInfo.button.h + 10/zoom), guiInfo.button.w, guiInfo.button.h) then
            self:useButton(v.type)
            return
        end
    end
end

function Menu:useButton(...)
    if self.blockClick then return end
    if arg[1] == "close" then
        self:close()

    elseif arg[1] == "save" then
        if self.lastSave then return end
        self.saving = {"", getTickCount()}
        triggerServerEvent("savePlayerEscapeData", resourceRoot)

    elseif arg[1] == "benchmark" then
        if getElementData(source, "isOnEvent") or getElementData(source, "waitingEvent") then exports.TR_noti:create(source, "Bir etkinlik sırasında test başlatamazsınız.", "error") return end
        if isElement(getElementData(source, "cuffed")) or isElement(getElementData(source, "cuffedBy")) then exports.TR_noti:create(source, "Testi şimdi başlatamazsınız.", "error") return end

        local job = exports.TR_jobs:getPlayerJob()
        if job then exports.TR_noti:create("NÇalışırken testi başlatamazsınız.", "error") return end

        createBenchmark()
        self:close()

    elseif arg[1] == "logout" then
        self.blockClick = true
        triggerServerEvent("redirectPlayerToServer", resourceRoot)

    elseif arg[1] == "quit" then
        self.blockClick = true
        triggerServerEvent("kickPlayer", resourceRoot, localPlayer, "SYSTEM", "Sunucudan başarıyla ayrıldınız. Sonsuza kadar olmamasını umuyoruz.")
    end
end

function Menu:response(...)
    setTimer(function(...)
        self.saving = nil
        self.lastSave = getTickCount()
        self.blockClick = nil
    end, 3500, 1)
end

function Menu:formatTime(...)
    local ms = tonumber(arg[1])/1000
    return string.format("%02d:%02d", math.floor(ms / 60), (ms % 60))
end

function Menu:drawBackground(x, y, rx, ry, color, radius, post)
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

function Menu:openNoti(text)

end

function Menu:isMouseInPosition(x, y, width, height)
    if (not isCursorShowing()) then return false end
    local cx, cy = getCursorPosition()
    local cx, cy = (cx*sx), (cy*sy)
    if (cx >= x and cx <= x + width) and (cy >= y and cy <= y + height) then return true end
    return false
end

settings.menu = Menu:create()
function responseEscapeMenu(...)
    if not settings.menu then return end
    settings.menu:response(...)
end
addEvent("responseEscapeMenu", true)
addEventHandler("responseEscapeMenu", root, responseEscapeMenu)

exports.TR_dx:setEscapeOpen(false)