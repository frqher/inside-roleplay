local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    vehicleSpawns = {
        Vector3(-1805.41, 953.34, 24.48),
        Vector3(-1805.41, 955.34, 24.48),
        Vector3(-1805.41, 957.34, 24.48),
        Vector3(-1805.41, 959.34, 24.48),
        Vector3(-1805.41, 961.34, 24.48),
        Vector3(-1805.41, 963.34, 24.48),
        Vector3(-1805.41, 965.34, 24.48),
        Vector3(-1805.41, 967.34, 24.48),
        Vector3(-1805.41, 969.34, 24.48),
        Vector3(-1805.41, 971.34, 24.48),
        Vector3(-1805.41, 973.34, 24.48),
        Vector3(-1805.41, 975.34, 24.48),
        Vector3(-1805.41, 977.34, 24.48),
        Vector3(-1805.41, 979.34, 24.48),
        Vector3(-1805.41, 981.34, 24.48),
        Vector3(-1805.41, 983.34, 24.48),
        Vector3(-1805.41, 985.34, 24.48),
        Vector3(-1805.41, 987.34, 24.48),
        Vector3(-1805.41, 989.34, 24.48),
        Vector3(-1805.41, 991.34, 24.48),
        Vector3(-1805.41, 993.34, 24.48),
        Vector3(-1805.41, 995.34, 24.48),
        Vector3(-1805.41, 997.34, 24.48),
        Vector3(-1805.41, 999.34, 24.48),
    },

    hourEarning = {3500, 3550},
    maxEarning = 50,
}

local cardInfo = {
    size = Vector2(220/zoom, 220/zoom),
    offsetX = 40/zoom,
    offsetY = 30/zoom,
}

