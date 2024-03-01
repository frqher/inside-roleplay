local VehicleExchanges = {
    {
        minPrice = 2000,
        maxPrice = 50000,
        border = {1256.84375, 145.2001953125, 1261.2080078125, 158.302734375, 1268.3583984375, 176.2041015625, 1284.619140625, 212.3427734375, 1314.302734375, 199.642578125, 1327.837890625, 191.0849609375, 1320.4580078125, 163.3271484375, 1318.4443359375, 145.7001953125, 1309.224609375, 130.5341796875, 1293.8583984375, 129.625},
        marker = {1310.4658203125, 158.7900390625, 20.427},
    },
    {
        minPrice = 50000,
        maxPrice = 300000,
        border = {-2154.16, -744.93, -2121.58, -744.96, -2119.63, -745.14, -2117.54, -745.98, -2115.94, -747.12, -2114.53, -748.89, -2113.77, -750.81, -2113.42, -752.89, -2113.40, -966.70, -2113.62, -968.81, -2114.51, -970.86, -2115.70, -972.48, -2117.53, -973.88, -2119.35, -974.62, -2121.47, -974.92, -2154.26, -974.91,},
        marker = {-2129.326171875, -860.111328125, 32.0234375},
    },
    {
        minPrice = 300000,
        maxPrice = 10000000,
        border = {1397.3203125, 663.45312, 1357.8603515625, 663.703125, 1357.7158203125, 797.81054687, 1397.4208984375, 797.733398437},
        marker = {1392.3779296875, 746.4560546875, 10.820},
    },
}

function updateVehicleExchange()
    local vehData = exports.TR_mysql:querry("SELECT tr_vehicles.ID, tr_vehicles.mileage, tr_vehicles.engineCapacity, tr_vehicles.exchangePrice, tr_accounts.username, tr_accounts.UID as UID FROM tr_vehicles LEFT JOIN tr_accounts ON tr_accounts.UID = tr_vehicles.ownedPlayer WHERE tr_vehicles.exchangePrice IS NOT NULL")
    if vehData and vehData[1] then
        for i, v in pairs(vehData) do
            local veh = getElementByID("vehicle"..v.ID)
            if veh then
                setElementData(veh, "exchangeData", {
                    mileage = v.mileage,
                    engineCapacity = v.engineCapacity,
                    price = v.exchangePrice,
                    owner = v.username,
                    ownerUID = v.UID,
                })
            end
        end
    end
end

function setVehicleOnExchange(veh, price)
    local data = getElementData(veh, "vehicleData")
    if not data then return end

    local vehData = exports.TR_mysql:querry("SELECT mileage, engineCapacity FROM tr_vehicles WHERE ID = ? LIMIT 1", data.ID)
    setElementData(veh, "exchangeData", {
        mileage = vehData[1].mileage,
        engineCapacity = vehData[1].engineCapacity,
        price = price,
        owner = getPlayerName(client),
        ownerUID = getElementData(client, "characterUID"),
    })

    exports.TR_mysql:querry("UPDATE tr_vehicles SET exchangePrice = ? WHERE ID = ? LIMIT 1", price, data.ID)
    exports.TR_vehicles:saveVehicle(veh)

    triggerClientEvent(client, "addAchievements", resourceRoot, "vehicleExchangeSet")
end
addEvent("setVehicleOnExchange", true)
addEventHandler("setVehicleOnExchange", root, setVehicleOnExchange)

function leaveZone(el)
    if getElementType(el) ~= "vehicle" then return end
    removeElementData(el, "exchangeData")

    local data = getElementData(el, "vehicleData")
    if not data then return end
    exports.TR_mysql:querry("UPDATE tr_vehicles SET exchangePrice = NULL WHERE ID = ? LIMIT 1", data.ID)
end

function enterMarker(el)
    if getElementType(el) ~= "vehicle" then return end
    local driver = getVehicleOccupant(el, 0)
    if not driver then return end

    local vehData = getElementData(el, "vehicleData")
    if not vehData then return end

    local isPlayerOwner = exports.TR_mysql:querry("SELECT ID FROM tr_vehicles WHERE ownedPlayer = ? AND ID = ? LIMIT 1", getElementData(driver, "characterUID"), vehData.ID)
    if not isPlayerOwner or not isPlayerOwner[1] then return exports.TR_noti:create(driver, "Nie jesteś właścicielem tego pojazdu.", "error") end


    local data = getElementData(source, "exchangeData")
    triggerClientEvent(driver, "openExchangeWindow", resourceRoot, data, source)
end

function createExchanges()
    for i, v in pairs(VehicleExchanges) do
        createColPolygon(0, 0, unpack(v.border))

        local blip = createBlip(v.marker[1], v.marker[2], v.marker[3], 0, 2, 107, 201, 48, 0)
        setElementData(blip, "icon", 29)

        local marker = createMarker(v.marker[1], v.marker[2], v.marker[3] - 0.9, "cylinder", 3, 107, 201, 48, 0)
        setElementData(marker, "markerIcon", "exchange")
        setElementData(marker, "markerData", {
            title = "Giełda samochodowa",
            desc = string.format("Aracın sergilenmesi\n$%d - $%d", v.minPrice, v.maxPrice)
        })
        setElementData(marker, "exchangeData", {
            minPrice = v.minPrice,
            maxPrice = v.maxPrice,
        }, false)
    end

    addEventHandler("onColShapeLeave", resourceRoot, leaveZone)
    addEventHandler("onMarkerHit", resourceRoot, enterMarker)
