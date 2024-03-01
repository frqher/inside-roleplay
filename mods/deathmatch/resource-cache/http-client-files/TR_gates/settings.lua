gateInfo = {
    [976] = {
        offset = Vector3(4, 0, 0),
        openOffset = Vector3(0, 0, 2),
        openRotOffset = Vector3(0, 90, 0),

        openTime = 5000,
        closeTime = 5000,
    },
    [3055] = {
        offset = Vector3(4, 0, 0),
        openOffset = Vector3(0, -2, 1.9),
        openRotOffset = Vector3(90, 0, 0),

        openTime = 5000,
        closeTime = 5000,
    },
    [10184] = {
        offset = Vector3(4, 0, 0),
        openOffset = Vector3(0, 0, 2),
        openRotOffset = Vector3(0, 90, 0),

        openTime = 5000,
        closeTime = 5000,
    },
    [16775] = {
        offset = Vector3(6, 0, 0),
        openOffset = Vector3(0, 0, 2.8),
        openRotOffset = Vector3(90, 0, 0),

        openTime = 15000,
        closeTime = 15000,
    },

    -- Test fire
    [2909] = {
        offset = Vector3(0, 0, 0),
        openOffset = Vector3(0, -8, 0),
        openRotOffset = Vector3(0, 0, 0),

        openTime = 5000,
        closeTime = 5000,
    },

    [1874] = {
        offset = Vector3(4, 0, 0),
        openOffset = Vector3(0, -2, 1.9),
        openRotOffset = Vector3(90, 0, 0),

        openTime = 5000,
        closeTime = 5000,
    },

    [9823] = {
        offset = Vector3(4, 0, 0),
        openOffset = Vector3(2, 0, 1.9),
        openRotOffset = Vector3(0, 90, 0),

        openTime = 5000,
        closeTime = 5000,
    },
    [5422] = {
        offset = Vector3(4, 0, 0),
        openOffset = Vector3(2, 0, 1.9),
        openRotOffset = Vector3(0, 90, 0),

        openTime = 5000,
        closeTime = 5000,
    },
    [1553] = {
        offset = Vector3(4, 0, 0),
        openOffset = Vector3(2, 0, 1.9),
        openRotOffset = Vector3(0, 90, 0),

        openTime = 5000,
        closeTime = 5000,
    },

    [968] = {
        offset = Vector3(0, 0, 0),
        openOffset = Vector3(0, 0, 0),
        openRotOffset = Vector3(0, -90, 0),

        openTime = 900,
        closeTime = 2500,
    },
}

