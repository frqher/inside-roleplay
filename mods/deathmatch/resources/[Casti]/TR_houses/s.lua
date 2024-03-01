local settings = {
	loadingResumeTime = 100,
	loadingCount = 100,

	checkResumeTime = 1000,
	checkCount = 2,
	checkTime = 60 * 1000,

	boughtColor = {200, 0, 0},
	freeColor = {0, 200, 0},
}

function loadHomeCoroutine()
	local count = 0
	local totalCount = 0
	local startTime = getTickCount()

	local querry = exports.TR_mysql:querry("SELECT ID, owner, pos FROM `tr_houses`")
	if #querry > 0 then
		for i, v in pairs(querry) do
			local pos = split(v.pos, ",")
			local marker = createMarker(pos[1], pos[2], pos[3] - 0.99, "cylinder", 1.2, settings.boughtColor[1], settings.boughtColor[2], settings.boughtColor[3], 0)
			setElementData(marker, "markerIcon", "house-bought")
			setElementData(marker, "homeData", {
				ID = v.ID,
			}, false)
			setElementID(marker, "homeID"..(v.ID))
			addEventHandler("onMarkerHit", marker, enterMarker)

			if not v.owner then
				setMarkerColor(marker, settings.freeColor[1], settings.freeColor[2], settings.freeColor[3], 0)
				setElementData(marker, "markerIcon", "house-free")
			end

			count = count + 1
			totalCount = totalCount + 1

			if count >= settings.loadingCount then
				count = 0
				setTimer(function()
					coroutine.resume(settings.loadingCoroutine)
				end, settings.loadingResumeTime, 1)
				coroutine.yield()
			end
		end

		print("[TR_houses] " .. totalCount .. " ev yüklendi " .. getTickCount() - startTime .. "ms.")

		loadOrgnizationsToHouses()
		checkHouseStatus()
		setTimer(checkHouseStatus, settings.checkTime, 1)
	else
		print("[TR_houses] Ev bulunamadı.")
	end
end

function loadOrgnizationsToHouses()
	local querry = exports.TR_mysql:querry("SELECT tr_houses.ID, tr_organizations.ID as orgID FROM `tr_houses` LEFT JOIN tr_organizations ON tr_organizations.ID = tr_houses.ownedOrg WHERE ownedOrg IS NOT NULL")
	if querry and querry[1] then
		for i, v in pairs(querry) do
			local marker = getElementByID("homeID"..v.ID)
			setMarkerColor(marker, 255, 255, 255, 0)
			setElementData(marker, "orgID", v.orgID)
		end
	end
end

function loadHomes()
	settings.loadingCoroutine = coroutine.create(loadHomeCoroutine)
	coroutine.resume(settings.loadingCoroutine)
end
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), loadHomes)


function enterMarker(el, dm)
	if not dm then return end
	if getElementType(el) ~= "player" then return end
	if getPedOccupiedVehicle(el) then return end
	if not getElementData(el, "characterUID") then return end

	local homeData = getElementData(source, "homeData")
	local dataHome = getHomeData(homeData.ID)
	if not dataHome then return end

	local houses, limit = getHousesCount(el)
	triggerClientEvent(el, "openHouseGuiInfo", resourceRoot, dataHome, houses, limit)
end


function playerPayForHome(state, data)
	local days, id = data[1], data[2]

	if state then
		local plrUID = getElementData(source, "characterUID")
		local homeData = getHomeData(id)

		if homeData.owner then
			local querryPayHome = exports.TR_mysql:querry("UPDATE `tr_houses` SET `date`= DATE_ADD(date, INTERVAL ? DAY) WHERE `ID` = ? LIMIT 1", days, id)

			if tonumber(days) >= 10 then
				triggerClientEvent(source, "addAchievements", resourceRoot, "houseRent10")
			end
			if tonumber(days) >= 30 then
				triggerClientEvent(source, "addAchievements", resourceRoot, "houseRent30")
			end

			homeData = getHomeData(id)
			triggerClientEvent(source, "updateHouseGuiInfo", resourceRoot, homeData)
			exports.TR_noti:create(source, "Evin kirası uzatıldı.", "success")
			return

		elseif not homeData.owner then
			local querryPayHome = exports.TR_mysql:querry("UPDATE `tr_houses` SET `date`= DATE_ADD(NOW(), INTERVAL ? DAY), `owner`= ? WHERE ID = ? LIMIT 1", days, plrUID, id)

			homeData = getHomeData(id)
			triggerClientEvent(source, "updateHouseGuiInfo", resourceRoot, homeData)
			triggerClientEvent(source, "addAchievements", resourceRoot, "houseRent")

			exports.TR_noti:create(source, "Ev başarıyla satın alındı. Bir sonraki kiranızı zamanında ödemeyi unutmayın.", "success")
			local marker = getElementByID("homeID"..id)
			if marker then
				local data = getElementData(marker, "homeData")
				setMarkerColor(marker, settings.boughtColor[1], settings.boughtColor[2], settings.boughtColor[3], 0)
				setElementData(marker, "markerIcon", "house-bought")
			end
		end
	end
	triggerClientEvent(source, "updateHouseGuiInfo", resourceRoot, false)
