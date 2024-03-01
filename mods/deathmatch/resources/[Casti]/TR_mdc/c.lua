local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local scale = 0.6
local guiInfo = {
    x = (sx - 1071/zoom)/2,
    y = (sy - 770/zoom)/2,
    w = 1071/zoom,
    h = 770/zoom,

    logo = {
        x = (sx - 220/zoom)/2,
        y = (sy - 220/zoom)/2,
        w = 220/zoom,
        h = 220/zoom,

        progress = 0,
    },

    main = {
        categories = {
            {
                text = "Oyuncu ara",
                type = "searchPlayer",
                icon = "people",
            },
            {
                text = "Araç ara",
                type = "searchVehicle",
                icon = "vehicle",
            },
            {
                text = "Arananlar",
                type = "wanted",
                icon = "wanted",
            },
        },
    },
}

MDC = {}
MDC.__index = MDC

function MDC:create()
    local instance = {}
    setmetatable(instance, MDC)
    if instance:constructor() then
        return instance
    end
    return false
end

function MDC:constructor()
    self.alpha = 0
    self.tab = "login"
    self.canUse = false

    self.playerName = getPlayerName(localPlayer)

    guiInfo.logo.username = ""
    guiInfo.logo.password = ""
    guiInfo.main.alpha = 0

    self.edits = {}
    self.edits.searchPlayer = exports.TR_dx:createEdit((sx - 300/zoom)/2, guiInfo.logo.y + guiInfo.logo.h/2, 300/zoom, 40/zoom, "Nick gracza")
    self.edits.searchVehicle = exports.TR_dx:createEdit((sx - 300/zoom)/2, guiInfo.logo.y + guiInfo.logo.h/2, 300/zoom, 40/zoom, "Numer rejestracyjny")
    self.edits.note = exports.TR_dx:createEdit(guiInfo.x + 120/zoom, guiInfo.y + guiInfo.h - 200/zoom, guiInfo.w - 240/zoom, 40/zoom, "Tekst notatki")

    self.buttons = {}
    self.buttons.search = exports.TR_dx:createButton((sx - 250/zoom)/2, guiInfo.logo.y + guiInfo.logo.h/2 + 70/zoom, 250/zoom, 40/zoom, "Wyszukaj")
    self.buttons.updateWanted = exports.TR_dx:createButton(guiInfo.x + guiInfo.w - 320/zoom, guiInfo.y + 180/zoom, 200/zoom, 40/zoom, "Zmień status")
    self.buttons.addNewNote = exports.TR_dx:createButton(guiInfo.x + guiInfo.w - 320/zoom, guiInfo.y + guiInfo.h - 150/zoom, 200/zoom, 40/zoom, "Dodaj notatkę")
    self.buttons.rejectNote = exports.TR_dx:createButton(guiInfo.x + 120/zoom, guiInfo.y + guiInfo.h - 150/zoom, 200/zoom, 40/zoom, "Anuluj")

    exports.TR_dx:setEditVisible(self.edits, false)
    exports.TR_dx:setButtonVisible(self.buttons, false)

    self.textures = {}
    self.textures.tablet = dxCreateTexture("files/images/tablet.png", "argb", true, "clamp")
    self.textures.button = dxCreateTexture("files/images/button.png", "argb", true, "clamp")
    self.textures.logo = dxCreateTexture("files/images/logo.png", "argb", true, "clamp")

    self.fonts = {}
    self.fonts.big = exports.TR_dx:getFont(20)
    self.fonts.search = exports.TR_dx:getFont(15)
    self.fonts.edit = exports.TR_dx:getFont(12)
    self.fonts.note = exports.TR_dx:getFont(10)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.click = function(...) self:click(...) end
    self.func.buttonClick = function(...) self:buttonClick(...) end
    self.func.scrollKey = function(...) self:scrollKey(...) end

    self:open()
    return true
end

function MDC:open()
    exports.TR_dx:setOpenGUI(true)

    self.state = "opening"
    self.tick = getTickCount()

    self:selectTab("login")

    showCursor(true)
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientKey", root, self.func.scrollKey)
    addEventHandler("guiButtonClick", root, self.func.buttonClick)
end

function MDC:close()
    self.state = "closing"
    self.tick = getTickCount()

    showCursor(false)
    removeEventHandler("onClientClick", root, self.func.click)
    removeEventHandler("onClientKey", root, self.func.scrollKey)
    removeEventHandler("guiButtonClick", root, self.func.buttonClick)
