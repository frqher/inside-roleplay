local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    map = {
        x = 40/zoom,
        y = sy - 240/zoom,
        w = 350/zoom,
        h = 200/zoom,

        mapRec = 400,

        tileSize = 512,
        blipSize = 32/zoom,
        plrBlipSize = 14/zoom,
        localBlipSize = 20/zoom,

        maxSize = 5000,
        minSize = 2000,
        zoomSpeed = 20,
    },
}
guiInfo.map.mapSize = guiInfo.map.tileSize * 6
guiInfo.map.scale = 6000 / guiInfo.map.mapSize

Minimap = {}
Minimap.__index = Minimap

function Minimap:create()
    local instance = {}
    setmetatable(instance, Minimap)
    if instance:constructor() then
        return instance
    end
    return false
end

function Minimap:constructor()
    self.state = ""
    self.camera = getCamera()
    self.lastTickUpdate = getTickCount()

    self.fonts = {}
    self.fonts.gps = exports.TR_dx:getFont(14)
    self.fonts.area = exports.TR_dx:getFont(13)
    self.fonts.dist = exports.TR_dx:getFont(11)

    self.textures = {}
    self.textures.minimap = dxCreateRenderTarget(guiInfo.map.w, guiInfo.map.h, true)
    self.textures.minimapBg = dxCreateRenderTarget(guiInfo.map.mapSize, guiInfo.map.mapSize, true)
    self.textures.minimapMask = dxCreateTexture("files/images/radar/mask.png")
    self.textures.busola = dxCreateTexture("files/images/radar/busola.png", "argb", true, "clamp")

    self.shaders = {}
    self.shaders.mask = dxCreateShader("files/shaders/hud_mask.fx")
    dxSetShaderValue(self.shaders.mask, "sPicTexture", self.textures.minimap)
    dxSetShaderValue(self.shaders.mask, "sMaskTexture", self.textures.minimapMask)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.onRestore = function() self:onRestore() end


    self:createRadarTextures()
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientRestore", root, self.func.onRestore)
    return true
end

function Minimap:render()
    if settings.blockHud then return end
    self:renderRadarLocation()

    if settings.blockRadar then return end
    self:renderMap()
end

function Minimap:setSize(size)
    guiInfo.map.mapSize = size
    guiInfo.map.scale = 6000 / guiInfo.map.mapSize
end

