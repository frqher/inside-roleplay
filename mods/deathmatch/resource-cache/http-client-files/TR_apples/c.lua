local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    markers = {
        Vector3(996.531, -344.740, 71.831),
        Vector3(984.858, -370.495, 69.972),
        Vector3(970.030, -368.128, 66.984),
        Vector3(959.929, -379.963, 64.774),
        Vector3(956.166, -366.005, 63.575),
        Vector3(962.213, -336.194, 64.572),
        Vector3(972.663, -304.394, 66.165),
        Vector3(958.852, -315.197, 62.648),
        Vector3(889.761, -303.210, 36.967),
        Vector3(870.639, -302.847, 32.477),
        Vector3(862.643, -312.920, 31.320),
        Vector3(851.705, -321.734, 29.735),
        Vector3(874.653, -323.299, 35.718),
        Vector3(886.500, -319.465, 38.674),
        Vector3(892.433, -347.240, 42.875),
        Vector3(910.995, -331.284, 47.913),
        Vector3(915.720, -316.104, 47.168),
        Vector3(934.283, -326.539, 55.810),
        Vector3(939.134, -341.479, 57.934),
        Vector3(921.226, -365.168, 53.319),
        Vector3(758.832, -240.251, 12.074),
        Vector3(752.131, -248.895, 11.162),
        Vector3(754.595, -258.008, 11.590),
        Vector3(762.298, -253.778, 12.311),
        Vector3(782.383, -245.587, 15.068),
        Vector3(797.476, -230.580, 16.773),
        Vector3(799.726, -249.031, 17.285),
        Vector3(820.045, -239.100, 18.849),
        Vector3(842.623, -235.035, 19.893),
        Vector3(822.070, -263.114, 20.547),
        Vector3(801.460, -278.062, 18.350),
        Vector3(808.395, -288.344, 20.035),
        Vector3(828.870, -287.065, 23.062),
        Vector3(838.041, -262.167, 20.961),
        Vector3(858.063, -275.093, 25.230),
        Vector3(861.396, -286.743, 27.823),
        Vector3(853.125, -301.229, 27.905),
        Vector3(838.179, -299.490, 25.504),
        Vector3(826.339, -300.892, 23.828),
    },

    tree = {
        x = (sx - 740/zoom)/2,
        y = (sy - 800/zoom)/2,
        w = 740/zoom,
        h = 800/zoom
    },

    box = {
        x = (sx - 400/zoom)/2,
        y = sy - 221/zoom,
        w = 400/zoom,
        h = 221/zoom
    },

    apple = {
        size = 50/zoom,
    },

    hourEarning = {3800, 3900},
    maxEarning = 240,
}

Apples = {}
Apples.__index = Apples

function Apples:create(...)
    local instance = {}
    setmetatable(instance, Apples)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function Apples:constructor(...)
    self.move = 0
    self.blips = {}
    self.markers = {}
    self.treeApples = {}
    self.basketApples = {}
    self.givedApples = 0
    self.ownedUpgrades = arg[1] or {}

    self.appleToGet = self.ownedUpgrades[1] and 35 or 25

    self.fonts = {}
    self.fonts.exit = exports.TR_dx:getFont(15)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.click = function(...) self:click(...) end
    self.func.closeTree = function() self:closeTree() end
    self.func.blockVehicleEnter = function(...) self:blockVehicleEnter(...) end
    self.func.enterBasketMarker = function(...) self:enterBasketMarker(...) end
    self.func.enterAppleMarker = function(...) self:enterAppleMarker(source, ...) end

    exports.TR_noti:create("Elma toplayıcısı olarak işe başladınız.", "job")
    exports.TR_jobs:createInformation(jobSettings.name, "Sadece bir elma toplama işi.")

    self:createMarkers()

    addEventHandler("onClientVehicleStartEnter", root, self.func.blockVehicleEnter)
    return true
