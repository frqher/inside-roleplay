jobSettings = {
    name = "Elma Bahçesinde Çalışma",
    desc = "İş, bahçedeki ağaçlardan olgun elmaları toplamayı içerir.\nUnutma ki sepetinin sınırlı bir kapasitesi var ve sadece olgun elmaları toplamalısın. Sonraki seferlerde daha fazla para kazanacaksın.",
    require = "Deneyim: 50 puan",
    earnings = "$3900",

    upgrades = {
        {
            name = "Daha Büyük Sepet",
            desc = "Bu yükseltme daha fazla elma toplamanı sağlar.",
            price = 100,
            type = "box",
            additionalMoney = {400, 600}
        },
        {
            name = "Sağlıklı Yaşam",
            desc = "Bu yükseltme sayesinde daha az çürük elma bulabilirsin.",
            price = 300,
            type = "apple",
        },
        {
            name = "Mutlu Elma",
            desc = "Bu yükseltme sayesinde altın değerinde bir altın elma bulabilirsin ($500 değerinde).",
            price = 450,
            type = "goldapple",
        },
    },
}
function getJobDetails()
    return jobSettings
end