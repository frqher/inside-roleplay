addEvent("guiScrollbarClick", true)

createdScrolls = {}

Scrollbar = {}
Scrollbar.__index = Scrollbar

function Scrollbar:create(...)
  local instance = {}
  setmetatable(instance, Scrollbar)

  if instance:constructor(...) then
    createdScrolls[instance.element] = instance
    return instance
  end
  return false
end

function Scrollbar:constructor(...)
  self.x = arg[1]
  self.y = arg[2]
  self.w = arg[3]
  self.h = arg[4]

  self.visibleCount = arg[5] or 5
  self.clickable = arg[6] and true or false
  self.multiSelect = arg[6] == "multi" and true or false
  self.data = self:prepareText(arg[7]) or {}

  self.textHorizontal = arg[8] or "center"
  self.textVertical = arg[9] or "center"

  self.w = #self.data > self.visibleCount and self.w - 10/zoom or self.w

  --- STATIC VARIABLES ---
  self.alpha = 1
  self.alphaHover = 0
  self.scroll = 0
  self.barHover = 0
  self.visible = true
  self.hoverEffects = {}
  self.selected = {}
  self.background = true
  self.rowH = math.floor(self.h/self.visibleCount)
  self.h = self.rowH * self.visibleCount
  self.element = createElement("dx-scroll")

  return true
end

function Scrollbar:destroy()
  createdScrolls[self.element] = nil
  destroyElement(self.element)
  self = nil

  return true
end




function Scrollbar:draw()
  if not self.visible then return end
  if self.hidding then self:hiddingDraw() end
  if self.showing then self:showingDraw() end

  for i = 1, self.visibleCount do
    local id = i + self.scroll
    if self.data[id] then self:hoverDraw(i, id) end
    local alpha = 255
    if not self.background then alpha = 0 end

    if i == 1 then
      if self.visibleCount < #self.data then
        self:drawUpLeft(self.x, self.y + self.rowH * (i-1), self.w, self.rowH, tocolor(37, 37, 37, alpha * self.alpha), 5, true)
      else
        self:drawUp(self.x, self.y + self.rowH * (i-1), self.w, self.rowH, tocolor(37, 37, 37, alpha * self.alpha), 5, true)
      end

    elseif i == self.visibleCount or id == #self.data then
      if self.visibleCount < #self.data then
        self:drawDownLeft(self.x, self.y + self.rowH * (i-1), self.w, self.rowH, tocolor(37, 37, 37, alpha * self.alpha), 5, true)
      else
        self:drawDown(self.x, self.y + self.rowH * (i-1), self.w, self.rowH, tocolor(37, 37, 37, alpha * self.alpha), 5, true)
      end
    else
      dxDrawRectangle(self.x, self.y + self.rowH * (i-1), self.w, self.rowH, tocolor(37, 37, 37, alpha * self.alpha), true)
    end

    local textColor = {200, 200, 200}
    if self.clickable then
      local color = self.selected[id] and {27, 27, 27} or {32, 32, 32}
      textColor = self.selected[id] and {160, 160, 160} or textColor

      local clickHover = self.hoverEffects[id] and self.hoverEffects[id].alphaHover or 0
      clickHover = self.selected[id] and 1 or clickHover

      if i == 1 then
        if self.visibleCount < #self.data then
          self:drawUpLeft(self.x, self.y + self.rowH * (i-1), self.w, self.rowH, tocolor(color[1], color[2], color[3], alpha * self.alpha * clickHover), 5, true)
        else
          self:drawUp(self.x, self.y + self.rowH * (i-1), self.w, self.rowH, tocolor(color[1], color[2], color[3], alpha * self.alpha * clickHover), 5, true)
        end

      elseif i == self.visibleCount or id == #self.data then
        self:drawDown(self.x, self.y + self.rowH * (i-1), self.w, self.rowH, tocolor(color[1], color[2], color[3], alpha * self.alpha * clickHover), 5, true)
      else
        dxDrawRectangle(self.x, self.y + self.rowH * (i-1), self.w, self.rowH, tocolor(color[1], color[2], color[3], 255 * self.alpha * clickHover), true)
      end
    end

    if type(self.data[id]) == "table" then
      dxDrawImage(self.x + 10/zoom, self.y + self.rowH * (i-1) + 4/zoom, self.rowH - 8/zoom, self.rowH - 8/zoom, self.data[id].img, 0, 0, 0, tocolor(textColor[1], textColor[2], textColor[3], 255 * self.alpha), true)
      if self.data[id] then dxDrawText(self.data[id].text, self.x + self.rowH + 10/zoom, self.y + self.rowH * (i-1) + 5/zoom, self.x + self.w - 10/zoom, self.y + self.rowH * i - 5/zoom, tocolor(textColor[1], textColor[2], textColor[3], 255 * self.alpha), 1/zoom, getFont(13), self.textHorizontal, self.textVertical, true, true, true, true) end
    else
      if self.data[id] then dxDrawText(self.data[id], self.x + 10/zoom, self.y + self.rowH * (i-1) + 5/zoom, self.x + self.w - 10/zoom, self.y + self.rowH * i - 5/zoom, tocolor(textColor[1], textColor[2], textColor[3], 255 * self.alpha), 1/zoom, getFont(13), self.textHorizontal, self.textVertical, true, true, true, true) end
    end
  end

  self:drawBar()
