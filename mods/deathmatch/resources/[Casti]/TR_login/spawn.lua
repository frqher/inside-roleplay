local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    cameraHeight = 10,
    cameraDistance = 20,
    cameraTimeRotation = 60000,
    cameraTimeMoveUp = 280,

    cameraMoveHeight = 400,

    text = {
        x = 0,
        y = sy - 120/zoom,
        w = sx,
        h = sy,
    },

    defaultSpawns = {
        -- {
        --     pos = Vector3(-2103.0263671875, -2467.0712890625, 30.625),
        --     name = "EVENT ŚWIĄTECZNY | ANGEL PINE",
        --     premium = false,
        --     rot = 315,
        -- },
        {
            pos = Vector3(-1916.7041015625, 883.4033203125, 35.414),
            name = "DOWNTOWN | SAN FIERRO",
            premium = false,
            rot = 270,
        },
        {
            pos = Vector3(2363.2451171875, 2377.6279296875, 10.8203125),
            name = "ROCA ESCALANTE | LAS VENTURAS",
            premium = false,
            rot = 90,
        },
        {
            pos = Vector3(408.400390625, -1542.908203125, 32.2734375),
            name = "RODEO | LOS SANTOS",
            premium = false,
            rot = 225.05,
        },
        {
            pos = Vector3(-2389.2412109375, 2216.0693359375, 4.984375),
            name = "TIERRA ROBADA | BAYSIDE",
            premium = false,
            rot = 90,
        },
        {
            pos = Vector3(681.51171875, -477.29296875, 16.3359375),
            name = "DILLIMORE | RED COUNTY",
            premium = false,
            rot = 180,
        },

    },

    jobSpawns = {
        {
            pos = Vector3(-2279.4453125, 2279.6181640625, 4.9675340652466),
            name = "DEPO MESLEĞİ | BAYSIDE MARINA",
            premium = "diamond",
            rot = 314.51,
        },
        {
            pos = Vector3(-2401.15625, 700.2587890625, 35.171875),
            name = "BAHÇIVAN MESLEĞİ | SAN FIERRO",
            premium = "diamond",
        },
        {
            pos = Vector3(1040.23046875, -366.4072265625, 73.905654907227),
            name = "ÇİÇEKÇİLİK MESLEĞİ | RED COUNTY",
            premium = "diamond",
            rot = 44,
        },
        {
            pos = Vector3(-1818.4013671875, 156.4521484375, 15.109375),
            name = "KONTEYNER TEDARİKÇİ MESLEĞİ | SAN FIERRO",
            premium = "diamond",
            rot = 273.63,
        },
        {
            pos = Vector3(-2720.07421875, 76.1689453125, 4.3359375),
            name = "SÜPÜRGE MESLEĞİ | SAN FIERRO",
            premium = "diamond",
            rot = 90,
        },
        {
            pos = Vector3(1375.3193359375, 1026.75, 10.8203125),
            name = "KURYE MESLEĞİ | LAS VENTURAS",
            premium = "diamond",
            rot = 223,
        },
        {
            pos = Vector3(1154.7939453125, 1222.7236328125, 10.8203125),
            name = "OTOBÜS MESLEĞİ | LAS VENTURAS",
            premium = "diamond",
            rot = 39,
        },
        {
            pos = Vector3(-888.6884765625, 2693.4453125, 42.370262145996),
            name = "DALGIÇ MESLEĞİ | VALLE OCULTADO",
            premium = "diamond",
            rot = 354,
        },
        {
            pos = Vector3(2577.9345703125, 2794.70703125, 10.8203125),
            name = "PETROL SEVKİYAT MESLEĞİ | K.A.C.C. MILITARY FUELS",
            premium = "diamond",
            rot = 183,
        },
        {
            pos = Vector3(383.0439453125, 874.0478515625, 20.40625),
            name = "TAŞ OCAĞI MESLEĞİ | HUNTER QUARRY",
            premium = "diamond",
            rot = 63,
        },
        {
            pos = Vector3(2121.013671875, -99.3828125, 5.6905121803284),
            name = "BALIKÇILIK MESLEĞİ | PALOMINO CREEK",
            premium = "diamond",
            rot = 260.99,
        },
    },

    fractionSpawns = {
        {
            pos = Vector3(-1618.408203125, 718.21484375, 14.303391456604),
            name = "SAN ANDREAS POLICE DEPARTMENT | SAN FIERRO",
            premium = false,
            rot = 90,
            fractionID = 1,
        },
        {
            pos = Vector3(2052.1259765625, -1373.1357421875, 23.977123260498),
            name = "FACTION KARARLIĞI | LOS SANTOS", -- BUNU ANLAMADIM
            premium = false,
            rot = 90,
            fractionID = 2,
        },
        {
            pos = Vector3(-2356.4873046875, -78.916015625, 35.3203125),
            name = "SAN ANDREAS FIRE DEPARTMENT | SAN FIERRO",
            premium = false,
            rot = 0,
            fractionID = 3,
        },
        {
            pos = Vector3(2482.4365234375, 1201.7236328125, 10.8203125),
            name = "SAN ANDREAS FIRE DEPARTMENT | LAS VENTURAS",
            premium = false,
            rot = 0,
            fractionID = 3,
        },
        {
            pos = Vector3(-2529.765625, -622.759765625, 132.74913024902),
            name = "HABER BİNASI | SAN FIERRO",
            premium = false,
            rot = 0,
            fractionID = 4,
        },
        {
            pos = Vector3(-53.2900390625, -297.70703125, 5.4296875),
            name = "ACİL YOL HİZMETLERİ | RED COUNTY",
            premium = false,
            rot = 214,
            fractionID = 5,
        },
    }
}