end
addEvent("playerPayForHome", true)
addEventHandler("playerPayForHome", root, playerPayForHome)


function getHousesCount(plr)
	local plrUID = getElementData(plr, "characterUID")
	local plrData = getElementData(plr, "characterData")

	local houseLimit = exports.TR_mysql:querry("SELECT houseLimit FROM `tr_accounts` WHERE `UID` = ? LIMIT 1", plrUID)

	if plrData.premium == "gold" then
		local houseCount = exports.TR_mysql:querry("SELECT ID FROM `tr_houses` WHERE `owner` = ?", plrUID)
		return #houseCount, houseLimit[1].houseLimit

	elseif plrData.premium == "diamond" then
		local houseCount = exports.TR_mysql:querry("SELECT ID FROM `tr_houses` WHERE `owner` = ?", plrUID)
		return #houseCount, houseLimit[1].houseLimit

	else
		local houseCount = exports.TR_mysql:querry("SELECT ID FROM `tr_houses` WHERE `owner` = ?", plrUID)
		return #houseCount, houseLimit[1].houseLimit
	end

	return 0, houseLimit[1].houseLimit
end


function enterHome(id)
	if not client then return end
	local homeData = getHomeData(id)

	if homeData.owner == getElementData(client, "characterUID") or homeData.orgID == getElementData(client, "characterOrgID") then
		enterHomeLoadInterior(client, id)
		setElementData(client, "canUseHouseStash", id)

	else
		if homeData.locked == 1 then
			local name = getPlayerName(client)
			if type(homeData.rent) == 'table' then rent = homeData.rent else
				rent = homeData.rent and fromJSON(homeData.rent) or {}
			end

			for i, v in ipairs(rent) do
				if v == name then
					enterHomeLoadInterior(client, id)
					setElementData(client, "canUseHouseStash", nil)
					return
				end
			end
			exports.TR_noti:create(client, "Kapı kilitli olduğundan içeri giremezsin.", "error")
			triggerClientEvent(client, "updateHouseGuiInfo", resourceRoot)
		else
			enterHomeLoadInterior(client, id)
			setElementData(client, "canUseHouseStash", nil)
		end
	end
end
addEvent("playerEnterHome", true)
addEventHandler("playerEnterHome", resourceRoot, enterHome)

