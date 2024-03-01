local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 150/zoom)/2,
    y = (sy - 55/zoom),
    w = 150/zoom,
    h = 55/zoom,

    fonts = {
        title = exports.TR_dx:getFont(14),
        count = exports.TR_dx:getFont(12),
    },

    smoothSegments = 10,
}

HoseManager = {}
HoseManager.__index = HoseManager

function HoseManager:create()
    local instance = {}
    setmetatable(instance, HoseManager)
    if instance:constructor() then
        return instance
    end
    return false
end

function HoseManager:constructor()
    self.hoses = {}
    self.alpha = 0
    -- self.isSmooth = true

    self.func = {}
    self.func.render = function() self:render() end
    addEventHandler("onClientPreRender", root, self.func.render)

    self:createTextures()
    return true
end

function HoseManager:onRemove(...)
    if arg[1].texture == "fuel" then
        exports.TR_fuelStation:hoseFuelEnd()
    end
end

function HoseManager:createTextures()
    self.hoseImg = {
        ["fuel"] = dxCreateTexture("files/images/fuel.png", "argb", true, "clamp"),
        ["fire"] = dxCreateTexture("files/images/fire.png", "argb", true, "clamp"),
    }

    self.hoseSize = {
        ["fuel"] = 0.05,
        ["fire"] = 0.1,
    }
end

function HoseManager:updateData(...)
    for i, v in pairs(arg[1]) do
        self:createHose(i, v)
    end
end

function HoseManager:createHose(...)
    self.hoses[arg[1]] = {
        texture = arg[3] or "fuel",
        maxPositions = arg[4] or 10,
        positions = {{x = arg[2].x, y = arg[2].y, z = arg[2].z}},
    }

    if arg[1] == localPlayer then
        self.state = "show"
        self.tick = getTickCount()

        local pos = Vector3(getElementPosition(localPlayer))
        local z = getGroundPosition(pos)
        table.insert(self.hoses[arg[1]].positions, {x = pos.x, y = pos.y, z = z + 0.1})
    end
end

function HoseManager:removeHose(...)
    if arg[1] == localPlayer and self.hoses[arg[1]] then
        local data = self.hoses[arg[1]]
        self:onRemove(self.hoses[arg[1]])
        self.state = "hide"
        self.tick = getTickCount()
        triggerServerEvent("removePlayerHose", resourceRoot, localPlayer)

        setElementData(localPlayer, "hoseEndPos", nil)

        if data.texture == "fire" then
            exports.TR_fractions:plrTakeoutFireHose(nil, true)
        end
    end
    self.hoses[arg[1]] = nil
end

function HoseManager:updatePlayerHose(...)
    if arg[1] == localPlayer then return end
    self.hoses[arg[1]] = arg[2]
end

function HoseManager:updateHoseData(...)
    self.hoses = arg[1]
end

function HoseManager:animate()
    if self.state == "show" then
        local progress = (getTickCount() - self.tick)/500
        self.alpha = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "Linear")
        if progress >= 1 then
            self.alpha = 1
            self.tick = nil
            self.state = "opened"
        end

    elseif self.state == "hide" then
        local progress = (getTickCount() - self.tick)/500
        self.alpha = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "Linear")
        if progress >= 1 then
            self.alpha = 0
            self.tick = nil
            self.state = "closed"
        end
    end
end

function HoseManager:renderLocal()
    self:animate()
    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 5)
    dxDrawText("Długość węża", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 30/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, guiInfo.fonts.title, "center", "center")
    dxDrawText((self.localHoseActDist and math.max(self.localHoseActDist + 1, 0) or 0).."m/"..(self.localHoseMaxDist and math.max(self.localHoseMaxDist, 0) or 0).."m", guiInfo.x, guiInfo.y + 30/zoom, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, guiInfo.fonts.count, "center", "center")
end