end

function MDC:destroy()
    exports.TR_dx:setOpenGUI(false)
    removeEventHandler("onClientRender", root, self.func.render)

    guiInfo.panel = nil
    self = nil
end

function MDC:animate()
    if not self.tick then return end

    if self.state == "opening" then
        local progress = (getTickCount() - self.tick)/500
        self.alpha = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "Linear")

        if progress >= 1 then
            self.alpha = 1
            self.state = "logging"
            self.tick = getTickCount()
        end

    elseif self.state == "logging" then
        local progress = (getTickCount() - self.tick)/500
        guiInfo.logo.progress = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "Linear")

        if progress >= 1 then
            self.tick = nil
            self:performLoginAnimation()
        end

    elseif self.state == "loading" then
        local progress = (getTickCount() - self.tick)/500
        guiInfo.logo.progress = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "Linear")

        if progress >= 1 then
            self.tick = nil
            self.state = "loadingWait"
            self.tick = getTickCount()
            guiInfo.logo.progress = 0
        end

    elseif self.state == "loadingWait" then
        local progress = (getTickCount() - self.tick)/2000

        if progress >= 1 then
            self:selectTab("showMain")
            self.state = "showMain"
            self.tick = getTickCount()
        end

    elseif self.state == "showMain" then
        local progress = (getTickCount() - self.tick)/500
        guiInfo.main.alpha = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "Linear")

        if progress >= 1 then
            self:selectTab("main")
            self.lastTab = "main"
            guiInfo.main.alpha = 1
            self.canUse = true

            self.state = nil
            self.tick = nil

            addEventHandler("onClientClick", root, self.func.click)
        end

    elseif self.state == "closing" then
        local progress = (getTickCount() - self.tick)/500
        self.alpha = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "Linear")

        if progress >= 1 then
            self:destroy()
            return true
        end
    end
end