SpawnSelect = {}
SpawnSelect.__index = SpawnSelect

function SpawnSelect:create(...)
    local instance = {}
    setmetatable(instance, SpawnSelect)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function SpawnSelect:constructor(...)
    self.alpha = 1
    self.alphaState = "showed"
    self.alphaTick = getTickCount()

    self.cameraFOV = 70

    self.rot = 0
    self.tick = getTickCount()
    self.model = arg[1]
    if tonumber(self.model) ~= nil then
        setElementModel(localPlayer, self.model)
    else
        setElementModel(localPlayer, 0)
        setElementData(localPlayer, "customModel", self.model)
    end

    self.fonts = {}
    self.fonts.name = exports.TR_dx:getFont(24)
    self.fonts.access = exports.TR_dx:getFont(14)
    self.fonts.info = exports.TR_dx:getFont(10)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.buttonClick = function(...) self:buttonClick(...) end
    self.func.acceptSpawnSelect = function(...) self:acceptSpawnSelect(...) end

    self:buildSpawns(arg[2])
    self:setControls(false)

    self:checkCameraDistance()

    exports.TR_hud:blockPlayerSprint(true)
    bindKey("arrow_l", "down", self.func.buttonClick)
    bindKey("arrow_r", "down", self.func.buttonClick)
    bindKey("enter", "down", self.func.acceptSpawnSelect)

    setElementInterior(localPlayer, 0)
    setElementDimension(localPlayer, 0)

    setTimer(function()
        showCursor(false)
        setCursorAlpha(255)

        addEventHandler("onClientRender", root, self.func.render)
        exports.TR_dx:hideLoading()
    end, 3000, 1)
    return true
end

function SpawnSelect:checkCameraDistance()
    setCameraTarget(localPlayer)
    setTimer(function()
        local x, y, z, lx, ly, lz = getCameraMatrix()
        local px, py, pz = getElementPosition(localPlayer)

        self.playerCamera = {
            distance = getDistanceBetweenPoints2D(x, y, px, py),
            heightCamera = z - pz,
            fov = getCameraFieldOfView("player"),
        }
    end, 1000, 1)
end

