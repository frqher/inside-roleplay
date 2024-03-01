local sx, sy = guiGetScreenSize()

local guiInfo = {
    x = (sx - 600/zoom)/2,
    y = (sy - 384/zoom)/2,
    w = 600/zoom,
    h = 384/zoom,
}

CheckLicence = {}
CheckLicence.__index = CheckLicence

function CheckLicence:create(...)
    local instance = {}
    setmetatable(instance, CheckLicence)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function CheckLicence:constructor(...)
    self.data = arg[1][1]
    self.alpha = 0

    self.fonts = {}
    self.fonts.number = exports.TR_dx:getFont(17)
    self.fonts.data = exports.TR_dx:getFont(14)
    self.fonts.us = exports.TR_dx:getFont(10)

    self.licenceFront = dxCreateRenderTarget(guiInfo.w, guiInfo.h, true)
    self.textures = {}
    self.textures.licence = dxCreateTexture("files/images/licences/licence.png", "argb", true, "clamp")

    self.func = {}
    self.func.render = function() self:render() end
    self.func.click = function(...) self:click(...) end

    self:open()
    self:updateRender()
    return true
end

function CheckLicence:updateRender()
    dxSetRenderTarget(self.licenceFront, true)
    dxSetBlendMode("modulate_add")
    dxDrawImage(0, 0, guiInfo.w, guiInfo.h, self.textures.licence)

    -- Licence number
    dxDrawText(string.format("#5f48b0DL #701a01%s", self:getLicenceNumber()), 210/zoom, 113/zoom, guiInfo.w, guiInfo.h, tocolor(112, 26, 1, 255), 1/zoom, self.fonts.number, "left", "top", false, false, false, true)

    -- Right
    dxDrawText(string.format("#5f48b0CLASS #701a01%s", self:getCategories()), 470/zoom, 140/zoom, guiInfo.w, guiInfo.h, tocolor(112, 26, 1, 255), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)
    dxDrawText("#5f48b0END #701a01NONE", 470/zoom, 160/zoom, guiInfo.w, guiInfo.h, tocolor(112, 26, 1, 255), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)

    -- Center
    dxDrawText(string.format("#5f48b0FN #701a01%s", string.upper(self.data.username)), 210/zoom, 180/zoom, guiInfo.w, guiInfo.h, tocolor(112, 26, 1, 255), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)
    dxDrawText(string.format("#5f48b0DOB #701a01%s", self:formatDate(self.data.created)), 210/zoom, 200/zoom, guiInfo.w, guiInfo.h, tocolor(112, 26, 1, 255), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)

    -- Down
    dxDrawText(string.format("#5f48b0DOR #701a01%s", self:formatDate(self.data.licenceCreated)), 210/zoom, 260/zoom, guiInfo.w, guiInfo.h, tocolor(112, 26, 1, 255), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)
    dxDrawText("#5f48b0SSN #701a01ON FILE", 210/zoom, 280/zoom, guiInfo.w, guiInfo.h, tocolor(112, 26, 1, 255), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)

    -- US
    dxDrawText("#5f48b0US", 270/zoom, 345/zoom, guiInfo.w, guiInfo.h, tocolor(112, 26, 1, 255), 1/zoom, self.fonts.data, "left", "top", false, false, false, true)
    dxDrawText(string.format("#000000%s1266737RP/AMER/19", self:formatDate(self.data.licenceCreated, "/")), 298/zoom, 350/zoom, guiInfo.w, guiInfo.h, tocolor(112, 26, 1, 255), 1/zoom, self.fonts.us, "left", "top", false, false, false, true)

    dxSetRenderTarget()
    dxSetBlendMode("blend")
end

function CheckLicence:getCategories()
    local licenceString = ""
    local licences = fromJSON(self.data.licence)
    for i, v in pairs(licences) do
        if i == "a" or i == "b" or i == "c" then
            licenceString = string.format("%s%s,", licenceString, string.upper(i))
        end
    end
    return string.sub(licenceString, 0, string.len(licenceString) - 1)
end

function CheckLicence:getLicenceNumber()
    return string.format("638373674389%d", 1100 + self.data.UID)
end

function CheckLicence:formatDate(date, symbol)
    if not symbol then symbol = "." end
    local d = split(date, " ")
    local y = split(d[1], "-")
    return string.format("%s%s%s%s%s", y[3], symbol, y[2], symbol, y[1])
end


function CheckLicence:open()
    exports.TR_dx:setOpenGUI(true)
    self.alpha = 0
    self.state = "opening"
    self.tick = getTickCount()

    showCursor(true)

    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientClick", root, self.func.click)
end

function CheckLicence:close()
    exports.TR_dx:setOpenGUI(false)
    self.alpha = 1
    self.state = "closing"
    self.tick = getTickCount()

    showCursor(false)
    removeEventHandler("onClientClick", root, self.func.click)
end

function CheckLicence:destroy()
    removeEventHandler("onClientRender", root, self.func.render)
    guiInfo.licence = nil
    self = nil
end


function CheckLicence:animate()
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

function CheckLicence:render()
    self:animate()
    dxDrawImage(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, self.licenceFront, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
end


function CheckLicence:click(...)
    if arg[2] == "up" then return end
    if arg[1] == "left" then
        self:close()
    end
end


function openPlayerLicence(state, ...)
    exports.TR_dx:setResponseEnabled(false)

    if type(state) == "string" then
        if state == "veh" then
            exports.TR_noti:create("W pojeździe nie ma kierowcy.", "error")
        else
            exports.TR_noti:create("Ten gracz nie posiada prawa jazdy.", "licence")
        end
        return
    end
    if guiInfo.licence then return end
    guiInfo.licence = CheckLicence:create(...)
end
addEvent("openPlayerLicence", true)
addEventHandler("openPlayerLicence", root, openPlayerLicence)