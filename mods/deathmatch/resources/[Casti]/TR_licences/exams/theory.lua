local sx, sy = guiGetScreenSize()

local guiInfo = {
    x = (sx - 700/zoom)/2,
    y = (sy - 400/zoom)/2,
    w = 700,
    h = 400,

    timeToAnswer = 30,
}

LicenceTheory = {}
LicenceTheory.__index = LicenceTheory

function LicenceTheory:create(...)
    local instance = {}
    setmetatable(instance, LicenceTheory)
    if instance:constructor(...) then
        return instance
    end
end

function LicenceTheory:constructor(...)
    self.alpha = 0
    self.tick = getTickCount()

    self.licence = arg[1]

    self.buttons = {}
    self.checks = {}

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.title = exports.TR_dx:getFont(13)
    self.fonts.text = exports.TR_dx:getFont(12)
    self.fonts.time = exports.TR_dx:getFont(10)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.clickButton = function(...) self:clickButton(...) end

    self:randomizeQuestions()
    self:open()
    return true
end

function LicenceTheory:open()
    self.state = "opening"
    self.tick = getTickCount()

    exports.TR_dx:setOpenGUI(true)

    self.buttons.start = exports.TR_dx:createButton((sx - 250/zoom)/2, guiInfo.y + guiInfo.h - 50/zoom, 250/zoom, 40/zoom, "Sınavı başlat")
    exports.TR_dx:setButtonVisible(self.buttons.start, false)
    exports.TR_dx:showButton(self.buttons.start)

    showCursor(true)
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("guiButtonClick", root, self.func.clickButton)
end

function LicenceTheory:close()
    self.state = "closing"
    self.tick = getTickCount()

    exports.TR_dx:hideButton(self.buttons.close)

    showCursor(false)
    removeEventHandler("guiButtonClick", root, self.func.clickButton)
end

function LicenceTheory:destroy()
    exports.TR_dx:setOpenGUI(false)
    removeEventHandler("onClientRender", root, self.func.render)

    exports.TR_dx:destroyButton(self.buttons.close)

    guiInfo.licence = nil

    self = nil
end


function LicenceTheory:animate()
    if not self.tick then return end
    local progress = (getTickCount() - self.tick)/500

    if self.state == "opening" then
      self.alpha = interpolateBetween(self.alpha, 0, 0, 1, 0, 0, progress, "Linear")
      if progress >= 1 then
        self.alpha = 1
        self.state = "opened"
        self.tick = nil
      end

    elseif self.state == "closing" then
      self.alpha = interpolateBetween(self.alpha, 0, 0, 0, 0, 0, progress, "Linear")
      if progress >= 1 then
        self.alpha = 0
        self.state = "closed"
        self.tick = nil

        self:destroy()
        return true
      end
    end
end

