local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 400/zoom)/2,
    y = sy - 140/zoom,
    w = 400/zoom,
    h = 140/zoom,

    keys = {
        ["addPoint"] = {name = "Mouse1", key = "mouse1"},
        ["removePoint"] =  {name = "Mouse2", key = "mouse2"},
        ["tpBegin"] =  {name = "HOME", key = "home"},
        ["accept"] =  {name = "ENTER", key = "enter"},
        ["reject"] =  {name = "BACKSPACE", key = "backspace"},
    },

    legend = [[
Tuşlar:
%s - yeni bir kontrol noktası oluşturma
%s - önceki kontrol noktasını silme
%s - rotanın başlangıcına ışınlanma
%s - rota kabulü
%s - rota iptal
    ]],

    maxMarkers = 50,
    minMarkers = 10,
}
guiInfo.legend = string.format(guiInfo.legend, guiInfo.keys["addPoint"].name, guiInfo.keys["removePoint"].name, guiInfo.keys["tpBegin"].name, guiInfo.keys["accept"].name, guiInfo.keys["reject"].name)

TrackCreator = {}
TrackCreator.__index = TrackCreator

function TrackCreator:create(...)
    local instance = {}
    setmetatable(instance, TrackCreator)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function TrackCreator:constructor(...)
    self.data = arg[1]
    self.track = {}

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.standard = exports.TR_dx:getFont(10)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.addPoint = function(...) self:addPoint(...) end
    self.func.removePoint = function(...) self:removePoint(...) end
    self.func.tpBegin = function(...) self:tpBegin(...) end
    self.func.accept = function(...) self:accept(...) end
    self.func.reject = function(...) self:reject(...) end
    self.func.updateCollisions = function(...) self:updateCollisions(...) end

    self:open()
    return true
end

function TrackCreator:open()
    addEventHandler("onClientRender", root, self.func.render)

    setElementPosition(localPlayer, self.data.selectedMinimapPos.map + Vector3(0, 0, 2))
    setTimer(function()
        self.data.selectedMinimapPos.map.z = getGroundPosition(self.data.selectedMinimapPos.map.x, self.data.selectedMinimapPos.map.y, 1000)
        setElementPosition(localPlayer, self.data.selectedMinimapPos.map + Vector3(0, 0, 4))

        setTimer(function()
            if not isElementInWater(localPlayer) then
                triggerServerEvent("createVehicleTrackCreation", resourceRoot, self.data.selectedMinimapPos.map.x, self.data.selectedMinimapPos.map.y, self.data.selectedMinimapPos.map.z + 2)
                setTimer(closeRacePanelByTrackCreator, 2000, 1)

                toggleControl("enter_exit", false)
                self:bindKeys()
            else
                setTimer(function()
                    exports.TR_dx:hideLoading()
                    exports.TR_dx:setResponseEnabled(false)
                    exports.TR_noti:create("Bu noktada yarışa başlayamazsınız.", "error")
                end, 500, 1)

                self:close()
            end
        end, 1500, 1)
    end, 3000, 1)
end

function TrackCreator:close()
    triggerServerEvent("removeAttachedObject", resourceRoot, 500)
    triggerServerEvent("onPlayerVehicleCreationeEnd", resourceRoot)

    removeEventHandler("onClientRender", root, self.func.render)
    toggleControl("enter_exit", true)

    self:removeMarkers()
    self:unbindKeys()
    if isTimer(self.updateCollisionsTimer) then killTimer(self.updateCollisionsTimer) end

    for i, v in pairs(getElementsByType("player", root)) do
        setElementCollisionsEnabled(v, true)
        setElementAlpha(v, 255)
    end

    guiInfo.creator = nil
    self = nil
end

function TrackCreator:bindKeys()
    for i, v in pairs(guiInfo.keys) do
        bindKey(v.key, "down", self.func[i])
    end

    self.updateCollisionsTimer = setTimer(self.func.updateCollisions, 1000, 0)
end

function TrackCreator:unbindKeys()
    for i, v in pairs(guiInfo.keys) do
        unbindKey(v.key, "down", self.func[i])
    end
end

function TrackCreator:updateCollisions()
    local veh = getPedOccupiedVehicle(localPlayer)
    for i, v in pairs(getElementsByType("player", root, true)) do
        if v ~= localPlayer then
            setElementCollisionsEnabled(v, false)
            setElementAlpha(v, 0)
        end
    end

    for i, v in pairs(getElementsByType("vehicle", resourceRoot, true)) do
        if v ~= veh then
            setElementCollisionsEnabled(v, false)
            setElementAlpha(v, 0)
        end
    end
end

