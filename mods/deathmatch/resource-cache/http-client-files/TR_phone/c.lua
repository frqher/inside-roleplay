local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end
local guiInfo = {
    x = sx - 249/zoom,
    y = sy - 547/zoom,
    w = 229/zoom,
    h = 527/zoom,

    numButtons = {
        1, 2, 3, 4, 5, 6, 7, 8, 9, "*", 0, "#"
    },

    menu = {
        {"Rehber.", "phoneBook"},
        {"Engellenenler.", "blockList"},
        {"Zil", "ringTones"},
        {"Ses V.", "volume"},
    },

    volumes = {
        {"Yüksek", 1}, {"ORTALAMA", 0.6}, {"Kısık", 0.2}, {"SESSİZ", 0}
    },

    specialNumbersCount = 0,
}

Phone = {}
Phone.__index = Phone

function Phone:create(...)
    local instance = {}
    setmetatable(instance, Phone)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function Phone:constructor(...)
    self.alpha = 0
    self.ringToneSelected =  1
    self.volume =  1
    self.blocked = {}

    self.fonts = {}
    self.fonts.menu = dxCreateFont("files/fonts/font.ttf", 10)
    self.fonts.number = dxCreateFont("files/fonts/font.ttf", 16)
    -- self.fonts.info = exports.TR_dx:getFont(12)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.handleClick = function(...) self:handleClick(...) end
    self.func.cancelTimeCall = function(...) self:cancelTimeCall(...) end

    guiInfo.targetY = guiInfo.y
    guiInfo.y = sy

    triggerServerEvent("getPhoneData", resourceRoot)
    return true
end

function Phone:setPhoneData(...)
    self.ringToneSelected = arg[1] and tonumber(arg[1]) or 1
    self.volume = arg[2] and tonumber(arg[2]) or 1
    self.blocked = arg[3] or {}
end

function Phone:switch()
    if not self.state then
        self:open()

    elseif self.state == "opened" then
        self:close()
    end
end

function Phone:getTab()
    if self.speakingPlayer then
        self.tab = "speaking"
    elseif self.phoningPlayer then
        self.tab = "acceptCall"
    elseif self.notPickedPlayer then
        self.tab = "notPickedUp"
    elseif self.declinePlayer then
        self.tab = "decline"
    elseif self.endCallPlayer then
        self.tab = "endCall"
     end
end

function Phone:open()
    local isTutorial = exports.TR_tutorial:isTutorialOpen()
    if isTutorial then
        if isTutorial ~= 15 then return end
        exports.TR_tutorial:setNextState(true)
    else
        if not exports.TR_dx:canOpenGUI() then return end
    end

    self.state = "opening"
    self.tick = getTickCount()

    self.lastTab = "main"
    self.tab = "main"

    self.number = ""
    self.selected = 0

    self.phone = dxCreateTexture("files/images/phone.png", "argb", true, "clamp")
    self.phoneButtons = dxCreateTexture("files/images/phone_buttons.png", "argb", true, "clamp")
    self.phoneSignal = dxCreateTexture("files/images/phone_signal.png", "argb", true, "clamp")
    self.phoneWallpaper = dxCreateTexture("files/images/phone_wallpaper.png", "argb", true, "clamp")

    exports.TR_dx:setOpenGUI(true)

    self:getTab()
    showCursor(true, true)
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientClick", root, self.func.handleClick)
end

function Phone:close()
    local isTutorial = exports.TR_tutorial:isTutorialOpen()
    if isTutorial then
        if isTutorial ~= 17 then return end
    else
        if exports.TR_dx:isResponseEnabled() then return end
    end


    if self.response then return end
    self.state = "closing"
    self.tick = getTickCount()

    showCursor(false)
    removeEventHandler("onClientClick", root, self.func.handleClick)
    if isElement(self.ringTone) then destroyElement(self.ringTone) end
end

function Phone:destroy()
    if isElement(self.phone) then destroyElement(self.phone) end
    if isElement(self.phoneButtons) then destroyElement(self.phoneButtons) end
    if isElement(self.phoneSignal) then destroyElement(self.phoneSignal) end
    if isElement(self.phoneWallpaper) then destroyElement(self.phoneWallpaper) end
    -- if isElement() then destroyElement() end

    if not exports.TR_tutorial:isTutorialOpen() then exports.TR_dx:setOpenGUI(false) end
    removeEventHandler("onClientRender", root, self.func.render)
end

function Phone:animate()
    if not self.tick then return end
    local progress = (getTickCount() - self.tick)/500
    if self.state == "opening" then
      self.alpha, guiInfo.y = interpolateBetween(0, sy, 0, 1, guiInfo.targetY, 0, progress, "Linear")
      if progress >= 1 then
        self.alpha = 1
        self.state = "opened"
        self.tick = nil
      end

    elseif self.state == "closing" then
      self.alpha, guiInfo.y = interpolateBetween(1, guiInfo.targetY, 0, 0, sy, 0, progress, "Linear")
      if progress >= 1 then
        self.alpha = 0
        self.state = nil
        self.tick = nil

        self:destroy()
      end
    end
end

