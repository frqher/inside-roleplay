local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    center = {
        x = (sx - 100/zoom)/2,
        y = sy - 230/zoom,
        w = 100/zoom,
        h = 167/zoom,
    },

    img = {
        x = sx - 300/zoom + 86/zoom,
        y = (sy - 128/zoom)/2,
        size = 128/zoom,
    },

    vehicle = {
        model = 414,
        respawnPos = Vector3(2255.5834960938, -185.18118286133, 96.183654785156),
        pos = Vector3(2255.5834960938, -195.18118286133, 96.183654785156),
        rot = Vector3(0, 0, 0),

        moveTime = 5000,
        trunkTime = 2000,
    },

    marker = {
        pos = Vector3(2255.5432128906, -199.31307983398, 96.181617736816),
        int = 5,
        dim = 5,
    },

    skins = {
        [16] = "male",
        [298] = "female",
    },

    boxPoints = {
        {
            pos = Vector3(2272.6450195313, -200.24397277832, 96.185935974121),
            name = "Kitaplık",
            plural = "kitaplar",
            texture = "books",
        },
        {
            pos = Vector3(2282.6811523438, -200.15278625488, 96.185935974121),
            name = "Parça Rafı",
            plural = "araba parçaları",
            texture = "parts",
        },
        {
            pos = Vector3(2279.3596191406, -205.93141174316, 96.185935974121),
            name = "İçecek Rafı",
            plural = "içecekler",
            texture = "water",
        },
        {
            pos = Vector3(2262.8029785156, -209.33880615234, 96.188446044922),
            name = "Süt Ürünleri Rafı",
            plural = "süt ürünleri",
            texture = "egg",
        },
        {
            pos = Vector3(2248.9833984375, -202.60075378418, 96.173606872559),
            name = "Et Rafı",
            plural = "et",
            texture = "meat",
        },
        {
            pos = Vector3(2251.3854980469, -211.12852478027, 96.170150756836),
            name = "Ekmek Rafı",
            plural = "ekmek",
            texture = "bread",
        },
        {
            pos = Vector3(2291.703125, -206.43612670898, 96.187034606934),
            name = "Dondurma Rafı",
            plural = "dondurma",
            texture = "icecream",
        },
        {
            pos = Vector3(2308.9265136719, -201.47285461426, 96.179512023926),
            name = "RTV Rafı",
            plural = "RTV",
            texture = "rtv",
        },
        {
            pos = Vector3(2304.7255859375, -197.99008178711, 96.177665710449),
            name = "AGD Rafı",
            plural = "AGD",
            texture = "agd",
        },
        {
            pos = Vector3(2298.3610839844, -196.25189208984, 96.176559448242),
            name = "Oyuncak Rafı",
            plural = "oyuncaklar",
            texture = "toys",
        },
        {
            pos = Vector3(2294.9858398438, -209.27627563477, 96.18830871582),
            name = "İlaç Rafı",
            plural = "ilaçlar",
            texture = "medic",
        },
        {
            pos = Vector3(2254.5729980469, -208.30506896973, 96.174026489258),
            name = "Meyve Rafı",
            plural = "meyveler",
            texture = "fruits",
        },
        {
            pos = Vector3(2257.6315917969, -211.83152770996, 96.184692382813),
            name = "Şekerleme Rafı",
            plural = "şekerlemeler",
            texture = "candy",
        },
        {
            pos = Vector3(2264.5510253906, -196.85148620605, 96.186401367188),
            name = "Şeker Rafı",
            plural = "şeker kutuları",
            texture = "sugar",
        },
    },
    hourEarning = {3450, 3550},
    maxEarning = 38,
}

Warehouse = {}
Warehouse.__index = Warehouse