function SpawnSelect:hide(hasTutorial)
    self.hasTutorial = hasTutorial
    exports.TR_dx:setResponseEnabled(false)

    exports.TR_hud:setHudVisible(true, 1000)
    exports.TR_chat:createChat(1000)
    exports.TR_hud:blockPlayerSprint(false)

    self.alphaState = "hidding"
    self.alphaTick = getTickCount()

    self.state = "moveToPlayer"
    self.tick = getTickCount()

    self.cameraMove = self.cameraNow

    local plrPos = Vector3(getElementPosition(localPlayer))
    local x, y, z = self:getPosition(localPlayer, Vector3(0, -self.playerCamera.distance, 0))

    self.cameraTarget = {
        pos = Vector3(x, y, plrPos.z + self.playerCamera.heightCamera),
        target = Vector3(getPedBonePosition(localPlayer, 5)),
    }
end

function SpawnSelect:getPosition(element, vec)
	local rot = Vector3(getElementRotation(element))
	local mat = Matrix(Vector3(getElementPosition(element)), rot)
	local newPos = mat:transformPosition(vec)
	return newPos.x, newPos.y, newPos.z, rot.z
end

function SpawnSelect:destroy()
    removeEventHandler("onClientRender", root, self.func.render)
    setCameraTarget(localPlayer)
    self:setControls(true)
    setElementFrozen(localPlayer, false)

    if self.hasTutorial then
        exports.TR_tutorial:createTutorial()
    end

    exports.TR_bw:startBW()
    if self.bwTime then exports.TR_bw:openBW(self.bwTime) end
    if self.prisonData then exports.TR_jail:openPrisonTimer(self.prisonData) end

    guiInfo = nil
    self = nil
end

