local createdGates = {}
local createdZones = {}
local settings = {
    canDrop = {
        {
            type = "Marihuana Tohumu",
            variant = 0,
            variant2 = 0,
            count = {4, 20},
        },
        {
            type = "Haşhaş Tohumu",
            variant = 0,
            variant2 = 1,
            count = {4, 20},
        },
        {
            type = "Organik Gübre",
            variant = 0,
            variant2 = 2,
            count = {2, 10},
        },

        {
            type = "Fenilaseton",
            variant = 1,
            variant2 = 0,
            count = {1, 5},
        },
        {
            type = "Metilamin",
            variant = 1,
            variant2 = 1,
            count = {2, 10},
        },
        {
            type = "Kızılağaç Yaprağı",
            variant = 1,
            variant2 = 2,
            count = {4, 20},
        },

        {
            type = "Silah Parçaları",
            variant = 2,
            variant2 = 0,
            count = {100, 500},
        },
        {
            type = "Silah Susturucusu",
            variant = 2,
            variant2 = 1,
            count = {1, 3},
        },
        {
            type = "Silah Dipçiği",
            variant = 2,
            variant2 = 2,
            count = {1, 3},
        },
    },
}

function createGates()
    for i, v in pairs(DocksGates) do
        local gate = createObject(16775, v.pos, v.rot)
        setObjectScale(gate, v.scale)

        setElementData(gate, "gateData",
        {
            model = 16775,
            defPos = {x = v.pos.x, y = v.pos.y, z = v.pos.z},
            defRot = {x = v.rot.x, y = v.rot.y, z = v.rot.z},
        })

        table.insert(createdGates, {
            gate = gate,
        })
    end

    for i, v in pairs(DocksZones) do
        createdZones[i] = createColCuboid(v.pos, v.width, v.lenght, v.height)

        local chest = createObject(2991, v.chest.pos, v.chest.rot)
        setElementData(chest, "dockZone", i)
    end

    createNpcs()

    checkGates()
    setTimer(checkGates, 60000, 0)
end

function checkGates()
    local time = getRealTime()
    if time.minute < 20 then
        local magazines = exports.TR_mysql:querry("SELECT COUNT(ID) as magazines FROM tr_gangOrders WHERE orderDate = CURDATE() AND orderHour = ? LIMIT 3", time.hour)
        if magazines and magazines[1] then
            settings.opened = true
            for i = 1, tonumber(magazines[1].magazines) do
                setElementData(createdGates[i].gate, "open", true)
                randomizeItems(i)
            end
        end

    else
        for i, v in pairs(createdGates) do
            setElementData(v.gate, "open", nil)
        end
        if settings.opened then
            setTimer(function()
                for i, _ in pairs(DocksZones) do
                    for _, plr in pairs(getElementsWithinColShape(createdZones[i])) do
                        setElementPosition(plr, DocksZones[i].exit)
                    end
                end
            end, 15000, 1)

            settings.opened = nil
            exports.TR_mysql:querry("DELETE FROM tr_items WHERE ownedType = 20")
        end
    end
end