function enterHomeLoadInterior(plr, homeID)
	if not plr or not homeID then exports.TR_noti:create(plr, "[H_1] Bir hata oluştu.", "error") return end
	local homeFurniture = exports.TR_mysql:querry("SELECT tr_accounts.username as ownerName, interiorFloor, interiorWalls, interiorObjects, interiorSize FROM `tr_houses` LEFT JOIN tr_accounts ON tr_houses.owner = tr_accounts.UID WHERE `ID` = ? LIMIT 1", homeID)
	if homeFurniture and #homeFurniture > 0 then
		local gangDrugs = exports.TR_mysql:querry("SELECT objectIndex, plantType, TIMESTAMPDIFF(SECOND, NOW(), growth) as growth, TIMESTAMPDIFF(SECOND, NOW(), fertilizer) as fertilizer FROM tr_gangHouseDrugs WHERE homeID = ?", homeID)

		local marker = getElementByID("homeID"..homeID)
		local x, y, z = getElementPosition(marker)
		local int = getElementInterior(marker)
		local dim = getElementDimension(marker)

		local posInt = string.format("%.2f,%.2f,%.2f,%d,%d", x, y, z + 400, 100, 0 + homeID)
		local posHome = string.format("%.2f,%.2f,%.2f,%d,%d", x, y, z + 0.5, int, dim)

		local ownerName = homeFurniture[1].ownerName or "Do kupienia"

		setElementData(plr, "characterHomeID", homeID, ownerName ~= "Do kupienia" and true or false)
		setElementData(plr, "characterQuit", {x, y, z, 0, 0}, false)

		triggerClientEvent(plr, "closeHouseGuiInfo", resourceRoot, "Mülk yükleniyor")

		local attachments = getAttachedElements(plr)
		if attachments then
			for i, v in pairs(attachments) do
				if getElementType(v) == "player" then
					triggerClientEvent(v, "setInteriorLoading", resourceRoot, "Mülk yükleniyor", 5)
					triggerClientEvent(v, "setRadarCustomLocation", resourceRoot, "Mülk | "..ownerName, true)
					setTimer(function()
						triggerClientEvent(v, "interiorLoadObjects", resourceRoot, homeFurniture[1].interiorSize, homeID, homeFurniture[1].interiorObjects, posInt, posHome, homeFurniture[1].interiorWalls, homeFurniture[1].interiorFloor, gangDrugs)
					end, 1000, 1)
				end
			end
		end

		triggerClientEvent(plr, "setRadarCustomLocation", resourceRoot, "Mülk | "..ownerName, true)
		setTimer(function()
			triggerClientEvent(plr, "interiorLoadObjects", resourceRoot, homeFurniture[1].interiorSize, homeID, homeFurniture[1].interiorObjects, posInt, posHome, homeFurniture[1].interiorWalls, homeFurniture[1].interiorFloor, gangDrugs)
		end, 1000, 1)
	else
		exports.TR_noti:create(plr, "[H_2] Bir hata oluştu.", "error")
	end
end

function playerCloseHome(homeID)
	if not homeID then exports.TR_noti:create(client, "[H_3] Bir hata oluştu.", "error") return end
	local homeData = getHomeData(homeID)

	local locked = tonumber(homeData.locked) == 1 and 0 or 1
	exports.TR_mysql:querry("UPDATE `tr_houses` SET locked = ? WHERE `ID` = ?", locked, homeID)
	homeData.locked = locked

	triggerClientEvent(client, "updateHouseGuiInfo", resourceRoot, homeData)
end
addEvent("playerCloseHome", true)
addEventHandler("playerCloseHome", resourceRoot, playerCloseHome)

function bindHouseToOrganization(homeID, bound)
	if not homeID then exports.TR_noti:create(client, "[H_3] Bir hata oluştu.", "error") return end
	local homeData = getHomeData(homeID)

	if not bound then
		local orgID = getElementData(client, "characterOrgID")
		if not orgID then
			triggerClientEvent(client, "updateHouseGuiInfo", resourceRoot)
			exports.TR_noti:create(client, "Herhangi bir kuruluşun sahibi değilsiniz.", "error")
			return
		end

		local hasOrg = exports.TR_mysql:querry("SELECT ID, name FROM `tr_organizations` WHERE `owner` = ? LIMIT 1", getElementData(client, "characterUID"))
		if not hasOrg or not hasOrg[1] then
			triggerClientEvent(client, "updateHouseGuiInfo", resourceRoot)
			exports.TR_noti:create(client, "Herhangi bir kuruluşun sahibi değilsiniz.", "error")
			return
		end

		if tonumber(homeData.owner) == getElementData(client, "characterUID") then
			local bounded = exports.TR_mysql:querry("SELECT ID FROM `tr_houses` WHERE `ownedOrg` = ? LIMIT 1", orgID)
			if bounded and bounded[1] then
				triggerClientEvent(client, "updateHouseGuiInfo", resourceRoot, homeData)
				exports.TR_noti:create(client, "Kuruluşunuza atanmış bir mülkünüz zaten var.", "error")

			else
				exports.TR_mysql:querry("UPDATE `tr_houses` SET ownedOrg = ? WHERE `ID` = ?", orgID, homeID)

				local marker = getElementByID("homeID"..homeID)
				setMarkerColor(marker, 255, 255, 255, 0)
				setElementData(marker, "orgID", orgID)

				homeData.orgID = orgID
				homeData.orgName = hasOrg[1].name
				homeData.orgOwner = getPlayerName(client)

				triggerClientEvent(client, "updateHouseGuiInfo", resourceRoot, homeData)
				exports.TR_noti:create(client, "Mülk başarıyla kuruluşa atandı.", "success")
			end
		else
			triggerClientEvent(client, "updateHouseGuiInfo", resourceRoot)
			exports.TR_noti:create(client, "Bu evin sahibi değilsiniz ve onu bir kuruluşa devredemezsiniz.", "error")
		end
	else
		local marker = getElementByID("homeID"..homeID)
		setMarkerColor(marker, settings.boughtColor[1], settings.boughtColor[2], settings.boughtColor[3], 0)
		removeElementData(marker, "orgID")

		exports.TR_mysql:querry("UPDATE `tr_houses` SET ownedOrg = NULL WHERE `ID` = ?", homeID)
		homeData.orgID = nil
		homeData.orgName = nil
		homeData.orgOwner = nil

		triggerClientEvent(client, "updateHouseGuiInfo", resourceRoot, homeData)
		exports.TR_noti:create(client, "Mülkiyet kuruluştan başarıyla silindi.", "success")
	end
