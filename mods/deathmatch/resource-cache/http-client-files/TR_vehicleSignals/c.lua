local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local settings = {
    blockHorn = {
        [601] = true,
        [597] = true,
        [599] = true,
        [598] = true,
        [596] = true,
        [544] = true,
        [407] = true,
        [528] = true,
        [490] = true,
        [427] = true,
        [416] = true,
        [433] = true,
        [512] = true,
    },

    hornSounds = {
        [416] = "files/sounds/ambulance/horn.wav",
        [598] = "files/sounds/police/horn.wav",
        [599] = "files/sounds/police/horn.wav",
        [601] = "files/sounds/police/horn.wav",
        [427] = "files/sounds/police/horn.wav",
        [490] = "files/sounds/police/horn.wav",
        [596] = "files/sounds/police/horn.wav",
        [544] = "files/sounds/fire/horn.wav",
        [407] = "files/sounds/fire/horn.wav",
        [433] = "files/sounds/fire/horn.wav",
        [512] = "files/sounds/sleigh/sleigh.wav",
    },

    avaliableVehicles = {
        [416] = "ambulance",
        [544] = "fire",
        [407] = "fire",
        [470] = "ambulance",
        [433] = "fire",
        [440] = "fire",
        [443] = "fire",
        [601] = "swat",
        [427] = "swat",
        [490] = "swat",
        [598] = "police",
        [599] = "police",
        [596] = "police",
        [523] = "policebike",
        [497] = "police",
        [560] = "police",
        [426] = "police",
        [551] = "police",
        [421] = "police",
        [609] = "police",
        [597] = "police",
        [604] = "police",
        [504] = "police",
        [428] = "ers",
        [482] = "ers",
        [525] = "ers",
        [552] = "ers",
        [507] = "ers",
        [579] = "ers",
        [489] = "ers",
        [554] = "ers",
        [512] = true,
    },

    sirenNormalLights = {
        ["ambulance"] = {
            colorLeft = {255, 255, 255},
            colorRight = {255, 255, 255},
        },
        ["police"] = {
            colorLeft = {0, 0, 255},
            colorRight = {255, 0, 0},
        },
        ["swat"] = {
            colorLeft = {255, 255, 255},
            colorRight = {255, 255, 255},
        },
        ["fire"] = {
            colorLeft = {255, 255, 255},
            colorRight = {255, 255, 255},
        },
        ["ers"] = {
            colorLeft = {255, 149, 0},
            colorRight = {255, 149, 0},
        },
    },

    sirenType = {
        ["ambulance"] = {
            [1] = {
                {state = 1, time = 2},
                {state = 2, time = 2},
            },
            [2] = {
                {state = 1, time = 3},
                {state = 2, time = 3},
            },
            [3] = {
                {state = 1, time = 5},
                {state = 2, time = 5},
            },
            [4] = {
                {state = 1, time = 3},
                {state = 2, time = 3},
            },
        },
        ["police"] = {
            [1] = {
                {state = 1, time = 1},
                {state = 0, time = 1},
                {state = 1, time = 2},
                {state = 0, time = 1},
                {state = 2, time = 2},
                {state = 0, time = 1},
                {state = 2, time = 1},
                {state = 0, time = 1},
            },
            [2] = {
                {state = 1, time = 2},
                {state = 0, time = 1},
                {state = 2, time = 2},
                {state = 0, time = 1},
            },
            [3] = {
                {state = 1, time = 1},
                {state = 2, time = 1},
            },
        },
        ["swat"] = {
            [1] = {
                {state = 1, time = 1},
                {state = 0, time = 1},
                {state = 1, time = 2},
                {state = 0, time = 1},
                {state = 2, time = 2},
                {state = 0, time = 1},
                {state = 2, time = 1},
                {state = 0, time = 1},
            },
            [2] = {
                {state = 1, time = 2},
                {state = 2, time = 2},
            },
            [3] = {
                {state = 1, time = 3},
                {state = 2, time = 3},
            },
        },
        ["policebike"] = {
            [1] = {
                {state = 1, time = 1},
                {state = 0, time = 1},
                {state = 1, time = 2},
                {state = 0, time = 1},
                {state = 2, time = 2},
                {state = 0, time = 1},
                {state = 2, time = 1},
                {state = 0, time = 1},
            },
            [2] = {
                {state = 1, time = 2},
                {state = 2, time = 2},
            },
        },
        ["fire"] = {
            [1] = {
                {state = 1, time = 1},
                {state = 3, time = 1},
                {state = 2, time = 1},
                {state = 3, time = 1},
            },
            [2] = {
                {state = 1, time = 1},
                {state = 2, time = 1},
            },
            [3] = {
                {state = 1, time = 8},
                {state = 2, time = 8},
            },
        },
        ["ers"] = {
            [1] = {
                {state = 1, time = 1},
                {state = 3, time = 1},
                {state = 2, time = 1},
                {state = 3, time = 1},
            },
            [2] = {
                {state = 1, time = 1},
                {state = 2, time = 1},
            },
            [3] = {
                {state = 1, time = 8},
                {state = 2, time = 8},
            },
        },
    },

    sirenNames = {
        ["ambulance"] = {
            [1] = "Sinyaller kapalı",
            [2] = "Sinyal 1",
            [3] = "Sinyal 2",
            [4] = "Sinyal 3",
        },
        ["police"] = {
            [1] = "Sinyaller kapalı",
            [2] = "Sinyal 1",
            [3] = "Sinyal 2",
            [4] = "Sinyal 3",
        },
        ["swat"] = {
            [1] = "Sinyaller kapalı",
            [2] = "Sinyal 1",
            [3] = "Sinyal 2",
        },
        ["policebike"] = {
            [1] = "Sinyaller kapalı",
            [2] = "Sinyal 1",
            [3] = "Sinyal 2",
        },
        ["fire"] = {
            [1] = "Sinyaller kapalı",
            [2] = "Sinyal 1",
            [3] = "Sinyal 2",
            [4] = "Sinyal 3",
        },
        ["ers"] = {
            [1] = "Sinyaller kapalı",
            [2] = "Sinyal 1",
            [3] = "Sinyal 2",
            [4] = "Sinyal 3",
        },
    },

    sirenSounds = {
        ["police"] = {
            [1] = "files/sounds/police/1.wav",
            [2] = "files/sounds/police/2.wav",
            [3] = "files/sounds/police/3.wav",
        },
        ["policebike"] = {
            [1] = "files/sounds/policebike/1.wav",
            [2] = "files/sounds/policebike/2.wav",
        },
        ["fire"] = {
            [1] = "files/sounds/fire/1.wav",
            [2] = "files/sounds/fire/2.wav",
            [3] = "files/sounds/fire/3.wav",
        },
        ["ambulance"] = {
            [1] = "files/sounds/ambulance/1.wav",
            [2] = "files/sounds/ambulance/2.wav",
            [3] = "files/sounds/ambulance/3.wav",
        },
        ["swat"] = {
            [1] = "files/sounds/swat/1.wav",
            [2] = "files/sounds/swat/2.wav",
        },
    },

    gui = {
        x = 46/zoom,
        y = sy - 360/zoom,
        w = 340/zoom,
        h = 100/zoom,
    },
}

