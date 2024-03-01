addEvent("guiCheckboxSelected", true)
createdChecks = {}

Checkbox = {}
Checkbox.__index = Checkbox

function Checkbox:create(...)
  local instance = {}
  setmetatable(instance, Checkbox)

  if instance:constructor(...) then
    createdChecks[instance.element] = instance
    return instance
  end
  return false
end

function Checkbox:constructor(...)
  self.x = arg[1]
  self.y = arg[2]
  self.w = arg[3]
  self.h = arg[4]
  self.selected = arg[5] or false
  self.text = arg[6] or false

  --- STATIC VARIABLES ---
  self.alpha = 1
  self.alphaHover = 0
  self.addTextSize = self.text and (dxGetTextWidth(self.text, 1/zoom, getFont(13)) + 10/zoom) or 0
  self.clickProgress = self.selected and 1 or 0
  self.visible = true
  self.element = createElement("dx-check")
  return true
end

function Checkbox:destroy(...)
  createdChecks[self.element] = nil
  destroyElement(self.element)
  self = nil

  return true
end



function Checkbox:draw()
  if not self.visible then return end
  if self.hidding then self:hiddingDraw() end
  if self.showing then self:showingDraw() end
  self:hoverDraw()
  self:clickDraw()

  dxDrawImage(self.x, self.y, self.w, self.h, guiData.checkbox.bg, 0, 0, 0, tocolor(37, 37, 37, 255 * self.alpha), true)
  dxDrawImage(self.x, self.y, self.w, self.h, guiData.checkbox.bg, 0, 0, 0, tocolor(42, 42, 42, 255 * self.alpha * self.alphaHover), true)

  if self.text then
    local color = 200 + 30 * self.alphaHover
    dxDrawText(self.text, self.x + self.w + 10/zoom, self.y, self.x + self.w + 20/zoom, self.y + self.h, tocolor(color, color, color, 200 * self.alpha), 1/zoom, getFont(13), "left", "center", false, false, true)
  end

  dxDrawImageSection(self.x + self.w/2 - (self.w/2 * self.clickProgress), self.y + self.h/2 - (self.h/2 * self.clickProgress), self.w * self.clickProgress, self.h * self.clickProgress, 0, 0, 64, 64, guiData.checkbox.check, 0, 0, 0, tocolor(190, 190, 190, 255 * self.alpha * self.clickProgress), true)
  dxDrawImageSection(self.x + self.w/2 - (self.w/2 * self.clickProgress), self.y + self.h/2 - (self.h/2 * self.clickProgress), self.w * self.clickProgress, self.h * self.clickProgress, 0, 0, 64, 64, guiData.checkbox.check, 0, 0, 0, tocolor(220, 220, 220, 255 * self.alpha * self.alphaHover), true)

  --dxDrawImage(self.x, self.y, self.w, self.h, guiData.checkbox.check, 0, 0, 0, tocolor(31, 147, 18, 255 * self.alpha * self.clickProgress), true)
end

function Checkbox:hoverDraw()
  if isMouseInPosition(self.x, self.y, self.w + self.addTextSize, self.h) then
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

function Checkbox:clickDraw()
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
    local progress = (getTickCount() - self.cTick)/ self.clickProgressAnimTime
    self.clickProgress, _, _ = interpolateBetween(self.clickProgressS, 0, 0, 0, 0, 0, progress, self.clickProgressAnim)
    if progress >= 1 then
      self.clickAnim = nil
      self.clickProgress = 0
      self.clickProgressS = nil
      self.clickProgressAnim = nil
      self.clickProgressAnimTime= nil
      self.cTick = nil
    end
  end
end

function Checkbox:hiddingDraw()
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

function Checkbox:showingDraw()
  local progress = (getTickCount() - self.showing)/ self.actionTime
  self.alpha = interpolateBetween(self.alphaCurrent, 0, 0, 1, 0, 0, progress, self.easing)
  if progress >= 1 then
    self.alphaCurrent = nil
    self.easing = nil
    self.showing = nil
    self.actionTime = nil
  end
end




