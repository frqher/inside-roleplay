local sx, sy = guiGetScreenSize()
zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 600/zoom)/2,
    y = (sy - 360/zoom)/2,
    w = 700/zoom,
    h = 360/zoom,

    iconSize = 40/zoom,

    stand = {
        x = (sx - 550/zoom)/2,
        y = (sy - 350/zoom)/2 + 100/zoom,
        w = 550/zoom,
        h = 124/zoom,
    },

    tabs = {
        {
            name = "Bilgi",
            tab = "info",
        },
        {
            name = "Rütbe",
            tab = "rank",
        },
        {
            name = "Geliştirmeler",
            tab = "upgrade",
        },
        {
            name = "Maaş",
            tab = "payment",
        },
    },

    groupTabs = {
        {
            name = "Grup",
            tab = "group",
        },
        {
            name = "Chat",
            tab = "chat",
        },
    },

    blockTabSelect = {
        ["acceptUpgrade"] = true,
        ["selectRoom"] = true,
        ["getJobPrizes"] = true,
    },
}

Jobs = {}
Jobs.__index = Jobs

function Jobs:create(jobID, playerJobData, playerLicenceBlocked)
    local instance = {}
    setmetatable(instance, Jobs)
    if instance:constructor(jobID, playerJobData, playerLicenceBlocked) then
        return instance
    end
    return false
end

function Jobs:constructor(jobID, playerJobData, playerLicenceBlocked)
    local plrData = getElementData(localPlayer, "characterData")
    self.alpha = 0
    self.jobID = jobID
    self.canSwitchTab = true
    self.hasBlockedLicence = playerLicenceBlocked

    self.currentJob = getPlayerJob()
    self.licences = plrData.licence or {}
    self.bankCode = plrData.bankcode and true or false

    self.fonts = {}
    self.fonts.trophy = exports.TR_dx:getFont(20)
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.info = exports.TR_dx:getFont(13)
    self.fonts.parts = exports.TR_dx:getFont(12)
    self.fonts.desc = exports.TR_dx:getFont(11)
    self.fonts.tab = exports.TR_dx:getFont(10)

    self.textures = {}
    self.textures.rank = dxCreateTexture("files/images/rank.png", "argb", true, "clamp")
    self.textures.info = dxCreateTexture("files/images/info.png", "argb", true, "clamp")
    self.textures.upgrade = dxCreateTexture("files/images/upgrade.png", "argb", true, "clamp")
    self.textures.stand = dxCreateTexture("files/images/stand.png", "argb", true, "clamp")
    self.textures.payment = dxCreateTexture("files/images/payment.png", "argb", true, "clamp")
    self.textures.information = dxCreateTexture("files/images/information.png", "argb", true, "clamp")
    self.textures.trophy = dxCreateTexture("files/images/trophy.png", "argb", true, "clamp")

    self.textures.loading = dxCreateTexture("files/images/loading.png", "argb", true, "clamp")
    self.textures.group = dxCreateTexture("files/images/group.png", "argb", true, "clamp")
    self.textures.chat = dxCreateTexture("files/images/chat.png", "argb", true, "clamp")
    self.textures.person = dxCreateTexture("files/images/person.png", "argb", true, "clamp")
    self.textures.crown = dxCreateTexture("files/images/crown.png", "argb", true, "clamp")
    self.textures.remove = dxCreateTexture("files/images/remove.png", "argb", true, "clamp")

    self.textures.cash = dxCreateTexture("files/images/cash.png", "argb", true, "clamp")
    self.textures.card = dxCreateTexture("files/images/card.png", "argb", true, "clamp")

    self.buttons = {}
    self.buttons.close = exports.TR_dx:createButton(guiInfo.x + 10/zoom, guiInfo.y + guiInfo.h - 50/zoom, 254/zoom, 40/zoom, "Kapat")
    self.buttons.goBack = exports.TR_dx:createButton(guiInfo.x + 10/zoom, guiInfo.y + guiInfo.h - 50/zoom, 254/zoom, 40/zoom, "Geri")

    self.buttons.createRoom = exports.TR_dx:createButton(guiInfo.x + guiInfo.w - 364/zoom, guiInfo.y + guiInfo.h - 50/zoom, 254/zoom, 40/zoom, "Oda oluştur")
    self.buttons.setReady = exports.TR_dx:createButton(guiInfo.x + guiInfo.w - 364/zoom, guiInfo.y + guiInfo.h - 50/zoom, 254/zoom, 40/zoom, "Hazır")
    self.buttons.startJob = exports.TR_dx:createButton(guiInfo.x + guiInfo.w - 364/zoom, guiInfo.y + guiInfo.h - 50/zoom, 254/zoom, 40/zoom, self.jobID == self.currentJob and "İşi bitir" or "İşi başlat")

    self.buttons.accept = exports.TR_dx:createButton(guiInfo.x + guiInfo.w - 364/zoom, guiInfo.y + guiInfo.h - 50/zoom, 254/zoom, 40/zoom, "Yükseltmeyi satın al", "green")
    self.buttons.decline = exports.TR_dx:createButton(guiInfo.x + 10/zoom, guiInfo.y + guiInfo.h - 50/zoom, 254/zoom, 40/zoom, "İptal", "red")
    exports.TR_dx:setButtonVisible(self.buttons, false)

    self.edits = {}
    self.edits.text = exports.TR_dx:createEdit(guiInfo.x + 20/zoom, guiInfo.y + guiInfo.h - 50/zoom, guiInfo.w - 140/zoom, 40/zoom, "Mesajınızı yazın")

    exports.TR_dx:setEditVisible(self.edits.text, false)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.buttonClick = function(...) self:buttonClick(...) end
    self.func.onMouseClick = function(...) self:onMouseClick(...) end
    self.func.onScrollKey = function(...) self:onScrollKey(...) end
    self.func.sendMessage = function(...) self:sendMessage(...) end

    self:getJobDetails()
    self:buildPlayerJobData(playerJobData)

    self:selectTab(guiInfo.tabs[1].tab)
    self:loadPayment()

    self:open()
    return true
end

function Jobs:getJobDetails()
    local details = self.jobID and exports[self.jobID]:getJobDetails() or {}
    self.jobName = details.name
    self.desc = details.desc or "Açıklama yok"
    self.req = details.require or "Gerekli değil"
    
    self.img = self:getImage(details.img)
    self.payment = details.earnings or "???"
    self.multipleWork = details.minPlayers and details.minPlayers or false
    self.multipleWorkMax = details.maxPlayers and details.maxPlayers or self.multipleWork
    self.multipleWorkWorkers = details.workers and details.workers or false

    self.avaliableUpgrades = details.upgrades
    for i, v in pairs(self.avaliableUpgrades) do
        self.avaliableUpgrades[i].img = string.format(":%s/files/images/upgrades/%s.png", self.jobID, v.type)
    end
end

function Jobs:buildTopPlayers(data)
    self.ranking = {}
    for i, v in pairs(data) do
        table.insert(self.ranking, string.format("%s (%spkt)", v.username, v.totalPoints))
    end
end

function Jobs:buildPlayerJobData(data)
    local upgrades = fromJSON(data.upgrades)

    local haveUpgrades = {}
    if upgrades then
        for i, v in pairs(upgrades) do
            haveUpgrades[tonumber(i)] = true
        end
    end

    self.playerJobData = {
        points = data.points,
        totalPoints = data.totalPoints,
        upgrades = haveUpgrades,
    }
end

function Jobs:getImage(img)
    if self.jobID then
        if fileExists(string.format(":%s/files/images/job.png", self.jobID)) then return string.format(":%s/files/images/job.png", self.jobID) end
    end
    if fileExists(img) then return img end
    return false
end


