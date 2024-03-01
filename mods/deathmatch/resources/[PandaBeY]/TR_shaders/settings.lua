local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = 45/zoom,
    y = sy - 265/zoom,
    size = 22/zoom,

    font = exports.TR_dx:getFont(10)
}

local shaderSettings = {
    effectInfos = {}
}

local trip_objects = {
    1609, 1608, 1607, 1606, 1605, 1604, 1603, 1602, 1601, 1600, 1599, 1598
}


function setWaterTexture(state)
    if state and not shaderSettings.water then
        shaderSettings.water = WaterShader:create()

    elseif not state and shaderSettings.water then
        shaderSettings.water:destroy()
        shaderSettings.water = nil
    end
    exports.TR_dashboard:setDashboardResponseShader()
end

function setRainTexture(state)
    if state and not shaderSettings.rain then
        shaderSettings.rain = RainShader:create()

    elseif not state and shaderSettings.rain then
        shaderSettings.rain:destroy()
        shaderSettings.rain = nil
    end
    exports.TR_dashboard:setDashboardResponseShader()
end

function setDynamicSky(state)
	if state and not shaderSettings.sky then
        startDynamicSky()
        shaderSettings.sky = true

    elseif not state and shaderSettings.sky then
        stopDynamicSky()
        shaderSettings.sky = nil
    end
    exports.TR_dashboard:setDashboardResponseShader()
end

function setPalette(state)
	if state and not shaderSettings.palette then
        enablePalette()
        shaderSettings.palette = true

    elseif not state and shaderSettings.palette then
        disablePalette()
        shaderSettings.palette = nil
    end
    exports.TR_dashboard:setDashboardResponseShader()
end

function setTextures(state)
	if state and not shaderSettings.details then
        enableDetail()
        shaderSettings.details = true

    elseif not state and shaderSettings.details then
        disableDetail()
        shaderSettings.details = nil
    end
    exports.TR_dashboard:setDashboardResponseShader()
end

function setVehicleReflexes(state)
	if state and not shaderSettings.vehicles then
        startCarPaintRefLite()
        shaderSettings.vehicles = true

    elseif not state and shaderSettings.vehicles then
        stopCarPaintRefLite()
        shaderSettings.vehicles = nil
    end
    exports.TR_dashboard:setDashboardResponseShader()
end

function setMarijuanaEffect(state, strength, time)
    if state then
        enableEffect(3, true)
        setEffectMaxStrength(3, 0, math.min(strength, 1))

        if isTimer(shaderSettings.colorsTimer) then killTimer(shaderSettings.colorsTimer) end
        if time then
            local totalTime = time
            if shaderSettings.effectInfos["marijuana"] then
                if shaderSettings.effectInfos["marijuana"].feature then return end

                totalTime = totalTime + shaderSettings.effectInfos["marijuana"].time
            end

            shaderSettings.colorsTimer = setTimer(function()
                setMarijuanaEffect(false)
            end, totalTime * 1000, 1)

            shaderSettings.effectInfos["marijuana"] = {
                timeToEnd = getTickCount() + totalTime * 1000,
                time = totalTime,
                icon = "marijuana",
                effectTick = getTickCount(),
                effectTime = math.random(5000, 15000)
            }
        else
            shaderSettings.effectInfos["marijuana"] = nil
        end

    elseif not state then
        enableEffect(3, false)

        if isTimer(shaderSettings.colorsTimer) then killTimer(shaderSettings.colorsTimer) end

        shaderSettings.effectInfos["marijuana"] = nil
    end
    setElementData(localPlayer, "marijuana", state)
end

function setScreenEsotropia(state, strength, time)
    if state then
        enableEffect(4, true)
        setEffectMaxStrength(4, 0, strength)

        if isTimer(shaderSettings.esotropiaTimer) then killTimer(shaderSettings.esotropiaTimer) end
        if time then
            local totalTime = time
            if shaderSettings.effectInfos["beer"] then
                if shaderSettings.effectInfos["beer"].feature then return end

                totalTime = totalTime + shaderSettings.effectInfos["beer"].time
            end

            shaderSettings.esotropiaTimer = setTimer(function()
                setScreenEsotropia(false)
            end, totalTime * 1000, 1)

            shaderSettings.effectInfos["beer"] = {
                timeToEnd = getTickCount() + totalTime * 1000,
                time = totalTime,
                icon = "beer",
            }
        else
            shaderSettings.effectInfos["beer"] = nil
        end

    elseif not state then
        enableEffect(4, false)
        exports.TR_hud:setPlayerDrunk(false)

        if isTimer(shaderSettings.esotropiaTimer) then killTimer(shaderSettings.esotropiaTimer) end

        shaderSettings.effectInfos["beer"] = nil
    end
    setElementData(localPlayer, "beer", state)
end