function Checkbox:click()
  if isMouseInPosition(self.x, self.y, self.w + self.addTextSize, self.h) and self.visible and not isResponseEnabled() and not isEscapeOpen() then
    if #self:getGroup() > 0 and self.selected then return end
    self.selected = not self.selected
    self:setChecked(self.selected)
    triggerEvent("guiCheckboxSelected", root, self.element)
  end
end

function Checkbox:setVisible(...)
  self.visible = arg[1]
end

function Checkbox:hide(...)
  if not self.visible then return end
  self.alphaCurrent = self.alpha
  self.hidding = getTickCount()
  self.actionTime = arg[1] or 500
  self.easing = arg[2] or "OutQuad"
  return true
end

function Checkbox:show(...)
  if self.visible then return end
  self.alphaCurrent = self.alpha
  self.showing = getTickCount()
  self.actionTime = arg[1] or 500
  self.easing = arg[2] or "OutQuad"
  self.visible = true
  return true
end

function Checkbox:setGroup(...)
  self.group = arg[1]
end

function Checkbox:getGroup()
  if not self.group then return {} end
  return self.group
end

function Checkbox:setOwner(...)
  self.owner = arg[1]
end

function Checkbox:getOwner()
  return self.owner
end

function Checkbox:setChecked(...)
  self.selected = arg[1]

  if self.selected then
    self.clickAnim = "showing"
    self.clickProgressS = self.clickProgress
    self.cTick = getTickCount()

    for _, v in pairs(self:getGroup()) do
      if createdChecks[v] ~= self then
        createdChecks[v]:setChecked(false, true)
      end
    end

  else
    if arg[2] then
      self.clickProgressAnim = "Linear"
      self.clickProgressAnimTime = 100
    else
      self.clickProgressAnim = "InBack"
      self.clickProgressAnimTime = 300
    end
    self.clickAnim = "hidding"
    self.clickProgressS = self.clickProgress
    self.cTick = getTickCount()
  end
end



function createCheck(...)
  local checkbox = Checkbox:create(...)
  checkbox:setOwner(getResourceName(sourceResource))

  return checkbox.element
end

function destroyCheck(...)
  if type(arg[1]) == "table" then
    for _, v in pairs(arg[1]) do
      createdChecks[v]:destroy(arg[2])
    end
  else
    createdChecks[arg[1]]:setVisible(arg[2])
  end
  return true
end

function setCheckVisible(...)
  if type(arg[1]) == "table" then
    for _, v in pairs(arg[1]) do
      createdChecks[v]:setVisible(arg[2])
    end
  else
    createdChecks[arg[1]]:setVisible(arg[2])
  end
  return true
end

function showCheck(...)
  if type(arg[1]) == "table" then
    for _, v in pairs(arg[1]) do
      createdChecks[v]:show(arg[2], arg[3])
    end
  else
    createdChecks[arg[1]]:show(arg[2], arg[3])
  end
  return true
end

function hideCheck(...)
  if type(arg[1]) == "table" then
    for _, v in pairs(arg[1]) do
      createdChecks[v]:hide(arg[2], arg[3])
    end
  else
    createdChecks[arg[1]]:hide(arg[2], arg[3])
  end
  return true
end

function isCheckSelected(...)
  return createdChecks[arg[1]].selected
end

function setCheckSelected(...)
  if type(arg[1]) == "table" then
    for _, v in pairs(arg[1]) do
      createdChecks[v]:setChecked(arg[2])
    end
  else
    createdChecks[arg[1]]:setChecked(arg[2])
  end
  return true
end

function setCheckGroup(...)
  if type(arg[1]) == "table" then
    for _, v in pairs(arg[1]) do
      createdChecks[v]:setGroup(arg[1])
    end
  end
  return true
end

--- RENDER CHECKS ---
function renderChecks()
  for i, v in pairs(createdChecks) do
    v:draw()
  end
end
addEventHandler("onClientRender", root, renderChecks)

function clickChecks(btn, state)
  if btn == "left" and state == "down" then
    for i, v in pairs(createdChecks) do
      v:click()
    end
  end
end
addEventHandler("onClientClick", root, clickChecks)