local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

settings = {
    alpha = 0,
    hudSpeedAnim = 500,
    minimapOrder = true,
    characterDescVisible = true,
    windRoseVisible = true,
}
GPS = {}

weaponWithoutAmmo = {
    [1] = true,
    [2] = true,
    [3] = true,
    [4] = true,
    [5] = true,
    [6] = true,
    [7] = true,
    [8] = true,
    [9] = true,
    [23] = true,
    [41] = true,
    [42] = true,
    [43] = true,
}

vehicleSpeedometerData = {
    standard = {
		x = sx - 380/zoom,
		y = sy - 370/zoom,
		w = 380/zoom,
		h = 380/zoom,

		alpha = 0,
		startRot = -151,
		maxRot = 100,
		speedDowngrade = 0.84,

		mileageHeight = 240,

        bg = "files/images/speedo/speedo.png",
        bgRed = "files/images/speedo/speedoRed.png",
        needle = "files/images/speedo/needle.png",
    },

    old = {
		x = (sx - 614/zoom)/2,
		y = sy - 191/zoom,
		w = 614/zoom,
        h = 141/zoom,

        fuel = {
            x = (sx - 614/zoom)/2 - 60/zoom,
            y = sy - 100/zoom,
        },

        maxRot = 27,
        minRot = -26.4,
    },

    super = {
		x = sx - 350/zoom - 15/zoom,
		y = sy - 350/zoom - 15/zoom,
		w = 350/zoom,
        h = 350/zoom,

        fuel = {
            x = (sx - 614/zoom)/2 - 60/zoom,
            y = sy - 100/zoom,
        },

        maxRot = 268,
        minRot = -20,
    },

    motorbike = {
		x = sx - 448/zoom - 15/zoom,
		y = sy - 300/zoom - 20/zoom,
		w = 448/zoom,
        h = 300/zoom,

        fuel = {
            x = (sx - 614/zoom)/2 - 60/zoom,
            y = sy - 100/zoom,
        },

        maxRot = 222,
        minRot = 6,
    },

    boat = {
		x = (sx - 380/zoom)/2,
		y = sy - 240/zoom,
		w = 380/zoom,
        h = 220/zoom,

        maxRot = 27,
        minRot = -26.4,
    },
}

vehicleSpeedometerTuningData = {
    standard = {
		x = (sx - 380/zoom)/2,
		y = (sy - 380/zoom)/2,
		w = 380/zoom,
		h = 380/zoom,

		alpha = 0,
		startRot = -151,
		maxRot = 100,
		speedDowngrade = 0.84,

		mileageHeight = 240,

        bg = "files/images/speedo/speedo.png",
        bgRed = "files/images/speedo/speedoRed.png",
        needle = "files/images/speedo/needle.png",
    },

    old = {
		x = (sx - 614/zoom)/2,
		y = (sy - 141/zoom)/2,
		w = 614/zoom,
        h = 141/zoom,

        fuel = {
            x = (sx - 614/zoom)/2 - 60/zoom,
            y = (sy - 141/zoom)/2 + 91/zoom,
        },

        maxRot = 27,
        minRot = -26.4,
    },

    super = {
		x = (sx - 350/zoom)/2,
		y = (sy - 350/zoom)/2,
		w = 350/zoom,
        h = 350/zoom,

        maxRot = 268,
        minRot = -20,
    },

    motorbike = {
		x = (sx - 448/zoom)/2,
		y = (sy - 300/zoom)/2,
		w = 448/zoom,
        h = 300/zoom,

        maxRot = 222,
        minRot = 6,
    },
}

