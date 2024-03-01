local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    markers = {
        Vector3(-962.6943359375, 2414.2041015625, -37.433536529541),
        Vector3(-982.958984375, 2434.3955078125, -40.764446258545),
        Vector3(-975.1318359375, 2453.017578125, -46.921875),
        Vector3(-946.951171875, 2440.46484375, -43.529552459717),
        Vector3(-941.0009765625, 2465.5830078125, -37.959449768066),
        Vector3(-947.1162109375, 2487.84765625, -45.90049743652),
        Vector3(-970.3125, 2503.1142578125, -46.92187),
        Vector3(-1004.43359375, 2548.986328125, -42.99965286254),
        Vector3(-973.9697265625, 2549.7080078125, -46.921875),
        Vector3(-962.7841796875, 2520.4189453125, -46.921875),
        Vector3(-988.0517578125, 2436.083984375, -39.825580596924),
        Vector3(-1004.142578125, 2439.82421875, -32.346206665039),
        Vector3(-1002.4521484375, 2469.34375, -44.490833282471),
        Vector3(-1013.9140625, 2497.33984375, -36.347938537598),
        Vector3(-1019.09375, 2466.154296875, -31.905586242676),
        Vector3(-976.1904296875, 2416.7890625, -30.262172698975),
        Vector3(-957.1962890625, 2429.9521484375, -46.92187),
        Vector3(-924.9541015625, 2489.701171875, -37.790214538574),
        Vector3(-922.6572265625, 2511.0029296875, -38.683570861816),
        Vector3(-943.7841796875, 2525.2021484375, -44.909236907959),
        Vector3(-944.3525390625, 2559.595703125, -45.084903717041),
        Vector3(-978.4482421875, 2573.5068359375, -46.921875),
        Vector3(-976.541015625, 2608.40234375, -46.92187),
        Vector3(-956.6611328125, 2605.1611328125, -46.921875),
        Vector3(-955.7333984375, 2583.9736328125, -46.921875),
        Vector3(-935.2529296875, 2613.66796875, -37.8780136108),
        Vector3(-939.41796875, 2592.171875, -40.39233779907),
        Vector3(-925.421875, 2579.41015625, -35.904209136963),
        Vector3(-910.759765625, 2554.99609375, -35.165069580078),
        Vector3(-928.2548828125, 2542.45703125, -40.327236175537),
        Vector3(-901.2958984375, 2529.4462890625, -32.372509002686),
        Vector3(-896.533203125, 2572.427734375, -28.055404663086),
        Vector3(-903.044921875, 2612.810546875, -20.521774291992),
        Vector3(-919.7763671875, 2604.205078125, -29.552984237671),
        Vector3(-941.2802734375, 2639.0947265625, -30.49095726013),
        Vector3(-977.8505859375, 2651.1103515625, -22.730018615723),
        Vector3(-993.0869140625, 2630.494140625, -39.480018615723),
        Vector3(-1001.42578125, 2597.810546875, -46.492950439453),
        Vector3(-1030.416015625, 2617.3779296875, -45.73563385009),
        Vector3(-1021.27734375, 2640.265625, -32.872493743896),
        Vector3(-1062.712890625, 2633.1669921875, -33.288848876953),
        Vector3(-1102.8154296875, 2621.232421875, -28.028755187988),
        Vector3(-1054.9736328125, 2621.208984375, -45.07063293457),
        Vector3(-1044.2333984375, 2596.9501953125, -39.656753540039),
        Vector3(-1027.1416015625, 2572.830078125, -38.849090576172),
        Vector3(-1026.0830078125, 2550.267578125, -26.868783950806),
        Vector3(-1056.09375, 2562.767578125, -19.281608581543),
        Vector3(-994.34375, 2528.2705078125, -46.921875),
        Vector3(-1012.0205078125, 2524.296875, -36.276466369629),
        Vector3(-994.8828125, 2497.630859375, -46.921875),
        Vector3(-960.3671875, 2389.6484375, -38.92993927002),
        Vector3(-973.6806640625, 2365.6279296875, -27.929643630981),
        Vector3(-978.5224609375, 2387.5908203125, -24.116495132446),
        Vector3(-989.826171875, 2399.7080078125, -17.394166946411),
        Vector3(-948.5927734375, 2419.5439453125, -44.424510955811),
        Vector3(-930.1875, 2442.6806640625, -26.792621612549),
        Vector3(-922.158203125, 2472.8154296875, -20.31983757019),
        Vector3(-941.2431640625, 2405.0478515625, -35.186592102051),
        Vector3(-928.015625, 2400.474609375, -19.282611846924),
        Vector3(-936.416015625, 2377.078125, -34.439979553223),
        Vector3(-934.7919921875, 2358.267578125, -28.543378829956),
        Vector3(-951.1298828125, 2372.5126953125, -45.478801727295),
        Vector3(-971.173828125, 2376.1328125, -30.112590789795),
    },

    fontsSizes = {},

    hud = {
        x = 255/zoom,
        y = (sy - 100/zoom)/2 + 40/zoom,
        w = 42/zoom,
        h = 42/zoom
    },

    hourEarning = {4600, 4700},
    maxEarning = 2400,
}