end
addEvent("bindHouseToOrganization", true)
addEventHandler("bindHouseToOrganization", resourceRoot, bindHouseToOrganization)

function setHouseEmpty(homeID)
	if not homeID then exports.TR_noti:create(client, "[H_3] Bir hata oluştu.", "error") return end
	local homeData = getHomeData(homeID)

	if homeData.owner == getElementData(client, "characterUID") then
		exports.TR_mysql:querry("UPDATE `tr_houses` SET owner = NULL, ownedOrg = NULL, locked = 0 WHERE `ID` = ? LIMIT 1", homeID)
		triggerClientEvent(client, "addAchievements", resourceRoot, "houseLeave")

		local marker = getElementByID("homeID"..homeID)
		if marker then
			setMarkerColor(marker, settings.freeColor[1], settings.freeColor[2], settings.freeColor[3], 0)
			setElementData(marker, "markerIcon", "house-free")
		end

		triggerClientEvent(client, "updateHouseGuiInfo", resourceRoot, "close")

	else
		triggerClientEvent(client, "updateHouseGuiInfo", resourceRoot)
		exports.TR_noti:create(client, "Bu evin sahibi değilsin ve onu terk edemezsin.", "error")
	end
end
addEvent("setHouseEmpty", true)
addEventHandler("setHouseEmpty", resourceRoot, setHouseEmpty)

function playerEditHome(homeID)
	if not homeID then exports.TR_noti:create(client, "[H_3] Bir hata oluştu.", "error"); triggerClientEvent(client, "closeHouseGuiInfo", resourceRoot) return end
	local homeData = getHomeData(homeID)
	if homeData.owner == getElementData(client, "characterUID") then
		local homeFurnitures = exports.TR_mysql:querry("SELECT interiorFloor, interiorWalls, interiorObjects, interiorSize, pos FROM `tr_houses` WHERE `id` = ? LIMIT 1", homeID)
		if homeFurnitures and #homeFurnitures > 0 then
			local gangDrugs = exports.TR_mysql:querry("SELECT * FROM tr_gangHouseDrugs WHERE homeID = ?", homeID)

			local marker = getElementByID("homeID"..homeID)
			local x, y, z = getElementPosition(marker)
			local int = getElementInterior(marker)
			local dim = getElementDimension(marker)

			setElementData(client, "characterQuit", {x, y, z, 0, 0}, false)
			local posInt = string.format("%.2f,%.2f,%.2f,%d,%d", x, y, z + 400, 100, 0 + homeID)
			local posHome = string.format("%.2f,%.2f,%.2f,%d,%d", x, y, z + 0.5, int, dim)

			triggerClientEvent(client, "interiorsBuilderOpen", resourceRoot, homeFurnitures[1].interiorSize, homeID, homeFurnitures[1].interiorObjects, posInt, homeFurnitures[1].interiorWalls, homeFurnitures[1].interiorFloor, posHome, gangDrugs)
			triggerClientEvent(client, "closeHouseGuiInfo", resourceRoot, "Düzenleyici yükleniyor")
		end
	else
		triggerClientEvent(client, "closeHouseGuiInfo", resourceRoot)
		exports.TR_noti:create(client, "Bu evin sahibi değilsin.", "error")
	end
end
addEvent("playerEditHome", true)
addEventHandler("playerEditHome", resourceRoot, playerEditHome)

