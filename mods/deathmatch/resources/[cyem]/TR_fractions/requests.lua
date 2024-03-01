local requests = {
    ["p"] = {},
    ["m"] = {},
    ["f"] = {},
    ["ers"] = {},
}


function addFractionRequest(fraction, text)
    if requests[fraction][client] then exports.TR_noti:create(client, "Zaten bir hizmet raporu gönderdiniz.", "error") return end
    requests[fraction][client] = {pos = {getElementPosition(client)}, time = getRequestTime(), text = text, tick = getTickCount()}

    exports.TR_noti:create(client, "Hizmetler bilgilendirildi. Yakında biri gelmelidir.", "success")
    triggerClientEvent(root, "addedFractionReport", resourceRoot, fraction)
end
addEvent("addFractionRequest", true)
addEventHandler("addFractionRequest", root, addFractionRequest)

function addFractionCustomRequest(fraction, sender, text, pos)
    if requests[fraction][sender] then return false end
    requests[fraction][sender] = {pos = pos, time = getRequestTime(), text = text, tick = getTickCount(), isCustom = true}
    return true
end

function getRequestTime()
    local time = getRealTime()
    return string.format("%02d:%02d", time.hour, time.minute)
end

function getFractionPanel(fraction)
    for i, v in pairs(requests[fraction]) do
        if not isElement(i) and not v.isCustom then
            requests[fraction][i] = nil

        elseif (getTickCount() - v.tick)/600000 > 1 and not v.isCustom then
            requests[fraction][i] = nil
        end
    end

    triggerClientEvent(client, "updateFractionPanel", resourceRoot, requests[fraction])
end
addEvent("getFractionPanel", true)
addEventHandler("getFractionPanel", resourceRoot, getFractionPanel)

function selectFractionRequest(fraction, player)
    if requests[fraction][player] then
        if (getTickCount() - requests[fraction][player].tick)/600000 > 1 and not requests[fraction][player].isCustom then
            requests[fraction][player] = nil
            triggerClientEvent(client, "updateFractionPanel", resourceRoot, requests[fraction], "old")
            return
        end

        requests[fraction][player] = nil
        triggerClientEvent(client, "updateFractionPanel", resourceRoot, requests[fraction], "take")

        if isElement(player) then
            triggerClientEvent(player, "showCustomMessage", resourceRoot, "#d89932Dispeçer", "#ac7a28Rapor alındı. Uygun hizmetler yakında belirtilen konumda olacak.", "files/images/msg_received.png")
        end
    else
        triggerClientEvent(client, "updateFractionPanel", resourceRoot, requests[fraction], "taken")
    end
end
addEvent("selectFractionRequest", true)
addEventHandler("selectFractionRequest", resourceRoot, selectFractionRequest)