local points = {
    Vector3(-2538.3134765625, 830.109375, 49.98437),
    Vector3(-2540.6162109375, 832.3388671875, 52.09375),
    Vector3(-2556.0205078125, 896.6396484375, 64.984375),
    Vector3(-2583.7802734375, 896.5751953125, 64.984375),
    Vector3(-2580.931640625, 919.9091796875, 64.984375),
    Vector3(-2551.83203125, 920.0654296875, 64.984375),
    Vector3(-2541.6240234375, 987.8154296875, 78.2890625),
    Vector3(-2542.396484375, 942.7783203125, 64),
    Vector3(-2471.849609375, 921.0419921875, 63.162635803223),
    Vector3(-2431.345703125, 895.5732421875, 50.513565063477),
    Vector3(-2402.2841796875, 930.5830078125, 45.445312),
    Vector3(-2620.5283203125, 855.140625, 53.568695068359),
    Vector3(-2592.8125, 833.365234375, 52.0937),
    Vector3(-2618.318359375, 830.9892578125, 49.984375),
    Vector3(-2645.58984375, 803.2646484375, 49.9765625),
    Vector3(-2670.5205078125, 803.43359375, 49.9765625),
    Vector3(-2709.732421875, 803.1044921875, 49.9765625),
    Vector3(-2737.3291015625, 822.5986328125, 53.632900238037),
    Vector3(-2738.58203125, 771.6484375, 54.3828125),
    Vector3(-2731.470703125, 723.2412109375, 41.2734375),
    Vector3(-2678.21875, 721.703125, 28.669284820557),
    Vector3(-2625.1298828125, 733.142578125, 28.05667877197),
    Vector3(-2594.720703125, 750.86328125, 33.705749511719),
    Vector3(-2594.529296875, 785.2470703125, 46.22819519043),
    Vector3(-2569.162109375, 794.611328125, 49.482460021973),
    Vector3(-2541.0869140625, 750.9638671875, 33.710014343262),
    Vector3(-2369.390625, 740.6962890625, 35.115478515625),
    Vector3(-2369.171875, 763.521484375, 35.129341125488),
    Vector3(-2321.78515625, 797.08203125, 45.324676513672),
    Vector3(-2286.552734375, 796.875, 49.4453125),
    Vector3(-2282.25390625, 873.2001953125, 66.90422058105),
    Vector3(-2282.150390625, 916.6953125, 66.6484375),
    Vector3(-2282.1513671875, 1023.1337890625, 84.089950561523),
    Vector3(-2282.24609375, 1070.3525390625, 81.688186645508),
    Vector3(-2227.9521484375, 1107.74609375, 80.0078125),
    Vector3(-2188.0908203125, 1107.7236328125, 80.0078125),
    Vector3(-2173.0224609375, 1080.3818359375, 80.0078125),
    Vector3(-2139.9169921875, 1189.82421875, 55.7265625),
    Vector3(-2205.830078125, 1164.06640625, 55.7265625),
    Vector3(-2382.7060546875, 1226.3828125, 33.063850402832),
    Vector3(-2382.529296875, 1263.068359375, 26.337690353394),
    Vector3(-2382.6337890625, 1318.0751953125, 16.21750450134),
    Vector3(-2351.3916015625, 1336.3359375, 12.77414894104),
    Vector3(-2553.66796875, 992.6015625, 78.2734375),
    Vector3(-2573.611328125, 992.6611328125, 78.273437),
    Vector3(-2513.5712890625, 849.0947265625, 52.6953125),
    Vector3(-2239.1943359375, 962.216796875, 66.652183532715),
    Vector3(-2174.2509765625, 933.8818359375, 80),
    Vector3(-2174.345703125, 902.8271484375, 80.0078125),
    Vector3(-2129.8193359375, 894.9384765625, 80),
    Vector3(-2094.2568359375, 822.7021484375, 69.562),
    Vector3(-2048.2392578125, 796.453125, 57.005737304688),
    Vector3(-2018.1650390625, 832.0302734375, 45.4453125),
    Vector3(-2017.966796875, 865.7822265625, 45.4453125),
    Vector3(-2018.1943359375, 970.1171875, 45.4453125),
    Vector3(-2017.9296875, 1016.9140625, 53.908557891846),
    Vector3(-1872.6083984375, 1125.330078125, 45.4453125),
    Vector3(-1872.2705078125, 1146.6884765625, 45.445312),
    Vector3(-1915.435546875, 1190.18359375, 45.4453125),
    Vector3(-1955.59765625, 1190.1015625, 45.4453125),
    Vector3(-1997.4755859375, 1189.7734375, 45.4453125),
    Vector3(-2054.248046875, 1194.1591796875, 45.457389831543),
    Vector3(-2084.21484375, 1160.1904296875, 49.953125),
    Vector3(-1742.75390625, 1174.419921875, 25.125),
    Vector3(-1761.123046875, 1174.28125, 25.125),
    Vector3(-1776.1826171875, 1115.296875, 45.4453125),
    Vector3(-1732.23046875, 1115.2197265625, 45.445312),
    Vector3(-2018.2802734375, 784.728515625, 45.4453125),
    Vector3(-2018.2333984375, 748.099609375, 45.4453125),
}

local orders = {
    "- Pizza Carbasa",
    "- Pizza Margherita",
    "- Pizza Capriciosa",
    "- Pizza Parma",
    "- Pizza Campione",
    "- Pizza Decoro",
    "- Pizza Pepe Roso",
    "- Pizza Napoletana",
    "- Pizza Piacere",
    "- Pizza Roma",
    "- Pizza Inverno",
    "- Pizza Semplicita",
    "- Pizza Mafioso",
    "- Pizza Wiejska",
    "- Pizza Sparare",
    "- Pizza Pepperoni",
    "- Pizza Havai",
    "- Pizza Formicetta",
    "- Pizza Pepe Bianco",
    "- Pizza Pancetta",
    "- Pizza Basilico",
    "- Pizza Viola",
    "- Pizza Marinara",
    "- Pizza Green Day",
    "- Pizza Vegano",
    "- Pizza Scampi Tuna",
    "- Pizza Corso",
    "- Pizza Camareo",
    "- Pizza Kebab",
    "- Pizza Pollo",
    "- Pizza Barbecue",
    "- Pizza Saporito",
    "- Pizza Abalano",
    "- Sprunk 0.5l",
    "- Cola 0.5l",
    "- Water 0.5l",
    "- Hi-C 0.5l",
    "- Iced Tea 0.5l",
    "- Mello yello 0.5l",
    "- Fanta 0.5l",
}

