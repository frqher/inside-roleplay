jobSettings = {
    name = "Pizza Teslimatı",
    desc = "İş, müşterilere siparişlerin teslim edilmesinden oluşmaktadır. Sipariş listesini aldıktan sonra, restoran personeli tarafından hazırlanan motosiklete binip tüm siparişleri ilgili müşterilere teslim etmelisiniz.",
    require = false,
    earnings = "$3500",

    upgrades = {
        {
            name = "Daha Büyük Çanta",
            desc = "Aynı anda 2 kat daha fazla siparişi alabilirsiniz.",
            price = 50,
            type = "storage",
            additionalMoney = {250, 400},
        },
        {
            name = "Karizma",
            desc = "Bahşiş alma şansını artırır.",
            price = 80,
            type = "tip",
        },
        {
            name = "Daha Hızlı Scooter",
            desc = "Teslimat scooter'ının hızını artırır.",
            price = 100,
            type = "vehicle",
            additionalMoney = {400, 600},
        },
    },
}
function getJobDetails()
    return jobSettings
end