end
createExchanges()




function buyVehicleExchange(veh)
    if not canBuyVehicle(client) then exports.TR_noti:create(client, "Sonrasında sınırınıza ulaştınız. Hesabınızı yükseltin veya araç limitinizi artırın.", "error") return end

    local exchangeData = getElementData(veh, "exchangeData")
    if not exchangeData then return exports.TR_noti:create(client, "Bu araba artık satılık değil.", "info") end

    local vehData = getElementData(veh, "vehicleData")
    local checkBought = exports.TR_mysql:querry("SELECT exchangePrice FROM tr_vehicles WHERE ID = ? LIMIT 1", vehData.ID)
    if checkBought and checkBought[1] then
        if checkBought[1].exchangePrice == "Nabıyon bilader" then
            exports.TR_noti:create(client, "Bu araba zaten satın alındı.", "error")
            return
        end
    end

    local plrUID = getElementData(client, "characterUID")
    local plrData = getElementData(client, "characterData")

    local money = tonumber(plrData.money)
    exchangeData.price = tonumber(exchangeData.price)

    if exchangeData.price > money then return exports.TR_noti:create(client, "Üzerinizde o kadar para yok.", "error") end
    if exports.TR_core:takeMoneyFromPlayer(client, exchangeData.price) then
        for i, v in pairs(getVehicleOccupants(veh)) do
            removePedFromVehicle(v)
        end

        local seller = getPlayerFromName(exchangeData.owner)
        if isElement(seller) then
            if getElementData(seller, "characterUID") == exchangeData.ownerUID then
                exports.TR_core:giveMoneyToPlayer(seller, exchangeData.price)
                exports.TR_noti:create(seller, "Listelenen aracınız yeni satıldı.", "success")
            else
                exports.TR_mysql:querry("UPDATE `tr_accounts` SET money = money + ? WHERE UID = ? LIMIT 1", exchangeData.price, exchangeData.ownerUID)
            end
        else
            exports.TR_mysql:querry("UPDATE `tr_accounts` SET money = money + ? WHERE UID = ? LIMIT 1", exchangeData.price, exchangeData.ownerUID)
        end

        exports.TR_mysql:querry("UPDATE tr_vehicles SET ownedPlayer = ?, exchangePrice = NULL, requestOrg = NULL, ownedOrg = NULL WHERE ID = ? LIMIT 1", plrUID, vehData.ID)
        exports.TR_mysql:querry("DELETE FROM tr_vehiclesRent WHERE vehID = ?", vehData.ID)
        exports.TR_noti:create(client, "Araba başarıyla satın alındı.", "success")

        local time = getRealTime()
        exports.TR_discord:sendChannelMsg("vehicleBuy", {
          time = string.format("[%02d:%02d %02d.%02d]", time.hour, time.minute, time.monthday, time.month),
          author = getPlayerName(client),
          text = string.format("Pazarda %d kimlikli bir aracı %s oyuncusundan bir miktar karşılığında satın aldı $%.2f.", vehData.ID, exchangeData.owner, exchangeData.price),
        })

        removeElementData(veh, "exchangeData")
        setElementData(veh, "vehicleOwners", {plrUID})
	    removeElementData(veh, "vehicleOrganization")

        triggerClientEvent(client, "addAchievements", resourceRoot, "vehicleExchangeBuy")
    end
end
addEvent("buyVehicleExchange", true)
addEventHandler("buyVehicleExchange", root, buyVehicleExchange)


function canBuyVehicle(plr)
    local plrUID = getElementData(plr, "characterUID")
    local plrData = getElementData(plr, "characterData")

    local vehicleCount = exports.TR_mysql:querry("SELECT ID FROM tr_vehicles WHERE ownedPlayer = ?", plrUID)
    local vehicleLimit = exports.TR_mysql:querry("SELECT vehicleLimit FROM `tr_accounts` WHERE `UID` = ? LIMIT 1", plrUID)
    local limit = tonumber(vehicleLimit[1].vehicleLimit)

    if plrData.premium == "gold" then
      limit = limit + 10

    elseif plrData.premium == "diamond" then
      limit = limit + 30
    end

    if #vehicleCount < limit then return true end
    return false
end



function checkExchange()
    local toRemove = exports.TR_mysql:querry("SELECT ID FROM tr_vehicles WHERE exchangePrice = ?", "skurwiel do wyjebania")
    if toRemove then
        for i, v in pairs(toRemove) do
            local veh = getElementByID("vehicle"..v.ID)
            if veh then
                exports.TR_vehicles:saveVehicle(veh)
                destroyElement(veh)
            end
        end
    end
    exports.TR_mysql:querry("UPDATE tr_vehicles SET exchangePrice = NULL, parking = 1 WHERE exchangePrice = ?", "skurwiel do wyjebania")
end
checkExchange()
setTimer(checkExchange, 60000, 0)