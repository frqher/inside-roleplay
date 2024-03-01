local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 1200/zoom)/2,
    y = (sy - 800/zoom)/2,
    w = 1200/zoom,
    h = 800/zoom,

    events = {
        "closeAdminPlayerPanelInfo", "takeoutPenaltyAdminPanelInfo", "givePenaltyAdminPlayerPanelInfo"
    }
}

AdminLogs = {}
AdminLogs.__index = AdminLogs

function AdminLogs:create(...)
    local instance = {}
    setmetatable(instance, AdminLogs)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function AdminLogs:constructor(...)
    self.func = {}
    self.func.render = function() self:render() end
    self.func.onLoaded = function() self:onLoaded() end
    self.func.onBrowserCreate = function() self:onBrowserCreate() end
    self.func.cursorMove = function(...) self:cursorMove(...) end
    self.func.injectClicks = function(...) self:injectClicks(...) end
    self.func.injectButtons = function(...) self:injectButtons(...) end
    self.func.loadPlayerData = function(...) self:loadPlayerData(...) end

    self:buildData(...)
    self:createPanel()
    return true
end

function AdminLogs:takeoutPenaltyAdminPanelInfo(penaltyID)
    triggerServerEvent("takeoutAdminPanelPlayerPenalty", resourceRoot, penaltyID)
end

function AdminLogs:givePenaltyAdminPlayerPanelInfo(playerID, playerUsername, penaltyType, penaltyMessage, penaltyTime, penaltyTimeType)
    local player = false
    for i, v in pairs(getElementsByType("player")) do
        if getElementData(v, "characterUID") == tonumber(playerID) then
            player = v
            break
        end
    end
    triggerServerEvent("givePenaltyAdminPlayerPanelInfo", resourceRoot, playerID, playerUsername, penaltyType, penaltyMessage, penaltyTime, penaltyTimeType, player)
end

function AdminLogs:closeAdminPlayerPanelInfo()
    removeEventHandler("onClientBrowserCreated", self.browser, self.func.onBrowserCreate)
    removeEventHandler("onClientBrowserDocumentReady", root, self.func.onLoaded)
    removeEventHandler("onClientRender", root, self.func.render)
    removeEventHandler("onClientCursorMove", root, self.func.cursorMove)
    removeEventHandler("onClientClick", root, self.func.injectClicks)
    removeEventHandler("onClientKey", root, self.func.injectButtons)

    if isElement(self.browser) then destroyElement(self.browser) end
    showCursor(false)

    guiInfo.panel = nil
    self = nil
end

function AdminLogs:buildData(plrData, vehicles, houses, organizations, penalties)
    self.data = {}
    self.data["userData"] = {}
    self.data["vehicles"] = {}
    self.data["houses"] = {}
    self.data["organizations"] = {}
    self.data["penalties"] = {}

    if plrData then
        for i, v in pairs(plrData) do
            self.data["userData"][i] = v
        end
    end

    if vehicles then
        for i, v in pairs(vehicles) do
            local veh = getElementByID("vehicle"..v.ID)

            if veh then
                local lastDriver = getElementData(veh, "lastDriver")
                self.data["vehicles"][i] = {
                    ID = v.ID,
                    model = string.format("%s (%d)", vehicleNames[tonumber(v.model) - 399], tonumber(v.model)),
                    location = getZoneName(Vector3(getElementPosition(veh))),
                    lastDriver = lastDriver and lastDriver or "Bilinmiyor"
                }

            else
                self.data["vehicles"][i] = {
                    ID = v.ID,
                    model = string.format("%s (%d)", vehicleNames[tonumber(v.model) - 399], tonumber(v.model)),
                    location = "Park Halinde",
                    lastDriver = "Bilinmiyor",
                }
            end
        end
    end

    if houses then
        for i, v in pairs(houses) do
            local pos = split(v.pos, ",")
            local zone = getZoneName(pos[1], pos[2], pos[3])
            self.data["houses"][i] = {
                ID = v.ID,
                date = v.date,
                location = zone,
            }
        end
    end

    if organizations then
        for i, v in pairs(organizations) do
            self.data["organizations"][i] = {
                ID = v.ID,
                name = v.name,
                money = v.money,
            }
        end
    end

    if penalties then
        for i, v in pairs(penalties) do
            self.data["penalties"][i] = {
                ID = v.ID,
                reason = v.reason,
                time = v.time,
                type = v.type,
                timeEnd = v.timeEnd,
                admin = v.admin,
                active = v.active,
                takenBy = v.takenBy,
            }
        end
    end
