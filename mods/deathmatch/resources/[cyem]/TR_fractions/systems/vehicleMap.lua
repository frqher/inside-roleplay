local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local settings = {}
local guiInfo = {
  mapSize = 6000,

  minZoom = 5,
  maxZoom = 1.7,
  blipZoom = 0.8,

  legend = {
	x = 0,
	y = sy - 80/zoom,
	w = sx,
	h = 80/zoom,

	mapLegend = {},
  },

  fonts = {
	zone = exports.TR_dx:getFont(13),
	option = exports.TR_dx:getFont(12),
	legend = exports.TR_dx:getFont(11),
  },

  legendText = "#f0c437PPM #c8c8c8- Opcje mapy\n#f0c437LPM #c8c8c8- Przesuwanie mapy\n#f0c437Scroll #c8c8c8- Przybliż/oddal mapę",

  fractionPlayerBlip = {
	[1] = 33,
	[3] = 31,
	[5] = 57,
  }
}

Map = {}
Map.__index = Map

function Map:create(...)
  local instance = {}
  setmetatable(instance, Map)
  if instance:constructor(...) then
	return instance
  end
  return false
end

function Map:constructor(...)
	settings.textures = exports.TR_hud:getMapTextures()

	self.mapFractionID = arg[1]
	self.anim = 0
	self.showedBlips = {}

	self.zoom = 3
	self.mapSize = guiInfo.mapSize / self.zoom

	self:calculateRender()
	self.target = dxCreateRenderTarget(guiInfo.target.w, guiInfo.target.h)

	self.buttons = {}
	self.buttons.exit = exports.TR_dx:createButton(guiInfo.legend.x + guiInfo.legend.w - 260/zoom, guiInfo.legend.y + (guiInfo.legend.h - 40/zoom)/2, 250/zoom, 40/zoom, "Zamknij mapę")
	exports.TR_dx:setButtonVisible(self.buttons, false)
	exports.TR_dx:showButton(self.buttons)

	-- Static
	self.func = {}
	self.func.render = function(...) self:render(...) end
	self.func.switch = function(...) self:switch(...) end
	self.func.buttonClick = function(...) self:buttonClick(...) end

	self:open()
	return true
end

function Map:calculateRender()
  guiInfo.target = {
	x = 0,
	y = 0,
	w = sx,
	h = sy - guiInfo.legend.h,
  }
end

function Map:centerOnPlayer()
  if not self.centered then return end
  local x, y = self:getCenterPoints()
  local px, py, _ = getElementPosition(localPlayer)

  self.x = x
  self.y = y
end

function Map:getMapPositionFromWorld(x, y)
  return self.x + (x * (self.mapSize/6000)), self.y - (y * (self.mapSize/6000))
end

function Map:getWorldPositionFromMap(x, y)
  local cx, cy = self:getCenterPoints()
  return ((cx - self.x) + x) * (6000/self.mapSize), ((self.y - cy ) - y) * (6000/self.mapSize)
end

function Map:getCenterPoints()
  return guiInfo.target.w/2, guiInfo.target.h/2
end

function Map:open()
  if not getElementData(localPlayer, "characterUID") then return end
  if not exports.TR_dx:canOpenGUI() then return end

  self.opened = true
  self.centered = true
  self.onBlip = {}

  exports.TR_chat:showCustomChat(false)
  exports.TR_dx:setOpenGUI(true)
  exports.TR_hud:setHudVisible(false)

  self:centerOnPlayer()

  self.tick = getTickCount()
  self.state = "opening"
  addEventHandler("onClientRender", root, self.func.render)
  addEventHandler("onClientKey", root, self.func.switch)
  addEventHandler("guiButtonClick", root, self.func.buttonClick)
  showCursor(true)
end

function Map:buttonClick(...)
	if arg[1] == self.buttons.exit then
		self:close()
	end
end

function Map:switch(...)
  if exports.TR_dx:isResponseEnabled() then return false end
  if self.tick or not self.opened then return end
  if arg[1] == "mouse_wheel_up" and arg[2] then
	if self:isMouseInPosition(guiInfo.target.x, guiInfo.target.y, guiInfo.target.w, guiInfo.target.h) then self:zoomMap("down") end

  elseif arg[1] == "mouse_wheel_down" and arg[2] then
	if self:isMouseInPosition(guiInfo.target.x, guiInfo.target.y, guiInfo.target.w, guiInfo.target.h) then self:zoomMap("up") end

  elseif arg[1] == "mouse1" and arg[2] then
	if self:isMouseInPosition(guiInfo.target.x, guiInfo.target.y, guiInfo.target.w, guiInfo.target.h) then
	  self.centered = false
	  local cx, cy = getCursorPosition()
	  self.move = {cx * sx, cy * sy}
	  self.options = nil
	end

  elseif arg[1] == "mouse1" and not arg[2] then
	self.move = nil
  end
