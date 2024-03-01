local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    dontHaveMessages = {
        "Nasıl olur da yok? Herkes seni tavsiye ediyor ve sahip olacağını söylüyorlar, peki burada ne var?! Hoşçakal.",
        "Bu ürüne sahip değilsin mi? Bir başka pazar günü satıcısı daha bulundu!",
        "İhtiyacım olanı bulamıyorum. Rezalet! Buradan çekiliyorum.",
    },
    buyMessages = {
        "İş yapmak seninle keyifli, iletişimde kalalım.",
        "Daha fazla pisliğe ihtiyacım olduğunda geleceğim, kendine iyi bak.",
        "Umarım satın almak için pişman olmam.",
    },
    tooBigPriceMessages = {
        "Delirdin mi? Bu kadar çok mu? Pfff... Başka birini bulurum.",
        "Kesinlikle çok fazla istiyorsun, buradan çekiliyorum.",
        "Seninle iş yapmak mantıklı değil. Fiyatların uzaydan geliyor gibi.",
    },
    iHaveDrugs = {"evet", "doğru", "kesinlikle", "elbette", "en fazla", "var"},
    needs = {
        {
            itemType = 18,
            itemVariant = 0,
            itemVariant2 = 0,
            productName = "haszyszu",
            price = 130,
            offset = 35,
        },
        {
            itemType = 18,
            itemVariant = 0,
            itemVariant2 = 1,
            productName = "marihuany",
            price = 130,
            offset = 35,
        },
        {
            itemType = 18,
            itemVariant = 1,
            itemVariant2 = 0,
            productName = "heroiny",
            price = 270,
            offset = 50,
        },
        {
            itemType = 18,
            itemVariant = 1,
            itemVariant2 = 1,
            productName = "LSD",
            price = 100,
            offset = 30,
        },
        {
            itemType = 18,
            itemVariant = 1,
            itemVariant2 = 2,
            productName = "MDMA",
            price = 120,
            offset = 30,
        },
        {
            itemType = 18,
            itemVariant = 1,
            itemVariant2 = 3,
            productName = "DMT",
            price = 230,
            offset = 40,
        },
        {
            itemType = 18,
            itemVariant = 1,
            itemVariant2 = 4,
            productName = "cracku",
            price = 120,
            offset = 30,
        },
        {
            itemType = 18,
            itemVariant = 2,
            itemVariant2 = 0,
            productName = "kokainy",
            price = 295,
            offset = 40,
        },
        {
            itemType = 18,
            itemVariant = 2,
            itemVariant2 = 1,
            productName = "amfetaminy",
            price = 270,
            offset = 50,
        },
        {
            itemType = 18,
            itemVariant = 2,
            itemVariant2 = 2,
            productName = "metaamfetaminy",
            price = 285,
            offset = 60,
        },
        {
            itemType = 18,
            itemVariant = 3,
            itemVariant2 = 0,
            productName = "xanaxu",
            price = 100,
            offset = 30,
        },
        {
            itemType = 18,
            itemVariant = 3,
            itemVariant2 = 1,
            productName = "adderallu",
            price = 100,
            offset = 20,
        },
    },

    newPedTime = {12, 20},
    totalTime = 1800000,
    avaliableSkins = {7,21,22,23,25,28,29,30,41,47,170,190,192,193,195},
    pedDistance = 8,
}

Corners = {}
Corners.__index = Corners

function Corners:create(zoneID)
    local instance = {}
    setmetatable(instance, Corners)
    if instance:constructor(zoneID) then
        return instance
    end
    return false
end

function Corners:constructor(zoneID)
    self.first = true
    self.zoneID = zoneID
    self.startTick = getTickCount()

    self.func = {}
    self.func.render = function() self:render() end
    self.func.npcAway = function() self:npcAway() end
    self.func.createNextCustomer = function() self:createNextCustomer() end

    addEventHandler("onClientRender", root, self.func.render)

    self.timer = setTimer(self.func.createNextCustomer, math.random(guiInfo.newPedTime[1], guiInfo.newPedTime[2]) * 1000, 1)
    exports.TR_noti:create("Uyuşturucu satışına başladınız. Yakında ilk müşterileriniz gelmeli, ancak polisi unutmayın.", "success", 10)

    exports.TR_noti:create("Köşe bu bildirimle sona erecek.", "info", guiInfo.totalTime/1000)

    setElementData(localPlayer, "animation", {"dealer", "dealer_idle"})
    self:toggleControl(false)
    setElementData(localPlayer, "cornerEnabled", true)
    triggerServerEvent("onCornerStarted", resourceRoot, self.zoneID)
    return true
