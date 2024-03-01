local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 600/zoom)/2,
    y = (sy - 410/zoom)/2,
    w = 600/zoom,
    h = 410/zoom,

    visibleItems = 10,
}

CreateItem = {}
CreateItem.__index = CreateItem

function CreateItem:create()
    local instance = {}
    setmetatable(instance, CreateItem)
    if instance:constructor() then
        return instance
    end
    return false
end

function CreateItem:constructor()
    self.scroll = 0

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.name = exports.TR_dx:getFont(12)

    self.buttons = {}
    self.buttons.createItem = exports.TR_dx:createButton(guiInfo.x + guiInfo.w - 260/zoom, guiInfo.y + guiInfo.h - 50/zoom, 250/zoom, 40/zoom, "Stwórz przedmiot", "green")

    self.edits = {}
    self.edits.itemValue = exports.TR_dx:createEdit(guiInfo.x + 10/zoom, guiInfo.y + guiInfo.h - 50/zoom, guiInfo.w - 280/zoom, 40/zoom, "Wartość przedmiotu")

    self.func = {}
    self.func.render = function() self:render() end
    self.func.onClick = function(...) self:onClick(...) end
    self.func.onScroll = function(...) self:onScroll(...) end
    self.func.buttonClick = function(...) self:buttonClick(...) end

    self:open()
    return true
end

function CreateItem:open()
    exports.TR_dx:setOpenGUI(true)

    showCursor(true)
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientClick", root, self.func.onClick)
    addEventHandler("guiButtonClick", root, self.func.buttonClick)
    addEventHandler("onClientKey", root, self.func.onScroll)
end

function CreateItem:close()
    exports.TR_dx:setOpenGUI(false)

    exports.TR_dx:destroyButton(self.buttons)
    exports.TR_dx:destroyEdit(self.edits)

    showCursor(false)
    removeEventHandler("onClientRender", root, self.func.render)
    removeEventHandler("onClientClick", root, self.func.onClick)
    removeEventHandler("guiButtonClick", root, self.func.buttonClick)
    removeEventHandler("onClientKey", root, self.func.onScroll)

    guiInfo.creator = nil
    self = nil
end

function CreateItem:render()
    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255), 4)
    dxDrawText("Tworzenie przedmiotów", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255), 1/zoom, self.fonts.main, "center", "center")

    for i = 1, guiInfo.visibleItems do
        local details = itemDetails[i + self.scroll]
        if details then
            local color = tocolor(220, 220, 220, 255)
            if self.selectedItem == i + self.scroll then
                dxDrawRectangle(guiInfo.x, guiInfo.y + 50/zoom + (i-1) * 30/zoom, guiInfo.w, 30/zoom, tocolor(27, 27, 27, 255))
                color = tocolor(212, 175, 55, 255)

            elseif self:isMouseInPosition(guiInfo.x, guiInfo.y + 50/zoom + (i-1) * 30/zoom, guiInfo.w, 30/zoom) then
                dxDrawRectangle(guiInfo.x, guiInfo.y + 50/zoom + (i-1) * 30/zoom, guiInfo.w, 30/zoom, tocolor(27, 27, 27, 255))
            end

            dxDrawImage(guiInfo.x + 20/zoom, guiInfo.y + 53/zoom + (i-1) * 30/zoom, 24/zoom, 24/zoom, string.format("files/images/items/%s.png", details.icon), 0, 0, 0, color)
            dxDrawText(details.name, guiInfo.x + 55/zoom, guiInfo.y + 50/zoom + (i-1) * 30/zoom, guiInfo.x + guiInfo.w, guiInfo.y + 80/zoom + (i-1) * 30/zoom, color, 1/zoom, self.fonts.name, "left", "center")
        end
    end
end

function CreateItem:onClick(...)
    if exports.TR_dx:isResponseEnabled() then return end
    for i = 1, guiInfo.visibleItems do
        local details = itemDetails[i + self.scroll]
        if details then
            if self:isMouseInPosition(guiInfo.x, guiInfo.y + 50/zoom + (i-1) * 30/zoom, guiInfo.w, 30/zoom) then
                self:selectItem(i + self.scroll, details)
                break
            end
        end
    end
end

function CreateItem:onScroll(...)
    if exports.TR_dx:isResponseEnabled() then return end
    if arg[1] == "mouse_wheel_up" then
        self.scroll = math.max(self.scroll - 1, 0)
    elseif arg[1] == "mouse_wheel_down" then
        self.scroll = math.min(self.scroll + 1, #itemDetails - guiInfo.visibleItems)
    end
end

function CreateItem:selectItem(index, details)
    self.selectedItem = index

    if details.defaultAdminValue then
        exports.TR_dx:setEditText(self.edits.itemValue, details.defaultAdminValue)
    else
        exports.TR_dx:setEditText(self.edits.itemValue, "")
    end
end

function CreateItem:buttonClick(...)
    if arg[1] == self.buttons.createItem then
        if not self.selectedItem then exports.TR_noti:create("Nie wybrałeś żadnego przedmiotu.", "error") return end
        local value = guiGetText(self.edits.itemValue)
        -- if string.len(value) > 0 and tonumber(value) == nil then exports.TR_noti:create("Wartość musi być liczbą.", "error") return end
        if value == "" or string.len(value) < 1 then value = false end

        exports.TR_dx:setResponseEnabled(true)
        triggerServerEvent("createAdminItem", resourceRoot, itemDetails[self.selectedItem], value)
    end
end

function CreateItem:response()
    exports.TR_dx:setResponseEnabled(false)
    exports.TR_noti:create(string.format("Przedmiot %s został pomyślnie utworzony.", itemDetails[self.selectedItem].name), "success")
end



function CreateItem:isMouseInPosition(x, y, width, height)
    if (not isCursorShowing()) then return false end
    local cx, cy = getCursorPosition()
    local cx, cy = (cx*sx), (cy*sy)
    if (cx >= x and cx <= x + width) and (cy >= y and cy <= y + height) then return true end
    return false
end

function CreateItem:drawBackground(x, y, rx, ry, color, radius, post)
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


function createAdminItemCreator()
    if guiInfo.creator then
        guiInfo.creator:close()
        return
    end
    if not exports.TR_dx:canOpenGUI() then return end
    guiInfo.creator = CreateItem:create()
end
addEvent("createAdminItemCreator", true)
addEventHandler("createAdminItemCreator", root, createAdminItemCreator)

function createAdminItemCreatorResponse()
    if not guiInfo.creator then return end
    guiInfo.creator:response()
end
addEvent("createAdminItemCreatorResponse", true)
addEventHandler("createAdminItemCreatorResponse", root, createAdminItemCreatorResponse)