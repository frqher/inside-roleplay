local createdLoadings = {}

Loading = {}
Loading.__index = Loading

function Loading:create(...)
  local instance = {}
  setmetatable(instance, Loading)
  if instance:constructor(...) then
    return instance
  end
  return false
end

function Loading:constructor(...)
  ---- STATIC VARIABLES ----
  self.anim = "hidden"
  self.tick = getTickCount()
  self.alpha = 0
  self.visible = false
  self.rot = 0

  self.x = (sx - 300/zoom)/2
  self.y = (sy - 500/zoom)/2
  self.w = 300/zoom
  self.h = 300/zoom

  self.dots = {
    {progress = 0, time = 300},
    {progress = 0, time = 300},
    {progress = 0, time = 300},
  }
  return true
end


function Loading:draw()
  if not self.visible then return end
  dxDrawImage(0, 0, sx, sy, self.img, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha), true)
  -- DODAĆ ALPHE
  dxDrawText("İpuçları", self.x, sy - 360/zoom, self.x + self.w, sy - 130/zoom, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, getFont(16), "center", "top", false, false, true)
  dxDrawText(self.tip, self.x, sy - 330/zoom, self.x + self.w, sy - 130/zoom, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, getFont(14), "center", "top", false, false, true)

  dxDrawImage(self.x, self.y, self.w, self.h, guiData.loading.bg.logo, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha), true)
  dxDrawText(self.text, self.x, sy - 180/zoom, self.x + self.w, sy - 130/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, getFont(13), "center", "center", false, false, true)

  self:animate()
  self:animateLoader()
end

function Loading:animateLoader()
  for i, v in pairs(self.dots) do
    if self.dots[i].anim == "up" then
      local progress = (getTickCount() - self.dots[i].tick)/200
      self.dots[i].progress = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "OutQuad")
      if progress >= 1 then
        self.dots[i].anim = "down"
        self.dots[i].tick = getTickCount()
        self.dots[i].progress = 1
      end

    elseif self.dots[i].anim == "down" then
      local progress = (getTickCount() - self.dots[i].tick)/200
      self.dots[i].progress = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "OutQuad")
      if progress >= 1 then
        self.dots[i].anim = "wait"
        self.dots[i].tick = getTickCount()
        self.dots[i].progress = 0
      end

    elseif self.dots[i].anim == "wait" then
      local progress = (getTickCount() - self.dots[i].tick)/500
      if progress >= 1 then
        self.dots[i].anim = "waited"
        self.dots[i].progress = 0
        if i == 3 then
          self:startDots()
        end
      end
    end

    local r, g, b = interpolateBetween(255, 255, 255, 240, 196, 55, self.dots[i].progress, "Linear")
    dxDrawImage((sx - 90/zoom)/2 + 30/zoom * (i-1), sy - 100/zoom - 10/zoom * self.dots[i].progress, 30/zoom, 30/zoom, guiData.checkbox.check, 0, 0, 0, tocolor(r, g, b, 255 * self.alpha), true)
  end
end

function Loading:startDots()
  for i, v in pairs(self.dots) do
    setTimer(function()
      self.dots[i].tick = getTickCount()
      self.dots[i].anim = "up"
      self.dots[i].progress = 0
    end, 100 * i, 1)
  end
end

function Loading:animate()
  if self.anim == "show" then
    local progress = (getTickCount() - self.tick)/200
    self.alpha = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "OutQuad")
    if progress >= 1 then
      self.anim = "showed"
      self.tick = getTickCount()
      self.alpha = 1
    end

  elseif self.anim == "showed" then
    local progress = (getTickCount() - self.tick)/self.time
    if progress >= 1 then
      self:hide()
    end

  elseif self.anim == "hide" then
    local progress = (getTickCount() - self.tick)/200
    self.alpha = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "OutQuad")
    if progress >= 1 then
      self.anim = "hidden"
      self.tick = nil
      self.alpha = 0
      self.visible = false
    end
  end
end

function Loading:hide(...)
  if not self.visible then return end
  self.tick = getTickCount()
  self.anim = "hide"

  self.count = 0;
    setTimer(function()
      if self.count == 5 then
        destroyElement(self.music)
      else
        setSoundVolume(self.music, (self.music and getSoundVolume(self.music) or 0) - 0.2)
      end
      self.count = self.count + 1
    end, 50, 6)

  return true
end

function Loading:show(...)
  if not self.visible then
    self.anim = "show"

    if isElement(self.music) then destroyElement(self.music) end
    self.music = playSound("files/sound/loading.mp3", true)
    setSoundVolume(self.music, 0)

    self.count = 0;
    setTimer(function()
      if self.count == 5 then
        setSoundVolume(self.music, 1)
      else
        setSoundVolume(self.music, (self.music and getSoundVolume(self.music) or 0) + 0.2)
      end
      self.count = self.count + 1
    end, 50, 6)

    self:startDots()

    self.img = guiData.loading.bg[math.random(1, guiData.loading.maxImg)]
    self.tip = guiData.loading.tips[math.random(1, #guiData.loading.tips)]
  end

  self.tick = getTickCount()
  self.time = arg[1] or 5000
  self.text = arg[2] or "Trwa wczytywanie"
  self.visible = true
  return true
end





function createLoading(...)
  return Loading:create(...)
end

function showLoading(...)
  createdLoading:show(...)
  return true
end

function hideLoading(...)
  createdLoading:hide(...)
  return true
end

function renderLoading()
  if createdLoading then
    createdLoading:draw()
  end
end
addEventHandler("onClientRender", root, renderLoading, false, "normal-1")

createdLoading = createLoading()
if not getElementData(localPlayer, "characterUID") then
  setTimer(function()
    createdLoading:show(9999999, "Sunucu dosyaları indiriliyor")
  end, 1000, 1)
end