Diver = {}
Diver.__index = Diver

function Diver:create(...)
    local instance = {}
    setmetatable(instance, Diver)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function Diver:constructor(...)
    self.move = 0
    self.blips = {}
    self.markers = {}
    self.ownedUpgrades = arg[1] or {}

    self.maxCapacity = self.ownedUpgrades[1] and 75 or 50
    self.capacity = 0

    self.maxOxygen = self.ownedUpgrades[2] and 25 or 10
    self.oxygen = self.maxOxygen


    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(13, "opensansRegular")
    self.fonts.bold = exports.TR_dx:getFont(13, "opensansSemi")

    self.textures = {}
    self.textures.oxygen = dxCreateTexture("files/images/oxygen.png", "argb", true, "clamp")
    self.textures.box = dxCreateTexture("files/images/box.png", "argb", true, "clamp")

    guiInfo.fontsSizes.oxygen = dxGetTextWidth("Oksijen:", 1/zoom, self.fonts.main)
    guiInfo.fontsSizes.capacity = dxGetTextWidth("Kapasite:", 1/zoom, self.fonts.main)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.enterTargetMarker = function(...) self:enterTargetMarker(...) end
    self.func.enterOxygenMarker = function(...) self:enterOxygenMarker(...) end
    self.func.enterCapacityMarker = function(...) self:enterCapacityMarker(...) end

    exports.TR_noti:create("Dalış işine başladınız.", "iş")
    exports.TR_jobs:createInformation(jobSettings.name, "Batık eşyaları aramak için dalın. En az 25kg toplarsanız, bunları kaptana geri dönüp teslim edebilirsiniz.")
    self:createMarkers()

    exports.TR_jobs:resetPaymentTime()
    exports.TR_jobs:setPaymentTime()

    triggerServerEvent("startDivingJob", resourceRoot)
    addEventHandler("onClientRender", root, self.func.render)
    return true
end

function Diver:destroy()
    exports.TR_jobs:resetPaymentTime()
    self:removeMarkers()

    exports.TR_jobs:setPlayerTargetPos(false)

    removeEventHandler("onClientRender", root, self.func.render)

    guiInfo.work = nil
    self = nil
end

function Diver:removeMarkers()
    if isElement(self.oxygenRefill) then destroyElement(self.oxygenRefill) end
    if isElement(self.takoutTrash) then destroyElement(self.takoutTrash) end
    if isElement(self.targetObject) then destroyElement(self.targetObject) end
    if isElement(self.targetBlip) then destroyElement(self.targetBlip) end
    if isElement(self.targetCol) then destroyElement(self.targetCol) end

    for i, v in pairs(self.markers) do
        if isElement(v) then destroyElement(v) end
    end
    for i, v in pairs(self.blips) do
        if isElement(v) then destroyElement(v) end
    end

    self.markers = {}
    self.blips = {}
