jobSettings = {
    name = "Konteyner Taşıma",
    desc = "İş, yerel depodan müşteri firmalara konteyner taşımak üzerine kuruludur.\nYük en iyi durumda teslim edilmelidir, aksi takdirde tazminat maliyeti maaşınızdan kesilecektir. Uzun rotalar daha fazla ücretlidir.",
    require = "C sınıfı ehliyet\nDeneyim: 130 puan",
    earnings = "$4300",

    upgrades = {
        {
            name = "Zırhlı Yük",
            desc = "Çarpışmalar sırasında yük daha az hasar alır.",
            price = 15,
            type = "shield",
        },
        {
            name = "Daha Fazla Konfor",
            desc = "Uzun mesafe rotaları açılır.",
            price = 50,
            type = "longDistance",
            additionalMoney = {20, 50},
        },
        {
            name = "Hız Artışı",
            desc = "Kamyonun hızını artırır.",
            price = 100,
            type = "speedometer",
            additionalMoney = {300, 400},
        },
        {
            name = "Değerli Yük",
            desc = "Daha değerli yük taşıyabilirsiniz.",
            price = 150,
            type = "watch",
            additionalMoney = {450, 550},
        },
    },
}

function getJobDetails()
    return jobSettings
end




nearPoints = {
    {-1857.4814453125, 1420.255859375, 7.176357269287, 0},
    {-1327.3388671875, 447.564453125, 7.1875, 180},
    {-52.078125, -1137.3076171875, 1.078125, 249},
    {-2094.787109375, -2243.9609375, 30.625053405762, 318},
    {-304.4375, 2680.466796875, 62.629875183105, 180},
}

farPoints = {
    {1090.232421875, 2374.33984375, 10.8203125, 180},
    {1039.310546875, 2228.7734375, 10.8203125, 267},
    {988.134765625, 2172.7978515625, 10.8203125, 2},
    {1024.162109375, 2109.8779296875, 10.8203125, 179},
    {1142.986328125, 1973.794921875, 10.8203125, 271},
    {1074.4892578125, 1860.4775390625, 10.8203125, 91},
    {2304.2587890625, 2809.837890625, 10.8203125, 357},
    {2429.4833984375, 2799.76953125, 10.8203125, 349},
    {2845.427734375, 2633.375, 10.8203125, 2},
    {1737.1904296875, 922.033203125, 10.8203125, 270},
    {1362.30859375, 1090.6650390625, 10.8203125, 89},
    {1310.7197265625, 1171.7607421875, 10.8203125, 87},
    {1636.2109375, 753.2578125, 10.8203125, 358},
    {1695.0791015625, 692.83984375, 10.8203125, 177},
    {2206.7392578125, -2523.8408203125, 13.546875, 84},
    {2609.9990234375, -2205.904296875, 13.546875, 1},
    {2266.138671875, -2442.2666015625, 13.546875, 270},
}