function SpawnSelect:buildSpawns(...)
    self.avaliableSpawns = {}

    if arg[1].prisonData then
        self.prisonData = arg[1].prisonData
        local pos = arg[1].prisonData.position
        table.insert(self.avaliableSpawns, {
            pos = Vector3(tonumber(pos.pos[1]), tonumber(pos.pos[2]), tonumber(pos.pos[3])),
            name = "CELA WIĘZIENNA | STATE PRISON",
            int = pos.int,
            dim = pos.dim,
        })

        self:buildDefault()
        return
    end

    if arg[1].bwTime then
        if arg[1].bwTime > 0 then
            self.bwTime = arg[1].bwTime
            local lastPos = split(arg[1].lastPos, ",")
            local zone = getZoneName(lastPos[1], lastPos[2], lastPos[3], true)

            if tonumber(lastPos[4]) ~= 0 or tonumber(lastPos[5]) ~= 0 then
                local pos = exports.TR_interiors:getExitPosFromNearestInterior(tonumber(lastPos[1]), tonumber(lastPos[2]), tonumber(lastPos[3]), tonumber(lastPos[4]), tonumber(lastPos[5]))
                if pos then
                    lastPos = {pos[1], pos[2], pos[3], 0, 0}
                    zone = getZoneName(lastPos[1], lastPos[2], lastPos[3], true)
                end
            end

            table.insert(self.avaliableSpawns, {
                pos = Vector3(tonumber(lastPos[1]), tonumber(lastPos[2]), tonumber(lastPos[3])),
                name = "OSTATNIA POZYCJA | "..string.upper(zone),
                int = 0,
                dim = 0,
            })

            self:buildDefault()
            return
        end
    end

    for i, v in pairs(guiInfo.defaultSpawns) do
        table.insert(self.avaliableSpawns, {
            pos = v.pos,
            name = v.name,
            premium = v.premium,
            rot = v.rot,
        })
    end

    if arg[1] then
        if arg[1].houses then
            for i, v in pairs(arg[1].houses) do
                local housePos = split(v.pos, ",")
                local zone = getZoneName(housePos[1], housePos[2], housePos[3], true)

                if not v.ownedOrg then
                    table.insert(self.avaliableSpawns, {
                        pos = Vector3(housePos[1], housePos[2], housePos[3]),
                        name = "POSIADŁOŚĆ | "..string.upper(zone),
                        premium = false,
                    })
                else
                    table.insert(self.avaliableSpawns, {
                        pos = Vector3(housePos[1], housePos[2], housePos[3]),
                        name = "SIEDZIBA ORGANIZACJI | "..string.upper(zone),
                        premium = false,
                    })
                end
            end
        end
        if arg[1].rentHouses then
            for i, v in pairs(arg[1].rentHouses) do
                local housePos = split(v.pos, ",")
                local zone = getZoneName(housePos[1], housePos[2], housePos[3], true)

                if not v.ownedOrg then
                    table.insert(self.avaliableSpawns, {
                        pos = Vector3(housePos[1], housePos[2], housePos[3]),
                        name = "POSIADŁOŚĆ | "..string.upper(zone),
                        premium = false,
                    })
                else
                    table.insert(self.avaliableSpawns, {
                        pos = Vector3(housePos[1], housePos[2], housePos[3]),
                        name = "SIEDZIBA ORGANIZACJI | "..string.upper(zone),
                        premium = false,
                    })
                end
            end
        end

        if arg[1].fractionID then
            for i, v in pairs(guiInfo.fractionSpawns) do
                if v.fractionID == tonumber(arg[1].fractionID) then
                    table.insert(self.avaliableSpawns, {
                        pos = v.pos,
                        name = v.name,
                        premium = v.premium,
                        rot = v.rot,
                    })
                end
            end
        end

        if arg[1].lastPos then
            local lastPos = split(arg[1].lastPos, ",")
            local zone = getZoneName(lastPos[1], lastPos[2], lastPos[3], true)

            if tonumber(lastPos[4]) ~= 0 or tonumber(lastPos[5]) ~= 0 then
                local pos = exports.TR_interiors:getExitPosFromNearestInterior(tonumber(lastPos[1]), tonumber(lastPos[2]), tonumber(lastPos[3]), tonumber(lastPos[4]), tonumber(lastPos[5]))
                if pos then
                    lastPos = {pos[1], pos[2], pos[3], 0, 0}
                    zone = getZoneName(lastPos[1], lastPos[2], lastPos[3], true)
                end
            end

            table.insert(self.avaliableSpawns, {
                pos = Vector3(tonumber(lastPos[1]), tonumber(lastPos[2]), tonumber(lastPos[3])),
                name = "OSTATNIA POZYCJA | "..string.upper(zone),
                premium = "gold",
                int = 0,
                dim = 0,
            })
        end
    end

    for i, v in pairs(guiInfo.jobSpawns) do
        table.insert(self.avaliableSpawns, {
            pos = v.pos,
            name = v.name,
            premium = v.premium,
            rot = v.rot,
        })
    end

    self:buildDefault()
end

function SpawnSelect:buildDefault()
    self.tick = getTickCount()
    self.state = "rotate"

    self.selected = 1
    self.selectedData = self.avaliableSpawns[1]

    local camX, camY = self:getPointFromDistanceRotation(self.selectedData.pos.x, self.selectedData.pos.y, guiInfo.cameraDistance, -self.rot)
    self.cameraNow = {
        pos = Vector3(camX, camY, self.selectedData.pos.z + guiInfo.cameraHeight),
        target = self.selectedData.pos,
    }
    self.cameraTarget = self.cameraNow
    self:canSpawnInLocation()
    self:createPedOnSpawn()

    setTimer(setElementRotation, 500, 1, localPlayer, 0, 0, self.selectedData.rot or 0)
end

function SpawnSelect:animateAlpha()
    if self.alphaState == "hidding" then
        local progress = (getTickCount() - self.alphaTick)/1000
        self.alpha = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "Linear")

        if progress > 1 then
            self.alpha = 0
            self.alphaState = "hidden"
            return true
        end
    end
end

