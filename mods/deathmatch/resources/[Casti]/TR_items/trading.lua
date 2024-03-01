local sx, sy = guiGetScreenSize()

local guiData = {
    x = (sx - 650/zoom)/2,
    y = (sy - 500/zoom)/2,
    w = 650/zoom,
    h = 500/zoom,
}

Trading = {}
Trading.__index = Trading

function Trading:create()
    local instance = {}
    setmetatable(instance, Trading)
    if instance:constructor() then
        return instance
    end
    return false
end

function Trading:constructor()
    self.alpha = 0
    self.items = {}

    self.scrollLocal = 0
    self.scrollTarget = 0

    self.fonts = {}
    self.fonts.title = exports.TR_dx:getFont(13)
    self.fonts.items = exports.TR_dx:getFont(10)
    self.fonts.desc = exports.TR_dx:getFont(8)

    self.func = {}
    self.func.tryOpen = function() self:tryOpen() end
    self.func.checkTrade = function() self:checkTrade() end
    self.func.render = function() self:render() end
    self.func.button = function(...) self:buttonClick(...) end
    self.func.click = function(...) self:itemClick(...) end
    self.func.scroll = function(...) self:scrollList(...) end

    return true
end

function Trading:createTrade(plr)
    if not getElementData(localPlayer, "characterUID") then return end
    if isTimer(self.opener) then return end
    if self.opened then return end

    self.items = {}
    self.tradingData = {
        player = plr,
        playerName = getPlayerName(plr),
        state = "cancel",
    }

    if not GUI.eq:isOpened() and exports.TR_dx:canOpenGUI() then
        self:open()
        return
    end

    self.opener = setTimer(self.func.tryOpen, 100, 0)
    self.openerNoti = exports.TR_noti:create(string.format("%s oyuncusu ile ticaret başlatıldı. Takas işlemine devam etmek için diğer pencereleri kapatın.", self.tradingData.playerName), "trade", 0, true)
end

function Trading:cancelTrade(info)
    if info then exports.TR_noti:create(string.format("%s oyuncusu takası iptal etti.", self.tradingData.playerName), "error") end
    self:close()
end

function Trading:openTutorialTrade()
    self.items = {}
    self.tradingData = {
        tutorial = true,
        playerName = "Matthew the Carrier",
        state = "cancel",
    }


    self:open()
    showCursor(true)
end

function Trading:tryOpen()
    if GUI.eq:isOpened() then self:open() return end
    if not GUI.eq:isOpened() and not exports.TR_dx:canOpenGUI() then return end
    if not isElement(self.tradingData.player) then
        self:removeOpener("Oyuncu oyundan çıktı. Takas iptal edildi.")
        return
    end
    if getDistanceBetweenPoints3D(Vector3(getElementPosition(localPlayer)), Vector3(getElementPosition(self.tradingData.player))) > 3 then
        self:removeOpener("Oyuncu çok uzakta. Takas iptal edildi.")
        return
    end

    self:open()
end

function Trading:removeOpener(error)
    if isTimer(self.opener) then killTimer(self.opener) end
    if self.openerNoti then exports.TR_noti:destroy(self.openerNoti); self.openerNoti = nil end
    if error then exports.TR_noti:create(error, "error") end
end


function Trading:checkTrade()
    if not self.tradingData then self:close() return end
    if not self.tradingData.tutorial then
        if not isElement(self.tradingData.player) then self:close() return end
        if getDistanceBetweenPoints3D(Vector3(getElementPosition(localPlayer)), Vector3(getElementPosition(self.tradingData.player))) > 3 then self:close() return end
    end

    if not self.gui then return end
    if not self.gui.moneyEdit then return end

    local data = getElementData(localPlayer, "characterData")
    local text = guiGetText(self.gui.moneyEdit)

    local money = tonumber(string.format("%.2f", math.floor((tonumber(text) and tonumber(text) or 0) * 100)/100))
    local plrMoney = tonumber(data.money)

    if not plrMoney or not money then return end
    if plrMoney < money then return end
    self.money = money

    if self.tradingData.tutorial then return end
    triggerServerEvent("syncMoneyTrade", resourceRoot, self.tradingData.player, money)
end

