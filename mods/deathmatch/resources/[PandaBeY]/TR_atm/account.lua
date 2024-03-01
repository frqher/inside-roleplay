local sx, sy = guiGetScreenSize()

local guiData = {
    x = (sx - 400/zoom)/2,
    y = (sy - 440/zoom)/2,
    w = 400/zoom,
    h = 440/zoom,
}

exports.TR_dx:setOpenGUI(false)

Account = {}
Account.__index = Account

function Account:create(...)
    local instance = {}
    setmetatable(instance, Account)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function Account:constructor(...)
    self.alpha = 0
    self.fonts = {}
    self.fonts.big = exports.TR_dx:getFont(12)
    self.fonts.small = exports.TR_dx:getFont(10)
    self.logo = dxCreateTexture("files/images/logo.png", "argb", true, "clamp")

    self.buttons = {}
    self.buttons.create = exports.TR_dx:createButton((sx - 200/zoom)/2, guiData.y + guiData.h - 100/zoom, 200/zoom, 40/zoom, "Hesap oluşturun")
    self.buttons.close = exports.TR_dx:createButton((sx - 200/zoom)/2, guiData.y + guiData.h - 50/zoom, 200/zoom, 40/zoom, "İptal")

    self.edit = exports.TR_dx:createEdit((sx - 300/zoom)/2, guiData.y + guiData.h - 190/zoom, 300/zoom, 40/zoom, "PIN girin", true, false)
    exports.TR_dx:setButtonVisible(self.buttons, false)
    exports.TR_dx:setEditVisible(self.edit, false)
    exports.TR_dx:setEditLimit(self.edit, 8)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.button = function(...) self:button(...) end

    self:open()
    return true
end

function Account:destroy()
    removeEventHandler("onClientRender", root, self.func.render)

    exports.TR_dx:setOpenGUI(false)
    exports.TR_dx:destroyButton(self.buttons)

    guiData.account = nil
    self = nil
end

function Account:open()
    self.tick = getTickCount()
    self.state = "show"

    showCursor(true)
    exports.TR_dx:setOpenGUI(true)
    exports.TR_dx:showButton(self.buttons)
    exports.TR_dx:showEdit(self.edit)
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("guiButtonClick", root, self.func.button)
end

function Account:close()
    self.tick = getTickCount()
    self.state = "hide"

    showCursor(false)
    exports.TR_dx:hideButton(self.buttons)
    exports.TR_dx:hideEdit(self.edit)
    removeEventHandler("guiButtonClick", root, self.func.button)
end

function Account:animate()
    if self.state == "show" then
        local progress = (getTickCount() - self.tick)/600
        self.alpha = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "InOutQuad")

        if progress >= 1 then
            self.tick = getTickCount()
            self.alpha = 1
            self.state = "showed"
        end

    elseif self.state == "hide" then
        local progress = (getTickCount() - self.tick)/400
        self.alpha = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "InOutQuad")

        if progress >= 1 then
            self.tick = nil
            self.alpha = 0
            self.state = nil

            self:destroy()
        end
    end
end

function Account:render()
    self:animate()
    self:drawBackground(guiData.x, guiData.y, guiData.w, guiData.h, tocolor(17, 17, 17, 255 * self.alpha), 5)
    dxDrawImage((sx - 143/zoom)/2, guiData.y + 20/zoom, 143/zoom, 65/zoom, self.logo, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))

    dxDrawText("Bir banka hesabı oluşturmanın maliyeti #d4af37$200#999999'dur.\n\nATM'leri kullanırken\nkullanılacak olan #d4af37PIN#999999 kart kodunu girin.", guiData.x + 5/zoom, guiData.y + 75/zoom, guiData.x + guiData.w - 5/zoom, guiData.y + guiData.h - 200/zoom, tocolor(153, 153, 153, 255 * self.alpha), 1/zoom, self.fonts.big, "center", "center", true, true, false, true)
    dxDrawText("Unutma! PIN yalnızca rakamlardan oluşabilir!", guiData.x + 5/zoom, guiData.y + guiData.h - 145/zoom, guiData.x + guiData.w - 5/zoom, guiData.y + guiData.h - 100/zoom, tocolor(153, 153, 153, 255 * self.alpha), 1/zoom, self.fonts.small, "center", "top", true, true)
end


function Account:button(...)
    if arg[1] == self.buttons.create then
        local text = guiGetText(self.edit)
        if string.len(text) < 4 then exports.TR_noti:create("PIN kodu en az 4 haneli olmalıdır.", "error") return end
        if string.len(text) > 8 then exports.TR_noti:create("PIN maksimum 8 haneli olmalıdır.", "error") return end
        if tonumber(text) == nil then exports.TR_noti:create("PIN kodu yalnızca rakamlardan oluşmalıdır.", "error") return end

        self:close()
        triggerServerEvent("createPin", resourceRoot, text)

    elseif arg[1] == self.buttons.close then
        self:close()
    end
end


function Account:drawBackground(x, y, rx, ry, color, radius, post)
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


function createBankAccount(...)
    if guiData.account then return end
    guiData.account = Account:create(...)
end
addEvent("createBankAccount", true)
addEventHandler("createBankAccount", root, createBankAccount)