VehicleSignals = {}
VehicleSignals.__index = VehicleSignals

function VehicleSignals:create()
    local instance = {}
    setmetatable(instance, VehicleSignals)
    if instance:constructor() then
        return instance
    end
    return false
end

function VehicleSignals:constructor()
    self.streamed = {}
    self.sirens = {}
    self.horns = {}

    self.fonts = {}
    self.fonts.siren = exports.TR_dx:getFont(12)
    self.fonts.small = exports.TR_dx:getFont(10)

    self.state = 0

    self.shader = dxCreateShader("files/shaders/replace.fx")
    self.shaderBar = dxCreateShader("files/shaders/replace.fx")
    self.texture = dxCreateTexture("files/images/lights.png", "dxt4", true, "clamp")
    self.textureBar = dxCreateTexture("files/images/lightsBar.png", "dxt4", true, "clamp")
    dxSetShaderValue(self.shader, "gTexture", self.texture)
    dxSetShaderValue(self.shaderBar, "gTexture", self.textureBar)

    self.func = {}
    self.func.checkSiren = function() self:checkSiren() end
    self.func.checkVehicles = function() self:checkVehicles() end
    self.func.streamIn = function() self:streamIn() end
    self.func.streamOut = function() self:streamOut() end
    self.func.switchGui = function(...) self:switchGui(...) end
    self.func.renderGui = function() self:renderGui() end
    self.func.setLights = function(...) self:setLights(...) end

    setTimer(self.func.checkSiren, 100, 0)
    setTimer(self.func.checkVehicles, 1000, 0)

    bindKey("z", "both", self.func.switchGui)

    addEventHandler("onClientElementStreamIn", root, self.func.streamIn)
    addEventHandler("onClientElementStreamOut", root, self.func.streamOut)
    self:loadVehicles()
    return true
