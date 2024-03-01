local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 700/zoom)/2,
    y = sy - 829/zoom,
    w = 700/zoom,
    h = 829/zoom,

    plus = {
        x = 420/zoom,
        y = 602/zoom,
        w = 65/zoom,
        h = 45/zoom,
    },
    minus = {
        x = 212/zoom,
        y = 602/zoom,
        w = 65/zoom,
        h = 45/zoom,
    },
    start = {
        x = 300/zoom,
        y = 600/zoom,
        w = 100/zoom,
        h = 60/zoom,
    },
    rolls = {
        x = 198/zoom,
        y = 237/zoom,
        w = 70/zoom,
        h = 183/zoom,
        space = 114/zoom,
        -- 61 one img height
        -- 549 oryginal height
    },

    minBet = 100,
    maxBet = 10000,
    changeBet = 100,

    gamesPlayed = 0,
    gamesToFeature = math.random(5, 8),

    iconOrder = {"bell", "seven", "cherry", "cash", "seven", "lemon", "plums", "seven", "cherry"},
    iconLegend = {
        {
            name = "Yedi",
            multiplayer = 10,
        },
        {
            name = "Para",
            multiplayer = 6,
        },
        {
            name = "Zil",
            multiplayer = 5,
        },
        {
            name = "Limon",
            multiplayer = 4,
        },
        {
            name = "Erik",
            multiplayer = 3,
        },
        {
            name = "Kiraz",
            multiplayer = 2,
        },
    },
}

SlotMachine = {}
SlotMachine.__index = SlotMachine

function SlotMachine:create()
    local instance = {}
    setmetatable(instance, SlotMachine)
    if instance:constructor() then
        return instance
    end
    return false
end

function SlotMachine:constructor()
    self.rolls = {
        {
            y = 0,
            symbol = 0,
        },
        {
            y = 0,
            symbol = 0,
        },
        {
            y = 0,
            symbol = 0,
        },
    }

    self.screenText = "Oyuna başlamak için START'a basın."
    self.playBet = guiInfo.minBet

    self.fonts = {}
    self.fonts.legend = exports.TR_dx:getFont(20)
    self.fonts.multiplayer = exports.TR_dx:getFont(12)
    self.fonts.screen = exports.TR_dx:getFont(12, "myriadLight")
    self.fonts.bet = exports.TR_dx:getFont(11, "myriadLight")

    self.func = {}
    self.func.render = function() self:render() end
    self.func.onClick = function(...) self:onClick(...) end
    self.func.submitGame = function() self:submitGame() end
    self.func.updateData = function() self:updateData() end

    self:open()
    exports.TR_dx:setOpenGUI(true)
    guiInfo.betIcon = dxGetTextWidth("Bahis: "..self.playBet, 1/zoom, self.fonts.bet)/2
    return true
end