end

function AdminLogs:reloadPenalties(penalties)
    local newPenalties = {}
    if penalties then
        for i, v in pairs(penalties) do
            newPenalties[i] = {
                ID = v.ID,
                reason = v.reason,
                time = v.time,
                type = v.type,
                timeEnd = v.timeEnd,
                admin = v.admin,
                active = v.active,
                takenBy = v.takenBy,
            }
        end
    end
    executeBrowserJavascript(self.browser, string.format([[updatePenalties('%s')]], toJSON(newPenalties)))
end

function AdminLogs:createPanel()
    self.browser = createBrowser(guiInfo.w, guiInfo.h, true, false)

    showCursor(true)
    addEventHandler("onClientBrowserCreated", self.browser, self.func.onBrowserCreate)
    addEventHandler("onClientCursorMove", root, self.func.cursorMove)
    addEventHandler("onClientClick", root, self.func.injectClicks)
    addEventHandler("onClientKey", root, self.func.injectButtons)
    addEventHandler("onClientBrowserDocumentReady", root, self.func.onLoaded)
end

function AdminLogs:onLoaded()
    addEventHandler("onClientRender", root, self.func.render)
    setTimer(self.func.loadPlayerData, 1000, 1)
end

function AdminLogs:onBrowserCreate()
    loadBrowserURL(self.browser, "http://mta/local/files/html/AdminLogs.html")
    focusBrowser(self.browser)

    for i, v in pairs(guiInfo.events) do
        self.func[v] = function(...) self[v](self, ...) end
        addEvent(v, true)
        addEventHandler(v, self.browser, self.func[v])
    end
end

function AdminLogs:loadPlayerData()
    local permissions = exports.TR_admin:getAdminPermissions()

    executeBrowserJavascript(self.browser, string.format([[loadAdminName('%s')]], getPlayerName(localPlayer)))
    executeBrowserJavascript(self.browser, string.format([[loadAdminPermissions('%s')]], toJSON(permissions)))
    executeBrowserJavascript(self.browser, string.format([[pushDataToPanel('%s')]], toJSON(self.data)))
end

function AdminLogs:render()
    if not self.browser then return end

    dxDrawImage(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, self.browser, 0, 0, 0, tocolor(255,255,255,255), true)
end


-- Using web browser
function AdminLogs:cursorMove(relativeX, relativeY, absoluteX, absoluteY)
    local browserX, browserY = absoluteX - guiInfo.x, absoluteY - guiInfo.y
    injectBrowserMouseMove(self.browser, browserX, browserY)
end

function AdminLogs:injectButtons(button)
	if button == "mouse_wheel_down" then
		injectBrowserMouseWheel(self.browser, -40, 0)
	elseif button == "mouse_wheel_up" then
		injectBrowserMouseWheel(self.browser, 40, 0)
	end
end

function AdminLogs:injectClicks(button, state)
	if state == "down" then
        injectBrowserMouseDown(self.browser, button)
    else
        injectBrowserMouseUp(self.browser, button)
    end
end
--

function showAdminPlayerPanelInfo(...)
    if guiInfo.panel then return end
    guiInfo.panel = AdminLogs:create(...)
end
addEvent("showAdminPlayerPanelInfo", true)
addEventHandler("showAdminPlayerPanelInfo", root, showAdminPlayerPanelInfo)

function reloadPenaltiesAdminPlayerPanelInfo(...)
    if not guiInfo.panel then return end
    guiInfo.panel:reloadPenalties(...)
end
addEvent("reloadPenaltiesAdminPlayerPanelInfo", true)
addEventHandler("reloadPenaltiesAdminPlayerPanelInfo", root, reloadPenaltiesAdminPlayerPanelInfo)