Equipment = {}
Equipment.__index = Equipment

function Equipment:create(...)
    local instance = {}
    setmetatable(instance, Equipment)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function Equipment:constructor()
    self.func = {}
    self.func.opener = function(...) self:open(...) end

    return true
end

function Equipment:open(...)
    local uid = getElementData(arg[1], "characterUID")
    if not uid then return end

    exports.TR_mysql:querryAsyncMultiselect(
        {
            callback = "onLoadPlayerItems",
            plr = arg[1],
            open = arg[2],
        },
        [[
            SELECT ID, type, variant, variant2, value, value2, durability, used, favourite FROM tr_items WHERE owner = ? AND ownedType = 0;
            SELECT ID, model FROM tr_vehicles WHERE ownedPlayer = ?;
            SELECT ID, pos FROM tr_houses WHERE owner = ? AND date > NOW();
        ]], uid, uid, uid)
end

function Equipment:setFavourite(...)
    if not getElementData(arg[1], "characterUID") then return end
    exports.TR_mysql:querry(string.format("UPDATE tr_items SET favourite = %s WHERE ID = ? LIMIT 1", arg[3] and "1" or "NULL"), arg[2])

    if arg[3] then
        triggerClientEvent(arg[1], "equipmentResponse", resourceRoot, "Öğe favorilere eklendi.")
    else
        triggerClientEvent(arg[1], "equipmentResponse", resourceRoot, "Öğe favorilerden kaldırıldı.")
    end
end

function Equipment:removeItem(...)
    if not getElementData(arg[1], "characterUID") then return end

    if not arg[3] then
        triggerClientEvent(arg[1], "equipmentResponse", resourceRoot, "Öğe başarıyla yok edildi.")
        exports.TR_mysql:querryAsyncWithoutResponse("DELETE FROM tr_items WHERE ID = ? LIMIT 1", arg[2])
    else
        exports.TR_mysql:querryAsyncWithoutResponse("UPDATE tr_items SET value2 = value2 - 1 WHERE ID = ? LIMIT 1; DELETE FROM tr_items WHERE ID = ? AND value2 <= 0 LIMIT 1", arg[2], arg[2])
    end
end

function Equipment:mergeItems(plr, id, type, value, value2)
    local uid = getElementData(plr, "characterUID")
    local items = exports.TR_mysql:querry("SELECT SUM(value2) as sum FROM tr_items WHERE type = ? AND variant = ? AND variant2 = ? AND ID != ? AND owner = ? AND ownedType = 0", type, value, value2, id, uid)

    exports.TR_mysql:querry("UPDATE tr_items SET value2 = value2 + ? WHERE ID = ? LIMIT 1", items[1].sum, id)
    exports.TR_mysql:querry("DELETE FROM tr_items WHERE type = ? AND variant = ? AND variant2 = ? AND ID != ? AND owner = ? AND ownedType = 0", type, value, value2, id, uid)

    triggerClientEvent(plr, "equipmentResponse", resourceRoot, "Öğeler birleştirilerek tek bir öğe haline getirildi.")
end

function Equipment:splitItems(plr, id, count)
    local uid = getElementData(plr, "characterUID")

    local itemData = exports.TR_mysql:querry("SELECT * FROM tr_items WHERE ID = ? AND ownedType = 0 LIMIT 1", id)
    exports.TR_mysql:querry("UPDATE tr_items SET value2 = value2 - ? WHERE ID = ? LIMIT 1", count, id)
    exports.TR_mysql:querry("INSERT INTO tr_items (favourite, used, owner, type, variant, variant2, value, value2) VALUES (NULL, NULL, ?, ?, ?, ?, ?, ?)", uid, itemData[1].type, itemData[1].variant, itemData[1].variant2, itemData[1].value, count)

    self:open(plr)
end

function Equipment:takeItemCount(plr, id, count)
    exports.TR_mysql:querryAsyncWithoutResponse("UPDATE tr_items SET value2 = value2 - ? WHERE ID = ? LIMIT 1; DELETE FROM tr_items WHERE ID = ? AND value2 <= 0 LIMIT 1", count, id, id)
    self:open(plr)
end

function Equipment:createItem(plr, type, variant, variant2, value, value2)
    local uid = getElementData(plr, "characterUID")
    exports.TR_mysql:querryAsyncWithoutResponse(string.format("INSERT INTO tr_items (owner, type, variant, variant2, value, value2) VALUES (?, ?, ?, ?, %s, %s)", value and tostring(value) or "NULL", value2 and tostring(value2) or "1"), uid, type, variant, variant2)
    self:open(plr)
end

