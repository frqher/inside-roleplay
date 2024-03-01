function getReports()
    local reports = exports.TR_mysql:querry("SELECT reporter, reported FROM tr_reports WHERE admin IS NULL")
    triggerClientEvent(client, "updateReports", resourceRoot, reports)
end
addEvent("getReports", true)
addEventHandler("getReports", root, getReports)

function updateReports()
    local reports = exports.TR_mysql:querry("SELECT reporter, reported FROM tr_reports WHERE admin IS NULL")
    triggerClientEvent(root, "updateReports", resourceRoot, reports)
end

function updateLogs(text)
    triggerClientEvent(root, "updateLogs", resourceRoot, text)
end
addEvent("updateLogs", true)
addEventHandler("updateLogs", root, updateLogs)


-- Chat systems
function clearChat(...)
    if not hasPlayerPermission(source, "clearChat") then return end
    triggerClientEvent(root, "clearChat", resourceRoot)
end
addEvent("clearChatCommand", true)
addEventHandler("clearChatCommand", root, clearChat)
exports.TR_chat:addCommand("cc", "clearChatCommand")



-- Penalties
function mute(targetID, count, unit, ...)
    if not isPlayerOnDuty(source) then return end
    if not targetID or not count or not unit then triggerClientEvent(source, "showCustomMessage", resourceRoot, "#008a2eKomut Kullanımı", "#438f5c/mute (ID/İsim) (miktar) (dakika/saat/gün) (sebep)", "files/images/command.png") return end

    unit = string.lower(unit)
    count = tonumber(count)

    local reason = table.concat(arg, " ")
    if not avaliableMuteUnits[unit] or string.len(reason) < 1 then triggerClientEvent(source, "showCustomMessage", resourceRoot, "#008a2eKomut Kullanımı", "#438f5c/mute (ID/İsim) (miktar) (dakika/saat/gün) (sebep)", "files/images/command.png") return end

    local target = findPlayer(source, targetID)
    if not target then exports.TR_noti:create(source, "Belirtilen oyuncu bulunamadı!", "error") return end
    if source == target then exports.TR_noti:create(source, "Kendini susturamazsın!", "error") return end

    if not hasPlayerPermission(source, "isDev") and isPlayerOnDuty(target) then exports.TR_noti:create(source, "Yetkili bir kişiyi susturamazsın!", "error") return end

    local targetUID = getElementData(target, "characterUID")
    local targetName = getPlayerName(target)
    local targetSerial = getPlayerSerial(target)
    exports.TR_mysql:querry(string.format("INSERT INTO `tr_penalties` (`plrUID`, `serial`, `reason`, `time`, `timeEnd`, `type`, `admin`) VALUES (?, ?, ?, NOW(), DATE_ADD(NOW(), INTERVAL %d %s), 'mute', ?)", count, avaliableMuteUnits[unit]), targetUID, targetSerial, reason, getPlayerName(source))

    local adminName = getPlayerName(source)
    exports.TR_noti:create(root, string.format("%s adlı oyuncu %s tarafından susturuldu.\nSebep: %s", targetName,adminName, reason), "penalty")
    setElementData(target, "playerMute", true)

    local time = getRealTime()
    exports.TR_discord:sendChannelMsg("adminPenalties", {
        time = string.format("[%02d:%02d %02d.%02d]", time.hour, time.minute, time.monthday, time.month),
        author = adminName,
        text = string.format("%s adlı oyuncu %d%s süreyle susturuldu sebep: %s", targetName, count, unit, reason),
    })
end
addEvent("mutePlayerCommand", true)
addEventHandler("mutePlayerCommand", root, mute)
exports.TR_chat:addCommand("mute", "mutePlayerCommand")

function warn(targetID, ...)
    if not isPlayerOnDuty(source) then return end

    local reason = table.concat(arg, " ")
    if not targetID or not reason or string.len(reason) < 1 then triggerClientEvent(source, "showCustomMessage", resourceRoot, "#008a2eKomut Kullanımı", "#438f5c/warn (ID/İsim) (sebep)", "files/images/command.png") return end

    local target = findPlayer(source, targetID)
    if not target then exports.TR_noti:create(source, "Belirtilen oyuncu bulunamadı!", "error") return end
    if source == target then exports.TR_noti:create(source, "Kendini uyaramazsın", "error") return end
    if not hasPlayerPermission(source, "isDev") and isPlayerOnDuty(target) then exports.TR_noti:create(source, "Yetkili ekibinden birisini uyaramazsın", "error") return end

    local targetUID = getElementData(target, "characterUID")
    local targetName = getPlayerName(target)
    local targetSerial = getPlayerSerial(target)
    local adminName = getPlayerName(source)

    exports.TR_mysql:querry("INSERT INTO `tr_penalties` (`plrUID`, `serial`, `reason`, `time`, `timeEnd`, `type`, `admin`) VALUES (?, ?, ?, NOW(), NULL, 'warn', ?)", targetUID, targetSerial, reason, adminName)
    triggerClientEvent(root, "showWarn", resourceRoot, targetName, adminName, reason)

    local time = getRealTime()
    exports.TR_discord:sendChannelMsg("adminPenalties", {
        time = string.format("[%02d:%02d %02d.%02d]", time.hour, time.minute, time.monthday, time.month),
        author = adminName,
        text = string.format("%s adlı oyuncuyu uyardı. sebep: %s", targetName, reason),
    })
end
addEvent("warnCommand", true)
addEventHandler("warnCommand", root, warn)
exports.TR_chat:addCommand("warn", "warnCommand")

