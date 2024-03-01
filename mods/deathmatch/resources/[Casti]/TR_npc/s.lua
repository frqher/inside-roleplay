local createdNPC = {}

NPC = {}
NPC.__index = NPC

function NPC:create(...)
  local instance = {}
  setmetatable(instance, NPC)

  if instance:constructor(...) then
    return instance
  end
  return false
end

function NPC:constructor(...)
  self.ped = createPed(arg[1], arg[2], arg[3], arg[4], arg[5], false)
  self.name = arg[6] or ""
  self.role = arg[7] or ""

  setElementData(self.ped, "name", self.name)
  setElementData(self.ped, "role", self.role)
  setElementFrozen(self.ped, true)

  self.func = {}

  self:setAction(arg[8], arg[9])
  self:setAnimation(arg[10], arg[11])
  return true
end

function NPC:destroy(...)
  if isElement(self.ped) then destroyElement(self.ped) end
  if isElement(self.colider) then destroyElement(self.colider) end
  self = nil
end

function NPC:setAction(...)
  if not arg[1] then return end
  self.action = arg[1]
end

function NPC:getAction(...)
  return self.action
end

function NPC:setAnimation(...)
  if not arg[1] and not arg[2] then return end
  self.animation = {arg[1], arg[2]}
end

function NPC:getPed()
  return self.ped
end

function NPC:setOwner(...)
  self.owner = arg[1]
end

function NPC:getOwner(...)
  return self.owner
end

function NPC:setDialogue(...)
  self.dialogue = arg[1]
end

function NPC:getDialogue(...)
  return getDialogueText(self.dialogue)
end



-- Model, x, y, z, rot, name, role, action, distance
function createNPC(...)
  local npc = NPC:create(...)
  if sourceResource then npc:setOwner(getResourceName(sourceResource)) end
  createdNPC[npc:getPed()] = npc

  return npc:getPed()
end

-- Instance of npc
function destroyNPC(...)
  if createdNPC[arg[1]] then
    createdNPC[arg[1]]:destroy()
    return true
  end
  return false
end

function setNPCDialogue(...)
  if createdNPC[arg[1]] then
    createdNPC[arg[1]]:setDialogue(arg[2])
    return true
  end
  return false
end

function triggerNPC(...)
  if createdNPC[arg[1]] then
    local action = createdNPC[arg[1]]:getAction()
    if action == "dialogue" then
      local dialogue = createdNPC[arg[1]]:getDialogue()
      triggerClientEvent(client, "setNPCdialogue", resourceRoot, arg[1], action, dialogue)

    elseif action == "trigger" then
      triggerEvent()
    end
  end
  return false
end
addEvent("triggerNPC", true)
addEventHandler("triggerNPC", root, triggerNPC)



function removeNPCstoppedResource(res)
  local owner = getResourceName(res)

  for i, v in pairs(createdNPC) do
    if v:getOwner() == owner then
      v:destroy()
    end
  end
end
addEventHandler("onResourceStop", root, removeNPCstoppedResource)


function blockDmg()

end
addEventHandler("onPedDamage", resourceRoot, blockDmg)