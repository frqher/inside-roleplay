

function onPlayerInPrizonTimeEnd(plr)
    local prisonIndex = getElementData(plr, "prisonIndex")
    if not prisonIndex then return end

    for i, v in pairs(PoliceJails[prisonIndex].cells) do
        for k, plr in pairs(v.players) do
            if plr == plr then
                table.remove(PoliceJails[prisonIndex].cells[i].players, k)
                break
            end
        end
    end

    setElementPosition(plr, PoliceJails[prisonIndex].exitPos)
    removeElementData(plr, "prisonIndex")

    exports.TR_noti:create(plr, "Hapishanedeki süreniz doldu ve hücrenizden çıkartıldınız.", "info")
end

function setPlayerInPrizon(prisonIndex, player, time, reason)
    removeElementData(player, "cuffedBy")
    removeElementData(player, "animation")
    setPedAnimation(player, nil, nil)

    if client then
        removeElementData(client, "cuffed")
        detachElements(player, client)

        local data = {
            prisonIndex = prisonIndex,
            time = time,
            reason = reason,
            police = getPlayerName(client),
        }
        exports.TR_mysql:querry("UPDATE tr_accounts SET prisonData = ? WHERE UID = ? LIMIT 1", toJSON(data), getElementData(player, "characterUID"))
        triggerClientEvent(player, "openPrisonTimer", resourceRoot, data)
    end

    local cellIndex = getPrizonIndex(prisonIndex)
    table.insert(PoliceJails[prisonIndex].cells[cellIndex].players, player)

    setElementPosition(player, PoliceJails[prisonIndex].cells[cellIndex].pos)
    setElementData(player, "prisonIndex", prisonIndex)
end
addEvent("setPlayerInPrizon", true)
addEventHandler("setPlayerInPrizon", resourceRoot, setPlayerInPrizon)

function updatePlayerJailTime(data)

    if data then
        exports.TR_mysql:querry("UPDATE tr_accounts SET prisonData = ? WHERE UID = ? LIMIT 1", data, getElementData(client, "characterUID"))
    else
        exports.TR_mysql:querry("UPDATE tr_accounts SET prisonData = NULL WHERE UID = ? LIMIT 1", getElementData(client, "characterUID"))
        onPlayerInPrizonTimeEnd(client)
    end
end
addEvent("updatePlayerJailTime", true)
addEventHandler("updatePlayerJailTime", resourceRoot, updatePlayerJailTime)

function getFreePrizonPosition(prisonIndex)
    local prisonIndex = tonumber(prisonIndex)
    if not prisonIndex then return end

    local cellIndex = getPrizonIndex(prisonIndex)

    local pos = {
        pos = {PoliceJails[prisonIndex].cells[cellIndex].pos.x, PoliceJails[prisonIndex].cells[cellIndex].pos.y, PoliceJails[prisonIndex].cells[cellIndex].pos.z},
        int = PoliceJails[prisonIndex].marker.int,
        dim = PoliceJails[prisonIndex].marker.dim,
    }
    return pos
end

function getPrizonIndex(prisonIndex)
    local needFree = 0
    local index = 1

    while needFree do
        local count = #PoliceJails[prisonIndex].cells[index].players

        if count == needFree then
            return index
        end

        if index >= #PoliceJails[prisonIndex].cells then
            index = 1
            needFree = needFree + 1
        else
            index = index + 1
        end
    end
end


function removePlayerFromPrizonOnQuit()
    local prisonIndex = getElementData(source, "prisonIndex")
    if not prisonIndex then return end

    for i, v in pairs(PoliceJails[prisonIndex].cells) do
        for k, plr in pairs(v.players) do
            if plr == source then
                table.remove(PoliceJails[prisonIndex].cells[i].players, k)
                return
            end
        end
    end
end
addEventHandler("onPlayerQuit", root, removePlayerFromPrizonOnQuit)