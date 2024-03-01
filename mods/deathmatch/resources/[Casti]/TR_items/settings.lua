itemTypes = {
    weapon = 1,
    food = 2,
    clothes = 3,
    keys = 4,
    documents = 5,
    cigarettes = 6,
    joints = 7,
    alcohol = 8,
    mask = 9,
    ammo = 10,
    armor = 11,
    armorplate = 12,
    fishingbait = 13,
    premium = 14,
    gift = 15,
    autograph = 16,
    spray = 17,
    drugs = 18,
    paperSheet = 19,
    boombox = 20,
    flowers = 21,
    diverChest = 22,
    neon = 23,
}

itemCategories = {
    [1] = "weapons",
    [2] = "food",
    [3] = "clothes",
    [4] = "keys",
    [5] = "other",
    [6] = "other",
    [7] = "other",
    [8] = "food",
    [9] = "weapons",
    [10] = "weapons",
    [11] = "weapons",
    [12] = "weapons",
    [13] = "other",
    [14] = "other",
    [15] = "other",
    [16] = "other",
    [17] = "other",
    [18] = "other",
    [19] = "other",
    [20] = "other",
    [21] = "other",
    [22] = "other",
    [23] = "other",
}

weaponsWithoutAmmo = {
    [1] = true,
    [2] = true,
    [3] = true,
    [4] = true,
    [5] = true,
    [6] = true,
    [7] = true,
    [8] = true,
    [9] = true,
}

weaponAmmoType = {
    [31] = 0, -- 5.56
    [23] = 0, -- 5.56
    [33] = 1, -- 6
    [34] = 1, -- 6
    [30] = 2, -- 7.62
    [28] = 3, -- 9
    [29] = 3, -- 9
    [32] = 3, -- 9
    [22] = 4, -- 11.43
    [25] = 5, -- 12
    [26] = 5, -- 12
    [24] = 6, -- 12.7
}

weaponDurability = {
    [22] = 300, -- Colt
    [23] = 400, -- Silenced
    [24] = 200, -- Deagle
    [25] = 100, -- Shotgun
    [26] = 100, -- Sawed-off
    [28] = 600, -- Uzi
    [29] = 500, -- MP5
    [30] = 600, -- AK
    [31] = 900, -- M4
    [32] = 400, -- Tec-9
    [33] = 100, -- Small Sniper
    [34] = 100, -- Sniper
}

weaponSlots = {
    [2] = 1,
    [3] = 1,
    [4] = 1,
    [5] = 1,
    [6] = 1,
    [7] = 1,
    [8] = 1,
    [9] = 1,
    [22] = 2,
    [23] = 2,
    [24] = 2,
    [25] = 3,
    [26] = 3,
    [27] = 3,
    [28] = 4,
    [29] = 4,
    [32] = 4,
    [30] = 5,
    [31] = 5,
    [33] = 6,
    [34] = 6,
    [35] = 7,
    [36] = 7,
    [37] = 7,
    [38] = 7,
    [10] = 10,
    [11] = 10,
    [12] = 10,
    [13] = 10,
    [14] = 10,
    [15] = 10,
    [44] = 11,
    [45] = 11,
    [46] = 11,
}

shootAnim = {
    [3] = { -- Torso
        front = "dam_stomach_frmft",
        back = "dam_stomach_frmbk",
        left = "dam_stomach_frmlt",
        right = "dam_stomach_frmrt",
    },
    [4] = { -- Ass
        front = "dam_stomach_frmft",
        back = "dam_stomach_frmbk",
        left = "dam_stomach_frmlt",
        right = "dam_stomach_frmrt",
    },
    [5] = { -- Left arm
        front = "dam_arml_frmft",
        back = "dam_arml_frmbk",
        left = "dam_arml_frmlt",
    },
    [6] = { -- Right arm
        front = "dam_armr_frmft",
        back = "dam_armr_frmbk",
        right = "dam_armr_frmrt",
    },
    [7] = { -- Left leg
        front = "dam_legl_frmft",
        back = "dam_legl_frmbk",
        left = "dam_legl_frmlt",
    },
    [8] = { -- Right leg
        front = "dam_legr_frmft",
        back = "dam_legr_frmbk",
        right = "dam_legr_frmrt",
    },
}