function playerAddPlayerToRentHome(homeID, targetID)
	if not client then return end

	local homeData = getHomeData(homeID)
	if homeData.owner ~= getElementData(client, "characterUID") then return end

	local target = getElementByID("ID"..targetID)
	if target then
		local rentedPeople = exports.TR_mysql:querry("SELECT ID, plrUID FROM tr_housesRent WHERE houseID = ? LIMIT 6", homeID)
		if #rentedPeople >= 6 then
			exports.TR_noti:create(client, "Daha fazla oda arkadaşı ekleyemezsiniz.", "error")
			triggerClientEvent(client, "updateHouseGuiInfo", resourceRoot)
			return
		end

		local isAlreadyRented = exports.TR_mysql:querry("SELECT ID FROM tr_housesRent WHERE houseID = ? AND plrUID = ? LIMIT 1", homeID, targetID)
		if isAlreadyRented and isAlreadyRented[1] then
			exports.TR_noti:create(client, "Bu kişi zaten oda arkadaşı olarak eklendi.", "error")
			triggerClientEvent(client, "updateHouseGuiInfo", resourceRoot)
			return
		end

		local targetName = getPlayerName(target)
		exports.TR_mysql:querry("INSERT INTO `tr_housesRent`(`plrUID`, `houseID`) VALUES (?, ?)", targetID, homeID)
		exports.TR_noti:create(client, targetName.." oda arkadaşı listesine başarıyla eklendi.", "success")
		triggerClientEvent(client, "updateHouseGuiInfo", resourceRoot, homeData)
	else
		exports.TR_noti:create(client, "Böyle bir oyuncu bulunamadı.", "error")
		triggerClientEvent(client, "updateHouseGuiInfo", resourceRoot)
	end
end
addEvent("playerAddPlayerToRentHome", true)
addEventHandler("playerAddPlayerToRentHome", resourceRoot, playerAddPlayerToRentHome)

function playerRemovePlayerFromRentHome(homeID, targetID)
	if not client then return end
	local homeData = getHomeData(homeID)
	if homeData.owner ~= getElementData(client, "characterUID") then return end

	exports.TR_mysql:querry("DELETE FROM `tr_housesRent` WHERE plrUID = ? AND houseID = ? LIMIT 1", targetID, homeID)

	triggerClientEvent(client, "updateHouseGuiInfo", resourceRoot, homeData)
	exports.TR_noti:create(client, "Oda arkadaşı başarıyla kaldırıldı.", "success")
end
addEvent("playerRemovePlayerFromRentHome", true)
addEventHandler("playerRemovePlayerFromRentHome", resourceRoot, playerRemovePlayerFromRentHome)

function removeHouseVisitors(houseID)
	for i, v in pairs(getElementsByType("player")) do
		if v ~= client then
			local homeID = getElementData(v, "characterHomeID")
			if homeID and homeID == houseID then
				triggerClientEvent(v, "removePlayerFromBuildedInterior", resourceRoot, true)
			end
		end
	end
	exports.TR_noti:create(client, "Mülkünüze gelen tüm ziyaretçilerden ayrılmaları istendi.", "success")
	triggerClientEvent(client, "updateHouseGuiInfo", resourceRoot)
end
addEvent("removeHouseVisitors", true)
addEventHandler("removeHouseVisitors", resourceRoot, removeHouseVisitors)


-- Check house status
function checkHouseStatus()
	settings.checkCoroutine = coroutine.create(checkCoroutine)
	coroutine.resume(settings.checkCoroutine)
end

function checkCoroutine()
	local count = 0
	local querry = exports.TR_mysql:querry("SELECT ID FROM `tr_houses` WHERE owner IS NOT NULL AND date < NOW()")
	if #querry > 0 then
		for i, v in pairs(querry) do
			local marker = getElementByID("homeID"..v.ID)
			if marker then
				setMarkerColor(marker, settings.freeColor[1], settings.freeColor[2], settings.freeColor[3], 0)
				setElementData(marker, "markerIcon", "house-free")
				removeElementData(marker, "orgID")
			end

			count = count + 1
			if count >= settings.checkCount then
				setTimer(function()
					coroutine.resume(settings.checkCoroutine)
					count = 0
				end, settings.checkResumeTime, 1)
				coroutine.yield()
			end
		end
	end
	exports.TR_mysql:querry("UPDATE `tr_houses` SET owner = NULL, ownedOrg = NULL, locked = 0 WHERE `date` < NOW()")
	setTimer(checkHouseStatus, settings.checkTime, 1)
