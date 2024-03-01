function playBoomboxMusic(plr, url)
    local boomboxData = getElementData(plr, "boombox")
    if not boomboxData then return end

    local int = getElementInterior(plr)
    local dim = getElementDimension(plr)

    local musicData = {
        owner = plr,
        url = url,
        startTick = getTickCount(),
        element = boomboxData.boombox,
    }

    if boomboxData.type == "hand" then
        musicData.sphere = createColSphere(Vector3(getElementPosition(plr)), 15)
        attachElements(musicData.sphere, client)

    elseif boomboxData.type == "ground" then
        musicData.sphere = createColSphere(Vector3(getElementPosition(boomboxData.boombox)), 15)
        attachElements(musicData.sphere, boomboxData.boombox)
    end

    setElementInterior(musicData.sphere, int)
    setElementDimension(musicData.sphere, dim)
    setElementParent(musicData.sphere, boomboxData.boombox)

    setElementData(musicData.sphere, "boomboxData", musicData, true)

    local players = getElementsWithinColShape(musicData.sphere, "player")
    for i, v in pairs(players) do
        triggerClientEvent(v, "playBoomboxSound", resourceRoot, musicData, getTickCount())
    end

    exports.TR_objectManager:attachObjectToPlayer(plr, boomboxData.col)

    boomboxData.col = musicData.sphere
    setElementData(plr, "boombox", boomboxData)

    if boomboxData.type == "ground" then
        local boomboxAdmin = createElement("boomboxAdmin")
        setElementData(boomboxAdmin, "boomboxAdmin", {
            id = getElementData(plr, "ID"),
            playerName = getPlayerName(plr),
        })

        setElementPosition(boomboxAdmin, Vector3(getElementPosition(boomboxData.boombox)))
        attachElements(boomboxAdmin, boomboxData.boombox)
        setElementParent(boomboxAdmin, boomboxData.boombox)
    end
end

function playBoomboxMusicEvent(url)
    playBoomboxMusic(client, url)
end
addEvent("playBoomboxMusic", true)
addEventHandler("playBoomboxMusic", root, playBoomboxMusicEvent)

function destroyPlayerBoombox(plr)
    local boomboxData = getElementData(plr, "boombox")
    if not boomboxData then return end

    exports.TR_objectManager:removeObject(plr, 2226)

    if isElement(boomboxData.col) then destroyElement(boomboxData.col) end
    removeElementData(plr, "boombox")
end

function destroyPlayerBoomboxEvent()
    destroyPlayerBoombox(client)

    triggerClientEvent(client, "equipmentResponse", resourceRoot, "Müzik kutusu gizlendi.", "success", true)
end
addEvent("destroyPlayerBoombox", true)
addEventHandler("destroyPlayerBoombox", root, destroyPlayerBoomboxEvent)

function takeBoomboxToHand(itemID, url)
    local boomboxObject = exports.TR_objectManager:attachObjectToBone(client, 2226, 1, 12, 0, 0, 0.4, 0, 270, 0)

    setElementData(client, "boombox", {
        itemID = itemID,
        boombox = boomboxObject,
        type = "hand",
    })

    setElementInterior(boomboxObject, getElementInterior(client))
    setElementDimension(boomboxObject, getElementDimension(client))
    setElementCollisionsEnabled(boomboxObject, false)

    playBoomboxMusic(client, url)
end
addEvent("takeBoomboxToHand", true)
addEventHandler("takeBoomboxToHand", root, takeBoomboxToHand)

function placeBoomboxOnGround(itemID, url)
    local boomboxObject = createObject(2226, Vector3(getElementPosition(client)) - Vector3(0, 0, 0.8))
    local _, _, rot = getElementRotation(client)
    setElementRotation(boomboxObject, 0, 90, rot - 180)
    setElementInterior(boomboxObject, getElementInterior(client))
    setElementDimension(boomboxObject, getElementDimension(client))
    setElementCollisionsEnabled(boomboxObject, false)

    setElementData(client, "boombox", {
        itemID = itemID,
        boombox = boomboxObject,
        type = "ground",
    })

    exports.TR_objectManager:attachObjectToPlayer(client, boomboxObject)

    playBoomboxMusic(client, url)
end
addEvent("placeBoomboxOnGround", true)
addEventHandler("placeBoomboxOnGround", root, placeBoomboxOnGround)

function loadBoomboxMusic(el, md)
    if getElementType(el) ~= "player" or not md then return end

    local boomboxData = getElementData(source, "boomboxData")
    if not boomboxData then return end

    triggerClientEvent(el, "playBoomboxSound", resourceRoot, boomboxData, getTickCount())
end
addEventHandler("onColShapeHit", resourceRoot, loadBoomboxMusic)

function adminRemoveBoombox(targetID)
    if not exports.TR_admin:isPlayerOnDuty(source) then return end
    if not targetID then triggerClientEvent(source, "showCustomMessage", resourceRoot, "#008a2eKomut kullanımı", "#438f5c/bboff (ID/İsim)", "files/images/command.png") return end

    local target = findPlayer(source, targetID)
    if not target then return end

    triggerClientEvent(target, "adminRemoveBoombox", resourceRoot, getPlayerName(source))
    exports.TR_noti:create(source, string.format("%s isimli oyuncunun müzik kutusu devre dışı bırakıldı.", getPlayerName(target)), "success")
end
addEvent("adminRemoveBoombox", true)
addEventHandler("adminRemoveBoombox", root, adminRemoveBoombox)
exports.TR_chat:addCommand("bboff", "adminRemoveBoombox")

function findPlayer(plr, id)
    local target = getElementByID("ID"..id)
    if not target then target = getPlayerFromName(id) end
    if not target or not isElement(target) then exports.TR_noti:create(plr, "Belirtilen oyuncu bulunamadı.", "error") return false end
    return target
end