local sx, sy = guiGetScreenSize()

local guiInfo = {
    x = (sx - 600/zoom)/2,
    y = (sy - 435/zoom)/2,
    w = 600/zoom,
    h = 435/zoom,
}

Panel = {}
Panel.__index = Panel

function Panel:create(...)
    local instance = {}
    setmetatable(instance, Panel)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function Panel:constructor(...)
    self.alpha = 0

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.info = exports.TR_dx:getFont(12)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.handleClick = function(...) self:handleClick(...) end
    self.func.declineTaxiRequest = function(...) self:declineTaxiRequest(...) end

    self.declineOrder = exports.TR_dx:createButton((sx - 250/zoom)/2, guiInfo.y + guiInfo.h - 50/zoom, 250/zoom, 40/zoom, "Geçerli işi iptal et", "red")
    exports.TR_dx:setButtonVisible(self.declineOrder, false)
    exports.TR_dx:showButton(self.declineOrder)

    exports.TR_dx:setResponseEnabled(true)
    triggerServerEvent("getTaxiPanel", resourceRoot)

    self:createList(arg[1])
    self:open()
    return true
end

function Panel:createList(...)
    self.requests = {}

    if arg[1] then
        local plrPos = Vector3(getElementPosition(localPlayer))

        for i, v in pairs(arg[1]) do
            table.insert(self.requests, {
                pos = v,
                dist = getDistanceBetweenPoints3D(plrPos, v[1], v[2], v[3]),
                destination = getZoneName(v[1], v[2], v[3]),
                playerName = getPlayerName(i),
                player = i,
            })
        end

        table.sort(self.requests, function(a, b)
            if a.dist > b.dist then return true end
            return false
        end)
    end

    if arg[2] == "take" then
        local pos = self.selectData.pos
        exports.TR_hud:findBestWay(pos[1], pos[2], true)
        exports.TR_noti:create(string.format("Başvuru kabul edildi.\nLokasyon: %s", self.selectData.destination), "success", 6)
        exports.TR_jobs:createInformation("Taxi Sürücüsü", string.format("%s oyuncusunu almak için %s'e gidin.", self.selectData.destination, self.selectData.playerName))

        if isTimer(guiInfo.blipTimer) then killTimer(guiInfo.blipTimer) end
        if isElement(guiInfo.blip) then destroyElement(guiInfo.blip) end

        guiInfo.blip = createBlip(pos[1], pos[2], pos[3], 0, 2, 255, 0, 0, 0)
        setElementData(guiInfo.blip, "icon", 22, false)
        guiInfo.blipTimer = setTimer(updateBlipPos, 1000, 0)
        guiInfo.client = self.selectData.player
        guiInfo.clientName = self.selectData.playerName


    elseif arg[2] == "taken" then
        exports.TR_noti:create("Bu istek zaten başka bir taksi şoförü tarafından kabul edildi.", "error")
    end

    exports.TR_dx:setResponseEnabled(false)
end


function Panel:open()
    self.state = "opening"
    self.tick = getTickCount()

    exports.TR_dx:setOpenGUI(true)

    showCursor(true)
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientClick", root, self.func.handleClick)
    addEventHandler("guiButtonClick", root, self.func.declineTaxiRequest)
end

function Panel:close()
    if self.state ~= "opened" then return end
    if exports.TR_dx:isResponseEnabled() then return end
    self.state = "closing"
    self.tick = getTickCount()

    exports.TR_dx:hideButton(self.declineOrder)

    showCursor(false)
    removeEventHandler("onClientClick", root, self.func.handleClick)
    removeEventHandler("guiButtonClick", root, self.func.declineTaxiRequest)
end

function Panel:destroy()
    exports.TR_dx:destroyButton(self.declineOrder)
    exports.TR_dx:setOpenGUI(false)
    removeEventHandler("onClientRender", root, self.func.render)
    guiInfo.info = nil
    self = nil
end

function Panel:animate()
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
        self.state = "closed"
        self.tick = nil

        self:destroy()
      end
    end
end