function setXanaxEffect(state, strength, time)
    if state then
        if isTimer(shaderSettings.xanaxTimer) then killTimer(shaderSettings.xanaxTimer) end
        if time then
            local totalTime = time
            if shaderSettings.effectInfos["xanax"] then
                if shaderSettings.effectInfos["xanax"].feature then return end

                totalTime = totalTime + shaderSettings.effectInfos["xanax"].time
            end

            shaderSettings.xanaxTimer = setTimer(function()
                setGameSpeed(1)
            end, totalTime * 1000, 1)

            shaderSettings.effectInfos["xanax"] = {
                timeToEnd = getTickCount() + totalTime * 1000,
                time = totalTime,
                icon = "marijuana",
            }

            setGameSpeed(0.5)
        else
            shaderSettings.effectInfos["xanax"] = nil
        end

    elseif not state then
        if isTimer(shaderSettings.xanaxTimer) then killTimer(shaderSettings.xanaxTimer) end
        setGameSpeed(1)
        shaderSettings.effectInfos["xanax"] = nil
    end
    setElementData(localPlayer, "marijuana", state)
end

function setHeroinEffect(state, strength, time)
    if state then
        if isTimer(shaderSettings.heroinTimer) then killTimer(shaderSettings.heroinTimer) end
        if time then
            local totalTime = time
            if shaderSettings.effectInfos["heroin"] then
                if shaderSettings.effectInfos["heroin"].feature then return end

                totalTime = totalTime + shaderSettings.effectInfos["heroin"].time
            end

            shaderSettings.heroinTimer = setTimer(function()
                setGameSpeed(1)
            end, totalTime * 1000, 1)

            shaderSettings.effectInfos["heroin"] = {
                timeToEnd = getTickCount() + totalTime * 1000,
                time = totalTime,
                icon = "marijuana",
                effectTick = getTickCount(),
                effectTime = math.random(2000, 5000)
            }
        else
            shaderSettings.effectInfos["heroin"] = nil
        end

    elseif not state then
        if isTimer(shaderSettings.heroinTimer) then killTimer(shaderSettings.heroinTimer) end
        resetSkyGradient()
        resetWaterColor()
        resetFogDistance()
        shaderSettings.effectInfos["heroin"] = nil
    end
    setElementData(localPlayer, "marijuana", state)
end

function setCrackEffect(state, strength, time)
    if state then
        if isTimer(shaderSettings.crackTimer) then killTimer(shaderSettings.crackTimer) end
        if time then
            local totalTime = time
            if shaderSettings.effectInfos["crack"] then
                if shaderSettings.effectInfos["crack"].feature then return end

                totalTime = totalTime + shaderSettings.effectInfos["crack"].time
            end

            shaderSettings.crackTimer = setTimer(function()
                setGameSpeed(1)
            end, totalTime * 1000, 1)

            shaderSettings.effectInfos["crack"] = {
                timeToEnd = getTickCount() + totalTime * 1000,
                time = totalTime,
                icon = "marijuana",
                effectTick = getTickCount(),
                effectTime = math.random(1000, 2000)
            }
        else
            shaderSettings.effectInfos["crack"] = nil
        end

    elseif not state then
        if isTimer(shaderSettings.crackTimer) then killTimer(shaderSettings.crackTimer) end
        resetSkyGradient()
        resetWaterColor()
        resetFogDistance()
        shaderSettings.effectInfos["crack"] = nil
    end
    setElementData(localPlayer, "marijuana", state)
end

