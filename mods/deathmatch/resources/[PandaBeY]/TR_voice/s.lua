addEventHandler("onPlayerJoin", root, function()
    setPlayerVoiceIgnoreFrom(source, root)
    setPlayerVoiceBroadcastTo(source, nil)
end)

function broadcastUpdate(broadcastList)
    if not client or source ~= client then return end

    if not broadcastList then
        setPlayerVoiceIgnoreFrom(source, root)
        setPlayerVoiceBroadcastTo(source, nil)
    else
        setPlayerVoiceIgnoreFrom(source, root)
        setPlayerVoiceBroadcastTo(source, broadcastList)
    end
end
addEvent("proximity-voice::broadcastUpdate", true)
addEventHandler("proximity-voice::broadcastUpdate", root, broadcastUpdate)