function MDC:render()
    if self:animate() then return end

    dxDrawImage(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, self.textures.tablet, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))

    if self:isMouseInPosition(guiInfo.x + guiInfo.w - 70/zoom, guiInfo.y + (guiInfo.h - 50/zoom)/2, 50/zoom, 50/zoom) and self.canUse then
        dxDrawImage(guiInfo.x + guiInfo.w - 70/zoom, guiInfo.y + (guiInfo.h - 50/zoom)/2, 50/zoom, 50/zoom, self.textures.button, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
    else
        dxDrawImage(guiInfo.x + guiInfo.w - 70/zoom, guiInfo.y + (guiInfo.h - 50/zoom)/2, 50/zoom, 50/zoom, self.textures.button, 0, 0, 0, tocolor(255, 255, 255, 150 * self.alpha))
    end

    if self.tab == "login" then
        dxDrawImage(guiInfo.logo.x, guiInfo.logo.y - 120/zoom * guiInfo.logo.progress, guiInfo.logo.w, guiInfo.logo.h, self.textures.logo, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))

        dxDrawText("Kullanıcı Adı:", guiInfo.logo.x - 50/zoom, guiInfo.logo.y + 140/zoom, guiInfo.logo.x - 50/zoom, guiInfo.logo.y + 145/zoom, tocolor(200, 200, 200, 255 * self.alpha * guiInfo.logo.progress), 1/zoom, self.fonts.edit, "left", "bottom")
        self:drawBackground(guiInfo.logo.x - 50/zoom, guiInfo.logo.y + 150/zoom, guiInfo.logo.w + 100/zoom, 35/zoom, tocolor(37, 37, 37, 255 * self.alpha * guiInfo.logo.progress), 4)
        dxDrawText(guiInfo.logo.username, guiInfo.logo.x - 40/zoom, guiInfo.logo.y + 150/zoom, guiInfo.logo.x - 50/zoom, guiInfo.logo.y + 185/zoom, tocolor(200, 200, 200, 255 * self.alpha * guiInfo.logo.progress), 1/zoom, self.fonts.edit, "left", "center")

        dxDrawText("Şifre:", guiInfo.logo.x - 50/zoom, guiInfo.logo.y + 140/zoom, guiInfo.logo.x - 50/zoom, guiInfo.logo.y + 220/zoom, tocolor(200, 200, 200, 255 * self.alpha * guiInfo.logo.progress), 1/zoom, self.fonts.edit, "left", "bottom")
        self:drawBackground(guiInfo.logo.x - 50/zoom, guiInfo.logo.y + 225/zoom, guiInfo.logo.w + 100/zoom, 35/zoom, tocolor(37, 37, 37, 255 * self.alpha * guiInfo.logo.progress), 4)
        dxDrawText(guiInfo.logo.password, guiInfo.logo.x - 40/zoom, guiInfo.logo.y + 225/zoom, guiInfo.logo.x - 50/zoom, guiInfo.logo.y + 260/zoom, tocolor(200, 200, 200, 255 * self.alpha * guiInfo.logo.progress), 1/zoom, self.fonts.edit, "left", "center")

        self:drawBackground(guiInfo.logo.x, guiInfo.logo.y + 290/zoom, guiInfo.logo.w, 40/zoom, tocolor(37, 37, 37, 255 * self.alpha * guiInfo.logo.progress), 4)
        dxDrawText("Giriş yap", guiInfo.logo.x, guiInfo.logo.y + 290/zoom, guiInfo.logo.x + guiInfo.logo.w, guiInfo.logo.y + 330/zoom, tocolor(200, 200, 200, 255 * self.alpha * guiInfo.logo.progress), 1/zoom, self.fonts.edit, "center", "center")

    elseif self.tab == "loading" then
        dxDrawImage(guiInfo.logo.x, guiInfo.logo.y - 120/zoom * guiInfo.logo.progress, guiInfo.logo.w, guiInfo.logo.h, self.textures.logo, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
        dxDrawText("Yükleniyor...", guiInfo.logo.x, guiInfo.logo.y + 290/zoom, guiInfo.logo.x + guiInfo.logo.w, guiInfo.logo.y + 330/zoom, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.edit, "center", "center")

    elseif self.tab == "showMain" then
        dxDrawImage(guiInfo.logo.x, guiInfo.logo.y, guiInfo.logo.w, guiInfo.logo.h, self.textures.logo, 0, 0, 0, tocolor(255, 255, 255, 255 - 105 * guiInfo.main.alpha))
        dxDrawText("Yükleniyor...", guiInfo.logo.x, guiInfo.logo.y + 290/zoom, guiInfo.logo.x + guiInfo.logo.w, guiInfo.logo.y + 330/zoom, tocolor(200, 200, 200, 255 - 255 * guiInfo.main.alpha), 1/zoom, self.fonts.edit, "center", "center")

        self:renderCategoryButtons()

    elseif self.tab == "main" then
        dxDrawImage(guiInfo.logo.x, guiInfo.logo.y, guiInfo.logo.w, guiInfo.logo.h, self.textures.logo, 0, 0, 0, tocolor(255, 255, 255, 150 * self.alpha))

        self:renderCategoryButtons()

    elseif self.tab == "searchPlayer" then
        dxDrawImage((sx - 64/zoom)/2, guiInfo.logo.y + guiInfo.logo.h/2 - 120/zoom, 64/zoom, 64/zoom, "files/images/people.png", 0, 0, 0, tocolor(255, 255, 255, 150 * self.alpha))
        dxDrawText("Oyuncu ara", guiInfo.logo.x, guiInfo.logo.y + guiInfo.logo.h/2 - 50/zoom, guiInfo.logo.x + guiInfo.logo.w, guiInfo.logo.y + 330/zoom, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.search, "center", "top")

        if self.searching then
            self.rot = self.rot + 4
            if self.rot >= 360 then self.rot = self.rot - 360 end

            self:drawBackground((sx - 250/zoom)/2, guiInfo.logo.y + guiInfo.logo.h/2 + 70/zoom, 250/zoom, 40/zoom, tocolor(37, 37, 37, 255 * self.alpha), 4)
            dxDrawImage(guiInfo.logo.x + 30/zoom, guiInfo.logo.y + guiInfo.logo.h/2 + 77/zoom, 26/zoom, 26/zoom, "files/images/loading.png", self.rot, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
            dxDrawText("Aranıyor...", guiInfo.logo.x + 70/zoom, guiInfo.logo.y + guiInfo.logo.h/2 + 70/zoom, guiInfo.logo.x + guiInfo.logo.w - 10/zoom, guiInfo.logo.y + guiInfo.logo.h/2 + 110/zoom, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.edit, "left", "center")
        end

    elseif self.tab == "searchVehicle" then
        dxDrawImage((sx - 64/zoom)/2, guiInfo.logo.y + guiInfo.logo.h/2 - 120/zoom, 64/zoom, 64/zoom, "files/images/vehicle.png", 0, 0, 0, tocolor(255, 255, 255, 150 * self.alpha))
        dxDrawText("Araç ara", guiInfo.logo.x, guiInfo.logo.y + guiInfo.logo.h/2 - 50/zoom, guiInfo.logo.x + guiInfo.logo.w, guiInfo.logo.y + 330/zoom, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.search, "center", "top")

        if self.searching then
            self.rot = self.rot + 4
            if self.rot >= 360 then self.rot = self.rot - 360 end

            self:drawBackground((sx - 250/zoom)/2, guiInfo.logo.y + guiInfo.logo.h/2 + 70/zoom, 250/zoom, 40/zoom, tocolor(37, 37, 37, 255 * self.alpha), 4)
            dxDrawImage(guiInfo.logo.x + 30/zoom, guiInfo.logo.y + guiInfo.logo.h/2 + 77/zoom, 26/zoom, 26/zoom, "files/images/loading.png", self.rot, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
            dxDrawText("Aranıyor...", guiInfo.logo.x + 70/zoom, guiInfo.logo.y + guiInfo.logo.h/2 + 70/zoom, guiInfo.logo.x + guiInfo.logo.w - 10/zoom, guiInfo.logo.y + guiInfo.logo.h/2 + 110/zoom, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.edit, "left", "center")
        end

    elseif self.tab == "inspectVehicle" then
        dxDrawText(string.format("#ffffffModel: #aaaaaa%s", self.searchData.modelName), guiInfo.x + 120/zoom, guiInfo.y + 120/zoom, guiInfo.x + guiInfo.w, guiInfo.y + 330/zoom, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.big, "left", "top", false, false, false, true)
        dxDrawText(string.format("#ffffffID: #aaaaaa%s", self.searchData.ID), guiInfo.x + 120/zoom, guiInfo.y + 155/zoom, guiInfo.x + guiInfo.w, guiInfo.y + 330/zoom, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.edit, "left", "top", false, false, false, true)
        dxDrawText(string.format("#ffffffSahibi: #aaaaaa%s", self.searchData.username), guiInfo.x + 120/zoom, guiInfo.y + 175/zoom, guiInfo.x + guiInfo.w, guiInfo.y + 330/zoom, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.edit, "left", "top", false, false, false, true)
        dxDrawText(string.format("#ffffffPlaka: #aaaaaaSA %s", self.searchData.plateText or string.format("%05d", tonumber(self.searchData.ID))), guiInfo.x + 120/zoom, guiInfo.y + 195/zoom, guiInfo.x + guiInfo.w, guiInfo.y + 330/zoom, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.edit, "left", "top", false, false, false, true)


    elseif self.tab == "inspectPlayer" then
        if self.searchData.isWanted then
            dxDrawText("ARANIYOR", guiInfo.x + 120/zoom, guiInfo.y + 120/zoom, guiInfo.x + guiInfo.w - 120/zoom, guiInfo.y + 330/zoom, tocolor(173, 50, 50, 255 * self.alpha), 1/zoom, self.fonts.big, "right", "top", false, false, false, true)
            dxDrawText(string.format("#aaaaaa%s#ffffff'den itibaren", self.searchData.isWanted or "ERROR"), guiInfo.x + 120/zoom, guiInfo.y + 150/zoom, guiInfo.x + guiInfo.w - 120/zoom, guiInfo.y + 330/zoom, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.edit, "right", "top", false, false, false, true)
        else
            dxDrawText("ARANMIYOR", guiInfo.x + 120/zoom, guiInfo.y + 120/zoom, guiInfo.x + guiInfo.w - 120/zoom, guiInfo.y + 330/zoom, tocolor(85, 173, 50, 255 * self.alpha), 1/zoom, self.fonts.big, "right", "top", false, false, false, true)
        end

        dxDrawText(string.format("#ffffffKullanıcı Adı: #aaaaaa%s", self.searchData.username), guiInfo.x + 120/zoom, guiInfo.y + 120/zoom, guiInfo.x + guiInfo.w, guiInfo.y + 330/zoom, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.big, "left", "top", false, false, false, true)
        dxDrawText(string.format("#ffffffKarakter Adı: #aaaaaa%s", self.searchData.usernameRP or "Eksiklik"), guiInfo.x + 120/zoom, guiInfo.y + 155/zoom, guiInfo.x + guiInfo.w, guiInfo.y + 330/zoom, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.edit, "left", "top", false, false, false, true)
        dxDrawText(string.format("#ffffffÖdenmemiş Cezaları: #aaaaaa$%.2f", self.searchData.ticketPrice and tonumber(self.searchData.ticketPrice) or 0), guiInfo.x + 120/zoom, guiInfo.y + 175/zoom, guiInfo.x + guiInfo.w, guiInfo.y + 330/zoom, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.edit, "left", "top", false, false, false, true)
        dxDrawText(string.format("#ffffffCezasını hapiste çekiyor: #aaaaaa%s", self.searchData.prisonData and "Evet" or "Hayır"), guiInfo.x + 120/zoom, guiInfo.y + 195/zoom, guiInfo.x + guiInfo.w, guiInfo.y + 330/zoom, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.edit, "left", "top", false, false, false, true)

        dxDrawText("Oyuncu notları:", guiInfo.x + 120/zoom, guiInfo.y + 250/zoom, guiInfo.x + guiInfo.w, guiInfo.y + 330/zoom, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.big, "left", "top", false, false, false, true)
        if self.playerNotes then
            if #self.playerNotes > 0 then
                for i = 1, 7 do
                    local v = self.playerNotes[i]
                    if v then
                        dxDrawText(v.text.." ~ "..v.username, guiInfo.x + 120/zoom, guiInfo.y + 290/zoom + 45/zoom * (i-1), guiInfo.x + guiInfo.w - 110/zoom, guiInfo.y + 290/zoom + 45/zoom * i, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.note, "left", "top", true, true)
                    end
                end
            else
                dxDrawText("Not yok", guiInfo.x + 120/zoom, guiInfo.y + 285/zoom, guiInfo.x + guiInfo.w, guiInfo.y + 330/zoom, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.edit, "left", "top", false, false, false, true)
            end
        else
            dxDrawText("Not yok", guiInfo.x + 120/zoom, guiInfo.y + 285/zoom, guiInfo.x + guiInfo.w, guiInfo.y + 330/zoom, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.edit, "left", "top", false, false, false, true)
        end

    elseif self.tab == "addNote" then
        dxDrawText("Not önizlemesi:", guiInfo.x + 120/zoom, guiInfo.y + 270/zoom, guiInfo.x + guiInfo.w - 120/zoom, guiInfo.y + 330/zoom, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.big, "center", "top", false, false, false, true)
        dxDrawText(guiGetText(self.edits.note).." ~ "..self.playerName, guiInfo.x + 120/zoom, guiInfo.y + 320/zoom, guiInfo.x + guiInfo.w - 120/zoom, guiInfo.y + 500/zoom, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.note, "center", "top", true, true)

    elseif self.tab == "wanted" then
        dxDrawText("İnsnlar Aranıyor", guiInfo.x + 120/zoom, guiInfo.y + 120/zoom, guiInfo.x + guiInfo.w - 120/zoom, guiInfo.y + 330/zoom, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.big, "center", "top", false, false, false, true)
        -- dxDrawText(guiGetText(self.edits.note).." ~ "..self.playerName, guiInfo.x + 120/zoom, guiInfo.y + 320/zoom, guiInfo.x + guiInfo.w - 120/zoom, guiInfo.y + 500/zoom, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.note, "center", "top", true, true)

        if self.searching then
            self.rot = self.rot + 4
            if self.rot >= 360 then self.rot = self.rot - 360 end
            dxDrawImage((sx - 64/zoom)/2, guiInfo.logo.y + guiInfo.logo.h/2 - 20/zoom, 64/zoom, 64/zoom, "files/images/loading.png", self.rot, 0, 0, tocolor(200, 200, 200, 255 * self.alpha))
            dxDrawText("Liste yükleniyor...", guiInfo.x, guiInfo.logo.y + guiInfo.logo.h/2 + 50/zoom, guiInfo.x + guiInfo.w, guiInfo.logo.y + guiInfo.logo.h/2 + 110/zoom, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.search, "center", "center")

        else
            if #self.wantedPlayers > 0 then
                local y = guiInfo.y + 110/zoom
                local xMove = (guiInfo.w - 260/zoom)/2

                for i = 1, 12 do
                    local v = self.wantedPlayers[i + self.scroll]
                    if v then
                        local x = guiInfo.x + 130/zoom
                        if i%2 == 0 then
                            x = guiInfo.x + 130/zoom + xMove
                        else
                            y = y + 80/zoom
                        end

                        dxDrawImage(x, y, 64/zoom, 64/zoom, "files/images/people.png", 0, 0, 0, tocolor(220, 220, 220, 255 * self.alpha))
                        dxDrawText(v.username, x + 80/zoom, y + 8/zoom, guiInfo.x + guiInfo.w, guiInfo.logo.y + guiInfo.logo.h, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.search, "left", "top")
                        dxDrawText(v.wantedTime.."'den itibaren aranıyor.", x + 80/zoom, y + 32/zoom, guiInfo.x + guiInfo.w, guiInfo.logo.y + guiInfo.logo.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.edit, "left", "top")
                    end
                end
            else
                dxDrawText("Aranan kimse yok.", guiInfo.x, guiInfo.logo.y, guiInfo.x + guiInfo.w, guiInfo.logo.y + guiInfo.logo.h, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.search, "center", "center")
            end
        end

    end
end

function MDC:renderCategoryButtons()
    local move = (guiInfo.w - 200/zoom)/#guiInfo.main.categories
    local x = guiInfo.x + 100/zoom

    for i, v in pairs(guiInfo.main.categories) do
        local alpha = 200
        if self:isMouseInPosition(x + move * (i - 1), guiInfo.y + 100/zoom, move, 80/zoom) then
            alpha = 255
        end

        dxDrawText(v.text, x + move * (i - 1), guiInfo.y + 155/zoom, x + move * i, guiInfo.logo.y + 330/zoom, tocolor(200, 200, 200, alpha * self.alpha * guiInfo.main.alpha), 1/zoom, self.fonts.edit, "center", "top")
        dxDrawImage(x + (move - 40/zoom)/2 + move * (i - 1), guiInfo.y + 110/zoom, 40/zoom, 40/zoom, string.format("files/images/%s.png", v.icon), 0, 0, 0, tocolor(255, 255, 255, alpha * self.alpha * guiInfo.main.alpha))

        if i ~= #guiInfo.main.categories then
            dxDrawRectangle(x + move * i - 1/zoom, guiInfo.y + 100/zoom, 2/zoom, 85/zoom, tocolor(255, 255, 255, 50 * self.alpha * guiInfo.main.alpha))
        end
    end
end

function MDC:performLoginAnimation()
    local usernameIndex = 1
    setTimer(function()
        local letter = utf8.sub(getPlayerName(localPlayer), usernameIndex, usernameIndex)
        guiInfo.logo.username = guiInfo.logo.username .. letter
        usernameIndex = usernameIndex + 1
    end, 100, utf8.len(getPlayerName(localPlayer)))

    setTimer(function()
        self:performPasswordAnimation()
    end, utf8.len(getPlayerName(localPlayer)) * 100 + 500, 1)
end

function MDC:performPasswordAnimation()
    local passwordCount = math.random(6, 15)
    setTimer(function()
        guiInfo.logo.password = guiInfo.logo.password .. "*"
    end, 100, passwordCount)

    setTimer(function()
        self:selectTab("loading")
        self.state = "loading"
        self.tick = getTickCount()
    end, passwordCount * 100 + 200, 1)
end

function MDC:selectTab(tab)
    self.lastTab = self.tab
    self.tab = tab
    exports.TR_dx:setEditVisible(self.edits, false)
    exports.TR_dx:setButtonVisible(self.buttons, false)

    if tab == "searchPlayer" then
        exports.TR_dx:setEditVisible(self.edits.searchPlayer, true)
        exports.TR_dx:setButtonVisible(self.buttons.search, true)

    elseif tab == "searchVehicle" then
        exports.TR_dx:setEditVisible(self.edits.searchVehicle, true)
        exports.TR_dx:setButtonVisible(self.buttons.search, true)

    elseif tab == "inspectPlayer" then
        self.canUse = true
        exports.TR_dx:setButtonVisible({self.buttons.updateWanted, self.buttons.addNewNote}, true)

    elseif tab == "addNote" then
        self.canUse = false
        exports.TR_dx:setEditVisible({self.edits.note}, true)
        exports.TR_dx:setButtonVisible({self.buttons.rejectNote, self.buttons.addNewNote}, true)

    elseif tab == "wanted" then
        self.rot = 0
        self.searching = true
        self.canUse = false

        exports.TR_dx:setResponseEnabled(true)
        triggerServerEvent("MDTGetWantedPlayers", resourceRoot)
    end
end

function MDC:buttonClick(btn)
    if exports.TR_dx:isResponseEnabled() then return end
    if btn == self.buttons.updateWanted then
        if self.searchData.isWanted then
            self.canUse = false
            exports.TR_dx:setResponseEnabled(true)
            triggerServerEvent("MDTSetPlayerUnwanted", resourceRoot, self.searchData.UID)
        else
            self.canUse = false
            exports.TR_dx:setResponseEnabled(true)
            triggerServerEvent("MDTSetPlayerWanted", resourceRoot, self.searchData.UID)
        end

    elseif btn == self.buttons.addNewNote then
        if self.tab == "addNote" then
            local text = guiGetText(self.edits.note)
            if string.len(text) < 3 then exports.TR_noti:create("En az 3 karakter girmelisiniz.", "error") return end

            exports.TR_dx:setResponseEnabled(true)
            triggerServerEvent("MDTAddPlayerNote", resourceRoot, self.searchData.UID, text)
        else
            self:selectTab("addNote")
        end

    elseif btn == self.buttons.rejectNote then
        self:selectTab("inspectPlayer")

    elseif btn == self.buttons.search then
        if self.tab == "searchPlayer" then
            local text = guiGetText(self.edits.searchPlayer)
            if string.len(text) < 3 then exports.TR_noti:create("En az 3 karakter girmelisiniz.", "error") return end

            self.searching = true
            self.canUse = false
            self.rot = 0
            exports.TR_dx:setButtonVisible(self.buttons.search, false)

            exports.TR_dx:setResponseEnabled(true)
            triggerServerEvent("MDTSearchPlayer", resourceRoot, text)

        elseif self.tab == "searchVehicle" then
            local text = guiGetText(self.edits.searchVehicle)
            if string.len(text) < 3 then exports.TR_noti:create("En az 3 karakter girmelisiniz.", "error") return end

            self.searching = true
            self.canUse = false
            self.rot = 0
            exports.TR_dx:setButtonVisible(self.buttons.search, false)

            triggerServerEvent("MDTSearchVehicle", resourceRoot, text)
        end
    end
end

function MDC:click(btn, state)
    if btn ~= "left" or state ~= "down" or not self.canUse then return end

    if self:isMouseInPosition(guiInfo.x + guiInfo.w - 70/zoom, guiInfo.y + (guiInfo.h - 50/zoom)/2, 50/zoom, 50/zoom) then
        if self.tab == "main" then
            self:close()

        elseif self.tab == "searchPlayer" or self.tab == "searchVehicle" or self.tab == "wanted" then
            self:selectTab("main")

        elseif self.tab == "inspectPlayer" then
            self:selectTab("searchPlayer")

        elseif self.tab == "inspectVehicle" then
            self:selectTab("searchVehicle")
        end
        return
    end

    if self.tab == "main" then
        local move = (guiInfo.w - 200/zoom)/#guiInfo.main.categories
        local x = guiInfo.x + 100/zoom
        for i, v in pairs(guiInfo.main.categories) do
            if self:isMouseInPosition(x + move * (i - 1), guiInfo.y + 100/zoom, move, 80/zoom) then
                self:selectTab(v.type)
                return
            end
        end
    end
end

function MDC:scrollKey(...)
    if not arg[2] then return end
    if self.tab ~= "wanted" then return end

    if arg[1] == "mouse_wheel_up" then
        if self.scroll <= 1 then
            self.scroll = 0
            return
        end
        self.scroll = self.scroll - 2

    elseif arg[1] == "mouse_wheel_down" then
        if #self.wantedPlayers < 13 then return end
        self.scroll = self.scroll + 2

        if self.scroll > #self.wantedPlayers - 12 then self.scroll = #self.wantedPlayers - 12 end
    end
end

function MDC:response(...)
    exports.TR_dx:setResponseEnabled(false)

    if self.tab == "searchVehicle" then
        self.searching = false
        self.canUse = true

        if arg[1] == "noVehicle" then
            exports.TR_noti:create("Bu oyuncu bulunamadı.", "error")
            exports.TR_dx:setButtonVisible(self.buttons.search, true)
            return
        end

        self.searchData = arg[1]
        self.searchData.modelName = getVehicleNameFromModel(tonumber(self.searchData.model))
        self:selectTab("inspectVehicle")

    elseif self.tab == "searchPlayer" then
        self.searching = false
        self.canUse = true

        if arg[1] == "noPlayer" then
            exports.TR_noti:create("Bu oyuncu bulunamadı.", "error")
            exports.TR_dx:setButtonVisible(self.buttons.search, true)
            return
        end

        self.searchData = arg[1]
        self.playerNotes = arg[2] or {}

        if arg[3] then
            if arg[3][1] then
                if arg[3][1].ID then
                    self.searchData.isWanted = arg[3][1].wantedTime
                end
            end
        end
        self:selectTab("inspectPlayer")

    elseif self.tab == "inspectPlayer" then
        self.canUse = true

        if arg[1] == "setUnwanted" then
            self.searchData.isWanted = nil

        elseif arg[1] == "setWated" then
            local time = getRealTime()
            self.searchData.isWanted = string.format("%04d-%02d-%02d", time.year + 1900, time.month + 1, time.monthday)
        end

    elseif self.tab == "addNote" then
        self.canUse = true

        if arg[1] == "noteAdded" then
            local note = {
                text = guiGetText(self.edits.note),
                username = getPlayerName(localPlayer),
            }
            table.insert(self.playerNotes, 1, note)
            self:selectTab("inspectPlayer")
        end

    elseif self.tab == "wanted" then
        self.canUse = true
        self.searching = false
        self.scroll = 0
        self.wantedPlayers = arg[1] or {}
    end
end

function MDC:drawBackground(x, y, rx, ry, color, radius, post)
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

function MDC:isMouseInPosition(x, y, width, height)
    if (not isCursorShowing()) then return false end
    local cx, cy = getCursorPosition()
    local cx, cy = (cx*sx), (cy*sy)
    if (cx >= x and cx <= x + width) and (cy >= y and cy <= y + height) then return true end
    return false
end



function openPanelMDC()
    if guiInfo.panel then return end
    if not exports.TR_dx:canOpenGUI() then return end
    guiInfo.panel = MDC:create()
end
addEvent("MDTOpen", true)
addEventHandler("MDTOpen", root, openPanelMDC)

function responsePanelMDT(...)
    if not guiInfo.panel then return end
    guiInfo.panel:response(...)
end
addEvent("MDTResponse", true)
addEventHandler("MDTResponse", root, responsePanelMDT)








-- local vehicleIds = {400, 401, 402, 403, 404, 405, 406, 407, 408, 409, 410, 411, 412, 413, 414, 415,
-- 	416, 417, 418, 419, 420, 421, 422, 423, 424, 425, 426, 427, 428, 429, 430, 431, 432, 433,
-- 	434, 435, 436, 437, 438, 439, 440, 441, 442, 443, 444, 445, 446, 447, 448, 449, 450, 451,
-- 	452, 453, 454, 455, 456, 457, 458, 459, 460, 461, 462, 463, 464, 465, 466, 467, 468, 469,
-- 	470, 471, 472, 473, 474, 475, 476, 477, 478, 479, 480, 481, 482, 483, 484, 485, 486, 487,
-- 	488, 489, 490, 491, 492, 493, 494, 495, 496, 497, 498, 499, 500, 501, 502, 503, 504, 505,
-- 	506, 507, 508, 509, 510, 511, 512, 513, 514, 515, 516, 517, 518, 519, 520, 521, 522, 523,
-- 	524, 525, 526, 527, 528, 529, 530, 531, 532, 533, 534, 535, 536, 537, 538, 539, 540, 541,
-- 	542, 543, 544, 545, 546, 547, 548, 549, 550, 551, 552, 553, 554, 555, 556, 557, 558, 559,
-- 	560, 561, 562, 563, 564, 565, 566, 567, 568, 569, 570, 571, 572, 573, 574, 575, 576, 577,
-- 	578, 579, 580, 581, 582, 583, 584, 585, 586, 587, 588, 589, 590, 591, 592, 593, 594, 595,
-- 	596, 597, 598, 599, 600, 601, 602, 603, 604, 605, 606, 607, 608, 609, 610, 611
-- }



-- file = fileCreate("pojazdy.txt")

-- local text = ""
-- for i, v in pairs(vehicleIds) do
--     text = string.format("%s{vehicleName: \"%s\", vehicleModel: %d},\n", text, getVehicleNameFromModel(v), v)
-- end
-- fileWrite(file, "[\n"..text.."\n]")
-- fileClose(file)