end

function Map:close()
  self.opened = nil

  exports.TR_dx:hideButton(self.buttons)

  exports.TR_chat:showCustomChat(true)
  exports.TR_hud:setHudVisible(true)

  self.tick = getTickCount()
  self.state = "closing"
  showCursor(false)
end

function Map:zoomMap(...)
  if arg[1] == "up" then
	local mx, my = self:getWorldPositionFromMap(0, 0)

	self.zoom = self.zoom + 0.1
	if self.zoom >= guiInfo.minZoom then self.zoom = guiInfo.minZoom end
	self.mapSize = guiInfo.mapSize / self.zoom

	local x, y = self:getCenterPoints()
	self.x = x - mx * (self.mapSize/6000)
	self.y = y + my * (self.mapSize/6000)

  elseif arg[1] == "down" then
	local mx, my = self:getWorldPositionFromMap(0, 0)

	self.zoom = self.zoom - 0.1
	if self.zoom <= guiInfo.maxZoom then self.zoom = guiInfo.maxZoom end
	self.mapSize = guiInfo.mapSize / self.zoom

	local x, y = self:getCenterPoints()
	self.x = x - mx * (self.mapSize/6000)
	self.y = y + my * (self.mapSize/6000)
  end
end

function Map:animate()
  if not self.tick then return end
  local progress = (getTickCount() - self.tick)/500
  if self.state == "opening" then
	self.anim = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "Linear")
	if progress >= 1 then
	  self.anim = 1
	  self.state = "opened"
	  self.tick = nil
	end

  elseif self.state == "closing" then
	self.anim = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "Linear")
	if progress >= 1 then
	  self.anim = 0
	  self.state = "closed"
	  self.tick = nil
	  self.options = nil
	  exports.TR_dx:setOpenGUI(false)
	  exports.TR_dx:destroyButton(self.buttons.exit)

	  removeEventHandler("onClientRender", root, self.func.render)
	  removeEventHandler("onClientKey", root, self.func.switch)
	  removeEventHandler("guiButtonClick", root, self.func.buttonClick)

	  guiInfo.map = nil
	  self = nil
	end
  end
end

function Map:render()
  self:animate()
  self:renderTarget()
  self:drag()

  dxDrawRectangle(guiInfo.legend.x, guiInfo.legend.y, guiInfo.legend.w, guiInfo.legend.h, tocolor(17, 17, 17, 255 * self.anim))
  dxDrawText(guiInfo.legendText, guiInfo.legend.x + 10/zoom, guiInfo.legend.y, guiInfo.legend.x + guiInfo.legend.w, guiInfo.legend.y + guiInfo.legend.h - 10/zoom, tocolor(200, 200, 200, 200 * self.anim), 1/zoom, guiInfo.fonts.legend, "left", "bottom", false, false, false, true)

  dxDrawImage(guiInfo.target.x, guiInfo.target.y, guiInfo.target.w, guiInfo.target.h, self.target, 0, 0, 0, tocolor(255, 255, 255, 255 * self.anim))

  if self:isMouseInPosition(guiInfo.target.x, guiInfo.target.y, guiInfo.target.w, guiInfo.target.h) then
	local cx, cy = getCursorPosition()
	cx, cy = (cx*sx) - guiInfo.target.x - guiInfo.target.w/2, (cy*sy) - guiInfo.target.y - guiInfo.target.h/2

	local mx, my = self:getWorldPositionFromMap(cx, cy)
	local city = getZoneName(mx, my, 0, true)
	local zone = getZoneName(mx, my, 0)
	if city ~= "Unknown" and zone ~= "Unknown" then
	  dxDrawText(string.format("%s | %s", city, zone), guiInfo.legend.x, guiInfo.legend.y, guiInfo.legend.x + guiInfo.legend.w, guiInfo.legend.y + guiInfo.legend.h, tocolor(255, 255, 255, 200 * self.anim), 1/zoom, guiInfo.fonts.zone, "center", "center")
	end

  else
	dxDrawText("Najedź na mapę aby poznać lokalizację.", guiInfo.legend.x, guiInfo.legend.y, guiInfo.legend.x + guiInfo.legend.w, guiInfo.legend.y + guiInfo.legend.h, tocolor(255, 255, 255, 200 * self.anim), 1/zoom, guiInfo.fonts.zone, "center", "center")
  end
end

