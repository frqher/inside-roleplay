local sw,sh = guiGetScreenSize()

local zoom = 1
local baseX = 1900
local minZoom = 2
if sw < baseX then
  zoom = math.min(minZoom, baseX/sw)
end

local guiInfo = {}
guiInfo.modelsID = {
  wall = 1866,
  floor = 1868,
  doors = 1867,
  roof = 1870,
}

guiInfo.shaders = {
  builded = {},
  buildedTextures = {},
}

guiInfo.builderDetails = {
  floorSize = 1.5,
  wallHeight = 3.12,
  roofSize = 3,
}

guiInfo.isObjectIndexable = {
  [2203] = true
}

guiInfo.doorIDs = {
  [1492] = true,
  [1502] = true,
  [1523] = true,
  [1499] = true,
  [1494] = true,
  [1491] = true,
}

function interiorLoadObjects(int, idHome, homeBuilded, posExit, posTP, oryginalWalls, oryginalFloor, gangObjects)
  setElementData(localPlayer, "homeEnterTick", getTickCount(), false)
  setWeather(1)
  int = tonumber(int)

  local intSize = {int^2, int, int/2}

  posExit = split(posExit, ",")
  guiInfo.uidHome = idHome
  guiInfo.markerExitTP = split(posTP, ",")

  guiInfo.posXldefL = posExit[1]
  guiInfo.posYldefL = posExit[2]
  guiInfo.posZldefL = posExit[3]

  guiInfo.posXl = guiInfo.posXldefL
  guiInfo.posYl = guiInfo.posYldefL
  guiInfo.posZl = guiInfo.posZldefL

  guiInfo.rot = 270
  guiInfo.floor = 1

  oryginalFloor = oryginalFloor and fromJSON(oryginalFloor) or {}

  guiInfo.skeleton = {}
  local posNext = Vector3(guiInfo.posXldefL - guiInfo.builderDetails.floorSize*intSize[3], guiInfo.posYldefL - guiInfo.builderDetails.floorSize*intSize[3], guiInfo.posZldefL)
  buildEnterFloor(posNext, posExit[4], posExit[5], oryginalFloor)

  local row = 1
  local obj = 0
  for i=5, intSize[1]+4 do
    if obj == intSize[2] then
      row = row + 1
      obj = 0
    end

    guiInfo.skeleton[i] = createObject(guiInfo.modelsID.floor, posNext.x + guiInfo.builderDetails.floorSize*row, posNext.y + guiInfo.builderDetails.floorSize*obj, guiInfo.posZldefL, 0, 0, 0)
    setElementInterior(guiInfo.skeleton[i], posExit[4])
    setElementDimension(guiInfo.skeleton[i], posExit[5])

    if type(oryginalFloor) == "table" then
      if oryginalFloor[i] then
        changeTexture(guiInfo.skeleton[i], oryginalFloor[i][1], oryginalFloor[i][2])
      end
    end
    obj = obj + 1
  end


  guiInfo.skeletonWalls = {}
  local obj = 2
  local row = 1
   oryginalWalls = oryginalWalls and fromJSON(oryginalWalls) or {}

  for i=1, intSize[2]*4 do
    if obj == intSize[2] then
      row = row + 1
      obj = 0
    end
    local dataWall = loadBuildWallDataLoad(row, obj, intSize[2])

    if not dataWall then break end

    guiInfo.skeletonWalls[i] = createObject(guiInfo.modelsID.wall, posNext.x + dataWall[1], posNext.y + dataWall[2], guiInfo.posZldefL + guiInfo.builderDetails.wallHeight/2, 0, 0, dataWall[3])
    setElementInterior(guiInfo.skeletonWalls[i], posExit[4])
    setElementDimension(guiInfo.skeletonWalls[i], posExit[5])

    -- local farElement = createObject(guiInfo.modelsID.wall, posNext.x + dataWall[1], posNext.y + dataWall[2], guiInfo.posZldefL + guiInfo.builderDetails.wallHeight/2, 0, 0, dataWall[3], true)
    -- setElementInterior(farElement, posExit[4])
    -- setElementDimension(farElement, posExit[5])
    -- setLowLODElement(guiInfo.skeletonWalls[i], farElement)
    -- setElementParent(farElement, guiInfo.skeletonWalls[i])

    obj = obj + 1

    if oryginalWalls[i] then
      changeTexture(guiInfo.skeletonWalls[i], oryginalWalls[i][1], oryginalWalls[i][2])
      -- changeTexture(farElement, oryginalWalls[i][1], oryginalWalls[i][2])
    end
  end

  buildEnterEntrence(posNext.x, posNext.y + guiInfo.builderDetails.floorSize*obj, posExit[4], posExit[5], oryginalWalls)


  guiInfo.defPosForPlayer = {posNext.x - guiInfo.builderDetails.floorSize, posNext.y + guiInfo.builderDetails.floorSize/2, guiInfo.posZldefL + 1}
  triggerServerEvent("setPlayerInteriorPos", resourceRoot, {posNext.x - guiInfo.builderDetails.floorSize, posNext.y + guiInfo.builderDetails.floorSize/2, guiInfo.posZldefL + 1, posExit[4], posExit[5]})
  exports.TR_dx:setResponseEnabled(false)
  exports.TR_weather:setCustomWeather(0, 12, 0, 9999)
  setTimer(function() guiInfo.opened = true end, 5000, 1)

  guiInfo.markerExit = createMarker(posNext.x - guiInfo.builderDetails.floorSize/2, posNext.y + guiInfo.builderDetails.floorSize/2, guiInfo.posZldefL+0.1, "cylinder", 1.2, 2, 220, 220, 0)
  setElementInterior(guiInfo.markerExit, posExit[4])
  setElementDimension(guiInfo.markerExit, posExit[5])
  setElementData(guiInfo.markerExit, "markerIcon", "house-exit", false)

  addEventHandler("onClientMarkerHit", guiInfo.markerExit, enterMarker)
  addEventHandler("onClientMarkerLeave", guiInfo.markerExit, leaveMarker)


  guiInfo.roof = {}
  local posNext = Vector3(guiInfo.posXldefL - guiInfo.builderDetails.floorSize*intSize[3] - guiInfo.builderDetails.floorSize/2, guiInfo.posYldefL - guiInfo.builderDetails.floorSize*intSize[3] + guiInfo.builderDetails.floorSize/2, guiInfo.posZldefL + guiInfo.builderDetails.wallHeight)
  local row = 0
  local obj = 0

  local size = math.ceil(intSize[2]/2) + 1
  for i=1, (size * size) do
    if obj == size then
      row = row + 1
      obj = 0
    end
    guiInfo.roof[i] = createObject(guiInfo.modelsID.roof, posNext.x + guiInfo.builderDetails.roofSize * obj, posNext.y + guiInfo.builderDetails.roofSize * row, posNext.z, 0, 0, 0)
    setElementInterior(guiInfo.roof[i], posExit[4])
    setElementDimension(guiInfo.roof[i], posExit[5])
    obj = obj + 1
  end

  guiInfo.buildedObjects = {}
  if homeBuilded then
    local objectIDs = {}
    local homeObjects = fromJSON(homeBuilded) and fromJSON(homeBuilded) or {}
    for i, v in pairs(homeObjects) do
      local obj = createObject(v[1], v[2], v[3], v[4], v[5], v[6], v[7])
      setElementInterior(obj, posExit[4])
      setElementDimension(obj, posExit[5])

      local model = tonumber(v[1])
      if guiInfo.isObjectIndexable[model] then
        if not objectIDs[model] then objectIDs[model] = 0 end

        objectIDs[model] = objectIDs[model] + 1
        setElementData(obj, "objectIndex", objectIDs[model], false)
        setElementID(obj, "interior_"..model.."_"..objectIDs[model])
      end

      if not guiInfo.doorIDs[model] then
        setElementFrozen(obj, true)
      end

      changeTexture(obj, v[8], v[9])

      table.insert(guiInfo.buildedObjects, obj)
    end
  end

  if gangObjects then
    for i, v in pairs(gangObjects) do
      local obj = getElementByID("interior_2203_"..v.objectIndex)
      if obj then
        setElementData(obj, "drugState", {
          growth = v.growth,
          fertilizer = v.fertilizer,
          plantType = v.plantType,
          tick = getTickCount(),
        }, false)
      end
    end
  end
