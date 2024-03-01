local settings = {
    featureData = {
        ["strenght"] = {
            textUp = {"OLUMLU KARAKTER ARTTI!", "Karakter gücü artırıldı."},
            textDown = {"OLUMLU ÖZELLİK AZALDI!", "Karakter gücü düşürüldü."},
            type = "positive",
            index = 1,

            earnToUpgrade = 900,
            earnToDowngrade = 10800,
        },
        ["lungs"] = {
            textUp = {"OLUMLU KARAKTER ARTTI!", "Karakter dayanıklılığı artırıldı."},
            textDown = {"OLUMLU ÖZELLİK AZALDI!", "Karakter dayanıklılığı azaltıldı."},
            type = "positive",
            index = 2,

            earnToUpgrade = 1200,
            earnToDowngrade = 10800,
        },
        ["steer"] = {
            textUp = {"OLUMLU KARAKTER ARTTI!", "Sürüş yeteneği artırıldı."},
            textDown = {"OLUMLU ÖZELLİK AZALDI!", "Sürüş yeteneği azaltıldı."},
            type = "positive",
            index = 3,

            earnToUpgrade = 1200,
            earnToDowngrade = 10800,
        },
        ["weapon"] = {
            textUp = {"OLUMLU KARAKTER ARTTI!", "Atış becerisi artırıldı."},
            textDown = {"OLUMLU ÖZELLİK AZALDI!", "Atış becerisi azaltıldı."},
            type = "positive",
            index = 4,

            earnToUpgrade = 100,
            earnToDowngrade = 10800,
        },
        ["medicine"] = {
            textUp = {"OLUMLU KARAKTER ARTTI!", "Tıp bilgisi arttı."},
            textDown = {"OLUMLU ÖZELLİK AZALDI!", "Tıp bilgisi azaldı."},
            type = "positive",
            index = 5,

            earnToUpgrade = 0,
            earnToDowngrade = 10800,
        },
        ["fat"] = {
            textUp = {"OLUMSUZ ÖZELLİK ARTTI!", "Obezite derecesi arttı."},
            textDown = {"OLUMSUZ ÖZELLİK AZALDI!", "Obezite derecesi azaldı."},
            type = "negative",
            index = 6,
        },
        ["casino"] = {
            textUp = {"OLUMSUZ ÖZELLİK ARTTI!", "Kumar bağımlılığı arttı."},
            textDown = {"OLUMSUZ ÖZELLİK AZALDI!", "Kumar bağımlılığı azaldı."},
            type = "negative",
            index = 7,

            earnToUpgrade = 0,
            earnToDowngrade = 1200,
        },
        ["cheers"] = {
            textUp = {"OLUMSUZ ÖZELLİK ARTTI!", "Alkol bağımlılığı arttı."},
            textDown = {"OLUMSUZ ÖZELLİK AZALDI!", "Alkol bağımlılığı azaldı."},
            type = "negative",
            index = 8,

            earnToUpgrade = 0,
            earnToDowngrade = 1200,
        },
        ["smoking"] = {
            textUp = {"OLUMSUZ ÖZELLİK ARTTI!", "Nikotin bağımlılığı arttı."},
            textDown = {"OLUMSUZ ÖZELLİK AZALDI!", "Nikotin bağımlılığı azaldı."},
            type = "negative",
            index = 9,

            earnToUpgrade = 0,
            earnToDowngrade = 1200,
        },
        ["pills"] = {
            textUp = {"OLUMSUZ ÖZELLİK ARTTI!", "Uyuşturucu bağımlılığı arttı."},
            textDown = {"OLUMSUZ ÖZELLİK AZALDI!", "Uyuşturucu bağımlılığı azaldı."},
            type = "negative",
            index = 10,

            earnToUpgrade = 0,
            earnToDowngrade = 1200,
        },
    },

    colors = {
        ["positive_up"] = {60, 200, 60},
        ["negative_up"] = {200, 0, 0},
        ["positive_down"] = {200, 0, 0},
        ["negative_down"] = {60, 200, 60},
    },

    blockedWeapons = {
        [0] = true,
        [1] = true,
        [2] = true,
        [3] = true,
        [4] = true,
        [5] = true,
        [6] = true,
        [7] = true,
        [8] = true,
        [9] = true,
        [37] = true,
        [38] = true,
        [16] = true,
        [17] = true,
        [18] = true,
        [39] = true,
        [41] = true,
        [42] = true,
        [43] = true,
        [10] = true,
        [11] = true,
        [12] = true,
        [13] = true,
        [14] = true,
        [15] = true,
        [44] = true,
        [45] = true,
        [46] = true,
        [40] = true,
    },
}

