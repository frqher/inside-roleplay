local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 450/zoom)/2,
    y = (sy - 200/zoom),
    w = 450/zoom,
    h = 180/zoom,

    waterY = (sy - 200/zoom) + 40/zoom,

    fishingTime = {},

    small = {
        x = (sx - 250/zoom)/2,
        y = (sy - 110/zoom),
        w = 250/zoom,
        h = 90/zoom,
    },

    speed = 1200,
    checkOffset = Vector3(0, 4, -10),

    catchTime = {
        ["Buğday"] = {20, 40},
        ["Mısır"] = {20, 40},
        ["Beyaz Solucanlar"] = {20, 40},
        ["Kırmızı Solucanlar"] = {20, 40},
        ["Canlı Balıklar"] = {40, 70},
    },

    catchFishes = {
        ["Mısır"] = {
            {"Sazan", 7, 9},
            {"Kara Balık", 6, 8},
            {"Kalkan", 8, 10},
            {"Levrek", 5, 9},
        },

        ["Buğday"] = {
            {"Alabalık", 8, 10},
            {"Orkinos", 8, 11},
            {"Kılıç Balığı", 7, 12},
            {"Mezgit", 8, 13},
        },

        ["Beyaz Solucanlar"] = {
            {"Japon Balığı", 8, 17},
            {"Kefal", 9, 15},
            {"Sazan", 9, 16},
            {"Levrek", 8, 15},
            {"Alabalık", 9, 16},
            {"Sazan", 9, 18},
        },
        ["Kırmızı Solucanlar"] = {
            {"Karpia", 10, 14},
            {"Miętusa", 10, 20},
            {"Bolenia", 9, 17},
            {"Somon", 10, 27},
            {"Turna", 10, 24},
            {"Sazan", 10, 19},
            {"Alabalık", 10, 21},
            {"Halibut", 15, 30},
            {"Dorade", 10, 19},
            {"Mezgit", 8, 20},
        },

        ["Canlı balıklar"] = {
            {"Karpia", 10, 30},
            {"Somon", 11, 50},
            {"Suma", 48, 108},
            {"Halibut", 30, 66},
            {"Ton balığı", 14, 60},
        },
    },
}

Fisherman = {}
Fisherman.__index = Fisherman

function Fisherman:create()
    local instance = {}
    setmetatable(instance, Fisherman)
    if instance:constructor() then
        return instance
    end
    return false
end

function Fisherman:constructor()
    self.hasFishRod = false
    self.clickTime = 0

    self.float = {
        move = "up",
        tick = getTickCount(),
        y = guiInfo.y + 50/zoom,
        h = 64,
        fishY = 0,
        tileX = 0,
    }

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.info = exports.TR_dx:getFont(11)

    self.textures = {}
    self.textures.sea = dxCreateTexture("files/images/sea.png", "argb", true, "wrap")
    self.textures.seaDeep = dxCreateTexture("files/images/sea_deep.png", "argb", true, "wrap")
    self.textures.float = dxCreateTexture("files/images/float.png", "argb", true, "clamp")

    self.func = {}
    self.func.render = function() self:render() end
    self.func.useRod = function() self:useRod() end
    self.func.getFish = function() self:getFish() end
    self.func.fishEscape = function() self:fishEscape() end
    self.func.checkWater = function() self:checkWater() end

    addEventHandler("onClientRender", root, self.func.render)
    return true
end

