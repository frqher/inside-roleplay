addEvent("syncDataToAdminPanel", true)

local sx, sy = guiGetScreenSize()
zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end


AdminInfo = {}
AdminInfo.__index = AdminInfo

function AdminInfo:create(...)
    local instance = {}
    setmetatable(instance, AdminInfo)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function AdminInfo:constructor(...)
    self.fonts = {
        reports = exports.TR_dx:getFont(10),
        pause = exports.TR_dx:getFont(16),
    }
    self.reportsList = {}
    self.chatLogs = {}

    self.centerChat = (sy - 200/zoom)/2

    self.isDev = arg[1].isDev or false
    self.showDev = false
    self.showUsage = false
    self.serverMysql = {}
    self.serverMysqlCount = 0
    self.serverMysqlTick = getTickCount()
    self.showChatLogs = true

    self.func = {}
    self.func.renderer = function() self:render() end
    self.func.chatLogsSwitch = function() self:chatLogsSwitch() end
    self.func.switchAdminPanel = function(...) self:switchAdminPanel(...) end
    self.func.syncDataToAdminPanel = function(...) self:syncDataToAdminPanel(...) end
    addEventHandler("syncDataToAdminPanel", root, self.func.syncDataToAdminPanel)

    addEventHandler("onClientRender", root, self.func.renderer)
    bindKey(",", "down", self.func.chatLogsSwitch)
    bindKey("lctrl", "both", self.func.switchAdminPanel)

    if self.isDev then
        self.func.devSwitch = function() self:switchDev() end
        self.func.usageSwitch = function() self:switchUsage() end
        bindKey(".", "down", self.func.devSwitch)
        bindKey("m", "down", self.func.usageSwitch)
        setDevelopmentMode(true)
    end

    self.adminPanel = AdminPanel:create()
    return true
end

function AdminInfo:remove()
    removeEventHandler("syncDataToAdminPanel", root, self.func.syncDataToAdminPanel)
    removeEventHandler("onClientRender", root, self.func.renderer)
    unbindKey(",", "down", self.func.chatLogsSwitch)
    unbindKey("lctrl", "both", self.func.switchAdminPanel)

    if self.isDev then
        unbindKey(".", "down", self.func.devSwitch)
        unbindKey("m", "down", self.func.usageSwitch)
    end
    self = nil
end


function AdminInfo:updateReports(reports)
    local count = #self.reportsList
    local newCount = #reports
    self.reportsList = {}
    for i, v in pairs(reports) do
        table.insert(self.reportsList, string.format("%s → %s", v.reporter, v.reported))
    end

    if count < newCount then
        exports.TR_noti:create("Przyszedł nowy report! Rzucajcie się jak na szynkę!", "system", 4)
    end
end

