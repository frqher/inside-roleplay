local settings = {
    stopAt = 1000,

    noCompile = {
        "TR_devTools", "TR_mysql", "TR_discord", "TR_orgLogos"
    },
}

function compile(plr)
    -- if not isObjectInACLGroup("user."..getAccountName(getPlayerAccount(plr)), aclGetGroup("Admin")) then return end

    local count = 0
    for i, v in pairs(getResources()) do
        local resName = getResourceName(v)
        if string.find(resName, "TR_") or resName == "bone_attach" then
            if not string.find(resName, "TR_M_") then
                if count >= settings.stopAt then return end
                compileResource(v, resName, getFolderForResource(resName))
                count = count + 1
            end
        end
    end
end
addCommandHandler("compile", compile)

function getFolderForResource(resName)
    if string.find(resName, "TR_M_") then return "[Mapy]/" end
    return ""
end

function compileResource(res, resName, folder)
    if not folder then return end
    if settings.noCompile[resName] then return end
    local xml = xmlLoadFile(string.format(":%s/meta.xml", resName))
    if not xml then return end

    local resourceDirectory = string.format(":%s/", resName)
    local newResourceDirectory = string.format("compiled/%s%s/", folder, resName)

    local nodes = xmlNodeGetChildren(xml)
    for i, v in pairs(nodes) do
        local nodeName = xmlNodeGetName(v)

        if nodeName == "script" then
            local fileDir = xmlNodeGetAttribute(v, "src")
            local type = xmlNodeGetAttribute(v, "type")

            if type == "client" or type == "shared" then
                local fileName = split(fileDir, "/")
                compileFile(fileName[#fileName], string.format("%s%s", resourceDirectory, fileDir), string.format("%s%s", newResourceDirectory, fileDir), resName)
            else
                fileCopy(string.format("%s/%s", resourceDirectory, fileDir), string.format("%s/%s", newResourceDirectory, fileDir), true)
            end

        elseif nodeName == "file" then
            local fileDir = xmlNodeGetAttribute(v, "src")
            local fileName = split(fileDir, "/")
            fileCopy(string.format("%s/%s", resourceDirectory, fileDir), string.format("%s/%s", newResourceDirectory, fileDir), true)

            outputDebugString(string.format("[Compiler] Dosya kopyalanıyor %s from %s", fileName[#fileName], resName), 0, 0, 140, 255)

        elseif nodeName == "map" then
            local fileDir = xmlNodeGetAttribute(v, "src")
            local fileName = split(fileDir, "/")
            fileCopy(string.format("%s/%s", resourceDirectory, fileDir), string.format("%s/%s", newResourceDirectory, fileDir), true)

            outputDebugString(string.format("[Compiler] Dosya kopyalanıyor %s from %s", fileName[#fileName], resName), 0, 0, 140, 255)
        end
    end
    xmlUnloadFile(xml)

    fileCopy(string.format("%smeta.xml", resourceDirectory), string.format("%smeta.xml", newResourceDirectory), true)
    outputDebugString(string.format("[Compiler] Dosya kopyalanıyor meta.xml from %s", resName), 0, 0, 140, 255)

    changeMetaLuac(string.format("%smeta.xml", newResourceDirectory), resName)
end

function changeMetaLuac(dir, resName)
    local xml = xmlLoadFile(dir)
    if not xml then outputDebugString(string.format("[Compiler] Cant open meta.xml file from %s", resName), 1) return end

    local nodes = xmlNodeGetChildren(xml)
    for i, v in pairs(nodes) do
        local nodeName = xmlNodeGetName(v)
        if nodeName == "script" then
            local type = xmlNodeGetAttribute(v, "type")

            if type == "client" or type == "shared" then
                local atribute = xmlNodeGetAttribute(v, "src")
                xmlNodeSetAttribute(v, "src", atribute.."c")
            end
        end
    end

    outputDebugString(string.format("[Derleyici] meta.xml dosyası yeniden oluşturuldu %s", resName), 0, 250, 220, 20)
    xmlSaveFile(xml)
    xmlUnloadFile(xml)
end

function compileFile(fileName, fileDir, fileNewDir, resName)
    local file = fileOpen(fileDir)

    fetchRemote("http://luac.mtasa.com/?compile=1&debug=0&obfuscate=3", function(data)
        if fileExists(fileNewDir.."c") then fileDelete(fileNewDir.."c") end
        local newscriptFile = fileCreate(fileNewDir.."c")
        if newscriptFile then
            fileWrite(newscriptFile, data)
            fileFlush(newscriptFile)
            fileClose(newscriptFile)

            outputDebugString(string.format("[Derleyici] Derlenen dosya %s from %s", fileName, resName))
        end
    end, fileRead(file, fileGetSize(file)), true)

    fileClose(file)
end