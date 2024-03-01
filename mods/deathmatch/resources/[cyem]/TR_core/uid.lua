local ID = {}

function setPlayerID(plr)
  if not plr or not isElement(plr) then return end

  local co = coroutine.create(findFreeID)
  coroutine.resume(co, co, plr, 1, 0)
end
addEvent("setPlayerID", true)
addEventHandler("setPlayerID", root, setPlayerID)

function findFreeID(co, plr, freeID, count)
  while true do
    if isElement(ID[freeID]) then
      freeID = freeID + 1
      count = count + 1

      if count >= 25 then
        setTimer(function() coroutine.resume(co, co, plr, freeID, 0) end, 50, 1)
        coroutine.yield(co)
      end

    else
      ID[freeID] = plr
      setElementID(plr, "ID"..freeID)
      setElementData(plr, "ID", freeID)

      triggerEvent("loadPlayerFriends", root, plr, true)
      return
    end
  end
end

function playerQuit()
  local plrID = getElementData(source, "ID")
  if not plrID then return end
  ID[plrID] = nil
end
addEventHandler("onPlayerQuit", root, playerQuit)

function appendID()
  local plrID = 1
  for i, v in ipairs(getElementsByType("player")) do
    if getElementData(v, "characterUID") then
      ID[plrID] = v
      setElementID(v, "ID"..plrID)
      setElementData(v, "ID", plrID)

      plrID = plrID + 1
    end
  end
end
appendID()

function nickChangeHandler()
  cancelEvent()
end
addEventHandler("onPlayerChangeNick", getRootElement(), nickChangeHandler)