function createList()
    local file = fileCreate("metaFiles.txt")
    local text = ""
    for i = 400, 620 do
        local path = string.format("files/images/vehicles/%d.png", i)
        if fileExists(path) then
            text = text .. "<file src=\"" .. path .. "\" type=\"client\"></file>\n"
        end
    end

    fileWrite(file, text)
    fileClose(file)
end
-- createList()