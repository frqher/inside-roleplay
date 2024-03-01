function createPirate()
    local dialogue = exports.TR_npc:createDialogue()
    exports.TR_npc:addDialogueText(dialogue, "Merhaba. Bu kadar gaz tüpüne ne için ihtiyacın var?", {pedResponse = "Ahoj dostum! Bunlar gaz değil, oksijen tüpleri."})
    exports.TR_npc:addDialogueText(dialogue, "Ahoj? Dostum? Bir denizci misin?", {pedResponse = "Hayır, ancak deniz hikayeleri her zaman beni büyülemiştir. Eğer atalarımızın deniz kurtları efsanelerine inanırsak, XVII. yüzyılda bu bölgede büyük bir hazineyle dolu korsan gemisi battı! Misyonum, bu derinliklerde saklanan tüm hazineleri bulmaktır.", responseTo = "Merhaba. Bu kadar gaz tüpüne ne için ihtiyacın var?"})
    exports.TR_npc:addDialogueText(dialogue, "Sana nasıl yardımcı olabilirim?", {pedResponse = "Ayyy! Tabii ki genç dostum, dalış ehliyetini almak için San Fierro'ya git, görünüşüne bakılırsa biraz şehirde deneyim kazanman da iyi olacak, kendini hazır hissettiğinde bana geri dön!", responseTo = "Ahoj? Dostum? Bir denizci misin?"})
    exports.TR_npc:addDialogueText(dialogue, "O zaman yakında geri döneceğim.", {pedResponse = "", responseTo = "Sana nasıl yardımcı olabilirim?"})
    exports.TR_npc:addDialogueText(dialogue, "[mırıldanarak] Çılgınlar beni çevreliyor...", {pedResponse = "", responseTo = "Ahoj? Dostum? Bir denizci misin?"})

    exports.TR_npc:addDialogueText(dialogue, "Nasıl başlayabilirim?", {pedResponse = "Merhaba genç dostum! Kayıp artefakt arayıcısı olarak seni işe almak isterim, ancak önce San Fierro'da dalış ehliyeti almalısın ve şehirde biraz deneyim kazanmalısın. Hazır olduğunda bana gel, seni bekleyeceğim."})
    exports.TR_npc:addDialogueText(dialogue, "Görüşürüz.", {pedResponse = "", responseTo = "Nasıl başlayabilirim?"})

    exports.TR_npc:addDialogueText(dialogue, "Bana ilginç geliyor.", {pedResponse = "Belki belki. Her şey sana ne teklif edeceğine bağlı."})
    exports.TR_npc:addDialogueText(dialogue, "Bu eski gümüş kutuyu buldum.", {pedResponse = "", responseTo = "Bana ilginç geliyor.", trigger = "divingPirateGiveItems", triggerData = {"silver"}})
    exports.TR_npc:addDialogueText(dialogue, "Dalarken bu altın paketi buldum.", {pedResponse = "", responseTo = "Bana ilginç geliyor.", trigger = "divingPirateGiveItems", triggerData = {"gold"}})
    exports.TR_npc:addDialogueText(dialogue, "Bu yırtık parçalar karşılığında ne vereceksin?", {pedResponse = "Hangi yırtık parçalar? Bana ne anlatıyorsun?", responseTo = "Bana ilginç geliyor."})
    exports.TR_npc:addDialogueText(dialogue, "Bunu halletmeye gücün yeter mi? (maliyet: $5000)", {pedResponse = "", responseTo = "Bu yırtık parçalar karşılığında ne vereceksin?", trigger = "divingPirateGiveItems", triggerData = {"skin"}})
    exports.TR_npc:addDialogueText(dialogue, "Belki sonra...", {pedResponse = "", responseTo = "Bu yırtık parçalar karşılığında ne vereceksin?"})

    exports.TR_npc:addDialogueText(dialogue, "Aramalarda başarılar!", {pedResponse = "Teşekkürler. Ahoj!"})

    local ped = exports.TR_npc:createNPC(120, -912.466796875, 2671.662109375, 42.370262145996, 235, "Jack Spaylow", "FoF Sahibi", "diyalog")
    exports.TR_npc:setNPCDialogue(ped, dialogue)
end
createPirate()


