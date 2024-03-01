local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 500/zoom)/2,
    y = sy - 120/zoom,
    w = 500/zoom,
    h = 100/zoom,

    fonts = {
        main = exports.TR_dx:getFont(14),
        small = exports.TR_dx:getFont(10),
    },
}



local components = {"door_lf_dummy", "door_rf_dummy"};

local element = nil; -- pojazd

local screen = Vector2(guiGetScreenSize());

local vehiclesTable = {
	-- 2 drzwi
	vehs1 = {
		602, 429, 402, 541, 415, 480, 562, 587, 565, 559, 603, 506, 558, 555, 536, 575,
        518, 419, 534, 576, 412, 496, 401, 527, 542, 533, 526, 474, 545, 517, 410, 436,
        475, 439, 549, 491, 599, 552, 499, 422, 414, 600, 543, 478, 456, 554, 589, 500,
        489, 442, 495, 502, 503
    },

    vehs1_1 = {
    	411, 451, 477, 535, 528, 525, 508, 494, 423
    },

    vehs1_2 = {
    	433, 524, 455, 403, 443, 515, 514, 408
    },

    -- 4 drzwi
    vehs2 = {
    	560, 567, 445, 438, 507, 585, 466, 492, 546, 551, 516, 467, 426, 547, 405, 580,
        550, 566, 420, 540, 421, 529, 490, 596, 598, 597, 418, 579, 400, 470, 404, 479,
        458, 561
    },

    vehs2_1 = {
    	416, 427, 609, 498, 428, 459, 482, 582, 413, 440
    },

    used = {
    	 602, 429, 402, 541, 415, 480, 562, 587, 565, 559, 603, 506, 558, 555, 536, 575,
         518, 419, 534, 576, 412, 496, 401, 527, 542, 533, 526, 474, 545, 517, 410, 436,
         475, 439, 549, 491, 599, 552, 499, 422, 414, 600, 543, 478, 456, 554, 589, 500,
         489, 442, 495, 560, 567, 445, 438, 507, 585, 466, 492, 546, 551, 516, 467, 426,
         547, 405, 580, 550, 566, 420, 540, 421, 529, 490, 596, 598, 597, 418, 579, 400,
         470, 404, 479, 458, 561, 411, 451, 477, 535, 528, 525, 508, 494, 502, 503, 423,
         416, 427, 609, 498, 428, 459, 482, 582, 413, 440, 433, 524, 455, 403, 443, 515,
         514, 408, 407, 544, 601, 573, 574, 483, 588, 434, 444, 583, 409
    },
};

relativePos = function()
    if (element) and (getElementType(element) == "vehicle") then
        local vx, vy, vz = getElementPosition(element);
        local rxv, ryv, rzv = getElementRotation(element);
        local px, py, pz = getElementPosition(localPlayer);
        local anglePlayerToVehicle = math.atan2(px - vx, py - vy);
        local formattedAnglePlayerToVehicle = math.deg(anglePlayerToVehicle) + 180;
        local vehicleRelatedPosition = formattedAnglePlayerToVehicle + rzv;

        if (vehicleRelatedPosition < 0) then
            vehicleRelatedPosition = vehicleRelatedPosition + 360;
        elseif (vehicleRelatedPosition > 360) then
            vehicleRelatedPosition = vehicleRelatedPosition - 360;
        end

        return math.floor(vehicleRelatedPosition) + 0.5;
    else
        return "false";
    end;
end;

