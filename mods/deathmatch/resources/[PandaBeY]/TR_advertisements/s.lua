local data = {
    adverts = {},
    advertPlayers = {},
}

function openAdvert()
    data.timer = nil

    local info = data.adverts[1]
    data.advertPlayers[info.sender] = nil
    triggerClientEvent(root, "openAdvert", resourceRoot, info.sender, info.text)

    local time = getRealTime()
    exports.TR_discord:sendChannelMsg("add", {
        time = string.format("[%02d:%02d %02d.%02d]", time.hour, time.minute, time.monthday, time.month),
        author = info.sender,
        text = info.text,
    })

    table.remove(data.adverts, 1)

    createTimer()
end

function createTimer()
    if data.timer then return end
    if #data.adverts < 1 then return end

    data.timer = setTimer(openAdvert, 12000, 1)
end

function addAdvert(sender, text)
    if data.advertPlayers[sender] then return exports.TR_noti:create(source, "Sırada zaten bir reklamınız olduğu için başka bir reklam ekleyemezsiniz.", "error") end
    if #data.adverts >= 10 then return exports.TR_noti:create(source, "Sırada çok fazla reklam olduğu için reklamınız eklenmedi.", "error") end
    if string.len(text) < 5 then return end

    data.advertPlayers[sender] = true
    table.insert(data.adverts, #data.adverts + 1, {
        sender = sender,
        text = text,
    })

    exports.TR_noti:create(source, "Reklamınız sıraya eklendi.", "success")

    createTimer()
end
addEvent("addAdvert", true)
addEventHandler("addAdvert", root, addAdvert)

function addAdvertForPremium(...)
    local data = getElementData(source, "characterData")
    if not data then return end
    if data.premium ~= "gold" and data.premium ~= "diamond" then return end
    if not exports.TR_chat:hasPlayerMute(source, true) then exports.TR_noti:create("Yönetici tarafından sesiniz kapatıldığı için reklam yayınlayamazsınız.", "error") return end

    local msg = table.concat({...}, " ")
    addAdvert(getPlayerName(source), msg)
end
addEvent("addAdvertForPremium", true)
addEventHandler("addAdvertForPremium", root, addAdvertForPremium)
exports.TR_chat:addCommand("reklam", "addAdvertForPremium")