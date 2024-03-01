local sx, sy = guiGetScreenSize()

local settings = {
    keys = [[
c - kamera noktasını ayarlama
f - imleci göster
x - animasyonu oynat
    ]],

    iconSize = 64,
    actionSize = 30,
    moveLineSize = 1,
    cameraDepth = 50,
    smoothLine = 10,
}

Cinematic = {}
Cinematic.__index = Cinematic

function Cinematic:create()
    local instance = {}
    setmetatable(instance, Cinematic)
    if instance:constructor() then
        return instance
    end
    return false
end

function Cinematic:constructor()
    self.points = {}
    self.recording = false
    self.speed = 100

    self.func = {}
    self.func.render = function() self:render() end
    self.func.moveCamera = function(...) self:moveCamera(...) end
    self.func.createPoint = function(...) self:createPoint(...) end
    self.func.showCursor = function(...) self:showCursor(...) end
    self.func.playAnim = function(...) self:playAnim(...) end
    self.func.onClick = function(...) self:onClick(...) end

    self.abx, self.aby, self.abz = getElementPosition(localPlayer)
    setElementAlpha(localPlayer, 0)

    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientPreRender", root, self.func.moveCamera)
    addEventHandler("onClientClick", root, self.func.onClick)
    bindKey("c", "down", self.func.createPoint)
    bindKey("f", "down", self.func.showCursor)
    bindKey("x", "down", self.func.playAnim)
    return true
end

function Cinematic:destroy()
    removeEventHandler("onClientRender", root, self.func.render)
    removeEventHandler("onClientPreRender", root, self.func.moveCamera)

    setElementAlpha(localPlayer, 255)
    setCameraTarget(localPlayer)
    self = nil
    settings.camera = nil
end

function Cinematic:playAnim()
    if self.recording then return end
    if #self.points < 2 then exports.TR_noti:create("En az 2 kamera noktası oluşturmalısın.", "error") return end
    self.recording = true
    self.isEditing = nil
    showCursor(false)

    self.recordTick = getTickCount()
    self.recordIndex = 1

    self:getRecordTime()
    self:unselectObject()
end

function Cinematic:getRecordTime()
    self.recordTime = getDistanceBetweenPoints3D(self.points[self.recordIndex].position, self.points[self.recordIndex + 1].position) * self.speed
end


function Cinematic:render()
    if not self.recording then
        self:renderKeys()

        for i, v in pairs(self.points) do
            self:drawPoint(i)
        end

        self:moveObject()
    else
        self:record()
    end
end

function Cinematic:record()
    local progress = (getTickCount() - self.recordTick)/self.recordTime
    local step = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "Linear")

    local point = self.points[self.recordIndex]
    local nextPoint = self.points[self.recordIndex + 1]
    local camPos = self:getBezierStep(step, point.position, point.curve, nextPoint.position)
    local targetPos = Vector3(interpolateBetween(point.target, nextPoint.target, progress, "Linear"))
    setCameraMatrix(camPos, targetPos)

    if progress >= 1 then
        if not self.points[self.recordIndex + 2] then
            self.recording = nil
            self.recordTick = nil
            setCameraTarget(localPlayer)
            return
        end
        self.recordIndex = self.recordIndex + 1
        self.recordTick = getTickCount()
        self:getRecordTime()
    end
end

function Cinematic:renderKeys()
    dxDrawText(settings.keys, 10, 0, sx, sy - 10, tocolor(255, 255, 255, 255), 1.4, "default", "left", "bottom")
    -- dxDrawText(inspect(self.points), 500, 10)
end

function Cinematic:drawPoint(index)
    local point = self.points[index]
    local nextPoint = index + 1 <= #self.points and self.points[index + 1] or false

    dxDrawLine3D(point.position, point.target, tocolor(34, 125, 171, 255), 2)

    local wx, wy = getScreenFromWorldPosition(point.position)
    if wx and wy then
        local dist = getDistanceBetweenPoints3D(point.position, self.abx, self.aby, self.abz)
        if dist < settings.iconSize then
            local size = settings.iconSize - dist
            dxDrawImage(wx - size/2, wy - size/2, size, size, "files/images/camera.png")
        end
    end

    local wx, wy = getScreenFromWorldPosition(point.target)
    if wx and wy then
        local dist = getDistanceBetweenPoints3D(point.target, self.abx, self.aby, self.abz)
        if dist < settings.iconSize then
            local size = settings.iconSize - dist
            dxDrawImage(wx - size/2, wy - size/2, size, size, "files/images/eye.png")
        end
    end

    if point.curve then
        local wx, wy = getScreenFromWorldPosition(point.curve)
        if wx and wy then
            local dist = getDistanceBetweenPoints3D(point.curve, self.abx, self.aby, self.abz)
            if dist < settings.iconSize then
                local size = settings.iconSize - dist
                dxDrawImage(wx - size/2, wy - size/2, size, size, "files/images/curve.png")
            end
        end

        if nextPoint then
            for i = 0, (settings.smoothLine - (1/settings.smoothLine)) do
                self:drawBezierLine(i/settings.smoothLine, point.position, point.curve, nextPoint.position)
            end
            dxDrawLine3D(point.target, nextPoint.target, tocolor(255, 255, 255, 255), 2)
        end
    end

    if self.isEditing then
        self:renderEditPoint(index)
    end