function Warehouse:create(...)
    local instance = {}
    setmetatable(instance, Warehouse)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function Warehouse:constructor(...)
    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(12)
    self.ownedUpgrades = arg[1]

    self.textures = {}
    self.textures.left = dxCreateTexture("files/images/mouse_l.png", "argb", true, "clamp")
    self.textures.right = dxCreateTexture("files/images/mouse_r.png", "argb", true, "clamp")
    self.textures.mouse = dxCreateTexture("files/images/mouse.png", "argb", true, "clamp")

    self.func = {}
    self.func.render = function() self:render() end
    self.func.onKey = function(...) self:onKey(...) end

    self.func.openVehicleTrunk = function() self:openVehicleTrunk() end
    self.func.closeVehicleTrunk = function() self:closeVehicleTrunk() end

    self.func.createDeliveryTruck = function() self:createDeliveryTruck() end
    self.func.removeDeliveryTruck = function() self:removeDeliveryTruck() end

    self.func.waitForNextTruck = function() self:waitForNextTruck() end

    self.func.createVehicleMarker = function() self:createVehicleMarker() end

    self.func.takeBoxHit = function(...) self:takeBoxHit(...) end
    self.func.takeoutBoxHit = function(...) self:takeoutBoxHit(source, ...) end

    self.func.endJobForce = function(...) self:endJobForce(...) end

    self.timer = setTimer(function()
        self:createDeliveryTruck(true)
    end, 15000, 1)

    addEventHandler("onClientKey", root, self.func.onKey)
    self.checkerTimer = setTimer(self.func.endJobForce, 5000, 0)

    exports.TR_noti:create("Depo işçisi olarak işe başladınız.", "iş")
    exports.TR_jobs:createInformation(jobSettings.name, "İş elbisesi giyin.")
    exports.TR_jobs:setPlayerTargetPos(2254.0112304688, -221.82743835449, 96.182502746582, 5, 5, "Giyinmek için etkileşimi (e) kullanın ve dolaba basın")
    toggleControl("crouch", false)

    self:setPedDucked(localPlayer, false)
    return true
end

function Warehouse:endJobForce()
    if getElementInterior(localPlayer) ~= 5 and getElementDimension(localPlayer) ~= 5 then
        self:destroy()
        exports.TR_jobs:setPlayerJob(false)
        exports.TR_jobs:removeInformation()
        exports.TR_jobs:setPlayerTargetPos(false)
        exports.TR_noti:create("İş yerini terk ettiniz. Otomatik olarak işten çıkarıldınız.", "info")
        triggerServerEvent("endJob", resourceRoot)
    end
end

function Warehouse:destroy()
    if isTimer(self.timer) then killTimer(self.timer) end
    if isTimer(self.checkerTimer) then killTimer(self.checkerTimer) end

    for i, v in pairs(self.textures) do
        destroyElement(v)
    end

    if isElement(self.takeBoxMarker) then destroyElement(self.takeBoxMarker) end
    if isElement(self.deliveryMarker) then destroyElement(self.deliveryMarker) end
    if isElement(self.mover) then destroyElement(self.mover) end
    if isElement(self.vehicle) then destroyElement(self.vehicle) end

    setElementData(localPlayer, "inJob", nil)

    self:setControls(true)
    setPedAnimation(localPlayer, "ped", "idle_gang1")
    setTimer(setPedAnimation, 100, 1, localPlayer, nil, nil)
    setTimer(setElementData, 100, 1, localPlayer, "animation", nil)

    setElementData(localPlayer, "blockAnim", nil, false)

    removeEventHandler("onClientRender", root, self.func.render)
    removeEventHandler("onClientKey", root, self.func.onKey)

    toggleControl("crouch", true)
    guiInfo.work = nil
    self = nil
end

function Warehouse:renderPackImage()
    dxDrawImage(guiInfo.img.x, guiInfo.img.y + 25/zoom, guiInfo.img.size, guiInfo.img.size, self.textures.icon)
end

