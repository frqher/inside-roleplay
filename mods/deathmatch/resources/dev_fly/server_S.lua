-- Sitemiz : https://sparrow-mta.blogspot.com/

-- Facebook : https://facebook.com/sparrowgta/
-- İnstagram : https://instagram.com/sparrowmta/
-- YouTube : https://youtube.com/c/SparroWMTA/

-- Discord : https://discord.gg/DzgEcvy

Flying = {}

----------------- Fly --------------------
function fly(thePlayer, commandName)
	-- if isObjectInACLGroup ( "user." ..getAccountName(getPlayerAccount(thePlayer)), aclGetGroup ("Admin")) then --- ACL
		triggerClientEvent(thePlayer, "onClientFlyToggle", thePlayer)
	-- else
		-- outputChatBox("[!] Bu komutu sadece yetkililer kullanabilir.", thePlayer, 255, 0, 0, true) 
	-- end
end
addCommandHandler("fly", fly, false, false)  --- KOMUT

-- Sitemiz : https://sparrow-mta.blogspot.com/

-- Facebook : https://facebook.com/sparrowgta/
-- İnstagram : https://instagram.com/sparrowmta/
-- YouTube : https://youtube.com/c/SparroWMTA/

-- Discord : https://discord.gg/DzgEcvy

