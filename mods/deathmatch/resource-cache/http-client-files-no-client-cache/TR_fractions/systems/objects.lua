local sx, sy = guiGetScreenSize()

local guiInfo = {
    x = (sx - 200/zoom)/2,
    y = sy - 250/zoom,
    w = 200/zoom,
    h = 300/zoom,

    objectLimit = 30,

    avaliableObjects = {
        ["police"] = {
            {
                name = "Barierka",
                model = 1228,
                offset = Vector3(0, 1.4, 0.4),
                rotation = 90,
            },
            {
                name = "Pachołek",
                model = 1238,
                offset = Vector3(0, 1.4, 0.28),
            },
            {
                name = "Kolczatka",
                model = 2899,
                offset = Vector3(0, 3.4, 0.10),
            },
            {
                name = "Światło ostrzegawcze",
                model = 3526,
                offset = Vector3(0, 1.4, 0.07),
                rotation = 90,
            },
        },
        ["medic"] = {
            {
                name = "Torba medyczna",
                model = 3000,
                offset = Vector3(0, 1.4, 0.27),
                rotation = 270,
            },
        },
        ["fire"] = {
            {
                name = "Barierka",
                model = 1228,
                offset = Vector3(0, 1.4, 0.4),
                rotation = 90,
            },
            {
                name = "Pachołek",
                model = 1238,
                offset = Vector3(0, 1.4, 0.28),
            },
            {
                name = "Światło ostrzegawcze",
                model = 3526,
                offset = Vector3(0, 1.4, 0.07),
                rotation = 90,
            },
            {
                name = "Deska ratownicza",
                model = 2995,
                offset = Vector3(0, 1.4, 0.07),
                rotation = 90,
            },
            {
                name = "Namiot",
                model = 2996,
                offset = Vector3(0, 5, 1.58),
                rotation = 270,
            },
            {
                name = "Parawan",
                model = 2997,
                offset = Vector3(0, 1.4, 0.78),
                rotation = 270,
            },
            {
                name = "Pompa hydrauliczna",
                model = 2999,
                offset = Vector3(0, 1.4, 0.36),
                rotation = 90,
            },
            {
                name = "Torba medyczna",
                model = 3000,
                offset = Vector3(0, 1.4, 0.27),
                rotation = 270,
            },
            {
                name = "Skokochron",
                model = 1856,
                offset = Vector3(0, 1.4, 0.17),
                rotation = 90,
            },
            {
                name = "Mała drabina",
                model = 1428,
                offset = Vector3(0, 1.4, 1.05),
                rotation = 0,
                rot = Vector2(-30, 0),
            },
            {
                name = "Duża drabina",
                model = 1437,
                offset = Vector3(0, 1.4, 0.9),
                rotation = 0,
                rot = Vector2(-30, 0),
            },
        },
        ["ers"] = {
            {
                name = "Barierka",
                model = 1228,
                offset = Vector3(0, 1.4, 0.4),
                rotation = 90,
            },
            {
                name = "Pachołek",
                model = 1238,
                offset = Vector3(0, 1.4, 0.28),
            },
            {
                name = "Światło ostrzegawcze",
                model = 3526,
                offset = Vector3(0, 1.4, 0.07),
                rotation = 90,
            },
            {
                name = "Mała drabina",
                model = 1428,
                offset = Vector3(0, 1.4, 1.05),
                rotation = 0,
                rot = Vector2(-30, 0),
            },
            {
                name = "Duża drabina",
                model = 1437,
                offset = Vector3(0, 1.4, 0.9),
                rotation = 0,
                rot = Vector2(-30, 0),
            },
            {
                name = "Kanister z benzyną",
                model = 1650,
                offset = Vector3(0, 1.4, 0.3),
                rotation = 90,
            },
        },
    }
}

ObjectSystem = {}
ObjectSystem.__index = ObjectSystem

function ObjectSystem:create(...)
    local instance = {}
    setmetatable(instance, ObjectSystem)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function ObjectSystem:constructor()
    self.alpha = 0
    self.state = "closed"
    self.createdObjects = 0

    self.fonts = {}
    self.fonts.title = exports.TR_dx:getFont(18)
    self.fonts.info = exports.TR_dx:getFont(12)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.updateObject = function() self:updateObject() end
    self.func.useObject = function(...) self:useObject(...) end
    self.func.switchObject = function(...) self:switchObject(...) end

    return true
