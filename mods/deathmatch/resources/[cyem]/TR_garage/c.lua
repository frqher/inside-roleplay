local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
  selected = 1,

  fonts = {
    vehicle = exports.TR_dx:getFont(14),
    normal = exports.TR_dx:getFont(13),
    legend = exports.TR_dx:getFont(11),
  },

  vehicles = {},
  legend = [[
#d4af37←,→ #c8c8c8- araç seçimi
#d4af37ENTER #c8c8c8- kabul et
#d4af37BACKSPACE #c8c8c8- çıkış]],

  garagePos = {
    pedPos = {-1747.9079589844, 983.79528808594, 111.40000152588, 56},
    vehiclePos = {-1751.5739746094, 984.61364746094, 111.40000152588, 48},
    camLook = {-1751.5739746094, 984.61364746094, 111.40000152588},
    camPos = {-1759.396484375, 991.8046875, 113.59852600098},
    int = 0,
    dim = 1,
  }
}

function showVehicleGarage(querry, garageData)
  if not exports.TR_dx:canOpenGUI() then return end
  exports.TR_dx:showLoading(3000, "Garaj yükleniyor")
  exports.TR_hud:setHudVisible(false)
  exports.TR_chat:showCustomChat(false)
  exports.TR_dx:setOpenGUI(true)
  guiInfo.vehicles = {}
  guiInfo.garageData = guiInfo.garagePos
  guiInfo.garageNow = garageData.style
  guiInfo.spawnPos = table.concat(garageData.quit, ",")
  guiInfo.selected = 1

  local added = {}
  for i, v in pairs(querry) do
    if not added[v.ID] then
      table.insert(guiInfo.vehicles, v)
      added[v.ID] = true
    end
  end

  guiInfo.vehicle = createVehicle(411, guiInfo.garageData.vehiclePos[1], guiInfo.garageData.vehiclePos[2], guiInfo.garageData.vehiclePos[3] - 10, 0, 0, guiInfo.garageData.vehiclePos[4])
	guiInfo.ped = createPed(getElementModel(localPlayer), guiInfo.garageData.pedPos[1], guiInfo.garageData.pedPos[2], guiInfo.garageData.pedPos[3], guiInfo.garageData.pedPos[4], false)
  setElementInterior(guiInfo.vehicle, guiInfo.garageData.int)
  setElementDimension(guiInfo.vehicle, guiInfo.garageData.dim)
  setElementInterior(guiInfo.ped, guiInfo.garageData.int)
  setElementDimension(guiInfo.ped, guiInfo.garageData.dim)

  setTimer(selectVehicle, 200, 1, 1)

  setPlayerMove(false)
  setElementFrozen(localPlayer, true)
  setElementInterior(localPlayer, guiInfo.garageData.int)
  setElementDimension(localPlayer, guiInfo.garageData.dim)
  setElementAlpha(localPlayer, 0)

  setTimer(function() addEventHandler("onClientRender", root, render); addEventHandler("onClientKey", root, click) end, 3000, 1)
end
addEvent("showVehicleGarage", true)
addEventHandler("showVehicleGarage", root, showVehicleGarage)

function closeVehicleGarage(state)
  if not state then exports.TR_dx:setResponseEnabled(false) return end

  exports.TR_dx:showLoading(3000, "Dünya yükleniyor")
  exports.TR_dx:setResponseEnabled(false)
  exports.TR_hud:setHudVisible(true)
  exports.TR_chat:showCustomChat(true)
  exports.TR_dx:setOpenGUI(false)

  removeEventHandler("onClientKey", root, click)

  setTimer(function()
    destroyElement(guiInfo.vehicle)
    destroyElement(guiInfo.ped)
    removeEventHandler("onClientRender", root, render)
  end, 1000,1)

  setTimer(function()
    setPlayerMove(true)
    setCameraTarget(localPlayer)
    setElementAlpha(localPlayer, 255)
    setElementFrozen(localPlayer, false)

    setElementInterior(localPlayer, 0)
    setElementDimension(localPlayer, 0)
  end, 1600, 1 )
end
addEvent("closeVehicleGarage", true)
addEventHandler("closeVehicleGarage", root, closeVehicleGarage)

function render()
  local vehname = getVehicleName(guiInfo.vehicles[guiInfo.selected].model)
  if not vehname then vehname = "ERROR" end

	setCameraMatrix(guiInfo.garageData.camPos[1], guiInfo.garageData.camPos[2], guiInfo.garageData.camPos[3], guiInfo.garageData.camLook[1], guiInfo.garageData.camLook[2], guiInfo.garageData.camLook[3])

  -- drawBackground(-10, sy - 75/zoom, 180/zoom, 85/zoom, tocolor(17, 17, 17, 255), 5)
  -- dxDrawText(guiInfo.legend, 10/zoom, 0, 0, sy - 10/zoom, tocolor(255, 255, 255, 255), 1/zoom, guiInfo.fonts.legend, "left", "bottom", false, false, false, true)

  drawBackground((sx - 600/zoom)/2, sy - 100/zoom, 600/zoom, 75/zoom, tocolor(17, 17, 17, 255), 5)
  dxDrawText(string.format("%s (ID: %d)", vehname, guiInfo.vehicles[guiInfo.selected].ID), 0, sy - 75/zoom, sx, sy - 65/zoom, tocolor(240, 196, 55, 255), 1/zoom, guiInfo.fonts.vehicle, "center", "bottom")
  dxDrawText("Araç almak için #d4af37ENTER#c8c8c8 tuşuna basın, çıkmak için #d4af37BACKSPACE#c8c8c8 tuşuna basın.", 0, sy - 65/zoom, sx, sy - 37/zoom, tocolor(200, 200, 200, 255), 1, guiInfo.fonts.normal, "center", "bottom", false, false, false, true)
end

function getVehicleName(model)
  if model == 471 then return "Kar Motoru" end
  if model == 604 then return "Noel Manana" end
  return getVehicleNameFromModel(model)
end

function click(btn, state)
  if btn == "arrow_r" and state then
    if guiInfo.selected + 1 > #guiInfo.vehicles then return end
    guiInfo.selected = guiInfo.selected + 1
    selectVehicle(guiInfo.selected)

  elseif btn == "arrow_l" and state then
    if guiInfo.selected == 1 then return end
    guiInfo.selected = guiInfo.selected - 1
    selectVehicle(guiInfo.selected)

  elseif btn == "enter" and state then
    for i, v in pairs(getElementsByType("player")) do
      local blockTune = getElementData(v, "blockTune")
      if blockTune then
        if tonumber(blockTune) == guiInfo.vehicles[guiInfo.selected].ID then
          exports.TR_noti:create("Şu anda bu aracı çıkaramazsınız.", "error")
          return
        end
      end
    end

    for i, v in pairs(getElementsByType("vehicle")) do
      local vehData = getElementData(v, "vehicleData")
      if vehData then
        if vehData.ID == guiInfo.vehicles[guiInfo.selected].ID then
          exports.TR_noti:create("Bu araç zaten alındı.", "error")
          return
        end
      end
    end

    triggerServerEvent("spawnGarageVehicle", localPlayer, {id = guiInfo.vehicles[guiInfo.selected].ID, position = guiInfo.spawnPos, garageID = guiInfo.garageNow})
    exports.TR_achievements:addAchievements("vehicleGarage")

  elseif btn == "backspace" and state then
    closeVehicleGarage(true)
    triggerServerEvent("exitGarageWindow", resourceRoot)
  end
end

function selectVehicle(id)
  local data = guiInfo.vehicles[id]
  if not data then return end
  guiInfo.selected = id
  guiInfo.garageID = data.parking

  local color = split(data.color, ",")
  local panelstates = split(data.panelstates, ",")
  local doorstates = split(data.doorstates, ",")

  setElementPosition(guiInfo.vehicle, guiInfo.garageData.vehiclePos[1], guiInfo.garageData.vehiclePos[2], guiInfo.garageData.vehiclePos[3] - 10)

  setElementModel(guiInfo.vehicle, tonumber(data.model))
  setElementHealth(guiInfo.vehicle, tonumber(data.health))
  setVehicleColor(guiInfo.vehicle, color[1], color[2], color[3], color[4], color[5], color[6], color[7], color[8],color[9], color[10], color[11], color[12])
  setVehicleHeadLightColor(guiInfo.vehicle, color[13], color[14], color[15])
  setVehicleOverrideLights(guiInfo.vehicle, 2)

  if data.paintjob then setVehiclePaintjob(guiInfo.vehicle, tonumber(data.paintjob)) else setVehiclePaintjob(guiInfo.vehicle, 3) end

  if data.neon then
    setElementData(guiInfo.vehicle, "vehicle:neon", split(data.neon, ","), false)
  else
    setElementData(guiInfo.vehicle, "vehicle:neon", nil, false)
  end



  setTimer(function()
    if data.tuning then
      for i,v in ipairs(split(data.tuning, ",")) do addVehicleUpgrade(guiInfo.vehicle, v) end
    end
    for i = 0, 6 do
			setVehiclePanelState(guiInfo.vehicle, i, panelstates[i + 1])
		end
		for i = 0, 5 do
			setVehicleDoorState(guiInfo.vehicle, i, doorstates[i + 1])
    end

    setElementPosition(guiInfo.vehicle, guiInfo.garageData.vehiclePos[1], guiInfo.garageData.vehiclePos[2], guiInfo.garageData.vehiclePos[3])
    setElementRotation(guiInfo.vehicle, 0, 0, guiInfo.garageData.vehiclePos[4])
  end, 100, 1)
end


-- Utils
function isMouseInPosition ( x, y, width, height )
	if ( not isCursorsyowing( ) ) then
		return false
	end
  local cx, cy = getCursorPosition ( )
  local cx, cy = ( cx * sx ), ( cy * sy )
  if ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) then
      return true
  else
      return false
  end
