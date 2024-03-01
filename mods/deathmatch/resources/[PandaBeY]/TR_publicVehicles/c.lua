local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

PrivateVehicles = {}
PrivateVehicles.__index = PrivateVehicles

function PrivateVehicles:create()
    local instance = {}
    setmetatable(instance, PrivateVehicles)
    if instance:constructor() then
        return instance
    end
    return false
end

function PrivateVehicles:isEventHandlerAdded( sEventName, pElementAttachedTo, func )
    if type( sEventName ) == 'string' and isElement( pElementAttachedTo ) and type( func ) == 'function' then
        local aAttachedFunctions = getEventHandlers( sEventName, pElementAttachedTo )
        if type( aAttachedFunctions ) == 'table' and #aAttachedFunctions > 0 then
            for i, v in ipairs( aAttachedFunctions ) do
                if v == func then
                    return true
                end
            end
        end
    end
    return false
end

function PrivateVehicles:constructor()
    self.elements = {}
    self.counter = 0
    self.time = {}
    self.vehicle = nil
    self.font = exports.TR_dx:getFont(11)
    self.streamIn = function(...) self:onClientElementStreamIn(source, ...) end
    self.streamOut = function(...) self:onClientElementStreamOut(source, ...) end
    self.onDataChange = function(...) self:onClientElementDataChange(source, ...) end
    self.onVehicleExit = function(...) self:onClientVehicleExit(source, ...) end
    self.onVehicleEnter = function(...) self:onClientVehicleEnter(source, ...) end
    self.render = function(...) self:onClientRender(...) end
    self.preRender = function(...) self:onClientPreRender(...) end
    self.onElementDestroy = function(...) self:onClientElementDestroy(source, ...) end
    for index,vehicle in ipairs(getElementsByType("vehicle", resourceRoot, true)) do
        self.counter = self.counter+1
        self.elements[vehicle] = { true, owner = getElementData(vehicle, "publicOwner") }
    end
     if self.counter > 0 then
        if not self:isEventHandlerAdded("onClientRender", root, self.render) then
            addEventHandler( "onClientRender", root, self.render)
        end
    end
    addEventHandler("onClientElementStreamIn", resourceRoot, self.streamIn)
    addEventHandler("onClientElementStreamOut", resourceRoot, self.streamOut)
    addEventHandler("onClientElementDataChange", resourceRoot, self.onDataChange)
    addEventHandler("onClientElementDestroy", resourceRoot, self.onElementDestroy)
    addEventHandler("onClientVehicleEnter", resourceRoot, self.onVehicleEnter)
    addEventHandler("onClientVehicleExit", resourceRoot, self.onVehicleExit)
end

function PrivateVehicles:onClientElementDestroy(theElement)
    if self.vehicle == theElement then
        self.time = {}
        self.udpate = 0
        self.vehicle = nil
    end
    if getElementType(theElement) == "vehicle" and self.elements[theElement] then
        self.elements[theElement] = nil
        self.counter = self.counter-1
    end
    if self.counter <= 0 then
        if self:isEventHandlerAdded("onClientRender", root, self.render) then
            removeEventHandler( "onClientRender", root, self.render)
        end
    end
    collectgarbage()
end

function PrivateVehicles:onClientElementDataChange(theElement)
    if getElementType(theElement) == "vehicle" and self.elements[theElement] then
        local owner = getElementData(theElement, "publicOwner")
        if owner == getPlayerName(localPlayer) and not self.vehicle then
            self.vehicle = theElement
        end
        self.elements[theElement] = {true, owner = owner}
    end
end

function PrivateVehicles:onClientElementStreamIn(theElement)
    if getElementType(theElement) == "vehicle" and not self.elements[theElement] then
        self.elements[theElement] = {true, owner = getElementData(theElement, "publicOwner")}
        self.counter = self.counter+1
    end
    if self.counter > 0 then
        if not self:isEventHandlerAdded("onClientRender", root, self.render) then
            addEventHandler( "onClientRender", root, self.render)
        end
    end
end