function SpawnSelect:animate()
    if self.state == "toAir" then
        local progress = (getTickCount() - self.tick)/self.moveToAirTime

        local x, y, z = interpolateBetween(self.cameraMove.pos, self.cameraMove.pos.x, self.cameraMove.pos.y, guiInfo.cameraMoveHeight, progress, "Linear")
        self.cameraNow.pos = Vector3(x, y, z)

        if progress >= 1 then
            self.state = "move"
            self.tick = getTickCount()
        end

    elseif self.state == "toGround" then
        local progress = (getTickCount() - self.tick)/self.moveToAirTime

        local x, y, z = interpolateBetween(self.cameraMove.pos, self.cameraTarget.pos, progress, "Linear")
        self.cameraNow.pos = Vector3(x, y, z)

        setElementRotation(localPlayer, 0, 0, self.selectedData.rot or 0)

        self:canRotateCamera()

        if progress >= 1 then
            self.state = "rotate"
            self.tick = getTickCount()
        end

    elseif self.state == "move" then
        local progress = (getTickCount() - self.tick)/self.cameraMoveTime

        local x, y, z = interpolateBetween(self.cameraMove.pos.x, self.cameraMove.pos.y, guiInfo.cameraMoveHeight, self.cameraTarget.pos.x, self.cameraTarget.pos.y, guiInfo.cameraMoveHeight, progress, "Linear")
        local tx, ty, tz = interpolateBetween(self.cameraMove.target, self.cameraTarget.target, progress, "Linear")
        self.cameraNow.pos = Vector3(x, y, z)
        self.cameraNow.target = Vector3(tx, ty, tz)

        if progress >= 1 then
            self.tick = getTickCount()
            self.state = "toGround"

            self:createPedOnSpawn()

            self.cameraMove.pos = self.cameraNow.pos
            self.moveToAirTime = (guiInfo.cameraMoveHeight - self.cameraTarget.pos.z)*5
        end

    elseif self.state == "rotate" then
        if self.blockRotate then return end

        self.rot = self.rot + 0.1
        if self.rot >= 360 then self.rot = self.rot - 360 end
        self.cameraNow.pos.x, self.cameraNow.pos.y = self:getPointFromDistanceRotation(self.selectedData.pos.x, self.selectedData.pos.y, guiInfo.cameraDistance, -self.rot)

    elseif self.state == "moveToPlayer" then
        local progress = (getTickCount() - self.tick)/2000

        local x, y, z = interpolateBetween(self.cameraMove.pos, self.cameraTarget.pos, progress, "Linear")
        local tx, ty, tz = interpolateBetween(self.cameraMove.target, self.cameraTarget.target, progress, "Linear")
        self.cameraNow.pos = Vector3(x, y, z)
        self.cameraNow.target = Vector3(tx, ty, tz)

        self.cameraFOV = interpolateBetween(70, 0, 0, self.playerCamera.fov, 0, 0, progress * 2, "Linear")

        if progress >= 0.5 then
            self:destroy()
            return true
        end
    end
end

function SpawnSelect:render()
    if self:animate() then return end
    self:animateAlpha()

    if self.selectedData then
        setElementInterior(localPlayer, self.selectedData.int or 0)
        setElementDimension(localPlayer, self.selectedData.dim or 0)
    end

    setCameraMatrix(self.cameraNow.pos, self.cameraNow.target, 0, self.cameraFOV)

    dxDrawRectangle(0, 0, sx, sy, tocolor(17, 17, 17, 120 * self.alpha))

    dxDrawText(self.selectedData.name, guiInfo.text.x, guiInfo.text.y, guiInfo.text.w, guiInfo.text.h, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.name, "center", "top")
    dxDrawText(self.selectedData.canSpawn, guiInfo.text.x, guiInfo.text.y + 40/zoom, guiInfo.text.w, guiInfo.text.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.access, "center", "top", false, false, false, true)

    dxDrawText("Aby zmienić miejsce użyj #b89935STRZAŁEK\n#aaaaaaAby zaakceptować naciśnij #b89935ENTER", guiInfo.text.x, guiInfo.text.y + 80/zoom, guiInfo.text.w, guiInfo.text.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "top", false, false, false, true)