function SlotMachine:updateData()
    local symbol = math.random(1, #guiInfo.iconOrder)
    local symbol2 = self:getOtherIndexSymbol(guiInfo.iconOrder[symbol])
    local symbol3 = self:getOtherIndexSymbol(guiInfo.iconOrder[symbol2])

    symbol = symbol - 2
    symbol2 = symbol2 - 2
    symbol3 = symbol3 - 2
    self.rolls = {
        {
            y = (symbol + (1 * 9)) * 61,
            lastY = (symbol + (1 * 9)) * 61,
            symbol = symbol,
            spins = 0,
        },
        {
            y = (symbol2 + (6 * 9)) * 61,
            lastY = (symbol2 + (6 * 9)) * 61,
            symbol = symbol2, --math.min(symbolIndex + 1, #guiInfo.iconOrder),
            spins = 0 + 1,
        },
        {
            y = (symbol3 + (7 * 9)) * 61,
            lastY = (symbol3 + (7 * 9)) * 61,
            symbol = symbol3, --math.max(symbolIndex - 1, 1),
            spins = 0 + 2,
        },
    }
end

function SlotMachine:destroy()
    exports.TR_dx:setOpenGUI(false)
    removeEventHandler("onClientRender", root, self.func.render)

    guiInfo.machine = nil
    self = nil
end

function SlotMachine:open()
    self.alpha = 0
    self.state = "opening"
    self.tick = getTickCount()

    showCursor(true)
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientClick", root, self.func.onClick)
end

function SlotMachine:close()
    self.alpha = 1
    self.state = "closing"
    self.tick = getTickCount()

    showCursor(false)
    removeEventHandler("onClientClick", root, self.func.onClick)
end


function SlotMachine:animate()
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

function SlotMachine:render()
    if self:animate() then return end
    dxDrawRectangle(0, 0, sx, sy, tocolor(7, 7, 7, 100 * self.alpha))

    -- Machine
    dxDrawImage(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, "files/images/bg.png", 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))

    -- Screen
    dxDrawText(self.screenText, guiInfo.x + 162/zoom, guiInfo.y + 470/zoom, guiInfo.x + guiInfo.w - 168/zoom, guiInfo.y + 500/zoom, tocolor(150, 150, 150, 255 * self.alpha), 1/zoom, self.fonts.screen, "center", "top")
    dxDrawText("Bahis: "..self.playBet, guiInfo.x + 162/zoom, guiInfo.y + 495/zoom, guiInfo.x + guiInfo.w - 168/zoom, guiInfo.y + 500/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.bet, "center", "top")

    dxDrawImage(guiInfo.x + 350/zoom + guiInfo.betIcon, guiInfo.y + 497/zoom, 16/zoom, 16/zoom, "files/images/chip.png", 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))

    self:drawButtons()
    self:drawRolls()
    self:drawLegend()
    dxDrawLine(guiInfo.x + 162/zoom, guiInfo.y + 330/zoom, guiInfo.x + guiInfo.w - 168/zoom, guiInfo.y + 330/zoom, tocolor(255, 0, 0, 255 * self.alpha), 2)

    if self:isMouseInPosition(guiInfo.x + 350/zoom - 32/zoom, sy - 84/zoom, 64/zoom, 64/zoom) then
        dxDrawImage(guiInfo.x + 350/zoom - 32/zoom, sy - 84/zoom, 64/zoom, 64/zoom, "files/images/close.png", 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
    else
        dxDrawImage(guiInfo.x + 350/zoom - 32/zoom, sy - 84/zoom, 64/zoom, 64/zoom, "files/images/close.png", 0, 0, 0, tocolor(255, 255, 255, 200 * self.alpha))
    end
end

function SlotMachine:drawLegend()
    dxDrawImage(10/zoom, sy - 417/zoom, 70/zoom, 366/zoom, "files/images/prizes.png", 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
    dxDrawText("Sembollerin efsanesi:", 20/zoom, sy - 412/zoom, guiInfo.x + guiInfo.w - 168/zoom, sy - 427/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.legend, "left", "bottom")

    for i, v in pairs(guiInfo.iconLegend) do
        dxDrawText(v.name, 90/zoom, sy - 412/zoom + 61/zoom * (i-1), guiInfo.x + guiInfo.w - 168/zoom, sy - 417/zoom + 61/zoom * i, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.legend, "left", "top")
        dxDrawText("Çarpan: x"..v.multiplayer, 90/zoom, sy - 417/zoom + 61/zoom * (i-1), guiInfo.x + guiInfo.w - 168/zoom, sy - 422/zoom + 61/zoom * i, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.multiplayer, "left", "bottom")
    end
end

function SlotMachine:drawButtons()
    if self:isMouseInPosition(guiInfo.x + guiInfo.start.x, guiInfo.y + guiInfo.start.y, guiInfo.start.w, guiInfo.start.h) and not self.playing then
        dxDrawImage(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, "files/images/start.png", 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
    else
        dxDrawImage(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, "files/images/start.png", 0, 0, 0, tocolor(255, 255, 255, 200 * self.alpha))
    end

    if self:isMouseInPosition(guiInfo.x + guiInfo.plus.x, guiInfo.y + guiInfo.plus.y, guiInfo.plus.w, guiInfo.plus.h) and not self.playing then
        dxDrawImage(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, "files/images/plus.png", 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
    else
        dxDrawImage(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, "files/images/plus.png", 0, 0, 0, tocolor(255, 255, 255, 200 * self.alpha))
    end

    if self:isMouseInPosition(guiInfo.x + guiInfo.minus.x, guiInfo.y + guiInfo.minus.y, guiInfo.minus.w, guiInfo.minus.h) and not self.playing then
        dxDrawImage(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, "files/images/minus.png", 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
    else
        dxDrawImage(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, "files/images/minus.png", 0, 0, 0, tocolor(255, 255, 255, 200 * self.alpha))
    end
end

function SlotMachine:drawRolls()
    for i = 0, 2 do
        local v = self.rolls[i+1]
        if v.tick then
            local progress = (getTickCount() - v.tick)/v.time
            v.y = interpolateBetween(v.lastY, 0, 0, (v.symbol + (v.spins * 9)) * 61, 0, 0, progress, "OutQuad")

        end
        dxDrawImageSection(guiInfo.x + guiInfo.rolls.x + guiInfo.rolls.space * i, guiInfo.y + guiInfo.rolls.y, guiInfo.rolls.w, guiInfo.rolls.h, 0, v.y, 70, 183, "files/images/roll.png", 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
    end
end

function SlotMachine:onClick(...)
    if arg[1] ~= "left" or arg[2] ~= "down" or self.playing then return end

    if self:isMouseInPosition(guiInfo.x + guiInfo.start.x, guiInfo.y + guiInfo.start.y, guiInfo.start.w, guiInfo.start.h) then
        local chips = exports.TR_hud:getCasinoCount() or 0
        if chips < self.playBet then exports.TR_noti:create("Yeterli miktarda jetonunuz yok. Bunları belirlenmiş bir yerden veya bir kurpiyeden veya barmenden satın alabilirsiniz.", "error", 8) return end

        self:startGame()
        exports.TR_hud:updateCasinoCount(chips - self.playBet)
        triggerServerEvent("takePlayerChips", resourceRoot, self.playBet)
    end

    if self:isMouseInPosition(guiInfo.x + guiInfo.plus.x, guiInfo.y + guiInfo.plus.y, guiInfo.plus.w, guiInfo.plus.h) then
        if self.playBet >= 1000 then
            self.playBet = math.min(self.playBet + 1000, guiInfo.maxBet)
        else
            self.playBet = math.min(self.playBet + guiInfo.changeBet, guiInfo.maxBet)
        end
        guiInfo.betIcon = dxGetTextWidth("Bahis: "..self.playBet, 1/zoom, self.fonts.bet)/2
    end

    if self:isMouseInPosition(guiInfo.x + guiInfo.minus.x, guiInfo.y + guiInfo.minus.y, guiInfo.minus.w, guiInfo.minus.h) then
        if self.playBet > 1000 then
            self.playBet = math.max(self.playBet - 1000, guiInfo.minBet)
        else
            self.playBet = math.max(self.playBet - guiInfo.changeBet, guiInfo.minBet)
        end
        guiInfo.betIcon = dxGetTextWidth("Bahis: "..self.playBet, 1/zoom, self.fonts.bet)/2
    end

    if self:isMouseInPosition(guiInfo.x + 350/zoom - 32/zoom, sy - 84/zoom, 64/zoom, 64/zoom) then
        self:close()
    end
end

function SlotMachine:startGame()
    local spins = math.random(4, 8)

    if math.random(1, 100) > 15 then
        local symbol = math.random(1, #guiInfo.iconOrder)
        local symbol2 = self:getOtherIndexSymbol(guiInfo.iconOrder[symbol])
        local symbol3 = self:getOtherIndexSymbol(guiInfo.iconOrder[symbol2])

        symbol = symbol - 2
        symbol2 = symbol2 - 2
        symbol3 = symbol3 - 2

        self.rolls = {
            {
                y = self.rolls[1].symbol * 61,
                lastY = self.rolls[1].symbol * 61,
                symbol = symbol,
                spins = spins,
                time = spins * 1000,
                tick = getTickCount(),
            },
            {
                y = self.rolls[2].symbol * 61,
                lastY = self.rolls[2].symbol * 61,
                symbol = symbol2, --math.min(symbolIndex + 1, #guiInfo.iconOrder),
                spins = spins + 1,
                time = (spins + 1) * 1000,
                tick = getTickCount(),
            },
            {
                y = self.rolls[3].symbol * 61,
                lastY = self.rolls[3].symbol * 61,
                symbol = symbol3, --math.max(symbolIndex - 1, 1),
                spins = spins + 2,
                time = (spins + 2) * 1000,
                tick = getTickCount(),
            },
        }

        setTimer(self.func.submitGame, (spins + 2) * 1000, 1)
    else
        local symbolIndex, toWin = self:getIndexWinSymbol()
        self.toWin = toWin
        self.rolls = {
            {
                y = self.rolls[1].symbol * 61,
                lastY = self.rolls[1].symbol * 61,
                symbol = symbolIndex,
                spins = spins,
                time = spins * 1000,
                tick = getTickCount(),
            },
            {
                y = self.rolls[2].symbol * 61,
                lastY = self.rolls[2].symbol * 61,
                symbol = symbolIndex,
                spins = spins + 1,
                time = (spins + 1) * 1000,
                tick = getTickCount(),
            },
            {
                y = self.rolls[3].symbol * 61,
                lastY = self.rolls[3].symbol * 61,
                symbol = symbolIndex,
                spins = spins + 2,
                time = (spins + 2) * 1000,
                tick = getTickCount(),
            },
        }

        setTimer(self.func.submitGame, (spins + 2) * 1000, 1)
    end

    self.playing = true
    self.screenText = "Çekiliş devam ediyor..."
    self.machineSound = playSound("files/sounds/machine.mp3", true)
    setSoundVolume(self.machineSound, 0.6)

    guiInfo.gamesPlayed = guiInfo.gamesPlayed + 1
    if guiInfo.gamesPlayed >= guiInfo.gamesToFeature then
        guiInfo.gamesPlayed = 0
        guiInfo.gamesToFeature = math.random(3, 8)
        exports.TR_features:updateState("casino", 2)
    end
end

function SlotMachine:submitGame(symbol)
    if self.rolls[1].symbol == self.rolls[2].symbol and self.rolls[1].symbol == self.rolls[3].symbol then
        local sound = playSound("files/sounds/win.ogg")
        setSoundVolume(sound, 0.6)

        local sound = playSound("files/sounds/coins.ogg")
        setSoundVolume(sound, 0.6)

        self.screenText = string.format("KAZANDIN! %d jeton kazandınız!", self.toWin)

        local chips = exports.TR_hud:getCasinoCount() or 0
        exports.TR_hud:updateCasinoCount(chips + self.toWin)
        triggerServerEvent("givePlayerChips", resourceRoot, self.toWin, self.playBet)
    else
        local sound = playSound("files/sounds/lose.ogg")
        setSoundVolume(sound, 0.6)

        self.screenText = "Üzgünüm, kazanamadınız. Lütfen tekrar deneyin."
    end
    if isElement(self.machineSound) then destroyElement(self.machineSound) end
    self.playing = nil
end

function SlotMachine:getIndexWinSymbol()
    local random = math.random(1, 10000)
    if random == 1 then
        return self:getIndexSymbol("seven"), self.playBet * 10
    elseif random <= 101 then
        return self:getIndexSymbol("cash"), self.playBet * 6
    elseif random <= 301 then
        return self:getIndexSymbol("bell"), self.playBet * 5
    elseif random <= 601 then
        return self:getIndexSymbol("lemon"), self.playBet * 4
    elseif random <= 1001 then
        return self:getIndexSymbol("plums"), self.playBet * 3
    else
        return self:getIndexSymbol("cherry"), self.playBet * 2
    end
end


function SlotMachine:getIndexSymbol(symbol)
    local symbols = {}
    for i, v in pairs(guiInfo.iconOrder) do
        if v == symbol then table.insert(symbols, i) end
    end
    return symbols[math.random(1, #symbols)] - 2
end

function SlotMachine:getOtherIndexSymbol(symbol)
    local numIndex = math.random(1, #guiInfo.iconOrder)
    while (symbol == guiInfo.iconOrder[numIndex]) do
        numIndex = math.random(1, #guiInfo.iconOrder)
    end
    return numIndex
end


function SlotMachine:isMouseInPosition(x, y, width, height)
    if (not isCursorShowing()) then return false end
    local cx, cy = getCursorPosition()
    local cx, cy = (cx*sx), (cy*sy)
    if (cx >= x and cx <= x + width) and (cy >= y and cy <= y + height) then return true end
    return false
end




function openSlotMachine()
    if guiInfo.machine then return end
    if not exports.TR_dx:canOpenGUI() then return end

    guiInfo.machine = SlotMachine:create()
end

function onSlotMarkerEnter(el, md)
    if el ~= localPlayer or not md then return end
    if getElementInterior(source) ~= getElementInterior(el) then return end

    openSlotMachine()
end

-- Slot machine create
function createSlotMachines()
    for i, v in pairs(SlotMachines) do
        local marker = createMarker(v.pos - Vector3(0, 0, 1), "cylinder", 1, 255, 191, 23, 0)
        if v.int then setElementInterior(marker, v.int) end
        if v.dim then setElementDimension(marker, v.dim) end

        setElementData(marker, "markerIcon", "slotMachine", false)
        setElementData(marker, "markerData", {
            title = "Tek kollu haydut",
            desc = "Oyuna başlamak için marker'a girin.",
        }, false)

        addEventHandler("onClientMarkerHit", marker, onSlotMarkerEnter)
    end
end
createSlotMachines()

-- exports.TR_dx:setOpenGUI(false)
-- openSlotMachine()

-- function test()
--     local symbolIndex = math.random(1, #guiInfo.iconOrder)
--     local symbol = guiInfo.iconOrder[symbolIndex]
--     local symbol2 = getOtherIndexSymbol(symbol)
--     local symbol3 = getOtherIndexSymbol(guiInfo.iconOrder[symbol2])


--     if symbol == guiInfo.iconOrder[symbol2] and symbol == guiInfo.iconOrder[symbol3] then
--         print("Takie same: ", symbol)
--     end
-- end

-- function getOtherIndexSymbol(symbol)
--     local numIndex = math.random(1, #guiInfo.iconOrder)
--     while (symbol == guiInfo.iconOrder[numIndex]) do
--         numIndex = math.random(1, #guiInfo.iconOrder)
--     end
--     return numIndex
-- end

-- setTimer(test, 100, 0)