local pinColors = {
    Vector3(244, 65, 55),
    Vector3(233, 31, 99),
    Vector3(156, 41, 178),
    Vector3(102, 59, 183),
    Vector3(63, 81, 182),
    Vector3(139, 195, 73),
    Vector3(33, 150, 243),
    Vector3(1, 188, 214),
    Vector3(0, 150, 136),
    Vector3(76, 176, 81),
    Vector3(205, 220, 58),
    Vector3(255, 235, 60),
    Vector3(254, 193, 6),
    Vector3(255, 152, 0),
    Vector3(253, 86, 36),
    Vector3(121, 85, 72),
    Vector3(158, 158, 158),
    Vector3(95, 125, 138),
}

local workSkins = {
    [155] = true,
    [304] = true,
}


Pizzaboy = {}
Pizzaboy.__index = Pizzaboy

function Pizzaboy:create(...)
    local instance = {}
    setmetatable(instance, Pizzaboy)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function Pizzaboy:constructor(...)
    self.ownedUpgrades = arg[1]

    if not self:createJobVehicle() then return false end

    self.func = {}
    self.func.chiefMarkerHit = function(...) self:chiefMarkerHit(...) end
    self.func.pointMarkerHit = function(...) self:pointMarkerHit(...) end
    self.func.render = function(...) self:render(...) end

    self.textures = {}
    self.textures.card = dxCreateTexture("files/images/card.png", "argb", true, "clamp")
    self.textures.cardPin = dxCreateTexture("files/images/card_pin.png", "argb", true, "clamp")

    self.fonts = {}
    self.fonts.card1 = dxCreateFont("files/fonts/font1.ttf", 18)
    self.fonts.card2 = dxCreateFont("files/fonts/font2.ttf", 22)

    self.pizzaCount = 0

    self:createChiefMarker()
    exports.TR_noti:create("Pizza dağıtıcısı olarak işe başladın.", "iş")
    exports.TR_jobs:createInformation(jobSettings.name, "Firma kıyafetini giymek için soyunma odasına git.")

    exports.TR_jobs:setPlayerTargetPos(368.19998168945, -116.17266845703, 1001.9995117188, 5, 1, "Değişmek için etkileşime geç (e) ve dolaba bas.")
    return true
end

function Pizzaboy:createJobVehicle()
    local respIndex = self:getFreeRespawn()
    if not respIndex then
        exports.TR_noti:create("Araç park yerinde boş yer yok. Boş bir yer açılmasını bekleyin.", "error")
        exports.TR_jobs:responseJobWindow(true)
        self:destroy()
        return false
    end

    local pos = guiInfo.vehicleSpawns[respIndex]
    triggerServerEvent("createPizzaboyVehicle", resourceRoot, {pos.x, pos.y, pos.z}, self.ownedUpgrades[3])
    exports.TR_jobs:responseJobWindow()
    return true
end

function Pizzaboy:render()
    local veh = getPedOccupiedVehicle(localPlayer)
    if veh then
        if getElementModel(veh) == 448 then
            if not self.ownedUpgrades[3] then
                local speed = math.floor(self:getElementSpeed(veh, 1))
                if speed >= 70 then
                    self:setElementSpeed(veh, 1, 70)
                end
            else
                local speed = math.floor(self:getElementSpeed(veh, 1))
                if speed >= 120 then
                    self:setElementSpeed(veh, 1, 120)
                end
            end
        end
    end

    dxDrawImage(sx-cardInfo.size.x-cardInfo.offsetX, sy/2-(cardInfo.size.y)/2+cardInfo.offsetY, cardInfo.size, self.textures.card)
    dxDrawImage(sx-cardInfo.size.x-cardInfo.offsetX, sy/2-(cardInfo.size.y)/2+cardInfo.offsetY, cardInfo.size, self.textures.cardPin, 0, 0, 0, tocolor(self.pinColor.x, self.pinColor.y, self.pinColor.z, 255))

    dxDrawText(table.concat(self.orders, "\n"), sx-cardInfo.size.x-cardInfo.offsetX+5/zoom, sy/2-(cardInfo.size.y)/2+cardInfo.offsetY+20/zoom, sx-cardInfo.size.x-cardInfo.offsetX+5/zoom, sy/2-(cardInfo.size.y)/2+cardInfo.offsetY+20/zoom, tocolor(15, 15, 15), 1/zoom, self.pinFont, "left", "top", false, true)

    if not isElement(self.point) then return end
    if getDistanceBetweenPoints3D(Vector3(getElementPosition(localPlayer)), Vector3(getElementPosition(self.point))) < 50 then
        if not self.isNear then
            exports.TR_jobs:createInformation(jobSettings.name, string.format("Scooterden pizzayı al ve müşteriye kapının önüne götür.\n Kalan siparişler: %d", self.pizzaCount), 240/zoom)
            self.isNear = true
        end

    else
        if self.isNear then
            exports.TR_jobs:createInformation(jobSettings.name, string.format("Müşteriye ulaşmak için skutere bin ve onun siparişini teslim et.\n Kalan siparişler: %d", self.pizzaCount), 240/zoom)
            self.isNear = nil
        end
    end
