local sx, sy = guiGetScreenSize()

zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local radioData = {
  anim = "hidden",
  alpha = 0,

  selected = 1,
  selectedSound = 1,

  font = exports.TR_dx:getFont(16),

  radioTable = {
    {"Radio OFF", "", id = 1},
    -- {"AllOutMusic", "https://s3.slotex.pl/shoutcast/7620/stream?sid=1", id = 25},
    {"977 Today's Hits", "https://playerservices.streamtheworld.com/api/livestream-redirect/977_HITSAAC_SC", id = 2},
    {"CK 105.5 FM", "https://playerservices.streamtheworld.com/api/livestream-redirect/WWCKFMAAC_SC", 0.8, id = 3},
    {"100hitz - Hot Hitz", "https://onlineradiobox.com/json/us/100hitzhothitz/play?platform=web", id = 4},
    {"Z108", "https://onlineradiobox.com/json/us/z108/play?platform=web", id = 5},
    {"011.FM - The Office Mix", "https://onlineradiobox.com/json/us/011fm/play?platform=web", id = 6},
    {"Family Radio Network", "https://playerservices.streamtheworld.com/api/livestream-redirect/FAMILYRADIO_EASTAAC.aac", id = 7},
    {"181.FM The Mix", "https://onlineradiobox.com/json/us/181fmthemix/play?platform=web", id = 8},
    {"chilly.fm", "http://radio.streemlion.com:1170/stream", id = 9},
    {"HOT 810 Radio", "https://onlineradiobox.com/json/us/hot810/play?platform=web", id = 10},
    {"113.FM K-Pop", "https://113fm.cdnstream1.com/1789_128?cb=742761.mp3", 0.4, id = 11},
    {"Radio Bristol Americana", "https://onlineradiobox.com/json/us/wbcmamericana/play?platform=web", 0.3, id = 12},
    {"105 Oldschool", "http://stream01.my105.ch/my105oldschool.mp3", id = 13},
    {"Kiss FM", "http://online.kissfm.ua/KissFM_Trendz", id = 14},
    {"CashX", "https://cxfm.stream.laut.fm/cxfm", id = 15},
    {"R&B Nightclub", "http://ice.onestreaming.com/athenspartyrnb", id = 16},
    {"Lowrider Cut", "http://46.20.3.246/stream/50/", id = 17},
    {"Progressive Hits", "https://jivn.stream.laut.fm/jivn", id = 18},
    {"Classic Joints", "http://hemnos.cdnstream.com/1674_128", id = 19},
    {"Q-DANCE", "http://149.11.65.228:3690/Q_DANCE_SC", id = 20},
    {"HOT 107.9", "http://198.245.62.16:8066/", id = 21},
    {"RMF FM", "http://www.rmfon.pl/n/rmffm.pls", id = 22},
    {"RMF MAXXX", "http://www.rmfon.pl/n/rmfmaxxx.pls", id = 23},
    {"ANTY RADIO", "http://ant-kat.cdn.eurozet.pl:8604/listen.pls", id = 24},
  },

  blocked = {
    ["BMX"] = true,
    ["Quad"] = true,
  }
}




function renderRadio()
  renderRadioAnim()
  checkPlayerVehicle()

  if radioData.radioTable[radioData.selected - 1] then
    if fileExists("files/stations/"..(radioData.radioTable[radioData.selected - 1].id)..".png") then
      dxDrawImage(sx/2 - 300/zoom, 5/zoom, 150/zoom, 75/zoom, "files/stations/"..(radioData.radioTable[radioData.selected - 1].id)..".png", 0, 0, 0, tocolor(255, 255, 255, 140 * radioData.alpha))
    end
  end
  if fileExists("files/stations/"..(radioData.radioTable[radioData.selected].id)..".png") then
    dxDrawImage(sx/2 - 100/zoom, 10/zoom, 200/zoom, 100/zoom, "files/stations/"..(radioData.radioTable[radioData.selected].id)..".png", 0, 0, 0, tocolor(255, 255, 255, 245 * radioData.alpha))
    dxDrawText(radioData.radioTable[radioData.selected][1], sx/2, 160/zoom, sx/2, 100/zoom, tocolor(220, 220, 220, 245 * radioData.alpha), 1.0, radioData.font, "center", "center")
  end
  if radioData.radioTable[radioData.selected + 1] then
    if fileExists("files/stations/"..(radioData.radioTable[radioData.selected + 1].id)..".png") then
      dxDrawImage(sx/2 + 150/zoom, 5/zoom, 150/zoom, 75/zoom, "files/stations/"..(radioData.radioTable[radioData.selected + 1].id)..".png", 0, 0, 0, tocolor(255, 255, 255, 140 * radioData.alpha))
    end
  end
end

function renderRadioAnim()
  if radioData.anim == "showing" then
    local progress = (getTickCount() - radioData.animTime) / 500
    radioData.alpha = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "Linear")

    if progress > 1 then
      radioData.anim = "showed"
      radioData.animTime = getTickCount()
    end

  elseif radioData.anim == "showed" then
    local progress = (getTickCount() - radioData.animTime) / 2000

    if progress > 1 then
      radioData.anim = "hiding"
      radioData.animTime = getTickCount()
    end

  elseif radioData.anim == "hiding" then
    local progress = (getTickCount() - radioData.animTime) / 500
    radioData.alpha = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "Linear")

    if progress > 1 then
      radioData.anim = "hidden"
    end
   end
