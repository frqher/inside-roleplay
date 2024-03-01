function savePlayerData(plr, unloadItems)
  local UID = getElementData(plr, "characterUID")
  if not UID then
    local tempUID = getElementData(plr, "tempUID")
    if tempUID then
      exports.TR_mysql:querry("UPDATE tr_accounts SET isOnline = NULL WHERE `UID` = ? LIMIT 1", tempUID)
    end
    return
  end

  local data = getElementData(plr, "characterData")
  if not data then return end

  local position = getPlayerPosition(plr)
  local health = getElementHealth(plr)
  local skin = data.skin
  local onlineTime = math.floor((getTickCount() - data.enterTime)/1000)
  local features = table.concat(getElementData(plr, "characterFeatures"), ",")
  local jobPoints = getElementData(plr, "characterPoints")

  local ticketPrice = getElementData(plr, "ticketPrice")
  exports.TR_mysql:querry("UPDATE `tr_accounts` SET `skin` = ?, `health`= ?, `position`= ?, `features` = ?, `isOnline` = NULL, `online` = online + ?, `money`= ?, `jobPoints` = ?, `ticketPrice` = ? WHERE `UID` = ? LIMIT 1", skin, health, position, features, onlineTime, string.format("%.2f", data.money), jobPoints, ticketPrice, UID)

  if unloadItems then
    exports.TR_mysql:querry("UPDATE `tr_items` SET `used` = NULL WHERE `owner` = ? AND (type = 1 OR type = 9) AND ownedType = 0", UID)
  end
end

function savePlayerEscapeData()
  savePlayerData(client)

  local data = getElementData(client, "characterData")
  data.enterTime = getTickCount()
  setElementData(client, "characterData", data)

  triggerClientEvent(client, "responseEscapeMenu", resourceRoot, "save")
end
addEvent("savePlayerEscapeData", true)
addEventHandler("savePlayerEscapeData", root, savePlayerEscapeData)

function playerQuit()
  savePlayerData(source, true)
end
addEventHandler("onPlayerQuit", root, playerQuit)

function getPlayerPosition(player)
  local quitPosition = getElementData(player, "characterQuit")
  if quitPosition then
    return string.format("%.2f,%.2f,%.2f,%d,%d", quitPosition[1], quitPosition[2], quitPosition[3], quitPosition[4], quitPosition[5])

  else
    local x, y, z = getElementPosition(player)
    local int = getElementInterior(player)
    local dim = getElementDimension(player)
    return string.format("%.2f,%.2f,%.2f,%d,%d", x, y, z, int, dim)
  end
end

function res()
  for i, v in pairs(getElementsByType("player")) do
    if isPedDead(v) then
      local x, y, z = getElementPosition(v)
      spawnPlayer(v, x, y, z + 0.5)
    end
  end
end
res()

function resetOnline()
  exports.TR_mysql:querry("UPDATE tr_accounts SET isOnline = NULL")
  for i, v in pairs(getElementsByType("player")) do
    local uid = getElementData(v, "characterUID")
    if uid then
      exports.TR_mysql:querry("UPDATE tr_accounts SET isOnline = 1 WHERE UID = ? LIMIT 1", uid)
    end
  end
end
resetOnline()