local sx, sy = guiGetScreenSize()

local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 430/zoom)/2,
    y = sy - 180/zoom,
    w = 430/zoom,
    h = 130/zoom,
}

SkinShop = {}
SkinShop.__index = SkinShop

function SkinShop:create(...)
    local instance = {}
    setmetatable(instance, SkinShop)
    if SkinShop:constructor(...) then
        return instance
    end
    return false
end

function SkinShop:constructor(...)
    exports.TR_dx:showLoading(3000, "Mağaza yükleniyor")

    self.shopName = arg[1]
    self.shopSkins = skinShops[arg[1]]
    self.shopCamera = cameraShops[arg[1]]
    self.dim = getElementDimension(localPlayer)

    self.ped = createPed(self.shopSkins[1], self.shopCamera[1], self.shopCamera[2], self.shopCamera[3], self.shopCamera[4], false)
    setElementInterior(self.ped, getElementInterior(localPlayer))
    setElementDimension(self.ped, self:getDimension())
    setElementDimension(localPlayer, self:getDimension())
    self.rot = self.shopCamera[4]

    self.font = exports.TR_dx:getFont(14)

    self.scroll = 1

    self.func = {}
    self.func.render = function() self:render() end
    self.func.click = function(...) self:click(...) end
    self.func.button = function(...) self:button(...) end

    setTimer(function()
        self:updateModel()
        self:open()
    end, 1000, 1)
    return true
end

function SkinShop:open()
    exports.TR_hud:setHudVisible(false)
    exports.TR_chat:showCustomChat(false)
    exports.TR_dx:setOpenGUI(true)

    self.buttons = {}
    self.buttons.buy = exports.TR_dx:createButton(guiInfo.x + guiInfo.w - 210/zoom, guiInfo.y + guiInfo.h - 50/zoom, 200/zoom, 40/zoom, "Satın al", "green")
    self.buttons.exit = exports.TR_dx:createButton(guiInfo.x + 10/zoom, guiInfo.y + guiInfo.h - 50/zoom, 200/zoom, 40/zoom, "Kapat", "red")

    bindKey("mouse1", "both", self.func.click)
    showCursor(true)
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("guiButtonClick", root, self.func.button)
    setCameraMatrix(self.shopCamera[5], self.shopCamera[6], self.shopCamera[7], self.shopCamera[1], self.shopCamera[2], self.shopCamera[3])
end

function SkinShop:close()
    exports.TR_dx:showLoading(3000, "Bir dünya yükleniyor")

    unbindKey("mouse1", "both", self.func.click)
    removeEventHandler("guiButtonClick", root, self.func.button)
    showCursor(false)

    setTimer(function()
        exports.TR_hud:setHudVisible(true)
        exports.TR_chat:showCustomChat(true)
        exports.TR_dx:setOpenGUI(false)

        exports.TR_dx:destroyButton(self.buttons)

        removeEventHandler("onClientRender", root, self.func.render)
        setCameraTarget(localPlayer)
        setElementDimension(localPlayer, self.dim)

        destroyElement(self.ped)

        guiInfo.skinShop = nil
        self = nil
    end, 1000, 1)
end

function SkinShop:render()
    if self.clickX then
        local cx, _ = getCursorPosition()
        cx = cx * sx

        self.rot = self.rot - (self.clickX - cx)/10
        if self.rot >= 360 then self.rot = self.rot - 360 end
        if self.rot <= 0 then self.rot = self.rot + 360 end
        self.clickX = cx

        setElementRotation(self.ped, 0, 0, self.rot)
    end

    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255), 4)
    if self:isMouseInPosition(guiInfo.x + guiInfo.w - 60/zoom, guiInfo.y + 15/zoom, 50/zoom, 50/zoom) then
        dxDrawImage(guiInfo.x + guiInfo.w - 60/zoom, guiInfo.y + 15/zoom, 50/zoom, 50/zoom, "files/images/arrow.png", 0, 0, 0, tocolor(255, 255, 255, 255))
    else
        dxDrawImage(guiInfo.x + guiInfo.w - 60/zoom, guiInfo.y + 15/zoom, 50/zoom, 50/zoom, "files/images/arrow.png", 0, 0, 0, tocolor(255, 255, 255, 200))
    end
    if self:isMouseInPosition(guiInfo.x + 10/zoom, guiInfo.y + 15/zoom, 50/zoom, 50/zoom) then
        dxDrawImage(guiInfo.x + 10/zoom, guiInfo.y + 15/zoom, 50/zoom, 50/zoom, "files/images/arrow.png", 180, 0, 0, tocolor(255, 255, 255, 255))
    else
        dxDrawImage(guiInfo.x + 10/zoom, guiInfo.y + 15/zoom, 50/zoom, 50/zoom, "files/images/arrow.png", 180, 0, 0, tocolor(255, 255, 255, 200))
    end

    dxDrawText("ID: #f0c437"..self.skinModel, guiInfo.x + 10/zoom, guiInfo.y + 15/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + 10/zoom, tocolor(255, 255, 255, 255), 1/zoom, self.font, "center", "top", false, false, false, true)
    dxDrawText(string.format("Fiyat: #d4af37$%.2f", self.skinPrice), guiInfo.x + 10/zoom, guiInfo.y + 40/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + 10/zoom, tocolor(255, 255, 255, 255), 1/zoom, self.font, "center", "top", false, false, false, true)
