local sx, sy = guiGetScreenSize()

Ladder = {}
Ladder.__index = Ladder

local guiInfo = {
    x = (sx - 800/zoom)/2,
    y = sy - 300/zoom,
    w = 800/zoom,
    h = 300/zoom,

    moveSpeed = {
        platform = 0.2,
        ladder = 0.2,
        ladderSmall = 0.01,
    },

    components = {
        platform = "Platform",
        ladder = "ladderA",
        ladderSmall = "ladderB",
    }
}

function Ladder:create(...)
    local instance = {}
    setmetatable(instance, Ladder)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function Ladder:constructor(...)
    self.vehicle = arg[1]
    self.alpha = 0

    self.fonts = {}
    self.fonts.exit = exports.TR_dx:getFont(12)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.close = function() self:close() end

    self:open()
    return true
end

function Ladder:open()
    exports.TR_dx:setOpenGUI(true)
    self.alpha = 0
    self.state = "opening"
    self.tick = getTickCount()
    self.updateTick = getTickCount()

    self.bg = dxCreateTexture("files/images/ladder.png", "argb", true, "clamp")

    local data = getElementData(self.vehicle, "ladder")
    self.components = {
        platform = {
            rot = Vector3(getVehicleComponentRotation(self.vehicle, guiInfo.components.platform)),
        },
        ladder = {
            pos = Vector3(getVehicleComponentPosition(self.vehicle, guiInfo.components.ladder)),
            rot = Vector3(getVehicleComponentRotation(self.vehicle, guiInfo.components.ladder)),
        },
        ladderSmall = {
            pos = Vector3(0, data and data.ladderSmall or 0, 0),
        }
    }

    local camPos = Vector3(getVehicleComponentPosition(self.vehicle, guiInfo.components.platform, "world"))
    self.camPos = Vector3(camPos.x, camPos.y, camPos.z + 0.8)

    setElementData(self.vehicle, "blockAction", localPlayer)
    setElementData(localPlayer, "blockAction", true)

    setElementFrozen(localPlayer, true)
    showCursor(true)
    bindKey("enter", "down", self.func.close)
    addEventHandler("onClientRender", root, self.func.render)
end

function Ladder:close()
    self.alpha = 0
    self.state = "closing"
    self.tick = getTickCount()

    showCursor(false)
    setCameraTarget(localPlayer)
    setElementFrozen(localPlayer, false)

    setElementData(self.vehicle, "blockAction", nil)
    setElementData(localPlayer, "blockAction", nil)

    unbindKey("enter", "down", self.func.close)
    self:updateLadder()
end

function Ladder:destroy()
    exports.TR_dx:setOpenGUI(false)

    destroyElement(self.bg)

    removeEventHandler("onClientRender", root, self.func.render)
    guiInfo.ladder = nil
    self = nil
end

function Ladder:animate()
    if not self.tick then return end
    local progress = (getTickCount() - self.tick)/500
    if self.state == "opening" then
        self.alpha = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "Linear")
        if progress >= 1 then
            self.alpha = 1
            self.state = "opened"
            self.tick = nil
        end

    elseif self.state == "closing" then
      self.alpha = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "Linear")
      if progress >= 1 then
            self.alpha = 0
            self.state = "closed"
            self.tick = nil

            self:destroy()
            return true
        end
    end
end