end

function checkPlayerVehicle()
  local veh = getPedOccupiedVehicle(localPlayer)
  if not veh then
    removeRadio()
  end
end




function createRadio()
  if radioData.open then return end
  if radioData.blocked[getVehicleType(getPedOccupiedVehicle(localPlayer))] then return end
  radioData.open = true
  setRadioChannel(0)

  bindKey("mouse_wheel_up", "both", switchRadio)
  bindKey("mouse_wheel_down", "both", switchRadio)
  bindKey("r", "both", switchRadio)
  addEventHandler("onClientRender", root, renderRadio)

  local seat = getPedOccupiedVehicleSeat(localPlayer)
  if seat ~= 0 then radioMusicUpdate() end
end


function removeRadio()
  if not radioData.open then return end
  radioData.open = nil

  if isTimer(radioData.radioTimer) then killTimer(radioData.radioTimer) end
  if isElement(radioData.radioSound) then destroyElement(radioData.radioSound) end

  radioData.selectedSound = nil

  unbindKey("mouse_wheel_up", "both", switchRadio)
  unbindKey("mouse_wheel_down", "both", switchRadio)
  unbindKey("r", "both", switchRadio)
  removeEventHandler("onClientRender", root, renderRadio)
end

function radioMusicUpdate()
  if not radioData.open then return end
  local vehicle = getPedOccupiedVehicle(localPlayer)
  if not vehicle then return end

  local radioChannel = getElementData(vehicle, "vehicleRadio")
  playRadio(radioChannel)
  setTimer(radioMusicUpdate, 2000, 1)
end

function switchRadio(key, state)
  if not exports.TR_dx:canOpenGUI() then return end
  if exports.TR_vehicleSignals:isGuiOpened() then return end

	local veh = getPedOccupiedVehicle(localPlayer)
  if not veh then return end

  local seat = getPedOccupiedVehicleSeat(localPlayer)
  if seat == 0 then
    if key == "mouse_wheel_up" and state == "down" then
  		if radioData.selected == #radioData.radioTable then return end
      radioData.selected = radioData.selected + 1

      playRadio(radioData.selected)
      if radioData.anim == "hidden" or radioData.anim == "hiding" then
        radioData.animTime = getTickCount()
        radioData.anim = "showing"

      elseif radioData.anim == "showed" then
        radioData.animTime = getTickCount()
        radioData.anim = "showed"
      end

  	elseif key == "mouse_wheel_down" and state == "down" then
  		if radioData.selected == 1 then return end
      radioData.selected = radioData.selected - 1

      playRadio(radioData.selected)
      if radioData.anim == "hidden" or radioData.anim == "hiding" then
        radioData.animTime = getTickCount()
        radioData.anim = "showing"

      elseif radioData.anim == "showed" then
        radioData.animTime = getTickCount()
        radioData.anim = "showed"
      end

  	elseif key == "r" and state == "down" then
      radioData.selected = radioData.selected + 1
      if radioData.selected > #radioData.radioTable then radioData.selected = 1 end

      playRadio(radioData.selected)
      if radioData.anim == "hidden" or radioData.anim == "hiding" then
        radioData.animTime = getTickCount()
        radioData.anim = "showing"

      elseif radioData.anim == "showed" then
        radioData.animTime = getTickCount()
        radioData.anim = "showed"
      end
    end
  end
end

function playRadio(station)
  if station == radioData.selectedSound then return end
  if isElement(radioData.radioSound) then destroyElement(radioData.radioSound) end
  if isTimer(radioData.radioTimer) then killTimer(radioData.radioTimer) end

  local seat = getPedOccupiedVehicleSeat(localPlayer)
  if seat == 0 then
    radioData.radioTimer = setTimer(function()
      local veh = getPedOccupiedVehicle(localPlayer)
      if not veh then return end
      setElementData(veh, "vehicleRadio", station)
    end, 2000, 1)
  end

  radioData.selectedSound = station

  if station == 1 then return end
  local stationData = radioData.radioTable[station]
  if not stationData then return end

  radioData.radioSound = playSound(stationData[2])
  if isElement(radioData.radioSound) then setSoundVolume(radioData.radioSound, stationData[3] and stationData[3] or 0.4) end
end


function vehicleEnter(plr)
  if plr == localPlayer then
    local seat = getPedOccupiedVehicleSeat(localPlayer)
    createRadio()
    radioData.selected = getElementData(getPedOccupiedVehicle(localPlayer), "vehicleRadio") or 1
    playRadio(radioData.selected)
  end
end
addEventHandler("onClientVehicleEnter", getRootElement(), vehicleEnter)

function vehicleStartExit(plr)
  if plr == localPlayer then
    local seat = getPedOccupiedVehicleSeat(localPlayer)
    removeRadio()
    radioData.selectedSound = nil
  end
end
addEventHandler("onClientVehicleStartExit", getRootElement(), vehicleStartExit)

if getPedOccupiedVehicle(localPlayer) then createRadio() end