function Map:renderBlips()
  local selectedBlip = false
  for i, v in pairs(getElementsByType("vehicle", resourceRoot)) do
	local fractionID = getElementData(v, "fractionID")
	if fractionID == self.mapFractionID then
		local x, y, _ = getElementPosition(v)
		local r, g, b = 0, 200, 0
		x, y = self:getMapPositionFromWorld(x, y)

		for i = 0, 1 do
			local occupant = getVehicleOccupant(v, i)
			if occupant then
				local characterDuty = getElementData(occupant, "characterDuty")
				if characterDuty then
					if characterDuty[4] == self.mapFractionID then
						r, g, b = 200, 0, 0
					end
				end
			end
		end

		dxDrawImage(x - 40/zoom/self.zoom * guiInfo.blipZoom, y - 80/zoom/self.zoom * guiInfo.blipZoom, 80/zoom/self.zoom * guiInfo.blipZoom, 80/zoom/self.zoom * guiInfo.blipZoom, settings.textures["bg"], 0, 0, 0, tocolor(r, g, b, 255 * self.anim))
		dxDrawImage(x - 40/zoom/self.zoom * guiInfo.blipZoom, y - 80/zoom/self.zoom * guiInfo.blipZoom, 80/zoom/self.zoom * guiInfo.blipZoom, 80/zoom/self.zoom * guiInfo.blipZoom, settings.textures[2], 0, 0, 0, tocolor(r, g, b, 255 * self.anim))

		local cx, cy = getCursorPosition()
		if cx and cy then
			cx, cy = (cx*sx) - guiInfo.target.x - guiInfo.target.w/2, (cy*sy) - guiInfo.target.y - guiInfo.target.h/2
			cx, cy = self:getWorldPositionFromMap(cx, cy)
			local mx, my = self:getMapPositionFromWorld(cx, cy)
			if mx >= x - 40/zoom/self.zoom * guiInfo.blipZoom and mx <= x - 40/zoom/self.zoom * guiInfo.blipZoom + 70/zoom/self.zoom * guiInfo.blipZoom and my >= y - 80/zoom/self.zoom * guiInfo.blipZoom and my <= y - 80/zoom/self.zoom * guiInfo.blipZoom + 70/zoom/self.zoom * guiInfo.blipZoom then
				selectedBlip = v
			end
		end
	end
  end
  return selectedBlip
end

function Map:renderBlipInfo(blip)
	if self.onBlip.blip ~= blip then
		local blipType = getElementType(blip)
		if blipType == "player" then
			self.onBlip = {
				color = {255, 0, 0},
				icon = guiInfo.fractionPlayerBlip[self.mapFractionID],
			}

			self.onBlip.name = getPlayerName(blip)
			self.onBlip.w = dxGetTextWidth(self.onBlip.name, 1/zoom, guiInfo.fonts.zone) + 50/zoom
			self.onBlip.h = 40/zoom

		elseif blipType == "vehicle" then
			self.onBlip = {
				color = {0, 200, 0},
				icon = 2,
			}

			self.onBlip.name = getVehicleName(blip)..self:getVehicleNumber(blip)
			self.onBlip.w = math.max(dxGetTextWidth(self.onBlip.name, 1/zoom, guiInfo.fonts.zone) + 50/zoom, 80/zoom)
			self.onBlip.h = 64/zoom

			self.onBlip.descTitle = "Personel:"
			self.onBlip.descTable = {}
			for i = 0, 1 do
				local occupant = getVehicleOccupant(blip, i)
				if occupant then
					local characterDuty = getElementData(occupant, "characterDuty")
					if characterDuty then
						if characterDuty[4] == self.mapFractionID then
							local name = getPlayerName(occupant)
							table.insert(self.onBlip.descTable, name)

							self.onBlip.w = math.max(dxGetTextWidth("- "..name, 1/zoom, guiInfo.fonts.zone) + 50/zoom, self.onBlip.w)
							self.onBlip.color = {255, 0, 0}
						end
					end
				end
			end

			if #self.onBlip.descTable < 1 then
				self.onBlip.descTable = {"Brak"}
			end
			self.onBlip.h = self.onBlip.h + #self.onBlip.descTable * 15/zoom
		end
	end

	local cx, cy = getCursorPosition()
	if cx and cy then
		cx, cy = cx * sx, cy * sy
		local color = self.onBlip.color

		self:drawBackground(cx, cy, self.onBlip.w, self.onBlip.h + 5/zoom, tocolor(color[1], color[2], color[3], 255 * self.anim), 5, true)
		dxDrawImage(cx, cy + 4/zoom, 40/zoom, 40/zoom, settings.textures[self.onBlip.icon], 0, 0, 0, tocolor(color[1], color[2], color[3], 255 * self.anim), true)
		dxDrawText(self.onBlip.name, cx + 40/zoom, cy, cx + self.onBlip.w, cy + 40/zoom, tocolor(color[1], color[2], color[3], 255 * self.anim), 1/zoom, guiInfo.fonts.zone, "left", "center", true, true, true)

		if self.onBlip.descTitle then
			dxDrawText(self.onBlip.descTitle, cx + 10/zoom, cy + 34/zoom, cx + self.onBlip.w, cy + self.onBlip.h, tocolor(200, 200, 200, 255 * self.anim), 1/zoom, guiInfo.fonts.legend, "left", "top", true, true, true)

			for i, v in pairs(self.onBlip.descTable) do
			  dxDrawText("- "..v, cx + 10/zoom, cy + 52/zoom + 17/zoom * (i-1), cx + self.onBlip.w, cy + self.onBlip.h, tocolor(170, 170, 170, 255 * self.anim), 1/zoom, guiInfo.fonts.legend, "left", "top", true, true, true)
			end
		end
	end