function AdminInfo:updateLogs(log)
    if #self.chatLogs > 20 then
        table.remove(self.chatLogs, #self.chatLogs)
    end

    table.insert(self.chatLogs, 1, {
        text = log,
    })

    if self:isLogSuspected(log) then
        self.chatLogs[1].suspected = true
    end
    outputConsole(log)
end

function AdminInfo:isLogSuspected(log)
    log = string.lower(log)
    for i, v in pairs(suspectedWords) do
        if string.find(log, v) then return true end
    end
    return false
end

function AdminInfo:updateServerStatus(...)
    self.serverStatus = {}
    self.serverPackets = arg[2][3]

    local status = arg[1]
    for i, v in ipairs(status) do
        if string.len(v[2]) < 2 and string.len(v[7]) < 2 then
            status[i] = nil
        end
    end
    for _, v in pairs(status) do
        if string.len(v[2]) < 2 then v[2] = "0%" end
        if string.len(v[7]) < 2 then v[7] = "0%" end
        v.nowNum = tonumber(string.sub(v[2], 1, string.len(v[2]) - 1))
        table.insert(self.serverStatus, v)
    end

    table.sort(self.serverStatus, function(a, b)
        return a.nowNum < b.nowNum
    end)
end

function AdminInfo:addMysqlInfo(...)
    table.insert(self.serverMysql, arg[1])
    if #self.serverMysql > 5 then table.remove(self.serverMysql, 1) end
    self.serverMysqlCount = self.serverMysqlCount + 1
    if not self.serverMysqlTick then self.serverMysqlTick = getTickCount() end
end

function AdminInfo:switchDev()
    self.showDev = not self.showDev
end

function AdminInfo:switchUsage()
    self.showUsage = not self.showUsage
end

function AdminInfo:chatLogsSwitch()
    self.showChatLogs = not self.showChatLogs
end

function AdminInfo:setPermissions(permissions)
    self.permissions = {}
    for i, v in pairs(permissions) do
        self.permissions[i] = v == 1 and true or false
    end
end

function AdminInfo:getPermissions()
    return self.permissions
end

function AdminInfo:switchAdminPanel(btn, state)
    if state == "down" then
        if getPedOccupiedVehicle(localPlayer) then return end
        self.adminPanel:open()
    else
        self.adminPanel:close()
    end
end

function AdminInfo:syncDataToAdminPanel(data)
    self.adminPanel:syncData(data)
end




-- Renders
function AdminInfo:render()
    self:renderChatLogs()
    self:renderReportLogs()
    self:renderTeleportPoints()
    self:renderBoomboxOwners()

    if self.isDev then
        self:renderTechnicalPause()
        self:renderVehicleData()
        self:renderObjectData()
        self:renderPlayerData()
        self:renderServerStatus()
        self:renderServerMysql()
    end
end

function AdminInfo:renderChatLogs()
    if not self.showChatLogs then return end
    local y = 430/zoom

    dxDrawText("LOGI CHATU (wyłączanie \",\"):", 20/zoom, y, sx - 5/zoom, y + 20/zoom, tocolor(255, 255, 255, 200), 1/zoom, self.fonts.reports, "left", "center", true, true)
    for i = 1, 17 do
        if self.chatLogs[i] then
            if self.chatLogs[i].suspected then
                dxDrawText(string.format("%s", self.chatLogs[i].text), 20/zoom, y + 5/zoom + i * 15/zoom, sx - 5/zoom, y + 15/zoom + i * 20/zoom, tocolor(255, 160, 160, 200), 1/zoom, self.fonts.reports, "left", "top", true, true)

            else
                dxDrawText(string.format("%s", self.chatLogs[i].text), 20/zoom, y + 5/zoom + i * 15/zoom, sx - 5/zoom, y + 15/zoom + i * 20/zoom, tocolor(255, 255, 255, 200), 1/zoom, self.fonts.reports, "left", "top", true, true)
            end
         end
    end
end

function AdminInfo:renderReportLogs()
    local y = (sy - 44/zoom) - math.min(#self.reportsList + 1, 12) * 15/zoom

    if #self.reportsList > 12 then
        y = y - 15/zoom
        dxDrawText(string.format("I %d więcej...", #self.reportsList - 10), 400/zoom, y + 13 * 15/zoom, sx - 5/zoom, y + 15/zoom + 13 * 20/zoom, tocolor(255, 255, 255, 200), 1/zoom, self.fonts.reports, "left", "top", true, true)
    end

    dxDrawText("LISTA REPORTÓW:", 400/zoom, y, sx - 5/zoom, y + 20/zoom, tocolor(255, 255, 255, 200), 1/zoom, self.fonts.reports, "left", "center", true, true)
    for i = 1, 12 do
        if self.reportsList[i] then
            dxDrawText(string.format("%s", self.reportsList[i]), 400/zoom, y + i * 15/zoom, sx - 5/zoom, y + 15/zoom + i * 20/zoom, tocolor(255, 255, 255, 200), 1/zoom, self.fonts.reports, "left", "top", true, true)
        end
    end
end

function AdminInfo:renderTeleportPoints()
    local plrPos = Vector3(getElementPosition(localPlayer))
    local plrInt = getElementInterior(localPlayer)
    local plrDim = getElementDimension(localPlayer)

    for i, v in pairs(getElementsByType("adminTP", root, true)) do
        local int = getElementInterior(v)
        local dim = getElementDimension(v)

        if int == plrInt and dim == plrDim then
            local pos = Vector3(getElementPosition(v))
            local dist = getDistanceBetweenPoints3D(plrPos, pos)

            local scx, scy = getScreenFromWorldPosition(pos + Vector3(0, 0, 0.5))
            if scx and scy and dist < 20 then
                local data = getElementData(v, "data")
                self:drawTextShadowed(string.format("#c21717[YÖNETİCİ IŞINLANMASI]\n#dcdcdcOluşturan: #888888%s\n#dcdcdcSlotlar: #888888%d\n#c21717▼", data.admin, data.slots), scx, scy, scx, scy, tocolor(255, 255, 255, 255), 1 * (1 - dist/20), self.fonts.reports, "center", "center", false, false, false, true)
            end
        end
    end
end


function AdminInfo:renderBoomboxOwners()
    local plrPos = Vector3(getElementPosition(localPlayer))
    local plrInt = getElementInterior(localPlayer)
    local plrDim = getElementDimension(localPlayer)

    for i, v in pairs(getElementsByType("boomboxAdmin", root, true)) do
        local boomboxAdmin = getElementData(v, "boomboxAdmin")
        if boomboxAdmin then
            local pos = Vector3(getElementPosition(v))
            local dist = getDistanceBetweenPoints3D(plrPos, pos)

            local scx, scy = getScreenFromWorldPosition(pos + Vector3(0, 0, 0.5))
            if scx and scy and dist < 20 then
                self:drawTextShadowed(string.format("#c21717[BOMBOX]\n#dcdcdcSahibi: #888888%s (%d)\n#dcdcdcKaldırmak için: #888888/bboff %d\n#c21717▼", boomboxAdmin.playerName, boomboxAdmin.id, boomboxAdmin.id), scx, scy, scx, scy, tocolor(255, 255, 255, 255), 1 * (1 - dist/20), self.fonts.reports, "center", "center", false, false, false, true)
            end
        end
    end
end


-- Dev renderers
function AdminInfo:renderTechnicalPause()
    if self.technicalPause then
        dxDrawText("TEKNİK ARIZA MODU ETKİN", 0, 10/zoom, sx, 0, tocolor(255, 50, 50, 255), 1/zoom, self.fonts.pause, "center", "top")
    end
end

function AdminInfo:renderObjectData()
    if not self.showDev then return end
    local px, py, pz = getElementPosition(localPlayer)

    for _, obj in pairs(getElementsByType("object", true)) do
        local x, y, z = getElementPosition(obj)
        local scx, scy = getScreenFromWorldPosition(x, y, z + 1)

        if scx and scy and getDistanceBetweenPoints3D(x, y, z, px, py, pz) < 40 then
            dxDrawText(string.format("%s", "object"), scx, scy, scx, scy, tocolor(255, 255, 255, 255), 1/zoom, "center", "center")
            local res = getElementParent(getElementParent(obj))
            if getElementType(res) == "resource" then
                print(getResourceName(res))
            end
        end
    end
end

function AdminInfo:renderVehicleData()
    if not self.showDev then return end
    local px, py, pz = getElementPosition(localPlayer)

    for _, veh in pairs(getElementsByType("vehicle", true)) do
        local x, y, z = getElementPosition(veh)
        local scx, scy = getScreenFromWorldPosition(x, y, z + 1)

        if scx and scy and getDistanceBetweenPoints3D(x, y, z, px, py, pz) < 40 then
            local rx, ry, rz = getElementRotation(veh)
            local model = getElementModel(veh)
            local name = getVehicleNameFromModel(model)
            local speed = self:getSpeed(veh, "km/h")
            local health = getElementHealth(veh)
            local vehicleID = getElementID(veh)
            local status = "Publiczny"

            if vehicleID then
                if string.len(vehicleID) > 4 then
                    status = string.format("Özellik %s", string.sub(vehicleID, 8, string.len(vehicleID)))
                end
            end

            dxDrawText(string.format("[%s]\n%s (%d)\nSağlık: %d\nHız: %d km/h\nx=%.2f, y=%.2f, z=%.2f\nrx=%.2f, ry=%.2f, rz=%.2f", status, name, model, health, speed, x, y, z, rx, ry, rz), scx, scy, scx, scy, tocolor(255, 255, 255, 255), 1/zoom, "center", "center")
        end
        self:renderBoxColider(veh, tocolor(255, 0, 0, 255), 3)
    end
end

function AdminInfo:renderPlayerData()
    if not self.showDev then return end
    local px, py, pz = getElementPosition(localPlayer)

    for _, plr in pairs(getElementsByType("player", true)) do
        local x, y, z = getElementPosition(plr)
        local scx, scy = getScreenFromWorldPosition(x, y, z + 0.4)

        if scx and scy and getDistanceBetweenPoints3D(x, y, z, px, py, pz) < 40 then
            local _, _, rz = getElementRotation(plr)
            local id = getElementData(plr, "ID")
            local uid = getElementData(plr, "characterUID")
            local model = getElementModel(plr)
            local speed = self:getSpeed(plr, "km/h")
            local health = getElementHealth(plr)

            dxDrawText(string.format("ID: %s\nUID: %d\nModel: %d\nSağlık: %d\nHız: %d km/h\nx=%.2f, y=%.2f, z=%.2f\nrz=%.2f", id, uid, model, health, speed, x, y, z, rz), scx, scy, scx, scy, tocolor(255, 255, 255, 255), 1/zoom, "center", "center")
        end
        self:renderBoxColider(plr, tocolor(200, 200, 200, 255), 1)
    end
end

function AdminInfo:renderServerStatus()
    if not self.showUsage then return end
    if not self.serverStatus or not self.serverPackets then return end

    local y = (sy - 50/zoom) - math.max(#self.serverStatus + 1, 2) * 20/zoom
    dxDrawText("Zużycie zasobów:", 600/zoom, y, 200/zoom, y, tocolor(255, 255, 255, 255), 1/zoom, self.fonts.reports, "left", "top")

    if #self.serverStatus > 0 then
        for i, row in ipairs(self.serverStatus) do
            if row.nowNum > 10 then
                dxDrawText(string.format("%s - %s (%s)", row[1], row[2], row[7]), 600/zoom, y + 20/zoom * i, 200/zoom, y + 20/zoom * i, tocolor(235, 38, 38, 255), 1/zoom, self.fonts.reports, "left", "top")
            elseif row.nowNum > 5 then
                dxDrawText(string.format("%s - %s (%s)", row[1], row[2], row[7]), 600/zoom, y + 20/zoom * i, 200/zoom, y + 20/zoom * i, tocolor(235, 192, 38, 255), 1/zoom, self.fonts.reports, "left", "top")
            else
                dxDrawText(string.format("%s - %s (%s)", row[1], row[2], row[7]), 600/zoom, y + 20/zoom * i, 200/zoom, y + 20/zoom * i, tocolor(255, 255, 255, 255), 1/zoom, self.fonts.reports, "left", "top")
            end
        end
    else
        dxDrawText("Server Durumu Kaydedilemedi", 600/zoom, y + 20/zoom, 200/zoom, y + 20/zoom, tocolor(255, 255, 255, 255), 1/zoom, self.fonts.reports, "left", "top")
    end
    dxDrawText(string.format("Senkronizasyon: %s %s", self.serverPackets[3], self.serverPackets[7]), 600/zoom, (sy - 40/zoom), 200/zoom, (sy - 40/zoom), tocolor(255, 255, 255, 255), 1/zoom, self.fonts.reports, "left", "top")
end

function AdminInfo:renderServerMysql()
    if not self.showUsage then return end
    local mysqlY = (sy - 50/zoom) - (#self.serverMysql + 1) * 20/zoom
    dxDrawText(string.format("Mysql querry (%s/s):", self.serverMysqlCount), 900/zoom, mysqlY, 200/zoom, mysqlY, tocolor(255, 255, 255, 255), 1/zoom, self.fonts.reports, "left", "top")
    if #self.serverMysql > 0 then
        for i, v in ipairs(self.serverMysql) do
            dxDrawText(v, 900/zoom, mysqlY + 20/zoom * i, 200/zoom, mysqlY + 20/zoom * i, tocolor(255, 255, 255, 255), 1/zoom, self.fonts.reports, "left", "top")
        end
    end

    if self.serverMysqlTick then
        if (getTickCount() - self.serverMysqlTick)/1000 >= 1 then
            self.serverMysqlTick = nil
            self.serverMysqlCount = 0
        end
    end
end








function AdminInfo:renderBoxColider(element, color, size)
    local m = element.matrix
    local e, s = Vector3(getElementBoundingBox(element)),Vector3(unpack({getElementBoundingBox(element)},4,6))
    local tfl = m:transformPosition(e.x,s.y,s.z)
    local tfr = m:transformPosition(s.x,s.y,s.z)
    local bfr = m:transformPosition(s.x,s.y,e.z)
    local bfl = m:transformPosition(e.x,s.y,e.z)
    dxDrawLine3D(tfl, tfr, color, size)
    dxDrawLine3D(tfr, bfr, color, size)
    dxDrawLine3D(bfr, bfl, color, size)
    dxDrawLine3D(bfl, tfl, color, size)
    local tbl = m:transformPosition(e.x,e.y,s.z)
    local tbr = m:transformPosition(s.x,e.y,s.z)
    local bbr = m:transformPosition(s.x,e.y,e.z)
    local bbl = m:transformPosition(e.x,e.y,e.z)
    dxDrawLine3D(tbl, tbr, color, size)
    dxDrawLine3D(tbr, bbr, color, size)
    dxDrawLine3D(bbr, bbl, color, size)
    dxDrawLine3D(bbl, tbl, color, size)
    dxDrawLine3D(tfl, tbl, color, size)
    dxDrawLine3D(tfr, tbr, color, size)
    dxDrawLine3D(bfr, bbr, color, size)
    dxDrawLine3D(bfl, bbl, color, size)
end

function AdminInfo:getSpeed(theElement, unit)
    assert(isElement(theElement), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(theElement) .. ")")
    local elementType = getElementType(theElement)
    assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "Invalid element type @ getElementSpeed (player/ped/object/vehicle/projectile expected, got " .. elementType .. ")")
    assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)")
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    return (Vector3(getElementVelocity(theElement)) * mult).length
end


function AdminInfo:setPauseState(state)
    self.technicalPause = state
end

function AdminInfo:drawTextShadowed(text, x, y, w, h, color, scale, font, vert, hori, clip, brake, post, colored)
	local withoutColor = self:removeColor(text)
	dxDrawText(withoutColor, x + 1, y + 1, w + 1, h + 1, tocolor(0, 0, 0, 100), scale, font, vert, hori, clip, brake, post)
	dxDrawText(text, x, y, w, h, color, scale, font, vert, hori, clip, brake, post, colored)
end

function AdminInfo:removeColor(text)
    while string.find(text, "#%x%x%x%x%x%x") do
      text = string.gsub(text, "#%x%x%x%x%x%x", "")
    end
    return text
end



-- Exports
local adminPanel

function openAdminGui(data, technicalPause, permissions)
    if adminPanel then return end
    adminPanel = AdminInfo:create(data)
    adminPanel:setPauseState(technicalPause)
    adminPanel:setPermissions(permissions)
    triggerServerEvent("getReports", resourceRoot)
end
addEvent("openAdminGui", true)
addEventHandler("openAdminGui", root, openAdminGui)

function closeAdminGui()
    if not adminPanel then return end
    adminPanel:remove()
    adminPanel = nil
    setDevelopmentMode(false)
end
addEvent("closeAdminGui", true)
addEventHandler("closeAdminGui", root, closeAdminGui)

function updateReports(reports)
    if not adminPanel then return end
    adminPanel:updateReports(reports)
end
addEvent("updateReports", true)
addEventHandler("updateReports", root, updateReports)

function updateLogs(log)
    if not adminPanel then return end
    adminPanel:updateLogs(log)
end
addEvent("updateLogs", true)
addEventHandler("updateLogs", root, updateLogs)


function updateAdminPermisions(permissions)
    if not adminPanel then return end
    adminPanel:setPermissions(permissions)
end
addEvent("updateAdminPermisions", true)
addEventHandler("updateAdminPermisions", root, updateAdminPermisions)


function updateServerStatus(...)
    if not adminPanel then return end
    adminPanel:updateServerStatus(...)
end
addEvent("updateServerStatus", true)
addEventHandler("updateServerStatus", root, updateServerStatus)

function addMysqlInfo(...)
    if not adminPanel then return end
    adminPanel:addMysqlInfo(...)
end
addEvent("addMysqlInfo", true)
addEventHandler("addMysqlInfo", root, addMysqlInfo)


function getAdminPermissions()
    if not adminPanel then return {} end
    return adminPanel:getPermissions()
end


function setTechnicalPauseState(state)
    if not adminPanel then return end
    adminPanel:setPauseState(state)
end


function isPlayerOnDuty()
    if not adminPanel then return false, {} end
    return true, adminPanel:getPermissions()
end

function isPlayerDeveloper()
    if not adminPanel then return false end
    return adminPanel.isDev
end




-- Technical pause
local technicalPause = {}

function performTechnicalPause(time)
    if not time then removeTechnicalPause() return end

    technicalPause.noti = exports.TR_noti:create(string.format("Planlı bakım %d %s sonra başlayacak.\nTüm önemli işlerinizi tamamlayın.", time, getTechnicalMinutes(time)), "system", time * 60)
    technicalPause.time = time
    technicalPause.timer = setTimer(updateTechnicalPause, 60000, 0)
    setTechnicalPauseState(true)
end
addEvent("performTechnicalPause", true)
addEventHandler("performTechnicalPause", root, performTechnicalPause)

function updateTechnicalPause()
    technicalPause.time = technicalPause.time - 1
    exports.TR_noti:setText(technicalPause.noti, string.format("Planlı bakım %d %s sonra başlayacak.\nTüm önemli işlerinizi tamamlayın.", technicalPause.time, getTechnicalMinutes(technicalPause.time)))
end

function removeTechnicalPause()
    if technicalPause.noti then
        exports.TR_noti:create("Planlı bakım sona erdi.\nNormal oyuna dönebilirsiniz", "system")

        exports.TR_noti:destroy(technicalPause.noti)
        killTimer(technicalPause.timer)
        technicalPause = {}
    end
    setTechnicalPauseState(nil)
end

function getTechnicalMinutes(number)
    return "dakika"
end

setDevelopmentMode(false)