function Jobs:open()
    self.state = "opening"
    self.tick = getTickCount()

    exports.TR_dx:showButton({self.buttons.close, self.buttons.startJob})
    exports.TR_dx:setOpenGUI(true)

    showCursor(true)
    bindKey("mouse_wheel_up", "down", self.func.onScrollKey)
    bindKey("mouse_wheel_down", "down", self.func.onScrollKey)
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("guiButtonClick", root, self.func.buttonClick)
    addEventHandler('onClientClick', root, self.func.onMouseClick)
    addEventHandler('onClientKey', root, self.func.sendMessage)
end

function Jobs:close()
    self.state = "closing"
    self.tick = getTickCount()

    exports.TR_dx:hideButton(self.buttons)

    showCursor(false)
    unbindKey("mouse_wheel_up", "down", self.func.onScrollKey)
    unbindKey("mouse_wheel_down", "down", self.func.onScrollKey)
    removeEventHandler("guiButtonClick", root, self.func.buttonClick)
    removeEventHandler('onClientClick', root, self.func.onMouseClick)
    removeEventHandler('onClientKey', root, self.func.sendMessage)
end

function Jobs:destroy()
    exports.TR_dx:setOpenGUI(false)
    exports.TR_dx:destroyButton(self.buttons)
    exports.TR_dx:destroyEdit(self.edits)
    removeEventHandler("onClientRender", root, self.func.render)

    for i, v in pairs(self.textures) do
        destroyElement(v)
    end

    guiInfo.job = nil
    self = nil
end


function Jobs:animate()
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