function Warehouse:render()
    if not self.carryingBox then return end
    self:renderPackImage()

    if not self.ownedUpgrades[3] then
        toggleControl("walk", false)
        setPedControlState(localPlayer, "walk", true)
    end

    if self.ownedUpgrades[1] then return end
    if not self.selectedKey and (getTickCount() - self.tick)/self.buttonTickToClick >= 1 then
        self.selectedKey = math.random(1, 2)
        self.tick = getTickCount()

    elseif self.selectedKey then
        if (getTickCount() - self.tick)/2000 >= 1 then
            self.selectedKey = nil
            self.tick = getTickCount()

            exports.TR_noti:create("Dengenizi kaybettiniz ve paketi düşürdünüz.", "error")
            exports.TR_jobs:resetPaymentTime()
            self:removeBox(true)
        end
    end

    if self.selectedKey == 1 then
        dxDrawImage(guiInfo.center.x, guiInfo.center.y, guiInfo.center.w, guiInfo.center.h, self.textures.left, 0, 0, 0, tocolor(255, 255, 255, 255))
    elseif self.selectedKey == 2 then
        dxDrawImage(guiInfo.center.x, guiInfo.center.y, guiInfo.center.w, guiInfo.center.h, self.textures.right, 0, 0, 0, tocolor(255, 255, 255, 255))
    else
        dxDrawImage(guiInfo.center.x, guiInfo.center.y, guiInfo.center.w, guiInfo.center.h, self.textures.mouse, 0, 0, 0, tocolor(255, 255, 255, 255))
    end
    dxDrawText("Dengenizi kaybetmemek için dengeyi kaybettiğinizde uygun\ntuşlara basın.", guiInfo.center.x, guiInfo.center.y + guiInfo.center.h + 10/zoom, guiInfo.center.x + guiInfo.center.w, guiInfo.center.y, tocolor(255, 255, 255, 255), 1/zoom, self.fonts.main, "center", "top")
end

function Warehouse:onKey(...)
    if not arg[2] then return end
    if not self.carryingBox then return end
    if self.ownedUpgrades[1] then return end

    if arg[1] == "mouse1" and self.selectedKey == 1 then
        self.selectedKey = nil
        self.buttonTickToClick = math.random(guiInfo.clickTimeInterval[1], guiInfo.clickTimeInterval[2])*100
        self.tick = getTickCount()

    elseif arg[1] == "mouse2" and self.selectedKey == 2 then
        self.selectedKey = nil
        self.buttonTickToClick = math.random(guiInfo.clickTimeInterval[1], guiInfo.clickTimeInterval[2])*100
        self.tick = getTickCount()

    elseif arg[1] == "mouse1" or arg[1] == "mouse2" then
        self.selectedKey = nil
        exports.TR_noti:create("Dengenizi kaybettiniz ve paketi düşürdünüz.", "error")
        self:removeBox(true)
    end
end

function Warehouse:createDeliveryTruck(blockMsg)
    if not self.mover then
        self.mover = createObject(1271, guiInfo.vehicle.respawnPos, guiInfo.vehicle.rot)
        self.vehicle = createVehicle(guiInfo.vehicle.model, guiInfo.vehicle.respawnPos, guiInfo.vehicle.rot)
        attachElements(self.vehicle, self.mover)
        setElementData(self.vehicle, "blockAction", true, false)

        setElementInterior(self.vehicle, guiInfo.marker.int)
        setElementDimension(self.vehicle, guiInfo.marker.dim)
        setElementInterior(self.mover, guiInfo.marker.int)
        setElementDimension(self.mover, guiInfo.marker.dim)
    end

    self.timer = setTimer(function()
        setElementAlpha(self.mover, 0)
        moveObject(self.mover, guiInfo.vehicle.moveTime, guiInfo.vehicle.pos)
        self.timer = setTimer(self.func.openVehicleTrunk, guiInfo.vehicle.moveTime, 1)
    end, 100, 1)

    if blockMsg then return end
    exports.TR_jobs:createInformation(jobSettings.name, "Teslimat kamyonu geliyor. Boşaltma işlemine hazırlanın.")