function kick(targetID, ...)
    if not hasPlayerPermission(source, "kick") then return end

    local reason = table.concat(arg, " ")
    if not targetID or not reason or string.len(reason) < 1 then triggerClientEvent(source, "showCustomMessage", resourceRoot, "#008a2eKomut Kullanımı", "#438f5c/kick (ID/İsim) (sebep)", "files/images/command.png") return end

    local target = findPlayer(source, targetID)
    if not target then exports.TR_noti:create(source, "Belirtilen oyuncu bulunamadı!", "error") return end
    if source == target then exports.TR_noti:create(source, "Kendinizi kickleyemezsiniz.", "error") return end
    if not hasPlayerPermission(source, "isDev") and isPlayerOnDuty(target) then exports.TR_noti:create(source, "Yetkili ekibinden birisini kicklemeyezsin.", "error") return end

    local targetUID = getElementData(target, "characterUID")
    local targetName = getPlayerName(target)
    local targetSerial = getPlayerSerial(target)
    local adminName = getPlayerName(source)

    exports.TR_noti:create(root, string.format("%s adlı oyuncu %s adlı yetki tarafından kicklendi.\nSebep: %s", targetName, adminName, reason), "penalty")
    exports.TR_mysql:querry("INSERT INTO `tr_penalties` (`plrUID`, `serial`, `reason`, `time`, `timeEnd`, `type`, `admin`) VALUES (?, ?, ?, NOW(), NULL, 'kick', ?)", targetUID, targetSerial, reason, adminName)
    kickPlayerFromServer(target, getPlayerName(source), reason)

    local time = getRealTime()
    exports.TR_discord:sendChannelMsg("adminPenalties", {
        time = string.format("[%02d:%02d %02d.%02d]", time.hour, time.minute, time.monthday, time.month),
        author = adminName,
        text = string.format("%s adlı oyuncuyu kickledi. Sebep: %s", targetName, reason),
    })
end
addEvent("kickPlayerCommand", true)
addEventHandler("kickPlayerCommand", root, kick)
exports.TR_chat:addCommand("kick", "kickPlayerCommand")

function ban(targetID, count, unit, ...)
    -- if not hasPlayerPermission(source, "ban") then return end
    if not targetID or not count or not unit then triggerClientEvent(source, "showCustomMessage", resourceRoot, "#008a2eKomut Kullanımı", "#438f5c/ban (ID/İsim) (miktar) (gün/ay/yıl) (sebep)", "files/images/command.png") return end

    unit = string.lower(unit)
    count = tonumber(count)

    local reason = table.concat(arg, " ")
    if not avaliableUnits[unit] or string.len(reason) < 1 then triggerClientEvent(source, "showCustomMessage", resourceRoot, "#008a2eKomut Kullanımı", "#438f5c/ban (ID/İsim) (miktar) (gün/ay/yıl) (sebep)", "files/images/command.png") return end

    local target = findPlayer(source, targetID)
    if not target then exports.TR_noti:create(source, "Belirtilen oyuncu bulunamadı!", "error") return end
    -- if source == target then exports.TR_noti:create(source, "Nie możesz zbanować samego siebie.", "error") return end
    if not hasPlayerPermission(source, "isDev") and isPlayerOnDuty(target) then exports.TR_noti:create(source, "Yetkili ekibinden birisini banlayamazsın.", "error") return end

    local targetUID = getElementData(target, "characterUID")
    local targetName = getPlayerName(target)
    local targetSerial = getPlayerSerial(target)
    exports.TR_mysql:querry(string.format("INSERT INTO `tr_penalties` (`plrUID`, `serial`, `reason`, `time`, `timeEnd`, `type`, `admin`) VALUES (?, ?, ?, NOW(), DATE_ADD(NOW(), INTERVAL %d %s), 'ban', ?)", count, avaliableUnits[unit]), targetUID, targetSerial, reason, getPlayerName(source))

    local adminName = getPlayerName(source)
    exports.TR_noti:create(root, string.format("%s adlı oyuncu %s adlı yetkili tarafından yasaklandı\nSebep: %s", targetName, adminName, reason), "penalty")
    kickPlayerFromServer(target, getPlayerName(source), "Yasaklandınız! Ayrıntıları görmek için sunucumuzu ziyaret edin.")

    local time = getRealTime()
    exports.TR_discord:sendChannelMsg("adminPenalties", {
        time = string.format("[%02d:%02d %02d.%02d]", time.hour, time.minute, time.monthday, time.month),
        author = adminName,
        text = string.format("%s adlı oyuncu %d%s süresiyle yasaklandı sebep: %s", targetName, count, unit, reason),
    })
end
addEvent("banPlayerCommand", true)
addEventHandler("banPlayerCommand", root, ban)
exports.TR_chat:addCommand("ban", "banPlayerCommand")

function tpl(targetID, count, unit, ...)
    if not hasPlayerPermission(source, "tpl") then return end
    if not targetID or not count or not unit then triggerClientEvent(source, "showCustomMessage", resourceRoot, "#008a2eKomut Kullanımı", "#438f5c/tpl (ID/İsim) (miktar) (gün/ay/yıl) (sebep)", "files/images/command.png") return end

    unit = string.lower(unit)
    count = tonumber(count)

    local reason = table.concat(arg, " ")
    if not avaliableMuteUnits[unit] or string.len(reason) < 1 then triggerClientEvent(source, "showCustomMessage", resourceRoot, "#008a2eKomut Kullanımı", "#438f5c/tpl (ID/İsim) (miktar) (gün/ay/yıl) (sebep)", "files/images/command.png") return end

    local target = findPlayer(source, targetID)
    if not target then exports.TR_noti:create(source, "Belirtilen oyuncu bulunamadı!", "error") return end
    if source == target then exports.TR_noti:create(source, "Kendi ehliyetinize el koyamazsınız", "error") return end

    if not hasPlayerPermission(source, "isDev") and isPlayerOnDuty(target) then exports.TR_noti:create(source, "Yetkili ekibinden birisine bu işlemi yapamazsınız!.", "error") return end

    local targetUID = getElementData(target, "characterUID")
    local targetName = getPlayerName(target)
    local targetSerial = getPlayerSerial(target)
    local adminName = getPlayerName(source)
    exports.TR_mysql:querry(string.format("INSERT INTO `tr_penalties` (`plrUID`, `serial`, `reason`, `time`, `timeEnd`, `type`, `admin`) VALUES (?, ?, ?, NOW(), DATE_ADD(NOW(), INTERVAL %d %s), 'license', ?)", count, avaliableMuteUnits[unit]), targetUID, targetSerial, reason, adminName)

    exports.TR_noti:create(root, string.format("%s adlı oyuncunun ehliyetine el konuldu.\nSebep: %s", targetName, reason), "penalty")

    local seat = getPedOccupiedVehicleSeat(target)
    if seat == 0 then
        removePedFromVehicle(target)
    end

    local time = getRealTime()
    exports.TR_discord:sendChannelMsg("adminPenalties", {
        time = string.format("[%02d:%02d %02d.%02d]", time.hour, time.minute, time.monthday, time.month),
        author = adminName,
        text = string.format("%s adlı oyuncunun ehliyetine %d%s süreyle el konuldu sebep: %s", targetName, count, unit, reason),
    })
