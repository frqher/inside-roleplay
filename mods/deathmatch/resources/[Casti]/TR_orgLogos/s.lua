local extension = ".lua"

function loadNewLogosAdmin()
    if not exports.TR_admin:isPlayerOnDuty(source) then return end
    if not exports.TR_admin:hasPlayerPermission(source, "orgLogos") then return end
    local newLogosRequest = exports.TR_mysql:querry("SELECT ID, name, type, img, logoRequest FROM tr_organizations WHERE logoRequest IS NOT NULL")
    if newLogosRequest and newLogosRequest[1] then
        triggerClientEvent(source, "createAdminOrgLogos", resourceRoot, newLogosRequest)

        for i, v in pairs(newLogosRequest) do
            getNewOrganizationImage(source, v.name, v.logoRequest)
        end
        return
    end
    exports.TR_noti:create(source, "Faction'un logosunun değiştirildiğine dair herhangi bir rapor bulunmamaktadır.", "error")
end
addEvent("loadNewLogosAdmin", true)
addEventHandler("loadNewLogosAdmin", root, loadNewLogosAdmin)
exports.TR_chat:addCommand("orglogos", "loadNewLogosAdmin")

function declineOrganizationNewLogo(orgID)
    exports.TR_mysql:querry("UPDATE tr_organizations SET logoRequest = NULL WHERE ID = ? LIMIT 1", orgID)
    exports.TR_mysql:querry("INSERT INTO tr_computerLogs (text, name, owner, type) VALUES (?, ?, ?, ?)", "Faction logosunu değiştirme talebini reddetti.", "Administrator "..getPlayerName(client), orgID, "org")

    triggerClientEvent(client, "responseAdminOrgLogos", resourceRoot, "declined")
end
addEvent("declineOrganizationNewLogo", true)
addEventHandler("declineOrganizationNewLogo", root, declineOrganizationNewLogo)

function acceptOrganizationNewLogo(orgID, url)
    fetchRemote(url, saveNewOrganizationLogo, "", false, client, orgID, client)
end
addEvent("acceptOrganizationNewLogo", true)
addEventHandler("acceptOrganizationNewLogo", root, acceptOrganizationNewLogo)

function saveNewOrganizationLogo(data, error, plr, orgID, client)
    if fileExists(string.format("files/logos/%d.png", orgID)) then fileDelete(string.format("files/logos/%d.png", orgID)) end
    local file = fileCreate(string.format("files/logos/%d.png", orgID))
    if file then
        fileWrite(file, data)
        fileClose(file)

        exports.TR_mysql:querry("UPDATE tr_organizations SET img = logoRequest, logoRequest = NULL WHERE ID = ? LIMIT 1", orgID)
        exports.TR_mysql:querry("INSERT INTO tr_computerLogs (text, name, owner, type) VALUES (?, ?, ?, ?)", "Faction'un logo tipinin değiştirilmesi talebini kabul etti..", "Administrator "..getPlayerName(client), orgID, "org")

        triggerClientEvent(plr, "responseAdminOrgLogos", resourceRoot, "saved")
    else
        triggerClientEvent(plr, "responseAdminOrgLogos", resourceRoot, "saveError")
    end
end

function getNewOrganizationImage(plr, name, url)
    fetchRemote(url, sendImage, "", false, plr, name, url)
end

function sendImage(data, error, plr, name, url)
    if error == 0 then
        triggerLatentClientEvent(plr, "loadOrganizationAdminImage", resourceRoot, name, true, data, url)
    else
        triggerLatentClientEvent(plr, "loadOrganizationAdminImage", resourceRoot, name, false)
    end
end


function reloadLogos()
    local xml = xmlCreateFile("meta.xml", "meta")
    if xml then
        local info = xmlCreateChild(xml, "info")
        xmlNodeSetAttribute(info, "author", "Xantris")
        xmlNodeSetAttribute(info, "type", "script")
        xmlNodeSetAttribute(info, "name", "TR_orgLogos")

        -- Scripts
        local admin = xmlCreateChild(xml, "script")
        xmlNodeSetAttribute(admin, "src", "admin"..extension)
        xmlNodeSetAttribute(admin, "type", "client")

        local c = xmlCreateChild(xml, "script")
        xmlNodeSetAttribute(c, "src", "c"..extension)
        xmlNodeSetAttribute(c, "type", "client")

        local s = xmlCreateChild(xml, "script")
        xmlNodeSetAttribute(s, "src", "s.lua")
        xmlNodeSetAttribute(s, "type", "server")

        -- Admin UI images
        local loading = xmlCreateChild(xml, "file")
        xmlNodeSetAttribute(loading, "src", "files/images/loading.png")
        xmlNodeSetAttribute(loading, "type", "client")

        local accept = xmlCreateChild(xml, "file")
        xmlNodeSetAttribute(accept, "src", "files/images/accept.png")
        xmlNodeSetAttribute(accept, "type", "client")

        local decline = xmlCreateChild(xml, "file")
        xmlNodeSetAttribute(decline, "src", "files/images/decline.png")
        xmlNodeSetAttribute(decline, "type", "client")

        -- Exports
        local export = xmlCreateChild(xml, "export")
        xmlNodeSetAttribute(export, "function", "getLogo")
        xmlNodeSetAttribute(export, "type", "client")


        local orgs = exports.TR_mysql:querry("SELECT ID FROM tr_organizations WHERE img IS NOT NULL")
        for i, v in pairs(orgs) do
            local fileName = getOrgFileName(v.ID)
            if fileName then
                local logo = xmlCreateChild(xml, "file")
                xmlNodeSetAttribute(logo, "src", fileName)
                xmlNodeSetAttribute(logo, "type", "client")
            end
        end

        -- Saving
        xmlSaveFile(xml)
        xmlUnloadFile(xml)

        exports.TR_noti:create(client, "Yeni faction logoları başarıyla yüklendi.", "success")
        exports.TR_starter:reloadResources({"TR_orgLogos"})
    end
end
addEvent("reloadLogos", true)
addEventHandler("reloadLogos", resourceRoot, reloadLogos)

function getOrgFileName(orgID)
    if fileExists(string.format("files/logos/%d.png", orgID)) then
        return string.format("/files/logos/%d.png", orgID)
    end
    return false
end