end

function Map:getVehicleNumber(veh)
	local fractionNumber = getElementData(veh, "fractionNumber") or getElementData(veh, "fractionNumberNoImg")
	if not fractionNumber then return "" end
	return " #"..fractionNumber
end

function Map:renderPlayers()
	local selectedBlip = false

  	for i, v in pairs(getElementsByType("player")) do
		if getElementInterior(v) == 0 and getElementDimension(v) == 0 then
			local characterDuty = getElementData(v, "characterDuty")
			if characterDuty then
				if getElementData(v, "characterUID") and not getElementData(v, "inv") and characterDuty[4] == self.mapFractionID and not getPedOccupiedVehicle(v) then
					local x, y, _ = getElementPosition(v)
					local r, g, b = 255, 0, 0
					x, y = self:getMapPositionFromWorld(x, y)
					dxDrawImage(x - 20/zoom/self.zoom * guiInfo.blipZoom, y - 20/zoom/self.zoom * guiInfo.blipZoom, 40/zoom/self.zoom * guiInfo.blipZoom, 40/zoom/self.zoom * guiInfo.blipZoom, settings.textures[0], 0, 0, 0, tocolor(r, g, b, 255 * self.anim))

					if self:isMouseInPosition(x - 20/zoom/self.zoom * guiInfo.blipZoom, y - 20/zoom/self.zoom * guiInfo.blipZoom, 40/zoom/self.zoom * guiInfo.blipZoom, 40/zoom/self.zoom * guiInfo.blipZoom) then
						selectedBlip = v
					end
				end
			end
		end
	end
	return selectedBlip
end

function Map:getBlipName(blip, icon)
  local data = getElementData(blip, "blipName")
  if data then return data end

  for i, v in pairs(mapLegend) do
	if v.id == icon then
	  return v.text
	end
  end
  return ""
end

function Map:renderTarget()
  local selectedBlip = false

  dxSetRenderTarget(self.target, true)
  dxDrawRectangle(0, 0, guiInfo.target.w,guiInfo.target.h, tocolor(17, 17, 17, 255))

  local rx, ry = self.x - self.mapSize/2, self.y - self.mapSize/2
  for x=0, 5, 1 do
	for y=0, 5, 1 do
		if settings.textures.radar[x] and settings.textures.radar[x][y] then
			dxDrawImage(rx, ry, 1000/self.zoom, 1000/self.zoom, settings.textures.radar[x][y])
		end

	  ry = ry + 1000/self.zoom
	  if y == 5 then ry = self.y - self.mapSize/2 end
	end
	rx = rx + 1000/self.zoom
  end

  local x, y, _ = getElementPosition(localPlayer)
  local _, _, rz = getElementRotation(localPlayer)
  x, y = self:getMapPositionFromWorld(x, y)

  local selectedBlip = self:renderPlayers()
  local selectedVehicle = self:renderBlips()

  selectedBlip = selectedBlip and selectedBlip or selectedVehicle
  dxSetRenderTarget()

  if selectedBlip then self:renderBlipInfo(selectedBlip) end
end