Features = {}
Features.__index = Features

function Features:create()
    local instance = {}
    setmetatable(instance, Features)
    if instance:constructor() then
        return instance
    end
    return false
end

function Features:constructor()
    self.notis = {}
    self.partValues = {}

    self.func = {}
    self.func.checkUpdate = function() self:checkUpdate() end
    -- self.func.render = function() self:render() end
    self.func.checkWeaponFire = function(...) self:checkWeaponFire(...) end

    -- addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientPlayerWeaponFire", localPlayer, self.func.checkWeaponFire)

    setTimer(self.func.checkUpdate, 1000, 0)

    for i, v in pairs(settings.featureData) do
        if v.earnToUpgrade then
            self.partValues[i] = {
                up = 0,
                down = 0,
            }
        end
    end

    self:updateStats()
    return true
end

function Features:updateStats()
    local lungs = getFeatureValue("lungs")
    local weapon = getFeatureValue("weapon")
    triggerServerEvent("updateFeatures", resourceRoot, lungs, weapon)
end

-- function Features:render()
--     dxDrawText("Pozostało do ulepszenia:\n"..inspect(self.partValues), 600, 100)
-- end

function Features:checkUpdate()
    self:checkStrenght()
    self:checkSprint()
    self:checkVehicleRide()
    self:checkWeaponDown()
    self:checkMedicine()

    self:checkCigarette()
    self:checkCasino()
    self:checkDrugs()
    self:checkAlcohol()
end

function Features:checkStrenght()
    self.partValues.strenght.down = self.partValues.strenght.down + 1

    if self.partValues.strenght.down >= settings.featureData.strenght.earnToDowngrade then
        self.partValues.strenght.down = 0

        self:updateState("strenght", -2)
    end
end

function Features:checkMedicine()
    self.partValues.medicine.down = self.partValues.medicine.down + 1

    if self.partValues.medicine.down >= settings.featureData.medicine.earnToDowngrade then
        self.partValues.medicine.down = 0

        self:updateState("medicine", -1)
    end
end

function Features:checkSprint()
    local moveState = getPedMoveState(localPlayer)
    if moveState ~= "sprint" and getFeatureValue("fat") < 80 then
        self.partValues.lungs.down = self.partValues.lungs.down + 1

        if self.partValues.lungs.down >= settings.featureData.lungs.earnToDowngrade then
            self.partValues.lungs.up = 0
            self.partValues.lungs.down = 0

            self:updateState("lungs", -1)
        end
    else
        self.partValues.lungs.up = self.partValues.lungs.up + 1

        if self.partValues.lungs.up >= settings.featureData.lungs.earnToUpgrade then
            self.partValues.lungs.up = 0
            self.partValues.lungs.down = 0

            self:updateState("lungs", 1)
            self:updateState("fat", -2)
        end
    end
end

function Features:checkVehicleRide()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then self:vehicleDowngrade() return end
    local seat = getPedOccupiedVehicleSeat(localPlayer)
    if seat ~= 0 then self:vehicleDowngrade() return end

    if self:getElementSpeed(veh, 1) >= 20 then
        self.partValues.steer.up = self.partValues.steer.up + 1

        if self.partValues.steer.up >= settings.featureData.steer.earnToUpgrade then
            self.partValues.steer.up = 0
            self.partValues.steer.down = 0

            self:updateState("steer", 1)
        end
    else
        self:vehicleDowngrade()
    end
end

function Features:checkWeaponFire(weapon)
    if settings.blockedWeapons[weapon] then return end
    self.partValues.weapon.up = self.partValues.weapon.up + 1
    self.partValues.weapon.down = 0

    if self.partValues.weapon.up >= settings.featureData.weapon.earnToUpgrade then
        self.partValues.weapon.up = 0
        self.partValues.weapon.down = 0

        self:updateState("weapon", 5)
    end
end

function Features:checkWeaponDown()
    self.partValues.weapon.down = self.partValues.weapon.down + 1

    if self.partValues.weapon.down >= settings.featureData.weapon.earnToDowngrade then
        self.partValues.weapon.up = 0
        self.partValues.weapon.down = 0

        self:updateState("weapon", -5)
    end
end

function Features:vehicleDowngrade()
    self.partValues.steer.down = self.partValues.steer.down + 1

    if self.partValues.steer.down >= settings.featureData.steer.earnToDowngrade then
        self.partValues.steer.up = 0
        self.partValues.steer.down = 0

        self:updateState("steer", -1)
    end
end