function Trading:open()
    if self.opened then return end
    self.opened = true
    self.btnState = "cancel"
    self.money = nil

    self.checker = setTimer(self.func.checkTrade, 1000, 0)
    GUI.eq:open()
    GUI.eq:setTradeOpen(true)
    GUI.eq:setTradeBlock(false)
    GUI.eq:reselectItem()
    self:removeOpener()

    self.gui = {}
    self.gui.money = dxCreateTexture("files/images/money.png", "argb", true, "clamp")
    self.gui.moneyEdit = exports.TR_dx:createEdit(guiData.x + 10/zoom, guiData.y + guiData.h - 150/zoom, guiData.w/2 - 20/zoom, 40/zoom, "Para", false, self.gui.money)
    self.gui.acceptButton = exports.TR_dx:createButton(guiData.x + 10/zoom, guiData.y + guiData.h - 100/zoom, guiData.w/2 - 20/zoom, 40/zoom, "Onayla")
    self.gui.cancelButton = exports.TR_dx:createButton(guiData.x + 10/zoom, guiData.y + guiData.h - 50/zoom, guiData.w/2 - 20/zoom, 40/zoom, "İptal")

    exports.TR_dx:setButtonVisible({self.gui.acceptButton, self.gui.cancelButton}, false)
    exports.TR_dx:setEditVisible(self.gui.moneyEdit, false)
    exports.TR_dx:showButton({self.gui.acceptButton, self.gui.cancelButton})
    exports.TR_dx:showEdit(self.gui.moneyEdit)
    if self.tradingData.tutorial then exports.TR_dx:setEditLimit(self.gui.moneyEdit, 0) end


    self.alphaLast = self.alpha
    self.state = "opening"
    self.tick = getTickCount()
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("guiButtonClick", root, self.func.button)
    bindKey("mouse1", "down", self.func.click)
    bindKey("mouse_wheel_up", "down", self.func.scroll)
    bindKey("mouse_wheel_down", "down", self.func.scroll)
end

function Trading:close()
    if not self.opened then return end
    self.opened = nil
    GUI.eq:setTradeOpen(false)
    GUI.eq:reselectItem()

    self.alphaLast = self.alpha
    self.state = "closing"
    self.tick = getTickCount()

    if isTimer(self.checker) then killTimer(self.checker) end
    removeEventHandler("guiButtonClick", root, self.func.button)
    exports.TR_dx:hideEdit(self.gui.moneyEdit)
    exports.TR_dx:hideButton({self.gui.acceptButton, self.gui.cancelButton})

    setElementData(localPlayer, "blockAction", nil)
    unbindKey("mouse1", "down", self.func.click)
    unbindKey("mouse_wheel_up", "down", self.func.scroll)
    unbindKey("mouse_wheel_down", "down", self.func.scroll)
end

function Trading:clearData()
    self.tradingData = nil
    removeEventHandler("onClientRender", root, self.func.render)
    exports.TR_dx:destroyEdit(self.gui.moneyEdit)
    exports.TR_dx:destroyButton({self.gui.acceptButton, self.gui.cancelButton})
    destroyElement(self.gui.money)
end

function Trading:setTradeState(state)
    if state == "confirm" then
        self.tradingData.state = "confirm"
        self.btnState = "confirm"
        exports.TR_dx:setButtonText(self.gui.acceptButton, "Takas Onayla")
    else
        self.tradingData.state = state
    end
end

function Trading:addItem(plr, item)
    if not self.items[plr] then self.items[plr] = {} end

    local index = self:getItemIndex(plr, item.ID)
    if index then
        table.remove(self.items[plr], index)
        item.isTrade = nil
    else
        if #self.items[plr] >= 15 then exports.TR_noti:create("Tek bir takas için öğe sınırına ulaşıldı.", "error") return end
        table.insert(self.items[plr], item)
        item.isTrade = true
    end

    if plr == localPlayer then
        if not self.tradingData.tutorial then
            triggerServerEvent("syncItemTrade", resourceRoot, self.tradingData.player, self.items[localPlayer])
        end
        GUI.eq:reselectItem()
    end
end

