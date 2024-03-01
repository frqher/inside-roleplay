local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
  mapSize = 6000,

  minZoom = 5,
  maxZoom = 1.7,
  blipZoom = 0.8,

  legend = {
    x = 0,
    y = 0,
    w = 400/zoom,
    h = sy,

    mapLegend = {},
  },

  fonts = {
    zone = exports.TR_dx:getFont(13),
		option = exports.TR_dx:getFont(12),
		legend = exports.TR_dx:getFont(11),
  },

  legendText = "#f0c437PPM #c8c8c8- Harita seçenekleri\n#f0c437LPM #c8c8c8- Haritayı kaydırma\n#f0c437Scroll #c8c8c8- Haritayı yakınlaştırın/uzaklaştırın",

  jobID = {
    ["EasterBoard Farm"] = "TR_apples",
    ["Container Delivery"] = "TR_containers",
    ["Chuckup Delivery"] = "TR_courier",
    ["Praca koszenia trawy"] = "TR_landmowers",
    ["The Well Stacked Pizza"] = "TR_pizzaboy",
    ["Siedziba SnowHeaven"] = "TR_snowPlow",
    ["San Fierro Tram Center"] = "TR_tram",
    ["Magazyn LosBox"] = "TR_warehouse",
    ["Sweeper Company"] = "TR_sweepers",
    ["Canny Bus Group"] = "TR_bus",
    ["Finder of Finds"] = "TR_diver",
    ["K.A.C.C. Military Fuels"] = "TR_dieselTransport",
    ["Praca w kamieniołomie"] = "TR_mine",
  },
}

