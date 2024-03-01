local dialogueIndex = 0
local dialogues = {}

Dialogue = {}
Dialogue.__index = Dialogue

function Dialogue:create(...)
  local instance = {}
  setmetatable(instance, Dialogue)
  if instance:constructor(...) then
    return instance
  end
  return false
end

function Dialogue:constructor(...)
  self.dialogues = {}
  self:setIndex()

  return true
end

function Dialogue:destroy()
  dialogues[self.index] = nil
  self = nil
  collectgarbage()
end

function Dialogue:addText(...)
  if not arg[2] then arg[2] = {} end
  if not arg[2].type then
    if arg[2].responseTo then
      arg[2].type = "response"
    else
      arg[2].type = "text"
    end
  end

  if arg[2].type == "text" then
    local text = self:buildText(arg[1], arg[2].type, arg[2].pedResponse, arg[2].responseTo, arg[2].img, arg[2].trigger, arg[2].triggerData)
    table.insert(self.dialogues, text)

  elseif arg[2].type == "response" then
    for i, v in pairs(self.dialogues) do
      if v.text == arg[2].responseTo then
        if not v.dialogues then v.dialogues = {} end
        if type(arg[1]) == "table" then
          for _, text in pairs(arg[1]) do
            table.insert(v.dialogues, text)
          end
        else
          table.insert(v.dialogues, arg[1])
        end
        break
      end
    end
    local text = self:buildText(arg[1], arg[2].type, arg[2].pedResponse, arg[2].responseTo, arg[2].img, arg[2].trigger, arg[2].triggerData)
    table.insert(self.dialogues, text)
  end
end

function Dialogue:getText()
  return self.dialogues
end

function Dialogue:buildText(...)
  return
  {
    text = arg[1],
    type = arg[2],
    pedResponse = arg[3],
    responseTo = arg[4],
    img = arg[5],
    trigger = arg[6],
    triggerData = arg[7],
  }
end

function Dialogue:setOwner(...)
  self.owner = arg[1]
end

function Dialogue:getOwner()
  return self.owner
end

function Dialogue:setIndex()
  self.index = dialogueIndex
  dialogueIndex = dialogueIndex + 1
end

function Dialogue:getIndex()
  return self.index
end


--[[
  Avaliable options:
  {
    type = "text", -- Type clicked dialogue option (text/trigger)
    responseTo = "", -- If type is response then this will be ped response on player selected text
    pedResponse = "", -- Ped response text
    trigger = "", -- Trigger name what will be triggered
  }
]]


--
function createDialogue(...)
  local dialogue = Dialogue:create(...)
  if sourceResource then dialogue:setOwner(getResourceName(sourceResource)) else dialogue:setOwner("self") end
  dialogues[dialogue:getIndex()] = dialogue
  return dialogue:getIndex()
end

-- Dialogue, text, textOptions,
function addDialogueText(...)
  if not dialogues[arg[1]] then return end
  dialogues[arg[1]]:addText(arg[2], arg[3])
end

function getDialogueText(...)
  if not dialogues[arg[1]] then return end
  return dialogues[arg[1]]:getText()
end



function removeDialogueStoppedResource(res)
  local owner = getResourceName(res)

  for i, v in pairs(dialogues) do
    if v:getOwner() == owner then
      v:destroy()
    end
  end
end
addEventHandler("onResourceStop", root, removeDialogueStoppedResource)