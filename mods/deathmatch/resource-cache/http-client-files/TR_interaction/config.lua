disabledList = {}

avaliableObjects = {
    [1280] = "Bank",
    [1711] = "Koltuk",
    [2309] = "Sandalye",
    [2120] = "Sandalye",
    [1721] = "Sandalye",
    [1714] = "Sandalye",
    [2310] = "Sandalye",
    [2356] = "Sandalye",
    [2121] = "Sandalye",
    [1753] = "Kanepe",
    [1776] = "Atıştırmalık Otomat",
    [955] = "İçecek Otomatı",
    [1775] = "İçecek Otomatı",
    [2943] = "ATM",
    [3465] = "Dolum Makinesi",
    [14782] = "Giyim Dolabı",
    [2200] = "Giyim Dolabı",
    [1211] = "Hidrant",
    [2190] = "Bilgisayar",
    [964] = "Ekipman Kutusu",
    [1936] = "Sedye",
    [1938] = "Sedye",

    [2627] = "Koşu Bandı",
    [2630] = "Egzersiz Bisikleti",
    [2629] = "Egzersiz Bankı",

    [2332] = "Eşya Kasası",
    [2991] = "Kutu Yığını",
    [2203] = "Saksı",
    [3001] = "Uyuşturucu Üretim Masası",
    [3002] = "Silah Üretim Masası",

    [1880] = "Petrol Vanası",
    [3931] = "Madencilik Duvarı",
    [1654] = "Dinamit Paketi",
}


weaponsSlots = {
	[3] = 1,
	[23] = 2,
	[24] = 2,
	[25] = 3,
	[31] = 5,
	[29] = 4,
	[44] = 11,
}


objectIcons = {
    [1280] = "bench",
    [1711] = "officechair",
    [2309] = "chair",
    [2120] = "chair",
    [1721] = "chair",
    [1714] = "chair",
    [2310] = "chair",
    [2356] = "chair",
    [2121] = "chair",
    [1753] = "couch",
    [1776] = "vending",
    [955] = "vending",
    [1775] = "vending",
    [2943] = "atm",
    [3465] = "fuel",
    [14782] = "shirt",
    [2200] = "shirt",
    [1211] = "hydrant",
    [2190] = "computer",
    [964] = "chest",
    [1936] = "stretcher",
    [1938] = "stretcher",
    [1880] = "valve",

    [2627] = "treadmill",
    [2629] = "benchpress",
    [2630] = "stationaryBike",

    [2332] = "safe",
    [2203] = "flowerPot",
    [3001] = "table",
    [3002] = "table",

    [3931] = "stone",
    [1654] = "dynamite",
}


withoutTrunk = {
    [411] = true, -- Infernus
    [530] = true, -- Forklift
    [443] = true, -- Packer
    [531] = true, -- Tracktor
    [570] = true, -- Dune
    [455] = true, -- Flatbed
    [432] = true, -- Rhino
    [601] = true, -- SWAT Turret
    [525] = true, -- Tow truck
    [431] = true, -- Bus
    [437] = true, -- Coach
    [485] = true, -- Baggy
    [433] = true, -- Barracks
    [568] = true, -- Bandito
    [424] = true, -- BF Injection
    [444] = true, -- Monster 1
    [556] = true, -- Monster 2
    [557] = true, -- Monster 3
    [571] = true, -- Kart
    [508] = true, -- Journey
    [434] = true, -- Hotknife
    [494] = true, -- Hotring Racer
    [503] = true, -- Hotring Racer 2
    [502] = true, -- Hotring Racer 3
    [451] = true, -- Turismo
    [477] = true, -- ZR 350
    [515] = true, -- Roadtrain
    [514] = true, -- Tanker
    [403] = true, -- Linerunner
    [588] = true, -- Hot dog
    [456] = true, -- Yankee

    -- Bikes
    [581] = true, -- Hotring Racer 3
    [509] = true, -- Turismo
    [481] = true, -- ZR 350
    [462] = true, -- Roadtrain
    [521] = true, -- Tanker
    [463] = true, -- Linerunner
    [510] = true, -- Hot dog
    [522] = true, -- Hot dog
    [461] = true, -- Hot dog
    [448] = true, -- Hot dog
    [468] = true, -- Hot dog
    [586] = true, -- Hot dog
    [510] = true, -- Hot dog

    [407] = true, -- Fire Truck
    [544] = true, -- Fire Truck Ladder
    [416] = true, -- Ambulance
}

withoutHood = {
    [530] = true, -- Forklift
    [570] = true, -- Dune
    [432] = true, -- Rhino
    [601] = true, -- SWAT Turret
    [431] = true, -- Bus
    [437] = true, -- Coach
    [485] = true, -- Baggy
    [568] = true, -- Bandito
    [424] = true, -- BF Injection
    [444] = true, -- Monster 1
    [556] = true, -- Monster 2
    [557] = true, -- Monster 3
    [571] = true, -- Kart
    [434] = true, -- Hotknife
    [588] = true, -- Hot dog

    [407] = true, -- Fire Truck
    [544] = true, -- Fire Truck Ladder
}

withoutRoof = {
    [536] = true, -- Blade
    [575] = true, -- Broadway
    [567] = true, -- Savanna
    [533] = true, -- Feltzer
    [480] = true, -- Commet
    [429] = true, -- Banshee
    [555] = true, -- Vindsor
    [506] = true, -- Super-GT
    [531] = true, -- Tractor
    [572] = true, -- Mower
    [485] = true, -- Baggage
    [471] = true, -- Quad
    [571] = true, -- Cart
    [424] = true, -- BF Injector
    [568] = true, -- Bandito
}