end
function Apples:destroy()
    exports.TR_jobs:resetPaymentTime()
    exports.TR_hud:blockPlayerSprint(false)
    self:removeMarkers()

    setPedAnimation(localPlayer, "ped", "idle_gang1")
    triggerServerEvent("syncAnim", resourceRoot,"ped", "idle_gang1")
    setTimer(triggerServerEvent, 100, 1, "syncAnim", resourceRoot, nil, nil)
    setElementData(localPlayer, "blockAnim", nil, false)
    triggerServerEvent("removeAttachedObject", resourceRoot, 917)

    removeEventHandler("onClientVehicleStartEnter", root, self.func.blockVehicleEnter)

    guiInfo.work = nil
    self = nil
end

function Apples:removeMarkers()
    if isElement(self.basketMarker) then destroyElement(self.basketMarker) end
    if isElement(self.basketBlip) then destroyElement(self.basketBlip) end
    for i, v in pairs(self.markers) do
        if isElement(v) then destroyElement(v) end
    end
    for i, v in pairs(self.blips) do
        if isElement(v) then destroyElement(v) end
    end

    self.markers = {}
    self.blips = {}
end

function Apples:blockVehicleEnter(plr)
    if plr ~= localPlayer then return end
    cancelEvent()
    exports.TR_noti:create("Bu iş sırasında bu araca binemezsin.", "error")
end

function Apples:createMarkers()
    self.basketMarker = createMarker(1016.2822265625, -337.43801879883, 73.0921875, "cylinder", 1.2, 255, 60, 60, 0)
    setElementData(self.basketMarker, "markerIcon", "apple", false)
    setElementData(self.basketMarker, "markerData", {
        title = "Walton Bagajı",
        desc = "Sepeti almak için yaklaş.",
    }, false)
    addEventHandler("onClientMarkerHit", self.basketMarker, self.func.enterBasketMarker)

    self.basketBlip = createBlip(1016.2822265625, -337.43801879883, 73.0921875, 0, 1, 255, 60, 60, 255)
    setElementData(self.basketBlip, "icon", 22, false)

    for i, v in pairs(guiInfo.markers) do
        local marker = createMarker(v.x, v.y, v.z - 0.9, "cylinder", 1.2, 255, 60, 60, 0)
        setElementData(marker, "markerIcon", "apple", false)
        setElementData(marker, "markerData", {
            title = "Elma Ağacı",
            desc = "Elmaları toplamak için yaklaş.",
        }, false)
        setElementData(marker, "appleID", i, false)

        addEventHandler("onClientMarkerHit", marker, self.func.enterAppleMarker)

        table.insert(self.markers, marker)
    end

    exports.TR_jobs:setPlayerTargetPos(1016.2822265625, -337.43801879883, 74.2921875 - 0.5, 0, 0, "Elma sepetini al.")
    self:randomizeApplesOnTrees()
end

function Apples:randomizeApplesOnTrees()
    for i, v in pairs(self.markers) do
        self.treeApples[i] = {}

        local count = math.random(3, 5)
        for k = 0, count do
            local isRotten = false
            if self.ownedUpgrades[2] then
                if math.random(1, 10) >= 8 then isRotten = true end
            else
                if math.random(1, 10) >= 4 then isRotten = true end
            end

            local pos = self:getRandomApplePosition()
            table.insert(self.treeApples[i], {
                pos = pos,
                rotten = isRotten,
                isGold = self.ownedUpgrades[3] and (math.random(1, 800) == 1 and true or false) or false
            })
        end
    end

    self.appleCount = 0
end

function Apples:getRandomApplePosition()
    return Vector2(math.random(guiInfo.tree.x + 50/zoom, guiInfo.tree.x + guiInfo.tree.w - 50/zoom), math.random(guiInfo.tree.y + 50/zoom, 400/zoom))
end