end

function Pizzaboy:getNewOrders()
    self.orders = {}
    for i = 1, math.random(1, 3) do
        self.orders[i] = orders[math.random(1, #orders)].." x"..math.random(1, 4)
    end
end

function Pizzaboy:chiefMarkerHit(hit, md)
    if not hit or not md or getPedOccupiedVehicle(hit) or hit ~= localPlayer then return end
    if not self:hasSkin() then return end

    self.pizzaCount = self.ownedUpgrades[1] and 10 or 5
    self.pinColor = pinColors[math.random(1, #pinColors)]
    self.pinFont = (math.random(1, 2) == 1 and self.fonts.card1 or self.fonts.card2)

    self:getNewOrders()
    self:freezePlayer(2000)
    self:createPoint()
    addEventHandler("onClientRender", getRootElement(), self.func.render)
    removeEventHandler("onClientMarkerHit", self.chiefMarker, self.func.chiefMarkerHit)
    self:checkDestroy(self.chiefMarker)

    exports.TR_jobs:createInformation(jobSettings.name, string.format("Scooter'a bin, seni sağdaki otoparkta bekliyor.\n Kalan siparişler: %d", self.pizzaCount), 240/zoom)
end

function Pizzaboy:createChiefMarker()
    self.chiefMarker = createMarker(376.49130249023, -113.70402526855, 1001.4921875 - 0.9, "cylinder", 0.8, 255, 0, 0, 0)
    setElementData(self.chiefMarker, "markerData", {
        title = "Pizza Alma",
        desc = "Sipariş listesini almak için işaretleyiciye girin.",
    }, false)
    setElementData(self.chiefMarker, "markerIcon", "pizza", false)
    setElementInterior(self.chiefMarker, 5)
    setElementDimension(self.chiefMarker, 1)

    addEventHandler("onClientMarkerHit", self.chiefMarker, self.func.chiefMarkerHit)
end

function Pizzaboy:destroyChiefMarker()
    self:checkDestroy(self.chiefMarker)
end

function Pizzaboy:pointMarkerHit(hit, md)
    if not hit or not md or getPedOccupiedVehicle(hit) or hit ~= localPlayer or not isPedOnGround(localPlayer) then return end
    if not self.holdingPizza then exports.TR_noti:create("Aracınızdan pizzayı almalısınız.", "error") return end
    self.pinColor = pinColors[math.random(1, #pinColors)]
    self.pinFont = (math.random(1, 2) == 1 and self.fonts.card1 or self.fonts.card2)

    self:payForWork()
    self:destroyPoint()
    if self.pizzaCount >= 1 then
        self:createPoint()
        self:getNewOrders()
    else
        self:createChiefMarker()
        removeEventHandler("onClientRender", getRootElement(), self.func.render)
    end
    self:freezePlayer(6150)
    exports.TR_hud:blockPlayerSprint(false)

    setTimer(function()
        exports.TR_dx:setOpenGUI(false)
        toggleControl("enter_exit", true)
    end, 10000, 1)

    playSound("files/sounds/sound.mp3")
end

function Pizzaboy:createPoint()
    local r = math.random(1, #points)
    while(r == self.lastPosition) do
        r = math.random(1, #points)
    end
    self.lastPosition = r

    self.point = createMarker(points[r].x, points[r].y, points[r].z - 0.9, "cylinder", 1, 255, 60, 60, 0)
    setElementData(self.point, "markerData", {
        title = "Pizza Teslimatı",
        desc = "Pizzayı teslim etmek için işaretleyiciye girin.",
    }, false)
    setElementData(self.point, "markerIcon", "pizza", false)

    self.pointBlip = createBlip(points[r], 0, 1, 255, 60, 60, 255)
    setElementData(self.pointBlip, "icon", 22, false)

    addEventHandler("onClientMarkerHit", self.point, self.func.pointMarkerHit)
    exports.TR_jobs:setPlayerTargetPos(points[r].x, points[r].y, points[r].z - 0.5, 0, 0, "Müşteriye pizza teslim et")
    exports.TR_hud:findBestWay(points[r].x, points[r].y)

    exports.TR_jobs:setPaymentTime()
end

function Pizzaboy:destroyPoint()
    self.pizzaCount = self.pizzaCount - 1
    self:refreshPizzaCount()
    if self.point and isElement(self.point) then
        removeEventHandler("onClientMarkerHit", self.point, self.func.pointMarkerHit)
    end
    self:checkDestroy(self.point)
    self:checkDestroy(self.pointBlip)
end

function Pizzaboy:clearTextures()
    for i, v in pairs(self.textures) do
        destroyElement(v)
    end
end

function Pizzaboy:hasSkin()
    local model = getElementModel(localPlayer)
    return (workSkins[model])
end

function Pizzaboy:refreshPizzaCount()
    if self.pizzaCount >= 1 then
        exports.TR_jobs:createInformation(jobSettings.name, string.format("Scooter'e binin ve müşteriye gitmek için ilerleyin.\n Geriye kalan siparişler: %d", self.pizzaCount), 240/zoom)
    else
        exports.TR_jobs:createInformation(jobSettings.name, "Restorana geri dön ve yeni siparişler alın.")
        exports.TR_jobs:setPlayerTargetPos(-1806.7744140625, 943.859375, 24.890625 - 0.5, 0, 0, "Restorana geri dön ve yeni siparişler alın")
        exports.TR_hud:findBestWay(-1806.7744140625, 943.859375)
    end
end

function Pizzaboy:freezePlayer(time)
    for i, v in ipairs({"left", "right", "forwards", "backwards", "jump", "crouch", "sprint"}) do
        toggleControl(v, false)
    end
    setTimer(function()
        for i, v in ipairs({"left", "right", "forwards", "backwards", "jump", "crouch", "sprint"}) do
            toggleControl(v, true)
        end
    end, (time or 1000), 1)
    setElementFrozen(localPlayer, true)
    setTimer(setElementFrozen, (time or 1000), 1, localPlayer, false)

    setTimer(function()
        self.holdingPizza = nil
        setElementData(localPlayer, "blockAction", nil)

        triggerServerEvent("syncAnim", resourceRoot, nil, nil)
        setPedAnimation(localPlayer, "ped", "idle_gang1")
        setTimer(setPedAnimation, 100, 1, localPlayer, nil, nil)
        setElementData(localPlayer, "blockAnim", nil, false)

        if isElement(self.pizzaObject) then destroyElement(self.pizzaObject) end
    end, (time or 1000), 1)
end

function Pizzaboy:destroy()
    self:destroyPoint()
    self:destroyChiefMarker()
    self:clearTextures()

    exports.TR_jobs:resetPaymentTime()

    removeEventHandler("onClientRender", getRootElement(), self.func.render)
    triggerServerEvent("removeAttachedObject", resourceRoot, 448)
    setElementData(localPlayer, "animation", nil)
    guiInfo.work = nil
    self = nil
end

function Pizzaboy:checkDestroy(element)
    if element and isElement(element) then
        destroyElement(element)
    end
end

function Pizzaboy:getFreeRespawn()
    local freeResp = false

    for i, spawnPos in pairs(guiInfo.vehicleSpawns) do
        local clear = true
        for _, v in pairs(getElementsByType("vehicle", root)) do
            local pos = Vector3(getElementPosition(v))
            if getDistanceBetweenPoints3D(spawnPos, pos) < 5 then clear = false break end
        end
        if clear then freeResp = i end
    end

    return freeResp
end

function Pizzaboy:getPizzaFromVehicle()
    if getDistanceBetweenPoints3D(Vector3(getElementPosition(localPlayer)), Vector3(getElementPosition(self.point))) < 50 then
        self.pizzaObject = createObject(2814, 0, 0, 0)
        exports.bone_attach:attachElementToBone(self.pizzaObject, localPlayer, 11, -0.2, 0, 0.1, 270, 350, 0)

        exports.TR_hud:blockPlayerSprint(true)
        -- triggerServerEvent("syncAnim", resourceRoot, "CARRY", "crry_prtial", 1, true)
        setPedAnimation(localPlayer, "CARRY", "crry_prtial", 1, true)
        setElementData(localPlayer, "blockAnim", true, false)
        -- setElementData(localPlayer, "animation", {"CARRY", "crry_prtial"})

        self.holdingPizza = true
        setElementData(localPlayer, "blockAction", true)
        toggleControl("enter_exit", false)
        exports.TR_jobs:createInformation(jobSettings.name, "Kapıya pizza götür.", 240/zoom)
        return true
    else
        exports.TR_noti:create("Pizzayı alamazsınız, çünkü hedefe çok uzaksınız ve soğuk pizzayı teslim edemezsiniz.", "error")
        return false
    end
end


-- Payment
function Pizzaboy:payForWork()
    local payment = self:calculatePayment()
    local paymentType = exports.TR_jobs:getPlayerJobPaymentType()

    if self.ownedUpgrades[2] then
        if math.random(1, 10) >= 5 then
            local tip = math.random(1400, 1800)/100
            payment = payment + tip
            exports.TR_noti:create(string.format("Bahşiş olarak $%.2f aldınız.", tip), "para")
        end
    else
        if math.random(1, 10) >= 9 then
            local tip = math.random(1400, 1800)/100
            payment = payment + tip
            exports.TR_noti:create(string.format("Bahşiş olarak $%.2f aldınız.", tip), "para")
        end
    end

    triggerServerEvent("giveJobPayment", resourceRoot, payment, false, paymentType, getResourceName(getThisResource()))
end

function Pizzaboy:calculatePayment()
    local addMin, addMax = 0, 0
    for i, v in pairs(jobSettings.upgrades) do
        if self.ownedUpgrades[i] and v.additionalMoney then
            addMin = addMin + v.additionalMoney[1]
            addMax = addMax + v.additionalMoney[2]
        end
    end
    return math.min(exports.TR_jobs:getPaymentCount(guiInfo.hourEarning[1] + addMin, guiInfo.hourEarning[2] + addMax), guiInfo.maxEarning + (addMin + addMax)/2)
end

function Pizzaboy:setElementSpeed(element, unit, speed)
    local unit    = unit or 0
    local speed   = tonumber(speed) or 0
	local acSpeed = self:getElementSpeed(element, unit)
	if (acSpeed) then
		local diff = speed/acSpeed
		if diff ~= diff then return false end
        local x, y, z = getElementVelocity(element)
		return setElementVelocity(element, x*diff, y*diff, z*diff)
	end

	return false
end
function Pizzaboy:getElementSpeed(theElement, unit)
	if not isElement(theElement) then return 0 end
    local elementType = getElementType(theElement)
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    return (Vector3(getElementVelocity(theElement)) * mult).length
end


function startJob(...)
    if guiInfo.work then return end
    guiInfo.work = Pizzaboy:create(...)
end

function endJob()
    exports.TR_jobs:responseJobWindow()
    if not guiInfo.work then return end
    guiInfo.work:destroy()
end

function getPizzaFromVehicle()
    if not guiInfo.work then return false end
    return guiInfo.work:getPizzaFromVehicle()
end


-- setPedAnimation(localPlayer, "CARRY", "crry_prtial", 1, true)