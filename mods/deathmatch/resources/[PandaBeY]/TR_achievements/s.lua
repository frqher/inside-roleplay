function loadPlayerAchievements(plr)
    local plrUID = getElementData(plr, "characterUID")
    if not plrUID then return end

    local achievements = exports.TR_mysql:querry("SELECT * FROM tr_achievements WHERE plrUID = ?", plrUID, AchievementsCount)

    triggerClientEvent(plr, "createAchievements", resourceRoot, achievements)
end
addEvent("loadPlayerAchievements", true)
addEventHandler("loadPlayerAchievements", root, loadPlayerAchievements)

function addPlayerAchievement(achievement, prize, prizeValue)
    local plrUID = getElementData(client, "characterUID")
    if not plrUID then return end

    exports.TR_mysql:querry("INSERT INTO tr_achievements (plrUID, achievement, achieved) VALUES (?, ?, CURDATE())", plrUID, achievement)

    if prize == "money" then
        exports.TR_core:giveMoneyToPlayer(client, prizeValue)
    end
end
addEvent("addPlayerAchievement", true)
addEventHandler("addPlayerAchievement", resourceRoot, addPlayerAchievement)


function haniaCommand(targetID)
    triggerClientEvent(source, "addAchievements", resourceRoot, "haniaCommand")
end
addEvent("haniaCommand", true)
addEventHandler("haniaCommand", root, haniaCommand)
exports.TR_chat:addCommand("hania", "haniaCommand")


for i, v in pairs(getElementsByType("player")) do
    loadPlayerAchievements(v)
end