end
addEvent("tplPlayerCommand", true)
addEventHandler("tplPlayerCommand", root, tpl)
exports.TR_chat:addCommand("tpl", "tplPlayerCommand")

function resetMail(targetUID, mail)
    if not hasPlayerPermission(source, "resetMail") then return end
    if not targetUID or not mail then triggerClientEvent(source, "showCustomMessage", resourceRoot, "#008a2eKomut Kullanımı", "#438f5c/resetMail (UID) (mail)", "files/images/command.png") return end

    exports.TR_mysql:querry("UPDATE tr_accounts SET email = ? WHERE UID = ? LIMIT 1", mail, targetUID)
    exports.TR_noti:create(source, "Hesabın e-postası başarıyla güncellendi.", "success")

    local time = getRealTime()
    exports.TR_discord:sendChannelMsg("adminAction", {
        time = string.format("[%02d:%02d %02d.%02d]", time.hour, time.minute, time.monthday, time.month),
        author = getPlayerName(source),
        text = string.format("%d UID'li hesabın e-postası %s olarak değiştirildi.", targetUID, mail),
    })
end
addEvent("resetMail", true)
addEventHandler("resetMail", root, resetMail)
exports.TR_chat:addCommand("resetMail", "resetMail")


-- Teleports
function tpToPlayer(targetID)
    if not hasPlayerPermission(source, "playerTp") then return end
    if not targetID then triggerClientEvent(source, "showCustomMessage", resourceRoot, "#008a2eKomut Kullanımı", "#438f5c/tp (ID/İsim)", "files/images/command.png") return end

    local target = findPlayer(source, targetID)
    if not target then exports.TR_noti:create(source, "Belirtilen oyuncu bulunamadı!", "error") return end
    if source == target then exports.TR_noti:create(source, "Kendinize ışınlanamazsınız!", "error") return end

    if isPlayerOnDuty(target) then
        if not hasPlayerPermission(source, "isDev") and hasPlayerPermission(target, "isDev") then
            exports.TR_noti:create(source, "Bu oyuncuya ışınlamazsınız!", "system")
            exports.TR_noti:create(target, string.format("%s isimli yetkili size ışınlamaya çalıştı.", getPlayerName(source)), "system")
            return
        end
    end

    local veh = getPedOccupiedVehicle(target)
    if veh then
        local passangers = getVehicleMaxPassengers(veh)
        local found = false
        for i = 0, passangers do
            if not getVehicleOccupant(veh, i) then
                found = true
                warpPedIntoVehicle(source, veh, i)
                break
            end
        end

        if not found then
            setElementPosition(source, Vector3(getElementPosition(target)))
            setElementInterior(source, getElementInterior(target))
            setElementDimension(source, getElementDimension(target))
        end
    else
        setElementPosition(source, Vector3(getElementPosition(target)))
        setElementInterior(source, getElementInterior(target))
        setElementDimension(source, getElementDimension(target))
    end

    local targetName = getPlayerName(target)
    local adminName = getPlayerName(source)
    exports.TR_noti:create(source, string.format("%s adlı oyuncuya ışınlandınız.", targetName), "system")
    exports.TR_noti:create(target, string.format("%s adlı yetkili size ışınlandı.", adminName), "system")

    local time = getRealTime()
    exports.TR_discord:sendChannelMsg("adminAction", {
        time = string.format("[%02d:%02d %02d.%02d]", time.hour, time.minute, time.monthday, time.month),
        author = adminName,
        text = string.format("%s adlı oyuncu ışınlandı", targetName),
    })
end
addEvent("tpToPlayerCommand", true)
addEventHandler("tpToPlayerCommand", root, tpToPlayer)
exports.TR_chat:addCommand("tp", "tpToPlayerCommand")

function tpPlayerHere(targetID)
    if not hasPlayerPermission(source, "playerTp") then return end
    if not targetID then triggerClientEvent(source, "showCustomMessage", resourceRoot, "#008a2eKomut Kullanımı", "#438f5c/tphere (ID/İsim)", "files/images/command.png") return end

    local target = findPlayer(source, targetID)
    if not target then exports.TR_noti:create(source, "Belirtilen oyuncu bulunamadı!", "error") return end
    if source == target then exports.TR_noti:create(source, "Kendinizi kendinize ışınlayamazsınız!.", "error") return end
    if getElementData(target, "prisonIndex") then exports.TR_noti:create(source, "Hapishanedeki birisini ışınlıyamazsınız!", "error") return end

    if getPedOccupiedVehicle(target) then removePedFromVehicle(target) end
    setElementPosition(target, Vector3(getElementPosition(source)))
    setElementInterior(target, getElementInterior(source))
    setElementDimension(target, getElementDimension(source))

    local targetName = getPlayerName(target)
    local adminName = getPlayerName(source)
    exports.TR_noti:create(source, string.format("%s isimli oyuncuyu kendinize ışınladınız.", targetName), "system")
    exports.TR_noti:create(target, string.format("%s admin sizi kendisine ışınladı.", adminName), "system")

    local time = getRealTime()
    exports.TR_discord:sendChannelMsg("adminAction", {
        time = string.format("[%02d:%02d %02d.%02d]", time.hour, time.minute, time.monthday, time.month),
        author = adminName,
        text = string.format("%s adlı oyuncuyu kendisine ışınladı", targetName),
    })
end
addEvent("tpHerePlayerCommand", true)
addEventHandler("tpHerePlayerCommand", root, tpPlayerHere)
exports.TR_chat:addCommand("tphere", "tpHerePlayerCommand")

