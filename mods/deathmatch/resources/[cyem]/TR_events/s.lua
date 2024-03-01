function startAdminEvent(paid, data)
    if paid then
        if eventData.selectedEvent then
            exports.TR_noti:create(source, "Bir etkinlik gerçekleştiği için bir etkinlik oluşturamazsınız.", "error")
            triggerClientEvent(source, "paidForAdminEvent", resourceRoot)
            return
        end

        if eventData.lastEventTick then
            if (getTickCount() - eventData.lastEventTick)/(eventData.eventDelay * 1000) < 1 then
                exports.TR_noti:create(source, "Yakın zamanda başka bir etkinlik gerçekleştiği için etkinlik oluşturamazsınız.", "error")
                triggerClientEvent(source, "paidForAdminEvent", resourceRoot)
                return
            end
        end

        local event = eventData.events[data[1]]
        triggerClientEvent(root, "startEvent", resourceRoot, event.name, event.playerCount)

        eventData.selectedEvent = data[1]
        eventData.playerCount = 0
        eventData.winPrice = data[2]
        eventData.lastEventTick = getTickCount()
        eventData.createdAdmin = source

        setTimer(startEvent, eventData.startTime * 1000, 1)
    end

    triggerClientEvent(source, "paidForAdminEvent", resourceRoot)
end
addEvent("startAdminEvent", true)
addEventHandler("startAdminEvent", root, startAdminEvent)


function playerLoseEvent(plr, md)
    if not plr or not isElement(plr) or not md then return end
    if getElementType(plr) == "vehicle" then
        local occupant = getVehicleOccupant(plr)
        if not eventData.players[occupant] then return end
        removePedFromVehicle(occupant)
        destroyElement(plr)
        setTimer(playerLoseEvent, 500, 1, occupant, md)
        return

    elseif getElementType(plr) == "player" then
        if not eventData.players[plr] then return end
        if getPedOccupiedVehicle(plr) then return end
    else
        return
    end
    if not eventData.playersLeft[plr] then return end

    eventData.playerCount = eventData.playerCount - 1
    eventData.playersLeft[plr] = nil

    if eventData.playerCount <= 0 then
        if eventData.events[eventData.selectedEvent].type == "pirate" then
            checkPirateWin()
        else
            triggerClientEvent(root, "setEventNoti", resourceRoot, "win", {getPlayerName(plr), eventData.events[eventData.selectedEvent].name, eventData.winPrice})
            exports.TR_core:giveMoneyToPlayer(plr, eventData.winPrice)
        end
        endEvent()

    elseif eventData.playerCount == 1 then
        local winner
        for i, v in pairs(eventData.playersLeft) do
            winner = i
        end

        local veh = getPedOccupiedVehicle(winner)
        if veh then destroyElement(veh) end

        if eventData.events[eventData.selectedEvent].type == "pirate" then
            checkPirateWin()
        else
            triggerClientEvent(root, "setEventNoti", resourceRoot, "win", {getPlayerName(winner), eventData.events[eventData.selectedEvent].name, eventData.winPrice})
            exports.TR_core:giveMoneyToPlayer(winner, eventData.winPrice)
        end
        endEvent()

    else
        if eventData.events[eventData.selectedEvent].type == "pirate" then
            exports.TR_noti:create(plr, "Maalesef etkinlikten elendiniz ve takımınızın hareketlerini izleyebileceğiniz tribünlere taşındınız.", "error", 5)
            checkPirateWin()
        else
            exports.TR_noti:create(plr, "Maalesef etkinliği kazanamadınız ve diğer oyuncuların hareketlerini izleyebileceğiniz tribünlere taşındınız.", "error", 5)
        end
        movePlayerToWatchingPlace(plr)
    end
end
addEvent("playerLoseEvent", true)
addEventHandler("playerLoseEvent", resourceRoot, playerLoseEvent)


function onEventQuit()
    playerLoseEvent(source, true, true)
end
addEventHandler("onPlayerQuit", root, onEventQuit)


