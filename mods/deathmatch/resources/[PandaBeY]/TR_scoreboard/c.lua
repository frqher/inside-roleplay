local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end


local settings = {
  x = (sx - 950/zoom)/2,
  y = (sy - 700/zoom)/2,
  w = 950/zoom,
  h = 700/zoom,

  maxPlayers = 600,
  displayMax = 13,

  sortBy = "ID",

  fonts = {
    online = exports.TR_dx:getFont(12),
    onlineCount = exports.TR_dx:getFont(20),

    data = exports.TR_dx:getFont(13),
    info = exports.TR_dx:getFont(10),
  },
}

Scoreboard = {}
Scoreboard.__index = Scoreboard

function Scoreboard:create(...)
  local instance = {}
  setmetatable(instance, Scoreboard)

  if instance:constructor(...) then
    return instance
  end
  return false
end

function Scoreboard:constructor(...)
  self.players = {}
  self.playersList = {}
  self.search = ""
  self.pingError = 0

  -- Static values
  self.func = {}
  self.func.switch = function(...) self:switch(...) end
  self.func.render = function(...) self:render(...) end
  self.func.scrollList = function(...) self:scrollList(...) end
  self.func.checkPing = function() self:checkPing() end

  bindKey("tab", "down", self.func.switch)
  -- setTimer(self.func.checkPing, 1000, 0)
  return true
end

function Scoreboard:switch(...)
  if arg[2] == "down" then
    if self.opened then
      self:close()
    else
      self:open()
    end
  end
end

function Scoreboard:open(...)
  if not getElementData(localPlayer, "characterUID") then return end
  if not exports.TR_dx:canOpenGUI() then return end
  if exports.TR_chat:isChatOpened() then return end
  if self.opened then return end
  self.opened = true

  self.icons = {}
  self.icons.player = dxCreateTexture("files/images/man.png", "argb", true, "clamp")
  self.icons.gold = dxCreateTexture("files/images/crown.png", "argb", true, "clamp")
  self.icons.diamond = dxCreateTexture("files/images/diamond.png", "argb", true, "clamp")
  self.icons.mask = dxCreateTexture("files/images/mask.png", "argb", true, "clamp")
  self.icons.owner = dxCreateTexture("files/images/owner.png", "argb", true, "clamp")
  self.icons.adm = dxCreateTexture("files/images/adm.png", "argb", true, "clamp")
  self.icons.guard = dxCreateTexture("files/images/guard.png", "argb", true, "clamp")
  self.icons.supp = dxCreateTexture("files/images/supp.png", "argb", true, "clamp")
  self.icons.mod = dxCreateTexture("files/images/mod.png", "argb", true, "clamp")
  self.icons.dev = dxCreateTexture("files/images/dev.png", "argb", true, "clamp")

  self.searchIcon = dxCreateTexture("files/images/search.png", "argb", true, "clamp")
  self.searchEdit = exports.TR_dx:createEdit(settings.x + 300/zoom, settings.y + 25/zoom, 450/zoom, 40/zoom, "Oyuncu Ara", false, self.searchIcon)

  self:getPlayers()
  self.scroll = 0

  showCursor(true, false)
  exports.TR_dx:setOpenGUI(true)
  exports.TR_chat:setChatBlocked(true)
  addEventHandler("onClientRender", root, self.func.render)
  addEventHandler("onClientKey", root, self.func.scrollList)
  unbindKey("tab", "down", self.func.switch)
end

function Scoreboard:close(...)
  if not self.opened then return end
  self.opened = nil

  self.players = {}
  self.playersList = {}
  self.playersCount = 0

  self:removeIcons()

  showCursor(false)
  exports.TR_dx:destroyEdit(self.searchEdit)
  destroyElement(self.searchIcon)
  exports.TR_dx:setOpenGUI(false)
  exports.TR_chat:setChatBlocked(false)
  removeEventHandler("onClientRender", root, self.func.render)
  removeEventHandler("onClientKey", root, self.func.scrollList)

  setTimer(function() bindKey("tab", "down", self.func.switch) end, 50, 1)
end