end

function Corners:destroy()
    if isTimer(self.timer) then killTimer(self.timer) end

    self:destroyNpc()
    self:toggleControl(true)

    setElementData(localPlayer, "cornerEnabled", nil)
    setElementData(localPlayer, "animation", nil)

    exports.TR_noti:create("Satış tamamlandı.", "info")
    removeEventHandler("onClientRender", root, self.func.render)

    guiInfo.system = nil
    self = nil
end

function Corners:npcAway()
    if self.npcStatus == "bought" then
        self.npcStatus = "goAway"
        setElementData(self.npc, "animation", {"dealer", "dealer_deal"}, false)

        setTimer(function()
            local _, _, rot = getElementRotation(localPlayer)
            setElementRotation(self.npc, 0, 0, rot)

            setElementData(self.npc, "animation", {"ped", "walk_player", false, true}, false)
            setPedAnimation(self.npc, "ped", "walk_player", -1, true, true, false)
            self.npcState = "hide"
            self.npcTick = getTickCount()

            self.timer = setTimer(self.func.createNextCustomer, math.random(guiInfo.newPedTime[1], guiInfo.newPedTime[2]) * 1000, 1)
            self.offeredPrice = nil
            self.hasItem = nil
        end, 4000, 1)
    else
        self.npcStatus = "goAway"
        setElementData(self.npc, "animation", {"ped", "endchat_02"}, false)

        setTimer(function()
            local _, _, rot = getElementRotation(localPlayer)
            setElementRotation(self.npc, 0, 0, rot)

            setElementData(self.npc, "animation", {"ped", "walk_player", false, true}, false)
            setPedAnimation(self.npc, "ped", "walk_player", -1, true, true, false)
            self.npcState = "hide"
            self.npcStatus = "goAway"
            self.npcTick = getTickCount()

            self.timer = setTimer(self.func.createNextCustomer, math.random(guiInfo.newPedTime[1], guiInfo.newPedTime[2]) * 1000, 1)
            self.offeredPrice = nil
            self.hasItem = nil
        end, 3000, 1)
    end
end

function Corners:render()
    self:moveNpc()
    if (getTickCount() - self.startTick)/guiInfo.totalTime >= 1 then
        self:destroy()
    end
end


function Corners:destroyNpc()
    if isElement(self.npc) then destroyElement(self.npc) end
    self.npc = nil
end

function Corners:moveNpc()
    if not self.npc then return end

    if self.npcState == "show" then
        local progress = (getTickCount() - self.npcTick)/1500
        local alpha = interpolateBetween(0, 0, 0, 255, 0, 0, progress, "Linear")

        setElementAlpha(self.npc, alpha)

        if progress >= 1 then
            self.npcState = nil
            self.npcTick = nil
        end

    elseif self.npcState == "hide" then
        local progress = (getTickCount() - self.npcTick)/1500
        local alpha = interpolateBetween(255, 0, 0, 0, 0, 0, progress, "Linear")

        setElementAlpha(self.npc, alpha)

        if progress >= 1 then
            self.npcState = nil
            self.npcTick = nil
            self:destroyNpc()
            self.first = nil
            self.npcStatus = false
            return
        end
    end

    local plrPos = Vector3(getElementPosition(localPlayer))
    local npcPos = Vector3(getElementPosition(self.npc))
    if getDistanceBetweenPoints2D(plrPos.x, plrPos.y, npcPos.x, npcPos.y) < 1 and not self.npcStatus then
        setElementData(self.npc, "animation", nil, false)
        setPedAnimation(self.npc, nil, nil)
        self.npcStatus = true
        self.npcStatus = "near"

        self:setNpcNeeds()
    end
end