local mapLegend = {
  {id = 22, text = "Punkt docelowy"},
  {id = 2,  text = "Prywatny pojazd"},
  {id = 37, text = "Pojazd publiczny"},

  {id = 48, text = "Kasyno"},
  {id = 19, text = "BBO Bank"},
  {id = 3,  text = "Urząd miasta"},
  {id = 44, text = "Kościół"},
  {id = 45, text = "Siłownia"},
  {id = 43, text = "AllOutMusic"},
  {id = 46, text = "Gabinet psychologa"},
  {id = 24, text = "Interglobal Television"},
  {id = 25, text = "San Andreas DMV"},
  {id = 36, text = "San Andreas Fraction Center"},
  {id = 51, text = "San Andreas Sailing School"},
  {id = 54, text = "San Andreas Flight School"},
  {id = 56, text = "San Andreas Diving School"},
  {id = 34, text = "Emergency Medical Services"},
  {id = 36, text = "San Andreas Fraction Center"},
  {id = 31, text = "San Andreas Fire Department"},
  {id = 33, text = "San Andreas Police Department"},
  {id = 57, text = "Emergency Road Services"},
  {id = 50, text = "San Andreas State Prison"},
  {id = 52, text = "San Andreas Pharmacy"},

  {id = 23, text = "Bankomat"},

  {id = 38, text = "Rybak"},
  {id = 21, text = "Taxi Center"},
  {id = 30, text = "Praca dorywcza"},

  {id = 14, text = "Seven Store"},
  {id = 5,  text = "Liquor & Deli"},
  {id = 6,  text = "69¢ Store / Roboi's Food Mart"},
  {id = 53, text = "Sklep AGD"},
  {id = 55, text = "Kwiaciarnia"},

  {id = 12, text = "Burger Shot"},
  {id = 13, text = "Cluckin'Bell"},
  {id = 11, text = "The Well Stacked Pizza"},
  {id = 16, text = "Rusty Brown's Ring Donuts"},

  {id = 27, text = "Ammunation"},

  {id = 8,  text = "ProLaps"},
  {id = 9,  text = "ZIP / Victim"},
  {id = 7,  text = "Binco / Sub Urban / Ranch"},
  {id = 10, text = "Didier Sachs / Kevin Clone / Gnocchi"},

  {id = 4,  text = "Bar"},
  {id = 15, text = "Klub nocny"},
  -- {id = 32, text = "Posiadłość"},

  {id = 28, text = "Złomowisko"},
  {id = 17, text = "Stacja paliw"},
  {id = 39, text = "Cygan"},
  {id = 18, text = "Salon samochodowy"},
  {id = 47, text = "Myjnia samochodowa"},
  {id = 29, text = "Giełda samochodowa"},
  {id = 20, text = "Mechanik samochodowy"},
  {id = 40, text = "Tuning wizualny"},
  {id = 41, text = "Tuning osiągów"},
  {id = 35, text = "Przechowalnia pojazdów"},
  {id = 49, text = "Wyścigi pojazdów"},
  {id = 42, text = "Parking Policyjny"},
  {id = 26, text = "Bramki autostradowe"},
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
  self.anim = 0
  self.showedBlips = {}

  self.zoom = 3
  self.mapSize = guiInfo.mapSize / self.zoom

  self:calculateRender()
  self.target = dxCreateRenderTarget(guiInfo.target.w, guiInfo.target.h)

  -- Static
  self.func = {}
  self.func.switch = function(...) self:switch(...) end
  self.func.render = function(...) self:render(...) end
  self.func.scrollClick = function(...) self:scrollClick(...) end
  addEventHandler("onClientKey", root, self.func.switch)

  self:loadShowedBlips()
  return true
end

function Map:calculateRender()
  guiInfo.target = {
    x = guiInfo.legend.w,
    y = 0,
    w = sx - guiInfo.legend.w,
    h = sy,
  }
end

function Map:switch(...)
  if arg[1] == "F11" then
    cancelEvent()

    if self.tick then return end
    if arg[2] then
      if self.opened then
        if exports.TR_dx:isResponseEnabled() then return false end
        self:close()
      else
        self:open()
      end
    end
  end

  if exports.TR_dx:isResponseEnabled() then return false end
  if self.tick or not self.opened then return end
  if arg[1] == "mouse_wheel_up" and arg[2] then
    if self:isMouseInPosition(guiInfo.target.x, guiInfo.target.y, guiInfo.target.w, guiInfo.target.h) then self:zoomMap("down") end

  elseif arg[1] == "mouse_wheel_down" and arg[2] then
    if self:isMouseInPosition(guiInfo.target.x, guiInfo.target.y, guiInfo.target.w, guiInfo.target.h) then self:zoomMap("up") end

  elseif arg[1] == "mouse1" and arg[2] then
    if self.options then
      if self:isMouseInPosition(self.options.windowPos.x, self.options.windowPos.y, 200/zoom, #self.avaliableOptions * 30/zoom + 32/zoom) then
        for i, v in pairs(self.avaliableOptions) do
          if self:isMouseInPosition(self.options.windowPos.x, self.options.windowPos.y + i * 30/zoom, 200/zoom, 30/zoom) then
            if v[2] == "gps" then
              local city = getZoneName(self.options.mapPos.x, self.options.mapPos.y, 0, true)
              local zone = getZoneName(self.options.mapPos.x, self.options.mapPos.y, 0)

              if city == "Unknown" and zone == "Unknown" then
                exports.TR_noti:create("Seçilen noktaya giden rota bulunamadı.", "error")
                removeGPS()
              else
                if #GPS.road > 0 then
                  exports.TR_noti:create("GPS devre dışı bırakıldı.", "gps")
                  removeGPS()
                else
                  findBestWay(self.options.mapPos.x, self.options.mapPos.y, true)
                end
              end
              self.options = nil

            elseif v[2] == "target" then
              local pos, int, dim = exports.TR_jobs:getPlayerTargetPos()
              if not pos then
                exports.TR_noti:create("Belirlediğiniz hedef yok.", "error")
                self.options = nil
                return
              end
              if int ~= 0 or dim ~= 0 then
                exports.TR_noti:create("Hedefiniz bir binanın içinde.", "error")
                self.options = nil
                return
              end

              findBestWay(pos.x, pos.y, true)
              self.options = nil

            elseif v[2] == "teleport" then
              local z = getGroundPosition(self.options.mapPos.x, self.options.mapPos.y, 1000)
              local x, y = self.options.mapPos.x, self.options.mapPos.y

              self.options = nil
              exports.TR_dx:setResponseEnabled(true)

              setElementPosition(localPlayer, x, y, z + 2)

              setTimer(function()
                local z = getGroundPosition(x, y, 1000)
                setElementPosition(localPlayer, x, y, z + 2)

                exports.TR_noti:create("Belirtilen konuma ışınlandınız.", "success")

                exports.TR_dx:setResponseEnabled(false)
              end, 1000, 1)
            end
            return
          end
        end
        return
      end
    end
    if self:isMouseInPosition(guiInfo.target.x, guiInfo.target.y, guiInfo.target.w, guiInfo.target.h) then
      self.centered = false
      local cx, cy = getCursorPosition()
      self.move = {cx * sx, cy * sy}
      self.options = nil
    end

  elseif arg[1] == "mouse1" and not arg[2] then
    self.move = nil

  elseif arg[1] == "mouse2" and arg[2] then
    local cx, cy = getCursorPosition()
    local mcx, mcy = (cx*sx) - guiInfo.target.x - guiInfo.target.w/2, (cy*sy) - guiInfo.target.y - guiInfo.target.h/2

    local mx, my = self:getWorldPositionFromMap(mcx, mcy)

    self.options = {
      mapPos = Vector2(mx, my),
      windowPos = Vector2(cx * sx, cy * sy),
    }

    if #GPS.road > 0 then
      self.avaliableOptions = {
        {"İşaret kaldır", "gps"},
      }
    else
      self.avaliableOptions = {
        {"İşaretle", "gps"},
        {"Hedefinize gidin", "target"},
      }
    end

    local isAdmin = exports.TR_admin:isPlayerDeveloper()
    if isAdmin then
      table.insert(self.avaliableOptions, {"Işınlanma", "teleport"})
    end
  end
end

function Map:centerOnPlayer()
  if not self.centered then return end
  local x, y = self:getCenterPoints()
  local px, py, _ = getElementPosition(localPlayer)

  self.x = x - px * (self.mapSize/6000)
  self.y = y + py * (self.mapSize/6000)
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
  if getElementDimension(localPlayer) ~= 0 or getElementInterior(localPlayer) ~= 0 then return end
  if #guiInfo.legend.mapLegend < 1 then

    for i, v in pairs(mapLegend) do
      table.insert(guiInfo.legend.mapLegend, {img = settings.textures[v.id], text = v.text})
    end
  end

  self.opened = true
  self.centered = true
  self.onBlip = {}
  self.legend = exports.TR_dx:createScroll(guiInfo.legend.x + 20/zoom, guiInfo.legend.y + 300/zoom, guiInfo.legend.w - 40/zoom, 650/zoom, 15, "multi", guiInfo.legend.mapLegend, "left")
  exports.TR_dx:setScrollVisible(self.legend, false)
  exports.TR_dx:showScroll(self.legend)
  self:selectScroll()

  exports.TR_chat:showCustomChat(false)
  exports.TR_dx:setOpenGUI(true)
  setHudVisible(false)

  self:centerOnPlayer()
  self:getBlips()

  self.tick = getTickCount()
  self.state = "opening"
  addEventHandler("onClientRender", root, self.func.render)
  addEventHandler("guiScrollbarClick", root, self.func.scrollClick)
  showCursor(true, false)
end

function Map:getBlips()
  self.blips = {}
  for i, v in pairs(getElementsByType("blip")) do
    local icon = getElementData(v, "icon") or getBlipIcon(v)
    if icon == 23 or icon == 37 then
      table.insert(self.blips, 1, v)
    else
      table.insert(self.blips, #self.blips, v)
    end
  end
end

function Map:selectScroll()
  for i, v in pairs(mapLegend) do
    if not self.showedBlips[v.id] then
      exports.TR_dx:setScrollSelection(self.legend, i, true)
    end
  end
end

function Map:close()
  self.opened = nil

  exports.TR_dx:hideScroll(self.legend)

  exports.TR_chat:showCustomChat(true)
  setHudVisible(true)

  self.tick = getTickCount()
  self.state = "closing"
  showCursor(false)

  removeEventHandler("guiScrollbarClick", root, self.func.scrollClick)
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
      exports.TR_dx:destroyScroll(self.legend)
      removeEventHandler("onClientRender", root, self.func.render)
    end
  end
end

function Map:render()
  self:animate()
  self:centerOnPlayer()
  self:renderTarget()
  self:drag()

  dxDrawRectangle(guiInfo.legend.x, guiInfo.legend.y, guiInfo.legend.w, guiInfo.legend.h, tocolor(17, 17, 17, 255 * self.anim))
  dxDrawRectangle(guiInfo.legend.x + guiInfo.legend.w - 3/zoom, 0, 3/zoom, sy, tocolor(212, 175, 55, 200 * self.anim))
  dxDrawImage(guiInfo.legend.x + 100/zoom, guiInfo.legend.y + 50/zoom, 200/zoom, 200/zoom, ":TR_login/files/images/logo.png", 0, 0, 0, tocolor(255, 255, 255, 255 * self.anim))
  dxDrawText(guiInfo.legendText, guiInfo.legend.x + 10/zoom, guiInfo.legend.y, guiInfo.legend.x + guiInfo.legend.w, guiInfo.legend.y + guiInfo.legend.h - 10/zoom, tocolor(200, 200, 200, 200 * self.anim), 1/zoom, guiInfo.fonts.legend, "left", "bottom", false, false, false, true)

  dxDrawImage(guiInfo.target.x, guiInfo.target.y, guiInfo.target.w, guiInfo.target.h, self.target, 0, 0, 0, tocolor(255, 255, 255, 255 * self.anim))

  dxDrawText("Göstermek/gizlemek için Blip'in üstüne tıklayın", guiInfo.legend.x, guiInfo.legend.y + 300/zoom, guiInfo.legend.x + guiInfo.legend.w, guiInfo.legend.y + 295/zoom, tocolor(160, 160, 160, 200 * self.anim), 1/zoom, guiInfo.fonts.legend, "center", "bottom", false, false, false, true)

  if self:isMouseInPosition(guiInfo.target.x, guiInfo.target.y, guiInfo.target.w, guiInfo.target.h) then
    local cx, cy = getCursorPosition()
    cx, cy = (cx*sx) - guiInfo.target.x - guiInfo.target.w/2, (cy*sy) - guiInfo.target.y - guiInfo.target.h/2

    local mx, my = self:getWorldPositionFromMap(cx, cy)
    local city = getZoneName(mx, my, 0, true)
    local zone = getZoneName(mx, my, 0)
    if city ~= "Unknown" and zone ~= "Unknown" then
      dxDrawText(string.format("%s | %s", city, zone), guiInfo.legend.x, guiInfo.legend.y + 950/zoom, guiInfo.legend.x + guiInfo.legend.w, guiInfo.legend.y + 1000/zoom, tocolor(255, 255, 255, 200 * self.anim), 1/zoom, guiInfo.fonts.zone, "center", "center")
    end
  end

  self:renderOptions()
end

function Map:renderOptions()
  if not self.options then return end

  self:drawOptionsBackground(self.options.windowPos.x, self.options.windowPos.y, 200/zoom, #self.avaliableOptions * 30/zoom + 32/zoom, tocolor(27, 27, 27, 255 * self.anim), 5)
  dxDrawText("Wybierz opcję", self.options.windowPos.x, self.options.windowPos.y, self.options.windowPos.x + 200/zoom, self.options.windowPos.y + 30/zoom, tocolor(240, 196, 55, 255 * self.anim), 1/zoom, guiInfo.fonts.zone, "center", "center")

  for i, v in pairs(self.avaliableOptions) do
    if self:isMouseInPosition(self.options.windowPos.x, self.options.windowPos.y + i * 30/zoom, 200/zoom, 30/zoom) then
      dxDrawImage(self.options.windowPos.x + 7/zoom, self.options.windowPos.y + 5/zoom + i * 30/zoom, 20/zoom, 20/zoom, "files/images/radar/"..v[2]..".png", 0, 0, 0, tocolor(255, 255, 255, 255 * self.anim))
      dxDrawText(v[1], self.options.windowPos.x + 34/zoom, self.options.windowPos.y + i * 30/zoom, self.options.windowPos.x + 200/zoom, self.options.windowPos.y + 30/zoom + i * 30/zoom, tocolor(255, 255, 255, 255 * self.anim), 1/zoom, guiInfo.fonts.option, "left", "center")
    else
      dxDrawImage(self.options.windowPos.x + 7/zoom, self.options.windowPos.y + 5/zoom + i * 30/zoom, 20/zoom, 20/zoom, "files/images/radar/"..v[2]..".png", 0, 0, 0, tocolor(255, 255, 255, 200 * self.anim))
      dxDrawText(v[1], self.options.windowPos.x + 34/zoom, self.options.windowPos.y + i * 30/zoom, self.options.windowPos.x + 200/zoom, self.options.windowPos.y + 30/zoom + i * 30/zoom, tocolor(255, 255, 255, 200 * self.anim), 1/zoom, guiInfo.fonts.option, "left", "center")
    end
  end
end

function Map:renderBlips()
  local selectedBlip = false

  for i, v in ipairs(self.blips) do
    local id = getElementData(v, "icon") or getBlipIcon(v)
    if self.showedBlips[id] then
      local x, y, _ = getElementPosition(v)
      local r, g, b = getBlipColor(v)
      x, y = self:getMapPositionFromWorld(x, y)

      dxDrawImage(x - 40/zoom/self.zoom * guiInfo.blipZoom, y - 80/zoom/self.zoom * guiInfo.blipZoom, 80/zoom/self.zoom * guiInfo.blipZoom, 80/zoom/self.zoom * guiInfo.blipZoom, settings.textures["bg"], 0, 0, 0, tocolor(r, g, b, 255 * self.anim))
      dxDrawImage(x - 40/zoom/self.zoom * guiInfo.blipZoom, y - 80/zoom/self.zoom * guiInfo.blipZoom, 80/zoom/self.zoom * guiInfo.blipZoom, 80/zoom/self.zoom * guiInfo.blipZoom, settings.textures[id], 0, 0, 0, tocolor(r, g, b, 255 * self.anim))

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

  if getKeyState("h") then
    for i, v in pairs(getElementsByType("marker", root)) do
      local icon = getElementData(v, "markerIcon")
      if icon == "house-bought" then
        local pos = Vector3(getElementPosition(v))
        local x, y = self:getMapPositionFromWorld(pos.x, pos.y)
        dxDrawImage(x - 40/zoom/self.zoom * guiInfo.blipZoom, y - 80/zoom/self.zoom * guiInfo.blipZoom, 80/zoom/self.zoom * guiInfo.blipZoom, 80/zoom/self.zoom * guiInfo.blipZoom, settings.textures["bg"], 0, 0, 0, tocolor(200, 0, 0, 255))
        dxDrawImage(x - 40/zoom/self.zoom * guiInfo.blipZoom, y - 80/zoom/self.zoom * guiInfo.blipZoom, 80/zoom/self.zoom * guiInfo.blipZoom, 80/zoom/self.zoom * guiInfo.blipZoom, settings.textures[32], 0, 0, 0, tocolor(200, 0, 0, 255))

      elseif icon == "house-free" then
        local pos = Vector3(getElementPosition(v))
        local x, y = self:getMapPositionFromWorld(pos.x, pos.y)
        dxDrawImage(x - 40/zoom/self.zoom * guiInfo.blipZoom, y - 80/zoom/self.zoom * guiInfo.blipZoom, 80/zoom/self.zoom * guiInfo.blipZoom, 80/zoom/self.zoom * guiInfo.blipZoom, settings.textures["bg"], 0, 0, 0, tocolor(0, 200, 0, 255))
        dxDrawImage(x - 40/zoom/self.zoom * guiInfo.blipZoom, y - 80/zoom/self.zoom * guiInfo.blipZoom, 80/zoom/self.zoom * guiInfo.blipZoom, 80/zoom/self.zoom * guiInfo.blipZoom, settings.textures[32], 0, 0, 0, tocolor(0, 200, 0, 255))
      end
    end
  end
  if self.options then return false end
  return selectedBlip
end

function Map:renderBlipInfo(blip)
  if self.onBlip.blip ~= blip then
    self.onBlip = {
      color = {getBlipColor(blip)},
      icon = getElementData(blip, "icon") or getBlipIcon(blip),
    }
    self.onBlip.name = self:getBlipName(blip, self.onBlip.icon)
    self.onBlip.w = dxGetTextWidth(self.onBlip.name, 1/zoom, guiInfo.fonts.zone) + 47/zoom

    if tonumber(self.onBlip.icon) == 30 then
      local jobID = guiInfo.jobID[self.onBlip.name]

      if jobID then
        local data = exports[jobID]:getJobDetails()

        self.onBlip.descTitle = "İş talepleri:"
        if data.require then
          local text = split(data.require, "\n")
          self.onBlip.descTable = text
        else
          self.onBlip.descTable = {"Gereksinim yok"}
        end
        self.onBlip.h = 62/zoom + #self.onBlip.descTable * 15/zoom
      end

    elseif tonumber(self.onBlip.icon) == 2 then
      local vehicle = getElementData(blip, "vehObject")
      if vehicle and blip then
        local vehicleID = getElementData(vehicle, "vehicleID")
        local modelName = getVehicleName(vehicle)

        self.onBlip.descTitle = "Araç bilgisi:"
        self.onBlip.descTable = {"ID: "..vehicleID, "Model: "..modelName, }

        self.onBlip.h = 62/zoom + #self.onBlip.descTable * 15/zoom
      end
    end
  end

  if not self.onBlip.h then self.onBlip.h = 40/zoom end

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

function Map:renderPlayers()
  for i, v in pairs(getElementsByType("player")) do
    if getElementInterior(v) == 0 and getElementDimension(v) == 0 then
      if v ~= localPlayer and getElementData(v, "characterUID") and not isInDmZone(v) and not getElementData(v, "inv") then
        local x, y, _ = getElementPosition(v)
        local r, g, b = 255, 255, 255
        x, y = self:getMapPositionFromWorld(x, y)
        dxDrawImage(x - 20/zoom/self.zoom * guiInfo.blipZoom, y - 20/zoom/self.zoom * guiInfo.blipZoom, 40/zoom/self.zoom * guiInfo.blipZoom, 40/zoom/self.zoom * guiInfo.blipZoom, settings.textures[0], 0, 0, 0, tocolor(r, g, b, 255 * self.anim))
      end
    end
  end
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

  self:renderGPS()
  self:renderPlayers()
  dxDrawImage(x - 25/zoom/self.zoom, y - 25/zoom/self.zoom, 50/zoom/self.zoom, 50/zoom/self.zoom, settings.textures[1], -rz, 0, 0, tocolor(255, 255, 255, 255 * self.anim))
  selectedBlip = self:renderBlips()
  dxSetRenderTarget()

  if selectedBlip then self:renderBlipInfo(selectedBlip) end
end

function Map:renderGPS()
  if not GPS.road then return end
  if #GPS.road > 0 and not GPS.running then
    for i, v in ipairs(GPS.road) do
      if GPS.road[i + 1] then
        local nextNode = GPS.road[i + 1]
        local nowX, nowY = self:getMapPositionFromWorld(v.posX, v.posY)
        local nextX, nextY = self:getMapPositionFromWorld(nextNode.posX, nextNode.posY)
        dxDrawLine(nowX, nowY, nextX, nextY, tocolor(255, 0, 0, 255 * self.anim), 8/self.zoom)
      end
    end
  end
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

function Map:setGPS()
  if exports.TR_dx:isResponseEnabled() then return false end
  if self:isMouseInPosition(guiInfo.target.x, guiInfo.target.y, guiInfo.target.w, guiInfo.target.h) then
    local cx, cy = getCursorPosition()
    cx, cy = (cx*sx) - guiInfo.target.x - guiInfo.target.w/2, (cy*sy) - guiInfo.target.y - guiInfo.target.h/2

    local mx, my = self:getWorldPositionFromMap(cx, cy)
    local city = getZoneName(mx, my, 0, true)
    local zone = getZoneName(mx, my, 0)
    if city == "Unknown" and zone == "Unknown" then
      exports.TR_noti:create("Seçilen noktaya giden rota bulunamadı.", "error")
      removeGPS()
    else
      if #GPS.road > 0 then
        exports.TR_noti:create("GPS devre dışı bırakıldı.", "gps")
        removeGPS()
      else
        findBestWay(mx, my, true)
      end
    end
  end
end

function Map:scrollClick(scroll, pos)
  if scroll == self.legend then
    self.showedBlips[mapLegend[pos].id] = not self.showedBlips[mapLegend[pos].id]
    self:saveShowedBlips()
  end
end

function Map:loadShowedBlips()
  local xml = xmlLoadFile("blips.xml")
  if not xml then
    xml = xmlCreateFile("blips.xml", "blips")

    self.showedBlips = {}
    for i = 0, 64 do
      local node = xmlCreateChild(xml, "blip")
      xmlNodeSetAttribute(node, "id", i)
      xmlNodeSetValue(node, i == 32 and 0 or 1)

      self.showedBlips[i] = i ~= 32 and true or false
    end

    xmlSaveFile(xml)
    xmlUnloadFile(xml)
    return
  end

  for _, node in pairs(xmlNodeGetChildren(xml)) do
    local value = xmlNodeGetValue(node)
    local id = xmlNodeGetAttribute(node, "id")
    if tonumber(id) ~= nil then
      self.showedBlips[tonumber(id)] = tonumber(value) > 0 and true or false
    end
  end
  xmlUnloadFile(xml)
end

function Map:saveShowedBlips()
  local xml = xmlLoadFile("blips.xml")
  if not xml then return end

  for _, node in pairs(xmlNodeGetChildren(xml)) do
    local value = xmlNodeGetValue(node)
    local id = xmlNodeGetAttribute(node, "id")

    if not self.showedBlips[tonumber(id)] then
      xmlNodeSetValue(node, 0)
    else
      xmlNodeSetValue(node, 1)
    end
  end
  xmlSaveFile(xml)
  xmlUnloadFile(xml)
end

function Map:getShowedBlips()
  return self.showedBlips
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

local map = Map:create()

function getShowedBlips()
  return map:getShowedBlips()
end

exports.TR_dx:setOpenGUI(false)