addEvent("guiSwitchSelected", true)
createdSwitches = {}

Switch = {}
Switch.__index = Switch

function Switch:create(...)
  local instance = {}
  setmetatable(instance, Switch)

  if instance:constructor(...) then
    createdSwitches[instance.element] = instance
    return instance
  end
  return false
end

function Switch:constructor(...)
  self.x = arg[1]
  self.y = arg[2]
  self.w = arg[3]
  self.h = arg[4]
  self.selected = arg[5] or false

  --- STATIC VARIABLES ---
  self.alpha = 1
  self.alphaHover = 0
  self.clickProgress = self.selected and 1 or 0
  self.visible = true
  self.element = createElement("dx-switch")
  return true
end

function Switch:destroy(...)
  createdSwitches[self.element] = nil
  destroyElement(self.element)
  self = nil

  return true
end



function Switch:draw()
  if not self.visible then return end
  if self.hidding then self:hiddingDraw() end
  if self.showing then self:showingDraw() end
  self:hoverDraw()
  self:clickDraw()

  self:drawBackground(self.x, self.y, self.w, self.h, tocolor(37, 37, 37, 255 * self.alpha), 15, true)
  self:drawBackground(self.x, self.y, self.w, self.h, tocolor(42, 42, 42, 255 * self.alpha * self.alphaHover), 15, true)

  dxDrawImage(self.x + 4/zoom + (self.w - self.h) * self.clickProgress, self.y + 4/zoom, self.h - 8/zoom, self.h - 8/zoom, guiData.switch.circle, 0, 0, 0, tocolor(140, 140, 140, 255 * self.alpha), true)
  dxDrawImage(self.x + 4/zoom + (self.w - self.h) * self.clickProgress, self.y + 4/zoom, self.h - 8/zoom, self.h - 8/zoom, guiData.switch.circle, 0, 0, 0, tocolor(160, 160, 160, 255 * self.alpha * self.alphaHover), true)
  dxDrawImage(self.x + 4/zoom + (self.w - self.h) * self.clickProgress, self.y + 4/zoom, self.h - 8/zoom, self.h - 8/zoom, guiData.switch.circle, 0, 0, 0, tocolor(180, 180, 180, math.max(math.min(255 * self.alpha * self.clickProgress, 255), 0)), true)
  dxDrawImage(self.x + 4/zoom + (self.w - self.h) * self.clickProgress, self.y + 4/zoom, self.h - 8/zoom, self.h - 8/zoom, guiData.switch.circle, 0, 0, 0, tocolor(200, 200, 200, math.max(math.min(255 * self.alpha * self.clickProgress * self.alphaHover, 255), 0)), true)
end

function Switch:hoverDraw()
  if isMouseInPosition(self.x, self.y, self.w, self.h) then
    if (not self.hoverAnim or self.hoverAnim == "hidding") and not isResponseEnabled() then
      self.hoverAnim = "hovering"
      self.alphaHoverS = self.alphaHover
      self.hTick = getTickCount()
    end
  else
    if self.hoverAnim == "hovering" or self.hoverAnim == "hovered" then
      self.alphaHoverS = self.alphaHover
      self.hoverAnim = "hidding"
      self.hTick = getTickCount()
    end
  end

  if self.hoverAnim == "hovering" then
    local progress = (getTickCount() - self.hTick)/ 300
    self.alphaHover, _, _ = interpolateBetween(self.alphaHoverS, 0, 0, 1, 0, 0, progress, "OutQuad")
    if progress >= 1 then
      self.hoverAnim = "hovered"
      self.alphaHover = 1
      self.alphaHoverS = nil
      self.hTick = nil
    end

  elseif self.hoverAnim == "hidding" then
    local progress = (getTickCount() - self.hTick)/ 300
    self.alphaHover, _, _ = interpolateBetween(self.alphaHoverS, 0, 0, 0, 0, 0, progress, "OutQuad")
    if progress >= 1 then
      self.hoverAnim = nil
      self.alphaHover = 0
      self.alphaHoverS = nil
      self.hTick = nil
    end
  end
end

function Switch:clickDraw()
  if self.clickAnim == "showing" then
    local progress = (getTickCount() - self.cTick)/ 300
    self.clickProgress, _, _ = interpolateBetween(self.clickProgressS, 0, 0, 1, 0, 0, progress, "OutBack")
    if progress >= 1 then
      self.clickAnim = nil
      self.clickProgress = 1
      self.clickProgressS = nil
      self.cTick = nil
    end

  elseif self.clickAnim == "hidding" then
    local progress = (getTickCount() - self.cTick)/ 300
    self.clickProgress, _, _ = interpolateBetween(self.clickProgressS, 0, 0, 0, 0, 0, progress, "OutBack")
    if progress >= 1 then
      self.clickAnim = nil
      self.clickProgress = 0
      self.clickProgressS = nil
      self.cTick = nil
    end
  end