function tpVehHere(targetID)
    if not hasPlayerPermission(source, "vehicleTp") then return end
    if not targetID then triggerClientEvent(source, "showCustomMessage", resourceRoot, "#008a2eKomut Kullanımı", "#438f5c/tpv (Araç ID)", "files/images/command.png") return end

    local target = getElementByID("vehicle"..targetID)
    if not target then exports.TR_noti:create(source, "Belirtilen araç bulunamadı.", "error") return end

    if getElementDimension(source) ~= 0 or getElementInterior(source) ~= 0 then exports.TR_noti:create(source, "İnteriordayken araca ışınlanamazsın.", "error") return end

    setElementPosition(source, Vector3(getElementPosition(target)))
    exports.TR_noti:create(source, string.format("%d ID'li araca ışınlandınız.", targetID), "system")

    local adminName = getPlayerName(source)
    local time = getRealTime()
    exports.TR_discord:sendChannelMsg("adminAction", {
        time = string.format("[%02d:%02d %02d.%02d]", time.hour, time.minute, time.monthday, time.month),
        author = adminName,
        text = string.format("%d ID'li araca ışınlandı.", tonumber(targetID)),
    })
end
addEvent("tpHereVehicleCommand", true)
addEventHandler("tpHereVehicleCommand", root, tpVehHere)
exports.TR_chat:addCommand("tpv", "tpHereVehicleCommand")

function tpToVeh(targetID)
    if not hasPlayerPermission(source, "vehicleTp") then return end
    if not targetID then triggerClientEvent(source, "showCustomMessage", resourceRoot, "#008a2eKomut Kullanımı", "#438f5c/tpvhere (Araç ID)", "files/images/command.png") return end

    local target = getElementByID("vehicle"..targetID)
    if not target then exports.TR_noti:create(source, "Belirtilen araç bulunamadı!", "error") return end

    if getElementDimension(source) ~= 0 or getElementInterior(source) ~= 0 then exports.TR_noti:create(source, "İnterior içindeyken aracı kendinize ışınlıyamazsınız!", "error") return end

    setElementPosition(target, Vector3(getElementPosition(source)))
    exports.TR_noti:create(source, string.format("%d ID'li aracı kendinize ışınladınız.", targetID), "system")

    local adminName = getPlayerName(source)
    local time = getRealTime()
    exports.TR_discord:sendChannelMsg("adminAction", {
        time = string.format("[%02d:%02d %02d.%02d]", time.hour, time.minute, time.monthday, time.month),
        author = adminName,
        text = string.format("%d ID'li aracı kendine ışınladı.", tonumber(targetID)),
    })
end
addEvent("tpToVehicleCommand", true)
addEventHandler("tpToVehicleCommand", root, tpToVeh)
exports.TR_chat:addCommand("tpvhere", "tpToVehicleCommand")

function adminTeleportVehicleGarage(targetID)
    if not hasPlayerPermission(source, "vehicleTp") then return end
    if not targetID then triggerClientEvent(source, "showCustomMessage", resourceRoot, "#008a2eKomut Kullanımı", "#438f5c/tvg (Araç ID)", "files/images/command.png") return end

    local vehicle = getElementByID("vehicle"..targetID)
    if not vehicle then exports.TR_noti:create(source, "Belirtilen araç bulunamadı.", "error") return end

    local data = getElementData(vehicle, "vehicleData")
    exports.TR_vehicles:saveVehicle(vehicle)
    exports.TR_mysql:querry("UPDATE tr_vehicles SET parking = ? WHERE ID = ? LIMIT 1", 50, data.ID)
    destroyElement(vehicle)

    exports.TR_noti:create(source, "Aracı park yerine başarıyla ışınladınız.", "success")

    local time = getRealTime()
    exports.TR_discord:sendChannelMsg("adminAction", {
        time = string.format("[%02d:%02d %02d.%02d]", time.hour, time.minute, time.monthday, time.month),
        author = getPlayerName(source),
        text = string.format("%d ID'li aracı park yerine ışınladı.", tonumber(targetID)),
    })
end
addEvent("adminTeleportVehicleGarage", true)
addEventHandler("adminTeleportVehicleGarage", root, adminTeleportVehicleGarage)
exports.TR_chat:addCommand("tpvg", "adminTeleportVehicleGarage")




-- Reports
function report(targetID, ...)
    local reason = table.concat(arg, " ")
    if not targetID or not reason then triggerClientEvent(source, "showCustomMessage", resourceRoot, "#008a2eKomut Kullanımı", "#438f5c/report (ID/İsim) (sebep)", "files/images/command.png") return end
    if string.len(reason) < 1 then triggerClientEvent(source, "showCustomMessage", resourceRoot, "#008a2eKomut Kullanımı", "#438f5c/report (ID/İsim) (sebep)", "files/images/command.png") return end

    local target = findPlayer(source, targetID)
    if not target then exports.TR_noti:create(source, "Belirtilen oyuncu bulunamadı!", "error") return end

    local reportTime = getElementData(source, "reportTime")
    if reportTime then
        if (getTickCount() - reportTime)/60000 < 1 then
            exports.TR_noti:create(source, "Dakikada bir kez yetkili ekibine rapor yolluyabilirsiniz.", "error")
            return
        end
    end
    setElementData(source, "reportTime", getTickCount())

    exports.TR_noti:create(source, string.format("%s adlı oyuncuyla ilgili rapor yetkili ekibine iletildi.", getPlayerName(target)), "system")
    local _, _, id = exports.TR_mysql:querry("INSERT INTO tr_reports (reporter, reported, reason) VALUES (?, ?, ?)", getPlayerName(source), getPlayerName(target), reason)

    updateReports()
end
addEvent("reportCommand", true)
addEventHandler("reportCommand", root, report)
exports.TR_chat:addCommand("report", "reportCommand")

