local settings = {}

AchievementChecker = {}
AchievementChecker.__index = AchievementChecker

function AchievementChecker:create(...)
    local instance = {}
    setmetatable(instance, AchievementChecker)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function AchievementChecker:constructor(...)
    self.achievements = {}

    self.func = {}
    self.func.checkAchievements = function() self:checkAchievements() end
    setTimer(self.func.checkAchievements, 10000, 0)

    self:buildAchievements(arg[1])
    return true
end

function AchievementChecker:buildAchievements(...)
    if not arg[1] then return end
    for i, v in pairs(arg[1]) do
        self.achievements[v.achievement] = self:formatDate(v.achieved)
    end
end

function AchievementChecker:getPlayerAchievements(...)
    local earned = 0
    local earnedList, notEarnedList = {}, {}

    for i, v in pairs(Achievements) do
        if self.achievements[i] then
            table.insert(earnedList, {
                ID = i,
                name = v.name,
                desc = v.desc,
                earned = self.achievements[i],
            })
            earned = earned + 1
        else
            table.insert(notEarnedList, {
                ID = i,
                name = v.name,
                desc = v.desc,
            })
        end
    end

    table.sort(earnedList, function(a, b)
        if not a or not b then return false end
        return a.name < b.name
    end)

    for i, v in pairs(notEarnedList) do
        table.insert(earnedList, v)
    end

    if earned == AchievementsCount - 1 then
        self:addAchievements("getAllAchievements")
    end
    return earnedList, earned
end

function AchievementChecker:addAchievements(...)
    if self.achievements[arg[1]] then return end

    self.achievements[arg[1]] = self:getDate()
    openAchievementInfo(Achievements[arg[1]].name, Achievements[arg[1]].desc, Achievements[arg[1]].gift[1])

    triggerServerEvent("addPlayerAchievement", resourceRoot, arg[1], Achievements[arg[1]].gift[2], Achievements[arg[1]].gift[3])
end



function AchievementChecker:checkAchievements(...)
    local data = getElementData(localPlayer, "characterData")
    local features = getElementData(localPlayer, "characterFeatures")
    if not data or not features then return end

    data.money = tonumber(data.money)
    if data.money >= 1000 then
        self:addAchievements("money1000")
    end
    if data.money >= 10000 then
        self:addAchievements("money10000")
    end
    if data.money >= 50000 then
        self:addAchievements("money50000")
    end
    if data.money >= 100000 then
        self:addAchievements("money100000")
    end
    if data.money >= 500000 then
        self:addAchievements("money500000")
    end
    if data.money >= 1000000 then
        self:addAchievements("money1000000")
    end

    if data.premium == "gold" then
        self:addAchievements("goldAccount")
    end
    if data.premium == "diamond" then
        self:addAchievements("diamondAccount")
    end

    local featureNames = {"strenght", "lungs", "steer", "weapon", "medicine", "fat", "casino", "cheers", "smoking", "pills"}
    for i, v in pairs(features) do
        if tonumber(v) >= 80 then
            self:addAchievements(featureNames[i].."Feature")
        end
    end

    if getElementData(localPlayer, "characterOrgID") then
        self:addAchievements("getOrganization")
    end

    if getDistanceBetweenPoints3D(Vector3(getElementPosition(localPlayer)), -2313.099609375, -1650.7001953125, 483.54138183594) <= 20 then
        self:addAchievements("mountainClimber")
    end

    local time = getRealTime()
    if time.hour >= 1 and time.hour <= 5 then
        self:addAchievements("nightGame")
    end
end





-- Utils
function AchievementChecker:formatDate(...)
    local d = split(arg[1], "-")
    return string.format("%02d.%02d.%04d", d[3], d[2], d[1])
end

function AchievementChecker:getDate()
    local time = getRealTime()
    return string.format("%02d.%02d.%04d", time.monthday, time.month + 1, time.year + 1900)
end


-- Exports
function getPlayerAchievements()
    if not settings.achievements then return {} end
    return settings.achievements:getPlayerAchievements()
end

function recheckAchievements()
    if not settings.achievements then return {} end
    return settings.achievements:checkAchievements()
end

function createAchievements(...)
    if settings.achievements then return end
    settings.achievements = AchievementChecker:create(...)
end
addEvent("createAchievements", true)
addEventHandler("createAchievements", root, createAchievements)

function addAchievements(...)
    if not settings.achievements then return end
    settings.achievements:addAchievements(...)
end
addEvent("addAchievements", true)
addEventHandler("addAchievements", root, addAchievements)