vehicleSpeedometer = {
    [472] = "boat",
    [473] = "boat",
    [493] = "boat",
    [595] = "boat",
    [484] = "boat",
    [430] = "boat",
    [452] = "boat",
    [453] = "boat",
    [446] = "boat",
    [454] = "boat",

    [581] = "motorbike",
    [462] = "motorbike",
    [521] = "motorbike",
    [463] = "motorbike",
    [522] = "motorbike",
    [461] = "motorbike",
    [448] = "motorbike",
    [468] = "motorbike",
    [586] = "motorbike",
    [471] = "motorbike",

    [429] = "super",
    [541] = "super",
    [415] = "super",
    [480] = "super",
    [562] = "super",
    [565] = "super",
    [434] = "super",
    [494] = "super",
    [502] = "super",
    [503] = "super",
    [411] = "super",
    [559] = "super",
    [561] = "super",
    [560] = "super",
    [506] = "super",
    [451] = "super",
    [558] = "super",
    [555] = "super",
    [477] = "super",
    [402] = "super",
    [603] = "super",

    [410] = "old",
    [436] = "old",
    [467] = "old",
    [547] = "old",
    [466] = "old",
    [546] = "old",
    [404] = "old",
    [478] = "old",
    [418] = "old",
    [605] = "old",
    [422] = "old",
    [543] = "old",
    [449] = "old",
}

