function create(plr, ...)
  triggerClientEvent(plr, "createNoti", resourceRoot, ...)
end

function destroy(plr, ...)
  triggerClientEvent(plr, "destroyNoti", resourceRoot, ...)
end

function setText(plr, ...)
  triggerClientEvent(plr, "setTextNoti", resourceRoot, ...)
end

function setColor(plr, ...)
  triggerClientEvent(plr, "setColorNoti", resourceRoot, ...)
end