function Scoreboard:removeIcons(...)
  for i, v in pairs(self.icons) do
    if isElement(v) then destroyElement(v) end
  end
  self.icons = nil
end

function Scoreboard:scrollList(...)
  if arg[1] == "mouse1" and arg[2] then self:click() return
  elseif arg[1] == "tab" and arg[2] then self:close() return end

  if #self.playersList <= settings.displayMax then return end
  if arg[1] == "mouse_wheel_down" then
    if self.scroll + settings.displayMax >= #self.playersList then self.scroll = #self.playersList - settings.displayMax return end
    self.scroll = self.scroll + 1

  elseif arg[1] == "mouse_wheel_up" then
    if self.scroll == 0 then return end
    self.scroll = self.scroll - 1
  end
end

function Scoreboard:getPlayers()
  for i, v in pairs(getElementsByType("player")) do
    if v ~= localPlayer then
      local id = getElementData(v, "ID")
      local org = getElementData(v, "characterOrg")
      local duty = getElementData(v, "characterDuty")
      local points = getElementData(v, "characterPoints")

      if id and getElementData(v, "characterData") then
        local img, color = self:getPlayerData(v)
        local name, hasMask = self:getPlayerName(v)

        if img then
          local data = {
            ID = id,
            name = name,
            plr = v,
            rank = img,
            color = {string.toRGB(color)},
            duty = duty and not hasMask and self:getOnlyUpper(duty[1]) or false,
            job = self:getPlayerJob(v, hasMask),
            dutyColor = duty and duty[2] or {220, 220, 220},
            org = org and not hasMask and not exports.TR_hud:isInDmZone(v) and org or "-",
            points = points or 0,
          }
          table.insert(self.players, data)
        end
      end
    end
  end

  self:sortList()
  self:addLocalPlayer()
  self.playersList = self.players
  self.playersCount = #self.players
end