function Equipment:useItem(...)
    if not arg[1] then return end
    if arg[4] == itemTypes.clothes then
        local uid = getElementData(arg[1], "characterUID")
        local data = getElementData(arg[1], "characterData")
        local customModel = getElementData(arg[1], "customModel")

        if arg[3] then
            if customModel then
                if data.skin ~= model then triggerClientEvent(arg[1], "equipmentResponse", resourceRoot, "Zaten başka bir kıyafet giydiğin için bu kıyafeti giyemezsin.", "error") return end
            else
                if getElementModel(arg[1]) ~= 0 then triggerClientEvent(arg[1], "equipmentResponse", resourceRoot, "Zaten başka bir kıyafet giydiğin için bu kıyafeti giyemezsin.", "error") return end
            end
        end

        if not arg[3] then
            if customModel then
                if getElementModel(arg[1]) ~= 0 then triggerClientEvent(arg[1], "equipmentResponse", resourceRoot, "Şu an bu kıyafeti çıkaramazsın.", "error") return end
            else
                if getElementModel(arg[1]) ~= tonumber(data.skin) then triggerClientEvent(arg[1], "equipmentResponse", resourceRoot, "Şu an bu kıyafeti çıkaramazsın.", "error") return end
            end
        end

        local model, text = arg[5], "Kıyafet giyildi."
        if data.skin == model then
            model = 0
            text = "Kıyafet çıkarıldı."
        end

        if tonumber(model) ~= nil then
            setElementModel(arg[1], model)
            setElementData(arg[1], "customModel", nil)
        else
            setElementModel(arg[1], 0)
            setElementData(arg[1], "customModel", model)
        end

        data.skin = tostring(model)
        setElementData(arg[1], "characterData", data)

        triggerClientEvent(arg[1], "equipmentResponse", resourceRoot, text, "info", true)
        exports.TR_mysql:querry("UPDATE tr_accounts SET skin = ? WHERE UID = ? LIMIT 1", model, uid)
        exports.TR_mysql:querry(string.format("UPDATE tr_items SET used = %s WHERE ID = ? LIMIT 1", arg[3] and "1" or "NULL"), arg[2])

    elseif arg[4] == itemTypes.weapon then
        if not arg[3] then
            if tonumber(arg[6]) == 1 and (tonumber(arg[7]) >= 4 and tonumber(arg[7]) <= 12) then
                exports.TR_weaponSlots:takeWeapon(arg[1], 7, 999999999)
                triggerClientEvent(arg[1], "equipmentResponse", resourceRoot, "Olta saklandı.", "success", true)

            else
                exports.TR_weaponSlots:takeWeapon(arg[1], arg[5], 999999999)
                triggerClientEvent(arg[1], "equipmentResponse", resourceRoot, "Silah saklandı.", "success", true)
            end
        else
            local weapon = tonumber(arg[5])
            local variant = tonumber(arg[6])
            local variant1 = tonumber(arg[7])
            if tonumber(arg[6]) == 1 and (tonumber(arg[7]) >= 4 and tonumber(arg[7]) <= 12) then
                exports.TR_weaponSlots:giveWeapon(arg[1], 7, 999999, false)
                triggerClientEvent(arg[1], "equipmentResponse", resourceRoot, "Olta donatıldı.", "success", true)

            elseif weaponsWithoutAmmo[weapon] then
                exports.TR_weaponSlots:giveWeapon(arg[1], weapon, 999999, false)
                triggerClientEvent(arg[1], "equipmentResponse", resourceRoot, "Silah donatıldı.", "success", true)

            else
                local uid = getElementData(arg[1], "characterUID")
                local ammo = exports.TR_mysql:querry("SELECT SUM(value) as ammunition FROM tr_items WHERE type = 10 AND variant = ? AND owner = ? AND ownedType = 0", weaponAmmoType[weapon], uid)
                if ammo and ammo[1].ammunition then
                    if ammo[1].ammunition == 0 then
                        triggerClientEvent(arg[1], "equipmentResponse", resourceRoot, "Bu silaha ait mermiye sahip değilsin.", "error", false)
                        return
                    end

                    exports.TR_weaponSlots:giveWeapon(arg[1], weapon, ammo[1].ammunition, false)
                    triggerClientEvent(arg[1], "equipmentResponse", resourceRoot, "Silah donatıldı.", "success", true)
                else
                    triggerClientEvent(arg[1], "equipmentResponse", resourceRoot, "Bu silaha ait mermiye sahip değilsin.", "error", false)
                    return
                end
            end
        end

        exports.TR_mysql:querry(string.format("UPDATE tr_items SET used = %s WHERE ID = ? LIMIT 1", arg[3] and "1" or "NULL"), arg[2])

    elseif arg[4] == itemTypes.armor then
        if not arg[3] then
            removeElementData(arg[1], "armorID")
            setPedArmor(arg[1], 0)
            triggerClientEvent(arg[1], "equipmentResponse", resourceRoot, "Kurşun geçirmez yelek çıkarıldı.", "success", true)

        else
            local armor = getElementData(arg[1], "armorID")
            if armor then
                triggerClientEvent(arg[1], "equipmentResponse", resourceRoot, "Zaten bir yelek giymişsin.", "error", false)
                return
            end

            setElementData(arg[1], "armorID", arg[2])
            setPedArmor(arg[1], arg[5])
            triggerClientEvent(arg[1], "equipmentResponse", resourceRoot, "Kurşun geçirmez yelek giyildi.", "success", true)
        end
        exports.TR_mysql:querry(string.format("UPDATE tr_items SET used = %s WHERE ID = ? LIMIT 1", arg[3] and "1" or "NULL"), arg[2])

    elseif arg[4] == itemTypes.armorplate then
        local armorID = getElementData(arg[1], "armorID")
        local armor = getPedArmor(arg[1])

        if not armorID then
            triggerClientEvent(arg[1], "equipmentResponse", resourceRoot, "Hiçbir kurşun geçirmez yelek giymemişsin.", "error", false)
            return
        end

        if armor == 100 then
            triggerClientEvent(arg[1], "equipmentResponse", resourceRoot, "Plağı değiştirebilmek için yeleğin hasar görmüş olması gerekiyor.", "error", false)
            return
        end

        setPedArmor(arg[1], math.min(armor + 50, 100))
        exports.TR_mysql:querry("UPDATE tr_items SET value = value + 50 WHERE ID = ? LIMIT 1", armorID)
        exports.TR_mysql:querry("DELETE FROM tr_items WHERE ID = ? LIMIT 1", arg[2])
        triggerClientEvent(arg[1], "equipmentResponse", resourceRoot, "Yelekteki plaka değiştirildi.", "success")

    elseif arg[4] == itemTypes.food then
        setElementHealth(arg[1], math.min(getElementHealth(arg[1]) + arg[5], 100))

        exports.TR_mysql:querry("DELETE FROM tr_items WHERE ID = ? LIMIT 1", arg[2])
        triggerClientEvent(arg[1], "equipmentResponse", resourceRoot)

    elseif arg[4] == itemTypes.cigarettes then
        triggerClientEvent(arg[1], "equipmentResponse", resourceRoot)
        if tonumber(arg[5]) <= 1 then
            exports.TR_mysql:querry("DELETE FROM tr_items WHERE ID = ? LIMIT 1", arg[2])
        else
            exports.TR_mysql:querry("UPDATE tr_items SET value = ? WHERE ID = ? LIMIT 1", arg[5] - 1, arg[2])
        end

    elseif arg[4] == itemTypes.joints then
        triggerClientEvent(arg[1], "equipmentResponse", resourceRoot)
        exports.TR_mysql:querry("DELETE FROM tr_items WHERE ID = ? LIMIT 1", arg[2])

    elseif arg[4] == itemTypes.alcohol then
        triggerClientEvent(arg[1], "equipmentResponse", resourceRoot)
        exports.TR_mysql:querry("DELETE FROM tr_items WHERE ID = ? LIMIT 1", arg[2])

    elseif arg[4] == itemTypes.mask then
        if getElementData(arg[1], "characterMask") and arg[3] then
            triggerClientEvent(arg[1], "equipmentResponse", resourceRoot, "Zaten bir buff takmışsın.", "error")
            return
        end

        setElementData(arg[1], "characterMask", arg[3] and true or false)
        triggerClientEvent(arg[1], "equipmentResponse", resourceRoot, arg[3] and "Buff taktın." or "Buff çıkardın.", "success", true)
        exports.TR_mysql:querry(string.format("UPDATE tr_items SET used = %s WHERE ID = ? LIMIT 1", arg[3] and "1" or "NULL"), arg[2])

    elseif arg[4] == itemTypes.fishingbait then
        takeBait(arg[2])
        exports.TR_mysql:querry(string.format("UPDATE tr_items SET used = %s WHERE ID = ? LIMIT 1", arg[3] and "1" or "NULL"), arg[2])

        triggerClientEvent(arg[1], "equipmentResponse", resourceRoot, false, false, true)

    elseif arg[4] == itemTypes.premium then
        triggerClientEvent(arg[1], "equipmentResponse", resourceRoot)

        if self:givePlayerPremium(arg[1], tonumber(arg[6]), tonumber(arg[5])) then
            exports.TR_mysql:querry("DELETE FROM tr_items WHERE ID = ? LIMIT 1", arg[2])
            triggerClientEvent(arg[1], "equipmentResponse", resourceRoot)
        else
            triggerClientEvent(arg[1], "equipmentResponse", resourceRoot)
        end

    elseif arg[4] == itemTypes.gift then
        local uid = getElementData(arg[1], "characterUID")

        if arg[7] == 0 then
            local rand = math.random(1, 1000)
            if rand == 1 then
                exports.TR_mysql:querry("INSERT INTO `tr_items`(`owner`, `type`, `variant`, `variant2`, `value`) VALUES (?, ?, ?, ?, ?)", uid, 3, 9, 0, 307)
                exports.TR_noti:create(arg[1], "Hediye kutusunun içinde Noel kıyafeti var.", "gift")

            elseif rand <= 51 then
                local names = {"Xantrisa", "Wilka", "Vanze", "Mosesa"}
                local autograph = math.random(1, 4) - 1
                exports.TR_mysql:querry("INSERT INTO `tr_items`(`owner`, `type`, `variant`, `variant2`, `value`) VALUES (?, ?, ?, ?, ?)", uid, 16, autograph, 0, 5)
                exports.TR_noti:create(arg[1], string.format("Hediye kutusunun içinde bir not var %s.", names[autograph+1]), "gift")

            else
                exports.TR_core:giveMoneyToPlayer(arg[1], 500)
                exports.TR_noti:create(arg[1], "Hediyenin içinde 500$ var.", "gift")
            end

            triggerClientEvent(arg[1], "equipmentResponse", resourceRoot)
            exports.TR_mysql:querry("DELETE FROM tr_items WHERE ID = ? LIMIT 1", arg[2])
            self:open(arg[1])

        elseif arg[7] == 1 then
            triggerClientEvent(arg[1], "openEggsSelect", resourceRoot, arg[2])
            triggerClientEvent(arg[1], "equipmentResponse", resourceRoot)
        end

    elseif arg[4] == itemTypes.autograph then
        local uid = getElementData(arg[1], "characterUID")

        if tonumber(arg[5]) <= 1 then
            exports.TR_mysql:querry("DELETE FROM tr_items WHERE ID = ? LIMIT 1", arg[2])
        else
            exports.TR_mysql:querry("UPDATE tr_items SET value = value - 1 WHERE ID = ? LIMIT 1", arg[2])
        end

        setElementHealth(arg[1], 100)
        triggerClientEvent(arg[1], "updatePlayerHud", resourceRoot)
        triggerClientEvent(arg[1], "equipmentResponse", resourceRoot)

    elseif arg[4] == itemTypes.drugs then
        triggerClientEvent(arg[1], "equipmentResponse", resourceRoot)
        exports.TR_mysql:querry("DELETE FROM tr_items WHERE ID = ? LIMIT 1", arg[2])

    elseif arg[4] == itemTypes.paperSheet then
        local plrUID = getElementData(arg[1], "characterUID")
        if tonumber(arg[5]) <= 0 then
            exports.TR_mysql:querry("DELETE FROM tr_items WHERE ID = ? LIMIT 1", arg[2])
        else
            exports.TR_mysql:querry("UPDATE tr_items SET value = ? WHERE ID = ? LIMIT 1", arg[5], arg[2])
        end

        if arg[7] == 0 then
            exports.TR_mysql:querry("INSERT INTO `tr_items`(`owner`, `type`, `variant`, `variant2`, `value`) VALUES (?, ?, ?, ?, ?)", plrUID, itemTypes.joints, arg[6], 3, 1)
        elseif arg[7] == 1 then
            exports.TR_mysql:querry("INSERT INTO `tr_items`(`owner`, `type`, `variant`, `variant2`, `value`) VALUES (?, ?, ?, ?, ?)", plrUID, itemTypes.joints, arg[6], 0, 1)
        end

        triggerClientEvent(arg[1], "equipmentResponse", resourceRoot)
        self:open(arg[1])

    elseif arg[4] == itemTypes.neon then
        local uid = getElementData(arg[1], "characterUID")

        local veh = getPedOccupiedVehicle(arg[1])
        if not veh then
            exports.TR_noti:create(arg[1], "Hiçbir araçta oturmuyorsunuz.", "error")
            triggerClientEvent(arg[1], "equipmentResponse", resourceRoot)
            return
        end
        if getVehicleType(veh) ~= "Automobile" then
            exports.TR_noti:create(arg[1], "Bu araca neon ışıkları takamazsınız.", "error")
            triggerClientEvent(arg[1], "equipmentResponse", resourceRoot)
            return
        end

        local vehID = getElementData(veh, "vehicleID")
        local vehicleOwners = getElementData(veh, "vehicleOwners")
        if not vehID or not vehicleOwners then
            exports.TR_noti:create(arg[1], "Bu araca neon ışıkları takamazsınız.", "error")
            triggerClientEvent(arg[1], "equipmentResponse", resourceRoot)
            return
        end
        if vehicleOwners[1] ~= uid then
            exports.TR_noti:create(arg[1], "Bu araca neon ışıkları takamazsınız.", "error")
            triggerClientEvent(arg[1], "equipmentResponse", resourceRoot)
            return
        end

        local visualTuning = getElementData(veh, "visualTuning")
        if not visualTuning then visualTuning = {} end
        visualTuning.neon = {5, 255, 255, 255, visualTuning.neon and visualTuning.neon[5] or false}
        setElementData(veh, "visualTuning", visualTuning)
        exports.TR_mysql:querry("UPDATE tr_vehicles SET visualTuning = ? WHERE ID = ? LIMIT 1", toJSON(visualTuning), vehID)


        exports.TR_noti:create(arg[1], "Neon tabelalar başarıyla kuruldu.", "success")
        exports.TR_mysql:querry("DELETE FROM tr_items WHERE ID = ? LIMIT 1", arg[2])
        triggerClientEvent(arg[1], "equipmentResponse", resourceRoot)
        self:open(arg[1])
    end