end

function Diver:enterOxygenMarker(el, md)
    if not el or not md or el ~= localPlayer then return end
    if self.maxOxygen == self.oxygen then return end

    self.oxygen = self.maxOxygen

    setElementFrozen(localPlayer, true)
    setElementData(localPlayer, "animation", {"BOMBER", "BOM_Plant"})
    exports.TR_jobs:createInformation(jobSettings.name, "Solunum tüpünü doldurma işlemi devam ediyor...")

    setTimer(function()
        setElementFrozen(localPlayer, false)
        setElementData(localPlayer, "animation", nil)

        if self.capacity == self.maxCapacity then
            exports.TR_jobs:createInformation(jobSettings.name, "Daha fazlasını taşıyamazsınız. Eşyaları bırakmak için üsse geri dönün.")
            exports.TR_jobs:setPlayerTargetPos(-913.8994140625, 2686.330078125, 41.3702621459966, 0, 0, "Eşyaları bırak")
        else
            exports.TR_jobs:createInformation(jobSettings.name, "Batık eşyaları aramak için dalın. En az 25kg toplarsanız, bunları kaptana geri dönüp teslim edebilirsiniz.")
        end

        exports.TR_noti:create("Oksijen seviyesi dolduruldu.", "success")
    end, 5000, 1)
end

function Diver:enterCapacityMarker(el, md)
    if not el or not md or el ~= localPlayer then return end
    if self.capacity < 25 then exports.TR_noti:create("Ödül alabilmek için en az 25kg getirmeniz gerekmektedir.", "info") return end
    self.capacity = 0

    setElementData(localPlayer, "animation", {"BOMBER", "BOM_Plant"})
    exports.TR_jobs:createInformation(jobSettings.name, "Toplanan malzemelerin boşaltılması devam ediyor...")

    setTimer(function()
        setElementFrozen(localPlayer, false)
        setElementData(localPlayer, "animation", nil)

        self:payForJob()
        exports.TR_jobs:setPaymentTime()
        exports.TR_jobs:createInformation(jobSettings.name, "Batık eşyaları aramak için dalın. En az 25kg toplarsanız, bunları kaptana geri dönüp teslim edebilirsiniz.")

        self:createPoint()
    end, 5000, 1)
end

function Diver:enterTargetMarker(el, md)
    if not el or not md or el ~= localPlayer then return end

    if isElement(self.targetObject) then destroyElement(self.targetObject) end
    if isElement(self.targetBlip) then destroyElement(self.targetBlip) end
    if isElement(self.targetCol) then destroyElement(self.targetCol) end

    local pointRand = math.random(0, 100000)
    if pointRand == 1 then
        triggerServerEvent("giveDivingJobItem", resourceRoot, "clothes")
        exports.TR_noti:create("İçinde eski kıyafetler buldun.", "success")
        self:createPoint()

    elseif pointRand <= 5 then
        triggerServerEvent("giveDivingJobItem", resourceRoot, "gold")
        exports.TR_noti:create("İçinde altın torbası buldun.", "success")
        self:createPoint()

    elseif pointRand <= 50 then
        triggerServerEvent("giveDivingJobItem", resourceRoot, "silver")
        exports.TR_noti:create("İçinde gümüş kasa buldun.", "success")
        self:createPoint()

    else
        local randKgs
        if self.ownedUpgrades[3] then
            randKgs = math.random(300, 900)/100
        else
            randKgs = math.random(50, 600)/100
        end

        local kgs = math.min(randKgs, self.maxCapacity - self.capacity)

        self.capacity = self.capacity + kgs
        exports.TR_noti:create(string.format("Ağırlığı %.2fkg olan bir sandık çıkardın.", kgs), "success")

        if self.capacity == self.maxCapacity then
            exports.TR_jobs:createInformation(jobSettings.name, "Daha fazlasını taşıyamazsınız. Eşyaları bırakmak için üsse geri dönün.")
            exports.TR_jobs:setPlayerTargetPos(-913.8994140625, 2686.330078125, 41.3702621459966, 0, 0, "Eşyaları bırak")
        else
            self:createPoint()
        end
    end

    triggerServerEvent("givePlayerJobPoints", resourceRoot, getResourceName(getThisResource()), 1, "puan")
