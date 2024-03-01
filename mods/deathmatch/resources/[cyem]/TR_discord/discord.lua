addEvent("onDiscordPacket")

local discordChannels = {
    ["chat"] = {
        type = "chat.message.text",
        channel = "💬┋chat-lokalny",
    },
    ["pm"] = {
        type = "chat.message.pm",
        channel = "📨┋chat-prywatny",
    },
    ["medo"] = {
        type = "chat.message.text",
        channel = "🩸┋chat-me-do",
    },
    ["premium"] = {
        type = "chat.message.text",
        channel = "⭐┋chat-premium",
    },
    ["fraction"] = {
        type = "chat.message.text",
        channel = "📞┋chat-frakcyjny",
    },
    ["organization"] = {
        type = "chat.message.text",
        channel = "📞┋chat-organizacyjny",
    },
    ["trade"] = {
        type = "chat.message.trade",
        channel = "",
    },
    ["add"] = {
        type = "chat.message.text",
        channel = "🔍┋ogłoszenia",
    },
    ["adminPenalties"] = {
        type = "chat.message.text",
        channel = "❗┋kary-administracji",
    },
    ["adminAction"] = {
        type = "chat.message.text",
        channel = "💼┋akcje-administracji",
    },
    ["adminFlight"] = {
        type = "chat.message.text",
        channel = "💨┋latanie-administracji",
    },
    ["moneyTransfer"] = {
        type = "chat.message.text",
        channel = "💲┋przelewy",
    },
    ["moneyEarnings"] = {
        type = "chat.message.text",
        channel = "💲┋zarobki",
    },
    ["onPlayerDeath"] = {
        type = "chat.message.text",
        channel = "💀┋śmierci",
    },
    ["onFishBot"] = {
        type = "chat.message.text",
        channel = "🎣┋podejrzenia-rybackie",
    },
    ["casinoActions"] = {
        type = "chat.message.text",
        channel = "🎰┋wygrane-kasyno",
    },
    ["vehicleBuy"] = {
        type = "chat.message.text",
        channel = "🚗┋zakup-pojazdu",
    },
    ["playerTookItems"] = {
        type = "chat.message.text",
        channel = "🧰┋przeszukania",
    },
}

local socket = false

function createSocketFromConfig()
     local config = xmlLoadFile("config.xml")
     local channel = xmlNodeGetValue(xmlFindChild(config, "channel", 0))
     local passphrase = xmlNodeGetValue(xmlFindChild(config, "passphrase", 0))
     local hostname = xmlNodeGetValue(xmlFindChild(config, "hostname", 0))
     local port = tonumber(xmlNodeGetValue(xmlFindChild(config, "port", 0)))
     xmlUnloadFile(config)

     createDiscordPipe(hostname, port, passphrase, channel)
end

function sendChannelMsg(msgType, payload)
    local data = discordChannels[msgType]
    if not data then return end
    if not socket then return end

    payload.channel = data.channel

    socket:write(table.json {
        type = data.type,
        payload = payload,
    })
end
addEvent("sendDiscordChannelMsg", true)
addEventHandler("sendDiscordChannelMsg", root, sendChannelMsg)

function createDiscordPipe(hostname, port, passphrase, channel)
    socket = Socket:create(hostname, port, { autoReconnect = true })
    socket.channel = channel
    socket.passphrase = passphrase
    socket.bindmessage = false

    socket:on("ready", function (socket)
        outputDebugString("[Discord] Connected to ".. hostname .." on port ".. port)
        sendAuthPacket(socket)
    end)

    socket:on("data", handleDiscordPacket)

    socket:on("close", function (socket)
        outputDebugString("[Discord] Disconnected from ".. hostname)

        setTimer(
            function ()
                outputDebugString("[Discord] Reconnecting now..")
                socket:connect()
            end,
        15000, 1)
    end)
end

function sendAuthPacket(socket)
    local salt = md5(getTickCount() + getRealTime().timestamp)

    socket:write(table.json {
        type = "auth",
        payload = {
            salt = salt,
            passphrase = hash("sha256", salt .. hash("sha512", socket.passphrase):lower()):lower()
        }
    })
end

function handlePingPacket(socket)
    return socket:write(table.json { type = "pong" })
end

function handleAuthPacket(socket, payload)
    if payload.authenticated then
        outputDebugString("[Discord] Authentication successful")

        socket:write(table.json {
            type = "select-channel",
            payload = {
                channel = socket.channel
            }
        })
    else
        local error = tostring(payload.error) or "unknown error"
        outputDebugString("[Discord] Failed to authenticate: ".. error)
        socket:disconnect()
    end
end

function handleSelectChannelPacket(socket, payload)
    if payload.success then
        if payload.wait then
            outputDebugString("[Discord] Bot isn't ready")
        else
            outputDebugString("[Discord] Channel has been bound")

            if not socket.bindmessage then
                socket:write(table.json {
                    type = "chat.message.info",
                    payload = {
                        author = "Server",
                        channel = "system",
                        text = "Pomyślnie połączony!"
                    }
                })
                socket.bindmessage = true
            end
        end
    else
        local error = tostring(payload.error) or "unknown error"
        outputDebugString("[Discord] Failed to bind channel: ".. error)
        socket:disconnect()
    end
end

function handleDisconnectPacket(socket)
    outputDebugString("[Discord] Server has closed the connection")
    socket:disconnect()
    socket.bindmessage = false
end

function handleDiscordPacket(socket, packet, payload)
    if packet == "ping" then
        return handlePingPacket(socket)

    elseif packet == "auth" then
        return handleAuthPacket(socket, payload)

    elseif packet == "select-channel" then
        return handleSelectChannelPacket(socket, payload)

    elseif packet == "disconnect" then
        return handleDisconnectPacket(socket)

    elseif packet == "text.message" then
        return setConsoleChat(payload)

    else
        return triggerEvent("onDiscordPacket", resourceRoot, packet, payload)
    end
end

function setConsoleChat(payload)
    triggerClientEvent(root, "showCustomMessage", resourceRoot, string.format("#af31b0(CONSOLE) %s", payload.author.name), "#cf3bd1"..payload.message.text, "files/images/command.png")
end

-- setTimer(function()
    -- socket:write(table.json{
        -- type = "chat.message.info",
        -- payload = {
            -- author = "Server",
            -- channel = "system",
            -- text = "Utrzymanie połączenia."
        -- }
    -- })
-- end, 60000, 0)