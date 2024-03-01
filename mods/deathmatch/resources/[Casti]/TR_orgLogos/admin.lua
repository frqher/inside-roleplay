local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 800/zoom)/2,
    y = (sy - 500/zoom)/2,
    w = 800/zoom,
    h = 500/zoom,
}

AdminLogos = {}
AdminLogos.__index = AdminLogos

function AdminLogos:create(...)
    local instance = {}
    setmetatable(instance, AdminLogos)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function AdminLogos:constructor(...)
    self.orgRequests = arg[1]
    self.scroll = 0
    self.loadingRot = 0
    self.loadedNewLogo = false

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.text = exports.TR_dx:getFont(12)
    self.fonts.loading = exports.TR_dx:getFont(10)

    self.buttons = {}
    self.buttons.exit = exports.TR_dx:createButton(guiInfo.x + (guiInfo.w - 250/zoom)/2, guiInfo.y + guiInfo.h - 50/zoom, 250/zoom, 40/zoom, "Kaydet ve yeniden yükle")

    self.func = {}
    self.func.render = function() self:render() end
    self.func.buttonClick = function(...) self:buttonClick(...) end
    self.func.mouseClick = function(...) self:mouseClick(...) end

    self:open()
    return true
end

function AdminLogos:open()
    showCursor(true)
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("guiButtonClick", root, self.func.buttonClick)
    addEventHandler("onClientClick", root, self.func.mouseClick)
end

function AdminLogos:destroy()
    local reloadResource = self.loadedNewLogo
    for i, v in pairs(self.orgRequests) do
        if isElement(v.newImage) then destroyElement(v.newImage) end
    end

    exports.TR_dx:destroyButton(self.buttons)

    removeEventHandler("onClientRender", root, self.func.render)
    removeEventHandler("guiButtonClick", root, self.func.buttonClick)
    removeEventHandler("onClientClick", root, self.func.mouseClick)

    showCursor(false)
    guiInfo.window = nil
    self = nil

    if reloadResource then
        triggerServerEvent("reloadLogos", resourceRoot)
    else
        exports.TR_noti:create("Tüm değişiklikler başarıyla kaydedildi.", "success")
    end
end

