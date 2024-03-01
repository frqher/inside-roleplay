local sw,sh = guiGetScreenSize()

local zoom = 1
local baseX = 1900
local minZoom = 2
if sw < baseX then
  zoom = math.min(minZoom, baseX/sw)
end

local textures = {
  ["walls"] = {"208","209","210","211","212","213","214","215","216","217","218","219","220","221","222","223","224","225","226","227","228","229","230","231","232","233","234","235","236","237","238","239","240","241","242","243","244","245","246","247","248","249","250","251","252","253","254","255","256","257","258","259","260","261","262","263","264","265","266","267","268","269","270","271","272","273","274","275","276","277","278","279","280","281","282","283","284","285","286","287","288","289","290","291","292","293","294","295","296","297","298","299","300","301","302","303","304","305","306","307","308","309","310","311","312","313","314","315","316","317","318","319","320","321","322"},
  ["floor"] = {"1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59","60","61","62","63","64","65","66","67","68","69","70","71","72","73","74","75","76","77","78","79","80","81","82","83","84","85","86","87","88","89","90","91","92","93","94","95","96","97","98","99","100","101","102","103","104","105","106","107","108","109","110","111","112","113","114","115","116","117","118","119","120","121","122","123","125","126","127","128","129","130","131","132","133","134","135","137","138","139","140","141","143","144","145","146","147","148","149","150","151","152","153","154","155","156","157","158","159","160","161","162","163","164","165","166","167","168","169","170","171","172","173","174","175","176","177","178","179","180","181","182","183","184","185","186","187","188","189","190","191","192","193","194","195","196","197","198","199","200","201","202","203","204","205","206","207"},
}

