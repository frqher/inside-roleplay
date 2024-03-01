function takePlayerChips(count)
    exports.TR_mysql:querry("UPDATE tr_accounts SET `casinoChips` = `casinoChips` - ? WHERE UID = ? LIMIT 1", count, getElementData(client, "characterUID"))
end
addEvent("takePlayerChips", true)
addEventHandler("takePlayerChips", resourceRoot, takePlayerChips)

function givePlayerChips(count, playCount)
    exports.TR_mysql:querry("UPDATE tr_accounts SET `casinoChips` = `casinoChips` + ? WHERE UID = ? LIMIT 1", count, getElementData(client, "characterUID"))

    local time = getRealTime()
    exports.TR_discord:sendChannelMsg("casinoActions", {
      time = string.format("[%02d:%02d %02d.%02d]", time.hour, time.minute, time.monthday, time.month),
      author = getPlayerName(client),
      text = string.format("$%.2f için oynayan kumarhanede $%.2f kazandı.", count, playCount),
    })
end
addEvent("givePlayerChips", true)
addEventHandler("givePlayerChips", resourceRoot, givePlayerChips)