end

function Equipment:givePlayerPremium(plr, type, days)
    local uid = getElementData(plr, "characterUID")
    if type == 0 then
        local _, rows = exports.TR_mysql:querry(string.format("UPDATE tr_accounts SET gold = DATE_ADD(gold, INTERVAL %d DAY) WHERE UID = ? AND gold >= NOW() LIMIT 1", days), uid)
        if rows > 0 then self:updatePlayerPremium(plr, "gold", string.format("Hesabınızı başarıyla uzattınız Gold o %ddni.", days)) return true end

        local _, rows = exports.TR_mysql:querry(string.format("UPDATE tr_accounts SET gold = DATE_ADD(NOW(), INTERVAL %d DAY) WHERE UID = ? AND (gold <= NOW() OR gold IS NULL) LIMIT 1", days), uid)
        if rows > 0 then self:updatePlayerPremium(plr, "gold", string.format("Hesabınızı başarıyla talep ettiniz Gold na %ddni.", days)) return true end
        return true

    elseif type == 1 then
        exports.TR_mysql:querry(string.format("UPDATE tr_accounts SET gold = DATE_ADD(gold, INTERVAL %d DAY) WHERE UID = ? AND gold >= NOW() LIMIT 1", days), uid)
        local _, rows = exports.TR_mysql:querry(string.format("UPDATE tr_accounts SET diamond = DATE_ADD(diamond, INTERVAL %d DAY) WHERE UID = ? AND diamond >= NOW() LIMIT 1", days, days), uid)
        if rows > 0 then self:updatePlayerPremium(plr, "diamond", string.format("Hesabınızı başarıyla uzattınız Diamond o %ddni.", days)) return true end

        local _, rows = exports.TR_mysql:querry(string.format("UPDATE tr_accounts SET diamond = DATE_ADD(NOW(), INTERVAL %d DAY) WHERE UID = ? AND (diamond <= NOW() OR diamond IS NULL) LIMIT 1", days), uid)
        if rows > 0 then self:updatePlayerPremium(plr, "diamond", string.format("Hesabınızı başarıyla talep ettiniz Diamond na %ddni.", days)) return true end
        return true
    end
