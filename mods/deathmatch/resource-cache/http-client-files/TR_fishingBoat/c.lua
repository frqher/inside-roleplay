local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local boatsList = {}

function elementStreamIn()
    if getElementType(source) == "vehicle" and not boatsList[source] then
        boatsList[source] = getElementData(source, "fishBoat")
    end
end
addEventHandler("onClientElementStreamIn", resourceRoot, elementStreamIn)

function elementStreamOut()
    if getElementType(source) == "vehicle" and boatsList[source] then
        boatsList[source] = nil
    end
    collectgarbage()
end
addEventHandler("onClientElementStreamOut", resourceRoot, elementStreamOut)

function elementStreamOut()
    if getElementType(source) == "vehicle" and boatsList[source] then
        boatsList[source] = nil
    end
    collectgarbage()
end
addEventHandler("onClientElementDestroy", resourceRoot, elementStreamOut)



-- Fishing boat
function rentFishingBoat(price, id)
    triggerServerEvent("createPayment", resourceRoot, price, "onFishingBoatRent", {id = id})
end
addEvent("rentFishingBoat", true)
addEventHandler("rentFishingBoat", root, rentFishingBoat)

function responseFishingBoat(state)
    exports.TR_dx:setResponseEnabled(false)

    if state then
        exports.TR_noti:create("Tekne başarılı bir şekilde kiralandı.", "boat")
    end
end
addEvent("responseFishingBoat", true)
addEventHandler("responseFishingBoat", root, responseFishingBoat)

local textFont = exports.TR_dx:getFont(16)
function renderFishingTimes()
    local px, py, pz = getCameraMatrix()
    local nowTimestamp = getRealTime().timestamp

    for v, data in pairs(boatsList) do
        local x, y, z = getElementPosition(v)
        local vx, vy = getScreenFromWorldPosition(x, y, z + 1.6)
        local dist = getDistanceBetweenPoints3D(px, py, pz, x, y, z)
        local clear = isLineOfSightClear(px, py, pz, x, y, z, true, false, false, true, true, true)
        if vx and vy and clear and dist < 30 then
            if data then
                local alpha = dist <= 30 and 1 or (30 - dist)/10
                dist = dist/40

                dxDrawText(string.format("Kalan süre\n#999999%s\n(%s)", getTimeInSeconds(3600 - (nowTimestamp - data.timestamp)), data.owner), vx, vy, vx, vy, tocolor(255, 255, 255, 255 * alpha), 1/zoom - dist, textFont, "center", "center", false, false, false, true)
            end
        end
    end
end
addEventHandler("onClientRender", root, renderFishingTimes)

function getTimeInSeconds(seconds)
    local seconds = tonumber(seconds)

    if seconds <= 0 then
      return "00:00:00";
    else
      hours = string.format("%02.f", math.floor(seconds/3600));
      mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
      secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
      return hours..":"..mins..":"..secs
    end
end