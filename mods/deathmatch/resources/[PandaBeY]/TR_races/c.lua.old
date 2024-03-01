local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 650/zoom)/2,
    y = (sy - 400/zoom)/2,
    w = 650/zoom,
    h = 400/zoom,

    raceImages = {
        ["Sprint"] = "files/images/route.png",
        ["Okrążenia"] = "files/images/laps.png",
        ["Drag"] = "files/images/drag.png",
        ["Drift"] = "files/images/drifting.png",
    },
    raceTypes = {"Sprint", "Okrążenia", "Drift", "Drag"},
    vehicleTypes = {"Prywatny", "Hotring Racer", "Banshee", "Bullet", "Turismo", "ZR-350", "Super GT", "Buffalo", "Jester", "Uranus", "Elegy", "Sabre", "Manana"},
    vehicleSpeed = {"Bez limitu", 150, 180, 210, 240, 270, 300},

    searchAfterTime = 2000,
}

RacePanel = {}
RacePanel.__index = RacePanel

function RacePanel:create()
    local instance = {}
    setmetatable(instance, RacePanel)
    if instance:constructor() then
        return instance
    end
    return false
end

function RacePanel:constructor()
    self.rot = 0
    self.toLoad = 0
    self.scroll = 0
    self.loadedData = {}

    self.fonts = {}
    self.fonts.winPrice = exports.TR_dx:getFont(20)
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.category = exports.TR_dx:getFont(13)
    self.fonts.data = exports.TR_dx:getFont(12)
    self.fonts.minimap = exports.TR_dx:getFont(9)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.buttonClick = function(...) self:buttonClick(...) end
    self.func.onClientKey = function(...) self:onClientKey(...) end
    self.func.onClientClick = function(...) self:onClientClick(...) end
    self.func.blockDmg = function(...) self:blockDmg(...) end

    self.buttons = {}
    self.buttons.exit = exports.TR_dx:createButton((sx - 250/zoom)/2, guiInfo.y + guiInfo.h - 50/zoom, 250/zoom, 40/zoom, "Zamknij")
    self.buttons.back = exports.TR_dx:createButton(guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + guiInfo.h - 50/zoom, 250/zoom, 40/zoom, "Wróć")
    self.buttons.create = exports.TR_dx:createButton(guiInfo.x + guiInfo.w/2 + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + guiInfo.h - 50/zoom, 250/zoom, 40/zoom, "Stwórz nową")

    self.buttons.removeDeclineCenter = exports.TR_dx:createButton(guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 230/zoom, 250/zoom, 40/zoom, "Anuluj", "red")
    self.buttons.removeAcceptCenter = exports.TR_dx:createButton(guiInfo.x + guiInfo.w/2 + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 230/zoom, 250/zoom, 40/zoom, "Usuń", "green")

    self.edits = {}
    self.edits.findMap = exports.TR_dx:createEdit(guiInfo.x + guiInfo.w/2 + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + guiInfo.h - 50/zoom, 250/zoom, 40/zoom, "ID Mapy / Nick gracza")

    exports.TR_dx:setEditVisible(self.edits, false)
    exports.TR_dx:setButtonVisible(self.buttons, false)
    exports.TR_dx:showButton(self.buttons.exit)

    self:selectTab("main")
    self:open()
    return true
end

function RacePanel:open()
    self.alpha = 0
    self.state = "opening"
    self.tick = getTickCount()

    exports.TR_dx:setOpenGUI(true)

    showCursor(true)
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("guiButtonClick", root, self.func.buttonClick)
    addEventHandler("onClientClick", root, self.func.onClientClick)
    addEventHandler("onClientKey", root, self.func.onClientKey)
    addEventHandler("onClientPlayerDamage", localPlayer, self.func.blockDmg)
end

function RacePanel:close(started)
    self.alpha = 1
    self.state = "closing"
    self.tick = getTickCount()

    if not started then exports.TR_dx:hideButton(self.buttons) end

    showCursor(false)
    removeEventHandler("guiButtonClick", root, self.func.buttonClick)
    removeEventHandler("onClientClick", root, self.func.onClientClick)
    removeEventHandler("onClientKey", root, self.func.onClientKey)
    removeEventHandler("onClientPlayerDamage", localPlayer, self.func.blockDmg)
end

function RacePanel:destroy()
    removeEventHandler("onClientRender", root, self.func.render)

    exports.TR_dx:setOpenGUI(false)
    exports.TR_dx:destroyButton(self.buttons)

    guiInfo.panel = nil
    self = nil
end


function RacePanel:animate()
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