function Apples:createBlips(veh)
    if veh then
        for i, v in pairs(self.blips) do
            if isElement(v) then destroyElement(v) end
        end
        self.blips = {}

        if isElement(self.basketBlip) then destroyElement(self.basketBlip) end

        self.basketBlip = createBlip(1016.4016113281, -337.50631713867, 73.9921875, 0, 1, 255, 60, 60, 255)
        setElementData(self.basketBlip, "icon", 22, false)
    else
        if isElement(self.basketBlip) then destroyElement(self.basketBlip) end
        for i, v in pairs(guiInfo.markers) do
            local blip = createBlip(v, 0, 1, 255, 60, 60, 255)
            setElementData(blip, "icon", 22, false)
            table.insert(self.blips, blip)
        end
    end
end

function Apples:enterBasketMarker(plr, md)
    if plr ~= localPlayer or not md then return end
    if getPedOccupiedVehicle(localPlayer) then return end

    if self.appleCount < self.appleToGet and self.hasBasket then
        triggerEvent("showCustomMessage", localPlayer, "Wieslaw Norter", "Boş sepetle ne getiriyorsun? Tamamen doldur!", "files/images/npc.png")
        return
    end


    self:createBlips()
    if self.appleCount >= self.appleToGet then
        self:payForJob()
    end

    self.basketApples = {}
    self.appleCount = 0

    exports.TR_jobs:createInformation(jobSettings.name, string.format("Belirlenen elma ağacının altına git ve elma toplamak için topla.\n Sepet kapasitesi: %d/%d", self.appleCount, self.appleToGet))
    if not self.hasBasket then
        triggerServerEvent("attachObjectToBone", resourceRoot, 917, 1, 11, -0.2, 0.1, 0.1, 280, 80, 90)
        exports.TR_hud:blockPlayerSprint(true)
    else
        self.givedApples = self.givedApples + 1
        if self.givedApples >= 3 then
            self.givedApples = 0
            self:randomizeApplesOnTrees()
        end
    end
    -- triggerServerEvent("syncAnim", resourceRoot, "CARRY", "crry_prtial", 1, true)
    setPedAnimation(localPlayer, "CARRY", "crry_prtial", 1, true)
    setElementData(localPlayer, "blockAnim", true, false)

    self.hasBasket = true
    exports.TR_jobs:setPlayerTargetPos(false)
    exports.TR_jobs:setPaymentTime()
end

-- Payment
function Apples:payForJob()
    local payment = self:calculatePayment()
    local paymentType = exports.TR_jobs:getPlayerJobPaymentType()

    for i, v in pairs(self.basketApples) do
        if v.isGold then
            payment = payment + 500
        elseif v.rotten then
            payment = payment - 20
        end
    end

    if payment <= 0 then
        exports.TR_noti:create("Çok fazla çürük elma getirdiniz. Kazanılan para miktarı $0 oldu.", "error")
        return
    end

    exports.TR_jobPayments:giveJobPayment(payment, paymentType, getResourceName(getThisResource()))
end

function Apples:calculatePayment()
    local addMin, addMax = 0, 0
    for i, v in pairs(jobSettings.upgrades) do
        if self.ownedUpgrades[i] and v.additionalMoney then
            addMin = addMin + v.additionalMoney[1]
            addMax = addMax + v.additionalMoney[2]
        end
    end
    return math.min(exports.TR_jobs:getPaymentCount(guiInfo.hourEarning[1] + addMin, guiInfo.hourEarning[2] + addMax), guiInfo.maxEarning + (addMin + addMax)/2)
end