function startEvent()
    if not eventData.selectedEvent then return end
    if eventData.events[eventData.selectedEvent].minPlayers > eventData.playerCount then
        triggerClientEvent(root, "setEventNoti", resourceRoot, "notStarted")
        endEvent()
        return
    end

    eventData.playersLeft = {}
    eventData.playerCount = 0
    for i, v in pairs(eventData.players) do
        if isElement(i) then
            removePedFromVehicle(i)
            removeElementData(i, "waitingEvent")
            local x, y, z = getElementPosition(i)
            local int = getElementInterior(i)
            local dim = getElementDimension(i)
            local hp = getElementHealth(i)
            local customModel = getElementData(i, "customModel")
            setElementData(i, "characterQuit", {x, y, z, int, dim}, false)
            setElementData(i, "beforeEventHP", hp, false)
            setElementData(i, "lastSkin", getElementModel(i))
            setElementData(i, "lastCustomModel", customModel)
            setElementData(i, "customModel", nil)
            setElementData(i, "blockAction", true)
            setElementData(i, "isOnEvent", true)

            eventData.playersLeft[i] = i
            eventData.playerCount = eventData.playerCount + 1
        end
    end

    eventData.isStarted = true
    triggerClientEvent(root, "setEventNoti", resourceRoot, "start", {eventData.events[eventData.selectedEvent].name})

    if string.find(eventData.events[eventData.selectedEvent].type, "Derby") then
        setTimer(createDerbyVehicles, 100, 1)

    elseif string.find(eventData.events[eventData.selectedEvent].type, "pirate") then
        setTimer(createPirateEvent, 100, 1)

    elseif string.find(eventData.events[eventData.selectedEvent].type, "ox") then
        setTimer(createOX, 100, 1)

    elseif string.find(eventData.events[eventData.selectedEvent].type, "fallout") then
        exports.TR_fallout:createEventFallout(eventData.playersLeft, eventData.winPrice, eventData.createdAdmin)
    end
end

function movePlayerToWatchingPlace(plr)
    local tribune = eventData.events[eventData.selectedEvent].tribune
    setElementPosition(plr, tribune)
    setElementRotation(plr, 0, 0, 0)
    eventData.players[plr].onTribune = true
end

function endEvent()
    setPlayersBackToPosition()

    eventData.selectedEvent = nil
    eventData.isStarted = nil
    eventData.players = {}
end
addEvent("endEvent", true)
addEventHandler("endEvent", root, endEvent)

function setPlayersBackToPosition()
    for i, v in pairs(eventData.players) do
        sendPlayerBackFromEvent(i)
    end
end
addEvent("setPlayersBackToPosition", true)
addEventHandler("setPlayersBackToPosition", root, setPlayersBackToPosition)


function sendPlayerBackFromEvent(plr)
    if isElement(plr) then
        local pos = getElementData(plr, "characterQuit")
        if pos then
            setElementPosition(plr, pos[1], pos[2], pos[3])
            setElementInterior(plr, pos[4])
            setElementDimension(plr, pos[5])
        end
        local lastModel = getElementData(plr, "lastSkin")
        if lastModel then setElementModel(plr, lastModel) end
        local lastCustomModel = getElementData(plr, "lastCustomModel")
        if lastCustomModel then setElementData(plr, "customModel", lastCustomModel) end
        local beforeEventHP = getElementData(plr, "beforeEventHP")
        if beforeEventHP then setElementHealth(plr, beforeEventHP) end
        removeElementData(plr, "lastSkin")
        removeElementData(plr, "lastCustomModel")
        removeElementData(plr, "isOnEvent")
        removeElementData(plr, "blockAction")
        removeElementData(plr, "characterQuit")
        removeElementData(plr, "waitingEvent")
        removeElementData(plr, "beforeEventHP")

        exports.TR_weaponSlots:takeAllWeapons(plr)
        setPlayerTeam(plr, nil)

        exports.TR_items:updatePlayerMask(plr)
    end
end