end

function Equipment:updatePlayerPremium(plr, rank, noti)
    if not getElementData(plr, "characterData") then return end

    exports.TR_noti:create(plr, noti, "success", 10)

    local data = getElementData(plr, "characterData")
    if data.premium == "diamond" and rank == "gold" then return end
    data.premium = rank
    setElementData(plr, "characterData", data)
end


-- Initializer
local eq = Equipment:create()
function bindPlayerEquipment(plr)
    eq:bindPlayer(plr)
end

function onLoadPlayerItems(data, items)
    triggerLatentClientEvent(data.plr, "updateItems", 5000, resourceRoot, items and items[1][1] or {}, items and items[2][1] or {}, items and items[3][1] or {}, data.open)
end
addEvent("onLoadPlayerItems", true)
addEventHandler("onLoadPlayerItems", root, onLoadPlayerItems)

function getItems()
    eq:open(client, true)
end
addEvent("getItems", true)
addEventHandler("getItems", resourceRoot, getItems)

function updateItems(...)
    eq:open(arg[1], arg[2])
end

function setItemFavourite(id, state)
    eq:setFavourite(client, id, state)
end
addEvent("setItemFavourite", true)
addEventHandler("setItemFavourite", resourceRoot, setItemFavourite)

function removeItem(id, blockMsg)
    eq:removeItem(client, id, blockMsg)