end

function setPlayerMove(state)
  toggleControl("forwards", state)
  toggleControl("backwards", state)
  toggleControl("left", state)
  toggleControl("right", state)
  toggleControl("jump", state)
  toggleControl("crouch", state)
  toggleControl("enter_exit", state)
end





local hideData = {}

function garageHideVehicle(garageID, marker)
  local veh = getPedOccupiedVehicle(localPlayer)
  if not veh then return end

  hideData.timer = setTimer(checkHideVelocity, 100, 0)
  hideData.garageID = garageID
  hideData.marker = marker

  exports.TR_noti:create("Araç depoya teslim etmek için belirlenen yere durun.", "info", 5)
  toggleControl("enter_exit", false)
end
addEvent("garageHideVehicle", true)
addEventHandler("garageHideVehicle", root, garageHideVehicle)

function openGarageHideVehicle()
  if hideData.state then return end
  stopCheckingVelocity()

  hideData.state = "opening"
  hideData.alpha = 0
  hideData.tick = getTickCount()

  hideData.font = exports.TR_dx:getFont(14)
  hideData.fontSmall = exports.TR_dx:getFont(13)
  hideData.cancel = exports.TR_dx:createButton((sx - 515/zoom)/2 + 45/zoom, (sy + 200/zoom)/2 - 50/zoom, 200/zoom, 40/zoom, "İptal", "red")
  hideData.accept = exports.TR_dx:createButton((sx + 515/zoom)/2 - 245/zoom, (sy + 200/zoom)/2 - 50/zoom, 200/zoom, 40/zoom, "Araç Teslim Et", "green")
  exports.TR_dx:setButtonVisible({hideData.stopButton, hideData.closeButton}, false)
  exports.TR_dx:showButton({hideData.stopButton, hideData.closeButton})

  showCursor(true)
  addEventHandler("onClientRender", root, renderHidding)
  addEventHandler("guiButtonClick", root, garageHideClick)