end

function VehicleSignals:removeVehicleSiren(veh)
    if isElement(self.horns[veh]) then destroyElement(self.horns[veh]) end
    if self.sirens[veh] and isElement(self.sirens[veh].sound) then destroyElement(self.sirens[veh].sound) end
    self.streamed[veh] = nil
    self.sirens[veh] = nil
    self.horns[veh] = nil
end

function VehicleSignals:getElementModel(veh)
    return getElementData(veh, "oryginalModel") or getElementModel(veh)
end

function VehicleSignals:streamIn()
    if settings.avaliableVehicles[self:getElementModel(source)] then
        self.streamed[source] = source
    end
end

function VehicleSignals:streamOut()
    self:removeVehicleSiren(source)
end

function VehicleSignals:checkVehicles()
    for i, v in pairs(self.streamed) do
        self:checkHorn(v)

        if not isElement(i) or not isElementStreamedIn(i) then
            self:removeVehicleSiren(i)
        else
            if not self.sirens[v] then
                local sirens = getElementData(v, "vehicleSirens")
                if sirens then
                    if not sirens[1] then
                        setVehicleHeadLightColor(v, 255, 255, 255)
                        setVehicleLightState(v, 0, 0)
                        setVehicleLightState(v, 1, 0)
                    else
                        self.sirens[v] = {
                            state = 1,
                            sirens = sirens[1],
                            sound = sirens[2],
                            time = 0,
                        }

                        local sirenSound = self:getSirenSound(sirens, v)
                        if sirenSound and sirens[1] and sirens[2] then
                            if isElement(self.sirens[v].sound) then destroyElement(self.sirens[v].sound) end
                            self.sirens[v].sound = playSound3D(sirenSound, 0, 0, 0, true)
                            setSoundMinDistance(self.sirens[v].sound, 10)
                            setSoundMaxDistance(self.sirens[v].sound, 100)
                            attachElements(self.sirens[v].sound, v)
                        end
                    end
                end

            elseif self.sirens[v] then
                local sirens = getElementData(v, "vehicleSirens")
                if not sirens then
                    self:updateShader(v, false)
                end
            end
        end
    end
end

function VehicleSignals:checkSiren()
    for i, v in pairs(self.streamed) do
        self:checkHorn(v)
    end
    for i, v in pairs(self.sirens) do
        self:updateShader(i, v)
    end

    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return end
    if getPedOccupiedVehicleSeat(localPlayer) > 0 then return end
    if not settings.blockHorn[self:getElementModel(veh)] then
        toggleControl("horn", true)

    else
        toggleControl("horn", false)

        if not settings.hornSounds[self:getElementModel(veh)] then return end
        if getKeyState("h") and not isCursorShowing() then
            if not getElementData(veh, "horn") then
                setElementData(veh, "horn", true)
            end
        else
            if getElementData(veh, "horn") then
                setElementData(veh, "horn", nil)
            end
        end
    end
end

function VehicleSignals:getSirenSound(siren, veh)
    if not siren or not siren[1] or siren[1] < 1 or not siren[2] then return false end

    local model = self:getElementModel(veh)
    local type = settings.avaliableVehicles[model]
    if not type then return false end
    if not settings.sirenSounds[type] then return false end
    return settings.sirenSounds[type][siren[1]] or false
end

function VehicleSignals:getSirenNames()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return {} end

    local model = self:getElementModel(veh)
    local type = settings.avaliableVehicles[model]

    if not type then return {} end
    return settings.sirenNames[type] or false
end

function VehicleSignals:getSirenType(veh)
    local model = self:getElementModel(veh)
    local type = settings.avaliableVehicles[model]

    if not type then return {} end
    return settings.sirenType[type] or false
end