end

function Warehouse:removeDeliveryTruck()
    if not guiInfo.work then return end
    moveObject(self.mover, guiInfo.vehicle.moveTime, guiInfo.vehicle.respawnPos)
    self.timer = setTimer(self.func.waitForNextTruck, guiInfo.vehicle.moveTime, 1)
end

function Warehouse:waitForNextTruck()
    if not guiInfo.work then return end
    if self.ownedUpgrades[2] then
        self.timer = setTimer(self.func.createDeliveryTruck, math.random(5, 10) * 1000, 1)
    else
        self.timer = setTimer(self.func.createDeliveryTruck, math.random(10, 20) * 1000, 1)
    end
    exports.TR_jobs:createInformation(jobSettings.name, "Bir sonraki teslimat kamyonunu bekleyin. Birazdan yerinde belirecek.")
end

function Warehouse:openVehicleTrunk()
    if not guiInfo.work then return end
    setVehicleDoorOpenRatio(self.vehicle, 1, 1, guiInfo.vehicle.trunkTime)
    self.timer = setTimer(self.func.createVehicleMarker, guiInfo.vehicle.trunkTime, 1)
end

function Warehouse:closeVehicleTrunk()
    if not guiInfo.work then return end
    setVehicleDoorOpenRatio(self.vehicle, 1, 0, guiInfo.vehicle.trunkTime)
    self.timer = setTimer(self.func.removeDeliveryTruck, guiInfo.vehicle.trunkTime, 1)
end

function Warehouse:createVehicleMarker()
    if not guiInfo.work then return end
    self.taken = 0
    self.toTake = 5

    if guiInfo.skins[getElementModel(localPlayer)] then
        exports.TR_jobs:createInformation(jobSettings.name, string.format("Arabayı boşalt. \nBoşaltılan paketler: %d/%d.", self.taken, self.toTake))
    end

    self.takeBoxMarker = createMarker(guiInfo.marker.pos.x, guiInfo.marker.pos.y, guiInfo.marker.pos.z - 0.9, "cylinder", 1.2, 255, 255, 255, 0)
    setElementData(self.takeBoxMarker, "markerData", {
        title = "Boşaltma Alanı",
        desc = "Paketi al ve doğru yere götür."
    }, false)
    setElementData(self.takeBoxMarker, "markerIcon", "magazineBox", false)

    setElementInterior(self.takeBoxMarker, guiInfo.marker.int)
    setElementDimension(self.takeBoxMarker, guiInfo.marker.dim)

    addEventHandler("onClientMarkerHit", self.takeBoxMarker, self.func.takeBoxHit)
end