function divingPirateGiveItems(ped, data)
    local pedName = getElementData(ped, "name")
    local uid = getElementData(client, "characterUID")

    if data[1] == "silver" then
        local item = exports.TR_mysql:querry("SELECT ID FROM tr_items WHERE owner = ? AND type = 22 AND variant = 0 AND variant2 = 0 AND ownedType = 0 LIMIT 1", uid)
        if not item or not item[1] then
            triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Ne yazık ki gerçekten bu sandığa sahip değilsin...", "files/images/npc.png")
            return
        end

        exports.TR_core:giveMoneyToPlayer(client, 300)
        exports.TR_mysql:querry("DELETE FROM tr_items WHERE ID = ? LIMIT 1", item[1].ID)
        triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Sana $300 veriyorum ve hiçbir pazarlık yapmadan! Bana onu burada ver.", "files/images/npc.png")
        triggerClientEvent(client, "takePlayerItem", resourceRoot, tonumber(item[1].ID))

    elseif data[1] == "gold" then
        local item = exports.TR_mysql:querry("SELECT ID FROM tr_items WHERE owner = ? AND type = 22 AND variant = 0 AND variant2 = 1 AND ownedType = 0 LIMIT 1", uid)
        if not item or not item[1] then
            triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Torba mı? Hiç torba gördün mü?", "files/images/npc.png")
            return
        end

        exports.TR_api:givePremium(getPlayerName(client), 1, 1)
        exports.TR_mysql:querry("DELETE FROM tr_items WHERE ID = ? LIMIT 1", item[1].ID)
        triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Sana onun için özel bir ödül vereceğim, paketin kadar altın değerinde!", "files/images/npc.png")
        triggerClientEvent(client, "takePlayerItem", resourceRoot, tonumber(item[1].ID))

    elseif data[1] == "skin" then
        local item = exports.TR_mysql:querry("SELECT ID FROM tr_items WHERE owner = ? AND type = 22 AND variant = 0 AND variant2 = 2 AND ownedType = 0 LIMIT 1", uid)
        if not item or not item[1] then
            triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Deniz yosunlarından mı bahsediyorsun? Gerçek korsan kıyafetlerini bulduğunda gel.", "files/images/npc.png")
            return
        end

        if exports.TR_core:takeMoneyFromPlayer(client, 5000) then
            exports.TR_mysql:querry("INSERT INTO `tr_items`(`owner`, `type`, `variant`, `variant2`, `value`) VALUES (?, ?, ?, ?, ?)", uid, 3, 10, 0, 203)
            exports.TR_mysql:querry("DELETE FROM tr_items WHERE ID = ? LIMIT 1", item[1].ID)
            triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Kara inciye! Bu, XVII. yüzyılın denizcilerinden birinin kıyafeti! Ancak eksik olduğunu görüyorum. Birkaç delik var. Bu nakit, sağlam bir şey dikmek için yeterli olmalı!", "files/images/npc.png")
            triggerClientEvent(client, "takePlayerItem", resourceRoot, tonumber(item[1].ID))
        else
            triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Eğer malzemeler için 5000 $ toplamayı başarırsan, sana güzel bir korsan kıyafeti dikerim!", "files/images/npc.png")
        end

    end
end
addEvent("divingPirateGiveItems", true)
addEventHandler("divingPirateGiveItems", root, divingPirateGiveItems)


-- Job skins
function startDivingJob()
    setElementModel(client, 291)
end
addEvent("startDivingJob", true)
addEventHandler("startDivingJob", resourceRoot, startDivingJob)

function giveDivingJobItem(type)
    local plrUID = getElementData(client, "characterUID")

    if type == "clothes" then
        local uid = getElementData(client, "characterUID")
        exports.TR_mysql:querry("INSERT INTO `tr_items`(`owner`, `type`, `variant`, `variant2`, `value`) VALUES (?, ?, ?, ?, ?)", uid, 22, 0, 2, 0)
        exports.TR_items:updateItems(client, false)

    elseif type == "gold" then
        local uid = getElementData(client, "characterUID")
        exports.TR_mysql:querry("INSERT INTO `tr_items`(`owner`, `type`, `variant`, `variant2`, `value`) VALUES (?, ?, ?, ?, ?)", uid, 22, 0, 1, 0)
        exports.TR_items:updateItems(client, false)

    elseif type == "silver" then
        local uid = getElementData(client, "characterUID")
        exports.TR_mysql:querry("INSERT INTO `tr_items`(`owner`, `type`, `variant`, `variant2`, `value`) VALUES (?, ?, ?, ?, ?)", uid, 22, 0, 0, 0)
        exports.TR_items:updateItems(client, false)

    end
end
addEvent("giveDivingJobItem", true)
addEventHandler("giveDivingJobItem", resourceRoot, giveDivingJobItem)