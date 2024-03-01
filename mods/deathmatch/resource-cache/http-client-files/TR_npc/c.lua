local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local settings = {
  x = 0,
  y = 400/zoom,
  w = 400/zoom,
  h = 20/zoom,

  animSpeed = 200,

  font = exports.TR_dx:getFont(11),
}

function stopTalkToNPC(...)
  if not settings.open then return end

  removeEventHandler("onClientClick", root, clickTalk)
  showCursor(false)

  if not exports.TR_tutorial:isTutorialOpen() then exports.TR_dx:setOpenGUI(false) end

  settings.open = nil
  settings.moveFrom = settings.x
  settings.moveTo = -settings.w
  settings.tick = getTickCount()
end
addEvent("stopTalkToNPC", true)
addEventHandler("stopTalkToNPC", root, stopTalkToNPC)

function setNPCdialogue(...)
  if settings.open then return end
  settings.open = true
  settings.talkPos = 0

  exports.TR_dx:setResponseEnabled(false)
  exports.TR_interaction:closeInteraction()
  exports.TR_dx:setOpenGUI(true)

  settings.npc = arg[1]
  settings.action = arg[2]

  settings.dialogue = rebuildText(arg[3])
  settings.texts = rebuildText(arg[3])
  settings.fontHeight = dxGetFontHeight(1/zoom, settings.font)

  calculateWindowSize()
  updateIcons()

  addEventHandler("onClientRender", root, renderTalk)
  addEventHandler("onClientClick", root, clickTalk)

  settings.moveFrom = -settings.w
  settings.moveTo = 0
  settings.tick = getTickCount()

  showCursor(true, true)
end
addEvent("setNPCdialogue", true)
addEventHandler("setNPCdialogue", root, setNPCdialogue)

function rebuildText(text)
  for i, v in pairs(text) do
    if type(v.text) == "table" then
      text[i].text = v.text
    end
    if type(v.pedResponse) == "table" then
      v.pedResponse = v.pedResponse
    end
  end

  return text
end

function updateIcons()
  for i, v in pairs(settings.texts) do
    if v.type == "text" then
      v.img = getTextImg(v)
    end
  end
end

function calculateWindowSize()
  local count = 0
  for i, v in pairs(settings.texts) do
    if v.type == "text" then
      count = count + 1
    end
  end

  settings.h = count * (settings.fontHeight + 20/zoom) + settings.fontHeight + 20/zoom
end


function renderTalk()
  renderAnim()
  drawBackground(settings.x, settings.y, settings.w, settings.h, tocolor(17, 17, 17, 255), 5)
  dxDrawText("Bir diyalog seçin", settings.x, settings.y + 10/zoom, settings.x + settings.w, settings.y + settings.fontHeight, tocolor(212, 175, 55, 255), 1/zoom, settings.font, "center")

  local y = settings.y + settings.fontHeight + 20/zoom
  for i, v in pairs(settings.texts) do
    if v.type == "text" then
      if isMouseInPosition(settings.x, y, settings.w, (settings.fontHeight + 20/zoom)) then
        dxDrawImage(settings.x + 10/zoom, y + 10/zoom, 20/zoom, 20/zoom, v.img, 0, 0, 0, tocolor(255, 255, 255, 255))
        dxDrawText(v.text, settings.x + 40/zoom, y + 10/zoom, settings.x + settings.w - 20/zoom, y + settings.fontHeight - 10/zoom, tocolor(255, 255, 255, 255), 1/zoom, settings.font)
      else
        dxDrawImage(settings.x + 10/zoom, y + 10/zoom, 20/zoom, 20/zoom, v.img, 0, 0, 0, tocolor(255, 255, 255, 200))
        dxDrawText(v.text, settings.x + 40/zoom, y + 10/zoom, settings.x + settings.w - 20/zoom, y + settings.fontHeight - 10/zoom, tocolor(255, 255, 255, 200), 1/zoom, settings.font)
      end
      y = y + (settings.fontHeight + 20/zoom)
    end
  end
end

function renderAnim()
  if not settings.tick then return end
  local progress = (getTickCount() - settings.tick)/ settings.animSpeed
  settings.x, _, _ = interpolateBetween(settings.moveFrom, 0, 0, settings.moveTo, 0, 0, progress, "Linear")
  if progress >= 1 then
    settings.x = settings.moveTo
    settings.tick = nil
    settings.moveFrom = nil

    if settings.moveTo == -settings.w then
      settings.open = nil
      removeEventHandler("onClientRender", root, renderTalk)
    end
  end
end

function clickTalk(btn, state)
  if btn == "left" and state == "down" then
    local y = settings.y + settings.fontHeight + 20/zoom
    for i, v in pairs(settings.texts) do
      if v.type == "text" then
        if isMouseInPosition(settings.x, y, settings.w, (settings.fontHeight + 20/zoom)) then
          performTalkClick(v)
          return
        end
        y = y + (settings.fontHeight + 20/zoom)
      end
    end
  end
end

function performTalkClick(data)
  settings.talkPos = settings.talkPos + 1

  if data.type == "text" then
    local nextDialogue = {}
    if data.pedResponse then talkPed(data.pedResponse) end
    if data.dialogues then
      for _, v in pairs(settings.dialogue) do
        for _, text in pairs(data.dialogues) do
          if v.text == text and v.responseTo == data.text then
            v.type = "text"
            table.insert(nextDialogue, v)
          end
        end
      end
      settings.texts = nextDialogue

      for i, v in pairs(settings.texts) do
        v.img = getTextImg(v)
      end
    end
    if #nextDialogue < 1 then stopTalkToNPC() end

    calculateWindowSize()
  end

  if data.text == "Nasıl yani?!" then
    exports.TR_tutorial:setNextState()
  end

  if data.trigger then
    triggerServerEvent(data.trigger, localPlayer, settings.npc, data.triggerData)
  end
end

function getTextImg(data)
  if data.img then return "files/images/"..data.img..".png" end
  if data.type == "trigger" then return "files/images/dialogue.png"
  elseif data.type == "text" and data.dialogues then return "files/images/dialogue.png"
  elseif data.text == settings.texts[#settings.texts].text then return "files/images/end.png"
  elseif data.type == "text" then return "files/images/dialogue.png"
  end
end

function talkPed(text)
  local name = getElementData(settings.npc, "name")
  triggerEvent("showCustomMessage", localPlayer, name, text, "files/images/npc.png")
end


-- Utils
function drawBackground(x, y, rx, ry, color, radius, post)
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

function isMouseInPosition(x, y, width, height)
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


-- Block dmg
function onPedDamage()
  cancelEvent()
end
addEventHandler("onClientPedDamage", resourceRoot, onPedDamage)