end




function SpawnSelect:buttonClick(...)
    if arg[1] == "arrow_l" then
        if self.selected <= 1 then return end
        self.selected = self.selected - 1

    elseif arg[1] == "arrow_r" then
        if self.selected >= #self.avaliableSpawns then return end
        self.selected = self.selected + 1
    end

    self:selectSpawn(self.selected)
end

function SpawnSelect:selectSpawn(id)
    self.selected = id
    self.selectedData = self.avaliableSpawns[self.selected]

    self:moveCameraToSpawn()
    self:canSpawnInLocation()
end

function SpawnSelect:createPedOnSpawn()
    setElementPosition(localPlayer, self.selectedData.pos)

    setElementInterior(localPlayer, self.selectedData.int or 0)
    setElementDimension(localPlayer, self.selectedData.dim or 0)
end

function SpawnSelect:moveCameraToSpawn()
    local camX, camY = self:getPointFromDistanceRotation(self.selectedData.pos.x, self.selectedData.pos.y, guiInfo.cameraDistance, -self.rot)
    self.cameraTarget = {
        pos = Vector3(camX, camY, self.selectedData.pos.z + guiInfo.cameraHeight),
        target = Vector3(self.selectedData.pos.x, self.selectedData.pos.y, self.selectedData.pos.z),
    }

    if self.state == "toAir" then return end
    self.cameraMove = {
        pos = self.cameraNow.pos,
        target = self.cameraNow.target
    }
    self.cameraMoveTime = getDistanceBetweenPoints2D(self.cameraNow.pos.x, self.cameraNow.pos.y, self.cameraTarget.pos.x, self.cameraTarget.pos.y)

    if self.state == "rotate" then
        self.state = "toAir"
        self.tick = getTickCount()
        self.moveToAirTime = (guiInfo.cameraMoveHeight - self.cameraNow.pos.z)*5

    elseif self.state == "move" then
        self.tick = getTickCount()
    else
        self.state = "toAir"
        self.tick = getTickCount()
        self.moveToAirTime = (guiInfo.cameraMoveHeight - self.cameraNow.pos.z)*5
    end
end

