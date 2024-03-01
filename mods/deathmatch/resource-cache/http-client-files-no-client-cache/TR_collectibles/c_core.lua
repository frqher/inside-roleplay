--[[
    Zacznijmy wiecej wymagac ~Xyrusek
    AUTOR: Xyrusek
--]]


--[[
    SKALOWANIE
--]]

local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

--[[
    KOD
--]]

local last = {}

addEventHandler("onClientColShapeHit", getResourceRootElement(), function(hit, md)
    if not hit or not md or hit ~= localPlayer then return false end
    if getPedOccupiedVehicle(localPlayer) then return end

    local idString = getElementID(source)
    if not idString then return false end

    local id = string.sub(idString, 12, string.len(idString))
    local id = tonumber(id)
    if not id then return end

    if getElementData(localPlayer, "onAir") then exports.TR_noti:create("0'a uçarken koleksiyon toplayamazsınız.", "error") return end

    if not last.collectibleHit or getTickCount()-last.collectibleHit > 5000 then
        last.collectibleHit = getTickCount()
        triggerLatentServerEvent("TR_collectibles:tryGetCollectible", 5000, false, getResourceRootElement(), id)
    else
        local t = ((last.collectibleHit+5000)-getTickCount())/1000
        local t = string.format("%.0f", t)
        exports.TR_noti:create("Koleksiyonu tekrar toplamayı denemek için "..t.." saniye bekleyin.", "info")
        return
    end
end)

function isNearCollectible()
    local plrPos = Vector3(getElementPosition(localPlayer))

    for i, v in ipairs(getElementsByType("pickup", resourceRoot, true)) do
        if getDistanceBetweenPoints3D(plrPos, Vector3(getElementPosition(v))) < 20 then
            return true
        end
    end

    return false
end