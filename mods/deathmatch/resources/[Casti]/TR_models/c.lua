-- local testPos = Vector3(2007.7369384766, -2490.4301757813, 13.546875)
-- local testPosVeh = Vector3(2007.3018798828, -2502.0241699219, 13.546875)
-- local testCount = 0
-- local testCountVeh = 0

local settings = {
    loadAtOnce = 20,
    loadTimeBreak = 100,
}

ModelLoader = {}
ModelLoader.__index = ModelLoader

function ModelLoader:create(...)
    local instance = {}
    setmetatable(instance, ModelLoader)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function ModelLoader:constructor(...)
    self.count = 0
    self.countAll = 0

    self.pos = arg[1]
    self.tutorial = arg[2]

    self.func = {}
    self.func.loadModels = function() self:loadModels() end
    self.func.unloadModels = function() self:unloadModels() end
    self.func.loadCoroutine = function() self:loadCoroutine() end
    self.func.resumeCoroutine = function() self:resumeCoroutine() end

    addEventHandler("onClientResourceStop", getResourceRootElement(getThisResource()), self.func.unloadModels)

    self:loadModels()
    return true
end

function ModelLoader:loadModels()
    exports.TR_dx:showLoading(9999999, "Modeller yükleniyor")

    setCameraMatrix(30000, 30000, 0, 30000, 30000, 0)
    setElementFrozen(localPlayer, true)
    setOcclusionsEnabled(false)

    self.coroutine = coroutine.create(self.func.loadCoroutine)
    coroutine.resume(self.coroutine)
end

function ModelLoader:loadCoroutine()
    for _, v in ipairs(replaceList) do
        if self.count >= settings.loadAtOnce then
            setTimer(self.func.resumeCoroutine, settings.loadTimeBreak, 1)
            coroutine.yield()
        end

        if v.type == "wheels" then
            local dir = string.format("models/wheels/wheel.txd", v.type)
            if fileExists("models/wheels/wheel.idff") then
                local fileString = self:uncompileFile("models/wheels/wheel", "idff")
                local txd = engineLoadTXD(fileString)
                if txd then
                    engineImportTXD(txd, v.model)
                else
                    outputDebugString(string.format("[TR_models] Failed to load TXD for model %s!", v.file), 0, 255, 0, 0)
                end
            end
        end

        local dir = string.format("models/%s/%s", v.type, v.file)
        if fileExists(dir..".idff") then
            local fileString = self:uncompileFile(dir, "idff")
            local txd = engineLoadTXD(fileString)
            if txd then
                engineImportTXD(txd, v.model)
            else
                outputDebugString(string.format("[TR_models] Failed to load TXD for model %s!", v.file), 0, 255, 0, 0)
            end
        end
        if fileExists(dir..".icol") then
            local fileString = self:uncompileFile(dir, "icol")
            local dff = engineLoadDFF(fileString)
            if dff then
                engineReplaceModel(dff, v.model, v.alpha)
            else
                outputDebugString(string.format("[TR_models] Failed to load DFF for model %s!", v.file), 0, 255, 0, 0)
            end
        end
        if fileExists(dir..".itxd") then
            local fileString = self:uncompileFile(dir, "itxd")
            local col = engineLoadCOL(fileString)
            if col then
                engineReplaceCOL(col, v.model)
            else
                outputDebugString(string.format("[TR_models] Failed to load COL for model %s!", v.file), 0, 255, 0, 0)
            end
        end

        if v.create then
            for _, c in ipairs(v.create) do
                local obj = createObject(c[1], c[2], c[3], c[4], c[5] or 0, c[6] or 0, c[7] or 0)
                if v.doubleside then setElementDoubleSided(obj, true) end
                if v.lod then
                    local lod = createObject(v.model, c[2], c[3], c[4], c[5] or 0, c[6] or 0, c[7] or 0, true)
                    setLowLODElement(obj, lod)
                end
            end
        end

        if v.remove then
            for _, r in ipairs(v.remove) do
                removeWorldModel(r[1], 2, r[2], r[3], r[4], 0)
            end
        end

        engineSetModelLODDistance(v.model, 3000)


        -- if v.type == "skins" then
        --     local ped = createPed(v.model, testPos.x - testCount * 2, testPos.y, testPos.z, 355)
        --     testCount = testCount + 1

        -- elseif v.type == "vehicles" then
        --     local veh = createVehicle(v.model, testPosVeh.x - testCountVeh * 5, testPosVeh.y, testPosVeh.z, 0, 0, 0)
        --     testCountVeh = testCountVeh + 1
        -- end

        self.count = self.count + 1
        self.countAll = self.countAll + 1
        -- break
    end

    if getElementData(localPlayer, "tempUID") then
        if self.tutorial then
            exports.TR_tutorial:createTutorial()
        else
            triggerServerEvent("openPlayerSpawnSelect", resourceRoot)
        end

    else
        if self.pos then setElementPosition(localPlayer, self.pos.x, self.pos.y, self.pos.z + 0.5) end

        exports.TR_dx:hideLoading()
        exports.TR_bw:startBW()
        setElementFrozen(localPlayer, false)
        setCameraTarget(localPlayer)
    end
end

function ModelLoader:resumeCoroutine()
    self.count = 0
    coroutine.resume(self.coroutine)
end

function ModelLoader:unloadModels()
    for _, v in ipairs(replaceList) do
        if v.remove then
            for _, r in ipairs(v.remove) do
                restoreWorldModel(r[1], 2, r[2], r[3], r[4])
            end
        end
    end
end

function ModelLoader:uncompileFile(dir, format)
    local file = fileOpen(dir.."."..format)
    local fileString = fileRead(file, fileGetSize(file))
    local uncompiledString = self:teaDecodeBinary(fileString, EncriptionKey)
    fileClose(file)
    return uncompiledString
end

function ModelLoader:teaDecodeBinary(data, key)
	local decoded = decodeString("tea", data, {key = key}) 
    return decoded
end

function loadModels(pos, tutorial)
    if settings.loaded then return end

    ModelLoader:create(pos, tutorial)
    settings.loaded = true
end

function starter()
    if getElementData(localPlayer, "characterUID") then
        loadModels(Vector3(getElementPosition(localPlayer)))
    end

    setWorldSpecialPropertyEnabled("extraairresistance", false)
end
addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), starter)





-- function renderer()
--     for i, v in pairs(getElementsByType("ped")) do
--         local pos = Vector3(getElementPosition(v))
--         local x, y = getScreenFromWorldPosition(pos)

--         if x and y then
--             dxDrawText(getElementModel(v), x, y)
--         end
--     end
-- end
-- addEventHandler("onClientRender", root, renderer)