function randomizeItems(i)
    local dropped = {}
    local droppedCount = 0

    local random = math.random(1, #settings.canDrop)
    while droppedCount < 3 do
        local data = settings.canDrop[random]

        if not dropped[data.type] then
            dropped[data.type] = data
            droppedCount = droppedCount + 1
        end
        random = math.random(1, #settings.canDrop)
    end

    for _, v in pairs(dropped) do
        exports.TR_mysql:querry("INSERT INTO `tr_items`(ownedType, owner, type, variant, variant2, value2) VALUES (20, ?, 24, ?, ?, ?)", i, v.variant, v.variant2, math.random(v.count[1], v.count[2]))
    end
end

function createNpcs()
    local dialogue = exports.TR_npc:createDialogue()
    exports.TR_npc:addDialogueText(dialogue, "Merhaba. Bir konteyner satın almak istiyorum.", {pedResponse = "Böyle bir şey yapabileceğimden emin değilim. Konteynerler müşterilerimize ait ve satmam gerektiğini düşünmüyorum."})
    exports.TR_npc:addDialogueText(dialogue, "Tamam ödeyeceğim. ($5000)", {pedResponse = "Hmm... Aslında gemi yolculuğu sırasında konteynerin kaybolduğunu söyleyebilirim. Anlaşma geçerli. Sadece hangi saatte buluşmak istiyorsunuz?", responseTo = "Merhaba. Bir konteyner satın almak istiyorum."})
    for i = 0, 23, 2 do
        exports.TR_npc:addDialogueText(dialogue, string.format("%d:00 en iyisi olur.", i + 1), {pedResponse = "", responseTo = "Tamam ödeyeceğim. ($5000)", trigger = "buyGangDocks", triggerData = i + 1, img = "dialogue"})
    end
    exports.TR_npc:addDialogueText(dialogue, "Hiçbir saat bana uymuyor.", {pedResponse = "Tamam o zaman başka bir zaman gelin, belki o zaman anlaşabiliriz.", responseTo = "Tamam ödeyeceğim. ($5000)"})

    exports.TR_npc:addDialogueText(dialogue, "Ne yazık ki.", {pedResponse = "Boş zamanım olduğunda gelip taşımacılık yapabilirsiniz.", responseTo = "Merhaba. Bir konteyner satın almak istiyorum."})
    exports.TR_npc:addDialogueText(dialogue, "Görüşürüz.", {pedResponse = "Görüşürüz."})

    for i, v in pairs(DocksNPCs) do
        local ped = exports.TR_npc:createNPC(v.skin, v.pos.x, v.pos.y, v.pos.z, v.rot, v.name, "Doklar Müdürü", "dialogue")
        exports.TR_npc:setNPCDialogue(ped, dialogue)
    end
end
createGates()



function buyGangDocks(ped, hour)
    local pedName = getElementData(ped, "name")
    local time = getRealTime()
    local orgID = getElementData(client, "characterOrgID")
    local orgType = getElementData(client, "characterOrgType")

    if not orgID or orgType ~= "crime" then
        triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Beni kandırmaya mı çalışıyorsun? Sıradan vatandaşlara güvenmiyorum. Görüşürüz!", "files/images/npc.png")
        return
    end

    local hadOrderToday = exports.TR_mysql:querry("SELECT ID FROM tr_gangOrders WHERE orderDate = CURDATE() AND orgID = ? LIMIT 1", orgID)
    if hadOrderToday and hadOrderToday[1] then
        triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Bugün zaten bir depo sağladım size. Defol buradan!", "files/images/npc.png")
        return
    end

    local hourOrders = exports.TR_mysql:querry("SELECT ID FROM tr_gangOrders WHERE orderDate = CURDATE() AND orderHour = ? LIMIT 3", hour)
    if hourOrders and #hourOrders >= 3 then
        triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Bu saate kadar tüm depolarım dolu. Üzgünüm.", "files/images/npc.png")
        return
    end

    if hour < time.hour then
        triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, string.format("Özür dilerim ama dürüst insanlar olduğumuzu düşünmüştüm ve hiçbir şaka yapmayacağımızı düşünüyordum. Bugün saat %d:00 için teslimat ayarlamamı nasıl istersiniz?", hour), "files/images/npc.png")
        return
    end

    if not exports.TR_core:takeMoneyFromPlayer(client, 5000) then
        triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "$5000 yanınızda yok. Kartla ödeme yapmıyorum. Çok tehlikeli.", "files/images/npc.png")
        return
    end

    exports.TR_mysql:querry("INSERT INTO tr_gangOrders (orgID, orderHour, orderDate) VALUES (?, ?, CURDATE())", orgID, hour)
    triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, string.format("O zaman saat %d:00'da depomuzu açacağız ama 20 dakikadan fazla değil. Kimin gelip gelmeyeceği beni ilgilendirmiyor, sadece saati iyi takip edin.", hour), "files/images/npc.png")
end
addEvent("buyGangDocks", true)
addEventHandler("buyGangDocks", root, buyGangDocks)




-- exports.TR_mysql:querry("DELETE FROM tr_items WHERE ownedType = 20")
-- randomizeItems(1)