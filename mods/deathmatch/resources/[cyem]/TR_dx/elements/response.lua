local createdResponses = {}

Response = {}
Response.__index = Response

function Response:create(...)
  local instance = {}
  setmetatable(instance, Response)
  if instance:constructor(...) then
    return instance
  end
  return false
end

function Response:constructor(...)
  self.x = arg[1]
  self.y = arg[2]
  self.w = arg[3]
  self.h = arg[4]

  ---- STATIC VARIABLES ----
  self.defY = self.y
  self.hideY = sy + self.h
  self.dots = "."
  self.dTick = getTickCount()
  self.alpha = 0
  self.rot = 0
  self.anim = "hidden"
  self.tick = getTickCount()
  self.enabled = false

  return true
end




function Response:draw()
  if not self.enabled then return end

  dxDrawRectangle(self.x, self.y, self.w, self.h, tocolor(17, 17, 17, 255 * self.alpha), true)

  self.rot = self.rot >= 360 and self.rot - 360 or self.rot + 5
  dxDrawImage(self.x + 10/zoom, self.y + 5/zoom, 40/zoom, 40/zoom, guiData.response.spinner, -self.rot, 0, 0, tocolor(240, 196, 55, 255 * self.alpha), true)
  dxDrawText(self.text..self.dots, self.x + 60/zoom, self.y, self.x + self.w, self.y + self.h, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, getFont(13), "left", "center", false, false, true)

  self:animate()
  self:animateDots()
end

function Response:animateDots()
  if self.dots == "." then
    local progress = (getTickCount() - self.dTick)/300
    if progress >= 1 then
      self.dTick = getTickCount()
      self.dots = ".."
    end

  elseif self.dots == ".." then
    local progress = (getTickCount() - self.dTick)/300
    if progress >= 1 then
      self.dTick = getTickCount()
      self.dots = "..."
    end

  elseif self.dots == "..." then
    local progress = (getTickCount() - self.dTick)/300
    if progress >= 1 then
      self.dTick = getTickCount()
      self.dots = "."
    end
  end
end

function Response:animate()
  if self.anim == "show" then
    local progress = (getTickCount() - self.tick)/200
    self.alpha, self.y = interpolateBetween(self.sAlpha, self.hideY, 0, 1, self.defY, 0, progress, "OutQuad")
    if progress >= 1 then
      self.anim = "showed"
      self.tick = nil
      self.alpha = 1
    end

  elseif self.anim == "hide" then
    local progress = (getTickCount() - self.tick)/200
    self.alpha, self.y = interpolateBetween(self.sAlpha, self.defY, 0, 0, self.hideY, 0, progress, "OutQuad")
    if progress >= 1 then
      self.anim = "hidden"
      self.tick = nil
      self.alpha = 0
      self.enabled = false
    end
  end
end




function Response:isEnabled()
  return self.enabled
end

function Response:setEnabled(...)
  if arg[1] then
    self.sAlpha = self.alpha
    self.anim = "show"
    self.tick = getTickCount()
    self.enabled = true
    self.text = arg[2] and arg[2] or "Sunucunun yanıt vermesi bekleniyor"
  else
    self.sAlpha = self.alpha
    self.anim = "hide"
    self.tick = getTickCount()
  end
end




function createResponse(...)
  return Response:create(...)
end

function setResponseEnabled(...)
  createdResponse:setEnabled(...)
  return true
end

function isResponseEnabled(...)
  return createdResponse:isEnabled()
end

function renderResponse()
  if createdResponse then
    createdResponse:draw()
  end
end
addEventHandler("onClientRender", root, renderResponse)


createdResponse = createResponse(0, sy - 50/zoom, 350/zoom, 50/zoom)