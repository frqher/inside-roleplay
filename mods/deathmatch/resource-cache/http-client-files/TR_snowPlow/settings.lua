jobSettings = {
    name = "Kar Temizleme İşi",
    desc = "Angel Pine şehrinde ve çevresinde sürekli kar yağıyor ve kaygan. Bu şehrin sokaklarını temizlemek, normal araçların güvenli bir şekilde yollarımızda seyahat etmesini sağlamak için göreviniz olacak.\nNe yazık ki, en yüksek teknolojiye sahip makinelerimiz yok, bu yüzden iş için iki kişiye ihtiyaç var.",
    require = "B sınıfı ehliyet\nDeneyim: 80 puan",
    earnings = "$3900",

    -- Çoklu iş
    minPlayers = 2,
    workers = {"karKüreme", "kum"},
    ----

    upgrades = {
        {
            name = "Daha Fazla Güven",
            desc = "Bu yükseltme, daha büyük bir mesafeyi koruyabileceğiniz anlamına gelir.",
            price = 50,
            type = "mesafe",
        },
        {
            name = "Güçlü Motor",
            desc = "Bu yükseltme, traktörün daha hızlı gitmesini sağlayacak.",
            price = 80,
            type = "traktör",
            additionalMoney = {150, 200},
        },
        {
            name = "Daha Büyük Taşıma Kapasitesi",
            desc = "Bu yükseltme, kürekte daha fazla kum taşıyabileceğiniz anlamına gelir.",
            price = 150,
            type = "kamyonet",
            additionalMoney = {400, 450},
        },
    },
}
function getJobDetails()
    return jobSettings
end