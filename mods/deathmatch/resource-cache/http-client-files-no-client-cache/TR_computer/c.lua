local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 800/zoom)/zoom,
    y = (sx - 800/zoom)/zoom,
    w = 800/zoom,
    h = 800/zoom,

    logo =  {
        x = (sx - 400/zoom)/2,
        y = (sy - 400/zoom)/2,
        w = 400/zoom,
        h = 400/zoom,
    },

    bar = {
        x = 0,
        y = sy - 40/zoom,
        w = sx,
        h = 40/zoom,
    },

    noti = {
        x = sx - 400/zoom,
        y = 0,
        w = 400/zoom,
        h = sy - 40/zoom,
    },

    info = {
        x = sx - 300/zoom,
        y = sy - 40/zoom - 70/zoom ,
        w = 300/zoom,
        h = 70/zoom,
    },

    accept = {
        x = (sx - 350/zoom)/2,
        y = (sy - 110/zoom)/2,
        w = 350/zoom,
        h = 110/zoom,
    },

    addObject = {
        x = (sx - 350/zoom)/2,
        y = (sy - 150/zoom)/2,
        w = 350/zoom,
        h = 150/zoom,
    },

    app = {
        x = (sx - 900/zoom)/2,
        y = (sy - 600/zoom)/2,
        w = 900/zoom,
        h = 600/zoom,
    },

    fullApp = {
        x = 0,
        y = 0,
        w = sx,
        h = sy - 40/zoom,
    },
}


Computer = {}
Computer.__index = Computer

function Computer:create(...)
    local instance = {}
    setmetatable(instance, Computer)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function Computer:constructor(...)
    self.alpha = 0
    self.fractionID = arg[1]
    self.fractionType = arg[2]
    self.computerType = arg[3]

    self.playerName = getPlayerName(localPlayer)

    self.cursorImg = "cursor"
    self.scroll = 0

    self.refreshAngle = 0
    self.refreshCount = 0

    self.edits = nil
    self.checks = nil

    self.fonts = {}
    self.fonts.orgName = dxCreateFont("files/fonts/font.ttf", 20, true)
    self.fonts.upgradeName = dxCreateFont("files/fonts/font.ttf", 16, true)
    self.fonts.orgInfo = dxCreateFont("files/fonts/font.ttf", 16)
    self.fonts.infoApp = dxCreateFont("files/fonts/font.ttf", 14)
    self.fonts.titleApp = dxCreateFont("files/fonts/font.ttf", 12)
    self.fonts.closeApp = dxCreateFont("files/fonts/font.ttf", 11)
    self.fonts.icons = dxCreateFont("files/fonts/font.ttf", 10)

    self.notiTextHeight = dxGetFontHeight(1/zoom, self.fonts.icons)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.mouseClick = function(...) self:mouseClick(...) end
    self.func.scrollKey = function(...) self:scrollKey(...) end
    self.func.selectCheckbox = function(...) self:selectCheckbox(...) end
    self.func.buildOrganizationLogo = function(...) self:buildOrganizationLogo(...) end

    self:getComputerApps()
    self:buildTextures()
    self:open()
    return true
end

function Computer:buildTextures()
    self.textures = {}

    if self.fractionType == "police" then
        self.textures.wallpaper = dxCreateTexture("files/images/wallpaper_1.png", "argb", true, "clamp")

    elseif self.fractionType == "fire" then
        self.textures.wallpaper = dxCreateTexture("files/images/wallpaper_2.png", "argb", true, "clamp")

    elseif self.fractionType == "medic" then
        self.textures.wallpaper = dxCreateTexture("files/images/wallpaper_3.png", "argb", true, "clamp")

    elseif self.fractionType == "ers" then
        self.textures.wallpaper = dxCreateTexture("files/images/wallpaper_6.png", "argb", true, "clamp")

    elseif self.fractionType == "crime" then
        self.textures.wallpaper = dxCreateTexture("files/images/wallpaper_4.png", "argb", true, "clamp")

    else
        self.textures.wallpaper = dxCreateTexture("files/images/wallpaper_5.png", "argb", true, "clamp")
    end

    self.textures.cursor = dxCreateTexture("files/images/cursor.png", "argb", true, "clamp")
    self.textures.pointer = dxCreateTexture("files/images/pointer.png", "argb", true, "clamp")
    self.textures.windows = dxCreateTexture("files/images/windows.png", "argb", true, "clamp")
    self.textures.icons = dxCreateTexture("files/images/icons.png", "argb", true, "clamp")
    self.textures.noti = dxCreateTexture("files/images/noti.png", "argb", true, "clamp")

    self.textures.bin = dxCreateTexture("files/images/bin.png", "argb", true, "clamp")
    self.textures.folder_person = dxCreateTexture("files/images/folder_person.png", "argb", true, "clamp")
    self.textures.folder_vehicle = dxCreateTexture("files/images/folder_vehicle.png", "argb", true, "clamp")
    self.textures.folder_ranks = dxCreateTexture("files/images/folder_ranks.png", "argb", true, "clamp")
    self.textures.settings = dxCreateTexture("files/images/settings.png", "argb", true, "clamp")
    self.textures.info = dxCreateTexture("files/images/info.png", "argb", true, "clamp")
    self.textures.upgrade = dxCreateTexture("files/images/upgrade.png", "argb", true, "clamp")
    self.textures.earnings = dxCreateTexture("files/images/earnings.png", "argb", true, "clamp")
    self.textures.web = dxCreateTexture("files/images/web.png", "argb", true, "clamp")
    self.textures.darkweb = dxCreateTexture("files/images/darkweb.png", "argb", true, "clamp")

    self.textures.person_info = dxCreateTexture("files/images/person_info.png", "argb", true, "clamp")
    self.textures.vehicle_info = dxCreateTexture("files/images/vehicle_info.png", "argb", true, "clamp")
    self.textures.ranks_info = dxCreateTexture("files/images/ranks_info.png", "argb", true, "clamp")

    self.textures.weapon_dark = dxCreateTexture("files/images/weapon_dark.png", "argb", true, "clamp")
    self.textures.drugs_dark = dxCreateTexture("files/images/drugs_dark.png", "argb", true, "clamp")

    self.textures.upgrade_person = dxCreateTexture("files/images/upgrade_person.png", "argb", true, "clamp")
    self.textures.upgrade_vehicle = dxCreateTexture("files/images/upgrade_vehicle.png", "argb", true, "clamp")
    self.textures.upgrade_money = dxCreateTexture("files/images/upgrade_money.png", "argb", true, "clamp")

    self.textures.close = dxCreateTexture("files/images/close.png", "argb", true, "clamp")
    self.textures.minimalize = dxCreateTexture("files/images/minimalize.png", "argb", true, "clamp")
    self.textures.resize_up = dxCreateTexture("files/images/resize_up.png", "argb", true, "clamp")
    self.textures.resize_down = dxCreateTexture("files/images/resize_down.png", "argb", true, "clamp")
    self.textures.shutdown = dxCreateTexture("files/images/shutdown.png", "argb", true, "clamp")

    self.textures.rank = dxCreateTexture("files/images/rank.png", "argb", true, "clamp")
    self.textures.more = dxCreateTexture("files/images/more.png", "argb", true, "clamp")
    self.textures.selected = dxCreateTexture("files/images/selected.png", "argb", true, "clamp")
    self.textures.add = dxCreateTexture("files/images/add.png", "argb", true, "clamp")
    self.textures.edit = dxCreateTexture("files/images/edit.png", "argb", true, "clamp")
    self.textures.dollar = dxCreateTexture("files/images/dollar.png", "argb", true, "clamp")

    self.textures.error = dxCreateTexture("files/images/error.png", "argb", true, "clamp")
    self.textures.success = dxCreateTexture("files/images/success.png", "argb", true, "clamp")
end

function Computer:loadData(ranks, players, vehicles, computerInfo, orgInfo, orgEarn)
    if ranks then
        self.leaderData.folder_ranks = {}
        for i, v in pairs(ranks) do
            table.insert(self.leaderData.folder_ranks, {
                ID = v.ID,
                level = v.level,
                name = v.rankName,
                canManage = v.canManage and true or false,
                veh1 = v.veh1,
                veh2 = v.veh2,
                veh3 = v.veh3,
                veh4 = v.veh4,
                veh5 = v.veh5,
                veh6 = v.veh6,
            })
        end

        table.sort(self.leaderData.folder_ranks, function(a, b) return a.level < b.level end)
    end

    if players then
        self.leaderData.folder_person = {}
        for i, v in pairs(players) do
            table.insert(self.leaderData.folder_person, {
                UID = v.UID,
                name = v.username,
                rankID = v.rankID,
                skin = tonumber(v.skin),
                added = self:formatDate(v.added),
                created = self:formatDate(v.created),
                lastOnline = self:formatDate(v.lastOnline),
                toPay = v.toPay,
                allEarn = v.allEarn,
                allPaid = v.allPaid,

                weekDutyTime = v.weekDutyTime and self:minutesToTime(v.weekDutyTime) or 0,
                todayDutyTime = v.todayDutyTime and self:minutesToTime(v.todayDutyTime) or 0,
            })
        end
    end

    if vehicles then
        self.leaderData.folder_vehicle = {}

        if self.computerType == "fraction" then
            for i, v in pairs(vehicles) do
                table.insert(self.leaderData.folder_vehicle, {
                    vehicle = v,
                    name = self:getVehicleName(v),
                    model = getElementModel(v),
                    color = {getVehicleColor(v)},
                })
            end

        elseif self.computerType == "organization" then
            for i, v in pairs(vehicles) do
                local veh = getElementByID("vehicle"..v.ID)

                table.insert(self.leaderData.folder_vehicle, {
                    ID = v.ID,
                    vehicle = veh,
                    name = self:getVehicleName(v.model),
                    model = v.model,
                    tuning = v.tuning and fromJSON(v.tuning) or false,
                    paintjob = v.paintjob,
                    color = split(v.color, ","),
                    ownedOrg = v.ownedOrg,
                    requestOrg = v.requestOrg,
                    textColor = v.requestOrg and {120, 176, 173} or false
                })
            end
        end
    end

    if computerInfo then
        self.notifications = computerInfo
    end

    if orgInfo then
        self.leaderData.info = orgInfo
        self.leaderData.info.created = self:formatDate(orgInfo.created)
        self.leaderData.info.rent = self:formatDate(orgInfo.rent)
        self.organizationInterior = orgInfo.interior
        self.organizationOwner = orgInfo.owner
        self:loadOrganizationLogo(orgInfo.ID)
    end

    if orgEarn then
        self.earnDiagram = {
            maxEarn = 0,
            minEarn = 99999999999,
            totalEarn = 0,
        }

        self.earnData = {}
        for i, v in pairs(orgEarn) do
            local date = split(v.day, "-")
            table.insert(self.earnData, {
                totalEarn = tonumber(v.totalEarn),
                day = string.format("%s.%s", date[3], date[2])
            })

            self.earnDiagram.totalEarn = self.earnDiagram.totalEarn + tonumber(v.totalEarn)

            if self.earnDiagram.maxEarn < tonumber(v.totalEarn) then
                self.earnDiagram.maxEarn = tonumber(v.totalEarn)

            elseif self.earnDiagram.minEarn > tonumber(v.totalEarn) then
                self.earnDiagram.minEarn = tonumber(v.totalEarn)
            end
        end
    end
end

function Computer:getVehicleName(v)
    local name = ""
    if isElement(v) then
        name = getVehicleName(v)
    else
        name = getVehicleNameFromModel(tonumber(v))
    end

    if name == "Police LV" then return "Police Premier" end
    if name == "HPV1000" then return "Police Bike" end
    if name == "Damaged Glendale" then return "Christmas Manana" end
    return name
end

function Computer:open()
    exports.TR_dx:setOpenGUI(true)

    self.tick = getTickCount()
    self.state = "opening"

    self.windowsBar = {"windows"}
    self.notifications = {}
    self.leaderData = {}

    showCursor(true)
    setCursorAlpha(0)
    bindKey("mouse_wheel_up", "down", self.func.scrollKey)
    bindKey("mouse_wheel_down", "down", self.func.scrollKey)
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientClick", root, self.func.mouseClick)
    addEventHandler("guiCheckboxSelected", root, self.func.selectCheckbox)
end

function Computer:close()
    showCursor(false)

    if self.edits then exports.TR_dx:hideEdit(self.edits) end
    if self.checks then exports.TR_dx:hideCheck(self.checks) end

    self.state = "closing"
    self.tick = getTickCount()
    setCursorAlpha(255)
    unbindKey("mouse_wheel_up", "down", self.func.scrollKey)
    unbindKey("mouse_wheel_down", "down", self.func.scrollKey)
    removeEventHandler("onClientClick", root, self.func.mouseClick)
    removeEventHandler("guiCheckboxSelected", root, self.func.selectCheckbox)

    if isElement(self.previewElement) then destroyElement(self.previewElement) end
end

function Computer:destroy()
    exports.TR_dx:setOpenGUI(false)

    removeEventHandler("onClientRender", root, self.func.render)

    for i, v in pairs(self.textures) do
        destroyElement(v)
    end
    self.textures = false
    if self.edits then exports.TR_dx:destroyEdit(self.edits) end
    if self.checks then exports.TR_dx:destroyCheck(self.checks); self.checks = nil end

    guiInfo.panel = nil
    self = nil
end


function Computer:animate()
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
        return true
      end
    end
end

function Computer:render()
    if not guiInfo.panel then return end
    if self:animate() then return end
    dxDrawImage(0, 0, sx, sy, self.textures.wallpaper, 0, 0, 0, tocolor(0, 0, 0, 255 * self.alpha))
    dxDrawImage(0, 0, sx, sy - guiInfo.bar.h, self.textures.wallpaper, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))

    self:renderWindowsIcons()
    self:renderWindowsPanel()

    self:renderAppWindow()
    self:renderNotificationList()
    self:renderSelectedObject()

    self:renderAddObject()
    self:renderAccept()
    self:renderInfo()
    self:renderCursor()
end

function Computer:renderCursor()
    local cx, cy = getCursorPosition()
    if not cx or not cy then return end
    cx, cy = sx * cx, sy * cy

    if self.cursorImg == "cursor" then
        dxDrawImage(cx - 4, cy, 20, 20, self.textures[self.cursorImg], 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha), true)
    else
        dxDrawImage(cx - 8, cy, 20, 20, self.textures[self.cursorImg], 0, 0, 0, tocolor(220, 220, 220, 255 * self.alpha), true)
    end

    self.cursorImg = "cursor"
end

function Computer:renderCursorHint(text)
    local cx, cy = getCursorPosition()
    if not cx or not cy then return end
    cx, cy = sx * cx, sy * cy

    local width = dxGetTextWidth(text, 1/zoom, self.fonts.icons)
    cx, cy = math.min(cx, sx - (width + 20/zoom)), math.min(cy, sy - 20/zoom)
    dxDrawRectangle(cx + 8/zoom, cy + 12/zoom, width + 8/zoom, 20/zoom, tocolor(57, 57, 57, 255 * self.alpha), true)
    dxDrawText(text, cx + 8/zoom, cy + 12/zoom, cx + 10/zoom + width + 6/zoom, cy + 30/zoom, tocolor(160, 160, 160, 255 * self.alpha), 1/zoom, self.fonts.icons, "center", "center", false, false, true)
end