end

function Cinematic:createPoint()
    local x, y, z = getCameraMatrix()

    table.insert(self.points, {
        position = Vector3(x, y, z),
        target = Vector3(getWorldFromScreenPosition(sx/2, sy/2, settings.cameraDepth)),
    })

    self:calculateMiddlePoint(#self.points)
end

function Cinematic:renderEditPoint(index)
    local point = self.points[index]

    self:renderMovingLine(point.position, Vector3(settings.moveLineSize, 0, 0), Vector3(220, 0, 0), "X", index, "position")
    self:renderMovingLine(point.position, Vector3(0, settings.moveLineSize, 0), Vector3(0, 0, 220), "Y", index, "position")
    self:renderMovingLine(point.position, Vector3(0, 0, settings.moveLineSize), Vector3(0, 220, 0), "Z", index, "position")

    self:renderMovingLine(point.target, Vector3(settings.moveLineSize, 0, 0), Vector3(220, 0, 0), "X", index, "target")
    self:renderMovingLine(point.target, Vector3(0, settings.moveLineSize, 0), Vector3(0, 0, 220), "Y", index, "target")
    self:renderMovingLine(point.target, Vector3(0, 0, settings.moveLineSize), Vector3(0, 220, 0), "Z", index, "target")

    if point.curve then
        self:renderMovingLine(point.curve, Vector3(settings.moveLineSize, 0, 0), Vector3(220, 0, 0), "X", index, "curve")
        self:renderMovingLine(point.curve, Vector3(0, settings.moveLineSize, 0), Vector3(0, 0, 220), "Y", index, "curve")
        self:renderMovingLine(point.curve, Vector3(0, 0, settings.moveLineSize), Vector3(0, 220, 0), "Z", index, "curve")
    end
end

function Cinematic:renderMovingLine(pos, offset, color, axis, index, type)
    local offsetPos = Vector3(pos.x + offset.x, pos.y + offset.y, pos.z + offset.z)
    local wx, wy = getScreenFromWorldPosition(offsetPos)
    if wx and wy then
        local dist = getDistanceBetweenPoints3D(offsetPos, self.abx, self.aby, self.abz)
        if dist < settings.actionSize then
            local size = settings.actionSize - dist
            local sizeText = (size / settings.actionSize)
            local arrowSize = math.max(size - 2 * sizeText, 0)

            if self:isMouseInPosition(wx - size/2, wy - size/2, size, size) or (index == self.selectedObject and type == self.selectedType and axis == self.selectedAxis) then
                if getKeyState("mouse1") and not self.selectedObject then
                    self.selectedObject = index
                    self.selectedType = type
                    self.selectedAxis = axis
                end
            else
                color = Vector3(math.max(0, color.x - 80), math.max(0, color.y - 80), math.max(0, color.z - 80))
            end

            dxDrawLine3D(pos, offsetPos, tocolor(color.x, color.y, color.z, 255), 4)

            dxDrawRectangle(wx - size/2, wy - size/2, size, size, tocolor(color.x, color.y, color.z, 255))
            dxDrawImage(wx - arrowSize/2, wy - arrowSize/2, arrowSize, arrowSize, "files/images/move.png", 0, 0, 0, tocolor(255, 255, 255, 255))
        end
    end
end

function Cinematic:moveObject()
    if not self.selectedObject then return end
    local obj = self.points[self.selectedObject][self.selectedType]

    local wx, wy = getScreenFromWorldPosition(obj)
    if wx and wy then
        local axis = string.lower(self.selectedAxis)
        local cx, cy = getCursorPosition()
        local depth = math.min(getDistanceBetweenPoints3D(Vector3(getCameraMatrix()), obj), 300)
        local pos = Vector3(getWorldFromScreenPosition(cx * sx, cy * sy, depth))

        local diff = self.points[self.selectedObject][self.selectedType][axis] - pos[axis]

        self.points[self.selectedObject][self.selectedType][axis] = pos[axis]

        self:updateMiddlePoint(self.selectedObject, axis, diff)
    end
end

function Cinematic:showCursor()
    if self.recording then return end

    showCursor(not isCursorShowing())
    self.isEditing = isCursorShowing()
    self:unselectObject()
end


function Cinematic:onClick(...)
    if arg[1] == "left" then
        if arg[2] == "up" then
            self:unselectObject()
        end
    end
end

function Cinematic:unselectObject()
    self.selectedObject = nil
    self.selectedType = nil
    self.selectedAxis = nil
end

function Cinematic:moveCamera(timeSlice)
    if self.recording then setElementPosition(localPlayer, self.abx, self.aby, self.abz) return end
    local cx,cy,cz,ctx,cty,ctz = getCameraMatrix()
    ctx,cty = ctx-cx,cty-cy
    timeSlice = timeSlice*0.1
    local tx, ty, tz = getWorldFromScreenPosition(sx / 2, sy / 2, 10)
    if isChatBoxInputActive() or isConsoleActive() or isMainMenuActive () or isTransferBoxActive () then return end
    if getKeyState("lctrl") then timeSlice = timeSlice*4 end
    if getKeyState("lalt") then timeSlice = timeSlice*0.15 end
    local mult = timeSlice/math.sqrt(ctx*ctx+cty*cty)
    ctx,cty = ctx*mult,cty*mult
    if getKeyState("w") then self.abx,self.aby = self.abx+ctx,self.aby+cty end
    if getKeyState("s") then self.abx,self.aby = self.abx-ctx,self.aby-cty end
    if getKeyState("a") then self.abx,self.aby = self.abx-cty,self.aby+ctx end
    if getKeyState("d") then self.abx,self.aby = self.abx+cty,self.aby-ctx end
    if getKeyState("space") then self.abz = self.abz+timeSlice end
    if getKeyState("lshift") then self.abz = self.abz-timeSlice end

    setElementPosition(localPlayer, self.abx, self.aby, self.abz)
end

function Cinematic:calculateMiddlePoint(index)
    local lastPoint = self.points[index - 1] and self.points[index - 1] or false
    if lastPoint then
        local pos = self.points[index].position
        self.points[index - 1].curve = Vector3((pos.x + lastPoint.position.x)/2, (pos.y + lastPoint.position.y)/2, (pos.z + lastPoint.position.z)/2)
    end

    local nextPoint = self.points[index + 1] and self.points[index + 1] or false
    if nextPoint then
        local pos = self.points[index].position
        self.points[index].curve = Vector3((pos.x + nextPoint.position.x)/2, (pos.y + nextPoint.position.y)/2, (pos.z + nextPoint.position.z)/2)
    end
end

function Cinematic:updateMiddlePoint(index, axis, diff)
    if self.selectedType == "target" then return end
    if not self.points[index].curve then return end
    self.points[index].curve[axis] = self.points[index].curve[axis] - diff/2
end

function Cinematic:drawBezierLine(i, start, curve, endPos)
    local pos1 = self:getBezierStep(i, start, curve, endPos)
    local pos2 = self:getBezierStep(i + 1/settings.smoothLine, start, curve, endPos)
    dxDrawLine3D(pos1, pos2, tocolor(255, 255, 255), 2)
end

function Cinematic:changeSpeed(speed)
    self.speed = tonumber(speed)
    print("Camera speed set at: ", speed)
end

function Cinematic:getBezierStep(step, start, curve, endPos)
    local px = (1-step)*((1-step)*start.x + step*curve.x) + step*((1-step)*curve.x + step*endPos.x)
    local py = (1-step)*((1-step)*start.y + step*curve.y) + step*((1-step)*curve.y + step*endPos.y)
    local pz = (1-step)*((1-step)*start.z + step*curve.z) + step*((1-step)*curve.z + step*endPos.z)
    return Vector3(px, py, pz)
end

function Cinematic:isMouseInPosition(x, y, width, height)
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

function switchCamera()
    if settings.camera then
        settings.camera:destroy()
    else
        settings.camera = Cinematic:create()
    end
end
addCommandHandler("cinematic", switchCamera)


function changeSpeed(cmd, speed)
    if settings.camera then
        settings.camera:changeSpeed(speed)
    end
end
addCommandHandler("speed", changeSpeed)
-- switchCamera()
setCameraTarget(localPlayer)