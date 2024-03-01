local sx, sy = guiGetScreenSize()

local guiInfo = {
    x = (sx - 600/zoom)/2,
    y = (sy - 500/zoom)/2,
    w = 600/zoom,
    h = 500/zoom,
}

Trunk = {}
Trunk.__index = Trunk

function Trunk:create(...)
    local instance = {}
    setmetatable(instance, Trunk)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function Trunk:constructor(...)
    self.alpha = 0
    self.scroll = 0
    self.type = arg[1]
    self.id = arg[2]
    self.items = {}
    self.weight = 0
    self.maxWeight = self:getMaxSize(arg[4])
    self:buildItems(arg[3])
    self:setHeaderText()

    self.func = {}
    self.func.render = function() self:render() end
    self.func.scrollItem = function(...) self:scrollItem(...) end

    self.fonts = {}
    self.fonts.title = exports.TR_dx:getFont(14)
    self.fonts.name = exports.TR_dx:getFont(13)
    self.fonts.category = exports.TR_dx:getFont(10)

    return self:tryOpen()
end

function Trunk:setHeaderText()
    if self.type == 0 then
        self.header = "Oyuncu Eşyaları"

    elseif self.type == 1 then
        self.header = "Bagaj İçeriği"

    elseif self.type == 2 then
        self.header = "Kasa İçeriği"

    elseif self.type == 20 then
        self.header = "Kutu İçeriği"
    end
end


function Trunk:getMaxSize(model)
    if self.type == 0 then
        return 25000

    elseif self.type == 1 then
        return exports.TR_hud:getVehicleTrunkCapacity(model) * 1000

    elseif self.type == 2 then
        return 50000

    elseif self.type == 20 then
        return 100000
    end
end

function Trunk:buildItems(items)
    if not items then return end
    for i, item in pairs(items) do
        local details = GUI.eq:getItemDetailsTable(item)
        table.insert(self.items, {
            ID = item.ID,
            name = details.name,
            description = details.description,
            icon = string.format("files/images/items/%s.png", details.icon),
            type = item.type,
            value = GUI.eq:getItemValue(item),
            value2 = tonumber(item.value2),
            variant = item.variant,
            variant2 = item.variant2,
            canRemove = not details.blockRemove,
            used = GUI.eq:isItemUsed(item),
            stackable = details.stackable,
        })

        self.weight = self.weight + (details.weight and details.weight * (item.value2 or 1) or 0)
    end
end

function Trunk:tryOpen()
    if not GUI.eq:isOpened() then
        GUI.eq:open(true)
        self:open()
        return true
    end
    return false
end

function Trunk:open()
    self.state = "opening"
    self.tick = getTickCount()
    self.lastAlpha = self.alpha
    self.alpha = 0

    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientKey", root, self.func.scrollItem)
end

function Trunk:close()
    self.state = "closing"
    self.tick = getTickCount()
    self.lastAlpha = self.alpha
    self.alpha = 1

    removeEventHandler("onClientKey", root, self.func.scrollItem)
end

function Trunk:destroy()
    removeEventHandler("onClientRender", root, self.func.render)

    GUI.trunk = nil
    self = nil
end


function Trunk:animate()
    if not self.tick then return end
    local progress = (getTickCount() - self.tick)/500
    if self.state == "opening" then
        self.alpha = interpolateBetween(self.lastAlpha, 0, 0, 1, 0, 0, progress, "Linear")
        if progress >= 1 then
            self.alpha = 1
            self.state = "opened"
            self.tick = nil
        end

    elseif self.state == "closing" then
        self.alpha = interpolateBetween(self.lastAlpha, 0, 0, 0, 0, 0, progress, "Linear")
        if progress >= 1 then
            self.alpha = 0
            self.state = "closed"
            self.tick = nil

            self:destroy()
            return true
        end
    end
end

