function getImage(type, img)
    local path = string.format("files/images/%s/%s.png", type, tostring(img))
    if fileExists(path) then return ":TR_images/"..path end
    return false
end