function Apples:enterAppleMarker(source, plr, md)
    if not self.hasBasket then return end
    if plr ~= localPlayer or not md then return end
    if getPedOccupiedVehicle(localPlayer) then return end
    if not exports.TR_dx:canOpenGUI() then return end
    exports.TR_dx:setOpenGUI(true)
    exports.TR_chat:showCustomChat(false)

    showCursor(true)
    setElementFrozen(localPlayer, true)

    self.selectedTree = getElementData(source, "appleID")

    self.tick = getTickCount()
    self.state = "opening"

    self.textures = {}
    self.textures.tree = dxCreateTexture("files/images/tree.png", "argb", true, "clamp")
    self.textures.apple = dxCreateTexture("files/images/apple.png", "argb", true, "clamp")
    self.textures.apple_rotten = dxCreateTexture("files/images/apple_rotten.png", "argb", true, "clamp")
    self.textures.apple_gold = dxCreateTexture("files/images/apple_gold.png", "argb", true, "clamp")
    self.textures.box = dxCreateTexture("files/images/box.png", "argb", true, "clamp")
    self.textures.box_front = dxCreateTexture("files/images/box_front.png", "argb", true, "clamp")

    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientClick", root, self.func.click)
    bindKey("lshift", "down", self.func.closeTree)
    bindKey("rshift", "down", self.func.closeTree)
end

function Apples:closeTree()
    if self.state ~= "opened" then return end
    unbindKey("lshift", "down", self.func.closeTree)
    unbindKey("rshift", "down", self.func.closeTree)

    exports.TR_dx:setOpenGUI(false)
    exports.TR_chat:showCustomChat(true)

    showCursor(false)
    setElementFrozen(localPlayer, false)
    self:moveAppleToDefaultPosition()

    if self.appleCount >= self.appleToGet then
        exports.TR_jobs:createInformation(jobSettings.name, "Sepetiniz dolu. Yeni almak için arabanıza gidin.")
        exports.TR_jobs:setPlayerTargetPos(1016.2822265625, -337.43801879883, 74.2921875 - 0.5, 0, 0, "Elma sepetini bırakın.")
    else
        exports.TR_jobs:createInformation(jobSettings.name, string.format("Seçtiğiniz elma ağacının altına giderek elmaları toplayın.\n Sepet kapasitesi: %d/%d", self.appleCount, self.appleToGet))
    end

    self.tick = getTickCount()
    self.state = "closing"
end

function Apples:removeTextures()
    for i, v in pairs(self.textures) do
        if isElement(v) then destroyElement(v) end
    end
    self.textures = nil
    self.selectedTree = nil

    removeEventHandler("onClientRender", root, self.func.render)
    removeEventHandler("onClientClick", root, self.func.click)
end

function Apples:animate()
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

            self:removeTextures()
            return true
        end
    end
end