function HoseManager:render()
    self:renderLocal()
    local playerPos = Vector3(getElementPosition(localPlayer))

    for plr, data in pairs(self.hoses) do
        local pos = Vector3(getElementPosition(plr))
        local _, _, rot = getElementRotation(localPlayer)
        local hoseEnd = getElementData(plr, "hoseEndPos")

        if plr == localPlayer then
            local lastCount = #data.positions
            local renderLocal = true

            if getDistanceBetweenPoints2D(pos.x, pos.y, data.positions[#data.positions].x, data.positions[#data.positions].y) > 1 and not hoseEnd then
                if data.maxPositions then
                    if #data.positions >= data.maxPositions then
                        setElementPosition(localPlayer, data.positions[#data.positions].x, data.positions[#data.positions].y, data.positions[#data.positions].z + 0.6)
                    end
                end

                local count = math.floor(getDistanceBetweenPoints2D(pos.x, pos.y, data.positions[#data.positions].x, data.positions[#data.positions].y))
                for i = 1, count do
                    local lastPos = data.positions[#data.positions]
                    local brot = self:findRotation(lastPos.x, lastPos.y, pos.x, pos.y)
                    local x, y = self:getPointFromDistanceRotation(lastPos.x, lastPos.y, 1, -brot)

                    if getDistanceBetweenPoints2D(pos.x, pos.y, x, y) < 1.2 then
                        local z = getGroundPosition(x, y, pos.z)
                        table.insert(data.positions, {x = x, y = y, z = z + 0.1})
                    end
                end
            end

            if #data.positions > 1 and not hoseEnd then
                self:checkHoseMovement(data.positions[#data.positions], data.positions[#data.positions - 1], #data.positions, data.maxPositions)
            end

            if not hoseEnd then
                local remove = nil
                for i, v in pairs(data.positions) do
                    if i > 2 and #data.positions ~= i then
                        if getDistanceBetweenPoints2D(pos.x, pos.y, v.x, v.y) < 0.8 and not remove then
                            remove = i
                            break
                        end
                    end
                end
                if remove then
                    for i = remove, #data.positions do
                        table.remove(data.positions, remove)
                    end
                end
            end

            if lastCount ~= #data.positions and renderLocal then
                triggerServerEvent("updatePlayerHose", resourceRoot, data)
            end

            self.localHoseMaxDist = data.maxPositions
            self.localHoseActDist = data.maxPositions - #data.positions
        end

        if getDistanceBetweenPoints3D(Vector3(getElementPosition(plr)), playerPos) < 150 then
            local lastEnd = false
            for i, v in pairs(data.positions) do
                local hoseEndPos = getElementData(plr, "hoseEndPos")

                if i == i and data.positions[i + 1] then
                    if self.isSmooth then
                        local rot = self:findRotation(v.x, v.y, data.positions[i + 1].x, data.positions[i + 1].y)

                        local nowPos = Vector3(self:getPointFromDistanceRotation(v.x, v.y, 0.2, -rot))
                        local newPos = Vector3(self:getPointFromDistanceRotation(data.positions[i + 1].x, data.positions[i + 1].y, -0.2, -rot))

                        nowPos.z = v.z
                        newPos.z = getGroundPosition(newPos.x, newPos.y, data.positions[i + 1].z + 1) + 0.1

                        dxDrawMaterialLine3D(nowPos, newPos, self.hoseImg[data.texture], self.hoseSize[data.texture])
                        if lastEnd then
                            for k = 0, (guiInfo.smoothSegments - (1/guiInfo.smoothSegments)) do
                                self:renderBezierLine(k/guiInfo.smoothSegments, nowPos, v, lastEnd, data.texture)
                            end
                        end

                        lastEnd = newPos
                    else
                        lastEnd = Vector3(data.positions[i + 1].x, data.positions[i + 1].y, getGroundPosition(data.positions[i + 1].x, data.positions[i + 1].y, data.positions[i + 1].z + 1) + 0.1)
                        dxDrawMaterialLine3D(Vector3(v.x, v.y, v.z), lastEnd, self.hoseImg[data.texture], self.hoseSize[data.texture])
                    end


                elseif data.positions[i + 1] then
                    if self.isSmooth then
                        local rot = self:findRotation(v.x, v.y, data.positions[i + 1].x, data.positions[i + 1].y)

                        local nowPos = Vector3(self:getPointFromDistanceRotation(v.x, v.y, 0.2, -rot))
                        local newPos = Vector3(self:getPointFromDistanceRotation(data.positions[i + 1].x, data.positions[i + 1].y, -0.2, -rot))

                        nowPos.z = getGroundPosition(nowPos.x, nowPos.y, v.z) + 0.1
                        newPos.z = getGroundPosition(newPos.x, newPos.y, data.positions[i + 1].z + 1) + 0.1

                        dxDrawMaterialLine3D(nowPos, newPos, self.hoseImg[data.texture], self.hoseSize[data.texture])

                        if lastEnd then
                            for k = 0, (guiInfo.smoothSegments - (1/guiInfo.smoothSegments)) do
                                self:renderBezierLine(k/guiInfo.smoothSegments, nowPos, v, lastEnd, data.texture)
                            end
                        end

                        lastEnd = newPos
                    else
                        lastEnd = Vector3(data.positions[i + 1].x, data.positions[i + 1].y, getGroundPosition(data.positions[i + 1].x, data.positions[i + 1].y, data.positions[i + 1].z + 1) + 0.1)
                        dxDrawMaterialLine3D(Vector3(v.x, v.y, v.z), lastEnd, self.hoseImg[data.texture], self.hoseSize[data.texture])
                    end

                elseif hoseEndPos then
                    if self.isSmooth then
                        if lastEnd then
                            for k = 0, (guiInfo.smoothSegments - (1/guiInfo.smoothSegments)) do
                                self:renderBezierLine(k/guiInfo.smoothSegments, lastEnd, v, hoseEndPos, data.texture)
                            end
                        end
                    else
                        if lastEnd then
                            dxDrawMaterialLine3D(hoseEndPos.x, hoseEndPos.y, hoseEndPos.z, lastEnd, self.hoseImg[data.texture], self.hoseSize[data.texture])
                        end
                    end
                else
                    local pos = Vector3(getPedBonePosition(plr, 25))
                    local _, _, rot = getElementRotation(plr)
                    local x, y = self:getPointFromDistanceRotation(pos.x, pos.y, -0.12, -rot)

                    if self.isSmooth then
                        if lastEnd then
                            for k = 0, (guiInfo.smoothSegments - (1/guiInfo.smoothSegments)) do
                                self:renderBezierLine(k/guiInfo.smoothSegments, Vector3(x, y, pos.z + 0.06), v, lastEnd, data.texture)
                            end
                        end

                    else
                        if lastEnd then
                            dxDrawMaterialLine3D(Vector3(x, y, pos.z + 0.06), lastEnd, self.hoseImg[data.texture], self.hoseSize[data.texture])
                        end
                    end
                end
            end
        end
    end
end

function HoseManager:renderBezierLine(i, start, curve, endPos, texture)
    local pos1 = self:getBezierStep(i, start, curve, endPos)
    local pos2 = self:getBezierStep(i + 1/guiInfo.smoothSegments, start, curve, endPos)
    dxDrawMaterialLine3D(pos1, pos2, self.hoseImg[texture], self.hoseSize[texture])
end

function HoseManager:checkHoseMovement(pos, lastpos, count, max)
    local plrPos = Vector3(getElementPosition(localPlayer))
    local _, _, rot = getElementRotation(localPlayer)
    local x, y = self:getPointFromDistanceRotation(plrPos.x, plrPos.y, 0.1, -rot)

    local brot = self:findRotation(pos.x, pos.y, plrPos.x, plrPos.y)
    local bx, by = self:getPointFromDistanceRotation(plrPos.x, plrPos.y, -0.1, -brot)

    if getDistanceBetweenPoints2D(pos.x, pos.y, x, y) > 0.8 and count >= max then
        setElementPosition(localPlayer, bx, by, plrPos.z)
    end
end

function HoseManager:drawBackground(x, y, w, h, color, radius, post)
    dxDrawRectangle(x - radius, y, w + radius * 2, h + radius, color, post)
    dxDrawRectangle(x, y - radius, w, radius, color, post)
    dxDrawCircle(x, y, radius, 180, 270, color, color, 7, 1, post)
    dxDrawCircle(x + w, y, radius, 270, 360, color, color, 7, 1, post)
end

function HoseManager:getBezierStep(step, start, curve, endPos)
    local px = (1-step)*((1-step)*start.x + step*curve.x) + step*((1-step)*curve.x + step*endPos.x)
    local py = (1-step)*((1-step)*start.y + step*curve.y) + step*((1-step)*curve.y + step*endPos.y)
    local pz = (1-step)*((1-step)*start.z + step*curve.z) + step*((1-step)*curve.z + step*endPos.z)
    return Vector3(px, py, pz)
end

function HoseManager:drawSmoothLine3D(x, y, z, tx, ty, tz, texture, segments)
    local rot = self:findRotation(x, y, tx, ty)
    local dist = getDistanceBetweenPoints2D(x, y, tx, ty)

    local segments = segments or 40
    local segAngle = 90/segments
    local difZ = z - tz

    for i=1, segments do
        x, y = self:getPointFromDistanceRotation(x, y, dist/segments, -rot)
        local nx, ny = self:getPointFromDistanceRotation(x, y, dist/segments + 0.001, -rot)
        local angle = math.rad(segAngle * i)
        local ptz = z + difZ * math.sin(-angle)
        local ptnz = z + difZ * math.sin(math.rad(-segAngle * (i + 1)))

        dxDrawMaterialLine3D(x, y, ptz, nx, ny, ptnz, self.hoseImg[texture], self.hoseSize[texture])
    end
end

function HoseManager:findRotation( x1, y1, x2, y2 )
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end

function HoseManager:getPointFromDistanceRotation(x, y, dist, angle)
    local a = math.rad(90 - angle);
    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;
    return x+dx, y+dy;
end

function HoseManager:setHoseSmooth(...)
    self.isSmooth = arg[1]
end



local manager = HoseManager:create()
function createHose(...)
    manager:createHose(...)
end
addEvent("createHose", true)
addEventHandler("createHose", root, createHose)

function removeHose(...)
    manager:removeHose(...)
end
addEvent("removeHose", true)
addEventHandler("removeHose", root, removeHose)

function updatePlayerHose(...)
    manager:updatePlayerHose(...)
end
addEvent("updatePlayerHose", true)
addEventHandler("updatePlayerHose", root, updatePlayerHose)

function updateHoseData(...)
    manager:updateHoseData(...)
end
addEvent("updateHoseData", true)
addEventHandler("updateHoseData", root, updateHoseData)

function setHoseSmooth(...)
    manager:setHoseSmooth(...)
end


-- if getPlayerName(localPlayer) == "Xantris" then
--     createHose(localPlayer, Vector3(getElementPosition(localPlayer)), "fire", 15)
-- end