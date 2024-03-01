local settings = {
    graffitiSize = 3,
    logos = {},
}

Graffiti = {}
Graffiti.__index = Graffiti

function Graffiti:create()
    local instance = {}
    setmetatable(instance, Graffiti)
    if instance:constructor() then
        return instance
    end
    return false
end

function Graffiti:constructor()
    self.emptyGraffiti = dxCreateTexture("files/images/noGangGraffiti.png", "argb", true, "clamp")
    self.materialBack = dxCreateTexture("files/images/bar.png", "argb", true, "clamp")

    self.func = {}
    self.func.render = function() self:render() end

    addEventHandler("onClientRender", root, self.func.render)
    return true
end

function Graffiti:render()
    local plrPos = Vector3(getElementPosition(localPlayer))
    for i, v in pairs(getElementsByType("gangZone", resourceRoot, true)) do
        local zoneID = tonumber(getElementID(v))
        if GangZones[zoneID].graffiti then
            local graffiti = GangZones[zoneID].graffiti
            if getDistanceBetweenPoints2D(graffiti.pos.x, graffiti.pos.y, plrPos.x, plrPos.y) < 70 then
                local gangData = getElementData(v, "ownedGang")
                local x, y = self:getPointFromDistanceRotation(graffiti.pos.x, graffiti.pos.y, -0.3, -graffiti.rot)
                local fx, fy = self:getPointFromDistanceRotation(graffiti.pos.x, graffiti.pos.y, 1, -graffiti.rot)
                local pos = Vector3(x, y, graffiti.pos.z)

                if gangData then
                    local orgImg = exports.TR_orgLogos:getLogo(gangData.ownedGang)
                    if orgImg then
                        if not settings.logos[gangData.ownedGang] then
                            settings.logos[gangData.ownedGang] = dxCreateTexture(orgImg, "argb", true, "clamp")
                        end

                        dxDrawMaterialLine3D(pos + Vector3(0, 0, settings.graffitiSize/2), pos - Vector3(0, 0, settings.graffitiSize/2), settings.logos[gangData.ownedGang], settings.graffitiSize, tocolor(255, 255, 255, 255), false, fx, fy, graffiti.pos.z)

                    else
                        dxDrawMaterialLine3D(pos + Vector3(0, 0, settings.graffitiSize/2), pos - Vector3(0, 0, settings.graffitiSize/2), self.emptyGraffiti, settings.graffitiSize, tocolor(255, 255, 255, 255), false, fx, fy, graffiti.pos.z)
                    end
                else
                    dxDrawMaterialLine3D(pos + Vector3(0, 0, settings.graffitiSize/2), pos - Vector3(0, 0, settings.graffitiSize/2), self.emptyGraffiti, settings.graffitiSize, tocolor(255, 255, 255, 255), false, fx, fy, graffiti.pos.z)
                end


                local gangTimePoint = getElementData(v, "gangTimePoint")
                if gangTimePoint then
                    local progress = gangTimePoint/180
                    local x, y = self:getPointFromDistanceRotation(graffiti.pos.x, graffiti.pos.y, -0.29, -graffiti.rot)
                    dxDrawMaterialLine3D(pos + Vector3(0, 0, 0.1) + Vector3(0, 0, 1.5), pos - Vector3(0, 0, 0.1) + Vector3(0, 0, 1.5), self.materialBack, settings.graffitiSize, tocolor(0, 0, 0, 255), false, fx, fy, graffiti.pos.z + 1.5)
                    dxDrawMaterialLine3D(Vector3(x, y, graffiti.pos.z) + Vector3(0, 0, 0.1) + Vector3(0, 0, 1.5), pos - Vector3(0, 0, 0.1) + Vector3(0, 0, 1.5), self.materialBack, settings.graffitiSize * progress, tocolor(255, 255, 255, 255), false, fx, fy, graffiti.pos.z + 1.5)
                end
            end
        end
    end
end

function Graffiti:getPointFromDistanceRotation(x, y, dist, angle)
    local a = math.rad(90 - angle);
    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;
    return x+dx, y+dy;
end

Graffiti:create()



function getNearestGraffiti()
    local plrPos = Vector3(getElementPosition(localPlayer))
    for i, v in pairs(GangZones) do
        if getDistanceBetweenPoints2D(v.graffiti.pos.x, v.graffiti.pos.y, plrPos.x, plrPos.y) < 1 and plrPos.z <= v.graffiti.pos.z then
            return i
        end
    end

    return false
end