function Corners:setNpcNeeds()
    self.npcNeeds = guiInfo.needs[math.random(1, #guiInfo.needs)]
    self.npcNeedsPrice = math.random(self.npcNeeds.price - self.npcNeeds.offset, self.npcNeeds.price + self.npcNeeds.offset)

    exports.TR_chat:showCustomMessage("Yabancı", string.format("Merhaba. Biraz %s'ye ihtiyacım var. Yanında var mı acaba?", self.npcNeeds.productName), "files/images/npc.png")

    if self.first then
        exports.TR_noti:create("Yabancıya sohbet üzerinden cevap verin.", "info", 5)
    end
end

function Corners:createNextCustomer()
    local plrPos = Vector3(getElementPosition(localPlayer))
    local x, y, z = getPosition(localPlayer, Vector3(0, guiInfo.pedDistance, 0))
    local rot = findRotation(x, y, plrPos.x, plrPos.y)

    local skin = guiInfo.avaliableSkins[math.random(1, #guiInfo.avaliableSkins)]
    self.npc = createPed(skin, x, y, plrPos.z, rot, false)

    setElementData(self.npc, "name", "Yabancı", false)
    setElementData(self.npc, "role", "Vatandaş", false)
    setElementData(self.npc, "blockAction", true, false)
    setElementData(self.npc, "animation", {"ped", "walk_player", false, true}, false)
    setPedAnimation(self.npc, "ped", "walk_player", -1, true, true, false)
    for i, v in pairs(getElementsByType("player", root, true)) do
        setElementCollidableWith(self.npc, v, false)
    end
    for i, v in pairs(getElementsByType("vehicle", root, true)) do
        setElementCollidableWith(self.npc, v, false)
    end

    self.npcStatus = false
    self.npcState = "show"
    self.npcTick = getTickCount()
end

function Corners:useCornerChat(msg)
    if self.npcStatus == "near" or self.npcStatus == "checkAgain" then
        local has = false
        for i, v in pairs(guiInfo.iHaveDrugs) do
            if utf8.find(utf8.lower(msg), v) then
                has = true
                break
            end
        end

        if has then
            self.hasItem = exports.TR_items:hasPlayerItem(self.npcNeeds.itemType, self.npcNeeds.itemVariant, self.npcNeeds.itemVariant2)
            if not self.hasItem then
                if self.npcStatus == "checkAgain" then
                    exports.TR_chat:showCustomMessage("Yabancı", "Neden yalan söylüyorsun? Eğer yoksa, yok dediğini söyle.", "files/images/npc.png")
                    self:npcAway()
                else
                    exports.TR_chat:showCustomMessage("Yabancı", "Emin misin? Bir kez daha düşün.", "files/images/npc.png")
                    self.npcStatus = "checkAgain"
                end
                return
            end

            exports.TR_chat:showCustomMessage("Yabancı", string.format("Bunun için ne kadar istersin? Ben $%.2f teklif ediyorum.", self.npcNeedsPrice), "files/images/npc.png")
            self.npcStatus = "setPrice"

        elseif utf8.find(utf8.lower(msg), "nie") then
            self:npcAway()
            exports.TR_chat:showCustomMessage("Yabancı", guiInfo.dontHaveMessages[math.random(1, #guiInfo.dontHaveMessages)], "files/images/npc.png")
        end

    elseif self.npcStatus == "setPrice" then
        local price = tonumber(msg)
        if price == nil then exports.TR_noti:create("Geçerli bir fiyat girin.", "error") return end
        if price < 0 then exports.TR_noti:create("Geçerli bir fiyat girin.", "error") return end

        if price < self.npcNeedsPrice then
            exports.TR_chat:showCustomMessage("Yabancı", "Wow, düşündüğümden daha ucuz. Harika.", "files/images/npc.png")
            self:performBuy(price)
            self:npcAway()

        elseif price == self.npcNeedsPrice then
            exports.TR_chat:showCustomMessage("Yabancı", guiInfo.buyMessages[math.random(1, #guiInfo.buyMessages)], "files/images/npc.png")
            self:performBuy(price)
            self:npcAway()

        elseif price > self.npcNeedsPrice + self.npcNeeds.offset then
            exports.TR_chat:showCustomMessage("Yabancı", guiInfo.tooBigPriceMessages[math.random(1, #guiInfo.tooBigPriceMessages)], "files/images/npc.png")
            self:npcAway()
        else
            local add = price - self.npcNeedsPrice
            local percent = add/self.npcNeeds.offset

            if self.offeredPrice then
                if price >= self.offeredPrice then
                    exports.TR_chat:showCustomMessage("Yabancı", "Görüyorum ki fırsatı kullanamıyorsun. Üzücü.", "files/images/npc.png")
                    self:npcAway()
                    return
                end
            end

            if math.random(1, 100)/100 > percent then
                exports.TR_chat:showCustomMessage("Yabancı", guiInfo.buyMessages[math.random(1, #guiInfo.buyMessages)], "files/images/npc.png")
                self:performBuy(price)
                self:npcAway()

            else
                if math.random(0, 1) == 0 and not self.offeredPrice then
                    exports.TR_chat:showCustomMessage("Yabancı", "Kafan mı karıştı? İyi bir fiyat için hala bir şansın var.", "files/images/npc.png")
                    self.offeredPrice = price

                else
                    exports.TR_chat:showCustomMessage("Yabancı", guiInfo.tooBigPriceMessages[math.random(1, #guiInfo.tooBigPriceMessages)], "files/images/npc.png")
                    self:npcAway()
                end
            end

        end
    end
end

function Corners:performBuy(price)
    self.npcStatus = "bought"
    exports.TR_items:takePlayerItem(self.hasItem)
    triggerServerEvent("removeItem", resourceRoot, self.hasItem, true)
    triggerServerEvent("payForDrugs", resourceRoot, price)
    exports.TR_noti:create("İşlem başarıyla gerçekleşti.", "success")

    setElementData(localPlayer, "animation", {"dealer", "dealer_deal"})
    setTimer(function()
        setElementData(localPlayer, "animation", {"dealer", "dealer_idle"})
    end, 3000, 1)
end


function Corners:isCornerChatEnabled(state)
    if self.npcStatus then return true end
    return false
end

function Corners:toggleControl(state)
    toggleControl("walk", state)
    toggleControl("forwards", state)
    toggleControl("backwards", state)
    toggleControl("left", state)
    toggleControl("right", state)
    toggleControl("action", state)
    toggleControl("fire", state)
    toggleControl("aim_weapon", state)
    setElementFrozen(localPlayer, not state)
end




function enableCorner(zoneID)
    if not canEnableCorner() then exports.TR_noti:create("Bu bölgede satışa başlayamazsınız.", "error") return end
    if guiInfo.system then return end
    guiInfo.system = Corners:create(zoneID)
end
addEvent("enableCorner", true)
addEventHandler("enableCorner", root, enableCorner)
function disableCorner()
    if guiInfo.system then
        guiInfo.system:destroy()
    end
end
addEvent("disableCorner", true)
addEventHandler("disableCorner", root, disableCorner)


function canEnableCorner()
    local x, y, z = getPosition(localPlayer, Vector3(0, guiInfo.pedDistance, 0))
    local hit, x, y, z, elementHit = processLineOfSight(Vector3(getElementPosition(localPlayer)), x, y, z, true, true, false, true, true, false, false, false, localPlayer)

    if hit or isElement(elementHit) then return false end
    return true
end

function useCornerChat(...)
    if not guiInfo.system then return end
    guiInfo.system:useCornerChat(...)
end

function isCornerEnabled()
    if not guiInfo.system then return false end
    return guiInfo.system:isCornerChatEnabled()
end



-- Utils
function getPosition(element, vec)
	local rot = Vector3(getElementRotation(element))
	local mat = Matrix(Vector3(getElementPosition(element)), rot)
	local newPos = mat:transformPosition(vec)
	return newPos.x, newPos.y, newPos.z, rot.z
end

function findRotation(x1, y1, x2, y2)
    local t = -math.deg(math.atan2(x2 - x1, y2 - y1))
    return t < 0 and t + 360 or t
end

setElementData(localPlayer, "cornerEnabled", nil)