end
addEvent("interiorLoadObjects", true)
addEventHandler("interiorLoadObjects", root, interiorLoadObjects)


function closeInteriorLoader()
  guiInfo.opened = nil

  if isElement(guiInfo.markerExit) then destroyElement(guiInfo.markerExit) end
  for i, v in pairs(guiInfo.skeletonWalls) do
    if isElement(v) then destroyElement(v) end
  end
  for i, v in pairs(guiInfo.skeleton) do
    if isElement(v) then destroyElement(v) end
  end
  for i, v in pairs(guiInfo.buildedObjects) do
    if isElement(v) then destroyElement(v) end
  end
  if guiInfo.roof then
    for i, v in pairs(guiInfo.roof) do
      if isElement(v) then destroyElement(v) end
    end
  end
  for i, v in pairs(guiInfo.shaders.builded) do
    if isElement(v[1]) then destroyElement(v[1]) end
    if isElement(v[2]) then destroyElement(v[2]) end
  end

  setElementData(localPlayer, "homeEnterTick", nil, false)

  exports.TR_weather:setCustomWeather(false)
end


function enterMarker(hitPlayer)
  if hitPlayer ~= localPlayer then return end
  if not guiInfo.opened then return end
  if not exports.TR_dx:canOpenGUI() then return end
  if isElement(getElementData(localPlayer, "cuffedBy")) then return end
  if guiInfo.bindedKey then return end

  exports.TR_dx:setOpenGUI(true)

  guiInfo.bindedKey = true
  bindKey("e", "down", exit)
  exports.TR_noti:create("Evden çıkmak için E tuşuna basın.", "info")