function blockVehicleExit()
    cancelEvent()
end
addEventHandler("onVehicleStartExit", resourceRoot, blockVehicleExit)

function onFallOffEvent(plr, md)
    playerLoseEvent(plr, md)
end
addEventHandler("onColShapeHit", resourceRoot, onFallOffEvent)

function isPlayerOnEvent(plr)
    return eventData.players[plr] and true or false
end

function canCreateEvent(plr)
    if eventData.selectedEvent then
        exports.TR_noti:create(plr, "Bir etkinlik gerçekleştiği için bir etkinlik oluşturamazsınız.", "error")
        return false
    end

    if eventData.lastEventTick then
        if (getTickCount() - eventData.lastEventTick)/(eventData.eventDelay * 1000) < 1 then
            local timeToEnd = eventData.eventDelay - (eventData.eventDelay * ((getTickCount() - eventData.lastEventTick)/(eventData.eventDelay * 1000)))
            exports.TR_noti:create(plr, "Yakın zamanda başka bir etkinlik gerçekleştiği için etkinlik oluşturamazsınız.\nKalan süre: "..getTimeInSeconds(timeToEnd), "error", 10)
            return false
        end
    end
    return true
end

function joinEvent()
    if getElementData(source, "prisonIndex") then exports.TR_noti:create(source, "Hapisteyken etkinliğe katılamazsınız.", "error") return end
    if isElement(getElementData(source, "cuffed")) or isElement(getElementData(source, "cuffedBy")) then exports.TR_noti:create(source, "Bu etkinliğe kayıt olamazsınız.", "error") return end

    if not eventData.selectedEvent then exports.TR_noti:create(source, "Hiçbir etkinlik başlatılmadı.", "error") return end
    if eventData.isStarted then exports.TR_noti:create(source, "Etkinlik zaten devam ediyor.", "error") return end
    if eventData.players[source] then exports.TR_noti:create(source, "Bu etkinlik için zaten kayıtlısınız.", "error") return end
    if eventData.events[eventData.selectedEvent].playerCount - eventData.playerCount == 0 then exports.TR_noti:create(source, "Tüm koltuklar dolu olduğu için bu etkinliğe katılamazsınız.", "error", 3) return end

    if string.find(eventData.events[eventData.selectedEvent].type, "ox") then
        if source == eventData.createdAdmin then exports.TR_noti:create(source, "Kendi etkinliğinize katılamazsınız.", "error") return end
    end

    eventData.players[source] = {}
    eventData.playerCount = eventData.playerCount + 1

    local emptyPlaces = eventData.events[eventData.selectedEvent].playerCount - eventData.playerCount
    triggerClientEvent(root, "updateEventPlaces", resourceRoot, emptyPlaces)
    exports.TR_noti:create(source, "Etkinliğe başarıyla kaydoldunuz.", "success")

    setElementData(source, "waitingEvent", true)
end
addEvent("joinEvent", true)
addEventHandler("joinEvent", root, joinEvent)
exports.TR_chat:addCommand("event", "joinEvent")

function leaveEvent()
    if not eventData.selectedEvent then return end
    if not eventData.isStarted then return end
    if not eventData.players[source] then return end
    if not eventData.players[source].onTribune then return end

    sendPlayerBackFromEvent(source)

    triggerClientEvent(source, "onClientPlayerQuitEvent", source, "OX")
	setElementData(source, "OX", nil)

    eventData.players[source] = nil
    exports.TR_noti:create(source, "Etkinlikten başarıyla ayrıldınız.", "success")
end
addEvent("leaveEvent", true)
addEventHandler("leaveEvent", root, leaveEvent)
exports.TR_chat:addCommand("levent", "leaveEvent")



function getTimeInSeconds(seconds)
    local seconds = tonumber(seconds)

    if seconds <= 0 then
      return "00:00:00";
    else
      hours = string.format("%02.f", math.floor(seconds/3600));
      mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
      secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
      return hours..":"..mins..":"..secs
    end
end