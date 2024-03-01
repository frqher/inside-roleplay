jobSettings = {
    name = "Çim Biçme İşi",
    desc = "İş, Juniper Hill'in temizliğini ve estetiğini korumayı gerektirir. Parkın her zaman harika görünmesini ve San Fierro şehrinin gururu olmasını sağlamak için çimenin düzgün ve uygun yükseklikte olmasına dikkat edilmelidir.\nBu senin görevin olacak!",
    earnings = "$3000",
    require = false,

    upgrades = {
        {
            name = "Yoğun Çim",
            desc = "Toplanan çim miktarını ikiye katlar.",
            price = 400,
            type = "grass",
            additionalMoney = {400, 800},
        },
        {
            name = "Hızlı Boşaltma",
            desc = "Çim boşaltma süresini kısaltır.",
            price = 100,
            type = "bag",
            additionalMoney = {100, 250},
        },
        {
            name = "Hızlı Çim Biçme Makinesi",
            desc = "Çim biçme makinesinin maksimum hızı artırılır.",
            price = 350,
            type = "landmower",
            additionalMoney = {450, 600},
        },
    },
}
function getJobDetails()
    return jobSettings
end