function AdminLogos:render()
    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255), 4)
    dxDrawText("Faction logosundaki değişikliklerin bildirimleri", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(212, 175, 55, 255), 1/zoom, self.fonts.main, "center", "center")

    dxDrawRectangle(guiInfo.x, guiInfo.y + 50/zoom, guiInfo.w, 2/zoom, tocolor(27, 27, 27, 255))
    dxDrawText("Faction adı", guiInfo.x + 20/zoom, guiInfo.y + 60/zoom, guiInfo.x + guiInfo.w, guiInfo.y + 80/zoom, tocolor(170, 170, 170, 255), 1/zoom, self.fonts.text, "left", "top")
    dxDrawText("Eski logo", guiInfo.x + 250/zoom, guiInfo.y + 60/zoom, guiInfo.x + 350/zoom, guiInfo.y + 80/zoom, tocolor(170, 170, 170, 255), 1/zoom, self.fonts.text, "center", "top")
    dxDrawText("Yeni logo", guiInfo.x + 450/zoom, guiInfo.y + 60/zoom, guiInfo.x + 550/zoom, guiInfo.y + 80/zoom, tocolor(170, 170, 170, 255), 1/zoom, self.fonts.text, "center", "top")
    dxDrawText("Paylaş", guiInfo.x + 600/zoom, guiInfo.y + 60/zoom, guiInfo.x + 800/zoom, guiInfo.y + 80/zoom, tocolor(170, 170, 170, 255), 1/zoom, self.fonts.text, "center", "top")

    for i = 1, 3 do
        local v = self.orgRequests[i + self.scroll]
        if v then
            dxDrawText(string.format("%s\n(%s)", v.name, v.type == "org" and "Prywatna" or "Przestępcza"), guiInfo.x + 20/zoom, guiInfo.y + 90/zoom + (i-1) * 110/zoom, guiInfo.x + 230/zoom, guiInfo.y + 90/zoom + i * 110/zoom, tocolor(170, 170, 170, 255), 1/zoom, self.fonts.text, "left", "center", true, true)

            local currentLogo = self:getLogo(v.ID)
            if currentLogo then
                if fileExists(currentLogo) then
                    dxDrawImage(guiInfo.x + 250/zoom, guiInfo.y + 90/zoom + (i-1) * 110/zoom, 100/zoom, 100/zoom, currentLogo)
                else
                    dxDrawText("BRAK", guiInfo.x + 250/zoom, guiInfo.y + 90/zoom + (i-1) * 110/zoom, guiInfo.x + 350/zoom, guiInfo.y + 90/zoom + i * 110/zoom, tocolor(170, 170, 170, 255), 1/zoom, self.fonts.main, "center", "center")
                end
            else
                dxDrawText("BRAK", guiInfo.x + 250/zoom, guiInfo.y + 90/zoom + (i-1) * 110/zoom, guiInfo.x + 350/zoom, guiInfo.y + 90/zoom + i * 110/zoom, tocolor(170, 170, 170, 255), 1/zoom, self.fonts.main, "center", "center")
            end

            if v.newImage then
                dxDrawImage(guiInfo.x + 450/zoom, guiInfo.y + 90/zoom + (i-1) * 110/zoom, 100/zoom, 100/zoom, v.newImage)

                if v.invalidFormat then
                    dxDrawImage(guiInfo.x + 655/zoom, guiInfo.y + 124/zoom + (i-1) * 110/zoom, 32/zoom, 32/zoom, "files/images/accept.png", 0, 0, 0, tocolor(50, 120, 50, 150))

                    if self:isMouseInPosition(guiInfo.x + 655/zoom, guiInfo.y + 124/zoom + (i-1) * 110/zoom, 32/zoom, 32/zoom) then
                        local cx, cy = getCursorPosition()
                        local cx, cy = cx * sx, cy * sy

                        dxDrawRectangle(cx, cy, 200/zoom, 40/zoom, tocolor(27, 27, 27, 255), true)
                        dxDrawText("Bu logo tüm gereksinimleri karşılamıyor (yanlış resim boyutu).", cx, cy, cx + 200/zoom, cy + 40/zoom, tocolor(255, 255, 255, 200), 1/zoom, self.fonts.loading, "center", "center", false, true, true)
                    end
                else
                    if self:isMouseInPosition(guiInfo.x + 655/zoom, guiInfo.y + 124/zoom + (i-1) * 110/zoom, 32/zoom, 32/zoom) then
                        dxDrawImage(guiInfo.x + 655/zoom, guiInfo.y + 124/zoom + (i-1) * 110/zoom, 32/zoom, 32/zoom, "files/images/accept.png", 0, 0, 0, tocolor(70, 170, 70, 255))
                    else
                        dxDrawImage(guiInfo.x + 655/zoom, guiInfo.y + 124/zoom + (i-1) * 110/zoom, 32/zoom, 32/zoom, "files/images/accept.png", 0, 0, 0, tocolor(50, 120, 50, 255))
                    end
                end
                if self:isMouseInPosition(guiInfo.x + guiInfo.w - 55/zoom - 32/zoom, guiInfo.y + 124/zoom + (i-1) * 110/zoom, 32/zoom, 32/zoom) then
                    dxDrawImage(guiInfo.x + guiInfo.w - 55/zoom - 32/zoom, guiInfo.y + 124/zoom + (i-1) * 110/zoom, 32/zoom, 32/zoom, "files/images/decline.png", 0, 0, 0, tocolor(170, 70, 70, 255))
                else
                    dxDrawImage(guiInfo.x + guiInfo.w - 55/zoom - 32/zoom, guiInfo.y + 124/zoom + (i-1) * 110/zoom, 32/zoom, 32/zoom, "files/images/decline.png", 0, 0, 0, tocolor(120, 50, 50, 255))
                end
            else
                dxDrawImage(guiInfo.x + 484/zoom, guiInfo.y + 115/zoom + (i-1) * 110/zoom, 32/zoom, 32/zoom, "files/images/loading.png", self.loadingRot, 0, 0, tocolor(120, 120, 120, 255))
                dxDrawText("Yükleniyor...", guiInfo.x + 450/zoom, guiInfo.y + 153/zoom + (i-1) * 110/zoom, guiInfo.x + 550/zoom, guiInfo.y + 90/zoom + i * 110/zoom, tocolor(120, 120, 120, 255), 1/zoom, self.fonts.loading, "center", "top")
            end
        end
    end

    if #self.orgRequests > 3 then
        dxDrawText(string.format("Ve %d daha fazlasını bildiriyor...", #self.orgRequests - 3), sx/2, guiInfo.y, sx/2, guiInfo.y + guiInfo.h - 55/zoom, tocolor(120, 120, 120, 255), 1/zoom, self.fonts.loading, "center", "bottom")
    end

    self.loadingRot = self.loadingRot + 4
    if self.loadingRot >= 360 then self.loadingRot = self.loadingRot - 360 end
end

function AdminLogos:buttonClick(...)
    if exports.TR_dx:isResponseEnabled() then return end

    if arg[1] == self.buttons.exit then
        self:destroy()
    end
end

function AdminLogos:mouseClick(...)
    if exports.TR_dx:isResponseEnabled() then return end

    if arg[1] == "left" and arg[2] == "down" then
        for i = 1, 3 do
            local v = self.orgRequests[i + self.scroll]
            if v then
                if self:isMouseInPosition(guiInfo.x + 655/zoom, guiInfo.y + 124/zoom + (i-1) * 110/zoom, 32/zoom, 32/zoom) and not v.invalidFormat then
                    exports.TR_dx:setResponseEnabled(true)

                    self.selectedIndex = i + self.scroll
                    triggerServerEvent("acceptOrganizationNewLogo", resourceRoot, v.ID, v.url)
                    return

                elseif self:isMouseInPosition(guiInfo.x + guiInfo.w - 55/zoom - 32/zoom, guiInfo.y + 124/zoom + (i-1) * 110/zoom, 32/zoom, 32/zoom) then
                    exports.TR_dx:setResponseEnabled(true)

                    self.selectedIndex = i + self.scroll
                    triggerServerEvent("declineOrganizationNewLogo", resourceRoot, v.ID)
                    return
                end
            end
        end
    end
end

function AdminLogos:uploadNewImage(...)
    for i, v in pairs(self.orgRequests) do
        if v.name == arg[1] then
            if arg[2] then
                v.url = arg[4]
                v.newImage = dxCreateTexture(arg[3], "argb", true, "clamp")

                local width, height = dxGetPixelsSize(arg[3])
                v.invalidFormat = width ~= 400 and true or height ~= 400 and true or false
            end
            break
        end
    end
end

function AdminLogos:response(...)
    if arg[1] == "declined" then
        local org = self.orgRequests[self.selectedIndex]
        if isElement(org.newImage) then destroyElement(org.newImage) end

        exports.TR_noti:create(string.format("%s'nin yeni logosu reddedildi.", org.name), "error")
        table.remove(self.orgRequests, self.selectedIndex)

    elseif arg[1] == "saved" then
        local org = self.orgRequests[self.selectedIndex]
        if isElement(org.newImage) then destroyElement(org.newImage) end

        exports.TR_noti:create(string.format("Yeni %s faction logosu yüklendi.", org.name), "success")
        table.remove(self.orgRequests, self.selectedIndex)
        self.loadedNewLogo = true

    elseif arg[1] == "saveError" then
        local org = self.orgRequests[self.selectedIndex]
        if isElement(org.newImage) then destroyElement(org.newImage) end

        exports.TR_noti:create(string.format("Yeni %s faction logosu kaydedilirken bir hata oluştu.", org.name), "error")
        table.remove(self.orgRequests, self.selectedIndex)
        self.loadedNewLogo = true
    end

    exports.TR_dx:setResponseEnabled(false)
end

function AdminLogos:drawBackground(x, y, rx, ry, color, radius, post)
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

function AdminLogos:isMouseInPosition(x, y, width, height)
    if (not isCursorShowing()) then return false end
    local cx, cy = getCursorPosition()
    local cx, cy = (cx*sx), (cy*sy)
    if (cx >= x and cx <= x + width) and (cy >= y and cy <= y + height) then return true end
    return false
end

function AdminLogos:getLogo(orgID)
    if fileExists(string.format("files/logos/%d.png", orgID)) then
        return string.format("/files/logos/%d.png", orgID)
    end
    return false
end

function createAdminOrgLogos(...)
    if guiInfo.window then return end
    guiInfo.window = AdminLogos:create(...)
end
addEvent("createAdminOrgLogos", true)
addEventHandler("createAdminOrgLogos", root, createAdminOrgLogos)

function loadOrganizationAdminImage(...)
    if not guiInfo.window then return end
    guiInfo.window:uploadNewImage(...)
end
addEvent("loadOrganizationAdminImage", true)
addEventHandler("loadOrganizationAdminImage", root, loadOrganizationAdminImage)

function responseAdminOrgLogos(...)
    if not guiInfo.window then return end

    setTimer(function()
        guiInfo.window:response(unpack(arg))
    end, 1000, 1)
end
addEvent("responseAdminOrgLogos", true)
addEventHandler("responseAdminOrgLogos", root, responseAdminOrgLogos)

exports.TR_dx:setResponseEnabled(false)