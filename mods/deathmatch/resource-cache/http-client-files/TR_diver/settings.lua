jobSettings = {
    name = "Dalış İşi",
    desc = "Dalış elbisesi giy ve Sherman çıkışının derinliklerinde kaybolmuş artefaktları ara. Bu artefaktlar, yıllar önce San Fierro'ya çeşitli malzemelerle yüklü bir korsan gemisinin katliamında batmış olabilir. Sherman sularının derinliklerinde XVII. yüzyıla ait ilginç eşyalar bulabilirsin.",
    require = "Dalış Lisansı\nDeneyim: 500puan",
    earnings = "$4700",

    upgrades = {
        {
            name = "Büyük Çanta",
            desc = "Bu yükseltme daha fazla eşya toplamanı sağlar.",
            price = 60,
            type = "sırt çantası",
        },
        {
            name = "Derin Nefes",
            desc = "Bu yükseltmeyle tüpü 25 litre doldurabilirsin.",
            price = 120,
            type = "tank",
            additionalMoney = {200, 400}
        },
        {
            name = "Altıncı His",
            desc = "Bu yükseltmeyle sandıkları daha iyi arayabilirsin.",
            price = 200,
            type = "beyin",
            additionalMoney = {400, 600}
        },
        {
            name = "Geniş Paletler",
            desc = "Bu yükseltmeyle daha hızlı yüzebilirsin.",
            price = 250,
            type = "palet",
            additionalMoney = {600, 850}
        },
    },
}

function getJobDetails()
    return jobSettings
end