end


function SkinShop:click(...)
    if exports.TR_dx:isResponseEnabled() then return end
    if arg[1] == "mouse1" and arg[2] == "down" then
        if self:isMouseInPosition(guiInfo.x + guiInfo.w - 60/zoom, guiInfo.y + 15/zoom, 50/zoom, 50/zoom) then
            self.scroll = self.scroll + 1
            if self.scroll > #self.shopSkins then self.scroll = 1 end
            self:updateModel()

        elseif self:isMouseInPosition(guiInfo.x + 10/zoom, guiInfo.y + 15/zoom, 50/zoom, 50/zoom) then
            self.scroll = self.scroll - 1
            if self.scroll < 1 then self.scroll = #self.shopSkins end
            self:updateModel()

        else
            local cx, _ = getCursorPosition()
            self.clickX = cx * sx
        end

    elseif arg[1] == "mouse1" and arg[2] == "up" then
        self.clickX = nil
    end
end

function SkinShop:button(...)
    if exports.TR_dx:isResponseEnabled() then return end
    if arg[1] == self.buttons.buy then
        if not self:canBuySkin() then return end
        local price = self.skinPrice
        triggerServerEvent("createPayment", resourceRoot, price, "playerBuySkin", {self.shopName, self.shopSkins[self.scroll]})
        exports.TR_dx:setResponseEnabled(true)

    elseif arg[1] == self.buttons.exit then
        self:close()
    end
end

function SkinShop:updateModel(...)
    setElementModel(self.ped, self.shopSkins[self.scroll])
    self.skinModel = self.shopSkins[self.scroll]
    self.skinPrice = skins[self.shopSkins[self.scroll]] or 0
end

function SkinShop:response(...)
    exports.TR_dx:setResponseEnabled(false)
    if arg[1] then exports.TR_noti:create("Dış görünüm başarıyla satın alındı ​​ve envanterinize eklendi.", "success") end
end

function SkinShop:isMouseInPosition(x, y, width, height)
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

function SkinShop:getDimension()
    if self.shopName == "ranch" or self.shopName == "kc" or self.shopName == "gnocchi" then
        return getElementDimension(localPlayer)
    else
        return 10
    end
end

function SkinShop:canBuySkin()
    local plrData = getElementData(localPlayer, "characterData")
    if self.shopName == "kc" then
        if plrData.premium == "gold" or plrData.premium == "diamond" then return true end
        exports.TR_noti:create("Bu görünümü satın almak için bir Gold veya Diamond hesabına ihtiyacınız var.", "error")
        return false

    elseif self.shopName == "gnocchi" then
        if plrData.premium == "diamond" then return true end
        exports.TR_noti:create("Bu dış görünümü satın almak için bir Diamond hesabına ihtiyacınız var.", "error")
        return false
    end
    return true
end

function SkinShop:drawBackground(x, y, rx, ry, color, radius, post)
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


function createSkinShop(...)
    if guiInfo.skinShop then return end
    guiInfo.skinShop = SkinShop:create(...)
end
addEvent("createSkinShop", true)
addEventHandler("createSkinShop", root, createSkinShop)

function responseSkinShop(...)
    if not guiInfo.skinShop then return end
    guiInfo.skinShop:response(...)
end
addEvent("responseSkinShop", true)
addEventHandler("responseSkinShop", root, responseSkinShop)



-- local unused = {}

-- function render()
--     dxDrawText(inspect(unused), 400, 150, 1000, 1800, tocolor(255, 255, 255, 255), 1, "default", "left", "top", true, true)
-- end
-- addEventHandler("onClientRender", root, render)

-- function findUnUsed()
--     local allSkins = getValidPedModels()
--     local skins = {}
--     local findedSkins = {}
--     unused.unused = 0

--     for i, v in pairs(allSkins) do
--         skins[v] = true
--     end

--     for _, v in pairs(skinShops) do
--         for _, skin in pairs(v) do
--             if skins[skin] then
--                 findedSkins[skin] = true
--             end
--         end
--     end

--     for i, v in pairs(allSkins) do
--         if not findedSkins[v] then
--             table.insert(unused, v)
--             unused.unused = unused.unused + 1
--         end
--     end

--     unused.used = #allSkins - unused.unused
-- end
-- findUnUsed()