function Fisherman:addFishingTimeData()
    if not self.fishTick or not self.catchedFish then return end
    table.insert(guiInfo.fishingTime, 1, getTickCount() - self.fishTick)

    if #guiInfo.fishingTime > 5 then
        table.remove(guiInfo.fishingTime, #guiInfo.fishingTime)
        self:analyseTimeData()
    end
end

function Fisherman:analyseTimeData()
    local lastData = guiInfo.fishingTime[1]
    local diff = guiInfo.fishingTime[1]
    for i = 2, #guiInfo.fishingTime do
        local v = guiInfo.fishingTime[i]
        if lastData == v then
            lastData = v
            diff = diff + v

        elseif lastData < v and v - lastData < 50 then
            diff = diff + v
            lastData = v

        elseif lastData > v and lastData - v < 50 then
            diff = diff + v
            lastData = v
        else
            return
        end
    end
    guiInfo.fishingTime = {}
    triggerServerEvent("updateLogs", resourceRoot, string.format("[ADMIN_FISHING] Bir oyuncuda balık botu şüphesi tespit edildi [%d] %s. Ortalama tepki süresi %dms!", getElementData(localPlayer, "ID"), getPlayerName(localPlayer), diff/5))

    local time = getRealTime()
    triggerServerEvent("sendDiscordChannelMsg", resourceRoot, "onFishBot", {
        time = string.format("[%02d:%02d %02d.%02d]", time.hour, time.minute, time.monthday, time.month),
        author = getPlayerName(localPlayer),
        text = string.format("muhtemelen bir balıkçılık botuna sahiptir. Ortalama tepki süresi %dms.", diff/5),
    })
end

function Fisherman:open()
    if self.hasFishRod then return end
    self.hasFishRod = true

    bindKey("mouse1", "down", self.func.useRod)
end

function Fisherman:close()
    if not self.hasFishRod then return end
    self.hasFishRod = nil
    self:disableAnim()

    unbindKey("mouse1", "down", self.func.useRod)
end

function Fisherman:disableAnim()
    if not self.hasAnim then return end
    self.hasAnim = nil
    setPedAnimation(localPlayer, nil, nil)
    triggerServerEvent("syncAnim", resourceRoot, nil, nil)
end

function Fisherman:render()
    if isElementInWater(localPlayer) then self:disableAnim() return end
    if not self:checkRod() then self:disableAnim() return end
    if not self:checkWater() then
        self:drawBackground(guiInfo.small.x, guiInfo.small.y, guiInfo.small.w, guiInfo.small.h, tocolor(17, 17, 17, 255), 4)
        dxDrawText("Balık Tutma", guiInfo.small.x + 10/zoom, guiInfo.small.y + 10/zoom, guiInfo.small.x + guiInfo.small.w - 10/zoom, guiInfo.small.y + guiInfo.small.h - 10/zoom, tocolor(212, 175, 55, 255), 1/zoom, self.fonts.main, "center", "top", true, true)
        dxDrawText("Balık tutmaya başlamak için suya gitmelisiniz.", guiInfo.small.x + 10/zoom, guiInfo.small.y, guiInfo.small.x + guiInfo.small.w - 10/zoom, guiInfo.small.y + guiInfo.small.h - 10/zoom, tocolor(170, 170, 170, 255), 1/zoom, self.fonts.info, "center", "bottom", true, true)
        self:disableAnim()
        return
    end

    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255), 4)
    dxDrawText("Balık Tutma", guiInfo.x + 10/zoom, guiInfo.y + 10/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h - 10/zoom, tocolor(212, 175, 55, 255), 1/zoom, self.fonts.main, "center", "top", true, true)
    dxDrawText("Balık, çekirgeyi çektiğinde yem suyun altına inecek. Onu çıkarmak için uygun zamanda LPM'ye basın.", guiInfo.x + 10/zoom, guiInfo.y, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h - 10/zoom, tocolor(170, 170, 170, 255), 1/zoom, self.fonts.info, "center", "bottom", true, true)

    self:renderWater(guiInfo.x + (guiInfo.w - 64/zoom)/2 + 128/zoom)
    self:renderWater(guiInfo.x + (guiInfo.w - 64/zoom)/2 + 64/zoom)
    self:renderWater(guiInfo.x + (guiInfo.w - 64/zoom)/2, true)
    self:renderWater(guiInfo.x + (guiInfo.w - 64/zoom)/2 - 64/zoom)
    self:renderWater(guiInfo.x + (guiInfo.w - 64/zoom)/2 - 128/zoom)

    dxDrawText(string.format("Przynęta: %s", self.bait and self.bait or "Brak"), guiInfo.x + 10/zoom, guiInfo.y, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h - 55/zoom, tocolor(220, 220, 220, 255), 1/zoom, self.fonts.info, "center", "bottom", true, true)


    if self.fishTick then
        if self.catchedFish then
            local progress = (getTickCount() - self.fishTick)/self.toTakeFish
            if progress >= 1 then
                self:fishEscape()
            end

        else
            local progress = (getTickCount() - self.fishTick)/self.toTakeFish
            if progress >= 1 then
                self:getFish()
            end
        end
    end