function Computer:renderInfo()
    if not self.infoType then return end

    if (getTickCount() - self.infoTick)/5000 >= 1 then
        self.infoType = nil
        self.infoText = nil
        self.infoTick = nil
        return
    end

    dxDrawRectangle(guiInfo.info.x, guiInfo.info.y, guiInfo.info.w, 30/zoom, tocolor(47, 47, 47, 255 * self.alpha), true)
    dxDrawRectangle(guiInfo.info.x, guiInfo.info.y + 30/zoom, guiInfo.info.w, guiInfo.info.h - 30/zoom, tocolor(37, 37, 37, 255 * self.alpha), true)

    dxDrawImage(guiInfo.info.x + 8/zoom, guiInfo.info.y + 8/zoom, 14/zoom, 14/zoom, self.textures[self.infoImg], 0, 0, 0, tocolor(160, 160, 160, 255 * self.alpha), true)
    dxDrawText(self.infoType, guiInfo.info.x + 30/zoom, guiInfo.info.y, guiInfo.info.x + guiInfo.info.w - 50/zoom, guiInfo.info.y + 30/zoom, tocolor(160, 160, 160, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "left", "center", false, false, true)
    dxDrawText(self.infoText, guiInfo.info.x + 10/zoom, guiInfo.info.y + 35/zoom, guiInfo.info.x + guiInfo.info.w - 20/zoom, guiInfo.info.y + guiInfo.info.h - 10/zoom, tocolor(160, 160, 160, 255 * self.alpha), 1/zoom, self.fonts.icons, "left", "top", true, true, true)
end

function Computer:renderAccept()
    if not self.acceptWindowTitle then return end

    dxDrawRectangle(guiInfo.accept.x - 2/zoom, guiInfo.accept.y - 2/zoom, guiInfo.accept.w + 4/zoom, guiInfo.accept.h + 4/zoom, tocolor(17, 17, 17, 255 * self.alpha), true)
    dxDrawRectangle(guiInfo.accept.x, guiInfo.accept.y, guiInfo.accept.w, guiInfo.accept.h, tocolor(22, 22, 22, 255 * self.alpha), true)

    dxDrawText(self.acceptWindowTitle, guiInfo.accept.x, guiInfo.accept.y, guiInfo.accept.x + guiInfo.accept.w, guiInfo.accept.y + 30/zoom, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "center", "center", false, false, true)
    dxDrawText(self.acceptWindowText, guiInfo.accept.x + 10/zoom, guiInfo.accept.y + 35/zoom, guiInfo.accept.x + guiInfo.accept.w - 10/zoom, guiInfo.accept.y + guiInfo.accept.h - 5/zoom, tocolor(140, 140, 140, 255 * self.alpha), 1/zoom, self.fonts.icons, "center", "top", true, true, true, true)

    if self:isMouseInPosition(guiInfo.accept.x + 10/zoom, guiInfo.accept.y + guiInfo.accept.h - 40/zoom, (guiInfo.accept.w - 30/zoom)/2, 30/zoom) then
        dxDrawRectangle(guiInfo.accept.x + 10/zoom, guiInfo.accept.y + guiInfo.accept.h - 40/zoom, (guiInfo.accept.w - 30/zoom)/2, 30/zoom, tocolor(47, 47, 47, 255 * self.alpha), true)
    else
        dxDrawRectangle(guiInfo.accept.x + 10/zoom, guiInfo.accept.y + guiInfo.accept.h - 40/zoom, (guiInfo.accept.w - 30/zoom)/2, 30/zoom, tocolor(37, 37, 37, 255 * self.alpha), true)
    end
    if self:isMouseInPosition(guiInfo.accept.x + guiInfo.accept.w - (guiInfo.accept.w - 30/zoom)/2 - 10/zoom, guiInfo.accept.y + guiInfo.accept.h - 40/zoom, (guiInfo.accept.w - 30/zoom)/2, 30/zoom) then
        dxDrawRectangle(guiInfo.accept.x + guiInfo.accept.w - (guiInfo.accept.w - 30/zoom)/2 - 10/zoom, guiInfo.accept.y + guiInfo.accept.h - 40/zoom, (guiInfo.accept.w - 30/zoom)/2, 30/zoom, tocolor(47, 47, 47, 255 * self.alpha), true)
    else
        dxDrawRectangle(guiInfo.accept.x + guiInfo.accept.w - (guiInfo.accept.w - 30/zoom)/2 - 10/zoom, guiInfo.accept.y + guiInfo.accept.h - 40/zoom, (guiInfo.accept.w - 30/zoom)/2, 30/zoom, tocolor(37, 37, 37, 255 * self.alpha), true)
    end
    dxDrawText("Anuluj", guiInfo.accept.x + 10/zoom, guiInfo.accept.y + guiInfo.accept.h - 40/zoom, guiInfo.accept.x + (guiInfo.accept.w - 30/zoom)/2 + 10/zoom, guiInfo.accept.y + guiInfo.accept.h - 10/zoom, tocolor(160, 160, 160, 255 * self.alpha), 1/zoom, self.fonts.icons, "center", "center", true, true, true)
    dxDrawText("Akceptuj", guiInfo.accept.x + guiInfo.accept.w - (guiInfo.accept.w - 30/zoom)/2 - 10/zoom, guiInfo.accept.y + guiInfo.accept.h - 40/zoom, guiInfo.accept.x + guiInfo.accept.w - 10/zoom, guiInfo.accept.y + guiInfo.accept.h - 10/zoom, tocolor(160, 160, 160, 255 * self.alpha), 1/zoom, self.fonts.icons, "center", "center", true, true, true)
end

function Computer:renderAddObject()
    if not self.addObjectTitle then return end

    dxDrawRectangle(guiInfo.addObject.x - 2/zoom, guiInfo.addObject.y - 2/zoom, guiInfo.addObject.w + 4/zoom, guiInfo.addObject.h + 4/zoom, tocolor(17, 17, 17, 255 * self.alpha))
    dxDrawRectangle(guiInfo.addObject.x, guiInfo.addObject.y, guiInfo.addObject.w, guiInfo.addObject.h, tocolor(22, 22, 22, 255 * self.alpha))

    dxDrawText(self.addObjectTitle, guiInfo.addObject.x, guiInfo.addObject.y, guiInfo.addObject.x + guiInfo.addObject.w, guiInfo.addObject.y + 40/zoom, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "center", "center")

    if self:isMouseInPosition(guiInfo.addObject.x + 10/zoom, guiInfo.addObject.y + guiInfo.addObject.h - 40/zoom, (guiInfo.addObject.w - 30/zoom)/2, 30/zoom) then
        dxDrawRectangle(guiInfo.addObject.x + 10/zoom, guiInfo.addObject.y + guiInfo.addObject.h - 40/zoom, (guiInfo.addObject.w - 30/zoom)/2, 30/zoom, tocolor(47, 47, 47, 255 * self.alpha))
    else
        dxDrawRectangle(guiInfo.addObject.x + 10/zoom, guiInfo.addObject.y + guiInfo.addObject.h - 40/zoom, (guiInfo.addObject.w - 30/zoom)/2, 30/zoom, tocolor(37, 37, 37, 255 * self.alpha))
    end
    if self:isMouseInPosition(guiInfo.addObject.x + guiInfo.addObject.w - (guiInfo.addObject.w - 30/zoom)/2 - 10/zoom, guiInfo.addObject.y + guiInfo.addObject.h - 40/zoom, (guiInfo.addObject.w - 30/zoom)/2, 30/zoom) then
        dxDrawRectangle(guiInfo.addObject.x + guiInfo.addObject.w - (guiInfo.addObject.w - 30/zoom)/2 - 10/zoom, guiInfo.addObject.y + guiInfo.addObject.h - 40/zoom, (guiInfo.addObject.w - 30/zoom)/2, 30/zoom, tocolor(47, 47, 47, 255 * self.alpha))
    else
        dxDrawRectangle(guiInfo.addObject.x + guiInfo.addObject.w - (guiInfo.addObject.w - 30/zoom)/2 - 10/zoom, guiInfo.addObject.y + guiInfo.addObject.h - 40/zoom, (guiInfo.addObject.w - 30/zoom)/2, 30/zoom, tocolor(37, 37, 37, 255 * self.alpha))
    end
    dxDrawText("İptal", guiInfo.addObject.x + 10/zoom, guiInfo.addObject.y + guiInfo.addObject.h - 40/zoom, guiInfo.addObject.x + (guiInfo.addObject.w - 30/zoom)/2 + 10/zoom, guiInfo.addObject.y + guiInfo.addObject.h - 10/zoom, tocolor(160, 160, 160, 255 * self.alpha), 1/zoom, self.fonts.icons, "center", "center")
    dxDrawText(self.acceptButtonText, guiInfo.addObject.x + guiInfo.addObject.w - (guiInfo.addObject.w - 30/zoom)/2 - 10/zoom, guiInfo.addObject.y + guiInfo.addObject.h - 40/zoom, guiInfo.addObject.x + guiInfo.addObject.w - 10/zoom, guiInfo.addObject.y + guiInfo.addObject.h - 10/zoom, tocolor(160, 160, 160, 255 * self.alpha), 1/zoom, self.fonts.icons, "center", "center")
end

function Computer:renderSelectedObject()
    if not self.selectedObject then return end

    dxDrawRectangle(self.selectedObjectPos.x - 2/zoom, self.selectedObjectPos.y - 2/zoom, self.selectedObjectPos.w + 4/zoom, self.selectedObjectPos.h + 4/zoom, tocolor(17, 17, 17, 255 * self.alpha), true)
    dxDrawRectangle(self.selectedObjectPos.x, self.selectedObjectPos.y, self.selectedObjectPos.w, self.selectedObjectPos.h, tocolor(22, 22, 22, 255 * self.alpha), true)

    for i, v in pairs(self.selectedObjectOptions) do
        if self:isMouseInPosition(self.selectedObjectPos.x, self.selectedObjectPos.y + (i-1) * 25/zoom, self.selectedObjectPos.w, 25/zoom) or self.hoveredOption == i then
            dxDrawRectangle(self.selectedObjectPos.x, self.selectedObjectPos.y + (i-1) * 25/zoom, self.selectedObjectPos.w, 25/zoom, tocolor(37, 37, 37, 255 * self.alpha), true)
            self.hoveredOption = i
        end
        dxDrawText(v.title, self.selectedObjectPos.x + 25/zoom, self.selectedObjectPos.y + (i-1) * 25/zoom, self.selectedObjectPos.x + self.selectedObjectPos.w, self.selectedObjectPos.y + 25/zoom + (i-1) * 25/zoom, tocolor(160, 160, 160, 255 * self.alpha), 1/zoom, self.fonts.icons, "left", "center", false, false, true)

        if self.textures[v.icon] then
            dxDrawImage(self.selectedObjectPos.x + 7/zoom, self.selectedObjectPos.y + 7/zoom + (i-1) * 25/zoom, 11/zoom, 11/zoom, self.textures[v.icon], 0, 0, 0, tocolor(180, 180, 180, 255 * self.alpha), true)
        end

        if v.type == "rank" then
            dxDrawImage(self.selectedObjectPos.x + self.selectedObjectPos.w - 18/zoom, self.selectedObjectPos.y + 7/zoom + (i-1) * 25/zoom, 11/zoom, 11/zoom, self.textures.more, 0, 0, 0, tocolor(180, 180, 180, 255 * self.alpha), true)

            if self.hoveredOption == i then
                local posY = self.selectedObjectPos.y + (i-1) * 25/zoom + #self.leaderData.folder_ranks * 25/zoom >= sy - 40/zoom and self.selectedObjectPos.y + i * 25/zoom - #self.leaderData.folder_ranks * 25/zoom or self.selectedObjectPos.y + (i-1) * 25/zoom

                if self.leaderData.folder_ranks then
                    posY = self.selectedObjectPos.y + (i-1) * 25/zoom + #self.leaderData.folder_ranks * 25/zoom >= sy - 40/zoom and self.selectedObjectPos.y + i * 25/zoom - #self.leaderData.folder_ranks * 25/zoom or self.selectedObjectPos.y + (i-1) * 25/zoom

                    dxDrawRectangle(self.selectedObjectPos.x + self.selectedObjectPos.w, posY - 2/zoom, self.selectedObjectPos.w + 4/zoom, #self.leaderData.folder_ranks * 25/zoom + 4/zoom, tocolor(17, 17, 17, 255 * self.alpha), true)
                    dxDrawRectangle(self.selectedObjectPos.x + self.selectedObjectPos.w + 2/zoom, posY, self.selectedObjectPos.w, #self.leaderData.folder_ranks * 25/zoom, tocolor(22, 22, 22, 255 * self.alpha), true)

                    for k, rank in pairs(self.leaderData.folder_ranks) do
                        if self.selectedObjectData.rankID == rank.ID then
                            dxDrawRectangle(self.selectedObjectPos.x + self.selectedObjectPos.w + 2/zoom, posY + (k-1) * 25/zoom, self.selectedObjectPos.w, 25/zoom, tocolor(42, 42, 42, 255 * self.alpha), true)
                            dxDrawImage(self.selectedObjectPos.x + self.selectedObjectPos.w * 2 - 11/zoom, posY + 10/zoom + (k-1) * 25/zoom, 5/zoom, 5/zoom, self.textures.selected, 0, 0, 0, tocolor(180, 180, 180, 255 * self.alpha), true)

                        elseif self:isMouseInPosition(self.selectedObjectPos.x + self.selectedObjectPos.w + 2/zoom, posY + (k-1) * 25/zoom, self.selectedObjectPos.w, 25/zoom) then
                            dxDrawRectangle(self.selectedObjectPos.x + self.selectedObjectPos.w + 2/zoom, posY + (k-1) * 25/zoom, self.selectedObjectPos.w, 25/zoom, tocolor(37, 37, 37, 255 * self.alpha), true)
                        end

                        dxDrawText(rank.name, self.selectedObjectPos.x + self.selectedObjectPos.w + 7/zoom, posY + (k-1) * 25/zoom, self.selectedObjectPos.x + self.selectedObjectPos.w, posY + 25/zoom + (k-1) * 25/zoom, tocolor(160, 160, 160, 255 * self.alpha), 1/zoom, self.fonts.icons, "left", "center", false, false, true)
                    end
                end
            end
        end
    end
end

function Computer:renderWindowsIcons()
    local i = 1
    for _, v in pairs(guiInfo.apps) do
        if v.onScreen then
            self:renderWindowsIcon((i - 1), v)
            i = i + 1
        end
    end
end

function Computer:renderWindowsIcon(i, data)
    if self:isMouseInPosition(10/zoom, 15/zoom + i * 110/zoom, 130/zoom, 85/zoom, self.windowSize and self.windowSize.size == "full" or self.selectedObject or self.acceptWindowTitle or self.addObjectTitle or false) and not self.selectedObject and not self.acceptWindowTitle and not self.addObjectTitle then
        if guiInfo.apps[i + 1].state == "clicked" then
            self:drawIconHover(10/zoom, 15/zoom + i * 110/zoom, 130/zoom, 85/zoom, tocolor(71, 175, 255, 40 * self.alpha), 5)
        else
            self:drawIconHover(10/zoom, 15/zoom + i * 110/zoom, 130/zoom, 85/zoom, tocolor(255, 255, 255, 20 * self.alpha), 5)
        end

    elseif guiInfo.apps[i + 1].state == "clicked" then
        self:drawIconHover(10/zoom, 15/zoom + i * 110/zoom, 130/zoom, 85/zoom, tocolor(71, 175, 255, 30 * self.alpha), 5)
    end
    dxDrawImage(50/zoom, 20/zoom + i * 110/zoom, 50/zoom, 50/zoom, self.textures[data.type], 0, 0, 0, tocolor(170, 170, 170, 255 * self.alpha))
    dxDrawText(data.title, 15/zoom, 75/zoom + i * 110/zoom, 135/zoom, guiInfo.bar.y, tocolor(160, 160, 160, 255 * self.alpha), 1/zoom, self.fonts.icons, "center", "top", true, true)
end

function Computer:renderWindowsPanel()
    dxDrawRectangle(guiInfo.bar.x, guiInfo.bar.y, guiInfo.bar.w, guiInfo.bar.h, tocolor(17, 17, 17, 255 * self.alpha), false) -- Dodać true na końcu

    for i, v in pairs(self.windowsBar) do
        self:renderWindowsBarIcon((i - 1), v)
    end

    local time = getRealTime()
    dxDrawText(string.format("%02d:%02d", time.hour, time.minute), guiInfo.bar.x + guiInfo.bar.w - 120/zoom, guiInfo.bar.y + 1/zoom, guiInfo.bar.x + guiInfo.bar.w - 34/zoom, guiInfo.bar.y, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.icons, "center", "top", false, false, true)
    dxDrawText(string.format("%02d.%02d.%02d", time.monthday, time.month+1, 1900 + time.year), guiInfo.bar.x + guiInfo.bar.w - 120/zoom, guiInfo.bar.y + 5/zoom, guiInfo.bar.x + guiInfo.bar.w - 34/zoom, guiInfo.bar.y + guiInfo.bar.h - 3/zoom, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.icons, "center", "bottom", false, false, true)

    if self:isMouseInPosition(guiInfo.bar.x + guiInfo.bar.w - 40/zoom, guiInfo.bar.y, 40/zoom, guiInfo.bar.h) or self.notiOpen then
        dxDrawRectangle(guiInfo.bar.x + guiInfo.bar.w - 40/zoom, guiInfo.bar.y, 40/zoom, guiInfo.bar.h, tocolor(27, 27, 27, 255 * self.alpha), true)
    end
    dxDrawImage(guiInfo.bar.x + guiInfo.bar.w - 34/zoom, guiInfo.bar.y + 6/zoom, 28/zoom, 28/zoom, self.textures.noti, 0, 0, 0, tocolor(170, 170, 170, 255 * self.alpha), true)
    dxDrawImage(guiInfo.bar.x + guiInfo.bar.w - 220/zoom, guiInfo.bar.y, 100/zoom, guiInfo.bar.h, self.textures.icons, 0, 0, 0, tocolor(170, 170, 170, 255 * self.alpha), true)
end

function Computer:renderWindowsBarIcon(i, img)
    local openedType = self.focusedApp and guiInfo.apps[self.focusedApp].type or false

    if (self:isMouseInPosition(guiInfo.bar.x + i * 48/zoom, guiInfo.bar.y, 48/zoom, guiInfo.bar.h, self.acceptWindowTitle or self.addObjectTitle) or self.iconBar == i or img == openedType) and not self.acceptWindowTitle and not self.addObjectTitle then
        dxDrawRectangle(guiInfo.bar.x + i * 48/zoom, guiInfo.bar.y, 48/zoom, guiInfo.bar.h, tocolor(27, 27, 27, 255 * self.alpha), true)

        if i == 0 then
            dxDrawImage(guiInfo.bar.x + 10/zoom + i * 48/zoom, guiInfo.bar.y + 6/zoom, 28/zoom, 28/zoom, self.textures[img], 0, 0, 0, tocolor(66, 156, 227, 255 * self.alpha), true)
        else
            dxDrawImage(guiInfo.bar.x + 10/zoom + i * 48/zoom, guiInfo.bar.y + 6/zoom, 28/zoom, 28/zoom, self.textures[img], 0, 0, 0, tocolor(170, 170, 170, 255 * self.alpha), true)
            dxDrawRectangle(guiInfo.bar.x + i * 48/zoom, guiInfo.bar.y + guiInfo.bar.h - 2/zoom, 48/zoom, 2/zoom, tocolor(160, 160, 160, 255 * self.alpha), true)
        end
    else
        dxDrawImage(guiInfo.bar.x + 10/zoom + i * 48/zoom, guiInfo.bar.y + 6/zoom, 28/zoom, 28/zoom, self.textures[img], 0, 0, 0, tocolor(170, 170, 170, 255 * self.alpha), true)

        if i ~= 0 then
            dxDrawRectangle(guiInfo.bar.x + 5/zoom + i * 48/zoom, guiInfo.bar.y + guiInfo.bar.h - 2/zoom, 38/zoom, 2/zoom, tocolor(160, 160, 160, 255 * self.alpha), true)
        end
    end

    if self.iconBar == i then
        dxDrawRectangle(guiInfo.bar.x - 2/zoom + i * 48/zoom, guiInfo.bar.y - 36/zoom, 200/zoom, 36/zoom, tocolor(17, 17, 17, 255 * self.alpha), true)
        dxDrawRectangle(guiInfo.bar.x + i * 48/zoom, guiInfo.bar.y - 34/zoom, 196/zoom, 34/zoom, tocolor(27, 27, 27, 255 * self.alpha), true)

        if self:isMouseInPosition(guiInfo.bar.x + i * 48/zoom, guiInfo.bar.y - 32/zoom, 196/zoom, 34/zoom) then
            dxDrawRectangle(guiInfo.bar.x + i * 48/zoom, guiInfo.bar.y - 32/zoom, 196/zoom, 32/zoom, tocolor(37, 37, 37, 255 * self.alpha), true)
        end

        if self.iconBar == 0 then
            dxDrawImage(guiInfo.bar.x + 10/zoom + i * 48/zoom, guiInfo.bar.y - 26/zoom, 16/zoom, 16/zoom, self.textures.shutdown, 0, 0, 0, tocolor(170, 170, 170, 255 * self.alpha), true)
            dxDrawText("bilgisayarı Kapat", guiInfo.bar.x + 35/zoom + i * 48/zoom, guiInfo.bar.y - 32/zoom, guiInfo.bar.x + 192/zoom + i * 48/zoom, guiInfo.bar.y - 4/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.closeApp, "left", "center", false, false, true)
        else
            dxDrawImage(guiInfo.bar.x + 10/zoom + i * 48/zoom, guiInfo.bar.y - 26/zoom, 16/zoom, 16/zoom, self.textures.close, 0, 0, 0, tocolor(170, 170, 170, 255 * self.alpha), true)
            dxDrawText("Pencereyi kapat", guiInfo.bar.x + 35/zoom + i * 48/zoom, guiInfo.bar.y - 32/zoom, guiInfo.bar.x + 192/zoom + i * 48/zoom, guiInfo.bar.y - 4/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.closeApp, "left", "center", false, false, true)
        end
    end
end

function Computer:renderAppWindow()
    if not self.focusedApp then return end
    local appData = guiInfo.apps[self.focusedApp]
    dxDrawRectangle(self.windowSize.x, self.windowSize.y, self.windowSize.w, 30/zoom, tocolor(17, 17, 17, 255 * self.alpha))
    dxDrawRectangle(self.windowSize.x, self.windowSize.y + 30/zoom, self.windowSize.w, self.windowSize.h - 30/zoom, tocolor(27, 27, 27, 255 * self.alpha))

    dxDrawRectangle(self.windowSize.x, self.windowSize.y + self.windowSize.h - 30/zoom, self.windowSize.w, 2/zoom, tocolor(57, 57, 57, 255 * self.alpha))

    dxDrawImage(self.windowSize.x + 10/zoom, self.windowSize.y + 4/zoom, 22/zoom, 22/zoom, self.textures[appData.type], 0, 0, 0, tocolor(170, 170, 170, 255 * self.alpha), true)
    dxDrawText(appData.title, self.windowSize.x + 42/zoom, self.windowSize.y, self.windowSize.x + 8/zoom, self.windowSize.y + 30/zoom, tocolor(140, 140, 140, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "left", "center", false, false, true)

    self:renderAppOptions()

    if appData.type == "info" then
        self:renderInfoAppWindow()
        return

    elseif appData.type == "earnings" then
        self:renderEarningsAppWindow()
        return

    elseif appData.type == "upgrade" then
        self:renderUpgradeAppWindow()
        return

    elseif appData.type == "darkweb" then
        self:renderDarkWebAppWindow()
        return
    end

    if self.focusedAppData then
        if self.focusedAppData.data then
            dxDrawText(string.format("Element miktarı: %d", #self.focusedAppData.data), self.windowSize.x + 10/zoom, self.windowSize.y + self.windowSize.h - 30/zoom, self.windowSize.x + 8/zoom, self.windowSize.y + self.windowSize.h, tocolor(140, 140, 140, 255 * self.alpha), 1/zoom, self.fonts.icons, "left", "center", false, false, true)

            local maxCol, maxRow, startX = self:calculateRowCount()
            local col, row = 0, 0
            for i = 1, maxCol * maxRow do
                local data = self.focusedAppData.data[i + self.scroll]
                if data then
                    if self.focusedAppData.data[i + self.scroll].clicked then
                        if (self:isMouseInPosition(startX + col * 120/zoom, self.windowSize.y + 50/zoom + row * 100/zoom, 100/zoom, 90/zoom, self.selectedObject or self.acceptWindowTitle or self.addObjectTitle) and not self.selectedObject and not self.acceptWindowTitle and not self.addObjectTitle) or self.selectedObject == i + self.scroll then
                            self:drawIconHover(startX + col * 120/zoom, self.windowSize.y + 50/zoom + row * 100/zoom, 100/zoom, 90/zoom, tocolor(71, 175, 255, 40 * self.alpha), 5)
                        else
                            self:drawIconHover(startX + col * 120/zoom, self.windowSize.y + 50/zoom + row * 100/zoom, 100/zoom, 90/zoom, tocolor(71, 175, 255, 20 * self.alpha), 5)
                        end
                    else
                        if (self:isMouseInPosition(startX + col * 120/zoom, self.windowSize.y + 50/zoom + row * 100/zoom, 100/zoom, 90/zoom, self.selectedObject or self.acceptWindowTitle or self.addObjectTitle) and not self.selectedObject and not self.acceptWindowTitle and not self.addObjectTitle) or self.selectedObject == i + self.scroll then
                            self:drawIconHover(startX + col * 120/zoom, self.windowSize.y + 50/zoom + row * 100/zoom, 100/zoom, 90/zoom, tocolor(255, 255, 255, 20 * self.alpha), 5)
                        end
                    end

                    local textColor = data.textColor or {140, 140, 140}
                    dxDrawImage(startX + 25/zoom + col * 120/zoom, self.windowSize.y + 54/zoom + row * 100/zoom, 50/zoom, 50/zoom, self.textures[self.focusedAppData.icon], 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
                    dxDrawText(data.name, startX + 5/zoom + col * 120/zoom, self.windowSize.y + 105/zoom + row * 100/zoom, startX + 95/zoom + col * 120/zoom, self.windowSize.y + 137/zoom + row * 100/zoom, tocolor(textColor[1], textColor[2], textColor[3], 255 * self.alpha), 1/zoom, self.fonts.icons, "center", "center", true, true)

                    col = col + 1
                    if col >= maxCol then
                        col = 0
                        row = row + 1
                    end
                end
            end

            if #self.focusedAppData.data > maxCol * maxRow then
                local b1 = (self.windowSize.h - 80/zoom) / math.ceil(#self.focusedAppData.data / maxCol)
                local barY = b1 * self.scroll / maxCol
                local barH = b1 * maxRow

                dxDrawRectangle(self.windowSize.x + self.windowSize.w - 10/zoom, self.windowSize.y + 40/zoom, 5/zoom, self.windowSize.h - 80/zoom, tocolor(47, 47, 47, 255 * self.alpha))
                dxDrawRectangle(self.windowSize.x + self.windowSize.w - 10/zoom, self.windowSize.y + 40/zoom + barY, 5/zoom, barH, tocolor(67, 67, 67, 255 * self.alpha))
            end

        elseif self.focusedAppData.info then
            if appData.type == "ranks_info" then
                dxDrawImage(self.windowSize.x + 40/zoom, self.windowSize.y + 30/zoom + 256/zoom/2, 256/zoom, 256/zoom, self.textures.ranks_info, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
            end

            dxDrawText(string.format("Seçilen öğe: %s", self.focusedAppData.element), self.windowSize.x + 10/zoom, self.windowSize.y + self.windowSize.h - 30/zoom, self.windowSize.x + 8/zoom, self.windowSize.y + self.windowSize.h, tocolor(140, 140, 140, 255 * self.alpha), 1/zoom, self.fonts.icons, "left", "center", false, false, true)

            local y = 100/zoom
            for _, v in pairs(self.focusedAppData.info) do
                dxDrawText(v.name, self.previewX, self.windowSize.y + y, self.windowSize.x + 8/zoom, self.windowSize.y + self.windowSize.h, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.infoApp, "left", "top", false, false, true)

                y = y + 25/zoom
                for i, data in ipairs(v.value) do
                    if string.len(data.value) > 0 then
                        dxDrawText(string.format("%s: %s", data.name, data.value), self.previewX, self.windowSize.y + y, self.windowSize.x + 8/zoom, self.windowSize.y + self.windowSize.h, tocolor(140, 140, 140, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "left", "top", false, false, true)
                        y = y + 20/zoom
                    else
                        dxDrawText(string.format("%s", data.name), self.previewX + 25/zoom, self.windowSize.y + y, self.windowSize.x + 8/zoom, self.windowSize.y + self.windowSize.h, tocolor(140, 140, 140, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "left", "top", false, false, true)
                        y = y + 30/zoom
                    end

                end
                y = y + 30/zoom
            end
        end

        if self.focusedAppData.text then
            dxDrawText(self.focusedAppData.text, self.windowSize.x, self.windowSize.y + 40/zoom, self.windowSize.x + self.windowSize.w, self.windowSize.y + self.windowSize.h, tocolor(140, 140, 140, 255 * self.alpha), 1/zoom, self.fonts.closeApp, "center", "top", false, false, true)
        end
    end
end

function Computer:renderInfoAppWindow()
    if self.windowSize.size == "full" then
        if self.textures.orgLogo then
            dxDrawImage(self.windowSize.x + (self.windowSize.w - 400/zoom)/2, self.windowSize.y + 75/zoom, 400/zoom, 400/zoom, self.textures.orgLogo, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
        end

        dxDrawText(self.focusedAppData.data.name, self.windowSize.x + 10/zoom, self.windowSize.y + 585/zoom, self.windowSize.x + self.windowSize.w - 10/zoom, self.windowSize.y + self.windowSize.h, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.orgName, "center", "top", false, false)
        dxDrawText(string.format("$%s", self:formatNumber(self.focusedAppData.data.money)), self.windowSize.x + 10/zoom, self.windowSize.y + 620/zoom, self.windowSize.x + self.windowSize.w - 10/zoom, self.windowSize.y + self.windowSize.h, tocolor(184, 153, 53, 255 * self.alpha), 1/zoom, self.fonts.infoApp, "center", "top", false, false)

		dxDrawText("T.C. Kimlik No:", self.windowSize.x + 10/zoom, self.windowSize.y + 665/zoom, self.windowSize.x + self.windowSize.w/2 - 5/zoom, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "right", "top", false, false)
		dxDrawText("Kurucu:", self.windowSize.x + 10/zoom, self.windowSize.y + 685/zoom, self.windowSize.x + self.windowSize.w/2 - 5/zoom, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "right", "top", false, false)
		dxDrawText("Kuruluş Tarihi:", self.windowSize.x + 10/zoom, self.windowSize.y + 705/zoom, self.windowSize.x + self.windowSize.w/2 - 5/zoom, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "right", "top", false, false)
       
   	    dxDrawText(string.format("64-%07d", self.focusedAppData.data.ID), self.windowSize.x + self.windowSize.w/2 + 5/zoom, self.windowSize.y + 665/zoom, self.windowSize.x + self.windowSize.w - 5/zoom, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "left", "top", false, false)
        dxDrawText(self.focusedAppData.data.owner, self.windowSize.x + self.windowSize.w/2 + 5/zoom, self.windowSize.y + 685/zoom, self.windowSize.x + self.windowSize.w - 5/zoom, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "left", "top", false, false)
        dxDrawText(self.focusedAppData.data.created, self.windowSize.x + self.windowSize.w/2 + 5/zoom, self.windowSize.y + 705/zoom, self.windowSize.x + self.windowSize.w - 5/zoom, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "left", "top", false, false)

		dxDrawText("Üye Sayısı:", self.windowSize.x + 10/zoom, self.windowSize.y + 725/zoom, self.windowSize.x + self.windowSize.w/2 - 5/zoom, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "right", "top", false, false)
		dxDrawText("Araç Sayısı:", self.windowSize.x + 10/zoom, self.windowSize.y + 745/zoom, self.windowSize.x + self.windowSize.w/2 - 5/zoom, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "right", "top", false, false)
		dxDrawText("Organizasyonun Ücreti Ödenmiş Hâli:", self.windowSize.x + 10/zoom, self.windowSize.y + 765/zoom, self.windowSize.x + self.windowSize.w/2 - 5/zoom, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "right", "top", false, false)

        dxDrawText(string.format("%d / %d", #self.leaderData.folder_person, self.leaderData.info.players * 5), self.windowSize.x + self.windowSize.w/2 + 5/zoom, self.windowSize.y + 725/zoom, self.windowSize.x + self.windowSize.w - 10/zoom, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "left", "top", false, false)
        dxDrawText(string.format("%d / %d", self.leaderData.folder_vehicle and #self.leaderData.folder_vehicle or 0, self.leaderData.info.vehicles * 3), self.windowSize.x + self.windowSize.w/2 + 5/zoom, self.windowSize.y + 745/zoom, self.windowSize.x + self.windowSize.w - 10/zoom, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "left", "top", false, false)
        dxDrawText(self.focusedAppData.data.rent, self.windowSize.x + self.windowSize.w/2 + 5/zoom, self.windowSize.y + 765/zoom, self.windowSize.x + self.windowSize.w - 10/zoom, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "left", "top", false, false)

        dxDrawText(string.format("Seçilen öğe: %s", self.focusedAppData.data.name), self.windowSize.x + 10/zoom, self.windowSize.y + self.windowSize.h + 170/zoom, self.windowSize.x + 8/zoom, self.windowSize.y + self.windowSize.h, tocolor(140, 140, 140, 255 * self.alpha), 1/zoom, self.fonts.icons, "left", "center", false, false)
    else
        if self.textures.orgLogo then
            dxDrawImage(self.windowSize.x + (self.windowSize.w - 200/zoom)/2, self.windowSize.y + 75/zoom, 200/zoom, 200/zoom, self.textures.orgLogo, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
        end

        dxDrawText(self.focusedAppData.data.name, self.windowSize.x + 10/zoom, self.windowSize.y + 285/zoom, self.windowSize.x + self.windowSize.w - 10/zoom, self.windowSize.y + self.windowSize.h, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.orgName, "center", "top", false, false)
        dxDrawText(string.format("$%s", self:formatNumber(self.focusedAppData.data.money)), self.windowSize.x + 10/zoom, self.windowSize.y + 320/zoom, self.windowSize.x + self.windowSize.w - 10/zoom, self.windowSize.y + self.windowSize.h, tocolor(184, 153, 53, 255 * self.alpha), 1/zoom, self.fonts.infoApp, "center", "top", false, false)

		dxDrawText("Vergi Kimlik Numarası:", self.windowSize.x + 10/zoom, self.windowSize.y + 365/zoom, self.windowSize.x + self.windowSize.w/2 - 5/zoom, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "right", "top", false, false)
		dxDrawText("Kurucu:", self.windowSize.x + 10/zoom, self.windowSize.y + 385/zoom, self.windowSize.x + self.windowSize.w/2 - 5/zoom, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "right", "top", false, false)
		dxDrawText("Kuruluş Tarihi:", self.windowSize.x + 10/zoom, self.windowSize.y + 405/zoom, self.windowSize.x + self.windowSize.w/2 - 5/zoom, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "right", "top", false, false)

        dxDrawText(string.format("64-%07d", self.focusedAppData.data.ID), self.windowSize.x + self.windowSize.w/2 + 5/zoom, self.windowSize.y + 365/zoom, self.windowSize.x + self.windowSize.w - 5/zoom, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "left", "top", false, false)
        dxDrawText(self.focusedAppData.data.owner, self.windowSize.x + self.windowSize.w/2 + 5/zoom, self.windowSize.y + 385/zoom, self.windowSize.x + self.windowSize.w - 5/zoom, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "left", "top", false, false)
        dxDrawText(self.focusedAppData.data.created, self.windowSize.x + self.windowSize.w/2 + 5/zoom, self.windowSize.y + 405/zoom, self.windowSize.x + self.windowSize.w - 5/zoom, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "left", "top", false, false)

		dxDrawText("Üye Sayısı:", self.windowSize.x + 10/zoom, self.windowSize.y + 425/zoom, self.windowSize.x + self.windowSize.w/2 - 5/zoom, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "right", "top", false, false)
		dxDrawText("Araç Sayısı:", self.windowSize.x + 10/zoom, self.windowSize.y + 445/zoom, self.windowSize.x + self.windowSize.w/2 - 5/zoom, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "right", "top", false, false)
		dxDrawText("Organizasyonun Ücreti Ödenmiş Hâli:", self.windowSize.x + 10/zoom, self.windowSize.y + 465/zoom, self.windowSize.x + self.windowSize.w/2 - 5/zoom, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "right", "top", false, false)

        dxDrawText(string.format("%d / %d", #self.leaderData.folder_person, self.leaderData.info.players * 5), self.windowSize.x + self.windowSize.w/2 + 5/zoom, self.windowSize.y + 425/zoom, self.windowSize.x + self.windowSize.w - 10/zoom, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "left", "top", false, false)
        dxDrawText(string.format("%d / %d", self.leaderData.folder_vehicle and #self.leaderData.folder_vehicle or 0, self.leaderData.info.vehicles * 3), self.windowSize.x + self.windowSize.w/2 + 5/zoom, self.windowSize.y + 445/zoom, self.windowSize.x + self.windowSize.w - 10/zoom, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "left", "top", false, false)
        dxDrawText(self.focusedAppData.data.rent, self.windowSize.x + self.windowSize.w/2 + 5/zoom, self.windowSize.y + 465/zoom, self.windowSize.x + self.windowSize.w - 10/zoom, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "left", "top", false, false)

        dxDrawText(string.format("Seçilen öğe: %s", self.focusedAppData.data.name), self.windowSize.x + 10/zoom, self.windowSize.y + self.windowSize.h - 30/zoom, self.windowSize.x + 8/zoom, self.windowSize.y + self.windowSize.h, tocolor(140, 140, 140, 255 * self.alpha), 1/zoom, self.fonts.icons, "left", "center", false, false)
    end

    if self:isMouseInPosition(self.windowSize.x + self.windowSize.w/2 - (self.windowSize.w/2 - 300/zoom)/2 - 300/zoom, self.windowSize.y + self.windowSize.h - 75/zoom, 300/zoom, 35/zoom, self.addObjectTitle) and not self.addObjectTitle then
        dxDrawRectangle(self.windowSize.x + self.windowSize.w/2 - (self.windowSize.w/2 - 300/zoom)/2 - 300/zoom, self.windowSize.y + self.windowSize.h - 75/zoom, 300/zoom, 35/zoom, tocolor(47, 47, 47, 255 * self.alpha))
    else
        dxDrawRectangle(self.windowSize.x + self.windowSize.w/2 - (self.windowSize.w/2 - 300/zoom)/2 - 300/zoom, self.windowSize.y + self.windowSize.h - 75/zoom, 300/zoom, 35/zoom, tocolor(37, 37, 37, 255 * self.alpha))
    end
    dxDrawText(string.format("Organizasyon için ödeme yapın ($%s)", 2000), self.windowSize.x + self.windowSize.w/2 - (self.windowSize.w/2 - 300/zoom)/2 - 300/zoom, self.windowSize.y + self.windowSize.h - 75/zoom, self.windowSize.x + self.windowSize.w/2 - (self.windowSize.w/2 - 300/zoom)/2, self.windowSize.y + self.windowSize.h - 40/zoom, tocolor(160, 160, 160, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "center", "center")

    if self:isMouseInPosition(self.windowSize.x + self.windowSize.w/2 + (self.windowSize.w/2 - 300/zoom)/2, self.windowSize.y + self.windowSize.h - 75/zoom, 300/zoom, 35/zoom, self.addObjectTitle) and not self.addObjectTitle then
        dxDrawRectangle(self.windowSize.x + self.windowSize.w/2 + (self.windowSize.w/2 - 300/zoom)/2, self.windowSize.y + self.windowSize.h - 75/zoom, 300/zoom, 35/zoom, tocolor(47, 47, 47, 255 * self.alpha))
        dxDrawText("Kuruluşunuzun logosunu değiştirin (400x400px)", self.windowSize.x + self.windowSize.w/2 + (self.windowSize.w/2 - 300/zoom)/2, self.windowSize.y + self.windowSize.h - 75/zoom, self.windowSize.x + self.windowSize.w/2 + (self.windowSize.w/2 - 300/zoom)/2 + 300/zoom, self.windowSize.y + self.windowSize.h - 40/zoom, tocolor(160, 160, 160, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "center", "center")
    else
        dxDrawRectangle(self.windowSize.x + self.windowSize.w/2 + (self.windowSize.w/2 - 300/zoom)/2, self.windowSize.y + self.windowSize.h - 75/zoom, 300/zoom, 35/zoom, tocolor(37, 37, 37, 255 * self.alpha))
        dxDrawText("Kuruluşunuzun logosunu değiştirin (400x400px)", self.windowSize.x + self.windowSize.w/2 + (self.windowSize.w/2 - 300/zoom)/2, self.windowSize.y + self.windowSize.h - 75/zoom, self.windowSize.x + self.windowSize.w/2 + (self.windowSize.w/2 - 300/zoom)/2 + 300/zoom, self.windowSize.y + self.windowSize.h - 40/zoom, tocolor(160, 160, 160, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "center", "center")
    end
end

function Computer:renderEarningsAppWindow()
    local diagram = {
        x = self.windowSize.x + 100/zoom,
        y = self.windowSize.y + 60/zoom,
        w = self.windowSize.w - 200/zoom,
        h = self.windowSize.h - 200/zoom,
    }

    if #self.earnData > 0 then
        local addedPrice = {}
        local lastY = 0

        local move = diagram.w/(#self.earnData + 1)
        for i, v in pairs(self.earnData) do
            local y = diagram.y + diagram.h + 30/zoom - (v.totalEarn/self.earnDiagram.maxEarn) * diagram.h
            dxDrawLine(diagram.x, y - 15/zoom, diagram.x + diagram.w, y - 15/zoom, tocolor(37, 37, 37, 255), 2)
            dxDrawLine(diagram.x + move * i, diagram.y, diagram.x + move * i, diagram.y + diagram.h, tocolor(37, 37, 37, 255), 2)
        end

        for i, v in pairs(self.earnData) do
            local y = diagram.y + diagram.h + 30/zoom - (v.totalEarn/self.earnDiagram.maxEarn) * diagram.h

            if i == 1 then
                dxDrawLine(diagram.x, diagram.y + diagram.h, diagram.x + move * i, y - 15/zoom, tocolor(127, 37, 37, 255), 2)
                lastY = y - 15/zoom
            else
                dxDrawLine(diagram.x + move * (i-1), lastY, diagram.x + move * i, y - 15/zoom, tocolor(127, 37, 37, 255), 2)
                lastY = y - 15/zoom
            end

            if not addedPrice[v.totalEarn] then
                local canAdd = true
                for _, d in pairs(addedPrice) do
                    if math.abs(d.y - y) <= 25 then
                        canAdd = false
                        break
                    end
                end
                if canAdd then
                    dxDrawText(string.format("$%.2f", v.totalEarn), diagram.x, y - 15/zoom, diagram.x, y - 15/zoom, tocolor(140, 140, 140, 255 * self.alpha), 1/zoom, self.fonts.icons, "center", "center", false, false, true)
                end

                addedPrice[v.totalEarn] = {
                    y = y - 15/zoom,
                }
            end

            dxDrawText(v.day, diagram.x + move * i, diagram.y + diagram.h, diagram.x + move * i, diagram.y + diagram.h, tocolor(140, 140, 140, 255 * self.alpha), 1/zoom, self.fonts.icons, "center", "top", false, false, true)
        end

        dxDrawText(string.format("Kuruluşun son 7 gündeki geliri şöyle oldu: $%.2f", self.earnDiagram.totalEarn), diagram.x + diagram.w/2, diagram.y + diagram.h + 30/zoom, diagram.x + diagram.w/2, diagram.y + diagram.h, tocolor(140, 140, 140, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "center", "top", false, false, true)

    else
        dxDrawText("Kuruluşunuz henüz para kazanmadı.", diagram.x + diagram.w/2, diagram.y, diagram.x + diagram.w/2, diagram.y + diagram.h, tocolor(140, 140, 140, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "center", "center", false, false, true)
    end


    if self:isMouseInPosition(self.windowSize.x + self.windowSize.w/2 - (self.windowSize.w/2 - 300/zoom)/2 - 300/zoom, self.windowSize.y + self.windowSize.h - 75/zoom, 300/zoom, 35/zoom, self.addObjectTitle) and not self.addObjectTitle then
        dxDrawRectangle(self.windowSize.x + self.windowSize.w/2 - (self.windowSize.w/2 - 300/zoom)/2 - 300/zoom, self.windowSize.y + self.windowSize.h - 75/zoom, 300/zoom, 35/zoom, tocolor(47, 47, 47, 255 * self.alpha))
    else
        dxDrawRectangle(self.windowSize.x + self.windowSize.w/2 - (self.windowSize.w/2 - 300/zoom)/2 - 300/zoom, self.windowSize.y + self.windowSize.h - 75/zoom, 300/zoom, 35/zoom, tocolor(37, 37, 37, 255 * self.alpha))
    end
    dxDrawText("Kuruluşa para bağışlayın", self.windowSize.x + self.windowSize.w/2 - (self.windowSize.w/2 - 300/zoom)/2 - 300/zoom, self.windowSize.y + self.windowSize.h - 75/zoom, self.windowSize.x + self.windowSize.w/2 - (self.windowSize.w/2 - 300/zoom)/2, self.windowSize.y + self.windowSize.h - 40/zoom, tocolor(160, 160, 160, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "center", "center")

    if self:isMouseInPosition(self.windowSize.x + self.windowSize.w/2 + (self.windowSize.w/2 - 300/zoom)/2, self.windowSize.y + self.windowSize.h - 75/zoom, 300/zoom, 35/zoom, self.addObjectTitle) and not self.addObjectTitle then
        dxDrawRectangle(self.windowSize.x + self.windowSize.w/2 + (self.windowSize.w/2 - 300/zoom)/2, self.windowSize.y + self.windowSize.h - 75/zoom, 300/zoom, 35/zoom, tocolor(47, 47, 47, 255 * self.alpha))
        dxDrawText("Ekstra ücret ödeyin", self.windowSize.x + self.windowSize.w/2 + (self.windowSize.w/2 - 300/zoom)/2, self.windowSize.y + self.windowSize.h - 75/zoom, self.windowSize.x + self.windowSize.w/2 + (self.windowSize.w/2 - 300/zoom)/2 + 300/zoom, self.windowSize.y + self.windowSize.h - 40/zoom, tocolor(160, 160, 160, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "center", "center")
    else
        dxDrawRectangle(self.windowSize.x + self.windowSize.w/2 + (self.windowSize.w/2 - 300/zoom)/2, self.windowSize.y + self.windowSize.h - 75/zoom, 300/zoom, 35/zoom, tocolor(37, 37, 37, 255 * self.alpha))
        dxDrawText("Ekstra ücret ödeyin", self.windowSize.x + self.windowSize.w/2 + (self.windowSize.w/2 - 300/zoom)/2, self.windowSize.y + self.windowSize.h - 75/zoom, self.windowSize.x + self.windowSize.w/2 + (self.windowSize.w/2 - 300/zoom)/2 + 300/zoom, self.windowSize.y + self.windowSize.h - 40/zoom, tocolor(160, 160, 160, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "center", "center")
    end

    -- if self.organizationInterior == self.focusedAppData.info.ID then
    --     dxDrawText("Twoja siedziba znajduje się w tym budynku.", self.windowSize.x + self.windowSize.w - 275/zoom, self.windowSize.y + self.windowSize.h - 75/zoom, self.windowSize.x + self.windowSize.w - 75/zoom, self.windowSize.y + self.windowSize.h - 40/zoom, tocolor(160, 160, 160, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "center", "center")

    -- elseif self.organizationOwner == self.playerName then
    --     if self:isMouseInPosition(self.windowSize.x + self.windowSize.w - 275/zoom, self.windowSize.y + self.windowSize.h - 75/zoom, 200/zoom, 35/zoom) then
    --         dxDrawRectangle(self.windowSize.x + self.windowSize.w - 275/zoom, self.windowSize.y + self.windowSize.h - 75/zoom, 200/zoom, 35/zoom, tocolor(47, 47, 47, 255 * self.alpha))
    --     else
    --         dxDrawRectangle(self.windowSize.x + self.windowSize.w - 275/zoom, self.windowSize.y + self.windowSize.h - 75/zoom, 200/zoom, 35/zoom, tocolor(37, 37, 37, 255 * self.alpha))
    --     end
    --     dxDrawText("Przenieś siedzibę", self.windowSize.x + self.windowSize.w - 275/zoom, self.windowSize.y + self.windowSize.h - 75/zoom, self.windowSize.x + self.windowSize.w - 75/zoom, self.windowSize.y + self.windowSize.h - 40/zoom, tocolor(160, 160, 160, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "center", "center")

    -- else
    --     dxDrawText("Nie możesz przenieść siedziby.", self.windowSize.x + self.windowSize.w - 275/zoom, self.windowSize.y + self.windowSize.h - 75/zoom, self.windowSize.x + self.windowSize.w - 75/zoom, self.windowSize.y + self.windowSize.h - 40/zoom, tocolor(160, 160, 160, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "center", "center")
    -- end

    dxDrawText("Seçilen öğe: Finans", self.windowSize.x + 10/zoom, self.windowSize.y + self.windowSize.h - 30/zoom, self.windowSize.x + 8/zoom, self.windowSize.y + self.windowSize.h, tocolor(140, 140, 140, 255 * self.alpha), 1/zoom, self.fonts.icons, "left", "center", false, false, true)
end

function Computer:renderDarkWebAppWindow()
    if self.focusedAppData.window == "main" then
        if (self:isMouseInPosition(self.windowSize.x, self.windowSize.y + 30/zoom, self.windowSize.w/2, self.windowSize.h - 60/zoom, self.acceptWindowTitle) and not self.acceptWindowTitle) or self.acceptWindowIndex == 1 then
            dxDrawRectangle(self.windowSize.x, self.windowSize.y + 30/zoom, self.windowSize.w/2, self.windowSize.h - 60/zoom, tocolor(32, 32, 32, 255 * self.alpha))
        elseif (self:isMouseInPosition(self.windowSize.x + self.windowSize.w/2, self.windowSize.y + 30/zoom, 300/zoom, self.windowSize.h - 60/zoom, self.acceptWindowTitle) and not self.acceptWindowTitle) or self.acceptWindowIndex == 3 then
            dxDrawRectangle(self.windowSize.x + self.windowSize.w/2, self.windowSize.y + 30/zoom, self.windowSize.w/2, self.windowSize.h - 60/zoom, tocolor(32, 32, 32, 255 * self.alpha))
        end

        dxDrawImage(self.windowSize.x + (self.windowSize.w/2 - 256/zoom)/2, self.windowSize.y + 50/zoom, 256/zoom, 256/zoom, self.textures.drugs_dark, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
        dxDrawImage(self.windowSize.x + self.windowSize.w/2 + (self.windowSize.w/2 - 256/zoom)/2, self.windowSize.y + 50/zoom, 256/zoom, 256/zoom, self.textures.weapon_dark, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))

		dxDrawText("İkinci El Bölümü", self.windowSize.x + 10/zoom, self.windowSize.y + 310/zoom, self.windowSize.x + self.windowSize.w/2 - 10/zoom, self.windowSize.y + self.windowSize.h, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.orgName, "center", "top", false, false, true)
		dxDrawText("Bu seçeneği seçerek, San Andreas'ta bulunan her türlü ikinci el satış ilanını görebilirsiniz; uyuşturuculardan, esrar ve diğer tüm bu tür uyuşturuculara kadar. Hangi mahallede satıcıyı bulabileceğinizi ve saat kaçta olduğunu görebilirsiniz. Tüm bu bilgilere yerel satıcıların ilanlarını okuyarak ulaşabilirsiniz.", self.windowSize.x + 15/zoom, self.windowSize.y + 350/zoom, self.windowSize.x + self.windowSize.w/2 - 15/zoom, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.infoApp, "center", "top", true, true)

		dxDrawText("Silah Bölümü", self.windowSize.x + self.windowSize.w/2 + 10/zoom, self.windowSize.y + 310/zoom, self.windowSize.x + self.windowSize.w - 10/zoom, self.windowSize.y + self.windowSize.h, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.orgName, "center", "top", false, false, true)
		dxDrawText("Bu seçeneği seçerek, San Andreas'ta bulunan her türlü silah satış ilanını görebilirsiniz; en küçük tabancalardan uzun menzilli güçlü saldırı tüfeklerine kadar. Hangi mahallede satıcıyı bulabileceğinizi ve saat kaçta olduğunu görebilirsiniz. Tüm bu bilgilere yerel satıcıların ilanlarını okuyarak ulaşabilirsiniz.", self.windowSize.x + self.windowSize.w/2 + 15/zoom, self.windowSize.y + 350/zoom, self.windowSize.x + self.windowSize.w - 15/zoom, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.infoApp, "center", "top", true, true)

		dxDrawText("Bağlantı: Özel", self.windowSize.x + 10/zoom, self.windowSize.y + self.windowSize.h - 30/zoom, self.windowSize.x + 8/zoom, self.windowSize.y + self.windowSize.h, tocolor(140, 140, 140, 255 * self.alpha), 1/zoom, self.fonts.icons, "left", "center", false, false, true)

    elseif self.focusedAppData.window == "weapon" then
        if not self.focusedAppData.data then
            dxDrawText("Reklamlar yükleniyor...", self.windowSize.x, self.windowSize.y, self.windowSize.x + self.windowSize.w, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.infoApp, "center", "center", true, true)
        else
		if #self.focusedAppData.data < 1 then
			dxDrawText("Bugün için herhangi bir ilan bulunmuyor.", self.windowSize.x, self.windowSize.y, self.windowSize.x + self.windowSize.w, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.infoApp, "center", "center", true, true)
		else
			dxDrawText("Konum", self.windowSize.x + 20/zoom, self.windowSize.y + 35/zoom, self.windowSize.x + self.windowSize.w - 20/zoom, self.windowSize.y + 70/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.infoApp, "left", "center")
			dxDrawText("Satılan Ürün", self.windowSize.x + 300/zoom, self.windowSize.y + 35/zoom, self.windowSize.x + self.windowSize.w - 20/zoom, self.windowSize.y + 70/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.infoApp, "left", "center")
			dxDrawText("Saat", self.windowSize.x + self.windowSize.w - 100/zoom, self.windowSize.y + 35/zoom, self.windowSize.x + self.windowSize.w - 20/zoom, self.windowSize.y + 70/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.infoApp, "center", "center")
		end
                dxDrawLine(self.windowSize.x + 10/zoom, self.windowSize.y + 70/zoom, self.windowSize.x + self.windowSize.w - 10/zoom, self.windowSize.y + 70/zoom, tocolor(57, 57, 57, 255 * self.alpha), 1/zoom)

                for i = 1, 11 do
                    local v = self.focusedAppData.data[i + self.scroll]
                    if v then
                        dxDrawText(v.location, self.windowSize.x + 20/zoom, self.windowSize.y + 80/zoom + (i-1) * 40/zoom, self.windowSize.x + 280/zoom, self.windowSize.y + self.windowSize.h - 40/zoom, tocolor(140, 140, 140, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "left", "top", true)
                        dxDrawText(v.text, self.windowSize.x + 300/zoom, self.windowSize.y + 80/zoom + (i-1) * 40/zoom, self.windowSize.x + self.windowSize.w - 120/zoom, self.windowSize.y + self.windowSize.h - 40/zoom, tocolor(140, 140, 140, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "left", "top", true)
                        dxDrawText(v.hour, self.windowSize.x + self.windowSize.w - 100/zoom, self.windowSize.y + 80/zoom + (i-1) * 40/zoom, self.windowSize.x + self.windowSize.w - 20/zoom, self.windowSize.y + self.windowSize.h - 40/zoom, tocolor(140, 140, 140, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "center", "top")
                    end
                end

                if #self.focusedAppData.data > 11 then
                    local b1 = (self.windowSize.h - 165/zoom) / #self.focusedAppData.data
                    local barY = b1 * self.scroll
                    local barH = b1 * 11

                    dxDrawRectangle(self.windowSize.x + self.windowSize.w - 10/zoom, self.windowSize.y + 75/zoom, 5/zoom, self.windowSize.h - 165/zoom, tocolor(47, 47, 47, 255 * self.alpha))
                    dxDrawRectangle(self.windowSize.x + self.windowSize.w - 10/zoom, self.windowSize.y + 75/zoom + barY, 5/zoom, barH, tocolor(67, 67, 67, 255 * self.alpha))
                end
            end

            if self.fractionType ~= "crime" and not self.addObjectTitle then
                dxDrawRectangle(self.windowSize.x + self.windowSize.w - (self.windowSize.w - 300/zoom)/2 - 300/zoom, self.windowSize.y + self.windowSize.h - 80/zoom, 300/zoom, 35/zoom, tocolor(37, 37, 37, 255 * self.alpha))
                dxDrawText("Bir ilan yayınla", self.windowSize.x + self.windowSize.w - (self.windowSize.w - 300/zoom)/2 - 300/zoom, self.windowSize.y + self.windowSize.h - 80/zoom, self.windowSize.x + self.windowSize.w - (self.windowSize.w - 300/zoom)/2, self.windowSize.y + self.windowSize.h - 45/zoom, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "center", "center")

            elseif self:isMouseInPosition(self.windowSize.x + self.windowSize.w - (self.windowSize.w - 300/zoom)/2 - 300/zoom, self.windowSize.y + self.windowSize.h - 80/zoom, 300/zoom, 35/zoom, self.addObjectTitle) and not self.addObjectTitle then
                dxDrawRectangle(self.windowSize.x + self.windowSize.w - (self.windowSize.w - 300/zoom)/2 - 300/zoom, self.windowSize.y + self.windowSize.h - 80/zoom, 300/zoom, 35/zoom, tocolor(47, 47, 47, 255 * self.alpha))
                dxDrawText("Bir ilan yayınla", self.windowSize.x + self.windowSize.w - (self.windowSize.w - 300/zoom)/2 - 300/zoom, self.windowSize.y + self.windowSize.h - 80/zoom, self.windowSize.x + self.windowSize.w - (self.windowSize.w - 300/zoom)/2, self.windowSize.y + self.windowSize.h - 45/zoom, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "center", "center")

            else
                dxDrawRectangle(self.windowSize.x + self.windowSize.w - (self.windowSize.w - 300/zoom)/2 - 300/zoom, self.windowSize.y + self.windowSize.h - 80/zoom, 300/zoom, 35/zoom, tocolor(37, 37, 37, 255 * self.alpha))
                dxDrawText("Bir ilan yayınla", self.windowSize.x + self.windowSize.w - (self.windowSize.w - 300/zoom)/2 - 300/zoom, self.windowSize.y + self.windowSize.h - 80/zoom, self.windowSize.x + self.windowSize.w - (self.windowSize.w - 300/zoom)/2, self.windowSize.y + self.windowSize.h - 45/zoom, tocolor(160, 160, 160, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "center", "center")
            end
        end

        dxDrawText("Bağlantı: Özel - Silah", self.windowSize.x + 10/zoom, self.windowSize.y + self.windowSize.h - 30/zoom, self.windowSize.x + 8/zoom, self.windowSize.y + self.windowSize.h, tocolor(140, 140, 140, 255 * self.alpha), 1/zoom, self.fonts.icons, "left", "center", false, false, true)


    elseif self.focusedAppData.window == "drugs" then
        if not self.focusedAppData.data then
            dxDrawText("Reklamlar yükleniyor...", self.windowSize.x, self.windowSize.y, self.windowSize.x + self.windowSize.w, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.infoApp, "center", "center", true, true)
        else
            if #self.focusedAppData.data < 1 then
                dxDrawText("Bugün için herhangi bir duyuru yok.", self.windowSize.x, self.windowSize.y, self.windowSize.x + self.windowSize.w, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.infoApp, "center", "center", true, true)
            else
                dxDrawText("Konum", self.windowSize.x + 20/zoom, self.windowSize.y + 35/zoom, self.windowSize.x + self.windowSize.w - 20/zoom, self.windowSize.y + 70/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.infoApp, "left", "center")
                dxDrawText("Satılık ürünler", self.windowSize.x + 300/zoom, self.windowSize.y + 35/zoom, self.windowSize.x + self.windowSize.w - 20/zoom, self.windowSize.y + 70/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.infoApp, "left", "center")
                dxDrawText("Zaman", self.windowSize.x + self.windowSize.w - 100/zoom, self.windowSize.y + 35/zoom, self.windowSize.x + self.windowSize.w - 20/zoom, self.windowSize.y + 70/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.infoApp, "center", "center")

                dxDrawLine(self.windowSize.x + 10/zoom, self.windowSize.y + 70/zoom, self.windowSize.x + self.windowSize.w - 15/zoom, self.windowSize.y + 70/zoom, tocolor(57, 57, 57, 255 * self.alpha), 1/zoom)

                for i = 1, 11 do
                    local v = self.focusedAppData.data[i + self.scroll]
                    if v then
                        dxDrawText(v.location, self.windowSize.x + 20/zoom, self.windowSize.y + 80/zoom + (i-1) * 40/zoom, self.windowSize.x + 280/zoom, self.windowSize.y + self.windowSize.h - 40/zoom, tocolor(140, 140, 140, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "left", "top", true)
                        dxDrawText(v.text, self.windowSize.x + 300/zoom, self.windowSize.y + 80/zoom + (i-1) * 40/zoom, self.windowSize.x + self.windowSize.w - 120/zoom, self.windowSize.y + self.windowSize.h - 40/zoom, tocolor(140, 140, 140, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "left", "top", true)
                        dxDrawText(v.hour, self.windowSize.x + self.windowSize.w - 100/zoom, self.windowSize.y + 80/zoom + (i-1) * 40/zoom, self.windowSize.x + self.windowSize.w - 20/zoom, self.windowSize.y + self.windowSize.h - 40/zoom, tocolor(140, 140, 140, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "center", "top")
                    end
                end

                if #self.focusedAppData.data > 11 then
                    local b1 = (self.windowSize.h - 165/zoom) / #self.focusedAppData.data
                    local barY = b1 * self.scroll
                    local barH = b1 * 11

                    dxDrawRectangle(self.windowSize.x + self.windowSize.w - 10/zoom, self.windowSize.y + 75/zoom, 5/zoom, self.windowSize.h - 165/zoom, tocolor(47, 47, 47, 255 * self.alpha))
                    dxDrawRectangle(self.windowSize.x + self.windowSize.w - 10/zoom, self.windowSize.y + 75/zoom + barY, 5/zoom, barH, tocolor(67, 67, 67, 255 * self.alpha))
                end
            end

            if self.fractionType ~= "crime" and not self.addObjectTitle then
                dxDrawRectangle(self.windowSize.x + self.windowSize.w - (self.windowSize.w - 300/zoom)/2 - 300/zoom, self.windowSize.y + self.windowSize.h - 80/zoom, 300/zoom, 35/zoom, tocolor(37, 37, 37, 255 * self.alpha))
                dxDrawText("Bir ilan yayınla", self.windowSize.x + self.windowSize.w - (self.windowSize.w - 300/zoom)/2 - 300/zoom, self.windowSize.y + self.windowSize.h - 80/zoom, self.windowSize.x + self.windowSize.w - (self.windowSize.w - 300/zoom)/2, self.windowSize.y + self.windowSize.h - 45/zoom, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "center", "center")

            elseif self:isMouseInPosition(self.windowSize.x + self.windowSize.w - (self.windowSize.w - 300/zoom)/2 - 300/zoom, self.windowSize.y + self.windowSize.h - 80/zoom, 300/zoom, 35/zoom, self.addObjectTitle) and not self.addObjectTitle then
                dxDrawRectangle(self.windowSize.x + self.windowSize.w - (self.windowSize.w - 300/zoom)/2 - 300/zoom, self.windowSize.y + self.windowSize.h - 80/zoom, 300/zoom, 35/zoom, tocolor(47, 47, 47, 255 * self.alpha))
                dxDrawText("Bir ilan yayınla", self.windowSize.x + self.windowSize.w - (self.windowSize.w - 300/zoom)/2 - 300/zoom, self.windowSize.y + self.windowSize.h - 80/zoom, self.windowSize.x + self.windowSize.w - (self.windowSize.w - 300/zoom)/2, self.windowSize.y + self.windowSize.h - 45/zoom, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "center", "center")

            else
                dxDrawRectangle(self.windowSize.x + self.windowSize.w - (self.windowSize.w - 300/zoom)/2 - 300/zoom, self.windowSize.y + self.windowSize.h - 80/zoom, 300/zoom, 35/zoom, tocolor(37, 37, 37, 255 * self.alpha))
                dxDrawText("Bir ilan yayınla", self.windowSize.x + self.windowSize.w - (self.windowSize.w - 300/zoom)/2 - 300/zoom, self.windowSize.y + self.windowSize.h - 80/zoom, self.windowSize.x + self.windowSize.w - (self.windowSize.w - 300/zoom)/2, self.windowSize.y + self.windowSize.h - 45/zoom, tocolor(160, 160, 160, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "center", "center")
            end
        end

        dxDrawText("Bağlantı: Özel - Uyuşturucu", self.windowSize.x + 10/zoom, self.windowSize.y + self.windowSize.h - 30/zoom, self.windowSize.x + 8/zoom, self.windowSize.y + self.windowSize.h, tocolor(140, 140, 140, 255 * self.alpha), 1/zoom, self.fonts.icons, "left", "center", false, false, true)
    end
end

function Computer:renderUpgradeAppWindow()
    if (self:isMouseInPosition(self.windowSize.x, self.windowSize.y + 30/zoom, 300/zoom, self.windowSize.h - 60/zoom, self.acceptWindowTitle) and not self.acceptWindowTitle) or self.acceptWindowIndex == 1 then
        dxDrawRectangle(self.windowSize.x, self.windowSize.y + 30/zoom, 300/zoom, self.windowSize.h - 60/zoom, tocolor(32, 32, 32, 255 * self.alpha))
    elseif (self:isMouseInPosition(self.windowSize.x + 300/zoom, self.windowSize.y + 30/zoom, 300/zoom, self.windowSize.h - 60/zoom, self.acceptWindowTitle) and not self.acceptWindowTitle) or self.acceptWindowIndex == 2 then
        dxDrawRectangle(self.windowSize.x + 300/zoom, self.windowSize.y + 30/zoom, 300/zoom, self.windowSize.h - 60/zoom, tocolor(32, 32, 32, 255 * self.alpha))
    elseif (self:isMouseInPosition(self.windowSize.x + 600/zoom, self.windowSize.y + 30/zoom, 300/zoom, self.windowSize.h - 60/zoom, self.acceptWindowTitle) and not self.acceptWindowTitle) or self.acceptWindowIndex == 3 then
        dxDrawRectangle(self.windowSize.x + 600/zoom, self.windowSize.y + 30/zoom, 300/zoom, self.windowSize.h - 60/zoom, tocolor(32, 32, 32, 255 * self.alpha))
    end

    dxDrawImage(self.windowSize.x + (300/zoom - 128/zoom)/2, self.windowSize.y + 80/zoom, 128/zoom, 128/zoom, self.textures.upgrade_person, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
    dxDrawImage(self.windowSize.x + (300/zoom - 128/zoom)/2 + 300/zoom, self.windowSize.y + 80/zoom, 128/zoom, 128/zoom, self.textures.upgrade_vehicle, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
    dxDrawImage(self.windowSize.x + (300/zoom - 128/zoom)/2 + 600/zoom, self.windowSize.y + 80/zoom, 128/zoom, 128/zoom, self.textures.upgrade_money, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))

dxDrawText("Çalışan Sınırı", self.windowSize.x + 10/zoom, self.windowSize.y + 250/zoom, self.windowSize.x + 290/zoom, self.windowSize.y + self.windowSize.h, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.upgradeName, "center", "top", false, false, true)
dxDrawText(string.format("Maliyet: $%s", self:formatNumber(self.leaderData.info.players * 15000)), self.windowSize.x + 10/zoom, self.windowSize.y + 280/zoom, self.windowSize.x + 290/zoom, self.windowSize.y + self.windowSize.h, tocolor(184, 153, 53, 255 * self.alpha), 1/zoom, self.fonts.infoApp, "center", "top", false, false, true)
dxDrawText("Araç Sınırı", self.windowSize.x + 310/zoom, self.windowSize.y + 250/zoom, self.windowSize.x + 590/zoom, self.windowSize.y + self.windowSize.h, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.upgradeName, "center", "top", false, false, true)
dxDrawText(string.format("Maliyet: $%s", self:formatNumber(self.leaderData.info.vehicles * 20000)), self.windowSize.x + 310/zoom, self.windowSize.y + 280/zoom, self.windowSize.x + 590/zoom, self.windowSize.y + self.windowSize.h, tocolor(184, 153, 53, 255 * self.alpha), 1/zoom, self.fonts.infoApp, "center", "top", false, false, true)
dxDrawText("Kazanç Artışı", self.windowSize.x + 610/zoom, self.windowSize.y + 250/zoom, self.windowSize.x + self.windowSize.w - 10/zoom, self.windowSize.y + self.windowSize.h, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.upgradeName, "center", "top", false, false, true)
dxDrawText(string.format("Maliyet: $%s", self:formatNumber((self.leaderData.info.moneyBonus * 50000) + 50000)), self.windowSize.x + 610/zoom, self.windowSize.y + 280/zoom, self.windowSize.x + self.windowSize.w - 10/zoom, self.windowSize.y + self.windowSize.h, tocolor(184, 153, 53, 255 * self.alpha), 1/zoom, self.fonts.infoApp, "center", "top", false, false, true)

dxDrawText("Bu yükseltme daha fazla çalışanı işe almanıza izin verecektir. Organizasyondaki oyuncu sayısı gelirinize bağlıdır. Maksimum sınırı artırarak ve birkaç ekstra kişiyi işe alarak organizasyonun daha hızlı büyümesine yardımcı olabilirsiniz.", self.windowSize.x + 10/zoom, self.windowSize.y + 320/zoom, self.windowSize.x + 290/zoom, self.windowSize.y + self.windowSize.h - 40/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.closeApp, "center", "top", true, true, true)
dxDrawText(string.format("Mevcut sınır: %d", self.leaderData.info.players * 5), self.windowSize.x + 10/zoom, self.windowSize.y + 470/zoom, self.windowSize.x + 290/zoom, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.infoApp, "center", "top", false, false, true)
dxDrawText(string.format("Artırılmış sınır: %d", self.leaderData.info.players * 5 + 5), self.windowSize.x + 10/zoom, self.windowSize.y + 495/zoom, self.windowSize.x + 290/zoom, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.infoApp, "center", "top", false, false, true)

dxDrawText("Bu yükseltme organizasyona daha fazla araç atama imkanı sağlayacaktır. Bazı çalışanlarınız araçlarını paylaşmak istiyorsa, onları organizasyona atayın. Bu sayede işe gitmek daha kolay olacaktır.", self.windowSize.x + 310/zoom, self.windowSize.y + 320/zoom, self.windowSize.x + 590/zoom, self.windowSize.y + self.windowSize.h - 40/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.closeApp, "center", "top", true, true, true)
dxDrawText(string.format("Mevcut sınır: %d", self.leaderData.info.vehicles * 3), self.windowSize.x + 310/zoom, self.windowSize.y + 470/zoom, self.windowSize.x + 590/zoom, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.infoApp, "center", "top", false, false, true)
dxDrawText(string.format("Artırılmış sınır: %d", self.leaderData.info.vehicles * 3 + 3), self.windowSize.x + 310/zoom, self.windowSize.y + 495/zoom, self.windowSize.x + 590/zoom, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.infoApp, "center", "top", false, false, true)

dxDrawText("Bu yükseltme organizasyonun ve çalışanların gelirini artırmanıza yardımcı olacaktır. Organizasyonun geliri ne kadar yüksek olursa, ödeyebileceğiniz maaşlar da o kadar yüksek olur. Yüksek maaşlarla çalışanlarınız mutlu olacaklar.", self.windowSize.x + 610/zoom, self.windowSize.y + 320/zoom, self.windowSize.x + self.windowSize.w - 10/zoom, self.windowSize.y + self.windowSize.h - 40/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.closeApp, "center", "top", true, true, true)
dxDrawText(string.format("Mevcut gelir artışı: +%d%%", self.leaderData.info.moneyBonus + 5), self.windowSize.x + 610/zoom, self.windowSize.y + 470/zoom, self.windowSize.x + self.windowSize.w - 10/zoom, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.infoApp, "center", "top", false, false, true)
dxDrawText(string.format("Artırılmış gelir artışı: +%d%%", self.leaderData.info.moneyBonus + 6), self.windowSize.x + 610/zoom, self.windowSize.y + 495/zoom, self.windowSize.x + self.windowSize.w - 10/zoom, self.windowSize.y + self.windowSize.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.infoApp, "center", "top", false, false, true)
end


function Computer:renderAppOptions()
    for i, v in pairs(guiInfo.appOptions) do
        if self:isMouseInPosition(self.windowSize.x + self.windowSize.w - 40/zoom * i, self.windowSize.y, 40/zoom, 30/zoom, self.acceptWindowTitle or self.addObjectTitle or (v.type == "resize" and self.blockResize)) and not self.acceptWindowTitle and not self.addObjectTitle then
            if i == 1 then
                dxDrawRectangle(self.windowSize.x + self.windowSize.w - 40/zoom * i, self.windowSize.y, 40/zoom, 30/zoom, tocolor(160, 20, 20, 255 * self.alpha))
            elseif v.type == "resize" and self.blockResize then
            else
                dxDrawRectangle(self.windowSize.x + self.windowSize.w - 40/zoom * i, self.windowSize.y, 40/zoom, 30/zoom, tocolor(70, 70, 70, 255 * self.alpha))
            end

            if v.type == "resize" then
                if self.windowSize.size == "full" then
                    if self.blockResize then
                        self:renderCursorHint("Bu uygulama pencereli modu desteklemiyor")
                        dxDrawImage(self.windowSize.x + 13/zoom + self.windowSize.w - 40/zoom * i, self.windowSize.y + 8/zoom, 14/zoom, 14/zoom, self.textures.resize_down, 0, 0, 0, tocolor(80, 80, 80, 255 * self.alpha), true)

                    else
                        dxDrawImage(self.windowSize.x + 13/zoom + self.windowSize.w - 40/zoom * i, self.windowSize.y + 8/zoom, 14/zoom, 14/zoom, self.textures.resize_down, 0, 0, 0, tocolor(220, 220, 220, 255 * self.alpha), true)
                        self:renderCursorHint("küçült")
                    end

                else
                    if self.blockResize then
                        self:renderCursorHint("Bu uygulama tam ekran modunu desteklemiyor")
                        dxDrawImage(self.windowSize.x + 13/zoom + self.windowSize.w - 40/zoom * i, self.windowSize.y + 8/zoom, 14/zoom, 14/zoom, self.textures.resize_up, 0, 0, 0, tocolor(80, 80, 80, 255 * self.alpha), true)

                    else
                        dxDrawImage(self.windowSize.x + 13/zoom + self.windowSize.w - 40/zoom * i, self.windowSize.y + 8/zoom, 14/zoom, 14/zoom, self.textures.resize_up, 0, 0, 0, tocolor(220, 220, 220, 255 * self.alpha), true)
                        self:renderCursorHint("Büyüt")
                    end
                end

            else
                dxDrawImage(self.windowSize.x + 13/zoom + self.windowSize.w - 40/zoom * i, self.windowSize.y + 8/zoom, 14/zoom, 14/zoom, self.textures[v.type], 0, 0, 0, tocolor(220, 220, 220, 255 * self.alpha), true)
                self:renderCursorHint(v.hint)
            end

        else
            if v.type == "resize" then
                if self.windowSize.size == "full" then
                    if self.blockResize then
                        dxDrawImage(self.windowSize.x + 13/zoom + self.windowSize.w - 40/zoom * i, self.windowSize.y + 8/zoom, 14/zoom, 14/zoom, self.textures.resize_down, 0, 0, 0, tocolor(80, 80, 80, 255 * self.alpha), true)
                    else
                        dxDrawImage(self.windowSize.x + 13/zoom + self.windowSize.w - 40/zoom * i, self.windowSize.y + 8/zoom, 14/zoom, 14/zoom, self.textures.resize_down, 0, 0, 0, tocolor(120, 120, 120, 255 * self.alpha), true)
                    end
                 else
                    if self.blockResize then
                        dxDrawImage(self.windowSize.x + 13/zoom + self.windowSize.w - 40/zoom * i, self.windowSize.y + 8/zoom, 14/zoom, 14/zoom, self.textures.resize_up, 0, 0, 0, tocolor(80, 80, 80, 255 * self.alpha), true)
                    else
                        dxDrawImage(self.windowSize.x + 13/zoom + self.windowSize.w - 40/zoom * i, self.windowSize.y + 8/zoom, 14/zoom, 14/zoom, self.textures.resize_up, 0, 0, 0, tocolor(120, 120, 120, 255 * self.alpha), true)
                    end
                end

            else
                dxDrawImage(self.windowSize.x + 13/zoom + self.windowSize.w - 40/zoom * i, self.windowSize.y + 8/zoom, 14/zoom, 14/zoom, self.textures[v.type], 0, 0, 0, tocolor(140, 140, 140, 255 * self.alpha), true)
            end
        end
    end
end

function Computer:renderNotificationList()
    if not self.notiOpen then return end
    dxDrawRectangle(guiInfo.noti.x, guiInfo.noti.y, guiInfo.noti.w, guiInfo.noti.h, tocolor(22, 22, 22, 255 * self.alpha), true)
    dxDrawText("Bildirimler", guiInfo.noti.x, guiInfo.noti.y + 10/zoom, guiInfo.noti.x + guiInfo.noti.w, guiInfo.noti.y, tocolor(140, 140, 140, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "center", "top", false, false, true)
    dxDrawRectangle(guiInfo.noti.x, guiInfo.noti.y + 40/zoom, guiInfo.noti.w, 2/zoom, tocolor(37, 37, 37, 255 * self.alpha), true)

    local height = 0
    for i = 1, 18 do
        local v = self.notifications[i]

        if v then
            local h = self:calculateTextHeight(v.text, self.fonts.icons, 1/zoom, guiInfo.noti.w - 30/zoom)
            local last = height + h + 100/zoom > guiInfo.noti.h
            self:renderNotification(height, v.name, v.text, h, i, last)
            if last then break end

            height = height + h + 40/zoom
        end
    end
end

function Computer:renderNotification(height, player, text, h, i, last)
    dxDrawText(player, guiInfo.noti.x + 10/zoom, guiInfo.noti.y + 55/zoom + height, guiInfo.noti.x + guiInfo.noti.w, guiInfo.noti.y + 75/zoom + height, tocolor(190, 190, 190, 255 * self.alpha), 1/zoom, self.fonts.titleApp, "left", "top", true, true, true)
    dxDrawText(text, guiInfo.noti.x + 10/zoom, guiInfo.noti.y + 75/zoom + height, guiInfo.noti.x + guiInfo.noti.w - 10/zoom, guiInfo.noti.y + guiInfo.noti.h, tocolor(140, 140, 140, 255 * self.alpha), 1/zoom, self.fonts.icons, "left", "top", true, true, true)

    if i ~= #self.notifications and not last then
        dxDrawRectangle(guiInfo.noti.x + 5/zoom, guiInfo.noti.y + 85/zoom + height + h, guiInfo.noti.w - 10/zoom, 2/zoom, tocolor(37, 37, 37, 255 * self.alpha), true)
    end
end


function Computer:mouseClick(key, state)
    if exports.TR_dx:isResponseEnabled() then return end
    if state ~= "down" then return end

    if self.acceptWindowTitle then
        if key == "left" then
            if self:isMouseInPosition(guiInfo.accept.x + 10/zoom, guiInfo.accept.y + guiInfo.accept.h - 40/zoom, (guiInfo.accept.w - 30/zoom)/2, 30/zoom) then
                self.acceptWindowTitle = nil
                self.acceptWindowText = nil
                self.acceptWindowType = nil
                self.acceptWindowIndex = nil

            elseif self:isMouseInPosition(guiInfo.accept.x + guiInfo.accept.w - (guiInfo.accept.w - 30/zoom)/2 - 10/zoom, guiInfo.accept.y + guiInfo.accept.h - 40/zoom, (guiInfo.accept.w - 30/zoom)/2, 30/zoom) then
                if self.acceptWindowType == "remove" then
                    if guiInfo.apps[self.focusedApp].type == "folder_person" then
                        local data = self.leaderData[guiInfo.apps[self.focusedApp].type][self.acceptWindowIndex]

                        triggerServerEvent("removeComputerWorker", resourceRoot, self.computerType == "fraction" and true or false, self.fractionID, data.UID, data.name)

                        self.responseInfo = {
                            player = data.name,
                            type = "remove",
                        }
                        exports.TR_dx:setResponseEnabled(true)

                    elseif guiInfo.apps[self.focusedApp].type == "folder_ranks" then
                        local data = self.leaderData[guiInfo.apps[self.focusedApp].type][self.acceptWindowIndex]
                        local defaultRankID = self.leaderData[guiInfo.apps[self.focusedApp].type][1].ID

                        self.responseInfo = {
                            name = data.name,
                            changeRankIndex = self.acceptWindowIndex,
                            type = "rankRemove",
                        }

                        triggerServerEvent("removeComputerRank", resourceRoot, self.computerType == "fraction" and true or false, self.fractionID, data.ID, data.name, defaultRankID, data.level)
                        exports.TR_dx:setResponseEnabled(true)
                    end

                elseif self.acceptWindowType == "declineVehicle" then
                    local data = self.leaderData[guiInfo.apps[self.focusedApp].type][self.acceptWindowIndex]
                    triggerServerEvent("declineComputerVehicle", resourceRoot, self.fractionID, data.ID, data.name)
                    exports.TR_dx:setResponseEnabled(true)

                elseif self.acceptWindowType == "removeVehicle" then
                    local data = self.leaderData[guiInfo.apps[self.focusedApp].type][self.acceptWindowIndex]
                    triggerServerEvent("removeComputerVehicle", resourceRoot, self.fractionID, data.ID, data.name)
                    exports.TR_dx:setResponseEnabled(true)

                elseif self.acceptWindowType == "addVehicle" then
                    local data = self.leaderData[guiInfo.apps[self.focusedApp].type][self.acceptWindowIndex]
                    triggerServerEvent("addComputerVehicle", resourceRoot, self.fractionID, data.ID, data.name)
                    exports.TR_dx:setResponseEnabled(true)

                elseif self.acceptWindowType == "changeOffice" then
                    triggerServerEvent("changeComputerOffice", resourceRoot, self.fractionID, self.focusedAppData.info.ID, tonumber(self.focusedAppData.info.price), self.focusedAppData.element)
                    exports.TR_dx:setResponseEnabled(true)

                elseif self.acceptWindowType == "payRent" then
                    triggerServerEvent("payComputerRent", resourceRoot, self.fractionID, self.focusedAppData.data.rentCost)
                    exports.TR_dx:setResponseEnabled(true)

                elseif self.acceptWindowType == "buyUpgrade" then
                    triggerServerEvent("payComputerUpgrade", resourceRoot, self.fractionID, self.acceptWindowIndex)
                    exports.TR_dx:setResponseEnabled(true)
                    self.acceptWindowIndex = nil
                end

                self.acceptWindowTitle = nil
                self.acceptWindowText = nil
                self.acceptWindowType = nil
            end
        end
        return

    elseif self.addObjectTitle then
        if self:isMouseInPosition(guiInfo.addObject.x + 10/zoom, guiInfo.addObject.y + guiInfo.addObject.h - 40/zoom, (guiInfo.addObject.w - 30/zoom)/2, 30/zoom) then
            if self.addObjectTitle == "Ek ücret" then
                self.responseInfo = nil
            end

            self.addObjectTitle = nil
            if self.edits then exports.TR_dx:destroyEdit(self.edits.edit) end
            if self.checks then exports.TR_dx:destroyCheck(self.checks); self.checks = nil end
            self.edits = nil
            self.checks = nil

        elseif self:isMouseInPosition(guiInfo.addObject.x + guiInfo.addObject.w - (guiInfo.addObject.w - 30/zoom)/2 - 10/zoom, guiInfo.addObject.y + guiInfo.addObject.h - 40/zoom, (guiInfo.addObject.w - 30/zoom)/2, 30/zoom) then
            local text = guiGetText(self.edits.edit)

            if guiInfo.apps[self.focusedApp].type == "folder_person" then
                if string.len(text) < 3 or string.len(text) > 20 then self:showInfo("Girilen metin hatalı.", "error") return end

                local text = guiGetText(self.edits.edit)
                if text == getPlayerName(localPlayer) then self:showInfo("Kendinizi çalışan olarak ekleyemezsiniz.", "error") return end

                local player = getPlayerFromName(text)
                if not player or not isElement(player) then self:showInfo("Böyle bir kişi bulunamadı.", "error") return end

                for i, v in pairs(self.leaderData[guiInfo.apps[self.focusedApp].type]) do
                    if v.name == text then
                        self:showInfo("Böyle bir kişi zaten çalışan listesinde.", "error")
                        return
                    end
                end

                if getElementInterior(player) ~= getElementInterior(localPlayer) then self:showInfo("Bu kişi senden çok uzakta.", "error") return end
                if getElementDimension(player) ~= getElementDimension(localPlayer) then self:showInfo("Bu kişi senden çok uzakta.", "error") return end
                if getDistanceBetweenPoints3D(Vector3(getElementPosition(localPlayer)), Vector3(getElementPosition(player))) > 5 then self:showInfo("Ta osoba znajduje się zbyt daleko od ciebie.", "error") return end

                triggerServerEvent("addComputerWorker", resourceRoot, self.computerType == "fraction" and true or false, self.fractionID, getElementData(player, "characterUID"), self.leaderData.folder_ranks[1].ID, text)

                self.responseInfo = {
                    player = text,
                    type = "addPlayer",
                }
                exports.TR_dx:setResponseEnabled(true)

            elseif guiInfo.apps[self.focusedApp].type == "folder_ranks" then
                if self.selectedObjectOptions[self.hoveredOption].type == "rename" then
                    if string.len(text) < 3 or string.len(text) > 32 then self:showInfo("Girilen metin hatalı.", "error") return end

                    for i, v in pairs(self.leaderData[guiInfo.apps[self.focusedApp].type]) do
                        if v.name == text then
                            self:showInfo("Bu rütbe zaten mevcut.", "error")
                            return
                        end
                    end

                    self.responseInfo = {
                        text = text,
                        changeRankIndex = self.changeRankIndex,
                        lastRankName = self.leaderData.folder_ranks[self.changeRankIndex].name,
                        type = "rename",
                    }

                    triggerServerEvent("changeComputerRankName", resourceRoot, self.computerType == "fraction" and true or false, self.fractionID, self.leaderData.folder_ranks[self.changeRankIndex].ID, self.leaderData.folder_ranks[self.changeRankIndex].name, text)
                    exports.TR_dx:setResponseEnabled(true)

                elseif self.selectedObjectOptions[self.hoveredOption].type == "add" then
                    if string.len(text) < 3 or string.len(text) > 32 then self:showInfo("Girilen metin hatalı.", "error") return end

                    for i, v in pairs(self.leaderData[guiInfo.apps[self.focusedApp].type]) do
                        if v.name == text then
                            self:showInfo("Bu rütbe zaten mevcut.", "error")
                            return
                        end
                    end

                    self.responseInfo.text = text
                    triggerServerEvent("addComputerRank", resourceRoot, self.computerType == "fraction" and true or false, self.fractionID, self.responseInfo.lastRank.level, text)
                    exports.TR_dx:setResponseEnabled(true)

                end

            elseif guiInfo.apps[self.focusedApp].type == "info" then
			if self.addObjectTitle == "Organizasyon Logosunu Değiştir" then
				if string.len(text) < 5 then
					self:showInfo("Girilen bağlantı geçersiz.", "error")
					return
				end
				if isLink(text) ~= 1 then
					self:showInfo("Girilen bağlantı geçersiz.", "error")
					return
				end
				if not string.find(text, "imgur") then
					self:showInfo("Girilen bağlantı imgur bağlantısı değil.", "error")
					return
				end
				if not string.find(text, ".png") then
					self:showInfo("Girilen bağlantı doğrudan bir .png resim bağlantısı değil.", "error")
					return
				end
			end

                    self.responseInfo = {
                        player = text,
                        type = "changeLogo",
                    }
                    triggerServerEvent("changeComputerLogo", resourceRoot, self.fractionID, text)
                    exports.TR_dx:setResponseEnabled(true)
                end

            elseif guiInfo.apps[self.focusedApp].type == "kazanç" then
                if self.addObjectTitle == "Kuruluşa bağış" then
                    local amount = tonumber(text)

                    if string.len(text) < 1 then self:showInfo("Girilen tutar hatalı.", "error") return end
                    if amount == nil then self:showInfo("Girilen tutar hatalı.", "error") return end

                    exports.TR_dx:setEditText(self.edits.edit, string.format("%.2f", amount))

                    if amount < 0.01 then
                        self:showInfo("Girilen tutar aşağıdakilerden büyük olmalıdır: \n$0.01.", "error")
                        return
                    end

                    local data = getElementData(localPlayer, "characterData")
                    local money = tonumber(data.money)

                    if money < amount then
                        self:showInfo("Üstünde o kadar para yok.", "error")
                        return
                    end

                    self.responseInfo = {
                        type = "giveMoneyToOrg",
                        amount = amount,
                    }

                    exports.TR_dx:setResponseEnabled(true)
                    triggerServerEvent("addMoneyToOrganization", resourceRoot, self.fractionID, amount)

                elseif self.addObjectTitle == "Ek ücret" then
                    if string.len(text) < 1 then self:showInfo("Girilen oyuncu geçersiz.", "error") return end

                    if self.responseInfo then
                        if self.responseInfo.type == "additionalPaymentPlayer" then
                            local amount = tonumber(text)
                            if amount == nil then self:showInfo("Girilen tutar hatalı.", "error") return end

                            exports.TR_dx:setEditText(self.edits.edit, string.format("%.2f", amount))

                            if amount < 0.01 then
                                self:showInfo("Girilen tutar aşağıdakilerden büyük olmalıdır: \n$0.01.", "error")
                                return
                            end

                            if tonumber(self.leaderData["info"].money) < amount then
                                self:showInfo("Örgütün o kadar parası yok.", "error")
                                return
                            end

                            self.responseInfo.amount = amount

                            exports.TR_dx:setResponseEnabled(true)
                            triggerServerEvent("addMoneyToPlayerByOrganization", resourceRoot, self.fractionID, amount, self.responseInfo.player)
                            return
                        end
                    end

                    for i, v in pairs(self.leaderData.folder_person) do
                        if v.name == text then
                            self.responseInfo = {
                                type = "additionalPaymentPlayer",
                                player = text,
                            }
                            exports.TR_dx:setEditText(self.edits.edit, "")
                            self:addObject("Ek ücret", "Toplam", false, "Geri")
                            return
                        end
                    end

                    self:showInfo("Bu organizasyonda böyle bir kişi çalışmıyor.", "error")
                end


            elseif guiInfo.apps[self.focusedApp].type == "darkweb" then
                if self.responseInfo.type == "setDarkWebLocation" then
                    if string.len(text) < 5 or string.len(text) > 100 then self:showInfo("5 ile 100 karakter arasında olmalıdır.", "error") return end

                    self.responseInfo = {
                        type = "setDarkWebText",
                        location = text,
                    }
                    self:addObject("Ürün ve fiyat", "Ürün ve fiyatı girin", false, "Dalej")

                elseif self.responseInfo.type == "setDarkWebText" then
                    if string.len(text) < 5 or string.len(text) > 100 then self:showInfo("Ürün ve fiyat 5 ila 100 karakter arasında olmalıdır.", "error") return end

                    self.responseInfo = {
                        type = "setDarkWebHour",
                        location = self.responseInfo.location,
                        text = text,
                    }
                    self:addObject("Toplantı saati", "Toplantı saatini girin", false, "Dodaj")

                elseif self.responseInfo.type == "setDarkWebHour" then
                    if string.len(text) < 0 or string.len(text) > 5 then self:showInfo("Zaman 0 ila 5 karakter içermelidir.", "error") return end

                    self.addObjectTitle = nil
                    if self.edits and self.edits.edit then exports.TR_dx:destroyEdit(self.edits.edit); self.edits.edit = nil end

                    exports.TR_dx:setResponseEnabled(true)
                    triggerServerEvent("addGangDarkwebData", resourceRoot, self.focusedAppData.window, self.responseInfo.location, self.responseInfo.text, text)

                    self.responseInfo = nil
                end
            end
        end
        return
    end

    if key == "left" then
        if self.selectedObject then
            if not self.hoveredOption then self.selectedObject = nil return end
            if self.selectedObjectOptions[self.hoveredOption].type == "rank" then
                local posY = self.selectedObjectPos.y + (self.hoveredOption-1) * 25/zoom + #self.leaderData.folder_ranks * 25/zoom >= sy - 40/zoom and self.selectedObjectPos.y + self.hoveredOption * 25/zoom - #self.leaderData.folder_ranks * 25/zoom or self.selectedObjectPos.y + (self.hoveredOption-1) * 25/zoom

                if self.leaderData.folder_ranks then
                    posY = self.selectedObjectPos.y + (self.hoveredOption-1) * 25/zoom + #self.leaderData.folder_ranks * 25/zoom >= sy - 40/zoom and self.selectedObjectPos.y + self.hoveredOption * 25/zoom - #self.leaderData.folder_ranks * 25/zoom or self.selectedObjectPos.y + (self.hoveredOption-1) * 25/zoom

                    for k, rank in pairs(self.leaderData.folder_ranks) do
                        if self:isMouseInPosition(self.selectedObjectPos.x + self.selectedObjectPos.w + 2/zoom, posY + (k-1) * 25/zoom, self.selectedObjectPos.w, 25/zoom, true) then
                            if self.selectedObjectData.rankID == rank.ID then return end

                            local _, playerRank, _, canManage = self:getPlayerRank()
                            local playerName = getPlayerName(localPlayer)

                            if not playerRank or not canManage then self:showInfo("Bu seçeneğe erişiminiz yok.", "error"); self.selectedObject = nil return end
                            if self.selectedObjectData.name == playerName then self:showInfo("Sıralamayı kendiniz değiştiremezsiniz.", "error"); self.selectedObject = nil return end

                            for i, v in pairs(self.leaderData[guiInfo.apps[self.focusedApp].type]) do
                                if self.selectedObjectData.name == v.name then
                                    local _, targetRank = self:getPlayerRank(v.name)

                                    if playerRank <= rank.level then
                                        self:showInfo("Bu çalışanın rütbesini sizinkine eşit veya daha yüksek bir rütbeyle değiştiremezsiniz.", "error")
                                        self.selectedObject = nil
                                        return

                                    elseif playerRank <= targetRank then
                                        self:showInfo("Bu çalışanın rütbesini değiştiremezsiniz çünkü onun rütbesi sizinkinden yüksek.", "error")
                                        self.selectedObject = nil
                                        return
                                    end

                                    self.responseInfo = {
                                        objectIndex = i,
                                        player = v.name,
                                        rankID = rank.ID,
                                        rankName = rank.name,
                                        type = "changeRank",
                                    }

                                    triggerServerEvent("changeComputerWorkerRank", resourceRoot, self.computerType == "fraction" and true or false, self.fractionID, v.UID, v.name, rank.ID, rank.name)
                                    exports.TR_dx:setResponseEnabled(true)
                                    break
                                end
                            end
                            self.selectedObject = nil
                            return
                        end
                    end
                end

                if self:isMouseInPosition(self.selectedObjectPos.x, self.selectedObjectPos.y + (self.hoveredOption-1) * 25/zoom, self.selectedObjectPos.w, 25/zoom) then return end

            else
                if self:isMouseInPosition(self.selectedObjectPos.x, self.selectedObjectPos.y + (self.hoveredOption-1) * 25/zoom, self.selectedObjectPos.w, 25/zoom) then
                    if self.selectedObjectOptions[self.hoveredOption].type == "remove" then
                        if guiInfo.apps[self.focusedApp].type == "folder_person" then
                            local _, playerRank, _, canManage = self:getPlayerRank()
                            local playerName = getPlayerName(localPlayer)

                            if self.computerType == "fraction" then
                                if not playerRank or not canManage then self:showInfo("Bu seçeneğe erişiminiz yok.", "error"); self.selectedObject = nil return end
                                if self.selectedObjectData.name == playerName then self:showInfo("Kendini kovamazsın.", "error") self.selectedObject = nil return end

                            else
                                if (not playerRank or not canManage) and self.selectedObjectData.name ~= playerName then self:showInfo("Nie masz dostępu do tej opcji.", "error"); self.selectedObject = nil return end
                            end

                            for i, v in pairs(self.leaderData[guiInfo.apps[self.focusedApp].type]) do
                                if self.selectedObjectData.name == v.name then
                                    local _, targetRank = self:getPlayerRank(v.name)
                                    if playerRank <= targetRank and v.name ~= playerName then
                                        self:showInfo("Bu çalışanı kovamazsınız.", "error")
                                        self.selectedObject = nil
                                        return
                                    end

                                    if self.computerType == "organization" then
                                        if self.leaderData.info.owner == v.name then
                                            self:showInfo("Kuruluşun sahibini kovamazsınız.", "error")
                                            self.selectedObject = nil
                                            return
                                        end
                                    end

                                    if v.name == playerName then
                                        self:openAcceptWindow("Bir çalışanı kovmak", "Kendinizi kovmak istediğinizden emin misiniz??", "remove", i)
                                    else
                                        self:openAcceptWindow("Bir çalışanı işten çıkarmak", string.format("Oyuncuyu kovmak istediğinizden emin misiniz? %s?", v.name), "remove", i)
                                    end
                                    self.selectedObject = nil
                                    return
                                end
                            end

                        elseif guiInfo.apps[self.focusedApp].type == "folder_ranks" then
                            local _, _, _, canManage = self:getPlayerRank()
                            if not canManage then self:showInfo("Bu seçeneğe erişiminiz yok.", "error"); self.selectedObject = nil return end

                            local data = self.leaderData[guiInfo.apps[self.focusedApp].type][self.selectedObject]
                            if self.selectedObject == 1 or self.selectedObject == #self.leaderData[guiInfo.apps[self.focusedApp].type] then
                                self:showInfo("Bir temel sıralamayı kaldıramazsınız.", "error")
                                self.selectedObject = nil
                                return
                            end

                            self:openAcceptWindow("Sıralamayı silme", string.format("Sıralamayı silmek istediğinizden emin misiniz? %s?", data.name), "remove", self.selectedObject)
                            self.selectedObject = nil
                        end

                    elseif self.selectedObjectOptions[self.hoveredOption].type == "add" then
                        if guiInfo.apps[self.focusedApp].type == "folder_person" then
                            local _, _, _, canManage = self:getPlayerRank()
                            if not canManage then self:showInfo("Bu seçeneğe erişiminiz yok.", "error"); self.selectedObject = nil return end

                            self:addObject("Yeni bir çalışan ekleme", "Bir ad girin")

                        elseif guiInfo.apps[self.focusedApp].type == "folder_ranks" then
                            local _, _, _, canManage = self:getPlayerRank()
                            if not canManage then self:showInfo("Bu seçeneğe erişiminiz yok.", "error"); self.selectedObject = nil return end

                            if #self.leaderData.folder_ranks >= 20 then
                                self:showInfo("Sınıra ulaşıldığı için daha fazla derece ekleyemezsiniz.", "error")
                                self.selectedObject = nil
                                return
                            end

                            self.responseInfo = {
                                lastRank = self.leaderData.folder_ranks[#self.leaderData.folder_ranks],
                                type = "addRank",
                            }

                            self:addObject("Yeni bir rütbe ekleme", "Rütbe için bir ad girin")
                        end

                    elseif self.selectedObjectOptions[self.hoveredOption].type == "givePayment" then
                        local _, _, _, canManage = self:getPlayerRank()
                        if not canManage then self:showInfo("Bu seçeneğe erişiminiz yok.", "error"); self.selectedObject = nil return end

                        self.responseInfo = {
                            type = "givePayment",
                        }
                        exports.TR_dx:setResponseEnabled(true)

                        triggerServerEvent("payComputerPlayers", resourceRoot, self.fractionID)

                    elseif self.selectedObjectOptions[self.hoveredOption].type == "rename" then
                        local _, _, _, canManage = self:getPlayerRank()
                        if not canManage then self:showInfo("Bu seçeneğe erişiminiz yok.", "error"); self.selectedObject = nil return end

                        local rankName = self.leaderData[guiInfo.apps[self.focusedApp].type][self.selectedObject].name
                        self.changeRankIndex = self.selectedObject
                        self:addObject("Sıralamayı Düzenle", "Sıralama için bir ad girin", rankName, "Kaydet")

                    elseif self.selectedObjectOptions[self.hoveredOption].type == "declineVehicle" then
                        local data = self.leaderData[guiInfo.apps[self.focusedApp].type][self.selectedObject]

                        self.responseInfo = {
                            text = data.name,
                            type = "declineVehicle",
                            selected = self.selectedObject,
                        }
                        self:openAcceptWindow("Araç siliniyor", "Bu aracı eklemeyi reddetmek istediğinizden emin misiniz?", "declineVehicle", self.selectedObject)

                    elseif self.selectedObjectOptions[self.hoveredOption].type == "removeVehicle" then
                        local data = self.leaderData[guiInfo.apps[self.focusedApp].type][self.selectedObject]

                        self.responseInfo = {
                            text = data.name,
                            type = "removeVehicle",
                            selected = self.selectedObject,
                        }
                        self:openAcceptWindow("Aracın silinmesi", "Aracı kuruluştan silmek istediğinizden emin misiniz?", "removeVehicle", self.selectedObject)

                    elseif self.selectedObjectOptions[self.hoveredOption].type == "addVehicle" then
                        local data = self.leaderData[guiInfo.apps[self.focusedApp].type][self.selectedObject]

                        self.responseInfo = {
                            text = data.name,
                            type = "addVehicle",
                            selected = self.selectedObject,
                        }
                        self:openAcceptWindow("Araç atama", "Aracı kuruluşa atamak istediğinizden emin misiniz?", "addVehicle", self.selectedObject)
                    end
                end
            end

        elseif self.focusedApp then
            if guiInfo.apps[self.focusedApp].type == "darkweb" then
                if self.focusedAppData.window == "main" then
                    if (self:isMouseInPosition(self.windowSize.x, self.windowSize.y + 30/zoom, self.windowSize.w/2, self.windowSize.h - 60/zoom, self.acceptWindowTitle) and not self.acceptWindowTitle) or self.acceptWindowIndex == 1 then
                        self.focusedAppData.window = "drugs"

                        exports.TR_dx:setResponseEnabled(true)
                        triggerServerEvent("loadGangDarkwebData", resourceRoot, "drugs")

                    elseif (self:isMouseInPosition(self.windowSize.x + self.windowSize.w/2, self.windowSize.y + 30/zoom, 300/zoom, self.windowSize.h - 60/zoom, self.acceptWindowTitle) and not self.acceptWindowTitle) or self.acceptWindowIndex == 3 then
                        self.focusedAppData.window = "weapon"

                        exports.TR_dx:setResponseEnabled(true)
                        triggerServerEvent("loadGangDarkwebData", resourceRoot, "weapon")
                    end

                elseif self.focusedAppData.window == "weapon" and self.fractionType == "crime" and not self.addObjectTitle then
                    if self:isMouseInPosition(self.windowSize.x + self.windowSize.w - (self.windowSize.w - 300/zoom)/2 - 300/zoom, self.windowSize.y + self.windowSize.h - 80/zoom, 300/zoom, 35/zoom) and not self.addObjectTitle then
                        self.responseInfo = {
                            type = "setDarkWebLocation",
                        }
                        self:addObject("Toplantı yeri", "Toplantı yerini girin", false, "Dalej")
                    end

                elseif self.focusedAppData.window == "drugs" and self.fractionType == "crime" and not self.addObjectTitle then
                    if self:isMouseInPosition(self.windowSize.x + self.windowSize.w - (self.windowSize.w - 300/zoom)/2 - 300/zoom, self.windowSize.y + self.windowSize.h - 80/zoom, 300/zoom, 35/zoom) and not self.addObjectTitle then
                        self.responseInfo = {
                            type = "setDarkWebLocation",
                        }
                        self:addObject("Toplantı yeri", "Toplantı yerini girin", false, "Dalej")
                    end
                end
            end
        end
        self.selectedObject = nil


        if self:isMouseInPosition(guiInfo.bar.x + guiInfo.bar.w - 40/zoom, guiInfo.bar.y, 40/zoom, guiInfo.bar.h, true) or (self:isMouseInPosition(guiInfo.noti.x, guiInfo.noti.y, guiInfo.noti.w, guiInfo.noti.h, true) and self.notiOpen) then
            self.notiOpen = true
        else
            self.notiOpen = nil
        end

        if self.iconBar then
            if self:isMouseInPosition(guiInfo.bar.x + 4/zoom + self.iconBar * 48/zoom, guiInfo.bar.y - 32/zoom, 196/zoom, 28/zoom, true) then
                self:closeApp()
                return
            end
        end
        self.iconBar = nil

        for i, v in pairs(self.windowsBar) do
            if self:isMouseInPosition(guiInfo.bar.x + (i-1) * 48/zoom, guiInfo.bar.y, 48/zoom, guiInfo.bar.h, true) then
                if i == 1 then
                    self.iconBar = 0
                else
                    local selectedApp = false
                    for k, app in pairs(guiInfo.apps) do
                        if app.type == v then
                            selectedApp = k
                            break
                        end
                    end
                    if selectedApp then self:focusApp(selectedApp) end
                end
                return
            end
        end

        if self.focusedApp then
            if self:isMouseInPosition(self.windowSize.x + self.windowSize.w - 24/zoom, self.windowSize.y + self.windowSize.h - 22/zoom, 14/zoom, 14/zoom, true) and not self.refreshTick then
                self.refreshTick = getTickCount()
                self.refreshAngle = 0
                self.refreshCount = 0
                return
            end
            for i, v in pairs(guiInfo.appOptions) do
                if self:isMouseInPosition(self.windowSize.x + self.windowSize.w - 40/zoom * i, self.windowSize.y, 40/zoom, 30/zoom, true) and not (v.type == "resize" and self.blockResize) then
                    if v.type == "resize" then
                        self:resizeAppWindow()
                    elseif v.type == "close" then
                        self:closeApp()
                    elseif v.type == "minimalize" then
                        self:minimalizeApp()
                    end
                    return
                end
            end


            if self.focusedAppData.data then
                if self.focusedAppData.icon == "info" then
                    local _, _, _, canManage = self:getPlayerRank()
                    if canManage then
                        if self:isMouseInPosition(self.windowSize.x + self.windowSize.w/2 - (self.windowSize.w/2 - 300/zoom)/2 - 300/zoom, self.windowSize.y + self.windowSize.h - 75/zoom, 300/zoom, 35/zoom) then
                            self:openAcceptWindow("Organizasyon ücreti", "7 günlük organizasyon ücretini ödemek istediğinizden emin misiniz?", "payRent", false)
                        end
                    end

                    if self:isMouseInPosition(self.windowSize.x + self.windowSize.w/2 + (self.windowSize.w/2 - 300/zoom)/2, self.windowSize.y + self.windowSize.h - 75/zoom, 300/zoom, 35/zoom, self.addObjectTitle) then
                        if self.organizationOwner ~= self.playerName then
                            self:showInfo("Kuruluşun logosunu yalnızca sahibi değiştirebilir.", "error")
                            return
                        end

                        self:addObject("Kuruluşun logosunun değiştirilmesi", "img bağlantısı", false, "Zmień")
                    end

                elseif self.focusedAppData.icon == "upgrade" then
                    local _, _, _, canManage = self:getPlayerRank()
                    if canManage then
                        if self:isMouseInPosition(self.windowSize.x, self.windowSize.y + 30/zoom, 300/zoom, self.windowSize.h - 60/zoom) then
                            self.responseInfo = {
                                type = "buyUpgrade",
                                text = "Çalışan sayısını artırdı.",
                                price = tonumber(self.leaderData.info.players * 15000),
                                index = "players",
                            }
                            self:openAcceptWindow("Yükseltme satın alınıyor", "Bu yükseltmeyi satın almak istediğinizden emin misiniz?", "buyUpgrade", 1)

                        elseif self:isMouseInPosition(self.windowSize.x + 300/zoom, self.windowSize.y + 30/zoom, 300/zoom, self.windowSize.h - 60/zoom) then
                            self.responseInfo = {
                                type = "buyUpgrade",
                                text = "Araç sayısı artırıldı.",
                                price = tonumber(self.leaderData.info.vehicles * 20000),
                                index = "vehicles",
                            }
                            self:openAcceptWindow("Yükseltme satın alma", "Bu yükseltmeyi satın almak istediğinizden emin misiniz?", "buyUpgrade", 2)

                        elseif self:isMouseInPosition(self.windowSize.x + 600/zoom, self.windowSize.y + 30/zoom, 300/zoom, self.windowSize.h - 60/zoom) then
                            self.responseInfo = {
                                type = "buyUpgrade",
                                text = "Ulepszył wysokość zarobku.",
                                price = tonumber((self.leaderData.info.moneyBonus * 50000) + 50000),
                                index = "moneyBonus",
                            }
                            self:openAcceptWindow("Yükseltme satın alma", "Bu yükseltmeyi satın almak istediğinizden emin misiniz?", "buyUpgrade", 3)
                        end
                    end

                elseif self.focusedAppData.icon == "earnings" then
                    if self:isMouseInPosition(self.windowSize.x + self.windowSize.w/2 - (self.windowSize.w/2 - 300/zoom)/2 - 300/zoom, self.windowSize.y + self.windowSize.h - 75/zoom, 300/zoom, 35/zoom) then
                        self:addObject("Kuruluşa ödeme", "Depozito tutarı", false, "Wpłać")

                    elseif self:isMouseInPosition(self.windowSize.x + self.windowSize.w/2 + (self.windowSize.w/2 - 300/zoom)/2, self.windowSize.y + self.windowSize.h - 75/zoom, 300/zoom, 35/zoom, self.organizationOwner ~= self.playerName) then
                        if self.organizationOwner ~= self.playerName then
                            self:showInfo("Yalnızca kuruluşun sahibi ek ücret ödeyebilir.", "error")
                            return
                        end

                        self:addObject("Ek ücret", "Oyuncu takma adı", false, "Wybierz")
                    end

                else
                    local maxCol, maxRow, startX = self:calculateRowCount()
                    local col, row = 0, 0
                    for i = 1, maxCol * maxRow do
                        if self.focusedAppData.data[i + self.scroll] then
                            if self:isMouseInPosition(startX + col * 120/zoom, self.windowSize.y + 50/zoom + row * 100/zoom, 100/zoom, 90/zoom) then
                                if self.focusedAppData.data[i + self.scroll].clicked then
                                    if self.clickTick then
                                        if (getTickCount() - self.clickTick)/300 <= 1 then
                                            self.clickTick = nil
                                            self.focusedAppData.data[i + self.scroll].clicked = nil

                                            local appName = guiInfo.apps[self.focusedApp].type
                                            appName = string.find(appName, "_") and split(appName, "_")[2].."_info" or appName.."_info"

                                            local selectedApp = false
                                            for k, app in pairs(guiInfo.apps) do
                                                if app.type == appName then
                                                    selectedApp = k
                                                    break
                                                end
                                            end
                                            if selectedApp then self:openApp(selectedApp, i + self.scroll) end
                                            return
                                        end

                                    else
                                        self.focusedAppData.data[i + self.scroll].clicked = true
                                    end
                                else
                                    self.focusedAppData.data[i + self.scroll].clicked = true
                                    self.clickTick = getTickCount()
                                end
                            else
                                self.focusedAppData.data[i + self.scroll].clicked = nil
                            end

                            col = col + 1
                            if col >= maxCol then
                                col = 0
                                row = row + 1
                            end
                        end
                    end
                end
            end
        end

        for i, v in pairs(guiInfo.apps) do
            guiInfo.apps[i].state = "unclicked"
        end

        local i = 1
        for _, v in pairs(guiInfo.apps) do
            if v.onScreen then
                if self:isMouseInPosition(10/zoom, 15/zoom + (i-1) * 110/zoom, 130/zoom, 85/zoom, true) and self:canClickIconApp() then
                    if self.clickTick and i == self.clickedIcon then
                        if (getTickCount() - self.clickTick)/300 <= 1 then
                            self:openApp(i)
                            self.clickTick = nil
                            return
                        end
                    end

                    guiInfo.apps[i].state = "clicked"
                    self.clickTick = getTickCount()
                    self.clickedIcon = i
                    return
                end
                i = i + 1
            end
        end

    elseif key == "right" then
        self.iconBar = nil
        self.notiOpen = nil

        if self.selectedObject then
            if not self:isMouseInPosition(self.selectedObjectPos.x, self.selectedObjectPos.y, self.selectedObjectPos.w, self.selectedObjectPos.h, true) then
                self.selectedObject = nil
            end
        end

        for i, v in pairs(self.windowsBar) do
            if self:isMouseInPosition(guiInfo.bar.x + (i-1) * 48/zoom, guiInfo.bar.y, 48/zoom, guiInfo.bar.h, true) then
                if i ~= 1 then
                    self.iconBar = i-1
                    break
                end
            end
        end

        if self.focusedApp and self.focusedAppData.data then
            if self:isMouseInPosition(self.windowSize.x, self.windowSize.y + 30/zoom, self.windowSize.w, self.windowSize.h - 30/zoom, true) then
                local maxCol, maxRow, startX = self:calculateRowCount()
                local col, row = 0, 0
                for i = 1, maxCol * maxRow do
                    if self.focusedAppData.data[i + self.scroll] then
                        if self:isMouseInPosition(startX + col * 120/zoom, self.windowSize.y + 50/zoom + row * 100/zoom, 100/zoom, 90/zoom) then
                            local dataApp = guiInfo.apps[self.focusedApp]
                            if not guiInfo.objectOption[dataApp.type] then return end

                            self.selectedObject = i + self.scroll
                            self.selectedObjectData = self.focusedAppData.data[i + self.scroll]
                            self.selectedObjectOptions = self:getObjectOptions(dataApp.type)

                            local cx, cy = getCursorPosition()
                            local optionsH = 25/zoom * #self.selectedObjectOptions
                            local isDownMenu = cy * sy + optionsH <= sy - 40/zoom
                            self.selectedObjectPos = {
                                x = cx * sx,
                                y = isDownMenu and cy * sy or cy * sy - optionsH,
                                w = 200/zoom,
                                h = optionsH,
                            }
                            return
                        end
                    end

                    col = col + 1
                    if col >= maxCol then
                        col = 0
                        row = row + 1
                    end
                end

                local dataApp = guiInfo.apps[self.focusedApp]
                if not guiInfo.objectOption[dataApp.type.."_blank"] then return end

                self.selectedObject = true
                self.selectedObjectData = nil
                self.selectedObjectOptions = guiInfo.objectOption[dataApp.type.."_blank"]

                local cx, cy = getCursorPosition()
                local optionsH = 25/zoom * #self.selectedObjectOptions
                local isDownMenu = cy * sy + optionsH <= sy - 40/zoom
                self.selectedObjectPos = {
                    x = cx * sx,
                    y = isDownMenu and cy * sy or cy * sy - optionsH,
                    w = 200/zoom,
                    h = optionsH,
                }
            end
        end
    end
end

function Computer:getObjectOptions(type)
    if self.computerType == "organization" and type == "folder_vehicle" then
        if self.selectedObjectData.ownedOrg then
            return {
                {
                    title = "Aracı yazın",
                    icon = "close",
                    type = "removeVehicle",
                },
            }
        else
            return {
                {
                    title = "Aracı kabul et",
                    icon = "add",
                    type = "addVehicle",
                },
                {
                    title = "Aracı reddet",
                    icon = "close",
                    type = "declineVehicle",
                },
            }
        end
    end
    return guiInfo.objectOption[type]
end

function Computer:openAcceptWindow(title, text, type, index)
    self.acceptWindowTitle = title
    self.acceptWindowText = text
    self.acceptWindowType = type
    self.acceptWindowIndex = index

    if string.find(text, "\n") then
        guiInfo.accept = {
            x = (sx - 350/zoom)/2,
            y = (sy - 125/zoom)/2,
            w = 350/zoom,
            h = 125/zoom,
        }
    else
        guiInfo.accept = {
            x = (sx - 350/zoom)/2,
            y = (sy - 110/zoom)/2,
            w = 350/zoom,
            h = 110/zoom,
        }
    end
end

function Computer:getPlayerRank(player)
    local playerName = player and player or getPlayerName(localPlayer)
    local plrData
    local rankID

    for i, v in pairs(self.leaderData.folder_person) do
        if v.name == playerName then
            rankID = v.rankID
            break
        end
    end

    for i, v in pairs(self.leaderData.folder_ranks) do
        if v.ID == rankID then
            return v.ID, v.level, v.name, v.canManage
        end
    end
    return false, false, false, false
end

function Computer:showInfo(text, type)
    local typeText = ""
    if type == "error" then typeText = "Błąd" end
    if type == "success" then typeText = "Sukces" end

    self.infoText = text
    self.infoType = typeText
    self.infoImg = type
    self.infoTick = getTickCount()

    local h = self:calculateTextHeight(text, self.fonts.icons, 1/zoom, guiInfo.info.w - 20/zoom) + 45/zoom
    guiInfo.info.y = sy - 40/zoom - h
    guiInfo.info.h = h
end

function Computer:scrollKey(key)
    if not self.focusedApp then return end
    if self.selectedObject then return end
    if not self.focusedAppData.data then return end
    if not self:isMouseInPosition(self.windowSize.x, self.windowSize.y + 30/zoom, self.windowSize.w, self.windowSize.h - 30/zoom, true) then return end

    local maxCol, maxRow = self:calculateRowCount()

    if guiInfo.apps[self.focusedApp] then
        if guiInfo.apps[self.focusedApp].type == "darkweb" then
            if key == "mouse_wheel_up" then
                self.scroll = math.max(self.scroll - 1, 0)

            elseif key == "mouse_wheel_down" then
                if not self.focusedAppData.data then return end
                if #self.focusedAppData.data < 11 then return end
                self.scroll = math.min(self.scroll + 1, #self.focusedAppData.data - 11)
            end
            return
        end
    end

    if key == "mouse_wheel_up" then
        self.scroll = math.max(self.scroll - maxCol, 0)

    elseif key == "mouse_wheel_down" then
        if not self.focusedAppData.data then return end
        self.scroll = math.min(self.scroll + maxCol, (math.ceil(#self.focusedAppData.data / maxCol) - maxRow) * maxCol)
    end
end

function Computer:calculateRowCount()
    local colCount = math.floor(self.windowSize.w / 120/zoom)
    local rowCount = math.floor((self.windowSize.h - 80/zoom) / 100/zoom)
    return colCount, rowCount, self.windowSize.x + (self.windowSize.w - (colCount * 120/zoom) + (#self.focusedAppData.data > colCount * rowCount and 10/zoom or 0))/2
end


function Computer:canClickIconApp()
    if self.windowSize then
        if self.windowSize.size == "full" then return false end
    end
    return true
end

function Computer:resizeAppWindow()
    if not self.focusedApp then return end

    if self.windowSize.size == "full" then
        self.windowSize = guiInfo.app
        self.windowSize.size = "small"
    else
        self.windowSize = guiInfo.fullApp
        self.windowSize.size = "full"
    end
    self.scroll = 0
end

function Computer:minimalizeApp()
    if self.checks then
        exports.TR_dx:destroyCheck(self.checks)
        self.checks = nil
    end

    self.focusedApp = nil
    self.windowSize = nil

    if self.preview then exports.TR_preview:destroyObjectPreview(self.preview) end
    if isElement(self.previewElement) then destroyElement(self.previewElement) end
end

function Computer:focusApp(app, force)
    if self.focusedApp == app and not force then
        if guiInfo.apps[self.focusedApp] then
            if guiInfo.apps[self.focusedApp].type ~= "darkweb" then
                return
            end
        else
            return
        end
    end
    if self.checks then
        exports.TR_dx:destroyCheck(self.checks)
        self.checks = nil
    end

    self.focusedApp = app
    self.windowSize = self.windowSize and self.windowSize or guiInfo.app
    self.windowSize.size = self.windowSize == guiInfo.app and "small" or "full"
    self.scroll = 0

    local dataApp = guiInfo.apps[self.focusedApp]
    if dataApp.type == "bin" then
        self.focusedAppData = {
            data = {},
            text = "Bu klasör boş.",
        }

        self.blockResize = nil

    elseif string.find(dataApp.type, "_info") then
        local _, icon = self:getDataToApp(dataApp.type, dataApp)
        local data, element = self:getInfoToApp(dataApp.type)
        self.focusedAppData = {
            data = nil,
            info = data,
            element = element,
            icon = icon,
        }

        self.windowSize = guiInfo.app
        self.windowSize.size = "small"
        self.blockResize = true

    elseif dataApp.type == "darkweb" then
        self.focusedAppData = {
            data = nil,
            window = "main",
        }

        self.windowSize = guiInfo.app
        self.windowSize.size = "small"
        self.blockResize = true

    else
        local data, icon = self:getDataToApp(dataApp.type, dataApp)
        self.focusedAppData = {
            data = data,
            icon = icon,
        }

        self.blockResize = nil
    end

    self:createPreview(dataApp.type, self.infoIndex)
end

function Computer:addObject(text, editText, textInEdit, textButtonAccept)
    self.addObjectTitle = text

    if not self.edits then self.edits = {} end
    if self.edits.edit then exports.TR_dx:destroyEdit(self.edits.edit) end

    self.edits.edit = exports.TR_dx:createEdit(guiInfo.addObject.x + 10/zoom, guiInfo.addObject.y + 50/zoom, guiInfo.addObject.w - 20/zoom, 40/zoom, editText)
    self.acceptButtonText = textButtonAccept and textButtonAccept or "Dodaj"

    if textInEdit then exports.TR_dx:setEditText(self.edits.edit, textInEdit) end
end

function Computer:getDataToApp(app, dataApp)
    local appData = self.leaderData[app] and self.leaderData[app] or {}

    if dataApp then
        if dataApp.type == "folder_ranks" then
            table.sort(self.leaderData.folder_ranks, function(a, b) return a.level < b.level end)

        elseif dataApp.type == "folder_vehicle" and self.computerType == "organization" then
            table.sort(appData, function(a, b) return (b.requestOrg and b.requestOrg or 0) > (a.requestOrg and a.requestOrg or 0) end)

        elseif dataApp.type == "info" then
            appData.rentCost = 2000
        else
            table.sort(appData, function(a, b) return a.name < b.name end)
        end
    end

    return appData, split(app, "_") and split(app, "_")[2] and split(app, "_")[2].."_info" or app
end

function Computer:getInfoToApp(app)
    local data = {}
    local element = ""

    if app == "person_info" then
        local leaderData = self.leaderData["folder_person"][math.min(self.infoIndex or 1, #self.leaderData["folder_person"])]
        local player = getPlayerFromName(leaderData.name)
        local _, _, rank = self:getPlayerRank(leaderData.name)

       table.insert(data, {name = "Özel Bilgiler", value = {}})
		table.insert(data[#data].value, {name = "Kullanıcı Adı", value = leaderData.name})
		table.insert(data[#data].value, {name = "Durum", value = player and "Çevrimiçi" or "Çevrimdışı"})
		table.insert(data[#data].value, {name = "Konum", value = player and getZoneName(getElementPosition(player)) or "Bilgi Yok"})
		table.insert(data[#data].value, {name = "Hesap Oluşturuldu", value = leaderData.created})
		table.insert(data[#data].value, {name = "Son Çevrimiçi", value = leaderData.lastOnline})

		table.insert(data, {name = "İş Bilgileri", value = {}})
		table.insert(data[#data].value, {name = "Rütbe", value = rank})
		table.insert(data[#data].value, {name = "İşe Alındığı Tarih", value = leaderData.added})

		if self.computerType == "organization" then
			table.insert(data[#data].value, {name = "Organizasyona Yapılan Ödemeler", value = string.format("$%s", self:formatNumber(leaderData.allPaid))})
			table.insert(data[#data].value, {name = "Organizasyon İçin Kazanç", value = string.format("$%s", self:formatNumber(leaderData.allEarn))})
			table.insert(data[#data].value, {name = "Ödenmesi Gereken Tutar", value = string.format("$%s", self:formatNumber(leaderData.toPay))})
		elseif self.computerType == "fraction" then
			table.insert(data[#data].value, {name = "Haftalık Görev Süresi", value = leaderData.weekDutyTime})
			table.insert(data[#data].value, {name = "Bugünkü Görev Süresi", value = leaderData.todayDutyTime})
		end


        end
        element = leaderData.name

    elseif app == "vehicle_info" then
        local leaderData = self.leaderData["folder_vehicle"][math.min(self.infoIndex or 1, #self.leaderData["folder_vehicle"])]
        local vehicle = leaderData.vehicle
        local lastDriver = self:getVehicleLastDriver(vehicle)

		table.insert(data, {name = "Araç Bilgileri", value = {}})
		table.insert(data[#data].value, {name = "Model", value = leaderData.model})
		table.insert(data[#data].value, {name = "Ad", value = leaderData.name})
		table.insert(data[#data].value, {name = "Konum", value = vehicle and getZoneName(getElementPosition(vehicle)) or "Yok"})
		table.insert(data[#data].value, {name = "Son Sürücü", value = lastDriver})

        if self.computerType == "fraction" then
            table.insert(data[#data].value, {name = "Operasyonel numara", value = vehicle and getElementData(vehicle, "operationalNumber") or "Brak"})
        end
        element = leaderData.name

    elseif app == "ranks_info" then
        local leaderData = self.leaderData["folder_ranks"][math.min(self.infoIndex or 1, #self.leaderData["folder_ranks"])]
        self.openedRank = leaderData

        table.insert(data, {name = "Rütbe Bilgileri", value = {}})
		table.insert(data[#data].value, {name = "İsim", value = leaderData.name})

        local permissions = self:getRankPermissions()
        if #permissions > 0 then
            table.insert(data, {name = "İzinler", value = {}})

            local isLast = self.infoIndex == #self.leaderData["folder_ranks"] and true or false
            self.checks = {}
            local y = 200/zoom

            local _, _, _, canManage = self:getPlayerRank()
            for i, v in pairs(permissions) do
                if canManage and not isLast then
                    local check = exports.TR_dx:createCheck(self.windowSize.x + 355/zoom, self.windowSize.y + y, 25/zoom, 25/zoom, leaderData[v.value], "")
                    self.checks[v.value] = check
                    table.insert(data[#data].value, {name = v.name, value = ""})
                else
                    table.insert(data[#data].value, {name = v.name, value = leaderData[v.value] and "Evet" or "Hayır"})

                end

                y = y + 30/zoom
            end
        end
        element = leaderData.name
    end

    return data, element
end

function Computer:selectCheckbox(checkBox)
    for i, v in pairs(self.checks) do
        if v == checkBox then
            local state = exports.TR_dx:isCheckSelected(checkBox)
            self:changePermission(i, state)
            break
        end
    end
end

function Computer:changePermission(permission, state)
    self:updateRankPermission(self.openedRank.ID, permission, state)

    self:showInfo(string.format("%s rütbesinin izinleri değiştirildi.", self.openedRank.name), "success")
    table.insert(self.notifications, 1, {name = getPlayerName(localPlayer), text = string.format("Sıralama izinleri değiştirildi %s.",  self.openedRank.name)})

    triggerServerEvent("setComputerRankPermission", resourceRoot, self.computerType == "fraction" and true or false, self.fractionID, self.openedRank.ID, self.openedRank.name, permission, state)
end

function Computer:updateRankPermission(id, permission, state)
    for i, v in pairs(self.leaderData["folder_ranks"]) do
        if v.ID == id then
            self.leaderData["folder_ranks"][i][permission] = state
            break
        end
    end
end

function Computer:getVehicleLastDriver(vehicle)
    if not vehicle then return "Brak" end
    local driver = getElementData(vehicle, "lastDriver")
    if not driver then return "Brak" end

    local _, _, rankName = self:getPlayerRank(driver)
    if rankName then
        return string.format("%s (%s)", driver, rankName)
    end
    return driver
end

function Computer:openApp(i, infoIndex)
    local appData = guiInfo.apps[i]
    local addBar = true
    for i, v in pairs(self.windowsBar) do
        if v == appData.type then
            addBar = false
            break
        end
    end
    if addBar then table.insert(self.windowsBar, appData.type) end

    self.infoIndex = infoIndex

    self:focusApp(i)
end

function Computer:createPreview(app)
    local preview = exports.TR_dashboard:canSeePreview()

    if preview then
        if self.preview then exports.TR_preview:destroyObjectPreview(self.preview) end
        if isElement(self.previewElement) then destroyElement(self.previewElement) end
    end

    if not self.infoIndex then return end
    if app == "person_info" then
        if preview then
            self.previewElement = createPed(self.leaderData["folder_person"][self.infoIndex].skin, 0, 0, 0)
            setElementInterior(self.previewElement, getElementInterior(localPlayer))
            setElementDimension(self.previewElement, getElementDimension(localPlayer))

            self.preview = exports.TR_preview:createObjectPreview(self.previewElement, -10, 0, 180, self.windowSize.x - (self.windowSize.h - 80/zoom)/2 + 180/zoom, self.windowSize.y + 40/zoom, self.windowSize.h - 80/zoom, self.windowSize.h - 80/zoom, false, true)
        end
        self.previewX = self.windowSize.x + 400/zoom

    elseif app == "vehicle_info" then
        if preview then
            self.previewElement = createVehicle(self.leaderData["folder_vehicle"][self.infoIndex].model, 0, 0, 0)
            setVehicleColor(self.previewElement, unpack(self.leaderData["folder_vehicle"][self.infoIndex].color))
            if self.leaderData["folder_vehicle"][self.infoIndex].paintjob then setVehiclePaintjob(self.previewElement, self.leaderData["folder_vehicle"][self.infoIndex].paintjob) end
            if self.leaderData["folder_vehicle"][self.infoIndex].tuning then
                for i, v in pairs(self.leaderData["folder_vehicle"][self.infoIndex].tuning) do
                    addVehicleUpgrade(self.previewElement, v)
                end
            end

            setElementInterior(self.previewElement, getElementInterior(localPlayer))
            setElementDimension(self.previewElement, getElementDimension(localPlayer))

            self.preview = exports.TR_preview:createObjectPreview(self.previewElement, 0, 0, 220, self.windowSize.x - (self.windowSize.h - 80/zoom)/2 + 180/zoom, self.windowSize.y + 40/zoom, self.windowSize.h - 80/zoom, self.windowSize.h - 80/zoom, false, true)
        end
        self.previewX = self.windowSize.x + 500/zoom

    elseif app == "ranks_info" then
        self.previewX = self.windowSize.x + 360/zoom
    end
end

function Computer:getBarIndex()
    if self.iconBar then return self.iconBar + 1 end

    if self.focusedApp then
        for i, v in pairs(self.windowsBar) do
            if v == guiInfo.apps[self.focusedApp].type then
                return i
            end
        end
    end

    return false
end

function Computer:closeApp()
    if self.checks then
        exports.TR_dx:destroyCheck(self.checks)
        self.checks = nil
    end

    local barIconIndex = self:getBarIndex()
    if not barIconIndex then return end

    if barIconIndex == 1 then
        self:close()
        return
    end
    local app = self.windowsBar[barIconIndex]
    for i, v in pairs(self.windowsBar) do
        if v == app then
            table.remove(self.windowsBar, i)
            break
        end
    end

    for i, v in pairs(guiInfo.apps) do
        if v.type == app and i == self.focusedApp then
            self.focusedApp = nil
            self.windowSize = nil

            if self.preview then exports.TR_preview:destroyObjectPreview(self.preview) end
            if isElement(self.previewElement) then destroyElement(self.previewElement) end
            break
        end
    end

    self.iconBar = nil
end

function Computer:calculateTextHeight(text, font, fontSize, rectangeWidth)
	local line_text = ""
	local line_count = 1

	for word in text:gmatch("%S+") do
		local temp_line_text = line_text .. " " .. word

		local temp_line_width = dxGetTextWidth(temp_line_text, fontSize, font)
		if temp_line_width >= rectangeWidth then
			line_text = word
			line_count = line_count + 1
		else
			line_text = temp_line_text
		end
	end

	return line_count * self.notiTextHeight
end

function Computer:response(status, info, type)
    if not status then
        self:showInfo(info, type)

    elseif self.responseInfo and status then
        if self.responseInfo.type == "addPlayer" then
            self:showInfo(string.format("Çalışan %s başarıyla işe alındı.", self.responseInfo.player), "success")
            table.insert(self.notifications, 1, {name = getPlayerName(localPlayer), text = string.format("%s oyuncusunu işe aldı.",  self.responseInfo.player)})

            table.insert(self.leaderData.folder_person, {
                UID = info.UID,
                name = info.username,
                rankID = info.rankID,
                skin = tonumber(info.skin),
                added = self:formatDate(info.added),
                created = self:formatDate(info.created),
                lastOnline = self:formatDate(info.lastOnline),

                weekDutyTime = 0,
                todayDutyTime = 0,
            })

            if self.edits then exports.TR_dx:destroyEdit(self.edits.edit) end
            if self.checks then exports.TR_dx:destroyCheck(self.checks); self.checks = nil end
            self.checks = nil
            self.edits = nil
            self.addObjectTitle = nil

            self:focusApp(self.focusedApp, true)

        elseif self.responseInfo.type == "remove" then
            self:showInfo(string.format("Çalışan %s başarıyla kovuldu.", self.responseInfo.player), "success")

            table.insert(self.notifications, 1, {name = getPlayerName(localPlayer), text = string.format("Oyuncuyu kovdu: %s.",  self.responseInfo.player)})
            table.remove(self.leaderData[guiInfo.apps[self.focusedApp].type], self.acceptWindowIndex)
            self.acceptWindowIndex = nil

        elseif self.responseInfo.type == "changeRank" then
            self.leaderData["folder_person"][self.responseInfo.objectIndex].rankID = self.responseInfo.rankID

            table.insert(self.notifications, 1, {name = getPlayerName(localPlayer), text = string.format("Oyuncunun rütbesi değiştirildi: %s, Yeni rütbe: %s.", self.responseInfo.player, self.responseInfo.rankName)})
            self:showInfo(string.format("Çalışanın rütbesi başarıyla değiştirildi: %s.", self.responseInfo.player), "success")

        elseif self.responseInfo.type == "rename" then
            self.leaderData["folder_ranks"][self.responseInfo.changeRankIndex].name = self.responseInfo.text

            table.insert(self.notifications, 1, {name = getPlayerName(localPlayer), text = string.format("Rütbenin adı değiştirildi: %s, Yeni ad: %s.", self.responseInfo.lastRankName, self.responseInfo.text)})
            self:showInfo("Rütbe adı değiştirildi.", "success")

            if self.edits then exports.TR_dx:destroyEdit(self.edits.edit) end
            if self.checks then exports.TR_dx:destroyCheck(self.checks); self.checks = nil end
            self.checks = nil
            self.edits = nil
            self.addObjectTitle = nil

        elseif self.responseInfo.type == "changeLogo" then
            self:showInfo("Organizasyon logosu değişikliği kabul edildi. Yeni logo yönetici tarafından onaylanmayı bekliyor.", "success")

            if self.edits then exports.TR_dx:destroyEdit(self.edits.edit) end
            if self.checks then exports.TR_dx:destroyCheck(self.checks); self.checks = nil end
            self.checks = nil
            self.edits = nil
            self.addObjectTitle = nil

        elseif self.responseInfo.type == "rankRemove" then
            local oldRankID = self.leaderData[guiInfo.apps[self.focusedApp].type][self.acceptWindowIndex].ID
            local defaultRankID = self.leaderData[guiInfo.apps[self.focusedApp].type][1].ID

            for i, v in pairs(self.leaderData.folder_person) do
                if v.rankID == oldRankID then
                    v.rankID = defaultRankID
                end
            end

            self:loadData(info)
            self:focusApp(self.focusedApp, true)

            table.insert(self.notifications, 1, {name = getPlayerName(localPlayer), text = string.format("Usunął rangę %s.", self.responseInfo.name)})
            self:showInfo("Sıralama kaldırıldı.", "success")
            self.acceptWindowIndex = nil

        elseif self.responseInfo.type == "addRank" then
            local oldRankID = self.responseInfo.lastRank.ID
            self:loadData(info)

            local newRankID = self.responseInfo.lastRank.ID
            for i, v in pairs(self.leaderData.folder_person) do
                if v.rankID == oldRankID then
                    v.rankID = newRankID
                end
            end

            if self.edits then exports.TR_dx:destroyEdit(self.edits.edit) end
            if self.checks then exports.TR_dx:destroyCheck(self.checks); self.checks = nil end
            self.checks = nil
            self.edits = nil
            self.addObjectTitle = nil

            self:focusApp(self.focusedApp, true)

            table.insert(self.notifications, 1, {name = getPlayerName(localPlayer), text = string.format("%s adlı rütbe eklendi.", self.responseInfo.text)})
            self:showInfo("Rütbe eklendi.", "success")

        elseif self.responseInfo.type == "declineVehicle" then
            table.remove(self.leaderData[guiInfo.apps[self.focusedApp].type], self.responseInfo.selected)
            table.insert(self.notifications, 1, {name = getPlayerName(localPlayer), text = string.format("%s adlı aracın kabul önerisini reddetti.", self.responseInfo.text)})
            self:showInfo("Araç reddedildi.", "success")

        elseif self.responseInfo.type == "removeVehicle" then
            table.remove(self.leaderData[guiInfo.apps[self.focusedApp].type], self.responseInfo.selected)
            table.insert(self.notifications, 1, {name = getPlayerName(localPlayer), text = string.format("%s adlı aracı organizasyondan çıkardı.", self.responseInfo.text)})
            self:showInfo("Araç çıkarıldı.", "success")

        elseif self.responseInfo.type == "addVehicle" then
            self.leaderData[guiInfo.apps[self.focusedApp].type][self.responseInfo.selected].requestOrg = false
            self.leaderData[guiInfo.apps[self.focusedApp].type][self.responseInfo.selected].textColor = false
            self.leaderData[guiInfo.apps[self.focusedApp].type][self.responseInfo.selected].ownedOrg = self.fractionID

            table.insert(self.notifications, 1, {name = getPlayerName(localPlayer), text = string.format("%s adlı aracı organizasyona atadı.", self.responseInfo.text)})
            self:showInfo("Araç atandı.", "success")

        elseif self.responseInfo.type == "givePayment" then
            table.insert(self.notifications, 1, {name = getPlayerName(localPlayer), text = "Çalışanlara ödeme yaptı."})
            self:showInfo("Ödemeler başarıyla yapıldı.", "success")


            for i, v in pairs(self.leaderData.folder_person) do
                v.toPay = 0
            end

        elseif self.responseInfo.type == "buyUpgrade" then
            table.insert(self.notifications, 1, {name = getPlayerName(localPlayer), text = self.responseInfo.text})
            self.leaderData.info.money = tonumber(self.leaderData.info.money) - self.responseInfo.price
            self.leaderData.info[self.responseInfo.index] = self.leaderData.info[self.responseInfo.index] + 1
            self:showInfo("Yükseltme başarıyla satın alındı.", "success")

        elseif self.responseInfo.type == "giveMoneyToOrg" then
            local uid = getElementData(localPlayer, "characterUID")

            for i, v in pairs(self.leaderData.folder_person) do
                if v.UID == uid then
                    v.allPaid = v.allPaid + self.responseInfo.amount
                    break
                end
            end

            local time = getRealTime()
            for i, v in pairs(self.earnData) do
                local date = split(v.day, ".")
                if tonumber(date[1]) == time.monthday and tonumber(date[2]) == (time.month + 1) then
                    v.totalEarn = v.totalEarn + self.responseInfo.amount
                    break
                end
            end

            self.earnDiagram = {
                maxEarn = 0,
                minEarn = 99999999999,
                totalEarn = 0,
            }
            for i, v in pairs(self.earnData) do
                self.earnDiagram.totalEarn = self.earnDiagram.totalEarn + tonumber(v.totalEarn)

                if self.earnDiagram.maxEarn < tonumber(v.totalEarn) then
                    self.earnDiagram.maxEarn = tonumber(v.totalEarn)

                elseif self.earnDiagram.minEarn > tonumber(v.totalEarn) then
                    self.earnDiagram.minEarn = tonumber(v.totalEarn)
                end
            end

            self.leaderData.info.money = tonumber(self.leaderData.info.money) + self.responseInfo.amount
            table.insert(self.notifications, 1, {name = getPlayerName(localPlayer), text = string.format("Kuruluşa %.2f $ bağışladı.", self.responseInfo.amount)})

            self.addObjectTitle = nil
            if self.edits then exports.TR_dx:destroyEdit(self.edits.edit) end
            if self.checks then exports.TR_dx:destroyCheck(self.checks); self.checks = nil end
            self.edits = nil
            self.checks = nil

        elseif self.responseInfo.type == "additionalPaymentPlayer" then
            table.insert(self.notifications, 1, {name = getPlayerName(localPlayer), text = string.format("%s oyuncusuna şu miktarda ek tazminat ödendi: $%.2f.", self.responseInfo.player, self.responseInfo.amount)})
            self.leaderData.info.money = tonumber(self.leaderData.info.money) - self.responseInfo.amount

            self.addObjectTitle = nil
            if self.edits then exports.TR_dx:destroyEdit(self.edits.edit) end
            if self.checks then exports.TR_dx:destroyCheck(self.checks); self.checks = nil end
            self.edits = nil
            self.checks = nil
        end
    end

    self.responseInfo = nil
    exports.TR_dx:setResponseEnabled(false)
end

function Computer:responseData(type, data)
    if type == "folder_person" then
        self.leaderData["folder_person"] = {}

        for i, v in pairs(data) do
            table.insert(self.leaderData["folder_person"], {
                player = v.username,
                rankID = v.rankID,
            })
        end

    elseif type == "info" then
        self.leaderData.info.rent = self:formatDate(data)
        self.organizationInterior = self.responseInfo.ID
        self.leaderData["info"].money = tonumber(self.leaderData["info"].money) - self.responseInfo.price

        table.insert(self.notifications, 1, {name = getPlayerName(localPlayer), text = string.format("Örgütün merkezini Şehire taşıdı %s.", self.responseInfo.text)})
        self:showInfo(string.format("Merkez, %s şehrine taşındı.", self.responseInfo.text), "success")

    elseif type == "info_rent" then
        self.leaderData.info.rent = self:formatDate(data)
        self.leaderData["info"].money = tonumber(self.leaderData["info"].money) - self.focusedAppData.data.rentCost

        table.insert(self.notifications, 1, {name = getPlayerName(localPlayer), text = "7 gün boyunca organizasyonun parasını ödedi."})
        self:showInfo("Organizasyon için 7 günlük kira ödendi.", "success")

    elseif type == "darkweb" then
        self.focusedAppData.data = data
    end

    self.responseInfo = nil
    exports.TR_dx:setResponseEnabled(false)
end

function Computer:formatDate(date, withTime)
    local f = split(date, " ")
    local d = split(f[1], "-")
    local t = split(f[1], ":")
    if withTime then return string.format("%s %02d.%02d.%02dr.", f[2], d[3], d[2], d[1]) end
    return string.format("%02d.%02d.%02dr.", d[3], d[2], d[1])
end

function Computer:getRankPermissions()
    if self.fractionType == "police" then
        return {
            {
                name = "Yönetmek",
                value = "canManage",
            },
            {
                name = "Akademi araçları",
                value = "veh1",
            },
            {
                name = "İşaretli araçlar",
                value = "veh2",
            },
            {
                name = "İşaretsiz araçlar",
                value = "veh3",
            },
            {
                name = "Özel araçlar",
                value = "veh4",
            },
        }

    elseif self.fractionType == "ers" then
        return {
            {
                name = "Yönet",
                value = "canManage",
            },
            {
                name = "Çekici kamyonlar",
                value = "veh1",
            },
            {
                name = "Devriye araçları",
                value = "veh2",
            },
            {
                name = "Özel araçlar",
                value = "veh4",
            },
        }

    elseif self.fractionType == "fire" then
        return {
            {
                name = "Yönet",
                value = "canManage",
            },
            {
                name = "Su araçları",
                value = "veh1",
            },
            {
                name = "Devriye araçları",
                value = "veh2",
            },
            {
                name = "Özel araçlar",
                value = "veh3",
            },
        }

    elseif self.fractionType == "medic" then
        return {
            {
                name = "Yönet",
                value = "canManage",
            },
            {
                name = "Acil durum araçları",
                value = "veh1",
            },
            {
                name = "Devriye araçları",
                value = "veh2",
            },
            {
                name = "Özel araçlar",
                value = "veh3",
            },
        }

    elseif self.fractionType == "news" then
        return {
            {
                name = "Yönet",
                value = "canManage",
            },
            {
                name = "Haber aracı",
                value = "veh1",
            },
            {
                name = "Şirket araçları",
                value = "veh2",
            },
            {
                name = "Arazi araçları",
                value = "veh3",
            },
            {
                name = "Helikopter",
                value = "veh4",
            },
        }

    elseif self.computerType == "organization" then
        return {
            {
                name = "Yönet",
                value = "canManage",
            },
        }
    end
    return {}
end

function Computer:getComputerApps()
    if self.computerType == "fraction" then
        guiInfo.objectOption = {
            ["folder_person"] = {
                {
                    title = "Yavaş",
                    icon = "close",
                    type = "remove",
                },
                {
                    title = "Sıralamayı değiştir",
                    icon = "rank",
                    type = "rank",
                },
            },
            ["folder_person_blank"] = {
                {
                    title = "Bir çalışan ekleyin",
                    icon = "add",
                    type = "add",
                },
            },
            ["folder_ranks"] = {
                {
                    title = "Yeniden isimlendirmek",
                    icon = "edit",
                    type = "rename",
                },
                {
                    title = "Sıralamayı kaldır",
                    icon = "close",
                    type = "remove",
                },
            },
            ["folder_ranks_blank"] = {
                {
                    title = "Sıralama ekle",
                    icon = "add",
                    type = "add",
                },
            },
        }

        guiInfo.appOptions = {
            {
                icon = "close",
                type = "close",
                hint = "Kapat",
            },
            {
                icon = "resize",
                type = "resize",
            },
            {
                icon = "minimalize",
                type = "minimalize",
                hint = "Sakla",
            },
        }

        guiInfo.apps = {
            {
                title = "Çöp Kutusu",
                type = "bin",
                onScreen = true,
            },
            {
                title = "işçi listesi",
                type = "folder_person",
                onScreen = true,
            },
            {
                title = "Lista pojazdów",
                type = "folder_vehicle",
                onScreen = true,
            },
            {
                title = "Lista rang",
                type = "folder_ranks",
                onScreen = true,
            },
            {
                title = "Tor",
                type = "darkweb",
                onScreen = true,
            },

            {
                title = "Informacje o pracowniku",
                type = "person_info",
                onScreen = false,
            },
            {
                title = "Informacje o pojeździe",
                type = "vehicle_info",
                onScreen = false,
            },
            {
                title = "Informacje o randze",
                type = "ranks_info",
                onScreen = false,
            },
        }

    elseif self.computerType == "organization" and self.fractionType == "org" then
        guiInfo.objectOption = {
            ["folder_person"] = {
                {
                    title = "İşten Çıkar",
                    icon = "close",
                    type = "remove",
                },
                {
                    title = "Rütbe Değiştir",
                    icon = "rank",
                    type = "rank",
                },
            },
            ["folder_person_blank"] = {
                {
                    title = "Çalışan Ekle",
                    icon = "add",
                    type = "add",
                },
                {
                    title = "Maaşları Öde",
                    icon = "dollar",
                    type = "givePayment",
                },
            },
            ["folder_ranks"] = {
                {
                    title = "İsmi Değiştir",
                    icon = "edit",
                    type = "rename",
                },
                {
                    title = "Rütbe Sil",
                    icon = "close",
                    type = "remove",
                },
            },
            ["folder_ranks_blank"] = {
                {
                    title = "Rütbe Ekle",
                    icon = "add",
                    type = "add",
                },
            },
            ["folder_vehicle"] = {
                {
                    title = "Araç Ekle",
                    icon = "add",
                    type = "add",
                },
                {
                    title = "Araç Sil",
                    icon = "close",
                    type = "remove",
                },
            },
        }

        guiInfo.appOptions = {
            {
                icon = "close",
                type = "close",
                hint = "Kapat",
            },
            {
                icon = "resize",
                type = "resize",
            },
            {
                icon = "minimalize",
                type = "minimalize",
                hint = "Gizle",
            },
        }

    elseif self.computerType == "organization" and self.fractionType == "crime" then
        guiInfo.objectOption = {
            ["folder_person"] = {
                {
                    title = "İşten Çıkar",
                    icon = "close",
                    type = "remove",
                },
                {
                    title = "Rütbe Değiştir",
                    icon = "rank",
                    type = "rank",
                },
            },
            ["folder_person_blank"] = {
                {
                    title = "Çalışan Ekle",
                    icon = "add",
                    type = "add",
                },
                {
                    title = "Maaş Öde",
                    icon = "dollar",
                    type = "givePayment",
                },
            },
            ["folder_ranks"] = {
                {
                    title = "İsmi Değiştir",
                    icon = "edit",
                    type = "rename",
                },
                {
                    title = "Rütbe Sil",
                    icon = "close",
                    type = "remove",
                },
            },
            ["folder_ranks_blank"] = {
                {
                    title = "Rütbe Ekle",
                    icon = "add",
                    type = "add",
                },
            },
            ["folder_vehicle"] = {
                {
                    title = "Araç Ekle",
                    icon = "add",
                    type = "add",
                },
                {
                    title = "Araç Sil",
                    icon = "close",
                    type = "remove",
                },
            },
        }

        guiInfo.appOptions = {
            {
                icon = "close",
                type = "close",
                hint = "Kapat",
            },
            {
                icon = "resize",
                type = "resize",
            },
            {
                icon = "minimalize",
                type = "minimalize",
                hint = "Gizle",
            },
        }

        guiInfo.apps = {
            {
                title = "Çöp Kutusu",
                type = "bin",
                onScreen = true,
            },
            {
                title = "Bilgiler",
                type = "info",
                onScreen = true,
            },
            {
                title = "Kazançlar",
                type = "earnings",
                onScreen = true,
            },
            {
                title = "Personel Listesi",
                type = "folder_person",
                onScreen = true,
            },
            {
                title = "Araç Listesi",
                type = "folder_vehicle",
                onScreen = true,
            },
            {
                title = "Rütbe Listesi",
                type = "folder_ranks",
                onScreen = true,
            },
            {
                title = "Yükseltmeler",
                type = "upgrade",
                onScreen = true,
            },
            {
                title = "Karanlık Ağ",
                type = "darkweb",
                onScreen = true,
            },

            {
                title = "Personel Bilgileri",
                type = "person_info",
                onScreen = false,
            },
            {
                title = "Araç Bilgileri",
                type = "vehicle_info",
                onScreen = false,
            },
            {
                title = "Rütbe Bilgileri",
                type = "ranks_info",
                onScreen = false,
            },
        }

    else
        guiInfo.objectOption = {
            ["folder_person"] = {
                {
                    title = "İşten Çıkar",
                    icon = "close",
                    type = "remove",
                },
                {
                    title = "Rütbe Değiştir",
                    icon = "rank",
                    type = "rank",
                },
            },
            ["folder_person_blank"] = {
                {
                    title = "Çalışan Ekle",
                    icon = "add",
                    type = "add",
                },
            },
            ["folder_ranks"] = {
                {
                    title = "İsmi Değiştir",
                    icon = "edit",
                    type = "rename",
                },
                {
                    title = "Rütbe Sil",
                    icon = "close",
                    type = "remove",
                },
            },
            ["folder_ranks_blank"] = {
                {
                    title = "Rütbe Ekle",
                    icon = "add",
                    type = "add",
                },
            },
            ["folder_vehicle"] = {
                {
                    title = "Araç Ekle",
                    icon = "add",
                    type = "add",
                },
                {
                    title = "Araç Sil",
                    icon = "close",
                    type = "remove",
                },
            },
        }

        guiInfo.appOptions = {
            {
                icon = "close",
                type = "close",
                hint = "Kapat",
            },
            {
                icon = "resize",
                type = "resize",
            },
            {
                icon = "minimalize",
                type = "minimalize",
                hint = "Gizle",
            },
        }

        guiInfo.apps = {
            {
                title = "Çöp Kutusu",
                type = "bin",
                onScreen = true,
            },
            {
                title = "Çalışan Listesi",
                type = "folder_person",
                onScreen = true,
            },
            {
                title = "Araç Listesi",
                type = "folder_vehicle",
                onScreen = true,
            },
            {
                title = "Rütbe Listesi",
                type = "folder_ranks",
                onScreen = true,
            },
            {
                title = "Karanlık Ağ",
                type = "darkweb",
                onScreen = true,
            },

            {
                title = "Çalışan Bilgileri",
                type = "person_info",
                onScreen = false,
            },
            {
                title = "Araç Bilgileri",
                type = "vehicle_info",
                onScreen = false,
            },
            {
                title = "Rütbe Bilgileri",
                type = "ranks_info",
                onScreen = false,
            },
        }
    end

    for i, v in pairs(guiInfo.apps) do
        guiInfo.apps[i].state = "unclicked"
    end
end

function Computer:loadOrganizationLogo(orgID)
    local orgImg = exports.TR_orgLogos:getLogo(orgID)
    if not orgImg then return end
    self.textures.orgLogo = dxCreateTexture(orgImg, "argb", true, "clamp")
end

function Computer:formatNumber(n)
    local n = string.format("%.2f", tonumber(n))
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1 '):reverse())..right
end

function Computer:minutesToTime(minutes)
	local minutes = tonumber(minutes)

    if minutes <= 0 then
      return "0h 0min";
    else
      hours = string.format("%02.f", math.floor(minutes/60));
      mins = string.format("%02.f", math.floor(minutes - (hours*60)));
      return hours.."h "..mins.."min"
    end
end


function Computer:drawBackground(x, y, rx, ry, color, radius, post)
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

function Computer:drawIconHover(x, y, w, h, color)
    dxDrawRectangle(x, y, w, h, color, post)
    dxDrawRectangle(x, y, 2, h, color, post)
    dxDrawRectangle(x + 2, y, w - 4, 2, color, post)
    dxDrawRectangle(x + w - 2, y, 2, h, color, post)
    dxDrawRectangle(x + 2, y + h - 2, w - 4, 2, color, post)
end

function Computer:isMouseInPosition(x, y, width, height, noAffectCursor)
	if (not isCursorShowing()) then
		return false
	end
    local cx, cy = getCursorPosition()
    local cx, cy = (cx*sx), (cy*sy)
    if (cx >= x and cx <= x + width) and (cy >= y and cy <= y + height) then
        if not noAffectCursor then self.cursorImg = "pointer" end
        return true
    else
        return false
    end
end

function createComputer(...)
    if guiInfo.panel then return end
    guiInfo.panel = Computer:create(arg[1], arg[2], arg[3])

    for i = 1, 3 do table.remove(arg, 1) end
    guiInfo.panel:loadData(unpack(arg))

    exports.TR_dx:setResponseEnabled(false)
end
addEvent("createComputer", true)
addEventHandler("createComputer", root, createComputer)

function responseComputer(...)
    if not guiInfo.panel then return end
    guiInfo.panel:response(...)
end
addEvent("responseComputer", true)
addEventHandler("responseComputer", root, responseComputer)

function responseComputerData(...)
    if not guiInfo.panel then return end
    guiInfo.panel:responseData(...)
end
addEvent("responseComputerData", true)
addEventHandler("responseComputerData", root, responseComputerData)


function cantOpenComputer(...)
    exports.TR_dx:setOpenGUI(false)
    exports.TR_dx:setResponseEnabled(false)

    exports.TR_noti:create("Bu bilgisayarı kullanamazsınız.", "error")
end
addEvent("cantOpenComputer", true)
addEventHandler("cantOpenComputer", root, cantOpenComputer)


function openComputer()
    local _, jobType = exports.TR_jobs:getPlayerJob()

    if jobType == "police" or jobType == "fire" or jobType == "medic" or jobType == "fractionc" or jobType == "news" or jobType == "ers" then
        triggerServerEvent("getComputerData", resourceRoot, "fraction")

    else
        exports.TR_dx:setOpenGUI(false)
        exports.TR_dx:setResponseEnabled(false)
        exports.TR_noti:create("Bu bilgisayarı kullanamazsınız.", "error")
    end
end

function canUseComputer()
    local _, jobType = exports.TR_jobs:getPlayerJob()
    local orgID = getElementData(localPlayer, "characterOrgID")
    if jobType == "police" or jobType == "fire" or jobType == "medic" or jobType == "fractionc" or jobType == "news" or jobType == "ers" or orgID then
        return true
    end
    return false
end

function openOrgComputerByKey()
    if not exports.TR_dx:canOpenGUI() then return end
    if exports.TR_dx:isResponseEnabled() then return end

    local orgID = getElementData(localPlayer, "characterOrgID")
    if not orgID then exports.TR_noti:create("Hiçbir organizasyona üye değilsiniz.", "error") return end

    exports.TR_dx:setResponseEnabled(true, "Bilgisayar açılıyor, lütfen bekleyin")
    triggerServerEvent("getComputerData", resourceRoot, "organization", orgID)
end
bindKey("F3", "down", openOrgComputerByKey)



exports.TR_dx:setOpenGUI(false)
exports.TR_dx:setResponseEnabled(false)


-- if getPlayerName(localPlayer) == "Xantris" then
--     openOrgComputerByKey()
-- end

-- if getPlayerName(localPlayer) == 'Xantris' then
--     openComputer()
--     triggerServerEvent("getComputerData", resourceRoot, "organization", 1)
-- end

-- createObject(2190, 1588.6953125, -1625.1336669922, 13.382812)
-- setCursorAlpha(255)
-- if getElementData(localPlayer, "characterUID") then
--     -- triggerServerEvent("getComputerData", resourceRoot, "fraction")

--     --createComputer("Los Santos Police Department", "police", true)
--     -- createComputer("Los Santos Police Department", "police")


    -- triggerServerEvent("getComputerData", resourceRoot, "organization", 1)
-- end
-- setCursorAlpha(255)




-- Diagram
local dataTable = {}
local zOld = 0

function dxCreateDiagram(N,x,y,cleanSize,color,size,gui)
    local _,h = guiGetScreenSize()
    local x = x or 0
    local y = y or h/2
    local N = N or 0
    local cleanSize = cleanSize or h/2
    local color = color or tocolor(255, 255, 255, 255)
    local size = size or 1
    local gui = gui or false
    local izmen = (N-zOld)

    table.insert( dataTable, izmen)

    for i, z in pairs(dataTable) do
        local x3 = dataTable[i+1] or 1
        local x2 = dataTable[i] or 1
        if i >= cleanSize then
            for f,_ in pairs(dataTable) do
                table.remove(dataTable, f)
            end
        end
        dxDrawLine(x+(i-1), y+1-x2, x+i, y+1-x3, color,size,gui)
    end
end



local domains = [[.ac.ad.ae.aero.af.ag.ai.al.am.an.ao.aq.ar.arpa.as.asia.at.au
   .aw.ax.az.ba.bb.bd.be.bf.bg.bh.bi.biz.bj.bm.bn.bo.br.bs.bt.bv.bw.by.bz.ca
   .cat.cc.cd.cf.cg.ch.ci.ck.cl.cm.cn.co.com.coop.cr.cs.cu.cv.cx.cy.cz.dd.de
   .dj.dk.dm.do.dz.ec.edu.ee.eg.eh.er.es.et.eu.fi.firm.fj.fk.fm.fo.fr.fx.ga
   .gb.gd.ge.gf.gh.gi.gl.gm.gn.gov.gp.gq.gr.gs.gt.gu.gw.gy.hk.hm.hn.hr.ht.hu
   .id.ie.il.im.in.info.int.io.iq.ir.is.it.je.jm.jo.jobs.jp.ke.kg.kh.ki.km.kn
   .kp.kr.kw.ky.kz.la.lb.lc.li.lk.lr.ls.lt.lu.lv.ly.ma.mc.md.me.mg.mh.mil.mk
   .ml.mm.mn.mo.mobi.mp.mq.mr.ms.mt.mu.museum.mv.mw.mx.my.mz.na.name.nato.nc
   .ne.net.nf.ng.ni.nl.no.nom.np.nr.nt.nu.nz.om.org.pa.pe.pf.pg.ph.pk.pl.pm
   .pn.post.pr.pro.ps.pt.pw.py.qa.re.ro.ru.rw.sa.sb.sc.sd.se.sg.sh.si.sj.sk
   .sl.sm.sn.so.sr.ss.st.store.su.sv.sy.sz.tc.td.tel.tf.tg.th.tj.tk.tl.tm.tn
   .to.tp.tr.travel.tt.tv.tw.tz.ua.ug.uk.um.us.uy.va.vc.ve.vg.vi.vn.vu.web.wf
   .ws.xxx.ye.yt.yu.za.zm.zr.zw]]
local tlds = {}
for tld in domains:gmatch'%w+' do
   tlds[tld] = true
end

function max4(a,b,c,d)
    return math.max(a+0, b+0, c+0, d+0)
end

local protocols = {[''] = 0, ['http://'] = 0, ['https://'] = 0, ['ftp://'] = 0}
local finished = {}

function isLink(url)
    for pos_start, url, prot, subd, tld, colon, port, slash, path in url:gmatch'()(([%w_.~!*:@&+$/?%%#-]-)(%w[-.%w]*%.)(%w+)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%%#=-]*))' do
        if protocols[prot:lower()] == (1 - #slash) * #path and not subd:find'%W%W' and (colon == '' or port ~= '' and port + 0 < 65536) and (tlds[tld:lower()] or tld:find'^%d+$' and subd:find'^%d+%.%d+%.%d+%.$' and max4(tld, subd:match'^(%d+)%.(%d+)%.(%d+)%.$') < 256) then
            finished[pos_start] = true
            return pos_start
        end
    end

    for pos_start, url, prot, dom, colon, port, slash, path in url:gmatch'()((%f[%w]%a+://)(%w[-.%w]*)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%%#=-]*))' do
        if not finished[pos_start] and not (dom..'.'):find'%W%W' and protocols[prot:lower()] == (1 - #slash) * #path and (colon == '' or port ~= '' and port + 0 < 65536) then
            return pos_start
        end
    end
    return 0
end
