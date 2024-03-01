local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local settings = {}

CustomModels = {}
CustomModels.__index = CustomModels

function CustomModels:create()
    local instance = {}
    setmetatable(instance, CustomModels)
    if instance:constructor() then
        return instance
    end
    return false
end

function CustomModels:render()
    dxDrawText(inspect(self.models), 500, 100)
end

function CustomModels:constructor()
    self.models = {}
    self.added = {}

    self.func = {}
    self.func.render = function() self:render() end
    self.func.unloadModels = function() self:unloadModels() end
    self.func.onElementDestroy = function(...) self:onElementDestroy(source, ...) end
    self.func.onElementStreamIn = function(...) self:onElementStreamIn(source, ...) end
    self.func.onElementStreamOut = function(...) self:onElementStreamOut(source, ...) end
    self.func.onElementDataChange = function(...) self:onElementDataChange(source, ...) end
    self.func.onElementModelChange = function(...) self:onElementModelChange(source) end

    -- addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientResourceStop", resourceRoot, self.func.unloadModels)
    addEventHandler("onClientElementDestroy", root, self.func.onElementDestroy)
    addEventHandler("onClientElementStreamIn", root, self.func.onElementStreamIn)
    addEventHandler("onClientElementStreamOut", root, self.func.onElementStreamOut)
    addEventHandler("onClientElementDataChange", root, self.func.onElementDataChange)
    addEventHandler("onClientElementModelChange", root, self.func.onElementModelChange)

    self:getValidModels()
    self:streamElements()
    return true
end

function CustomModels:streamElements()
    for i, v in pairs(getElementsByType("player", root, true)) do
        self:onElementStreamIn(v)
    end
    for i, v in pairs(getElementsByType("vehicle", root, true)) do
        self:onElementStreamIn(v)
    end
    for i, v in pairs(getElementsByType("object", root, true)) do
        self:onElementStreamIn(v)
    end
    for i, v in pairs(getElementsByType("ped", root, true)) do
        self:onElementStreamIn(v)
    end
end

function CustomModels:onElementModelChange(source)
    if not self.added[source] then return end
    if not self.models[self.added[source]] then return end

    if getElementType(source) == "player" or getElementType(source) == "ped" then
        local data = getElementData(source, "characterData")
        if tonumber(data.skin) == nil and getElementModel(source) == 0 then
            setElementModel(source, self.models[self.added[source]].modelID)
        end
    end
end

function CustomModels:onElementDataChange(source, key)
    if key ~= "customModel" then return end
    self:onElementStreamOut(source)
    self:onElementStreamIn(source)
end

function CustomModels:onElementDestroy(source)
    if not self.added[source] then return end
    self:onElementStreamOut(source)
end

function CustomModels:onElementStreamIn(source, ...)
    if self.added[source] then return end
    local model, elementType = self:getModelToLoad(source)
    if not self:isModelValid(model, elementType) then return end

    if not self.models[model] then
        self:alocateModel(model, elementType, self:getElementModel(source))
    end

    if self.added[source] then return end
    self.added[source] = model

    table.insert(self.models[model].elements, source)
    setElementData(source, "oryginalModel", self:getElementModel(source))
    setElementModel(source, self.models[model].modelID)
end

function CustomModels:getElementModel(object)
    return getElementData(object, "oryginalModel") or getElementModel(object)
end

function CustomModels:onElementStreamOut(source, ...)
    local model = self.added[source]
    if not model or not self.models[model] then return end

    for i, v in pairs(self.models[model].elements) do
        if v == source then
            table.remove(self.models[model].elements, i)
            break
        end
    end
    self.added[source] = nil
    if #self.models[model].elements < 1 then
        self:delocateModel(model)
    end
end

function CustomModels:alocateModel(model, elementType, objectModel)
    self.models[model] = {
        modelID = engineRequestModel(elementType, objectModel),
        elements = {},
    }
    outputDebugString(string.format("[TR_customModels] Model %s (%s) ID %d olarak tahsis edildi.", model, elementType, self.models[model].modelID), 0, 0, 255, 0)

    self:loadModel(model, elementType, self.models[model].modelID)
end

function CustomModels:getValidModels()
    self.validModels = {}

    for i, v in pairs(Models) do
        if not self.validModels[v.type] then self.validModels[v.type] = {} end
        self.validModels[v.type][tostring(v.file)] = true
    end
end

function CustomModels:isModelValid(model, elementType)
    local model = tostring(model)
    if not self.validModels[elementType] then return false end
    if not self.validModels[elementType][model] then return false end
    return true
end

function CustomModels:loadModel(model, elementType, modelID)
    local dir = string.format("models/%s/%s", elementType, tostring(model))
    if fileExists(dir..".idff") then
        local fileString = self:uncompileFile(dir, "idff")
        local txd = engineLoadTXD(fileString)
        if txd then
            engineImportTXD(txd, modelID)
        else
            outputDebugString(string.format("[TR_customModels] Model %s için TXD yüklenemedi!", model), 0, 255, 0, 0)
        end
    end
    if fileExists(dir..".icol") then
        local fileString = self:uncompileFile(dir, "icol")
        local dff = engineLoadDFF(fileString)
        if dff then
            engineReplaceModel(dff, modelID)
        else
            outputDebugString(string.format("[TR_customModels] Model %s için DFF yüklenemedi!", model), 0, 255, 0, 0)
        end
    end
    if fileExists(dir..".itxd") then
        local fileString = self:uncompileFile(dir, "itxd")
        local col = engineLoadCOL(fileString)
        if col then
            engineReplaceCOL(col, modelID)
        else
            outputDebugString(string.format("[TR_customModels] Model %s için COL yüklenemedi!", model), 0, 255, 0, 0)
        end
    end
end

function CustomModels:delocateModel(model)
    engineFreeModel(self.models[model].modelID)
    self.models[model] = nil
end

function CustomModels:getModelToLoad(element)
    local elementType = getElementType(element)
    if elementType == "player" or elementType == "ped" then
        return getElementData(element, "customModel") or false, "ped"

    elseif elementType == "vehicle" then
        return getElementData(element, "customModel") or false, "vehicle"

    elseif elementType == "object" then
        return getElementData(element, "customModel") or false, "object"
    end
    return false, false
end

function CustomModels:unloadModels()
    for i, v in pairs(self.models) do
        engineFreeModel(v.modelID)
    end
end

function CustomModels:uncompileFile(dir, format)
    local file = fileOpen(dir.."."..format)
    local fileString = fileRead(file, fileGetSize(file))
    local uncompiledString = self:teaDecodeBinary(fileString, EncriptionKey)
    fileClose(file)
    return uncompiledString
end

function CustomModels:teaDecodeBinary(data, key)
    return decodeString("tea", data, {key = key})
end


function loadCustomModels()
    CustomModels:create()
end
loadCustomModels()