end

function Fisherman:renderFloat()
    if self.float.move == "up" then
        local progress = (getTickCount() - self.float.tick)/guiInfo.speed

        self.float.y, self.float.tileX = interpolateBetween(guiInfo.waterY, 0, 0, guiInfo.waterY - 4/zoom, 64/8, 0, progress, "Linear")
        if progress >= 1 then
            self.float.move = "down"
            self.float.tick = getTickCount()
        end

    elseif self.float.move == "down" then
        local progress = (getTickCount() - self.float.tick)/guiInfo.speed

        self.float.y, self.float.tileX = interpolateBetween(guiInfo.waterY - 4/zoom, 64/8, 0, guiInfo.waterY, 64/4, 0, progress, "Linear")
        if progress >= 1 then
            self.float.move = "up"
            self.float.tick = getTickCount()
        end
    end

    if self.isFishing then
        self.float.h = math.max(self.float.h - 4, 0)
    else
        self.float.h = math.min(self.float.h + 4, 64)
    end

    if not self.catchedFish then
        self.float.fishY = math.max(self.float.fishY - 2, 0)
    else
        self.float.fishY = math.min(self.float.fishY + 2, 10)
    end

    dxDrawImageSection(guiInfo.x + (guiInfo.w - 64/zoom)/2, self.float.y + self.float.fishY, 64/zoom, 64/zoom, 0, self.float.h, 64, 64, self.textures.float, 0, 0, 0, tocolor(220, 220, 220, 255))
end

function Fisherman:renderWater(x, float)
    dxDrawImageSection(x, guiInfo.y + 50/zoom, 64/zoom, 64/zoom, self.float.tileX, 0, 64, 64, self.textures.sea, 0, 0, 0, tocolor(220, 220, 220, 255))
    if float then
        self:renderFloat()
        dxDrawImageSection(x, guiInfo.y + 50/zoom, 64/zoom, 64/zoom, self.float.tileX, 0, 64, 64, self.textures.seaDeep, 0, 0, 0, tocolor(220, 220, 220, 255))
    end
end




function Fisherman:checkRod()
    local weapon = getPedWeapon(localPlayer)
    if weapon == 7 then
        self:open()
        return true
    else
        self:close()
        return false
    end
end




function Fisherman:drawBackground(x, y, rx, ry, color, radius, post)
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


function Fisherman:checkWater()
    local plrPos = Vector3(getElementPosition(localPlayer))
    local pos = self:getPositionFromElementOffset(localPlayer, guiInfo.checkOffset.x, guiInfo.checkOffset.y, 0)
    local inWater = testLineAgainstWater(pos, pos.x, pos.y, pos.z + guiInfo.checkOffset.z)

    if inWater then
        local process = processLineOfSight(pos, pos.x, pos.y, pos.z + guiInfo.checkOffset.z, true, true, false, true, true, false, false, false, self.checker)
        return not process
    end
    return false
end


function Fisherman:useRod(...)
    if not exports.TR_dx:canOpenGUI() then return end
    local job = exports.TR_jobs:getPlayerJob()

    if job then
        exports.TR_noti:create("Başka bir iş yaparken balık tutamazsınız.", "error")
        return
    end

    if (getTickCount() - self.clickTime)/2000 < 1 then return end

    if self:checkWater() and not self.isFishing and not isElementInWater(localPlayer) and getPedMoveState(localPlayer) == "stand" then
        if not self.bait then exports.TR_noti:create("Yem olmadan balık tutamazsınız.", "error") return end
        local time = guiInfo.catchTime[self.bait]
        self.isFishing = true

        self.fishTick = getTickCount()
        self.toTakeFish = math.random(time and time[1] or 50, time and time[2] or 60) * 1000

        self.hasAnim = true
        setPedAnimation(localPlayer, "SWORD", "sword_block", -1, false, false, true,true)
        triggerServerEvent("syncAnim", resourceRoot, "SWORD", "sword_block", -1, true)
        self:setControl(false)
        self.clickTime = getTickCount()

    elseif self.isFishing then
        self:pullRod()
        self.clickTime = getTickCount()
    end