function VehicleSignals:checkHorn(veh)
    if not isElement(veh) then
        if isElement(self.horns[veh]) then destroyElement(self.horns[veh]) end
        self.horns[veh] = nil
        return
    end

    local horn = getElementData(veh, "horn")

    if (horn and not self.horns[veh]) then
        local model = self:getElementModel(veh)
        self.horns[veh] = playSound3D(settings.hornSounds[model], 0, 0, 0, true)
        if model == 512 then
            setSoundMinDistance(self.horns[veh], 40)
            setSoundMaxDistance(self.horns[veh], 80)
        else
            setSoundMinDistance(self.horns[veh], 10)
            setSoundMaxDistance(self.horns[veh], 40)
        end
        attachElements(self.horns[veh], veh)

    elseif (not horn and self.horns[veh]) or (not getVehicleOccupant(veh, 0) and self.horns[veh]) then
        if isElement(self.horns[veh]) then destroyElement(self.horns[veh]) end
        self.horns[veh] = nil
    end
end

function VehicleSignals:updateShader(i, v)
    local sirens = getElementData(i, "vehicleSirens")
    if not sirens or not sirens[1] or not sirens[2] then
        if isElement(self.sirens[i].sound) then destroyElement(self.sirens[i].sound) end
    end
    if not sirens[1] or not v then
        self:setLightState(0, i)
        if isElement(self.sirens[i].sound) then destroyElement(self.sirens[i].sound) end
        self.sirens[i] = nil
        return
    end

    if not v.state or v.sirens ~= sirens[1] then v.state = 1 end
    local selectedSiren = self:getSirenType(i)[sirens[1]]
    if not selectedSiren then return end
    local currentSirenState = selectedSiren[v.state]

    if v.sirens ~= sirens[1] then
        if isElement(self.sirens[i].sound) then destroyElement(self.sirens[i].sound) end

        local sirenSound = self:getSirenSound(sirens, i)
        if sirenSound then
            self.sirens[i].sound = playSound3D(sirenSound, 0, 0, 0, true)
            setSoundMinDistance(self.sirens[i].sound, 10)
            setSoundMaxDistance(self.sirens[i].sound, 100)
            attachElements(self.sirens[i].sound, i)
        end
    end

    if sirens[2] then
        if not isElement(self.sirens[i].sound) then
            local sirenSound = self:getSirenSound(sirens, i)
            if sirenSound then
                self.sirens[i].sound = playSound3D(sirenSound, 0, 0, 0, true)
                setSoundMinDistance(self.sirens[i].sound, 10)
                setSoundMaxDistance(self.sirens[i].sound, 100)
                attachElements(self.sirens[i].sound, i)
            end
        end

    elseif not sirens[2] then
        if isElement(self.sirens[i].sound) then destroyElement(self.sirens[i].sound) end
    end
    self.sirens[i].sirens = sirens[1]

    self:setLightState(currentSirenState.state, i)

    self.sirens[i].time = self.sirens[i].time + 1
    if v.time >= currentSirenState.time then
        self.sirens[i].time = 0
        self.sirens[i].state = self.sirens[i].state + 1 > #selectedSiren and 1 or self.sirens[i].state + 1
    end
end

function VehicleSignals:loadVehicles()
    for i, v in pairs(getElementsByType("vehicle", root, true)) do
        if settings.avaliableVehicles[self:getElementModel(v)] then
            self.streamed[v] = v
        end
    end
end

