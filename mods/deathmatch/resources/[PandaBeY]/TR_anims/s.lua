function syncAnim(...)
  if not client then return end
  if not arg[1] then
    setPedAnimation(client, nil, nil)
    removeElementData(client, "animation")
    return
  end

  setPedAnimation(client, arg[1], arg[2], arg[3] and arg[3] or -1, not arg[4], false, false, true)
  setElementData(client, "animation", {arg[1], arg[2], arg[4]})
end
addEvent("syncAnim", true)
addEventHandler("syncAnim", root, syncAnim)

function syncWalkingStyle(...)
  setPedWalkingStyle(client, arg[1])
end
addEvent("syncWalkingStyle", true)
addEventHandler("syncWalkingStyle", resourceRoot, syncWalkingStyle)