function RacePanel:render()
    if self:animate() then return end

    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 4)

    if self.tab == "getPrice" then
        dxDrawText("Twoje nagrody za wyścigi", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")

        if not self.renderTable then
            self.rot = self.rot + 2
            if self.rot >= 360 then self.rot = self.rot - 360 end

            dxDrawImage((sx - 64/zoom)/2, guiInfo.y + 145/zoom, 64/zoom, 64/zoom, "files/images/loading.png", self.rot, 0, 0, tocolor(170, 170, 170, 200 * self.alpha))
            dxDrawText("Wczytywanie nagród...", guiInfo.x, guiInfo.y + 220/zoom, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(170, 170, 170, 200 * self.alpha), 1/zoom, self.fonts.category, "center", "top")

        else
            dxDrawImage(guiInfo.x + guiInfo.w/2 - 64/zoom, guiInfo.y + 60/zoom, 128/zoom, 128/zoom, "files/images/trophy.png", 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
            dxDrawText(string.format("$%s", self:comma_value(self.renderTable or 0)), guiInfo.x, guiInfo.y + 195/zoom, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.winPrice, "center", "top")

            dxDrawText(string.format("Nagrody przyznawane są za wyścigi, których popularność jest więszka niż %d. Nagrodę możesz otrzymać jako twórca popularnej mapy bądź jako jedna osoba z TOP3. Przyznawane są one o północy z niedzieli na poniedziałek wraz z resetem najlepszych czasów.", RaceData.minPopularity), guiInfo.x + 10/zoom, guiInfo.y + 250/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.data, "center", "top", true, true)
        end

    elseif self.tab == "main" then
        dxDrawText("Panel wyścigów", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")

        if self:isMouseInPosition(guiInfo.x + 50/zoom, guiInfo.y + 90/zoom, 148/zoom, 200/zoom) then
            dxDrawImage(guiInfo.x + 60/zoom, guiInfo.y + 110/zoom, 128/zoom, 128/zoom, "files/images/flag.png", 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
            dxDrawText("Rozpocznij wyścig", guiInfo.x + 60/zoom, guiInfo.y + 260/zoom, guiInfo.x + 188/zoom, guiInfo.y + 50/zoom, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.category, "center", "top")
        else
            dxDrawImage(guiInfo.x + 60/zoom, guiInfo.y + 110/zoom, 128/zoom, 128/zoom, "files/images/flag.png", 0, 0, 0, tocolor(255, 255, 255, 200 * self.alpha))
            dxDrawText("Rozpocznij wyścig", guiInfo.x + 60/zoom, guiInfo.y + 260/zoom, guiInfo.x + 188/zoom, guiInfo.y + 50/zoom, tocolor(255, 255, 255, 200 * self.alpha), 1/zoom, self.fonts.category, "center", "top")
        end
        if self:isMouseInPosition(guiInfo.x + guiInfo.w/2 - 74/zoom, guiInfo.y + 90/zoom, 148/zoom, 200/zoom) then
            dxDrawImage(guiInfo.x + guiInfo.w/2 - 64/zoom, guiInfo.y + 110/zoom, 128/zoom, 128/zoom, "files/images/trophy.png", 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
            dxDrawText("Odbierz nagrody", guiInfo.x + guiInfo.w/2 - 64/zoom, guiInfo.y + 260/zoom, guiInfo.x + guiInfo.w/2 + 64/zoom, guiInfo.y + 50/zoom, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.category, "center", "top")
        else
            dxDrawImage(guiInfo.x + guiInfo.w/2 - 64/zoom, guiInfo.y + 110/zoom, 128/zoom, 128/zoom, "files/images/trophy.png", 0, 0, 0, tocolor(255, 255, 255, 200 * self.alpha))
            dxDrawText("Odbierz nagrody", guiInfo.x + guiInfo.w/2 - 64/zoom, guiInfo.y + 260/zoom, guiInfo.x + guiInfo.w/2 + 64/zoom, guiInfo.y + 50/zoom, tocolor(255, 255, 255, 200 * self.alpha), 1/zoom, self.fonts.category, "center", "top")
        end
        if self:isMouseInPosition(guiInfo.x + guiInfo.w - 128/zoom - 70/zoom, guiInfo.y + 90/zoom, 148/zoom, 200/zoom) then
            dxDrawImage(guiInfo.x + guiInfo.w - 128/zoom - 60/zoom, guiInfo.y + 110/zoom, 128/zoom, 128/zoom, "files/images/track.png", 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
            dxDrawText("Stwórz trasę", guiInfo.x + guiInfo.w - 128/zoom - 60/zoom, guiInfo.y + 260/zoom, guiInfo.x + guiInfo.w - 60/zoom, guiInfo.y + 50/zoom, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.category, "center", "top")
        else
            dxDrawImage(guiInfo.x + guiInfo.w - 128/zoom - 60/zoom, guiInfo.y + 110/zoom, 128/zoom, 128/zoom, "files/images/track.png", 0, 0, 0, tocolor(255, 255, 255, 200 * self.alpha))
            dxDrawText("Stwórz trasę", guiInfo.x + guiInfo.w - 128/zoom - 60/zoom, guiInfo.y + 260/zoom, guiInfo.x + guiInfo.w - 60/zoom, guiInfo.y + 50/zoom, tocolor(255, 255, 255, 200 * self.alpha), 1/zoom, self.fonts.category, "center", "top")
        end

    -- Create own track
    elseif self.tab == "create" then
        dxDrawText("Twoje trasy", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")

        if not self.renderTable then
            self.rot = self.rot + 2
            if self.rot >= 360 then self.rot = self.rot - 360 end

            dxDrawImage((sx - 64/zoom)/2, guiInfo.y + 145/zoom, 64/zoom, 64/zoom, "files/images/loading.png", self.rot, 0, 0, tocolor(170, 170, 170, 200 * self.alpha))
            dxDrawText("Wczytywanie tras...", guiInfo.x, guiInfo.y + 220/zoom, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(170, 170, 170, 200 * self.alpha), 1/zoom, self.fonts.category, "center", "top")
        else

            if #self.renderTable > 0 then
                for i, v in pairs(self.renderTable) do
                    if self:isMouseInPosition(guiInfo.x, guiInfo.y + 50/zoom + 72/zoom * (i-1), guiInfo.w, 70/zoom) then
                        dxDrawRectangle(guiInfo.x, guiInfo.y + 50/zoom + 72/zoom * (i-1), guiInfo.w, 70/zoom, tocolor(37, 37, 37, 255 * self.alpha))
                    else
                        dxDrawRectangle(guiInfo.x, guiInfo.y + 50/zoom + 72/zoom * (i-1), guiInfo.w, 70/zoom, tocolor(27, 27, 27, 255 * self.alpha))
                    end

                    dxDrawImage(guiInfo.x + 20/zoom, guiInfo.y + 60/zoom + 72/zoom * (i-1), 50/zoom, 50/zoom, guiInfo.raceImages[v.type], 0, 0, 0, tocolor(220, 220, 220, 255 * self.alpha))
                    dxDrawText(string.format("ID: #aaaaaa#INS%04d", tonumber(v.ID)), guiInfo.x + 90/zoom, guiInfo.y + 53/zoom + 72/zoom * (i-1), guiInfo.x + 200/zoom, guiInfo.y + 50/zoom + 72/zoom * i, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)
                    dxDrawText(string.format("Utworzona: #aaaaaa%s", v.created), guiInfo.x + 90/zoom, guiInfo.y + 73/zoom + 72/zoom * (i-1), guiInfo.x + 200/zoom, guiInfo.y + 50/zoom + 72/zoom * i, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)
                    dxDrawText(string.format("Popularność: #aaaaaa%s", v.trackPopularity or 0), guiInfo.x + 90/zoom, guiInfo.y + 93/zoom + 72/zoom * (i-1), guiInfo.x + 200/zoom, guiInfo.y + 50/zoom + 72/zoom * i, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)

                    dxDrawText(string.format("Typ wyścigu: #aaaaaa%s", v.type), guiInfo.x + 380/zoom, guiInfo.y + 53/zoom + 72/zoom * (i-1), guiInfo.x + 200/zoom, guiInfo.y + 50/zoom + 72/zoom * i, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)
                    dxDrawText(string.format("Typ pojazdu: #aaaaaa%s", v.vehicleType), guiInfo.x + 380/zoom, guiInfo.y + 73/zoom + 72/zoom * (i-1), guiInfo.x + 200/zoom, guiInfo.y + 50/zoom + 72/zoom * i, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)
                    dxDrawText(string.format("Limit prędkości: #aaaaaa%s", v.vehicleSpeed or 0), guiInfo.x + 380/zoom, guiInfo.y + 93/zoom + 72/zoom * (i-1), guiInfo.x + 200/zoom, guiInfo.y + 50/zoom + 72/zoom * i, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)
                end
            else
                dxDrawText("Nie stworzyłeś jeszcze żadnej trasy.", guiInfo.x, guiInfo.y + 180/zoom, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(170, 170, 170, 200 * self.alpha), 1/zoom, self.fonts.category, "center", "top")
            end
        end

    elseif self.tab == "createSettings" then
        dxDrawText("Tworzenie trasy", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")

        dxDrawText("Typ wyścigu", guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 60/zoom, guiInfo.x + (guiInfo.w/2 + 250/zoom)/2, guiInfo.y + 50/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "top")
        dxDrawText(guiInfo.raceTypes[self.selectedRaceType], guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 85/zoom, guiInfo.x + (guiInfo.w/2 + 250/zoom)/2, guiInfo.y + 50/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.data, "center", "top")

        if self:isMouseInPosition(guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 74/zoom, 24/zoom, 24/zoom) then
            dxDrawImage(guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 74/zoom, 24/zoom, 24/zoom, "files/images/arrow.png", 180, 0, 0, tocolor(170, 170, 170, 255 * self.alpha))
        else
            dxDrawImage(guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 74/zoom, 24/zoom, 24/zoom, "files/images/arrow.png", 180, 0, 0, tocolor(170, 170, 170, 200 * self.alpha))
        end
        if self:isMouseInPosition(guiInfo.x + (guiInfo.w/2 + 250/zoom)/2 - 24/zoom, guiInfo.y + 74/zoom, 24/zoom, 24/zoom) then
            dxDrawImage(guiInfo.x + (guiInfo.w/2 + 250/zoom)/2 - 24/zoom, guiInfo.y + 74/zoom, 24/zoom, 24/zoom, "files/images/arrow.png", 0, 0, 0, tocolor(170, 170, 170, 255 * self.alpha))
        else
            dxDrawImage(guiInfo.x + (guiInfo.w/2 + 250/zoom)/2 - 24/zoom, guiInfo.y + 74/zoom, 24/zoom, 24/zoom, "files/images/arrow.png", 0, 0, 0, tocolor(170, 170, 170, 200 * self.alpha))
        end

        if guiInfo.raceTypes[self.selectedRaceType] == "Okrążenia" then
            dxDrawText("Ilość okrążeń", guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 130/zoom, guiInfo.x + (guiInfo.w/2 + 250/zoom)/2, guiInfo.y + 50/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "top")
            dxDrawText(self.selectedRaceLaps, guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 155/zoom, guiInfo.x + (guiInfo.w/2 + 250/zoom)/2, guiInfo.y + 50/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.data, "center", "top")

            if self:isMouseInPosition(guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 144/zoom, 24/zoom, 24/zoom) then
                dxDrawImage(guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 144/zoom, 24/zoom, 24/zoom, "files/images/arrow.png", 180, 0, 0, tocolor(170, 170, 170, 255 * self.alpha))
            else
                dxDrawImage(guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 144/zoom, 24/zoom, 24/zoom, "files/images/arrow.png", 180, 0, 0, tocolor(170, 170, 170, 200 * self.alpha))
            end
            if self:isMouseInPosition(guiInfo.x + (guiInfo.w/2 + 250/zoom)/2 - 24/zoom, guiInfo.y + 144/zoom, 24/zoom, 24/zoom) then
                dxDrawImage(guiInfo.x + (guiInfo.w/2 + 250/zoom)/2 - 24/zoom, guiInfo.y + 144/zoom, 24/zoom, 24/zoom, "files/images/arrow.png", 0, 0, 0, tocolor(170, 170, 170, 255 * self.alpha))
            else
                dxDrawImage(guiInfo.x + (guiInfo.w/2 + 250/zoom)/2 - 24/zoom, guiInfo.y + 144/zoom, 24/zoom, 24/zoom, "files/images/arrow.png", 0, 0, 0, tocolor(170, 170, 170, 200 * self.alpha))
            end
        else
            dxDrawText("Ilość okrążeń", guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 130/zoom, guiInfo.x + (guiInfo.w/2 + 250/zoom)/2, guiInfo.y + 50/zoom, tocolor(220, 220, 220, 120 * self.alpha), 1/zoom, self.fonts.main, "center", "top")
            dxDrawText(self.selectedRaceLaps, guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 155/zoom, guiInfo.x + (guiInfo.w/2 + 250/zoom)/2, guiInfo.y + 50/zoom, tocolor(170, 170, 170, 120 * self.alpha), 1/zoom, self.fonts.data, "center", "top")
            dxDrawImage(guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 144/zoom, 24/zoom, 24/zoom, "files/images/arrow.png", 180, 0, 0, tocolor(170, 170, 170, 120 * self.alpha))
            dxDrawImage(guiInfo.x + (guiInfo.w/2 + 250/zoom)/2 - 24/zoom, guiInfo.y + 144/zoom, 24/zoom, 24/zoom, "files/images/arrow.png", 0, 0, 0, tocolor(170, 170, 170, 120 * self.alpha))
        end


        dxDrawText("Typ pojazdu", guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 200/zoom, guiInfo.x + (guiInfo.w/2 + 250/zoom)/2, guiInfo.y + 50/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "top")
        dxDrawText(guiInfo.vehicleTypes[self.selectedVehicleType], guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 225/zoom, guiInfo.x + (guiInfo.w/2 + 250/zoom)/2, guiInfo.y + 50/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.data, "center", "top")

        if self:isMouseInPosition(guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 214/zoom, 24/zoom, 24/zoom) then
            dxDrawImage(guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 214/zoom, 24/zoom, 24/zoom, "files/images/arrow.png", 180, 0, 0, tocolor(170, 170, 170, 255 * self.alpha))
        else
            dxDrawImage(guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 214/zoom, 24/zoom, 24/zoom, "files/images/arrow.png", 180, 0, 0, tocolor(170, 170, 170, 200 * self.alpha))
        end
        if self:isMouseInPosition(guiInfo.x + (guiInfo.w/2 + 250/zoom)/2 - 24/zoom, guiInfo.y + 214/zoom, 24/zoom, 24/zoom) then
            dxDrawImage(guiInfo.x + (guiInfo.w/2 + 250/zoom)/2 - 24/zoom, guiInfo.y + 214/zoom, 24/zoom, 24/zoom, "files/images/arrow.png", 0, 0, 0, tocolor(170, 170, 170, 255 * self.alpha))
        else
            dxDrawImage(guiInfo.x + (guiInfo.w/2 + 250/zoom)/2 - 24/zoom, guiInfo.y + 214/zoom, 24/zoom, 24/zoom, "files/images/arrow.png", 0, 0, 0, tocolor(170, 170, 170, 200 * self.alpha))
        end


        if guiInfo.vehicleTypes[self.selectedVehicleType] == "Prywatny" then
            dxDrawText("Limit prędkości", guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 272/zoom, guiInfo.x + (guiInfo.w/2 + 250/zoom)/2, guiInfo.y + 50/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "top")
            dxDrawText(guiInfo.vehicleSpeed[self.selectedVehicleSpeed], guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 295/zoom, guiInfo.x + (guiInfo.w/2 + 250/zoom)/2, guiInfo.y + 50/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.data, "center", "top")

            if self:isMouseInPosition(guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 284/zoom, 24/zoom, 24/zoom) then
                dxDrawImage(guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 284/zoom, 24/zoom, 24/zoom, "files/images/arrow.png", 180, 0, 0, tocolor(170, 170, 170, 255 * self.alpha))
            else
                dxDrawImage(guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 284/zoom, 24/zoom, 24/zoom, "files/images/arrow.png", 180, 0, 0, tocolor(170, 170, 170, 200 * self.alpha))
            end
            if self:isMouseInPosition(guiInfo.x + (guiInfo.w/2 + 250/zoom)/2 - 24/zoom, guiInfo.y + 284/zoom, 24/zoom, 24/zoom) then
                dxDrawImage(guiInfo.x + (guiInfo.w/2 + 250/zoom)/2 - 24/zoom, guiInfo.y + 284/zoom, 24/zoom, 24/zoom, "files/images/arrow.png", 0, 0, 0, tocolor(170, 170, 170, 255 * self.alpha))
            else
                dxDrawImage(guiInfo.x + (guiInfo.w/2 + 250/zoom)/2 - 24/zoom, guiInfo.y + 284/zoom, 24/zoom, 24/zoom, "files/images/arrow.png", 0, 0, 0, tocolor(170, 170, 170, 200 * self.alpha))
            end
        else
            dxDrawText("Limit prędkości", guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 272/zoom, guiInfo.x + (guiInfo.w/2 + 250/zoom)/2, guiInfo.y + 50/zoom, tocolor(220, 220, 220, 120 * self.alpha), 1/zoom, self.fonts.main, "center", "top")
            dxDrawText(guiInfo.vehicleSpeed[self.selectedVehicleSpeed], guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 295/zoom, guiInfo.x + (guiInfo.w/2 + 250/zoom)/2, guiInfo.y + 50/zoom, tocolor(170, 170, 170, 120 * self.alpha), 1/zoom, self.fonts.data, "center", "top")
            dxDrawImage(guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 284/zoom, 24/zoom, 24/zoom, "files/images/arrow.png", 180, 0, 0, tocolor(170, 170, 170, 120 * self.alpha))
            dxDrawImage(guiInfo.x + (guiInfo.w/2 + 250/zoom)/2 - 24/zoom, guiInfo.y + 284/zoom, 24/zoom, 24/zoom, "files/images/arrow.png", 0, 0, 0, tocolor(170, 170, 170, 120 * self.alpha))
        end

        dxDrawImage(guiInfo.x + guiInfo.w/2 + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 55/zoom, 250/zoom, 250/zoom, "files/images/map.png", 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
        dxDrawText("Wybierz miejsce rozpoczęcia trasy.", guiInfo.x + guiInfo.w/2 + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 310/zoom, guiInfo.x + guiInfo.w/2 + (guiInfo.w/2 + 250/zoom)/2, guiInfo.y + 50/zoom, tocolor(220, 220, 220, 120 * self.alpha), 1/zoom, self.fonts.minimap, "center", "top", false, true)

        if self.selectedMinimapPos then
            local centerX, centerY = guiInfo.x + guiInfo.w/2 + (guiInfo.w/2 - 250/zoom)/2 + 250/zoom/2, guiInfo.y + 55/zoom + 250/zoom/2
            dxDrawImage(centerX + self.selectedMinimapPos.cursor.x - 12/zoom, centerY - self.selectedMinimapPos.cursor.y - 24/zoom, 24/zoom, 24/zoom, "files/images/location.png", 0, 0, 0, tocolor(220, 40, 40, 255 * self.alpha))
        end

    -- Race on tracks
    elseif self.tab == "race" then
        dxDrawText("Wybór wyścigu", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")

        if not self.renderTable then
            self.rot = self.rot + 2
            if self.rot >= 360 then self.rot = self.rot - 360 end

            dxDrawImage((sx - 64/zoom)/2, guiInfo.y + 145/zoom, 64/zoom, 64/zoom, "files/images/loading.png", self.rot, 0, 0, tocolor(170, 170, 170, 200 * self.alpha))
            dxDrawText("Wczytywanie listy tras...", guiInfo.x, guiInfo.y + 220/zoom, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(170, 170, 170, 200 * self.alpha), 1/zoom, self.fonts.category, "center", "top")

        elseif #self.renderTable > 0 then
            for i = 1, 4 do
                local v = self.renderTable[self.scroll + i]
                if v then
                    if self:isMouseInPosition(guiInfo.x, guiInfo.y + 50/zoom + 72/zoom * (i-1), guiInfo.w, 70/zoom) and not self.raceMapsLoading then
                        dxDrawRectangle(guiInfo.x, guiInfo.y + 50/zoom + 72/zoom * (i-1), guiInfo.w, 70/zoom, tocolor(37, 37, 37, 255 * self.alpha))
                    else
                        dxDrawRectangle(guiInfo.x, guiInfo.y + 50/zoom + 72/zoom * (i-1), guiInfo.w, 70/zoom, tocolor(27, 27, 27, 255 * self.alpha))
                    end

                    dxDrawImage(guiInfo.x + 20/zoom, guiInfo.y + 60/zoom + 72/zoom * (i-1), 50/zoom, 50/zoom, guiInfo.raceImages[v.type], 0, 0, 0, tocolor(220, 220, 220, 255 * self.alpha))
                    dxDrawText(string.format("ID: #aaaaaa#INS%04d", tonumber(v.ID)), guiInfo.x + 90/zoom, guiInfo.y + 53/zoom + 72/zoom * (i-1), guiInfo.x + 200/zoom, guiInfo.y + 50/zoom + 72/zoom * i, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)
                    dxDrawText(string.format("Utworzona: #aaaaaa%s", v.created), guiInfo.x + 90/zoom, guiInfo.y + 73/zoom + 72/zoom * (i-1), guiInfo.x + 200/zoom, guiInfo.y + 50/zoom + 72/zoom * i, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)
                    dxDrawText(string.format("Popularność: #aaaaaa%s", v.trackPopularity or 0), guiInfo.x + 90/zoom, guiInfo.y + 93/zoom + 72/zoom * (i-1), guiInfo.x + 200/zoom, guiInfo.y + 50/zoom + 72/zoom * i, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)

                    dxDrawText(string.format("Typ wyścigu: #aaaaaa%s", v.type), guiInfo.x + 380/zoom, guiInfo.y + 53/zoom + 72/zoom * (i-1), guiInfo.x + 200/zoom, guiInfo.y + 50/zoom + 72/zoom * i, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)
                    dxDrawText(string.format("Typ pojazdu: #aaaaaa%s", v.vehicleType), guiInfo.x + 380/zoom, guiInfo.y + 73/zoom + 72/zoom * (i-1), guiInfo.x + 200/zoom, guiInfo.y + 50/zoom + 72/zoom * i, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)
                    dxDrawText(string.format("Limit prędkości: #aaaaaa%s", v.vehicleSpeed or 0), guiInfo.x + 380/zoom, guiInfo.y + 93/zoom + 72/zoom * (i-1), guiInfo.x + 200/zoom, guiInfo.y + 50/zoom + 72/zoom * i, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)
                end
            end

            if self.raceMapsLoading then
                self.rot = self.rot + 2
                if self.rot >= 360 then self.rot = self.rot - 360 end

                dxDrawImage(guiInfo.x + 225/zoom, guiInfo.y + guiInfo.h - 110/zoom, 32/zoom, 32/zoom, "files/images/loading.png", self.rot, 0, 0, tocolor(170, 170, 170, 200 * self.alpha))
                dxDrawText("Wczytywanie tras...", guiInfo.x + 270/zoom, guiInfo.y + guiInfo.h - 110/zoom, guiInfo.x + guiInfo.w, guiInfo.y + guiInfo.h - 78/zoom, tocolor(170, 170, 170, 200 * self.alpha), 1/zoom, self.fonts.category, "left", "center")
            end

            if #self.renderTable > 4 then
                local b1 = (286/zoom) / #self.renderTable
                local barY = b1 * math.min(self.scroll, #self.renderTable - 4)
                local barHeight = b1 * 4
                dxDrawRectangle(guiInfo.x + guiInfo.w - 8/zoom, guiInfo.y + 50/zoom, 8/zoom, 286/zoom, tocolor(17, 17, 17, 255 * self.alpha))
                dxDrawRectangle(guiInfo.x + guiInfo.w - 6/zoom, guiInfo.y + 50/zoom + barY, 4/zoom, barHeight, tocolor(57, 57, 57, 255 * self.alpha))
            else
                dxDrawRectangle(guiInfo.x + guiInfo.w - 8/zoom, guiInfo.y + 50/zoom, 8/zoom, 286/zoom, tocolor(57, 57, 57, 255 * self.alpha))
            end
        else
            dxDrawText(self.searchText and self.searchText or "Nie została jeszcze stworzona żadna trasa.", guiInfo.x, guiInfo.y + 180/zoom, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(170, 170, 170, 200 * self.alpha), 1/zoom, self.fonts.category, "center", "top")
        end
        self:checkSearchEdit()

    elseif self.tab == "pickVehicle" then
        dxDrawText("Wybór pojazdu", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")

        if not self.renderTable then
            self.rot = self.rot + 2
            if self.rot >= 360 then self.rot = self.rot - 360 end

            dxDrawImage((sx - 64/zoom)/2, guiInfo.y + 145/zoom, 64/zoom, 64/zoom, "files/images/loading.png", self.rot, 0, 0, tocolor(170, 170, 170, 200 * self.alpha))
            dxDrawText("Wczytywanie listy pojazdów...", guiInfo.x, guiInfo.y + 220/zoom, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(170, 170, 170, 200 * self.alpha), 1/zoom, self.fonts.category, "center", "top")

        elseif #self.renderTable > 0 then
            for i = 1, 4 do
                local data = self.renderTable[self.scroll + i]
                if data then
                    if self:isMouseInPosition(guiInfo.x, guiInfo.y + 50/zoom + 72/zoom * (i-1), guiInfo.w, 70/zoom) or self.selectedVehicle == data.ID then
                        dxDrawRectangle(guiInfo.x, guiInfo.y + 50/zoom + 72/zoom * (i-1), guiInfo.w, 70/zoom, tocolor(37, 37, 37, 255 * self.alpha))
                    else
                        dxDrawRectangle(guiInfo.x, guiInfo.y + 50/zoom + 72/zoom * (i-1), guiInfo.w, 70/zoom, tocolor(27, 27, 27, 255 * self.alpha))
                    end
                end

                local color = tocolor(220, 220, 220, 255 * self.alpha)
                if self.selectedVehicle == data.ID then color = tocolor(212, 175, 55, 255 * self.alpha) end

                dxDrawImage(guiInfo.x + 20/zoom, guiInfo.y + 60/zoom + 72/zoom * (i-1), 50/zoom, 50/zoom, data.img, 0, 0, 0, color)
                dxDrawText(string.format("ID: #aaaaaa%d", tonumber(data.ID)), guiInfo.x + 90/zoom, guiInfo.y + 53/zoom + 72/zoom * (i-1), guiInfo.x + 200/zoom, guiInfo.y + 50/zoom + 72/zoom * i, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)
                dxDrawText(string.format("Model: #aaaaaa%s", data.name), guiInfo.x + 90/zoom, guiInfo.y + 73/zoom + 72/zoom * (i-1), guiInfo.x + 200/zoom, guiInfo.y + 50/zoom + 72/zoom * i, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)
                dxDrawText(string.format("Silnik: #aaaaaa%s", data.engine), guiInfo.x + 90/zoom, guiInfo.y + 93/zoom + 72/zoom * (i-1), guiInfo.x + 200/zoom, guiInfo.y + 50/zoom + 72/zoom * i, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)

                -- dxDrawText(string.format("Prędkość maksymalna: #aaaaaa%skm/h", data.maxSpeed or 0), guiInfo.x + 380/zoom, guiInfo.y + 53/zoom + 72/zoom * (i-1), guiInfo.x + 200/zoom, guiInfo.y + 50/zoom + 72/zoom * i, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)
                dxDrawText(string.format("Prędkość maksymalna: #aaaaaa%skm/h", data.maxSpeed or 0), guiInfo.x + 380/zoom, guiInfo.y + 73/zoom + 72/zoom * (i-1), guiInfo.x + 200/zoom, guiInfo.y + 50/zoom + 72/zoom * i, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)

                if self.trackDetails.vehicleSpeed == "Bez limitu" then
                    dxDrawText("Dostępny w tym wyścigu: #aaaaaaTAK", guiInfo.x + 380/zoom, guiInfo.y + 93/zoom + 72/zoom * (i-1), guiInfo.x + 200/zoom, guiInfo.y + 50/zoom + 72/zoom * i, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)
                else
                    dxDrawText(data.maxSpeed > tonumber(self.trackDetails.vehicleSpeed) and "Dostępny w tym wyścigu: #aaaaaaNIE" or "Dostępny w tym wyścigu: #aaaaaaTAK", guiInfo.x + 380/zoom, guiInfo.y + 93/zoom + 72/zoom * (i-1), guiInfo.x + 200/zoom, guiInfo.y + 50/zoom + 72/zoom * i, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)
                end
            end
        else
            dxDrawText(self.searchText and self.searchText or "Nie posiadasz żadnego prywatnego pojazdu.", guiInfo.x, guiInfo.y + 180/zoom, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(170, 170, 170, 200 * self.alpha), 1/zoom, self.fonts.category, "center", "top")
        end
        self:checkSearchEdit()

    elseif self.tab == "raceDetails" or self.tab == "raceStart" then
        dxDrawText("Detale wyścigu", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")

        if not self.trackDetails then
            self.rot = self.rot + 2
            if self.rot >= 360 then self.rot = self.rot - 360 end

            dxDrawImage((sx - 64/zoom)/2, guiInfo.y + 145/zoom, 64/zoom, 64/zoom, "files/images/loading.png", self.rot, 0, 0, tocolor(170, 170, 170, 200 * self.alpha))
            dxDrawText("Wczytywanie danych trasy...", guiInfo.x, guiInfo.y + 220/zoom, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(170, 170, 170, 200 * self.alpha), 1/zoom, self.fonts.category, "center", "top")

        else
            dxDrawText("Informacje dotyczące trasy:", guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 60/zoom, guiInfo.x + (guiInfo.w/2 + 250/zoom)/2, guiInfo.y + 50/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.main, "left", "top", false, false, false, true)
            dxDrawText(string.format("Typ wyścigu: #aaaaaa%s", self.trackDetails.type), guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 90/zoom, guiInfo.x + (guiInfo.w/2 + 250/zoom)/2, guiInfo.y + 50/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)
            if self.trackDetails.type == "Okrążenia" then
                dxDrawText(string.format("Ilość okrążeń: #aaaaaa%s", self.trackDetails.laps), guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 115/zoom, guiInfo.x + (guiInfo.w/2 + 250/zoom)/2, guiInfo.y + 50/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)
            else
                dxDrawText(string.format("Ilość okrążeń: #aaaaaa%s", self.trackDetails.laps), guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 115/zoom, guiInfo.x + (guiInfo.w/2 + 250/zoom)/2, guiInfo.y + 50/zoom, tocolor(170, 170, 170, 120 * self.alpha), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)
            end
            dxDrawText(string.format("Typ pojazdu: #aaaaaa%s", self.trackDetails.vehicleType), guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 140/zoom, guiInfo.x + (guiInfo.w/2 + 250/zoom)/2, guiInfo.y + 50/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)
            if self.trackDetails.vehicleType == "Prywatny" then
                dxDrawText(string.format("Limit prędkości: #aaaaaa%s", self.trackDetails.vehicleSpeed), guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 165/zoom, guiInfo.x + (guiInfo.w/2 + 250/zoom)/2, guiInfo.y + 50/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)
            else
                dxDrawText(string.format("Limit prędkości: #aaaaaa%s", self.trackDetails.vehicleSpeed), guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 165/zoom, guiInfo.x + (guiInfo.w/2 + 250/zoom)/2, guiInfo.y + 50/zoom, tocolor(170, 170, 170, 120 * self.alpha), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)
            end
            dxDrawText(string.format("Popularność: #aaaaaa%s", self.trackDetails.trackPopularity or 0), guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 190/zoom, guiInfo.x + (guiInfo.w/2 + 250/zoom)/2, guiInfo.y + 50/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)

            if self.trackDetails.type == "Drift" then
                dxDrawText("Najwięcej punktów:", guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 235/zoom, guiInfo.x + (guiInfo.w/2 + 250/zoom)/2, guiInfo.y + 50/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.main, "left", "top", false, false, false, true)
            else
                dxDrawText("Najlepsze czasy:", guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 235/zoom, guiInfo.x + (guiInfo.w/2 + 250/zoom)/2, guiInfo.y + 50/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.main, "left", "top", false, false, false, true)
            end

            if self.trackDetails.bestTimes then
                if self.trackDetails.bestTimes[1].username then
                    for i = 1, 3 do
                        local data = self.trackDetails.bestTimes[i]
                        if data and data.username then
                            dxDrawText(string.format("#%d #aaaaaa%s | %s", i, data.username, self.trackDetails.type == "Drift" and self:comma_value(tonumber(data.playerTime)) or self:getTimeInSeconds(tonumber(data.playerTime))), guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 265/zoom + 25/zoom * (i-1), guiInfo.x + (guiInfo.w/2 + 250/zoom)/2, guiInfo.y + 50/zoom + 25/zoom * (i-1), tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)
                        end
                    end
                else
                    dxDrawText("Brak czasów na tej trasie", guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 265/zoom, guiInfo.x + (guiInfo.w/2 + 250/zoom)/2, guiInfo.y + 50/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)
                end
            else
                dxDrawText("Brak czasów na tej trasie", guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 265/zoom, guiInfo.x + (guiInfo.w/2 + 250/zoom)/2, guiInfo.y + 50/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)
            end

            dxDrawImage(guiInfo.x + guiInfo.w/2 + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 55/zoom, 250/zoom, 250/zoom, "files/images/map.png", 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))

            if self.trackDetails.startPos then
                local centerX, centerY = guiInfo.x + guiInfo.w/2 + (guiInfo.w/2 - 250/zoom)/2 + 250/zoom/2, guiInfo.y + 55/zoom + 250/zoom/2
                local mapStartX, mapStartY = (self.trackDetails.startPos[1])/6000 * 250/zoom, (self.trackDetails.startPos[2])/6000 * 250/zoom
                local mapFinishX, mapFinishY = (self.trackDetails.lastPos[1])/6000 * 250/zoom, (self.trackDetails.lastPos[2])/6000 * 250/zoom

                dxDrawImage(centerX + mapStartX - 12/zoom, centerY - mapStartY - 24/zoom, 24/zoom, 24/zoom, "files/images/location.png", 0, 0, 0, tocolor(220, 40, 40, 255 * self.alpha))

                if self.trackDetails.type ~= "Okrążenia" then
                    dxDrawImage(centerX + mapFinishX - 12/zoom, centerY - mapFinishY - 24/zoom, 24/zoom, 24/zoom, "files/images/location.png", 0, 0, 0, tocolor(43, 128, 255, 255 * self.alpha))
                    dxDrawText("#dc2828Czerwony znacznik #dcdcdc- start\n#2b80ffNiebieski znacznik #dcdcdc- meta.", guiInfo.x + guiInfo.w/2 + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 310/zoom, guiInfo.x + guiInfo.w/2 + (guiInfo.w/2 + 250/zoom)/2, guiInfo.y + 50/zoom, tocolor(220, 220, 220, 120 * self.alpha), 1/zoom, self.fonts.minimap, "center", "top", false, false, false, true)
                else
                    dxDrawText("#dc2828Czerwony znacznik #dcdcdc- start i meta.", guiInfo.x + guiInfo.w/2 + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 320/zoom, guiInfo.x + guiInfo.w/2 + (guiInfo.w/2 + 250/zoom)/2, guiInfo.y + 50/zoom, tocolor(220, 220, 220, 120 * self.alpha), 1/zoom, self.fonts.minimap, "center", "top", false, false, false, true)
                end
            end
        end

    elseif self.tab == "trackRemove" then
        dxDrawText("Usuwanie trasy", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")

        dxDrawText("Czy jesteś pewny, że chcesz usunąć tę trasę?\n#a3281fTen proces jest nieodwracalny.", guiInfo.x, guiInfo.y + 310/zoom, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "center", "center", false, false, false, true)

    end
end

function RacePanel:checkSearchEdit()
    if self.blockSearch then return end
    local text = guiGetText(self.edits.findMap)
    if not self.lastText then self.lastText = text end

    if self.lastText ~= text then
        self.lastText = text
        self.searchMapTick = getTickCount()
        self.renderTable = nil
    end

    if self.searchMapTick then
        if (getTickCount() - self.searchMapTick)/guiInfo.searchAfterTime >= 1 then
            self.searchMapTick = nil
            self.blockSearch = true
            self:performTrachSearch(text)
        end
    end
end

function RacePanel:performTrachSearch(text)
    if string.find(text, "#") then
        if string.find(text, "#INS") then
            triggerServerEvent("getRaceTrackSearch", resourceRoot, "trackID", tonumber(string.sub(text, 5, string.len(text))))
        else
            triggerServerEvent("getRaceTrackSearch", resourceRoot, "trackID", tonumber(string.sub(text, 2, string.len(text))))
        end
        self.searchText = "Taka trasa nie została odnaleziona."

    elseif tonumber(text) ~= nil then
        triggerServerEvent("getRaceTrackSearch", resourceRoot, "trackID", tonumber(text))
        self.searchText = "Taka trasa nie została odnaleziona."

    elseif string.len(text) < 1 then
        triggerServerEvent("getRaceTrackBest", resourceRoot)
        self.searchText = nil

    else
        triggerServerEvent("getRaceTrackSearch", resourceRoot, "playerName", text)
        self.searchText = "Gracz nie stworzył jeszcze żadnej trasy."
    end

    self.toLoad = 0
end

function RacePanel:selectTab(tab, details)
    self.lastTab = self.tab
    self.tab = tab
    exports.TR_dx:setButtonVisible(self.buttons, false)
    exports.TR_dx:setEditVisible(self.edits, false)

    if tab == "main" then
        exports.TR_dx:setButtonVisible(self.buttons.exit, true)
        self.mainTab = nil
        self.renderTable = nil

    elseif tab == "create" then
        exports.TR_dx:setButtonVisible({self.buttons.back, self.buttons.create}, true)
        exports.TR_dx:setButtonText(self.buttons.create, "Stwórz nową")
        self:loadData("create")
        self.mainTab = tab

    elseif tab == "getPrice" then
        exports.TR_dx:setButtonVisible({self.buttons.back, self.buttons.create}, true)
        exports.TR_dx:setButtonText(self.buttons.create, "Odbierz nagrody")
        self:loadData("getPrice")

    elseif tab == "createSettings" then
        exports.TR_dx:setButtonVisible({self.buttons.back, self.buttons.create}, true)
        exports.TR_dx:setButtonText(self.buttons.create, "Dalej")

        self.selectedRaceType = 1
        self.selectedRaceLaps = 2
        self.selectedVehicleType = 1
        self.selectedVehicleSpeed = 1
        self.selectedMinimapPos = nil

    elseif tab == "race" then
        exports.TR_dx:setButtonVisible(self.buttons.back, true)
        exports.TR_dx:setEditVisible(self.edits.findMap, true)
        self:loadData("race")
        self.mainTab = tab
        self.scroll = 0

    elseif tab == "raceDetails" then
        exports.TR_dx:setButtonVisible({self.buttons.back, self.buttons.create}, true)
        exports.TR_dx:setButtonText(self.buttons.create, "Usuń trasę")
        self:loadData("raceDetails", details)

    elseif tab == "raceStart" then
        exports.TR_dx:setButtonVisible({self.buttons.back, self.buttons.create}, true)
        exports.TR_dx:setButtonText(self.buttons.create, "Rozpocznij wyścig")
        self:loadData("raceStart", details)

    elseif tab == "trackRemove" then
        exports.TR_dx:setButtonVisible({self.buttons.removeAcceptCenter, self.buttons.removeDeclineCenter}, true)

    elseif tab == "pickVehicle" then
        self:loadData("pickVehicle")
        exports.TR_dx:setButtonVisible({self.buttons.back, self.buttons.create}, true)
        exports.TR_dx:setButtonText(self.buttons.create, "Rozpocznij wyścig")
    end
end

function RacePanel:loadData(tab, details)
    if tab == "create" then
        if self.loadedData["create"] then
            self.renderTable = self.loadedData["create"]
        else
            exports.TR_dx:setResponseEnabled(true)
            triggerServerEvent("getPlayerCreatedRaceTracks", resourceRoot)
        end

    elseif tab == "raceDetails" or tab == "raceStart" then
        if details then
            exports.TR_dx:setResponseEnabled(true)

            local type = false
            for i, v in pairs(self.renderTable) do
                if v.ID == details then
                    type = v.type
                    break
                end
            end
            triggerServerEvent("getRaceTrackDetails", resourceRoot, details, type)
        end

    elseif tab == "race" then
        if self.loadedData["race"] then
            self.renderTable = self.loadedData["race"]
        else
            exports.TR_dx:setResponseEnabled(true)
            triggerServerEvent("getRaceTrackBest", resourceRoot)
        end

    elseif tab == "getPrice" then
        exports.TR_dx:setResponseEnabled(true)
        triggerServerEvent("getPlayerWinRacePrices", resourceRoot)

    elseif tab == "pickVehicle" then
        self.scroll = 0
        exports.TR_dx:setResponseEnabled(true)
        triggerServerEvent("getPlayerAvaliableRaceVehicles", resourceRoot)
    end
end

function RacePanel:response(data, type)
    exports.TR_dx:setResponseEnabled(false)
    self.blockSearch = nil

    if type == "playerNotFound" then
        self.searchText = "Taki gracz nie został odnaleziony."
        self.renderTable = {}
        self.loadedData["race"] = {}
    end
    if not data then return end
    if self.tab == "create" then
        self.loadedData["create"] = data
        self.renderTable = self.loadedData["create"]

    elseif self.tab == "race" then
        if type then
            for i, v in pairs(data) do
                table.insert(self.loadedData["race"], v)
                self.loadedRaceTracks = self.loadedRaceTracks + 1
            end

            if #data < 1 then
                self.scroll = self.scroll - 1
            end
            if self.loadedRaceTracks < self.toLoad + 10 then
                exports.TR_noti:create("Załadowano wszystkie dostępne trasy.", "success")
            end

            self.raceMapsLoading = false
        else
            self.loadedData["race"] = data
            self.renderTable = self.loadedData["race"]

            self.loadedRaceTracks = 10
        end

    elseif self.tab == "raceDetails" or self.tab == "raceStart" then
        if self.trackDetails then return end
        self.trackDetails = data
        self.trackDetails.track = fromJSON(data.track)
        self.trackDetails.startPos = self.trackDetails.track[1].pos
        self.trackDetails.lastPos = self.trackDetails.track[#self.trackDetails.track].pos
        self.trackDetails.bestTimes = #data.bestTimes > 0 and data.bestTimes or false

    elseif self.tab == "getPrice" then
        self.renderTable = data
        if type then exports.TR_noti:create("Nagrody zostały odebrane pomyślnie.", "success") end

    elseif self.tab == "pickVehicle" then
        self.renderTable = {}
        if data then
            for i, v in pairs(data) do
                local img = self:getVehicleImg(v.model)
                if img then
                    local capacity = self:getEngineCapacity(v.engineCapacity)
                    local maxSpeed = exports.TR_vehicles:getVehicleMaxSpeed(v.model, capacity)
                    if maxSpeed then
                        table.insert(self.renderTable, {
                            ID = v.ID,
                            img = img,
                            name = self:getVehicleName(v.model),
                            engine = v.engineCapacity,
                            maxSpeed = math.floor(maxSpeed),
                        })
                    end
                end
            end
        end
    end
end

function RacePanel:getEngineCapacity(capacity)
    local c = ""
    for i = 1, string.len(capacity) do
        local str = string.sub(capacity, i, i)
        if str == " " then break end
        c = c .. str
    end

    local newCapacity = tonumber(c)
    if string.find(capacity, "Turbo") then newCapacity = newCapacity + 0.5 end
    if string.find(capacity, "Biturbo") or string.find(capacity, "Twin Turbo") then newCapacity = newCapacity + 1 end

    return newCapacity
end

function RacePanel:onClientKey(btn, state)
    if exports.TR_dx:isResponseEnabled() then return end
    if self.tab ~= "pickVehicle" and self.tab ~= "race" then return end

    if btn == "mouse_wheel_up" then
        self.scroll = math.max(self.scroll - 1, 0)

    elseif btn == "mouse_wheel_down" then
        if not self.renderTable then return end
        if #self.renderTable <= 4 then return end

        if self.loadedRaceTracks < self.toLoad + 10 then
            self.scroll = math.min(self.scroll + 1, #self.renderTable - 4)
            return
        else
            self.scroll = math.min(self.scroll + 1, #self.renderTable - 3)
        end

        if self.scroll > #self.renderTable - 4 then
            self.raceMapsLoading = true

            self.toLoad = self.toLoad + 10
            triggerServerEvent("getRaceTrackBest", resourceRoot, self.toLoad)
            exports.TR_dx:setResponseEnabled(true)
        end
    end
end

function RacePanel:onClientClick(btn, state)
    if self.blockSearch then return end
    if exports.TR_dx:isResponseEnabled() then return end
    if btn ~= "left" or state ~= "down" then return end

    if self.tab == "main" then
        if self:isMouseInPosition(guiInfo.x + 50/zoom, guiInfo.y + 90/zoom, 148/zoom, 200/zoom) then
            self:selectTab("race")

        elseif self:isMouseInPosition(guiInfo.x + guiInfo.w - 128/zoom - 70/zoom, guiInfo.y + 90/zoom, 148/zoom, 200/zoom) then
            self:selectTab("create")

        elseif self:isMouseInPosition(guiInfo.x + guiInfo.w/2 - 74/zoom, guiInfo.y + 90/zoom, 148/zoom, 200/zoom) then
            self:selectTab("getPrice")
        end

    elseif self.tab == "create" then
        if #self.renderTable > 0 then
            for i, v in pairs(self.renderTable) do
                if self:isMouseInPosition(guiInfo.x, guiInfo.y + 50/zoom + 72/zoom * (i-1), guiInfo.w, 70/zoom) then
                    self.raceMapIndex = i
                    self:selectTab("raceDetails", v.ID)
                    break
                end
            end
        end

    elseif self.tab == "race" then
        if self.renderTable then
            if #self.renderTable > 0 then
                for i = 1, 4 do
                    local v = self.renderTable[self.scroll + i]
                    if v then
                        if self:isMouseInPosition(guiInfo.x, guiInfo.y + 50/zoom + 72/zoom * (i-1), guiInfo.w, 70/zoom) then
                            self.raceMapIndex = i
                            self:selectTab("raceStart", v.ID)
                            break
                        end
                    end
                end
            end
        end

    elseif self.tab == "pickVehicle" then
        if self.renderTable then
            if #self.renderTable > 0 then
                for i = 1, 4 do
                    local data = self.renderTable[self.scroll + i]
                    if data then
                        if self:isMouseInPosition(guiInfo.x, guiInfo.y + 50/zoom + 72/zoom * (i-1), guiInfo.w, 70/zoom) then
                            self.selectedVehicle = data.ID
                            break
                        end
                    end
                end
            end
        end

    elseif self.tab == "createSettings" then
        if self:isMouseInPosition(guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 74/zoom, 24/zoom, 24/zoom) then
            self.selectedRaceType = self.selectedRaceType - 1
            if self.selectedRaceType == 0 then self.selectedRaceType = #guiInfo.raceTypes end

        elseif self:isMouseInPosition(guiInfo.x + (guiInfo.w/2 + 250/zoom)/2 - 24/zoom, guiInfo.y + 74/zoom, 24/zoom, 24/zoom) then
            self.selectedRaceType = self.selectedRaceType + 1
            if self.selectedRaceType > #guiInfo.raceTypes then self.selectedRaceType = 1 end

        elseif self:isMouseInPosition(guiInfo.x + (guiInfo.w/2 + 250/zoom)/2 - 24/zoom, guiInfo.y + 144/zoom, 24/zoom, 24/zoom) and guiInfo.raceTypes[self.selectedRaceType] == "Okrążenia" then
            self.selectedRaceLaps = math.min(self.selectedRaceLaps + 1, 9)

        elseif self:isMouseInPosition(guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 144/zoom, 24/zoom, 24/zoom) and guiInfo.raceTypes[self.selectedRaceType] == "Okrążenia" then
            self.selectedRaceLaps = math.max(self.selectedRaceLaps - 1, 2)

        elseif self:isMouseInPosition(guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 214/zoom, 24/zoom, 24/zoom) then
            self.selectedVehicleType = self.selectedVehicleType + 1
            if self.selectedVehicleType > #guiInfo.vehicleTypes then self.selectedVehicleType = 1 end

        elseif self:isMouseInPosition(guiInfo.x + (guiInfo.w/2 + 250/zoom)/2 - 24/zoom, guiInfo.y + 214/zoom, 24/zoom, 24/zoom) then
            self.selectedVehicleType = self.selectedVehicleType - 1
            if self.selectedVehicleType <= 0 then self.selectedVehicleType = #guiInfo.vehicleTypes end


        elseif self:isMouseInPosition(guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 214/zoom, 24/zoom, 24/zoom) then
            self.selectedVehicleType = self.selectedVehicleType + 1
            if self.selectedVehicleType > #guiInfo.vehicleTypes then self.selectedVehicleType = 1 end

        elseif self:isMouseInPosition(guiInfo.x + (guiInfo.w/2 + 250/zoom)/2 - 24/zoom, guiInfo.y + 214/zoom, 24/zoom, 24/zoom) then
            self.selectedVehicleType = self.selectedVehicleType - 1
            if self.selectedVehicleType <= 0 then self.selectedVehicleType = #guiInfo.vehicleTypes end



        elseif self:isMouseInPosition(guiInfo.x + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 284/zoom, 24/zoom, 24/zoom) and guiInfo.vehicleTypes[self.selectedVehicleType] == "Prywatny" then
            self.selectedVehicleSpeed = self.selectedVehicleSpeed - 1
            if self.selectedVehicleSpeed <= 0 then self.selectedVehicleSpeed = #guiInfo.vehicleSpeed end

        elseif self:isMouseInPosition(guiInfo.x + (guiInfo.w/2 + 250/zoom)/2 - 24/zoom, guiInfo.y + 284/zoom, 24/zoom, 24/zoom) and guiInfo.vehicleTypes[self.selectedVehicleType] == "Prywatny" then
            self.selectedVehicleSpeed = self.selectedVehicleSpeed + 1
            if self.selectedVehicleSpeed > #guiInfo.vehicleSpeed then self.selectedVehicleSpeed = 1 end


        elseif self:isMouseInPosition(guiInfo.x + guiInfo.w/2 + (guiInfo.w/2 - 250/zoom)/2, guiInfo.y + 55/zoom, 250/zoom, 250/zoom) then
            local centerX, centerY = guiInfo.x + guiInfo.w/2 + (guiInfo.w/2 - 250/zoom)/2 + 250/zoom/2, guiInfo.y + 55/zoom + 250/zoom/2
            local cx, cy = getCursorPosition()
            local cx, cy = cx * sx, cy * sy

            local absoluteX, absoluteY = cx - centerX, centerY - cy
            local mapX, mapY = (absoluteX/250/zoom) * 6000, (absoluteY/250/zoom) * 6000
            local mapZ = getGroundPosition(mapX, mapY, 1000)

            self.selectedMinimapPos = {
                cursor = Vector2(absoluteX, absoluteY),
                map = Vector3(mapX, mapY, mapZ)
            }
        end
    end
end

function RacePanel:buttonClick(btn)
    if self.blockSearch then return end
    if btn == self.buttons.exit then
        self:close()

    elseif btn == self.buttons.back then
        if self.tab == "createSettings" then
            self:selectTab("create")

        elseif self.tab == "raceDetails" or self.tab == "raceStart" then
            self:selectTab(self.mainTab and self.mainTab or self.lastTab)
            self.trackDetails = nil

        elseif self.tab == "trackRemove" then
            self:selectTab(self.lastTab)

        elseif self.tab == "pickVehicle" then
            self:selectTab(self.lastTab)
        else
            self:selectTab("main")
        end

    elseif btn == self.buttons.create then
        if self.tab == "create" then
            if self.loadedData["create"] then
                if #self.loadedData["create"] >= 4 then
                    exports.TR_noti:create("Osiągnąłeś limit tras, jakie możesz utworzyć.", "error")
                    return
                end
            end
            self:selectTab("createSettings")

        elseif self.tab == "createSettings" then
            self:startTrackCreation()

        elseif self.tab == "raceDetails" then
            self:selectTab("trackRemove")

        elseif self.tab == "getPrice" then
            if not self.renderTable then return end
            if self.renderTable < 1 then exports.TR_noti:create("Nie posiadasz żadnej nagrody do odebrania.", "error") return end
            exports.TR_dx:setResponseEnabled(true)
            triggerServerEvent("getPlayerRaceWinMoney", resourceRoot)

        elseif self.tab == "raceStart" then
            local isAdmin = exports.TR_admin:isPlayerOnDuty()
            local isDev = exports.TR_admin:isPlayerDeveloper()
            if isAdmin and not isDev then exports.TR_noti:create("Nie możesz rozpocząć wyścigu podczas służby administracyjnej.", "error") return end

            if self.trackDetails.vehicleType == "Prywatny" then
                self.renderTable = nil
                self:selectTab("pickVehicle")

            else
                self.blockSearch = true
                exports.TR_dx:showLoading(900000, "Trwa wczytywanie wyścigu")

                setTimer(function()
                    self:close(true)
                end, 1000, 1)

                setTimer(function()
                    exports.TR_hud:setHudRaceMode(self.trackDetails.type)

                    if self.trackDetails.type == "Sprint" then
                        exports.TR_hud:updateRaceDetails({
                            lap = 1,
                            laps = self.trackDetails.laps,
                        })
                        createLapRace(1, self.trackDetails.track, self.trackDetails.ID)

                    elseif self.trackDetails.type == "Drag" then
                        exports.TR_hud:updateRaceDetails({
                            lap = 1,
                            laps = self.trackDetails.laps,
                        })
                        createLapRace(1, self.trackDetails.track, self.trackDetails.ID)
                        createDragShifter()

                    elseif self.trackDetails.type == "Okrążenia" then
                        exports.TR_hud:updateRaceDetails({
                            lap = 1,
                            laps = self.trackDetails.laps,
                        })
                        createLapRace(self.trackDetails.laps, self.trackDetails.track, self.trackDetails.ID)

                    elseif self.trackDetails.type == "Drift" then
                        exports.TR_hud:updateRaceDetails({
                            lap = 1,
                            laps = 1,
                            driftScore = 0,
                        })
                        createLapRace(1, self.trackDetails.track, self.trackDetails.ID)
                        createDriftCounter()

                    end

                    setTimer(startRaceCountdown, 2000, 1, self.trackDetails.type)
                end, 5000, 1)

                local x, y, z = getElementPosition(localPlayer)
                local int = getElementInterior(localPlayer)
                local dim = getElementDimension(localPlayer)
                setElementData(localPlayer, "characterQuit", {x, y, z, int, dim})

                triggerServerEvent("createVehicleRace", resourceRoot, {self.trackDetails.track[1].pos[1], self.trackDetails.track[1].pos[2], self.trackDetails.track[1].pos[3], self.trackDetails.track[1].rot}, getVehicleModelFromName(self.trackDetails.vehicleType), self.trackDetails.type)
            end

        elseif self.tab == "pickVehicle" then
            if not self.selectedVehicle then exports.TR_noti:create("Żaden pojazd nie został wybrany.", "error") return end
            if self.trackDetails.vehicleSpeed == "Bez limitu" then
                self.blockSearch = true
                exports.TR_dx:showLoading(900000, "Trwa wczytywanie wyścigu")

                setTimer(function()
                    self:close(true)
                end, 1000, 1)

                setTimer(function()
                    exports.TR_hud:setHudRaceMode(self.trackDetails.type)

                    if self.trackDetails.type == "Sprint" then
                        exports.TR_hud:updateRaceDetails({
                            lap = 1,
                            laps = self.trackDetails.laps,
                        })
                        createLapRace(1, self.trackDetails.track, self.trackDetails.ID)

                    elseif self.trackDetails.type == "Drag" then
                        exports.TR_hud:updateRaceDetails({
                            lap = 1,
                            laps = self.trackDetails.laps,
                        })
                        createLapRace(1, self.trackDetails.track, self.trackDetails.ID)
                        createDragShifter()

                    elseif self.trackDetails.type == "Okrążenia" then
                        exports.TR_hud:updateRaceDetails({
                            lap = 1,
                            laps = self.trackDetails.laps,
                        })
                        createLapRace(self.trackDetails.laps, self.trackDetails.track, self.trackDetails.ID)

                    elseif self.trackDetails.type == "Drift" then
                        exports.TR_hud:updateRaceDetails({
                            lap = 1,
                            laps = 1,
                            driftScore = 0,
                        })
                        createLapRace(1, self.trackDetails.track, self.trackDetails.ID)
                        createDriftCounter()

                    end

                    setTimer(startRaceCountdown, 2000, 1, self.trackDetails.type)
                end, 5000, 1)

                local x, y, z = getElementPosition(localPlayer)
                local int = getElementInterior(localPlayer)
                local dim = getElementDimension(localPlayer)
                setElementData(localPlayer, "characterQuit", {x, y, z, int, dim})

                triggerServerEvent("createVehiclePrivateRace", resourceRoot, {self.trackDetails.track[1].pos[1], self.trackDetails.track[1].pos[2], self.trackDetails.track[1].pos[3], self.trackDetails.track[1].rot}, self.trackDetails.type, self.selectedVehicle)
            else
                local data
                for i, v in pairs(self.renderTable) do
                    if v.ID == self.selectedVehicle then
                        data = v
                        break
                    end
                end
                if not data then return end
                if data.maxSpeed > tonumber(self.trackDetails.vehicleSpeed) then exports.TR_noti:create("Ten pojazd nie spełnia wymagań i nie możesz się nim ścigać w tym wyścigu.", "error") return end

                self.blockSearch = true
                exports.TR_dx:showLoading(900000, "Trwa wczytywanie wyścigu")

                setTimer(function()
                    self:close(true)
                end, 1000, 1)

                setTimer(function()
                    exports.TR_hud:setHudRaceMode(self.trackDetails.type)

                    if self.trackDetails.type == "Sprint" then
                        exports.TR_hud:updateRaceDetails({
                            lap = 1,
                            laps = self.trackDetails.laps,
                        })
                        createLapRace(1, self.trackDetails.track, self.trackDetails.ID)

                    elseif self.trackDetails.type == "Drag" then
                        exports.TR_hud:updateRaceDetails({
                            lap = 1,
                            laps = self.trackDetails.laps,
                        })
                        createLapRace(1, self.trackDetails.track, self.trackDetails.ID)
                        createDragShifter()

                    elseif self.trackDetails.type == "Okrążenia" then
                        exports.TR_hud:updateRaceDetails({
                            lap = 1,
                            laps = self.trackDetails.laps,
                        })
                        createLapRace(self.trackDetails.laps, self.trackDetails.track, self.trackDetails.ID)

                    elseif self.trackDetails.type == "Drift" then
                        exports.TR_hud:updateRaceDetails({
                            lap = 1,
                            laps = 1,
                            driftScore = 0,
                        })
                        createLapRace(1, self.trackDetails.track, self.trackDetails.ID)
                        createDriftCounter()

                    end

                    setTimer(startRaceCountdown, 2000, 1, self.trackDetails.type)
                end, 5000, 1)

                local x, y, z = getElementPosition(localPlayer)
                local int = getElementInterior(localPlayer)
                local dim = getElementDimension(localPlayer)
                setElementData(localPlayer, "characterQuit", {x, y, z, int, dim})

                triggerServerEvent("createVehiclePrivateRace", resourceRoot, {self.trackDetails.track[1].pos[1], self.trackDetails.track[1].pos[2], self.trackDetails.track[1].pos[3], self.trackDetails.track[1].rot}, self.trackDetails.type, self.selectedVehicle)
            end
        end

    elseif btn == self.buttons.removeDeclineCenter then
        self:selectTab(self.lastTab)

    elseif btn == self.buttons.removeAcceptCenter then
        exports.TR_dx:setResponseEnabled(true)

        triggerServerEvent("removePlayerRaceTrack", resourceRoot, self.loadedData["create"][self.raceMapIndex].ID)

        self:selectTab(self.mainTab)
        table.remove(self.loadedData["create"], self.raceMapIndex)
    end
end

function RacePanel:blockDmg()
    cancelEvent()
end

function RacePanel:startTrackCreation()
    if not self.selectedMinimapPos then exports.TR_noti:create("Aby przejść dalej musisz najpierw wybrać punkt rozpoczęcia.", "info") return end

    exports.TR_dx:showLoading(999999, "Sprawdzanie terenu rozpoczęcia trasy")
    exports.TR_dx:setResponseEnabled(true)

    local x, y, z = getElementPosition(localPlayer)
    local int = getElementInterior(localPlayer)
    local dim = getElementDimension(localPlayer)
    setElementData(localPlayer, "characterQuit", {x, y, z, int, dim})

    setTimer(function()
        local data = {
            selectedRaceType = guiInfo.raceTypes[self.selectedRaceType],
            selectedRaceLaps = self.selectedRaceLaps,
            selectedVehicleType = guiInfo.vehicleTypes[self.selectedVehicleType],
            selectedVehicleSpeed = guiInfo.vehicleSpeed[self.selectedVehicleSpeed],
            selectedMinimapPos = self.selectedMinimapPos,
        }
        startTrackCreation(data)
    end, 1000, 1)
end

function RacePanel:drawBackground(x, y, rx, ry, color, radius, post)
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

function RacePanel:isMouseInPosition(x, y, width, height)
    if (not isCursorShowing()) then return false end
    local cx, cy = getCursorPosition()
    local cx, cy = (cx*sx), (cy*sy)
    if (cx >= x and cx <= x + width) and (cy >= y and cy <= y + height) then return true end
    return false
end

function RacePanel:getTimeInSeconds(miliseconds)
    local durationInMillis = tonumber(miliseconds)
    if not durationInMillis or durationInMillis == nil then return "" end
    if durationInMillis <= 0 then
      return "00:00:00.000";
    else
		local millis = durationInMillis % 1000;
		local second = (durationInMillis / 1000) % 60;
		local minute = (durationInMillis / (1000 * 60)) % 60;
		local hour = (durationInMillis / (1000 * 60 * 60)) % 24;

        if hour >= 1 then
            return string.format("%02d:%02d:%02d.%03d", hour, minute, second, millis)
        else
            return string.format("%02d:%02d.%03d", minute, second, millis)
        end
    end
end

function RacePanel:comma_value(amount)
    local formatted = amount
    while true do
      formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1 %2')
      if (k==0) then
        break
      end
    end
    return formatted
end

function RacePanel:getVehicleImg(model)
    local model = tonumber(model)
    for i, v in pairs(categoryA) do
        if i == model then
            return "files/images/motorcycle.png"
        end
    end
    for i, v in pairs(categoryB) do
        if i == model then
            return "files/images/car.png"
        end
    end
    for i, v in pairs(categoryC) do
        if i == model then
            return "files/images/truck.png"
        end
    end
    return false
end

function RacePanel:getVehicleName(model)
    if model == 471 then return "Snowmobile" end
    if model == 604 then return "Christmas Manana" end
    return getVehicleNameFromID(model)
end



function openRacePanel()
    if guiInfo.panel then return end
    guiInfo.panel = RacePanel:create()
end

function closeRacePanelByTrackCreator(...)
    if not guiInfo.panel then return end

    exports.TR_dx:hideLoading()
    exports.TR_dx:setResponseEnabled(false)

    guiInfo.panel:close(...)
end

function onRaceResponsePanel(...)
    if not guiInfo.panel then return end
    guiInfo.panel:response(...)
end
addEvent("onRaceResponsePanel", true)
addEventHandler("onRaceResponsePanel", root, onRaceResponsePanel)


function onRaceMarkerHit(plr, md)
    if plr ~= localPlayer or not md then return end
    if not exports.TR_dx:canOpenGUI() then return end
    openRacePanel()
end

function createRaceMarkers()
    for i, v in pairs(RaceData.markerPos) do
        local blip = createBlip(v, 0, 2, 200, 200, 200, 0)
        setElementData(blip, "icon", 49, false)

        local marker = createMarker(v - Vector3(0, 0, 0.9), "cylinder", 1.2, 200, 200, 200, 0)
        setElementData(marker, "markerIcon", "race", false)
        setElementData(marker, "markerData", {
            title = "Wyścigi pojazdów",
            desc = "Wejdź w marker aby rozpocząć wyścig lub utworzyć własną trasę.",
        }, false)

        addEventHandler("onClientMarkerHit", marker, onRaceMarkerHit)
    end
end
createRaceMarkers()