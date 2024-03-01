local sx, sy = guiGetScreenSize()

local guiInfo = {
    x = (sx - 700/zoom)/2,
    y = (sy - 470/zoom)/2,
    w = 700/zoom,
    h = 470/zoom,
}

exports.TR_dx:setOpenGUI(false)
exports.TR_dx:setResponseEnabled(false)

Shop = {}
Shop.__index = Shop

function Shop:create(...)
    local instance = {}
    setmetatable(instance, Shop)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function Shop:constructor(...)
    self.shopName = arg[1]

    self.alpha = 0
    self.scroll = 0
    self.maxBuy = 9

    self.fonts = {}
    self.fonts.name = exports.TR_dx:getFont(14)
    self.fonts.desc = exports.TR_dx:getFont(11)
    self.fonts.price = exports.TR_dx:getFont(13)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.click = function(...) self:click(...) end
    self.func.scroll = function(...) self:scrollKey(...) end
    self.func.button = function(...) self:clickButton(...) end

    self:prepareItems(arg[2])
    self:open()

    return true
end

function Shop:open()
    if self.state then return end
    self.opened = true

    self.state = "opening"
    self.tick = getTickCount()

    self.buttons = {}
    self.buttons.exit = exports.TR_dx:createButton(guiInfo.x + 10/zoom, guiInfo.y + guiInfo.h - 50/zoom, guiInfo.w/2 - 20/zoom, 40/zoom, "Mağazayı Kapat")
    self.buttons.buy = exports.TR_dx:createButton(guiInfo.x + guiInfo.w - (guiInfo.w/2 - 20/zoom) - 10/zoom, guiInfo.y + guiInfo.h - 50/zoom, guiInfo.w/2 - 20/zoom, 40/zoom, "Öğeleri Satın Al")
    exports.TR_dx:setButtonVisible(self.buttons, false)
    exports.TR_dx:showButton(self.buttons)

    showCursor(true)
    exports.TR_dx:setOpenGUI(true)
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientClick", root, self.func.click)
    addEventHandler("guiButtonClick", root, self.func.button)
    addEventHandler("onClientKey", root, self.func.scroll)
end

function Shop:close()
    exports.TR_dx:hideButton(self.buttons)

    self.state = "closing"
    self.tick = getTickCount()

    showCursor(false)
    exports.TR_dx:setResponseEnabled(false)
end

function Shop:clearData()
    removeEventHandler("onClientRender", root, self.func.render)
    removeEventHandler("onClientClick", root, self.func.click)
    removeEventHandler("guiButtonClick", root, self.func.button)
    removeEventHandler("onClientKey", root, self.func.scroll)
    exports.TR_dx:setOpenGUI(false)

    guiInfo.shop = nil
    self = nil
end



function Shop:animate()
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
            self.tick = nil

            self:clearData()
        end
    end
end

function Shop:render()
    self:animate()

    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 5)
    dxDrawText(self.shopName, guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 40/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.name, "center", "center")

    -- dxDrawText(inspect(self.shopProducts), 300, 10)
    for i = 1, 6 do
        if self.shopProducts[i + self.scroll] then
            self:drawShopItem(self.shopProducts[i + self.scroll], i - 1)
        end
    end

    if #self.shopProducts > 6 then
        local b1 = 350/zoom / #self.shopProducts
        local barY = b1 * self.scroll
        local barHeight = b1 * 6
        dxDrawRectangle(guiInfo.x + guiInfo.w - 8/zoom, guiInfo.y + 50/zoom, 4/zoom, 350/zoom, tocolor(37, 37, 37, 255 * self.alpha))
        dxDrawRectangle(guiInfo.x + guiInfo.w - 8/zoom, guiInfo.y + 50/zoom + barY, 4/zoom, barHeight, tocolor(57, 57, 57, 255 * self.alpha))
    else
        dxDrawRectangle(guiInfo.x + guiInfo.w - 8/zoom, guiInfo.y + 50/zoom, 4/zoom, 350/zoom, tocolor(57, 57, 57, 255 * self.alpha))
    end
end

function Shop:drawShopItem(item, i)
    local move = 50/zoom + 60/zoom * i
    local alpha = 200

    dxDrawImage(guiInfo.x + 15/zoom, guiInfo.y + move, 50/zoom, 50/zoom, item.icon, 0, 0, 0, tocolor(220, 220, 220, 200 * self.alpha))
    dxDrawText(item.name, guiInfo.x + 75/zoom, guiInfo.y + 3/zoom + move, guiInfo.x + guiInfo.w, guiInfo.y + 40/zoom, tocolor(220, 220, 220, 200 * self.alpha), 1/zoom, self.fonts.name, "left", "top")
    dxDrawText(item.description, guiInfo.x + 75/zoom, guiInfo.y + 26/zoom + move, guiInfo.x + guiInfo.w, guiInfo.y + 40/zoom, tocolor(150, 150, 150, 200 * self.alpha), 1/zoom, self.fonts.desc, "left", "top")
    dxDrawText("$"..item.showPrice, guiInfo.x + guiInfo.w - 30/zoom, guiInfo.y + move, guiInfo.x + guiInfo.w - 50/zoom, guiInfo.y + 50/zoom + move, tocolor(212, 175, 55, 200 * self.alpha), 1/zoom, self.fonts.price, "right", "center")

    dxDrawText(item.count, guiInfo.x + guiInfo.w - 30/zoom, guiInfo.y + move, guiInfo.x + guiInfo.w - 30/zoom, guiInfo.y + 50/zoom + move, tocolor(220, 220, 220, 200 * self.alpha), 1/zoom, self.fonts.name, "center", "center")
    if self:isMouseInPosition(guiInfo.x + guiInfo.w - 37/zoom, guiInfo.y + 2/zoom + move, 14/zoom, 14/zoom) then
        dxDrawImage(guiInfo.x + guiInfo.w - 37/zoom, guiInfo.y + 2/zoom + move, 14/zoom, 14/zoom, "files/images/arrow.png", 180, 0, 0, tocolor(220, 220, 220, 255 * self.alpha))
    else
        dxDrawImage(guiInfo.x + guiInfo.w - 37/zoom, guiInfo.y + 2/zoom + move, 14/zoom, 14/zoom, "files/images/arrow.png", 180, 0, 0, tocolor(220, 220, 220, 200 * self.alpha))
    end
    if self:isMouseInPosition(guiInfo.x + guiInfo.w - 37/zoom, guiInfo.y + 35/zoom + move, 14/zoom, 14/zoom) then
        dxDrawImage(guiInfo.x + guiInfo.w - 37/zoom, guiInfo.y + 35/zoom + move, 14/zoom, 14/zoom, "files/images/arrow.png", 0, 0, 0, tocolor(220, 220, 220, 255 * self.alpha))
    else
        dxDrawImage(guiInfo.x + guiInfo.w - 37/zoom, guiInfo.y + 35/zoom + move, 14/zoom, 14/zoom, "files/images/arrow.png", 0, 0, 0, tocolor(220, 220, 220, 200 * self.alpha))
    end