end

function closeGarageHideVehicle()
  stopCheckingVelocity()

  hideData.state = "closing"
  hideData.alpha = 1
  hideData.tick = getTickCount()

  toggleControl("enter_exit", true)
  exports.TR_dx:hideButton({hideData.cancel, hideData.accept})
  removeEventHandler("guiButtonClick", root, garageHideClick)
  showCursor(false)
end

function garageHideClick(btn)
  if btn == hideData.cancel then
    closeGarageHideVehicle()

  elseif btn == hideData.accept then
    closeGarageHideVehicle()
    if not getPedOccupiedVehicle(localPlayer) then exports.TR_noti:create("Herhangi bir araçta oturmuyorsun.", "error") return end
    triggerServerEvent("hideGarageVehicle", resourceRoot, hideData.garageID)
  end
end

function animateRenderHidding()
  if not hideData.tick then return end
	local progress = (getTickCount() - hideData.tick)/500

	if hideData.state == "opening" then
		hideData.alpha = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "Linear")
    if progress >= 1 then
      hideData.alpha = 1
      hideData.state = "opened"
		  hideData.tick = nil
    end

  elseif hideData.state == "closing" then
    hideData.alpha = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "Linear")
    if progress >= 1 then
      hideData.alpha = 0
	    hideData.state = "closed"
      hideData.tick = nil

      exports.TR_dx:destroyButton({hideData.stopButton, hideData.closeButton})
      hideData = {}
      removeEventHandler("onClientRender", root, renderHidding)
      return true
    end
  end