gates = {
    -- Medic
    {
        model = 9823,
        pos = Vector3(2002.300390625, -1424.400390625, 11.400000190735),
        rot = Vector3(0, 0, 90),
        scale = 1.05,

        permission = {
            type = "fraction",
            value = "2",
        },
    },

    -- Test fire
    {
        model = 2909,
        pos = Vector3(1838.69, -1773.32, 12.74),
        rot = Vector3(0, 0, 270),
    },

    -- Fire Dept LS
    {
        model = 1874,
        pos = Vector3(1893.2690429688, -1773.8000488281, 14.39999961853),
        rot = Vector3(0, 0, 0),
        permission = {
            type = "fraction",
            value = "3",
        },
    },
    {
        model = 1874,
        pos = Vector3(1887.5400390625, -1773.7998046875, 14.39999961853),
        rot = Vector3(0, 0, 0),
        permission = {
            type = "fraction",
            value = "3",
        },
    },
    {
        model = 1874,
        pos = Vector3(1881.9449462891, -1772.8199462891, 14.39999961853),
        rot = Vector3(0, 0, 0),
        permission = {
            type = "fraction",
            value = "3",
        },
    },
    {
        model = 1874,
        pos = Vector3(1893.2690429688, -1788.0999755859, 14.39999961853),
        rot = Vector3(0, 0, 180),
        permission = {
            type = "fraction",
            value = "3",
        },
    },
    {
        model = 1874,
        pos = Vector3(1887.5400390625, -1788.099609375, 14.39999961853),
        rot = Vector3(0, 0, 180),
        permission = {
            type = "fraction",
            value = "3",
        },
    },
    {
        model = 1874,
        pos = Vector3(1881.9449462891, -1787.1400146484, 14.39999961853),
        rot = Vector3(0, 0, 180),
        permission = {
            type = "fraction",
            value = "3",
        },
    },
    {
        model = 1874,
        pos = Vector3(1856.6600341797, -1772.8199462891, 14.39999961853),
        rot = Vector3(0, 0, 0),
        permission = {
            type = "fraction",
            value = "3",
        },
    },
    {
        model = 1874,
        pos = Vector3(1849.9499511719, -1772.8203125, 14.39999961853),
        rot = Vector3(0, 0, 0),
        permission = {
            type = "fraction",
            value = "3",
        },
    },
    {
        model = 1874,
        pos = Vector3(1849.9501953125, -1787.9699707031, 14.39999961853),
        rot = Vector3(0, 0, 180),
        permission = {
            type = "fraction",
            value = "3",
        },
    },
    {
        model = 1874,
        pos = Vector3(1856.6600341797, -1787.9699707031, 14.39999961853),
        rot = Vector3(0, 0, 180),
        permission = {
            type = "fraction",
            value = "3",
        },
    },

    -- Fire Dept SF
    {
        model = 5422,
        pos = Vector3(-2324.8000488281, -84.199996948242, 36.299999237061),
        rot = Vector3(0, 0, 0),
        permission = {
            type = "fraction",
            value = "3",
        },
    },
    {
        model = 5422,
        pos = Vector3(-2324.8000488281, -91.099998474121, 36.299999237061),
        rot = Vector3(0, 0, 0),
        permission = {
            type = "fraction",
            value = "3",
        },
    },
    {
        model = 5422,
        pos = Vector3(-2324.8000488281, -98.099998474121, 36.299999237061),
        rot = Vector3(0, 0, 0),
        permission = {
            type = "fraction",
            value = "3",
        },
    },
    {
        model = 5422,
        pos = Vector3(-2334.1000976563, -107.40000152588, 36.299999237061),
        rot = Vector3(0, 0, 270),
        permission = {
            type = "fraction",
            value = "3",
        },
    },
    {
        model = 5422,
        pos = Vector3(-2341.1000976563, -107.40000152588, 36.299999237061),
        rot = Vector3(0, 0, 270),
        permission = {
            type = "fraction",
            value = "3",
        },
    },
    {
        model = 5422,
        pos = Vector3(-2348.1000976563, -107.40000152588, 36.299999237061),
        rot = Vector3(0, 0, 270),
        permission = {
            type = "fraction",
            value = "3",
        },
    },
    {
        model = 5422,
        pos = Vector3(-2355.1000976563, -107.40000152588, 36.299999237061),
        rot = Vector3(0, 0, 270),
        permission = {
            type = "fraction",
            value = "3",
        },
    },


    -- Fire dept LV
    {
        model = 1553,
        pos = Vector3(2492.2099609375,1224.4000244141,11.920000076294),
        rot = Vector3(0, 0, 270),
        permission = {
            type = "fraction",
            value = "3",
        },
    },
    {
        model = 1553,
        pos = Vector3(2497.919921875,1224.4000244141,11.920000076294),
        rot = Vector3(0, 0, 270),
        permission = {
            type = "fraction",
            value = "3",
        },
    },
    {
        model = 1553,
        pos = Vector3(2503.6201171875,1224.4000244141,11.920000076294),
        rot = Vector3(0, 0, 270),
        permission = {
            type = "fraction",
            value = "3",
        },
    },
    {
        model = 1553,
        pos = Vector3(2492.1999511719,1203.4000244141,11.89999961853),
        rot = Vector3(0, 0, 90),
        permission = {
            type = "fraction",
            value = "3",
        },
    },
    {
        model = 1553,
        pos = Vector3(2497.8999023438,1203.4000244141,11.89999961853),
        rot = Vector3(0, 0, 90),
        permission = {
            type = "fraction",
            value = "3",
        },
    },
    {
        model = 1553,
        pos = Vector3(2503.6000976562,1203.4000244141,11.89999961853),
        rot = Vector3(0, 0, 90),
        permission = {
            type = "fraction",
            value = "3",
        },
    },
    {
        model = 1553,
        pos = Vector3(2509.3200683594,1203.5,11.89999961853),
        rot = Vector3(0, 0, 90),
        permission = {
            type = "fraction",
            value = "3",
        },
    },
    {
        model = 1553,
        pos = Vector3(2516.1000976562,1228.4000244141,11.89999961853),
        rot = Vector3(0, 0, 180),
        permission = {
            type = "fraction",
            value = "3",
        },
    },
    {
        model = 1553,
        pos = Vector3(2516.1000976562,1235.5,11.89999961853),
        rot = Vector3(0, 0, 180),
        permission = {
            type = "fraction",
            value = "3",
        },
    },
    {
        model = 1553,
        pos = Vector3(2460.8000488281,1224.4000244141,11.89999961853),
        rot = Vector3(0, 0, 270),
        permission = {
            type = "fraction",
            value = "3",
        },
    },
    {
        model = 1553,
        pos = Vector3(2455.1999511719,1224.4000244141,11.89999961853),
        rot = Vector3(0, 0, 270),
        permission = {
            type = "fraction",
            value = "3",
        },
    },
    {
        model = 1553,
        pos = Vector3(2449.6999511719,1224.4000244141,11.89999961853),
        rot = Vector3(0, 0, 270),
        permission = {
            type = "fraction",
            value = "3",
        },
    },
    {
        model = 1553,
        pos = Vector3(2444.1000976562,1224.4000244141,11.89999961853),
        rot = Vector3(0, 0, 270),
        permission = {
            type = "fraction",
            value = "3",
        },
    },
    {
        model = 1553,
        pos = Vector3(2460.8000488281,1203.4000244141,11.89999961853),
        rot = Vector3(0, 0, 90),
        permission = {
            type = "fraction",
            value = "3",
        },
    },
    {
        model = 1553,
        pos = Vector3(2455.2199707031,1203.4000244141,11.89999961853),
        rot = Vector3(0, 0, 90),
        permission = {
            type = "fraction",
            value = "3",
        },
    },
    {
        model = 1553,
        pos = Vector3(2449.6550292969,1203.4000244141,11.89999961853),
        rot = Vector3(0, 0, 90),
        permission = {
            type = "fraction",
            value = "3",
        },
    },
    {
        model = 1553,
        pos = Vector3(2444.1101074219,1203.4000244141,11.89999961853),
        rot = Vector3(0, 0, 90),
        permission = {
            type = "fraction",
            value = "3",
        },
    },

}