end

function Switch:hiddingDraw()
  local progress = (getTickCount() - self.hidding)/ self.actionTime
  self.alpha, _, _ = interpolateBetween(self.alphaCurrent, 0, 0, 0, 0, 0, progress, self.easing)
  if progress >= 1 then
    self.alphaCurrent = nil
    self.easing = nil
    self.hidding = nil
    self.actionTime = nil
    self.visible = nil
  end
end

function Switch:showingDraw()
  local progress = (getTickCount() - self.showing)/ self.actionTime
  self.alpha = interpolateBetween(self.alphaCurrent, 0, 0, 1, 0, 0, progress, self.easing)
  if progress >= 1 then
    self.alphaCurrent = nil
    self.easing = nil
    self.showing = nil
    self.actionTime = nil
  end
end




function Switch:click()
  if isMouseInPosition(self.x, self.y, self.w, self.h) and self.visible and not isResponseEnabled() and not isEscapeOpen() then
    self.selected = not self.selected
    self:setSelected(self.selected)
    triggerEvent("guiSwitchSelected", root, self.element)
  end
end

function Switch:setVisible(...)
  self.visible = arg[1]
end

function Switch:hide(...)
  if not self.visible then return end
  self.alphaCurrent = self.alpha
  self.hidding = getTickCount()
  self.actionTime = arg[1] or 500
  self.easing = arg[2] or "OutQuad"
  return true
end

function Switch:show(...)
  if self.visible then return end
  self.alphaCurrent = self.alpha
  self.showing = getTickCount()
  self.actionTime = arg[1] or 500
  self.easing = arg[2] or "OutQuad"
  self.visible = true
  return true
end

function Switch:setSelected(...)
  self.selected = arg[1]

  if self.selected then
    self.clickAnim = "showing"
    self.clickProgressS = self.clickProgress
    self.cTick = getTickCount()

  else
    self.clickAnim = "hidding"
    self.clickProgressS = self.clickProgress
    self.cTick = getTickCount()
  end
end


function Switch:drawBackground(x, y, rx, ry, color, radius, post)
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

function Switch:setOwner(...)
  self.owner = arg[1]
end

function Switch:getOwner()
  return self.owner
end



function createSwitch(...)
  local switch = Switch:create(...)
  switch:setOwner(getResourceName(sourceResource))

  return switch.element
end

function destroySwitch(...)
  if type(arg[1]) == "table" then
    for _, v in pairs(arg[1]) do
      createdSwitches[v]:destroy(arg[2])
    end
  else
    createdSwitches[arg[1]]:setVisible(arg[2])
  end
  return true
end

function setSwitchVisible(...)
  if type(arg[1]) == "table" then
    for _, v in pairs(arg[1]) do
      createdSwitches[v]:setVisible(arg[2])
    end
  else
    createdSwitches[arg[1]]:setVisible(arg[2])
  end
  return true
end

function showSwitch(...)
  if type(arg[1]) == "table" then
    for _, v in pairs(arg[1]) do
      createdSwitches[v]:show(arg[2], arg[3])
    end
  else
    createdSwitches[arg[1]]:show(arg[2], arg[3])
  end
  return true
end

function hideSwitch(...)
  if type(arg[1]) == "table" then
    for _, v in pairs(arg[1]) do
      createdSwitches[v]:hide(arg[2], arg[3])
    end
  else
    createdSwitches[arg[1]]:hide(arg[2], arg[3])
  end
  return true
end

function isSwitchSelected(...)
  return createdSwitches[arg[1]].selected
end

function setSwitchSelected(...)
  if type(arg[1]) == "table" then
    for _, v in pairs(arg[1]) do
      createdSwitches[v]:setSelected(arg[2])
    end
  else
    createdSwitches[arg[1]]:setSelected(arg[2])
  end
  return true
end



--- RENDER SWITCHES ---
function renderSwitches()
  for i, v in pairs(createdSwitches) do
    v:draw()
  end
end
addEventHandler("onClientRender", root, renderSwitches)

function clickSwitches(btn, state)
  if btn == "left" and state == "down" then
    for i, v in pairs(createdSwitches) do
      v:click()
    end
  end
end
addEventHandler("onClientClick", root, clickSwitches)