end
addEvent("removeItem", true)
addEventHandler("removeItem", root, removeItem)

function useItem(id, used, type, value, variant, variant2)
    eq:useItem(client, id, used, type, value, variant, variant2)
end
addEvent("useItem", true)
addEventHandler("useItem", resourceRoot, useItem)

function mergeItems(id, type, variant, variant2)
    eq:mergeItems(client, id, type, variant, variant2)
end
addEvent("mergeItems", true)
addEventHandler("mergeItems", resourceRoot, mergeItems)

function splitItems(id, count)
    eq:splitItems(client, id, count)
end
addEvent("splitItems", true)
addEventHandler("splitItems", resourceRoot, splitItems)

function takeItemCount(id, count)
    eq:takeItemCount(client, id, count)
end
addEvent("takeItemCount", true)
addEventHandler("takeItemCount", root, takeItemCount)

function createInteractionItem(type, variant, variant2, value, value2)
    eq:createItem(client, type, variant, variant2, value, value2)

    exports.TR_noti:create(client, "Öğe başarıyla oluşturuldu.", "success")
    triggerClientEvent(client, "updateInteraction", resourceRoot)
end
addEvent("createInteractionItem", true)
addEventHandler("createInteractionItem", root, createInteractionItem)

-- Trade
function setTradeState(plr, value)
    triggerClientEvent(plr, "setTradeState", resourceRoot, value)
end
addEvent("setTradeState", true)
addEventHandler("setTradeState", resourceRoot, setTradeState)

function cancelTrade(plr)
    triggerClientEvent(plr, "cancelTrade", resourceRoot, true)
end
addEvent("cancelTrade", true)
addEventHandler("cancelTrade", resourceRoot, cancelTrade)

function syncItemTrade(plr, items)
    triggerClientEvent(plr, "syncItemTrade", resourceRoot, client, items)
end
addEvent("syncItemTrade", true)
addEventHandler("syncItemTrade", resourceRoot, syncItemTrade)

function syncMoneyTrade(plr, amount)
    triggerClientEvent(plr, "syncMoneyTrade", resourceRoot, amount)
end
addEvent("syncMoneyTrade", true)
addEventHandler("syncMoneyTrade", resourceRoot, syncMoneyTrade)