end


function Scrollbar:drawBar()
  if #self.data <= self.visibleCount then return end
  local b1 = self.h / #self.data
  self.barY = b1 * self.scroll
  self.barHeight = b1 * self.visibleCount

  if self.selectedScroll then
    self.barHover = 1
    self.scroll = math.min( math.max( math.floor((cursorY() - self.selectedScroll)/b1), 0), #self.data - self.visibleCount)
  elseif not isResponseEnabled() then
    self.barHover = math.min(math.max(isMouseInPosition(self.x + self.w, self.y + self.barY, 10/zoom, self.barHeight) and self.barHover + 0.2 or self.barHover - 0.2, 0), 1)
  end

  local alpha = 255
  if not self.background then alpha = 0 end
  self:drawRight(self.x + self.w, self.y, 10/zoom, self.h, tocolor(42, 42, 42, alpha * self.alpha), 5, true)
  self:drawBackground(self.x + self.w, self.y + self.barY, 10/zoom, self.barHeight, tocolor(212, 175, 55, 200 * self.alpha), 5, true)
  self:drawBackground(self.x + self.w, self.y + self.barY, 10/zoom, self.barHeight, tocolor(212, 175, 55, 230 * self.alpha * (self.barHover)), 5, true)
end

function Scrollbar:hoverDraw(i, id)
  if not self.hoverEffects[id] then self.hoverEffects[id] = {alphaHover = 0} end

  if isMouseInPosition(self.x, self.y + self.rowH * (i-1), self.w, self.rowH) and not isResponseEnabled() then
    if not self.hoverEffects[id].hoverAnim or self.hoverEffects[id].hoverAnim == "hidding" then
      self.hoverEffects[id].hoverAnim = "hovering"
      self.hoverEffects[id].alphaHoverS = self.hoverEffects[id].alphaHover
      self.hoverEffects[id].hTick = getTickCount()
    end
  else
    if self.hoverEffects[id].hoverAnim == "hovering" or self.hoverEffects[id].hoverAnim == "hovered" then
      self.hoverEffects[id].alphaHoverS = self.hoverEffects[id].alphaHover
      self.hoverEffects[id].hoverAnim = "hidding"
      self.hoverEffects[id].hTick = getTickCount()
    end
  end

  if self.hoverEffects[id].hoverAnim == "hovering" then
    local progress = (getTickCount() - self.hoverEffects[id].hTick)/ 300
    self.hoverEffects[id].alphaHover, _, _ = interpolateBetween(self.hoverEffects[id].alphaHoverS, 0, 0, 1, 0, 0, progress, "OutQuad")
    if progress >= 1 then
      self.hoverEffects[id].hoverAnim = "hovered"
      self.hoverEffects[id].alphaHover = 1
      self.hoverEffects[id].alphaHoverS = nil
      self.hoverEffects[id].hTick = nil
    end

  elseif self.hoverEffects[id].hoverAnim == "hidding" then
    local progress = (getTickCount() - self.hoverEffects[id].hTick)/ 300
    self.hoverEffects[id].alphaHover, _, _ = interpolateBetween(self.hoverEffects[id].alphaHoverS, 0, 0, 0, 0, 0, progress, "OutQuad")

    if progress >= 1 then
      self.hoverEffects[id] = {alphaHover = 0}
    end
  end
end

function Scrollbar:drawUp(x, y, rx, ry, color, radius, post)
  rx = rx - radius * 2
  ry = ry - radius * 2
  x = x + radius
  y = y + radius

  if (rx >= 0) and (ry >= 0) then
    dxDrawRectangle(x - radius, y, rx + radius * 2, ry + radius, color, post)
    dxDrawRectangle(x, y - radius, rx, radius, color, post)

    dxDrawCircle(x, y, radius, 180, 270, color, color, 7, 1, post)
    dxDrawCircle(x + rx, y, radius, 270, 360, color, color, 7, 1, post)
  end
end

function Scrollbar:drawDown(x, y, rx, ry, color, radius, post)
  rx = rx - radius * 2
  ry = ry - radius * 2
  x = x + radius
  y = y + radius

  if (rx >= 0) and (ry >= 0) then
    dxDrawRectangle(x, y + ry, rx, radius, color, post)
    dxDrawRectangle(x - radius, y - radius, rx + radius * 2, ry + radius, color, post)

    dxDrawCircle(x + rx, y + ry, radius, 0, 90, color, color, 7, 1, post)
    dxDrawCircle(x, y + ry, radius, 90, 180, color, color, 7, 1, post)
  end
end

function Scrollbar:drawUpLeft(x, y, rx, ry, color, radius, post)
  rx = rx - radius * 2
  ry = ry - radius * 2
  x = x + radius
  y = y + radius

  if (rx >= 0) and (ry >= 0) then
    dxDrawRectangle(x - radius, y, rx + radius * 2, ry + radius, color, post)
    dxDrawRectangle(x, y - radius, rx + radius, radius, color, post)

    dxDrawCircle(x, y, radius, 180, 270, color, color, 7, 1, post)
  end
end

function Scrollbar:drawDownLeft(x, y, rx, ry, color, radius, post)
  rx = rx - radius * 2
  ry = ry - radius * 2
  x = x + radius
  y = y + radius

  if (rx >= 0) and (ry >= 0) then
    dxDrawRectangle(x, y + ry, rx + radius, radius, color, post)
    dxDrawRectangle(x - radius, y - radius, rx + radius * 2, ry + radius, color, post)

    dxDrawCircle(x, y + ry, radius, 90, 180, color, color, 7, 1, post)
  end
end

function Scrollbar:drawRight(x, y, rx, ry, color, radius, post)
  rx = rx - radius * 2
  ry = ry - radius * 2
  x = x + radius
  y = y + radius

  if (rx >= 0) and (ry >= 0) then
    dxDrawRectangle(x - radius, y - radius, rx + radius, ry + radius * 2, color, post)
    dxDrawRectangle(x + rx, y, radius, ry, color, post)

    dxDrawCircle(x + rx, y, radius, 270, 360, color, color, 7, 1, post)
    dxDrawCircle(x + rx, y + ry, radius, 0, 90, color, color, 7, 1, post)
  end
end

function Scrollbar:drawBackground(x, y, rx, ry, color, radius, post)
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


function Scrollbar:hiddingDraw()
  local progress = (getTickCount() - self.hidding)/ (self.actionTime and self.actionTime or 500)
  self.alpha, _, _ = interpolateBetween(self.alphaCurrent, 0, 0, 0, 0, 0, progress, self.easing)
  if progress >= 1 then
    self.alphaCurrent = nil
    self.easing = nil
    self.hidding = nil
    self.actionTime = nil
    self.visible = nil
  end
end

function Scrollbar:showingDraw()
  local progress = (getTickCount() - self.showing)/ self.actionTime
  self.alpha = interpolateBetween(self.alphaCurrent, 0, 0, 1, 0, 0, progress, self.easing)
  if progress >= 1 then
    self.alphaCurrent = nil
    self.easing = nil
    self.showing = nil
    self.actionTime = nil
  end
end




function Scrollbar:click(state)
  if state == "down" and not isResponseEnabled() and not isEscapeOpen() then
    if #self.data > self.visibleCount and self.barY then
      if isMouseInPosition(self.x + self.w, self.y + self.barY, 10/zoom, self.barHeight) then
        local b1 = self.h / #self.data
        self.selectedScroll = math.floor(cursorY() - (b1 * self.scroll))
      end
    end

    if not self.clickable then return end

    local selected = false
    if not self.multiSelect then
      for k, _ in pairs(self.data) do
        if self.selected[k] then
          selected = k
        end
        break
      end
    end

    for i = 1, self.visibleCount do
      local id = i + self.scroll
      if self.data[id] then
        if isMouseInPosition(self.x, self.y + self.rowH * (i-1), self.w, self.rowH) then
          if not self.multiSelect then
            self:clearSelection()
            if selected ~= id then
              self:select(id, true)
            end
          else
            self:select(id, not self.selected[id])
          end
          triggerEvent("guiScrollbarClick", root, self.element, id, self.selected[id])
          break
        end
      end
    end

  elseif state == "up" then
    self.selectedScroll = nil
  end
end

function Scrollbar:select(...)
  self.selected[arg[1]] = arg[2]
end

function Scrollbar:clearSelection()
  for k, _ in pairs(self.data) do
    self.selected[k] = nil
  end
end

function Scrollbar:setVisible(...)
  self.visible = arg[1]
  if self.visible then
    self.alpha = 1
  else
    self.alpha = 0
  end
end

function Scrollbar:hide(...)
  if not self.visible then return end
  self.alphaCurrent = self.alpha
  self.hidding = getTickCount()
  self.actionTime = arg[1] or 500
  self.easing = arg[2] or "OutQuad"
  return true
end

function Scrollbar:show(...)
  if self.visible then return end
  self.alphaCurrent = self.alpha
  self.showing = getTickCount()
  self.actionTime = arg[1] or 500
  self.easing = arg[2] or "OutQuad"
  self.visible = true
  return true
end

function Scrollbar:scrolling(btn)
  if isMouseInPosition(self.x, self.y, self.w + 10/zoom, self.h) and not isResponseEnabled() then
    if btn == "mouse_wheel_up" then
      if self.scroll == 0 then return end
      self.scroll = self.scroll - 1

    elseif btn == "mouse_wheel_down" then
      if self.scroll + self.visibleCount >= #self.data then return end
      self.scroll = self.scroll + 1

    end
  end
end

function Scrollbar:setText(...)
  self.scroll = 0
  self.data = self:prepareText(arg[1])
end

function Scrollbar:prepareText(...)
  if type(arg[1]) == "table" then
    return arg[1]

  elseif type(arg[1]) == "string" then
    arg[1] = string.gsub(arg[1], "\n", "\n ")
    local sentences = split(arg[1], "\n")
    local textTable = {}

    for i, v in pairs(sentences) do
      local words = split(v, " ")
      local word = 1
      local text = words[1]
      local lastText = ""

      if #words > 0 then
        while (#words > 0) do
          local textLong = dxGetTextWidth(text, 1/zoom, getFont(13))
          if textLong >= (self.w - 20/zoom) then
            table.insert(textTable, lastText)
            for i = 2, (word + 1) do
              table.remove(words, word - i)
            end
            table.remove(words, 1)
            word = 1
            text = words[1]
            lastText = ""

          else
            word = word + 1
            if not words[word] then table.insert(textTable, text) break end

            lastText = text
            text = text.. " " ..words[word]
          end
        end
      else
        if i ~= #sentences then
          table.insert(textTable, "")
        end
      end
    end

    return textTable

  else
    return false
  end
end

function Scrollbar:setOwner(...)
  self.owner = arg[1]
end

function Scrollbar:getOwner()
  return self.owner
end

function Scrollbar:setBackground(...)
  self.background = arg[1]
end



function createScroll(...)
  local scroll = Scrollbar:create(...)
  scroll:setOwner(getResourceName(sourceResource))

  return scroll.element
end

function destroyScroll(...)
  if type(arg[1]) == "table" then
    for _, v in pairs(arg[1]) do
      createdScrolls[v]:destroy()
    end
  else
    createdScrolls[arg[1]]:destroy()
  end
  return true
end

function showScroll(...)
  if type(arg[1]) == "table" then
    for _, v in pairs(arg[1]) do
      createdScrolls[v]:show(arg[2], arg[3])
    end
  else
    createdScrolls[arg[1]]:show(arg[2], arg[3])
  end
  return true
end

function hideScroll(...)
  if type(arg[1]) == "table" then
    for _, v in pairs(arg[1]) do
      createdScrolls[v]:hide(arg[2], arg[3])
    end
  else
    createdScrolls[arg[1]]:hide(arg[2], arg[3])
  end
  return true
end

function setScrollVisible(...)
  if type(arg[1]) == "table" then
    for _, v in pairs(arg[1]) do
      createdScrolls[v]:setVisible(arg[2])
    end
  else
    createdScrolls[arg[1]]:setVisible(arg[2])
  end
  return true
end

function setScrollText(...)
  if type(arg[1]) == "table" then
    for _, v in pairs(arg[1]) do
      createdScrolls[v]:setText(arg[2])
    end
  else
    createdScrolls[arg[1]]:setText(arg[2])
  end
  return true
end

function setScrollBackground(...)
  if type(arg[1]) == "table" then
    for _, v in pairs(arg[1]) do
      createdScrolls[v]:setBackground(arg[2])
    end
  else
    createdScrolls[arg[1]]:setBackground(arg[2])
  end
  return true
end

function clearScrollSelection(...)
  if type(arg[1]) == "table" then
    for _, v in pairs(arg[1]) do
      createdScrolls[v]:clearSelection()
    end
  else
    createdScrolls[arg[1]]:clearSelection()
  end
  return true
end

function setScrollSelection(...)
  if type(arg[1]) == "table" then
    for _, v in pairs(arg[1]) do
      createdScrolls[v]:select(arg[2], arg[3])
    end
  else
    createdScrolls[arg[1]]:select(arg[2], arg[3])
  end
  return true
end


--- RENDER SCROLLS ---
function renderScrolls()
  for i, v in pairs(createdScrolls) do
    v:draw()
  end
end
addEventHandler("onClientRender", root, renderScrolls)

function clickScrolls(btn, state)
  if btn == "left" then
    for i, v in pairs(createdScrolls) do
      v:click(state)
    end
  end
end
addEventHandler("onClientClick", root, clickScrolls)

function scrollScrolls(btn, state)
  if (btn == "mouse_wheel_up" or btn == "mouse_wheel_down") and state then
    for i, v in pairs(createdScrolls) do
      v:scrolling(btn)
    end
  end
end
addEventHandler("onClientKey", root, scrollScrolls)