function PrivateVehicles:onClientElementStreamOut(theElement)
    if getElementType(theElement) == "vehicle" and self.elements[theElement] then
        self.elements[theElement] = nil
        self.counter = self.counter-1
    end
    if self.counter <= 0 then
        if self:isEventHandlerAdded("onClientRender", root, self.render) then
            removeEventHandler( "onClientRender", root, self.render)
        end
    end
    collectgarbage()
end

function PrivateVehicles:onClientVehicleEnter(vehicle, player, seat)
    if player == localPlayer and seat == 0 and self.vehicle == vehicle then
        self.time = {}
        self.update = 0
        if self.notification then
            exports.TR_noti:destroy(self.notification)
        end
        if not self:isEventHandlerAdded("onClientPreRender", root, self.preRender) then
            addEventHandler( "onClientPreRender", root, self.preRender)
        end
    end
end

function PrivateVehicles:onClientVehicleExit(vehicle, player, seat)
    if player == localPlayer and seat == 0 and self.vehicle == vehicle then
        self.update = 0
        self.notification = exports.TR_noti:create("Zsiadłeś z wypożyczonego roweru.\nPojazd zniknie za 60s.", "bike", 60)
        self.time.start = getTickCount(  )
        self.time.finish = self.time.start + 60 * 1000
        if self:isEventHandlerAdded("onClientPreRender", root, self.preRender) then
            removeEventHandler( "onClientPreRender", root, self.preRender)
        end
    end
end

function PrivateVehicles:onClientPreRender()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if self.vehicle and isElement(self.vehicle) and vehicle == self.vehicle then
        local model = getElementModel(vehicle)
        if model == 481 or model == 510 then
            local speed = self:getElementSpeed(self.vehicle, "km/h")
            if speed > 35 then
                self:setElementSpeed(self.vehicle, "km/h", 35)
            end
        end
    end
end

function PrivateVehicles:onClientRender()
    local px, py, pz = getCameraMatrix()
    for vehicle, data in pairs(self.elements) do
        local x, y, z = getElementPosition(vehicle)
        local vx, vy = getScreenFromWorldPosition(x, y, z)
        local dist = getDistanceBetweenPoints3D(px, py, pz, x, y, z)
        local clear = isLineOfSightClear(px, py, pz, x, y, z, true, false, false, true, true, true)
        if vx and vy and clear and dist < 40 then
             local alpha = dist <= 20 and 1 or (20 - dist)/10
             dist = dist/30
              dxDrawText(data.owner and string.format("Kamu aracı\n#999999(%s)", data.owner) or "Kamu aracı\n#999999(Özgür)", vx, vy, vx, vy, tocolor(255, 255, 255, 255 * alpha), 1/zoom - dist, self.font, "center", "center", false, false, false, true)
        end
    end
    if self.vehicle and isElement(self.vehicle) then
        if self.time and self.time.start and self.time.finish then
            local now = getTickCount()
            local elapsedTime = now - self.time.start
            local duration = self.time.finish - self.time.start
            local progress = elapsedTime / duration
            local time = (duration - elapsedTime)/1000
            if progress <= 1.0 and self.update ~= math.floor(time) then
                self.update = math.floor(time)
                if self.notification then
                    exports.TR_noti:setText(self.notification, string.format("Kiraladığınız bisikletten indiniz.\nAraç %ds içinde kaybolacak.", time) )
                end
            elseif progress > 1.0 then
                self.time = {}
                self.udpate = 0
                self.vehicle = nil
                triggerServerEvent("onVehicleDestroy", localPlayer)
            end
        end
    end
end

function PrivateVehicles:getElementSpeed(theElement, unit)
    local elementType = getElementType(theElement)
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    return (Vector3(getElementVelocity(theElement)) * mult).length
end

function PrivateVehicles:setElementSpeed(element, unit, speed)
    local unit    = unit or 0
    local speed   = tonumber(speed) or 0
    local acSpeed = self:getElementSpeed(element, unit)
    if acSpeed and acSpeed~=0 then
        local diff = speed/acSpeed
        if diff ~= diff then return false end
        local x, y, z = getElementVelocity(element)
        return setElementVelocity(element, x*diff, y*diff, z*diff)
    end
    return false
end

PrivateVehicles:create()