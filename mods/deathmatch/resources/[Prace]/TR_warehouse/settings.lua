jobSettings = {
    name = "Depo işçisi",
    desc = "Depo işçisi, depoya gelen araçların boşaltılmasını içerir.\nKamyon römorkundan çıkarılan kutuyu rafta taşımalısınız. Yükü, depodaki kutu ve raf işaretlemelerine göre sıralamalısınız.",
    require = false,
    earnings = "$3500",

    upgrades = {
        {
            name = "Daha fazla stabilite",
            desc = "Bu yükseltme, sallanmayı ve paketleri düşürmeyi durduracak.",
            price = 100,
            type = "stability",
        },
        {
            name = "Daha hızlı teslimat",
            desc = "Bu yükseltme, bir sonraki kamyonun daha hızlı gelmesini sağlayacak.",
            price = 350,
            type = "truck",
            additionalMoney = {500, 700},
        },
        {
            name = "Güçlü bacaklar",
            desc = "Bu yükseltme, paketler taşırken koşabileceğiniz anlamına gelir.",
            price = 700,
            type = "running",
            additionalMoney = {800, 1200},
        },
    },
}
function getJobDetails()
    return jobSettings
end