function Jobs:render()
    if self:animate() then return end
    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 5)

    if self.selectedTab == "info" then
        dxDrawText(self.jobName, guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w - 100/zoom, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")

        dxDrawText("İş Açıklaması:", guiInfo.x + 20/zoom, guiInfo.y + 50/zoom, guiInfo.x + guiInfo.w - 20/zoom, guiInfo.y + guiInfo.h - 50/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.info, "left", "top")
        dxDrawText(self.desc, guiInfo.x + 20/zoom, guiInfo.y + 80/zoom, guiInfo.x + guiInfo.w/2 - 20/zoom, guiInfo.y + guiInfo.h - 50/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.parts, "left", "top", true, true)

        dxDrawText("Gereksinimler:", guiInfo.x + guiInfo.w - 364/zoom, guiInfo.y + 198/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h - 50/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.info, "left", "top")
        dxDrawText(self.req, guiInfo.x + guiInfo.w - 364/zoom, guiInfo.y + 220/zoom, guiInfo.x + guiInfo.w - 110/zoom, guiInfo.y + guiInfo.h - 50/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.parts, "left", "top", true, true)

        dxDrawText("Ödeme:", guiInfo.x + guiInfo.w - 364/zoom, guiInfo.y + 256/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h - 60/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.info, "left", "bottom")
        dxDrawText(self.payment, guiInfo.x + guiInfo.w - 230/zoom, guiInfo.y + 220/zoom, guiInfo.x + guiInfo.w - 110/zoom, guiInfo.y + guiInfo.h - 60/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.info, "left", "bottom", true, true)


        if self:isMouseInPosition(guiInfo.x + guiInfo.w - 128/zoom, guiInfo.y + guiInfo.h - 80/zoom, 18/zoom, 18/zoom) then
            dxDrawImage(guiInfo.x + guiInfo.w - 128/zoom, guiInfo.y + guiInfo.h - 80/zoom, 18/zoom, 18/zoom, self.textures.information, 0, 0, 0, tocolor(220, 220, 220, 255 * self.alpha))

            local cx, cy = getCursorPosition()
            local width, height = 420/zoom, 85/zoom
            local x, y = cx * sx - width, cy * sy + 10/zoom
            self:drawBackground(x, y, width, height, tocolor(22, 22, 22, 255 * self.alpha), 4, true)
            dxDrawText("Verilen miktar, herhangi bir yükseltme satın alınmadığında 1 saat boyunca SABİT BİR KAZANÇTIR. Herhangi bir yükseltme satın aldıktan sonra puanların daha az olduğunu düşünebilirsiniz - bu sadece sizin algınız. Genel hesaplama ile yine de daha fazla kazanacaksınız!", x + 10/zoom, y + 10/zoom, x + width - 10/zoom, y + height - 10/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.tab, "left", "bottom", true, true, true)
            

        else
            dxDrawImage(guiInfo.x + guiInfo.w - 128/zoom, guiInfo.y + guiInfo.h - 80/zoom, 18/zoom, 18/zoom, self.textures.information, 0, 0, 0, tocolor(170, 170, 170, 255 * self.alpha))
        end

        if self.img then
            dxDrawRectangle(guiInfo.x + guiInfo.w - 364/zoom, guiInfo.y + 50/zoom, 254/zoom, 134/zoom, tocolor(37, 37, 37, 255 * self.alpha))
            dxDrawImage(guiInfo.x + guiInfo.w - 362/zoom, guiInfo.y + 52/zoom, 250/zoom, 130/zoom, self.img, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
        else
            dxDrawRectangle(guiInfo.x + guiInfo.w - 364/zoom, guiInfo.y + 50/zoom, 254/zoom, 134/zoom, tocolor(37, 37, 37, 255 * self.alpha))
            dxDrawRectangle(guiInfo.x + guiInfo.w - 362/zoom, guiInfo.y + 52/zoom, 250/zoom, 130/zoom, tocolor(17, 17, 17, 255 * self.alpha))
            dxDrawText("Buraya bir resim olmalıydı, ancak işverenin buna izin vermedi.", guiInfo.x + guiInfo.w - 354/zoom, guiInfo.y + 50/zoom, guiInfo.x + guiInfo.w - 120/zoom, guiInfo.y + 180/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "center", true, true)

        end

    elseif self.selectedTab == "rank" and self.loadingData then
        dxDrawText("En İyi Oyuncular", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w - 100/zoom, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")


        self.loadingDataRot = self.loadingDataRot + 4
        if self.loadingDataRot >= 360 then self.loadingDataRot = self.loadingDataRot - 360 end

        dxDrawImage(guiInfo.x + (guiInfo.w - guiInfo.iconSize - 60/zoom)/2 - 40/zoom/2, guiInfo.y + (guiInfo.h - 40/zoom)/2 - 20/zoom, 40/zoom, 40/zoom, self.textures.loading, self.loadingDataRot, 0, 0, tocolor(120, 120, 120, 255 * self.alpha))
        dxDrawText("Sıralama yükleniyor...", guiInfo.stand.x, guiInfo.y + (guiInfo.h + 40/zoom)/2, guiInfo.stand.x + guiInfo.stand.w, guiInfo.y + guiInfo.h - 15/zoom, tocolor(120, 120, 120, 255 * self.alpha), 1/zoom, self.fonts.tab, "center", "top")


    elseif self.selectedTab == "rank" and not self.loadingData then
        dxDrawText("En İyi Oyuncular", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w - 100/zoom, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")


        dxDrawImage(guiInfo.stand.x, guiInfo.stand.y, guiInfo.stand.w, guiInfo.stand.h, self.textures.stand, 0, 0, 0, tocolor(200, 200, 200, 170 * self.alpha))

        dxDrawText(self.ranking[1] or "Yok", guiInfo.stand.x + 182/zoom, guiInfo.y + 30/zoom, guiInfo.stand.x + 367/zoom, guiInfo.stand.y - 5/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "bottom", true, true)
        dxDrawText(self.ranking[2] or "Yok", guiInfo.stand.x + 367/zoom, guiInfo.y + 50/zoom, guiInfo.stand.x + 547/zoom, guiInfo.stand.y + 25/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "bottom", true, true)
        dxDrawText(self.ranking[3] or "Yok", guiInfo.stand.x + 2/zoom, guiInfo.y + 50/zoom, guiInfo.stand.x + 182/zoom, guiInfo.stand.y + 55/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "bottom", true, true)


        local x = guiInfo.stand.x
        local row = 1
        for i = 1, 4 do
            local v = self.ranking[i + 3]
            if v then
                dxDrawRectangle(x, guiInfo.stand.y + guiInfo.stand.h + 15/zoom + (row-1) * 40/zoom, guiInfo.stand.w/2 - 5/zoom, 30/zoom, tocolor(27, 27, 27, 255 * self.alpha))
                dxDrawText(string.format("%d. %s", i + 3, v), x + 5/zoom, guiInfo.stand.y + guiInfo.stand.h + 15/zoom + (row-1) * 40/zoom, x + guiInfo.stand.w/2 - 5/zoom, guiInfo.stand.y + guiInfo.stand.h + 45/zoom + (row-1) * 40/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.parts, "left", "center")
            else
                dxDrawRectangle(x, guiInfo.stand.y + guiInfo.stand.h + 15/zoom + (row-1) * 40/zoom, guiInfo.stand.w/2 - 5/zoom, 30/zoom, tocolor(27, 27, 27, 255 * self.alpha))
                dxDrawText(string.format("%d. Yok", i + 3), x + 5/zoom, guiInfo.stand.y + guiInfo.stand.h + 15/zoom + (row-1) * 40/zoom, x + guiInfo.stand.w/2 - 5/zoom, guiInfo.stand.y + guiInfo.stand.h + 45/zoom + (row-1) * 40/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.parts, "left", "center")
            end

            row = row + 1
            if i == 2 then
                x = guiInfo.stand.x + guiInfo.stand.w/2 + 5/zoom
                row = 1
            end
        end

        dxDrawText(string.format("Sıralama Puanları: %d", self.playerJobData.totalPoints), guiInfo.stand.x, guiInfo.stand.y, guiInfo.stand.x + guiInfo.stand.w, guiInfo.y + guiInfo.h - 15/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.parts, "left", "bottom")

    if self:isMouseInPosition(guiInfo.stand.x + guiInfo.stand.w - 160/zoom, guiInfo.y + guiInfo.h - 37/zoom, 162/zoom, 24/zoom) then
        dxDrawText("Ödülleri Al", guiInfo.stand.x, guiInfo.stand.y, guiInfo.stand.x + guiInfo.stand.w - 28/zoom, guiInfo.y + guiInfo.h - 15/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.parts, "right", "bottom")
        dxDrawImage(guiInfo.stand.x + guiInfo.stand.w - 20/zoom, guiInfo.y + guiInfo.h - 35/zoom, 20/zoom, 20/zoom, self.textures.trophy, 0, 0, 0, tocolor(220, 220, 220, 255 * self.alpha))
    else
        dxDrawText("Ödülleri Al", guiInfo.stand.x, guiInfo.stand.y, guiInfo.stand.x + guiInfo.stand.w - 28/zoom, guiInfo.y + guiInfo.h - 15/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.parts, "right", "bottom")
        dxDrawImage(guiInfo.stand.x + guiInfo.stand.w - 20/zoom, guiInfo.y + guiInfo.h - 35/zoom, 20/zoom, 20/zoom, self.textures.trophy, 0, 0, 0, tocolor(170, 170, 170, 255 * self.alpha))
    end



    elseif self.selectedTab == "upgrade" then
        dxDrawText("Yükseltmeler", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w - 100/zoom, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")

        for i, v in pairs(self.avaliableUpgrades) do
            local alpha = 170
            if self.playerJobData.upgrades[i] then alpha = 220
            elseif self:isMouseInPosition(guiInfo.x, guiInfo.y + 50/zoom + (i-1) * 70/zoom - 10/zoom, guiInfo.w - 100/zoom, 65/zoom) then alpha = 200 end
            dxDrawImage(guiInfo.x + 20/zoom, guiInfo.y + 50/zoom + (i-1) * 70/zoom, 45/zoom, 45/zoom, v.img, 0, 0, 0, tocolor(255, 255, 255, alpha * self.alpha))
            dxDrawText(v.name..string.format(" (%s)", self.playerJobData.upgrades[i] and "Sahip olunan" or  tostring(v.price).."pkt"), guiInfo.x + 80/zoom, guiInfo.y + 53/zoom + (i-1) * 70/zoom, 45/zoom, 45/zoom, tocolor(220, 220, 220, alpha * self.alpha), 1/zoom, self.fonts.info, "left", "top")
            dxDrawText(v.desc, guiInfo.x + 80/zoom, guiInfo.y + 45/zoom + (i-1) * 70/zoom, guiInfo.x + guiInfo.w - 110/zoom, guiInfo.y + 47/zoom + (i-1) * 70/zoom + 45/zoom, tocolor(170, 170, 170, alpha * self.alpha), 1/zoom, self.fonts.tab, "left", "bottom", true, true)
        end
        dxDrawText(string.format("Mevcut puanlar: %d", self.playerJobData.points), guiInfo.stand.x, guiInfo.stand.y, guiInfo.stand.x + guiInfo.stand.w, guiInfo.y + guiInfo.h - 15/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.parts, "center", "bottom")


    elseif self.selectedTab == "acceptUpgrade" then
        dxDrawText("Satın alma onayı", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w - 100/zoom, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")

        dxDrawImage(sx/2 - 64/zoom/2, guiInfo.y + 94/zoom, 64/zoom, 64/zoom, self.selectedUpgrade.img, 0, 0, 0, tocolor(220, 220, 220, 255 * self.alpha))
        dxDrawText(self.selectedUpgrade.name, guiInfo.x, guiInfo.y + 170/zoom, guiInfo.x + guiInfo.w - 100/zoom, guiInfo.y + 50/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.parts, "center", "top")
        dxDrawText(self.selectedUpgrade.desc, guiInfo.x, guiInfo.y + 195/zoom, guiInfo.x + guiInfo.w - 100/zoom, guiInfo.y + 50/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.desc, "center", "top")

    elseif self.selectedTab == "getJobPrizes" and self.loadingData then
        dxDrawText("Ödülleriniz", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w - 100/zoom, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")

        self.loadingDataRot = self.loadingDataRot + 4
        if self.loadingDataRot >= 360 then self.loadingDataRot = self.loadingDataRot - 360 end

        dxDrawImage(guiInfo.x + (guiInfo.w - guiInfo.iconSize - 60/zoom)/2 - 40/zoom/2, guiInfo.y + (guiInfo.h - 40/zoom)/2 - 20/zoom, 40/zoom, 40/zoom, self.textures.loading, self.loadingDataRot, 0, 0, tocolor(120, 120, 120, 255 * self.alpha))
        dxDrawText("Ödüller yükleniyor...", guiInfo.stand.x, guiInfo.y + (guiInfo.h + 40/zoom)/2, guiInfo.stand.x + guiInfo.stand.w, guiInfo.y + guiInfo.h - 15/zoom, tocolor(120, 120, 120, 255 * self.alpha), 1/zoom, self.fonts.tab, "center", "top")

    elseif self.selectedTab == "getJobPrizes" and not self.loadingData then
        dxDrawText("Ödülleriniz", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w - 100/zoom, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")

        dxDrawImage(sx/2 - 128/zoom/2, guiInfo.y + 50/zoom, 128/zoom, 128/zoom, self.textures.trophy, 0, 0, 0, tocolor(220, 220, 220, 255 * self.alpha))
        dxDrawText(string.format("$%d", self.playerPrizes), guiInfo.x, guiInfo.y + 185/zoom, guiInfo.x + guiInfo.w - 100/zoom, guiInfo.y + 50/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.trophy, "center", "top")
        dxDrawText("Ödüller her girişte ilk 7'ye verilir. Ödül hesaplanırken sıralama sıfırlanır, böylece bir sonraki ay herkesin eşit kazanma şansı olur..", guiInfo.x + 10/zoom, guiInfo.y + 235/zoom, guiInfo.x + guiInfo.w - 100/zoom, guiInfo.y + guiInfo.h - 60/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.desc, "center", "top", true, true)

    elseif self.selectedTab == "payment" then
        dxDrawText("Ödeme seçimi", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w - 100/zoom, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")

        local y = guiInfo.y + (guiInfo.h - 128/zoom)/2 - 20/zoom

        local alpha = 120
        if self.selectedPayment == "cash" then alpha = 220
        elseif self:isMouseInPosition(sx/2 - 128/zoom - 60/zoom - 15/zoom, y, 158/zoom, 190/zoom) then alpha = 150 end
        dxDrawImage(sx/2 - 128/zoom - 60/zoom, y, 128/zoom, 128/zoom, self.textures.cash, 0, 0, 0, tocolor(255, 255, 255, alpha * self.alpha))
        dxDrawText("Nakit", sx/2 - 128/zoom - 60/zoom, y + 148/zoom, sx/2 - 68/zoom, guiInfo.y + 50/zoom, tocolor(255, 255, 255, alpha * self.alpha), 1/zoom, self.fonts.main, "center", "top")

        local alpha = 120
        if not self.bankCode then alpha = 80
        elseif self.selectedPayment == "card" then alpha = 220
        elseif self:isMouseInPosition(sx/2 + 60/zoom - 15/zoom, y, 158/zoom, 190/zoom) then alpha = 150 end
        dxDrawImage(sx/2 + 60/zoom, guiInfo.y + (guiInfo.h - 128/zoom)/2 - 20/zoom, 128/zoom, 128/zoom, self.textures.card, 0, 0, 0, tocolor(255, 255, 255, alpha * self.alpha))
        dxDrawText("Kart", sx/2 + 60/zoom, y + 148/zoom, sx/2 + 188/zoom, sx/2 + 188/zoom, tocolor(255, 255, 255, alpha * self.alpha), 1/zoom, self.fonts.main, "center", "top")

        dxDrawText("Kazanılan para yukarıda seçilen şekilde ödenecektir..", guiInfo.stand.x, guiInfo.stand.y, guiInfo.stand.x + guiInfo.stand.w, guiInfo.y + guiInfo.h - 15/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.tab, "center", "bottom")

    elseif self.selectedTab == "selectRoom" then
        dxDrawText("Bir oda seçin", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w - 100/zoom, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")

        if self.loadingGroupList then
            self.loadingGroupList = self.loadingGroupList + 5
            self.loadingGroupList = self.loadingGroupList >= 360 and self.loadingGroupList - 360 or self.loadingGroupList

            dxDrawImage(guiInfo.x + (guiInfo.w - guiInfo.iconSize - 60/zoom)/2 - 40/zoom/2, guiInfo.y + (guiInfo.h - 40/zoom)/2 - 20/zoom, 40/zoom, 40/zoom, self.textures.loading, self.loadingGroupList, 0, 0, tocolor(120, 120, 120, 255 * self.alpha))
            dxDrawText("Odalar yükleniyor...", guiInfo.stand.x, guiInfo.y + (guiInfo.h + 40/zoom)/2, guiInfo.stand.x + guiInfo.stand.w, guiInfo.y + guiInfo.h - 15/zoom, tocolor(120, 120, 120, 255 * self.alpha), 1/zoom, self.fonts.tab, "center", "top")
        else
            if self.jobRooms then
                for i = 1, 4 do
                    local v = self.jobRooms[self.scroll + i]
                    if v then
                        if self:isMouseInPosition(guiInfo.x + 10/zoom, guiInfo.y + 50/zoom + 62/zoom * (i-1), guiInfo.w - guiInfo.iconSize - 80/zoom, 60/zoom) then
                            dxDrawRectangle(guiInfo.x + 10/zoom, guiInfo.y + 50/zoom + 62/zoom * (i-1), guiInfo.w - guiInfo.iconSize - 80/zoom, 60/zoom, tocolor(27, 27, 27, 255 * self.alpha))
                        else
                            dxDrawRectangle(guiInfo.x + 10/zoom, guiInfo.y + 50/zoom + 62/zoom * (i-1), guiInfo.w - guiInfo.iconSize - 80/zoom, 60/zoom, tocolor(22, 22, 22, 255 * self.alpha))
                        end

                        dxDrawText(string.format("Oyuncu odası %s", v.owner), guiInfo.x + 20/zoom, guiInfo.y + 60/zoom + 62/zoom * (i-1), guiInfo.x + guiInfo.w - 200/zoom, guiInfo.y + 50/zoom + 62/zoom * (i-1), tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.parts, "left", "top")

                        dxDrawImage(guiInfo.x + guiInfo.w - guiInfo.iconSize - 100/zoom, guiInfo.y + 60/zoom + 62/zoom * (i-1), 16/zoom, 16/zoom, self.textures.person, 0, 0, 0, tocolor(220, 220, 220, 255 * self.alpha))
                        dxDrawText(string.format("%d/%d", #v.players, self.multipleWorkMax), guiInfo.x + 20/zoom, guiInfo.y + 60/zoom + 62/zoom * (i-1), guiInfo.x + guiInfo.w - guiInfo.iconSize - 105/zoom, guiInfo.y + 76/zoom + 62/zoom * (i-1), tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.tab, "right", "center")

                        local inRoom = ""
                        for k, player in pairs(v.players) do
                            inRoom = string.format("%s%s%s", inRoom, player.name, #v.players ~= k and ", " or "")
                        end
                        dxDrawText(string.format("Bir odada: %s", inRoom), guiInfo.x + 20/zoom, guiInfo.y + 60/zoom + 62/zoom * (i-1), guiInfo.x + guiInfo.w - 200/zoom, guiInfo.y + 100/zoom + 62/zoom * (i-1), tocolor(120, 120, 120, 255 * self.alpha), 1/zoom, self.fonts.tab, "left", "bottom")
                    end
                end

                if #self.jobRooms > 4 then
                    local b1 = 246/zoom / #self.jobRooms
                    self.barY = b1 * self.scroll
                    self.barHeight = b1 * 4

                    dxDrawRectangle(guiInfo.x + guiInfo.w - guiInfo.iconSize - 72/zoom, guiInfo.y + 50/zoom, 4/zoom, 246/zoom, tocolor(37, 37, 37, 255 * self.alpha))
                    dxDrawRectangle(guiInfo.x + guiInfo.w - guiInfo.iconSize - 72/zoom, guiInfo.y + 50/zoom + self.barY, 4/zoom, self.barHeight, tocolor(60, 60, 60, 255 * self.alpha))
                end

            else
                dxDrawText("Henüz oda yok.\nÖnce bir oda oluşturabilirsiniz :)", guiInfo.stand.x, guiInfo.y + guiInfo.h/2, guiInfo.stand.x + guiInfo.stand.w, guiInfo.y + guiInfo.h/2, tocolor(120, 120, 120, 255 * self.alpha), 1/zoom, self.fonts.parts, "center", "center")
            end
        end

    elseif self.selectedTab == "group" then
        dxDrawText(string.format("Oyuncu odası %s", self.currentGroup.owner), guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w - 100/zoom, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")

        for i, v in pairs(self.currentGroup.players) do
            dxDrawRectangle(guiInfo.x + 10/zoom, guiInfo.y + 50/zoom + 62/zoom * (i-1), guiInfo.w - guiInfo.iconSize - 80/zoom, 60/zoom, tocolor(22, 22, 22, 255 * self.alpha))
            dxDrawText(string.format("%s (%d)", v.name, v.id), guiInfo.x + 42/zoom, guiInfo.y + 60/zoom + 62/zoom * (i-1), guiInfo.x + guiInfo.w - 200/zoom, guiInfo.y + 50/zoom + 62/zoom * (i-1), tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.parts, "left", "top")

            local color = v.ready and {12, 117, 13} or {140, 15, 15}
            dxDrawText(v.ready and "ÇALIŞMAYA HAZIR" or v.name == self.currentGroup.owner and "ONAY BEKLENİYOR" or "ÇALIŞMAYA HAZIR DEĞİLİZ", guiInfo.x + 20/zoom, guiInfo.y + 60/zoom + 62/zoom * (i-1), guiInfo.x + guiInfo.w - 200/zoom, guiInfo.y + 100/zoom + 62/zoom * (i-1), tocolor(color[1], color[2], color[3], 255 * self.alpha), 1/zoom, self.fonts.tab, "left", "bottom")

            if v.name == self.currentGroup.owner then
                dxDrawImage(guiInfo.x + 20/zoom, guiInfo.y + 62/zoom + 62/zoom * (i-1), 16/zoom, 16/zoom, self.textures.crown, 0, 0, 0, tocolor(v.color[1], v.color[2], v.color[3], 255 * self.alpha))
            else
                dxDrawImage(guiInfo.x + 20/zoom, guiInfo.y + 62/zoom + 62/zoom * (i-1), 16/zoom, 16/zoom, self.textures.person, 0, 0, 0, tocolor(v.color[1], v.color[2], v.color[3], 255 * self.alpha))

                if getPlayerName(localPlayer) == self.currentGroup.owner then
                    if self:isMouseInPosition(guiInfo.x + guiInfo.w - guiInfo.iconSize - 105/zoom, guiInfo.y + 68/zoom + 62/zoom * (i-1), 24/zoom, 24/zoom) then
                        dxDrawImage(guiInfo.x + guiInfo.w - guiInfo.iconSize - 105/zoom, guiInfo.y + 68/zoom + 62/zoom * (i-1), 24/zoom, 24/zoom, self.textures.remove, 0, 0, 0, tocolor(170, 170, 170, 255 * self.alpha))
                    else
                        dxDrawImage(guiInfo.x + guiInfo.w - guiInfo.iconSize - 105/zoom, guiInfo.y + 68/zoom + 62/zoom * (i-1), 24/zoom, 24/zoom, self.textures.remove, 0, 0, 0, tocolor(120, 120, 120, 255 * self.alpha))
                    end
                end
            end
        end

    elseif self.selectedTab == "chat" then
        dxDrawText("Sohbet odası", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w - 100/zoom, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")

        if self.currentGroup.messages then
            for i, v in pairs(self.currentGroup.messages) do
                i = 5 - i
                dxDrawRectangle(guiInfo.x + 10/zoom, guiInfo.y + 50/zoom + 62/zoom * (i-1), guiInfo.w - guiInfo.iconSize - 80/zoom, 60/zoom, tocolor(22, 22, 22, 255 * self.alpha))
                dxDrawText(string.format("%s (%d)", v.name, v.id), guiInfo.x + 42/zoom, guiInfo.y + 60/zoom + 62/zoom * (i-1), guiInfo.x + guiInfo.w - 200/zoom, guiInfo.y + 50/zoom + 62/zoom * (i-1), tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.parts, "left", "top")

                dxDrawText(v.text, guiInfo.x + 20/zoom, guiInfo.y + 60/zoom + 62/zoom * (i-1), guiInfo.x + guiInfo.w - 200/zoom, guiInfo.y + 100/zoom + 62/zoom * (i-1), tocolor(120, 120, 120, 255 * self.alpha), 1/zoom, self.fonts.tab, "left", "bottom")

                if v.name == self.currentGroup.owner then
                    dxDrawImage(guiInfo.x + 20/zoom, guiInfo.y + 62/zoom + 62/zoom * (i-1), 16/zoom, 16/zoom, self.textures.crown, 0, 0, 0, tocolor(v.color[1], v.color[2], v.color[3], 255 * self.alpha))
                else
                    dxDrawImage(guiInfo.x + 20/zoom, guiInfo.y + 62/zoom + 62/zoom * (i-1), 16/zoom, 16/zoom, self.textures.person, 0, 0, 0, tocolor(v.color[1], v.color[2], v.color[3], 255 * self.alpha))
                end
            end

        else
            dxDrawText("Henüz mesaj yok.\İlk yazan siz olabilirsiniz :)", guiInfo.stand.x, guiInfo.y + guiInfo.h/2, guiInfo.stand.x + guiInfo.stand.w, guiInfo.y + guiInfo.h/2, tocolor(120, 120, 120, 255 * self.alpha), 1/zoom, self.fonts.parts, "center", "center")
        end
    end

    dxDrawRectangle(guiInfo.x + guiInfo.w - guiInfo.iconSize - 60/zoom, guiInfo.y, 2/zoom, guiInfo.h, tocolor(37, 37, 37, 170 * self.alpha))
    self:renderTabSelect()
end

function Jobs:renderTabSelect()
    if self.isSelectingGroup then
        local y = guiInfo.y + guiInfo.h/2 - 80/zoom
        for i, v in pairs(guiInfo.groupTabs) do
            local alpha = self.selectedTab == "group" and 170 or self.selectedTab == "chat" and 170 or 100
            if v.tab == self.selectedTab then alpha = 255
            elseif self:isMouseInPosition(guiInfo.x + guiInfo.w - guiInfo.iconSize - 50/zoom, y - 8/zoom + 80/zoom * (i-1), guiInfo.iconSize + 40/zoom, guiInfo.iconSize + 40/zoom) and not self.canSwitchTab and (self.selectedTab == "group" or self.selectedTab == "chat") and not self.loadingData then alpha = 220 end

            dxDrawImage(guiInfo.x + guiInfo.w - guiInfo.iconSize - 30/zoom, y + 85/zoom * (i-1), guiInfo.iconSize, guiInfo.iconSize, self.textures[v.tab], 0, 0, 0, tocolor(200, 200, 200, alpha * self.alpha))
            dxDrawText(v.name, guiInfo.x + guiInfo.w - guiInfo.iconSize/2 - 30/zoom, y + 85/zoom * (i-1) + guiInfo.iconSize + 10/zoom, guiInfo.x + guiInfo.w - guiInfo.iconSize/2 - 30/zoom, y + guiInfo.iconSize * i + 10/zoom, tocolor(220, 220, 220, alpha * self.alpha), 1/zoom, self.fonts.tab, "center", "top")
        end

    else
        local y = guiInfo.y + 20/zoom
        for i, v in pairs(guiInfo.tabs) do
            local alpha = 170
            if v.tab == self.selectedTab then alpha = 255
            elseif self:isMouseInPosition(guiInfo.x + guiInfo.w - guiInfo.iconSize - 50/zoom, y - 8/zoom + 80/zoom * (i-1), guiInfo.iconSize + 40/zoom, guiInfo.iconSize + 40/zoom) and self.canSwitchTab then alpha = 220 end

            dxDrawImage(guiInfo.x + guiInfo.w - guiInfo.iconSize - 30/zoom, y + 85/zoom * (i-1), guiInfo.iconSize, guiInfo.iconSize, self.textures[v.tab], 0, 0, 0, tocolor(200, 200, 200, alpha * self.alpha))
            dxDrawText(v.name, guiInfo.x + guiInfo.w - guiInfo.iconSize/2 - 30/zoom, y + 85/zoom * (i-1) + guiInfo.iconSize + 10/zoom, guiInfo.x + guiInfo.w - guiInfo.iconSize/2 - 30/zoom, y + guiInfo.iconSize * i + 10/zoom, tocolor(220, 220, 220, alpha * self.alpha), 1/zoom, self.fonts.tab, "center", "top")
        end
    end
end

function Jobs:onScrollKey(...)
    if self.selectedTab ~= "selectRoom" then return end
    if not self.jobRooms then return end
    if #self.jobRooms <= 4 then return end
    if not self:isMouseInPosition(guiInfo.x, guiInfo.y, guiInfo.w - 100/zoom, guiInfo.h) then return end

    if arg[1] == "mouse_wheel_up" then
        self.scroll = math.max(self.scroll - 1, 0)

    elseif arg[1] == "mouse_wheel_down" then
        self.scroll = math.min(self.scroll + 1, #self.jobRooms - 4)
    end
end

function Jobs:sendMessage(...)
    if self.selectedTab ~= "chat" then return end
    if arg[1] ~= "enter" or not arg[2] then return end

    local text = guiGetText(self.edits.text)
    if not text then return end
    if string.len(text) < 2 or string.len(text) > 40 then return end

    exports.TR_dx:setEditText(self.edits.text, "")
    triggerServerEvent("addJobRoomMessage", resourceRoot, self.jobID, self.selectedRoom, text)
end

function Jobs:onMouseClick(...)
    if self.loadingData then return end
    if exports.TR_dx:isResponseEnabled() then return end

    if arg[1] == "left" and arg[2] == "down" then
        if self:isMouseInPosition(guiInfo.x + guiInfo.w - 100/zoom, guiInfo.y, 100/zoom, guiInfo.h) then
            if self.isSelectingGroup then
                if self.selectedTab ~= "group" and self.selectedTab ~= "chat" then return end
                local y = guiInfo.y + guiInfo.h/2 - 80/zoom
                for i, v in pairs(guiInfo.groupTabs) do
                    if self:isMouseInPosition(guiInfo.x + guiInfo.w - guiInfo.iconSize - 50/zoom, y - 8/zoom + 80/zoom * (i-1), guiInfo.iconSize + 40/zoom, guiInfo.iconSize + 40/zoom) then
                        self:selectTab(v.tab)
                        break
                    end
                end

            elseif self.canSwitchTab then
                local y = guiInfo.y + 20/zoom
                for i, v in pairs(guiInfo.tabs) do
                    if self:isMouseInPosition(guiInfo.x + guiInfo.w - guiInfo.iconSize - 50/zoom, y - 8/zoom + 80/zoom * (i-1), guiInfo.iconSize + 40/zoom, guiInfo.iconSize + 40/zoom) then
                        self:selectTab(v.tab)
                        break
                    end
                end
            end

        elseif self:isMouseInPosition(guiInfo.x, guiInfo.y, guiInfo.w - 100/zoom, guiInfo.h) then
            if self.selectedTab == "upgrade" then
                for i, v in pairs(self.avaliableUpgrades) do
                    if self:isMouseInPosition(guiInfo.x, guiInfo.y + 50/zoom + (i-1) * 70/zoom - 10/zoom, guiInfo.w - 100/zoom, 65/zoom) then
                        if self.playerJobData.upgrades[i] then return end
                        self:selectTab("acceptUpgrade")
                        self.selectedUpgrade = v
                        self.selectedUpgradeIndex = i
                        break
                    end
                end

            elseif self.selectedTab == "payment" then
                if self:isMouseInPosition(sx/2 - 128/zoom - 60/zoom - 15/zoom, guiInfo.y + (guiInfo.h - 128/zoom)/2 - 20/zoom, 158/zoom, 190/zoom) then
                    if not self.bankCode then return end
                    if self.selectedPayment == "cash" then return end

                    self:savePayment("cash")
                    exports.TR_noti:create("Ödeme yöntemi nakit olarak ayarlandı.", "success")

                elseif self:isMouseInPosition(sx/2 + 60/zoom - 15/zoom, guiInfo.y + (guiInfo.h - 128/zoom)/2 - 20/zoom, 158/zoom, 190/zoom) then
                    if not self.bankCode then return end
                    if self.selectedPayment == "card" then return end

                    self:savePayment("card")
                    exports.TR_noti:create("Ödeme yöntemi kart olarak ayarlandı.", "success")
                end

            elseif self.selectedTab == "selectRoom" then
                if self.jobRooms then
                    for i = 1, 4 do
                        local v = self.jobRooms[self.scroll + i]
                        if v then
                            if self:isMouseInPosition(guiInfo.x + 10/zoom, guiInfo.y + 50/zoom + 62/zoom * (i-1), guiInfo.w - guiInfo.iconSize - 80/zoom, 60/zoom) then
                                exports.TR_dx:setResponseEnabled(true, "Odaya katıl")
                                self.selectedRoom = v.owner
                                triggerServerEvent("joinJobRoom", resourceRoot, self.jobID, v.owner, self.multipleWorkMax)
                                break
                            end
                        end
                    end
                end

            elseif self.selectedTab == "group" then
                local plrName = getPlayerName(localPlayer)
                for i, v in pairs(self.currentGroup.players) do
                    if v.name ~= self.currentGroup.owner then
                        if plrName == self.currentGroup.owner then
                            if self:isMouseInPosition(guiInfo.x + guiInfo.w - guiInfo.iconSize - 105/zoom, guiInfo.y + 68/zoom + 62/zoom * (i-1), 24/zoom, 24/zoom) then
                                triggerServerEvent("leaveJobRoom", resourceRoot, self.jobID, self.selectedRoom, v.name)
                                break
                            end
                        end
                    end
                end

            elseif self.selectedTab == "rank" then
                if self:isMouseInPosition(guiInfo.stand.x + guiInfo.stand.w - 160/zoom, guiInfo.y + guiInfo.h - 37/zoom, 162/zoom, 24/zoom) then
                    self:selectTab("getJobPrizes")
                end
            end
        end
    end
end

function Jobs:selectTab(tab)
    if self.loadingGroupList then return end

    self.lastTab = self.selectedTab
    self.selectedTab = tab
    self.canSwitchTab = not guiInfo.blockTabSelect[tab]
    self.isSelectingGroup = false

    exports.TR_dx:setButtonVisible(self.buttons, false)
    exports.TR_dx:setEditVisible(self.edits.text, false)

    if tab == "info" then
        exports.TR_dx:setButtonVisible({self.buttons.startJob, self.buttons.close}, true)

    elseif tab == "acceptUpgrade" then
        exports.TR_dx:setButtonVisible({self.buttons.accept, self.buttons.decline}, true)
        exports.TR_dx:setButtonText(self.buttons.accept, "Satın al")
        exports.TR_dx:setButtonText(self.buttons.decline, "İptal")

    elseif tab == "getJobPrizes" then
        if self.playerPrizes then
            exports.TR_dx:setButtonVisible({self.buttons.accept, self.buttons.decline}, true)
            exports.TR_dx:setButtonText(self.buttons.accept, "Satın al")
            exports.TR_dx:setButtonText(self.buttons.decline, "İptal")
        else
            self.loadingData = true
            self.loadingDataRot = 0
            triggerServerEvent("getPlayerJobTabData", resourceRoot, self.jobID, tab)
        end

    elseif tab == "rank" then
        if not self.ranking then
            self.loadingData = true
            self.loadingDataRot = 0
            triggerServerEvent("getPlayerJobTabData", resourceRoot, self.jobID, tab)
        end


    elseif tab == "selectRoom" then
        exports.TR_dx:setButtonText(self.buttons.goBack, "Geri Dön")
        exports.TR_dx:setButtonVisible({self.buttons.goBack, self.buttons.createRoom}, true)
        self.isSelectingGroup = true
        self.loadingGroupList = 0
        self.jobRooms = nil
        self.scroll = 0
        self.selectedRoom = nil
        triggerServerEvent("getJobRooms", resourceRoot, self.jobID)

    elseif tab == "group" then
        exports.TR_dx:setButtonText(self.buttons.goBack, "Odayı terk et")
        exports.TR_dx:setButtonVisible({self.buttons.goBack, self.buttons.setReady}, true)
        self.isSelectingGroup = true

        if self.currentGroup then
            if self.currentGroup.owner == getPlayerName(localPlayer) then
                exports.TR_dx:setButtonText(self.buttons.setReady, "Başla")
            else
                exports.TR_dx:setButtonText(self.buttons.setReady, "Rapor hazırlığı")
            end
        end

    elseif tab == "chat" then
        exports.TR_dx:setEditVisible({self.edits.text}, true)
        self.isSelectingGroup = true
    end

    if not self.isSelectingGroup then
        self.loadingGroupList = nil
    end
end

function Jobs:loadData(data)
    if self.selectedTab == "getJobPrizes" then
        self.playerPrizes = data and tonumber(data.prize) or 0
        self.loadingData = false

        exports.TR_dx:setButtonVisible({self.buttons.accept, self.buttons.decline}, true)
        exports.TR_dx:setButtonText(self.buttons.accept, "Ödüllerinizi toplayın")
        exports.TR_dx:setButtonText(self.buttons.decline, "İptal")

    elseif self.selectedTab == "rank" then
        self:buildTopPlayers(data)
        self.loadingData = false
    end
end

function Jobs:buttonClick(...)
    if self.loadingData then return end
    if exports.TR_dx:isResponseEnabled() then return end
    if self.state ~= "opened" then return end

    if arg[1] == self.buttons.close then
        self:close()

    elseif arg[1] == self.buttons.startJob then
        if self.jobID == self.currentJob then
            self:endJob()
        elseif not self.currentJob then
            self:startJob()
        else
            exports.TR_noti:create("Burada çalışmaya başlayamazsınız çünkü zaten bir yerde çalışıyorsunuz.", "error")
        end

    elseif arg[1] == self.buttons.accept then
        if self.selectedTab == "getJobPrizes" then
            if not self.playerPrizes then exports.TR_noti:create("Ödeyeceğiniz bir ödül yok.", "error") return end
            if tonumber(self.playerPrizes) == nil then exports.TR_noti:create("Ödeyeceğiniz bir ödül yok.", "error") return end
            if tonumber(self.playerPrizes) < 1 then exports.TR_noti:create("Ödeyeceğiniz bir ödül yok.", "error") return end

            exports.TR_dx:setResponseEnabled(true)
            triggerServerEvent("payoutJobPrizes", resourceRoot, self.jobID)

        else
            if self.currentJob then
                exports.TR_noti:create("Çalışırken yükseltme satın alamazsınız.", "error")
                return
            end
            if self.selectedUpgrade.price > self.playerJobData.points then
                exports.TR_noti:create("Bu yükseltmeyi satın almak için yeterli puanınız yok.", "error")
                return
            end

            self.playerJobData.points = self.playerJobData.points - self.selectedUpgrade.price
            self.playerJobData.upgrades[self.selectedUpgradeIndex] = true

            exports.TR_dx:setResponseEnabled(true)
            triggerServerEvent("buyJobUpgrade", resourceRoot, self.jobID, self.selectedUpgrade.price, toJSON(self.playerJobData.upgrades))
        end

    elseif arg[1] == self.buttons.decline then
        self:selectTab(self.lastTab)

    elseif arg[1] == self.buttons.goBack then
        if self.selectedTab == "group" then
            exports.TR_dx:setResponseEnabled(true)

            triggerServerEvent("leaveJobRoom", resourceRoot, self.jobID, self.selectedRoom, getPlayerName(localPlayer))
            self:selectTab("selectRoom")
        else
            self:selectTab("info")
        end

    elseif arg[1] == self.buttons.createRoom then
        exports.TR_dx:setResponseEnabled(true)

        self.selectedRoom = getPlayerName(localPlayer)
        triggerServerEvent("addJobRoom", resourceRoot, self.jobID)

    elseif arg[1] == self.buttons.setReady then
        if not self.selectedRoom then return end

        if getPlayerName(localPlayer) == self.currentGroup.owner then
            if self.multipleWork > #self.currentGroup.players then
                exports.TR_noti:create(string.format("Odada çok az oyuncu var. Çalışmaya başlamak için odada en az %d oyuncu bulunmalıdır.", self.multipleWork), "error", 4)
                return
            end

            for i, v in pairs(self.currentGroup.players) do
                if not v.ready and v.name ~= self.currentGroup.owner then
                    exports.TR_noti:create("Herkes çalışmaya başlamaya hazır değil. Herkes hazır olduğunu bildirene kadar bekleyin.", "error", 4)
                    return
                end
            end

            exports.TR_dx:setResponseEnabled(true)
            triggerServerEvent("setJobRoomStartWork", resourceRoot, self.jobID, self.selectedRoom, self.multipleWorkWorkers)

        else
            exports.TR_dx:setResponseEnabled(true)
            triggerServerEvent("setJobReadyStatus", resourceRoot, self.jobID, self.selectedRoom)
        end
    end
end

function Jobs:startJob()
    if getElementData(localPlayer, "waitingEvent") then
        exports.TR_noti:create("Kayıtlı olduğunuz etkinliği beklerken çalışmaya başlayamazsınız.", "error", 8)
        return
    end

    if self.req then
        if string.find(self.req, "kat. A") then
            if not self.licences["a"] then exports.TR_noti:create("Tüm şartları karşılamadığınız için bu işi alamıyorsunuz.", "error") return end
            if self.hasBlockedLicence then exports.TR_noti:create("Ehliyetinize el konulduğu için bu işte iş bulamazsınız.", "error") return end

        elseif string.find(self.req, "kat. B") then
            if not self.licences["b"] then exports.TR_noti:create("Tüm şartları karşılamadığınız için bu işi alamıyorsunuz.", "error") return end
            if self.hasBlockedLicence then exports.TR_noti:create("Ehliyetinize el konulduğu için bu işte iş bulamazsınız.", "error") return end

        elseif string.find(self.req, "kat. C") then
            if not self.licences["c"] then exports.TR_noti:create("Tüm şartları karşılamadığınız için bu işi alamıyorsunuz.", "error") return end
            if self.hasBlockedLicence then exports.TR_noti:create("Ehliyetinize el konulduğu için bu işte iş bulamazsınız.", "error") return end

        elseif string.find(self.req, "Licencja lotnicza") then
            if not self.licences["fly"] then exports.TR_noti:create("Tüm şartları karşılamadığınız için bu işi alamıyorsunuz.", "error") return end
            if self.hasBlockedLicence then exports.TR_noti:create("Ehliyetinize el konulduğu için bu işte iş bulamazsınız.", "error") return end

        elseif string.find(self.req, "Licencja nurka") then
            if not self.licences["WATER"] then exports.TR_noti:create("Tüm şartları karşılamadığınız için bu işi alamıyorsunuz.", "error") return end

        end

        if string.find(self.req, "Deneyim:") then
            local text = string.match(self.req, "Deneyim: %d+")
            local pointsNeeded = tonumber(string.sub(text, 17, string.len(text)))
            local plrPoints = getElementData(localPlayer, "characterPoints") or 0

            if tonumber(plrPoints) < pointsNeeded then
                exports.TR_noti:create("Tüm şartları karşılamadığınız için bu işi alamıyorsunuz.", "error", 8)
                return
            end
        end
    end

    if not self.multipleWork then
        setElementData(localPlayer, "inJob", self.jobID)

        exports.TR_dx:setResponseEnabled(true)
        setPlayerJob(self.jobID, "casual", false)

        exports[self.jobID]:startJob(self.playerJobData.upgrades)
    else
        self:selectTab("selectRoom")
    end
end

function Jobs:endJob()
    exports.TR_dx:setResponseEnabled(true)
    exports.TR_jobs:setPlayerJob(nil, nil, nil)
    exports.TR_jobs:removeInformation()

    guiInfo.jobPaymentType = nil

    exports[self.jobID]:endJob()

    setElementData(localPlayer, "inJob", nil)
    triggerServerEvent("endJob", resourceRoot)
end

function Jobs:updateGroups(...)
    self.loadingGroupList = nil
    self.jobRooms = arg[1]
    self.selectedRoom = arg[2] or self.selectedRoom

    local plrName = getPlayerName(localPlayer)
    exports.TR_dx:setResponseEnabled(false)
    if self.selectedRoom then
        if self.jobRooms then
            for i, v in pairs(self.jobRooms) do
                if v.owner == self.selectedRoom then
                    for k, plr in pairs(v.players) do
                        if plr.name == plrName then
                            self.currentGroup = v
                            if self.selectedTab ~= "group" and self.selectedTab ~= "chat" then self:selectTab("group") end

                            if plrName == v.owner then
                                exports.TR_dx:setButtonText(self.buttons.setReady, "Başla")
                            else
                                if not plr.ready then
                                    exports.TR_dx:setButtonText(self.buttons.setReady, "Rapor hazır")
                                else
                                    exports.TR_dx:setButtonText(self.buttons.setReady, "Rapor hazır değil")
                                end
                            end
                            return
                        end
                    end
                end
            end
        end
        self:selectTab("selectRoom")
        exports.TR_noti:create("Dışarı atıldınız veya oda sahibi odadan çıktı.", "error")
    end
end

function Jobs:startMultipleWork(...)
    setPlayerJob(self.jobID, "casualMulti", false)

    exports[self.jobID]:startJob(self.playerJobData.upgrades, ...)
    self:close()
end

function Jobs:response(...)
    if arg[1] then
        exports.TR_dx:setResponseEnabled(false)
        return
    end

    if self.jobID == self.currentJob then
        exports.TR_noti:create("Çalışmanızı başarıyla tamamladınız.", "job")
    else
        guiInfo.jobPaymentType = self.selectedPayment
    end

    setTimer(function()
        exports.TR_dx:setResponseEnabled(false)
    end, 100, 1)

    self.currentJob = getPlayerJob()
    exports.TR_dx:setButtonText(self.buttons.startJob, self.jobID == self.currentJob and "İşini bitir" or "Başla")
end

function Jobs:responseUpgrade()
    self:selectTab("upgrade")
    exports.TR_dx:setResponseEnabled(false)
    exports.TR_noti:create("Yükseltme başarıyla satın alındı.", "success")
end

function Jobs:responsePrizes()
    self.playerPrizes = 0
    exports.TR_dx:setResponseEnabled(false)
    exports.TR_noti:create("Ödüller başarıyla ödendi.", "success")
end

function Jobs:getPedWeapons(ped)
	local playerWeapons = {}
	if ped and isElement(ped) and getElementType(ped) == "ped" or getElementType(ped) == "player" then
		for i=2,9 do
			local wep = getPedWeapon(ped,i)
			if wep and wep ~= 0 then
				table.insert(playerWeapons,wep)
			end
		end
	else
		return false
	end
	return playerWeapons
end

function Jobs:drawBackground(x, y, rx, ry, color, radius, post)
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

function Jobs:isMouseInPosition(x, y, width, height)
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

function Jobs:savePayment(payment)
    local xml = xmlLoadFile("payments.xml")
    if not xml then
        xml = xmlCreateFile("payments.xml", "payments")

        local node = xmlCreateChild(xml, "payment")
        xmlNodeSetValue(node, payment)

        xmlSaveFile(xml)
        xmlUnloadFile(xml)

        self.selectedPayment = payment
        return
    end

    local node = xmlNodeGetChildren(xml, 0)
    xmlNodeSetValue(node, payment)

    xmlSaveFile(xml)
    xmlUnloadFile(xml)

    self.selectedPayment = payment
end

function Jobs:loadPayment()
    local xml = xmlLoadFile("payments.xml", true)
    if not xml then
        self.selectedPayment = "cash"
        return
    end

    local node = xmlNodeGetChildren(xml, 0)
    if not node then
        self.selectedPayment = "cash"
        xmlUnloadFile(xml)
        return
    end

    local payment = xmlNodeGetValue(node)
    xmlUnloadFile(xml)

    if payment ~= "cash" and payment ~= "card" then
        self.selectedPayment = "cash"
    else
        if payment == "card" and self.bankCode then
            self.selectedPayment = "card"

        else
            self.selectedPayment = "cash"
        end
    end
end




function createJobWindow(jobID, playerJobData, playerLicenceBlocked)
    if guiInfo.job then return end
    if not exports.TR_dx:canOpenGUI() then return end

    guiInfo.job = Jobs:create(jobID, playerJobData, playerLicenceBlocked[1] and true or false)
end
addEvent("createJobWindow", true)
addEventHandler("createJobWindow", root, createJobWindow)

function closeJobWindow()
    if not guiInfo.job then return end
    guiInfo.job:close()
end
addEvent("closeJobWindow", true)
addEventHandler("closeJobWindow", root, closeJobWindow)

function responseJobWindow(...)
    if not guiInfo.job then return end
    guiInfo.job:response(...)
end
addEvent("responseJobWindow", true)
addEventHandler("responseJobWindow", root, responseJobWindow)

function responseJobPrizes(...)
    if not guiInfo.job then return end
    guiInfo.job:responsePrizes(...)
end
addEvent("responseJobPrizes", true)
addEventHandler("responseJobPrizes", root, responseJobPrizes)

function updatePlayerJobTabData(...)
    if not guiInfo.job then return end
    guiInfo.job:loadData(...)
end
addEvent("updatePlayerJobTabData", true)
addEventHandler("updatePlayerJobTabData", root, updatePlayerJobTabData)

function updateJobUpgrade(...)
    if not guiInfo.job then return end
    guiInfo.job:responseUpgrade()
end
addEvent("updateJobUpgrade", true)
addEventHandler("updateJobUpgrade", root, updateJobUpgrade)

function updateJobGroups(...)
    if not guiInfo.job then return end
    guiInfo.job:updateGroups(...)
end
addEvent("updateJobGroups", true)
addEventHandler("updateJobGroups", root, updateJobGroups)

function startMultipleWork(...)
    if not guiInfo.job then return end
    guiInfo.job:startMultipleWork(...)
end
addEvent("startMultipleWork", true)
addEventHandler("startMultipleWork", root, startMultipleWork)


function canStartJob()
    if guiInfo.jobID then return false end
    return true
end

function setPlayerTargetPos(x, y, z, int, dim, text)
    if not x then
        guiInfo.distancePos = nil
        guiInfo.distanceInt = nil
        guiInfo.distanceDim = nil
        guiInfo.distanceText = nil
        return
    end

    guiInfo.distancePos = Vector3(x, y, z)
    guiInfo.distanceInt = int
    guiInfo.distanceDim = dim
    guiInfo.distanceText = text
end

function getPlayerTargetPos()
    return guiInfo.distancePos, guiInfo.distanceInt, guiInfo.distanceDim, guiInfo.distanceText
end

function setPlayerJob(jobID, jobType, jobMoney, jobDistance)
    if not jobID then
        guiInfo.jobID = nil
        guiInfo.jobType = nil
        guiInfo.jobMoney = nil
        guiInfo.jobDistance = nil
        setPlayerTargetPos(nil, nil)

    else
        guiInfo.jobID = jobID
        guiInfo.jobType = jobType and jobType or jobID
        guiInfo.jobMoney = jobMoney and jobMoney or false
        guiInfo.jobDistance = jobDistance and jobDistance or false

        openLockerInfo()
    end
    return true
end

function getPlayerJob()
    return guiInfo.jobID, guiInfo.jobType, guiInfo.jobMoney
end

function getPlayerJobDistance()
    return guiInfo.jobDistance
end

function getPlayerJobPaymentType()
    return guiInfo.jobPaymentType or "cash"
end

function openLockerInfo()
    if guiInfo.jobType == "mechanic" then
        createInformation("Araba tamirhanesi", "Soyunma odasına gidin ve uygun iş kıyafetlerinizi giyin.")

    elseif guiInfo.jobType == "taxi" then
        createInformation("Taksi Şoförü", "İş kıyafetlerini giyin.")
    end
end

exports.TR_dx:setOpenGUI(false)
exports.TR_dx:setResponseEnabled(false)