function Minimap:updateMap()
    self.int, self.dim = getElementInterior(localPlayer), getElementDimension(localPlayer)

    local pXonMap = guiInfo.map.w/2 - (self.playerPos.x / guiInfo.map.scale)
  	local pYOnMap = guiInfo.map.h/2 + (self.playerPos.y / guiInfo.map.scale)

    dxSetRenderTarget(self.textures.minimap, true)
    dxSetBlendMode("overwrite")
    dxDrawImage(pXonMap - guiInfo.map.mapSize/2, pYOnMap - guiInfo.map.mapSize/2, guiInfo.map.mapSize, guiInfo.map.mapSize, self.textures.minimapBg, self.camRot.z, (self.playerPos.x / guiInfo.map.scale), -(self.playerPos.y / guiInfo.map.scale), tocolor(255, 255, 255, 255))

    if getKeyState("num_add") then
        self:setSize(math.min(guiInfo.map.mapSize + guiInfo.map.zoomSpeed, guiInfo.map.maxSize))

    elseif getKeyState("num_sub") then
        self:setSize(math.max(guiInfo.map.mapSize - guiInfo.map.zoomSpeed, guiInfo.map.minSize))
    end

    dxSetBlendMode("modulate_add")
    if GPS.road then
        if #GPS.road > 0 then
            for i = #GPS.road, 1, -1 do
                if (GPS.road[i + 1] ~= nil) then
                    local x, y = self:getMapPositionFromWorld(GPS.road[i].posX, GPS.road[i].posY)
                    local ex, ey = self:getMapPositionFromWorld(GPS.road[i + 1].posX,GPS.road[i + 1].posY)
                    dxDrawLine(x, y, ex, ey, tocolor(255, 0, 0, 255), 4)
                end
            end
        end
    end

    if self.int == 0 and self.dim == 0 then
        for i, v in pairs(getElementsByType("player", root, true)) do
            if v ~= localPlayer and not getElementData(v, "characterMask") and not isInDmZone(v) and not getElementData(v, "inv") then
                local pos = Vector3(getElementPosition(v))
                local x, y = self:getMapPositionFromWorld(pos.x, pos.y)
                dxDrawImage(x - guiInfo.map.plrBlipSize/2, y - guiInfo.map.plrBlipSize/2, guiInfo.map.plrBlipSize, guiInfo.map.plrBlipSize, settings.textures[0])
            end
        end

    elseif self.int == 0 and self.dim == 9531 then
        for i, v in pairs(getElementsByType("blip", root, true)) do
            local icon = getElementData(v, "icon") or 0
            if icon == 22 then
                local r, g, b = getBlipColor(v)
                table.insert(self.blips, {
                    pos = Vector3(getElementPosition(v)),
                    color = {r, g, b},
                    icon = icon,
                })
            end
        end
    end

    dxDrawImage(guiInfo.map.w/2 - guiInfo.map.localBlipSize/2, guiInfo.map.h/2 - guiInfo.map.localBlipSize/2, guiInfo.map.localBlipSize, guiInfo.map.localBlipSize, settings.textures[1], -self.playerRot.z + self.camRot.z)

    if settings.minimapOrder then
        local mapOrX, mapOrY = getPointFromDistanceRotation(guiInfo.map.w/2 - guiInfo.map.localBlipSize/2, guiInfo.map.h/2 - guiInfo.map.localBlipSize/2, 100, 0)
        table.sort(self.blips, function(a, b)
            local x1, y1 = self:getMapPositionFromWorld(a.pos.x, a.pos.y)
            local x2, y2 = self:getMapPositionFromWorld(b.pos.x, b.pos.y)
            return getDistanceBetweenPoints2D(mapOrX, mapOrY, x1, y1) > getDistanceBetweenPoints2D(mapOrX, mapOrY, x2, y2)
        end)
    end

    for i, v in pairs(self.blips) do
        if v ~= blockVehicleBlip then
            local x, y = self:getMapPositionFromWorld(v.pos.x, v.pos.y)
            dxDrawImage(x - guiInfo.map.blipSize/2, y - guiInfo.map.blipSize, guiInfo.map.blipSize, guiInfo.map.blipSize, settings.textures.bg, 0, 0, guiInfo.map.blipSize/2, tocolor(v.color[1], v.color[2], v.color[3], 255))
            dxDrawImage(x - guiInfo.map.blipSize/2, y - guiInfo.map.blipSize, guiInfo.map.blipSize, guiInfo.map.blipSize, settings.textures[v.icon], 0, 0, guiInfo.map.blipSize/2, tocolor(v.color[1], v.color[2], v.color[3], 255))
        end
    end

    self:renderKeyNeeded()

    dxSetBlendMode("blend")
    dxSetRenderTarget()

    if (getTickCount() - self.lastTickUpdate)/2000 > 1 then
        self:updateBlips()
        self.lastTickUpdate = getTickCount()
    end
end

function Minimap:renderKeyNeeded()
    if self.int ~= 0 and self.dim ~= 0 then return end
    if getKeyState("h") then
        for i, v in pairs(getElementsByType("marker", root, true)) do
            local icon = getElementData(v, "markerIcon")
            if icon == "house-bought" then
                local pos = Vector3(getElementPosition(v))
                local x, y = self:getMapPositionFromWorld(pos.x, pos.y)
                dxDrawImage(x - guiInfo.map.blipSize/2, y - guiInfo.map.blipSize, guiInfo.map.blipSize, guiInfo.map.blipSize, settings.textures.bg, 0, 0, guiInfo.map.blipSize/2, tocolor(200, 0, 0, 255))
                dxDrawImage(x - guiInfo.map.blipSize/2, y - guiInfo.map.blipSize, guiInfo.map.blipSize, guiInfo.map.blipSize, settings.textures[32], 0, 0, guiInfo.map.blipSize/2, tocolor(200, 0, 0, 255))

            elseif icon == "house-free" then
                local pos = Vector3(getElementPosition(v))
                local x, y = self:getMapPositionFromWorld(pos.x, pos.y)
                dxDrawImage(x - guiInfo.map.blipSize/2, y - guiInfo.map.blipSize, guiInfo.map.blipSize, guiInfo.map.blipSize, settings.textures.bg, 0, 0, guiInfo.map.blipSize/2, tocolor(0, 200, 0, 255))
                dxDrawImage(x - guiInfo.map.blipSize/2, y - guiInfo.map.blipSize, guiInfo.map.blipSize, guiInfo.map.blipSize, settings.textures[32], 0, 0, guiInfo.map.blipSize/2, tocolor(0, 200, 0, 255))
            end
        end
    end

    if getKeyState("j") then
        for i, v in pairs(getElementsByType("marker", root, true)) do
            local orgID = getElementData(v, "orgID")
            if orgID then
                local orgImg = exports.TR_orgLogos:getLogo(orgID)
                if orgImg then
                    local pos = Vector3(getElementPosition(v))
                    local x, y = self:getMapPositionFromWorld(pos.x, pos.y)
                    dxDrawImage(x - guiInfo.map.blipSize/2, y - guiInfo.map.blipSize, guiInfo.map.blipSize, guiInfo.map.blipSize, orgImg, 0, 0, guiInfo.map.blipSize/2, tocolor(255, 255, 2550, 255))
                end
            end
        end
    end