function areport()
    if not isPlayerOnDuty(source) then return end

    local reportData = exports.TR_mysql:querry("SELECT ID, reporter, reported, reason FROM tr_reports WHERE admin IS NULL LIMIT 1")
    if reportData and reportData[1] then
        local reporter = reportData[1].reporter
        local reported = reportData[1].reported

        local reporterPlr = getPlayerFromName(reportData[1].reporter)
        if reporterPlr then
            reporter = string.format("[%d] %s", getElementData(reporterPlr, "ID") or 0, reporter or "Brak")
            exports.TR_noti:create(reporterPlr, string.format("%s adlı yetkili raporunuzu kabul etti.", getPlayerName(source)), "system")
        end

        local reportedPlr = getPlayerFromName(reportData[1].reported)
        if reportedPlr then reported = string.format("[%d] %s", getElementData(reportedPlr, "ID") or 0, reported or "Brak") end

        triggerClientEvent(source, "showCustomMessage", resourceRoot, string.format("#efd133%s → %s", reporter, reported), "#f4e066"..reportData[1].reason, "files/images/report.png")
        exports.TR_mysql:querry("UPDATE tr_reports SET admin = ? WHERE ID = ? LIMIT 1", getPlayerName(source), reportData[1].ID)

    else
        exports.TR_noti:create(source, "Kabul edilecek başka rapor yok", "system")
    end
    updateReports()
end
addEvent("areportCommand", true)
addEventHandler("areportCommand", root, areport)
exports.TR_chat:addCommand("areport", "areportCommand")

function getAdminReports()
    if not isPlayerOnDuty(source) then return end

    if hasPlayerPermission(source, "allReports") then
        local time = getRealTime()
        local reports = exports.TR_mysql:querry("SELECT tr_accounts.username as username, COUNT(*) as count FROM tr_reports LEFT JOIN tr_accounts ON tr_accounts.username = tr_reports.admin WHERE YEARWEEK(`date`, 1) = YEARWEEK(CURDATE(), 1) GROUP BY tr_accounts.username")
        if reports and reports[1] then
            local text = ""
            for i, v in pairs(reports) do
                text = string.format("%s%s: %s", i == 1 and text or text.."\n", v.username or "ERROR", v.count or "0")
            end
            triggerClientEvent(source, "showCustomMessage", resourceRoot, "BU HAFTANIN RAPOR ISTATISTIKLERI", text, "files/images/system.png")
        else
            triggerClientEvent(source, "showCustomMessage", resourceRoot, "BU HAFTANIN RAPOR ISTATISTIKLERI", "Bu ay bir rapor istatistiği yok", "files/images/system.png")
        end
    else
        local time = getRealTime()
        local reports = exports.TR_mysql:querry("SELECT COUNT(*) as count FROM tr_reports WHERE admin = ? AND YEARWEEK(`date`, 1) = YEARWEEK(CURDATE(), 1)", getPlayerName(source))
        if reports and reports[1] then
            triggerClientEvent(source, "showCustomMessage", resourceRoot, "BU HAFTANIN RAPOR ISTATISTIKLERI", string.format("İlgilenilen Rapor: %s", reports[1].count), "files/images/system.png")
        else
            triggerClientEvent(source, "showCustomMessage", resourceRoot, "BU HAFTANIN RAPOR ISTATISTIKLERI", "Bu ay hiç raporla ilgilenmemişsiniz.", "files/images/system.png")
        end
    end
end
addEvent("getAdminReports", true)
addEventHandler("getAdminReports", root, getAdminReports)
exports.TR_chat:addCommand("reports", "getAdminReports")