function VehicleSignals:setLightState(state, veh)
    if not isElement(veh) then return end
    local model = self:getElementModel(veh)
    if state == 0 then
        engineRemoveShaderFromWorldTexture(self.shader, "vehiclelightsonelm1", veh)
        engineRemoveShaderFromWorldTexture(self.shader, "vehiclelightsonelm2", veh)
        engineRemoveShaderFromWorldTexture(self.shaderBar, "vehiclelightsonelm3", veh)
        engineRemoveShaderFromWorldTexture(self.shaderBar, "vehiclelightsonelm4", veh)
        engineRemoveShaderFromWorldTexture(self.shader, "vehs1", veh)
        engineRemoveShaderFromWorldTexture(self.shader, "vehs2", veh)

        local type = settings.avaliableVehicles[model]
        if type then
            local lights = settings.sirenNormalLights[type]
            if lights then
                setVehicleOverrideLights(veh, 1)
                setVehicleHeadLightColor(veh, 255, 255, 255)
            end
        end

    elseif state == 1 then
        engineApplyShaderToWorldTexture(self.shader, "vehiclelightsonelm1", veh)
        engineApplyShaderToWorldTexture(self.shaderBar, "vehiclelightsonelm3", veh)
        engineRemoveShaderFromWorldTexture(self.shader, "vehiclelightsonelm2", veh)
        engineRemoveShaderFromWorldTexture(self.shaderBar, "vehiclelightsonelm4", veh)
        engineApplyShaderToWorldTexture(self.shader, "vehs2", veh)
        engineRemoveShaderFromWorldTexture(self.shader, "vehs1", veh)

        local type = settings.avaliableVehicles[model]
        if type then
            local lights = settings.sirenNormalLights[type]
            if lights then
                setVehicleOverrideLights(veh, 2)
                setVehicleLightState(veh, 0, 1)
                setVehicleLightState(veh, 1, 0)
                setVehicleHeadLightColor(veh, lights.colorLeft[1], lights.colorLeft[2], lights.colorLeft[3])
            end
        end

    elseif state == 2 then
        engineApplyShaderToWorldTexture(self.shader, "vehiclelightsonelm2", veh)
        engineApplyShaderToWorldTexture(self.shaderBar, "vehiclelightsonelm4", veh)
        engineRemoveShaderFromWorldTexture(self.shader, "vehiclelightsonelm1", veh)
        engineRemoveShaderFromWorldTexture(self.shaderBar, "vehiclelightsonelm3", veh)
        engineRemoveShaderFromWorldTexture(self.shader, "vehs2", veh)
        engineApplyShaderToWorldTexture(self.shader, "vehs1", veh)

        local type = settings.avaliableVehicles[model]
        if type then
            local lights = settings.sirenNormalLights[type]
            if lights then
                setVehicleOverrideLights(veh, 2)
                setVehicleLightState(veh, 0, 0)
                setVehicleLightState(veh, 1, 1)
                setVehicleHeadLightColor(veh, lights.colorRight[1], lights.colorRight[2], lights.colorRight[3])
            end
        end
    end
end



-- GUI
function VehicleSignals:switchGui(key, state)
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return end
    if not settings.avaliableVehicles[self:getElementModel(veh)] then return end
    if not getElementData(veh, "fractionID") then return end
    if getPedOccupiedVehicleSeat(localPlayer) ~= 0 then return end

    if state == "down" then
        self:openGui()
    else
        self:closeGui()
    end
    cancelEvent()
end

function VehicleSignals:openGui()
    if self.opened then return end
    self.opened = true
    self.sirenLights = 0

    local sirens = #self:getSirenNames()
    settings.gui.h = 32/zoom + sirens * 20/zoom
    settings.gui.y = sy - 272/zoom - sirens * 20/zoom

    for i = 1, #self:getSirenType(getPedOccupiedVehicle(localPlayer)) + 1 do
        bindKey(i, "down", self.func.setLights)
    end
    bindKey("x", "down", self.func.setLights)
    bindKey("mouse_wheel_up", "down", self.func.setLights)
    bindKey("mouse_wheel_down", "down", self.func.setLights)
    addEventHandler("onClientRender", root, self.func.renderGui)
end

function VehicleSignals:closeGui()
    if not self.opened then return end
    self.opened = nil

    for i = 1, #self:getSirenType(getPedOccupiedVehicle(localPlayer)) + 1 do
        unbindKey(i, "down", self.func.setLights)
    end
    unbindKey("x", "down", self.func.setLights)
    unbindKey("mouse_wheel_up", "down", self.func.setLights)
    unbindKey("mouse_wheel_down", "down", self.func.setLights)
    removeEventHandler("onClientRender", root, self.func.renderGui)
end

function VehicleSignals:renderGui()
    self:drawBackground(settings.gui.x, settings.gui.y, settings.gui.w, settings.gui.h, tocolor(17, 17, 17, 255), 5)

    local siren, sound = self:getSirenVehicle()
    if not siren then
        dxDrawImage(settings.gui.x + 22/zoom, settings.gui.y + (settings.gui.h - 64/zoom)/2 - 2/zoom, 64/zoom, 64/zoom, "files/images/siren.png", 0, 0, 0, tocolor(60, 116, 194, 255))
    else
        self.sirenLights = self.sirenLights + 0.5
        if self.sirenLights >= 10 then self.sirenLights = 0 end
        self.sirenLights = self.sirenLights/zoom

        dxDrawImage(settings.gui.x + 22/zoom, settings.gui.y + (settings.gui.h - 64/zoom)/2 - 2/zoom, 64/zoom, 64/zoom, "files/images/siren.png", 0, 0, 0, tocolor(60, 116, 194, 255))
        dxDrawImage(settings.gui.x + 22/zoom - self.sirenLights/2, settings.gui.y + (settings.gui.h - 64/zoom)/2 - 2/zoom - self.sirenLights/2, 64/zoom + self.sirenLights, 64/zoom + self.sirenLights, "files/images/siren_lights.png", 0, 0, 0, tocolor(60, 116, 194, 255))
    end

    dxDrawText(sound and "Ses açık (x)" or "Ses kapalı (x)", settings.gui.x + settings.gui.w - 5/zoom, settings.gui.y + 9/zoom, settings.gui.x + settings.gui.w - 5/zoom, settings.gui.y + settings.gui.h - 5/zoom, tocolor(140, 140, 140, 255), 1/zoom, self.fonts.small, "right", "bottom")

    for i, v in pairs(self:getSirenNames()) do
        self:drawSirenText(string.format("%d. %s", i, v), i - 1, siren)
    end

    if not getPedOccupiedVehicle(localPlayer) then
        self:closeGui()
    end
