jobSettings = {
    name = "Tramvay Sürücüsü İşi",
    desc = "İş, San Fierro sokaklarında tramvay sürmekten oluşmaktadır. Rotanızdaki tüm duraklarda durmalı ve tüm yolcuların tramvaydan inip binmesini beklemelisiniz. Her yolcunun bilet alması gerektiği için onlardan bilet alacaksınız. Yolcuların iki farklı bilet türünden yararlandığını unutmayın. Dağıtırken karıştırmayın!",
    require = "Deneyim: 30 puan",
    earnings = "$3400",

    upgrades = {
        {
            name = "Daha Büyük Şehir",
            desc = "Bu yükseltme, duraklarda daha fazla yolcunun beklemesini sağlayacak.",
            price = 250,
            type = "people",
            additionalMoney = {20, 50}
        },
        {
            name = "Yeni Elektrikli Motorlar",
            desc = "Bu yükseltme, tramvayın daha hızlı hareket etmesini sağlayacak.",
            price = 500,
            type = "tram",
            additionalMoney = {300, 450}
        },
    },
}
function getJobDetails()
    return jobSettings
end




-- Stops
targetPoints = {
    {
        marker = Vector3(-2251.4287109375, 278.23046875, 35.1640625),
        npcs = {
            {
                pos = Vector3(-2259.9287109375, 281.734375, 35.387950897217),
                rot = 268,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-2260.064453125, 276.896484375, 35.387950897217),
                rot = 268,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-2260.015625, 275.1455078125, 35.387950897217),
                rot = 270,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-2260.3017578125, 277.70703125, 35.387950897217),
                rot = 287,
                anim = {"COP_AMBIENT", "Coplook_think"},
            },
            {
                pos = Vector3(-2260.021484375, 284.109375, 35.387950897217),
                rot = 270,
                anim = {"ped", "SEAT_idle"},
            },
        },
    },
    {
        marker = Vector3(-2251.9189453125, 123.6240234375, 35.171875),
        npcs = {
            {
                pos = Vector3(-2260.3369140625, 130.0556640625, 35.387950897217),
                rot = 270,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-2260.4560546875, 116.9091796875, 35.387950897217),
                rot = 266,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-2260.6005859375, 126.8525390625, 35.387950897217),
                rot = 268,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-2260.8740234375, 122.90625, 35.387950897217),
                rot = 301,
                anim = {"COP_AMBIENT", "Coplook_think"},
            },
        },
    },
    {
        marker = Vector3(-2166.7666015625, -14.75390625, 35.171875),
        npcs = {
            {
                pos = Vector3(-2158.8779296875, -16.8583984375, 35.387950897217),
                rot = 90,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-2159.052734375, -17.8798828125, 35.387950897217),
                rot = 90,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-2158.8876953125, -20.1240234375, 35.387950897217),
                rot = 90,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-2159.03515625, -21.1123046875, 35.387950897217),
                rot = 90,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-2159.0556640625, -12.05859375, 35.387950897217),
                rot = 90,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-2158.8544921875, -12.9130859375, 35.387950897217),
                rot = 90,
                anim = {"ped", "SEAT_idle"},
            },
        },
    },
    {
        marker = Vector3(-2006.6591796875, 210.0712890625, 27.5390625),
        npcs = {
            {
                pos = Vector3(-1997.6295166016, 210.79804992676, 27.787950515747),
                rot = 133,
                anim = {"COP_AMBIENT", "Coplook_think"},
            },
            {
                pos = Vector3(-1998.6363525391, 201.91914367676, 27.787950515747),
                rot = 42,
                anim = {"COP_AMBIENT", "Coplook_think"},
            },
            {
                pos = Vector3(-1997.9381103516, 212.55586242676, 27.787950515747),
                rot = 90,
                anim = {"ped", "SEAT_idle"},
            },
        },
    },
    {
        marker = Vector3(-2003.7734375, 451.140625, 35.015625),
        npcs = {
            {
                pos = Vector3(-1993.4208984375, 448.0654296875, 35.187950134277),
                rot = 90,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-1993.48046875, 445.5517578125, 35.187950134277),
                rot = 90,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-1993.396484375, 446.9873046875, 35.187950134277),
                rot = 90,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-1993.34765625, 452.6875, 35.187950134277),
                rot = 90,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-1993.4296875, 454.5048828125, 35.187950134277),
                rot = 90,
                anim = {"ped", "SEAT_idle"},
            },
        },
    },
    {
        marker = Vector3(-1856.828125, 603.3076171875, 35.015625),
        npcs = {
            {
                pos = Vector3(-1854.9833984375, 595.330078125, 35.187950134277),
                rot = 0,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-1860.734375, 595.2197265625, 35.187950134277),
                rot = 0,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-1859.14453125, 595.396484375, 35.187950134277),
                rot = 0,
                anim = {"ped", "SEAT_idle"},
            },
        },
    },
    {
        marker = Vector3(-1600.6201171875, 849.1611328125, 7.5390625),
        npcs = {
            {
                pos = Vector3(-1602.947265625, 862.306640625, 7.7879505157471),
                rot = 180,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-1596.7333984375, 859.9892578125, 7.7879505157471),
                rot = 151,
                anim = {"COP_AMBIENT", "Coplook_think"},
            },
            {
                pos = Vector3(-1601.19140625, 862.51171875, 7.7879505157471),
                rot = 194,
                anim = {"COP_AMBIENT", "Coplook_think"},
            },
        },
    },
    {
        marker = Vector3(-1863.2431640625, 849.1083984375, 35.025184631348),
        npcs = {
            {
                pos = Vector3(-1865.4724121094, 860.43103027344, 35.287952423096),
                rot = 180,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-1864.6198730469, 860.46423339844, 35.287952423096),
                rot = 180,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-1858.9694824219, 860.38220214844, 35.287952423096),
                rot = 180,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-1860.6911621094, 860.55798339844, 35.287952423096),
                rot = 180,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-1868.8415527344, 860.50622558594, 35.287952423096),
                rot = 180,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-1856.5251464844, 860.45739746094, 35.287952423096),
                rot = 180,
                anim = {"ped", "SEAT_idle"},
            },
        },
    },
    {
        marker = Vector3(-1676.7412109375, 921.173828125, 24.7421875),
        npcs = {
            {
                pos = Vector3(-1675.626953125, 907.685546875, 24.987949371338),
                rot = 0,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-1678.3740234375, 907.19140625, 24.987949371338),
                rot = 356,
                anim = {"COP_AMBIENT", "Coplook_think"},
            },
            {
                pos = Vector3(-1676.9013671875, 907.3740234375, 24.987949371338),
                rot = 28,
                anim = {"COP_AMBIENT", "Coplook_think"},
            },
            {
                pos = Vector3(-1680.4560546875, 907.8779296875, 24.987949371338),
                rot = 0,
                anim = {"ped", "SEAT_idle"},
            },
        },
    },
    {
        marker = Vector3(-1584.0126953125, 1068.44140625, 7.0390625),
        npcs = {
            {
                pos = Vector3(-1574.3879394531, 1066.1357421875, 7.1879506111145),
                rot = 90,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-1574.2958984375, 1065.2001953125, 7.1879506111145),
                rot = 90,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-1574.2783203125, 1071.548828125, 7.1879506111145),
                rot = 90,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-1574.34375, 1069.8984375, 7.1879506111145),
                rot = 90,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-1574.2861328125, 1074.1591796875, 7.1879506111145),
                rot = 90,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-1574.3759765625, 1062.6474609375, 7.1879506111145),
                rot = 90,
                anim = {"ped", "SEAT_idle"},
            },
        },
    },
    {
        marker = Vector3(-1630.455078125, 1243.3603515625, 7.0468425750732),
        npcs = {
            {
                pos = Vector3(-1621.4580078125, 1249.26171875, 7.0468425750732),
                rot = 132,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-1620.171875, 1248.068359375, 7.1879506111145),
                rot = 132,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-1617.7861328125, 1245.599609375, 7.187950611114),
                rot = 132,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-1622.9560546875, 1251.13671875, 7.1879506111145),
                rot = 161,
                anim = {"COP_AMBIENT", "Coplook_think"},
            },
            {
                pos = Vector3(-1625.1376953125, 1253.150390625, 7.1879506111145),
                rot = 132,
                anim = {"ped", "SEAT_idle"},
            },
        },
    },
    {
        marker = Vector3(-1968.5087890625, 1307.90625, 7.0390625),
        npcs = {
            {
                pos = Vector3(-1970.0244140625, 1319.021484375, 7.2879505157471),
                rot = 171,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-1961.9847412109, 1319.1882324219, 7.2879505157471),
                rot = 171,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-1966.1497802734, 1319.0163574219, 7.2879505157471),
                rot = 171,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-1973.1566162109, 1319.0612792969, 7.2879505157471),
                rot = 171,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-1974.9661865234, 1319.0476074219, 7.287950515747),
                rot = 171,
                anim = {"ped", "SEAT_idle"},
            },
        },
    },
    {
        marker = Vector3(-2264.9248046875, 886.396484375, 66.5),
        npcs = {
            {
                pos = Vector3(-2262.1640625, 884.0849609375, 66.587951660156),
                rot = 89,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-2262.1845703125, 892.474609375, 66.37574005127),
                rot = 89,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-2262.1748046875, 885.9228515625, 66.587951660156),
                rot = 51,
                anim = {"COP_AMBIENT", "Coplook_think"},
            },
            {
                pos = Vector3(-2262.1953125, 880.630859375, 66.587951660156),
                rot = 89,
                anim = {"ped", "SEAT_idle"},
            },
        },
    },
    {
        marker = Vector3(-2265.0634765625, 648.4423828125, 49.296875),
        npcs = {
            {
                pos = Vector3(-2262.1689453125, 645.8056640625, 49.296875),
                rot = 89,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-2262.1142578125, 650.9013671875, 49.296875),
                rot = 89,
                anim = {"ped", "SEAT_idle"},
            },
            {
                pos = Vector3(-2262.1318359375, 647.6220703125, 49.296875),
                rot = 89,
                anim = {"ped", "SEAT_idle"},
            },
        },
    },
}