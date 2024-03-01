local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 800/zoom)/2,
    y = (sy - 530/zoom)/2,
    w = 800/zoom,
    h = 530/zoom,
}

AdminList = {}
AdminList.__index = AdminList

function AdminList:create(...)
    local instance = {}
    setmetatable(instance, AdminList)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function AdminList:constructor(...)
    self:buildAdminList(arg[1], arg[2])
    self.scroll = 0

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.admin = exports.TR_dx:getFont(12)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.onClick = function(...) self:onClick(...) end
    self.func.onScroll = function(...) self:onScroll(...) end

    showCursor(true)
    addEventHandler("onClientRender", root, self.func.render)
    bindKey("mouse1", "down", self.func.onClick)
    bindKey("mouse_wheel_up", "down", self.func.onScroll)
    bindKey("mouse_wheel_down", "down", self.func.onScroll)
    return true
end

function AdminList:close()
    showCursor(false)
    removeEventHandler("onClientRender", root, self.func.render)
    unbindKey("mouse_wheel_up", "down", self.func.onScroll)
    unbindKey("mouse_wheel_down", "down", self.func.onScroll)
    unbindKey("mouse1", "down", self.func.onClick)

    guiInfo.panel = nil
    self = nil
end

function AdminList:buildAdminList(...)
    local reports = {}
    for i, v in pairs(arg[2]) do
        reports[v.username] = count
    end

    local admins = {
        ["admin"] = {},
        ["moderator"] = {},
        ["support"] = {},
        ["developer"] = {},
    }
    self.adminCount = 0

    if arg[1] then
        for i, v in pairs(arg[1]) do
            local rank, suspended = self:getRank(v.rankName)
            if admins[rank] then
                if v.username then
                    v.rankShow = rank
                    v.suspended = suspended
                    table.insert(admins[rank], v)
                    admins[rank][#admins[rank]].reports = reports[v.username] or "0"
                    self.adminCount = self.adminCount + 1
                end
            end
        end
    end

    self.admins = {}
    table.sort(admins.admin, function(a, b) return a.username < b.username end)
    for i, v in pairs(admins.admin) do
        table.insert(self.admins, v)
    end
    table.sort(admins.moderator, function(a, b) return a.username < b.username end)
    for i, v in pairs(admins.moderator) do
        table.insert(self.admins, v)
    end
    table.sort(admins.support, function(a, b) return a.username < b.username end)
    for i, v in pairs(admins.support) do
        table.insert(self.admins, v)
    end
    table.sort(admins.developer, function(a, b) return a.username < b.username end)
    for i, v in pairs(admins.developer) do
        table.insert(self.admins, v)
    end
end

function AdminList:getRank(rankName)
    if string.find(rankName, "-sus") then return string.match(rankName, "(.+)-"), true end
    return rankName, false
end

function AdminList:render()
    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255), 4)
    dxDrawText("Aktif Yetkililer", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255), 1/zoom, self.fonts.main, "center", "center")

    dxDrawText("İsim", guiInfo.x + 15/zoom, guiInfo.y + 40/zoom, guiInfo.x + guiInfo.w, guiInfo.y + 70/zoom, tocolor(220, 220, 220, 255), 1/zoom, self.fonts.admin, "left", "center")
    dxDrawText("Rütbe", guiInfo.x + 200/zoom, guiInfo.y + 40/zoom, guiInfo.x + guiInfo.w, guiInfo.y + 70/zoom, tocolor(220, 220, 220, 255), 1/zoom, self.fonts.admin, "left", "center")
    dxDrawText("Raporlar", guiInfo.x + 370/zoom, guiInfo.y + 40/zoom, guiInfo.x + 420/zoom, guiInfo.y + 70/zoom, tocolor(220, 220, 220, 255), 1/zoom, self.fonts.admin, "center", "center")
    dxDrawText("Görev Zamanı", guiInfo.x + 460/zoom, guiInfo.y + 40/zoom, guiInfo.x + 580/zoom, guiInfo.y + 70/zoom, tocolor(220, 220, 220, 255), 1/zoom, self.fonts.admin, "center", "center")
    dxDrawText("Haraketler", guiInfo.x + guiInfo.w - 120/zoom, guiInfo.y + 40/zoom, guiInfo.x + guiInfo.w - 14/zoom, guiInfo.y + 70/zoom, tocolor(220, 220, 220, 255), 1/zoom, self.fonts.admin, "center", "center")

    dxDrawLine(guiInfo.x + 10/zoom, guiInfo.y + 72/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + 72/zoom, tocolor(170, 170, 170, 100), 2)

    for i = 1, 15 do
        local v = self.admins[i + self.scroll]
        if v then
            -- if self:isMouseInPosition(guiInfo.x, guiInfo.y + 75/zoom + (i-1) * 30/zoom, guiInfo.w, 30/zoom) then
            --     dxDrawRectangle(guiInfo.x, guiInfo.y + 75/zoom + (i-1) * 30/zoom, guiInfo.w, 30/zoom, tocolor(27, 27, 27, 255))
            -- end
            dxDrawText(v.username, guiInfo.x + 15/zoom, guiInfo.y + 75/zoom + (i-1) * 30/zoom, guiInfo.x, guiInfo.y + 105/zoom + (i-1) * 30/zoom, tocolor(120, 120, 120, 255), 1/zoom, self.fonts.admin, "left", "center")
            dxDrawText(self:firstToUpper(v.rankShow), guiInfo.x + 200/zoom, guiInfo.y + 75/zoom + (i-1) * 30/zoom, guiInfo.x, guiInfo.y + 105/zoom + (i-1) * 30/zoom, tocolor(120, 120, 120, 255), 1/zoom, self.fonts.admin, "left", "center")
            dxDrawText(v.reports, guiInfo.x + 370/zoom, guiInfo.y + 75/zoom + (i-1) * 30/zoom, guiInfo.x + 420/zoom, guiInfo.y + 105/zoom + (i-1) * 30/zoom, tocolor(120, 120, 120, 255), 1/zoom, self.fonts.admin, "center", "center")
            dxDrawText(self:secondsToClock(v.dutyTime), guiInfo.x + 460/zoom, guiInfo.y + 75/zoom + (i-1) * 30/zoom, guiInfo.x + 580/zoom, guiInfo.y + 105/zoom + (i-1) * 30/zoom, tocolor(120, 120, 120, 255), 1/zoom, self.fonts.admin, "center", "center")

            if v.suspended then
                dxDrawLine(guiInfo.x + 200/zoom, guiInfo.y + 89/zoom + (i-1) * 30/zoom, guiInfo.x + 200/zoom + dxGetTextWidth(self:firstToUpper(v.rankShow), 1/zoom, self.fonts.admin), guiInfo.y + 89/zoom + (i-1) * 30/zoom, tocolor(255, 80, 80, 200), 2)
            end

            if self:isMouseInPosition(guiInfo.x + guiInfo.w - 30/zoom, guiInfo.y + 82/zoom + (i-1) * 30/zoom, 16/zoom, 16/zoom) then
                dxDrawImage(guiInfo.x + guiInfo.w - 30/zoom, guiInfo.y + 82/zoom + (i-1) * 30/zoom, 16/zoom, 16/zoom, "files/images/trash.png", 0, 0, 0, tocolor(170, 170, 170, 255))
                self:renderInfo("Sil")
            else
                dxDrawImage(guiInfo.x + guiInfo.w - 30/zoom, guiInfo.y + 82/zoom + (i-1) * 30/zoom, 16/zoom, 16/zoom, "files/images/trash.png", 0, 0, 0, tocolor(120, 120, 120, 255))
            end
            if self:isMouseInPosition(guiInfo.x + guiInfo.w - 60/zoom, guiInfo.y + 82/zoom + (i-1) * 30/zoom, 16/zoom, 16/zoom) then
                dxDrawImage(guiInfo.x + guiInfo.w - 60/zoom, guiInfo.y + 82/zoom + (i-1) * 30/zoom, 16/zoom, 16/zoom, "files/images/block.png", 0, 0, 0, tocolor(170, 170, 170, 255))
                self:renderInfo("Aksıya Al / Askıyı Kaldır")
            else
                dxDrawImage(guiInfo.x + guiInfo.w - 60/zoom, guiInfo.y + 82/zoom + (i-1) * 30/zoom, 16/zoom, 16/zoom, "files/images/block.png", 0, 0, 0, tocolor(120, 120, 120, 255))
            end
            if self:isMouseInPosition(guiInfo.x + guiInfo.w - 90/zoom, guiInfo.y + 82/zoom + (i-1) * 30/zoom, 16/zoom, 16/zoom) then
                dxDrawImage(guiInfo.x + guiInfo.w - 90/zoom, guiInfo.y + 82/zoom + (i-1) * 30/zoom, 16/zoom, 16/zoom, "files/images/arrow.png", 180, 0, 0, tocolor(170, 170, 170, 255))
                self:renderInfo("Küçült")
            else
                dxDrawImage(guiInfo.x + guiInfo.w - 90/zoom, guiInfo.y + 82/zoom + (i-1) * 30/zoom, 16/zoom, 16/zoom, "files/images/arrow.png", 180, 0, 0, tocolor(120, 120, 120, 255))
            end
            if self:isMouseInPosition(guiInfo.x + guiInfo.w - 120/zoom, guiInfo.y + 82/zoom + (i-1) * 30/zoom, 16/zoom, 16/zoom) then
                dxDrawImage(guiInfo.x + guiInfo.w - 120/zoom, guiInfo.y + 82/zoom + (i-1) * 30/zoom, 16/zoom, 16/zoom, "files/images/arrow.png", 0, 0, 0, tocolor(170, 170, 170, 255))
                self:renderInfo("Terfi Et")
            else
                dxDrawImage(guiInfo.x + guiInfo.w - 120/zoom, guiInfo.y + 82/zoom + (i-1) * 30/zoom, 16/zoom, 16/zoom, "files/images/arrow.png", 0, 0, 0, tocolor(120, 120, 120, 255))
            end
        end
    end