function LicenceTheory:render()
    self:animate()
    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 4)
    dxDrawText("Teori sınavı", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")

    if self.selectedQuestion then
        -- dxDrawText(string.format("Pozostały czas: %ds", guiInfo.timeToAnswer - (getTickCount() - self.questionTime)/1000), guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + guiInfo.h - 55/zoom, tocolor(120, 120, 120, 255 * self.alpha), 1/zoom, self.fonts.time, "center", "bottom")
        dxDrawText(self.selectedQuestion.question, guiInfo.x + 10/zoom, guiInfo.y + 50/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h - 50/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.title, "center", "top", true, true)

        dxDrawText("Olası cevaplar:", guiInfo.x + 25/zoom, guiInfo.y + 50/zoom, guiInfo.x + guiInfo.w - 10/zoom, self.answerY - 5/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.title, "left", "bottom", true, true)

        -- if guiInfo.timeToAnswer - (getTickCount() - self.questionTime)/1000 <= 0 then
        --     self:timeEnd()
        -- end

    elseif self.ended then
        dxDrawText("SINAV SONUÇLARI", guiInfo.x + 10/zoom, guiInfo.y + 160/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h - 50/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.title, "center", "top", true, true)
        local color = self.result and {67, 166, 31} or {166, 31, 31}
        dxDrawText(string.format(self.result and "Pozitif (%d/%d)" or "Olumsuz (%d/%d)", self.questionsGood, self.questionsCount), guiInfo.x + 10/zoom, guiInfo.y + 190/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h - 50/zoom, tocolor(color[1], color[2], color[3], 255 * self.alpha), 1/zoom, self.fonts.text, "center", "top", true, true)

    else
        dxDrawText("SINAV NASIL GÖRÜNÜYOR", guiInfo.x + 10/zoom, guiInfo.y + 80/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h - 50/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.title, "center", "top", true, true)
        dxDrawText("Teorik sınav, mevcut yanıtlar arasından doğru ve yasal olan bir tanımın seçilmesini içerir..", guiInfo.x + 10/zoom, guiInfo.y + 110/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h - 50/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.text, "center", "top", true, true)

        dxDrawText("SINAV SORULARI", guiInfo.x + 10/zoom, guiInfo.y + 210/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h - 50/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.title, "center", "top", true, true)
        dxDrawText(string.format("Sınav %d sorudan oluşuyor.\nGeçerli bir sonuç almak için %d soruyu doğru yanıtlamalısınız.", self.questionsCount, self.questionsNeeded), guiInfo.x + 10/zoom, guiInfo.y + 240/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h - 50/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.text, "center", "top", true, true)
    end
end


function LicenceTheory:randomizeQuestions()
    self.questions = table.clone(licences[self.licence].theoryQuestions)

    local shuffled = {}
    for i, v in ipairs(self.questions) do
        local pos = math.random(1, #shuffled+1)
        table.insert(shuffled, pos, v)
    end

    self.questions = shuffled
    self.questionsCount = #self.questions
    self.questionsNeeded = math.ceil(self.questionsCount - self.questionsCount/3)
    self.questionsGood = 0
end

function LicenceTheory:createNextQuestion()
    if #self.questions < 1 then
        exports.TR_dx:destroyCheck(self.checks)
        self.checks = {}

        self.ended = true
        self.result = self.questionsNeeded <= self.questionsGood and true or false
        self.selectedQuestion = nil

        exports.TR_dx:destroyButton(self.buttons.next)
        self.buttons.close = exports.TR_dx:createButton((sx - 250/zoom)/2, guiInfo.y + guiInfo.h - 50/zoom, 250/zoom, 40/zoom, "Pencereyi kapat")

        if self.result then
            triggerServerEvent("playerPassedTheory", resourceRoot, self.licence)
        end
    else
        self.selectedQuestion = self.questions[1]
        if not self.selectedQuestion then return end

        exports.TR_dx:destroyCheck(self.checks)
        self.checks = {}

        table.remove(self.questions, 1)

        self.questionTime = getTickCount()

        self.answerY = guiInfo.y + guiInfo.h - 80/zoom - #self.selectedQuestion.answers * 30/zoom
        for i, v in pairs(self.selectedQuestion.answers) do
            local check = exports.TR_dx:createCheck(guiInfo.x + 20/zoom, self.answerY + (i-1) * 30/zoom, 30/zoom, 30/zoom, false, v[1])
            table.insert(self.checks, check)
        end

        exports.TR_dx:setCheckGroup(self.checks)
    end
end

function LicenceTheory:timeEnd()
    self:createNextQuestion()
end



function LicenceTheory:clickButton(...)
    if arg[1] == self.buttons.start then
        exports.TR_dx:destroyButton(self.buttons.start)
        self:createNextQuestion()

        self.buttons.next = exports.TR_dx:createButton((sx - 250/zoom)/2, guiInfo.y + guiInfo.h - 50/zoom, 250/zoom, 40/zoom, "Sonraki soru")
        boughtExams.theory[self.licence] = nil

    elseif arg[1] == self.buttons.next then
        for i, v in pairs(self.checks) do
            if exports.TR_dx:isCheckSelected(v) then
                local isGood = false
                for k, info in pairs(self.selectedQuestion.answers) do
                    if i == k and info[2] then
                        isGood = true
                        break
                    end
                end

                self.questionsGood = isGood and self.questionsGood + 1 or self.questionsGood
                self:createNextQuestion()
                return
            end
        end
        exports.TR_noti:create("Bir sonraki soruya geçmek için cevaplardan birini seçmelisiniz.", "error")

    elseif arg[1] == self.buttons.close then
        self:close()
    end
end

function LicenceTheory:drawBackground(x, y, rx, ry, color, radius, post)
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


function table.clone(org)
    return {unpack(org)}
end



function openLicenceTheory(plr, md)
    if not md then return end
    if plr ~= localPlayer then return end

    if not exports.TR_dx:canOpenGUI() then return end
    if guiInfo.licence then return end

    local licence = getElementData(source, "licence")
    if not boughtExams["theory"][licence] then exports.TR_noti:create("Bu sınava başlamak için öncelikle masada ödeme yapmanız gerekmektedir..", "error") return end
    guiInfo.licence = LicenceTheory:create(licence)
end

function startLicenceTheory(state, licence)
    exports.TR_dx:setResponseEnabled(false)

    if state and not guiInfo.licence then
        guiInfo.licence = LicenceTheory:create(licence)
    end
end
addEvent("startLicenceTheory", true)
addEventHandler("startLicenceTheory", root, startLicenceTheory)

function createLicenceTheoryPositions()
    for licence, k in pairs(licences) do
        if k.theoryPositions then
            for _, v in pairs(k.theoryPositions) do
                local marker = createMarker(v.pos.x, v.pos.y, v.pos.z - 0.9, "cylinder", 0.6, 152, 22, 222, 0)
                setElementInterior(marker, v.int)
                setElementDimension(marker, v.dim)
                setElementData(marker, "licence", licence, false)
                setElementData(marker, "markerIcon", "licenceTheory", false)
                setElementData(marker, "markerData", {
                    title = "Egzamin teoretyczny",
                    desc = string.format("Kategori sınavının başlangıcı %s.", string.upper(licence)),
                }, false)
                addEventHandler("onClientMarkerHit", marker, openLicenceTheory)
            end
        end
    end
end
createLicenceTheoryPositions()



-- startLicenceTheory(true, "LAPL")