end



function Shop:click(...)
    if exports.TR_dx:isResponseEnabled() then return end
    if arg[1] == "left" and arg[2] == "down" then
        for i = 1, 6 do
            if self.shopProducts[i] then
                local move = 50/zoom + 60/zoom * (i - 1)
                if self:isMouseInPosition(guiInfo.x + guiInfo.w - 37/zoom, guiInfo.y + 2/zoom + move, 14/zoom, 14/zoom) then
                    self.shopProducts[i + self.scroll].count = math.min(self.shopProducts[i + self.scroll].count + 1, self.maxBuy)
                    break

                elseif self:isMouseInPosition(guiInfo.x + guiInfo.w - 37/zoom, guiInfo.y + 35/zoom + move, 14/zoom, 14/zoom) then
                    self.shopProducts[i + self.scroll].count = math.max(self.shopProducts[i + self.scroll].count - 1, 0)
                    break
                end
            end
        end
    end
end

function Shop:clickButton(...)
    if exports.TR_dx:isResponseEnabled() then return end
    if arg[1] == self.buttons.exit then
        self:close()

    elseif arg[1] == self.buttons.buy then
        if not self:canBuy() then exports.TR_noti:create("Hiçbir öğe seçmediniz.", "error") return end
        local itemsToBuy, itemsCost = {}, 0

        for _, v in pairs(self.shopProducts) do
            if v.count > 0 then
                for i = 1, v.count do
                    itemsCost = itemsCost + tonumber(v.price)
                    table.insert(itemsToBuy, {
                        type = v.type,
                        variant = v.variant,
                        variant2 = v.variant2,
                        value = v.value and v.value or "NULL",
                    })
                end
            end
        end
        triggerServerEvent("createPayment", resourceRoot, itemsCost, "buyShopItems", itemsToBuy)
    end
end

function Shop:scrollKey(...)
    if exports.TR_dx:isResponseEnabled() then return end
    if arg[1] == "mouse_wheel_up" then
        if self.scroll == 0 then return end
        self.scroll = self.scroll - 1

    elseif arg[1] == "mouse_wheel_down" then
        if self.scroll + 6 >= #self.shopProducts then return end
        self.scroll = self.scroll + 1
    end
end

function Shop:canBuy(...)
    local state = false
    for i, v in pairs(self.shopProducts) do
        if v.count > 0 then
            state = true
            break
        end
    end
    return state
end


function Shop:unselectItems()
    for i, v in pairs(self.shopProducts) do
        v.count = 0
    end
end

function Shop:prepareItems(items)
    self.shopProducts = {}

    for _, item in pairs(items) do
        local name, description, icon = self:getItemDetails(item)

        table.insert(self.shopProducts, {
            name = name,
            description = description,
            icon = icon,
            type = item.type,
            value = item.value,
            variant = item.variant,
            variant2 = item.variant2,
            count = 0,
            showPrice = self:formatNumber(string.format("%.2f", item.price and item.price or 50000)),
            price = item.price and item.price or 50000,
        })
    end
end

function Shop:getItemDetails(item)
    local name, description, icon, type = "Bilinmeyen öğe", "Kimse ne olduğu ve buraya nasıl geldiği konusunda emin değil.", "unknown"

    for i, v in ipairs(itemDetails) do
        if item.type == v.type and item.variant == v.variant and item.variant2 == v.variant2 then
            name, description, icon, type = v.name, v.description, v.icon or "unknown"
            break
        end
    end

    return name, description, string.format("files/images/items/%s.png", icon), type
end

function Shop:drawBackground(x, y, rx, ry, color, radius, post)
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

function Shop:formatNumber(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1 '):reverse())..right
end

function Shop:isMouseInPosition(x, y, width, height)
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



function createShop(...)
    if guiInfo.shop then return end
    guiInfo.shop = Shop:create(...)
end
addEvent("createShop", true)
addEventHandler("createShop", root, createShop)

function buyShopItem(...)
    if not guiInfo.shop then return end
    exports.TR_dx:setResponseEnabled(false)
    if arg[1] then
        guiInfo.shop:unselectItems()
        exports.TR_noti:create("Seçtiğiniz öğeleri başarıyla satın aldınız.", "success")

        exports.TR_achievements:addAchievements("shopBuy")
    end
end
addEvent("buyShopItem", true)
addEventHandler("buyShopItem", root, buyShopItem)