end

function AdminList:renderInfo(text)
    local cx, cy = getCursorPosition()
    if cx and cy then
        local cx, cy = cx * sx + 7/zoom, cy * sy + 5/zoom
        local width = dxGetTextWidth(text, 1/zoom, self.fonts.admin) + 10/zoom

        self:drawBackground(cx, cy, width, 30/zoom, tocolor(17, 17, 17, 255), 4, true)
        dxDrawText(text, cx + 5/zoom, cy, cx + width - 5/zoom, cy + 30/zoom, tocolor(170, 170, 170, 255), 1/zoom, self.fonts.admin, "center", "center", false, false, true)
    end
end


function AdminList:onClick()
    if exports.TR_dx:isResponseEnabled() then return end
    for i = 1, 15 do
        local v = self.admins[i + self.scroll]
        if v then
            if self:isMouseInPosition(guiInfo.x + guiInfo.w - 30/zoom, guiInfo.y + 82/zoom + (i-1) * 30/zoom, 16/zoom, 16/zoom) then
                exports.TR_dx:setResponseEnabled(true)
                triggerServerEvent("removePlayerAdmin", resourceRoot, v.uid, v.username)

            elseif self:isMouseInPosition(guiInfo.x + guiInfo.w - 60/zoom, guiInfo.y + 82/zoom + (i-1) * 30/zoom, 16/zoom, 16/zoom) then
                exports.TR_dx:setResponseEnabled(true)
                triggerServerEvent("suspendPlayerAdmin", resourceRoot, v.uid, v.username, v.suspended and v.rankShow or v.rankShow.."-sus")

            elseif self:isMouseInPosition(guiInfo.x + guiInfo.w - 90/zoom, guiInfo.y + 82/zoom + (i-1) * 30/zoom, 16/zoom, 16/zoom) then
                if v.rankShow == "support" or v.rankShow == "developer" then exports.TR_noti:create("Artık bu yetkilinin rütbesini düşüremezsiniz", "success") return end
                local newRank = "support"
                if v.rankShow == "admin" then newRank = "moderator" end

                exports.TR_dx:setResponseEnabled(true)
                triggerServerEvent("suspendPlayerAdmin", resourceRoot, v.uid, v.username, newRank)


            elseif self:isMouseInPosition(guiInfo.x + guiInfo.w - 120/zoom, guiInfo.y + 82/zoom + (i-1) * 30/zoom, 16/zoom, 16/zoom) then
                if v.rankShow == "admin" then exports.TR_noti:create("Artık bu yetkiliyi terfi ettiremezsiniz", "success") return end
                local newRank = "admin"
                if v.rankShow == "support" then newRank = "moderator" end

                exports.TR_dx:setResponseEnabled(true)
                triggerServerEvent("suspendPlayerAdmin", resourceRoot, v.uid, v.username, newRank)
            end
        end
    end
