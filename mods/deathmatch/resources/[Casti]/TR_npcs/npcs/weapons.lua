local NPCs = {
    {
        skin = 121,
        pos = Vector3(316.10852050781, -134.22518920898, 999.6015625),
        int = 7,
        dim = 1,
        rot = 92,
        name = "Mark Frank",
    },
    {
        skin = 121,
        pos = Vector3(316.10852050781, -134.22518920898, 999.6015625),
        int = 7,
        dim = 2,
        rot = 92,
        name = "Mark Freeway",
    },

    {
        skin = 121,
        pos = Vector3(295.06167602539, -82.530395507813, 1001.515625),
        int = 4,
        dim = 1,
        rot = 357,
        name = "Stephan Frank",
    },
    {
        skin = 121,
        pos = Vector3(295.06167602539, -82.530395507813, 1001.515625),
        int = 4,
        dim = 2,
        rot = 357,
        name = "Jozeph Yarn",
    },
    {
        skin = 121,
        pos = Vector3(295.06167602539, -82.530395507813, 1001.515625),
        int = 4,
        dim = 3,
        rot = 357,
        name = "Dennis Yarn",
    },

    {
        skin = 121,
        pos = Vector3(312.83920288086, -167.802734375, 999.59375),
        int = 6,
        dim = 1,
        rot = 0,
        name = "Mark Froyd",
    },
    {
        skin = 121,
        pos = Vector3(312.83920288086, -167.802734375, 999.59375),
        int = 6,
        dim = 2,
        rot = 0,
        name = "Jozeph Brown",
    },
    {
        skin = 121,
        pos = Vector3(312.83920288086, -167.802734375, 999.59375),
        int = 6,
        dim = 3,
        rot = 0,
        name = "Phillip White",
    },
    {
        skin = 121,
        pos = Vector3(312.83920288086, -167.802734375, 999.59375),
        int = 6,
        dim = 4,
        rot = 0,
        name = "Thomas Black",
    },
    {
        skin = 121,
        pos = Vector3(312.83920288086, -167.802734375, 999.59375),
        int = 6,
        dim = 5,
        rot = 0,
        name = "Thomas Grant",
    },
    {
        skin = 121,
        pos = Vector3(312.83920288086, -167.802734375, 999.59375),
        int = 6,
        dim = 6,
        rot = 0,
        name = "Dani Krose",
    },
    {
        skin = 121,
        pos = Vector3(308.2314453125, -143.091796875, 999.6015625),
        int = 7,
        dim = 2,
        rot = 358,
        name = "Tonny Grant",
    },
}

function createWaponsNPC()
    local dialogue = exports.TR_npc:createDialogue()
    exports.TR_npc:addDialogueText(dialogue, "Merhaba.", {pedResponse = "Günaydın. Hoş geldiniz. Size nasıl yardım edebilirim?"})
    exports.TR_npc:addDialogueText(dialogue, "Silah ruhsatı almak istiyorum.", {pedResponse = "Hangi kategori?", responseTo = "Merhaba."})
    exports.TR_npc:addDialogueText(dialogue, "Yakın dövüş silahı satın almak istiyorum.", {pedResponse = "", responseTo = "Merhaba.", img = "shop", trigger = "openAmmunationShop", triggerData = {"baseball"}})
    exports.TR_npc:addDialogueText(dialogue, "Ateşli silah satın almak istiyorum.", {pedResponse = "", responseTo = "Merhaba.", img = "shop", trigger = "openAmmunationShop", triggerData = {"guns"}})
    exports.TR_npc:addDialogueText(dialogue, "Mühimmat satın almak istiyorum.", {pedResponse = "", responseTo = "Merhaba.", img = "shop", trigger = "openAmmunationShop", triggerData = {"ammunition"}})
    exports.TR_npc:addDialogueText(dialogue, "Ek ekipman satın almak istiyorum.", {pedResponse = "", responseTo = "Merhaba.", img = "shop", trigger = "openAmmunationShop", triggerData = {"other"}})
    exports.TR_npc:addDialogueText(dialogue, "Teori sınavı.", {pedResponse = "", responseTo = "Silah ruhsatı almak istiyorum.", img = "pistol", trigger = "openAmmunationShop", triggerData = {"theory"}})
    exports.TR_npc:addDialogueText(dialogue, "Hazırlık sınavı.", {pedResponse = "", responseTo = "Silah ruhsatı almak istiyorum.", img = "pistol", trigger = "openAmmunationShop", triggerData = {"practice"}})

    exports.TR_npc:addDialogueText(dialogue, "Güle güle.", {pedResponse = "Güle güle."})

    for i, v in pairs(NPCs) do
        local ped = exports.TR_npc:createNPC(v.skin, v.pos.x, v.pos.y, v.pos.z, v.rot, v.name, "Mağaza Çalışanı", "dialogue")
        setElementInterior(ped, v.int)
        setElementDimension(ped, v.dim)
        setElementData(ped, "name", v.name)

        if v.animation then setElementData(ped, "animation", v.animation) end

        exports.TR_npc:setNPCDialogue(ped, dialogue)
    end