vehicleData = {
    -- Tram
    [449] = {capacity = 100, petrol = "p", trunkCapacity = 0},
    -- Vehicles
    [400] = {capacity = 75, petrol = "d", trunkCapacity = 50},
    [401] = {capacity = 50, petrol = "b", trunkCapacity = 20},
    [402] = {capacity = 60, petrol = "p", trunkCapacity = 15},
    [403] = {capacity = 150, petrol = "d", trunkCapacity = 0},
    [404] = {capacity = 50, petrol = "d", trunkCapacity = 40},
    [405] = {capacity = 50, petrol = "b", trunkCapacity = 30},
    [407] = {capacity = 120, petrol = "d", trunkCapacity = 0},
    [408] = {capacity = 120, petrol = "d", trunkCapacity = 0},
    [409] = {capacity = 80, petrol = "b", trunkCapacity = 10},
    [410] = {capacity = 45, petrol = "d", trunkCapacity = 15},
    [411] = {capacity = 70, petrol = "p", trunkCapacity = 10},
    [412] = {capacity = 65, petrol = "b", trunkCapacity = 30},
    [413] = {capacity = 70, petrol = "d", trunkCapacity = 85},
    [414] = {capacity = 70, petrol = "d", trunkCapacity = 0},
    [415] = {capacity = 65, petrol = "p", trunkCapacity = 15},
    [416] = {capacity = 80, petrol = "d", trunkCapacity = 0},
    [418] = {capacity = 70, petrol = "d", trunkCapacity = 60},
    [419] = {capacity = 55, petrol = "b", trunkCapacity = 20},
    [420] = {capacity = 50, petrol = "b", trunkCapacity = 0},
    [421] = {capacity = 50, petrol = "d", trunkCapacity = 30},
    [422] = {capacity = 60, petrol = "d", trunkCapacity = 40},
    [423] = {capacity = 70, petrol = "d", trunkCapacity = 0},
    [424] = {capacity = 45, petrol = "b", trunkCapacity = 10},
    [426] = {capacity = 50, petrol = "b", trunkCapacity = 35},
    [427] = {capacity = 80, petrol = "d", trunkCapacity = 0},
    [428] = {capacity = 80, petrol = "d", trunkCapacity = 0},
    [429] = {capacity = 70, petrol = "p", trunkCapacity = 10},
    [431] = {capacity = 150, petrol = "d", trunkCapacity = 0},
    [432] = {capacity = 250, petrol = "d", trunkCapacity = 0},
    [433] = {capacity = 150, petrol = "d", trunkCapacity = 0},
    [434] = {capacity = 50, petrol = "p", trunkCapacity = 10},
    [436] = {capacity = 50, petrol = "b", trunkCapacity = 15},
    [437] = {capacity = 150, petrol = "d", trunkCapacity = 0},
    [438] = {capacity = 50, petrol = "b", trunkCapacity = 0},
    [439] = {capacity = 60, petrol = "p", trunkCapacity = 20},
    [440] = {capacity = 70, petrol = "d", trunkCapacity = 0},
    [442] = {capacity = 50, petrol = "d", trunkCapacity = 45},
    [443] = {capacity = 150, petrol = "d", trunkCapacity = 0},
    [445] = {capacity = 50, petrol = "b", trunkCapacity = 30},
    [451] = {capacity = 70, petrol = "p", trunkCapacity = 10},
    [455] = {capacity = 120, petrol = "d", trunkCapacity = 0},
    [456] = {capacity = 70, petrol = "d", trunkCapacity = 0},
    [457] = {capacity = 30, petrol = "b", trunkCapacity = 5},
    [458] = {capacity = 50, petrol = "b", trunkCapacity = 40},
    [459] = {capacity = 70, petrol = "d", trunkCapacity = 0},
    [466] = {capacity = 55, petrol = "p", trunkCapacity = 30},
    [467] = {capacity = 55, petrol = "p", trunkCapacity = 30},
    [470] = {capacity = 70, petrol = "d", trunkCapacity = 0},
    [474] = {capacity = 70, petrol = "p", trunkCapacity = 20},
    [475] = {capacity = 60, petrol = "p", trunkCapacity = 20},
    [477] = {capacity = 70, petrol = "p", trunkCapacity = 10},
    [478] = {capacity = 60, petrol = "d", trunkCapacity = 35},
    [479] = {capacity = 70, petrol = "d", trunkCapacity = 40},
    [480] = {capacity = 60, petrol = "p", trunkCapacity = 15},
    [482] = {capacity = 70, petrol = "d", trunkCapacity = 55},
    [483] = {capacity = 70, petrol = "d", trunkCapacity = 50},
    [485] = {capacity = 40, petrol = "d", trunkCapacity = 0},
    [486] = {capacity = 100, petrol = "d", trunkCapacity = 0},
    [489] = {capacity = 70, petrol = "d", trunkCapacity = 35},
    [490] = {capacity = 70, petrol = "d", trunkCapacity = 0},
    [491] = {capacity = 60, petrol = "p", trunkCapacity = 20},
    [492] = {capacity = 55, petrol = "b", trunkCapacity = 30},
    [494] = {capacity = 70, petrol = "p", trunkCapacity = 0},
    [495] = {capacity = 80, petrol = "b", trunkCapacity = 30},
    [496] = {capacity = 60, petrol = "b", trunkCapacity = 25},
    [498] = {capacity = 70, petrol = "d", trunkCapacity = 0},
    [499] = {capacity = 70, petrol = "d", trunkCapacity = 0},
    [500] = {capacity = 50, petrol = "b", trunkCapacity = 40},
    [502] = {capacity = 70, petrol = "p", trunkCapacity = 0},
    [503] = {capacity = 70, petrol = "p", trunkCapacity = 0},
    [504] = {capacity = 60, petrol = "b", trunkCapacity = 0},
    [505] = {capacity = 70, petrol = "d", trunkCapacity = 35},
    [506] = {capacity = 70, petrol = "p", trunkCapacity = 10},
    [507] = {capacity = 60, petrol = "b", trunkCapacity = 30},
    [508] = {capacity = 70, petrol = "d", trunkCapacity = 75},
    [514] = {capacity = 150, petrol = "d", trunkCapacity = 0},
    [515] = {capacity = 150, petrol = "d", trunkCapacity = 0},
    [516] = {capacity = 60, petrol = "b", trunkCapacity = 30},
    [517] = {capacity = 55, petrol = "b", trunkCapacity = 25},
    [518] = {capacity = 60, petrol = "p", trunkCapacity = 20},
    [524] = {capacity = 100, petrol = "d", trunkCapacity = 0},
    [525] = {capacity = 70, petrol = "d", trunkCapacity = 0},
    [526] = {capacity = 55, petrol = "p", trunkCapacity = 20},
    [527] = {capacity = 60, petrol = "b", trunkCapacity = 15},
    [528] = {capacity = 60, petrol = "b", trunkCapacity = 0},
    [529] = {capacity = 65, petrol = "p", trunkCapacity = 20},
    [530] = {capacity = 40, petrol = "d", trunkCapacity = 0},
    [531] = {capacity = 80, petrol = "d", trunkCapacity = 0},
    [532] = {capacity = 150, petrol = "d", trunkCapacity = 0},
    [533] = {capacity = 50, petrol = "b", trunkCapacity = 20},
    [534] = {capacity = 50, petrol = "b", trunkCapacity = 20},
    [535] = {capacity = 80, petrol = "p", trunkCapacity = 20},
    [536] = {capacity = 65, petrol = "p", trunkCapacity = 20},
    [540] = {capacity = 50, petrol = "b", trunkCapacity = 20},
    [541] = {capacity = 70, petrol = "p", trunkCapacity = 10},
    [542] = {capacity = 65, petrol = "p", trunkCapacity = 20},
    [543] = {capacity = 70, petrol = "d", trunkCapacity = 35},
    [544] = {capacity = 120, petrol = "d", trunkCapacity = 0},
    [545] = {capacity = 50, petrol = "p", trunkCapacity = 10},
    [546] = {capacity = 60, petrol = "b", trunkCapacity = 20},
    [547] = {capacity = 60, petrol = "p", trunkCapacity = 25},
    [549] = {capacity = 60, petrol = "b", trunkCapacity = 20},
    [550] = {capacity = 60, petrol = "p", trunkCapacity = 25},
    [551] = {capacity = 60, petrol = "b", trunkCapacity = 25},
    [552] = {capacity = 70, petrol = "d", trunkCapacity = 0},
    [554] = {capacity = 70, petrol = "d", trunkCapacity = 50},
    [555] = {capacity = 60, petrol = "p", trunkCapacity = 10},
    [558] = {capacity = 60, petrol = "b", trunkCapacity = 10},
    [559] = {capacity = 70, petrol = "p", trunkCapacity = 10},
    [560] = {capacity = 70, petrol = "p", trunkCapacity = 30},
    [561] = {capacity = 55, petrol = "b", trunkCapacity = 40},
    [562] = {capacity = 60, petrol = "p", trunkCapacity = 15},
    [565] = {capacity = 55, petrol = "b", trunkCapacity = 15},
    [566] = {capacity = 55, petrol = "b", trunkCapacity = 30},
    [567] = {capacity = 55, petrol = "b", trunkCapacity = 20},
    [568] = {capacity = 40, petrol = "p", trunkCapacity = 0},
    [571] = {capacity = 5, petrol = "p", trunkCapacity = 0},
    [572] = {capacity = 10, petrol = "p", trunkCapacity = 0},
    [574] = {capacity = 40, petrol = "d", trunkCapacity = 0},
    [575] = {capacity = 65, petrol = "b", trunkCapacity = 15},
    [576] = {capacity = 65, petrol = "b", trunkCapacity = 20},
    [578] = {capacity = 70, petrol = "d", trunkCapacity = 0},
    [579] = {capacity = 65, petrol = "d", trunkCapacity = 40},
    [580] = {capacity = 60, petrol = "b", trunkCapacity = 30},
    [582] = {capacity = 70, petrol = "d", trunkCapacity = 0},
    [583] = {capacity = 45, petrol = "d", trunkCapacity = 0},
    [585] = {capacity = 60, petrol = "b", trunkCapacity = 25},
    [587] = {capacity = 60, petrol = "p", trunkCapacity = 20},
    [588] = {capacity = 70, petrol = "d", trunkCapacity = 0},
    [589] = {capacity = 60, petrol = "b", trunkCapacity = 20},
    [596] = {capacity = 70, petrol = "p", trunkCapacity = 0},
    [597] = {capacity = 70, petrol = "p", trunkCapacity = 0},
    [598] = {capacity = 70, petrol = "p", trunkCapacity = 0},
    [599] = {capacity = 70, petrol = "d", trunkCapacity = 0},
    [600] = {capacity = 60, petrol = "d", trunkCapacity = 30},
    [601] = {capacity = 150, petrol = "d", trunkCapacity = 0},
    [602] = {capacity = 70, petrol = "p", trunkCapacity = 20},
    [603] = {capacity = 70, petrol = "p", trunkCapacity = 20},
    [604] = {capacity = 50, petrol = "d", trunkCapacity = 0},
    [605] = {capacity = 60, petrol = "d", trunkCapacity = 0},
    [609] = {capacity = 70, petrol = "d", trunkCapacity = 0},

    -- Motorbikes
    [448] = {capacity = 15, petrol = "p", trunkCapacity = 0},
    [461] = {capacity = 20, petrol = "p", trunkCapacity = 5},
    [462] = {capacity = 15, petrol = "p", trunkCapacity = 5},
    [463] = {capacity = 25, petrol = "p", trunkCapacity = 5},
    [468] = {capacity = 15, petrol = "p", trunkCapacity = 5},
    [521] = {capacity = 20, petrol = "p", trunkCapacity = 5},
    [522] = {capacity = 20, petrol = "p", trunkCapacity = 5},
    [523] = {capacity = 25, petrol = "p", trunkCapacity = 0},
    [581] = {capacity = 20, petrol = "p", trunkCapacity = 0},
    [586] = {capacity = 30, petrol = "p", trunkCapacity = 10},

    -- Quad
    [471] = {capacity = 15, petrol = "p", trunkCapacity = 10},

    -- Monster Truck
    [406] = {capacity = 500, petrol = "d", trunkCapacity = 0},
    [444] = {capacity = 80, petrol = "d", trunkCapacity = 0},
    [556] = {capacity = 80, petrol = "d", trunkCapacity = 0},
    [557] = {capacity = 80, petrol = "d", trunkCapacity = 0},
    [573] = {capacity = 100, petrol = "d", trunkCapacity = 0},

    -- Boat
    [430] = {capacity = 150, petrol = "p", trunkCapacity = 0},
    [446] = {capacity = 250, petrol = "p", trunkCapacity = 0},
    [452] = {capacity = 85, petrol = "p", trunkCapacity = 0},
    [453] = {capacity = 200, petrol = "d", trunkCapacity = 0},
    [454] = {capacity = 400, petrol = "d", trunkCapacity = 0},
    [472] = {capacity = 100, petrol = "d", trunkCapacity = 0},
    [473] = {capacity = 50, petrol = "p", trunkCapacity = 0},
    [484] = {capacity = 400, petrol = "d", trunkCapacity = 0},
    [493] = {capacity = 200, petrol = "p", trunkCapacity = 0},
    [595] = {capacity = 200, petrol = "d", trunkCapacity = 0},

    -- Helicopter
    [417] = {capacity = 400, petrol = "d", trunkCapacity = 0},
    [425] = {capacity = 250, petrol = "d", trunkCapacity = 0},
    [447] = {capacity = 150, petrol = "d", trunkCapacity = 0},
    [469] = {capacity = 150, petrol = "d", trunkCapacity = 0},
    [487] = {capacity = 200, petrol = "d", trunkCapacity = 0},
    [488] = {capacity = 200, petrol = "d", trunkCapacity = 0},
    [497] = {capacity = 200, petrol = "d", trunkCapacity = 0},
    [548] = {capacity = 500, petrol = "d", trunkCapacity = 0},
    [563] = {capacity = 400, petrol = "d", trunkCapacity = 0},

    -- Plane
    [460] = {capacity = 200, petrol = "d", trunkCapacity = 0},
    [476] = {capacity = 350, petrol = "d", trunkCapacity = 0},
    [511] = {capacity = 1000, petrol = "d", trunkCapacity = 0},
    [512] = {capacity = 500, petrol = "d", trunkCapacity = 0},
    [513] = {capacity = 150, petrol = "d", trunkCapacity = 0},
    [519] = {capacity = 500, petrol = "d", trunkCapacity = 0},
    [520] = {capacity = 500, petrol = "d", trunkCapacity = 0},
    [539] = {capacity = 100, petrol = "d", trunkCapacity = 0},
    [553] = {capacity = 3000, petrol = "d", trunkCapacity = 0},
    [577] = {capacity = 10000, petrol = "d", trunkCapacity = 0},
    [592] = {capacity = 3500, petrol = "d", trunkCapacity = 0},
    [593] = {capacity = 150, petrol = "d", trunkCapacity = 0},
}

function getVehicleCapacity(model)
    if not vehicleData[model] then return false end
    return vehicleData[model].capacity
end

function getVehiclePetrolType(model)
    if not vehicleData[model] then return false end
    return vehicleData[model].petrol
end

function getVehicleTrunkCapacity(model)
    if not vehicleData[model] then return false end
    return vehicleData[model].trunkCapacity
end