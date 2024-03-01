--[[
    Zacznijmy wiecej wymagac ~Xyrusek
    AUTOR: Xyrusek
--]]

--[[
    KOD
--]]


for i, v in ipairs(collectibles) do
    local object = createPickup(v, 3, 1276, 0, 0)
    setElementCollisionsEnabled(object, false)
    local col = createColSphere(v, 1)
    setElementID(col, "collectable"..i)
end


function tryGetCollectible(player, collectibleID)
    if hasPlayerCollectible(player, collectibleID) then
        exports.TR_noti:create(player, "Bu hediyeyi zaten buldun.", "error")
        return
    end
    local playerUID = getPlayerUID(player)
    if not playerUID then return true end
    exports.TR_mysql:querry("INSERT INTO tr_collectibles SET playerUID = ?, collectibleID = ?", playerUID, collectibleID)

    local collectiblesCount = getPlayerCollectiblesCount(player)

    local price = math.random(1, 100) <= 70 and "money" or "points"
    if price == "money" then
        local randomMoney = 100
        if collectiblesCount < #collectibles then
            exports.TR_noti:create(player, string.format("Tebrikler! Bir hediye buldunuz.\nÖdül olarak $%d kazandınız.\nToplanan koleksiyon öğeleri: %d/%d.", randomMoney, collectiblesCount, #collectibles), "parrot", 15)

        elseif collectiblesCount >= #collectibles then
            exports.TR_noti:create(player, string.format("Tebrikler! Bir hediye buldunuz.\nÖdül olarak $%d kazandınız.\nListedeki son hesap olduğu için 3 günlük Gold hesap alıyorsunuz!", randomMoney, collectiblesCount, #collectibles), "parrot", 15)
            exports.TR_api:givePremium(getPlayerName(player), 3, 1, true)
        end
        exports.TR_core:giveMoneyToPlayer(player, randomMoney)

    else
        if collectiblesCount < #collectibles then
            local points = math.random(2, 4)
            exports.TR_noti:create(player, string.format("Tebrikler! Bir hediye buldunuz.\Ödül olarak deneyim puanı aldınız.\Toplanan koleksiyon: %d/%d.", points, collectiblesCount, #collectibles), "parrot", 15)

            local plrPoints = getElementData(player, "characterPoints") or 0
            setElementData(player, "characterPoints", plrPoints + points)

        elseif collectiblesCount >= #collectibles then
            exports.TR_noti:create(player, string.format("Tebrikler! Bir hediye buldunuz.\Ödül olarak $%d kazandınız.\nListedeki son hesap olduğu için 3 günlük bir Gold hesap alıyorsunuz!", randomMoney, collectiblesCount, #collectibles), "parrot", 15)
            exports.TR_api:givePremium(getPlayerName(player), 3, 1, true)
        end
    end
end

addEvent("TR_collectibles:tryGetCollectible", true)
addEventHandler("TR_collectibles:tryGetCollectible", getResourceRootElement(), function(collectibleID)
    if not client or not collectibleID then return false end
    tryGetCollectible(client, collectibleID)
end)

function hasPlayerCollectible(player, collectibleID)
    local playerUID = getPlayerUID(player)
    if not playerUID then return true end
    local q = exports.TR_mysql:querry("SELECT collectibleID FROM tr_collectibles WHERE playerUID=? AND collectibleID=? LIMIT 1", playerUID, collectibleID)
    return (q and #q > 0)
end

function getPlayerCollectiblesCount(player)
    local playerUID = getPlayerUID(player)
    if not playerUID then return true end
    local q = exports.TR_mysql:querry("SELECT COUNT(collectibleID) AS count FROM tr_collectibles WHERE playerUID=? LIMIT ?", playerUID, #collectibles)
    return (q and #q > 0 and q[1].count or 0)
end

function getPlayerUID(player)
    return getElementData(player, "characterUID")
end

function updatePlayerPremium(plr, rank)
    if not plr then return end
    if not getElementData(plr, "characterData") then return end

    local data = getElementData(plr, "characterData")
    if data.premium == "diamond" and rank == "gold" then return end
    data.premium = rank
    setElementData(plr, "characterData", data)
end

function getPlayerCollectibles()
    local count = getPlayerCollectiblesCount(source)
    exports.TR_noti:create(source, string.format("Toplanan koleksiyon: %d/%d.", count, #collectibles), "parrot")
end
addEvent("getPlayerCollectibles", true)
addEventHandler("getPlayerCollectibles", root, getPlayerCollectibles)
exports.TR_chat:addCommand("koleksiyon", "getPlayerCollectibles")