function Ladder:render()
    if self:animate() then return end
    self:updateCamera()

    dxDrawImage(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, self.bg, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
    dxDrawText("Naciśnij ENTER aby zamknąć okno.", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + guiInfo.h - 15/zoom, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.exit, "center", "bottom")
    self:renderButtons()
end

function Ladder:renderButtons()
    local move = {}

    if self:isPositionInCircle(guiInfo.x + 96/zoom, guiInfo.y + 75/zoom, 58/zoom, 66/zoom, 67/zoom) then -- EXTRACT
        if getKeyState("mouse1") then
            dxDrawCircle(guiInfo.x + 127/zoom, guiInfo.y + 105/zoom, 28/zoom, 0, 360, tocolor(255, 0, 0, 60), tocolor(255, 0, 0, 60))
            move = {"ladderSmall", "extract"}
        else
            dxDrawCircle(guiInfo.x + 127/zoom, guiInfo.y + 105/zoom, 28/zoom, 0, 360, tocolor(255, 0, 0, 100), tocolor(255, 0, 0, 100))
        end

    elseif self:isPositionInCircle(guiInfo.x + 96/zoom, guiInfo.y + 166/zoom, 58/zoom, 66/zoom, 67/zoom) then -- RETRACT
        if getKeyState("mouse1") then
            dxDrawCircle(guiInfo.x + 127/zoom, guiInfo.y + 194/zoom, 28/zoom, 0, 360, tocolor(255, 0, 0, 60), tocolor(255, 0, 0, 60))
            move = {"ladderSmall", "retract"}
        else
            dxDrawCircle(guiInfo.x + 127/zoom, guiInfo.y + 194/zoom, 28/zoom, 0, 360, tocolor(255, 0, 0, 100), tocolor(255, 0, 0, 100))
        end
    end

    if self:isPositionInCircle(guiInfo.x + 371/zoom, guiInfo.y + 75/zoom, 58/zoom, 66/zoom, 67/zoom) then -- RIGHT
        if getKeyState("mouse1") then
            dxDrawCircle(guiInfo.x + 401/zoom, guiInfo.y + 105/zoom, 28/zoom, 0, 360, tocolor(255, 0, 0, 60), tocolor(255, 0, 0, 60))
            move = {"platform", "right"}
        else
            dxDrawCircle(guiInfo.x + 401/zoom, guiInfo.y + 105/zoom, 28/zoom, 0, 360, tocolor(255, 0, 0, 100), tocolor(255, 0, 0, 100))
        end

    elseif self:isPositionInCircle(guiInfo.x + 371/zoom, guiInfo.y + 166/zoom, 58/zoom, 66/zoom, 67/zoom) then -- LEFT
        if getKeyState("mouse1") then
            dxDrawCircle(guiInfo.x + 401/zoom, guiInfo.y + 194/zoom, 28/zoom, 0, 360, tocolor(255, 0, 0, 60), tocolor(255, 0, 0, 60))
            move = {"platform", "left"}
        else
            dxDrawCircle(guiInfo.x + 401/zoom, guiInfo.y + 194/zoom, 28/zoom, 0, 360, tocolor(255, 0, 0, 100), tocolor(255, 0, 0, 100))
        end
    end

    if self:isPositionInCircle(guiInfo.x + 642/zoom, guiInfo.y + 75/zoom, 58/zoom, 66/zoom, 67/zoom) then -- LOWER
        if getKeyState("mouse1") then
            dxDrawCircle(guiInfo.x + 672/zoom, guiInfo.y + 105/zoom, 28/zoom, 0, 360, tocolor(255, 0, 0, 60), tocolor(255, 0, 0, 60))
            move = {"ladder", "lower"}
        else
            dxDrawCircle(guiInfo.x + 672/zoom, guiInfo.y + 105/zoom, 28/zoom, 0, 360, tocolor(255, 0, 0, 100), tocolor(255, 0, 0, 100))
        end

    elseif self:isPositionInCircle(guiInfo.x + 642/zoom, guiInfo.y + 166/zoom, 58/zoom, 66/zoom, 67/zoom) then -- RAISE
        if getKeyState("mouse1") then
            dxDrawCircle(guiInfo.x + 672/zoom, guiInfo.y + 194/zoom, 28/zoom, 0, 360, tocolor(255, 0, 0, 60), tocolor(255, 0, 0, 60))
            move = {"ladder", "raise"}
        else
            dxDrawCircle(guiInfo.x + 672/zoom, guiInfo.y + 194/zoom, 28/zoom, 0, 360, tocolor(255, 0, 0, 100), tocolor(255, 0, 0, 100))
        end
    end

    self:updateTurretPosition(move[1], move[2])
end

function Ladder:updateCamera()
    if self.state == "closing" then return end
    local pos = Vector3(getVehicleComponentPosition(self.vehicle, guiInfo.components.platform, "world"))
    local rot = Vector3(getElementRotation(self.vehicle))
    local ladderRot = Vector3(getVehicleComponentRotation(self.vehicle, guiInfo.components.ladder))
    pos.x = pos.x - math.sin(math.rad(rot.z + self.components.platform.rot.z)) * -10
    pos.y = pos.y + math.cos(math.rad(rot.z + self.components.platform.rot.z)) * -10

    setCameraMatrix(self.camPos, pos.x, pos.y, pos.z - self.components.ladder.rot.x/30 * 6)
end

function Ladder:updateTurretPosition(element, state)
    if element == "platform" then
        if state == "left" then
            self.components.platform.rot.z = self.components.platform.rot.z + guiInfo.moveSpeed.platform >= 360 and self.components.platform.rot.z + guiInfo.moveSpeed.platform - 360 or self.components.platform.rot.z + guiInfo.moveSpeed.platform

        elseif state == "right" then
            self.components.platform.rot.z = self.components.platform.rot.z - guiInfo.moveSpeed.platform <= 0 and self.components.platform.rot.z - guiInfo.moveSpeed.platform + 360 or self.components.platform.rot.z - guiInfo.moveSpeed.platform
        end

    elseif element == "ladder" then
        if state == "raise" then
            self.components.ladder.rot.x = self.components.ladder.rot.x - guiInfo.moveSpeed.ladder <= -30 and -30 or self.components.ladder.rot.x - guiInfo.moveSpeed.ladder

        elseif state == "lower" then
            self.components.ladder.rot.x = self.components.ladder.rot.x + guiInfo.moveSpeed.ladder >= 0 and 0 or self.components.ladder.rot.x + guiInfo.moveSpeed.ladder
        end

    elseif element == "ladderSmall" then
        if state == "extract" then
            self.components.ladderSmall.pos.y = self.components.ladderSmall.pos.y - guiInfo.moveSpeed.ladderSmall <= -2.95 and -2.95 or self.components.ladderSmall.pos.y - guiInfo.moveSpeed.ladderSmall

        elseif state == "retract" then
            self.components.ladderSmall.pos.y = self.components.ladderSmall.pos.y + guiInfo.moveSpeed.ladderSmall >= 0 and 0 or self.components.ladderSmall.pos.y + guiInfo.moveSpeed.ladderSmall
        end
    end

    local pos = getPositionOffset(self.vehicle, self.components.ladderSmall.pos)
    setVehicleComponentRotation(self.vehicle, guiInfo.components.platform, self.components.platform.rot)
    setVehicleComponentRotation(self.vehicle, guiInfo.components.ladder, self.components.ladder.rot)
    setVehicleComponentPosition(self.vehicle, guiInfo.components.ladderSmall, pos)


    if (getTickCount() - self.updateTick)/1000 < 1 then return end
    self.updateTick = getTickCount()

    self:updateLadder()
end

function Ladder:updateLadder()
    setElementData(self.vehicle, "ladder", {
        platform = math.floor(self.components.platform.rot.z * 100)/100,
        ladder = math.floor(self.components.ladder.rot.x * 100)/100 + 360,
        ladderSmall = math.floor(self.components.ladderSmall.pos.y * 100)/100,
    })
end

function getPositionOffset(veh, vec)
    local platformRot = Vector3(getVehicleComponentRotation(veh, guiInfo.components.platform))
    local ladderRot = Vector3(getVehicleComponentRotation(veh, guiInfo.components.ladder))
    local ladderPos = Vector3(getVehicleComponentPosition(veh, guiInfo.components.ladder))
    local ladderSmallPos = Vector3(getVehicleComponentPosition(veh, guiInfo.components.ladderSmall))

    local rot = Vector3(ladderRot.x - 1, ladderRot.y, platformRot.z)
	local mat = Matrix(ladderPos, rot)
    local newPos = mat:transformPosition(vec)

	return Vector3(newPos.x, newPos.y, newPos.z)
end

function Ladder:isMouseInPosition(x, y, width, height)
	if (not isCursorShowing()) then
		return false
	end
    local cx, cy = getCursorPosition()
    local cx, cy = (cx*sx), (cy*sy)
    if (cx >= x and cx <= x + width) and (cy >= y and cy <= y + height) then
        return true
    else
        return false
    end
end

function Ladder:isPositionInCircle(x, y, r, cx, cy)
    local i = 0
    for k=(-r), r do
        local q = math.sqrt((r/2)*(r/2)-k*k)
        if self:isMouseInPosition(x-q+(r/2), y+k+(r/2), 2*q, 1) then
            i = i+1
        end
    end
    return i ~= (-r)+r
end

function controlFireLadder(vehicle)
    exports.TR_dx:setResponseEnabled(false)

    if not vehicle then return end
    if guiInfo.ladder then return end
    guiInfo.ladder = Ladder:create(vehicle)
end


exports.TR_dx:setOpenGUI(false)
setCameraTarget(localPlayer)
setElementFrozen(localPlayer, false)

-- Update ladder collisions
local ladderCols = {}
function updateLadderCol()
    for i, v in pairs(getElementsByType("vehicle", resourceRoot, true)) do
        if getElementModel(v) == 544 then
            if ladderCols[v] then
                destroyElement(ladderCols[v].ladder)
                destroyElement(ladderCols[v].ladderSmall)
            end

            if not ladderCols[v] then ladderCols[v] = {} end

            local rotPlatfrom = Vector3(getVehicleComponentRotation(v, guiInfo.components.platform, "world"))
            local rotLadder = Vector3(getVehicleComponentRotation(v, guiInfo.components.ladder))
            local pos = Vector3(getVehicleComponentPosition(v, guiInfo.components.ladder, "world"))
            local posSmall = Vector3(getVehicleComponentPosition(v, guiInfo.components.ladderSmall, "world"))

            ladderCols[v].small = Vector3(getVehicleComponentPosition(v, guiInfo.components.ladderSmall))

            local rot = Vector3(rotLadder.x, rotLadder.y, rotPlatfrom.z)
            local mat = Matrix(posSmall, rot)
            local newPos = mat:transformPosition(Vector3(0, (posSmall.y - pos.y) * 0.02 - 1.6, 0))

            ladderCols[v].ladder = createObject(1916, pos, rotLadder.x - 1, rotLadder.y, rotPlatfrom.z)
            ladderCols[v].ladderSmall = createObject(1916, newPos, rotLadder.x - 1, rotLadder.y, rotPlatfrom.z)

            setElementAlpha(ladderCols[v].ladder, 0)
            setElementAlpha(ladderCols[v].ladderSmall, 0)

            setElementCollidableWith(ladderCols[v].ladder, v, false)
            setElementCollidableWith(ladderCols[v].ladderSmall, v, false)
        end
    end

    for i, v in pairs(ladderCols) do
        if not isElement(i) then
            if isElement(v.ladder) then destroyElement(v.ladder) end
            if isElement(v.ladderSmall) then destroyElement(v.ladderSmall) end
            ladderCols[v] = nil
        end
    end
end
setTimer(updateLadderCol, 100, 0)


function updateLadderPos()
    for _, veh in pairs(getElementsByType("vehicle", resourceRoot)) do
        if getElementModel(veh) == 544 and ladderCols[veh] then
            local data = getElementData(veh, "ladder")
            if data then
                local actPlatform = data.platform
                local actLadder = data.ladder
                local actLadderSmall = data.ladderSmall
                local ladderSmallPos = ladderCols[veh].small

                local platformRot = Vector3(getVehicleComponentRotation(veh, guiInfo.components.platform))
                local ladderRot = Vector3(getVehicleComponentRotation(veh, guiInfo.components.ladder))
                if round(platformRot.z) > actPlatform then
                    platformRot.z = getFastestPath(platformRot.z, actPlatform, guiInfo.moveSpeed.platform/2)

                elseif round(platformRot.y) < actPlatform then
                    platformRot.z = getFastestPath(platformRot.z, actPlatform, guiInfo.moveSpeed.platform/2)
                end

                if round(ladderRot.x) > actLadder then
                    ladderRot.x = getFastestPath(ladderRot.x, actLadder, guiInfo.moveSpeed.ladder/2)

                elseif round(ladderRot.x) < actLadder then
                    ladderRot.x = getFastestPath(ladderRot.x, actLadder, guiInfo.moveSpeed.ladder/2)
                end

                if round(ladderSmallPos.y) > actLadderSmall then
                    ladderSmallPos.y = math.min(round(ladderSmallPos.y - guiInfo.moveSpeed.ladderSmall/100), actLadderSmall)

                elseif round(ladderSmallPos.y) < actLadderSmall then
                    ladderSmallPos.y = math.max(round(ladderSmallPos.y - guiInfo.moveSpeed.ladderSmall/100), actLadderSmall)
                end
                ladderCols[veh].small = ladderSmallPos

                local pos = getPositionOffset(veh, Vector3(0, ladderSmallPos.y, 0))
                setVehicleComponentRotation(veh, guiInfo.components.platform, platformRot)
                setVehicleComponentRotation(veh, guiInfo.components.ladder, ladderRot)
                setVehicleComponentPosition(veh, guiInfo.components.ladderSmall, pos)
            end
        end
    end
end
addEventHandler("onClientRender", root, updateLadderPos)

function getFastestPath(now, new, speed)
    if now < new then
        if math.abs(now - new) < 180 then
            now = math.min(now + speed, new)
        else
            now = math.max(now - speed, new)
        end

    else
        if math.abs(now - new) < 180 then
            now = math.max(now - speed, new)
        else
            now = math.min(now + speed, new)
        end
    end

    return now
end

function round(number)
    return math.floor(number * 100)/100
end