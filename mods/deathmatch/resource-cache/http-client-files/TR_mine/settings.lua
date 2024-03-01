jobSettings = {
    name = "Taş Ocağı İşçisi",
    desc = "İş, tünel kazma ve taş çıkarma işleminden oluşmaktadır. Tüm operasyonlarda makine kullanılamayabilir. Tünelin kazıldığı yerde, üstteki yolun çökmemesi için özel dikkat gösterilmelidir. Göreviniz duvarlara patlayıcı yüklemek ve kırık taşları toplamaktır.",
    require = "Deneyim: 220 puan",
    earnings = "$4500",

    upgrades = {
        {
            name = "Güçlü dinamit",
            desc = "Bu yükseltme, duvara daha az dinamit çubuğu yerleştirmenizi gerektirecektir.",
            price = 200,
            type = "dynamite",
            additionalMoney = {300, 400},
        },
        {
            name = "Hassas ateşleyici",
            desc = "Bu yükseltme, duvardan daha az kaya parçasının düşmesine neden olacaktır.",
            price = 400,
            type = "igniter",
            additionalMoney = {500, 600},
        },
    },
}
function getJobDetails()
    return jobSettings
end