function Phone:render()
    self:animate()
    if not self.state then return end

    dxDrawImage(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, self.phoneButtons, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
    self:renderNumButtons()
    self:renderFuncButtons()
    dxDrawImage(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, self.phone, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))


    -- Signal and battery
    dxDrawImage(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, self.phoneSignal, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
    self:dxDrawProgressBar(guiInfo.x + 145/zoom, guiInfo.y + 80/zoom, 30/zoom, 8/zoom, 65)

    dxDrawRectangle(guiInfo.x + 59/zoom, guiInfo.y + 195/zoom, 104/zoom, 2/zoom, tocolor(26, 28, 22, 255 * self.alpha))


    -- dxDrawRectangle(guiInfo.x + 34/zoom, guiInfo.y + 68/zoom, 154/zoom, 148/zoom, tocolor(255, 11, 8, 150 * self.alpha)) -- Screen pos
    -- dxDrawText("999999999", guiInfo.x + 32/zoom, guiInfo.y + 660/zoom, guiInfo.x + 194/zoom, guiInfo.y + 703/zoom, tocolor(12, 11, 8, 255 * self.alpha), 1/zoom, self.fonts.main, "right", "top")

    self:drawScreen()
end

function Phone:drawScreen()
    if self.tab == "main" then
        dxDrawImage(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, self.phoneWallpaper, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
        dxDrawText("MENU", guiInfo.x + 34/zoom, guiInfo.y + 68/zoom, guiInfo.x + 188/zoom, guiInfo.y + 216/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.menu, "center", "bottom")

    elseif self.tab == "number" then
        dxDrawText(self.number, guiInfo.x + 34/zoom, guiInfo.y + 68/zoom, guiInfo.x + 180/zoom, guiInfo.y + 216/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.number, "right", "center", true, true)
        dxDrawText("USUN", guiInfo.x + 34/zoom, guiInfo.y + 68/zoom, guiInfo.x + 188/zoom, guiInfo.y + 216/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.menu, "center", "bottom")

    elseif self.tab == "menu" then
        dxDrawText("Seç", guiInfo.x + 34/zoom, guiInfo.y + 68/zoom, guiInfo.x + 188/zoom, guiInfo.y + 216/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.menu, "center", "bottom")

        for i = 1, 4 do
            if guiInfo.menu[self.selected + i] then
                if i == 1 then
                    dxDrawRectangle(guiInfo.x + 33/zoom, guiInfo.y + 108/zoom + (i-1) * 22/zoom, 154/zoom, 20/zoom, tocolor(108, 115, 94, 80 * self.alpha))
                end
                dxDrawText(guiInfo.menu[self.selected + i][1], guiInfo.x + 40/zoom, guiInfo.y + 108/zoom + (i-1) * 22/zoom, guiInfo.x + 188/zoom, guiInfo.y + 128/zoom + (i-1) * 22/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.menu, "left", "center")
            end
        end

    elseif self.tab == "phoneBook" then
        dxDrawText("Seç", guiInfo.x + 34/zoom, guiInfo.y + 68/zoom, guiInfo.x + 188/zoom, guiInfo.y + 216/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.menu, "center", "bottom")

        for i = 1, 4 do
            if self.players[i + self.selected] then
                if i == 1 then
                    dxDrawRectangle(guiInfo.x + 33/zoom, guiInfo.y + 108/zoom + (i-1) * 22/zoom, 154/zoom, 20/zoom, tocolor(108, 115, 94, 80 * self.alpha))
                end
                dxDrawText(self.players[i + self.selected], guiInfo.x + 40/zoom, guiInfo.y + 108/zoom + (i-1) * 22/zoom, guiInfo.x + 188/zoom, guiInfo.y + 128/zoom + (i-1) * 22/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.menu, "left", "center")

            end
        end

    elseif self.tab == "ringTones" then
        dxDrawText("Ayarlar", guiInfo.x + 34/zoom, guiInfo.y + 68/zoom, guiInfo.x + 188/zoom, guiInfo.y + 216/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.menu, "center", "bottom")

        for i = 1, 4 do
            if ringTones[i + self.selected] then
                if i == 1 then
                    dxDrawRectangle(guiInfo.x + 33/zoom, guiInfo.y + 108/zoom + (i-1) * 22/zoom, 154/zoom, 20/zoom, tocolor(108, 115, 94, 80 * self.alpha))
                end
                dxDrawText(ringTones[i + self.selected][1], guiInfo.x + 40/zoom, guiInfo.y + 108/zoom + (i-1) * 22/zoom, guiInfo.x + 188/zoom, guiInfo.y + 128/zoom + (i-1) * 22/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.menu, "left", "center")

            end
        end

    elseif self.tab == "volume" then
        dxDrawText("Ayarlar", guiInfo.x + 34/zoom, guiInfo.y + 68/zoom, guiInfo.x + 188/zoom, guiInfo.y + 216/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.menu, "center", "bottom")

        for i = 1, 4 do
            if guiInfo.volumes[i + self.selected] then
                if i == 1 then
                    dxDrawRectangle(guiInfo.x + 33/zoom, guiInfo.y + 108/zoom + (i-1) * 22/zoom, 154/zoom, 20/zoom, tocolor(108, 115, 94, 80 * self.alpha))
                end
                dxDrawText(guiInfo.volumes[i + self.selected][1], guiInfo.x + 40/zoom, guiInfo.y + 108/zoom + (i-1) * 22/zoom, guiInfo.x + 188/zoom, guiInfo.y + 128/zoom + (i-1) * 22/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.menu, "left", "center")

            end
        end

    elseif self.tab == "blockList" then
        dxDrawText("USUN", guiInfo.x + 34/zoom, guiInfo.y + 68/zoom, guiInfo.x + 188/zoom, guiInfo.y + 216/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.menu, "center", "bottom")

        for i = 1, 4 do
            if self.blocked[i + self.selected] then
                if i == 1 then
                    dxDrawRectangle(guiInfo.x + 33/zoom, guiInfo.y + 108/zoom + (i-1) * 22/zoom, 154/zoom, 20/zoom, tocolor(108, 115, 94, 80 * self.alpha))
                end
                dxDrawText(self.blocked[i + self.selected], guiInfo.x + 40/zoom, guiInfo.y + 108/zoom + (i-1) * 22/zoom, guiInfo.x + 188/zoom, guiInfo.y + 128/zoom + (i-1) * 22/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.menu, "left", "center")

            end
        end

    elseif self.tab == "ringTonesNew" then
        dxDrawText("OK", guiInfo.x + 34/zoom, guiInfo.y + 68/zoom, guiInfo.x + 188/zoom, guiInfo.y + 216/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.menu, "center", "bottom")
        dxDrawText(string.format("AyarlarIONO %s JAKO NOWY DZWONEK", self.newRingtone), guiInfo.x + 34/zoom, guiInfo.y + 68/zoom, guiInfo.x + 188/zoom, guiInfo.y + 216/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.menu, "center", "center", true, true)

    elseif self.tab == "volumeNew" then
        dxDrawText("OK", guiInfo.x + 34/zoom, guiInfo.y + 68/zoom, guiInfo.x + 188/zoom, guiInfo.y + 216/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.menu, "center", "bottom")
        dxDrawText(string.format("AyarlarIONO Ses V. NA %s", self.newVolume), guiInfo.x + 34/zoom, guiInfo.y + 68/zoom, guiInfo.x + 188/zoom, guiInfo.y + 216/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.menu, "center", "center", true, true)

    elseif self.tab == "addedBlocked" then
        dxDrawText("OK", guiInfo.x + 34/zoom, guiInfo.y + 68/zoom, guiInfo.x + 188/zoom, guiInfo.y + 216/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.menu, "center", "bottom")
        dxDrawText(string.format("DODANO %s DO BLOKOWANYCH KONTAKTOW", self.addedBlock), guiInfo.x + 34/zoom, guiInfo.y + 68/zoom, guiInfo.x + 188/zoom, guiInfo.y + 216/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.menu, "center", "center", true, true)

    elseif self.tab == "invalidCall" then
        dxDrawText("OK", guiInfo.x + 34/zoom, guiInfo.y + 68/zoom, guiInfo.x + 188/zoom, guiInfo.y + 216/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.menu, "center", "bottom")
        dxDrawText("NIEPOPRAWNY NUMER", guiInfo.x + 34/zoom, guiInfo.y + 68/zoom, guiInfo.x + 188/zoom, guiInfo.y + 216/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.menu, "center", "center", true, true)

    elseif self.tab == "blockListRemoved" then
        dxDrawText("OK", guiInfo.x + 34/zoom, guiInfo.y + 68/zoom, guiInfo.x + 188/zoom, guiInfo.y + 216/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.menu, "center", "bottom")
        dxDrawText(string.format("USUNIETO %s Z BLOKOWANYCH KONTAKTOW", self.blockedRemoved), guiInfo.x + 34/zoom, guiInfo.y + 68/zoom, guiInfo.x + 188/zoom, guiInfo.y + 216/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.menu, "center", "center", true, true)

    elseif self.tab == "calling" then
        dxDrawText("Zil", guiInfo.x + 34/zoom, guiInfo.y + 68/zoom, guiInfo.x + 188/zoom, guiInfo.y + 216/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.menu, "center", "bottom")
        dxDrawText(self.phoningPlayerName, guiInfo.x + 34/zoom, guiInfo.y + 68/zoom, guiInfo.x + 180/zoom, guiInfo.y + 216/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.number, "right", "center", true, true)

    elseif self.tab == "acceptCall" then
        dxDrawText("Arama yap", guiInfo.x + 34/zoom, guiInfo.y + 68/zoom, guiInfo.x + 188/zoom, guiInfo.y + 216/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.menu, "center", "bottom")
        dxDrawText(self.phoningPlayerName, guiInfo.x + 34/zoom, guiInfo.y + 68/zoom, guiInfo.x + 180/zoom, guiInfo.y + 216/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.number, "right", "center", true, true)

    elseif self.tab == "notPickedUp" then
        dxDrawText("Alınamadı", guiInfo.x + 34/zoom, guiInfo.y + 68/zoom, guiInfo.x + 188/zoom, guiInfo.y + 216/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.menu, "center", "bottom")
        dxDrawText(self.notPickedPlayerName, guiInfo.x + 34/zoom, guiInfo.y + 68/zoom, guiInfo.x + 180/zoom, guiInfo.y + 216/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.number, "right", "center", true, true)

    elseif self.tab == "speaking" then
        dxDrawText(self:getTimeInSeconds((getTickCount() - self.speakingTime)/1000), guiInfo.x + 34/zoom, guiInfo.y + 68/zoom, guiInfo.x + 188/zoom, guiInfo.y + 194/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.menu, "center", "bottom")
        dxDrawText("GÖRÜŞME DEVAM EDİYOR", guiInfo.x + 34/zoom, guiInfo.y + 68/zoom, guiInfo.x + 188/zoom, guiInfo.y + 216/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.menu, "center", "bottom")
        dxDrawText(self.speakingPlayerName, guiInfo.x + 34/zoom, guiInfo.y + 68/zoom, guiInfo.x + 180/zoom, guiInfo.y + 216/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.number, "right", "center", true, true)

    elseif self.tab == "decline" then
        dxDrawText("Reddet", guiInfo.x + 34/zoom, guiInfo.y + 68/zoom, guiInfo.x + 188/zoom, guiInfo.y + 216/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.menu, "center", "bottom")
        dxDrawText(self.declinePlayerName, guiInfo.x + 34/zoom, guiInfo.y + 68/zoom, guiInfo.x + 180/zoom, guiInfo.y + 216/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.number, "right", "center", true, true)

    elseif self.tab == "endCall" then
        dxDrawText(self:getTimeInSeconds(self.endCallPlayerTime), guiInfo.x + 34/zoom, guiInfo.y + 68/zoom, guiInfo.x + 188/zoom, guiInfo.y + 194/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.menu, "center", "bottom")
        dxDrawText("Konuşmayı bitir", guiInfo.x + 34/zoom, guiInfo.y + 68/zoom, guiInfo.x + 188/zoom, guiInfo.y + 216/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.menu, "center", "bottom")
        dxDrawText(self.endCallPlayerName, guiInfo.x + 34/zoom, guiInfo.y + 68/zoom, guiInfo.x + 180/zoom, guiInfo.y + 216/zoom, tocolor(26, 28, 22, 255 * self.alpha), 1/zoom, self.fonts.number, "right", "center", true, true)

    end
end

function Phone:renderNumButtons()
    local r = 0
    local c = 0
    for _, v in pairs(guiInfo.numButtons) do
        local lower = r ~= 1 and c * 42/zoom or 10/zoom + c * 42/zoom
        local height = r ~= 1 and 42/zoom or 35/zoom

        if self:isMouseInPosition(guiInfo.x + 24/zoom + r * 60/zoom, guiInfo.y + 336/zoom + lower, 58/zoom, height) then
            dxDrawRectangle(guiInfo.x + 24/zoom + r * 60/zoom, guiInfo.y + 336/zoom + lower, 58/zoom, height, tocolor(255, 255, 255, 20 * self.alpha))
        end
        r = r + 1
        if r == 3 then
            r = 0
            c = c + 1
        end
    end
end

function Phone:renderFuncButtons()
    if self:isMouseInPosition(guiInfo.x + 24/zoom, guiInfo.y + 280/zoom, 42/zoom, 50/zoom) then  -- Green
        dxDrawRectangle(guiInfo.x + 24/zoom, guiInfo.y + 280/zoom, 42/zoom, 50/zoom, tocolor(255, 255, 255, 10 * self.alpha))
    end

    if self:isMouseInPosition(guiInfo.x + 158/zoom, guiInfo.y + 280/zoom, 42/zoom, 50/zoom) then  -- Red
        dxDrawRectangle(guiInfo.x + 158/zoom, guiInfo.y + 280/zoom, 42/zoom, 50/zoom, tocolor(255, 255, 255, 10 * self.alpha))
    end

    if self:isMouseInPosition(guiInfo.x + 84/zoom, guiInfo.y + 274/zoom, 56/zoom, 14/zoom) then  -- Up
        dxDrawRectangle(guiInfo.x + 84/zoom, guiInfo.y + 274/zoom, 56/zoom, 14/zoom, tocolor(255, 255, 255, 15 * self.alpha))
    end

    if self:isMouseInPosition(guiInfo.x + 84/zoom, guiInfo.y + 323/zoom, 56/zoom, 14/zoom) then  -- Down
        dxDrawRectangle(guiInfo.x + 84/zoom, guiInfo.y + 323/zoom, 56/zoom, 14/zoom, tocolor(255, 255, 255, 15 * self.alpha))
    end

    if self:isMouseInPosition(guiInfo.x + 70/zoom, guiInfo.y + 288/zoom, 14/zoom, 35/zoom) then  -- Left
        dxDrawRectangle(guiInfo.x + 70/zoom, guiInfo.y + 288/zoom, 14/zoom, 35/zoom, tocolor(255, 255, 255, 15 * self.alpha))
    end

    if self:isMouseInPosition(guiInfo.x + 140/zoom, guiInfo.y + 288/zoom, 14/zoom, 35/zoom) then -- Right
        dxDrawRectangle(guiInfo.x + 140/zoom, guiInfo.y + 288/zoom, 14/zoom, 35/zoom, tocolor(255, 255, 255, 15 * self.alpha))
    end

    if self:isMouseInPosition(guiInfo.x + 84/zoom, guiInfo.y + 288/zoom, 56/zoom, 35/zoom) then -- Center
        dxDrawRectangle(guiInfo.x + 84/zoom, guiInfo.y + 288/zoom, 56/zoom, 35/zoom, tocolor(255, 255, 255, 10 * self.alpha))
    end
end

function Phone:handleClick(...)
    if self.response then return end
    if arg[1] == "left" and arg[2] == "down" then
        if self.tab == "main" then
            if self:isMouseInPosition(guiInfo.x + 84/zoom, guiInfo.y + 288/zoom, 56/zoom, 35/zoom) then
                self:changeMenu("menu")
            else
                self:phoneNumberClick()
            end

        elseif self.tab == "number" then
            if self:isMouseInPosition(guiInfo.x + 158/zoom, guiInfo.y + 280/zoom, 42/zoom, 50/zoom) then
                self:changeMenu("main")

            elseif self:isMouseInPosition(guiInfo.x + 24/zoom, guiInfo.y + 280/zoom, 42/zoom, 50/zoom) then
                self.response = true
                self.phoningPlayerName = self.number

                if string.sub(self.number, 1, 2) == "55" and string.len(self.number) == 7 then
                    local player = self:getPlayerByNumber(self.number)

                    if player and player ~= localPlayer then
                        self.phoningPlayer = player
                        self.phoningPlayerName = self.number

                        triggerServerEvent("callPlayerFromPhone", resourceRoot, self.phoningPlayer)
                    else
                        triggerServerEvent("callPhoneNumber", resourceRoot, tostring(self.number))
                    end
                else
                    triggerServerEvent("callPhoneNumber", resourceRoot, tostring(self.number))
                end

                self.phoningTimer = setTimer(self.func.cancelTimeCall, 18000, 1)
                self.phoningSound = playSound("files/sounds/calling.mp3")
                self:changeMenu("calling")

            elseif self:isMouseInPosition(guiInfo.x + 84/zoom, guiInfo.y + 288/zoom, 56/zoom, 35/zoom) then
                if string.len(self.number) <= 0 then return end
                self.number = string.sub(self.number, 1, -2)
                self:clickSound()

            else
                self:phoneNumberClick()
            end

        elseif self.tab == "menu" then
            if self:isMouseInPosition(guiInfo.x + 158/zoom, guiInfo.y + 280/zoom, 42/zoom, 50/zoom) then
                self:changeMenu("main")

            elseif self:isMouseInPosition(guiInfo.x + 84/zoom, guiInfo.y + 274/zoom, 56/zoom, 14/zoom) then
                if self.selected == 0 then return end
                self.selected = self.selected - 1
                self:clickSound()

            elseif self:isMouseInPosition(guiInfo.x + 84/zoom, guiInfo.y + 323/zoom, 56/zoom, 14/zoom) then
                if self.selected + 1 == #guiInfo.menu then return end
                self.selected = self.selected + 1
                self:clickSound()

            elseif self:isMouseInPosition(guiInfo.x + 84/zoom, guiInfo.y + 288/zoom, 56/zoom, 35/zoom) then
                self:changeMenu(guiInfo.menu[self.selected + 1][2])
            end

        elseif self.tab == "phoneBook" then
            if self:isMouseInPosition(guiInfo.x + 158/zoom, guiInfo.y + 280/zoom, 42/zoom, 50/zoom) then
                self:changeMenu("menu")

            elseif self:isMouseInPosition(guiInfo.x + 24/zoom, guiInfo.y + 280/zoom, 42/zoom, 50/zoom) or self:isMouseInPosition(guiInfo.x + 84/zoom, guiInfo.y + 288/zoom, 56/zoom, 35/zoom) then
                if not self.players[self.selected + 1] then return end
                self.response = true

                if self.selected + 1 <= guiInfo.specialNumbersCount then
                    self.phoningPlayerName = self.players[self.selected + 1]

                    local number = false
                    for i, v in pairs(specialNumbers) do
                        if v == self.phoningPlayerName then
                            number = i
                            break
                        end
                    end

                    self.phoningSound = playSound("files/sounds/calling.mp3")
                    self.phoningTimer = setTimer(self.func.cancelTimeCall, 18000, 1)
                    triggerServerEvent("callPhoneNumber", resourceRoot, tostring(number))

                else
                    self.phoningPlayer = getPlayerFromName(self.players[self.selected + 1])
                    self.phoningPlayerName = self.players[self.selected + 1]
                    self.phoningSound = playSound("files/sounds/calling.mp3")
                    self.phoningTimer = setTimer(self.func.cancelTimeCall, 18000, 1)

                    triggerServerEvent("callPlayerFromPhone", resourceRoot, self.phoningPlayer)
                end
                self:changeMenu("calling")


            elseif self:isMouseInPosition(guiInfo.x + 84/zoom, guiInfo.y + 274/zoom, 56/zoom, 14/zoom) then
                if self.selected == 0 then return end
                self.selected = self.selected - 1
                self:clickSound()

            elseif self:isMouseInPosition(guiInfo.x + 84/zoom, guiInfo.y + 323/zoom, 56/zoom, 14/zoom) then
                if self.selected + 1 == #self.players then return end
                self.selected = self.selected + 1
                self:clickSound()

            elseif self:isMouseInPosition(guiInfo.x + 144/zoom, guiInfo.y + 462/zoom, 58/zoom, 42/zoom) then
                table.insert(self.blocked, self.players[self.selected + 1])
                self.addedBlock = self.players[self.selected + 1]

                triggerServerEvent("updatePhoneBlocked", resourceRoot, toJSON(self.blocked))
                self:changeMenu("addedBlocked")
            end

        elseif self.tab == "blockList" then
            if self:isMouseInPosition(guiInfo.x + 158/zoom, guiInfo.y + 280/zoom, 42/zoom, 50/zoom) then
                self:changeMenu("menu")

            elseif self:isMouseInPosition(guiInfo.x + 84/zoom, guiInfo.y + 288/zoom, 56/zoom, 35/zoom) then
                if #self.blocked <= 0 then return end
                self.blockedRemoved = self.blocked[self.selected + 1]
                table.remove(self.blocked, self.selected + 1)
                self.selected = self.selected - 1

                triggerServerEvent("updatePhoneBlocked", resourceRoot, toJSON(self.blocked))
                self:changeMenu("blockListRemoved")

            elseif self:isMouseInPosition(guiInfo.x + 84/zoom, guiInfo.y + 274/zoom, 56/zoom, 14/zoom) then
                if self.selected == 0 then return end
                self.selected = self.selected - 1
                self:clickSound()

            elseif self:isMouseInPosition(guiInfo.x + 84/zoom, guiInfo.y + 323/zoom, 56/zoom, 14/zoom) then
                if self.selected + 1 == #self.blocked then return end
                self.selected = self.selected + 1
                self:clickSound()
            end

        elseif self.tab == "ringTones" then
            if self:isMouseInPosition(guiInfo.x + 84/zoom, guiInfo.y + 288/zoom, 56/zoom, 35/zoom) then
                self.ringToneSelected = self.selected + 1
                self.newRingtone = ringTones[self.selected + 1][1]
                triggerServerEvent("updatePhoneData", resourceRoot, string.format("%d,%d", self.ringToneSelected, self.volume))

                self:changeMenu("ringTonesNew")

            elseif self:isMouseInPosition(guiInfo.x + 158/zoom, guiInfo.y + 280/zoom, 42/zoom, 50/zoom) then
                self:changeMenu("menu")

            elseif self:isMouseInPosition(guiInfo.x + 84/zoom, guiInfo.y + 274/zoom, 56/zoom, 14/zoom) then
                if self.selected == 0 then return end
                self.selected = self.selected - 1
                self:clickSound()
                self:playRingtone(ringTones[self.selected + 1][2])

            elseif self:isMouseInPosition(guiInfo.x + 84/zoom, guiInfo.y + 323/zoom, 56/zoom, 14/zoom) then
                if self.selected + 1 == #ringTones then return end
                self.selected = self.selected + 1
                self:clickSound()
                self:playRingtone(ringTones[self.selected + 1][2])
            end

        elseif self.tab == "volume" then
            if self:isMouseInPosition(guiInfo.x + 84/zoom, guiInfo.y + 288/zoom, 56/zoom, 35/zoom) then
                self.volume = self.selected + 1
                self.newVolume = guiInfo.volumes[self.selected + 1][1]
                triggerServerEvent("updatePhoneData", resourceRoot, string.format("%d,%d", self.ringToneSelected, self.volume))

                self:changeMenu("volumeNew")

            elseif self:isMouseInPosition(guiInfo.x + 158/zoom, guiInfo.y + 280/zoom, 42/zoom, 50/zoom) then
                self:changeMenu("menu")

            elseif self:isMouseInPosition(guiInfo.x + 84/zoom, guiInfo.y + 274/zoom, 56/zoom, 14/zoom) then
                if self.selected == 0 then return end
                self.selected = self.selected - 1
                self:clickSound()
                self:playRingtone(ringTones[self.ringToneSelected][2], false, self.selected + 1)

            elseif self:isMouseInPosition(guiInfo.x + 84/zoom, guiInfo.y + 323/zoom, 56/zoom, 14/zoom) then
                if self.selected + 1 == #guiInfo.volumes then return end
                self.selected = self.selected + 1
                self:clickSound()
                self:playRingtone(ringTones[self.ringToneSelected][2], false, self.selected + 1)
            end

        elseif self.tab == "ringTonesNew" then
            if self:isMouseInPosition(guiInfo.x + 84/zoom, guiInfo.y + 288/zoom, 56/zoom, 35/zoom) then
                self.newRingtone = nil
                self:changeMenu("menu")
            end

        elseif self.tab == "volumeNew" then
            if self:isMouseInPosition(guiInfo.x + 84/zoom, guiInfo.y + 288/zoom, 56/zoom, 35/zoom) then
                self.newVolume = nil
                self:changeMenu("menu")
            end

        elseif self.tab == "calling" then
            if self:isMouseInPosition(guiInfo.x + 158/zoom, guiInfo.y + 280/zoom, 42/zoom, 50/zoom) then
                triggerServerEvent("stopPlayerCall", resourceRoot, self.phoningPlayer)

                self.phoningPlayer = nil

                if isElement(self.phoningSound) then destroyElement(self.phoningSound) end
                if isTimer(self.phoningTimer) then killTimer(self.phoningTimer) end

                local number = false
                if self.lastTab == "number" then number = self.phoningPlayerName end
                self:changeMenu(self.lastTab)
                if number then self.number = number end
                self.phoningPlayerName = nil
            end

        elseif self.tab == "decline" then
            if self:isMouseInPosition(guiInfo.x + 84/zoom, guiInfo.y + 288/zoom, 56/zoom, 35/zoom) then
                self.declinePlayer = nil
                self.declinePlayerName = nil

                self:changeMenu(self.lastTab)
            end

        elseif self.tab == "notPickedUp" then
            if self:isMouseInPosition(guiInfo.x + 84/zoom, guiInfo.y + 288/zoom, 56/zoom, 35/zoom) then
                self.notPickedPlayer = nil
                self.notPickedPlayerName = nil
                self:changeMenu("main")
            end

        elseif self.tab == "endCall" then
            if self:isMouseInPosition(guiInfo.x + 84/zoom, guiInfo.y + 288/zoom, 56/zoom, 35/zoom) then
                self.endCallPlayer = nil
                self.endCallPlayerName = nil
                self:changeMenu(self.lastTab)
            end

        elseif self.tab == "speaking" then
            if self:isMouseInPosition(guiInfo.x + 158/zoom, guiInfo.y + 280/zoom, 42/zoom, 50/zoom) then
                self.endCallPlayer = self.speakingPlayer
                self.endCallPlayerName = self.speakingPlayerName
                self.endCallPlayerTime = (getTickCount() - self.speakingTime)/1000

                triggerServerEvent("endPlayerCall", resourceRoot, self.speakingPlayer)

                self.speakingPlayer = nil
                self.speakingPlayerName = nil
                self:changeMenu("endCall")
            end

        elseif self.tab == "acceptCall" then
            if self:isMouseInPosition(guiInfo.x + 24/zoom, guiInfo.y + 280/zoom, 42/zoom, 50/zoom) then
                self.speakingPlayer = self.phoningPlayer
                self.speakingPlayerName = self.phoningPlayerName
                self.speakingTime = getTickCount()
                triggerServerEvent("acceptPlayerCall", resourceRoot, self.phoningPlayer)

                exports.TR_noti:create("Telefonda bir şey söylemek için sohbette /t [mesaj] komutunu kullanın.", "info", 5)

                self.phoningPlayer = nil
                self.phoningPlayerName = nil

                self:changeMenu("speaking")

            elseif self:isMouseInPosition(guiInfo.x + 158/zoom, guiInfo.y + 280/zoom, 42/zoom, 50/zoom) then
                triggerServerEvent("declinePlayerCall", resourceRoot, self.phoningPlayer)
                self.phoningPlayer = nil
                self.phoningPlayerName = nil

                if isElement(self.phoningSound) then destroyElement(self.phoningSound) end
                if isTimer(self.phoningTimer) then killTimer(self.phoningTimer) end

                self:changeMenu(self.lastTab)

            elseif self:isMouseInPosition(guiInfo.x + 144/zoom, guiInfo.y + 462/zoom, 58/zoom, 42/zoom) then
                triggerServerEvent("declinePlayerCall", resourceRoot, self.phoningPlayer)
                table.insert(self.blocked, self.phoningPlayerName)

                self.addedBlock = self.phoningPlayerName

                self:changeMenu("addedBlocked")
            end

        elseif self.tab == "addedBlocked" then
            if self:isMouseInPosition(guiInfo.x + 84/zoom, guiInfo.y + 288/zoom, 56/zoom, 35/zoom) then
                self.addedBlock = nil
                self:changeMenu(self.lastTab)
            end

        elseif self.tab == "invalidCall" then
            if self:isMouseInPosition(guiInfo.x + 84/zoom, guiInfo.y + 288/zoom, 56/zoom, 35/zoom) then
                self.addedBlock = nil
                self:changeMenu("main")
            end

        elseif self.tab == "blockListRemoved" then
            if self:isMouseInPosition(guiInfo.x + 84/zoom, guiInfo.y + 288/zoom, 56/zoom, 35/zoom) then
                self.addedBlock = nil
                self:changeMenu(self.lastTab)
            end
        end
    end
end

function Phone:cancelTimeCall()
    if not self.phoningPlayerName then return end
    if self.phoningPlayer then
        triggerServerEvent("declinePlayerCall", resourceRoot, self.phoningPlayer, self.targetIsPhoning)
    end

    self.phoningPlayer = nil
    self.phoningPlayerName = nil

    self:changeMenu(self.lastTab)
end

function Phone:phoneNumberClick(...)
    if string.len(self.number) >= 9 then return end
    local r = 0
    local c = 0
    for _, v in pairs(guiInfo.numButtons) do
        local lower = r ~= 1 and c * 42/zoom or 10/zoom + c * 42/zoom
        local height = r ~= 1 and 42/zoom or 35/zoom

        if self:isMouseInPosition(guiInfo.x + 24/zoom + r * 60/zoom, guiInfo.y + 336/zoom + lower, 58/zoom, height) then
            self:changeMenu("number", true)
            self.number = self.number .. v
            self:clickSound()
            break
        end
        r = r + 1
        if r == 3 then
            r = 0
            c = c + 1
        end
    end
end

function Phone:changeMenu(...)
    if self.tab == arg[1] then return end
    if self.tab ~= "calling" and self.tab ~= "decline" and self.tab ~= "notPickedUp" and self.tab ~= "speaking" and self.tab ~= "acceptCall" then
        self.lastTab = self.tab
    else
        self.lastTab = "main"
    end

    self.tab = arg[1]

    self.number = ""
    self.selected = 0

    if isElement(self.ringTone) then destroyElement(self.ringTone) end
    if self.tab == "phoneBook" then self:getPlayersToBook() end
    if self.tab == "ringTones" then self.selected = self.ringToneSelected - 1 end
    if not arg[2] then self:clickSound() end
end

function Phone:responsePhone(...)
    self.response = nil
    self.targetIsPhoning = nil

    if arg[1] == "isPhoning" then
        self.targetIsPhoning = true
    end
end

function Phone:getPlayersToBook()
    self.players = {}
    -- for _, v in pairs(getElementsByType("player")) do
    --     if v ~= localPlayer and getElementData(v, "characterUID") then
    --         local name = getPlayerName(v)

    --         if not self:isBlocked(name) then
    --             table.insert(self.players, name)
    --         end
    --     end
    -- end
    -- table.sort(self.players)

    self:addSpecialNumbers()
end

function Phone:addSpecialNumbers()
    local count = 0
    for i, v in pairs(specialNumbers) do
        if not disalowedInBook[v] then
            table.insert(self.players, 1, v)
            count = count + 1
        end
    end
    guiInfo.specialNumbersCount = count
end

function Phone:clickSound()
    playSound("files/sounds/click.mp3")
end

function Phone:playRingtone(...)
    if isElement(self.ringTone) then destroyElement(self.ringTone) end
    self.ringTone = playSound(string.format("files/sounds/ringtones/%s.mp3", arg[1]), arg[2])

    if arg[3] then
        setSoundVolume(self.ringTone, guiInfo.volumes[arg[3]][2])
    else
        setSoundVolume(self.ringTone, guiInfo.volumes[self.volume][2])
    end
end

function Phone:dxDrawProgressBar(x, y, w, h, progress)
    dxDrawRectangle(x + w - w * progress/100, y, w * progress/100, h, tocolor(26, 28, 22, 255 * self.alpha))

    dxDrawRectangle(x - 1, y - 1, 2, h + 2, tocolor(26, 28, 22, 255 * self.alpha))
    dxDrawRectangle(x + w - 1, y - 1, 2, h + 2, tocolor(26, 28, 22, 255 * self.alpha))
    dxDrawRectangle(x - 1, y - 1, w, 2, tocolor(26, 28, 22, 255 * self.alpha))
    dxDrawRectangle(x - 1, y + h - 1, w, 2, tocolor(26, 28, 22, 255 * self.alpha))
end

function Phone:getTimeInSeconds(seconds)
    local seconds = tonumber(seconds)

    if seconds <= 0 then
      return "00:00:00";
    else
      hours = string.format("%02.f", math.floor(seconds/3600));
      mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
      secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
      return hours..":"..mins..":"..secs
    end
end

function Phone:isMouseInPosition(psx,psy,pssx,pssy)
    if not isCursorShowing() then return end
    cx,cy=getCursorPosition()
    cx,cy=cx*sx,cy*sy
    if cx >= psx and cx <= psx+pssx and cy >= psy and cy <= psy+pssy then
        return true,cx,cy
    else
        return false
    end
end





function Phone:phonePlayer(...)
    local name = getPlayerName(arg[1])

    if self:isBlocked(name) then
        triggerServerEvent("declinePlayerCall", resourceRoot, arg[1])
        return
    end

    self.phoningPlayer = arg[1]
    self.phoningPlayerName = name

    self:changeMenu("acceptCall")
    self:playRingtone(ringTones[self.ringToneSelected][2], true)
end

function Phone:cancelCall(...)
    if self.speakingPlayer ~= self.phoningPlayer and not self.customNumber then return end

    self.notPickedPlayer = self.phoningPlayer
    self.notPickedPlayerName = self.phoningPlayerName

    self.phoningPlayer = nil
    self.phoningPlayerName = nil

    if isElement(self.phoningSound) then destroyElement(self.phoningSound) end
    if isTimer(self.phoningTimer) then killTimer(self.phoningTimer) end

    self:changeMenu("notPickedUp")
end

function Phone:acceptCall(...)
    if arg[2] then
        self:customNumberEffect(arg[2])
        return
    end

    self.customNumber = nil
    self.speakingPlayer = self.phoningPlayer
    self.speakingPlayerName = self.phoningPlayerName
    self.speakingTime = getTickCount()

    self.phoningPlayer = nil
    self.phoningPlayerName = nil

    if isElement(self.phoningSound) then destroyElement(self.phoningSound) end
    if isTimer(self.phoningTimer) then killTimer(self.phoningTimer) end

    if arg[2] then
        self:customNumberEffect(arg[2])
    else
        exports.TR_noti:create("Telefonda bir şey söylemek için sohbette /t [mesaj] komutunu kullanın.", "info", 5)
    end

    self:changeMenu("speaking")
end

function Phone:declineCall(...)
    self.declinePlayer = self.phoningPlayer
    self.declinePlayerName = self.phoningPlayerName

    self.phoningPlayer = nil
    self.phoningPlayerName = nil

    if isElement(self.phoningSound) then destroyElement(self.phoningSound) end
    if isTimer(self.phoningTimer) then killTimer(self.phoningTimer) end

    self:changeMenu("decline")
end

function Phone:endCall(...)
    self.endCallPlayer = self.speakingPlayer
    self.endCallPlayerName = self.speakingPlayerName
    self.endCallPlayerTime = (getTickCount() - self.speakingTime)/1000

    self.speakingPlayer = nil
    self.speakingPlayerName = nil

    self:changeMenu("endCall")
end

function Phone:invalidCall(...)
    self:responsePhone()

    if isElement(self.phoningSound) then destroyElement(self.phoningSound) end
    if isTimer(self.phoningTimer) then killTimer(self.phoningTimer) end

    self:changeMenu("invalidCall")
end

function Phone:isBlocked(...)
    for i, v in pairs(self.blocked) do
        if arg[1] == v then
            return true
        end
    end
    return false
end

function Phone:getPlayerByNumber()
    local number = tonumber(string.sub(self.number, 3, -1))
    if not number then return end

    for _, v in pairs(getElementsByType("player")) do
        if getElementData(v, "characterUID") == number then
            return v
        end
    end
    return false
end

function Phone:customNumberEffect(...)
    if isTimer(self.phoningTimer) then killTimer(self.phoningTimer) end

    self.phoningTimer = setTimer(function()
        if not self.phoningPlayerName then return end

        if arg[1] == "taxi" then
            self.speakingPlayerName = self.phoningPlayerName
            self.speakingTime = getTickCount()

            self:changeMenu("speaking")

            local id = getElementData(localPlayer, "ID")
            local name = getPlayerName(localPlayer)
            local zone = getZoneName(Vector3(getElementPosition(localPlayer)))

            if isElement(self.phoningSound) then destroyElement(self.phoningSound) end
            if isTimer(self.phoningTimer) then killTimer(self.phoningTimer) end


            exports.TR_chat:showCustomMessage("#009688Taksi çalışanı", "#2a8c44Günaydın. Konuşmanın kayıt altına alındığını hatırlatmak isterim. Size nasıl yardım edebilirim?", "files/images/call.png")
            self.phoningTimer = setTimer(function()
                exports.TR_chat:showCustomMessage(string.format("#009688[%d] %s", id, name), string.format("#2a8c44Günaydın. %s adresinden bir taksi sipariş etmek istiyorum.", zone), "files/images/call.png")

                self.phoningTimer = setTimer(function()
                    local int = getElementInterior(localPlayer)
                    local dim = getElementDimension(localPlayer)

                    if int == 0 and dim == 0 then
                        exports.TR_chat:showCustomMessage("#009688Taksi çalışanı", "#2a8c44Rapor genel merkeze iletildi. Başvurunun taksi şoförümüz tarafından kabul edildiğine ilişkin bilgi SMS ile gönderilecektir. Konuşma için teşekkür ederim. Güle güle.", "files/images/call.png")
                        triggerServerEvent("addTaxiRequest", resourceRoot)

                        exports.TR_achievements:addAchievements("getTaxi")
                    else
                        exports.TR_chat:showCustomMessage("#009688Taksi çalışanı", "#2a8c44Üzgünüz, adresinize taksi gönderemiyoruz. Rahatsızlıklardan dolayı özür dileriz. Güle güle.", "files/images/call.png")
                    end

                    self:endCall()
                end, 3000, 1)

            end, 2000, 1)


        elseif arg[1] == "Yol yardımı" then
            self.speakingPlayerName = self.phoningPlayerName
            self.speakingTime = getTickCount()

            self:changeMenu("speaking")

            local id = getElementData(localPlayer, "ID")
            local name = getPlayerName(localPlayer)
            local zone = getZoneName(Vector3(getElementPosition(localPlayer)))

            if isElement(self.phoningSound) then destroyElement(self.phoningSound) end
            if isTimer(self.phoningTimer) then killTimer(self.phoningTimer) end


            exports.TR_chat:showCustomMessage("#009688Yol yardım görevlisi", "#2a8c44Günaydın. Konuşmanın kayıt altına alındığını hatırlatmak isterim. Size nasıl yardım edebilirim?", "files/images/call.png")
            exports.TR_noti:create("Biletin içeriğini yazmak için /t (içerik) komutunu kullanın.", "info", 10)

        elseif arg[1] == "Alarm" then
            self.speakingPlayerName = self.phoningPlayerName
            self.speakingTime = getTickCount()

            self:changeMenu("speaking")

            local id = getElementData(localPlayer, "ID")
            local name = getPlayerName(localPlayer)
            local zone = getZoneName(Vector3(getElementPosition(localPlayer)))

            if isElement(self.phoningSound) then destroyElement(self.phoningSound) end
            if isTimer(self.phoningTimer) then killTimer(self.phoningTimer) end


            exports.TR_chat:showCustomMessage("#009688911 memuru", "#2a8c44Günaydın. Konuşmanın kayıt altına alındığını hatırlatmak isterim. Size nasıl yardım edebilirim?", "files/images/call.png")
            exports.TR_noti:create("Raporun içeriğini yazmak için /t (p/f/m) (içerik) komutunu kullanın.", "info", 10)

        elseif arg[1] == "tutorial" then
            local isTutorial = exports.TR_tutorial:isTutorialOpen()
            if not isTutorial then return end
            if isTutorial ~= 16 then return end

            self.speakingPlayerName = self.phoningPlayerName
            self.speakingTime = getTickCount()

            self:changeMenu("speaking")

            local id = getElementData(localPlayer, "ID")
            local name = getPlayerName(localPlayer)
            local zone = getZoneName(Vector3(getElementPosition(localPlayer)))

            if isElement(self.phoningSound) then destroyElement(self.phoningSound) end
            if isTimer(self.phoningTimer) then killTimer(self.phoningTimer) end


            exports.TR_chat:showCustomMessage("#009688Dawn Hort", "#2a8c44Merhaba. Neyle ilgili? Kim çağırıyor?", "files/images/call.png")
            self.phoningTimer = setTimer(function()
                exports.TR_chat:showCustomMessage(string.format("#009688[%d] %s", id, name), string.format("#2a8c44%s diyor. Bu numarayı kardeşinden aldım. Görünüşe göre adadan nasıl çıkılacağını bilmiyorsun.", name), "files/images/call.png")

                self.phoningTimer = setTimer(function()
                    exports.TR_chat:showCustomMessage("#009688Dawn Hort", "#2a8c44Otabiki biliyorum. Sanırım kardeşim sana beni aramanı söylediyse zaten oldukça iyi durumdadır. Masadan biraz mal alın. Bir arsa senin, diğerini taşıyıcıya ver, o seni şehre götürecek.", "files/images/call.png")

                    self.phoningTimer = setTimer(function()
                        exports.TR_chat:showCustomMessage(string.format("#009688[%d] %s", id, name), "#2a8c44Dyardımın için çok teşekkürler!", "files/images/call.png")

                        self.phoningTimer = setTimer(function()
                            exports.TR_chat:showCustomMessage("#009688Dawn Hort", "#2a8c44Aynen... Öyle olsa binanın arkasındaki arsanızı yakın. Adada kimse yok ama biliyorsun SWAT'ın kulübeme girmesini istemiyorum.", "files/images/call.png")

                            self.phoningTimer = setTimer(function()
                                exports.TR_chat:showCustomMessage(string.format("#009688[%d] %s", id, name), "#2a8c44O bilir. Şimdilik.", "files/images/call.png")

                                self.phoningTimer = setTimer(function()
                                    exports.TR_chat:showCustomMessage("#009688Dawn Hort", "#2a8c44Dikkatli ol.", "files/images/call.png")
                                    exports.TR_tutorial:setNextState(true)
                                    self:endCall()
                                    self:close()
                                end, 2000, 1)
                            end, 6000, 1)
                        end, 3000, 1)
                    end, 7000, 1)
                end, 3000, 1)
            end, 2000, 1)
        end

        self.customNumber = arg[1]

    end, 5500, 1) -- Custom number time response
end

function Phone:isCustomOpen()
    return self.customNumber
end

function Phone:canSpeak()
    return (self.tab == "speaking")
end

function Phone:setCustomText(...)
    if self.getText then return end
    if self.customNumber == "alarmowy" then
        self.getText = true

        local id = getElementData(localPlayer, "ID")
        local name = getPlayerName(localPlayer)

        local msgTable = {...}
        local fraction = msgTable[1]
        table.remove(msgTable, 1)

        local msg = table.concat(msgTable, " ")

        if getElementInterior(localPlayer) ~= 0 or getElementDimension(localPlayer) ~= 0 then
            exports.TR_chat:showCustomMessage("#009688911 Memuru", "#2a8c44Kusura bakmayın, zar zor duyabiliyorum. Binanın menzilinin çok zayıf olduğunu düşünüyorum. Dışarı çıkmayı isteyebilseydim bu harika olurdu.", "files/images/call.png")
            self.getText = nil
            return
        end

        if fraction ~= "p" and fraction ~= "f" and fraction ~= "m" then
            exports.TR_noti:create("Mevcut gruplar:\ör.p - polis, m - sağlık görevlileri, f - itfaiye.", "info", 7)
            exports.TR_chat:showCustomMessage("#009688911 Memuru", "#2a8c44Przepraszam, ale nie rozumiem jakie służby są potrzebne. Proszę powtórzyć zgłoszenie.", "files/images/call.png")
            self.getText = nil
            return
        end

        exports.TR_chat:showCustomMessage(string.format("#009688[%d] %s", id, name), string.format("#2a8c44%s", msg), "files/images/call.png")

        self.phoningTimer = setTimer(function()
            exports.TR_chat:showCustomMessage("#009688911 Memuru", "#2a8c44Rapor genel merkeze iletildi. Konuşma için teşekkür ederim. Güle güle.", "files/images/call.png")
            triggerServerEvent("addFractionRequest", resourceRoot, fraction, msg)

            self.getText = nil
            self:endCall()
        end, 500, 1)

    elseif self.customNumber == "Yol yardımı" then
        self.getText = true

        local id = getElementData(localPlayer, "ID")
        local name = getPlayerName(localPlayer)
        local msg = table.concat({...}, " ")

        if getElementInterior(localPlayer) ~= 0 or getElementDimension(localPlayer) ~= 0 then
            exports.TR_chat:showCustomMessage("#009688Yol yardım görevlisi", "#2a8c44Kusura bakmayın, zar zor duyabiliyorum. Binanın menzilinin çok zayıf olduğunu düşünüyorum. Dışarı çıkmayı isteyebilseydim bu harika olurdu.", "files/images/call.png")
            self.getText = nil
            return
        end

        exports.TR_chat:showCustomMessage(string.format("#009688[%d] %s", id, name), string.format("#2a8c44%s", msg), "files/images/call.png")

        self.phoningTimer = setTimer(function()
            exports.TR_chat:showCustomMessage("#009688Yol yardım görevlisi", "#2a8c44Rapor merkeze iletildi. Konuşma için teşekkür ederim. Güle güle.", "files/images/call.png")
            triggerServerEvent("addFractionRequest", resourceRoot, "ers", msg)

            self.getText = nil
            self:endCall()
        end, 500, 1)
    end
end

function Phone:autoPhoneByCommand(type)
    if not guiInfo.phone.state then
        self:switch()
        setTimer(function()
            self:animateAutoPhone(type)
        end, 500, 1)
    else
        self:animateAutoPhone(type)
    end
end

function Phone:animateAutoPhone(type)
    self:changeMenu("menu")
    self.phoningTimer = setTimer(function()
        self:changeMenu("phoneBook")
        self.phoningTimer = setTimer(function()
            self.selected = 0
            self:animationMoveToNumber(type)
        end, 500, 1)
    end, 500, 1)
end

function Phone:animationMoveToNumber(type)
    if type ~= self.players[self.selected + 1] then
        self.selected = self.selected + 1
        self:clickSound()

        self.phoningTimer = setTimer(function()
            self:animationMoveToNumber(type)
        end, 500, 1)
    else
        self:startAnimationCustomPhoning(type)
    end
end

function Phone:startAnimationCustomPhoning(type)
    if type == "taxi" then
        self.response = true
        self.phoningPlayerName = "8007383"
        self.number = "8007383"

        triggerServerEvent("callPhoneNumber", resourceRoot, "8007383")

        self.phoningTimer = setTimer(self.func.cancelTimeCall, 18000, 1)
        self.phoningSound = playSound("files/sounds/calling.mp3")
        self:changeMenu("calling")
    end
end

function autoPhoneByCommand(type)
    if not guiInfo.phone then return end
    guiInfo.phone:autoPhoneByCommand(type)
end


function phonePlayer(...)
    guiInfo.phone:phonePlayer(...)
end
addEvent("phonePlayer", true)
addEventHandler("phonePlayer", root, phonePlayer)

function cancelCall(...)
    guiInfo.phone:cancelCall(...)
end
addEvent("cancelCall", true)
addEventHandler("cancelCall", root, cancelCall)

function acceptCall(...)
    guiInfo.phone:acceptCall(...)
end
addEvent("acceptCall", true)
addEventHandler("acceptCall", root, acceptCall)

function declineCall(...)
    guiInfo.phone:declineCall(...)
end
addEvent("declineCall", true)
addEventHandler("declineCall", root, declineCall)

function endCall(...)
    guiInfo.phone:endCall(...)
end
addEvent("endCall", true)
addEventHandler("endCall", root, endCall)

function responsePhone(...)
    guiInfo.phone:responsePhone(...)
end
addEvent("responsePhone", true)
addEventHandler("responsePhone", root, responsePhone)

function invalidCall(...)
    guiInfo.phone:invalidCall(...)
end
addEvent("invalidCall", true)
addEventHandler("invalidCall", root, invalidCall)



guiInfo.phone = Phone:create()
function setPhoneData(...)
    local data = split(arg[1], ",")
    local blocked = fromJSON(arg[2])
    guiInfo.phone:setPhoneData(data[1], data[2], blocked)
end
addEvent("setPhoneData", true)
addEventHandler("setPhoneData", root, setPhoneData)

function switchPhone()
    if not guiInfo.phone then return end
    guiInfo.phone:switch()
end

function canSpeak(state)
    return guiInfo.phone:canSpeak()
end

function isCustomOpen()
    return guiInfo.phone:isCustomOpen()
end

function setCustomText(...)
    guiInfo.phone:setCustomText(...)
end

function openPhoneToPlayer(player)
    if not player then return false end
    local uid = getElementData(player, "characterUID")
    if not uid then return false end

    if not guiInfo.phone.state then
        guiInfo.phone:open()
    end
    guiInfo.phone.tab = "number"
    guiInfo.phone.number = string.format("55%05d", uid)
end

bindKey("end", "down", switchPhone)