end

function leaveMarker(hitPlayer)
  if hitPlayer ~= localPlayer then return end
  if not guiInfo.bindedKey then return end

  guiInfo.bindedKey = nil
  unbindKey("e", "down", exit)

  exports.TR_dx:setOpenGUI(false)
end

function exit()
  if not guiInfo.bindedKey then return end
  exports.TR_dx:showLoading(4000, "Dünya yükleniyor")
  exports.TR_dx:setOpenGUI(false)

  guiInfo.bindedKey = nil
  unbindKey("e", "down", exit)

  setElementData(localPlayer, "canUseHouseStash", nil)

  setTimer(closeInteriorLoader, 1200, 1)
  setTimer(triggerServerEvent, 2200, 1, "setPlayerInteriorPos", resourceRoot, guiInfo.markerExitTP, true)
end

function forceQuit()
  exit()
  setTimer(function()
    exports.TR_noti:create("Ev sahibi tarafından evden kovuldun.", "info")
  end, 4000, 1)
end
addEvent("removePlayerFromBuildedInterior", true)
addEventHandler("removePlayerFromBuildedInterior", root, forceQuit)

function quitBuildingWithCuffs()
  exports.TR_dx:showLoading(4000, "Dünya yükleniyor")
  setTimer(closeInteriorLoader, 200, 1)
  setTimer(triggerServerEvent, 1800, 1, "setPlayerInteriorPos", resourceRoot, guiInfo.markerExitTP, true)
end
addEvent("quitBuildingWithCuffs", true)
addEventHandler("quitBuildingWithCuffs", root, quitBuildingWithCuffs)

---- FUNCTIONS ----
function loadBuildWallDataLoad(row, obj, size)
  if row == 1 then
    return {guiInfo.builderDetails.floorSize/2, guiInfo.builderDetails.floorSize * obj, 90}
  elseif row == 2 then
    return {guiInfo.builderDetails.floorSize * (obj+1), guiInfo.builderDetails.floorSize * size - guiInfo.builderDetails.floorSize/2, 0}
  elseif row == 3 then
    return {guiInfo.builderDetails.floorSize * size + guiInfo.builderDetails.floorSize/2, guiInfo.builderDetails.floorSize * (obj), 270}
  elseif row == 4 then
    return {guiInfo.builderDetails.floorSize * (obj+1), -(guiInfo.builderDetails.floorSize/2), 180}
  end
end