local guiInfo = {
  y = sh - 40/zoom,
  state = "hidden",

  fonts = {
    small = exports.TR_dx:getFont(11),
    normal = exports.TR_dx:getFont(13),
    big = exports.TR_dx:getFont(16),
  },

  shaders = {
    builded = {},
    buildedTextures = {},
  },

  legend = [[#d4af37W,A,S,D #ffffff- kamera / obje kontrolü
  #d4af37Sol Tık #ffffff- obje yerleştirme / seçme
  #d4af37Sağ Tık #ffffff- kamera döndürme
  #d4af37↑,↓  #ffffff- yükseltme / alçaltma
  #d4af37←,→ #ffffff- döndürme
  #d4af37ENTER #ffffff- değişiklikleri onayla
  #d4af37BACKSPACE #ffffff- değişiklikleri iptal et]]
  
}


guiInfo.modelsID = {
  wall = 1866,
  floor = 1868,
  doors = 1867,
  roof = 1870,
}

guiInfo.howManyToShow = math.floor((sw-60)/(140/zoom))
guiInfo.spaceLeft = (sw - (guiInfo.howManyToShow * 140/zoom) + 60/zoom)/2

guiInfo.positionCamera = {
  [1] = 1.2,
  [2] = 6,
  [3] = 9,
}

guiInfo.isObjectIndexable = {
  [2203] = true
}

guiInfo.cameraDetails = {
  depth = 7,
  depth_min = 1,
  depth_max = 10,
  height = 3,
  height_min = 1,
  height_max = 10,

  zoom = 1,
  zoom_min = 0.3,
  zoom_max = 4,
  zoomScale = 0.3,
}

guiInfo.builderDetails = {
  floorSize = 1.5,
  wallHeight = 3.12,
  roofSize = 3,

  maxObjects = 100,
}

guiInfo.furniture = {
  rotation = 1,
  rotations = {
    [1] = {0, 0, guiInfo.builderDetails.floorSize/2},
    [2] = {270, guiInfo.builderDetails.floorSize/2, 0},
    [3] = {180, 0, -guiInfo.builderDetails.floorSize/2},
    [4] = {90, -guiInfo.builderDetails.floorSize/2, 0},
  },

  dorsRotation = {
    [1] = {0, -guiInfo.builderDetails.floorSize/2, guiInfo.builderDetails.floorSize/2},
    [2] = {270, guiInfo.builderDetails.floorSize/2, guiInfo.builderDetails.floorSize/2},
    [3] = {180, guiInfo.builderDetails.floorSize/2, -guiInfo.builderDetails.floorSize/2},
    [4] = {90, -guiInfo.builderDetails.floorSize/2, -guiInfo.builderDetails.floorSize/2},
  },

  dorsModelRotation = {
    [1499] = {
      [1] = {0, -0.0065, -0.01},
      [2] = {270, -0.01, 0.0065},
      [3] = {180, 0.004, 0.008},
      [4] = {90, 0.008, -0.004},
    },
    [1494] = {
      [1] = {0, -0.01, -0.002},
      [2] = {270, -0.003, 0.01},
      [3] = {180, 0, 0},
      [4] = {90, 0.005, -0.01},
    },
    [1492] = {
      [1] = {0, -0.01, 0.001},
      [2] = {270, 0, 0.01},
      [3] = {180, 0.01, 0},
      [4] = {90, 0.005, -0.014},
    },
    [1502] = {
      [1] = {0, -0.0152, -0.024},
      [2] = {270, -0.022, 0.015},
      [3] = {180, 0.015, 0.024},
      [4] = {90, 0.024, -0.017},
    },
    [1491] = {
      [1] = {0, -0.014, -0.01},
      [2] = {270, -0.01, 0.01},
      [3] = {180, 0.01, 0.01},
      [4] = {90, 0.01, -0.014},
    },
    [1523] = {
      [1] = {0, -0.026, -0.036},
      [2] = {270, -0.03, 0.015},
      [3] = {180, 0.016, 0.03},
      [4] = {90, 0.036, -0.024},
    },
  },

  doorIDs = {
    [1492] = true,
    [1502] = true,
    [1523] = true,
    [1499] = true,
    [1494] = true,
    [1491] = true,
  },
}

guiInfo.textures = {}
for i, _ in pairs(textures) do
  for _, v in pairs(textures[i]) do
    table.insert(guiInfo.textures, v)
  end
end

guiInfo.defaultOptions = {
  {1, 0}, -- Wall

  {1499, 130},
  {1494, 170},
  {1492, 190},
  {1502, 200},
  {1491, 230},
  {1523, 250},
}

guiInfo.furnitureCategories = {
  {"Bitkiler", "plant", 1},
  {"Masalar", "desk", 19},
  {"Masa", "table", 43},
  {"Komidinler", "nightTable", 62},
  {"Raflar", "shelf", 78},
  {"Sandalyeler", "furniture", 89},
  {"Kanepeler", "sofa", 105},
  {"Yataklar", "bed", 124},
  {"Elektronik", "tv", 138},
  {"Çeşitli", "trash", 167},
  {"Banyo", "bathroom", 177},
  {"Mutfak", "oven", 187},
  {"Spor Salonu", "sport", 216},
}


guiInfo.furnitureList = {
  -- Plants  (Rośliny)
  {948, 45}, -- 0
  {949, 55},
  {950, 25},
  {2001, 30},
  {2010, 60},
  {2011, 58},
  {2194, 15},
  {2195, 70},
  {2240, 81},
  {2241, 37},
  {2244, 20},
  {2245, 44},
  {2251, 90},
  {2252, 30},
  {2253, 15},
  {2811, 69},
  {2203, 10},
  {false, false},


  -- Desks  (Biurka)
  {1998, 260}, -- 17
  {1999, 200},
  {2008, 240},
  {2009, 250},
  {2165, 170},
  {2166, 130},
  {2171, 100},
  {2172, 280},
  {2173, 125},
  {2174, 230},
  {2180, 80},
  {2181, 265},
  {2182, 230},
  {2183, 350},
  {2184, 90},
  {2185, 120},
  {2193, 300},
  {2198, 220},
  {2205, 380},
  {2206, 320},
  {2308, 150},
  {2605, 160},
  {2607, 110},
  {false, false},


  -- Tables  (Stoły)
  {2637, 150}, -- 41
  {2747, 130},
  {2635, 100},
  {2762, 160},
  {2763, 130},
  {2764, 100},
  {1737, 90},
  {1770, 160},
  {2032, 110},
  {2110, 120},
  {2030, 90},
  {2111, 115},
  {941, 150},
  {937, 140},
  {936, 135},
  {2964, 500},
  {3001, 1500},
  {3002, 1500},
  {false, false},


  -- Cofee Tables  (Stoliki)
  {2024, 180}, -- 58
  {2311, 130},
  {2236, 100},
  {1822, 70},
  {2313, 140},
  {2314, 120},
  {2081, 90},
  {2315, 140},
  {2082, 85},
  {2083, 70},
  {2319, 120},
  {1821, 60},
  {1815, 100},
  {1819, 80},
  {1820, 75},
  {false, false},


  -- Regals  (Regały)
  {2204, 250}, -- 74
  {2200, 230},
  {2167, 170},
  {2163, 220},
  {2164, 240},
  {2162, 210},
  {2161, 190},
  {2191, 245},
  {1742, 200},
  {2063, 290},
  {false, false},


  -- Chairs  (Krzesła)
  {2636, 50}, -- 85
  {2123, 40},
  {1720, 55},
  {2120, 20},
  {2079, 30},
  {2807, 35},
  {2776, 25},
  {2121, 20},
  {1810, 15},
  {1716, 30},
  {2125, 45},
  {2310, 78},
  {1721, 55},
  {1715, 115},
  {1714, 130},
  {false, false},


  -- Couches  (Kanapy)
  {1709, 200}, -- 101
  {1710, 160},
  {1728, 120},
  {1729, 70},
  {1764, 130},
  {1765, 75},
  {1766, 140},
  {1767, 80},
  {1761, 150},
  {1762, 75},
  {1763, 130},
  {1759, 75},
  {1768, 170},
  {1769, 85},
  {1723, 180},
  {1724, 100},
  {1726, 210},
  {1727, 110},
  {false, false},


  -- Beds  (Łóżka)
  {2298, 410}, -- 120
  {1798, 390},
  {2302, 370},
  {2299, 380},
  {1799, 360},
  {2090, 360},
  {1797, 350},
  {1802, 340},
  {2301, 335},
  {1701, 340},
  {1700, 320},
  {1796, 300},
  {1800, 350},
  {false, false},


  -- RTV  (Elektronika)
  {2296, 400}, -- 134
  {2297, 350},
  {2312, 250},
  {2316, 230},
  {2322, 215},
  {2317, 200},
  {2318, 200},
  {2232, 150},
  {2229, 130},
  {2230, 115},
  {2231, 90},
  {2100, 300},
  {2104, 260},
  {2101, 200},
  {2225, 170},
  {2227, 150},
  {2028, 300},
  {2226, 250},
  {2103, 215},
  {2190, 200},
  {2149, 80},
  {1208, 190},
  {2069, 70},
  {2239, 95},
  {2238, 50},
  {2106, 45},
  {2105, 30},
  {2726, 74},
  {false, false},


  -- Other  (Różne)
  {2853, 10}, -- 164
  {2855, 15},
  {1430, 20},
  {1337, 30},
  {2690, 15},
  {2406, 40},
  {2405, 35},
  {2404, 48},
  {2332, 1800},
  {false, false},


  -- Bathroom  (Łazienka)
  {2522, 400}, -- 174
  {2517, 370},
  {2527, 300},
  {2526, 310},
  {2516, 340},
  {2528, 260},
  {2525, 230},
  {2523, 120},
  {2524, 100},
  {false, false},


  -- Kitchen  (Kuchnia)
  {14535, 2000}, -- 184
  {15036, 1300},
  {2127, 700},
  {2128, 400},
  {2130, 350},
  {2294, 400},
  {2129, 250},
  {2304, 270},
  {2131, 650},
  {2141, 350},
  {2132, 350},
  {2339, 220},
  {2133, 250},
  {2341, 215},
  {2140, 350},
  {2135, 300},
  {2136, 300},
  {2303, 250},
  {2138, 220},
  {2305, 200},
  {2139, 190},
  {2158, 250},
  {2336, 220},
  {2337, 240},
  {2157, 170},
  {2334, 130},
  {2335, 120},
  {2338, 115},
  {false, false},


  -- Gym  (Siłownia)
  {2628, 600}, -- 213
  {2629, 550},
  {2630, 390},
  {1985, 300},
  {2631, 95},
  {2632, 95},
}

-- if getPlayerName(localPlayer) == "Xantris" then
--   setCameraTarget(localPlayer)
--   setElementPosition(localPlayer, 2192.5544433594, -1470.421875, 25.769720077515)
--   setElementDimension(localPlayer, 0)
--   setElementInterior(localPlayer, 0)

--   exports.TR_dx:setOpenGUI(false)
--   exports.TR_dx:setResponseEnabled(false)

-- elseif getPlayerName(localPlayer) == "Wilku" then
--   setCameraTarget(localPlayer)
--   setElementPosition(localPlayer, 2192.5544433594, -1474.421875, 25.769720077515)
--   setElementDimension(localPlayer, 0)
--   setElementInterior(localPlayer, 0)

--   exports.TR_dx:setOpenGUI(false)
--   exports.TR_dx:setResponseEnabled(false)
-- end

guiInfo.renderGuiList = {}

function render()
  moveCamera()
  animateBuilderItems()
  gui()

  if guiInfo.selectedGuiList == "default" then
    local k = 0
    for i=0, (guiInfo.interiorSize[2]*2+1) do
      local pos = guiInfo.meshPosition
      if i >= guiInfo.interiorSize[2]+1 then
        dxDrawLine3D(pos[1] + guiInfo.builderDetails.floorSize*0.5, pos[2] - guiInfo.builderDetails.floorSize*0.5 + guiInfo.builderDetails.floorSize*k, pos[3], pos[1]+(guiInfo.interiorSize[2]+0.5)*guiInfo.builderDetails.floorSize, pos[2] - guiInfo.builderDetails.floorSize*0.5 + guiInfo.builderDetails.floorSize*k, pos[3], tocolor(20, 255, 20, 255), 2)
        k = k + 1

      else
        dxDrawLine3D(pos[1] + guiInfo.builderDetails.floorSize/2 + guiInfo.builderDetails.floorSize*i, pos[2] - guiInfo.builderDetails.floorSize/2, pos[3], pos[1] + guiInfo.builderDetails.floorSize/2 + guiInfo.builderDetails.floorSize*i, pos[2]+(guiInfo.interiorSize[2]-0.5)*guiInfo.builderDetails.floorSize, pos[3], tocolor(20, 255, 20, 255), 2)
      end
    end
  end

  if guiInfo.testingByPlayer then return end

  if guiInfo.mouse then
    local screenX,screenY,_,_,_ = getCursorPosition()
    if type(screenX) == "number" then
      local rotAdd = (screenX - guiInfo.screenX)*360
      guiInfo.rot = guiInfo.rot + rotAdd
      guiInfo.screenX = screenX
    end

    if type(screenY) == "number" then
      local zAdd = (screenY - guiInfo.screenY)*20
      guiInfo.cameraDetails.height = math.max(math.min(guiInfo.cameraDetails.height + zAdd, guiInfo.cameraDetails.height_max), guiInfo.cameraDetails.height_min)
      guiInfo.cameraDetails.depth = math.max(math.min(guiInfo.cameraDetails.depth - zAdd, guiInfo.cameraDetails.depth_max), guiInfo.cameraDetails.depth_min)
      guiInfo.screenY = screenY
    end
  end

  if guiInfo.editingElement and isElement(guiInfo.editingElement) then
    moveFurniture()

    if guiInfo.editingElementCanChangePos then drawPositionLines(guiInfo.editingElement) end

    local objPos = Vector3(guiInfo.editingElement:getPosition())
    local x, y = getPointFromDistanceRotation(objPos.x, objPos.y, guiInfo.cameraDetails.depth/3, guiInfo.rot)

    -- Camera.setMatrix(x, y, objPos.z+guiInfo.cameraDetails.height/3, objPos.x, objPos.y, objPos.z+0.5)

    local x, y = getPointFromDistanceRotation(guiInfo.posX, guiInfo.posY, guiInfo.cameraDetails.depth * guiInfo.cameraDetails.zoom, guiInfo.rot)
    Camera.setMatrix(x, y, guiInfo.posZ+guiInfo.positionCamera[guiInfo.floor] + guiInfo.cameraDetails.height * guiInfo.cameraDetails.zoom, guiInfo.posX, guiInfo.posY, guiInfo.posZ+guiInfo.positionCamera[guiInfo.floor])
    return
  end


  local x, y = getPointFromDistanceRotation(guiInfo.posX, guiInfo.posY, guiInfo.cameraDetails.depth * guiInfo.cameraDetails.zoom, guiInfo.rot)
  Camera.setMatrix(x, y, guiInfo.posZ+guiInfo.positionCamera[guiInfo.floor] + guiInfo.cameraDetails.height * guiInfo.cameraDetails.zoom, guiInfo.posX, guiInfo.posY, guiInfo.posZ+guiInfo.positionCamera[guiInfo.floor])

  if guiInfo.buildingWall and isElement(guiInfo.buildingWall) then
    local screenx, screeny, worldx, worldy, worldz = getCursorPosition()
    local px, py, pz = getCameraMatrix()
    local hit, x, y, z, elementHit = processLineOfSight(px, py, pz, worldx, worldy, worldz, true, false, false, true, true, false, false, false, guiInfo.buildingWall)
    if hit and isElement(elementHit) and elementHit:getData("builder:type") == "floor" then
      local posHit = Vector3(elementHit:getPosition())

      local wallRotation = getWallRotation(posHit, x, y)
      if not wallRotation then setElementPosition(guiInfo.buildingWall, guiInfo.posXdef, guiInfo.posYdef, guiInfo.posZdef + 200) return end
      local rot = guiInfo.furniture.rotations[wallRotation]
      guiInfo.buildingWall:setPosition(posHit.x + rot[2], posHit.y + rot[3], posHit.z + guiInfo.builderDetails.wallHeight/2)
      guiInfo.buildingWall:setRotation(0, 0, rot[1])
    end

    for i, v in pairs(guiInfo.buildedObjects) do
      if guiInfo.furniture.doorIDs[getElementModel(v)] then
        drawDoorsPositionNeeded(v)
      end
    end

  elseif guiInfo.buildingFurniture and isElement(guiInfo.buildingFurniture) then
    local screenx, screeny, worldx, worldy, worldz = getCursorPosition()
    local px, py, pz = getCameraMatrix()
    local hit, x, y, z, elementHit = processLineOfSight(px, py, pz, worldx, worldy, worldz, true, false, false, true, true, false, false, false, guiInfo.buildingFurniture)
    if hit and isElement(elementHit) then --and elementHit:getData("builder:type") == "floor" then
      if getKeyState("arrow_u") then guiInfo.buildingObjectZ = guiInfo.buildingObjectZ+0.005 end
      if getKeyState("arrow_d") then guiInfo.buildingObjectZ = guiInfo.buildingObjectZ-0.005 end

      if getKeyState("arrow_l") then guiInfo.rotFurniture = guiInfo.rotFurniture+0.3 end
      if getKeyState("arrow_r") then guiInfo.rotFurniture = guiInfo.rotFurniture-0.3 end


      -- Stawianie drzwi
      local model = getElementModel(guiInfo.buildingFurniture)
      if guiInfo.furniture.doorIDs[model] and not guiInfo.responseEnabled then
        if getElementModel(elementHit) == guiInfo.modelsID.floor then
          local posHit = Vector3(elementHit:getPosition())

          local wallRotation = getWallRotation(posHit, x, y)
          if not wallRotation then setElementPosition(guiInfo.buildingFurniture, guiInfo.posXdef, guiInfo.posYdef, guiInfo.posZdef + 200) return end

          local fixer = guiInfo.furniture.dorsModelRotation[model][wallRotation]
          local rot = guiInfo.furniture.dorsRotation[wallRotation]

          guiInfo.buildingFurniture:setPosition(posHit.x + rot[2] + fixer[2], posHit.y + rot[3] + fixer[3], posHit.z)
          guiInfo.buildingFurniture:setRotation(0, 0, rot[1])

          drawDoorsPositionNeeded(guiInfo.buildingFurniture)
        end


      elseif not guiInfo.responseEnabled then
        drawPositionLines(guiInfo.buildingFurniture)

        guiInfo.buildingFurniture:setPosition(x, y, z+guiInfo.buildingObjectZ)
        guiInfo.buildingFurniture:setRotation(0, 0, guiInfo.rotFurniture)

      elseif guiInfo.responseEnabled then
        setElementPosition(guiInfo.buildingFurniture, guiInfo.posXdef, guiInfo.posYdef, guiInfo.posZdef + 200)
      end

    else
      setElementPosition(guiInfo.buildingFurniture, guiInfo.posXdef, guiInfo.posYdef, guiInfo.posZdef + 200)
    end

    if guiInfo.furniture.doorIDs[getElementModel(guiInfo.buildingFurniture)] then
      for i, v in pairs(guiInfo.buildedObjects) do
        if guiInfo.furniture.doorIDs[getElementModel(v)] then
          drawDoorsPositionNeeded(v)
        end
      end
    end
  end
end

function clearBuildingObjects()
  if isElement(guiInfo.buildingWall) then
    destroyElement(guiInfo.buildingWall)
    guiInfo.buildingWall = nil
  end

  if isElement(guiInfo.buildingFurniture) then
    destroyElement(guiInfo.buildingFurniture)
    guiInfo.buildingFurniture = nil
  end

  guiInfo.buildingIndex = nil
  return true
end

function clearPainting()
  if isElement(guiInfo.editingElement) then
    guiInfo.editingElement = nil
    guiInfo.editingElementPositionDefault = nil
    guiInfo.editingElementRotationDefault = nil
    guiInfo.editingElementCanChangePos = nil

    removeWallEffects()
  end
end

function quitButtonsClick(btn)
  if btn == guiInfo.quitCancle then
    guiInfo.confirmInteriorQuit = nil
    removeEventHandler("guiButtonClick", root, quitButtonsClick)
    exports.TR_dx:setButtonVisible({guiInfo.quitCancle, guiInfo.quitAccept}, false)

  elseif btn == guiInfo.quitAccept then
    closeInteriorBuilder()
    removeEventHandler("guiButtonClick", root, quitButtonsClick)
  end
  guiInfo.blockEditor = nil
end

function click(btn, state)
  if guiInfo.responseEnabled then return end
  if guiInfo.blockEditor then return end

  if btn == "left" and state == "down" then
    local y = sh - 40/zoom - #guiInfo.furnitureCategories * 30/zoom

    if isMouseInPosition(15/zoom, sh-36/zoom, 100/zoom, 32/zoom) then
      clearBuildingObjects()
      clearPainting()
      guiInfo.confirmInteriorQuit = true
      guiInfo.blockEditor = true
      addEventHandler("guiButtonClick", root, quitButtonsClick)
      exports.TR_dx:setButtonVisible({guiInfo.quitCancle, guiInfo.quitAccept}, true)
      return

    elseif isMouseInPosition(150/zoom, sh-36/zoom, 85/zoom, 32/zoom) then
      clearBuildingObjects()
      clearPainting()
      saveBuildInterior()
      return

    elseif isMouseInPosition(270/zoom, sh-36/zoom, 115/zoom, 32/zoom) then
      clearPainting()
      setPlayerTestingInterior()
      return

    elseif isMouseInPosition(415/zoom, sh-36/zoom, 150/zoom, 32/zoom) then
      clearBuildingObjects()

      if guiInfo.selectedGuiList == "default" then
        guiInfo.selectedGuiList = nil
        animateGui(false)
        return
      end
      guiInfo.selectedGuiList = "default"
      guiInfo.menuScroll = 1
      animateGui(true, guiInfo.defaultOptions)
      return

    elseif isMouseInPosition(595/zoom, sh-36/zoom, 150/zoom, 32/zoom) then
      -- guiInfo.selectMenuOpen = not guiInfo.selectMenuOpen
      clearBuildingObjects()

      if guiInfo.selectedGuiList == "building" then
        guiInfo.selectedGuiList = nil
        animateGui(false)
        return
      end
      guiInfo.selectedGuiList = "building"
      guiInfo.menuScroll = 1
      animateGui(true, guiInfo.furnitureList)
      return

    elseif isMouseInPosition(760/zoom, sh-36/zoom, 165/zoom, 32/zoom) then
      clearBuildingObjects()

      if guiInfo.selectedGuiList == "textures" then
        guiInfo.selectedGuiList = nil
        animateGui(false)
        return
      end
      guiInfo.selectedGuiList = "textures"
      guiInfo.menuScroll = 1
      animateGui(true, guiInfo.textures)

    elseif isMouseInPosition(595/zoom, y, 150/zoom, #guiInfo.furnitureCategories * 30/zoom) and guiInfo.furnitureCategoriesOpen then
      for i, v in pairs(guiInfo.furnitureCategories) do
        if isMouseInPosition(595/zoom, y + (i-1) * 30/zoom, 150/zoom, 30/zoom) and v[3] then
          guiInfo.menuScroll = math.min(v[3], #guiInfo.furnitureList - guiInfo.howManyToShow + 1)
          guiInfo.furnitureCategoriesOpen = nil
          return
        end
      end

    elseif isMouseInPosition(10/zoom, guiInfo.y + 35/zoom, 40/zoom, 40/zoom) and guiInfo.selectedGuiList then
      if guiInfo.menuScroll <= 1 then return end
      guiInfo.menuScroll = guiInfo.menuScroll - 1
      return

    elseif isMouseInPosition(sw - 50/zoom, guiInfo.y + 35/zoom, 40/zoom, 40/zoom) and guiInfo.selectedGuiList then
      if (guiInfo.menuScroll + guiInfo.howManyToShow) > #guiInfo.renderGuiList then return end
      guiInfo.menuScroll = guiInfo.menuScroll + 1
      return

    elseif isMouseInPosition(0, sh-170/zoom, sw, 170/zoom) then
      if guiInfo.selectedGuiList == "textures" and type(guiInfo.renderGuiList[1]) ~= "table" then
        for i = 0, (guiInfo.howManyToShow - 1) do
          local index = guiInfo.menuScroll + i
          if guiInfo.renderGuiList[index] then
            if isMouseInPosition(guiInfo.spaceLeft + 140/zoom*(i), guiInfo.y + 5/zoom, 80/zoom, 100/zoom) then
              if guiInfo.buildingIndex == index then
                guiInfo.buildingIndex = nil
              else
                guiInfo.buildingIndex = index
              end
              break
            end
          end
        end

      else
        for i = 0, (guiInfo.howManyToShow - 1) do
          local index = guiInfo.menuScroll + i
          if guiInfo.renderGuiList[index] then
            if guiInfo.renderGuiList[index][1] then
              if isMouseInPosition(guiInfo.spaceLeft + 140/zoom*(i), guiInfo.y + 5/zoom, 80/zoom, 100/zoom) then
                  useOptionForBuilder(guiInfo.renderGuiList[index][1], guiInfo.renderGuiList[index][2], index)
                  guiInfo.buildingData = guiInfo.renderGuiList[index]
                break
              end
            end
          end
        end
      end

    elseif guiInfo.buildingWall and isElement(guiInfo.buildingWall) then
      if #guiInfo.buildedObjects >= guiInfo.builderDetails.maxObjects then
        exports.TR_noti:create("İnşaat limitine ulaşıldı. Daha fazla obje yerleştiremezsin.", "error")
        return
      end
      
      local screenx, screeny, worldx, worldy, worldz = getCursorPosition()
      local px, py, pz = getCameraMatrix()
      local hit, x, y, z, elementHit = processLineOfSight(px, py, pz, worldx, worldy, worldz, true, false, false, true, true, false, false, false, guiInfo.buildingWall)
      
      if hit then
        if elementHit:getData("builder:type") == "floor" then
          guiInfo.responseEnabled = true
      
          local canPlace = canPlaceWallObject(guiInfo.buildingWall, elementHit, x, y)
          if not canPlace then
            guiInfo.responseEnabled = nil
            return
          end
      
          exports.TR_dx:setResponseEnabled(true, "Obje yerleştiriliyor...")
      
          local posHit = Vector3(elementHit:getPosition())
          local wallRotation = getWallRotation(posHit, x, y)
          local rot = guiInfo.furniture.rotations[wallRotation]
      
          local wall = createObject(getElementModel(guiInfo.buildingWall), posHit.x + rot[2], posHit.y + rot[3], posHit.z + guiInfo.builderDetails.wallHeight/2)
          setElementRotation(wall, 0, 0, rot[1])
          setElementInterior(wall, 99)
          table.insert(guiInfo.buildedObjects, wall)
      
          setElementData(wall, "builder:price", guiInfo.buildingData[2], false)
          guiInfo.toPay = guiInfo.toPay + guiInfo.buildingData[2]
      
          setTimer(function()
            exports.TR_dx:setResponseEnabled(false)
            guiInfo.responseEnabled = nil
          end, 200, 1)
        end
      end
      


    elseif guiInfo.buildingFurniture and isElement(guiInfo.buildingFurniture) then
      local screenx, screeny, worldx, worldy, worldz = getCursorPosition()
      local px, py, pz = getCameraMatrix()
      local hit, x, y, z, elementHit = processLineOfSight(px, py, pz, worldx, worldy, worldz, true, false, false, true, true, false, false, false, guiInfo.buildingFurniture)
      if not hit or not isElement(elementHit) then return end
      local model = getElementModel(guiInfo.buildingFurniture)

      if guiInfo.furniture.doorIDs[model] then
        if #guiInfo.buildedObjects >= guiInfo.builderDetails.maxObjects then
          exports.TR_noti:create("İnşaat limitine ulaşıldı. Daha fazla obje yerleştiremezsin.", "error")
          return
        end
      
        if #guiInfo.buildedObjects + 3 >= guiInfo.builderDetails.maxObjects then
          exports.TR_noti:create("İnşaat limiti aşılacak. Kapılar 3 obje kaplar ve limiti aşarlar.", "error")
          return
        end
      
        if getElementModel(elementHit) ~= guiInfo.modelsID.floor then
          return
        end
      
        local posHit = Vector3(elementHit:getPosition())
        local wallRotation = getWallRotation(posHit, x, y)
        local fixer = guiInfo.furniture.dorsModelRotation[model][wallRotation]
        local rot = guiInfo.furniture.dorsRotation[wallRotation]
      
        local posObj = Vector3(posHit.x + rot[2] + fixer[2], posHit.y + rot[3] + fixer[3], posHit.z)
      
        local canPlace = canPlaceDoorObject(posObj, posHit, x, y)
        if not canPlace then
          guiInfo.responseEnabled = nil
          return
        end
      
        guiInfo.responseEnabled = true
        exports.TR_dx:setResponseEnabled(true, "Obje yerleştiriliyor")
      
        local furniture = Object(model, posObj.x, posObj.y, posObj.z)
        furniture:setRotation(0, 0, rot[1])
        furniture:setInterior(99)
        furniture:setCollisionsEnabled(true)
        table.insert(guiInfo.buildedObjects, furniture)
      
        setElementData(furniture, "builder:price", guiInfo.buildingData[2], false)
        guiInfo.toPay = guiInfo.toPay + guiInfo.buildingData[2]
      
        createDoorsWall(posHit, x, y)
      
        setTimer(function()
          exports.TR_dx:setResponseEnabled(false)
          guiInfo.responseEnabled = nil
          clearBuildingObjects()
        end, 1000, 1)
      
      else
        if #guiInfo.buildedObjects >= guiInfo.builderDetails.maxObjects then
          exports.TR_noti:create("İnşaat limitine ulaşıldı. Daha fazla obje yerleştiremezsin.", "error")
          return
        end
      
        exports.TR_dx:setResponseEnabled(true, "Obje yerleştiriliyor")
        guiInfo.responseEnabled = true
      
        local posObj = Vector3(guiInfo.buildingFurniture:getPosition())
        local posRot = Vector3(guiInfo.buildingFurniture:getRotation())
      
        local furniture = Object(model, posObj.x, posObj.y, posObj.z)
        furniture:setRotation(0, 0, posRot.z)
        furniture:setInterior(99)
        furniture:setCollisionsEnabled(true)
        table.insert(guiInfo.buildedObjects, furniture)
      
        setElementData(furniture, "builder:price", guiInfo.buildingData[2], false)
        guiInfo.toPay = guiInfo.toPay + guiInfo.buildingData[2]
      
        setTimer(function()
          exports.TR_dx:setResponseEnabled(false)
          guiInfo.responseEnabled = nil
          clearBuildingObjects()
        end, 200, 1)
      end
      

    elseif not guiInfo.buildingFurniture and not isElement(guiInfo.buildingFurniture) and not guiInfo.buildingWall and not isElement(guiInfo.buildingWall) then
      if guiInfo.buildingIndex and guiInfo.selectedGuiList == "textures" then
        local screenx, screeny, worldx, worldy, worldz = getCursorPosition()
        local px, py, pz = getCameraMatrix()
        local hit, x, y, z, elementHit = processLineOfSight(px, py, pz, worldx, worldy, worldz, true, false, false, true, true, false, false, false)
        if hit then
          for i, v in pairs(guiInfo.buildedObjects) do
            if v == elementHit then
              local modelID = elementHit:getModel()
              if modelID == guiInfo.modelsID.wall or modelID == guiInfo.modelsID.doors then
                local index = getWallTextureIndex(v)
                local textureData = elementHit:getData("builder:textures")
                local text = textureData and textureData or {"", ""}
                text[index] = guiInfo.renderGuiList[guiInfo.buildingIndex]
                changeTexture(elementHit, text[1], text[2])
                setElementData(elementHit, "builder:textures", text, false)
              end
              return
            end
          end

          -- Walls texturing
          for i, v in pairs(guiInfo.skeletonWalls) do
            if v == elementHit then
              local modelID = elementHit:getModel()
              if modelID == guiInfo.modelsID.doors then -- Above doors
                local index = getWallTextureIndex(v)
                local textureData = elementHit:getData("builder:textures")
                local text = textureData and textureData or {"", ""}
                text[index] = guiInfo.renderGuiList[guiInfo.buildingIndex]
                changeTexture(elementHit, text[1], text[2])
                setElementData(elementHit, "builder:textures", text, false)

              else -- Normal walls
                local textureData = elementHit:getData("builder:textures")
                local text = textureData and textureData or {"", ""}
                text[1] = guiInfo.renderGuiList[guiInfo.buildingIndex]
                changeTexture(elementHit, text[1], text[2])
                setElementData(elementHit, "builder:textures", text, false)
              end
              return
            end
          end

          -- Floor texturing
          for i, v in pairs(guiInfo.skeleton) do
            if v == elementHit then
              local textureData = elementHit:getData("builder:textures")
              local text = textureData and textureData or {"", ""}
              text[1] = guiInfo.renderGuiList[guiInfo.buildingIndex]
              changeTexture(elementHit, text[1], text[2])
              setElementData(elementHit, "builder:textures", text, false)
              return
            end
          end
        end

      elseif guiInfo.selectedGuiList == "building" then
        local screenx, screeny, worldx, worldy, worldz = getCursorPosition()
        local px, py, pz = getCameraMatrix()
        local hit, x, y, z, elementHit = processLineOfSight(px, py, pz, worldx, worldy, worldz, true, false, false, true, true, false, false, false)
        if hit then
          for i, v in pairs(guiInfo.buildedObjects) do
            if v == elementHit then
              guiInfo.editingElement = elementHit
              guiInfo.editingElementPositionDefault = Vector3(elementHit:getPosition())
              guiInfo.editingElementRotationDefault = Vector3(elementHit:getRotation())

              local modelID = elementHit:getModel()
              if modelID == guiInfo.modelsID.wall or modelID == guiInfo.modelsID.floor or modelID == guiInfo.modelsID.doors or guiInfo.furniture.doorIDs[modelID] then
                guiInfo.editingElement = nil
                guiInfo.editingElementPositionDefault = nil
                guiInfo.editingElementRotationDefault = nil
                removeWallEffects()
                return

              else
                guiInfo.editingElementCanChangePos = true

                local index = getElementData(elementHit, "objectIndex")
                if index then
                  if index <= guiInfo.gangDrugsBlock then
                    guiInfo.editingElement = nil
                    guiInfo.editingElementPositionDefault = nil
                    guiInfo.editingElementRotationDefault = nil

                    removeWallEffects()
                    exports.TR_noti:create("Nie możesz edytować tego obiektu.", "error")
                    return
                  end
                end

                removeWallEffects()
                createWallEffectForObject(elementHit, {0.94, 0.76, 0.21, 1})
              end

              break
            end
          end
        end

      elseif guiInfo.selectedGuiList == "default" then
        local screenx, screeny, worldx, worldy, worldz = getCursorPosition()
        local px, py, pz = getCameraMatrix()
        local hit, x, y, z, elementHit = processLineOfSight(px, py, pz, worldx, worldy, worldz, true, false, false, true, true, false, false, false)
        if hit then
          for i, v in pairs(guiInfo.buildedObjects) do
            if v == elementHit then
              guiInfo.editingElement = elementHit
              guiInfo.editingElementCanChangePos = false
              guiInfo.editingElementPositionDefault = nil
              guiInfo.editingElementRotationDefault = nil

              local modelID = elementHit:getModel()
              if modelID == guiInfo.modelsID.wall or modelID == guiInfo.modelsID.floor then
                removeWallEffects()
                createWallEffectForObject(elementHit, {0.94, 0.76, 0.21, 1})

              elseif guiInfo.furniture.doorIDs[modelID] then
                removeWallEffects()
                createWallEffectForObject(elementHit, {0.94, 0.76, 0.21, 1})

                local doorPos = getDoorCenterPosition(elementHit)
                for k, vv in pairs(guiInfo.buildedObjects) do
                  local model = getElementModel(vv)
                  if vv ~= v and model == guiInfo.modelsID.doors then
                    local elPos = Vector3(getElementPosition(vv))

                    if getDistanceBetweenPoints3D(doorPos.x, doorPos.y, doorPos.z, elPos) < 0.5 then
                      createWallEffectForObject(vv, {0.94, 0.76, 0.21, 1})
                    end
                  end
                end
              else
                removeWallEffects()
                guiInfo.editingElement = nil
                return
              end

              break
            end
          end
        end
      end
    end
  end
end

function key(btn, state)
  if guiInfo.blockEditor then return end
  if btn == "mouse2" then
    if state then
      guiInfo.mouse = true
      screenX,screenY,_,_,_ = getCursorPosition()
      guiInfo.screenX = screenX
      guiInfo.screenY = screenY
    else
      guiInfo.mouse = nil
      screenX,screenY,_,_,_ = getCursorPosition()
      guiInfo.screenX = screenX
      guiInfo.screenY = screenY
    end

  elseif btn == "mouse_wheel_up" then
    if state then
      if isMouseInPosition(0, sh-130/zoom, sw, 130/zoom) then
        if (guiInfo.menuScroll + guiInfo.howManyToShow) > #guiInfo.renderGuiList then return end
        guiInfo.menuScroll = guiInfo.menuScroll + 1

      else
        guiInfo.cameraDetails.zoom = math.max(math.min(guiInfo.cameraDetails.zoom - guiInfo.cameraDetails.zoomScale, guiInfo.cameraDetails.zoom_max), guiInfo.cameraDetails.zoom_min)
      end
    end
  elseif btn == "mouse_wheel_down" then
    if state then
      if isMouseInPosition(0, sh-130/zoom, sw, 130/zoom) then
        if guiInfo.menuScroll <= 1 then return end
        guiInfo.menuScroll = guiInfo.menuScroll - 1

      else
        guiInfo.cameraDetails.zoom = math.max(math.min(guiInfo.cameraDetails.zoom + guiInfo.cameraDetails.zoomScale, guiInfo.cameraDetails.zoom_max), guiInfo.cameraDetails.zoom_min)
      end
    end

  elseif btn == "enter" then
    if guiInfo.testingByPlayer then
      setPlayerTestingInterior()

    elseif guiInfo.editingElement then
      guiInfo.editingElement = nil
      guiInfo.editingElementPositionDefault = nil
      guiInfo.editingElementRotationDefault = nil
      guiInfo.editingElementCanChangePos = nil

      removeWallEffects()
    end

  elseif btn == "delete" and state and isElement(guiInfo.editingElement) then
    removeWallEffects()

    local price = guiInfo.editingElement:getData("builder:price")
    if price then
      guiInfo.toPay = guiInfo.toPay - price
    end

    local posB = Vector3(guiInfo.editingElement:getPosition())
    local model = getElementModel(guiInfo.editingElement)
    local isElement = false

    if guiInfo.furniture.doorIDs[model] then
      local doorPos = getDoorCenterPosition(guiInfo.editingElement)

      local remove = {}
      for k, vv in pairs(guiInfo.buildedObjects) do
        local model = getElementModel(vv)
        if vv ~= guiInfo.editingElement and model == guiInfo.modelsID.doors then
          local elPos = Vector3(getElementPosition(vv))

          if getDistanceBetweenPoints3D(doorPos.x, doorPos.y, doorPos.z, elPos) < 0.5 then
            guiInfo.buildedObjects[k]:destroy()
            table.remove(guiInfo.buildedObjects, k)
          end
        end
      end
    end

    for i, v in pairs(guiInfo.buildedObjects) do
      local pos = Vector3(v:getPosition())
      if pos.x == posB.x and pos.y == posB.y and pos.z == posB.z then
        isElement = i
        break
      end
    end
    if not isElement then return end
    guiInfo.buildedObjects[isElement]:destroy()
    table.remove(guiInfo.buildedObjects, isElement)

    if guiInfo.furniture.doorIDs[model] then

    end

  elseif btn == "backspace" then
    if isElement(guiInfo.editingElement) then
      if guiInfo.editingElementPositionDefault then
        local posDef = guiInfo.editingElementPositionDefault
        local rotDef = guiInfo.editingElementRotationDefault
        guiInfo.editingElement:setPosition(posDef.x, posDef.y, posDef.z)
        guiInfo.editingElement:setRotation(rotDef.x, rotDef.y, rotDef.z)
      end

      guiInfo.editingElement = nil
      guiInfo.editingElementPositionDefault = nil
      guiInfo.editingElementRotationDefault = nil
      guiInfo.editingElementCanChangePos = nil
      removeWallEffects()
    end
  end
end

function animateGui(state, nextTable)
  if state then
    if guiInfo.state == "hidden" then
      guiInfo.renderGuiList = nextTable
      guiInfo.state = "showing"
      guiInfo.lastY = guiInfo.y
      guiInfo.animTick = getTickCount()

    else
      if guiInfo.state ~= "hidding" then
        guiInfo.state = "hidding"
        guiInfo.lastY = guiInfo.y
        guiInfo.animTick = getTickCount()
      end
      guiInfo.nextTable = nextTable
    end

  else
    if guiInfo.state == "showed" or guiInfo.state == "showing" then
      guiInfo.lastY = guiInfo.y
      guiInfo.state = "hidding"
      guiInfo.animTick = getTickCount()
      guiInfo.nextTable = nil
    end
  end

  if isElement(guiInfo.editingElement) then
    if guiInfo.editingElementPositionDefault then
      local posDef = guiInfo.editingElementPositionDefault
      local rotDef = guiInfo.editingElementRotationDefault
      guiInfo.editingElement:setPosition(posDef.x, posDef.y, posDef.z)
      guiInfo.editingElement:setRotation(rotDef.x, rotDef.y, rotDef.z)

      exports.TR_noti:create("Düzenlenen obje önceki durumuna geri getirildi.", "info")

    end

    guiInfo.editingElement = nil
    guiInfo.editingElementPositionDefault = nil
    guiInfo.editingElementRotationDefault = nil
    guiInfo.editingElementCanChangePos = nil
    removeWallEffects()
  end
end

function animateBuilderItems()
  if guiInfo.state == "showing" then
    local progress = (getTickCount() - guiInfo.animTick)/300
    guiInfo.y = interpolateBetween(guiInfo.lastY, 0, 0, sh-150/zoom, 0, 0, progress, "Linear")

    if progress >= 1 then
      guiInfo.y = sh-150/zoom
      guiInfo.state = "showed"
    end

  elseif guiInfo.state == "hidding" then
    local progress = (getTickCount() - guiInfo.animTick)/300
    guiInfo.y = interpolateBetween(guiInfo.lastY, 0, 0, sh - 40/zoom, 0, 0, progress, "Linear")

    if progress >= 1 then
      guiInfo.y = sh - 40/zoom

      if guiInfo.nextTable then
        guiInfo.state = "showing"
        guiInfo.animTick = getTickCount()
        guiInfo.lastY = guiInfo.y

        guiInfo.renderGuiList = guiInfo.nextTable
        guiInfo.nextTable = nil

      else
        guiInfo.renderGuiList = {}
        guiInfo.state = "hidden"
      end
    end
  end

  dxDrawText(guiInfo.legend, 10/zoom, 5/zoom, 5/zoom, guiInfo.y - 5/zoom, tocolor(255, 255, 255, 255), 1/zoom, guiInfo.fonts.small, "left", "bottom", false, false, false, true)
  dxDrawRectangle(0, guiInfo.y, sw, 110/zoom, tocolor(17, 17, 17, 255))

  if guiInfo.menuScroll == 1 then
    dxDrawImage(10/zoom, guiInfo.y + 35/zoom, 40/zoom, 40/zoom, "files/icons/next.png", 180, 0, 0, tocolor(255, 255, 255, 100))
  elseif isMouseInPosition(10/zoom, guiInfo.y + 35/zoom, 40/zoom, 40/zoom) then
    dxDrawImage(10/zoom, guiInfo.y + 35/zoom, 40/zoom, 40/zoom, "files/icons/next.png", 180, 0, 0, tocolor(255, 255, 255, 200))
  else
    dxDrawImage(10/zoom, guiInfo.y + 35/zoom, 40/zoom, 40/zoom, "files/icons/next.png", 180, 0, 0, tocolor(255, 255, 255, 150))
  end

  if (guiInfo.menuScroll + guiInfo.howManyToShow) > #guiInfo.renderGuiList then
    dxDrawImage(sw - 50/zoom, guiInfo.y + 35/zoom, 40/zoom, 40/zoom, "files/icons/next.png", 0, 0, 0, tocolor(255, 255, 255, 100))
  elseif isMouseInPosition(sw - 50/zoom, guiInfo.y + 35/zoom, 40/zoom, 40/zoom) then
    dxDrawImage(sw - 50/zoom, guiInfo.y + 35/zoom, 40/zoom, 40/zoom, "files/icons/next.png", 0, 0, 0, tocolor(255, 255, 255, 200))
  else
    dxDrawImage(sw - 50/zoom, guiInfo.y + 35/zoom, 40/zoom, 40/zoom, "files/icons/next.png", 0, 0, 0, tocolor(255, 255, 255, 150))
  end

  -- Testowanie
  if #guiInfo.renderGuiList > 0 then
    if guiInfo.selectedGuiList == "textures" and type(guiInfo.renderGuiList[1]) ~= "table" then
      for i = 0, (guiInfo.howManyToShow - 1) do
        local index = guiInfo.menuScroll + i
        if guiInfo.renderGuiList[index] then
          -- dxDrawRectangle(guiInfo.spaceLeft + 140/zoom*(i), guiInfo.y + 5/zoom, 80/zoom, 100/zoom, tocolor(0, 0, 0, 255))
          if fileExists("files/textures/"..guiInfo.renderGuiList[index]..".jpg") then
            if index == guiInfo.buildingIndex then
              dxDrawImage(guiInfo.spaceLeft + 140/zoom*(i) + 10/zoom, guiInfo.y + 10/zoom, 60/zoom, 60/zoom, "files/textures/"..guiInfo.renderGuiList[index]..".jpg", 0, 0, 0, tocolor(255, 255, 255, 255))
              dxDrawText("$0", guiInfo.spaceLeft + 140/zoom*(i), guiInfo.y + 65/zoom, guiInfo.spaceLeft + 80/zoom + 140/zoom*(i), guiInfo.y + 115/zoom, tocolor(240, 196, 55, 255), 1/zoom, guiInfo.fonts.normal, "center", "center", true, true)

            elseif isMouseInPosition(guiInfo.spaceLeft + 140/zoom*(i), guiInfo.y + 10/zoom, 80/zoom, 100/zoom) then
              dxDrawImage(guiInfo.spaceLeft + 140/zoom*(i) + 10/zoom, guiInfo.y + 10/zoom, 60/zoom, 60/zoom, "files/textures/"..guiInfo.renderGuiList[index]..".jpg", 0, 0, 0, tocolor(255, 255, 255, 255))
              dxDrawText("$0", guiInfo.spaceLeft + 140/zoom*(i), guiInfo.y + 65/zoom, guiInfo.spaceLeft + 80/zoom + 140/zoom*(i), guiInfo.y + 115/zoom, tocolor(255, 255, 255, 255), 1/zoom, guiInfo.fonts.normal, "center", "center", true, true)

            else
              dxDrawImage(guiInfo.spaceLeft + 140/zoom*(i) + 10/zoom, guiInfo.y + 10/zoom, 60/zoom, 60/zoom, "files/textures/"..guiInfo.renderGuiList[index]..".jpg", 0, 0, 0, tocolor(255, 255, 255, 200))
              dxDrawText("$0", guiInfo.spaceLeft + 140/zoom*(i), guiInfo.y + 65/zoom, guiInfo.spaceLeft + 80/zoom + 140/zoom*(i), guiInfo.y + 115/zoom, tocolor(255, 255, 255, 200), 1/zoom, guiInfo.fonts.normal, "center", "center", true, true)
            end
          else
            if index == guiInfo.buildingIndex then
              dxDrawText("$0", guiInfo.spaceLeft + 140/zoom*(i), guiInfo.y + 65/zoom, guiInfo.spaceLeft + 80/zoom + 140/zoom*(i), guiInfo.y + 115/zoom, tocolor(240, 196, 55, 255), 1/zoom, guiInfo.fonts.normal, "center", "center", true, true)
            elseif isMouseInPosition(guiInfo.spaceLeft + 140/zoom*(i), guiInfo.y + 5/zoom, 80/zoom, 100/zoom) then
              dxDrawText("$0", guiInfo.spaceLeft + 140/zoom*(i), guiInfo.y + 65/zoom, guiInfo.spaceLeft + 80/zoom + 140/zoom*(i), guiInfo.y + 115/zoom, tocolor(255, 255, 255, 255), 1/zoom, guiInfo.fonts.normal, "center", "center", true, true)
            else
              dxDrawText("$0", guiInfo.spaceLeft + 140/zoom*(i), guiInfo.y + 65/zoom, guiInfo.spaceLeft + 80/zoom + 140/zoom*(i), guiInfo.y + 115/zoom, tocolor(255, 255, 255, 200), 1/zoom, guiInfo.fonts.normal, "center", "center", true, true)
            end
          end
        end
      end

    else
      for i = 0, (guiInfo.howManyToShow - 1) do
        local index = guiInfo.menuScroll + i
        if guiInfo.renderGuiList[index] then
          if guiInfo.renderGuiList[index][1] then
          -- dxDrawRectangle(guiInfo.spaceLeft + 140/zoom*(i), guiInfo.y + 5/zoom, 80/zoom, 100/zoom, tocolor(0, 0, 0, 255))
            if fileExists("files/icons/objects/"..guiInfo.renderGuiList[index][1]..".png") then
              if index == guiInfo.buildingIndex then
                dxDrawImage(guiInfo.spaceLeft + 140/zoom*(i) - 5/zoom, guiInfo.y - 5/zoom, 90/zoom, 90/zoom, "files/icons/objects/"..guiInfo.renderGuiList[index][1]..".png", 0, 0, 0, tocolor(255, 255, 255, 255))
                dxDrawText("$"..guiInfo.renderGuiList[index][2], guiInfo.spaceLeft + 140/zoom*(i), guiInfo.y + 65/zoom, guiInfo.spaceLeft + 80/zoom + 140/zoom*(i), guiInfo.y + 115/zoom, tocolor(240, 196, 55, 255), 1/zoom, guiInfo.fonts.normal, "center", "center", true, true)

              elseif isMouseInPosition(guiInfo.spaceLeft + 140/zoom*(i), guiInfo.y + 5/zoom, 80/zoom, 100/zoom) then
                dxDrawImage(guiInfo.spaceLeft + 140/zoom*(i) - 5/zoom, guiInfo.y - 5/zoom, 90/zoom, 90/zoom, "files/icons/objects/"..guiInfo.renderGuiList[index][1]..".png", 0, 0, 0, tocolor(255, 255, 255, 255))
                dxDrawText("$"..guiInfo.renderGuiList[index][2], guiInfo.spaceLeft + 140/zoom*(i), guiInfo.y + 65/zoom, guiInfo.spaceLeft + 80/zoom + 140/zoom*(i), guiInfo.y + 115/zoom, tocolor(255, 255, 255, 255), 1/zoom, guiInfo.fonts.normal, "center", "center", true, true)

              else
                dxDrawImage(guiInfo.spaceLeft + 140/zoom*(i) - 5/zoom, guiInfo.y - 5/zoom, 90/zoom, 90/zoom, "files/icons/objects/"..guiInfo.renderGuiList[index][1]..".png", 0, 0, 0, tocolor(255, 255, 255, 200))
                dxDrawText("$"..guiInfo.renderGuiList[index][2], guiInfo.spaceLeft + 140/zoom*(i), guiInfo.y + 65/zoom, guiInfo.spaceLeft + 80/zoom + 140/zoom*(i), guiInfo.y + 115/zoom, tocolor(255, 255, 255, 200), 1/zoom, guiInfo.fonts.normal, "center", "center", true, true)
              end
            else
              if index == guiInfo.buildingIndex then
                dxDrawText("$"..guiInfo.renderGuiList[index][2], guiInfo.spaceLeft + 140/zoom*(i), guiInfo.y + 65/zoom, guiInfo.spaceLeft + 80/zoom + 140/zoom*(i), guiInfo.y + 115/zoom, tocolor(240, 196, 55, 255), 1/zoom, guiInfo.fonts.normal, "center", "center", true, true)
              elseif isMouseInPosition(guiInfo.spaceLeft + 140/zoom*(i), guiInfo.y + 5/zoom, 80/zoom, 100/zoom) then
                dxDrawText("$"..guiInfo.renderGuiList[index][2], guiInfo.spaceLeft + 140/zoom*(i), guiInfo.y + 65/zoom, guiInfo.spaceLeft + 80/zoom + 140/zoom*(i), guiInfo.y + 115/zoom, tocolor(255, 255, 255, 255), 1/zoom, guiInfo.fonts.normal, "center", "center", true, true)
              else
                dxDrawText("$"..guiInfo.renderGuiList[index][2], guiInfo.spaceLeft + 140/zoom*(i), guiInfo.y + 65/zoom, guiInfo.spaceLeft + 80/zoom + 140/zoom*(i), guiInfo.y + 115/zoom, tocolor(255, 255, 255, 200), 1/zoom, guiInfo.fonts.normal, "center", "center", true, true)
              end
            end
          end
        end
      end
    end
  end
end

function gui()
  dxDrawRectangle(0, sh-40/zoom, sw, 40/zoom, tocolor(22, 22, 22, 255))
  dxDrawText(string.format("Toplam Obje: #f0c437%d#bbbbbb/#f0c437%d    #ffffffÖdenecek tutar: #f0c437$%.2f", #guiInfo.buildedObjects, guiInfo.builderDetails.maxObjects, guiInfo.toPay), sw-240/zoom, sh-40/zoom, sw-20/zoom, sh, tocolor(255, 255, 255, 255), 1/zoom, guiInfo.fonts.normal, "right", "center", false, false, false, true)
  -- dxDrawText(string.format("Postawione obiekty: #f0c437%d#bbbbbb/#f0c437%d    #ffffffDo zapłaty: #f0c437$%.2f", #guiInfo.buildedObjects, guiInfo.builderDetails.maxObjects, guiInfo.toPay), sw-240/zoom, sh-40/zoom, sw-20/zoom, sh, tocolor(255, 255, 255, 255), 1/zoom, guiInfo.fonts.normal, "right", "center", false, false, false, true)

  

  -- dxDrawRectangle(15/zoom, sh-166/zoom, 100/zoom, 32/zoom, tocolor(0, 0, 0, 255))
  if isMouseInPosition(15/zoom, sh-36/zoom, 100/zoom, 32/zoom) then
    dxDrawImage(15/zoom, sh-30/zoom, 20/zoom, 20/zoom, "files/icons/close.png", 0, 0, 0, tocolor(255, 255, 255, 255))
    dxDrawText("Kapat", 45/zoom, sh-40/zoom, 110/zoom, sh, tocolor(255, 255, 255, 255), 1/zoom, guiInfo.fonts.normal, "left", "center")
  else
    dxDrawImage(15/zoom, sh-30/zoom, 20/zoom, 20/zoom, "files/icons/close.png", 0, 0, 0, tocolor(255, 255, 255, 255))
    dxDrawText("Kapat", 45/zoom, sh-40/zoom, 110/zoom, sh, tocolor(255, 255, 255, 200), 1/zoom, guiInfo.fonts.normal, "left", "center")
  end

  -- dxDrawRectangle(150/zoom, sh-166/zoom, 85/zoom, 32/zoom, tocolor(0, 0, 0, 255))
  if isMouseInPosition(150/zoom, sh-36/zoom, 85/zoom, 32/zoom) then
    dxDrawImage(150/zoom, sh-30/zoom, 20/zoom, 20/zoom, "files/icons/save.png", 0, 0, 0, tocolor(255, 255, 255, 255))
    dxDrawText("Kaydet", 180/zoom, sh-40/zoom, 220/zoom, sh, tocolor(255, 255, 255, 255), 1/zoom, guiInfo.fonts.normal, "left", "center")
  else
    dxDrawImage(150/zoom, sh-30/zoom, 20/zoom, 20/zoom, "files/icons/save.png", 0, 0, 0, tocolor(255, 255, 255, 255))
    dxDrawText("Kaydet", 180/zoom, sh-40/zoom, 220/zoom, sh, tocolor(255, 255, 255, 200), 1/zoom, guiInfo.fonts.normal, "left", "center")
  end

  -- dxDrawRectangle(270/zoom, sh-166/zoom, 115/zoom, 32/zoom, tocolor(0, 0, 0, 255))
  if isMouseInPosition(270/zoom, sh-36/zoom, 115/zoom, 32/zoom) then
    dxDrawImage(270/zoom, sh-30/zoom, 20/zoom, 20/zoom, "files/icons/person.png", 0, 0, 0, tocolor(255, 255, 255, 255))
    dxDrawText("Test Et", 300/zoom, sh-40/zoom, 220/zoom, sh, tocolor(255, 255, 255, 255), 1/zoom, guiInfo.fonts.normal, "left", "center")
  else
    dxDrawImage(270/zoom, sh-30/zoom, 20/zoom, 20/zoom, "files/icons/person.png", 0, 0, 0, tocolor(255, 255, 255, 255))
    dxDrawText("Test Et", 300/zoom, sh-40/zoom, 220/zoom, sh, tocolor(255, 255, 255, 200), 1/zoom, guiInfo.fonts.normal, "left", "center")
  end


  -- dxDrawRectangle(415/zoom, sh-166/zoom, 150/zoom, 32/zoom, tocolor(0, 0, 0, 255))
  if isMouseInPosition(415/zoom, sh-36/zoom, 150/zoom, 32/zoom) or guiInfo.selectedGuiList == "default" then
    dxDrawImage(415/zoom, sh-30/zoom, 20/zoom, 20/zoom, "files/icons/build.png", 0, 0, 0, tocolor(255, 255, 255, 255))
    dxDrawText("Kapı ve Duvar", 445/zoom, sh-40/zoom, 220/zoom, sh, tocolor(255, 255, 255, 255), 1/zoom, guiInfo.fonts.normal, "left", "center")
else
    dxDrawImage(415/zoom, sh-30/zoom, 20/zoom, 20/zoom, "files/icons/build.png", 0, 0, 0, tocolor(255, 255, 255, 255))
    dxDrawText("Kapı ve Duvar", 445/zoom, sh-40/zoom, 220/zoom, sh, tocolor(255, 255, 255, 200), 1/zoom, guiInfo.fonts.normal, "left", "center")
end

-- dxDrawRectangle(600/zoom, sh-166/zoom, 150/zoom, 32/zoom, tocolor(0, 0, 0, 255))
if isMouseInPosition(595/zoom, sh-36/zoom, 150/zoom, 32/zoom) or guiInfo.selectedGuiList == "building" then
    dxDrawImage(600/zoom, sh-30/zoom, 20/zoom, 20/zoom, "files/icons/furniture.png", 0, 0, 0, tocolor(255, 255, 255, 255))
    dxDrawText("Mobilya", 630/zoom, sh-40/zoom, 220/zoom, sh, tocolor(255, 255, 255, 255), 1/zoom, guiInfo.fonts.normal, "left", "center")
else
    dxDrawImage(600/zoom, sh-30/zoom, 20/zoom, 20/zoom, "files/icons/furniture.png", 0, 0, 0, tocolor(255, 255, 255, 255))
    dxDrawText("Mobilya", 630/zoom, sh-40/zoom, 220/zoom, sh, tocolor(255, 255, 255, 200), 1/zoom, guiInfo.fonts.normal, "left", "center")
end

--dxDrawRectangle(760/zoom, sh-36/zoom, 165/zoom, 32/zoom, tocolor(0, 0, 0, 255))
if isMouseInPosition(760/zoom, sh-36/zoom, 165/zoom, 32/zoom) or guiInfo.selectedGuiList == "textures" then
    dxDrawImage(765/zoom, sh-30/zoom, 20/zoom, 20/zoom, "files/icons/painting.png", 0, 0, 0, tocolor(255, 255, 255, 255))
    dxDrawText("Döşeme", 795/zoom, sh-40/zoom, 220/zoom, sh, tocolor(255, 255, 255, 255), 1/zoom, guiInfo.fonts.normal, "left", "center")
else
    dxDrawImage(765/zoom, sh-30/zoom, 20/zoom, 20/zoom, "files/icons/painting.png", 0, 0, 0, tocolor(255, 255, 255, 255))
    dxDrawText("Döşeme", 795/zoom, sh-40/zoom, 220/zoom, sh, tocolor(255, 255, 255, 200), 1/zoom, guiInfo.fonts.normal, "left", "center")
end


  local y = sh - 40/zoom - #guiInfo.furnitureCategories * 30/zoom
  if isMouseInPosition(595/zoom, sh-40/zoom, 150/zoom, 32/zoom) and guiInfo.selectedGuiList == "building" then
    dxDrawRectangle(595/zoom, y, 150/zoom, #guiInfo.furnitureCategories * 30/zoom, tocolor(27, 27, 27, 255))

    for i, v in pairs(guiInfo.furnitureCategories) do
      dxDrawText(v[1], 630/zoom, y + (i-1) * 30/zoom, 220/zoom, y + 30/zoom + (i-1) * 30/zoom, tocolor(255, 255, 255, 200), 1/zoom, guiInfo.fonts.normal, "left", "center")
      local img = string.format("files/icons/%s.png", v[2])
      if fileExists(img) then
        dxDrawImage(600/zoom, y + 5/zoom + (i-1) * 30/zoom, 20/zoom, 20/zoom, img, 0, 0, 0, tocolor(255, 255, 255, 200))
      end
    end
    guiInfo.furnitureCategoriesOpen = true

  elseif isMouseInPosition(595/zoom, y, 150/zoom, #guiInfo.furnitureCategories * 30/zoom) and guiInfo.furnitureCategoriesOpen then
    dxDrawRectangle(595/zoom, y, 150/zoom, #guiInfo.furnitureCategories * 30/zoom, tocolor(27, 27, 27, 255))

    for i, v in pairs(guiInfo.furnitureCategories) do
      local img = string.format("files/icons/%s.png", v[2])
      if isMouseInPosition(595/zoom, y + (i-1) * 30/zoom, 150/zoom, 30/zoom) then
        dxDrawText(v[1], 630/zoom, y + (i-1) * 30/zoom, 220/zoom, y + 30/zoom + (i-1) * 30/zoom, tocolor(255, 255, 255, 255), 1/zoom, guiInfo.fonts.normal, "left", "center")

        if fileExists(img) then
          dxDrawImage(600/zoom, y + 5/zoom + (i-1) * 30/zoom, 20/zoom, 20/zoom, img, 0, 0, 0, tocolor(255, 255, 255, 255))
        end
      else
        dxDrawText(v[1], 630/zoom, y + (i-1) * 30/zoom, 220/zoom, y + 30/zoom + (i-1) * 30/zoom, tocolor(255, 255, 255, 200), 1/zoom, guiInfo.fonts.normal, "left", "center")

        if fileExists(img) then
          dxDrawImage(600/zoom, y + 5/zoom + (i-1) * 30/zoom, 20/zoom, 20/zoom, img, 0, 0, 0, tocolor(255, 255, 255, 200))
        end
      end
    end
  else
    guiInfo.furnitureCategoriesOpen = nil
  end

  -- dxDrawRectangle(10/zoom, sh-166/zoom, 130/zoom, 32/zoom)
  -- if isMouseInPosition(10/zoom, sh-166/zoom, 130/zoom, 32/zoom) or guiInfo.optionsMenuOpen then
  --   dxDrawImage(15/zoom, sh-163/zoom, 26/zoom, 26/zoom, "files/icons/options.png", 0, 0, 0, tocolor(240, 196, 55, 255))
  --   dxDrawText("Opcje", 52/zoom, sh-170/zoom, 86/zoom, sh-130/zoom, tocolor(255, 255, 255, 255), 1/zoom, guiInfo.fonts.normal, "left", "center", false, false, false, true)
  -- else
  --   dxDrawImage(15/zoom, sh-163/zoom, 26/zoom, 26/zoom, "files/icons/options.png", 0, 0, 0, tocolor(240, 196, 55, 255))
  --   dxDrawText("Opcje", 52/zoom, sh-170/zoom, 86/zoom, sh-130/zoom, tocolor(255, 255, 255, 200), 1/zoom, guiInfo.fonts.normal, "left", "center", false, false, false, true)
  -- end
  --dxDrawRectangle(375/zoom, sh-166/zoom, 160/zoom, 32/zoom, tocolor(255, 255, 255, 255)) -- do testowania wielkości przycisku

  -- dxDrawImage(160/zoom, sh-166/zoom, 32/zoom, 32/zoom, "files/icons/build.png", 0, 0, 0, tocolor(255, 255, 255, 255))
  -- dxDrawText("Projektowanie", 202/zoom, sh-170/zoom, 222/zoom, sh-130/zoom, tocolor(255, 255, 255, 255), 1/zoom, guiInfo.fonts.normal, "left", "center", false, false, false, true)

  -- dxDrawImage(375/zoom, sh-166/zoom, 32/zoom, 32/zoom, "files/icons/build.png", 0, 0, 0, tocolor(255, 255, 255, 255))
  -- dxDrawText("Urządzanie", 417/zoom, sh-170/zoom, 467/zoom, sh-130/zoom, tocolor(255, 255, 255, 255), 1/zoom, guiInfo.fonts.normal, "left", "center", false, false, false, true)

  -- if guiInfo.optionsMenuOpen then
  --   dxDrawRectangle(0, sh-306/zoom, 180/zoom, 136/zoom, tocolor(29, 33, 38, 255))
  --   dxDrawImage(10/zoom, sh-296/zoom, 32/zoom, 32/zoom, "files/icons/save.png", 0, 0, 0, tocolor(255, 255, 255, 255))
  --   dxDrawImage(10/zoom, sh-254/zoom, 32/zoom, 32/zoom, "files/icons/people.png", 0, 0, 0, tocolor(255, 255, 255, 255))
  --   dxDrawImage(10/zoom, sh-212/zoom, 32/zoom, 32/zoom, "files/icons/exit.png", 0, 0, 0, tocolor(255, 255, 255, 255))

  --   dxDrawText("Zapisz", 52/zoom, sh-296/zoom, 42/zoom, sh-264/zoom, tocolor(255, 255, 255, 255), 1/zoom, guiInfo.fonts.normal, "left", "center", false, false, false, true)
  --   dxDrawText("Przetestuj", 52/zoom, sh-254/zoom, 42/zoom, sh-222/zoom, tocolor(255, 255, 255, 255), 1/zoom, guiInfo.fonts.normal, "left", "center", false, false, false, true)
  --   dxDrawText("Zamknij edytor", 52/zoom, sh-212/zoom, 42/zoom, sh-180/zoom, tocolor(255, 255, 255, 255), 1/zoom, guiInfo.fonts.normal, "left", "center", false, false, false, true)
  -- end

  if guiInfo.confirmInteriorQuit then
    drawBackground((sw-420/zoom)/2, (sh-140/zoom)/2, 420/zoom, 140/zoom, tocolor(17, 17, 17, 255), 5)
    dxDrawText("Kaydetmeden çıkmak\ntüm değişikliklerin silinmesine neden olacak.\n#d4af37Gerçekten çıkmak istiyor musunuz?", (sw-410/zoom)/2, (sh-140/zoom)/2, (sw+410/zoom)/2, (sh+35/zoom)/2, tocolor(200, 200, 200, 255), 1/zoom, guiInfo.fonts.normal, "center", "center", true, true, false, true)
  end

end


function useOptionForBuilder(val, money, index)
  if guiInfo.confirmInteriorQuit then return end
  guiInfo.buildingIndex = nil
  clearPainting()

  if val == 1 or val == 2 then
    if isElement(guiInfo.buildingFurniture) then guiInfo.buildingFurniture:destroy(); guiInfo.buildingFurniture = nil end
    if isElement(guiInfo.buildingWall) then
      if val == 1 and guiInfo.modelsID.wall == guiInfo.buildingWall:getModel() then
        guiInfo.buildingWall:destroy(); guiInfo.buildingWall = nil
        return
      elseif val == 2 and guiInfo.modelsID.doors == guiInfo.buildingWall:getModel() then
        guiInfo.buildingWall:destroy(); guiInfo.buildingWall = nil
        return
      end
      guiInfo.buildingWall:destroy(); guiInfo.buildingWall = nil
    end

    if val == 1 then
      guiInfo.buildingWall = Object(guiInfo.modelsID.wall, guiInfo.posXdef, guiInfo.posYdef, guiInfo.posZdef + guiInfo.positionCamera[guiInfo.floor]+200)
      guiInfo.buildingWall:setInterior(99)

    elseif val == 2 then
      guiInfo.buildingWall = Object(guiInfo.modelsID.doors, guiInfo.posXdef, guiInfo.posYdef, guiInfo.posZdef + guiInfo.positionCamera[guiInfo.floor]+200)
      guiInfo.buildingWall:setInterior(99)

    elseif val == 3 then
      guiInfo.buildingWall = Object(guiInfo.modelsID.wall, guiInfo.posXdef, guiInfo.posYdef, guiInfo.posZdef + guiInfo.positionCamera[guiInfo.floor]+200)
      guiInfo.buildingWall:setInterior(99)
    end
    guiInfo.buildingIndex = index

  else
    local model = isElement(guiInfo.buildingFurniture) and guiInfo.buildingFurniture:getModel() or nil
    clearBuildingObjects()
    if model == val then return end

    guiInfo.buildingFurniture = createObject(val, guiInfo.posXdef, guiInfo.posYdef, guiInfo.posZdef + guiInfo.positionCamera[guiInfo.floor]+200)
    setElementInterior(guiInfo.buildingFurniture, 99)
    guiInfo.buildingIndex = index
    setElementDoubleSided(guiInfo.buildingFurniture, true)

    guiInfo.buildingObjectZ = 0
  end
end


function openInteriorBuilder(int, idHome, homeBuilded, homePos, oryginalWalls, oryginalFloor, exitPOS, gangObjects)
  setTimer(function()
    int = tonumber(int)
    setWeather(1)
    setTime(12, 0)

    local intSize = {int^2, int, int/2}
    posExit = split(homePos, ",")

    guiInfo.uidHome = idHome

    guiInfo.toPay = 0
    guiInfo.openedMenu = 1
    guiInfo.menuScroll = 1
    guiInfo.texturesScroll = 0

    guiInfo.optionsMenuOpen = false
    guiInfo.selectMenuOpen = false
    guiInfo.testingByPlayer = false
    guiInfo.interiorSize = intSize
    guiInfo.rotFurniture = 0
    guiInfo.exitPOS = split(exitPOS, ",")

    guiInfo.confirmInteriorQuit = false

    guiInfo.renderGuiList = {}


    guiInfo.posXdef = posExit[1]
    guiInfo.posYdef = posExit[2]
    guiInfo.posZdef = posExit[3]

    guiInfo.posX = guiInfo.posXdef
    guiInfo.posY = guiInfo.posYdef
    guiInfo.posZ = guiInfo.posZdef

    guiInfo.rot = 270
    guiInfo.floor = 1

    localPlayer:setInterior(99)
    localPlayer:setRotation(0, 0, 270)
    setElementFrozen(localPlayer, true)
    enableWallEffect()

    oryginalFloor = oryginalFloor and fromJSON(oryginalFloor) or {}

    guiInfo.skeleton = {}

    local posNext = Vector3(guiInfo.posX - guiInfo.builderDetails.floorSize*intSize[3], guiInfo.posY - guiInfo.builderDetails.floorSize*intSize[3], guiInfo.posZdef)
    buildEntrenceFloor(posNext, oryginalFloor)

    local row = 1
    local obj = 0
    for i=5, intSize[1]+4 do
      if obj == intSize[2] then
        row = row + 1
        obj = 0
      end
      guiInfo.skeleton[i] = Object(guiInfo.modelsID.floor, posNext.x + guiInfo.builderDetails.floorSize*row, posNext.y + guiInfo.builderDetails.floorSize*obj, guiInfo.posZdef, 0, 0, 0)
      guiInfo.skeleton[i]:setInterior(99)
      setElementData(guiInfo.skeleton[i], "builder:type", "floor", false)

      if type(oryginalFloor) == "table" then
        if oryginalFloor[i] then
          changeTexture(guiInfo.skeleton[i], oryginalFloor[i][1], oryginalFloor[i][2])
          setElementData(guiInfo.skeleton[i], "builder:textures", {oryginalFloor[i][1], oryginalFloor[i][2]}, false)
        end
      end
      obj = obj + 1
    end


    guiInfo.skeletonWalls = {}
    local max = 0
    local obj = 2
    local row = 1
    oryginalWalls = oryginalWalls and fromJSON(oryginalWalls) or {}

    for i=1, intSize[2]*4 do
      if obj == intSize[2] then
        row = row + 1
        obj = 0
      end
      local dataWall = loadBuildWallData(row, obj, intSize[2])

      if not dataWall then break end
      guiInfo.skeletonWalls[i] = Object(guiInfo.modelsID.wall, posNext.x + dataWall[1], posNext.y + dataWall[2], guiInfo.posZdef + guiInfo.builderDetails.wallHeight/2, 0, 0, dataWall[3])
      guiInfo.skeletonWalls[i]:setInterior(99)
      setElementData(guiInfo.skeletonWalls[i], "blockDoors", true, false)
      obj = obj + 1

      if type(oryginalWalls) == "table" then
        if oryginalWalls[i] then
          changeTexture(guiInfo.skeletonWalls[i], oryginalWalls[i][1], oryginalWalls[i][2])
          setElementData(guiInfo.skeletonWalls[i], "builder:textures", {oryginalWalls[i][1], oryginalWalls[i][2]}, false)
        end
      end

      max = i
    end
    buildEntrence(posNext.x, posNext.y + guiInfo.builderDetails.floorSize*obj, guiInfo.posZdef, oryginalWalls, max)

    guiInfo.meshPosition = {posNext.x, posNext.y, guiInfo.posZdef + 0.1}
    guiInfo.defPosForPlayer = {posNext.x - guiInfo.builderDetails.floorSize, posNext.y + guiInfo.builderDetails.floorSize/2, guiInfo.posZdef + 1}
    setElementPosition(localPlayer, posNext.x - guiInfo.builderDetails.floorSize, posNext.y + guiInfo.builderDetails.floorSize/2, guiInfo.posZdef + 1.1)
    showCursor(true)
    showChat(false)
    exports.TR_weather:setCustomWeather(0, 12, 0, 9999)

    local objectIDs = {}
    guiInfo.buildedObjects = {}
    if homeBuilded then
      local homeObjects = fromJSON(homeBuilded)
      if type(homeObjects) == "table" then
        for i, v in pairs(homeObjects) do
          local obj = createObject(v[1], v[2], v[3], v[4], v[5], v[6], v[7])
          setElementInterior(obj, 99)
          setElementData(obj, "builder:textures", {v[8], v[9]}, false)
          setElementCollisionsEnabled(obj, true)

          changeTexture(obj, v[8], v[9])

          local model = tonumber(v[1])
          if guiInfo.isObjectIndexable[model] then
            if not objectIDs[model] then objectIDs[model] = 0 end

            objectIDs[model] = objectIDs[model] + 1
            setElementData(obj, "objectIndex", objectIDs[model], false)
            setElementID(obj, "interior_"..model.."_"..objectIDs[model])
          end

          table.insert(guiInfo.buildedObjects, obj)
        end
      end
    end

    guiInfo.gangDrugsBlock = -1000
    if gangObjects then
      local max = -1000
      for i, v in pairs(gangObjects) do
        local index = tonumber(v.objectIndex)
        if index > max then
          max = index
        end
      end
      guiInfo.gangDrugsBlock = max
    end

    setTimer(function()
      addEventHandler("onClientRender", root, render)
      addEventHandler("onClientClick", root, click)
      addEventHandler("onClientKey", root, key)
    end, 3000, 1)

    guiInfo.quitCancle = exports.TR_dx:createButton((sw - 200/zoom)/2 - 105/zoom, sh/2 + 25/zoom, 200/zoom, 40/zoom, "İptal")
    guiInfo.quitAccept = exports.TR_dx:createButton((sw - 200/zoom)/2 + 105/zoom, sh/2 + 25/zoom, 200/zoom, 40/zoom, "Çıkış")


    exports.TR_dx:setButtonVisible({guiInfo.quitCancle, guiInfo.quitAccept}, false)
    exports.TR_hud:setHudVisible(false)
    exports.TR_chat:showCustomChat(false)
    exports.TR_dx:setOpenGUI(true)
  end, 1000, 1)
end
addEvent("interiorsBuilderOpen", true)
addEventHandler("interiorsBuilderOpen", root, openInteriorBuilder)

function closeInteriorBuilder()
  exports.TR_dx:showLoading(4000, "Dünya Yükleniyor")
  setTimer(function()
    exports.TR_hud:setHudVisible(true)
    exports.TR_chat:showCustomChat(true)
    exports.TR_dx:setOpenGUI(false)
  end, 4000, 1)

  setTimer(function()
    clearBuildingObjects()

    removeEventHandler("onClientRender", root, render)
    removeEventHandler("onClientClick", root, click)
    removeEventHandler("onClientKey", root, key)

    localPlayer:setInterior(0)
    localPlayer:setPosition(guiInfo.exitPOS[1], guiInfo.exitPOS[2], guiInfo.exitPOS[3])
    setElementFrozen(localPlayer, false)
    triggerServerEvent("setPlayerInteriorPos", resourceRoot, {guiInfo.exitPOS[1], guiInfo.exitPOS[2], guiInfo.exitPOS[3], 0, 0}, true)
    setElementData(localPlayer, "canUseHouseStash", nil)
    disableWallEffect()
    exports.TR_dx:destroyButton({guiInfo.quitCancle, guiInfo.quitAccept})
    exports.TR_weather:setCustomWeather(false)

    setCameraTarget(localPlayer)

    showCursor(false)
    showChat(true)

    for i, v in pairs(guiInfo.skeletonWalls) do
      if isElement(v) then v:destroy() end
    end
    for i, v in pairs(guiInfo.skeleton) do
      if isElement(v) then v:destroy() end
    end
    for i, v in pairs(guiInfo.buildedObjects) do
      if isElement(v) then v:destroy() end
    end
    if guiInfo.roof then
      for i, v in pairs(guiInfo.roof) do
        if isElement(v) then v:destroy() end
      end
    end
    for i, v in pairs(guiInfo.shaders.builded) do
      if isElement(v[1]) then v[1]:destroy() end
      if isElement(v[2]) then v[2]:destroy() end
    end
  end, 1000, 1)
end


function changeTexture(obj, txt1, txt2)
  local textName = getTextName(obj)
  if type(textName) == "table" then
    if not guiInfo.shaders.builded[obj] then guiInfo.shaders.builded[obj] = {dxCreateShader( "files/shaders/replace.fx"), dxCreateShader( "files/shaders/replace.fx")} end
    if txt1 ~= "" then
      if not guiInfo.shaders.buildedTextures[txt1] then guiInfo.shaders.buildedTextures[txt1] = dxCreateTexture("files/textures/"..txt1..".jpg", "dxt1", true, "clamp") end
      guiInfo.shaders.builded[obj][1]:setValue("gTexture", guiInfo.shaders.buildedTextures[txt1])
      guiInfo.shaders.builded[obj][1]:applyToWorldTexture(textName[1], obj)
    end

    if txt2 ~= "" then
      if not guiInfo.shaders.buildedTextures[txt2] then guiInfo.shaders.buildedTextures[txt2] = dxCreateTexture("files/textures/"..txt2..".jpg", "dxt1", true, "clamp") end
      guiInfo.shaders.builded[obj][2]:setValue("gTexture", guiInfo.shaders.buildedTextures[txt2])
      guiInfo.shaders.builded[obj][2]:applyToWorldTexture(textName[2], obj)
    end
  end
end


function saveBuildInterior()
  guiInfo.blockEditor = true
  guiInfo.mouse = nil

  local buildedTable = {}
  for i, v in pairs(guiInfo.buildedObjects) do
    local pos = Vector3(v:getPosition())
    local rot = Vector3(v:getRotation())
    local textures = v:getData("builder:textures") and v:getData("builder:textures") or {"", ""}
    table.insert(buildedTable, {v:getModel(), pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, textures[1], textures[2]})
  end

  local buildedWalls = {}
  for i, v in pairs(guiInfo.skeletonWalls) do
    local textures = v:getData("builder:textures") and v:getData("builder:textures") or {"", ""}
    table.insert(buildedWalls, {textures[1], textures[2]})
  end

  local buildedFloor = {}
  for i, v in pairs(guiInfo.skeleton) do
    local textures = v:getData("builder:textures") and v:getData("builder:textures") or {"", ""}
    table.insert(buildedFloor, {textures[1], textures[2]})
  end

  local buildedObjectsJSON = toJSON(buildedTable)
  local wallsToJSON = toJSON(buildedWalls)
  local floorToJSON = toJSON(buildedFloor)
  -- triggerServerEvent("saveBuildedHouse", resourceRoot, guiInfo.uidHome, guiInfo.toPay, buildedObjectsJSON, wallsToJSON, floorToJSON)

  triggerServerEvent("createPayment", resourceRoot, guiInfo.toPay, "saveBuildedHouse", {guiInfo.uidHome, buildedObjectsJSON, wallsToJSON, floorToJSON})
end


function setPlayerTestingInterior()
  if guiInfo.testingByPlayer then
    guiInfo.testingByPlayer = false

    localPlayer:setInterior(99)
    localPlayer:setRotation(0, 0, 270)
    setElementFrozen(localPlayer, true)
    exports.TR_noti:destroy(guiInfo.backNoti)

    addEventHandler("onClientRender", root, render)
    addEventHandler("onClientClick", root, click)
    showCursor(true)

    localPlayer:setPosition(guiInfo.defPosForPlayer[1], guiInfo.defPosForPlayer[2], guiInfo.defPosForPlayer[3])

    for i, v in pairs(guiInfo.roof) do
      if isElement(v) then v:destroy() end
    end

  else
    removeEventHandler("onClientRender", root, render)
    removeEventHandler("onClientClick", root, click)
    setElementFrozen(localPlayer, false)

    clearBuildingObjects()
    guiInfo.backNoti = exports.TR_noti:create("Test modundan çıkmak için ENTER tuşuna basın.", "info", false, true)


    guiInfo.roof = {}
    local posNext = Vector3(guiInfo.posX - guiInfo.builderDetails.floorSize*guiInfo.interiorSize[3] - guiInfo.builderDetails.floorSize/2, guiInfo.posY - guiInfo.builderDetails.floorSize*guiInfo.interiorSize[3] + guiInfo.builderDetails.floorSize/2, guiInfo.posZdef + guiInfo.builderDetails.wallHeight)
    local row = 0
    local obj = 0

    local size = math.ceil(guiInfo.interiorSize[2]/2) + 1
    for i=1, (size * size) do
      if obj == size then
        row = row + 1
        obj = 0
      end
      guiInfo.roof[i] = createObject(guiInfo.modelsID.roof, posNext.x + guiInfo.builderDetails.roofSize * obj, posNext.y + guiInfo.builderDetails.roofSize * row, posNext.z, 0, 0, 0)
      setElementInterior(guiInfo.roof[i], 99)
      obj = obj + 1
    end

    setTimer(function()
      setCameraTarget(localPlayer)
      guiInfo.testingByPlayer = true

      guiInfo.optionsMenuOpen = false
      guiInfo.selectMenuOpen = false

      showCursor(false)
    end, 50, 1)
  end
end


function interiorSaved(status)
  guiInfo.blockEditor = nil
  exports.TR_dx:setResponseEnabled(false)

  if status then
    guiInfo.toPay = 0

    for i, v in pairs(guiInfo.buildedObjects) do
      setElementData(v, "builder:price", nil, false)
    end
  end
end
addEvent("interiorSaved", true)
addEventHandler("interiorSaved", root, interiorSaved)


---- FUNCTIONS ----
function loadBuildWallData(row, obj, size)
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



function buildEntrenceFloor(posNext, oryginalFloor)
  guiInfo.skeleton[#guiInfo.skeleton + 1] = Object(guiInfo.modelsID.floor, posNext.x, posNext.y + guiInfo.builderDetails.floorSize, guiInfo.posZdef, 0, 0, 0)
  guiInfo.skeleton[#guiInfo.skeleton]:setInterior(99)

  guiInfo.skeleton[#guiInfo.skeleton + 1] = Object(guiInfo.modelsID.floor, posNext.x, posNext.y, guiInfo.posZdef, 0, 0, 0)
  guiInfo.skeleton[#guiInfo.skeleton]:setInterior(99)

  guiInfo.skeleton[#guiInfo.skeleton + 1] = Object(guiInfo.modelsID.floor, posNext.x - guiInfo.builderDetails.floorSize, posNext.y, guiInfo.posZdef, 0, 0, 0)
  guiInfo.skeleton[#guiInfo.skeleton]:setInterior(99)

  guiInfo.skeleton[#guiInfo.skeleton + 1] = Object(guiInfo.modelsID.floor, posNext.x - guiInfo.builderDetails.floorSize, posNext.y + guiInfo.builderDetails.floorSize, guiInfo.posZdef, 0, 0, 0)
  guiInfo.skeleton[#guiInfo.skeleton]:setInterior(99)

  if type(oryginalFloor) == "table" then
    for i = 1, 4 do
      if oryginalFloor[i] then changeTexture(guiInfo.skeleton[i], oryginalFloor[i][1], oryginalFloor[i][2]) end
      if oryginalFloor[i] then setElementData(guiInfo.skeleton[i], "builder:textures", {oryginalFloor[i][1], oryginalFloor[i][2]}, false) end
    end
  end
end

function buildEntrence(x, y, z, oryginalWalls)
  local start = #guiInfo.skeletonWalls + 1

  guiInfo.skeletonWalls[#guiInfo.skeletonWalls + 1] = Object(guiInfo.modelsID.wall, x, y + guiInfo.builderDetails.floorSize*1.5, z + guiInfo.builderDetails.wallHeight/2, 0, 0, 0)
  guiInfo.skeletonWalls[#guiInfo.skeletonWalls]:setInterior(99)

  guiInfo.skeletonWalls[#guiInfo.skeletonWalls + 1] = Object(guiInfo.modelsID.wall, x - guiInfo.builderDetails.floorSize, y + guiInfo.builderDetails.floorSize*1.5, z + guiInfo.builderDetails.wallHeight/2, 0, 0, 0)
  guiInfo.skeletonWalls[#guiInfo.skeletonWalls]:setInterior(99)

  guiInfo.skeletonWalls[#guiInfo.skeletonWalls + 1] = Object(guiInfo.modelsID.wall, x - guiInfo.builderDetails.floorSize*1.5, y, z + guiInfo.builderDetails.wallHeight/2, 0, 0, 90)
  guiInfo.skeletonWalls[#guiInfo.skeletonWalls]:setInterior(99)

  guiInfo.skeletonWalls[#guiInfo.skeletonWalls + 1] = Object(guiInfo.modelsID.wall, x - guiInfo.builderDetails.floorSize*1.5, y + guiInfo.builderDetails.floorSize, z + guiInfo.builderDetails.wallHeight/2, 0, 0, 90)
  guiInfo.skeletonWalls[#guiInfo.skeletonWalls]:setInterior(99)

  guiInfo.skeletonWalls[#guiInfo.skeletonWalls + 1] = Object(guiInfo.modelsID.wall, x, y - guiInfo.builderDetails.floorSize/2, z + guiInfo.builderDetails.wallHeight/2, 0, 0, 180)
  guiInfo.skeletonWalls[#guiInfo.skeletonWalls]:setInterior(99)

  guiInfo.skeletonWalls[#guiInfo.skeletonWalls + 1] = Object(guiInfo.modelsID.wall, x - guiInfo.builderDetails.floorSize, y - guiInfo.builderDetails.floorSize/2, z + guiInfo.builderDetails.wallHeight/2, 0, 0, 180)
  guiInfo.skeletonWalls[#guiInfo.skeletonWalls]:setInterior(99)

  guiInfo.skeletonWalls[#guiInfo.skeletonWalls + 1] = Object(guiInfo.modelsID.doors, x + guiInfo.builderDetails.floorSize/2, y, z + guiInfo.builderDetails.wallHeight/2, 0, 0, 90)
  guiInfo.skeletonWalls[#guiInfo.skeletonWalls]:setInterior(99)

  guiInfo.skeletonWalls[#guiInfo.skeletonWalls + 1] = Object(guiInfo.modelsID.doors, x + guiInfo.builderDetails.floorSize/2, y + guiInfo.builderDetails.floorSize, z + guiInfo.builderDetails.wallHeight/2, 0, 0, 90)
  guiInfo.skeletonWalls[#guiInfo.skeletonWalls]:setInterior(99)


  for k = 0, 7 do
    local i = start + k
    if oryginalWalls[i] then
      changeTexture(guiInfo.skeletonWalls[i], oryginalWalls[i][1], oryginalWalls[i][2])
      setElementData(guiInfo.skeletonWalls[i], "builder:textures", {oryginalWalls[i][1], oryginalWalls[i][2]}, false)
      setElementData(guiInfo.skeletonWalls[i], "blockDoors", true, false)
    end
  end
end

function moveCamera()
  if guiInfo.editingElementCanChangePos then return end
  if guiInfo.blockEditor then return end

  local cx,cy,cz,ctx,cty,ctz = getCameraMatrix()
  ctx,cty = ctx-cx,cty-cy
  local timeslice = 0.1
  local mult = timeslice/math.sqrt(ctx*ctx+cty*cty)
  ctx,cty = ctx*mult,cty*mult
  if getKeyState("w") then guiInfo.posX,guiInfo.posY = guiInfo.posX+ctx,guiInfo.posY+cty end
  if getKeyState("s") then guiInfo.posX,guiInfo.posY = guiInfo.posX-ctx,guiInfo.posY-cty end
  if getKeyState("a") then guiInfo.posX,guiInfo.posY = guiInfo.posX-cty,guiInfo.posY+ctx end
  if getKeyState("d") then guiInfo.posX,guiInfo.posY = guiInfo.posX+cty,guiInfo.posY-ctx end
end

function moveFurniture()
  if not guiInfo.editingElement or not isElement(guiInfo.editingElement) then return end
  if not guiInfo.editingElementCanChangePos then return end

  local posObj = Vector3(guiInfo.editingElement:getPosition())
  local rotObj = Vector3(guiInfo.editingElement:getRotation())
  local cx,cy,cz,ctx,cty,ctz = getCameraMatrix()
  ctx,cty = ctx-cx,cty-cy
  local timeslice = 0.02
  local mult = timeslice/math.sqrt(ctx*ctx+cty*cty)
  ctx,cty = ctx*mult,cty*mult
  if getKeyState("w") then posObj.x,posObj.y = posObj.x+ctx,posObj.y+cty end
  if getKeyState("s") then posObj.x,posObj.y = posObj.x-ctx,posObj.y-cty end
  if getKeyState("a") then posObj.x,posObj.y = posObj.x-cty,posObj.y+ctx end
  if getKeyState("d") then posObj.x,posObj.y = posObj.x+cty,posObj.y-ctx end
  if getKeyState("arrow_u") then posObj.z = posObj.z+0.005 end
  if getKeyState("arrow_d") then posObj.z = posObj.z-0.005 end

  if getKeyState("arrow_l") then rotObj.z = rotObj.z+0.3 end
  if getKeyState("arrow_r") then rotObj.z = rotObj.z-0.3 end

  guiInfo.editingElement:setPosition(posObj.x, posObj.y, posObj.z)
  guiInfo.editingElement:setRotation(rotObj.x, rotObj.y, rotObj.z)
end


function createDoorsWall(floorPos, x, y)
  local posHit = floorPos
  local wallRotation = getWallRotation(posHit, x, y)
  local wallRot = guiInfo.furniture.rotations[wallRotation]

  local wall = createObject(guiInfo.modelsID.doors, posHit.x + wallRot[2], posHit.y + wallRot[3], posHit.z + guiInfo.builderDetails.wallHeight/2)
  setElementRotation(wall, 0, 0, wallRot[1])
  setElementInterior(wall, 99)
  table.insert(guiInfo.buildedObjects, wall)
end


function getWallRotation(posHit, x, y)
  if posHit.x < x - 0.2 then
    wallRotation = 2
  elseif posHit.x > x + 0.2 then
    wallRotation = 4
  elseif posHit.y < y - 0.2 then
    wallRotation = 1
  elseif posHit.y > y + 0.2 then
    wallRotation = 3
  end
  return wallRotation
end

function getTextName(obj)
  local model = obj:getModel()
  if model == guiInfo.modelsID.wall then
    return {"wall1", "wall2"}
  elseif model == guiInfo.modelsID.floor then
    return {"floor", "wall2"} -- zmienić!
  elseif model == guiInfo.modelsID.doors then
    return {"wall1", "wall2"}

  else
    return false
  end
end

function canPlaceWallObject(object, elementHit, x, y)
  if not checkWallPlace(Vector3(elementHit:getPosition()), x, y) then return cantPlaceMessage() end
  -- local originalPos = Vector3(object:getPosition())

  -- for i, v in pairs(guiInfo.buildedObjects) do
  --   if guiInfo.furniture.doorIDs[getElementModel(v)] then
  --     local firstPos = Vector3(v:getPosition())
  --     local rot = getDoorsRotation(v)
  --     local posFix = guiInfo.furniture.dorsRotation[rot]

  --     firstPos.x = firstPos.x - posFix[2]
  --     firstPos.y = firstPos.y - posFix[3]

  --     local newPos = getFrontDoorByRotation(Vector3(firstPos), rot)
  --     if not checkWallPlaceByPos(newPos, rot, originalPos) then return cantPlaceMessage() end

  --     local newPos = getBackDoorByRotation(Vector3(firstPos), rot)
  --     if not checkWallPlaceByPos(newPos, rot, originalPos) then return cantPlaceMessage() end

  --     local secondPoss = getSideDoorByRotation(Vector3(firstPos), rot)
  --     if not checkWallPlaceByPos(secondPoss, rot, originalPos) then return cantPlaceMessage() end

  --     local newPos = getBackDoorByRotation(Vector3(secondPoss), rot)
  --     if not checkWallPlaceByPos(newPos, rot, originalPos) then return cantPlaceMessage() end

  --     local newPos = getNextDoorByRotation(Vector3(newPos), rot)
  --     if not checkWallPlaceByPos(newPos, rot, originalPos) then return cantPlaceMessage() end

  --     local thirdPos = getNextDoorByRotation(Vector3(secondPoss), rot)
  --     if not checkWallPlaceByPos(thirdPos, rot, originalPos) then return cantPlaceMessage() end
  --   end
  -- end

  return true
end

function getDoorsRotation(element)
  local _, _, rot_z = getElementRotation(element)
  local model = getElementModel(element)

  local rot;
  local pos = {0, 0}

  for i, v in pairs(guiInfo.furniture.dorsRotation) do
    if v[1] == rot_z then
      rot = i
      break
    end
  end

  local fixer = guiInfo.furniture.dorsModelRotation[model][wallRotation]
  local rott = guiInfo.furniture.dorsRotation[wallRotation]

  return rot, {-(rott[2] + fixer[2]), -(rott[3] + fixer[3])}
end

function canPlaceDoorObject(originalPos, firstPos, x, y)
  local wallRotation = getWallRotation(firstPos, x, y)
  if not checkWallPlace(firstPos, x, y, wallRotation) then return cantPlaceMessage() end

  local frontPos = getFrontDoorByRotation(Vector3(firstPos), wallRotation, true)
  local backPos = getBackDoorByRotation(Vector3(firstPos), wallRotation, true)

  for i, v in pairs(guiInfo.buildedObjects) do
    if guiInfo.furniture.doorIDs[getElementModel(v)] then
      local doorPos = Vector3(getElementPosition(v))

      local rot = getDoorsRotation(v)
      local posFix = guiInfo.furniture.dorsRotation[rot]

      doorPos.x = doorPos.x - posFix[2]
      doorPos.y = doorPos.y - posFix[3]

      local fPos = getFrontDoorByRotation(Vector3(doorPos), rot, true)
      local bPos = getBackDoorByRotation(Vector3(doorPos), rot, true)

      if getDistanceBetweenPoints2D(frontPos.x, frontPos.y, fPos.x, fPos.y) < 1 or getDistanceBetweenPoints2D(frontPos.x, frontPos.y, bPos.x, bPos.y) < 1 or getDistanceBetweenPoints2D(backPos.x, backPos.y, fPos.x, fPos.y) < 1 or getDistanceBetweenPoints2D(backPos.x, backPos.y, bPos.x, bPos.y) < 1 then
        return cantPlaceMessage()
      end
    end
  end

  return true
end

function getNextDoorByRotation(pos, wallRotation)
  if wallRotation == 1 then
    pos.x = pos.x - guiInfo.builderDetails.floorSize
  elseif wallRotation == 2 then
    pos.y = pos.y + guiInfo.builderDetails.floorSize
  elseif wallRotation == 3 then
    pos.x = pos.x + guiInfo.builderDetails.floorSize
  elseif wallRotation == 4 then
    pos.y = pos.y - guiInfo.builderDetails.floorSize
  end
  return pos
end

function getSideDoorByRotation(pos, wallRotation)
  if wallRotation == 1 then
    pos.x = pos.x + guiInfo.builderDetails.floorSize/2
    pos.y = pos.y - guiInfo.builderDetails.floorSize/2
  elseif wallRotation == 2 then
    pos.y = pos.y - guiInfo.builderDetails.floorSize/2
    pos.x = pos.x + guiInfo.builderDetails.floorSize/2
  elseif wallRotation == 3 then
    pos.x = pos.x - guiInfo.builderDetails.floorSize/2
    pos.y = pos.y + guiInfo.builderDetails.floorSize/2
  elseif wallRotation == 4 then
    pos.y = pos.y + guiInfo.builderDetails.floorSize/2
    pos.x = pos.x - guiInfo.builderDetails.floorSize/2
  end
  return pos
end

function getFrontDoorByRotation(pos, wallRotation, isHalf)
  if isHalf then
    if wallRotation == 2 then
      pos.x = pos.x + guiInfo.builderDetails.floorSize
    elseif wallRotation == 1 then
      pos.y = pos.y
    elseif wallRotation == 4 then
      pos.x = pos.x
    elseif wallRotation == 3 then
      pos.y = pos.y - guiInfo.builderDetails.floorSize
    end
    return pos
  else
    if wallRotation == 2 then
      pos.x = pos.x + guiInfo.builderDetails.floorSize
    elseif wallRotation == 1 then
      pos.y = pos.y - guiInfo.builderDetails.floorSize
    elseif wallRotation == 4 then
      pos.x = pos.x - guiInfo.builderDetails.floorSize
    elseif wallRotation == 3 then
      pos.y = pos.y + guiInfo.builderDetails.floorSize
    end
    return pos
  end
end

function getBackDoorByRotation(pos, wallRotation, isHalf)
  if isHalf then
    if wallRotation == 2 then
      pos.x = pos.x
    elseif wallRotation == 1 then
      pos.y = pos.y + guiInfo.builderDetails.floorSize
    elseif wallRotation == 4 then
      pos.x = pos.x - guiInfo.builderDetails.floorSize
    elseif wallRotation == 3 then
      pos.y = pos.y
    end
    return pos
  else
    if wallRotation == 2 then
      pos.x = pos.x - guiInfo.builderDetails.floorSize
    elseif wallRotation == 1 then
      pos.y = pos.y + guiInfo.builderDetails.floorSize
    elseif wallRotation == 4 then
      pos.x = pos.x + guiInfo.builderDetails.floorSize
    elseif wallRotation == 3 then
      pos.y = pos.y - guiInfo.builderDetails.floorSize
    end
    return pos
  end
end

function getNewWallRotation(pos, wallRotation)
  wallRotation = wallRotation + 1
  wallRotation = wallRotation > 4 and wallRotation - 4 or wallRotation
  wallRotation = wallRotation < 1 and wallRotation + 4 or wallRotation

  if wallRotation == 3 then
    pos.x = pos.x
  elseif wallRotation == 2 then
    pos.y = pos.y + guiInfo.builderDetails.floorSize
  elseif wallRotation == 1 then
    pos.x = pos.x
  elseif wallRotation == 4 then
    pos.y = pos.y - guiInfo.builderDetails.floorSize
  end
  return pos, wallRotation
end

function checkWallPlaceByPos(posHit, rotation, pos, myRot)
  local rot = guiInfo.furniture.rotations[rotation]
  local position = Vector2(posHit.x + rot[2], posHit.y + rot[3])

  local posFix = fixDoorPosition(myRot)
  local currPos = Vector2(pos.x + posFix[1], pos.y + posFix[2])

  if getDistanceBetweenPoints2D(position.x, position.y, currPos.x, currPos.y) < 0.2 then
    return false
  end
  return true
end

function fixDoorPosition(rot)
  if not rot or not guiInfo.furniture.dorsRotation[rot] then return {0, 0} end
  return {-guiInfo.furniture.dorsRotation[rot][2], -guiInfo.furniture.dorsRotation[rot][3]}
end

function checkWallPlace(posHit, x, y, rotation)
  local wallRotation = rotation and rotation or getWallRotation(posHit, x, y)
  local rot = guiInfo.furniture.rotations[wallRotation]
  local position = Vector2(posHit.x + rot[2], posHit.y + rot[3])

  -- local checker = createObject(guiInfo.modelsID.wall, position.x, position.y, posHit.z + 1)
  -- setElementRotation(checker, 0, 0, rot[1])
  -- setElementInterior(checker, getElementInterior(localPlayer))
  -- setElementDimension(checker, getElementDimension(localPlayer))

  for i, v in pairs(guiInfo.buildedObjects) do
    local pos = Vector3(v:getPosition())
    local model = getElementModel(v)
    if position.x == pos.x and position.y == pos.y then
      return false
    end
  end
  for i, v in pairs(guiInfo.skeletonWalls) do
    local pos = Vector3(v:getPosition())
    local model = getElementModel(v)
    if position.x == pos.x and position.y == pos.y then
      return false
    end
  end
  return true
end

---- UTILS ----
function drawPositionLines(element)
  local pos = Vector3(element:getPosition())
  dxDrawLine3D(pos, pos.x+1.5, pos.y, pos.z, tocolor(255, 0, 0, 255), 2)
  dxDrawLine3D(pos, pos.x, pos.y+1.5, pos.z, tocolor(0, 255, 0, 255), 2)
  dxDrawLine3D(pos, pos.x, pos.y, pos.z+1.5, tocolor(0, 0, 255, 255), 2)
end

function drawDoorsPositionNeeded(element, rot)
  local pos = Vector3(element:getPosition())
  local model = getElementModel(element)
  local rot, _ = getDoorsRotation(element)

  local posFix = guiInfo.furniture.dorsModelRotation[model][rot]

  pos.x = pos.x - posFix[2]
  pos.y = pos.y - posFix[3]
  pos.z = pos.z + 0.1


  if rot == 1 then
    dxDrawLine3D(pos.x + guiInfo.builderDetails.floorSize/2, pos.y, pos.z, pos.x + guiInfo.builderDetails.floorSize/2, pos.y + guiInfo.builderDetails.floorSize, pos.z, tocolor(255, 0, 0, 255), 3)
    dxDrawLine3D(pos.x + guiInfo.builderDetails.floorSize, pos.y + guiInfo.builderDetails.floorSize/2, pos.z, pos.x, pos.y + guiInfo.builderDetails.floorSize/2, pos.z, tocolor(255, 0, 0, 255), 3)

    dxDrawLine3D(pos.x + guiInfo.builderDetails.floorSize/2, pos.y, pos.z, pos.x + guiInfo.builderDetails.floorSize/2, pos.y - guiInfo.builderDetails.floorSize, pos.z, tocolor(255, 0, 0, 255), 3)
    dxDrawLine3D(pos.x + guiInfo.builderDetails.floorSize, pos.y - guiInfo.builderDetails.floorSize/2, pos.z, pos.x, pos.y - guiInfo.builderDetails.floorSize/2, pos.z, tocolor(255, 0, 0, 255), 3)

  elseif rot == 3 then
    dxDrawLine3D(pos.x - guiInfo.builderDetails.floorSize/2, pos.y, pos.z, pos.x - guiInfo.builderDetails.floorSize/2, pos.y + guiInfo.builderDetails.floorSize, pos.z, tocolor(255, 0, 0, 255), 3)
    dxDrawLine3D(pos.x - guiInfo.builderDetails.floorSize, pos.y + guiInfo.builderDetails.floorSize/2, pos.z, pos.x, pos.y + guiInfo.builderDetails.floorSize/2, pos.z, tocolor(255, 0, 0, 255), 3)

    dxDrawLine3D(pos.x - guiInfo.builderDetails.floorSize/2, pos.y, pos.z, pos.x - guiInfo.builderDetails.floorSize/2, pos.y - guiInfo.builderDetails.floorSize, pos.z, tocolor(255, 0, 0, 255), 3)
    dxDrawLine3D(pos.x - guiInfo.builderDetails.floorSize, pos.y - guiInfo.builderDetails.floorSize/2, pos.z, pos.x, pos.y - guiInfo.builderDetails.floorSize/2, pos.z, tocolor(255, 0, 0, 255), 3)

  elseif rot == 2 then
    dxDrawLine3D(pos.x, pos.y - guiInfo.builderDetails.floorSize/2, pos.z, pos.x + guiInfo.builderDetails.floorSize, pos.y - guiInfo.builderDetails.floorSize/2, pos.z, tocolor(255, 0, 0, 255), 3)
    dxDrawLine3D(pos.x + guiInfo.builderDetails.floorSize/2, pos.y, pos.z, pos.x + guiInfo.builderDetails.floorSize/2, pos.y - guiInfo.builderDetails.floorSize, pos.z, tocolor(255, 0, 0, 255), 3)

    dxDrawLine3D(pos.x - guiInfo.builderDetails.floorSize, pos.y - guiInfo.builderDetails.floorSize/2, pos.z, pos.x, pos.y - guiInfo.builderDetails.floorSize/2, pos.z, tocolor(255, 0, 0, 255), 3)
    dxDrawLine3D(pos.x - guiInfo.builderDetails.floorSize/2, pos.y, pos.z, pos.x - guiInfo.builderDetails.floorSize/2, pos.y - guiInfo.builderDetails.floorSize, pos.z, tocolor(255, 0, 0, 255), 3)

  elseif rot == 4 then
    dxDrawLine3D(pos.x + guiInfo.builderDetails.floorSize/2, pos.y, pos.z, pos.x + guiInfo.builderDetails.floorSize/2, pos.y + guiInfo.builderDetails.floorSize, pos.z, tocolor(255, 0, 0, 255), 3)
    dxDrawLine3D(pos.x, pos.y + guiInfo.builderDetails.floorSize/2, pos.z, pos.x + guiInfo.builderDetails.floorSize, pos.y + guiInfo.builderDetails.floorSize/2, pos.z, tocolor(255, 0, 0, 255), 3)

    dxDrawLine3D(pos.x - guiInfo.builderDetails.floorSize/2, pos.y, pos.z, pos.x - guiInfo.builderDetails.floorSize/2, pos.y + guiInfo.builderDetails.floorSize, pos.z, tocolor(255, 0, 0, 255), 3)
    dxDrawLine3D(pos.x, pos.y + guiInfo.builderDetails.floorSize/2, pos.z, pos.x - guiInfo.builderDetails.floorSize, pos.y + guiInfo.builderDetails.floorSize/2, pos.z, tocolor(255, 0, 0, 255), 3)
  end
end

function dxDrawBorder(x, y, w, h, size, color)
	size = size or 2;

	dxDrawRectangle(x - size, y + h, w + (size * 2), size, color or tocolor(0, 0, 0, 180), postGUI);
	dxDrawRectangle(x - size, y, size, h, color or tocolor(0, 0, 0, 180), postGUI);
	dxDrawRectangle(x + w, y, size, h, color or tocolor(0, 0, 0, 180), postGUI);
	dxDrawRectangle(x - size, y - size, w + (size * 2), size, color or tocolor(0, 0, 0, 180), postGUI);
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

function getWallTextureIndex(obj)
  local px, py, pz = getCameraMatrix()
  local ox, oy, oz = getElementPosition(obj)
  local _, _, zr = getElementRotation(obj)
  local rot = findRotation(px, py, ox, oy)

  if zr == 0 then
    if rot <= 270 and rot >= 90 then
      return 2
    else
      return 1
    end

  elseif zr == 90 then
    return rot <= 180 and 1 or 2

  elseif zr == 180 then
    if rot <= 270 and rot >= 90 then
      return 1
    else
      return 2
    end

  elseif zr == 270 then
    return rot >= 180 and 1 or 2
  end

  return 1
end

function findRotation(x1, y1, x2, y2)
  local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
  return t < 0 and t + 360 or t
end

function getDoorCenterPosition(obj)
  local x, y, z = getPositionByVector(obj, Vector3(0.8, 0, 1.5))
  return Vector3(x, y, z)
end

function getPositionByVector(element, vec)
	local rot = Vector3(getElementRotation(element))
	local mat = Matrix(Vector3(getElementPosition(element)), rot)
	local newPos = mat:transformPosition(vec)
	return newPos.x, newPos.y, newPos.z, rot.z
end

function getPointFromDistanceRotation(x, y, dist, angle)
    local a = math.rad(90 - angle);
    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;
    return x+dx, y+dy;
end

function isMouseInPosition ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
    local sx, sy = guiGetScreenSize ( )
    local cx, cy = getCursorPosition ( )
    local cx, cy = ( cx * sx ), ( cy * sy )
    if ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) then
        return true
    else
        return false
    end
end

function cantPlaceMessage()
  exports.TR_noti:create("Bunu buraya yerleştiremezsin.", "error")
  return false
end



local helper = {
  skins = getValidPedModels(),

  vehicleIds = {400, 401, 402, 403, 404, 405, 406, 407, 408, 409, 410, 411, 412, 413, 414, 415,
    416, 417, 418, 419, 420, 421, 422, 423, 424, 425, 426, 427, 428, 429, 430, 431, 432, 433,
    434, 435, 436, 437, 438, 439, 440, 441, 442, 443, 444, 445, 446, 447, 448, 449, 450, 451,
    452, 453, 454, 455, 456, 457, 458, 459, 460, 461, 462, 463, 464, 465, 466, 467, 468, 469,
    470, 471, 472, 473, 474, 475, 476, 477, 478, 479, 480, 481, 482, 483, 484, 485, 486, 487,
    488, 489, 490, 491, 492, 493, 494, 495, 496, 497, 498, 499, 500, 501, 502, 503, 504, 505,
    506, 507, 508, 509, 510, 511, 512, 513, 514, 515, 516, 517, 518, 519, 520, 521, 522, 523,
    524, 525, 526, 527, 528, 529, 530, 531, 532, 533, 534, 535, 536, 537, 538, 539, 540, 541,
    542, 543, 544, 545, 546, 547, 548, 549, 550, 551, 552, 553, 554, 555, 556, 557, 558, 559,
    560, 561, 562, 563, 564, 565, 566, 567, 568, 569, 570, 571, 572, 573, 574, 575, 576, 577,
    578, 579, 580, 581, 582, 583, 584, 585, 586, 587, 588, 589, 590, 591, 592, 593, 594, 595,
    596, 597, 598, 599, 600, 601, 602, 603, 604, 605, 606, 607, 608, 609, 610, 611
  }
}




addCommandHandler("helper", function(cmd, model)
  if not helper.open then
    photoHelper()
  else
    photoHelperClose()
  end
end)

addCommandHandler("model", function(cmd, model)
  if not helper.open then return end
  createPreviewModel(tonumber(model))
end)

addCommandHandler("photo", function(cmd, type)
  if not helper.open then return end
  if type == "all" then
    helper.id = 1
    setTimer(createPhotos, 500, 1)
    print("Tüm mobilyaların fotoğraflarının oluşturulması " .. math.floor(#guiInfo.furnitureList * 1000) / 1000 .. "s sürecek")
  else
    takePhoto(getElementModel(helper.object))
  end
end)

function photoHelper()
  addEventHandler("onClientRender", root, photoHelperRender)
  createPreviewModel(400)
  helper.open = true
end

function photoHelperClose()
  helper.open = nil
  removeEventHandler("onClientRender", root, photoHelperRender)

  exports.TR_preview:destroyObjectPreview(helper.preview)
  destroyElement(helper.object)
end

function photoHelperRender()
  -- dxDrawRectangle(0, 0, sw, sh, tocolor(0, 177, 64, 255))
  dxDrawRectangle(0, 0, sw, sh, tocolor(17, 17, 17, 255))
  dxDrawRectangle(0/zoom, 0/zoom, 400/zoom, 300/zoom, tocolor(27, 27, 27, 255))
end

function createPreviewModel(model, photo)
  if model then
    if not isElement(helper.object) then
      helper.object = createObject(model, 0, 0, 0)
      -- helper.object = createVehicle(model, 0, 0, 0)
      -- setVehicleColor(helper.object, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255)
      -- helper.object = createPed(model, 0, 0, 0)

    else
      exports.TR_preview:destroyObjectPreview(helper.preview)
      destroyElement(helper.object)
      helper.object = createObject(model, 0, 0, 0)
      -- helper.object = createVehicle(model, 0, 0, 0, 0, 0, 0, "FOR SALE")
      -- setVehicleColor(helper.object, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255)
      -- helper.object = createPed(model, 0, 0, 0)
    end

    helper.rx = 5
    helper.ry = 357
    helper.rz = 34
    -- helper.rx = 0
    -- helper.ry = 4
    -- helper.rz = 222
    -- helper.preview = exports.TR_preview:createObjectPreview(helper.object, helper.rx, helper.ry, helper.rz, 0, 0, sw, sh, false, true)
    helper.preview = exports.TR_preview:createObjectPreview(helper.object, helper.rx, helper.ry, helper.rz, -70/zoom, 0/zoom, 500/zoom, 300/zoom, false, true)
    exports.TR_preview:setDistanceSpread(helper.preview, 1)
    exports.TR_preview:setPositionOffsets(helper.preview, -0.1, 1.4, 0.2)

    if photo then
      setTimer(takePhoto, 500, 1, model)
    end
  end
  bindKey("q", "down", changePhotoRot)
  bindKey("w", "down", changePhotoRot)
  bindKey("e", "down", changePhotoRot)
  bindKey("a", "down", changePhotoRot)
  bindKey("s", "down", changePhotoRot)
  bindKey("d", "down", changePhotoRot)
end

function changePhotoRot(btn, state)
  if btn == "q" then helper.rx = helper.rx + 1 > 360 and 0 or helper.rx + 1 end
  if btn == "w" then helper.ry = helper.ry + 1 > 360 and 0 or helper.ry + 1 end
  if btn == "e" then helper.rz = helper.rz + 1 > 360 and 0 or helper.rz + 1 end
  if btn == "a" then helper.rx = helper.rx - 1 < 0 and 360 or helper.rx - 1 end
  if btn == "s" then helper.ry = helper.ry - 1 < 0 and 360 or helper.ry - 1 end
  if btn == "d" then helper.rz = helper.rz - 1 < 0 and 360 or helper.rz - 1 end

  exports.TR_preview:destroyObjectPreview(helper.preview)
  helper.preview = exports.TR_preview:createObjectPreview(helper.object, helper.rx, helper.ry, helper.rz, 0, 0, 800/zoom, 800/zoom, false, true)
  exports.TR_preview:setDistanceSpread(helper.preview, 2)
  exports.TR_preview:setPositionOffsets(helper.preview, 0.04, 2, 0.1)
  -- exports.TR_preview:setPositionOffsets(helper.preview, 0.04, -1.2, 0.1)

  print(helper.rx, helper.ry, helper.rz)
end

function takePhoto(model)
  exports.TR_preview:saveRTToFile(helper.preview, "photos/"..model..".png")
  print("Fotoğraf çekildi (" .. model .. ")")
end

-- function createPhotos()
--   createPreviewModel(guiInfo.furnitureList[helper.id][1], true)
--   helper.id = helper.id + 1
--   if helper.id > #guiInfo.furnitureList then return end
--   setTimer(createPhotos, 2000, 1)
-- end

function createPhotos()
  createPreviewModel(helper.vehicleIds[helper.id], true)
  helper.id = helper.id + 1
  if helper.id > #helper.vehicleIds then return end
  setTimer(createPhotos, 2000, 1)
end

vehicleIds = {400, 401, 402, 403, 404, 405, 406, 407, 408, 409, 410, 411, 412, 413, 414, 415,
	416, 417, 418, 419, 420, 421, 422, 423, 424, 425, 426, 427, 428, 429, 430, 431, 432, 433,
	434, 435, 436, 437, 438, 439, 440, 441, 442, 443, 444, 445, 446, 447, 448, 449, 450, 451,
	452, 453, 454, 455, 456, 457, 458, 459, 460, 461, 462, 463, 464, 465, 466, 467, 468, 469,
	470, 471, 472, 473, 474, 475, 476, 477, 478, 479, 480, 481, 482, 483, 484, 485, 486, 487,
	488, 489, 490, 491, 492, 493, 494, 495, 496, 497, 498, 499, 500, 501, 502, 503, 504, 505,
	506, 507, 508, 509, 510, 511, 512, 513, 514, 515, 516, 517, 518, 519, 520, 521, 522, 523,
	524, 525, 526, 527, 528, 529, 530, 531, 532, 533, 534, 535, 536, 537, 538, 539, 540, 541,
	542, 543, 544, 545, 546, 547, 548, 549, 550, 551, 552, 553, 554, 555, 556, 557, 558, 559,
	560, 561, 562, 563, 564, 565, 566, 567, 568, 569, 570, 571, 572, 573, 574, 575, 576, 577,
	578, 579, 580, 581, 582, 583, 584, 585, 586, 587, 588, 589, 590, 591, 592, 593, 594, 595,
	596, 597, 598, 599, 600, 601, 602, 603, 604, 605, 606, 607, 608, 609, 610, 611
}

local file = fileCreate("vehicles.txt")
local text = ""
for i=400, 611 do
  text = string.format( "%s\"%s\", ",text, getVehicleNameFromModel(i))
end
fileWrite(file, text)
fileClose(file)