end

function Minimap:renderMap()
    self:updateMap()
    dxDrawImage(guiInfo.map.x, guiInfo.map.y, guiInfo.map.w, guiInfo.map.h, self.shaders.mask, 0, 0, 0, tocolor(255, 255, 255, 255 * settings.alpha))

    if settings.windRoseVisible then
        dxDrawImage(guiInfo.map.x - 30/zoom, guiInfo.map.y + guiInfo.map.h - 85/zoom, 90/zoom, 90/zoom, self.textures.busola, self.camRot.z, 0, 0, tocolor(255, 255, 255, 170 * settings.alpha))
    end

    if GPS.waypointTurns and GPS.nextPosition then
        for i = 0, 3 do
            local waypoint = GPS.waypointTurns[#GPS.waypointTurns-i]
            if waypoint then
                local alpha = 255 - (i * 70)
                local dist = (waypoint.dist * 4)

                dxDrawImage(400/zoom, guiInfo.map.y + 10/zoom + i * 50/zoom, 32/zoom, 32/zoom, string.format("gps/images/%s.png", waypoint.icon), 0, 0, 0, tocolor(220, 220, 220, alpha * settings.alpha))
                dxDrawText(GPS.names[waypoint.icon], 440/zoom, guiInfo.map.y + 6/zoom + i * 50/zoom, 440/zoom, guiInfo.map.y + 47/zoom + i * 50/zoom, tocolor(220, 220, 220, alpha * settings.alpha), 1/zoom, self.fonts.gps, "left", "top")
                dxDrawText(self:formatDistanceGPS(dist), 440/zoom, guiInfo.map.y + 5/zoom + i * 50/zoom, 440/zoom, guiInfo.map.y + 45/zoom + i * 50/zoom, tocolor(140, 140, 140, alpha * settings.alpha), 1/zoom, self.fonts.dist, "left", "bottom")

                -- dxDrawText(inspect(GPS.waypointTurns), 500, 100)
            end
        end
    end
end

function Minimap:formatDistanceGPS(dist)
    if dist < 100 then
        return string.format("%d m", math.ceil(dist/10)*10)
    elseif dist < 500 then
        return string.format("%d m", math.ceil(dist/100)*100)
    end
    return string.format("%.1f km", math.ceil(dist/100)/10)
end

function Minimap:renderRadarLocation()
    self.playerPos = Vector3(getElementPosition(localPlayer))
    self.playerRot = Vector3(getElementRotation(localPlayer))
    self.camRot = Vector3(getElementRotation(self.camera))

	local city = getZoneName(self.playerPos, true)
    local zone = getZoneName(self.playerPos)

	if settings.customLocation then
		dxDrawText(settings.customLocation, guiInfo.map.x + 5/zoom, guiInfo.map.y + guiInfo.map.h, guiInfo.map.x + guiInfo.map.w, sy, tocolor(255, 255, 255, 200 * settings.alpha), 1/zoom, self.fonts.area)

    elseif city == "Unknown" and zone == "Unknown" then
		dxDrawText("Okyanus", guiInfo.map.x + 5/zoom, guiInfo.map.y + guiInfo.map.h, guiInfo.map.x + guiInfo.map.w, sy, tocolor(255, 255, 255, 200 * settings.alpha), 1/zoom, self.fonts.area)

    else
		dxDrawText(string.format("%s | %s", city, zone), guiInfo.map.x + 5/zoom, guiInfo.map.y + guiInfo.map.h, guiInfo.map.x + guiInfo.map.w, sy, tocolor(255, 255, 255, 200 * settings.alpha), 1/zoom, self.fonts.area)
	end
end

function Minimap:getMapPositionFromWorld(x, y)
    local dist = getDistanceBetweenPoints2D(self.playerPos.x, self.playerPos.y, x, y)
    local mapDist = dist / guiInfo.map.scale
    local rot = findRotation(x, y, self.playerPos.x, self.playerPos.y) - self.camRot.z
    local pointX, pointY = getPointFromDistanceRotation(guiInfo.map.w/2, guiInfo.map.h/2, mapDist, rot)
    return pointX, pointY
end

function Minimap:createRadarBlipTextures()
    settings.textures.bg = dxCreateTexture("files/images/blip/bg.png", "argb", true, "clamp")
    for i = 0, 65 do
        settings.textures[i] = dxCreateTexture("files/images/blip/"..i..".png", "argb", true, "clamp")
    end
end

function Minimap:createRadarTextures()
    settings.textures = {}
    settings.textures.radar = {}
    for x = 0, 5 do
		settings.textures.radar[x] = {}
        for y = 0, 5 do
            settings.textures.radar[x][y] = dxCreateTexture("files/images/radar/tile_"..y.."_"..x..".dds", "dxt3", true, "clamp")
        end
    end

    self:createRadarBlipTextures()
    self:renderRadarTextures()
end

function Minimap:renderRadarTextures()
    local characterOrgType = getElementData(localPlayer, "characterOrgType")
    dxSetRenderTarget(self.textures.minimapBg, true)
    for x = 0, 5 do
        for y = 0, 5 do
            dxDrawImage(guiInfo.map.tileSize * x, guiInfo.map.tileSize * y, guiInfo.map.tileSize, guiInfo.map.tileSize, settings.textures.radar[x][y])

            if characterOrgType and characterOrgType == "crime" then
                if (x == 4 and y == 4) or (x == 5 and y == 4) or (x == 4 and y == 5) or (x == 5 and y == 5) or (x == 5 and y == 3) then
                    for i, v in pairs(getElementsByType("gangZone")) do
                        local zoneID = getElementID(v)
                        local gangData = getElementData(v, "ownedGang")

                        if gangData then
                            if fileExists("files/images/radar/zones/"..x.."_"..y.."_"..zoneID..".dds") then
                                dxDrawImage(guiInfo.map.tileSize * x, guiInfo.map.tileSize * y, guiInfo.map.tileSize, guiInfo.map.tileSize, "files/images/radar/zones/"..x.."_"..y.."_"..zoneID..".dds", 0, 0, 0, tocolor(gangData.color[1], gangData.color[2], gangData.color[3], 210))
                            end
                        end
                    end
                end
            end
        end
    end
    dxSetRenderTarget()

    self:updateBlips()
end

function Minimap:updateBlips()
    self.blips = {}

    local blockVehicleBlip = false
    local veh = getPedOccupiedVehicle(localPlayer)
    if veh then
        local attached = getAttachedElements(veh)
        for i, v in pairs(attached) do
            if getElementType(v) == "blip" then
                blockVehicleBlip = v
                break
            end
        end
    end

    local pos = Vector3(getElementPosition(localPlayer))
    local showedBlips = getShowedBlips()

    if self.int ~= 0 and self.dim ~= 0 then return end
    for i, v in pairs(getElementsByType("blip")) do
        local icon = getElementData(v, "icon") or 0
        if v ~= blockVehicleBlip and showedBlips[icon] then
            local bPos = Vector3(getElementPosition(v))
            local r, g, b = getBlipColor(v)
            if getDistanceBetweenPoints2D(pos.x, pos.y, bPos.x, bPos.y) < 300 then
                local tableIndex = 1
                if icon ~= 23 and icon ~= 37 then
                    tableIndex = #self.blips
                end

                table.insert(self.blips, icon == 23 and 1 or #self.blips, {
                    pos = bPos,
                    color = {r, g, b},
                    icon = icon,
                })
            end
        end
    end
end

function Minimap:onRestore()
    self:renderRadarTextures()
    self:updateBlips()
end

function Minimap:updateOrder(state)
    self.minimapOrder = state
end