end

function ObjectSystem:open()
    local _, type = exports.TR_jobs:getPlayerJob()
    if not guiInfo.avaliableObjects[type] then return end
    if getPedOccupiedVehicle(localPlayer) then return end

    self.alpha = 0
    self.state = "opening"
    self.tick = getTickCount()


    self.selected = 1
    self.type = type

    exports.TR_dx:setOpenGUI(true)
    self:attachObject()

    bindKey("e", "down", self.func.switchObject)
    bindKey("q", "down", self.func.switchObject)
    bindKey("mouse1", "down", self.func.useObject)
    bindKey("mouse2", "down", self.func.useObject)

    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientPreRender", root, self.func.updateObject)
end

function ObjectSystem:close()
    self.alpha = 0
    self.state = "closing"
    self.tick = getTickCount()

    unbindKey("e", "down", self.func.switchObject)
    unbindKey("q", "down", self.func.switchObject)
    unbindKey("mouse1", "down", self.func.useObject)
    unbindKey("mouse2", "down", self.func.useObject)
end

function ObjectSystem:destroy()
    if self.object then destroyElement(self.object) end
    self.object = nil

    exports.TR_dx:setOpenGUI(false)

    removeEventHandler("onClientRender", root, self.func.render)
    removeEventHandler("onClientPreRender", root, self.func.updateObject)
end

function ObjectSystem:animate()
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
      end
    end
end

