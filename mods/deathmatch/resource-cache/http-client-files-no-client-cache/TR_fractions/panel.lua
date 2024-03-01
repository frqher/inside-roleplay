local sx, sy = guiGetScreenSize()

local guiInfo = {
    x = (sx - 800/zoom)/2,
    y = (sy - 470/zoom)/2,
    w = 800/zoom,
    h = 470/zoom,
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

    local _, jobType = exports.TR_jobs:getPlayerJob()
    if jobType == "ers" then
        self.fraction = "ers"
    else
        self.fraction = string.sub(jobType, 1, 1)
    end

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.info = exports.TR_dx:getFont(12)
    self.fonts.small = exports.TR_dx:getFont(10)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.handleClick = function(...) self:handleClick(...) end

    exports.TR_dx:setResponseEnabled(true)
    triggerServerEvent("getFractionPanel", resourceRoot, self.fraction)

    self:createList(arg[1])
    self:open()
    return true
end

function Panel:createList(...)
    self.requests = {}

    if arg[1] then
        local plrPos = Vector3(getElementPosition(localPlayer))

        for i, v in pairs(arg[1]) do
            if v.isCustom then
                local pos = v.pos
                table.insert(self.requests, {
                    pos = pos,
                    dist = getDistanceBetweenPoints3D(plrPos, pos[1], pos[2], pos[3]),
                    destination = getZoneName(pos[1], pos[2], pos[3]),
                    playerName = isElement(i) and getPlayerName(i) or i,
                    player = i,
                    time = v.time,
                    text = v.text,
                    isCustom = true,
                })
            else
                local pos = v.pos
                table.insert(self.requests, {
                    pos = pos,
                    dist = getDistanceBetweenPoints3D(plrPos, pos[1], pos[2], pos[3]),
                    destination = getZoneName(pos[1], pos[2], pos[3]),
                    playerName = getPlayerName(i),
                    player = i,
                    time = v.time,
                    text = v.text,
                })
            end
        end

        table.sort(self.requests, function(a, b)
            if a.dist > b.dist then return true end
            return false
        end)
    end

    if arg[2] == "take" then
        local pos = self.selectData.pos
        exports.TR_hud:findBestWay(pos[1], pos[2], true)
        exports.TR_noti:create("İhbar alındı.", "success", 6)
        exports.TR_jobs:createInformation(false, string.format("En kısa sürede ihbar yerine git. Konum: %s.", self.selectData.destination))

        if isTimer(guiInfo.blipTimer) then killTimer(guiInfo.blipTimer) end
        if isElement(guiInfo.blip) then destroyElement(guiInfo.blip) end

        guiInfo.blip = createBlip(pos[1], pos[2], pos[3], 0, 2, 255, 0, 0, 0)
        setElementData(guiInfo.blip, "icon", 22, false)
        guiInfo.blipTimer = setTimer(updateBlipPos, 1000, 0)
        guiInfo.clientName = self.selectData.playerName


    elseif arg[2] == "taken" then
        exports.TR_noti:create("Bu ihbar zaten alındı.", "error")

    elseif arg[2] == "removed" then
        exports.TR_noti:create("İhbar kaldırıldı.", "success")

    elseif arg[2] == "old" then
        exports.TR_noti:create("İhbar süresi doldu.", "error")
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
end

function Panel:close()
    if self.state ~= "opened" then return end
    if exports.TR_dx:isResponseEnabled() then return end
    self.state = "closing"
    self.tick = getTickCount()

    showCursor(false)
    removeEventHandler("onClientClick", root, self.func.handleClick)
end

function Panel:destroy()
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
    dxDrawText("Servis Bildirimleri", guiInfo.x + 10/zoom, guiInfo.y, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + 40/zoom, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")

    for i = 1, 6 do
        if self.requests[i] then
            if self:isMouseInPosition(guiInfo.x, guiInfo.y + 50/zoom + 60/zoom * (i-1), guiInfo.w, 60/zoom) then
                dxDrawRectangle(guiInfo.x, guiInfo.y + 50/zoom + 60/zoom * (i-1), guiInfo.w, 60/zoom, tocolor(27, 27, 27, 255 * self.alpha))
            end

            dxDrawText(string.format("%s", self.requests[i].playerName), guiInfo.x + 15/zoom, guiInfo.y + 62/zoom + 60/zoom * (i-1), guiInfo.x + 150/zoom, guiInfo.y + 110/zoom + 60/zoom * (i-1), tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.info, "left", "top", true, false)
            dxDrawText(string.format("saat: %s", self.requests[i].time), guiInfo.x + 15/zoom, guiInfo.y + 60/zoom + 60/zoom * (i-1), guiInfo.x + 150/zoom, guiInfo.y + 98/zoom + 60/zoom * (i-1), tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.small, "left", "bottom", true, false)
            dxDrawText(string.format("%s", self.requests[i].text), guiInfo.x + 180/zoom, guiInfo.y + 50/zoom + 60/zoom * (i-1), guiInfo.x + guiInfo.w - 130/zoom, guiInfo.y + 110/zoom + 60/zoom * (i-1), tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.small, "left", "center", true, true)
            dxDrawText("Mesafe:", guiInfo.x + 15/zoom, guiInfo.y + 62/zoom + 60/zoom * (i-1), guiInfo.x + guiInfo.w - 15/zoom, guiInfo.y + 110/zoom + 60/zoom * (i-1), tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.info, "right", "top", true, false)
            dxDrawText(string.format("%dm", self.requests[i].dist), guiInfo.x + 15/zoom, guiInfo.y + 60/zoom + 60/zoom * (i-1), guiInfo.x + guiInfo.w - 15/zoom, guiInfo.y + 98/zoom + 60/zoom * (i-1), tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.small, "right", "bottom", true, false)
        end
    end

    dxDrawText("EĞER BİLDİRİNİN İÇERİĞİNDEN BAŞKA FRAKSİYONLARIN DA UYGUN İŞLEMLERİ GERÇEKLEŞTİRMESİ GEREKTİĞİ ANLAŞILIRSA, ONLARI TELSİZLE BİLDİRİN! BİLDİRİLER 10 DAKİKA SONRA GEÇERSİZ OLACAK.", guiInfo.x + 10/zoom, guiInfo.y + guiInfo.h - 60/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h, tocolor(227, 70, 70, 255 * self.alpha), 1/zoom, self.fonts.small, "center", "center", true, true)
end

function Panel:handleClick(...)
    if exports.TR_dx:isResponseEnabled() then return end
    if arg[1] == "left" and arg[2] == "down" then
        for i = 1, 6 do
            if self.requests[i] then
                if self:isMouseInPosition(guiInfo.x, guiInfo.y + 50/zoom + 60/zoom * (i-1), guiInfo.w, 60/zoom) then
                    if isElement(guiInfo.blip) then exports.TR_noti:create("Başka bir bildirimi almadan önce mevcut olanı tamamlamalısınız.", "error") return end
                    exports.TR_dx:setResponseEnabled(true)
                    self.selectData = self.requests[i]

                    triggerServerEvent("selectFractionRequest", resourceRoot, self.fraction, self.requests[i].player)
                    break
                end
            end
        end
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
    local bpos = Vector3(getElementPosition(guiInfo.blip))
    local ppos = Vector3(getElementPosition(localPlayer))

    if getDistanceBetweenPoints3D(bpos, ppos) < 20 then
        destroyElement(guiInfo.blip)
        killTimer(guiInfo.blipTimer)
        exports.TR_jobs:hideInformation()
        exports.TR_noti:create("Bildirime ulaştınız.", "success")
    end
end

function createFractionPanel(...)
    if guiInfo.info then
        guiInfo.info:close()
        return
    end

    if not exports.TR_dx:canOpenGUI() then return end
    guiInfo.info = Panel:create(...)
end

function updateFractionPanel(...)
    if not guiInfo.info then return end
    guiInfo.info:createList(...)
end
addEvent("updateFractionPanel", true)
addEventHandler("updateFractionPanel", resourceRoot, updateFractionPanel)


exports.TR_dx:setResponseEnabled(false)
exports.TR_dx:setOpenGUI(false)