function TrackCreator:render()
    self:drawBubbleBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255), 4)

    dxDrawText("Rota oluşturma", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 40/zoom, tocolor(240, 196, 55, 255), 1/zoom, self.fonts.main, "center", "center")
    dxDrawText(guiInfo.legend, guiInfo.x + 10/zoom, guiInfo.y + 50/zoom, guiInfo.x + guiInfo.w, guiInfo.y + guiInfo.h - 10/zoom, tocolor(220, 220, 220, 255), 1/zoom, self.fonts.standard, "left", "center")

    dxDrawText(string.format("Puan miktarı: %d/%d", #self.track, guiInfo.maxMarkers), guiInfo.x + 10/zoom, guiInfo.y + 50/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h - 10/zoom, tocolor(220, 220, 220, 255), 1/zoom, self.fonts.standard, "right", "bottom")
end

function TrackCreator:removeMarkers()
    for i, v in pairs(self.track) do
        if isElement(v.marker) then destroyElement(v.marker) end
    end
end

function TrackCreator:createMarkers()
    self:removeMarkers()

    local lastPoint = false
    for i = 0, (#self.track-1) do
        local v = self.track[#self.track - i]

        self.track[#self.track - i].marker = createMarker(v.pos, "checkpoint", 5, 255, 255, 255, 255)
        setElementDimension(self.track[#self.track - i].marker, 9530)

        if lastPoint then
            setMarkerTarget(self.track[#self.track - i].marker, lastPoint)
        else
            setMarkerIcon(self.track[#self.track - i].marker, "finish")
        end
        lastPoint = v.pos
    end
end

function TrackCreator:addPoint()
    if #self.track >= guiInfo.maxMarkers then exports.TR_noti:create("Puan sınırına ulaşıldı.", "error") return end
    local pos = Vector3(getElementPosition(localPlayer))
    local _, _, rot = getElementRotation(localPlayer)

    table.insert(self.track, {
        pos = pos,
        rot = rot,
    })

    self:createMarkers()
end

function TrackCreator:removePoint()
    if #self.track == 0 then exports.TR_noti:create("Kaldırılabilecek herhangi bir kontrol noktanız yok.", "error") return end
    self:removeMarkers()
    table.remove(self.track, #self.track)
    self:createMarkers()
end

function TrackCreator:tpBegin()
    if #self.track == 0 then exports.TR_noti:create("Başlangıç ​​kontrol noktası ayarlamadınız.", "error") return end
    setElementPosition(getPedOccupiedVehicle(localPlayer), self.track[1].pos + Vector3(0, 0, 1))
end

function TrackCreator:accept()
    if #self.track < guiInfo.minMarkers then exports.TR_noti:create("Rotada çok az kontrol noktası var.", "error") return end
    if #self.track > guiInfo.maxMarkers then exports.TR_noti:create("Rotada çok fazla kontrol noktası var.", "error") return end

    if self.acceptTick then
        if (getTickCount() - self.acceptTick)/1000 <= 1 then
            self:saveTrack()
            return
        end
    end

    self.acceptTick = getTickCount()
    exports.TR_noti:create(string.format("Rotayı kaydetmeyi onaylamak için tekrar %s tuşuna basın.", guiInfo.keys["accept"].name), "info")
end

function TrackCreator:saveTrack()
    local data = self:buildSaveData()
    self:unbindKeys()

    exports.TR_dx:setResponseEnabled(true, "Rota kaydetme")
    triggerServerEvent("addPlayerNewRaceTrack", resourceRoot, data)
end

function TrackCreator:onTrackSaved()
    self:unbindKeys()
    exports.TR_dx:showLoading(99999, "Önceki konuma dön")

    setTimer(function()
        self:close()

        setTimer(function()
            exports.TR_dx:hideLoading()
            exports.TR_dx:setResponseEnabled(false)
            exports.TR_noti:create("Rota başarıyla oluşturuldu.", "success")
        end, 2500, 1)
    end, 1000, 1)
end

function TrackCreator:buildSaveData()
    local points = {}
    for i, v in pairs(self.track) do
        table.insert(points, {
            pos = {v.pos.x, v.pos.y, v.pos.z},
            rot = v.rot,
        })
    end

    return {
        track = toJSON(points),

        type = self.data.selectedRaceType,
        laps = self.data.selectedRaceLaps,
        vehicleType = self.data.selectedVehicleType,
        vehicleSpeed = self.data.selectedVehicleSpeed,
    }
end

function TrackCreator:reject()
    if self.rejectTick then
        if (getTickCount() - self.rejectTick)/1000 <= 1 then
            self:unbindKeys()
            exports.TR_dx:showLoading(99999, "Önceki konuma dön")

            setTimer(function()
                setTimer(function()
                    exports.TR_dx:hideLoading()
                end, 2500, 1)

                self:close()
            end, 1000, 1)
            return
        end
    end

    self.rejectTick = getTickCount()
    exports.TR_noti:create(string.format("Rotanın reddedildiğini onaylamak için tekrar %s tuşuna basın.", guiInfo.keys["reject"].name), "info")
end

function TrackCreator:drawBubbleBackground(x, y, rx, ry, color, radius, post)
    rx = rx - radius * 2
    ry = ry - radius * 2
    x = x + radius
    y = y + radius

    if (rx >= 0) and (ry >= 0) then
        dxDrawRectangle(x, y, rx, ry, color, post)
        dxDrawRectangle(x, y - radius, rx, radius, color, post)
        dxDrawRectangle(x, y + ry, rx, radius, color, post)
        dxDrawRectangle(x - radius, y, radius, ry, color, post)
        dxDrawRectangle(x + rx, y, radius, ry, color, post)

        dxDrawCircle(x, y, radius, 180, 270, color, color, 7, 1, post)
        dxDrawCircle(x + rx, y, radius, 270, 360, color, color, 7, 1, post)
        dxDrawCircle(x + rx, y + ry, radius, 0, 90, color, color, 7, 1, post)
        dxDrawCircle(x, y + ry, radius, 90, 180, color, color, 7, 1, post)
    end
end


function startTrackCreation(...)
    if guiInfo.creator then return end
    guiInfo.creator = TrackCreator:create(...)
end

function onTrackCreationSave(...)
    if not guiInfo.creator then return end
    guiInfo.creator:onTrackSaved(...)
end
addEvent("onTrackCreationSave", true)
addEventHandler("onTrackCreationSave", root, onTrackCreationSave)