function Map:drag()
  if not self.move then return end
  local cx, cy = getCursorPosition()
  if not cx or not cy then return end
  self.x = self.x - (self.move[1] - (cx * sx))
  self.y = self.y - (self.move[2] - (cy * sy))
  self.move = {(cx * sx), (cy * sy)}

  if self.x - self.mapSize/2 > guiInfo.target.w/2 then
	self.x = guiInfo.target.w/2 + self.mapSize/2
  elseif self.x + self.mapSize/2 < guiInfo.target.w/2 then
	self.x = guiInfo.target.w/2 - self.mapSize/2
  end
  if self.y - self.mapSize/2 > guiInfo.target.h/2 then
	self.y = guiInfo.target.h/2 + self.mapSize/2
  elseif self.y + self.mapSize/2 < guiInfo.target.h/2 then
	self.y = guiInfo.target.h/2 - self.mapSize/2
  end
end


function Map:drawBackground(x, y, rx, ry, color, radius, post)
  local bgColor = tocolor(37, 37, 37, 255 * self.anim)
  rx = rx - radius * 2
  ry = ry - radius * 2
  x = x + radius
  y = y + radius

  if (rx >= 0) and (ry >= 0) then
	dxDrawRectangle(x, y, rx, ry, bgColor, post)
	dxDrawRectangle(x, y - radius, rx, radius, bgColor, post)
	dxDrawRectangle(x, y + ry, rx, radius, color, post)
	dxDrawRectangle(x - radius, y, radius, ry, bgColor, post)
	dxDrawRectangle(x + rx, y, radius, ry, bgColor, post)

	dxDrawCircle(x, y, radius, 180, 270, bgColor, bgColor, 7, 1, post)
	dxDrawCircle(x + rx, y, radius, 270, 360, bgColor, bgColor, 7, 1, post)
	dxDrawCircle(x + rx, y + ry, radius, 0, 90, color, color, 7, 1, post)
	dxDrawCircle(x, y + ry, radius, 90, 180, color, color, 7, 1, post)
  end
end

function Map:drawOptionsBackground(x, y, rx, ry, color, radius, post)
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

function Map:isMouseInPosition(x, y, width, height)
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




function onMarkerHit(el, md)
	if el ~= localPlayer or not md then return end
	if getPedOccupiedVehicle(localPlayer) then return end
	if not isPedOnGround(localPlayer) then return end

	local characterDuty = getElementData(localPlayer, "characterDuty")
	if not characterDuty then return end

	local fractionID = getElementData(source, "fractionID")
	if characterDuty[4] ~= fractionID then return end

	if guiInfo.map then return end
	if not exports.TR_dx:canOpenGUI() then return end

	guiInfo.map = Map:create(fractionID)
end





local markerPositions = {
	-- SAPD
	{
		pos = Vector3(2818.39453125, -2437.9794921875, 82.295310974121),
		int = 2,
		dim = 6,
		fractionID = 1,
		color = {180, 180, 180},
	},
	{
		pos = Vector3(-1617.03515625, 686.4248046875, 7.1999998092651),
		int = 0,
		dim = 0,
		fractionID = 1,
		color = {180, 180, 180},
	},

	-- SAMC
	{
		pos = Vector3(2556.8671875, -2026.8701171875, 99.189064025879),
		int = 0,
		dim = 17,
		fractionID = 2,
		color = {180, 180, 180},
	},

	-- SAFD
	{
		pos = Vector3(2751.8720703125, -1962.6533203125, 67.192184448242),
		int = 2,
		dim = 2,
		fractionID = 3,
		color = {180, 180, 180},
	},
	{
		pos = Vector3(2476.177734375, 1210.2958984375, 10.8),
		int = 0,
		dim = 0,
		fractionID = 3,
		color = {180, 180, 180},
	},

	-- ROAD
	{
		pos = Vector3(-2892.9248046875, 130.0185546875, 20.697187423706),
		int = 0,
		dim = 15,
		fractionID = 4,
		color = {180, 180, 180},
	},

	-- Radio
	{
		pos = Vector3(-57.2958984375, -239.8154296875, 6.625),
		int = 0,
		dim = 0,
		fractionID = 5,
		color = {180, 180, 180},
	},
}

function createMarkers()
	for i, v in pairs(markerPositions) do
		local marker = createMarker(v.pos - Vector3(0, 0, 0.9), "cylinder", 1.2, v.color[1], v.color[2], v.color[3], 0)
		setElementInterior(marker, v.int)
		setElementDimension(marker, v.dim)

		setElementData(marker, "markerIcon", "map", false)
        setElementData(marker, "markerData", {
            title = "Dyżurka",
            desc = "Wejdź w marker aby otworzyć mapę.",
        }, false)

		local col = createColSphere(v.pos - Vector3(0, 0, 0.9), 2)
		setElementData(col, "fractionID", v.fractionID, false)
		setElementInterior(col, v.int)
		setElementDimension(col, v.dim)

		addEventHandler("onClientColShapeHit", col, onMarkerHit)
	end
end
createMarkers()