getComponentID = function(element)
    local vehicle = element;

    if (getBodyType(vehicle)) == "2 kapı" then
        if (relativePos() >= 140) and (relativePos() <= 220) then
            return 0;
        end;

        if (relativePos() >= 330) and (relativePos() <= 360)  or (relativePos() >= 0) and (relativePos() <= 30) then
            return 1;
        end;

        if (relativePos() >= 65) and (relativePos() <= 120) then
            return 2;
        end;

        if (relativePos() >= 240) and (relativePos() <= 295) then
            return 3;
        end;
    elseif (getBodyType(vehicle)) == "2 kapı, daha küçük" then
        if (relativePos() >= 140) and (relativePos() <= 220) then
            return 0;
        end;

        if (relativePos() >= 65) and (relativePos() <= 120) then
            return 2;
        end;

        if (relativePos() >= 240) and (relativePos() <= 295) then
            return 3;
        end;
    elseif (getBodyType(vehicle)) == "4 kapı" then
        if (relativePos() >= 140) and (relativePos() <= 220) then
            return 0;
        end;

        if (relativePos() >= 330) and (relativePos() <= 360)  or (relativePos() >= 0) and (relativePos() <= 30) then
            return 1;
        end;

        if (relativePos() >= 91) and (relativePos() <= 120) then
            return 2;
        end;

        if (relativePos() >= 240) and (relativePos() <= 270) then
            return 3;
        end;

        if (relativePos() >= 60) and (relativePos() <= 90) then
            return 4;
        end;

        if (relativePos() >= 271) and (relativePos() <= 300) then
            return 5;
        end;
    elseif (getBodyType(vehicle)) == "İle" then
        if (relativePos() >= 140) and (relativePos() <= 220) then
            return 0;
        end;

        if (relativePos() >= 91) and (relativePos() <= 130) then
            return 2;
        end;

        if (relativePos() >= 230) and (relativePos() <= 270) then
            return 3;
        end;

        if (relativePos() >= 0) and (relativePos() <= 30) then
            return 4;
        end;

        if (relativePos() >= 330) and (relativePos() <= 360) then
            return 5;
        end;
    elseif (getBodyType(vehicle)) == "Kamyonlar" then
        if (relativePos() >= 160) and (relativePos() <= 200) then
            return 0;
        end;

        if (relativePos() >= 120) and (relativePos() <= 155) then
            return 2;
        end;

        if (relativePos() >= 205) and (relativePos() <= 230) then
            return 3;
        end;
    end;

    return nil;
end;

isUsed = function(element)
    local vehicle = element;

    for i, v in pairs(vehiclesTable.used) do
        if (v == getElementModel(vehicle)) then
            return "true";
        end;
    end;
end;

getBodyType = function(element)
    local vehicle = element;

    if (isUsed(vehicle)) == "true" then
        for i, v in pairs(vehiclesTable.vehs1) do
            if (v == getElementModel(vehicle)) then
                return "2 kapı";
            end;
        end;

        for i, v in pairs(vehiclesTable.vehs1_1) do
            if (v == getElementModel(vehicle)) then
                return "2 kapı, küçük";
            end;
        end;

        for i, v in pairs(vehiclesTable.vehs2) do
            if (v == getElementModel(vehicle)) then
                return "4 kapı";
            end;
        end;

        for i, v in pairs(vehiclesTable.vehs2_1) do
            if (v == getElementModel(vehicle)) then
                return "ile";
            end;
        end;

        for i, v in pairs(vehiclesTable.vehs1_2) do
            if (v == getElementModel(vehicle)) then
                return "Kamyonlar";
            end;
        end;
    else
        return;
    end;
end;

local p = {};
p.tick = nil;

progressBarRender = function()
    local progress = math.min((getTickCount()-p.tick)/5000, 1)

    drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255), 5)

    dxDrawText("Yayma", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 40/zoom, tocolor(240, 196, 55, 255), 1/zoom, guiInfo.fonts.main, "center", "center")
    drawBackground(guiInfo.x + 10/zoom, guiInfo.y + 40/zoom, guiInfo.w - 20/zoom, 30/zoom, tocolor(47, 47, 47, 255), 5)
    drawBackground(guiInfo.x + 12/zoom, guiInfo.y + 42/zoom, (guiInfo.w - 24/zoom) * progress, 26/zoom, tocolor(240, 196, 55, 90), 5)

    dxDrawText(string.format("%d%%", progress * 100), guiInfo.x + 10/zoom, guiInfo.y + 40/zoom, guiInfo.x + guiInfo.w - 20/zoom, guiInfo.y + 70/zoom, tocolor(220, 220, 220, 255), 1/zoom, guiInfo.fonts.small, "center", "center")

    dxDrawText("Gösterge dolduğunda genişleme sona erecek.", guiInfo.x, guiInfo.y + 70/zoom, guiInfo.x + guiInfo.w, guiInfo.y + guiInfo.h, tocolor(170, 170, 170, 255), 1/zoom, guiInfo.fonts.small, "center", "center")