function Warehouse:takeBoxHit(el, md)
    if not el or not md then return end
    if el ~= localPlayer then return end
    if getPedOccupiedVehicle(el) then return end
    if self.carryingBox then return end
    if not exports.TR_dx:canOpenGUI() then return end
    if not guiInfo.skins[getElementModel(localPlayer)] then return end
    if self:getElementSpeed(localPlayer, 1) > 25 then exports.TR_noti:create("Paketi sakin bir şekilde al, koşma aksi takdirde almadan düşürebilirsin.", "info") return end

    self.taken = self.taken + 1
    if self.taken > self.toTake then
        self.timer = setTimer(self.func.closeVehicleTrunk, 5000, 1)
        exports.TR_jobs:setPlayerTargetPos(false)
        exports.TR_jobs:createInformation(jobSettings.name, "Sürücü sadece teslimatın bitirme belgelerini imzalayacak ve iş yerinden ayrılacak.")
        destroyElement(self.takeBoxMarker)
        exports.TR_jobs:setPaymentTime()
        return
    end

    self:createBox()
    local selectedDelivery = guiInfo.boxPoints[math.random(1, #guiInfo.boxPoints)]
    self.boxType = selectedDelivery.plural
    self:createDeliveryPoint(selectedDelivery)

    if isElement(self.textures.icon) then destroyElement(self.textures.icon) end
    self.textures.icon = dxCreateTexture(string.format("files/images/%s.png", selectedDelivery.texture), "argb", true, "clamp")
    exports.TR_jobs:createInformation(jobSettings.name, "Paketi uygun rafta bırak. Düşürmemeye çalış. \nPaket içeriği:", 170/zoom)
end

function Warehouse:createBox()
    self.carryingBox = true
    triggerServerEvent("attachObjectToBone", resourceRoot, 1271, 0.7, 11, -0.2, 0.2, 0.2, 280, 80, 90)

    self.buttonTickToClick = math.random(guiInfo.clickTimeInterval[1], guiInfo.clickTimeInterval[2])*100
    self.tick = getTickCount()

    setPedAnimation(localPlayer, "CARRY", "crry_prtial", 1, true)
    setElementData(localPlayer, "animation", {"CARRY", "crry_prtial"})
    setElementData(localPlayer, "blockAnim", true, false)

    self:setControls(false)

    addEventHandler("onClientRender", root, self.func.render)
end

function Warehouse:removeBox(angry)
    self.carryingBox = nil

    setPedAnimation(localPlayer, "ped", "idle_gang1")
    setElementData(localPlayer, "animation", nil)
    setTimer(setPedAnimation, 100, 1, localPlayer, nil, nil)
    setTimer(setElementData, 100, 1, localPlayer, "animation", nil)
    triggerServerEvent("removeAttachedObject", resourceRoot, 1271)

    if angry then
        if guiInfo.skins[getElementModel(localPlayer)] == "male" then
            setTimer(setPedAnimation, 500, 1, localPlayer, "FIGHT_D", "FightD_G", -1, false, false, false, false)
        else
            setPedControlState(localPlayer, "forwards", false)
            setPedControlState(localPlayer, "backwards", false)
            setPedControlState(localPlayer, "left", false)
            setPedControlState(localPlayer, "right", false)
            toggleControl("forwards", false)
            toggleControl("backwards", false)
            toggleControl("left", false)
            toggleControl("right", false)

            setTimer(setPedAnimation, 500, 1, localPlayer, "MISC", "plyr_shkhead", -1, false, false, false, false)

            setTimer(function()
                toggleControl("forwards", true)
                toggleControl("backwards", true)
                toggleControl("left", true)
                toggleControl("right", true)
            end, 1000, 1)
        end

    else
        setTimer(setPedAnimation, 100, 1, localPlayer, nil, nil)
        setTimer(setElementData, 100, 1, localPlayer, "animation", nil)
    end

    setTimer(triggerServerEvent, 100, 1, "syncAnim", resourceRoot, nil, nil)
    setElementData(localPlayer, "blockAnim", nil, false)

    self:setControls(true)

    if self.taken == self.toTake then
        exports.TR_jobs:createInformation(jobSettings.name, "Sürücüye tüm paketlerin boşaltıldığını bildirin.")
        exports.TR_jobs:setPlayerTargetPos(2255.5432128906, -199.31307983398, 95.681617736816, 5, 5, "Sürücü ile konuşmak için yaklaşın")
    else
        exports.TR_jobs:createInformation(jobSettings.name, string.format("Arabayı boşaltın. \nBoşaltılan paketler: %d/%d.", self.taken, self.toTake))
        exports.TR_jobs:setPlayerTargetPos(2255.5432128906, -199.31307983398, 95.681617736816, 5, 5, "Paketi boşaltmak için yaklaşın")
    end

    if isElement(self.deliveryMarker) then destroyElement(self.deliveryMarker) end
    removeEventHandler("onClientRender", root, self.func.render)
end

function Warehouse:createDeliveryPoint(data)
    self.deliveryMarker = createMarker(data.pos.x, data.pos.y, data.pos.z - 0.9, "cylinder", 1.2, 190, 60, 120, 0)
    setElementData(self.deliveryMarker, "boxType", data.plural, false)
    setElementData(self.deliveryMarker, "markerData", {
        title = data.name,
        desc = string.format("Buraya %s'li paketi bırakın.", data.plural),
    }, false)
    setElementData(self.deliveryMarker, "markerIcon", "magazineBox", false)

    setElementInterior(self.deliveryMarker, guiInfo.marker.int)
    setElementDimension(self.deliveryMarker, guiInfo.marker.dim)

    exports.TR_jobs:setPlayerTargetPos(data.pos.x, data.pos.y, data.pos.z - 0.5, 5, 5, "Doğru rafta paketi taşı")
    exports.TR_jobs:setPaymentTime()

    addEventHandler("onClientMarkerHit", self.deliveryMarker, self.func.takeoutBoxHit)
end

function Warehouse:takeoutBoxHit(source, el, md)
    if not el or not md then return end
    if el ~= localPlayer then return end
    if getPedOccupiedVehicle(el) then return end
    if not self.carryingBox then return end
    if not guiInfo.skins[getElementModel(localPlayer)] then return end

    local type = getElementData(source, "boxType")
    if type ~= self.boxType then
        exports.TR_noti:create("Paket yanlış yere bırakıldı. Hiçbir ödeme alamazsınız.", "error")
        exports.TR_jobs:resetPaymentTime()
    else
        local paymentType = exports.TR_jobs:getPlayerJobPaymentType()
        local payment = self:calculatePayment()
        exports.TR_jobPayments:giveJobPayment(payment, paymentType, getResourceName(getThisResource()))
    end

    self:removeBox()
end

function Warehouse:calculatePayment()
    local addMin, addMax = 0, 0
    for i, v in pairs(jobSettings.upgrades) do
        if self.ownedUpgrades[i] and v.additionalMoney then
            addMin = addMin + v.additionalMoney[1]
            addMax = addMax + v.additionalMoney[2]
        end
    end
    return math.min(exports.TR_jobs:getPaymentCount(guiInfo.hourEarning[1] + addMin, guiInfo.hourEarning[2] + addMax), guiInfo.maxEarning + (addMin + addMax)/2)
end

function Warehouse:setControls(state)
    toggleControl("sprint", state)
    toggleControl("jump", state)

    if not self.ownedUpgrades[3] then
        toggleControl("walk", state)
        setPedControlState(localPlayer, "walk", not state)
    end
    exports.TR_hud:blockPlayerSprint(not state)

    exports.TR_dx:setOpenGUI(not state)
end

function Warehouse:setPedDucked(ped, bool)
	local alreadyDucked = isPedDucked(ped)
	if (alreadyDucked and not bool) then
		setPedControlState(ped, "crouch", true)
		setTimer(setPedControlState, 50, 1, ped, "crouch", false)
		return true
	elseif (not alreadyDucked and bool) then
		setPedControlState(ped, "crouch", true)
		setTimer(setPedControlState, 50, 1, ped, "crouch", false)
		return true
	end
	return false
end

function Warehouse:findRotation( x1, y1, x2, y2 )
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end

function Warehouse:getElementSpeed(theElement, unit)
	if not isElement(theElement) then return 0 end
    local elementType = getElementType(theElement)
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    return (Vector3(getElementVelocity(theElement)) * mult).length
end

function startJob(...)
    if guiInfo.work then return end
    guiInfo.work = Warehouse:create(...)

    exports.TR_jobs:responseJobWindow()
end

function endJob()
    exports.TR_jobs:responseJobWindow()

    if not guiInfo.work then return end
    guiInfo.work:destroy()
end

-- startJob()


setElementData(localPlayer, "animation", nil)