function SpawnSelect:canRotateCamera()
    self.blockRotate = false
    local collCount = 0
    local withoutHit = {}

    for i = 0, 72 do
        local rot = i * 5
        local camX, camY = self:getPointFromDistanceRotation(self.selectedData.pos.x, self.selectedData.pos.y, guiInfo.cameraDistance- 2, rot)
        local clear = isLineOfSightClear(self.cameraTarget.target.x, self.cameraTarget.target.y, self.selectedData.pos.z + guiInfo.cameraHeight, camX, camY, self.selectedData.pos.z + guiInfo.cameraHeight, true, false, false, false, false, false, false, localPlayer)
        if not clear then
            collCount = collCount + 1

            if collCount >= 10 then
                self.blockRotate = true
            end
        else
            collCount = 0
            table.insert(withoutHit, rot)
        end
    end

    if not self.blockRotate then return end

    local groups = {{}}
    for i, v in pairs(withoutHit) do
        if not withoutHit[i+1] then
            table.insert(groups, {})
        end
        table.insert(groups[#groups], i)
    end

    local largestGroup, size = false, 0
    for i, v in pairs(groups) do
        if #v > size then
            largestGroup = i
            size = #v
        end
    end

    if not largestGroup then
        self.rot = 0
    else
        self.rot = groups[largestGroup][math.ceil(#groups[largestGroup])]
    end

    self.cameraTarget.pos.x, self.cameraTarget.pos.y = self:getPointFromDistanceRotation(self.selectedData.pos.x, self.selectedData.pos.y, guiInfo.cameraDistance, 360-self.rot)
end

function SpawnSelect:canSpawnInLocation()
    if not self.selectedData.premium then
        self.selectedData.canSpawn = "(TÜM OYUNCULAR İÇİN)"

    elseif self.selectedData.premium == "gold" then
        self.selectedData.canSpawn = "#d6a306(SADECE GOLD VIPLER İÇİN)"

    elseif self.selectedData.premium == "diamond" then
        self.selectedData.canSpawn = "#31caff(SADECE DIAMOND VIPLER İÇİN)"
    end
end

function SpawnSelect:acceptSpawnSelect()
    if self.state ~= "rotate" then
        exports.TR_noti:create("Seçiminizi onaylamak için kameranın seçilen yere gelmesini beklemeniz gerekmektedir.", "error")
        return
    end

    if not self:canRespawnInPlace() then return end
    if not self.selectedData.pos then return end

    local spawnPos = string.format("%.2f,%.2f,%.2f,%d,%d", self.selectedData.pos.x, self.selectedData.pos.y, self.selectedData.pos.z, self.selectedData.int or 0, self.selectedData.dim or 0)
    
    triggerServerEvent("spawnPlayerCharacter", resourceRoot, spawnPos, self.selectedData.rot)

    exports.TR_dx:setResponseEnabled(true)

    unbindKey("arrow_l", "down", self.func.buttonClick)
    unbindKey("arrow_r", "down", self.func.buttonClick)
    unbindKey("enter", "down", self.func.acceptSpawnSelect)
end

function SpawnSelect:canRespawnInPlace()
    if not self.selectedData.premium then return true end

    local plrData = getElementData(localPlayer, "characterData")

    if self.selectedData.premium == "gold" then
        if plrData.premium == "gold" or plrData.premium == "diamond" then return true end
        exports.TR_noti:create("Burada spawn olabilmek için bir Gold veya Diamond hesabınızın olması gerekmektedir.", "error")

    elseif self.selectedData.premium == "diamond" then
        if plrData.premium == "diamond" then return true end
        exports.TR_noti:create("Burada spawn olabilmek için bir Diamond hesabınızın olması gerekmektedir.", "error")
    end

    return false
end

function SpawnSelect:getPointFromDistanceRotation(x, y, dist, angle)
	local a = math.rad(90 - angle)
	local dx = math.cos(a) * dist
	local dy = math.sin(a) * dist
	return x + dx, y + dy
end

function SpawnSelect:findRotation(x1,y1,x2,y2)
	local t = -math.deg(math.atan2(x2-x1,y2-y1))
	if t < 0 then t = t + 360 end
	return t
end

function SpawnSelect:setControls(state)
    toggleControl("forwards", state)
    toggleControl("backwards", state)
    toggleControl("left", state)
    toggleControl("right", state)
    toggleControl("jump", state)
    toggleControl("action", state)
    toggleControl("sprint", state)
    toggleControl("crouch", state)
    toggleControl("walk", state)
    toggleControl("enter_exit", state)
end


function createSpawnSelect(...)
    if guiInfo.system then return end

    showCursor(true)
    setCursorAlpha(0)

    exports.TR_dx:showLoading(9999999, "Spawn ekranı yükleniyor")

    exports.TR_hud:createGUI()
    exports.TR_hud:setHudVisible(false)

    guiInfo.system = SpawnSelect:create(...)
end
addEvent("createSpawnSelect", true)
addEventHandler("createSpawnSelect", root, createSpawnSelect)


function loadSpawnSelectCharacter(...)
    if not guiInfo.system then return end

    guiInfo.system:hide(...)

    setElementData(localPlayer, "OX", true)
    setTimer(function()
        setElementData(localPlayer, "OX", nil)
    end, 10000, 1)
end
addEvent("loadSpawnSelectCharacter", true)
addEventHandler("loadSpawnSelectCharacter", root, loadSpawnSelectCharacter)


function isSpawnSelectEnabled()
    return guiInfo and guiInfo.system and true or false
end