end

function VehicleSignals:drawSirenText(text, i, siren)
    if not siren and i == 0 then
        dxDrawText(text, settings.gui.x + 115/zoom, settings.gui.y + 9/zoom + i * 20/zoom, settings.gui.x + 140/zoom, settings.gui.y + 20/zoom, tocolor(67, 135, 230, 255), 1/zoom, self.fonts.siren, "left", "top")
    elseif i == siren then
        dxDrawText(text, settings.gui.x + 115/zoom, settings.gui.y + 9/zoom + i * 20/zoom, settings.gui.x + 140/zoom, settings.gui.y + 20/zoom, tocolor(67, 135, 230, 255), 1/zoom, self.fonts.siren, "left", "top")
    else
        dxDrawText(text, settings.gui.x + 115/zoom, settings.gui.y + 9/zoom + i * 20/zoom, settings.gui.x + 140/zoom, settings.gui.y + 20/zoom, tocolor(140, 140, 140, 255), 1/zoom, self.fonts.siren, "left", "top")
    end
end

function VehicleSignals:getSirenVehicle()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return false end

    local siren = getElementData(veh, "vehicleSirens")
    if not siren then setElementData(veh, "vehicleSirens", {0, false}) return 0, false end
    return siren and siren[1] or false, siren[2]
end

function VehicleSignals:setLights(key)
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return end

    if key == "mouse_wheel_up" then
        local siren = self:getSirenVehicle()
        key = math.max(siren and siren or 1, 1)

    elseif key == "mouse_wheel_down" then
        local siren = self:getSirenVehicle()
        key = math.min(siren and siren + 2 or 2, #self:getSirenType(veh) + 1)

    elseif key == "x" then
        local currSiren = getElementData(veh, "vehicleSirens")
        setElementData(veh, "vehicleSirens", {currSiren and currSiren[1] or 0, not currSiren[2]})
        return
    end

    local currSiren = getElementData(veh, "vehicleSirens")
    if not currSiren then currSiren = {} end
    key = tonumber(key)
    if key == 1 then
        setElementData(veh, "vehicleSirens", {nil, currSiren[2]})
    else
        setElementData(veh, "vehicleSirens", {key - 1, currSiren[2]})
    end
end

function VehicleSignals:isGuiOpened()
    return self.opened
end

function VehicleSignals:drawBackground(x, y, rx, ry, color, radius, post)
    rx = rx - radius * 2
    ry = ry - radius * 2
    x = x + radius
    y = y + radius

    if (rx >= 0) and (ry >= 0) then
      dxDrawRectangle(x, y, rx, ry, color, post)
      dxDrawRectangle(x, y - radius, rx, radius, color, post)
      dxDrawRectangle(x, y + ry, rx, radius, color, post)
      dxDrawRectangle(x - radius, y, radius, ry, color, post)
      dxDrawRectangle(x + rx, y, radius, ry, color, post)

      dxDrawCircle(x, y, radius, 180, 270, color, color, 7, 1, post)
      dxDrawCircle(x + rx, y, radius, 270, 360, color, color, 7, 1, post)
      dxDrawCircle(x + rx, y + ry, radius, 0, 90, color, color, 7, 1, post)
      dxDrawCircle(x, y + ry, radius, 90, 180, color, color, 7, 1, post)
    end
end

function isGuiOpened()
    return settings.signals:isGuiOpened()
end

settings.signals = VehicleSignals:create()