function performTrade(plr, clientItems, plrItems, clientMoney, plrMoney)
    local plrUID = getElementData(plr, "characterUID")
    local clientUID = getElementData(client, "characterUID")
    local plrData = getElementData(plr, "characterData")
    local clientData = getElementData(client, "characterData")

    local clientName = getPlayerName(client)
    local plrName = getPlayerName(plr)

    clientMoney = tonumber(clientMoney)
    plrMoney = tonumber(plrMoney)

    if not plrUID or not clientUID or not plrData or not clientData then declineTrade(client, plr) return end

    if clientMoney then
        if tonumber(clientData.money) < clientMoney then declineTrade(client, plr) return end
        if exports.TR_core:takeMoneyFromPlayer(client, clientMoney) then exports.TR_core:giveMoneyToPlayer(plr, clientMoney) end

    end
    if plrMoney then
        if tonumber(plrData.money) < plrMoney then declineTrade(client, plr) return end
        if exports.TR_core:takeMoneyFromPlayer(plr, plrMoney) then exports.TR_core:giveMoneyToPlayer(client, plrMoney) end
    end

    local clientGivedPresent = false
    if clientItems then
        for _, item in ipairs(clientItems) do
            if tonumber(item.type) == itemTypes.gift then clientGivedPresent = true end
            exports.TR_mysql:querry("UPDATE tr_items SET owner = ?, favourite = NULL WHERE ID = ? LIMIT 1", plrUID, item.ID)
        end
    end

    local plrGivedPresent = false
    if plrItems then
        for _, item in ipairs(plrItems) do
            if tonumber(item.type) == itemTypes.gift then plrGivedPresent = true end
            exports.TR_mysql:querry("UPDATE tr_items SET owner = ?, favourite = NULL WHERE ID = ? LIMIT 1", clientUID, item.ID)
        end
    end

    triggerClientEvent(plr, "closeTrade", resourceRoot)
    exports.TR_noti:create(plr, "Ticaret başarıyla tamamlandı.", "success")
    exports.TR_noti:create(client, "Ticaret başarıyla tamamlandı.", "success")

    createTradeLog(clientName, plrName, clientMoney and clientMoney or 0, plrMoney and plrMoney or 0, clientItems and #clientItems or 0, plrItems and #plrItems or 0)

    eq:open(plr)
    eq:open(client)
end
addEvent("performTrade", true)
addEventHandler("performTrade", resourceRoot, performTrade)

function declineTrade(client, plr)
    triggerClientEvent(plr, "closeTrade", resourceRoot)
    exports.TR_noti:create(plr, "Ticaret iptal edildi. Bir şeyler yanlış gitti.", "error")
    exports.TR_noti:create(client, "Ticaret iptal edildi. Bir şeyler yanlış gitti.", "error")
end


function createTradeLog(plr1, plr2, amount1, amount2, items1, items2)
    local time = getRealTime()
    exports.TR_discord:sendChannelMsg("trade", {
        time = string.format("[%02d:%02d %02d.%02d]", time.hour, time.minute, time.monthday, time.month),
        author = plr1,
        target = plr2,
        amount1 = string.format("%.2f", amount1),
        amount2 = string.format("%.2f", amount2),
        items1 = items1,
        items2 = items2,
    })
end


-- Bait
function takeBait(itemID)
    exports.TR_mysql:querry("UPDATE tr_items SET value = value - 1 WHERE ID = ? LIMIT 1", itemID)
    exports.TR_mysql:querry("DELETE FROM `tr_items` WHERE value <= 0 AND ID = ? LIMIT 1", itemID)
end
addEvent("takeBait", true)
addEventHandler("takeBait", root, takeBait)

-- Items shop
function buyShopItems(state, data)
    if state then
        local uid = getElementData(source, "characterUID")
        for i, v in pairs(data) do
            exports.TR_mysql:querry("INSERT INTO `tr_items`(`owner`, `type`, `variant`, `variant2`, `value`, `used`, `favourite`) VALUES (?,?,?,?,?,NULL,NULL)", uid, v.type, v.variant, v.variant2, v.value)
        end
        triggerClientEvent(source, "buyShopItem", resourceRoot, true)
        eq:open(source)
    end
    triggerClientEvent(source, "buyShopItem", resourceRoot)
end
addEvent("buyShopItems", true)
addEventHandler("buyShopItems", root, buyShopItems)

function updateRentData(type, id, targetID, isAdding)
    if type == "veh" then
        if isAdding then
            exports.TR_mysql:querry("INSERT INTO `tr_vehiclesRent`(`plrUID`, `vehID`) VALUES (?, ?)", targetID, id)

            local veh = getElementByID("vehicle"..id)
            if veh then
                local vehOwners = getElementData(veh, "vehicleOwners")
                if vehOwners then
                    table.insert(vehOwners, targetID)
                    setElementData(veh, "vehicleOwners", vehOwners)
                end
            end
        else
            exports.TR_mysql:querry("DELETE FROM `tr_vehiclesRent` WHERE plrUID = ? AND vehID = ? LIMIT 1", targetID, id)

            local veh = getElementByID("vehicle"..id)
            if veh then
                local vehOwners = getElementData(veh, "vehicleOwners")
                if vehOwners then
                    local newOwners = {}
                    for i, v in ipairs(vehOwners) do
                        if v ~= targetID then
                            table.insert(newOwners, v)
                        end
                    end

                    setElementData(veh, "vehicleOwners", newOwners)
                end
            end
        end

    elseif type == "house" then
        if isAdding then
            exports.TR_mysql:querry("INSERT INTO `tr_housesRent`(`plrUID`, `houseID`) VALUES (?, ?)", targetID, id)
        else
            exports.TR_mysql:querry("DELETE FROM `tr_housesRent` WHERE plrUID = ? AND houseID = ? LIMIT 1", targetID, id)
        end
    end
    triggerClientEvent(client, "rentResponse", resourceRoot)
end
addEvent("updateRentData", true)
addEventHandler("updateRentData", root, updateRentData)



function onPlayerWeapFire(ammoType, weaponItemID, takeDurability)
    local uid = getElementData(client, "characterUID")
    exports.TR_mysql:querry("UPDATE tr_items SET value = value - 5 WHERE value > 0 AND type = 10 AND variant = ? AND owner = ? AND ownedType = 0 LIMIT 1", ammoType, uid)
    exports.TR_mysql:querry("DELETE FROM `tr_items` WHERE value <= 0 AND type = 10 AND variant = ? AND owner = ? AND ownedType = 0 LIMIT 1", ammoType, uid)

    if weaponItemID then
        exports.TR_mysql:querry("UPDATE tr_items SET durability = durability - ? WHERE ID = ? LIMIT 1", takeDurability, weaponItemID)
        exports.TR_mysql:querry("DELETE FROM `tr_items` WHERE durability <= 0 AND ID = ? LIMIT 1", weaponItemID)
    end
end
addEvent("onPlayerWeapFire", true)
addEventHandler("onPlayerWeapFire", resourceRoot, onPlayerWeapFire)


function updatePlayerMask(plr)
    -- if not plr then return end
    -- local uid = getElementData(plr, "characterUID")
    -- if not uid then return end

    -- local haveMask = exports.TR_mysql:querry("SELECT ID FROM `tr_items` WHERE owner = ? AND type = ? AND used = 1 LIMIT 1", uid, itemTypes.mask)
    -- if haveMask and haveMask[1] then
    --     setElementData(plr, "characterMask", true)
    -- end

    -- local haveArmor = exports.TR_mysql:querry("SELECT ID, value FROM `tr_items` WHERE owner = ? AND type = ? AND used = 1 LIMIT 1", uid, itemTypes.armor)
    -- if haveArmor and haveArmor[1] then
    --     setPedArmor(plr, haveArmor[1].value)
    --     setElementData(plr, "armorID", haveArmor[1].ID)
    -- end

    -- local weapons = exports.TR_mysql:querry("SELECT value, variant, variant2 FROM `tr_items` WHERE owner = ? AND type = ? AND used = 1", uid, itemTypes.weapon)
    -- if weapons and weapons[1] then
    --     for i, v in pairs(weapons) do
    --         if weaponsWithoutAmmo[tonumber(v.value)] then
    --             exports.TR_weaponSlots:giveWeapon(plr, tonumber(v.value), 9999, false)

    --         elseif tonumber(v.variant) == 1 then
    --             if tonumber(v.variant2) >= 4 and tonumber(v.variant2) <= 12 then
    --                 exports.TR_weaponSlots:giveWeapon(plr, 7, 9999, false)
    --             end

    --         else
    --             local ammo = exports.TR_mysql:querry("SELECT SUM(value) as ammunition FROM tr_items WHERE type = 10 AND variant = ? AND owner = ?", weaponAmmoType[tonumber(v.value)], uid)
    --             if ammo and ammo[1].ammunition then
    --                 exports.TR_weaponSlots:giveWeapon(plr, v.value, ammo[1].ammunition, false)
    --             end
    --         end
    --     end
    -- end

    bindKey(plr, "r", "down", reloadWeapon)
    updatePlayerStats(plr)
    -- eq:open(plr, false)
end
addEvent("updatePlayerMask", true)
addEventHandler("updatePlayerMask", root, updatePlayerMask)

function openAdminCreateItem()
    if not exports.TR_admin:hasPlayerPermission(source, "itemCreate") then return end
    triggerClientEvent(source, "createAdminItemCreator", resourceRoot)
end
addEvent("openAdminCreateItem", true)
addEventHandler("openAdminCreateItem", root, openAdminCreateItem)
exports.TR_chat:addCommand("citem", "openAdminCreateItem")

function createAdminItem(data, value)
    local uid = getElementData(client, "characterUID")
    exports.TR_mysql:querry("INSERT INTO `tr_items`(`owner`, `type`, `variant`, `variant2`, `value`) VALUES (?, ?, ?, ?, ?)", uid, data.type, data.variant, data.variant2, value)
    eq:open(client, false)

    triggerClientEvent(client, "createAdminItemCreatorResponse", resourceRoot)
end
addEvent("createAdminItem", true)
addEventHandler("createAdminItem", resourceRoot, createAdminItem)

function getRentKeysTable(type, id)
    if type == "vehicle" then
        local rentedPlayers = exports.TR_mysql:querry("SELECT ID, tr_accounts.UID as UID, tr_accounts.username as username FROM tr_vehiclesRent LEFT JOIN tr_accounts ON tr_vehiclesRent.plrUID = tr_accounts.UID WHERE tr_vehiclesRent.vehID = ? LIMIT 6", id)
        triggerLatentClientEvent(client, "updatePlayerKeysTable", 1000, resourceRoot, rentedPlayers)

    elseif type == "house" then
        local rentedPlayers = exports.TR_mysql:querry("SELECT ID, tr_accounts.UID as UID, tr_accounts.username as username FROM tr_housesRent LEFT JOIN tr_accounts ON tr_housesRent.plrUID = tr_accounts.UID WHERE tr_housesRent.houseID = ? LIMIT 6", id)
        triggerLatentClientEvent(client, "updatePlayerKeysTable", 1000, resourceRoot, rentedPlayers)
    end
end
addEvent("getRentKeysTable", true)
addEventHandler("getRentKeysTable", resourceRoot, getRentKeysTable)



function updatePlayerStats(plr)
    setPedStat(plr, 72, 1000)
    setPedStat(plr, 76, 1000)
    setPedStat(plr, 77, 1000)
    setPedStat(plr, 78, 1000)
end

function reloadWeapon(player)
    reloadPedWeapon(player)
end


-- Weapon reload
setTimer(function()
    for k, v in ipairs(getElementsByType("player")) do
        bindKey(v, "r", "down", reloadWeapon)
    end
end, 1000, 1)




function openTrunkItems(...)
    local uid = getElementData(client, "characterUID")
    if not uid then return end

    exports.TR_mysql:querryAsync(
        {
            callback = "onLoadTrunkItems",
            plr = client,
            type = arg[1],
            id = arg[2],
            model = arg[3],
        },
        "SELECT ID, type, variant, variant2, value, value2, durability, used, favourite FROM tr_items WHERE owner = ? AND ownedType = ?", arg[2], arg[1])
end
addEvent("openTrunkItems", true)
addEventHandler("openTrunkItems", root, openTrunkItems)

function onLoadTrunkItems(data, items)
    triggerClientEvent(data.plr, "openTrunkItems", resourceRoot, data.type, data.id, items, data.model)
end
addEvent("onLoadTrunkItems", true)
addEventHandler("onLoadTrunkItems", root, onLoadTrunkItems)

function putItemInStash(itemID, targetID, type)
    exports.TR_mysql:querry("UPDATE tr_items SET owner = ?, ownedType = ? WHERE ID = ? LIMIT 1", targetID, type, itemID)
    eq:open(client)
end
addEvent("putItemInStash", true)
addEventHandler("putItemInStash", root, putItemInStash)

function takeoutItemFromStash(itemID, stashType, stashID, itemName)
    local uid = getElementData(client, "characterUID")
    exports.TR_mysql:querry("UPDATE tr_items SET owner = ?, ownedType = 0 WHERE ID = ? LIMIT 1", uid, itemID)
    eq:open(client)

    if stashType == 0 then
        local nick = exports.TR_mysql:querry("SELECT username FROM tr_accounts WHERE UID = ? LIMIT 1", stashID)
        local time = getRealTime()
        exports.TR_discord:sendChannelMsg("playerTookItems", {
            time = string.format("[%02d:%02d %02d.%02d]", time.hour, time.minute, time.monthday, time.month),
            author = getPlayerName(client),
            text = string.format("%s sss %s.", itemName, nick[1].username),
        })
    end
end
addEvent("takeoutItemFromStash", true)
addEventHandler("takeoutItemFromStash", root, takeoutItemFromStash)




function giveEggPrize(itemID, type, value)
    local uid = getElementData(client, "characterUID")
    if type == "money" then
        exports.TR_core:giveMoneyToPlayer(client, value)

    elseif type == "diamond" then
        exports.TR_api:givePremium(getPlayerName(client), 1, 2)

    elseif type == "gold" then
        exports.TR_api:givePremium(getPlayerName(client), 3, 1)

    elseif type == "neon" then
        exports.TR_mysql:querry("INSERT INTO `tr_items`(`owner`, `type`, `variant`, `variant2`, `value`) VALUES (?, ?, ?, ?, ?)", uid, 23, 0, 0, 0)
        eq:open(client)
    end

    exports.TR_mysql:querry("DELETE FROM tr_items WHERE ID = ? LIMIT 1", itemID)
end
addEvent("giveEggPrize", true)
addEventHandler("giveEggPrize", root, giveEggPrize)



-- local plr = getPlayerFromName("Xantris")
-- setElementModel(plr, 0)
-- setElementData(plr, "customModel", nil)
-- local data = getElementData(plr, "characterData")
-- data.skin = 0
-- setElementData(plr, "characterData", data)

-- exports.TR_mysql:querry("UPDATE tr_items SET used = NULL WHERE owner = 1 AND ownedType = 0")