end

function Diver:createMarkers()
    self.oxygenRefill = createMarker(-898.8828125, 2686.923828125, 41.3702621459966, "cylinder", 1.2, 255, 60, 60, 0)
    setElementData(self.oxygenRefill, "markerIcon", "diving", false)
    setElementData(self.oxygenRefill, "markerData", {
        title = "Tüp doldurma noktası",
        desc = "Tüpü doldurmak için işaretçiye girin.",
    }, false)
    addEventHandler("onClientMarkerHit", self.oxygenRefill, self.func.enterOxygenMarker)

    self.takoutTrash = createMarker(-913.8994140625, 2686.330078125, 41.3702621459966, "cylinder", 1.2, 255, 60, 60, 0)
    setElementData(self.takoutTrash, "markerIcon", "magazineBox", false)
    setElementData(self.takoutTrash, "markerData", {
        title = "Hazine bırakma noktası",
        desc = "Topladığınız eşyaları bırakmak için işaretçiye girin.",
    }, false)
    addEventHandler("onClientMarkerHit", self.takoutTrash, self.func.enterCapacityMarker)

    self:createPoint()
end
function Diver:createPoint()
    if isElement(self.targetObject) then return end
    local random = math.random(1, #guiInfo.markers)
    local randPos = guiInfo.markers[random]

    while random == self.lastRandom do
        random = math.random(1, #guiInfo.markers)
        randPos = guiInfo.markers[random]
    end
    self.lastRandom = random

    self.targetObject = createObject(1271, randPos - Vector3(0, 0, 0.6))
    self.targetBlip = createBlip(randPos, 0, 1, 255, 60, 60, 255)
    setElementData(self.targetBlip, "icon", 22)

    self.targetCol = createColSphere(randPos - Vector3(0, 0, 0.6), 4)

    addEventHandler("onClientColShapeHit", self.targetCol, self.func.enterTargetMarker)

    exports.TR_jobs:setPlayerTargetPos(randPos.x, randPos.y, randPos.z, 0, 0, "Kutuyu Topla")
end

-- Payment
function Diver:payForJob()
    local payment = self:calculatePayment()
    local paymentType = exports.TR_jobs:getPlayerJobPaymentType()

    exports.TR_jobPayments:giveJobPayment(payment, paymentType)
end

function Diver:calculatePayment()
    local addMin, addMax = 0, 0
    for i, v in pairs(jobSettings.upgrades) do
        if self.ownedUpgrades[i] and v.additionalMoney then
            addMin = addMin + v.additionalMoney[1]
            addMax = addMax + v.additionalMoney[2]
        end
    end
    return math.min(exports.TR_jobs:getPaymentCount(guiInfo.hourEarning[1] + addMin, guiInfo.hourEarning[2] + addMax), guiInfo.maxEarning + (addMin + addMax)/2)
end

function Diver:render()
    if not isElementInWater(localPlayer) then
        if self.tickOxygen then
            self.lastOxygen = nil
            self.tickOxygen = nil

            setGameSpeed(1)
        end
        return
    end
    if not self.lastOxygen then
        self.lastOxygen = self.oxygen
        self.tickOxygen = getTickCount()

        if self.ownedUpgrades[4] then
            setGameSpeed(1.25)
        end
    end

    dxDrawImage(guiInfo.hud.x, guiInfo.hud.y, guiInfo.hud.w, guiInfo.hud.h, self.textures.oxygen, 0, 0, 0, tocolor(255, 255, 255, 255))
    dxDrawImage(guiInfo.hud.x, guiInfo.hud.y + guiInfo.hud.h, guiInfo.hud.w, guiInfo.hud.h, self.textures.box, 0, 0, 0, tocolor(255, 255, 255, 255))

    dxDrawText("Oxygen:", guiInfo.hud.x + guiInfo.hud.w + 10/zoom, guiInfo.hud.y, guiInfo.hud.x + guiInfo.hud.w + 10/zoom, guiInfo.hud.y + guiInfo.hud.h, tocolor(255, 255, 255, 255), 1/zoom, self.fonts.main, "left", "center", false, false, false, true)
    dxDrawText(string.format("%.2f / %dl", self.oxygen, self.maxOxygen), guiInfo.hud.x + guiInfo.hud.w + 15/zoom + guiInfo.fontsSizes.oxygen, guiInfo.hud.y, guiInfo.hud.x + guiInfo.hud.w + 10/zoom, guiInfo.hud.y + guiInfo.hud.h, tocolor(87, 191, 238, 255), 1/zoom, self.fonts.bold, "left", "center")

    dxDrawText("Capacity:", guiInfo.hud.x + guiInfo.hud.w + 10/zoom, guiInfo.hud.y + guiInfo.hud.h, guiInfo.hud.x + guiInfo.hud.w + 10/zoom, guiInfo.hud.y + guiInfo.hud.h * 2, tocolor(255, 255, 255, 255), 1/zoom, self.fonts.main, "left", "center", false, false, false, true)
    dxDrawText(string.format("%.2f / %dkg", self.capacity, self.maxCapacity), guiInfo.hud.x + guiInfo.hud.w + 15/zoom + guiInfo.fontsSizes.capacity, guiInfo.hud.y + guiInfo.hud.h, guiInfo.hud.x + guiInfo.hud.w + 10/zoom, guiInfo.hud.y + guiInfo.hud.h * 2, tocolor(218, 129, 55, 255), 1/zoom, self.fonts.bold, "left", "center")

    local plrPos = Vector3(getElementPosition(localPlayer))
    if plrPos.z < 40 then
        if self.oxygen <= 0 then
            self.oxygen = 0
            self.capacity = 0

            setElementPosition(localPlayer, -939.740234375, 2697.6962890625, 41.685317993164)
            exports.TR_noti:create("Oksijen tüpünde tükenmiş. Göl seni kıyıya güvenle attı, ancak tüm kazançlı eşyalarını kaybettin.", "info", 10)

            exports.TR_jobs:createInformation(jobSettings.name, "İşe geri dönebilmek için oksijen tüpünü doldurun.")
            exports.TR_jobs:setPlayerTargetPos(-898.8828125, 2686.923828125, 41.3702621459966, 0, 0, "Oksijen tüpünü doldur")
            exports.TR_jobs:resetPaymentTime()
            exports.TR_jobs:setPaymentTime()

            setElementData(localPlayer, "animation", {"Crack", "crckidle2"})
            getElementData(localPlayer, "blockAnim", true)
            setTimer(function()
                setElementData(localPlayer, "animation", nil)
                getElementData(localPlayer, "blockAnim", nil)
            end, 5000, 1)
        else
            local progress = (getTickCount() - self.tickOxygen)/(self.lastOxygen/self.maxOxygen * (self.ownedUpgrades[2] and 25 or 10) * 60000)
            self.oxygen = interpolateBetween(self.lastOxygen, 0, 0, 0, 0, 0, progress, "Linear")

            local maxOxygen = math.floor(1000 + getPedStat(localPlayer, 22) * 1.5 + getPedStat(localPlayer, 225) * 1.5)
            setPedOxygenLevel(localPlayer, maxOxygen)
        end
    else
        self.lastOxygen = self.oxygen
        self.tickOxygen = getTickCount()
    end
end

function startJob(...)
    if guiInfo.work then return end
    guiInfo.work = Diver:create(...)

    exports.TR_jobs:responseJobWindow()
end

function endJob()
    exports.TR_jobs:responseJobWindow()

    if not guiInfo.work then return end
    guiInfo.work:destroy()
end


-- startJob({})
-- triggerServerEvent("removeAttachedObject", resourceRoot, 917)