function Scoreboard:sortList()
  if settings.sortBy == "ID" then
    table.sort(self.players, function(a, b) return a.ID < b.ID end)

  elseif settings.sortBy == "name" then
    table.sort(self.players, function(a, b) return utf8.upper(a.name) < utf8.upper(b.name) end)

  elseif settings.sortBy == "points" then
    table.sort(self.players, function(a, b) return a.points < b.points end)

  elseif settings.sortBy == "org" then
    local temp = {}
    for i, v in pairs(self.players) do
      if v.org ~= "-" then
        table.insert(temp, v)
      end
    end
    table.sort(temp, function(a, b) return utf8.upper(a.org) < utf8.upper(b.org) end)
    for i, v in pairs(self.players) do
      if v.org == "-" then
        table.insert(temp, #temp + 1, v)
      end
    end
    self.players = temp

  elseif settings.sortBy == "job" then
    local temp = {}
    for i, v in pairs(self.players) do
      if v.job ~= "-" then
        table.insert(temp, v)
      end
    end
    table.sort(temp, function(a, b) return utf8.upper(a.job) < utf8.upper(b.job) end)
    for i, v in pairs(self.players) do
      if v.job == "-" then
        table.insert(temp, #temp + 1, v)
      end
    end
    self.players = temp
  end
end

function Scoreboard:getPlayerJob(plr, hasMask)
  local job = getElementData(plr, "inJob")
  if job then
    if hasMask then return "-" end
    if job == "taxi" then return "#febb1bTaxi" end
    if job == "mechanic" then return "Mechanik" end
    return "İşsiz"
  end
  return "-"
end

function Scoreboard:findPlayer(...)
  self.playersList = {}
  local searchName = string.lower(arg[1])
  for i, v in pairs(self.players) do
    if string.find(string.lower(v.name), searchName) then
      table.insert(self.playersList, v)

    elseif string.find(v.ID, searchName) then
      table.insert(self.playersList, v)
    end
  end
end

function Scoreboard:addLocalPlayer()
  local id = getElementData(localPlayer, "ID")
  local org = getElementData(localPlayer, "characterOrg")
  local duty = getElementData(localPlayer, "characterDuty")
  local points = getElementData(localPlayer, "characterPoints")

  local img, color = self:getPlayerData(localPlayer)
  local name, hasMask = self:getPlayerName(localPlayer)
  local data = {
    ID = id,
    name = name,
    plr = localPlayer,
    rank = img,
    color = {string.toRGB(color)},
    duty = duty and not hasMask and self:getOnlyUpper(duty[1]) or false,
    job = self:getPlayerJob(localPlayer, hasMask),
    dutyColor = duty and duty[2] or {220, 220, 220},
    org = org and not hasMask and org or "-",
    points = points or 0,
  }
  table.insert(self.players, 1, data)
end

function Scoreboard:checkSearch()
  local text = guiGetText(self.searchEdit)
  if self.search ~= text then
    self:findPlayer(text)
    self.search = text
  end
end

function Scoreboard:getOnlyUpper(text)
  if text == "Inside News" then return "NEWS" end
  local upper = ""
  for c in text:gmatch"." do
    if c == string.upper(c) and c ~= " " then
      upper = upper .. c
    end
  end
  return upper
end

function Scoreboard:render()
  self:drawBackground(settings.x, settings.y, settings.w, settings.h, tocolor(17, 17, 17, 255), 5)
  dxDrawRectangle(settings.x, settings.y + 90/zoom, settings.w, 2/zoom, tocolor(212, 175, 55, 255))
  dxDrawImage(settings.x + 20/zoom, settings.y + 15/zoom, 200/zoom, 60/zoom, "files/images/logo.png", 0, 0, 0, tocolor(255, 255, 255, 255))

  dxDrawText("Aktif oyuncu", settings.x + settings.w - 130/zoom, settings.y + 23/zoom, settings.x + settings.w - 30/zoom, settings.y + 23/zoom, tocolor(200, 200, 200, 200), 1/zoom, settings.fonts.online, "center", "top")
  dxDrawText(string.format("%d/%d", self.playersCount, settings.maxPlayers), settings.x + settings.w - 130/zoom, settings.y + 35/zoom, settings.x + settings.w - 30/zoom, settings.y + 80/zoom, tocolor(240, 196, 55, 220), 1/zoom, settings.fonts.onlineCount, "center", "top")

  self:checkSearch()
  self:drawPlayers()
end

function Scoreboard:drawPlayers()
  if self:isMouseInPosition(settings.x + 30/zoom, settings.y + 106/zoom, 40/zoom, 30/zoom) or settings.sortBy == "ID" then
    dxDrawText("ID", settings.x + 40/zoom, settings.y + 110/zoom, settings.x + 60/zoom, settings.y + 140/zoom, tocolor(255, 255, 255, 230), 1/zoom, settings.fonts.data, "center", "top")
  else
    dxDrawText("ID", settings.x + 40/zoom, settings.y + 110/zoom, settings.x + 60/zoom, settings.y + 140/zoom, tocolor(220, 220, 220, 200), 1/zoom, settings.fonts.data, "center", "top")
  end
  if self:isMouseInPosition(settings.x + 110/zoom, settings.y + 106/zoom, 110/zoom, 30/zoom) or settings.sortBy == "name" then
    dxDrawText("İsim", settings.x + 120/zoom, settings.y + 110/zoom, settings.x + 380/zoom, settings.y + 140/zoom, tocolor(255, 255, 255, 230), 1/zoom, settings.fonts.data, "left", "top", true, true)
  else
    dxDrawText("İsim", settings.x + 120/zoom, settings.y + 110/zoom, settings.x + 380/zoom, settings.y + 140/zoom, tocolor(220, 220, 220, 200), 1/zoom, settings.fonts.data, "left", "top", true, true)
  end
  if self:isMouseInPosition(settings.x + 440/zoom, settings.y + 106/zoom, 60/zoom, 30/zoom) or settings.sortBy == "points" then
    dxDrawText("EXP.", settings.x + 430/zoom, settings.y + 110/zoom, settings.x + 510/zoom, settings.y + 140/zoom, tocolor(255, 255, 255, 230), 1/zoom, settings.fonts.data, "center", "top", true)
  else
    dxDrawText("EXP.", settings.x + 430/zoom, settings.y + 110/zoom, settings.x + 510/zoom, settings.y + 140/zoom, tocolor(220, 220, 220, 200), 1/zoom, settings.fonts.data, "center", "top", true)
  end
  if self:isMouseInPosition(settings.x + 505/zoom, settings.y + 106/zoom, 115/zoom, 30/zoom) or settings.sortBy == "org" then
    dxDrawText("Birlik", settings.x + 515/zoom, settings.y + 110/zoom, settings.x + settings.w - 160/zoom, settings.y + 140/zoom, tocolor(255, 255, 255, 230), 1/zoom, settings.fonts.data, "left", "top", true)
  else
    dxDrawText("Birlik", settings.x + 515/zoom, settings.y + 110/zoom, settings.x + settings.w - 160/zoom, settings.y + 140/zoom, tocolor(220, 220, 220, 200), 1/zoom, settings.fonts.data, "left", "top", true)
  end
  if self:isMouseInPosition(settings.x + settings.w - 240/zoom, settings.y + 106/zoom, 80/zoom, 30/zoom) or settings.sortBy == "job" then
    dxDrawText("İş", settings.x + settings.w - 240/zoom, settings.y + 110/zoom, settings.x + settings.w - 160/zoom, settings.y + 140/zoom, tocolor(255, 255, 255, 230), 1/zoom, settings.fonts.data, "center", "top", true)
  else
    dxDrawText("İş", settings.x + settings.w - 240/zoom, settings.y + 110/zoom, settings.x + settings.w - 160/zoom, settings.y + 140/zoom, tocolor(220, 220, 220, 200), 1/zoom, settings.fonts.data, "center", "top", true)
  end

  dxDrawText("Ping", settings.x + settings.w - 90/zoom, settings.y + 110/zoom, settings.x + settings.w - 10/zoom, settings.y + 140/zoom, tocolor(220, 220, 220, 200), 1/zoom, settings.fonts.data, "center", "top", true)

  local y = settings.y + 150/zoom
  for i = 1, settings.displayMax do
    if self.playersList[i + self.scroll] then
      local v = self.playersList[i + self.scroll]

      if isElement(v.plr) then
        dxDrawText(v.ID, settings.x + 40/zoom, y, settings.x + 60/zoom, y + 40/zoom, tocolor(220, 220, 220, 200), 1/zoom, settings.fonts.data, "center", "center")

        dxDrawImage(settings.x + 120/zoom, y + 10/zoom, 20/zoom, 20/zoom, v.rank, 0, 0, 0, tocolor(255, 255, 255, 255))
        dxDrawText(v.name, settings.x + 156/zoom, y, settings.x + 430/zoom, y + 40/zoom, tocolor(v.color[1], v.color[2], v.color[3], 200), 1/zoom, settings.fonts.data, "left", "center", true, false, false, false)
        dxDrawText(v.points, settings.x + 430/zoom, y, settings.x + 510/zoom, y + 40/zoom, tocolor(220, 220, 220, 200), 1/zoom, settings.fonts.data, "center", "center", true, true)
        dxDrawText(v.org, settings.x + 515/zoom, y, settings.x + settings.w - 250/zoom, y + 40/zoom, tocolor(220, 220, 220, 200), 1/zoom, settings.fonts.data, "left", "center", true, true)
        dxDrawText(v.duty and v.duty or v.job, settings.x + settings.w - 240/zoom, y, settings.x + settings.w - 160/zoom, y + 40/zoom, tocolor(v.dutyColor[1], v.dutyColor[2], v.dutyColor[3], 200), 1/zoom, settings.fonts.data, "center", "center", true, true, false, true)

        dxDrawImage(settings.x + settings.w - 55/zoom, y + 17/zoom, 11/zoom, 5/zoom, self:getPlayerPing(v.plr), 0, 0, 0, tocolor(255, 255, 255, 255))

        if self:isMouseInPosition(settings.x + settings.w - 65/zoom, y + 7/zoom, 31/zoom, 25/zoom) then
          local cx, cy = getCursorPosition()
          cx, cy = cx * sx, cy * sy

          local ping = string.format("%dms", getPlayerPing(v.plr))
          local width = dxGetTextWidth(ping, 1/zoom, settings.fonts.online)
          self:drawBackground(cx + 4, cy + 7, width + 10/zoom, 30/zoom, tocolor(27, 27, 27, 255), 5, true)
          dxDrawText(ping, (cx + 4) + 10/zoom, cy + 7, cx + 4 + width, cy + 7 + 30/zoom, tocolor(220, 220, 220, 200), 1/zoom, settings.fonts.online, "center", "center", false, false, true)
        end

        -- Useful icons
        if self:isMouseInPosition(settings.x + settings.w - 130/zoom, y + 4/zoom, 32/zoom, 32/zoom) then
          self:drawBackground(settings.x + settings.w - 130/zoom, y + 4/zoom, 32/zoom, 32/zoom, tocolor(27, 27, 27, 220), 5)
          dxDrawImage(settings.x + settings.w - 122/zoom, y + 12/zoom, 16/zoom, 16/zoom, "files/images/message.png", 0, 0, 0, tocolor(255, 255, 255, 255))
        else
          self:drawBackground(settings.x + settings.w - 130/zoom, y + 4/zoom, 32/zoom, 32/zoom, tocolor(27, 27, 27, 200), 5)
          dxDrawImage(settings.x + settings.w - 122/zoom, y + 12/zoom, 16/zoom, 16/zoom, "files/images/message.png", 0, 0, 0, tocolor(255, 255, 255, 200))
        end

        y = y + 40/zoom
      else
        table.remove(self.playersList, i + self.scroll)
      end
    end
  end
  dxDrawText("Bir oyuncuyu, üst kısımdaki arama kutusuna girerek Nick veya ID'ye göre arayabilirsiniz. Kategori adına dokunarak da listeyi sıralayabilirsiniz.", settings.x, settings.y + settings.h - 35/zoom, settings.x + settings.w, settings.y + settings.h, tocolor(220, 220, 220, 100), 1/zoom, settings.fonts.info, "center", "center", true)
end

function Scoreboard:setPrivateMessage(...)
  if arg[1] == localPlayer then
    exports.TR_noti:create("Kendi kendine yazamazsın.", "error")
    return
  end
  self:close()

  exports.TR_chat:setChatMessage(string.format("/sms %d ", arg[1]))
end

function Scoreboard:click()
  if self:isMouseInPosition(settings.x, settings.y + 106/zoom, settings.w, 30/zoom) then
    if self:isMouseInPosition(settings.x + 30/zoom, settings.y + 106/zoom, 40/zoom, 30/zoom) and settings.sortBy ~= "ID" then
      table.remove(self.players, 1)
      settings.sortBy = "ID"
      self:sortList()
      self:addLocalPlayer()
      self.playersList = self.players

    elseif self:isMouseInPosition(settings.x + 110/zoom, settings.y + 106/zoom, 110/zoom, 30/zoom) and settings.sortBy ~= "name" then
      table.remove(self.players, 1)
      settings.sortBy = "name"
      self:sortList()
      self:addLocalPlayer()
      self.playersList = self.players

    elseif self:isMouseInPosition(settings.x + 440/zoom, settings.y + 106/zoom, 60/zoom, 30/zoom) and settings.sortBy ~= "points" then
      table.remove(self.players, 1)
      settings.sortBy = "points"
      self:sortList()
      self:addLocalPlayer()
      self.playersList = self.players

    elseif self:isMouseInPosition(settings.x + 505/zoom, settings.y + 106/zoom, 115/zoom, 30/zoom) and settings.sortBy ~= "org" then
      table.remove(self.players, 1)
      settings.sortBy = "org"
      self:sortList()
      self:addLocalPlayer()
      self.playersList = self.players

    elseif self:isMouseInPosition(settings.x + settings.w - 240/zoom, settings.y + 106/zoom, 80/zoom, 30/zoom) and settings.sortBy ~= "job" then
      table.remove(self.players, 1)
      settings.sortBy = "job"
      self:sortList()
      self:addLocalPlayer()
      self.playersList = self.players
    end

  else
    local y = settings.y + 150/zoom
    for i = 1, settings.displayMax do
      if self.playersList[i + self.scroll] then
        if self:isMouseInPosition(settings.x + settings.w - 130/zoom, y + 4/zoom, 32/zoom, 32/zoom) then
          self:setPrivateMessage(self.playersList[i + self.scroll].ID)
          break
        end
        y = y + 40/zoom
      end
    end
  end
end

function Scoreboard:getPlayerName(plr)
  local id = getElementData(plr, "ID")
  local fakeName = getElementData(plr, "fakeName")
  if fakeName then return fakeName, true end
  if getElementData(plr, "characterMask") and exports.TR_hud:isInDmZone(plr) then
    return string.format("Bilinmeyen #%03d", id), true
  end
  return getPlayerName(plr), false
end

function Scoreboard:getPlayerData(plr)
  local rank = getElementData(plr, "adminDuty")
  if rank then return self:getAdminInfo(rank) end

  local data = getElementData(plr, "characterData")
  if not data then return false end

  if getElementData(plr, "characterMask") and exports.TR_hud:isInDmZone(plr) then return self.icons.mask, "#929ea8" end

  if data.premium == "gold" then
    return self.icons.gold, "#d6a306"
  elseif data.premium == "diamond" then
    return self.icons.diamond, "#31caff"
  end
  return self.icons.player, "#dddddd"
end

function Scoreboard:getAdminInfo(rank)
  if string.find(rank, "-s") then return self.icons.player, "#dddddd" end
  if string.find(rank, "owner") then return self.icons.owner, "#7e0f0f" end
  if string.find(rank, "guardian") then return self.icons.guard, "#e73f0b" end
  if string.find(rank, "admin") then return self.icons.adm, "#da1717" end
  if string.find(rank, "moderator") then return self.icons.mod, "#0a8f0b" end
  if string.find(rank, "support") then return self.icons.supp, "#1ba3f3" end
  if string.find(rank, "developer") then return self.icons.dev, "#9424b4" end
end

function Scoreboard:getPlayerPing(...)
  if not isElement(arg[1]) then return "files/images/ping/ping-4.png" end
  local ping = getPlayerPing(arg[1])
  if ping < 30 then return "files/images/ping/ping-0.png"
  elseif ping < 70 then return "files/images/ping/ping-1.png"
  elseif ping < 120 then return "files/images/ping/ping-2.png"
  elseif ping < 160 then return "files/images/ping/ping-3.png"
  elseif ping > 160 then return "files/images/ping/ping-4.png"
  end
end

function string.toRGB(hex)
  hex = string.gsub(hex, "#", "")
  return tonumber("0x"..string.sub(hex, 1, 2)), tonumber("0x"..string.sub(hex, 3, 4)), tonumber("0x"..string.sub(hex, 5, 6))
end

function Scoreboard:drawBackground(x, y, rx, ry, color, radius, post)
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

function Scoreboard:isMouseInPosition(x, y, width, height)
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



function Scoreboard:checkPing()
  if not getElementData(localPlayer, "characterUID") then return end
  local ping = getPlayerPing(localPlayer)

  if ping > 160 and not self.showedPing then
    self.pingError = self.pingError + 1

    if self.pingError >= 5 then
      self.showedPing = true
      self.pingNoti = exports.TR_noti:create("Zayıf internet bağlantısı algılandı. Herhangi bir zararlı eyleme sebebiyet vermemeniz için tüm hareketleriniz kısıtlanmıştır.", "noNetwork", false, true)
      setElementFrozen(localPlayer, true)
    end

  elseif ping < 160 and self.showedPing then
    self.pingError = self.pingError - 1

    if self.pingError < 3 then
      self.pingError = 0
      self.showedPing = nil
      exports.TR_noti:destroy(self.pingNoti)
      setElementFrozen(localPlayer, false)

    else
      setElementFrozen(localPlayer, true)
    end

  elseif self.showedPing then
    setElementFrozen(localPlayer, true)
  end
end




exports.TR_dx:setOpenGUI(false)
Scoreboard:create()