function Panel:render()
    self:animate()
    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 5)
    dxDrawText("Taksi Bildirimleri", guiInfo.x + 10/zoom, guiInfo.y, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + 40/zoom, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")

    for i = 1, 8 do
        if self.requests[i] then
            if self:isMouseInPosition(guiInfo.x, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.w, 40/zoom) then
                dxDrawRectangle(guiInfo.x, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.w, 40/zoom, tocolor(27, 27, 27, 255 * self.alpha))
            end

            dxDrawText(string.format("%s (%s)", self.requests[i].playerName, self.requests[i].destination), guiInfo.x + 20/zoom, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.x + guiInfo.w - 20/zoom, guiInfo.y + 90/zoom + 40/zoom * (i-1), tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.info, "left", "center")
            dxDrawText(string.format("Mesafe: %dm", self.requests[i].dist), guiInfo.x + 20/zoom, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.x + guiInfo.w - 20/zoom, guiInfo.y + 90/zoom + 40/zoom * (i-1), tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.info, "right", "center")
        end
    end
end

function Panel:handleClick(...)
    if exports.TR_dx:isResponseEnabled() then return end
    if arg[1] == "left" and arg[2] == "down" then
        for i = 1, 8 do
            if self.requests[i] then
                if self:isMouseInPosition(guiInfo.x, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.w, 40/zoom) then
                    if not isElement(self.requests[i].player) then exports.TR_noti:create("Oyuncu sunucudan ayrıldığı için bu rapor artık geçerli değil.", "info") return end
                    if isElement(guiInfo.blip) then exports.TR_noti:create("Mevcut bileti tamamlamadan başka bir bilet alamazsınız.", "error") return end
                    if self.requests[i].player == localPlayer then exports.TR_noti:create("Kendi başvurunuzu kabul edemezsiniz.", "error") return end

                    exports.TR_dx:setResponseEnabled(true)
                    self.selectData = self.requests[i]

                    triggerServerEvent("selectTaxiRequest", resourceRoot, self.requests[i].player)
                    break
                end
            end
        end
    end
end


function Panel:declineTaxiRequest(btn)
    if not guiInfo.client then return end
    if btn == self.declineOrder then
        if isElement(guiInfo.blip) then destroyElement(guiInfo.blip) end
        if isTimer(guiInfo.blipTimer) then killTimer(guiInfo.blipTimer) end

        triggerServerEvent("declineTaxiRequest", resourceRoot, guiInfo.client)

        guiInfo.client = nil
        guiInfo.clientName = nil
        exports.TR_jobs:createInformation("Taxi Sürücüsü", "Başvuruyu bekleyin veya müşteri çekmek için sık ziyaret edilen bir yere gidin. Rapor panelini F4 butonunun altında bulabilirsiniz.")
        exports.TR_noti:create(client, "Başvurunuz başarıyla iptal edildi.", "success")
    end
end


function Panel:drawBackground(x, y, w, h, color, radius, post)
    dxDrawRectangle(x, y, w, h, color, post)
    dxDrawRectangle(x + radius, y - radius, w - radius * 2, radius, color, post)
    dxDrawRectangle(x + radius, y + h, w - radius * 2, radius, color, post)
    dxDrawCircle(x + radius, y, radius, 180, 270, color, color, 7, 1, post)
    dxDrawCircle(x + radius, y + h, radius, 90, 180, color, color, 7, 1, post)

    dxDrawCircle(x + w - radius, y, radius, 270, 360, color, color, 7, 1, post)
    dxDrawCircle(x + w - radius, y + h, radius, 0, 90, color, color, 7, 1, post)
end

function Panel:isMouseInPosition(x, y, width, height)
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


function updateBlipPos()
    if not isElement(guiInfo.blip) then killTimer(guiInfo.blipTimer) end
    if not isElement(guiInfo.client) then
        destroyElement(guiInfo.blip)
        killTimer(guiInfo.blipTimer)
        guiInfo.client = nil
        guiInfo.clientName = nil

        exports.TR_noti:create("Oyuncu sunucudan ayrıldığı için istek iptal edildi.", "info")
        exports.TR_jobs:createInformation("Taxi Sürücüsü", "Başvuruyu bekleyin veya müşteri çekmek için sık ziyaret edilen bir yere gidin. Rapor panelini F4 butonunun altında bulabilirsiniz.")
        return
    end

    local bpos = Vector3(getElementPosition(guiInfo.blip))
    local ppos = Vector3(getElementPosition(localPlayer))

    if getDistanceBetweenPoints3D(bpos, ppos) < 20 then
        destroyElement(guiInfo.blip)
        killTimer(guiInfo.blipTimer)
        guiInfo.client = nil
        guiInfo.clientName = nil

        exports.TR_jobs:createInformation("Taxi Sürücüsü", "Başvuruyu bekleyin veya müşteri çekmek için sık ziyaret edilen bir yere gidin. Rapor panelini F4 butonunun altında bulabilirsiniz.")
    end
end

function createTaxiPanel(...)
    if guiInfo.info then
        guiInfo.info:close()
        return
    end

    if not exports.TR_dx:canOpenGUI() then return end
    guiInfo.info = Panel:create(...)
end

function updateTaxiPanel(...)
    if not guiInfo.info then return end
    guiInfo.info:createList(...)
end
addEvent("updateTaxiPanel", true)
addEventHandler("updateTaxiPanel", resourceRoot, updateTaxiPanel)