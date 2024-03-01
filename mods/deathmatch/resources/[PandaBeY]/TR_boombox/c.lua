local settings = {
    distance = 15,
    maxSound = 0.1,
}
local playingRadios = {}

function adjustSoundsDimensions()
    local plrPos = Vector3(getElementPosition(localPlayer))
    local int = getElementInterior(localPlayer)
    local dim = getElementDimension(localPlayer)

    for plr, v in pairs(playingRadios) do
        if v.isBrowser then
            local dist = getDistanceBetweenPoints3D(plrPos, getElementPosition(v.element))
            if dist <= settings.distance and int == getElementInterior(v.element) and dim == getElementDimension(v.element) then
                setBrowserVolume(v.sound, settings.maxSound - dist/(settings.distance/settings.maxSound))
            else
                setBrowserVolume(v.sound, 0)
            end
        else
            setElementInterior(v.sound, int)
            setElementDimension(v.sound, dim)
        end
    end
end
addEventHandler("onClientRender", root, adjustSoundsDimensions)

function destroyBoomboxSound(owner)
    if not playingRadios[owner] then return end

    if isElement(playingRadios[owner].sound) then destroyElement(playingRadios[owner].sound) end
    if isTimer(playingRadios[owner].timer) then killTimer(playingRadios[owner].timer) end

    removeEventHandler("onClientElementDestroy", playingRadios[owner].element, onColDestroy)

    playingRadios[owner] = nil
end

function playBoomboxSound(data, nowTick)
    if not data or not nowTick then return end
    if playingRadios[data.owner] then
        if playingRadios[data.owner].url == data.url then return end
        destroyBoomboxSound(data.owner)
    end


    if string.find(data.url, "youtube") then
        local videoID = getYoutubeVideoID(data.url)

        local browser = createBrowser(1, 1, false)
        local time = math.floor((nowTick - data.startTick)/1000)

        addEventHandler("onClientBrowserCreated", browser, function()
            loadBrowserURL(browser, string.format("https://www.youtube.com/embed/%s?autoplay=1&iv_load_policy=3&enablejsapi=1&fs=0&theme=light&start=%d", videoID, time))
        end)

        playingRadios[data.owner] = {
            sound = browser,
            col = data.sphere,
            element = data.element,
            url = data.url,
            isBrowser = true,
        }

    else
        local sound = playSound3D(data.url, 0, 0, 0, true, false)
        setSoundMinDistance(sound, 8)
        setSoundMaxDistance(sound, 12)

        setElementInterior(sound, getElementInterior(data.owner))
        setElementDimension(sound, getElementDimension(data.owner))

        attachElements(sound, data.element)
        setSoundPaused(sound, true)

        playingRadios[data.owner] = {
            sound = sound,
            timer = setTimer(adjustBoomboxSound, 100, 0, data.owner),
            time = math.floor((nowTick - data.startTick)/100)/10,
            startCountTime = getTickCount(),
            col = data.sphere,
            element = data.element,
            url = data.url,
        }
    end

    addEventHandler("onClientElementDestroy", data.element, onColDestroy)
end
addEvent("playBoomboxSound", true)
addEventHandler("playBoomboxSound", root, playBoomboxSound)

function adjustBoomboxSound(owner)
    if not isElement(playingRadios[owner].sound) then return end

    setSoundPaused(playingRadios[owner].sound, true)
    setSoundPosition(playingRadios[owner].sound, playingRadios[owner].time + math.floor((getTickCount() - playingRadios[owner].startCountTime)/100)/10)

    if getSoundPosition(playingRadios[owner].sound) == playingRadios[owner].time + math.floor((getTickCount() - playingRadios[owner].startCountTime)/100)/10 then
        setSoundPaused(playingRadios[owner].sound, false)
        killTimer(playingRadios[owner].timer)
    end
end

function onColShapeLeave(el, md)
    if el ~= localPlayer then return end
    for owner, v in pairs(playingRadios) do
        if v.col == source then
            destroyBoomboxSound(owner)

            if owner == localPlayer then
                local data = getElementData(localPlayer, "boombox")
                exports.TR_items:setBoomboxUsed(data.itemID, false)
                exports.TR_noti:create("Müzik kutunuzdan çok uzaklaştınız ve otomatik olarak devre dışı bırakıldı.", "info")
                triggerServerEvent("destroyPlayerBoombox", resourceRoot)
            end
        end
    end
end
addEventHandler("onClientColShapeLeave", resourceRoot, onColShapeLeave)

function onColDestroy()
    for owner, v in pairs(playingRadios) do
        if v.element == source then
            destroyBoomboxSound(owner)
        end
    end
end

function adminRemoveBoombox(adminName)
    destroyBoomboxSound(owner)

    local data = getElementData(localPlayer, "boombox")
    exports.TR_items:setBoomboxUsed(data.itemID, false)
    exports.TR_noti:create(string.format("Yönetici %s, müzik kutunuzu devre dışı bıraktı.", adminName), "info")
    triggerServerEvent("destroyPlayerBoombox", resourceRoot)
end
addEvent("adminRemoveBoombox", true)
addEventHandler("adminRemoveBoombox", root, adminRemoveBoombox)


function getYoutubeVideoID(url)
    local url = split(url, 'v=')
    if not url or not url[2] then return false end

    local videoID = url[2]
    local ampersandPosition = string.find(videoID, '&')
    if ampersandPosition then
        videoID = string.sub(videoID, 0, ampersandPosition - 1)
    end
    return videoID
end