function Apples:render()
    if self:animate() then return end

    dxDrawImage(guiInfo.tree.x, guiInfo.tree.y, guiInfo.tree.w, guiInfo.tree.h, self.textures.tree, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
    dxDrawImage(guiInfo.box.x, guiInfo.box.y, guiInfo.box.w, guiInfo.box.h, self.textures.box, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))

    self:drawTreeApples()
    self:drawBasketApples()

    dxDrawImage(guiInfo.box.x, guiInfo.box.y, guiInfo.box.w, guiInfo.box.h, self.textures.box_front, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
    dxDrawText("Ağaçtan ayrılmak için SHIFT tuşuna basın.", 0, 0, sx, sy - 14/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.exit, "center", "bottom")
end

function Apples:drawTreeApples()
    if not self.selectedTree then return end
    for i, v in pairs(self.treeApples[self.selectedTree]) do
        if self.selectedApple == i then
            local cx, cy = getCursorPosition()
            cx, cy = cx * sx, cy * sy

            if v.isGold then
                dxDrawImage(cx - self.appleOffset.x, cy - self.appleOffset.y, guiInfo.apple.size, guiInfo.apple.size, self.textures.apple_gold, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
            elseif v.rotten then
                dxDrawImage(cx - self.appleOffset.x, cy - self.appleOffset.y, guiInfo.apple.size, guiInfo.apple.size, self.textures.apple_rotten, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
            else
                dxDrawImage(cx - self.appleOffset.x, cy - self.appleOffset.y, guiInfo.apple.size, guiInfo.apple.size, self.textures.apple, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
            end
        else
            if v.isGold then
                dxDrawImage(v.pos, guiInfo.apple.size, guiInfo.apple.size, self.textures.apple_gold, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
            elseif v.rotten then
                dxDrawImage(v.pos, guiInfo.apple.size, guiInfo.apple.size, self.textures.apple_rotten, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
            else
                dxDrawImage(v.pos, guiInfo.apple.size, guiInfo.apple.size, self.textures.apple, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
            end
        end
    end
end

function Apples:drawBasketApples()
    for i, v in pairs(self.basketApples) do
        if v.isGold then
            dxDrawImage(v.pos, guiInfo.apple.size, guiInfo.apple.size, self.textures.apple_gold, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
        elseif v.rotten then
            dxDrawImage(v.pos, guiInfo.apple.size, guiInfo.apple.size, self.textures.apple_rotten, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
        else
            dxDrawImage(v.pos, guiInfo.apple.size, guiInfo.apple.size, self.textures.apple, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
        end
    end
end

function Apples:click(...)
    if not self.selectedTree then return end
    if arg[1] == "left" then
        if arg[2] == "down" then
            if self:isMouseInPosition(guiInfo.box.x + 60/zoom, guiInfo.box.y + 10/zoom, guiInfo.box.w - 120/zoom, guiInfo.box.h - 30/zoom) then return end

            local selectedIndex = false
            for i, v in pairs(self.treeApples[self.selectedTree]) do
                if self:isMouseInPosition(v.pos.x, v.pos.y, guiInfo.apple.size, guiInfo.apple.size) then
                    selectedIndex = i
                end
            end
            if not selectedIndex then return end

            local cx, cy = getCursorPosition()
            cx, cy = cx * sx, cy * sy

            self.selectedApple = selectedIndex
            self.defaultApplePos = self.treeApples[self.selectedTree][selectedIndex]
            self.appleOffset = Vector2(cx - self.defaultApplePos.pos.x, cy - self.defaultApplePos.pos.y)

        else
            if self:isMouseInPosition(guiInfo.box.x + 60/zoom, guiInfo.box.y + 10/zoom, guiInfo.box.w - 120/zoom, guiInfo.box.h - 30/zoom) then
                if not self.selectedTree or not self.appleOffset or not self.selectedApple then return end

                if self.appleCount >= self.appleToGet then
                    self:moveAppleToDefaultPosition()
                    exports.TR_noti:create("Sepetiniz dolu ve başka bir elma sığmayacak.", "error")
                    return
                end

                local cx, cy = getCursorPosition()
                cx, cy = cx * sx, cy * sy

                table.insert(self.basketApples, {
                    pos = Vector2(cx - self.appleOffset.x, cy - self.appleOffset.y),
                    rotten = self.treeApples[self.selectedTree][self.selectedApple].rotten,
                    isGold = self.treeApples[self.selectedTree][self.selectedApple].isGold,
                })
                self.treeApples[self.selectedTree][self.selectedApple] = nil
                self.selectedApple = nil
                self.appleCount = self.appleCount + 1

                if self.appleCount == self.appleToGet then
                    self:createBlips(true)
                end

                exports.TR_jobs:createInformation(jobSettings.name, string.format("Seçili elmayı toplamak için ağacın altına gidin.\n Sepet kapasitesi: %d/%d", self.appleCount, self.appleToGet))
            else
                self:moveAppleToDefaultPosition()
            end
        end
    end
end

function Apples:moveAppleToDefaultPosition()
    if not self.selectedApple then return end
    self.treeApples[self.selectedTree][self.selectedApple] = self.defaultApplePos
    self.selectedApple = nil
end

function Apples:isMouseInPosition(x, y, width, height)
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


function startJob(...)
    if guiInfo.work then return end
    guiInfo.work = Apples:create(...)

    exports.TR_jobs:responseJobWindow()
end

function endJob()
    exports.TR_jobs:responseJobWindow()

    if not guiInfo.work then return end
    guiInfo.work:destroy()
end

-- triggerServerEvent("removeAttachedObject", resourceRoot, 917)