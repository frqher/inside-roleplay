local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    w = 400,
    h = 250,

    shader = [[
        texture gTexture;
        technique TexReplace
        {
            pass P0
            {
                Texture[0] = gTexture;
            }
        }
    ]],

    weights = {
        {
            weight = Vector3(298.193359375, -231.16796875, 1.5078125),
            sign = {
                pos = Vector3(293.826640625, -226.1142578125, 1.5078125),
                rot = 20,
            },
        },
    },
}

Weights = {}
Weights.__index = Weights

function Weights:create()
    local instance = {}
    setmetatable(instance, Weights)
    if instance:constructor() then
        return instance
    end
    return false
end

function Weights:constructor()
    self.weights = {}

    self.fonts = {}
    self.fonts.weight = dxCreateFont("files/fonts/font.ttf", 25)

    self.func = {}
    self.func.updateWeights = function() self:updateWeights() end

    self:createWeights()
    setTimer(self.func.updateWeights, 2000, 0)
    return true
end

function Weights:updateWeights()
    for i, v in pairs(self.weights) do
        self:updateWeight(v.sphere, v.target)
    end
end

function Weights:updateWeight(sphere, target)
    local totalWeight = self:getTotalWeight(sphere)

    dxSetRenderTarget(target)
    dxDrawRectangle(0, 0, guiInfo.w, guiInfo.h, tocolor(200, 200, 200, 255))
    dxDrawText("OKUMALAR:", 7, 10, guiInfo.w, guiInfo.h, tocolor(0, 0, 0, 255), 1, self.fonts.weight, "center", "top")
    dxDrawText(string.format("TOPLAM AĞIRLIK: %.3fT", totalWeight/1000), 7, 105, guiInfo.w, guiInfo.h, tocolor(255, 0, 0, 255), 1, self.fonts.weight, "center", "top")

    dxDrawText("ÜCRET", 7, 0, guiInfo.w, guiInfo.h - 5/zoom, tocolor(0, 0, 0, 255), 1.2, "default-bold", "center", "bottom")
    dxSetRenderTarget()
end

function Weights:getTotalWeight(sphere)
    return self:getPlayersWeight(sphere) + self:getVehiclesWeight(sphere)
end

function Weights:getPlayersWeight(sphere)
    local players = getElementsWithinColShape(sphere, "player")
    if not players or #players < 1 then return 0 end
    return #players * 60
end

function Weights:getVehiclesWeight(sphere)
    local totalWeight = 0

    local vehicles = getElementsWithinColShape(sphere, "vehicle")
    if not vehicles or #vehicles < 1 then return 0 end
    for i, v in pairs(vehicles) do
        local weight = self:getVehicleWeight(v)
        totalWeight = totalWeight + weight
    end

    return totalWeight
end

function Weights:getVehicleWeight(veh)
    return getVehicleHandling(veh)["mass"]
end

function Weights:createWeights()
    for i, v in pairs(guiInfo.weights) do
        table.insert(self.weights, {
            sphere = createColSphere(v.weight, 4),
            sign = createObject(7246, v.sign.pos, 0, 0, v.sign.rot),
            shader = dxCreateShader(guiInfo.shader, 0, 100, false, "object"),
            target = dxCreateRenderTarget(guiInfo.w, guiInfo.h)
        })
        setObjectBreakable(self.weights[#self.weights].sign, false)
        setObjectScale(self.weights[#self.weights].sign, 0.4)
        setElementCollisionsEnabled(self.weights[#self.weights].sign, false)

        dxSetShaderValue(self.weights[#self.weights].shader, "gTexture", self.weights[#self.weights].target)
        engineApplyShaderToWorldTexture(self.weights[#self.weights].shader, "roadsignbackground128", self.weights[#self.weights].sign)
    end
end


function Weights:getVehicles()
    local plrVehs = {}
    local nearest = self:getNearestWeight()

    if nearest then
        local vehicles = getElementsWithinColShape(self.weights[nearest].sphere, "vehicle")
        for i, v in pairs(vehicles) do
            local id = getElementID(v)
            if id then
                local vehID = string.sub(id, 8, string.len(id))
                table.insert(plrVehs, vehID)
            end
        end
    end
    return plrVehs
end

function Weights:getNearestWeight()
    local closest = false
    local closestDist = 3000
    local pos = Vector3(getElementPosition(localPlayer))

    for i, v in pairs(self.weights) do
        local dist = getDistanceBetweenPoints3D(pos, Vector3(getElementPosition(v.sphere)))
        if dist < closestDist then
            closestDist = dist
            closest = i
        end
    end

    return closest
end

guiInfo.weights = Weights:create()

function checkVehiclesOnWeight(pedName)
    if not guiInfo.weights then return end
    local vehicles = guiInfo.weights:getVehicles()

    if #vehicles < 1 then exports.TR_chat:showCustomMessage(pedName, "Ve hemen olması gerekiyordu! Mekanizmanızı ağırlığa göre paketleyin! Yakında alacağız!", "files/images/npc.png") return end
    triggerServerEvent("sellVehiclesOnScrap", resourceRoot, pedName, vehicles)
end
addEvent("checkVehiclesOnWeight", true)
addEventHandler("checkVehiclesOnWeight", root, checkVehiclesOnWeight)