end

function Fisherman:pullRod()
    self:addFishingTimeData()

    self.fishTick = nil
    self.toTakeFish = nil

    if self.catchedFish then
        local fishes = guiInfo.catchFishes[self.bait]
        local fish = fishes[math.random(1, #fishes)]

        if self.bait == "Canlı balıklar" then
            local rand = math.random(1, 1000)
            if rand <= 25 then
                fish = {"Köpekbalığı", 300, 550}
                exports.TR_achievements:addAchievements("fishingShark")

            elseif rand <= 26 then
                fish = {"Güneş Balığı", 400, 1200}
                exports.TR_achievements:addAchievements("fishingSunfish")
            end
        end

        local mass = math.floor(math.random(fish[2] * 100, fish[3] * 100))/100
        mass = guiInfo.isOnOcean and (mass * 1.1) or mass
        mass = tonumber(string.format("%.2f", mass))

        exports.TR_noti:create(string.format("Yakaladığın balık: %s, ağırlığı: %.2fkg.", fish[1], mass), "success")
        exports.TR_items:updateRodMass(mass)

        local hasBait, blockMsg = exports.TR_items:updateFishBait(self.baitItem)
        if not hasBait then
            self.bait = nil
            if not blockMsg then exports.TR_noti:create("Yem paketinde bitti.", "error") end
        end
        triggerServerEvent("catchFish", resourceRoot, mass)
    end

    self.hasAnim = nil
    setPedAnimation(localPlayer, nil, nil)
    triggerServerEvent("syncAnim", resourceRoot, nil, nil)
    self.isFishing = false
    self.catchedFish = false

    self:setControl(true)
end

function Fisherman:fishEscape()
    setPedAnimation(localPlayer, nil, nil)
    triggerServerEvent("syncAnim", resourceRoot, nil, nil)
    self.hasAnim = nil

    if not exports.TR_items:updateFishBait(self.baitItem) then
        self.bait = nil
        exports.TR_noti:create("Yem paketinde bitti.", "error")
    end

    self.catchedFish = false
    self.fishTick = nil
    self.toTakeFish = nil
    exports.TR_noti:create("Balık yemi yedi ve oltadan kaçtı.", "error")
end

function Fisherman:getFish()
    self.catchedFish = true

    self.fishTick = getTickCount()
    self.toTakeFish = math.random(2, 5) * 1000
end

function Fisherman:setControl(state)
    toggleControl("next_weapon", state)
    toggleControl("previous_weapon", state)
    toggleControl("forwards", state)
    toggleControl("backwards", state)
    toggleControl("left", state)
    toggleControl("right", state)
end

function Fisherman:setBait(bait, item)
    self.bait = bait
    self.baitItem = item
    if bait then exports.TR_noti:create("Yem takıldı.", "success") end
end

function Fisherman:canChangeBait()
    if self.bait or self.isFishing then return false end
    return true
end

function Fisherman:isPlayerFishing()
    return self.isFishing
end

function Fisherman:getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix(element)
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return Vector3(x, y, z)
end



guiInfo.fishing = Fisherman:create()

function setFishBait(...)
    guiInfo.fishing:setBait(...)
end

function canChangeBait()
    return guiInfo.fishing:canChangeBait()
end

function isPlayerFishing()
    return guiInfo.fishing:isPlayerFishing()
end

local ocean = 3500
function checkWater()
    local pos = Vector3(getElementPosition(localPlayer))

    if pos.x < -ocean or pos.x > ocean or pos.y > ocean or pos.y < -ocean then
        if guiInfo.isOnOcean then return end
        guiInfo.isOnOcean = exports.TR_noti:create("Derin okyanustasınız. Yakalanan balıklar daha büyük olacak.", "boat", 0, true)
        exports.TR_hud:setRadarCustomLocation("Derin okyanus")

    else
        if not guiInfo.isOnOcean then return end

        guiInfo.isOnOcean = exports.TR_noti:destroy(guiInfo.isOnOcean)
        guiInfo.isOnOcean = nil

        exports.TR_hud:setRadarCustomLocation(false)
    end
end
setTimer(checkWater, 1000, 0)