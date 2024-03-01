function getLogo(orgID)
    if not orgID then return false end
    if fileExists(string.format("files/logos/%d.png", orgID)) then
        return string.format(":TR_orgLogos/files/logos/%d.png", orgID)
    end
    return false
end