itemDetails = {
    -- Weapons

    {type = 1, variant = 1, variant2 = 0, name = "Polis Tonfası", description = "Sert kauçuk cop. Kauçuktan yapılmış olmasına rağmen acıtabilir.", icon = "baton", weight = 460, defaultAdminValue = 3},
    {type = 1, variant = 1, variant2 = 1, name = "Askeri Bıçak", description = "Plastiği kolayca kesen çok keskin bir bıçak.", icon = "knife", weight = 400, defaultAdminValue = 4},
    {type = 1, variant = 1, variant2 = 2, name = "Beyzbol Sopası", description = "Beyzbol oynamak için kullanılır, ancak ciddi darbelerde kullanılabilir.", icon = "baseball", weight = 1300, defaultAdminValue = 5},
    {type = 1, variant = 1, variant2 = 3, name = "Katana", description = "Çok keskin. Kalın bir tahta parçasını kolayca keser.", icon = "katana", weight = 1000, defaultAdminValue = 8},
    {type = 1, variant = 1, variant2 = 4, name = "Olta +1", description = "Balıkları saklamak için ideal ağlı olta.", icon = "fishingrod", weight = 300, defaultAdminValue = 0},
    {type = 1, variant = 1, variant2 = 5, name = "Olta +2", description = "Balıkları saklamak için ideal ağlı olta.", icon = "fishingrod", weight = 300, defaultAdminValue = 0},
    {type = 1, variant = 1, variant2 = 6, name = "Olta +3", description = "Balıkları saklamak için ideal ağlı olta.", icon = "fishingrod", weight = 300, defaultAdminValue = 0},
    {type = 1, variant = 1, variant2 = 7, name = "Olta +4", description = "Balıkları saklamak için ideal ağlı olta.", icon = "fishingrod", weight = 300, defaultAdminValue = 0},
    {type = 1, variant = 1, variant2 = 8, name = "Olta +5", description = "Balıkları saklamak için ideal ağlı olta.", icon = "fishingrod", weight = 300, defaultAdminValue = 0},
    {type = 1, variant = 1, variant2 = 9, name = "Olta +6", description = "Balıkları saklamak için ideal ağlı olta.", icon = "fishingrod", weight = 300, defaultAdminValue = 0},
    {type = 1, variant = 1, variant2 = 10, name = "Olta +7", description = "Balıkları saklamak için ideal ağlı olta.", icon = "fishingrod", weight = 300, defaultAdminValue = 0},
    {type = 1, variant = 1, variant2 = 11, name = "Olta +8", description = "Balıkları saklamak için ideal ağlı olta.", icon = "fishingrod", weight = 300, defaultAdminValue = 0},
    {type = 1, variant = 1, variant2 = 12, name = "Olta +9", description = "Balıkları saklamak için ideal ağlı olta.", icon = "fishingrod", weight = 300, defaultAdminValue = 0},
    
    

    
    {type = 1, variant = 2, variant2 = 0, name = "Glock 19", description = "Standart bir savunma tabancası.", icon = "glock", weight = 625, preview = {{title = "Kalibre", value = "11.43mm"}, {title = "Şarjör Kapasitesi", value = "17 mermi"}}, defaultAdminValue = 22},
    {type = 1, variant = 2, variant2 = 1, name = "Desert Eagle", description = "Bir eli kolayca koparabilen güçlü bir tabanca.", weight = 450, icon = "deserteagle", preview = {{title = "Kalibre", value = "12.7mm"}, {title = "Şarjör Kapasitesi", value = "7 mermi"}}, defaultAdminValue = 24},
    {type = 1, variant = 2, variant2 = 2, name = "SIG Mosquito", description = "Sessizce savaşmak için ideal susturuculu bir tabanca.", weight = 450, icon = "glock", preview = {{title = "Kalibre", value = "12.7mm"}, {title = "Şarjör Kapasitesi", value = "7 mermi"}}, defaultAdminValue = 24},
    {type = 1, variant = 3, variant2 = 0, name = "Remington 870", description = "Bir mermiyle çok büyük bir darbe gücüne sahip tek namlulu tüfek.", icon = "shotgun", weight = 2200, preview = {{title = "Kalibre", value = "12mm"}, {title = "Şarjör Kapasitesi", value = "1 mermi"}}, defaultAdminValue = 25},
    {type = 1, variant = 3, variant2 = 1, name = "Sawed-off Remington 870", description = "Yüksek darbe gücüne sahip çift namlulu bir tüfek.", icon = "sawedoff", weight = 2600, preview = {{title = "Kalibre", value = "12mm"}, {title = "Şarjör Kapasitesi", value = "2 mermi"}}, defaultAdminValue = 26},
    {type = 1, variant = 4, variant2 = 0, name = "Mac-10", description = "Çok yüksek ateş hızına sahip bir makineli tabanca.", icon = "mac10", weight = 2800, preview = {{title = "Kalibre", value = "9mm"}, {title = "Şarjör Kapasitesi", value = "50 mermi"}}, defaultAdminValue = 28},
    {type = 1, variant = 4, variant2 = 1, name = "HK MP5", description = "Alev geciktiricili bir makineli tabanca.", icon = "mp5", weight = 2500, preview = {{title = "Kalibre", value = "9mm"}, {title = "Şarjör Kapasitesi", value = "30 mermi"}}, defaultAdminValue = 29},
    {type = 1, variant = 4, variant2 = 2, name = "Tec-9", description = "Kompakt bir tabanca.", icon = "tec", weight = 1200, preview = {{title = "Kalibre", value = "9mm"}, {title = "Şarjör Kapasitesi", value = "50 mermi"}}, defaultAdminValue = 32},
    {type = 1, variant = 5, variant2 = 0, name = "AK-47", description = "Çok yüksek güçlü bir otomatik tüfek.", icon = "ak47", weight = 3400, preview = {{title = "Kalibre", value = "7.62mm"}, {title = "Şarjör Kapasitesi", value = "30 mermi"}}, defaultAdminValue = 30},
    {type = 1, variant = 5, variant2 = 1, name = "HK416", description = "Yüksek ateş hızına sahip bir otomatik tüfek.", icon = "m4", weight = 3300, preview = {{title = "Kalibre", value = "5.56mm"}, {title = "Şarjör Kapasitesi", value = "50 mermi"}}, defaultAdminValue = 31},
    {type = 1, variant = 6, variant2 = 0, name = "Blaser R93", description = "Avlanma için ideal bir tüfek.", icon = "smallsniper", weight = 4900, preview = {{title = "Kalibre", value = "6mm"}, {title = "Şarjör Kapasitesi", value = "1 mermi"}}, defaultAdminValue = 33},
    {type = 1, variant = 6, variant2 = 1, name = "Remington Model 7400", description = "Büyük darbe gücüne sahip bir keskin nişancı tüfeği.", icon = "sniper", weight = 3400, preview = {{title = "Kalibre", value = "6mm"}, {title = "Şarjör Kapasitesi", value = "1 mermi"}}, defaultAdminValue = 34},
    
    

    -- Food
    {type = 2, variant = 0, variant2 = 0, name = "Snapz Crisps", description = "Yağ oranı düşük elma ve sebze cipsleri.", icon = "chips", weight = 60, preview = {{title = "İyileştirir", value = "5%"}}},
    {type = 2, variant = 0, variant2 = 1, name = "Zone Perfect Nutrition", description = "Fıstık ezmesi dolgulu doğal protein barı.", icon = "chocolate", weight = 15, preview = {{title = "İyileştirir", value = "9%"}}},
    {type = 2, variant = 0, variant2 = 2, name = "Hawaiian Luau BBQ Chips", description = "Hawaiian Luau Barbekü lezzetli patates cipsleri.", icon = "chips", weight = 60, preview = {{title = "İyileştirir", value = "5%"}}},
    {type = 2, variant = 0, variant2 = 3, name = "Mr. Nature Unsalted Trail Mix", description = "Fındık, kuru üzüm, badem ve ayçiçeği çekirdeği karışımı.", icon = "chips", weight = 100, preview = {{title = "İyileştirir", value = "7%"}}},
    {type = 2, variant = 0, variant2 = 4, name = "Miss Vickie's Smokehouse BBQ", description = "Barbekü soslu patates cipsleri.", icon = "chips", weight = 60, preview = {{title = "İyileştirir", value = "5%"}}},
    {type = 2, variant = 0, variant2 = 5, name = "Fruit by the Foot", description = "Meyve aromalı sakız şeridi.", icon = "chocolate", weight = 25, preview = {{title = "İyileştirir", value = "5%"}}},
    {type = 2, variant = 0, variant2 = 6, name = "Bon Appetit Blueberry Muffin", description = "Yaban mersinli tatlı muffin.", icon = "cupcake", weight = 80, preview = {{title = "İyileştirir", value = "5%"}}},
    {type = 2, variant = 0, variant2 = 7, name = "Snickers", description = "Karamel ve yer fıstığı içeren çikolata bar.", icon = "chocolate", weight = 40, preview = {{title = "İyileştirir", value = "5%"}}},
    {type = 2, variant = 0, variant2 = 8, name = "Peanut M&M's", description = "Fındık kremalı çikolata kaplı şekerler.", icon = "chips", weight = 110, preview = {{title = "İyileştirir", value = "5%"}}},
    {type = 2, variant = 0, variant2 = 9, name = "Takis Fuego", description = "Acılı mısır cipsleri limon ve chili biberi aromasıyla.", icon = "chips", weight = 60, preview = {{title = "İyileştirir", value = "5%"}}},
    {type = 2, variant = 0, variant2 = 10, name = "Flamin 'Hot Funyuns", description = "Soğan halkaları atıştırmalığı.", icon = "chips", weight = 45, preview = {{title = "İyileştirir", value = "5%"}}},
    {type = 2, variant = 0, variant2 = 11, name = "Baby Ruth", description = "Ceviz, karamel ve nugat içeren süt çikolata barı.", icon = "chocolate", weight = 25, preview = {{title = "İyileştirir", value = "9%"}}},
    {type = 2, variant = 0, variant2 = 12, name = "Cliff Bar", description = "Beyaz çikolata ve Macadamia fındıklı bar.", icon = "chocolate", weight = 20, preview = {{title = "İyileştirir", value = "5%"}}},

    
    {type = 2, variant = 1, variant2 = 0, name = "Sprunk", description = "Limon ve limon aromalı gazlı içecek.", icon = "can", weight = 330, preview = {{title = "İyileştirir", value = "5%"}}},
    {type = 2, variant = 1, variant2 = 1, name = "Cola", description = "Şeker oranı yüksek tatlı gazlı içecek.", icon = "can", weight = 330, preview = {{title = "İyileştirir", value = "5%"}}},
    {type = 2, variant = 1, variant2 = 9, name = "Fanta", description = "Meyve aromalı gazlı içecek.", icon = "can", weight = 330, preview = {{title = "İyileştirir", value = "5%"}}},
    {type = 2, variant = 1, variant2 = 2, name = "Vitamin water", description = "Vitamin eklenmiş mineral suyu.", icon = "bottle", weight = 500, preview = {{title = "İyileştirir", value = "5%"}}},
    {type = 2, variant = 1, variant2 = 3, name = "Mineral water", description = "Doğal mineral içerikli su.", icon = "bottle", weight = 500, preview = {{title = "İyileştirir", value = "5%"}}},
    {type = 2, variant = 1, variant2 = 4, name = "Hi-C", description = "Meyve aromalı içecek.", icon = "can", weight = 330, preview = {{title = "İyileştirir", value = "5%"}}},
    {type = 2, variant = 1, variant2 = 5, name = "Seagram's Ginger Ale", description = "Kafeinsiz zencefil aromalı içecek.", icon = "can", weight = 330, preview = {{title = "İyileştirir", value = "5%"}}},
    {type = 2, variant = 1, variant2 = 6, name = "FUZE Iced Tea", description = "Serinletici buzlu çay.", icon = "bottle", weight = 500, preview = {{title = "İyileştirir", value = "5%"}}},
    {type = 2, variant = 1, variant2 = 7, name = "Powerade", description = "İzotonik içecek.", icon = "bottle", weight = 500, preview = {{title = "İyileştirir", value = "5%"}}},
    {type = 2, variant = 1, variant2 = 8, name = "Mello yello", description = "Yüksek kafeinli turunçgazozu aromalı içecek.", icon = "can", weight = 330, preview = {{title = "İyileştirir", value = "5%"}}},
    
    

    
    {type = 2, variant = 2, variant2 = 0, name = "Hamburger", description = "Taze pişmiş etle lezzetli bir hamburger.", icon = "burger", weight = 100, preview = {{title = "İyileştirir", value = "7%"}}},
    {type = 2, variant = 2, variant2 = 1, name = "Cheesburger", description = "Taze pişmiş etle ve peynirle lezzetli bir hamburger.", icon = "burger", weight = 105, preview = {{title = "İyileştirir", value = "7%"}}},

    {type = 2, variant = 3, variant2 = 0, name = "Tuzsuz Patates Kızartması", description = "Taze kızarmış patates kızartması.", icon = "fries", weight = 150, preview = {{title = "İyileştirir", value = "7%"}}},
    {type = 2, variant = 3, variant2 = 1, name = "Tuzlu Patates Kızartması", description = "Taze kızarmış ve tuzla kaplanmış patates kızartması.", icon = "fries", weight = 150, preview = {{title = "İyileştirir", value = "7%"}}},

    {type = 2, variant = 4, variant2 = 0, name = "Sosisli Ekmek Arası", description = "Ketçaplı taze sosisli ekmek arası.", icon = "hotdog", weight = 155, preview = {{title = "İyileştirir", value = "9%"}}},
    {type = 2, variant = 4, variant2 = 1, name = "Sosisli Ekmek Arası", description = "Hardal soslu taze sosisli ekmek arası.", icon = "hotdog", weight = 150, preview = {{title = "İyileştirir", value = "9%"}}},
    {type = 2, variant = 4, variant2 = 2, name = "Sosisli Ekmek Arası", description = "Hardal ve ketçaplı taze sosisli ekmek arası.", icon = "hotdog", weight = 160, preview = {{title = "İyileştirir", value = "9%"}}},


    
    {type = 2, variant = 5, variant2 = 0, name = "Küçük meyve sepeti", description = "Leziz meyvelerle dolu küçük bir sepet.", icon = "fruits", weight = 160, preview = {{title = "İyileştirir", value = "5%"}}},
    {type = 2, variant = 5, variant2 = 1, name = "Orta boy meyve sepeti", description = "Leziz meyvelerle dolu orta boy bir sepet.", icon = "fruits", weight = 320, preview = {{title = "İyileştirir", value = "10%"}}},
    {type = 2, variant = 5, variant2 = 2, name = "Büyük meyve sepeti", description = "Leziz meyvelerle dolu büyük bir sepet.", icon = "fruits", weight = 480, preview = {{title = "İyileştirir", value = "15%"}}},
    {type = 2, variant = 5, variant2 = 3, name = "Küçük sebze sepeti", description = "Leziz sebzelerle dolu küçük bir sepet.", icon = "vegetables", weight = 160, preview = {{title = "İyileştirir", value = "5%"}}},
    {type = 2, variant = 5, variant2 = 4, name = "Orta boy sebze sepeti", description = "Leziz sebzelerle dolu orta boy bir sepet.", icon = "vegetables", weight = 320, preview = {{title = "İyileştirir", value = "10%"}}},
    {type = 2, variant = 5, variant2 = 5, name = "Büyük sebze sepeti", description = "Leziz sebzelerle dolu büyük bir sepet.", icon = "vegetables", weight = 480, preview = {{title = "İyileştirir", value = "15%"}}},
    
    

    -- Cluckin bell
    
    {type = 2, variant = 7, variant2 = 0, name = "Dev Boy Paket", description = "Büyük bir kova, çift Fowl Burger, büyük boy patates kızartması ve Sprunk içerir.", icon = "foodset", weight = 1300, preview = {{title = "İyileştirir", value = "32%"}}},
    {type = 2, variant = 7, variant2 = 1, name = "Büyük Paket", description = "Büyük boy patates kızartması, Fillet Burger ve Sprunk içerir.", icon = "foodset", weight = 900, preview = {{title = "İyileştirir", value = "25%"}}},
    {type = 2, variant = 7, variant2 = 2, name = "Küçük Paket", description = "Çocuklar için paket. Patates kızartması, Sprunk ve oyuncak Bobby Broiler içerir.", icon = "foodset", weight = 400, preview = {{title = "İyileştirir", value = "15%"}}},
    {type = 2, variant = 7, variant2 = 3, name = "Little Clucker", description = "Çocuklar için paket. Patates kızartması, Küçük Kanat Parçası, Sprunk içerir.", icon = "foodset", weight = 400, preview = {{title = "İyileştirir", value = "12%"}}},
    {type = 2, variant = 7, variant2 = 4, name = "Salata", description = "Tavuklu ve Sprunk ile dolu tam bir sebze salatası.", icon = "salad", weight = 500, preview = {{title = "İyileştirir", value = "9%"}}},
    {type = 2, variant = 7, variant2 = 5, name = "Küçük Kanat Parçası", description = "Tatlı ekşi sosla birlikte küçük kanat parçaları.", icon = "chickenwings", weight = 300, preview = {{title = "İyileştirir", value = "10%"}}},
    {type = 2, variant = 7, variant2 = 6, name = "Kanat Parçası", description = "Tatlı ekşi sosla birlikte büyük kanat parçaları.", icon = "chickenwings", weight = 500, preview = {{title = "İyileştirir", value = "8%"}}},
    {type = 2, variant = 7, variant2 = 7, name = "Fowl Burger", description = "Taze pişmiş et ile yapılmış bir hamburger.", icon = "burger", weight = 200, preview = {{title = "İyileştirir", value = "8%"}}},
    {type = 2, variant = 7, variant2 = 8, name = "Fillet Burger", description = "İçinde bir balık parmağı bulunan bir hamburger.", icon = "burger", weight = 170, preview = {{title = "İyileştirir", value = "8%"}}},
    
    

    -- Burger Shot
    
    {type = 2, variant = 8, variant2 = 0, name = "Et Kulesi", description = "Büyük patates kızartması, çift Hamburger, büyük Sprunk içerir.", icon = "foodset", weight = 900, preview = {{title = "İyileştirir", value = "30%"}}},
    {type = 2, variant = 8, variant2 = 1, name = "Sığır Kulesi", description = "Büyük patates kızartması, orta boy Hamburger, orta boy Sprunk içerir.", icon = "foodset", weight = 750, preview = {{title = "İyileştirir", value = "24%"}}},
    {type = 2, variant = 8, variant2 = 2, name = "Çığlık atan çocuk seti", description = "Çocuklar için paket. Küçük patates kızartması, hamburger, küçük Sprunk içerir.", icon = "foodset", weight = 300, preview = {{title = "İyileştirir", value = "15%"}}},
    {type = 2, variant = 8, variant2 = 3, name = "Salata", description = "Tavuklu ve Sprunk ile dolu tam bir sebze salatası.", icon = "salad", weight = 600, preview = {{title = "İyileştirir", value = "20%"}}},
    
    

    -- Pizza
    
    {type = 2, variant = 9, variant2 = 0, name = "Tam Tezgah", description = "Çok büyük patates kızartması, tam pizza, büyük Sprunk içerir.", icon = "foodset", weight = 2000, preview = {{title = "İyileştirir", value = "40%"}}},
    {type = 2, variant = 9, variant2 = 1, name = "Çift D-Luxe", description = "Büyük patates kızartması, büyük pizza dilimi, küçük salata, büyük Sprunk içerir.", icon = "foodset", weight = 1200, preview = {{title = "İyileştirir", value = "32%"}}},
    {type = 2, variant = 9, variant2 = 2, name = "Buster", description = "Küçük patates kızartması, orta boy pizza dilimi, küçük Sprunk içerir.", icon = "foodset", weight = 600, preview = {{title = "İyileştirir", value = "24%"}}},
    {type = 2, variant = 9, variant2 = 3, name = "Salatalık yemek", description = "Barbunya ve sos ile dolu tam bir sebze salatası, Sprunk.", icon = "salad", weight = 500, preview = {{title = "İyileştirir", value = "18%"}}},
    {type = 2, variant = 9, variant2 = 4, name = "Tam pizza", description = "Mantar, sosis, soğan ve bol miktarda peynirle pizza.", icon = "pizza", weight = 1600, preview = {{title = "İyileştirir", value = "26%"}}},
    {type = 2, variant = 9, variant2 = 5, name = "Pizza dilimi", description = "Mantar, sosis, soğan ve bol miktarda peynirle pizza dilimi.", icon = "pizzaslice", weight = 200, preview = {{title = "İyileştirir", value = "12%"}}},
    
    

    
    -- Donuts
    {type = 2, variant = 10, variant2 = 0, name = "Rusty’s Büyük Çift", description = "Glazür ve şekerle kaplı büyük donutlar, büyük kahve.", icon = "donuts", weight = 3000, preview = {{title = "İyileştirir", value = "27%"}}},
    {type = 2, variant = 10, variant2 = 1, name = "Rusty’s Çift Namlulu", description = "Glazürlü büyük donutlar, orta boy kahve.", icon = "donuts", weight = 2700, preview = {{title = "İyileştirir", value = "18%"}}},
    {type = 2, variant = 10, variant2 = 2, name = "Rusty’s D-Luxe", description = "Çikolatalı muffin, şekerli donut, küçük kahve.", icon = "donuts", weight = 700, preview = {{title = "İyileştirir", value = "9%"}}},
    {type = 2, variant = 10, variant2 = 3, name = "Çifte Çikolata Patlaması", description = "İki kat çikolatalı donutlar.", icon = "donut", weight = 500, preview = {{title = "İyileştirir", value = "6%"}}},
    {type = 2, variant = 10, variant2 = 4, name = "Karamel Dolgulu Donutlar", description = "Karamel dolgulu donutlar.", icon = "donut", weight = 500, preview = {{title = "İyileştirir", value = "4%"}}},
    {type = 2, variant = 10, variant2 = 5, name = "Demlenmiş Kahve", description = "Siyah demlenmiş kahve.", icon = "coffee", weight = 500, preview = {{title = "İyileştirir", value = "8%"}}},
    {type = 2, variant = 10, variant2 = 6, name = "Hazır Kahve", description = "Siyah hazır kahve.", icon = "coffee", weight = 500, preview = {{title = "İyileştirir", value = "2%"}}},

    -- Clothes
    {type = 3, variant = 0, variant2 = 0, name = "Binco Giyim", description = "Kalabalıktan sıyrılmayan standart giyim.", icon = "clothes", weight = 1700},
    {type = 3, variant = 1, variant2 = 0, name = "Sub Urban Giyim", description = "Kalabalıktan sıyrılmayan standart giyim.", icon = "clothes", weight = 1700},
    {type = 3, variant = 2, variant2 = 0, name = "Victim Giyim", description = "Daha zarif giyim, tasarımcılar tarafından üretilir.", icon = "zip", weight = 1600},
    {type = 3, variant = 3, variant2 = 0, name = "ZIP Giyim", description = "Daha kaliteli malzemeden yapılmış yüksek kaliteli giyim.", icon = "zip", weight = 1600},
    {type = 3, variant = 4, variant2 = 0, name = "Didier Sachs Giyim", description = "Elitler tarafından giyilen çok şık giyim.", icon = "didier", weight = 1700},
    {type = 3, variant = 5, variant2 = 0, name = "ProLaps Giyim", description = "Antrenman sırasında giyilen spor giyim.", icon = "prolaps", weight = 1500},
    {type = 3, variant = 6, variant2 = 0, name = "Ranch Giyim", description = "Çiftçilere özgü iş kıyafeti.", icon = "clothes", weight = 1900},
    {type = 3, variant = 7, variant2 = 0, name = "Kevin Clone Giyim", description = "Gold oyuncular için çok yüksek kaliteli giyim.", icon = "clothes", weight = 2000},
    {type = 3, variant = 8, variant2 = 0, name = "Gnocchi Giyim", description = "Elmas oyuncular için çok yüksek kaliteli giyim.", icon = "clothes", weight = 2000},
    {type = 3, variant = 9, variant2 = 0, name = "Noel Kostümü", description = "Noel Baba tarafından hediye edilen çok özel bir kostüm.", icon = "christmasHat", weight = 1800},
    {type = 3, variant = 10, variant2 = 0, name = "Korsan Kostümü", description = "Çok özel bir kostüm. Hatta ahşap bacak bile var.", icon = "woodenLeg", weight = 2200},
    
    

    -- Documents
    {type = 4, variant = 0, variant2 = 0, name = "Araç Anahtarı", description = "Özel aracınızı açmanızı sağlayan anahtar.", icon = "carkey", weight = 10, blockTrade = true},
    {type = 4, variant = 1, variant2 = 0, name = "Emlak Anahtarı", description = "Hayalinizdeki evinizi açmanızı sağlayan anahtar.", icon = "housekey", weight = 10, blockTrade = true},

    -- Keys
    {type = 5, variant = 0, variant2 = 0, name = "Kimlik Belgesi", description = "Resmi işlerinizi halletmek için gereken belge.", icon = "id", weight = 24, blockTrade = true},
    {type = 5, variant = 1, variant2 = 0, name = "Sürücü Belgesi", description = "Belirli kategorideki araçları kullanma yetkinizi veren belge.", icon = "licence", weight = 24, blockTrade = true},
    {type = 5, variant = 1, variant2 = 1, name = "Dalış Lisansı", description = "Tüplü dalış yapma yetkinizi veren belge.", icon = "divingLicence", weight = 24, blockTrade = true},
    {type = 5, variant = 1, variant2 = 2, name = "Yat Kullanma Lisansı", description = "Tekneyle seyahat etme yetkinizi veren belge.", icon = "boatLicence", weight = 24, blockTrade = true},
    {type = 5, variant = 2, variant2 = 0, name = "Banka Kartı", description = "Bankamatik ve temassız ödeme yapmanızı sağlayan kart.", icon = "creditcard", weight = 32, blockTrade = true},
    {type = 5, variant = 3, variant2 = 0, name = "Cep Telefonu", description = "Eski bir model ama arama ve SMS gönderme işlevine sahip.", icon = "phone", weight = 180, blockTrade = true},

    -- Cigarettes
    {type = 6, variant = 0, variant2 = 0, name = "Marlboro", description = "Tütün mamulleri.", icon = "cigarettes", weight = 180, defaultAdminValue = 10},

    -- Joints
    {type = 7, variant = 0, variant2 = 0, name = "Marihuana Joint", description = "Birkaç nefes ve insan uçar.", icon = "joint", weight = 8, defaultAdminValue = 1},
    {type = 7, variant = 0, variant2 = 1, name = "Dawn'ın Arsayı", description = "Birkaç nefes ve insan uçar.", icon = "joint", weight = 8, canRemove = false, blockFavourite = true, fakeItem = true},
    {type = 7, variant = 0, variant2 = 2, name = "Taşıyıcılar İçin Dawn'ın Arsayı", description = "Birkaç nefes ve insan uçar.", icon = "joint", weight = 8, canRemove = false, blockUse = true, blockFavourite = true, fakeItem = true},
    {type = 7, variant = 0, variant2 = 3, name = "Haşhaş Joint", description = "Birkaç nefes ve insan uçar.", icon = "joint", weight = 8, defaultAdminValue = 1},

    -- Alcohol
    {type = 8, variant = 0, variant2 = 0, name = "Anthem Votka", description = "Standart 0.7 litrelik votka şişesi.", icon = "vodka", weight = 780, preview = {{title = "Alkol Oranı", value = "40%"}}},
    {type = 8, variant = 1, variant2 = 0, name = "Absolut Votka", description = "Standart 0.7 litrelik votka şişesi.", icon = "vodka", weight = 780, preview = {{title = "Alkol Oranı", value = "44%"}}},
    {type = 8, variant = 2, variant2 = 0, name = "50 Bleu Ultra Premium Votka", description = "Standart 0.7 litrelik votka şişesi.", weight = 780, icon = "vodka", preview = {{title = "Alkol Oranı", value = "48%"}}},

    {type = 8, variant = 0, variant2 = 1, name = "Modelo Especia", description = "Meksika'da üretilen bira.", icon = "beer", weight = 510, preview = {{title = "Alkol Oranı", value = "8%"}}},
    {type = 8, variant = 1, variant2 = 1, name = "Pilsner Urquell", description = "Çek Cumhuriyeti'nde üretilen açık renkli bira.", weight = 510, icon = "beer", preview = {{title = "Alkol Oranı", value = "7%"}}},
    {type = 8, variant = 2, variant2 = 1, name = "Warstainer", description = "Arnsberg Orman Doğa Parkı'nda üretilen bira.", weight = 510, icon = "beer", preview = {{title = "Alkol Oranı", value = "9%"}}},
    {type = 8, variant = 3, variant2 = 1, name = "Heineken", description = "Hollanda'da üretilen bira.", icon = "beer", weight = 510, preview = {{title = "Alkol Oranı", value = "5%"}}},
    {type = 8, variant = 4, variant2 = 1, name = "Budweiser", description = "Pirinç eklenerek yapılan Amerikan birası.", icon = "beer", weight = 510, preview = {{title = "Alkol Oranı", value = "7%"}}},

    -- Masks
        {type = 9, variant = 0, variant2 = 0, name = "Maske", description = "Bu maske ile anonim olabilirsiniz... Tam olarak değil belki.", icon = "mask", weight = 150},

    -- Mermi
    {type = 10, variant = 0, variant2 = 0, name = "5.56mm Mermi (50 adet)", description = "HK416, SIG Mosquito için uygun mermi.", icon = "6mm", weight = 500},
    {type = 10, variant = 1, variant2 = 0, name = "6mm Mermi (10 adet)", description = "Blaser R93 ve Remington Model 7400 için uygun mermi.", icon = "6mm", weight = 180},
    {type = 10, variant = 2, variant2 = 0, name = "7.62mm Mermi (30 adet)", description = "AK-47 için uygun mermi.", icon = "6mm", weight = 450},
    {type = 10, variant = 3, variant2 = 0, name = "9mm Mermi (50 adet)", description = "Mac-10, HK MP5 ve Tec-9 için uygun mermi.", icon = "11mm", weight = 790},
    {type = 10, variant = 4, variant2 = 0, name = "11.43mm Mermi (20 adet)", description = "Glock 19 için uygun mermi.", icon = "11mm", weight = 550},
    {type = 10, variant = 5, variant2 = 0, name = "12mm Mermi (20 adet)", description = "Remington 870 ve Sawed-off versiyonları için uygun mermi.", icon = "12mm", weight = 750},
    {type = 10, variant = 6, variant2 = 0, name = "12.7mm Mermi (10 adet)", description = "Desert Eagle için uygun mermi.", icon = "6mm", weight = 640},

    -- Zırh
    {type = 11, variant = 0, variant2 = 0, name = "Kurşun Geçirmez Yelek", description = "Mermilere karşı duyarlılığını azaltır... Neredeyse.", icon = "armor", weight = 11500, defaultAdminValue = 100},

    -- Zırh plakası
    {type = 12, variant = 0, variant2 = 0, name = "Kurşun Geçirmez Plaka", description = "Kurşun geçirmez yelekte değiştirerek yenileyebilirsiniz.", weight = 6500, icon = "armorplate", preview = {{title = "Dayanıklılık", value = "50%"}}},

    -- Balıkçılık yemi
    {type = 13, variant = 0, variant2 = 0, name = "Mısır", description = "30 atışa yetecek kadar. +1 olta için uygun.", icon = "fishingbait", weight = 300},
    {type = 13, variant = 1, variant2 = 0, name = "Kırmızı Solucanlar", description = "30 atışa yetecek kadar. +7 olta için uygun.", icon = "fishingbait", weight = 200},
    {type = 13, variant = 2, variant2 = 0, name = "Beyaz Solucanlar", description = "30 atışa yetecek kadar. +5 olta için uygun.", icon = "fishingbait", weight = 180},
    {type = 13, variant = 3, variant2 = 0, name = "Arpa", description = "30 atışa yetecek kadar. +3 olta için uygun.", icon = "fishingbait", weight = 340},
    {type = 13, variant = 4, variant2 = 0, name = "Canlı Balıklar", description = "15 atışa yetecek kadar. +9 olta için uygun.", icon = "fishingbait", weight = 650},

    -- Premium
    {type = 14, variant = 0, variant2 = 0, name = "Gold Hesap", description = "Bu jeton Gold hesap almanızı sağlar.", icon = "crown", weight = 0, defaultAdminValue = 7},
    {type = 14, variant = 1, variant2 = 0, name = "Diamond Hesap", description = "Bu jeton Diamond hesap almanızı sağlar.", icon = "diamond", weight = 0, defaultAdminValue = 7},

    -- Hediyeler
    {type = 15, variant = 0, variant2 = 0, name = "Noel Hediyesi", description = "İçinde ilginç bir ödül var.", icon = "gift", weight = 50},
    {type = 15, variant = 0, variant2 = 1, name = "Paskalya Sepeti", description = "İçinde ilginç bir ödül var.", icon = "easterEgg", weight = 50},


   -- Autograf
   {type = 16, variant = 0, variant2 = 0, name = "Autograf Xantris", description = "Xantris'in kendi el yazısıyla imzalı. Lütfu iyileştirebilir.", icon = "xantris", weight = 10},
   {type = 16, variant = 1, variant2 = 0, name = "Autograf Wilku", description = "Wilku'nun kendi el yazısıyla imzalı. Lütfu iyileştirebilir.", icon = "wilku", weight = 10},
   {type = 16, variant = 2, variant2 = 0, name = "Autograf Vanze", description = "Vanze'nin kendi el yazısıyla imzalı. Lütfu iyileştirebilir.", icon = "vanze", weight = 10},
   {type = 16, variant = 3, variant2 = 0, name = "Autograf Moses", description = "Moses'in kendi el yazısıyla imzalı. Lütfu iyileştirebilir.", icon = "moses", weight = 10},
   {type = 16, variant = 4, variant2 = 0, name = "Mała apteczka", description = "Różne rodzaje opatrunków, leków i plastrow pełne. Można użyć 1 raz.", icon = "firstAidKit", weight = 140},
   {type = 16, variant = 4, variant2 = 1, name = "Duża apteczka", description = "Różne rodzaje opatrunków, leków i plastrow pełne. Można użyć 5 razy.", icon = "firstAidKit", weight = 300},

   -- Spray
   {type = 17, variant = 0, variant2 = 0, name = "Puszka sprayu", description = "Idealna do sprayowania na ścianach.", icon = "sprayCan", weight = 500},

   -- Drugs
   {type = 18, variant = 0, variant2 = 0, name = "Haszysz", description = "Jointa sarma için ideal.", icon = "marijuana", weight = 1, blockUse = true, blockRemove = true, stackable = true},
   {type = 18, variant = 0, variant2 = 1, name = "Marihuana", description = "Jointa sarma için ideal.", icon = "marijuana", weight = 1, blockUse = true, blockRemove = true, stackable = true},

   {type = 18, variant = 1, variant2 = 0, name = "Heroina", description = "Opioidler grubuna ait bir uyuşturucu.", icon = "heroina", weight = 1, stackable = true, blockRemove = true},
   {type = 18, variant = 1, variant2 = 1, name = "LSD", description = "En güçlü halüsinojen maddelerden biri.", icon = "pills", weight = 1, stackable = true, blockRemove = true},
   {type = 18, variant = 1, variant2 = 2, name = "MDMA", description = "Saf formda popüler bir kulüp uyuşturucusu.", icon = "pills", weight = 1, stackable = true, blockRemove = true},
   {type = 18, variant = 1, variant2 = 3, name = "DMT", description = "Psikedelik bir psikoaktif madde.", icon = "cocaine", weight = 1, stackable = true, blockRemove = true},
   {type = 18, variant = 1, variant2 = 4, name = "Crack", description = "Kokainin en ucuz ve en bağımlılık yapan formu.", icon = "cocaine", weight = 1, stackable = true, blockRemove = true},

   {type = 18, variant = 2, variant2 = 0, name = "Kokaina", description = "Kolombiyalı kar.", icon = "cocaine", weight = 1, stackable = true, blockRemove = true},
   {type = 18, variant = 2, variant2 = 1, name = "Amfetamin", description = "Çok güçlü bir uyarıcı, kullanımdan sonra diş hekimine para biriktirin.", icon = "cocaine", weight = 1, stackable = true, blockRemove = true},
   {type = 18, variant = 2, variant2 = 2, name = "Metamfetamin", description = "Çok güçlü bir uyarıcı amfetamin türevidir.", icon = "cocaine", weight = 1, stackable = true, blockRemove = true},

   {type = 18, variant = 3, variant2 = 0, name = "Xanax", description = "Çok rahatlatıcı etkisi olan popüler bir psikotrop ilaç.", icon = "xanax", weight = 1, stackable = true, blockRemove = true},
   {type = 18, variant = 3, variant2 = 1, name = "Adderall", description = "ADHD ve ADD tedavisinde kullanılan bir ilaç.", icon = "xanax", weight = 1, stackable = true, blockRemove = true},

   -- Paper sheet
   {type = 19, variant = 0, variant2 = 0, name = "Paczka bibułek", description = "Haszysz blantlarını sarmak için hazır kağıt parçaları.", icon = "paperSheet", weight = 30, defaultAdminValue = 30},
   {type = 19, variant = 0, variant2 = 1, name = "Paczka bibułek", description = "Marihuana blantlarını sarmak için hazır kağıt parçaları.", icon = "paperSheet", weight = 30, defaultAdminValue = 30},

   -- Boombox
   {type = 20, variant = 0, variant2 = 0, name = "Boombox", description = "Arkadaşlarınla müzik dinlemek için ideal radyo.", icon = "boombox", weight = 3000},

   -- Flowers
   {type = 21, variant = 0, variant2 = 0, name = "Çiçek buketi", description = "Kadınlar için harika bir hediye.", icon = "flowers", weight = 150, defaultAdminValue = 0, blockUse = true},


   -- Neon
   {type = 23, variant = 0, variant2 = 0, name = "Paski neonowe", description = "Aracınıza monte edebileceğiniz benzersiz neonlar.", icon = "neon", weight = 1000},

    -- Gang utils
    {type = 24, variant = 0, variant2 = 0, name = "Marulanas Tohumu", description = "Kendi bitkinizi yetiştirmek için ideal.", icon = "seedBag", weight = 1, blockUse = true, stackable = true},
    {type = 24, variant = 0, variant2 = 1, name = "Haşhaş Tohumu", description = "Kendi bitkinizi yetiştirmek için ideal.", icon = "seedBag", weight = 1, blockUse = true, stackable = true},
    {type = 24, variant = 0, variant2 = 2, name = "Organik Gübre", description = "Bitkiler için mükemmel gübre.", icon = "fertilizer", weight = 1, blockUse = true, stackable = true},

    {type = 24, variant = 1, variant2 = 0, name = "Fenilaseton", description = "Güçlü bir kimyasal madde.", icon = "chemicalBottle", weight = 500, blockUse = true, stackable = true},
    {type = 24, variant = 1, variant2 = 1, name = "Metilamin", description = "Güçlü bir kimyasal madde.", icon = "chemicalBottle", weight = 500, blockUse = true, stackable = true},
    {type = 24, variant = 1, variant2 = 2, name = "Koka Yaprağı", description = "Kolombiyalı çiftçilerden toplanmıştır.", icon = "leaves", weight = 10, blockUse = true, stackable = true},

    {type = 24, variant = 2, variant2 = 0, name = "Silah Parçaları", description = "Cıvata ve somun yığını. Belki bunlardan bir şeyler yapılabilir.", icon = "nuts", weight = 20, blockUse = true, stackable = true},
    {type = 24, variant = 2, variant2 = 1, name = "Silah Susturucusu", description = "Silaha takıldığında ateş sesini azaltır.", icon = "suppressor", weight = 500, blockUse = true, stackable = true},
    {type = 24, variant = 2, variant2 = 2, name = "Silah Dipçiği", description = "Ateş etme sırasında silahı stabilize etmeye yardımcı olur.", icon = "attachmentWeapon", weight = 700, blockUse = true, stackable = true},
   
}


local itemFormat = [[%s    {
        "type": %d,
        "variant": %d,
        "variant2": %d,
        "name": "%s",
        "description": "%s",
        "icon": "%s"
    },
]]
function loadItemsToJSON()
    local text = ""
    local file = fileCreate("itemsList.json")

    for i, v in pairs(itemDetails) do
        text = string.format(itemFormat, text, v.type, v.variant, v.variant2, v.name, v.description, v.icon)
    end

    fileWrite(file, "[\n", string.sub(text, 0, string.len(text) - 2), "\n]")
    fileClose(file)
end
-- loadItemsToJSON()