end



-- Utils
function getHomeData(id)
	local info = exports.TR_mysql:querry("SELECT *, tr_accounts.username as ownerName FROM `tr_houses` LEFT JOIN tr_accounts ON tr_houses.owner = tr_accounts.UID WHERE ID = ? LIMIT 1", id)
	if #info < 1 then return false end

	local rentPlayers = exports.TR_mysql:querry("SELECT ID, tr_accounts.username as username FROM `tr_housesRent` LEFT JOIN tr_accounts ON tr_housesRent.plrUID = tr_accounts.UID WHERE houseID = ? LIMIT 6", id)
	local data = {
		ID = id,
		owner = tonumber(info[1].owner),
		ownerName = info[1].ownerName,
		price = info[1].price,
		date = info[1].date,
		interiorSize = info[1].interiorSize,
		locked = tonumber(info[1].locked),
		rent = rentPlayers,
		premium = info[1].premium,
		orgID = tonumber(info[1].ownedOrg),
	}

	if info[1].ownedOrg then
		local orgData = exports.TR_mysql:querry("SELECT name, owner FROM `tr_organizations` WHERE ID = ? LIMIT 1", info[1].ownedOrg)
		if orgData and orgData[1] then
			data.orgName = orgData[1].name
			data.orgOwner = orgData[1].owner
		end
	end
	return data
end


-- function checkHomes()
-- 	local querryCheckHome = exports.rpg_mysql:mysql_query("SELECT id FROM `rpg_houses` WHERE `date` < NOW()")
-- 	if querryCheckHome and #querryCheckHome > 0 then
-- 		for i, v in pairs(querryCheckHome) do
-- 			allHomes[v["id"]]:setColor(0, 180, 0, 0)
-- 			local dataHome = allHomes[v["id"]]:getData("house:data")
-- 			dataHome.owner = 0
-- 			allHomes[v["id"]]:setData("house:data", dataHome)
-- 		end

-- 		local querryClearHouses = exports.rpg_mysql:mysql_query("UPDATE `rpg_houses` SET `owner`= 0  WHERE `date` < NOW()")
-- 	end
-- end
-- setTimer(checkHomes, 10000, 0)





function cmdAdminCreateHouse(plr, cmd, price, size, int, dim, ...)
	if not plr:getData("adminDuty") then return end
	if not price or not size or not int or not dim or not ... then
		outputChatBox("Użyj: /"..cmd.." [cena] [wielkość] [int] [dim] [nazwa domu]", plr)
		return
	end
	local pos = Vector3(plr:getPosition())
	local posInt = tostring(pos.x..","..pos.y..","..(pos.z + 1000)..","..int..","..dim)
	local posEnter = tostring(pos.x..","..pos.y..","..pos.z..", 0, 0")
	local querryCheckHome, rows, id = exports.rpg_mysql:mysql_query(string.format("INSERT INTO `tr_houses`(`owner`, `name`, `price`, `pos`, `pos_int`, `interiorSize`, `date`, `interiorObjects`, `interiorWalls`, `interiorFloor`, `rent`) VALUES (0,'%s','%d','%s','%s','%d', NOW(),'%s','%s','%s','%s')", table.concat({...}, " "), tonumber(price), posEnter, posInt, tonumber(size), toJSON({}), toJSON({}), toJSON({}), toJSON({})))
	if querryCheckHome then
		local querry = exports.rpg_mysql:mysql_query("SELECT * FROM tr_houses WHERE id = ? LIMIT 1", id)

		local marker = createMarker(pos.x, pos.y, pos.z - 0.99, "cylinder", 1.2, 0, 180, 0, 0)
		marker:setData("customMarker:img", "house")
		marker:setData("house:data", {
			id = querry[1]["id"],
			owner = tonumber(querry[1]["owner"]),
			ownerName = querry[1]["owner_name"],
			date = querry[1]["date"],
			name = querry[1]["name"],
			price = querry[1]["price"],
			locked = tonumber(querry[1]["locked"]),
			size = querry[1]["interiorSize"],
			exitPos = {pos[1], pos[2], pos[3]},
			rent = fromJSON(querry[1]["rent"]) and fromJSON(querry[1]["rent"]) or {}
		})
		addEventHandler("onMarkerHit", marker, enterMarker)
		allHomes[querry[1]["id"]] = marker
	end
end
addCommandHandler("chouse", cmdAdminCreateHouse)