function ObjectSystem:render()
    self:animate()
    if getPedOccupiedVehicle(localPlayer) and self.state == "opened" then self:close() end
    dxDrawImage(guiInfo.x, guiInfo.y, guiInfo.w, 107/zoom, string.format("files/images/%s.png", guiInfo.avaliableObjects[self.type][self.selected].model), 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
    dxDrawText(guiInfo.avaliableObjects[self.type][self.selected].name, guiInfo.x, guiInfo.y + 115/zoom, guiInfo.x + guiInfo.w, guiInfo.y + 115/zoom, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.title, "center", "top")

    dxDrawText(string.format("Postawione obiekty: #d4af37%d#dcdcdc/#d4af37%d", self.createdObjects, guiInfo.objectLimit), guiInfo.x, guiInfo.y + 150/zoom, guiInfo.x + guiInfo.w, guiInfo.y + 180/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "top", false, false, false, true)
    dxDrawText("Aby postawić obiekt użyj #d4af37LPM", guiInfo.x, guiInfo.y + 180/zoom, guiInfo.x + guiInfo.w, guiInfo.y + 210/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "top", false, false, false, true)
    dxDrawText("Aby usunąć postawione obiekty użyj #d4af37PPM", guiInfo.x, guiInfo.y + 200/zoom, guiInfo.x + guiInfo.w, guiInfo.y + 230/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "top", false, false, false, true)
    dxDrawText("Aby zmienić obiekt użyj klawiszy #d4af37q #dcdcdclub #d4af37e", guiInfo.x, guiInfo.y + 220/zoom, guiInfo.x + guiInfo.w, guiInfo.y + 250/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "top", false, false, false, true)
end

function ObjectSystem:updateObject()
    local x, y, z = self:getPosition(localPlayer, guiInfo.avaliableObjects[self.type][self.selected].offset)
    z = getGroundPosition(x, y, z) + guiInfo.avaliableObjects[self.type][self.selected].offset.z
    setElementPosition(self.object, x, y, z)

    local rx, ry, rz = getElementRotation(localPlayer)
    setElementRotation(self.object, rx + (guiInfo.avaliableObjects[self.type][self.selected].rot and guiInfo.avaliableObjects[self.type][self.selected].rot.x or 0), ry + (guiInfo.avaliableObjects[self.type][self.selected].rot and guiInfo.avaliableObjects[self.type][self.selected].rot.y or 0), guiInfo.avaliableObjects[self.type][self.selected].rotation and rz + guiInfo.avaliableObjects[self.type][self.selected].rotation or rz)
end

function ObjectSystem:attachObject()
    if self.object then destroyElement(self.object) end
    self.object = createObject(guiInfo.avaliableObjects[self.type][self.selected].model, 0, 0, 0)
    setElementData(self.object, "action", true, false)

    setElementCollisionsEnabled(self.object, false)
    setElementAlpha(self.object, 180)
end


function ObjectSystem:switch()
    if self.state == "opened" then
        self:close()

    elseif self.state == "closed" then
        if not exports.TR_dx:canOpenGUI() then return end
        self:open()
    end
end

function ObjectSystem:switchObject(...)
    if arg[1] == "q" then
        self.selected = self.selected - 1
        if self.selected < 1 then self.selected = #guiInfo.avaliableObjects[self.type] end

    elseif arg[1] == "e" then
        self.selected = self.selected + 1
        if self.selected > #guiInfo.avaliableObjects[self.type] then self.selected = 1 end
    end
    self:attachObject()
end

function ObjectSystem:useObject(...)
    if arg[1] == "mouse1" then
        if self.createdObjects >= guiInfo.objectLimit then return end
        self.createdObjects = self.createdObjects + 1

        local model = getElementModel(self.object)
        local x, y, z = getElementPosition(self.object)
        local rx, ry, rz = getElementRotation(self.object)
        triggerServerEvent("placeObjectSystem", resourceRoot, model, x, y, z, rx, ry, rz)

    elseif arg[1] == "mouse2" then
        if self.createdObjects < 1 then return end
        self.createdObjects = self.createdObjects - 1
        triggerServerEvent("clearObjectsSystem", resourceRoot)
    end
end

function ObjectSystem:getPosition(element, vec)
	local rot = Vector3(getElementRotation(element))
	local mat = Matrix(Vector3(getElementPosition(element)), rot)
	local newPos = mat:transformPosition(vec)
	return newPos.x, newPos.y, newPos.z, rot.z
end



guiInfo.panel = ObjectSystem:create()

function openObjectSystem(key, state)
    guiInfo.panel:switch()
end
bindKey("z", "down", openObjectSystem)



function blockDestroy()
    for i, v in pairs(getElementsByType("object", resourceRoot)) do
        setObjectBreakable(v, false)
    end
end
blockDestroy()
setTimer(blockDestroy, 1000, 0)

function checkQuiver()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return end

    for i, v in pairs(getElementsByType("object", resourceRoot)) do
        local model = getElementModel(v)

        if model == 2899 or model == 2892 then
            local ox,oy = getElementPosition(v)
            local x1,y1,_ = getVehicleComponentPosition(veh,"wheel_lf_dummy","world")
            local x2,y2,_ = getVehicleComponentPosition(veh,"wheel_lb_dummy","world")
            local x3,y3,_ = getVehicleComponentPosition(veh,"wheel_rf_dummy","world")
            local x4,y4,_ = getVehicleComponentPosition(veh,"wheel_rb_dummy","world")
            local s1,s2,s3,s4 = getVehicleWheelStates(veh)
            local distance1 = getDistanceBetweenPoints2D(x1,y1,ox,oy)
            local distance2 = getDistanceBetweenPoints2D(x2,y2,ox,oy)
            local distance3 = getDistanceBetweenPoints2D(x3,y3,ox,oy)
            local distance4 = getDistanceBetweenPoints2D(x4,y4,ox,oy)

            if distance1 < 2.1 and s1 ~= 1 then
                triggerServerEvent("quiverDestroyWheel", resourceRoot, 1)
            end
            if distance2 < 2.1 and s2 ~= 1 then
                triggerServerEvent("quiverDestroyWheel", resourceRoot, 2)
            end
            if distance3 < 2.1 and s3 ~= 1 then
                triggerServerEvent("quiverDestroyWheel", resourceRoot, 3)
            end
            if distance4 < 2.1 and s4 ~= 1 then
                triggerServerEvent("quiverDestroyWheel", resourceRoot, 4)
            end
        end
    end
end
setTimer(checkQuiver, 200, 0)