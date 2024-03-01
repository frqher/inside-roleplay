Panel = {}
Panel.__index = Panel

function Panel:create()
    local instance = {}
    setmetatable(instance, Panel)
    if instance:constructor() then
        return instance
    end
    return false
end

function Panel:constructor()
    self.func = {}
    self.func.openVehicleInteraction = function() self:openVehicleInteraction() end
    bindKey("f4", "down", self.func.openVehicleInteraction)
    return true
end

function Panel:openVehicleInteraction()
    local _, jobType = getPlayerJob()

    if jobType == "taxi" then
        exports.TR_taxi:createTaxiPanel()

    elseif jobType == "police" or jobType == "medic" or jobType == "fire" or jobType == "ers" then
        exports.TR_fractions:createFractionPanel()
    end
end

Panel:create()