end
createWaponsNPC()


function createWeaponLicence(status, licence)
    if licence[1] == "practice" then
        triggerClientEvent(source, "createWeaponPracticeLicence", resourceRoot, status)
    else
        triggerClientEvent(source, "startLicenceTheory", resourceRoot, status, "weapon")
    end
end
addEvent("createWeaponLicence", true)
addEventHandler("createWeaponLicence", root, createWeaponLicence)

function openAmmunationShop(ped, data)
    local uid = getElementData(client, "characterUID")
    local pedName = getElementData(ped, "name")

    if data[1] == "theory" then
        local hasTheory = exports.TR_mysql:querry("SELECT UID FROM tr_accounts WHERE UID = ? AND licenceTheory LIKE ? LIMIT 1", uid, "%weapon%")
        if hasTheory and hasTheory[1] then triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Teorik sınav zaten geçildi.", "files/images/npc.png") return end

        triggerClientEvent(client, "payWeaponLicence", resourceRoot, data)
        return

    elseif data[1] == "practice" then
        local hasTheory = exports.TR_mysql:querry("SELECT UID FROM tr_accounts WHERE UID = ? AND licenceTheory LIKE ? LIMIT 1", uid, "%weapon%")
        if not hasTheory or not hasTheory[1] then triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Uygulamalı sınava girebilmek için önce teoriyi geçmelisiniz.", "files/images/npc.png") return end

        local hasPractice = exports.TR_mysql:querry("SELECT UID FROM tr_accounts WHERE UID = ? AND licence LIKE ? LIMIT 1", uid, "%weapon%")
        if hasPractice and hasPractice[1] then triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Zaten ateşli silah lisansınız var.", "files/images/npc.png") return end

        local weapons = getPedWeapons(client)
        if #weapons > 0 then triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Kendi silahınızla atış poligonuna girmeniz mümkün değildir. Lütfen sınava girmeden önce silahlarınızı bırakın.", "files/images/npc.png") return end

        triggerClientEvent(client, "payWeaponLicence", resourceRoot, data)
        return

    elseif data[1] == "baseball" then
        triggerClientEvent(client, "createShop", resourceRoot, "Mühimmat deposu", {
            {
                type = 1,
                variant = 1,
                variant2 = 0,
                price = 650,
                value = 3,
            },
            {
                type = 1,
                variant = 1,
                variant2 = 2,
                price = 800,
                value = 5,
            },
            {
                type = 1,
                variant = 1,
                variant2 = 1,
                price = 1200,
                value = 4,
            },
            {
                type = 1,
                variant = 1,
                variant2 = 3,
                price = 4200,
                value = 8,
            },
        })

    elseif data[1] == "guns" then
        local hasPractice = exports.TR_mysql:querry("SELECT UID FROM tr_accounts WHERE UID = ? AND licence LIKE ? LIMIT 1", uid, "%weapon%")
        if not hasPractice or not hasPractice[1] then triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Üzgünüm, ateşli silah ruhsatınız yok. O olmadan sana ateşli silah satamam.", "files/images/npc.png") return end

        triggerClientEvent(client, "createShop", resourceRoot, "Silah mağazası", {
            {
                type = 1,
                variant = 2,
                variant2 = 0,
                price = 18490,
                value = 22,
            },
            {
                type = 1,
                variant = 2,
                variant2 = 1,
                price = 28200,
                value = 24,
            },
            {
                type = 1,
                variant = 3,
                variant2 = 0,
                price = 36990,
                value = 25,
            },
            -- {
            --     type = 1,
            --     variant = 3,
            --     variant2 = 1,
            --     price = 3999.99,
            --     value = 26,
            -- },
            -- {
            --     type = 1,
            --     variant = 4,
            --     variant2 = 0,
            --     price = 3180,
            --     value = 28,
            -- },
            -- {
            --     type = 1,
            --     variant = 4,
            --     variant2 = 1,
            --     price = 4160,
            --     value = 29,
            -- },
            {
                type = 1,
                variant = 4,
                variant2 = 2,
                price = 22000,
                value = 32,
            },
            -- {
            --     type = 1,
            --     variant = 5,
            --     variant2 = 0,
            --     price = 6400,
            --     value = 30,
            -- },
            -- {
            --     type = 1,
            --     variant = 5,
            --     variant2 = 1,
            --     price = 7800,
            --     value = 31,
            -- },
            -- {
            --     type = 1,
            --     variant = 6,
            --     variant2 = 0,
            --     price = 5600,
            --     value = 33,
            -- },
            -- {
            --     type = 1,
            --     variant = 6,
            --     variant2 = 1,
            --     price = 6999,
            --     value = 34,
            -- },
        })

    elseif data[1] == "ammunition" then
        local hasPractice = exports.TR_mysql:querry("SELECT UID FROM tr_accounts WHERE UID = ? AND licence LIKE ? LIMIT 1", uid, "%weapon%")
        if not hasPractice or not hasPractice[1] then triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Üzgünüm, ateşli silah ruhsatınız yok. O olmadan sana cephane satamam.", "files/images/npc.png") return end

        triggerClientEvent(client, "createShop", resourceRoot, "Mühimmat deposu", {
            {
                type = 10,
                variant = 0,
                variant2 = 0,
                price = 263,
                value = 50,
            },
            {
                type = 10,
                variant = 1,
                variant2 = 0,
                price = 200,
                value = 10,
            },
            {
                type = 10,
                variant = 2,
                variant2 = 0,
                price = 241,
                value = 30,
            },
            {
                type = 10,
                variant = 3,
                variant2 = 0,
                price = 190,
                value = 50,
            },
            {
                type = 10,
                variant = 4,
                variant2 = 0,
                price = 120,
                value = 20,
            },
            {
                type = 10,
                variant = 5,
                variant2 = 0,
                price = 210,
                value = 20,
            },
            {
                type = 10,
                variant = 6,
                variant2 = 0,
                price = 170,
                value = 10,
            },
        })

    elseif data[1] == "other" then
        triggerClientEvent(client, "createShop", resourceRoot, "Mühimmat deposu", {
            {
                type = 11,
                variant = 0,
                variant2 = 0,
                price = 765,
                value = 100,
            },
            {
                type = 12,
                variant = 0,
                variant2 = 0,
                price = 240,
            },
        })
    end

    triggerClientEvent(client, "showCustomMessage", resourceRoot, pedName, "Size ne verebilirim?", "files/images/npc.png")
end
addEvent("openAmmunationShop", true)
addEventHandler("openAmmunationShop", root, openAmmunationShop)

function getPedWeapons(ped)
	local playerWeapons = {}
	if ped and isElement(ped) and getElementType(ped) == "ped" or getElementType(ped) == "player" then
		for i=2,9 do
			local wep = getPedWeapon(ped,i)
			if wep and wep ~= 0 then
				table.insert(playerWeapons,wep)
			end
		end
	else
		return false
	end
	return playerWeapons
end