end

function renderHidding()
  if animateRenderHidding() then return end
  drawBackground((sx - 515/zoom)/2, (sy - 200/zoom)/2, 515/zoom, 200/zoom, tocolor(17, 17, 17, 255 * hideData.alpha), 5)
  dxDrawText("Araç Saklama Alanı", (sx - 515/zoom)/2, (sy - 200/zoom)/2, (sx + 515/zoom)/2, (sy - 200/zoom)/2 + 50/zoom, tocolor(212, 175, 55, 255 * hideData.alpha), 1/zoom, hideData.font, "center", "center")
  dxDrawText("Araç buradan ücretsiz alınabilir veya başka bir park noktasında küçük bir taşıma ücreti karşılığında alınabilir.", (sx - 515/zoom)/2 + 5/zoom, (sy - 200/zoom)/2 + 35/zoom, (sx + 515/zoom)/2 - 5/zoom, (sy + 200/zoom)/2 - 65/zoom, tocolor(170, 170, 170, 255 * hideData.alpha), 1/zoom, hideData.fontSmall, "center", "center", true, true)
end

function stopCheckingVelocity()
  if isTimer(hideData.timer) then killTimer(hideData.timer) end
end

function checkHideVelocity()
  local veh = getPedOccupiedVehicle(localPlayer)
  if not veh then stopCheckingVelocity(); toggleControl("enter_exit", true) return end
  if not isElementWithinMarker(localPlayer, hideData.marker) then toggleControl("enter_exit", true); stopCheckingVelocity() return end

  if getElementSpeed(veh, "km/h") == 0 then
    openGarageHideVehicle()
    stopCheckingVelocity()
  end
end

-- Utils
function getElementSpeed(theElement, unit)
  assert(isElement(theElement), "getElementSpeed fonksiyonunda 1. argüman hatalı (element bekleniyor, alınan veri türü: " .. type(theElement) .. ")")
  local elementType = getElementType(theElement)
  assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "getElementSpeed fonksiyonunda geçersiz element türü (player/ped/object/vehicle/projectile bekleniyor, alınan veri türü: " .. elementType .. ")")
  assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "getElementSpeed fonksiyonunda 2. argüman hatalı (geçersiz hız birimi)")
  unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
  local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
  return (Vector3(getElementVelocity(theElement)) * mult).length
end

function drawBackground(x, y, rx, ry, color, radius, post)
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

function setVehicleCollidable(veh, state)
  for i, v in pairs(getElementsByType("vehicle")) do
    setElementCollidableWith(veh, v, state and true or false)
  end
end
addEvent("setVehicleCollidable", true)
addEventHandler("setVehicleCollidable", root, setVehicleCollidable)
