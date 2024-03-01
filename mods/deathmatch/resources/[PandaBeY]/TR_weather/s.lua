local settings = {
    changeTime = 3600000,

    states = {
        {
            cities = {
                "Los Santos", "Red County"
            },
            weathers = {0, 3, 7},
        },
        {
            cities = {
                "San Fierro", "Flint County",
            },
            weathers = {6, 5, 7},
        },
        {
            cities = {
                "Whetstone",
            },
            weathers = {15},
        },
        {
            cities = {
                "Las Venturas", "Bone County", "Tierra Robada",
            },
            weathers = {17, 18, 12},
        },
    }
}


WeatherSystem = {}
WeatherSystem.__index = WeatherSystem

function WeatherSystem:create(...)
    local instance = {}
    setmetatable(instance, WeatherSystem)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function WeatherSystem:constructor()
    self.weatherData = {}

    self.func = {}
    self.func.change = function() self:randomWeather() end
    setTimer(self.func.change, settings.changeTime, 0)
    setTimer(self.func.change, 1000, 1)

    self:timeSet()
    return true
end

function WeatherSystem:timeSet()
    local time = getRealTime()
    setTime(time.hour, time.minute)
    setMinuteDuration(60000)
end


function WeatherSystem:randomWeather()
    exports.TR_mysql:querry("DELETE FROM tr_weather")
    for i, _ in pairs(settings.states) do
        -- local weatherID = settings.states[i].weathers[math.random(1, #settings.states[i].weathers)]

        for _, v in pairs(settings.states[i].cities) do
            local weatherID = settings.states[i].weathers[math.random(1, #settings.states[i].weathers)]
            self.weatherData[v] = weatherID
            exports.TR_mysql:querry("INSERT INTO `tr_weather`(`weather_zone`, `weather_value`) VALUES (?, ?)", v, weatherID)
        end
    end

    triggerClientEvent(root, "updateWeatherData", resourceRoot, self.weatherData)
end

function WeatherSystem:getWeatherData()
    return self.weatherData
end


local weather = WeatherSystem:create()
function updateWeather(plr)
    if not plr then return end
    local time = getRealTime()
    triggerClientEvent(plr, "updateWeatherData", resourceRoot, weather:getWeatherData(), time.hour, time.minute, 60)
end
addEvent("updatePlayerWeather", true)
addEventHandler("updatePlayerWeather", root, updateWeather)

function getCurrentWeathers()
    return weather:getWeatherData()
end