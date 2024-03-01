function codeFiles(plr)
    if not isObjectInACLGroup("user."..getAccountName(getPlayerAccount(plr)), aclGetGroup("Admin")) then return end

    for _, v in ipairs(Models) do
        local dir = string.format("models/%s/%s", v.type, v.file)

        if fileExists(dir..".txd") then compileFile(dir, "txd", "idff", v.file) end
        if fileExists(dir..".dff") then compileFile(dir, "dff", "icol", v.file) end
        if fileExists(dir..".col") then compileFile(dir, "col", "itxd", v.file) end
    end

    exports.TR_starter:reloadResources({"TR_customModels"})
end
addCommandHandler("codecustom", codeFiles)

function compileFile(dir, format, newFormat, fileName)
    local startTime = getTickCount()

    if fileExists(dir.."."..newFormat) then fileDelete(dir.."."..newFormat) end

    local openedFile = fileOpen(dir.."."..format)
    local openedString = fileRead(openedFile, fileGetSize(openedFile))
    local codedString = teaEncodeBinary(openedString, EncriptionKey)
    local file = fileCreate(dir.."."..newFormat)
    fileWrite(file, codedString)
    fileClose(file)
    fileClose(openedFile)

    print(string.format("[Model Kodlama] %s.%s modelini %s.%s olarak %dms sürede kodluyor", fileName, format, fileName, newFormat, getTickCount() - startTime))
end

function teaEncodeBinary(data, key)
    return encodeString("tea", data, {key = key})
end





-- local veh = createVehicle(536, -2437.35986, -615.90259, 132.55507)
-- setElementData(veh, "customModel", "blade")