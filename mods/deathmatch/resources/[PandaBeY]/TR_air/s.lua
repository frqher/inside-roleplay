function addAdminLogFlight(inVeh, start, stop, distance, nearCollectible)
    local time = getRealTime()
    exports.TR_discord:sendChannelMsg("adminFlight", {
        time = string.format("[%02d:%02d %02d.%02d]", time.hour, time.minute, time.monthday, time.month),
        author = getPlayerName(client),
        text = string.format("%s'den %s'e %s uçtu, %dm mesafe kat etti. %s", inVeh and "arabayla" or "yalnız", start, stop, distance, nearCollectible and "(BULMAYA YAKIN)" or ""),
    })
end
addEvent("addAdminLogFlight", true)
addEventHandler("addAdminLogFlight", resourceRoot, addAdminLogFlight)


function givePlayerJobScore(jobID, points, plural)
    local uid = getElementData(client, "characterUID")
    if not uid then return end

    exports.TR_noti:create(client, string.format("%d %s alırsınız. Kazandığınız puanlarla iş yerinde yükseltme satın alabilirsiniz.", points and tonumber(points) or 1, plural and plural or "punkt"), "success")
    exports.TR_mysql:querry(string.format("UPDATE tr_jobsPlayers SET points = points + %d WHERE playerUID = ? AND jobID = ? LIMIT 1", points and tonumber(points) or 1), uid, jobID)
end
addEvent("givePlayerJobScore", true)
addEventHandler("givePlayerJobScore", root, givePlayerJobScore)