function Trading:scrollList(btn)
    if btn == "mouse_wheel_up" then
        if self:isMouseInPosition(guiData.x, guiData.y, guiData.w/2, guiData.h) then
            self.scrollLocal = math.max(self.scrollLocal - 1, 0)

        elseif self:isMouseInPosition(guiData.x + guiData.w/2, guiData.y, guiData.w/2, guiData.h) then
            self.scrollTarget = math.max(self.scrollTarget - 1, 0)
        end

    elseif btn == "mouse_wheel_down" then
        if self:isMouseInPosition(guiData.x, guiData.y, guiData.w/2, guiData.h) then
            if not self.items[localPlayer] then return end
            if #self.items[localPlayer] <= 6 then return end
            self.scrollLocal = math.min(self.scrollLocal + 1, #self.items[localPlayer] - 6)

        elseif self:isMouseInPosition(guiData.x + guiData.w/2, guiData.y, guiData.w/2, guiData.h) then
            if not self.items[self.tradingData.player] then return end
            if #self.items[self.tradingData.player] <= 7 then return end
            self.scrollTarget = math.min(self.scrollTarget + 1, #self.items[self.tradingData.player] - 7)

        end
    end
end

function Trading:getItemIndex(plr, id)
    if not self.items[plr] then return false end
    for i, v in ipairs(self.items[plr]) do
        if v.ID == id then
            return i
        end
    end
    return false
end

function Trading:syncItemTrade(plr, items)
    self.items[plr] = {}
    if items then
        for _, item in pairs(items) do
            self:addItem(plr, item)
        end
    end
end

function Trading:syncMoneyTrade(amount)
    self.tradingData.money = amount
end

function Trading:buttonClick(btn)
    if GUI.eq.blockHover then return end
    if btn == self.gui.acceptButton then
        if self.slowButton then
            if (getTickCount() - self.slowButton)/3000 < 1 then
                exports.TR_noti:create("Takas durumunu 3 saniyede bir değiştirebilirsin.", "error")
                return
            end
        end

        if self.btnState == "cancel" then
            if self.tradingData.tutorial then
                if not self.items[localPlayer] then return end
                if #self.items[localPlayer] < 1 then return end
            end

            if not self.tradingData.tutorial then
                local text = guiGetText(self.gui.moneyEdit)
                self.money = string.format("%.2f", math.floor((tonumber(text) and tonumber(text) or 0) * 100)/100)
                if tonumber(self.money) < 0 then
                    exports.TR_noti:create("Miktar para yanlış.", "error")
                    return
                end
                exports.TR_dx:setEditText(self.gui.moneyEdit, self.money)
                local plrData = getElementData(localPlayer, "characterData")
                if tonumber(plrData.money) < tonumber(self.money) then
                    exports.TR_noti:create("Yeterince nakit paranız yok.", "error")
                    return
                end
            end

            if self.tradingData.state == "accept" then
                self.tradingData.state = "confirm"
                self.btnState = "confirm"
                exports.TR_dx:setButtonText(self.gui.acceptButton, "Takas Onayla")

            else
                self.btnState = "accept"
                exports.TR_dx:setButtonText(self.gui.acceptButton, "İptal")
            end
            GUI.eq:setTradeBlock(true)
            GUI.eq:reselectItem()
            guiSetEnabled(self.gui.moneyEdit, false)

            if self.tradingData.tutorial then
                setTimer(function()
                    self.tradingData.state = "confirm"
                    self.btnState = "confirm"
                    exports.TR_dx:setButtonText(self.gui.acceptButton, "Takas Onayla")

                end, 1000, 1)
                return
            end
            triggerServerEvent("syncMoneyTrade", resourceRoot, self.tradingData.player, self.money)

        elseif self.btnState == "accept" then
            if self.tradingData.tutorial then return end
            self.btnState = "cancel"
            exports.TR_dx:setButtonText(self.gui.acceptButton, "Onayla")

            GUI.eq:setTradeBlock(false)
            GUI.eq:reselectItem()
            guiSetEnabled(self.gui.moneyEdit, true)

        elseif self.btnState == "confirm" then
            self.btnState = "confirmed"
            exports.TR_dx:setButtonText(self.gui.acceptButton, "Takas Onaylandı")

            if self.tradingData.tutorial then
                self:close()
                GUI.eq:close()
                exports.TR_noti:create("Takas başarıyla tamamlandı.", "success")

                exports.TR_tutorial:setNextState(true)
                return
            end

            if self.tradingData.state == "confirmed" then
                triggerServerEvent("performTrade", resourceRoot, self.tradingData.player, self.items[localPlayer], self.items[self.tradingData.player], tonumber(self.money), tonumber(self.tradingData.money))
                self:close()
                return
            end

        elseif self.btnState == "confirmed" then
            return
        end
        triggerServerEvent("setTradeState", resourceRoot, self.tradingData.player, self.btnState)
        self.slowButton = getTickCount()

    elseif btn == self.gui.cancelButton then
        if self.tradingData.tutorial then return end
        triggerServerEvent("cancelTrade", resourceRoot, self.tradingData.player)
        self:cancelTrade()
    end
end





function Trading:animate()
    if not self.tick then return end
    local progress = (getTickCount() - self.tick)/500
    if self.state == "opening" then
        self.alpha = interpolateBetween(self.alphaLast, 0, 0, 1, 0, 0, progress, "Linear")
        if progress >= 1 then
            self.alpha = 1
            self.state = "opened"
            self.tick = nil
        end

    elseif self.state == "closing" then
        self.alpha = interpolateBetween(self.alphaLast, 0, 0, 0, 0, 0, progress, "Linear")
        if progress >= 1 then
            self.alpha = 0
            self.state = "closed"
            self.tick = nil
            self:clearData()
        end
    end
end
function Trading:render()
    self:animate()
    if not self.tradingData then return end
    self:drawBackground(guiData.x, guiData.y, guiData.w, guiData.h, tocolor(17, 17, 17, 255 * self.alpha), 5)
    dxDrawRectangle(guiData.x + guiData.w/2 - 1/zoom, guiData.y, 2/zoom, guiData.h, tocolor(27, 27, 27, 255 * self.alpha))
    
    dxDrawText("Teklifiniz:", guiData.x + 10/zoom, guiData.y, guiData.x + guiData.w - 10/zoom, guiData.y + 40/zoom, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.title, "left", "center")
    dxDrawText(string.format("%s tarafından yapılan teklif:", self.tradingData.playerName), guiData.x + guiData.w/2 + 10/zoom, guiData.y, guiData.x + guiData.w - 10/zoom, guiData.y + 40/zoom, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.title, "left", "center", true)
    
      -- Kabul durumu
      self:drawBackground(guiData.x + guiData.w/2 + 10/zoom, guiData.y + guiData.h - 50/zoom, guiData.w/2 - 20/zoom, 40/zoom, tocolor(37, 37, 37, 255 * self.alpha), 5)
      if self.tradingData.state == "accept" then
          dxDrawText("Kabul edildi", guiData.x + guiData.w/2, guiData.y + guiData.h - 50/zoom, guiData.x + guiData.w - 10/zoom, guiData.y + guiData.h - 10/zoom, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.title, "center", "center")
      elseif self.tradingData.state == "confirm" then
          dxDrawText("Onay bekleniyor", guiData.x + guiData.w/2, guiData.y + guiData.h - 50/zoom, guiData.x + guiData.w - 10/zoom, guiData.y + guiData.h - 10/zoom, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.title, "center", "center")
      elseif self.tradingData.state == "confirmed" then
          dxDrawText("Takas onaylandı", guiData.x + guiData.w/2, guiData.y + guiData.h - 50/zoom, guiData.x + guiData.w - 10/zoom, guiData.y + guiData.h - 10/zoom, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.title, "center", "center")
      else
          dxDrawText("Kabul edilmedi", guiData.x + guiData.w/2, guiData.y + guiData.h - 50/zoom, guiData.x + guiData.w - 10/zoom, guiData.y + guiData.h - 10/zoom, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.title, "center", "center")
      end
      -- Para durumu
      self:drawBackground(guiData.x + guiData.w/2 + 10/zoom, guiData.y + guiData.h - 100/zoom, guiData.w/2 - 20/zoom, 40/zoom, tocolor(37, 37, 37, 255 * self.alpha), 5)
      self:drawBackground(guiData.x + guiData.w/2 + 10/zoom, guiData.y + guiData.h - 100/zoom, 40/zoom, 40/zoom, tocolor(47, 47, 47, 255 * self.alpha), 5)
      dxDrawImage(guiData.x + guiData.w/2 + 20/zoom, guiData.y + guiData.h - 90/zoom, 20/zoom, 20/zoom, self.gui.money, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
        dxDrawText(string.format("%.2f", self.tradingData.money and self.tradingData.money or 0), guiData.x + guiData.w/2 + 60/zoom, guiData.y + guiData.h - 100/zoom, guiData.x + guiData.w - 10/zoom, guiData.y + guiData.h - 60/zoom, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.title, "left", "center")
    
      self:renderItems(localPlayer, guiData.x + 10/zoom, guiData.y + 30/zoom, self.scrollLocal, 6)
      self:renderItems(self.tradingData.player, guiData.x + guiData.w/2 + 10/zoom, guiData.y + 30/zoom, self.scrollTarget, 7)
    end

function Trading:renderItems(owner, x, y, scroll, render)
    if not self.items[owner] then
        dxDrawText("Oyuncu hiçbir öğe eklemedi.", x, y, x, guiData.y + guiData.h - 80/zoom, tocolor(150, 150, 150, 255 * self.alpha), 1/zoom, self.fonts.items, "left", "top")
    else
        y = y + 10/zoom
        for i = 1, render do
            local item = self.items[owner][i + scroll]
            if item then
                local alpha = 200
                if self:isMouseInPosition(x, y + 50/zoom * (i - 1), guiData.w/2 - 20/zoom, 40/zoom) then
                    GUI.eq:setHoveredItem(item, self.alpha)
                    alpha = 255
                end
                dxDrawImage(x, y + 50/zoom * (i - 1), 40/zoom, 40/zoom, item.icon, 0, 0, 0, tocolor(220, 220, 220, alpha * self.alpha))
                dxDrawText(item.name, x + 50/zoom, y - 3/zoom + 50/zoom * (i - 1), x + guiData.w/2 - 30/zoom, y + 5/zoom + 50/zoom * i, tocolor(220, 220, 220, alpha * self.alpha), 1/zoom, self.fonts.items, "left", "top", true)
                dxDrawText(item.description, x + 50/zoom, y + 12/zoom + 50/zoom * (i - 1), x + guiData.w/2 - 30/zoom, y + 5/zoom + 50/zoom * i, tocolor(150, 150, 150, alpha * self.alpha), 1/zoom, self.fonts.desc, "left", "top", true, true)
            end
        end

        local height = (50/zoom * render)
        if #self.items[owner] > render then
            local b1 = height / #self.items[owner]
            local barY = b1 * scroll
            local barHeight = b1 * render
            dxDrawRectangle(x + guiData.w/2 - 20/zoom, guiData.y + 40/zoom, 4/zoom, height, tocolor(37, 37, 37, 255 * self.alpha))
            dxDrawRectangle(x + guiData.w/2 - 20/zoom, guiData.y + 40/zoom + barY, 4/zoom, barHeight, tocolor(57, 57, 57, 255 * self.alpha))
        else
            dxDrawRectangle(x + guiData.w/2 - 20/zoom, guiData.y + 40/zoom, 4/zoom, height, tocolor(57, 57, 57, 255 * self.alpha))
        end
    end
end



function Trading:itemClick(...)
    self:findItemClick(localPlayer, guiData.x + 10/zoom, guiData.y + 30/zoom)
    self:findItemClick(self.tradingData.player, guiData.x + guiData.w/2 + 10/zoom, guiData.y + 30/zoom)
end

function Trading:findItemClick(owner, x, y)
    if GUI.eq.blockHover or not owner or not self.items[owner] then return end
    y = y + 10/zoom
    for i = 1, 6 do
        local item = self.items[owner][i]
        if self:isMouseInPosition(x, y + 50/zoom * (i - 1), guiData.w/2 - 20/zoom, 40/zoom) and item then
            GUI.eq:setItemPreviev(item)
            break
        end
    end
end


function Trading:drawBackground(x, y, rx, ry, color, radius, post)
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

function Trading:isMouseInPosition(x, y, width, height)
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


GUI.trade = Trading:create()
function createTrade(plr)
    GUI.trade:createTrade(plr)
end
addEvent("createTrade", true)
addEventHandler("createTrade", root, createTrade)

function closeTrade(plr)
    GUI.trade:close()
end
addEvent("closeTrade", true)
addEventHandler("closeTrade", root, closeTrade)

function cancelTrade(info)
    GUI.trade:cancelTrade(info)
end
addEvent("cancelTrade", true)
addEventHandler("cancelTrade", root, cancelTrade)


function syncItemTrade(plr, items)
    GUI.trade:syncItemTrade(plr, items)
end
addEvent("syncItemTrade", true)
addEventHandler("syncItemTrade", root, syncItemTrade)

function syncMoneyTrade(amount)
    GUI.trade:syncMoneyTrade(amount)
end
addEvent("syncMoneyTrade", true)
addEventHandler("syncMoneyTrade", root, syncMoneyTrade)


function setTradeState(state)
    GUI.trade:setTradeState(state)
end
addEvent("setTradeState", true)
addEventHandler("setTradeState", root, setTradeState)

function openTutorialTrade()
    GUI.trade:openTutorialTrade()
end
setElementData(localPlayer, "blockAction", nil)