function buildEnterFloor(posNext, int, dim, oryginalFloor)
  guiInfo.skeleton[#guiInfo.skeleton + 1] = Object(guiInfo.modelsID.floor, posNext.x, posNext.y + guiInfo.builderDetails.floorSize, guiInfo.posZldefL, 0, 0, 0)
  setElementInterior(guiInfo.skeleton[#guiInfo.skeleton], int)
  setElementDimension(guiInfo.skeleton[#guiInfo.skeleton], dim)

  guiInfo.skeleton[#guiInfo.skeleton + 1] = Object(guiInfo.modelsID.floor, posNext.x, posNext.y, guiInfo.posZldefL, 0, 0, 0)
  setElementInterior(guiInfo.skeleton[#guiInfo.skeleton], int)
  setElementDimension(guiInfo.skeleton[#guiInfo.skeleton], dim)

  guiInfo.skeleton[#guiInfo.skeleton + 1] = Object(guiInfo.modelsID.floor, posNext.x - guiInfo.builderDetails.floorSize, posNext.y, guiInfo.posZldefL, 0, 0, 0)
  setElementInterior(guiInfo.skeleton[#guiInfo.skeleton], int)
  setElementDimension(guiInfo.skeleton[#guiInfo.skeleton], dim)

  guiInfo.skeleton[#guiInfo.skeleton + 1] = Object(guiInfo.modelsID.floor, posNext.x - guiInfo.builderDetails.floorSize, posNext.y + guiInfo.builderDetails.floorSize, guiInfo.posZldefL, 0, 0, 0)
  setElementInterior(guiInfo.skeleton[#guiInfo.skeleton], int)
  setElementDimension(guiInfo.skeleton[#guiInfo.skeleton], dim)

  if type(oryginalFloor) == "table" then
    for i = 1, 4 do
      if oryginalFloor[i] then
        changeTexture(guiInfo.skeleton[i], oryginalFloor[i][1], oryginalFloor[i][2])
      end
    end
  end
end

function buildEnterEntrence(x, y, int, dim, oryginalWalls)
  local start = #guiInfo.skeletonWalls + 1

  guiInfo.skeletonWalls[#guiInfo.skeletonWalls + 1] = Object(guiInfo.modelsID.wall, x, y + guiInfo.builderDetails.floorSize*1.5, guiInfo.posZldefL + guiInfo.builderDetails.wallHeight/2, 0, 0, 0)
  setElementInterior(guiInfo.skeletonWalls[#guiInfo.skeletonWalls], int)
  setElementDimension(guiInfo.skeletonWalls[#guiInfo.skeletonWalls], dim)

  guiInfo.skeletonWalls[#guiInfo.skeletonWalls + 1] = Object(guiInfo.modelsID.wall, x - guiInfo.builderDetails.floorSize, y + guiInfo.builderDetails.floorSize*1.5, guiInfo.posZldefL + guiInfo.builderDetails.wallHeight/2, 0, 0, 0)
  setElementInterior(guiInfo.skeletonWalls[#guiInfo.skeletonWalls], int)
  setElementDimension(guiInfo.skeletonWalls[#guiInfo.skeletonWalls], dim)

  guiInfo.skeletonWalls[#guiInfo.skeletonWalls + 1] = Object(guiInfo.modelsID.wall, x - guiInfo.builderDetails.floorSize*1.5, y, guiInfo.posZldefL + guiInfo.builderDetails.wallHeight/2, 0, 0, 90)
  setElementInterior(guiInfo.skeletonWalls[#guiInfo.skeletonWalls], int)
  setElementDimension(guiInfo.skeletonWalls[#guiInfo.skeletonWalls], dim)

  guiInfo.skeletonWalls[#guiInfo.skeletonWalls + 1] = Object(guiInfo.modelsID.wall, x - guiInfo.builderDetails.floorSize*1.5, y + guiInfo.builderDetails.floorSize, guiInfo.posZldefL + guiInfo.builderDetails.wallHeight/2, 0, 0, 90)
  setElementInterior(guiInfo.skeletonWalls[#guiInfo.skeletonWalls], int)
  setElementDimension(guiInfo.skeletonWalls[#guiInfo.skeletonWalls], dim)

  guiInfo.skeletonWalls[#guiInfo.skeletonWalls + 1] = Object(guiInfo.modelsID.wall, x, y - guiInfo.builderDetails.floorSize/2, guiInfo.posZldefL + guiInfo.builderDetails.wallHeight/2, 0, 0, 180)
  setElementInterior(guiInfo.skeletonWalls[#guiInfo.skeletonWalls], int)
  setElementDimension(guiInfo.skeletonWalls[#guiInfo.skeletonWalls], dim)

  guiInfo.skeletonWalls[#guiInfo.skeletonWalls + 1] = Object(guiInfo.modelsID.wall, x - guiInfo.builderDetails.floorSize, y - guiInfo.builderDetails.floorSize/2, guiInfo.posZldefL + guiInfo.builderDetails.wallHeight/2, 0, 0, 180)
  setElementInterior(guiInfo.skeletonWalls[#guiInfo.skeletonWalls], int)
  setElementDimension(guiInfo.skeletonWalls[#guiInfo.skeletonWalls], dim)

  guiInfo.skeletonWalls[#guiInfo.skeletonWalls + 1] = Object(guiInfo.modelsID.doors, x + guiInfo.builderDetails.floorSize/2, y, guiInfo.posZldefL + guiInfo.builderDetails.wallHeight/2, 0, 0, 90)
  setElementInterior(guiInfo.skeletonWalls[#guiInfo.skeletonWalls], int)
  setElementDimension(guiInfo.skeletonWalls[#guiInfo.skeletonWalls], dim)

  guiInfo.skeletonWalls[#guiInfo.skeletonWalls + 1] = Object(guiInfo.modelsID.doors, x + guiInfo.builderDetails.floorSize/2, y + guiInfo.builderDetails.floorSize, guiInfo.posZldefL + guiInfo.builderDetails.wallHeight/2, 0, 0, 90)
  setElementInterior(guiInfo.skeletonWalls[#guiInfo.skeletonWalls], int)
  setElementDimension(guiInfo.skeletonWalls[#guiInfo.skeletonWalls], dim)

  for k = 0, 7 do
    local i = start + k
    if oryginalWalls[i] then
      changeTexture(guiInfo.skeletonWalls[i], oryginalWalls[i][1], oryginalWalls[i][2])
    end
  end
end