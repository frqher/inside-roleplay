function saveBuildedHouse(state, data)
  if state then
    local querrySaveHome = exports.tr_mysql:querry("UPDATE `tr_houses` SET interiorObjects = ?, interiorWalls = ?, interiorFloor = ? WHERE id=?", data[2], data[3], data[4], data[1])

    triggerClientEvent(source, "interiorSaved", resourceRoot, true)
    exports.TR_noti:create(source, "Ev başarıyla kaydedildi.", "success")
  else
    triggerClientEvent(source, "interiorSaved", resourceRoot)
  end
end
addEvent("saveBuildedHouse", true)
addEventHandler("saveBuildedHouse", root, saveBuildedHouse)


function setPlayerInteriorPos(posExit, clearData)
  setElementPosition(client, tonumber(posExit[1]), tonumber(posExit[2]), tonumber(posExit[3]))
  setElementInterior(client, posExit[4])
  setElementDimension(client, posExit[5])

  if clearData then
    removeElementData(client, "characterHomeID")
    setElementData(client, "characterQuit", nil, false)
    triggerClientEvent(client, "setRadarCustomLocation", resourceRoot)

    local attachments = getAttachedElements(client)
    if attachments then
      for i, v in pairs(attachments) do
        if getElementType(v) == "player" then
          triggerClientEvent(v, "quitBuildingWithCuffs", resourceRoot)
        end
      end
    end
  end
end
addEvent("setPlayerInteriorPos", true)
addEventHandler("setPlayerInteriorPos", root, setPlayerInteriorPos)