end

function AdminList:onScroll(btn)
    if btn == "mouse_wheel_up" then
        if self.scroll <= 0 then return end
        self.scroll = self.scroll - 1

    elseif btn == "mouse_wheel_down" then
        if self.scroll + 15 >= self.adminCount then return end
        self.scroll = self.scroll + 1
    end
end

function AdminList:response(...)
    exports.TR_dx:setResponseEnabled(false)
    self:buildAdminList(arg[1], arg[2])
end

function AdminList:firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

function AdminList:drawBackground(x, y, rx, ry, color, radius, post)
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

function AdminList:isMouseInPosition(x, y, width, height)
    if (not isCursorShowing()) then return false end
    local cx, cy = getCursorPosition()
    local cx, cy = (cx*sx), (cy*sy)
    if (cx >= x and cx <= x + width) and (cy >= y and cy <= y + height) then return true end
    return false
end

function AdminList:secondsToClock(seconds)
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

function startAdminList(...)
    if not guiInfo.panel then
        guiInfo.panel = AdminList:create(...)
    else
        guiInfo.panel:close()
    end
end
addEvent("startAdminList", true)
addEventHandler("startAdminList", root, startAdminList)

function updateAdminPanelList(...)
    guiInfo.panel:response(...)
end
addEvent("updateAdminPanelList", true)
addEventHandler("updateAdminPanelList", root, updateAdminPanelList)