function Features:checkCigarette()
    self.partValues.smoking.down = self.partValues.smoking.down + 1

    if self.partValues.smoking.down >= settings.featureData.smoking.earnToDowngrade then
        self.partValues.smoking.down = 0
        self:updateState("smoking", -5)
    end

    local smoking = getFeatureValue("smoking")
    if smoking < 80 then return end
    self.partValues.smoking.up = self.partValues.smoking.up + 1

    if self.partValues.smoking.down >= 300 then
        self.partValues.smoking.down = 0
    end
end

function Features:checkCasino()
    self.partValues.casino.down = self.partValues.casino.down + 1

    if self.partValues.casino.down >= settings.featureData.casino.earnToDowngrade then
        self.partValues.casino.down = 0
        self:updateState("casino", -5)
    end
end

function Features:checkDrugs()
    self.partValues.pills.down = self.partValues.pills.down + 1

    if self.partValues.pills.down >= settings.featureData.pills.earnToDowngrade then
        self.partValues.pills.down = 0
        self:updateState("pills", -5)
    end
end

function Features:checkAlcohol()
    self.partValues.cheers.down = self.partValues.cheers.down + 1

    if self.partValues.cheers.down >= settings.featureData.cheers.earnToDowngrade then
        self.partValues.cheers.down = 0
        self:updateState("cheers", -5)
    end
end


function Features:setState(type, value)
    local data = getElementData(localPlayer, "characterFeatures")
    local index = settings.featureData[type].index

    local lastValue = data[index]
    data[index] = math.max(math.min(value, 100), 0)

    if lastValue ~= data[index] then
        setElementData(localPlayer, "characterFeatures", data)
        self:showInfo(type, data[index], lastValue > data[index])
    end

    if type == "lungs" or type == "weapon" then
        self:updateStats()
    end
end

function Features:updateState(type, value)
    local data = getElementData(localPlayer, "characterFeatures")
    local index = settings.featureData[type].index

    local lastValue = data[index]
    data[index] = math.max(math.min(data[index] + value, 100), 0)

    if lastValue ~= data[index] then
        setElementData(localPlayer, "characterFeatures", data)
        self:showInfo(type, data[index], lastValue > data[index])
    end

    if type == "lungs" or type == "weapon" then
        self:updateStats()
    end
end

function Features:showInfo(type, value, isLower)
    self.notis[type] = exports.TR_noti:create(isLower and settings.featureData[type].textDown or settings.featureData[type].textUp, "success", 4, false, string.format(":TR_dashboard/files/images/%s.png", type))

    local addon = isLower and "_down" or "_up"
    exports.TR_noti:setBarAnimation(self.notis[type], 0, value/100, 5, 5)
    exports.TR_noti:setIconColor(self.notis[type], settings.colors[settings.featureData[type].type..addon])
    exports.TR_noti:setColor(self.notis[type], settings.colors[settings.featureData[type].type..addon])
end

function Features:setElementSpeed(element, unit, speed)
    local unit    = unit or 0
    local speed   = tonumber(speed) or 0
	local acSpeed = self:getElementSpeed(element, unit)
	if (acSpeed) then
		local diff = speed/acSpeed
		if diff ~= diff then return false end
        local x, y, z = getElementVelocity(element)
		return setElementVelocity(element, x*diff, y*diff, z*diff)
	end

	return false
end

function Features:getElementSpeed(theElement, unit)
	if not isElement(theElement) then return 0 end
    local elementType = getElementType(theElement)
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    return (Vector3(getElementVelocity(theElement)) * mult).length
end



function createFeatures()
    if settings.features then return end
    settings.features = Features:create()
end

function updateState(...)
    if not settings.features then return end
    settings.features:updateState(...)
end

function setState(...)
    if not settings.features then return end
    settings.features:setState(...)
end

function getFeatureValue(type, plr)
    local el = plr and plr or localPlayer
    local data = getElementData(el, "characterFeatures")
    if not data then return 0 end
    return data[settings.featureData[type].index] or 0
end

if getElementData(localPlayer, "characterData") then createFeatures() end











-- Therapist
function onTherapistSelect(therapy)
    triggerServerEvent("createPayment", resourceRoot, 2500, "onTherapistPay", therapy)
end
addEvent("onTherapistSelect", true)
addEventHandler("onTherapistSelect", root, onTherapistSelect)

function therapistResponse(feature, success)
    exports.TR_dx:setResponseEnabled(false)

    if success then
        setState(feature, 0)
        exports.TR_achievements:addAchievements("clearFeature")
    end
end
addEvent("therapistResponse", true)
addEventHandler("therapistResponse", root, therapistResponse)