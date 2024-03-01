function playerPayForGymTicket(state)
    exports.TR_dx:setResponseEnabled(false)

    if state then
        GymSettings.hasTicket = getTickCount()

        exports.TR_noti:create("Spor salonu karnesi başarıyla satın alındı.", "success")

        exports.TR_achievements:addAchievements("workoutTicket")
    end
end
addEvent("playerPayForGymTicket", true)
addEventHandler("playerPayForGymTicket", root, playerPayForGymTicket)

function canUseGym(element)
    if not isGymEquipmentFree(element) then exports.TR_noti:create("Bu ekipman üzerinde zaten biri egzersiz yapıyor.", "error") return end
    if not hasPlayerPermission() then exports.TR_noti:create("Bu ekipmanı kullanma izniniz yok.", "error") return end

    return true
end

function isGymEquipmentFree(element)
    local x, y, z = getElementPosition(element)

    for i, v in pairs(getElementsByType("player", root, true)) do
        if v ~= localPlayer then
            if getDistanceBetweenPoints2D(x, y, Vector2(getElementPosition(v))) < 1.5 and getElementData(v, "isWorkouting") then return false end
        end
    end
    return true
end

function hasPlayerPermission()
    if GymSettings.hasTicket then
        if (getTickCount() - GymSettings.hasTicket)/(GymSettings.ticketTime * 1000) < 1 then return true end
    end

    local _, jobType = exports.TR_jobs:getPlayerJob()
    if jobType == "police" then return true end

    if getElementData(localPlayer, "characterHomeID") then return true end

    return false
end

-- Yardımcı Fonksiyonlar
function drawBackground(x, y, rx, ry, color, radius, post)
    rx = rx - radius * 2
    ry = ry - radius * 2
    x = x + radius
    y = y + radius

    if (rx >= 0) and (ry >= 0) then
        dxDrawRectangle(x, y, rx, ry, color, post)
        dxDrawRectangle(x, y - radius, rx, radius, color, post)
        dxDrawRectangle(x, y + ry, rx, radius, color, post)
        dxDrawRectangle(x - radius, y, radius, ry, color, post)
        dxDrawRectangle(x + rx, y, radius, ry, color, post)

        dxDrawCircle(x, y, radius, 180, 270, color, color, 7, 1, post)
        dxDrawCircle(x + rx, y, radius, 270, 360, color, color, 7, 1, post)
        dxDrawCircle(x + rx, y + ry, radius, 0, 90, color, color, 7, 1, post)
        dxDrawCircle(x, y + ry, radius, 90, 180, color, color, 7, 1, post)
    end
end

function getPosition(element, vec)
	local rot = Vector3(getElementRotation(element))
	local mat = Matrix(Vector3(getElementPosition(element)), rot)
	local newPos = mat:transformPosition(vec)
	return newPos.x, newPos.y, newPos.z, rot.z
end

function buyWorkoutTicket()
    triggerServerEvent("createPayment", resourceRoot, GymSettings.ticketPrice, "playerPayForGymTicket")
end
addEvent("buyWorkoutTicket", true)
addEventHandler("buyWorkoutTicket", root, buyWorkoutTicket)


-- setPedAnimation(localPlayer, "GYMNASIUM", "gym_tread_geton", 2000)
-- setPedAnimation(localPlayer, nil, nil)