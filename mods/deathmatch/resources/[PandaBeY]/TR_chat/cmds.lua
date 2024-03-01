local commandList = {}

Commands = {}
Commands.__index = Commands

function Commands:create(...)
  local instance = {}
  setmetatable(instance, Commands)

  if instance:constructor(...) then
    return instance
  end
  return false
end

function Commands:constructor(...)
  assert(arg[1], "[AddCommand] Command must have a name.")
  assert(arg[2], "[AddCommand] Command must have a triggered point.")
  self.cmd = arg[1]

  self:bindTrigger(arg[2])
  return true
end

function Commands:bindTrigger(...)
  self.trigger = arg[1]
end

function Commands:destroy(...)
  self = nil
  return true
end

function Commands:getCommand(...)
  return self.cmd
end

function Commands:perform(...)
  if not self.trigger then return end
  if type(self.trigger) == "string" then
    triggerEvent(self.trigger, source, ...)
  elseif type(self.trigger) == "function" then
    self.trigger(...)
  end
end

function Commands:setOwner(...)
  self.owner = arg[1]
end

function Commands:getOwner(...)
  return self.owner
end



-- Exported functions
function addCommand(...)
  local command = Commands:create(...)
  if command then
    local commandName = command:getCommand()
    commandList[commandName] = command
    if sourceResource then commandList[commandName]:setOwner(getResourceName(sourceResource)) end
    return true
  end
  return false
end

function performCommand(cmd, ...)
  if not commandList[cmd] then return false end
  commandList[cmd]:perform(...)
  return true
end

function removeCommands(res)
  local owner = getResourceName(res)

  if owner == "TR_chat" then
    local refresh = {}
    local resources = {}
    for _, v in pairs(commandList) do
      local name = v:getOwner()
      if name and not refresh[name] then
        refresh[name] = true
        table.insert(resources, name)
      end
    end
    exports.TR_starter:reloadResources(resources)

  else
    for _, v in pairs(commandList) do
      if v:getOwner() == owner then
        v:destroy()
      end
    end
  end
end
addEventHandler("onResourceStop", root, removeCommands)