function render()
    checkFeatures()

    local i = 0
    for index, v in pairs(shaderSettings.effectInfos) do
        local icon = v.icon
        if v.feature then
            dxDrawImage(guiInfo.x, guiInfo.y - i * guiInfo.size, guiInfo.size, guiInfo.size, string.format("files/images/icons/%s.png", icon))
            drawTextShadowed("Permanentny", guiInfo.x + guiInfo.size + 5/zoom, guiInfo.y - i * guiInfo.size, guiInfo.x - 5/zoom, guiInfo.y - (i-1) * guiInfo.size, tocolor(255, 255, 255, 255), 1/zoom, guiInfo.font, "left", "center")

            if (getTickCount() - v.tick)/300000 >= 1 then
                v.tick = getTickCount()
                setElementHealth(localPlayer, math.max(getElementHealth(localPlayer) - math.random(1, 3), 1))

                if icon == "beer" then
                    exports.TR_noti:create("Alkol bağımlılığınız yüzünden hayatınızın bir kısmını kaybettiniz.", "info")
                elseif icon == "marijuana" then
                    exports.TR_noti:create("Uyuşturucu bağımlılığınız yüzünden hayatınızın bir kısmını kaybettiniz.", "info")
                end
            end
        else
            dxDrawImage(guiInfo.x, guiInfo.y - i * guiInfo.size, guiInfo.size, guiInfo.size, string.format("files/images/icons/%s.png", icon))
            drawTextShadowed(secondsToClock((v.timeToEnd - getTickCount())/1000), guiInfo.x + guiInfo.size + 5/zoom, guiInfo.y - i * guiInfo.size, guiInfo.x - 5/zoom, guiInfo.y - (i-1) * guiInfo.size, tocolor(255, 255, 255, 255), 1/zoom, guiInfo.font, "left", "center")

            v.time = (v.timeToEnd - getTickCount())/1000

            i = i + 1
            if v.time <= 0 then
                shaderSettings.effectInfos[index] = nil

                if index == "beer" then
                    setElementData(localPlayer, "beer", nil)
                else
                    setElementData(localPlayer, "marijuana", nil)
                end
            end
        end

        if v.effectTime then
            if (getTickCount() - v.effectTick)/v.effectTime >= 1 then
                v.effectTick = getTickCount()

                if index == "marijuana" then
                    triggerServerEvent("onPlayerCustomCommand", localPlayer, "me", "Nedensizce gülüyor")
                    v.effectTime = math.random(60000, 100000)

                elseif index == "heroin" then
                    local x,y,z = getElementPosition(getLocalPlayer())
                    local trip_object = createObject(trip_objects[math.random(#trip_objects)], math.random(x-20, x+20), math.random(y-20, y+20), math.random(z-20, z+20), math.random(-180, 180), math.random(-180, 180), math.random(-180, 180))
                    setElementCollisionsEnabled(trip_object, false)
                    setObjectScale(trip_object, math.random(10, 1000)/1000, math.random(0.1, 5), math.random(0.1, 5))
                    moveObject(trip_object, 2000, math.random(x-20, x+20), math.random(y-20, y+20), math.random(z-20, z+20))
                    setTimer(function()
                        if (isElement(trip_object)) then
                            destroyElement(trip_object)
                        end
                    end, 2000, 1)

                    setSkyGradient(math.random(0,255), math.random(0,255), math.random(0,255), math.random(0,255), math.random(0,255), math.random(0,255))
                    setWaterColor(math.random(0,255), math.random(0,255), math.random(0,255), math.random(0, 255))
                    setFogDistance(math.random(0,500))
                    v.effectTime = math.random(1000, 1500)

                elseif index == "crack" then
                    setSkyGradient(math.random(0,255), math.random(0,255), math.random(0,255), math.random(0,255), math.random(0,255), math.random(0,255))
                    setWaterColor(math.random(0,255), math.random(0,255), math.random(0,255), math.random(0, 255))
                    setFogDistance(math.random(0,500))
                    v.effectTime = math.random(1000, 2000)
                end
            end
        end
    end
end
addEventHandler("onClientRender", root, render)

function checkFeatures()
    local drunk = exports.TR_features:getFeatureValue("cheers")
    local drugs = exports.TR_features:getFeatureValue("pills")

    if drunk >= 80 and not shaderSettings.effectInfos["beer"] then
        shaderSettings.effectInfos["beer"] = {
            feature = true,
            tick = getTickCount(),
        }
        enableEffect(4, true)
        setEffectMaxStrength(4, 0, 1)

    elseif drunk < 80 and shaderSettings.effectInfos["beer"] then
        if shaderSettings.effectInfos["beer"].feature then
            shaderSettings.effectInfos["beer"] = nil

            setScreenEsotropia(false)
        end
    end

    if drugs >= 70 and not shaderSettings.effectInfos["marijuana"] then
        shaderSettings.effectInfos["marijuana"] = {
            feature = true,
            tick = getTickCount(),
        }
        enableEffect(3, true)
        setEffectMaxStrength(3, 0, 1)

    elseif drugs < 70 and shaderSettings.effectInfos["marijuana"] then
        if shaderSettings.effectInfos["marijuana"].feature then
            shaderSettings.effectInfos["marijuana"] = nil

            setMarijuanaEffect(false)
        end
    end
end

function secondsToClock(seconds)
    local seconds = tonumber(seconds)

    if seconds <= 0 then
      return "00:00";
    else
      mins = string.format("%02.f", math.floor(seconds/60));
      secs = string.format("%02.f", math.floor(seconds - mins *60));
      return mins..":"..secs
    end
end

function drawTextShadowed(text, x, y, w, h, color, scale, font, vert, hori, clip, brake, post, colored)
	dxDrawText(text, x + 1, y + 1, w + 1, h + 1, tocolor(0, 0, 0, 100), scale, font, vert, hori, clip, brake, post)
	dxDrawText(text, x, y, w, h, color, scale, font, vert, hori, clip, brake, post, colored)
end


-- Fixer
setGameSpeed(1)
resetSkyGradient()
resetWaterColor()
resetFogDistance()
resetWindVelocity()
resetSunColor()
resetHeatHaze()
setCameraShakeLevel(1)