-- Online admin list
function onlineAdmins()
    local adminText = "#7e0f0fYetkili: \n#999999"
    local admins = {
        ["owner"] = {},
        ["guardian"] = {},
        ["admin"] = {},
        ["moderator"] = {},
        ["support"] = {},
    }

    for i, v in pairs(getElementsByType("player")) do
        local rank = getElementData(v, "adminDuty")
        if rank and not getElementData(v, "fakeName") then
            if string.find(rank, "owner") then table.insert(admins["owner"], {getElementData(v, "ID"), getPlayerName(v)})
            elseif string.find(rank, "guardian") then table.insert(admins["guardian"], {getElementData(v, "ID"), getPlayerName(v)})
            elseif string.find(rank, "admin") then table.insert(admins["admin"], {getElementData(v, "ID"), getPlayerName(v)})
            elseif string.find(rank, "moderator") then table.insert(admins["moderator"], {getElementData(v, "ID"), getPlayerName(v)})
            elseif string.find(rank, "support") then table.insert(admins["support"], {getElementData(v, "ID"), getPlayerName(v)})
            end
        end
    end

    if #admins["owner"] > 0 then
        for i, v in pairs(admins["owner"]) do
            adminText = string.format("%s%s#bbbbbb[%d] #999999%s%s", adminText, i == 1 and "" or " ", v[1], v[2], i == #admins["owner"] and "" or ", ")
        end
    else
        adminText = adminText .. "Yok"
    end

    adminText = adminText .. " \n \n#e73f0bGuardian: \n#999999"
    if #admins["guardian"] > 0 then
        for i, v in pairs(admins["guardian"]) do
            adminText = string.format("%s%s#bbbbbb[%d] #999999%s%s", adminText, i == 1 and "" or " ", v[1], v[2], i == #admins["guardian"] and "" or ", ")
        end
    else
        adminText = adminText .. "Yok"
    end

    adminText = adminText .. " \n \n#da1717Administrator: \n#999999"
    if #admins["admin"] > 0 then
        for i, v in pairs(admins["admin"]) do
            adminText = string.format("%s%s#bbbbbb[%d] #999999%s%s", adminText, i == 1 and "" or " ", v[1], v[2], i == #admins["admin"] and "" or ", ")
        end
    else
        adminText = adminText .. "Yok"
    end

    adminText = adminText .. " \n \n#0a8f0bModerator: \n#999999"
    if #admins["moderator"] > 0 then
        for i, v in pairs(admins["moderator"]) do
            adminText = string.format("%s%s#bbbbbb[%d] #999999%s%s", adminText, i == 1 and "" or " ", v[1], v[2], i == #admins["moderator"] and "" or ", ")
        end
    else
        adminText = adminText .. "Yok"
    end

    adminText = adminText .. " \n \n#1ba3f3Supporter: \n#999999"
    if #admins["support"] > 0 then
        for i, v in pairs(admins["support"]) do
            adminText = string.format("%s%s#bbbbbb[%d] #999999%s%s", adminText, i == 1 and "" or " ", v[1], v[2], i == #admins["support"] and "" or ", ")
        end
    else
        adminText = adminText .. "Yok"
    end

    triggerClientEvent(source, "showCustomMessage", resourceRoot, "ADMINISTRACJA ONLINE", adminText, "files/images/system.png")
end
addEvent("onlineAdmins", true)
addEventHandler("onlineAdmins", root, onlineAdmins)
exports.TR_chat:addCommand("admins", "onlineAdmins")

function adminHealPlayer(targetID)
    if not isPlayerOnDuty(source) then return end
    if not targetID then triggerClientEvent(source, "showCustomMessage", resourceRoot, "#008a2eKomut Kullanımı", "#438f5c/heal (ID/İsim)", "files/images/command.png") return end

    local target = findPlayer(source, targetID)
    if not target then exports.TR_noti:create(source, "Belirtilen oyuncu bulunamadı!", "error") return end

    setElementHealth(target, 100)

    local adminName = getPlayerName(source)
    local targetName = getPlayerName(target)
    exports.TR_noti:create(source, string.format("%s adlı oyuncuyu iyileştirdin.", targetName), "success")
    exports.TR_noti:create(target, string.format("%s adlı yetkili seni iyileştirdi.", adminName), "system")

    local time = getRealTime()
    exports.TR_discord:sendChannelMsg("adminAction", {
        time = string.format("[%02d:%02d %02d.%02d]", time.hour, time.minute, time.monthday, time.month),
        author = adminName,
        text = string.format("%s adlı oyuncuyu iyileştirdi", targetName),
    })
end
addEvent("adminHealPlayer", true)
addEventHandler("adminHealPlayer", root, adminHealPlayer)
exports.TR_chat:addCommand("heal", "adminHealPlayer")





-- Vehicle events
function adminFuelVehicle()
    if not hasPlayerPermission(source, "vehicleFuel") then return end
    local veh = getPedOccupiedVehicle(source)
    if not veh then exports.TR_noti:create(source, "Aracın yakıtını doldurmak için araca binmelisiniz", "error") return end

    local data = getElementData(veh, "vehicleData")
    if not data then exports.TR_noti:create(source, "Bu aracın yakıtını dolduramazsınız.", "error") return  end

    data.fuel = data.fuel + 10
    setElementData(veh, "vehicleData", data, false)
    triggerClientEvent(source, "playerSpeedometerOpen", resourceRoot, veh, data)
    exports.TR_noti:create(source, "Araca başarıyla 10 Litre benzin eklendi.", "success")
end
addEvent("adminFuelVehicle", true)
addEventHandler("adminFuelVehicle", root, adminFuelVehicle)
exports.TR_chat:addCommand("fuel", "adminFuelVehicle")


-- Admin addons
function adminJetPack()
    if not isPlayerOnDuty(source) then return end

    if isPedWearingJetpack(source) then
        setPedWearingJetpack(source, false)
    else
        setPedWearingJetpack(source, true)
    end
end
addEvent("adminJetPack", true)
addEventHandler("adminJetPack", root, adminJetPack)
exports.TR_chat:addCommand("jp", "adminJetPack")

function adminInvisible()
    if not isPlayerOnDuty(source) then return end

    local alpha = getElementData(source, "inv")
    if alpha then
        setElementAlpha(source, 255)
        setElementData(source, "inv", false)
    else
        setElementData(source, "inv", true)
    end
end
addEvent("adminInvisible", true)
addEventHandler("adminInvisible", root, adminInvisible)
exports.TR_chat:addCommand("inv", "adminInvisible")

function adminInterior(int)
    if not isPlayerOnDuty(source) then return end
    if tonumber(int) == nil then triggerClientEvent(source, "showCustomMessage", resourceRoot, "#008a2eKomut Kullanımı", "#438f5c/int (id)", "files/images/command.png") return end
    setElementInterior(source, tonumber(int))

    if adminVehicles[source] then
        exports.TR_noti:create(source, "Araçları oluşturduğunuz interiordan ayrıldığınız için araçlar silindi.", "info")
    end
    removeAdminSpawnedVehicles(source)
end
addEvent("adminInterior", true)
addEventHandler("adminInterior", root, adminInterior)
exports.TR_chat:addCommand("int", "adminInterior")

function adminDimension(dim)
    if not isPlayerOnDuty(source) then return end
    if tonumber(dim) == nil then triggerClientEvent(source, "showCustomMessage", resourceRoot, "#008a2eKomut Kullanımı", "#438f5c/dim (id)", "files/images/command.png") return end
    setElementDimension(source, tonumber(dim))

    if adminVehicles[source] then
        exports.TR_noti:create(source, "Araçları oluşturduğunuz boyuttan ayrıldığınız için araçlar silindi.", "info")
    end
    removeAdminSpawnedVehicles(source)
end
addEvent("adminDimension", true)
addEventHandler("adminDimension", root, adminDimension)
exports.TR_chat:addCommand("dim", "adminDimension")

function adminSpec(targetID)
    if not isPlayerOnDuty(source) then return end
    if not targetID then triggerClientEvent(source, "showCustomMessage", resourceRoot, "#008a2eKomut Kullanımı", "#438f5c/spec (ID/İsim)", "files/images/command.png") return end

    local target = findPlayer(source, targetID)
    if not target then exports.TR_noti:create(source, "Belirtilen oyuncu bulunamadı!", "error") return end

    triggerClientEvent(source, "createSpecWindow", resourceRoot, target)
end
addEvent("adminSpec", true)
addEventHandler("adminSpec", root, adminSpec)
exports.TR_chat:addCommand("spec", "adminSpec")


function adminSpawnVeh(model)
    if not isPlayerOnDuty(source) then return end

    local model = tonumber(model)
    if not model then triggerClientEvent(source, "showCustomMessage", resourceRoot, "#008a2eKomut Kullanımı", "#438f5c/cv (model)", "files/images/command.png") return end
    if not isVehicleModelAvaliable(model) then exports.TR_noti:create(source, "Böyle bir araç modeli mevcut değil.", "error") return end
    if getElementInterior(source) == 0 and getElementDimension(source) == 0 then exports.TR_noti:create(source, "Yalnızca bir interiorda ya da farklı bir boyutta bir araç oluşturabilirsiniz.", "error") return end

    if not adminVehicles[source] then adminVehicles[source] = {} end
    if #adminVehicles[source] >= 50 then exports.TR_noti:create(source, "Araç oluşturma limitine ulaştınız", "error") return end

    local veh = createVehicle(model, Vector3(getElementPosition(source)),Vector3(getElementRotation(source)))
    setElementData(veh, "vehicleData", {
        mileage = 0,
        fuel = 100,
    }, false)
    setElementInterior(veh, getElementInterior(source))
    setElementDimension(veh, getElementDimension(source))
    setElementData(veh, "freeForAll", true)
    warpPedIntoVehicle(source, veh)
    table.insert(adminVehicles[source], veh)
end
addEvent("adminSpawnVeh", true)
addEventHandler("adminSpawnVeh", root, adminSpawnVeh)
exports.TR_chat:addCommand("cv", "adminSpawnVeh")

function adminDespawnVeh(model)
    if not isPlayerOnDuty(source) then return end
    if not adminVehicles[source] then exports.TR_noti:create(source, "Oluşturduğunuz bir araç bulunmamaktadır.", "error") return end

    removeAdminSpawnedVehicles(source)
    exports.TR_noti:create(source, "Tüm araçlar başarıyla kaldırıldı.", "success")
end
addEvent("adminDespawnVeh", true)
addEventHandler("adminDespawnVeh", root, adminDespawnVeh)
exports.TR_chat:addCommand("dcv", "adminDespawnVeh")


-- Admin events
function adminChat(...)
    if not isPlayerOnDuty(source, true) then return end

    local players = getElementsByType("player")
    local id = getElementData(source, "ID")
    local plrName = getPlayerName(source)
    local msg = table.concat({...}, " ")

    local rank = getAdminRank(source)

    for _, player in ipairs(players) do
        local isAdm = getAdminRank(player)
        if isAdm then
            triggerClientEvent(player, "showCustomMessage", resourceRoot, string.format("%s %s", rank, plrName), "#cccccc"..msg, "files/images/system.png")
        end
    end
end
addEvent("adminChat", true)
addEventHandler("adminChat", root, adminChat)
exports.TR_chat:addCommand("a", "adminChat")

function adminNotiChat(...)
    if not isPlayerOnDuty(source) then return end

    local players = getElementsByType("player")
    local id = getElementData(source, "ID")
    local plrName = getPlayerName(source)
    local msg = table.concat({...}, " ")

    local rank = getAdminRank(source)
    triggerClientEvent(root, "showCustomMessage", resourceRoot, string.format("%s %s", rank, plrName), "#cccccc"..msg, "files/images/megaphone.png")
end
addEvent("adminNotiChat", true)
addEventHandler("adminNotiChat", root, adminNotiChat)
exports.TR_chat:addCommand("info", "adminNotiChat")

function createAdminEvent(type, price)
    if not isPlayerOnDuty(source) then return end

    if not type or not price then
        triggerClientEvent(source, "showCustomMessage", resourceRoot, "#008a2eKomut Kullanımı", "#438f5c/sevent (tür) (ödül)\nMD - Monster Derby (kazanana ödül)\nCD - Crossed Derby (kazanana ödül)\nOX - Prawda / Fałsz (kazanana ödül, yetkili gerekli)\nPB - Pirate Boarding (ödül ekip üyeleri arasında paylaştırılır)\nFO - Falling Boards (ödül ekip üyeleri arasında paylaştırılır)", "files/images/command.png")
        return
    end

    if not exports.TR_events:canCreateEvent(source) then return end

    if not exports.TR_events:isEventExists(type) then
        exports.TR_noti:create(source, "Böyle bir etkinlik mevcut değil.", "error")
        return
    end

    local price = tonumber(price)
    if not price then
        exports.TR_noti:create(source, "Girilen tutar hatalı.", "error")
        return
    end

    if price < 0 then
        exports.TR_noti:create(source, "Girilen tutar hatalı.", "error")
        return
    end

    triggerClientEvent(source, "payForAdminEvent", resourceRoot, type, price)
end
addEvent("createAdminEvent", true)
addEventHandler("createAdminEvent", root, createAdminEvent)
exports.TR_chat:addCommand("sevent", "createAdminEvent")



-- Developers
function cmd_gp(plr, cmd)
    if not isPlayerOnDuty(plr) then return end
    if not hasPlayerPermission(plr, "isDev") then return end
	local x,y,z = getElementPosition(plr)
	local _,_,rz = getElementRotation(plr)
	local int = getElementInterior(plr)
	local dim = getElementDimension(plr)
	outputChatBox(x..", "..y..", "..z..", "..rz, plr)
	outputChatBox("int: "..int.." dim: "..dim, plr)
end
addCommandHandler("gp", cmd_gp)

addCommandHandler("setslots", function(source, cmd, count)
    if not isPlayerOnDuty(source) then return end
    if not hasPlayerPermission(source, "isDev") then return end

    local slots = tonumber(count)
    if slots == nil then return end

    if slots > 500 then slots = 500 end
    setMaxPlayers(slots)

    exports.TR_noti:create(source, string.format("%d adet slot ayarlandı", slots), "success")
end)

addCommandHandler("setpasswd", function(source, cmd, pass)
    if not isPlayerOnDuty(source) then return end
    if not hasPlayerPermission(source, "isDev") then return end

    setServerPassword("")
end)

local sceneEnabled = false
function adminScene(...)
    if not isPlayerOnDuty(source) then return end
    if not hasPlayerPermission(source, "isDev") then return end

    if sceneEnabled then
        exports.TR_starter:stopResources({"eventScene"})
        exports.TR_noti:create(source, "Sahne kapatıldı.", "system")
        sceneEnabled = nil
    else
        exports.TR_starter:startResources({"eventScene"})
        exports.TR_noti:create(source, "Sahne açıldı.", "system")
        sceneEnabled = true
    end
end
addEvent("adminScene", true)
addEventHandler("adminScene", root, adminScene)
exports.TR_chat:addCommand("scene", "adminScene")


-- Teleport creator
function ctp(slots)
    if not isPlayerOnDuty(source) then return end
    local slots = tonumber(slots)
    if not slots then triggerClientEvent(source, "showCustomMessage", resourceRoot, "#008a2eKomut Kullanımı", "#438f5c/ctp (slot miktarı)", "files/images/command.png") return end

    if adminTeleports[source] then exports.TR_noti:create(source, "Zaten bir ışınlanma yeri oluşturdunuz. Yeni bir tane oluşturmak için öncekini silmelisiniz!", "error") return end

    local pos = Vector3(getElementPosition(source))
    local int = getElementInterior(source)
    local dim = getElementDimension(source)
    local adminName = getPlayerName(source)
    adminTeleports[source] = {
        slots = slots,
        pos = pos,
        element = createElement("adminTP"),
        int = int,
        dim = dim,
        players = {},
    }
    setElementPosition(adminTeleports[source].element, pos)
    setElementInterior(adminTeleports[source].element, int)
    setElementDimension(adminTeleports[source].element, dim)

    setElementData(adminTeleports[source].element, "data", {
        slots = slots,
        admin = adminName,
    })

    exports.TR_noti:create(source, "Işınlanma yeri başarıyla oluşturuldu", "success")
    exports.TR_noti:create(root, string.format("%s adlı yeri ışınlanma yeri oluşturdu.\nIşınlanmak için /tpa %s", adminName, adminName), "system", 10)

    local time = getRealTime()
    exports.TR_discord:sendChannelMsg("adminAction", {
        time = string.format("[%02d:%02d %02d.%02d]", time.hour, time.minute, time.monthday, time.month),
        author = adminName,
        text = string.format("bir ışınlayıcı yarattı (x = %.2f, y = %.2f, z = %.2f, int = %d, dim = %d) dla %d osób.", pos.x, pos.y, pos.z, int, dim, slots),
    })
end
addEvent("ctpAdminPoint", true)
addEventHandler("ctpAdminPoint", root, ctp)
exports.TR_chat:addCommand("ctp", "ctpAdminPoint")

function dtp()
    if not isPlayerOnDuty(source) then return end
    if not adminTeleports[source] then exports.TR_noti:create(source, "Oluşturduğunuz bir ışınlanma yeriniz yok", "error") return end

    destroyElement(adminTeleports[source].element)
    adminTeleports[source] = nil

    exports.TR_noti:create(source, "Işınlanma yeriniz başarıyla silindi.", "success")
end
addEvent("dtpAdminPoint", true)
addEventHandler("dtpAdminPoint", root, dtp)
exports.TR_chat:addCommand("dtp", "dtpAdminPoint")

function tpa(playerID)
    if not playerID then triggerClientEvent(source, "showCustomMessage", resourceRoot, "#008a2eKomut Kullanımı", "#438f5c/tpa (ID/İsim)", "files/images/command.png") return end

    local admin = getElementByID("ID"..playerID)
    if not admin then admin = getPlayerFromName(playerID) end
    if not admin or not adminTeleports[admin] then exports.TR_noti:create(source, "Bu yetkili her hangi bir ışınlanma yeri oluşturmadı", "error") return end
    if adminTeleports[admin].slots <= 0 then exports.TR_noti:create(source, "Bu ışınlanma yeri için bütün slotlar kullanıldı", "error") return end
    if adminTeleports[admin].players[source] then exports.TR_noti:create(source, "Bu ışınlamayı zaten kullandınız", "error") return end

    adminTeleports[admin].players[source] = true
    adminTeleports[admin].slots = adminTeleports[admin].slots - 1

    local data = getElementData(adminTeleports[admin].element, "data")
    data.slots = data.slots - 1
    setElementData(adminTeleports[admin].element, "data", data)

    removePedFromVehicle(source)
    setElementPosition(source, adminTeleports[admin].pos)
    setElementInterior(source, adminTeleports[admin].int)
    setElementDimension(source, adminTeleports[admin].dim)

    exports.TR_noti:create(source, "Başarılı bir şekilde ışınlanma yerine ışınlandınız", "success")

    if adminTeleports[admin].slots <= 0 then
        destroyElement(adminTeleports[admin].element)
        adminTeleports[admin] = nil
    end
end
addEvent("tpaAdminPoint", true)
addEventHandler("tpaAdminPoint", root, tpa)
exports.TR_chat:addCommand("tpa", "tpaAdminPoint")

-- Utils
function reconnectPlayer()
    redirectPlayer(source, getServerConfigSetting("serverip"), getServerPort())
end
addEvent("reconnectPlayer", true)
addEventHandler("reconnectPlayer", root, reconnectPlayer)
exports.TR_chat:addCommand("reconnect", "reconnectPlayer")


function findPlayer(plr, id)
    local target = getElementByID("ID"..id)
    if not target then target = getPlayerFromName(id) end
    if not target or not isElement(target) then exports.TR_noti:create(plr, "Belirtilen oyuncu bulunamadı!", "error") return false end
    return target
end

function getAdminRank(plr)
    local rank = getElementData(plr, "adminDuty")
    if not rank then return false end

    if string.find(rank, "owner") then return "#7e0f0f[Z]" end
    if string.find(rank, "guardian") then return "#e73f0b[G]" end
    if string.find(rank, "admin") then return "#da1717[A]" end
    if string.find(rank, "moderator") then return "#0f6c10[M]" end
    if string.find(rank, "support") then return "#1ba3f3[S]" end
    if string.find(rank, "developer") then return "#9424b4[D]" end
end

function isVehicleModelAvaliable(model)
    for i, v in pairs(avaliableModels) do
        if v == model then return true end
    end
    return false
end