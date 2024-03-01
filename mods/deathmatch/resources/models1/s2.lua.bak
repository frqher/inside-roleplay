function codeFiles(plr)
    if not isObjectInACLGroup("user."..getAccountName(getPlayerAccount(plr)), aclGetGroup("Admin")) then return end

    table.insert(replaceList, {
        file = "wheel",
        type = "wheels",
        model = 455,
    })
    for _, v in ipairs(replaceList) do
        local dir = string.format("models/%s/%s", v.type, v.file)

        if fileExists(dir..".txd") then compileFile(dir, "txd", "idff", v.file) end
        if fileExists(dir..".dff") then compileFile(dir, "dff", "icol", v.file) end
        if fileExists(dir..".col") then compileFile(dir, "col", "itxd", v.file) end
    end

    exports.TR_starter:reloadResources({"tr_models"})
end
addCommandHandler("code", codeFiles)

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

    print(string.format("[Coding Model] Coding model name %s.%s into %s.%s in time %dms", fileName, format, fileName, newFormat, getTickCount() - startTime))
end

function teaEncodeBinary(data, key)
    return encodeString("tea", data, {key = key})
end

function decodeFiles(plr)
    if not isObjectInACLGroup("user."..getAccountName(getPlayerAccount(plr)), aclGetGroup("Admin")) then return end

    table.insert(replaceList, {
        file = "wheel",
        type = "wheels",
        model = 455,
    })
    for _, v in ipairs(replaceList) do
        local dir = string.format("models/%s/%s", v.type, v.file)

        if fileExists(dir..".idff") then decompileFile(dir, "txd", "idff", v.file) end
        if fileExists(dir..".icol") then decompileFile(dir, "dff", "icol", v.file) end
        if fileExists(dir..".itxd") then decompileFile(dir, "col", "itxd", v.file) end
    end

    exports.TR_starter:reloadResources({"tr_models"})
end
addCommandHandler("decode", decodeFiles)

function decompileFile(dir, newFormat, format, fileName)
    local startTime = getTickCount()

    if fileExists(dir.."."..newFormat) then fileDelete(dir.."."..newFormat) end

    local openedFile = fileOpen(dir.."."..format)
    local openedString = fileRead(openedFile, fileGetSize(openedFile))
    local codedString = teaDecodeBinary(openedString, EncriptionKey)
    local file = fileCreate(dir.."."..newFormat)
    fileWrite(file, codedString)
    fileClose(file)
    fileClose(openedFile)

    print(string.format("[Coding Model] Decompiling model name %s.%s into %s.%s in time %dms", fileName, format, fileName, newFormat, getTickCount() - startTime))
end

function teaDecodeBinary(data, key)
    return decodeString("tea", data, {key = key})
end