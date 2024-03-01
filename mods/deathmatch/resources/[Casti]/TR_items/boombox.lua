local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 350/zoom)/2,
    y = (sy - 300/zoom)/2,
    w = 350/zoom,
    h = 300/zoom,
}

Boombox = {}
Boombox.__index = Boombox

function Boombox:create(...)
    local instance = {}
    setmetatable(instance, Boombox)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function Boombox:constructor(...)
    self.useType = arg[1]
    self.itemID = arg[2]
    self.alpha = 1

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.info = exports.TR_dx:getFont(10)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.buttonClick = function(...) self:buttonClick(...) end

    self.edits = {}
    self.edits.url = exports.TR_dx:createEdit((sx - 250/zoom)/2, guiInfo.y + 100/zoom, 250/zoom, 40/zoom, "URL utworu")

    self.buttons = {}
    self.buttons.exit = exports.TR_dx:createButton((sx - 250/zoom)/2, guiInfo.y + guiInfo.h - 50/zoom, 250/zoom, 40/zoom, "Anuluj", "red")

    if self.useType == "hand" then
        self.buttons.use = exports.TR_dx:createButton((sx - 250/zoom)/2, guiInfo.y + guiInfo.h - 100/zoom, 250/zoom, 40/zoom, "Weź do ręki", "green")

    elseif self.useType == "ground" then
        self.buttons.use = exports.TR_dx:createButton((sx - 250/zoom)/2, guiInfo.y + guiInfo.h - 100/zoom, 250/zoom, 40/zoom, "Połóż na ziemi", "green")

    elseif self.useType == "change" then
        self.buttons.use = exports.TR_dx:createButton((sx - 250/zoom)/2, guiInfo.y + guiInfo.h - 100/zoom, 250/zoom, 40/zoom, "Zmień piosenkę", "green")
    end

    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("guiButtonClick", root, self.func.buttonClick)
    return true
end

function Boombox:close()
    self.tick = getTickCount()

    exports.TR_dx:hideEdit(self.edits)
    exports.TR_dx:hideButton(self.buttons)

    removeEventHandler("guiButtonClick", root, self.func.buttonClick)
end

function Boombox:destroy()
    GUI.eq.boombox = nil
    GUI.eq.blockHover = nil
    GUI.eq.selectedItem = nil
    GUI.eq.acceptDetails = nil

    exports.TR_dx:destroyEdit(self.edits)
    exports.TR_dx:destroyButton(self.buttons)

    removeEventHandler("onClientRender", root, self.func.render)
    self = nil
end

function Boombox:animate()
    if not self.tick then return end
    local progress = (getTickCount() - self.tick)/500
    self.alpha = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "Linear")

    if progress >= 1 then
        self:destroy()
        return true
    end
end

function Boombox:render()
    if self:animate() then return end
    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 4)
    dxDrawText("Boombox", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")
    dxDrawText("Wklej poniżej link do YouTube lub bezpośredni link do pliku audio aby móc słuchać swojej ulubionej muzyki.", guiInfo.x + 10/zoom, guiInfo.y + 50/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h - 110/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "top", true, true)
    dxDrawText("Rozszerzenia plików, które są kompatybilne: MP3, WAV, OGG, RIFF, MOD, XM, IT, S3M.", guiInfo.x + 20/zoom, guiInfo.y + 155/zoom, guiInfo.x + guiInfo.w - 20/zoom, guiInfo.y + guiInfo.h - 110/zoom, tocolor(163, 47, 47, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "top", true, true)
end

function Boombox:buttonClick(btn)
    if btn == self.buttons.use then
        if getPedOccupiedVehicle(localPlayer) then exports.TR_noti:create("Nie możesz korzystać z boomboxa w pojeździe.", "error") return end

        local url = guiGetText(self.edits.url)
        if not url or string.len(url) < 1 then exports.TR_noti:create("Link jest niepoprawny.", "error") return end
        if not string.starts(url, "https://") and not string.starts(url, "http://") then exports.TR_noti:create("Link jest niepoprawny.", "error") return end

        if self.useType == "hand" then
            triggerServerEvent("takeBoomboxToHand", resourceRoot, self.itemID, url)

        elseif self.useType == "ground" then
            triggerServerEvent("placeBoomboxOnGround", resourceRoot, self.itemID, url)

        elseif self.useType == "change" then
            triggerServerEvent("playBoomboxMusic", resourceRoot, url)

        end
        GUI.eq:setBoomboxUsed(self.itemID, true)
        self:close()

    elseif btn == self.buttons.exit then
        GUI.eq.boombox = nil
        GUI.eq.blockHover = nil
        GUI.eq.selectedItem = nil
        GUI.eq.acceptDetails = nil

        exports.TR_dx:destroyEdit(self.edits)
        exports.TR_dx:destroyButton(self.buttons)

        removeEventHandler("guiButtonClick", root, self.func.buttonClick)
        removeEventHandler("onClientRender", root, self.func.render)
    end
end

function Boombox:drawBackground(x, y, rx, ry, color, radius, post)
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

function string.starts(String,Start)
    return string.sub(String,1,string.len(Start))==Start
end