end;

enableProgressBar = function()
    p.tick = getTickCount();

    if (getTickCount()-p.tick) > 5000 then
        fadeCamera(true)
        removeEventHandler("onClientRender", root, progressBarRender);
    else
        progress = interpolateBetween(0, 0, 0, 100, 0, 0, (getTickCount()-p.tick)/5000, "Linear");

        addEventHandler('onClientRender', root, progressBarRender);

        fadeCamera(true);
    end;

    --addEventHandler('onClientRender', root, progressBarRender);
end;
addEvent('spreader:enableProgress', true);
addEventHandler('spreader:enableProgress', root, enableProgressBar);

disableProgressBar = function()
    removeEventHandler('onClientRender', root, progressBarRender);
end;
addEvent('spreader:disableProgress', true);
addEventHandler('spreader:disableProgress', root, disableProgressBar);

enableSound = function(x, y, z)
    local xx, yy, zz = x, y, z;
    sound = playSound3D('files/sounds/spreader.mp3', xx, yy, zz, false);
    setSoundVolume(sound, 30);
    setSoundMaxDistance(sound, 15);
end;
addEvent('spreader:enableSound', true);
addEventHandler('spreader:enableSound', resourceRoot, enableSound);

disableSound = function()
    setSoundVolume(sound, 0);
    stopSound(sound);
end;
addEvent('spreader:disableSound', true);
addEventHandler('spreader:disableSound', resourceRoot, disableSound);

enableSpreader = function()
    if not canRemoveDoor() then return end

	if (element) then
		if (getElementType(element) == 'vehicle') and (getComponentID(element)) then
			local model = getVehicleName(element);

			triggerServerEvent('spreader:enable', localPlayer, tonumber(getComponentID(element)));

			--unbindKey('e', 'down', enableSpreader);

			--[[
			local componentID = getComponentID(element);
			if (componentID == 0) then
				outputChatBox('maska')
			elseif (componentID == 1) then
				outputChatBox('bagaznik')
			elseif (componentID == 2) then
				outputChatBox('lewe przednie drzwi')
			elseif (componentID == 3) then
				outputChatBox('prawe przednie drzwi')
			elseif (componentID == 4) then
				outputChatBox('lewe tylne drzwi')
			elseif (componentID == 5) then
				outputChatBox('prawe tylne drzwi')
			end;
			]]
		end;
	end;
end;

renderSpreader = function()
	element = getPedTarget(localPlayer);
end;

loadSpreader = function()
	addEventHandler('onClientRender', root, renderSpreader);

	bindKey('x', 'down', enableSpreader);
end;
loadSpreader();

-- Xantris functions
function canRemoveDoor()
    local plrModel = getElementModel(localPlayer)
    if plrModel ~= 278 and plrModel ~= 277 then return false, false end

    local weapons = getElementData(localPlayer, "fakeWeapons")
    if weapons then
        local have = false
        for i, v in pairs(weapons) do
            if v == "dRemove" then
                return true
            end
        end
    end
    return false
end

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

engineImportTXD(engineLoadTXD("files/models/rozpieracz.txd"), 2881);
engineReplaceModel(engineLoadDFF("files/models/rozpieracz.dff", 2881), 2881);
--engineReplaceCOL(engineLoadCOL("files/models/rozpieracz.col"), 2881);

setElementData(localPlayer, 'rozpieranie', false);