function Trunk:render()
    if self:animate() then return end
    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 4)
    dxDrawText(self.header or "Gizli öğeler", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 40/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.title, "center", "center")
    

    for i = 1, 7 do
        local item = self.items[i + self.scroll]
        if item then
            local alpha = 200
            if (self:isMouseInPosition(guiInfo.x, guiInfo.y + 40/zoom + (i - 1) * 60/zoom, guiInfo.w - 75/zoom, 50/zoom) and not self.selectedItem and not self.blockHover) or item.ID == self.selectedItem then alpha = 230 end
            if not item.used then
                local width = dxGetTextWidth(item.name, 1/zoom, self.fonts.name)
                dxDrawImage(guiInfo.x + 15/zoom, guiInfo.y + 40/zoom + (i - 1) * 60/zoom, 50/zoom, 50/zoom, item.icon, 0, 0, 0, tocolor(220, 220, 220, alpha * self.alpha))
                dxDrawText(string.format("%s %s", item.name, item.stackable and "("..item.value2..")" or ""), guiInfo.x + 75/zoom, guiInfo.y + 43/zoom + (i - 1) * 60/zoom, guiInfo.x + guiInfo.w - 85/zoom, guiInfo.y + 70/zoom + (i - 1) * 60/zoom, tocolor(220, 220, 220, alpha * self.alpha), 1/zoom, self.fonts.name, "left", "top", true)
                dxDrawText(item.description, guiInfo.x + 75/zoom, guiInfo.y + 60/zoom + (i - 1) * 60/zoom, guiInfo.x + guiInfo.w - 85/zoom, guiInfo.y + 85/zoom + (i - 1) * 60/zoom, tocolor(150, 150, 150, alpha * self.alpha), 1/zoom, self.fonts.category, "left", "bottom", true)

            else
                dxDrawImage(guiInfo.x + 15/zoom, guiInfo.y + 40/zoom + (i - 1) * 60/zoom, 50/zoom, 50/zoom, item.icon, 0, 0, 0, tocolor(184, 153, 53, alpha * self.alpha))
                dxDrawText(string.format("%s %s", item.name, item.stackable and "("..item.value2..")" or ""), guiInfo.x + 75/zoom, guiInfo.y + 43/zoom + (i - 1) * 60/zoom, guiInfo.x + guiInfo.w - 85/zoom, guiInfo.y + 70/zoom + (i - 1) * 60/zoom, tocolor(220, 220, 220, alpha * self.alpha), 1/zoom, self.fonts.name, "left", "top", true)
                dxDrawText(item.description, guiInfo.x + 75/zoom, guiInfo.y + 60/zoom + (i - 1) * 60/zoom, guiInfo.x + guiInfo.w - 85/zoom, guiInfo.y + 85/zoom + (i - 1) * 60/zoom, tocolor(150, 150, 150, alpha * self.alpha), 1/zoom, self.fonts.category, "left", "bottom", true)
            end

            if (self:isMouseInPosition(guiInfo.x, guiInfo.y + 40/zoom + (i - 1) * 60/zoom, guiInfo.w - 75/zoom, 50/zoom) and not self.selectedItem and not self.blockHover) then
                GUI.eq:setHoveredItem(item, self.alpha)
            end


            if self:isMouseInPosition(guiInfo.x + guiInfo.w - 40/zoom, guiInfo.y + 60/zoom + (i - 1) * 60/zoom, 20/zoom, 20/zoom) then
                dxDrawImage(guiInfo.x + guiInfo.w - 40/zoom, guiInfo.y + 60/zoom + (i - 1) * 60/zoom, 20/zoom, 20/zoom, "files/images/takeout.png", 0, 0, 0, tocolor(220, 220, 220, 255 * self.alpha))
            else
                dxDrawImage(guiInfo.x + guiInfo.w - 40/zoom, guiInfo.y + 60/zoom + (i - 1) * 60/zoom, 20/zoom, 20/zoom, "files/images/takeout.png", 0, 0, 0, tocolor(170, 170, 170, 255 * self.alpha))
            end
        end
    end

    if #self.items > 7 then
        local b1 = (guiInfo.h - 80/zoom) / #self.items
        local barY = b1 * self.scroll
        local barHeight = b1 * 7
        dxDrawRectangle(guiInfo.x + guiInfo.w - 5/zoom, guiInfo.y + 40/zoom, 4/zoom, 290/zoom, tocolor(37, 37, 37, 255 * self.alpha))
        dxDrawRectangle(guiInfo.x + guiInfo.w - 5/zoom, guiInfo.y + 40/zoom + barY, 4/zoom, barHeight, tocolor(57, 57, 57, 255 * self.alpha))
    else
        dxDrawRectangle(guiInfo.x + guiInfo.w - 5/zoom, guiInfo.y + 40/zoom, 4/zoom, (guiInfo.h - 80/zoom), tocolor(57, 57, 57, 255 * self.alpha))
    end

    dxDrawImage(guiInfo.x + 15/zoom, guiInfo.y + guiInfo.h - 40/zoom + (40/zoom - 14/zoom)/2, 14/zoom, 14/zoom, "files/images/weight.png", 0, 0, 0, tocolor(120, 120, 120, 255 * self.alpha))
    dxDrawLine(guiInfo.x + 10/zoom, guiInfo.y + guiInfo.h - 40/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h - 40/zoom, tocolor(37, 37, 37, 255 * self.alpha))
    dxDrawText(string.format("Doluş: %.3fkg / %dkg", self.weight/1000, self.maxWeight/1000), guiInfo.x + 35/zoom, guiInfo.y + guiInfo.h - 40/zoom, guiInfo.x + guiInfo.w - 15/zoom, guiInfo.y + guiInfo.h, tocolor(150, 150, 150, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "center", false, false, true, true)

end


function Trunk:scrollItem(btn, state)
    if exports.TR_dx:isResponseEnabled() then return end
    if not self:isMouseInPosition(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h) then return end
    if not state then return end
    if btn == "mouse_wheel_up" then
        self.scroll = math.max(self.scroll - 1, 0)

    elseif btn == "mouse_wheel_down" then
        if #self.items <= 7 then return end
        self.scroll = math.min(self.scroll + 1, #self.items - 7)

    elseif btn == "mouse1" then
        for i = 1, 7 do
            local item = self.items[i + self.scroll]
            if item then
                if self:isMouseInPosition(guiInfo.x + guiInfo.w - 40/zoom, guiInfo.y + 60/zoom + (i - 1) * 60/zoom, 20/zoom, 20/zoom) then
                    if item.used then
                        exports.TR_noti:create("Bu öğeyi alamazsın.", "error")
                        return
                    end

                    local details = GUI.eq:getItemDetailsTable(item)
                    self.weight = self.weight - (details.weight and details.weight * (item.value2 or 1) or 0)

                    exports.TR_dx:setResponseEnabled(true)
                    table.remove(self.items, i + self.scroll)

                    triggerServerEvent("takeoutItemFromStash", resourceRoot, item.ID, self.type, self.id, details.name)

                    if #self.items > 7 then
                        self.scroll = math.min(self.scroll, #self.items - 7)
                    end
                    return
                end
            end
        end
    end
end

function Trunk:canInsertItem(item)
    local details = GUI.eq:getItemDetailsTable(item)
    local itemWeight = details.weight and details.weight * (item.value2 or 1) or 0

    if self.weight + itemWeight >= self.maxWeight then exports.TR_noti:create("Bu öğeyi saklayamazsın, çünkü yer kalmadı.", "error")
        return false end
    return true
end

function Trunk:addItem(item)
    if not self:canInsertItem(item) then return end
    exports.TR_dx:setResponseEnabled(true)
    table.insert(self.items, item)

    local details = GUI.eq:getItemDetailsTable(item)
    self.weight = self.weight + (details.weight and details.weight * (item.value2 or 1) or 0)

    triggerServerEvent("putItemInStash", resourceRoot, item.ID, self.id, self.type)
end

function Trunk:drawBackground(x, y, rx, ry, color, radius, post)
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

function Trunk:isMouseInPosition(x, y, width, height)
    if (not isCursorShowing()) then return false end
    local cx, cy = getCursorPosition()
    local cx, cy = (cx*sx), (cy*sy)
    if (cx >= x and cx <= x + width) and (cy >= y and cy <= y + height) then return true end
    return false
end

function openTrunkItems(type, id, items, model)
    if GUI.trunk then return end

    GUI.trunk = Trunk:create(type, id, items, model)
end
addEvent("openTrunkItems", true)
addEventHandler("openTrunkItems", root, openTrunkItems)


-- if getPlayerName(localPlayer) == "Xantris" then
--     setTimer(function()
--         triggerServerEvent("openTrunkItems", resourceRoot, 1, 1, 411)
--     end, 100, 1)
-- end