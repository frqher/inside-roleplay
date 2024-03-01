local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

Dashboard = {}
Dashboard.__index = Dashboard

local guiInfo = {
    time = {},
    descriptionLimit = 250,
    achievementsCount = 6,
    symbolTable = split("私 金 魚 煙 草 莨 東 京 わ た し き ん ぎ ょ た ば こ と う き ょ う ワ タ シ キ ン ギ ョ タ バ コ ト ウ キ ョ ウ", " "),

    suspectedWords = {
        "kurwa",
        "kurwo",
        "pierdole",
        "pierdolić",
        "pierdolic",
        "pierdolony",
        "pojeb",
        "pojebie",
        "pojebany",
        "pojebańcu",
        "pojebancu",
        "jebie",
        "jebać",
        "jebac",
        "chuj",
        "chuju",
        "huj",
        "huju",
        "cwel",
        "cwelu",
        "pizda",
        "pizdo",
        "discord",
        ".gg",

        "davet",
        "katılın",
        "en iyi",
    },

    bg = {
        x = 300/zoom,
        y = 0,
        w = sx - 300/zoom,
        h = sy,
    },

    category = {
        x = 0,
        y = 0,
        w = 300/zoom,
        h = sy,
    },

    account = {
        x = 0,
        y = 0,
        w = 300/zoom,
        h = 280/zoom,
        img = 128/zoom,
    },

    vehicles = {
        visible = 6,
        h = sy/6,
    },

    logs = {
        visible = 10,
        h = sy/10,
    },

    card = {
        w = 300/zoom,
        h = 450/zoom,
        imgSize = 128/zoom,

        prizes = [[
 #aaaaaa- Karta #d45555tekrar çevirme hakkı
 #aaaaaa- Karta #7651b8uyuşturucu #aaaaaa(5min - 10min)
 #aaaaaa- Karta #f28e1cimprezy #aaaaaa(5min - 10min)
 #aaaaaa- Karta #4c9c3dpara #aaaaaa($150 - $500)
 #aaaaaa- Karta #d6a306Gold #aaaaaa(1gün - 5gün)
 #aaaaaa- Karta #31caffDiamond #aaaaaa(1gün - 5gün)
        ]],
    },

    categories = {
        {"Karakterim", "player"},
        {"Karakter Durumu", "description"},
        {"Karakter Özellikleri", "skills"},
        {"Mevcut Araçlar", "vehicle"},
        {"Mevcut Evler", "house"},
        {"Başarımlar", "medal"},
        {"Arkadaşlar", "friends"},
        {"Giriş Logları", "logs"},
        {"Alınan Cezalar", "penalties"},
        {"Günlük Piyango", "cards"},
        {"Referans Kodu", "reference"},
        {"Oyun Ayarları", "settings"},
        {"Oyun Grafikleri", "graphic"},
    },

    reference = {
        w = 500/zoom,
    },

    defaultSettings = {
        ["chat"] = 1,
        ["hud"] = 1,
        ["nicks"] = 1,
        ["fps"] = 0,
        ["advertisement"] = 1,
        ["premium"] = 1,
        ["vehicleEngine"] = 1,
        ["wantRP"] = 0,
        ["characterDesc"] = 1,
        ["smsOff"] = 1,
        ["gpsSound"] = 1,
        ["firstPerson"] = 0,
        ["chatMinified"] = 0,
        ["windRose"] = 1,

        ["water"] = 0,
        ["sky"] = 0,
        ["colors"] = 0,
        ["textures"] = 0,
        ["vehicles"] = 0,
        ["realisticNight"] = 0,
        ["farClipDistance"] = 0,
        ["blurLevel"] = 1,
        ["snow"] = 1,
        ["rain"] = 1,
        ["blipsMapOrder"] = 1,
        ["hoseSmooth"] = 1,
    },

    settingsList = {
        ["game"] = {
            {
                type = "title",
                value = "Arayüz",
            },
            {
                type = "option",
                value = "Sohbet",
                switch = "chat",
            },
            {
                type = "option",
                value = "Ana Arayüz",
                switch = "hud",
            },
            {
                type = "option",
                value = "Oyuncu İsimleri",
                switch = "nicks",
            },
            {
                type = "option",
                value = "FPS",
                switch = "fps",
            },
            {
                type = "option",
                value = "Minimalist Sohbet",
                switch = "chatMinified",
            },
            {
                type = "option",
                value = "Oyuncu Reklamları",
                switch = "advertisement",
            },
            {
                type = "option",
                value = "Pusula",
                switch = "windRose",
            },
            {
                type = "",
                value = "",
            },
            {
                type = "title",
                value = "OYUN",
            },
            {
                type = "option",
                value = "Özel Mesajlar",
                switch = "smsOff",
            },
            {
                type = "option",
                value = "Premium Mesajlar",
                switch = "premium",
            },
            {
                type = "option",
                value = "Araba Sesleri",
                switch = "vehicleEngine",
            },
            {
                type = "option",
                value = "Sesli GPS",
                switch = "gpsSound",
            },
            {
                type = "option",
                value = "Role Girmek İstiyorum",
                switch = "wantRP",
            },
            {
                type = "option",
                value = "Karakter Durumları",
                switch = "characterDesc",
            },
            {
                type = "option",
                value = "FPS Kamera",
                switch = "firstPerson",
            },
        },

        ["graphic"] = {
            {
                type = "title",
                value = "GRAFIKLER",
            },
            {
                type = "option",
                value = "Gerçekçi Deniz",
                switch = "water",
            },
            {
                type = "option",
                value = "Gerçekçi Gökyüzü",
                switch = "sky",
            },
            {
                type = "option",
                value = "Gerçekçi Renkler",
                switch = "colors",
            },
            {
                type = "option",
                value = "Gerçekci Kaplamalar",
                switch = "textures",
            },
            {
                type = "option",
                value = "Gerçekci Araç Gövdeleri",
                switch = "vehicles",
            },
            {
                type = "option",
                value = "Gerçekci Gece",
                switch = "realisticNight",
            },
            {
                type = "option",
                value = "Uzak Mesafe Görüş",
                switch = "farClipDistance",
            },
            {
                type = "option",
                value = "Sürüş sırasında bulanıklık",
                switch = "blurLevel",
            },
            {
                type = "",
                value = "",
            },
            {
                type = "title",
                value = "OPTİMİZASYON",
            },
            {
                type = "option",
                value = "Kar Taneleri",
                switch = "snow",
            },
            {
                type = "option",
                value = "Hava Durumu Ayrıntıları",
                switch = "rain",
            },
            {
                type = "option",
                value = "Kolejność blipów",
                switch = "blipsMapOrder",
            },
            {
                type = "option",
                value = "Hortum Yumuşatma",
                switch = "hoseSmooth",
            },
        },
    },

    skills = {
        ["positive"] = {
            {
                name = "Kas",
                desc = "Karakterin kas derecesi.",
                icon = "strenght",
                index = 1,
                hoverInfo = {
                    {"SAHİP OLMANIN AVANTAJLARI", "info"},
                    {"•	 Envanter kapasitesini arttırır.", "plus"},
                    {"•	 Sopa ve yumruk hasarını arttırır.", "plus"},
                    {""},
                    {"NASIL YÜKSELTİLEBİLİR?", "info"},
                    {"Karakterin kas derecesini artırmak için", "text"},
                    {"spor salonuda ağırlık kaldırın.", "text"},
                    {""},
                    {"NASIL AZALIR?", "info"},
                    {"Bir şey yapmadığınız zaman", "text"},
                    {"ara sıra azalır.", "text"},
                },
            },
            {
                name = "Dayanıklılık",
                desc = "Karakterin Dayanıklılığı.",
                icon = "lungs",
                index = 2,
                hoverInfo = {
                    {"SAHİP OLMANIN AVANTAJLARI", "info"},
                    {"•	 Dalış sırasında daha fazla oksijen.", "plus"},
                    {"", "plus"},
                    {"NASIL YÜKSELTİLEBİLİR?", "info"},
                    {"Dayanıklılığı arttırmak için", "text"},
                    {"sürekli koşun veya", "text"},
                    {"spor salonunda koşu bandını kullanın", "text"},
                    {""},
                    {"NASIL AZALIR?", "info"},
                    {"Çok fazla hareket etmezseniz", "text"},
                    {"ara sıra azalır.", "text"},
                },
            },
            {
                name = "Şoförlük",
                desc = "Karakterin Şoförlük Derecesi",
                icon = "steer",
                index = 3,
                hoverInfo = {
                    {"SAHİP OLMANIN AVANTAJLARI", "info"},
                    {"•	 Araç ile çarptığında daha az hasar alır.", "plus"},
                    {"", "plus"},
                    {"NASIL YÜKSELTİLEBİLİR?", "info"},
                    {"Şoförlük derecesini yükseltmek için", "text"},
                    {"mümkün oldukça farklı arabalar", "text"},
                    {"sürmeyi deneyin", "text"},
                    {""},
                    {"NASIL AZALIR?", "info"},
                    {"Herhangi bir araç kullanmıyorsanız", "text"},
                    {"özellik zaman zaman otomatik olarak azalır.", "text"},
                },
            },
            {
                name = "Silah",
                desc = "Karakterin Silah Derecesi",
                icon = "weapon",
                index = 4,
                hoverInfo = {
                    {"SAHİP OLMANIN AVANTAJLARI", "info"},
                    {"•	 Silahların hasarını yükseltir.", "plus"},
                    {"", "plus"},
                    {"NASIL YÜKSELTİLEBİLİR?", "info"},
                    {"Silah derecesini yükseltmek için", "text"},
                    {"mümkün oldukça farklı silahlar kullanın", "text"},
                    {""},
                    {"NASIL AZALIR?", "info"},
                    {"Herhangi bir silahı ateşlemezseniz", "text"},
                    {"özellik zaman zaman otomatik olarak azalır.", "text"},
                },
            },
            {
                name = "Tıbbi Bilgi",
                desc = "Karakterin Tıbbi Bilgi Derecesi",
                icon = "medicine",
                index = 5,
                hoverInfo = {
                    {"SAHİP OLMANIN AVANTAJLARI", "info"},
                    {"•	 Alınan hasarı azaltır.", "plus"},
                    {"•	 Can veren itemler daha fazla can verir.", "plus"},
                    {"", "plus"},
                    {"NASIL YÜKSELTİLEBİLİR?", "info"},
                    {"Tıbbi Bilgi derecesini yükseltmek için", "text"},
                    {"diğer oyunculara tıbbi yardım", "text"},
                    {"sağlamanız gerekir.", "text"},
                    {""},
                    {"NASIL AZALTILABİLİR?", "info"},
                    {"Tıbbi yardım sağlamazsak", "text"},
                    {"özellik zaman zaman otomatik olarak azalır.", "text"},
                },
            },
        },
        ["negative"] = {
            {
                name = "Obezite",
                desc = "Karakterin obezite derecesi",
                icon = "fat",
                index = 6,
                hoverInfo = {
                    {"ÖZELLİĞİN EKSİLERİ", "info"},
                    {"•	 Karakter koşamaz.", "minus"},
                    {"•	 Karakter zıplayamaz.", "minus"},
                    {"", "plus"},
                    {"NASIL YÜKSELTİLEBİLİR?", "info"},
                    {"Obezite derecesini arttırmak için", "text"},
                    {"çok fazla yemek yemelisiniz.", "text"},
                    {""},
                    {"NASIL AZALTILABİLİR?", "info"},
                    {"Obezite derecesini azaltmak için", "text"},
                    {"spor salonunda egzersiz yapmalısınız.", "text"},
                },
            },
            {
                name = "Kumarbaz",
                desc = "Karakterin kumarbaz derecesi",
                icon = "casino",
                index = 7,
                hoverInfo = {
                    {"ÖZELLİĞİN EKSİLERİ", "info"},
                    {"•	 ALL-IN yaparken ani girişler", "minus"},
                    {"   kumar oyunları", "minus"},
                    {"•	 Daha fazla fiş satın alma", "minus"},
                    {"   kumarhanede", "minus"},
                    {"", "text"},
                    {"NASIL YÜKSELTİLEBİLİR?", "info"},
                    {"Kumar bağımlılığınızı artırmak için", "text"},
                    {"kumarhaneyi sık sık oynamalısınız.", "text"},
                    {""},
                    {"NASIL AZALTILABİLİR?", "info"},
                    {"Kumar bağımlılığı derecesini azaltmak için", "text"},
                    {"kumarhanede oynamayı bırakmalısınız.", "text"},
                    {"Daha yüksek bir bağımlılık düzeyi ile", "text"},
                    {"bir psikolog ile tedavi edilebilirsiniz.", "text"},
                },
            },
            {
                name = "Alkolizm",
                desc = "Karakterin alkolizm derecesi",
                icon = "cheers",
                index = 8,
                hoverInfo = {
                    {"ÖZELLİĞİN EKSİLERİ", "info"},
                    {"•	 Konsekwentna utrata życia", "minus"},
                    {"•	 Sarhoş olmanın etkisi ile akşamdan kalma", "minus"},
                    {" 	  sonsuz yaşam", "minus"},
                    {"", "plus"},
                    {"NASIL YÜKSELTİLEBİLİR?", "info"},
                    {"Alkol bağımlılığı derecesini artırmak için", "text"},
                    {"sık sık alkol almanız gerekir.", "text"},
                    {""},
                    {"NASIL AZALTILABİLİR?", "info"},
                    {"Alkol bağımlılığı derecesini azaltmak için", "text"},
                    {"içmeyi bırakmalısınız.", "text"},
                    {"Daha yüksek bir bağımlılık düzeyi ile", "text"},
                    {"bir psikolog ile tedavi edilebilirsiniz.", "text"},
                },
            },
            {
                name = "Nikotin Bağımlılığı",
                desc = "Karakterin nikotin bağımlılığı derecesi",
                icon = "smoking",
                index = 9,
                hoverInfo = {
                    {"ÖZELLİĞİN EKSİLERİ", "info"},
                    {"•	 Konsekwentna utrata życia", "minus"},
                    {"•	 Karakterin dayanıklılık yeteneğinin", "minus"},
                    {"   yükselmesini engeller", "minus"},
                    {"", "plus"},
                    {"NASIL YÜKSELTİLEBİLİR?", "info"},
                    {"Nikotin bağımlılığı derecesini arttırmak için", "text"},
                    {"sık sık sigara içmeniz gerekir.", "text"},
                    {""},
                    {"NASIL AZALTILABİLİR?", "info"},
                    {"Nikotin bağımlılığınızı azaltmak için", "text"},
                    {"sigarayı bırakın.", "text"},
                    {"Daha yüksek bir bağımlılık düzeyi ile", "text"},
                    {"bir psikolog ile tedavi edilebilirsiniz.", "text"},
                },
            },
            {
                name = "Uyuşturucu Bağımlılığı",
                desc = "Karakterin uyuşturucu bağımlılığı derecesi",
                icon = "pills",
                index = 10,
                hoverInfo = {
                    {"ÖZELLİĞİN EKSİLERİ", "info"},
                    {"•	 Konsekwentna utrata życia", "minus"},
                    {"•	 Uyuşturucu kullanmadan rastgele ilaç", "minus"},
                    {" 	  etkileri", "minus"},
                    {"", "plus"},
                    {"NASIL YÜKSELTİLEBİLİR?", "info"},
                    {"Uyuşturucu bağımlılığı derecesini arttırmak", "text"},
                    {"için sık sık uyuşturucu kullanmanız gerekir.", "text"},
                    {""},
                    {"NASIL AZALTILABİLİR?", "info"},
                    {"Uyuşturucu bağımlılığı derecesini azaltmak", "text"},
                    {"için uyuşturucu kullanımı bırakılmalıdır.", "text"},
                    {"Daha yüksek bir bağımlılık düzeyi ile", "text"},
                    {"bir psikolog ile tedavi edilebilirsiniz.", "text"},
                },
            },
        }
    }
}

function Dashboard:create(...)
    local instance = {}
    setmetatable(instance, Dashboard)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function Dashboard:constructor(...)
    self.alpha = 0
    self.descList = {}

    local savedTime = getElementData(localPlayer, "dashboardTick")
    self.onlineTime = savedTime and savedTime or getTickCount()
    setElementData(localPlayer, "dashboardTick", getTickCount(), false)

    self.premiumDiamond = dxCreateTexture("files/images/diamond.png", "argb", true, "clamp")
    self.premiumGold = dxCreateTexture("files/images/crown.png", "argb", true, "clamp")
    self.premiumMan = dxCreateTexture("files/images/man.png", "argb", true, "clamp")
    self.houseRender = dxCreateTexture("files/images/house_img.png", "argb", true, "clamp")

    self.cardBack = dxCreateTexture("files/images/card_back.png", "argb", true, "clamp")
    self.cardFront = dxCreateTexture("files/images/card_front.png", "argb", true, "clamp")
    self.cardFrontSymbols = dxCreateTexture("files/images/card_frontSymbols.png", "argb", true, "clamp")

    self.chestImage = dxCreateTexture("files/images/chest.png", "argb", true, "clamp")
    self.coinsImage = dxCreateTexture("files/images/coins.png", "argb", true, "clamp")

    self.plrImageMain = exports.TR_images:getImage("skins", getElementModel(localPlayer))

    self.fonts = {}
    self.fonts.nick = exports.TR_dx:getFont(20)
    self.fonts.tab = exports.TR_dx:getFont(16)
    self.fonts.premium = exports.TR_dx:getFont(14)
    self.fonts.category = exports.TR_dx:getFont(14)
    self.fonts.goldDate = exports.TR_dx:getFont(12)
    self.fonts.small = exports.TR_dx:getFont(10)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.scrollKey = function(...) self:scrollKey(...) end
    self.func.mouseClick = function(...) self:mouseClick(...) end
    self.func.buttonClick = function(...) self:buttonClick(...) end
    self.func.switchSelect = function(...) self:switchSelect(...) end
    self.func.switch = function(...) self:switch(...) end

    bindKey("f5", "down", self.func.switch)

    setTimer(function()
        self:loadSettings()
        self:getCharacterDescriptions()
    end, 500, 1)
    return true
end

function Dashboard:switch()
    if self.state == "opened" then
        self:close()
    else
        self:open()
    end
end

function Dashboard:open(...)
    if self.state then return end
    if exports.TR_login:isSpawnSelectEnabled() then return end
    self.vehicleData = nil
    self.houseData = nil
    self.totalPlayers = nil
    self.penalties = nil
    self.logs = nil
    self.friendsData = nil

    local isTutorial = exports.TR_tutorial:isTutorialOpen()
    if isTutorial then
        if isTutorial ~= 11 then return end
        exports.TR_tutorial:setNextState()
    else
        if not exports.TR_dx:canOpenGUI() and not arg[1] then return end
    end

    exports.TR_dx:setOpenGUI(true)
    exports.TR_chat:showCustomChat(false)

    self.tab = 1
    self.state = "opening"
    self.tick = getTickCount()
    self.loaded = nil
    self.rot = 0
    self.revealData = false
    self.vehiclePreview = nil
    self.cardMixed = 0
    self.referenceProgress = 0
    self.openedTick = getTickCount()

    self:getAchievments()

    showCursor(true)
    addEventHandler("onClientKey", root, self.func.scrollKey)
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientClick", root, self.func.mouseClick)
    addEventHandler("guiButtonClick", root, self.func.buttonClick)
    addEventHandler("guiSwitchSelected", root, self.func.switchSelect)

    local data = getElementData(localPlayer, "characterData")
    local uid = getElementData(localPlayer, "characterUID")
    local number = string.format("55%05d", uid)

    self.playerData = {
        UID = uid,
        name = getPlayerName(localPlayer),
        premium = data.premium or "Standard",
        premiumName = data.premium and string.upper(data.premium) or "STANDARD",
        premiumColor = data.premium == "diamond" and {49, 202, 255} or data.premium == "gold" and {214, 163, 6} or {221, 221, 221},
        money = data.money,
        skin = data.skin,
        bankcode = data.bankcode,

        features = getElementData(localPlayer, "characterFeatures")
    }


    if data.premium == "diamond" then
        self.premiumImg = self.premiumDiamond
    elseif data.premium == "gold" then
        self.premiumImg = self.premiumGold
    else
        self.premiumImg = self.premiumMan
    end

    self.referenceCode = teaEncodeBinary(uid, referenceEncryptionKey)

    triggerServerEvent("getDashboardData", resourceRoot)
end

function Dashboard:close(...)
    if not self.loaded then return end
    if self.playingCards then return end
    if exports.TR_dx:isResponseEnabled() then return end

    self.state = "closing"
    self.tick = getTickCount()

    if self.buttons then exports.TR_dx:hideButton(self.buttons) end
    if self.edits then exports.TR_dx:hideEdit(self.edits) end
    if self.switches then exports.TR_dx:hideSwitch(self.switches) end
    exports.TR_dx:hideSwitch(self.previewEnabledSwitch)

    self:removePreview()

    showCursor(false)
    exports.TR_chat:showCustomChat(true)
    removeEventHandler("onClientKey", root, self.func.scrollKey)
    removeEventHandler("onClientClick", root, self.func.mouseClick)
    removeEventHandler("guiButtonClick", root, self.func.buttonClick)
    removeEventHandler("guiSwitchSelected", root, self.func.switchSelect)
end

function Dashboard:destroy()
    if not exports.TR_tutorial:isTutorialOpen() then exports.TR_dx:setOpenGUI(false) end

    if self.buttons then exports.TR_dx:destroyButton(self.buttons) end
    if self.edits then exports.TR_dx:destroyEdit(self.edits) end
    if self.switches then exports.TR_dx:destroySwitch(self.switches) end
    exports.TR_dx:destroySwitch(self.previewEnabledSwitch)

    self.buttons = nil
    self.edits = nil
    self.switches = nil

    removeEventHandler("onClientRender", root, self.func.render)
    guiInfo.info = nil
    self = nil
end

function Dashboard:animateCards()
    if not self.cardTick then return end

    for i, v in pairs(guiInfo.card.cards) do
        if self.cardAnim == "start" then
            local progress = (getTickCount() - (self.cardTick))/500
            guiInfo.card.cards[i].x = interpolateBetween(v.lastX, 0, 0, v.defX, 0, 0, progress, "Linear")

            if progress >= 1 and i == 3 then
                self:moveCards("hideBack")
            end

        elseif self.cardAnim == "hideBack" then
            local progress = (getTickCount() - (self.cardTick))/150
            guiInfo.card.cards[i].w = interpolateBetween(v.lastW, 0, 0, guiInfo.card.w, 0, 0, progress, "Linear")

            if progress >= 1 and i == 3 then
                self:moveCards("revealFront")
            end

        elseif self.cardAnim == "showBack" then
            local progress = (getTickCount() - (self.cardTick))/150
            guiInfo.card.cards[i].w = interpolateBetween(v.lastW, 0, 0, 0, 0, 0, progress, "Linear")

            if progress >= 1 and i == 3 then
                self:moveCards("mixCenter")
            end

        elseif self.cardAnim == "revealFront" then
            local progress = (getTickCount() - (self.cardTick))/150
            guiInfo.card.cards[i].frontW = interpolateBetween(v.lastW, 0, 0, 0, 0, 0, progress, "Linear")

            if progress >= 1 and i == 3 then
                self:moveCards("show")
            end

        elseif self.cardAnim == "hideFront" then
            local progress = (getTickCount() - (self.cardTick))/150
            guiInfo.card.cards[i].frontW = interpolateBetween(0, 0, 0, guiInfo.card.w, 0, 0, progress, "Linear")

            if progress >= 1 and i == 3 then
                self:moveCards("showBack")
            end

        elseif self.cardAnim == "show" then
            local progress = (getTickCount() - (self.cardTick))/3000

            if progress >= 1 and i == 3 then
                self:moveCards("hideFront")
            end

        elseif self.cardAnim == "mixCenter" then
            local progress = (getTickCount() - (self.cardTick))/400
            guiInfo.card.cards[i].x = interpolateBetween(v.lastX, 0, 0, guiInfo.bg.x + (guiInfo.bg.w - guiInfo.card.w)/2, 0, 0, progress, "Linear")

            if progress >= 1 and i == 3 then
                self.cardMixed = self.cardMixed + 1
                if self.cardMixed >= 10 then
                    self:moveCards("pick")
                else

                    local randomCard = math.random(1, 3)
                    while (self.randomMix == randomCard) do
                        randomCard = math.random(1, 3)
                    end
                    self.randomOnTop = math.random(1, 2) == 1 and (randomCard == 2 and false or true) or false
                    self.randomMix = randomCard
                    self.randomMixPick = math.random(1, 2)
                    self.randomMixPick = self.randomMixPick == 2 and 3 or 1
                    self:moveCards("mixDefault")
                end
            end

        elseif self.cardAnim == "mixDefault" then
            local progress = (getTickCount() - (self.cardTick))/200
            guiInfo.card.cards[self.randomMix].x = interpolateBetween(self.randomMix == 2 and guiInfo.card.cards[self.randomMixPick].lastX or guiInfo.card.cards[self.randomMix].lastX, 0, 0, self.randomMix == 2 and guiInfo.card.cards[self.randomMixPick].defX or guiInfo.card.cards[self.randomMix].defX, 0, 0, progress, "Linear")

            if progress >= 1 and i == 3 then
                self:moveCards("mixCenter")
            end

        elseif self.cardAnim == "pick" then
            local progress = (getTickCount() - (self.cardTick))/400
            guiInfo.card.cards[i].x = interpolateBetween(v.lastX, 0, 0, v.defX, 0, 0, progress, "Linear")

            if progress >= 1 and i == 3 then
                self.cardTick = nil
                self.cardAnim = nil
                self.randomMix = nil
                self.randomMixPick = nil
                self.randomOnTop = nil
                self.canPickCard = true
            end

        elseif self.cardAnim == "hideBackPrice" then
            local progress = (getTickCount() - (self.cardTick))/400
            guiInfo.card.cards[self.selectedCard].w = interpolateBetween(guiInfo.card.cards[self.selectedCard].lastW, 0, 0, guiInfo.card.w, 0, 0, progress, "Linear")

            if progress >= 1 and i == 3 then
                self:moveCards("showFrontPrice")
            end

        elseif self.cardAnim == "showFrontPrice" then
            local progress = (getTickCount() - (self.cardTick))/400
            guiInfo.card.cards[self.selectedCard].frontW = interpolateBetween(guiInfo.card.cards[self.selectedCard].lastW, 0, 0, 0, 0, 0, progress, "Linear")

            if progress >= 1 and i == 3 then
                self:moveCards("priceWait")
            end

        elseif self.cardAnim == "priceWait" then
            local progress = (getTickCount() - (self.cardTick))/3000

            if progress >= 1 and i == 3 then
                self:moveCards("priceHideBack")
            end

        elseif self.cardAnim == "priceHideBack" then
            local progress = (getTickCount() - (self.cardTick))/150
            if self.selectedCard ~= i then
                guiInfo.card.cards[i].w = interpolateBetween(guiInfo.card.cards[i].lastW, 0, 0, guiInfo.card.w, 0, 0, progress, "Linear")
            end

            if progress >= 1 and i == 3 then
                self:moveCards("priceRevealFront")
            end

        elseif self.cardAnim == "priceRevealFront" then
            local progress = (getTickCount() - (self.cardTick))/150
            if self.selectedCard ~= i then
                guiInfo.card.cards[i].frontW = interpolateBetween(guiInfo.card.cards[i].lastW, 0, 0, 0, 0, 0, progress, "Linear")
            end

            if progress >= 1 and i == 3 then
                self:moveCards("priceWaitToHide")
            end

        elseif self.cardAnim == "priceWaitToHide" then
            local progress = (getTickCount() - (self.cardTick))/5000

            if progress >= 1 and i == 3 then
                self:moveCards("priceHideFrontAll")
            end

        elseif self.cardAnim == "priceHideFrontAll" then
            local progress = (getTickCount() - (self.cardTick))/150
            guiInfo.card.cards[i].frontW = interpolateBetween(0, 0, 0, guiInfo.card.w, 0, 0, progress, "Linear")

            if progress >= 1 and i == 3 then
                self:moveCards("priceShowBackAll")
            end

        elseif self.cardAnim == "priceShowBackAll" then
            local progress = (getTickCount() - (self.cardTick))/150
            guiInfo.card.cards[i].w = interpolateBetween(v.lastW, 0, 0, 0, 0, 0, progress, "Linear")

            if progress >= 1 and i == 3 then
                self:moveCards("priceMoveToStart")
            end

        elseif self.cardAnim == "priceMoveToStart" then
            local progress = (getTickCount() - (self.cardTick))/500
            guiInfo.card.cards[i].x = interpolateBetween(v.lastX, 0, 0, guiInfo.bg.x + (guiInfo.bg.w - guiInfo.card.w)/2 - guiInfo.card.w + 40/zoom, 0, 0, progress, "Linear")

            if progress >= 1 and i == 3 then
                self.cardTick = nil
                self.cardAnim = nil
                self.playingCards = nil
                self.selectedCard = nil
                self:removeCards()
                self:selectTab(6, true)
            end
        end
    end
end

function Dashboard:animate()
    if not self.tick then return end
    local progress = (getTickCount() - self.tick)/500
    if self.state == "opening" then
      self.alpha = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "Linear")
      if progress >= 1 then
        self.alpha = 1
        self.state = "opened"
        self.tick = nil
      end

    elseif self.state == "closing" then
      self.alpha = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "Linear")
      if progress >= 1 then
        self.alpha = 0
        self.state = nil
        self.tick = nil

        self:destroy()
        return true
      end
    end
end

function Dashboard:render()
    if self:animate() then return end

    dxDrawRectangle(guiInfo.bg.x, guiInfo.bg.y, guiInfo.bg.w, guiInfo.bg.h, tocolor(17, 17, 17, 255 * self.alpha))
    dxDrawRectangle(guiInfo.category.x, guiInfo.category.y, guiInfo.category.w, guiInfo.category.h, tocolor(27, 27, 27, 255 * self.alpha))

    dxDrawImage(guiInfo.category.x + (guiInfo.category.w - guiInfo.account.img)/2, guiInfo.category.y + 40/zoom, guiInfo.account.img, guiInfo.account.img, self.premiumImg, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
    dxDrawText(self.playerData.name, guiInfo.category.x, guiInfo.category.y + guiInfo.account.img + 50/zoom, guiInfo.category.x + guiInfo.category.w, guiInfo.category.y + guiInfo.account.img + 60/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.nick, "center", "top")
    dxDrawText(self.playerData.premiumName, guiInfo.category.x, guiInfo.category.y + guiInfo.account.img + 80/zoom, guiInfo.category.x + guiInfo.category.w, guiInfo.category.y + guiInfo.account.img + 60/zoom, tocolor(self.playerData.premiumColor[1], self.playerData.premiumColor[2], self.playerData.premiumColor[3], 255 * self.alpha), 1/zoom, self.fonts.premium, "center", "top")
    dxDrawText(self.playerData.premiumDate or "", guiInfo.category.x, guiInfo.category.y + guiInfo.account.img + 105/zoom, guiInfo.category.x + guiInfo.category.w, guiInfo.category.y + guiInfo.account.img + 60/zoom, tocolor(120, 120, 120, 255 * self.alpha), 1/zoom, self.fonts.small, "center", "top")

    self:renderCategories()
    self:renderCategory()

    -- if self.previews then
    --     for _, v in pairs(self.previews) do
    --         setElementAlpha(v.element, 255 * self.alpha)
    --     end
    -- end
end

function Dashboard:getAchievments(text)
    self.achievements, self.achievementsEarned = exports.TR_achievements:getPlayerAchievements()
    for i, v in pairs(self.achievements) do
        if not v.earned then
            v.name = self:getRandomText(v.name)
            v.desc = self:getRandomText(v.desc)
            v.notEarned = self:getRandomText("Nie zdobyto")
        end
    end
end

function Dashboard:getRandomText(text)
    local symbolTable = split("実 績 の ロ ッ ク が 解 除 さ れ て い ま せ ん", " ")
    local newText = ""
    for letter in utf8.gmatch(text, ".") do
        if letter == " " then
            newText = newText.."  "

        elseif letter ~= "," then
            newText = newText..guiInfo.symbolTable[math.random(1, #guiInfo.symbolTable)]
        end
    end
    return newText
end

function Dashboard:renderCategory()
    if not self.loaded then
        self.rot = self.rot + 2
        if self.rot == 360 then self.rot = 0 end
        dxDrawImage(guiInfo.bg.x + (guiInfo.bg.w - 128/zoom)/2, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2 - 10/zoom, 128/zoom, 128/zoom, "files/images/loader.png", self.rot, 0, 0, tocolor(180, 180, 180, 255 * self.alpha))
        dxDrawText("Veri yükleniyor...", guiInfo.bg.x + (guiInfo.bg.w - 128/zoom)/2, guiInfo.bg.y + (guiInfo.bg.h + 128/zoom)/2 + 10/zoom, guiInfo.bg.x + (guiInfo.bg.w + 128/zoom)/2, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "center", "top")
        return
    end

    local tab = guiInfo.categories[self.tab][2]
    if tab == "player" then
        dxDrawText("HESAP BİLGİLERİ", guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 - 30/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.tab, "left", "top", false, false, false, true)
        dxDrawText(string.format("ID: #b89935%s", self.playerData.UID), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText(string.format("Serial: #b89935%s", self.revealData and self.playerData.serial or "Gizli"), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 25/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText(string.format("Sahip IP: #b89935%s", self.revealData and self.playerData.createIP or "Gizli"), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 50/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText(string.format("Mevcut IP: #b89935%s", self.revealData and self.playerData.ip or "Gizli"), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 75/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)

        dxDrawText("KARAKTER BİLGİLERİ", guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 140/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.tab, "left", "top", false, false, false, true)
        dxDrawText(string.format("İsim: #b89935%s", self.playerData.name), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 170/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText(string.format("Skin ID: #b89935%s", tostring(self.playerData.skin)), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 195/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText(string.format("Oluşturma Tarihi: #b89935%s", self.playerData.created), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 220/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText(string.format("Toplam Çevrimiçi Süre: #b89935%s", self:getTimeInSeconds(self.playerData.online + (getTickCount() - self.onlineTime)/1000)), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 245/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText(string.format("Çevrimiçi Süre: #b89935%s", self:getTimeInSeconds((getTickCount() - self.onlineTime)/1000)), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 270/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText(string.format("Para: #b89935$%.2f", self.playerData.money), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 295/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText(string.format("Bankadaki Para: #b89935%s", self.playerData.bankcode and string.format("$%.2f", self.playerData.bankmoney) or "Hesap Yok"), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 320/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText(string.format("Lisanlar: #b89935%s", self.playerData.licence or "Yok"), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 345/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText(string.format("Ehliyet: #b89935%s", self.playerData.vehicleLicence), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 370/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText(string.format("Karakter Puanı: #b89935%d pkt", getElementData(localPlayer, "characterPoints") or 0), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 395/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)

        dxDrawText("Karakteri 3D Göster", guiInfo.bg.x + guiInfo.bg.w/2 + 60/zoom, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2 + 100/zoom, guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2 + 130/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "center", false, false, false, true)

        if not self.enabledPreviews then
            dxDrawImage(guiInfo.bg.x + 300/zoom, guiInfo.bg.y + (guiInfo.bg.h - 600/zoom)/2, 500/zoom, 500/zoom, self.plrImageMain, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
        end

        if (getTickCount() - self.onlineTime)/1000 > 3600 and not guiInfo.time.online1 then
            guiInfo.time.online1 = true
            exports.TR_achievements:addAchievements("online1")
        end
        if (getTickCount() - self.onlineTime)/1000 > 2 * 3600 and not guiInfo.time.online2 then
            guiInfo.time.online2 = true
            exports.TR_achievements:addAchievements("online2")
        end
        if (getTickCount() - self.onlineTime)/1000 > 5 * 3600 and not guiInfo.time.online5 then
            guiInfo.time.online5 = true
            exports.TR_achievements:addAchievements("online5")
        end
        if (getTickCount() - self.onlineTime)/1000 > 12 * 3600 and not guiInfo.time.online12 then
            guiInfo.time.online12 = true
            exports.TR_achievements:addAchievements("online12")
        end
        if (getTickCount() - self.onlineTime)/1000 > 24 * 3600 and not guiInfo.time.online24 then
            guiInfo.time.online24 = true
            exports.TR_achievements:addAchievements("online24")
        end

        if self.playerData.online + (getTickCount() - self.onlineTime)/1000 > 10 * 3600 and not guiInfo.time.totalTime10 then
            guiInfo.time.totalTime10 = true
            exports.TR_achievements:addAchievements("totalTime10")
        end
        if self.playerData.online + (getTickCount() - self.onlineTime)/1000 > 50 * 3600 and not guiInfo.time.totalTime50 then
            guiInfo.time.totalTime50 = true
            exports.TR_achievements:addAchievements("totalTime50")
        end
        if self.playerData.online + (getTickCount() - self.onlineTime)/1000 > 100 * 3600 and not guiInfo.time.totalTime100 then
            guiInfo.time.totalTime100 = true
            exports.TR_achievements:addAchievements("totalTime100")
        end
        if self.playerData.online + (getTickCount() - self.onlineTime)/1000 > 250 * 3600 and not guiInfo.time.totalTime250 then
            guiInfo.time.totalTime250 = true
            exports.TR_achievements:addAchievements("totalTime250")
        end
        if self.playerData.online + (getTickCount() - self.onlineTime)/1000 > 500 * 3600 and not guiInfo.time.totalTime500 then
            guiInfo.time.totalTime500 = true
            exports.TR_achievements:addAchievements("totalTime500")
        end
        if self.playerData.online + (getTickCount() - self.onlineTime)/1000 > 1000 * 3600 and not guiInfo.time.totalTime1000 then
            guiInfo.time.totalTime1000 = true
            exports.TR_achievements:addAchievements("totalTime1000")
        end

    elseif tab == "friends" then
        dxDrawText("Arkadaş Listesi", sx/2 - 460/zoom, sy/2 - 400/zoom, sx/2 + 600/zoom, sy, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.tab, "center", "top")

        if #self.friendsData > 0 then
            local i = 1
            for k = 1, 5 * 2 do
                local v = self.friendsData[k + self.scroll]
                if v then
                    if k%2 == 1 then
                        dxDrawImage(sx/2 - 460/zoom, sy/2 - 360/zoom + (i-1) * 120/zoom + 17/zoom, 100/zoom, 100/zoom, v.skin, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
                        dxDrawText(string.format("%s (ID: %d)", v.username, v.UID), sx/2 - 350/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom, guiInfo.bg.x + (guiInfo.bg.w + 128/zoom)/2, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.tab, "left", "top")

                        if not v.friendsFor then
                            if v.isTarget then
                                dxDrawText("Onay bekleniyor...", sx/2 - 350/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 28/zoom, sx/2 + 50/zoom, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2, tocolor(184, 153, 53, 255 * self.alpha), 1/zoom, self.fonts.goldDate, "left", "top")

                                if self:isMouseInPosition(sx/2 - 350/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, 100/zoom, 30/zoom) then
                                    self:drawBackground(sx/2 - 350/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, 100/zoom, 30/zoom, tocolor(37, 87, 37, 255 * self.alpha), 4)
                                    dxDrawText("Onayla", sx/2 - 350/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, sx/2 - 250/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 85/zoom, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.small, "center", "center")
                                else
                                    self:drawBackground(sx/2 - 350/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, 100/zoom, 30/zoom, tocolor(37, 67, 37, 255 * self.alpha), 4)
                                    dxDrawText("Onayla", sx/2 - 350/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, sx/2 - 250/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 85/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.small, "center", "center")
                                end

                                if self:isMouseInPosition(sx/2 - 245/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, 200/zoom, 30/zoom) then
                                    self:drawBackground(sx/2 - 245/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, 100/zoom, 30/zoom, tocolor(87, 47, 47, 255 * self.alpha), 4)
                                    dxDrawText("Reddet", sx/2 - 245/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, sx/2 - 145/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 85/zoom, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.small, "center", "center")
                                else
                                    self:drawBackground(sx/2 - 245/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, 100/zoom, 30/zoom, tocolor(67, 37, 37, 255 * self.alpha), 4)
                                    dxDrawText("Reddet", sx/2 - 245/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, sx/2 - 145/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 85/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.small, "center", "center")
                                end

                            else
                                dxDrawText("Arkadaşlık isteği gönderildi...", sx/2 - 350/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 28/zoom, sx/2 + 50/zoom, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2, tocolor(184, 153, 53, 255 * self.alpha), 1/zoom, self.fonts.goldDate, "left", "top")

                                if self:isMouseInPosition(sx/2 - 350/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, 100/zoom, 30/zoom) then
                                    self:drawBackground(sx/2 - 350/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, 100/zoom, 30/zoom, tocolor(87, 37, 37, 255 * self.alpha), 4)
                                    dxDrawText("Kapat", sx/2 - 350/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, sx/2 - 250/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 85/zoom, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.small, "center", "center")
                                else
                                    self:drawBackground(sx/2 - 350/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, 100/zoom, 30/zoom, tocolor(67, 37, 37, 255 * self.alpha), 4)
                                    dxDrawText("Kapat", sx/2 - 350/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, sx/2 - 250/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 85/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.small, "center", "center")
                                end
                            end
                        else
                            dxDrawText(string.format("Son Görülme: %s", v.lastOnline), sx/2 - 350/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 28/zoom, sx/2 + 50/zoom, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2, tocolor(184, 153, 53, 255 * self.alpha), 1/zoom, self.fonts.goldDate, "left", "top")
                            dxDrawText(string.format("Ekleme tarihi: %s", v.friendsFor), sx/2 - 350/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 48/zoom, sx/2 + 50/zoom, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2, tocolor(184, 153, 53, 255 * self.alpha), 1/zoom, self.fonts.goldDate, "left", "top")

                            if self:isMouseInPosition(sx/2 - 350/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 75/zoom, 200/zoom, 30/zoom) then
                                self:drawBackground(sx/2 - 350/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 75/zoom, 200/zoom, 30/zoom, tocolor(87, 37, 37, 255 * self.alpha), 4)
                                dxDrawText("Arkadaşlıkdan Sil", sx/2 - 350/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 75/zoom, sx/2 - 150/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 105/zoom, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.small, "center", "center")
                            else
                                self:drawBackground(sx/2 - 350/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 75/zoom, 200/zoom, 30/zoom, tocolor(67, 37, 37, 255 * self.alpha), 4)
                                dxDrawText("Arkadaşlıkdan Sil", sx/2 - 350/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 75/zoom, sx/2 - 150/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 105/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.small, "center", "center")
                            end
                        end

                    else
                        dxDrawImage(sx/2 + 190/zoom, sy/2 - 360/zoom + (i-1) * 120/zoom + 17/zoom, 100/zoom, 100/zoom, v.skin, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
                        dxDrawText(string.format("%s (ID: %d)", v.username, v.UID), sx/2 + 300/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom, guiInfo.bg.x + (guiInfo.bg.w + 128/zoom)/2, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.tab, "left", "top")

                        if not v.friendsFor then
                            if v.isTarget then
                                dxDrawText("Onay bekleniyor...", sx/2 + 300/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 28/zoom, sx/2 + 50/zoom, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2, tocolor(184, 153, 53, 255 * self.alpha), 1/zoom, self.fonts.goldDate, "left", "top")

                                if self:isMouseInPosition(sx/2 + 300/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, 100/zoom, 30/zoom) then
                                    self:drawBackground(sx/2 + 300/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, 100/zoom, 30/zoom, tocolor(37, 87, 37, 255 * self.alpha), 4)
                                    dxDrawText("Onayla", sx/2 + 300/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, sx/2 + 400/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 85/zoom, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.small, "center", "center")
                                else
                                    self:drawBackground(sx/2 + 300/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, 100/zoom, 30/zoom, tocolor(37, 67, 37, 255 * self.alpha), 4)
                                    dxDrawText("Onayla", sx/2 + 300/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, sx/2 + 400/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 85/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.small, "center", "center")
                                end

                                if self:isMouseInPosition(sx/2 + 405/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, 200/zoom, 30/zoom) then
                                    self:drawBackground(sx/2 + 405/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, 100/zoom, 30/zoom, tocolor(87, 47, 47, 255 * self.alpha), 4)
                                    dxDrawText("Reddet", sx/2 + 405/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, sx/2 + 505/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 85/zoom, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.small, "center", "center")
                                else
                                    self:drawBackground(sx/2 + 405/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, 100/zoom, 30/zoom, tocolor(67, 37, 37, 255 * self.alpha), 4)
                                    dxDrawText("Reddet", sx/2 + 405/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, sx/2 + 505/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 85/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.small, "center", "center")
                                end

                            else
                                dxDrawText("Arkadaşlık isteği gönderildi...", sx/2 + 300/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 28/zoom, sx/2 + 50/zoom, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2, tocolor(184, 153, 53, 255 * self.alpha), 1/zoom, self.fonts.goldDate, "left", "top")

                                if self:isMouseInPosition(sx/2 + 300/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, 100/zoom, 30/zoom) then
                                    self:drawBackground(sx/2 + 300/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, 100/zoom, 30/zoom, tocolor(87, 37, 37, 255 * self.alpha), 4)
                                    dxDrawText("Kapat", sx/2 + 300/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, sx/2 + 400/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 85/zoom, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.small, "center", "center")
                                else
                                    self:drawBackground(sx/2 + 300/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, 100/zoom, 30/zoom, tocolor(67, 37, 37, 255 * self.alpha), 4)
                                    dxDrawText("Kapat", sx/2 + 300/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, sx/2 + 400/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 85/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.small, "center", "center")
                                end
                            end
                        else
                            dxDrawText(string.format("Son Görülme: %s", v.lastOnline), sx/2 + 300/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 28/zoom, sx/2 + 50/zoom, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2, tocolor(184, 153, 53, 255 * self.alpha), 1/zoom, self.fonts.goldDate, "left", "top")
                            dxDrawText(string.format("Ekleme tarihi: %s", v.friendsFor), sx/2 + 300/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 48/zoom, sx/2 + 50/zoom, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2, tocolor(184, 153, 53, 255 * self.alpha), 1/zoom, self.fonts.goldDate, "left", "top")

                            if self:isMouseInPosition(sx/2 + 300/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 75/zoom, 200/zoom, 30/zoom) then
                                self:drawBackground(sx/2 + 300/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 75/zoom, 200/zoom, 30/zoom, tocolor(87, 37, 37, 255 * self.alpha), 4)
                                dxDrawText("Arkadaşlıkdan Sil", sx/2 + 300/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 75/zoom, sx/2 + 500/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 105/zoom, tocolor(255, 255, 255, 255 * self.alpha), 1/zoom, self.fonts.small, "center", "center")
                            else
                                self:drawBackground(sx/2 + 300/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 75/zoom, 200/zoom, 30/zoom, tocolor(67, 37, 37, 255 * self.alpha), 4)
                                dxDrawText("Arkadaşlıkdan Sil", sx/2 + 300/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 75/zoom, sx/2 + 500/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 105/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.small, "center", "center")
                            end
                        end

                        i = i + 1
                    end
                end
            end
        else

            dxDrawImage(sx/2 - 460/zoom + (1060/zoom - 128/zoom)/2, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2 - 40/zoom, 128/zoom, 128/zoom, "files/images/sad.png", 0, 0, 0, tocolor(180, 180, 180, 255 * self.alpha))
            dxDrawText("Hiç arkadaşın yok!\nBiraz arkadaşın edin!", sx/2 - 460/zoom, guiInfo.bg.y + (guiInfo.bg.h + 128/zoom)/2 - 20/zoom, sx/2 + 600/zoom, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "center", "top")
        end

        dxDrawText("Arkadaş Ekle", sx/2 - 460/zoom, sy/2 + 320/zoom, sx/2 + 600/zoom, sy, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.tab, "center", "top")

    elseif tab == "medal" then
        dxDrawText("Başarımla", sx/2 - 460/zoom, sy/2 - 120/zoom * guiInfo.achievementsCount/2 - 70/zoom, sx/2 + 600/zoom, sy, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.tab, "center", "top")

        local i = 1
        for k = 1, guiInfo.achievementsCount * 2 do
            local v = self.achievements[k + self.scroll]
            if v then
                if k%2 == 1 then
                    if v.earned then
                        local percent = (self.earnedAchievementCount[v.ID] or 0)/self.totalPlayers
                        dxDrawImage(sx/2 - 460/zoom, sy/2 - 120/zoom * guiInfo.achievementsCount/2 + (i-1) * 120/zoom, 80/zoom, 80/zoom, "files/images/medal.png", 0, 0, 0, tocolor(184, 153, 53, 255 * self.alpha))
                        dxDrawText(v.name, sx/2 - 350/zoom, sy/2 - 120/zoom * guiInfo.achievementsCount/2 + (i-1) * 120/zoom, guiInfo.bg.x + (guiInfo.bg.w + 128/zoom)/2, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.tab, "left", "top")
                        dxDrawText(string.format("Alındı: %s", v.earned), sx/2 - 350/zoom, sy/2 - 120/zoom * guiInfo.achievementsCount/2 + (i-1) * 120/zoom + 28/zoom, sx/2 + 50/zoom, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2, tocolor(184, 153, 53, 255 * self.alpha), 1/zoom, self.fonts.goldDate, "left", "top")

                        self:drawBackground(sx/2 - 350/zoom, sy/2 - 120/zoom * guiInfo.achievementsCount/2 + (i-1) * 120/zoom + 53/zoom, 300/zoom, 25/zoom, tocolor(27, 27, 27, 255 * self.alpha), 4)
                        self:drawBackground(sx/2 - 350/zoom, sy/2 - 120/zoom * guiInfo.achievementsCount/2 + (i-1) * 120/zoom + 53/zoom, 300/zoom * percent/100, 25/zoom, tocolor(184, 153, 53, 150 * self.alpha), 4)
                        dxDrawText(string.format("%.2f%% (%d/%d) tamamlandı", percent * 100, self.earnedAchievementCount[v.ID] or 0, self.totalPlayers), sx/2 - 350/zoom, sy/2 - 120/zoom * guiInfo.achievementsCount/2 + (i-1) * 120/zoom + 53/zoom, guiInfo.bg.x + 610/zoom, sy/2 - 120/zoom * guiInfo.achievementsCount/2 + (i-1) * 120/zoom + 78/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.small, "center", "center")

                    else
                        dxDrawImage(sx/2 - 460/zoom, sy/2 - 120/zoom * guiInfo.achievementsCount/2 + (i-1) * 120/zoom, 80/zoom, 80/zoom, "files/images/medalB.png", 0, 0, 0, tocolor(170, 170, 170, 150 * self.alpha))
                        dxDrawText(v.name, sx/2 - 350/zoom, sy/2 - 120/zoom * guiInfo.achievementsCount/2 + (i-1) * 120/zoom, guiInfo.bg.x + (guiInfo.bg.w + 128/zoom)/2, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2, tocolor(170, 170, 170, 150 * self.alpha), 1/zoom, self.fonts.tab, "left", "top")
                        dxDrawText(v.notEarned, sx/2 - 350/zoom, sy/2 - 120/zoom * guiInfo.achievementsCount/2 + (i-1) * 120/zoom + 28/zoom, sx/2 + 50/zoom, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2, tocolor(184, 153, 53, 150 * self.alpha), 1/zoom, self.fonts.goldDate, "left", "top")

                        self:drawBackground(sx/2 - 350/zoom, sy/2 - 120/zoom * guiInfo.achievementsCount/2 + (i-1) * 120/zoom + 53/zoom, 300/zoom, 25/zoom, tocolor(27, 27, 27, 255 * self.alpha), 4)
                        dxDrawText("Kilitli", sx/2 - 350/zoom, sy/2 - 120/zoom * guiInfo.achievementsCount/2 + (i-1) * 120/zoom + 53/zoom, guiInfo.bg.x + 610/zoom, sy/2 - 120/zoom * guiInfo.achievementsCount/2 + (i-1) * 120/zoom + 78/zoom, tocolor(140, 140, 140, 150 * self.alpha), 1/zoom, self.fonts.small, "center", "center")
                    end

                else
                    if v.earned then
                        local percent = (self.earnedAchievementCount[v.ID] or 0)/self.totalPlayers
                        dxDrawImage(sx/2 + 190/zoom, sy/2 - 120/zoom * guiInfo.achievementsCount/2 + (i-1) * 120/zoom, 80/zoom, 80/zoom, "files/images/medal.png", 0, 0, 0, tocolor(184, 153, 53, 255 * self.alpha))
                        dxDrawText(v.name, sx/2 + 300/zoom, sy/2 - 120/zoom * guiInfo.achievementsCount/2 + (i-1) * 120/zoom, guiInfo.bg.x + (guiInfo.bg.w + 128/zoom)/2, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.tab, "left", "top")
                        dxDrawText(string.format("Alındı: %s", v.earned), sx/2 + 300/zoom, sy/2 - 120/zoom * guiInfo.achievementsCount/2 + (i-1) * 120/zoom + 28/zoom, sx/2 + 700/zoom, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2, tocolor(184, 153, 53, 255 * self.alpha), 1/zoom, self.fonts.goldDate, "left", "top")

                        self:drawBackground(sx/2 + 300/zoom, sy/2 - 120/zoom * guiInfo.achievementsCount/2 + (i-1) * 120/zoom + 53/zoom, 300/zoom, 25/zoom, tocolor(27, 27, 27, 255 * self.alpha), 4)
                        self:drawBackground(sx/2 + 300/zoom, sy/2 - 120/zoom * guiInfo.achievementsCount/2 + (i-1) * 120/zoom + 53/zoom, 300/zoom * percent/100, 25/zoom, tocolor(184, 153, 53, 150 * self.alpha), 4)
                        dxDrawText(string.format("%.2f%% (%d/%d) tamamlandı", percent, self.earnedAchievementCount[v.ID] or 0, self.totalPlayers), sx/2 + 300/zoom, sy/2 - 120/zoom * guiInfo.achievementsCount/2 + (i-1) * 120/zoom + 53/zoom, sx/2 + 600/zoom, sy/2 - 120/zoom * guiInfo.achievementsCount/2 + (i-1) * 120/zoom + 78/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.small, "center", "center")

                    else
                        dxDrawImage(sx/2 + 190/zoom, sy/2 - 120/zoom * guiInfo.achievementsCount/2 + (i-1) * 120/zoom, 80/zoom, 80/zoom, "files/images/medalB.png", 0, 0, 0, tocolor(170, 170, 170, 150 * self.alpha))
                        dxDrawText(v.name, sx/2 + 300/zoom, sy/2 - 120/zoom * guiInfo.achievementsCount/2 + (i-1) * 120/zoom, guiInfo.bg.x + (guiInfo.bg.w + 128/zoom)/2, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2, tocolor(170, 170, 170, 150 * self.alpha), 1/zoom, self.fonts.tab, "left", "top")
                        dxDrawText(v.notEarned, sx/2 + 300/zoom, sy/2 - 120/zoom * guiInfo.achievementsCount/2 + (i-1) * 120/zoom + 28/zoom, guiInfo.bg.x + (guiInfo.bg.w + 128/zoom)/2, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2, tocolor(184, 153, 53, 150 * self.alpha), 1/zoom, self.fonts.goldDate, "left", "top")

                        self:drawBackground(sx/2 + 300/zoom, sy/2 - 120/zoom * guiInfo.achievementsCount/2 + (i-1) * 120/zoom + 53/zoom, 300/zoom, 25/zoom, tocolor(27, 27, 27, 255 * self.alpha), 4)
                        dxDrawText("Kilitli", sx/2 + 300/zoom, sy/2 - 120/zoom * guiInfo.achievementsCount/2 + (i-1) * 120/zoom + 53/zoom, sx/2 + 600/zoom, sy/2 - 120/zoom * guiInfo.achievementsCount/2 + (i-1) * 120/zoom + 78/zoom, tocolor(140, 140, 140, 150 * self.alpha), 1/zoom, self.fonts.small, "center", "center")
                    end

                    i = i + 1
                end
            end
        end
        dxDrawText(string.format("Toplam Başarımlar: %d%% (%d/%d)", self.achievementsEarned/#self.achievements * 100, self.achievementsEarned, #self.achievements), sx/2 - 460/zoom, sy/2 + 120/zoom * guiInfo.achievementsCount/2, sx/2 + 600/zoom, sy, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.premium, "center", "top")

    elseif tab == "skills" then
        dxDrawText("OLUMLU ÖZELLİKLER", guiInfo.bg.x + 200/zoom, sy/2 - 120/zoom * #guiInfo.skills["positive"]/2 - 50/zoom, sx/2 + 50/zoom, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.tab, "center", "top", false, false, false, true)

        local hover = false
        for i, v in pairs(guiInfo.skills["positive"]) do
            local percent = self.playerData.features[v.index]/100
            if self:isMouseInPosition(sx/2 - 465/zoom, sy/2 - 120/zoom * #guiInfo.skills["positive"]/2 + (i-1) * 120/zoom - 5/zoom, 430/zoom, 90/zoom) then
                hover = {"positive", i}
            end

            dxDrawImage(sx/2 - 460/zoom, sy/2 - 120/zoom * #guiInfo.skills["positive"]/2 + (i-1) * 120/zoom, 80/zoom, 80/zoom, string.format("files/images/%s.png", v.icon), 0, 0, 0, tocolor(170, 170, 170, 255 * self.alpha))
            dxDrawText(v.name, sx/2 - 350/zoom, sy/2 - 120/zoom * #guiInfo.skills["positive"]/2 + (i-1) * 120/zoom, guiInfo.bg.x + (guiInfo.bg.w + 128/zoom)/2, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.tab, "left", "top")
            dxDrawText(v.desc, sx/2 - 350/zoom, sy/2 - 120/zoom * #guiInfo.skills["positive"]/2 + (i-1) * 120/zoom + 28/zoom, guiInfo.bg.x + (guiInfo.bg.w + 128/zoom)/2, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2, tocolor(184, 153, 53, 255 * self.alpha), 1/zoom, self.fonts.goldDate, "left", "top")

            self:drawBackground(sx/2 - 350/zoom, sy/2 - 120/zoom * #guiInfo.skills["positive"]/2 + (i-1) * 120/zoom + 53/zoom, 300/zoom, 25/zoom, tocolor(27, 27, 27, 255 * self.alpha), 4)
            self:drawBackground(sx/2 - 350/zoom, sy/2 - 120/zoom * #guiInfo.skills["positive"]/2 + (i-1) * 120/zoom + 53/zoom, 300/zoom * percent, 25/zoom, tocolor(184, 153, 53, 150 * self.alpha), 4)
            dxDrawText(string.format("%d%%", self.playerData.features[v.index]), sx/2 - 350/zoom, sy/2 - 120/zoom * #guiInfo.skills["positive"]/2 + (i-1) * 120/zoom + 53/zoom, guiInfo.bg.x + 610/zoom, sy/2 - 120/zoom * #guiInfo.skills["positive"]/2 + (i-1) * 120/zoom + 78/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.goldDate, "center", "center")
        end

        dxDrawText("OLUMSUZ ÖZELLİKLER", sx/2 + 190/zoom, sy/2 - 120/zoom * #guiInfo.skills["negative"]/2 - 50/zoom, sx/2 + 690/zoom, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.tab, "center", "top", false, false, false, true)

        for i, v in pairs(guiInfo.skills["negative"]) do
            local percent = self.playerData.features[v.index]/100
            if self:isMouseInPosition(sx/2 + 185/zoom, sy/2 - 120/zoom * #guiInfo.skills["positive"]/2 + (i-1) * 120/zoom - 5/zoom, 430/zoom, 90/zoom) then
                hover = {"negative", i}
            end

            dxDrawImage(sx/2 + 190/zoom, sy/2 - 120/zoom * #guiInfo.skills["negative"]/2 + (i-1) * 120/zoom, 80/zoom, 80/zoom, string.format("files/images/%s.png", v.icon), 0, 0, 0, tocolor(170, 170, 170, 255 * self.alpha))
            dxDrawText(v.name, sx/2 + 300/zoom, sy/2 - 120/zoom * #guiInfo.skills["negative"]/2 + (i-1) * 120/zoom, guiInfo.bg.x + (guiInfo.bg.w + 128/zoom)/2, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.tab, "left", "top")
            dxDrawText(v.desc, sx/2 + 300/zoom, sy/2 - 120/zoom * #guiInfo.skills["negative"]/2 + (i-1) * 120/zoom + 28/zoom, guiInfo.bg.x + (guiInfo.bg.w + 128/zoom)/2, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2, tocolor(184, 153, 53, 255 * self.alpha), 1/zoom, self.fonts.goldDate, "left", "top")

            self:drawBackground(sx/2 + 300/zoom, sy/2 - 120/zoom * #guiInfo.skills["negative"]/2 + (i-1) * 120/zoom + 53/zoom, 300/zoom, 25/zoom, tocolor(27, 27, 27, 255 * self.alpha), 4)
            self:drawBackground(sx/2 + 300/zoom, sy/2 - 120/zoom * #guiInfo.skills["negative"]/2 + (i-1) * 120/zoom + 53/zoom, 300/zoom * percent, 25/zoom, tocolor(184, 153, 53, 150 * self.alpha), 4)
            dxDrawText(string.format("%d%%", self.playerData.features[v.index]), sx/2 + 300/zoom, sy/2 - 120/zoom * #guiInfo.skills["negative"]/2 + (i-1) * 120/zoom + 53/zoom, sx/2 + 600/zoom, sy/2 - 120/zoom * #guiInfo.skills["negative"]/2 + (i-1) * 120/zoom + 78/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.goldDate, "center", "center")
        end

        dxDrawText("Daha fazla bilgi edinmek için bir özelliğin üzerine gelin.", sx/2 - 460/zoom, sy/2 + 120/zoom * #guiInfo.skills["negative"]/2, sx/2 + 600/zoom, sy, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.premium, "center", "top")

        if hover then
            local cx, cy = getCursorPosition()
            local cx, cy = cx * sx + 7, cy * sy + 7

            local details = guiInfo.skills[hover[1]][hover[2]].hoverInfo
            if cx and cy and details then
                local height, top = 0, 0
                for i, v in pairs(details) do
                    height = height + (v[2] == "info" and 26/zoom or 20/zoom)
                end
                self:drawBackground(cx, cy, 340/zoom, height + 10/zoom, tocolor(37, 37, 37, 255 * self.alpha), 4)

                for i, v in pairs(details) do
                    if v[2] == "info" then
                        dxDrawText(v[1], cx + 5/zoom, cy + 5/zoom + top, cx + 345/zoom, cy + 5/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.premium, "center", "top")

                    elseif v[2] == "plus" then
                        dxDrawText(v[1], cx + 5/zoom, cy + 5/zoom + top, cx + 5/zoom, cy + 5/zoom, tocolor(60, 160, 60, 255 * self.alpha), 1/zoom, self.fonts.goldDate, "left", "top")

                    elseif v[2] == "minus" then
                        dxDrawText(v[1], cx + 5/zoom, cy + 5/zoom + top, cx + 5/zoom, cy + 5/zoom, tocolor(160, 60, 60, 255 * self.alpha), 1/zoom, self.fonts.goldDate, "left", "top")

                    elseif v[2] == "text" then
                        dxDrawText(v[1], cx + 5/zoom, cy + 5/zoom + top, cx + 5/zoom, cy + 5/zoom, tocolor(160, 160, 160, 255 * self.alpha), 1/zoom, self.fonts.goldDate, "left", "top")
                    end
                    top = top + (v[2] == "info" and 26/zoom or 20/zoom)
                end
            end
        end


    elseif tab == "description" then
        dxDrawText("KAYITLI DURUMLAR", guiInfo.bg.x + 300/zoom, guiInfo.bg.y + 150/zoom, guiInfo.bg.x + guiInfo.bg.w - 300/zoom, guiInfo.bg.y + (guiInfo.bg.h + guiInfo.card.h)/2, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.tab, "center", "top", false, false, false, true)

        for i = 1, 5 do
            local desc = self.descList[i]
            if desc then
                dxDrawRectangle(guiInfo.bg.x + 300/zoom, guiInfo.bg.y + 190/zoom + 75/zoom * (i-1), guiInfo.bg.w - 600/zoom, 70/zoom, tocolor(27, 27, 27, 255 * self.alpha))
                dxDrawText(string.wrap(desc, guiInfo.bg.w - guiInfo.bg.x - 370/zoom, 1/zoom, self.fonts.goldDate, true), guiInfo.bg.x + 310/zoom, guiInfo.bg.y + 190/zoom + 75/zoom * (i-1), guiInfo.bg.x + guiInfo.bg.w - 350/zoom, guiInfo.bg.y + 260/zoom + 75/zoom * (i-1), tocolor(150, 150, 150, 255 * self.alpha), 1/zoom, self.fonts.goldDate, "left", "center", true, true, false, true)

                if self:isMouseInPosition(guiInfo.bg.x + guiInfo.bg.w - 300/zoom - 35/zoom, guiInfo.bg.y + 202/zoom + 75/zoom * (i-1), 16/zoom, 16/zoom) then
                    dxDrawImage(guiInfo.bg.x + guiInfo.bg.w - 300/zoom - 35/zoom, guiInfo.bg.y + 202/zoom + 75/zoom * (i-1), 16/zoom, 16/zoom, "files/images/use.png", 0, 0, 0, tocolor(220, 220, 220, 255 * self.alpha))
                else
                    dxDrawImage(guiInfo.bg.x + guiInfo.bg.w - 300/zoom - 35/zoom, guiInfo.bg.y + 202/zoom + 75/zoom * (i-1), 16/zoom, 16/zoom, "files/images/use.png", 0, 0, 0, tocolor(180, 180, 180, 255 * self.alpha))
                end
                if self:isMouseInPosition(guiInfo.bg.x + guiInfo.bg.w - 300/zoom - 35/zoom, guiInfo.bg.y + 232/zoom + 75/zoom * (i-1), 16/zoom, 16/zoom) then
                    dxDrawImage(guiInfo.bg.x + guiInfo.bg.w - 300/zoom - 35/zoom, guiInfo.bg.y + 232/zoom + 75/zoom * (i-1), 16/zoom, 16/zoom, "files/images/trash.png", 0, 0, 0, tocolor(220, 220, 220, 255 * self.alpha))
                else
                    dxDrawImage(guiInfo.bg.x + guiInfo.bg.w - 300/zoom - 35/zoom, guiInfo.bg.y + 232/zoom + 75/zoom * (i-1), 16/zoom, 16/zoom, "files/images/trash.png", 0, 0, 0, tocolor(180, 180, 180, 255 * self.alpha))
                end
            end
        end

        dxDrawText("DURUM OLUŞTUR", guiInfo.bg.x + 300/zoom, guiInfo.bg.y + 620/zoom, guiInfo.bg.x + guiInfo.bg.w - 300/zoom, guiInfo.bg.y + (guiInfo.bg.h + guiInfo.card.h)/2, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.tab, "center", "top", false, false, false, true)
        dxDrawText("ÖN İZLEME", guiInfo.bg.x + 300/zoom, guiInfo.bg.y + 780/zoom, guiInfo.bg.x + guiInfo.bg.w - 300/zoom, guiInfo.bg.y + (guiInfo.bg.h + guiInfo.card.h)/2, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.premium, "center", "top", false, false, false, true)
        dxDrawText(string.wrap(guiGetText(self.edits.charDesc) or "", guiInfo.bg.w - guiInfo.bg.x - 300/zoom, 1/zoom, self.fonts.goldDate, true), guiInfo.bg.x + 300/zoom, guiInfo.bg.y + 810/zoom, guiInfo.bg.x + guiInfo.bg.w - 300/zoom, guiInfo.bg.y + 810/zoom + 70/zoom, tocolor(150, 150, 150, 255 * self.alpha), 1/zoom, self.fonts.goldDate, "center", "center", true, true, false, true)


    elseif tab == "vehicle" and not self.vehiclePreview then
        if #self.vehicleData < 1 then
            dxDrawImage(guiInfo.bg.x + (guiInfo.bg.w - 128/zoom)/2, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2 - 10/zoom, 128/zoom, 128/zoom, "files/images/sad.png", 0, 0, 0, tocolor(180, 180, 180, 255 * self.alpha))
            dxDrawText(string.format("Herhangi bir aracınız yok.\nSahip olabilceğiniz maksimum araç sayısı: %d.", self.playerData.maxVehicles), guiInfo.bg.x + (guiInfo.bg.w - 128/zoom)/2, guiInfo.bg.y + (guiInfo.bg.h + 128/zoom)/2 + 10/zoom, guiInfo.bg.x + (guiInfo.bg.w + 128/zoom)/2, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "center", "top")

        else
            for i = 1, guiInfo.vehicles.visible do
                if self.vehicleData[i + self.scroll] then
                    if self:isMouseInPosition(guiInfo.bg.x, guiInfo.bg.y + (i-1) * guiInfo.vehicles.h, guiInfo.bg.w - 550/zoom, guiInfo.vehicles.h) then
                        dxDrawRectangle(guiInfo.bg.x, guiInfo.bg.y + (i-1) * guiInfo.vehicles.h, guiInfo.bg.w - 550/zoom, guiInfo.vehicles.h, tocolor(22, 22, 22, 255 * self.alpha))
                    end
                    if self.vehicleData[i + self.scroll].isRented then
                        dxDrawText(string.format("%s (%d)", self:getVehicleName(self.vehicleData[i + self.scroll].model), self.vehicleData[i + self.scroll].ID), guiInfo.bg.x + 550/zoom, guiInfo.bg.y + (i-1) * guiInfo.vehicles.h + 25/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(21, 163, 191, 255 * self.alpha), 1/zoom, self.fonts.tab, "left", "top", false, false, false, true)
                    else
                        dxDrawText(string.format("%s (%d)", self:getVehicleName(self.vehicleData[i + self.scroll].model), self.vehicleData[i + self.scroll].ID), guiInfo.bg.x + 550/zoom, guiInfo.bg.y + (i-1) * guiInfo.vehicles.h + 25/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.tab, "left", "top", false, false, false, true)
                    end
                    dxDrawText(string.format("Plaka: #b89935%s", self.vehicleData[i + self.scroll].plateText and string.format("SA %s", self.vehicleData[i + self.scroll].plateText) or string.format("SA %05d", self.vehicleData[i + self.scroll].ID)), guiInfo.bg.x + 550/zoom, guiInfo.bg.y + (i-1) * guiInfo.vehicles.h + 55/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
                    dxDrawText(string.format("Depo Tipi: #b89935%s", self.vehicleData[i + self.scroll].engineType == "d" and "Diesel" or "Benzyna"), guiInfo.bg.x + 550/zoom, guiInfo.bg.y + (i-1) * guiInfo.vehicles.h + 80/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
                    dxDrawText(string.format("Motor: #b89935%s", self.vehicleData[i + self.scroll].engineCapacity), guiInfo.bg.x + 550/zoom, guiInfo.bg.y + (i-1) * guiInfo.vehicles.h + 105/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
                    dxDrawText(string.format("Konum: #b89935%s", self.vehicleData[i + self.scroll].parking), guiInfo.bg.x + 550/zoom, guiInfo.bg.y + (i-1) * guiInfo.vehicles.h + 130/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
                end

                if not self.enabledPreviews and self.vehicleData[i + self.scroll].img then
                    dxDrawImage(guiInfo.bg.x + 80/zoom, guiInfo.bg.y + (i-1) * guiInfo.vehicles.h - 50/zoom, 400/zoom, 300/zoom, self.vehicleData[i + self.scroll].img, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
                end
            end
            dxDrawImage(guiInfo.bg.x + guiInfo.bg.w - 350/zoom, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2 - 35/zoom, 128/zoom, 128/zoom, "files/images/bored.png", 0, 0, 0, tocolor(180, 180, 180, 255 * self.alpha))
            dxDrawText(string.format("Arabalarından sıkıldınmı?\nYeni bir araba al veya modifiye dene?\n%d/%d araca sahipsiniz.", self.playerData.vehicleCount, self.playerData.maxVehicles), guiInfo.bg.x + guiInfo.bg.w - 350/zoom, guiInfo.bg.y + (guiInfo.bg.h + 128/zoom)/2 - 15/zoom, guiInfo.bg.x + guiInfo.bg.w - 222/zoom, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "center", "top")

        end

    elseif tab == "vehicle" and self.vehiclePreview then
        dxDrawText("ARAÇ BİLGİSİ", guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.tab, "left", "top", false, false, false, true)
        dxDrawText(string.format("ID: #b89935%s", self.vehicleData[self.vehiclePreview].ID), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 30/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText(string.format("Durum: #b89935%s", self.vehicleData[self.vehiclePreview].isRented and "Kiralık Araç" or "Kendi Aracın"), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 55/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText(string.format("Sahip ID: #b89935%d", self.vehicleData[self.vehiclePreview].ownedPlayer), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 80/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)

        dxDrawText("TEKNİK VERİ", guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 140/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.tab, "left", "top", false, false, false, true)
        dxDrawText(string.format("Model: #b89935%s", self.vehicleData[self.vehiclePreview].model), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 170/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText(string.format("İsim: #b89935%s", self:getVehicleName(self.vehicleData[self.vehiclePreview].model)), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 195/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText(string.format("Depo Tipi: #b89935%s", self.vehicleData[self.vehiclePreview].engineType == "d" and "Diesel" or "Benzyna"), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 220/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText(string.format("Motor: #b89935%s", self.vehicleData[self.vehiclePreview].engineCapacity), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 245/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText(string.format("Plaka: #b89935%s", self.vehicleData[self.vehiclePreview].plateText and string.format("SA %s", self.vehicleData[self.vehiclePreview].plateText) or string.format("SA %05d", self.vehicleData[self.vehiclePreview].ID)), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 270/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText(string.format("Alım Tarihi: #b89935%s", self.vehicleData[self.vehiclePreview].boughtDate), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 295/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText(string.format("Konum: #b89935%s", self.vehicleData[self.vehiclePreview].parking), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 320/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)

        if not self.enabledPreviews and self.vehicleData[self.vehiclePreview].img then
            dxDrawImage(guiInfo.bg.x + 300/zoom, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2, 500/zoom, 400/zoom, self.vehicleData[self.vehiclePreview].img, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
        end

        dxDrawText("SON SÜRÜCÜLER", guiInfo.bg.x + guiInfo.bg.w/2 + 400/zoom, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.tab, "left", "top", false, false, false, true)
        for i, v in pairs(self.drivers) do
            dxDrawText(v, guiInfo.bg.x + guiInfo.bg.w/2 + 400/zoom, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 30/zoom + (i-1) * 25/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        end

    elseif tab == "house" and not self.houseSelected then
        if #self.houseData < 1 then
            dxDrawImage(guiInfo.bg.x + (guiInfo.bg.w - 128/zoom)/2, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2 - 10/zoom, 128/zoom, 128/zoom, "files/images/sad.png", 0, 0, 0, tocolor(180, 180, 180, 255 * self.alpha))
            dxDrawText(string.format("Herhangi bir mülkünüz yok.\nSahip olabilceğiniz maksimum adet: %d.", self.playerData.maxHouse), guiInfo.bg.x + (guiInfo.bg.w - 128/zoom)/2, guiInfo.bg.y + (guiInfo.bg.h + 128/zoom)/2 + 10/zoom, guiInfo.bg.x + (guiInfo.bg.w + 128/zoom)/2, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "center", "top")

        else
            for i = 1, guiInfo.logs.visible do
                if self.houseData[i + self.scroll] then
                    if self:isMouseInPosition(guiInfo.bg.x, guiInfo.bg.y + (i-1) * guiInfo.logs.h, guiInfo.bg.w - 550/zoom, guiInfo.logs.h) then
                        dxDrawRectangle(guiInfo.bg.x, guiInfo.bg.y + (i-1) * guiInfo.logs.h, guiInfo.bg.w - 550/zoom, guiInfo.logs.h, tocolor(22, 22, 22, 255 * self.alpha))
                    end
                    dxDrawImage(guiInfo.bg.x + 50/zoom, guiInfo.bg.y + (guiInfo.logs.h - 64/zoom)/2 + (i-1) * guiInfo.logs.h, 64/zoom, 64/zoom, self.houseRender, 0, 0, 0, tocolor(200, 200, 200, 255 * self.alpha))

                    if self.houseData[i + self.scroll].rent then
                        dxDrawText(string.format("%s (%d)", self.houseData[i + self.scroll].size, self.houseData[i + self.scroll].ID), guiInfo.bg.x + 164/zoom, guiInfo.bg.y + (i-1) * guiInfo.logs.h + 25/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(21, 163, 191, 255 * self.alpha), 1/zoom, self.fonts.tab, "left", "top", false, false, false, true)
                    else
                        dxDrawText(string.format("%s (%d)", self.houseData[i + self.scroll].size, self.houseData[i + self.scroll].ID), guiInfo.bg.x + 164/zoom, guiInfo.bg.y + (i-1) * guiInfo.logs.h + 25/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.tab, "left", "top", false, false, false, true)
                    end
                    dxDrawText(string.format("Konum: #b89935%s", self.houseData[i + self.scroll].pos), guiInfo.bg.x + 164/zoom, guiInfo.bg.y + (i-1) * guiInfo.logs.h + 55/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
                end
            end
            dxDrawImage(guiInfo.bg.x + guiInfo.bg.w - 350/zoom, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2 - 35/zoom, 128/zoom, 128/zoom, "files/images/bored.png", 0, 0, 0, tocolor(180, 180, 180, 255 * self.alpha))
            dxDrawText(string.format("Evinizin manzarasından sıkıldınız mı?\nEv değişikliği bir kurtuluş olmalı!\n%d/%d %s.", self.playerData.houseCount, self.playerData.maxHouse, self.playerData.maxHouse == 1 and "evler" or "evler"), guiInfo.bg.x + guiInfo.bg.w - 350/zoom, guiInfo.bg.y + (guiInfo.bg.h + 128/zoom)/2 - 15/zoom, guiInfo.bg.x + guiInfo.bg.w - 222/zoom, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "center", "top")

        end

    elseif tab == "house" and self.houseSelected then
        dxDrawImage(guiInfo.bg.x + 600/zoom, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2, 128/zoom, 128/zoom, self.houseRender, 0, 0, 0, tocolor(200, 200, 200, 255 * self.alpha))
        dxDrawText("MÜLK BİLGİLERİ", guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 20/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.tab, "left", "top", false, false, false, true)
        dxDrawText(string.format("ID: #b89935%d", self.houseData[self.houseSelected].ID), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 50/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText(string.format("Durum: #b89935%s", self.houseData[self.houseSelected].rent and "Kiralık Ev" or "Kendi Evin" ), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 75/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText(string.format("Sahip ID: #b89935%s", self.houseData[self.houseSelected].owner), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 100/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)

        dxDrawText("MÜLK DETAYLARI", guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 160/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.tab, "left", "top", false, false, false, true)
        dxDrawText(string.format("Typ posiadłości: #b89935%s", self.houseData[self.houseSelected].size), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 190/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText(string.format("Günlük kira: #b89935$%s", self.houseData[self.houseSelected].price), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 215/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText(string.format("Konum: #b89935%s", self.houseData[self.houseSelected].pos), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 240/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText(string.format("Mülkün Büyüklüğü: #b89935%dm×%dm", self.houseData[self.houseSelected].interiorSize, self.houseData[self.houseSelected].interiorSize), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 265/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText(string.format("Kira bitiş tarihi: #b89935%s", self.houseData[self.houseSelected].date), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 290/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)

    elseif tab == "logs" and not self.logSelected then
        for i = 1, guiInfo.logs.visible do
            if self.logs[i + self.scroll] then
                if self:isMouseInPosition(guiInfo.bg.x, guiInfo.bg.y + (i-1) * guiInfo.logs.h, guiInfo.bg.w - 550/zoom, guiInfo.logs.h) then
                    dxDrawRectangle(guiInfo.bg.x, guiInfo.bg.y + (i-1) * guiInfo.logs.h, guiInfo.bg.w - 550/zoom, guiInfo.logs.h, tocolor(22, 22, 22, 255 * self.alpha))
                end
                dxDrawImage(guiInfo.bg.x + 50/zoom, guiInfo.bg.y + (guiInfo.logs.h - 64/zoom)/2 + (i-1) * guiInfo.logs.h, 64/zoom, 64/zoom, self.logs[i + self.scroll].img, 0, 0, 0, tocolor(200, 200, 200, 255 * self.alpha))
                dxDrawText(string.format("%s", self.logs[i + self.scroll].title), guiInfo.bg.x + 164/zoom, guiInfo.bg.y + (i-1) * guiInfo.logs.h + 25/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.tab, "left", "top", false, false, false, true)
                dxDrawText(string.format("#b89935%s", self.logs[i + self.scroll].text), guiInfo.bg.x + 164/zoom, guiInfo.bg.y + (i-1) * guiInfo.logs.h + 55/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
            end
        end
        dxDrawImage(guiInfo.bg.x + guiInfo.bg.w - 350/zoom, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2 - 35/zoom, 128/zoom, 128/zoom, "files/images/happy.png", 0, 0, 0, tocolor(180, 180, 180, 255 * self.alpha))
        dxDrawText("Herşey yolunda mı?\nBu, hesabınızın güvende olduğunun bir işaretidir..", guiInfo.bg.x + guiInfo.bg.w - 350/zoom, guiInfo.bg.y + (guiInfo.bg.h + 128/zoom)/2 - 15/zoom, guiInfo.bg.x + guiInfo.bg.w - 222/zoom, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "center", "top")


    elseif tab == "logs" and self.logSelected then
        dxDrawImage(guiInfo.bg.x + 600/zoom, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2, 128/zoom, 128/zoom, self.logs[self.logSelected].img, 0, 0, 0, tocolor(200, 200, 200, 255 * self.alpha))
        dxDrawText(self.logs[self.logSelected].title, guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 95/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.tab, "left", "top", false, false, false, true)
        dxDrawText(string.format("Kayıt: #b89935%s", self.logs[self.logSelected].text), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 125/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText(string.format("Tarih: #b89935%s", self.logs[self.logSelected].date), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 150/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText(string.format("Serial: #b89935%s", self.revealData and (self.logs[self.logSelected].serial and self.logs[self.logSelected].serial or "Nie połączony") or "Ukryte"), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 175/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText(string.format("IP: #b89935%s", self.revealData and (self.logs[self.logSelected].ip and self.logs[self.logSelected].ip or "Nie połączony") or "Ukryte"), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 200/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)

    elseif tab == "penalties" and not self.penaltySelected then
        if #self.penalties < 1 then
            dxDrawImage(guiInfo.bg.x + (guiInfo.bg.w - 128/zoom)/2, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2 - 10/zoom, 128/zoom, 128/zoom, "files/images/happy.png", 0, 0, 0, tocolor(180, 180, 180, 255 * self.alpha))
            dxDrawText("Herhangi bir cezanız yok.\nSeninle gurur duyuyoruz!", guiInfo.bg.x + (guiInfo.bg.w - 128/zoom)/2, guiInfo.bg.y + (guiInfo.bg.h + 128/zoom)/2 + 10/zoom, guiInfo.bg.x + (guiInfo.bg.w + 128/zoom)/2, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "center", "top")

        else
            for i = 1, guiInfo.logs.visible do
                if self.penalties[i + self.scroll] then
                    if self:isMouseInPosition(guiInfo.bg.x, guiInfo.bg.y + (i-1) * guiInfo.logs.h, guiInfo.bg.w - 550/zoom, guiInfo.logs.h) then
                        dxDrawRectangle(guiInfo.bg.x, guiInfo.bg.y + (i-1) * guiInfo.logs.h, guiInfo.bg.w - 550/zoom, guiInfo.logs.h, tocolor(22, 22, 22, 255 * self.alpha))
                    end
                    dxDrawImage(guiInfo.bg.x + 50/zoom, guiInfo.bg.y + (guiInfo.logs.h - 64/zoom)/2 + (i-1) * guiInfo.logs.h, 64/zoom, 64/zoom, string.format("files/images/%s.png", self.penalties[i + self.scroll].type), 0, 0, 0, tocolor(200, 200, 200, 255 * self.alpha))
                    dxDrawText(string.format("%s", self.penalties[i + self.scroll].title), guiInfo.bg.x + 164/zoom, guiInfo.bg.y + (i-1) * guiInfo.logs.h + 25/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.tab, "left", "top", false, false, false, true)
                    dxDrawText(string.format("#b89935%s", self.penalties[i + self.scroll].reason), guiInfo.bg.x + 164/zoom, guiInfo.bg.y + (i-1) * guiInfo.logs.h + 55/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
                end
            end
            dxDrawImage(guiInfo.bg.x + guiInfo.bg.w - 350/zoom, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2 - 35/zoom, 128/zoom, 128/zoom, "files/images/tear.png", 0, 0, 0, tocolor(180, 180, 180, 255 * self.alpha))
            dxDrawText("Uygunsuz bir şey mi yaptın?\nDavranışınız için üzgünüz.", guiInfo.bg.x + guiInfo.bg.w - 350/zoom, guiInfo.bg.y + (guiInfo.bg.h + 128/zoom)/2 - 15/zoom, guiInfo.bg.x + guiInfo.bg.w - 222/zoom, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "center", "top")
        end

    elseif tab == "penalties" and self.penaltySelected then
        dxDrawImage(guiInfo.bg.x + 600/zoom, guiInfo.bg.y + (guiInfo.bg.h - 128/zoom)/2, 128/zoom, 128/zoom, string.format("files/images/%s.png", self.penalties[self.penaltySelected].type), 0, 0, 0, tocolor(200, 200, 200, 255 * self.alpha))
        dxDrawText(self.penalties[self.penaltySelected].title, guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 95/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.tab, "left", "top", false, false, false, true)
        dxDrawText(string.format("Sebep: #b89935%s", self.penalties[self.penaltySelected].reason), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 125/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText(string.format("Tarih: #b89935%s %s", self.penalties[self.penaltySelected].time, self.penalties[self.penaltySelected].timeEnd and "- "..self.penalties[self.penaltySelected].timeEnd or ""), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 150/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText(string.format("Serial: #b89935%s", self.revealData and (self.penalties[self.penaltySelected].serial and self.penalties[self.penaltySelected].serial or "Nie połączony") or "Ukryte"), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 175/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText(string.format("Admin: #b89935%s", self.penalties[self.penaltySelected].admin), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 400/zoom)/2 + 200/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)

    elseif tab == "cards" and self.playingCards then
        self:animateCards()
        for i, v in pairs(guiInfo.card.cards) do
            dxDrawImage(v.x + v.w/2, guiInfo.bg.y + (guiInfo.bg.h - guiInfo.card.h)/2 - 20/zoom, guiInfo.card.w - v.w, guiInfo.card.h, self.cardBack, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
            dxDrawImage(v.x + v.frontW/2, guiInfo.bg.y + (guiInfo.bg.h - guiInfo.card.h)/2 - 20/zoom, guiInfo.card.w - v.frontW, guiInfo.card.h, self.cardFront, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))

            if self.cardPrices then
                if self.cardPrices[i].renderTarget then
                    dxDrawImage(v.x + v.frontW/2, guiInfo.bg.y + (guiInfo.bg.h - guiInfo.card.h)/2 - 20/zoom, guiInfo.card.w - v.frontW, guiInfo.card.h, self.cardPrices[i].renderTarget, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
                end
            end

            if self:isMouseInPosition(v.x + v.w/2, guiInfo.bg.y + (guiInfo.bg.h - guiInfo.card.h)/2 - 20/zoom, guiInfo.card.w - v.w, guiInfo.card.h) and self.canPickCard then
                self:drawBackground(v.x + v.w/2, guiInfo.bg.y + (guiInfo.bg.h - guiInfo.card.h)/2 - 20/zoom, guiInfo.card.w - v.w, guiInfo.card.h, tocolor(255, 255, 255, 30 * self.alpha), 7)
            end
        end
        if self.randomOnTop and self.cardAnim == "mixCenter" then
            local v = guiInfo.card.cards[self.randomMix]
            dxDrawImage(v.x + v.w/2, guiInfo.bg.y + (guiInfo.bg.h - guiInfo.card.h)/2 - 20/zoom, guiInfo.card.w - v.w, guiInfo.card.h, self.cardBack, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
        end
        if self.randomMix == 3 and self.cardAnim == "mixCenter" then
            dxDrawImage(guiInfo.bg.x + (guiInfo.bg.w - guiInfo.card.w)/2, guiInfo.bg.y + (guiInfo.bg.h - guiInfo.card.h)/2 - 20/zoom, guiInfo.card.w, guiInfo.card.h, self.cardBack, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
        end
        if self.canPickCard then
            dxDrawText("Bir kart seçin ve ödül kazanın.", guiInfo.bg.x, guiInfo.bg.y + (guiInfo.bg.h - guiInfo.card.h)/2 + guiInfo.card.h + 30/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y +  guiInfo.bg.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.tab, "center", "top", false, false, false, true)
        end

    elseif tab == "cards" and not self.playingCards then
        dxDrawImage(guiInfo.bg.x + (guiInfo.bg.w - guiInfo.card.w)/2 - guiInfo.card.w + 44/zoom, guiInfo.bg.y + (guiInfo.bg.h - guiInfo.card.h)/2 - 16/zoom, guiInfo.card.w, guiInfo.card.h, self.cardBack, 0, 0, 0, tocolor(150, 150, 150, 255 * self.alpha))
        dxDrawImage(guiInfo.bg.x + (guiInfo.bg.w - guiInfo.card.w)/2 - guiInfo.card.w + 42/zoom, guiInfo.bg.y + (guiInfo.bg.h - guiInfo.card.h)/2 - 18/zoom, guiInfo.card.w, guiInfo.card.h, self.cardBack, 0, 0, 0, tocolor(150, 150, 150, 255 * self.alpha))
        dxDrawImage(guiInfo.bg.x + (guiInfo.bg.w - guiInfo.card.w)/2 - guiInfo.card.w + 40/zoom, guiInfo.bg.y + (guiInfo.bg.h - guiInfo.card.h)/2 - 20/zoom, guiInfo.card.w, guiInfo.card.h, self.cardBack, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))

        dxDrawText("OYUN KURALLARI", guiInfo.bg.x + (guiInfo.bg.w - guiInfo.card.w)/2 - guiInfo.card.w + 450/zoom, guiInfo.bg.y + (guiInfo.bg.h - guiInfo.card.h)/2 - 30/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + guiInfo.card.h)/2, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.tab, "left", "top", false, false, false, true)
        dxDrawText("Oyun 24 saatte bir oynanabilir.\nBaşladıktan sonra, mevcut ödülleri içeren üç rastgele kart göreceksiniz. Bir süre sonra\nkartlar ters çevrilir ve karıştırılır. \nÖyleyse kartları çevirmek sizin işiniz. Tersine çevrilen kartın ödülü \nhesabınıza yatırılacaktır.", guiInfo.bg.x + (guiInfo.bg.w - guiInfo.card.w)/2 - guiInfo.card.w + 450/zoom, guiInfo.bg.y + (guiInfo.bg.h - guiInfo.card.h)/2, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + guiInfo.card.h)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
        dxDrawText("MEVCUT ÖDÜLLER", guiInfo.bg.x + (guiInfo.bg.w - guiInfo.card.w)/2 - guiInfo.card.w + 450/zoom, guiInfo.bg.y + (guiInfo.bg.h - guiInfo.card.h)/2 + 200/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + guiInfo.card.h)/2, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.tab, "left", "top", false, false, false, true)
        dxDrawText(guiInfo.card.prizes, guiInfo.bg.x + (guiInfo.bg.w - guiInfo.card.w)/2 - guiInfo.card.w + 450/zoom, guiInfo.bg.y + (guiInfo.bg.h - guiInfo.card.h)/2 + 230/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + guiInfo.card.h)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)

        if self.playerData.cardTime then
            dxDrawText("Bir sonraki ücretsiz oyun: "..self:getTimeInSeconds(self.playerData.cardTime - (getTickCount() - self.openedTick)/1000), guiInfo.bg.x + (guiInfo.bg.w - guiInfo.card.w)/2 - guiInfo.card.w + 450/zoom, guiInfo.bg.y + (guiInfo.bg.h + guiInfo.card.h)/2 - 5/zoom, guiInfo.bg.x + (guiInfo.bg.w - guiInfo.card.w)/2 - guiInfo.card.w + 700/zoom, guiInfo.bg.y + (guiInfo.bg.h + guiInfo.card.h)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.small, "center", "top", false, false, false, true)
        end

    elseif tab == "reference" then
        dxDrawImage(guiInfo.bg.x + guiInfo.bg.w/2 + guiInfo.reference.w - 81/zoom, guiInfo.bg.y + guiInfo.bg.h/2 - 211/zoom, 162/zoom, 161/zoom, self.chestImage, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
        dxDrawImage(guiInfo.bg.x + guiInfo.bg.w/2 - guiInfo.reference.w - 50/zoom, guiInfo.bg.y + guiInfo.bg.h/2 - 140/zoom, 100/zoom, 100/zoom, self.coinsImage, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))

        local progress = math.max(math.min((self.playerData.referencedPlayers - self.playerData.referenced * 10)/10, 1), 0)
        self.referenceProgress = progress > self.referenceProgress and math.min(self.referenceProgress + 0.01, progress) or math.max(self.referenceProgress - 0.01, progress)

        dxDrawRectangle(guiInfo.bg.x + guiInfo.bg.w/2 - guiInfo.reference.w, guiInfo.bg.y + guiInfo.bg.h/2 - 10/zoom, guiInfo.reference.w * 2, 20/zoom, tocolor(67, 67, 67, 255 * self.alpha))

        if self.referenceProgress >= 0.5 then -- Center
            dxDrawRectangle(guiInfo.bg.x + guiInfo.bg.w/2 - 2/zoom, guiInfo.bg.y + guiInfo.bg.h/2 - 10/zoom, 4/zoom, 40/zoom, tocolor(184, 153, 53, 255 * self.alpha))
            dxDrawText("5", guiInfo.bg.x + guiInfo.bg.w/2 - 2/zoom, guiInfo.bg.y + guiInfo.bg.h/2 + 30/zoom, guiInfo.bg.x + guiInfo.bg.w/2 + 2/zoom, guiInfo.bg.y + guiInfo.bg.h/2 + 30/zoom, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.category, "center", "top")
        else
            dxDrawRectangle(guiInfo.bg.x + guiInfo.bg.w/2 - 2/zoom, guiInfo.bg.y + guiInfo.bg.h/2 + 10/zoom, 4/zoom, 20/zoom, tocolor(67, 67, 67, 255 * self.alpha))
            dxDrawText("5", guiInfo.bg.x + guiInfo.bg.w/2 - 2/zoom, guiInfo.bg.y + guiInfo.bg.h/2 + 30/zoom, guiInfo.bg.x + guiInfo.bg.w/2 + 2/zoom, guiInfo.bg.y + guiInfo.bg.h/2 + 30/zoom, tocolor(140, 140, 140, 255 * self.alpha), 1/zoom, self.fonts.category, "center", "top")
        end

        if self.referenceProgress >= 1 then -- End
            dxDrawRectangle(guiInfo.bg.x + guiInfo.bg.w/2 + guiInfo.reference.w - 4/zoom, guiInfo.bg.y + guiInfo.bg.h/2 - 30/zoom, 4/zoom, 60/zoom, tocolor(184, 153, 53, 255 * self.alpha))
            dxDrawText("10", guiInfo.bg.x + guiInfo.bg.w/2 + guiInfo.reference.w - 4/zoom, guiInfo.bg.y + guiInfo.bg.h/2 + 30/zoom, guiInfo.bg.x + guiInfo.bg.w/2 + guiInfo.reference.w, guiInfo.bg.y + guiInfo.bg.h/2 + 30/zoom, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.category, "center", "top")
        else
            dxDrawRectangle(guiInfo.bg.x + guiInfo.bg.w/2 + guiInfo.reference.w - 4/zoom, guiInfo.bg.y + guiInfo.bg.h/2 - 30/zoom, 4/zoom, 60/zoom, tocolor(67, 67, 67, 255 * self.alpha))
            dxDrawText("10", guiInfo.bg.x + guiInfo.bg.w/2 + guiInfo.reference.w - 4/zoom, guiInfo.bg.y + guiInfo.bg.h/2 + 30/zoom, guiInfo.bg.x + guiInfo.bg.w/2 + guiInfo.reference.w, guiInfo.bg.y + guiInfo.bg.h/2 + 30/zoom, tocolor(140, 140, 140, 255 * self.alpha), 1/zoom, self.fonts.category, "center", "top")
        end

        dxDrawText("0", guiInfo.bg.x + guiInfo.bg.w/2 - guiInfo.reference.w, guiInfo.bg.y + guiInfo.bg.h/2 + 30/zoom, guiInfo.bg.x + guiInfo.bg.w/2 - guiInfo.reference.w + 4/zoom, guiInfo.bg.y + guiInfo.bg.h/2 + 30/zoom, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.category, "center", "top")
        dxDrawRectangle(guiInfo.bg.x + guiInfo.bg.w/2 - guiInfo.reference.w, guiInfo.bg.y + guiInfo.bg.h/2 - 30/zoom, 4/zoom, 60/zoom, tocolor(184, 153, 53, 255 * self.alpha)) -- Start
        dxDrawRectangle(guiInfo.bg.x + guiInfo.bg.w/2 - guiInfo.reference.w, guiInfo.bg.y + guiInfo.bg.h/2 - 10/zoom, 10/zoom, 20/zoom, tocolor(184, 153, 53, 255 * self.alpha))
        dxDrawRectangle(guiInfo.bg.x + guiInfo.bg.w/2 - guiInfo.reference.w, guiInfo.bg.y + guiInfo.bg.h/2 - 10/zoom, guiInfo.reference.w * 2 * self.referenceProgress, 20/zoom, tocolor(184, 153, 53, 255 * self.alpha))

        dxDrawText("SİSTEM NASIL ÇALIŞIR", guiInfo.bg.x + guiInfo.bg.w/2 - guiInfo.reference.w + 260/zoom, guiInfo.bg.y + (guiInfo.bg.h - guiInfo.card.h)/2 - 40/zoom, guiInfo.bg.x + guiInfo.bg.w/2 - guiInfo.reference.w - 200/zoom, guiInfo.bg.y + (guiInfo.bg.h + guiInfo.card.h)/2, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.tab, "left", "top", false, false, false, true)
        dxDrawText("Każdy gracz otrzymuje unikalny kod, który jest \njego prywatnym reflinkiem. Rejestracja nowego \nkonta z wykorzystaniem takiego kodu odblokowywuje\njego właścicielowi nagrodę. Za każde 10 kont\nzarejestrowanych z Twojego reflinku, które przegrają\nminimalnie 3h na serwerze, otrzymasz konto Gold \nna okres 3 dni oraz $5000, a gracz korzystający z kodu\notrzymuje $500 na start!", guiInfo.bg.x + guiInfo.bg.w/2 - guiInfo.reference.w + 260/zoom, guiInfo.bg.y + (guiInfo.bg.h - guiInfo.card.h)/2 - 10/zoom, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + guiInfo.card.h)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)

        if self:isMouseInPosition(guiInfo.bg.x + (guiInfo.bg.w - 250/zoom)/2, guiInfo.bg.y + guiInfo.bg.h/2 + 65/zoom, 250/zoom, 55/zoom) then
            dxDrawText(string.format("Kodun: #d4af37%s", self.referenceCode), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + guiInfo.bg.h/2 + 70/zoom, guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h + guiInfo.card.h)/2, tocolor(200, 200, 200, 255 * self.alpha), 1/zoom, self.fonts.category, "center", "top", false, false, false, true)
        else
            dxDrawText(string.format("Kodun: #b89935%s", self.referenceCode), guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + guiInfo.bg.h/2 + 70/zoom, guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h + guiInfo.card.h)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "center", "top", false, false, false, true)
        end

        dxDrawText("(kopyalamak için tıkla)", guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + guiInfo.bg.h/2 + 92/zoom, guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h + guiInfo.card.h)/2, tocolor(140, 140, 140, 255 * self.alpha), 1/zoom, self.fonts.small, "center", "top", false, false, false, true)

        self:updateReferenceButtons()

        if not self.playerData.hasReferenceUsed then
            dxDrawText("KODU KULLAN", guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + guiInfo.bg.h/2 + 260/zoom, guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h + guiInfo.card.h)/2, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.tab, "center", "top", false, false, false, true)
        end

    elseif tab == "settings" then
        local y = (sy - (#guiInfo.settingsList["game"] * 40/zoom))/2
        for i, v in pairs(guiInfo.settingsList["game"]) do
            if v.type == "title" then
                dxDrawText(v.value, guiInfo.bg.x + 200/zoom, y, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + guiInfo.card.h)/2, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.tab, "left", "top", false, false, false, true)

            elseif v.type == "option" then
                dxDrawText(v.value..":", guiInfo.bg.x + 200/zoom, y, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + guiInfo.card.h)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
            end

            y = y + 40/zoom
        end

        dxDrawText("ŞİFRE DEĞİŞİMİ", guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h - 300/zoom)/2 - 5/zoom, guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h + guiInfo.card.h)/2, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.tab, "center", "top", false, false, false, true)
        dxDrawText("E-MAİL DEĞİŞİMİ", guiInfo.bg.x + 1150/zoom, guiInfo.bg.y + (guiInfo.bg.h - 300/zoom)/2, guiInfo.bg.x + 1400/zoom, guiInfo.bg.y + (guiInfo.bg.h + guiInfo.card.h)/2, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.tab, "center", "top", false, false, false, true)


        local newPass = guiGetText(self.edits.newPassword)
        local strength = calculateStrength(newPass)
        local r, g, b = interpolateBetween(157, 28, 28, 41, 157, 28, strength/100, "Linear")
        self:drawBackground(guiInfo.bg.x + (guiInfo.bg.w - 246/zoom)/2, guiInfo.bg.y + (guiInfo.bg.h - 300/zoom)/2 + 183/zoom, 246/zoom, 4/zoom, tocolor(37, 37, 37, 255 * self.alpha), 2)
        self:drawBackground(guiInfo.bg.x + (guiInfo.bg.w - 246/zoom)/2, guiInfo.bg.y + (guiInfo.bg.h - 300/zoom)/2 + 183/zoom, 246/zoom * math.min(math.max(strength/100, 0), 100), 4/zoom, tocolor(r, g, b, 255 * self.alpha), 2)

    elseif tab == "graphic" then
        local y = (sy - (#guiInfo.settingsList["graphic"] * 40/zoom))/2
        for i, v in pairs(guiInfo.settingsList["graphic"]) do
            if v.type == "title" then
                dxDrawText(v.value, guiInfo.bg.x + 650/zoom, y, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + guiInfo.card.h)/2, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.tab, "left", "top", false, false, false, true)

            elseif v.type == "option" then
                dxDrawText(v.value..":", guiInfo.bg.x + 650/zoom, y, guiInfo.bg.x + guiInfo.bg.w, guiInfo.bg.y + (guiInfo.bg.h + guiInfo.card.h)/2, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "top", false, false, false, true)
            end

            y = y + 40/zoom
        end
    end
end

function Dashboard:drawBackground(x, y, rx, ry, color, radius, post)
    rx = rx - radius * 2
    ry = ry - radius * 2
    x = x + radius
    y = y + radius

    if (rx >= 0) and (ry >= 0) then
        dxDrawRectangle(x, y, rx, ry, color, post)
        dxDrawRectangle(x, y - radius, rx, radius, color, post)
        dxDrawRectangle(x, y + ry, rx, radius, color, post)
        dxDrawRectangle(x - radius, y, radius, ry, color, post)
        dxDrawRectangle(x + rx, y, radius, ry, color, post)

        dxDrawCircle(x, y, radius, 180, 270, color, color, 7, 1, post)
        dxDrawCircle(x + rx, y, radius, 270, 360, color, color, 7, 1, post)
        dxDrawCircle(x + rx, y + ry, radius, 0, 90, color, color, 7, 1, post)
        dxDrawCircle(x, y + ry, radius, 90, 180, color, color, 7, 1, post)
    end
end

function Dashboard:renderCategories()
    for i, v in pairs(guiInfo.categories) do
        if i == self.tab then
            dxDrawRectangle(guiInfo.category.x, guiInfo.category.y + guiInfo.account.h + (i-1) * 50/zoom, guiInfo.category.w, 50/zoom, tocolor(37, 37, 37, 255 * self.alpha))

            if fileExists(string.format("files/images/%s.png", v[2])) then
                dxDrawImage(guiInfo.category.x + 10/zoom, guiInfo.category.y + guiInfo.account.h + 9/zoom + (i-1) * 50/zoom, 32/zoom, 32/zoom, string.format("files/images/%s.png", v[2]), 0, 0, 0, tocolor(240, 196, 55, 255 * self.alpha))
            end
            dxDrawText(v[1], guiInfo.category.x + 52/zoom, guiInfo.category.y + guiInfo.account.h + (i-1) * 50/zoom, guiInfo.category.x + guiInfo.category.w, guiInfo.category.y + guiInfo.account.h + 50/zoom + (i-1) * 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "center")

        else
            local color = 180
            if self:isMouseInPosition(guiInfo.category.x, guiInfo.category.y + guiInfo.account.h + (i-1) * 50/zoom, guiInfo.category.w, 50/zoom) and self.loaded and not self.playingCards then
                color = 220
            end

            if fileExists(string.format("files/images/%s.png", v[2])) then
                dxDrawImage(guiInfo.category.x + 10/zoom, guiInfo.category.y + guiInfo.account.h + 9/zoom + (i-1) * 50/zoom, 32/zoom, 32/zoom, string.format("files/images/%s.png", v[2]), 0, 0, 0, tocolor(color, color, color, 255 * self.alpha))
            end
            dxDrawText(v[1], guiInfo.category.x + 52/zoom, guiInfo.category.y + guiInfo.account.h + (i-1) * 50/zoom, guiInfo.category.x + guiInfo.category.w, guiInfo.category.y + guiInfo.account.h + 50/zoom + (i-1) * 50/zoom, tocolor(color, color, color, 255 * self.alpha), 1/zoom, self.fonts.category, "left", "center")
        end
    end
end


function Dashboard:clickCard()
    for i, v in pairs(guiInfo.card.cards) do
        if self:isMouseInPosition(v.x + v.w/2, guiInfo.bg.y + (guiInfo.bg.h - guiInfo.card.h)/2 - 20/zoom, guiInfo.card.w - v.w, guiInfo.card.h) and self.canPickCard then
            self:mixCardPrices()

            self.canPickCard = nil
            self.selectedCard = i
            self:moveCards("hideBackPrice")

            if self.cardPrices[self.selectedCard].type == "repeat" then
                self.playerData.cardPlays = self.playerData.cardPlays + 1
                exports.TR_dx:setButtonText(self.buttons.playCards, string.format("Oyna (%d)", self.playerData.cardPlays))

            elseif self.cardPrices[self.selectedCard].type == "beer" then
                exports.TR_shaders:setScreenEsotropia(true, 0.6, self.cardPrices[self.selectedCard].amount * 60)

            elseif self.cardPrices[self.selectedCard].type == "drugs" then
                exports.TR_shaders:setMarijuanaEffect(true, 0.5, self.cardPrices[self.selectedCard].amount * 60)
            end

            triggerServerEvent("playerPickCard", resourceRoot, self.cardPrices[self.selectedCard].type, self.cardPrices[self.selectedCard].amount)
            break
        end
    end
end

function Dashboard:mixCardPrices()
    for i = #self.cardPrices, 2, -1 do
        local j = math.random(i)
        self.cardPrices[i], self.cardPrices[j] = self.cardPrices[j], self.cardPrices[i]
    end
end

function Dashboard:mouseClick(...)
    if exports.TR_dx:isResponseEnabled() then return end
    if not self.loaded then return end
    if arg[1] == "left" and arg[2] == "down" then
        local tab = guiInfo.categories[self.tab][2]

        if self.playingCards then self:clickCard() return end
        if self:isMouseInPosition(guiInfo.category.x, guiInfo.category.y, guiInfo.category.w, guiInfo.category.h) then
            for i, v in pairs(guiInfo.categories) do
                if self:isMouseInPosition(guiInfo.category.x, guiInfo.category.y + guiInfo.account.h + (i-1) * 50/zoom, guiInfo.category.w, 50/zoom) then
                    self:selectTab(i)
                    break
                end
            end

        elseif self:isMouseInPosition(guiInfo.bg.x, guiInfo.bg.y, guiInfo.bg.w, guiInfo.bg.h) then
            if tab == "vehicle" and not self.vehiclePreview then
                for i = 1, guiInfo.vehicles.visible do
                    if self.vehicleData[i + self.scroll] then
                        if self:isMouseInPosition(guiInfo.bg.x, guiInfo.bg.y + (i-1) * guiInfo.vehicles.h, guiInfo.bg.w - 550/zoom, guiInfo.vehicles.h) then
                            self:selectVehiclePreview(i + self.scroll)
                            break
                        end
                    end
                end

            elseif tab == "house" and not self.houseSelected then
                for i = 1, guiInfo.logs.visible do
                    if self.houseData[i + self.scroll] then
                        if self:isMouseInPosition(guiInfo.bg.x, guiInfo.bg.y + (i-1) * guiInfo.logs.h, guiInfo.bg.w - 550/zoom, guiInfo.logs.h) then
                            self:selectHouse(i + self.scroll)
                            break
                        end
                    end
                end

            elseif tab == "logs" and not self.logSelected then
                for i = 1, guiInfo.logs.visible do
                    if self.logs[i + self.scroll] then
                        if self:isMouseInPosition(guiInfo.bg.x, guiInfo.bg.y + (i-1) * guiInfo.logs.h, guiInfo.bg.w - 550/zoom, guiInfo.logs.h) then
                            self:selectLog(i + self.scroll)
                            break
                        end
                    end
                end

            elseif tab == "penalties" and not self.penaltySelected then
                for i = 1, guiInfo.logs.visible do
                    if self.penalties[i + self.scroll] then
                        if self:isMouseInPosition(guiInfo.bg.x, guiInfo.bg.y + (i-1) * guiInfo.logs.h, guiInfo.bg.w - 550/zoom, guiInfo.logs.h) then
                            self:selectPenalty(i + self.scroll)
                            break
                        end
                    end
                end
            elseif tab == "reference" then
                if self:isMouseInPosition(guiInfo.bg.x + (guiInfo.bg.w - 250/zoom)/2, guiInfo.bg.y + guiInfo.bg.h/2 + 65/zoom, 250/zoom, 55/zoom) then
                    setClipboard(self.referenceCode)
                    exports.TR_noti:create("Kod panoya kopyalandı.", "success")
                end

            elseif tab == "description" then
                for i = 1, 5 do
                    local desc = self.descList[i]
                    if desc then
                        if self:isMouseInPosition(guiInfo.bg.x + guiInfo.bg.w - 300/zoom - 35/zoom, guiInfo.bg.y + 202/zoom + 75/zoom * (i-1), 16/zoom, 16/zoom) then
                            local plrData = getElementData(localPlayer, "characterData")
                            local blockColor = true
                            if plrData.premium == "gold" or plrData.premium == "diamond" then
                                blockColor = false
                            end

                            if blockColor and string.find(desc, "#%x%x%x%x%x%x") then exports.TR_noti:create("Bu durumu seçemezsiniz çünkü renklidir ve premium hesabınız yoktur.", "error") return end
                            for i, v in pairs(guiInfo.suspectedWords) do
                                if string.find(desc, v) then
                                    exports.TR_noti:create("Durum uygunsuz kelimeler içeriyor.", 'error')
                                    return
                                end
                            end

                            setElementData(localPlayer, "characterDesc", desc)
                            exports.TR_dx:setEditText(self.edits.charDesc, desc)
                            exports.TR_noti:create("Durum başarıyla ayarlandı.", "success")

                            exports.TR_achievements:addAchievements("characterDesc")
                            self:getAchievments()
                            break

                        elseif self:isMouseInPosition(guiInfo.bg.x + guiInfo.bg.w - 300/zoom - 35/zoom, guiInfo.bg.y + 232/zoom + 75/zoom * (i-1), 16/zoom, 16/zoom) then
                            table.remove(self.descList, i)
                            self:saveCharacterDescriptions()
                            exports.TR_noti:create("Durum başarıyla silindi.", "success")
                            break
                        end
                    end
                end
            elseif tab == "friends" then
                if #self.friendsData > 0 then
                    local i = 1
                    for k = 1, 5 * 2 do
                        local v = self.friendsData[k + self.scroll]
                        if v then
                            if k%2 == 1 then
                                if not v.friendsFor then
                                    if v.isTarget then
                                        if self:isMouseInPosition(sx/2 - 350/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, 100/zoom, 30/zoom) then
                                            exports.TR_dx:setResponseEnabled(true)
                                            triggerServerEvent("acceptPlayerFriend", resourceRoot, v.UID, v.username)
                                        end
                                        if self:isMouseInPosition(sx/2 - 245/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, 200/zoom, 30/zoom) then
                                            exports.TR_dx:setResponseEnabled(true)
                                            triggerServerEvent("removePlayerFriend", resourceRoot, v.UID, v.username)
                                        end
                                    else
                                        if self:isMouseInPosition(sx/2 - 350/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, 100/zoom, 30/zoom) then
                                            exports.TR_dx:setResponseEnabled(true)
                                            triggerServerEvent("removePlayerFriend", resourceRoot, v.UID, v.username, true)
                                        end
                                    end
                                else
                                    if self:isMouseInPosition(sx/2 - 350/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 75/zoom, 200/zoom, 30/zoom) then
                                        exports.TR_dx:setResponseEnabled(true)
                                        triggerServerEvent("removePlayerFriend", resourceRoot, v.UID, v.username)
                                    end
                                end

                            else
                                if not v.friendsFor then
                                    if v.isTarget then
                                        if self:isMouseInPosition(sx/2 + 300/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, 100/zoom, 30/zoom) then
                                            exports.TR_dx:setResponseEnabled(true)
                                            triggerServerEvent("acceptPlayerFriend", resourceRoot, v.UID, v.username)
                                        end
                                        if self:isMouseInPosition(sx/2 + 405/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, 200/zoom, 30/zoom) then
                                            exports.TR_dx:setResponseEnabled(true)
                                            triggerServerEvent("removePlayerFriend", resourceRoot, v.UID, v.username)
                                        end

                                    else
                                        if self:isMouseInPosition(sx/2 + 300/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 55/zoom, 100/zoom, 30/zoom) then
                                            exports.TR_dx:setResponseEnabled(true)
                                            triggerServerEvent("removePlayerFriend", resourceRoot, v.UID, v.username, true)
                                        end
                                    end
                                else
                                    if self:isMouseInPosition(sx/2 + 300/zoom, sy/2 - 340/zoom + (i-1) * 120/zoom + 75/zoom, 200/zoom, 30/zoom) then
                                        exports.TR_dx:setResponseEnabled(true)
                                        triggerServerEvent("removePlayerFriend", resourceRoot, v.UID, v.username)
                                    end
                                end

                                i = i + 1
                            end
                        end
                    end
                end
            end
        end
    end
end

function Dashboard:buttonClick(...)
    if exports.TR_dx:isResponseEnabled() then return end
    if arg[1] == self.buttons.revealHidden then
        self.revealData = not self.revealData
        exports.TR_dx:setButtonText(self.buttons.revealHidden, self.revealData and "Hassas verileri gizle" or "Hassas verileri göster")

    elseif arg[1] == self.buttons.showLogs then
        self.revealData = not self.revealData
        exports.TR_dx:setButtonText(self.buttons.showLogs, self.revealData and "Hassas verileri gizle" or "Hassas verileri göster")

    elseif arg[1] == self.buttons.showPenalty then
        self.revealData = not self.revealData
        exports.TR_dx:setButtonText(self.buttons.showPenalty, self.revealData and "Hassas verileri gizle" or "Hassas verileri göster")

    elseif arg[1] == self.buttons.backPreview then
        self:selectVehiclePreview(nil)

    elseif arg[1] == self.buttons.localizeVehicle then
        if not self.vehiclePreview then return end
        local veh = getElementByID("vehicle"..self.vehicleData[self.vehiclePreview].ID)
        if not veh or self.vehicleData[self.vehiclePreview].parking == "Parking" then
            exports.TR_noti:create("Depodaki bir aracı takip edemezsiniz.", "error")
            return
        end

        if getElementInterior(localPlayer) ~= 0 or getElementDimension(localPlayer) ~= 0 then
            exports.TR_noti:create("Bir binanın içindeyken bir aracı izleyemezsiniz.", "error")
            return
        end

        local x, y = getElementPosition(veh)
        exports.TR_hud:findBestWay(x, y)

    elseif arg[1] == self.buttons.backHouse then
        self:selectHouse(nil)

    elseif arg[1] == self.buttons.backLogs then
        self:selectLog(nil)

    elseif arg[1] == self.buttons.backPenalty then
        self:selectPenalty(nil)

    elseif arg[1] == self.buttons.playCards then
        if self.playerData.cardPlays < 1 then
            exports.TR_noti:create("Herhangi bir oyun hakkına sahip olmadığın için oynayamazsın.", "error")
            return
        end
        self:playCardGame()
        exports.TR_achievements:addAchievements("cardPlay")
        self:getAchievments()

    elseif arg[1] == self.buttons.getReferences then
        exports.TR_dx:setResponseEnabled(true)
        triggerServerEvent("getPlayerReference", resourceRoot)

    elseif arg[1] == self.buttons.useReferences then
        local code = guiGetText(self.edits.referenceCode)
        if string.len(code) < 3 then exports.TR_noti:create("Kod geçersiz.", "error") return end
        if self.referenceCode == code then exports.TR_noti:create("Kendi kodunuzu kullanamazsınız.", "error") return end

        exports.TR_dx:setResponseEnabled(true)
        triggerServerEvent("useDashboardReferenceCode", resourceRoot, code)

    elseif arg[1] == self.buttons.changePassword then
        self:changePassword()

    elseif arg[1] == self.buttons.changeMail then
        self:changeMail()

    elseif arg[1] == self.buttons.descDefaultColor then
        local text = guiGetText(self.edits.charDesc)
        if utf8.len(text) + 7 < guiInfo.descriptionLimit then
            guiFocus(self.edits.charDesc)
            triggerEvent("returnClipBoard", resourceRoot, "#969696")
        end

    elseif arg[1] == self.buttons.descSave then
        local text = guiGetText(self.edits.charDesc)
        local plrData = getElementData(localPlayer, "characterData")
        local limit = 3
        local blockColor = true
        if plrData.premium == "gold" or plrData.premium == "diamond" then
            limit = 5
            blockColor = false
        end

        if #self.descList >= limit then exports.TR_noti:create("Maksimum durum sayısına ulaştınız.", "error") return end
        if blockColor and string.find(text, "#%x%x%x%x%x%x") then exports.TR_noti:create("Renk yalnızca premium bir oyuncu tarafından kullanılabilir.", "error") return end

        for i, v in pairs(guiInfo.suspectedWords) do
            if string.find(text, v) then
                exports.TR_noti:create("Durum uygunsuz kelimeler içeriyor.", 'error')
                return
            end
        end

        table.insert(self.descList, text)
        self:saveCharacterDescriptions()
        exports.TR_noti:create("Durum başarıyla eklendi.", "success")


    elseif arg[1] == self.buttons.addFriend then
        local text = guiGetText(self.edits.addFriend)
        if string.len(text) < 3 then exports.TR_noti:create("Girilen nick en az 3 karakterden oluşmalıdır.", "error") return end
        if string.lower(getPlayerName(localPlayer)) == string.lower(text) then exports.TR_noti:create("Bir arkadaş olarak kendinizi ekleyemezsiniz.", "error") return end

        exports.TR_dx:setResponseEnabled(true)
        triggerServerEvent("requestPlayerToFriends", resourceRoot, text)
    end
end

function Dashboard:playCardGame()
    guiInfo.card.cards = {
        {
            defX = guiInfo.bg.x + (guiInfo.bg.w - guiInfo.card.w)/2 - guiInfo.card.w - 50/zoom,
            x = guiInfo.bg.x + (guiInfo.bg.w - guiInfo.card.w)/2 - guiInfo.card.w + 40/zoom,
            w = 0,
            frontW = guiInfo.card.w,
        },
        {
            defX = guiInfo.bg.x + (guiInfo.bg.w - guiInfo.card.w)/2,
            x = guiInfo.bg.x + (guiInfo.bg.w - guiInfo.card.w)/2 - guiInfo.card.w + 40/zoom,
            w = 0,
            frontW = guiInfo.card.w,
        },
        {
            defX = guiInfo.bg.x + (guiInfo.bg.w - guiInfo.card.w)/2 + guiInfo.card.w + 50/zoom,
            x = guiInfo.bg.x + (guiInfo.bg.w - guiInfo.card.w)/2 - guiInfo.card.w + 40/zoom,
            w = 0,
            frontW = guiInfo.card.w,
        },
    }

    self.playingCards = true
    self.cardMixed = 0
    self.playerData.cardPlays = self.playerData.cardPlays - 1
    exports.TR_dx:setButtonText(self.buttons.playCards, string.format("Oyna (%d)", self.playerData.cardPlays))

    self:moveCards("start")
    self:switchButtons()
    self:randomizeCardPrice()

    triggerServerEvent("playPlayerCards", resourceRoot, self.playerData.cardPlay)
    self.playerData.cardPlay = nil
end

function Dashboard:randomizeCardPrice()
    self.cardPrices = {}
    for i = 1, 3 do
        local card = self:getRandomCard()
        table.insert(self.cardPrices, card)
    end
end

function Dashboard:removeCards()
    if self.cardPrices then
        for i, v in pairs(self.cardPrices) do
            if isElement(v.renderTarget) then destroyElement(v.renderTarget) end
        end
        self.cardPrices = nil
    end
end

function Dashboard:getRandomCard()
    local card = {}

    local rand = math.random(1, 100)
    if rand == 100 then
        card = {
            img = "files/images/diamond.png",
            amount = math.random(1, 5),
            color = {49, 202, 255},
            text = "Diamond",
            type = "diamond",
            renderTarget = dxCreateRenderTarget(guiInfo.card.w, guiInfo.card.h, true),
        }
        card.amountText = string.format("%d %s", card.amount, card.amount == 1 and " gün" or " gün")

    elseif rand >= 95 and rand < 100 then
        card = {
            img = "files/images/crown.png",
            amount = math.random(1, 5),
            color = {214, 163, 6},
            text = "Gold",
            type = "gold",
            renderTarget = dxCreateRenderTarget(guiInfo.card.w, guiInfo.card.h, true),
        }
        card.amountText = string.format("%d %s", card.amount, card.amount == 1 and " gün" or " gün")

    elseif rand < 95 and rand >= 80 then
        card = {
            img = "files/images/beer.png",
            amount = math.random(5, 10),
            color = {242, 142, 28},
            text = "Alköl",
            type = "beer",
            renderTarget = dxCreateRenderTarget(guiInfo.card.w, guiInfo.card.h, true),
        }
        card.amountText = string.format("%s dk", card.amount)

    elseif rand < 80 and rand >= 65 then
        card = {
            img = "files/images/drugs.png",
            amount = math.random(5, 10),
            color = {118, 81, 184},
            text = "Uyuşturuc",
            type = "drugs",
            renderTarget = dxCreateRenderTarget(guiInfo.card.w, guiInfo.card.h, true),
        }
        card.amountText = string.format("%s dk", card.amount)

    elseif rand < 65 and rand >= 55 then
        card = {
            img = "files/images/repeat.png",
            amount = math.random(5, 10),
            color = {212, 85, 85},
            text = "Tekrar Çevir",
            type = "repeat",
            renderTarget = dxCreateRenderTarget(guiInfo.card.w, guiInfo.card.h, true),
        }
        card.amountText = "Tekrar oyna"

    elseif rand < 95 then
        card = {
            img = "files/images/money_prize.png",
            amount = math.random(100, 500),
            color = {76, 156, 61},
            text = "Para",
            type = "money",
            renderTarget = dxCreateRenderTarget(guiInfo.card.w, guiInfo.card.h, true),
        }
        card.amountText = string.format("$%.2f", card.amount)
    end

    dxSetRenderTarget(card.renderTarget)
    dxSetBlendMode("add")
    dxDrawImage(0, 0, guiInfo.card.w, guiInfo.card.h, self.cardFrontSymbols, 0, 0, 0, tocolor(card.color[1], card.color[2], card.color[3], 255))
    dxDrawImage((guiInfo.card.w - guiInfo.card.imgSize)/2, 120/zoom, guiInfo.card.imgSize, guiInfo.card.imgSize, card.img, 0, 0, 0, tocolor(255, 255, 255, 255))
    dxDrawText(card.text, 0, 290/zoom, guiInfo.card.w, guiInfo.card.h, tocolor(220, 220, 220, 255), 1/zoom, self.fonts.tab, "center", "top")
    dxDrawText(card.amountText, 0, 320/zoom, guiInfo.card.w, guiInfo.card.h, tocolor(card.color[1], card.color[2], card.color[3], 255), 1/zoom, self.fonts.tab, "center", "top")
    dxSetBlendMode()
    dxSetRenderTarget()

    return card
end


function Dashboard:moveCards(...)
    for i, v in pairs(guiInfo.card.cards) do
        guiInfo.card.cards[i].lastX = v.x

        guiInfo.card.cards[i].lastX = v.x
        guiInfo.card.cards[i].lastW = v.w
    end

    self.cardTick = getTickCount()
    self.cardAnim = arg[1]
end

function Dashboard:scrollKey(...)
    if not self.loaded then return end
    local tab = guiInfo.categories[self.tab][2]

    if arg[1] == "mouse_wheel_up" then
        if tab == "vehicle" then
            if #self.vehicleData - guiInfo.vehicles.visible < 1 then return end
            if self.scroll == 0 then return end
            self.scroll = math.max(self.scroll - 1, 0)
            self:updateVehicle()

        elseif tab == "medal" then
            if #self.achievements - guiInfo.achievementsCount * 2 < 1 then return end
            if self.scroll == 0 then return end
            self.scroll = math.max(self.scroll - 2, 0)

        elseif tab == "friends" then
            if #self.friendsData - 5 * 2 < 1 then return end
            if self.scroll == 0 then return end
            self.scroll = math.max(self.scroll - 2, 0)
        end

    elseif arg[1] == "mouse_wheel_down" then
        if tab == "vehicle" then
            if #self.vehicleData - guiInfo.vehicles.visible < 1 then return end
            if self.scroll == (#self.vehicleData - guiInfo.vehicles.visible) then return end
            self.scroll = math.min(self.scroll + 1, #self.vehicleData - guiInfo.vehicles.visible)
            self:updateVehicle()

        elseif tab == "medal" then
            if #self.achievements - guiInfo.achievementsCount * 2 < 1 then return end
            if self.scroll >= (#self.achievements - guiInfo.achievementsCount * 2) then return end
            self.scroll = math.min(self.scroll + 2, #self.achievements)

        elseif tab == "friends" then
            if #self.friendsData - 5 * 2 < 1 then return end
            if self.scroll >= (#self.friendsData - 5 * 2) then return end
            self.scroll = math.min(self.scroll + 2, #self.friendsData)
        end

    elseif tab == "medal" and arg[2] then
        if not self.konamiCode then self.konamiCode = {} end
        if #self.konamiCode >= 10 then table.remove(self.konamiCode, 1) end
        table.insert(self.konamiCode, arg[1])

        local konamiCode = {"arrow_u", "arrow_u", "arrow_d", "arrow_d", "arrow_l", "arrow_r", "arrow_l", "arrow_r", "b", "a"}
        for i, v in pairs(self.konamiCode) do
            if v ~= konamiCode[i] then return end
        end
        if #self.konamiCode ~= 10 then return end

        exports.TR_achievements:addAchievements("konamiCode")
        self:getAchievments()
    end
end



function Dashboard:onFriendLogin(plr, username)
    if not self.friendsData then return end
    for i, v in pairs(self.friendsData) do
        if v.username == username then
            local id = getElementData(plr, "ID")
            exports.TR_noti:create(string.format("Arkadaşınız %s az önce giriş yaptı! Ona yazmak istiyorsanız, komutu kullanın.:\n/sms %d (msj)", username, id), "info", 10)
        end
    end
end

function Dashboard:loadFriends(data, data2)
    self.friendsData = {}
    if data then
        self:loadFriendsData(data, false)
    end
    if data2 then
        self:loadFriendsData(data2, true)
    end

    local temp = {}
    for i, v in pairs(self.friendsData) do
        if v.friendsFor then
            table.insert(temp, v)
        end
    end
    table.sort(temp, function(a, b)
        return a.UID < b.UID
    end)

    for i, v in pairs(self.friendsData) do
        if not v.friendsFor then
            if v.isTarget then
                table.insert(temp, 1, v)
            else
                table.insert(temp, #temp + 1, v)
            end
        end
    end

    self.friendsData = temp

    self.loaded = true
end

function Dashboard:loadFriendsData(data, isTarget)
    local date = getRealTime()
    for i, v in pairs(data) do
        local lastOnline = split(v.lastOnline, " ")
        local lastOnlineDate = split(lastOnline[1], "-")
        local lastOnlineHour = split(lastOnline[2], ":")

        if date.monthday == tonumber(lastOnlineDate[3]) and date.month + 1 == tonumber(lastOnlineDate[2]) and date.year + 1900 == tonumber(lastOnlineDate[1]) then
            lastOnlineDate = string.format("%02d:%02d", lastOnlineHour[1], lastOnlineHour[2])
        else
            lastOnlineDate = string.format("%s.%s.%sr.", lastOnlineDate[3], lastOnlineDate[2], lastOnlineDate[1])
        end

        local ID = false
        local plr = getPlayerFromName(v.username)
        if isElement(plr) then
            if getElementData(plr, "characterUID") then
                lastOnlineDate = "Çevrimiçi, ID: "..getElementData(plr, "ID")
            end
        end

        local friendsForString = false
        if v.friendsFor then
            local friendsFor = split(v.friendsFor, " ")
            local friendsForDate = split(friendsFor[1], "-")
            friendsForString = string.format("%s.%s.%sr.", friendsForDate[3], friendsForDate[2], friendsForDate[1])
        end

        table.insert(self.friendsData, {
            UID = v.UID,
            skin = exports.TR_images:getImage("skins", v.skin),
            username = v.username,
            lastOnline = lastOnlineDate,
            friendsFor = friendsForString,
            isTarget = isTarget,
        })
    end
end

function Dashboard:setData(data, data2, referencedPlayers)
    local tab = guiInfo.categories[self.tab][2]

    if tab == "player" then
        self.loaded = true
        self.playerData.bankmoney = data.bankmoney
        self.playerData.online = data.online
        self.playerData.serial = data.serial
        self.playerData.createIP = data.createIP
        self.playerData.ip = data.ip
        self.playerData.cards = data.cards
        self.playerData.cardPlays = tonumber(data.cardPlays) + (data2 and data2[1] and data2[1].cardPlay and 1 or 0)
        self.playerData.referenced = data.referenced and data.referenced or 0
        self.playerData.referencedPlayers = referencedPlayers and #referencedPlayers or 0
        self.playerData.vehicleLimit = data.vehicleLimit
        self.playerData.houseLimit = data.houseLimit
        self.playerData.hasReferenceUsed = tonumber(data.referencedPlayer) ~= 0 and true or false

        local premiumDate = false
        if data.premiumDate then
            local d = split(data.premiumDate, " ")
            local date = split(d[1], "-")
            premiumDate = string.format("(%s.%s.%sr.)", date[3], date[2], date[1])
        end
        self.playerData.premiumDate = premiumDate

        local c = split(data.created, " ")
        local c1 = split(c[1], "-")
        local c2 = split(c[2], ":")
        self.playerData.created = string.format("%02d:%02d %02d.%02d.%04dr.", c2[1], c2[2], c1[3], c1[2], c1[1])

        if data.licence then
            local licences = ""
            local vehicleLicence = ""
            local licencesTable = fromJSON(data.licence) or {}
            local licenceVehiclesCount = 0

            if licencesTable then
                for i, v in pairs(licencesTable) do
                    if i == "a" or i == "b" or i == "c" then
                        vehicleLicence = vehicleLicence..licenceName[i]..", "
                        licenceVehiclesCount = licenceVehiclesCount + 1
                    else
                        licences = licences..licenceName[i]..", "
                    end
                end
            end

            if licenceVehiclesCount == 3 then
                exports.TR_achievements:addAchievements("allDriveLicence")
                self:getAchievments()
            end

            self.playerData.licence = string.len(licences) > 1 and string.sub(licences, 0, string.len(licences) - 2) or "Yok"
            self.playerData.vehicleLicence = string.sub(vehicleLicence, 0, string.len(vehicleLicence) - 2)
        else
            self.playerData.licence = "Yok"
            self.playerData.vehicleLicence = "Yok"
        end

        self.playerData.cardPlay = data2 and data2[1] and data2[1].cardPlay and true or false

        local cardTime = tonumber(data.cardTime)
        self.playerData.cardTime = cardTime and cardTime > 0 and cardTime or 0

        self:createButtons()
        self:selectTab(1, true)

    elseif tab == "vehicle" then
        self.vehicleData = {}
        self.playerData.vehicleCount = 0
        self.playerData.maxVehicles = self:calculateMaxVehicle(tonumber(self.playerData.vehicleLimit))

        if data then
            for i, v in pairs(data) do
                table.insert(self.vehicleData, v)

                local d = split(v.boughtDate, " ")
                local date = split(d[1], "-")
                self.vehicleData[#self.vehicleData].boughtDate = string.format("%s.%s.%sr.", date[3], date[2], date[1])
                if not v.parking then
                    local veh = getElementByID("vehicle"..v.ID)

                    self.vehicleData[#self.vehicleData].parking = veh and getZoneName(Vector3(getElementPosition(veh))) or "Bilinmeyen Konum"

                elseif tonumber(v.parking) == 100 then
                    self.vehicleData[#self.vehicleData].parking = "Polis Otoparkı"
                else
                    self.vehicleData[#self.vehicleData].parking = "Otopark"
                end

                self.vehicleData[#self.vehicleData].img = exports.TR_images:getImage("vehicles", self.vehicleData[i + self.scroll].model)
            end

            self.playerData.vehicleCount = #data
        end

        if data2 then
            for i, v in pairs(data2) do
                table.insert(self.vehicleData, v)
                self.vehicleData[#self.vehicleData].isRented = true

                local d = split(v.boughtDate, " ")
                local date = split(d[1], "-")
                self.vehicleData[#self.vehicleData].boughtDate = string.format("%s.%s.%sr.", date[3], date[2], date[1])
                if not v.parking then
                    local veh = getElementByID("vehicle"..v.ID)
                    self.vehicleData[#self.vehicleData].parking = veh and getZoneName(Vector3(getElementPosition(veh))) or "Bilinmeyen Konum"
                elseif tonumber(v.parking) == 100 then
                    self.vehicleData[#self.vehicleData].parking = "Polis Otoparkı"
                else
                    self.vehicleData[#self.vehicleData].parking = "Otopark"
                end
            end
        end

    elseif tab == "house" then
        self.houseData = {}
        self.playerData.maxHouse = self:calculateMaxHouse(tonumber(self.playerData.houseLimit))

        if data then
            for i, v in pairs(data) do
                local pos = split(v.pos, ",")
                table.insert(self.houseData, v)
                self.houseData[#self.houseData].size = exports.TR_houses:getHouseNameFromSize(v.interiorSize)
                self.houseData[#self.houseData].img = self:getHouseImgFromName(self.houseData[#self.houseData].size)
                self.houseData[#self.houseData].pos = getZoneName(pos[1], pos[2], pos[3])


                local c = split(v.date, " ")
                local c1 = split(c[1], "-")
                local c2 = split(c[2], ":")
                self.houseData[#self.houseData].date = string.format("%02d:%02d:%02d %02d.%02d.%04dr.", c2[1], c2[2], c2[3], c1[3], c1[2], c1[1])
            end

            self.playerData.houseCount = #data
        end

        if data2 then
            for i, v in pairs(data2) do
                local pos = split(v.pos, ",")
                table.insert(self.houseData, v)
                self.houseData[#self.houseData].size = exports.TR_houses:getHouseNameFromSize(v.interiorSize)
                self.houseData[#self.houseData].isRented = true
                self.houseData[#self.houseData].img = self:getHouseImgFromName(self.houseData[#self.houseData].size)
                self.houseData[#self.houseData].pos = getZoneName(pos[1], pos[2], pos[3])
                self.houseData[#self.houseData].rent = true

                local c = split(v.date, " ")
                local c1 = split(c[1], "-")
                local c2 = split(c[2], ":")
                self.houseData[#self.houseData].date = string.format("%02d:%02d:%02d %02d.%02d.%04dr.", c2[1], c2[2], c2[3], c1[3], c1[2], c1[1])
            end
        end

    elseif tab == "medal" then
        if data then
            self.earnedAchievementCount = {}

            for i, v in pairs(data) do
                self.earnedAchievementCount[v.achievement] = tonumber(v.earnedPlayers)
            end
        end

        self.totalPlayers = tonumber(data2)

    elseif tab == "penalties" then
        self.penalties = {}
        if data then
            for i, v in pairs(data) do
                table.insert(self.penalties, v)
                self.penalties[#self.penalties].title = string.gsub(v.type, "^%l", string.upper)

                if v.time then
                    local c = split(v.time, " ")
                    local c1 = split(c[1], "-")
                    local c2 = split(c[2], ":")
                    self.penalties[#self.penalties].time = string.format("%02d:%02d:%02d %02d.%02d.%04dr.", c2[1], c2[2], c2[3], c1[3], c1[2], c1[1])
                end
                if v.timeEnd then
                    local c = split(v.timeEnd, " ")
                    local c1 = split(c[1], "-")
                    local c2 = split(c[2], ":")
                    self.penalties[#self.penalties].timeEnd = string.format("%02d:%02d:%02d %02d.%02d.%04dr.", c2[1], c2[2], c2[3], c1[3], c1[2], c1[1])
                end
            end
        end

    elseif tab == "logs" then
        self.logs = {}
        if data then
            for i, v in pairs(data) do
                table.insert(self.logs, v)
                local title, img = self:getLogsData(v.type)
                self.logs[#self.logs].title = title
                self.logs[#self.logs].img = img

                local c = split(v.date, " ")
                local c1 = split(c[1], "-")
                local c2 = split(c[2], ":")
                self.logs[#self.logs].date = string.format("%02d:%02d:%02d %02d.%02d.%04dr.", c2[1], c2[2], c2[3], c1[3], c1[2], c1[1])
            end
        end
    end

    self.loaded = true
    self:createPreview()

    return
end

function Dashboard:updateCardPlays(amount)
    if not self.buttons then return end
    if not self.buttons.playCards then return end
    self.playerData.cardPlays = self.playerData.cardPlays + amount
    exports.TR_dx:setButtonText(self.buttons.playCards, string.format("Oyna (%d)", self.playerData.cardPlays))
end

function Dashboard:getHouseImgFromName(...)
    if arg[1] == "Willa" then return "large" end
    if arg[1] == "Dom wielorodzinny" then return "big" end
    if arg[1] == "Dom dwurodzinny" then return "medium" end
    if arg[1] == "Dom jednorodzinny" then return "small" end
end

function Dashboard:getLogsData(...)
    if arg[1] == "login" then return "Logowanie", "files/images/login.png" end
    if arg[1] == "password" then return "Zmiana hasła", "files/images/password.png" end
    if arg[1] == "money" then return "Przelew bankowy", "files/images/money.png" end
    if arg[1] == "email" then return "Zmiana adresu email", "files/images/email.png" end
end

function Dashboard:updateVehicle()
    if not self.enabledPreviews then return end
    if self.vehiclePreview then return end
    self:removePreview()
    self.previews = {}

    for i = 1, guiInfo.vehicles.visible do
        if self.vehicleData[i + self.scroll] then
            table.insert(self.previews, {
                element = createVehicle(self.vehicleData[i + self.scroll].model, 0, 0, 0)
            })
            if tonumber(self.vehicleData[i + self.scroll].model) ~= 522 then
                local variant = split(self.vehicleData[i + self.scroll].variant, ",")
                setVehicleVariant(self.previews[#self.previews].element, tonumber(variant[1]), tonumber(variant[2]))
            end
            setElementInterior(self.previews[#self.previews].element, getElementInterior(localPlayer))
            setElementDimension(self.previews[#self.previews].element, getElementDimension(localPlayer))

            local color = split(self.vehicleData[i + self.scroll].color, ",")
            setVehicleColor(self.previews[#self.previews].element, color[1], color[2], color[3], color[4], color[5], color[6], color[7], color[8], color[9], color[10], color[11], color[12])
            setVehiclePaintjob(self.previews[#self.previews].element, self.vehicleData[i].paintjob or 3)
            setElementCollisionsEnabled(self.previews[#self.previews].element, false)

            if self.vehicleData[i + self.scroll].tuning then
                local upgrades = fromJSON(self.vehicleData[i + self.scroll].tuning)
                if upgrades then
                    for i, v in pairs(upgrades) do
                        addVehicleUpgrade(self.previews[#self.previews].element, v)
                    end
                end
            end
            self.previews[#self.previews].preview = exports.TR_preview:createObjectPreview(self.previews[#self.previews].element, 0, 0, 220, guiInfo.bg.x + 50/zoom, guiInfo.bg.y + (i-1) * guiInfo.vehicles.h - guiInfo.vehicles.h/2, guiInfo.vehicles.h * 2, guiInfo.vehicles.h * 2, false, true)
        end
    end
end


function Dashboard:selectTab(...)
    if arg[1] == self.tab and not arg[2] then return end

    self.tab = arg[1]
    self.scroll = 0
    self.revealData = nil
    self.vehiclePreview = nil
    self.houseSelected = nil
    self.logSelected = nil
    self.penaltySelected = nil

    local tab = guiInfo.categories[self.tab][2]
    if tab == "vehicle" and not self.vehicleData then
        self.loaded = false
        triggerServerEvent("loadDashboardData", resourceRoot, tab)

    elseif tab == "house" and not self.houseData then
        self.loaded = false
        triggerServerEvent("loadDashboardData", resourceRoot, tab)

    elseif tab == "medal" and not self.totalPlayers then
        self.loaded = false
        triggerServerEvent("loadDashboardData", resourceRoot, tab)

    elseif tab == "penalties" and not self.penalties then
        self.loaded = false
        triggerServerEvent("loadDashboardData", resourceRoot, tab)

    elseif tab == "logs" and not self.logs then
        self.loaded = false
        triggerServerEvent("loadDashboardData", resourceRoot, tab)

    elseif tab == "friends" and not self.friendsData then
        self.loaded = false
        triggerServerEvent("loadDashboardData", resourceRoot, tab)
    end

    self:createPreview()
    self:switchButtons()
end

function Dashboard:switchButtons()
    exports.TR_dx:setButtonVisible(self.buttons, false)
    exports.TR_dx:setEditVisible(self.edits, false)
    exports.TR_dx:setSwitchVisible(self.switches, false)
    exports.TR_dx:setSwitchVisible(self.previewEnabledSwitch, false)

    local tab = guiInfo.categories[self.tab][2]
    if tab == "player" then
        exports.TR_dx:setButtonVisible(self.buttons.revealHidden, true)
        exports.TR_dx:setSwitchVisible(self.previewEnabledSwitch, true)

    elseif tab == "vehicle" and self.vehiclePreview then
        exports.TR_dx:setButtonVisible({self.buttons.backPreview, self.buttons.localizeVehicle}, true)

    elseif tab == "house" and self.houseSelected then
        exports.TR_dx:setButtonVisible(self.buttons.backHouse, true)

    elseif tab == "logs" and self.logSelected then
        exports.TR_dx:setButtonVisible({self.buttons.backLogs, self.buttons.showLogs}, true)

    elseif tab == "penalties" and self.penaltySelected then
        exports.TR_dx:setButtonVisible({self.buttons.showPenalty, self.buttons.backPenalty}, true)

    elseif tab == "cards" and not self.playingCards then
        exports.TR_dx:setButtonVisible(self.buttons.playCards, true)

    elseif tab == "reference" then
        if self.referenceProgress >= 1 then
            exports.TR_dx:setButtonVisible(self.buttons.getReferences, true)
        end

        if not self.playerData.hasReferenceUsed then
            exports.TR_dx:setButtonVisible(self.buttons.useReferences, true)
            exports.TR_dx:setEditVisible(self.edits.referenceCode, true)
        end

    elseif tab == "settings" then
        exports.TR_dx:setEditVisible({self.edits.currPassword, self.edits.newPassword, self.edits.newPasswordRe, self.edits.currEmail, self.edits.newEmail, self.edits.newEmailRe}, true)
        exports.TR_dx:setButtonVisible({self.buttons.changePassword, self.buttons.changeMail}, true)

        local switches = {}
        for i, v in pairs(guiInfo.settingsList["game"]) do
            if v.switch then
                table.insert(switches, self.switches[v.switch])
            end
        end
        exports.TR_dx:setSwitchVisible(switches, true)

    elseif tab == "graphic" then
        local switches = {}
        for i, v in pairs(guiInfo.settingsList["graphic"]) do
            if v.switch then
                table.insert(switches, self.switches[v.switch])
            end
        end
        exports.TR_dx:setSwitchVisible(switches, true)

    elseif tab == "description" then
        exports.TR_dx:setEditVisible(self.edits.charDesc, true)
        exports.TR_dx:setButtonVisible({self.buttons.descSave, self.buttons.descDefaultColor}, true)

    elseif tab == "friends" then
        exports.TR_dx:setEditVisible(self.edits.addFriend, true)
        exports.TR_dx:setButtonVisible(self.buttons.addFriend, true)
    end
end

function Dashboard:updateReferenceButtons()
    local progress = math.max(math.min((self.playerData.referencedPlayers - self.playerData.referenced * 10)/10, 1), 0)
    if self.referenceProgress ~= progress then
        if not self.referenceButtonHidden then
            self.referenceButtonHidden = true
            exports.TR_dx:setButtonVisible(self.buttons.getReferences, false)
        end

        self.rot = self.rot + 2
        if self.rot == 360 then self.rot = 0 end
        dxDrawImage(guiInfo.bg.x + (guiInfo.bg.w - 40/zoom)/2, guiInfo.bg.y + guiInfo.bg.h/2 + 130/zoom, 40/zoom, 40/zoom, "files/images/loader.png", self.rot, 0, 0, tocolor(180, 180, 180, 255 * self.alpha))


    elseif self.referenceProgress == progress then
        if self.referenceProgress >= 1 and self.referenceButtonHidden then
            exports.TR_dx:setButtonVisible(self.buttons.getReferences, true)

        elseif self.referenceProgress < 1 then
            self:drawBackground(guiInfo.bg.x + (guiInfo.bg.w - 250/zoom)/2, guiInfo.bg.y + guiInfo.bg.h/2 + 130/zoom, 250/zoom, 40/zoom, tocolor(27, 27, 27, 255 * self.alpha), 5)
            dxDrawText("Ödülünü Al", guiInfo.bg.x + (guiInfo.bg.w - 250/zoom)/2, guiInfo.bg.y + guiInfo.bg.h/2 + 130/zoom, guiInfo.bg.x + (guiInfo.bg.w + 250/zoom)/2, guiInfo.bg.y + guiInfo.bg.h/2 + 170/zoom, tocolor(140, 140, 140, 255 * self.alpha), 1/zoom, self.fonts.category, "center", "center")
        end
        self.referenceButtonHidden = nil
    end
end

function Dashboard:switchSelect(...)
    exports.TR_dx:setResponseEnabled(true, "Değişiklikler uygulanıyor")

    if arg[1] == self.switches.hud then
        local state = exports.TR_dx:isSwitchSelected(self.switches.hud)
        exports.TR_hud:setHudBlocked(not state)

    elseif arg[1] == self.switches.nicks then
        local state = exports.TR_dx:isSwitchSelected(self.switches.nicks)
        exports.TR_hud:setNamesBlocked(not state)

    elseif arg[1] == self.switches.fps then
        local state = exports.TR_dx:isSwitchSelected(self.switches.fps)
        exports.TR_hud:setFpsBlocked(not state)

    elseif arg[1] == self.switches.chat then
        local state = exports.TR_dx:isSwitchSelected(self.switches.chat)
        exports.TR_chat:setChatBlockVisible(not state)

    elseif arg[1] == self.switches.water then
        local state = exports.TR_dx:isSwitchSelected(self.switches.water)
        exports.TR_shaders:setWaterTexture(state)

    elseif arg[1] == self.switches.sky then
        local state = exports.TR_dx:isSwitchSelected(self.switches.sky)
        exports.TR_shaders:setDynamicSky(state)

    elseif arg[1] == self.switches.colors then
        local state = exports.TR_dx:isSwitchSelected(self.switches.colors)
        exports.TR_shaders:setPalette(state)

    elseif arg[1] == self.switches.textures then
        local state = exports.TR_dx:isSwitchSelected(self.switches.textures)
        exports.TR_shaders:setTextures(state)

    elseif arg[1] == self.switches.vehicles then
        local state = exports.TR_dx:isSwitchSelected(self.switches.vehicles)
        exports.TR_shaders:setVehicleReflexes(state)

    elseif arg[1] == self.switches.snow then
        local state = exports.TR_dx:isSwitchSelected(self.switches.snow)
        exports.TR_weather:setSnowBlocked(not state)

    elseif arg[1] == self.switches.rain then
        local state = exports.TR_dx:isSwitchSelected(self.switches.rain)
        exports.TR_shaders:setRainTexture(not state)

    elseif arg[1] == self.switches.premium then
        local state = exports.TR_dx:isSwitchSelected(self.switches.premium)
        exports.TR_chat:blockPremium(not state)

    elseif arg[1] == self.switches.advertisement then
        local state = exports.TR_dx:isSwitchSelected(self.switches.advertisement)
        exports.TR_advertisements:block(not state)

    elseif arg[1] == self.switches.wantRP then
        local state = exports.TR_dx:isSwitchSelected(self.switches.wantRP)
        setElementData(localPlayer, "wantRP", state)
        self:responseShader()

    elseif arg[1] == self.switches.characterDesc then
        local state = exports.TR_dx:isSwitchSelected(self.switches.characterDesc)
        exports.TR_hud:setCharacterDescVisible(state)

    elseif arg[1] == self.switches.firstPerson then
        local state = exports.TR_dx:isSwitchSelected(self.switches.firstPerson)
        exports.TR_firstperson:setFirspersonEnabled(state)

    elseif arg[1] == self.switches.smsOff then
        local state = exports.TR_dx:isSwitchSelected(self.switches.smsOff)
        setElementData(localPlayer, "smsOff", not state)
        self:responseShader()

    elseif arg[1] == self.switches.vehicleEngine then
        local state = exports.TR_dx:isSwitchSelected(self.switches.vehicleEngine)
        exports.TR_vehicleEngine:toggleEngines(state)

    elseif arg[1] == self.switches.realisticNight then
        local state = exports.TR_dx:isSwitchSelected(self.switches.realisticNight)
        exports.TR_weather:setRealisticNight(state)

    elseif arg[1] == self.switches.farClipDistance then
        local state = exports.TR_dx:isSwitchSelected(self.switches.farClipDistance)
        if state then
            setFarClipDistance(2600)
        else
            resetFarClipDistance()
        end
        self:responseShader()

    elseif arg[1] == self.switches.gpsSound then
        local state = exports.TR_dx:isSwitchSelected(self.switches.gpsSound)
        exports.TR_hud:setGpsVoice(state)

    elseif arg[1] == self.switches.blipsMapOrder then
        local state = exports.TR_dx:isSwitchSelected(self.switches.blipsMapOrder)
        exports.TR_hud:setBlipsMapOrder(state)

    elseif arg[1] == self.switches.hoseSmooth then
        local state = exports.TR_dx:isSwitchSelected(self.switches.hoseSmooth)
        exports.TR_objectManager:setHoseSmooth(state)
        self:responseShader()

    elseif arg[1] == self.switches.chatMinified then
        local state = exports.TR_dx:isSwitchSelected(self.switches.chatMinified)
        exports.TR_chat:setMinified(state)

    elseif arg[1] == self.switches.windRose then
        local state = exports.TR_dx:isSwitchSelected(self.switches.windRose)
        exports.TR_hud:setWindRoseVisible(state)

    elseif arg[1] == self.switches.blurLevel then
        local state = exports.TR_dx:isSwitchSelected(self.switches.blurLevel)
        if state then
            setBlurLevel(36)
        else
            setBlurLevel(0)
        end

        self:responseShader()

    elseif arg[1] == self.previewEnabledSwitch then
        local state = exports.TR_dx:isSwitchSelected(self.previewEnabledSwitch)
        self.enabledPreviews = state
        if state then
            self:createPreview()
        else
            self:removePreview()
        end

        self:responseShader()
        return
    end
    if not arg[2] then self:saveSettings() end
end

function Dashboard:createPreview(index)
    if not self.enabledPreviews then return end
    self:removePreview()
    if not self.loaded then return end

    self.previews = {}
    local tab = guiInfo.categories[self.tab][2]

    if tab == "player" then
        if tonumber(self.playerData.skin) ~= nil then
            table.insert(self.previews, {
                element = createPed(tonumber(self.playerData.skin), 0, 0, 0)
            })
        else
            table.insert(self.previews, {
                element = createPed(0, 0, 0, 0)
            })
            setElementData(self.previews[#self.previews].element, "customModel", self.playerData.skin, false)
        end

        setElementInterior(self.previews[#self.previews].element, getElementInterior(localPlayer))
        setElementDimension(self.previews[#self.previews].element, getElementDimension(localPlayer))

        self.previews[#self.previews].preview = exports.TR_preview:createObjectPreview(self.previews[#self.previews].element, -6, 0, 184, guiInfo.bg.x + 250/zoom, guiInfo.bg.y + (guiInfo.bg.h - 600/zoom)/2, 600/zoom, 600/zoom, false, true, true)

    elseif tab == "vehicle" and not self.vehiclePreview then
        for i = 1, guiInfo.vehicles.visible do
            if self.vehicleData[i + self.scroll] then
                table.insert(self.previews, {
                    element = createVehicle(self.vehicleData[i + self.scroll].model, 0, 0, 0)
                })
                if tonumber(self.vehicleData[i + self.scroll].model) ~= 522 then
                    local variant = split(self.vehicleData[i + self.scroll].variant, ",")
                    setVehicleVariant(self.previews[#self.previews].element, tonumber(variant[1]), tonumber(variant[2]))
                end
                setElementInterior(self.previews[#self.previews].element, getElementInterior(localPlayer))
                setElementDimension(self.previews[#self.previews].element, getElementDimension(localPlayer))

                local color = split(self.vehicleData[i + self.scroll].color, ",")
                setVehicleColor(self.previews[#self.previews].element, color[1], color[2], color[3], color[4], color[5], color[6], color[7], color[8], color[9], color[10], color[11], color[12])
                setVehiclePaintjob(self.previews[#self.previews].element, self.vehicleData[i].paintjob or 3)
                setElementCollisionsEnabled(self.previews[#self.previews].element, false)

                if self.vehicleData[i + self.scroll].tuning then
                    local upgrades = fromJSON(self.vehicleData[i + self.scroll].tuning)
                    if upgrades then
                        for i, v in pairs(upgrades) do
                            addVehicleUpgrade(self.previews[#self.previews].element, v)
                        end
                    end
                end

                self.previews[#self.previews].preview = exports.TR_preview:createObjectPreview(self.previews[#self.previews].element, 0, 0, 220, guiInfo.bg.x + 50/zoom, guiInfo.bg.y + (i-1) * guiInfo.vehicles.h - guiInfo.vehicles.h/2, guiInfo.vehicles.h * 2, guiInfo.vehicles.h * 2, false, true)
            end
        end

    elseif tab == "vehicle" and self.vehiclePreview then
        table.insert(self.previews, {
            element = createVehicle(self.vehicleData[self.vehiclePreview].model, 0, 0, 0)
        })
        if tonumber(self.vehicleData[self.vehiclePreview].model) ~= 522 then
            local variant = split(self.vehicleData[self.vehiclePreview].variant, ",")
            setVehicleVariant(self.previews[#self.previews].element, tonumber(variant[1]), tonumber(variant[2]))
        end

        setElementInterior(self.previews[#self.previews].element, getElementInterior(localPlayer))
        setElementDimension(self.previews[#self.previews].element, getElementDimension(localPlayer))

        local color = split(self.vehicleData[self.vehiclePreview].color, ",")
        setVehicleColor(self.previews[#self.previews].element, color[1], color[2], color[3], color[4], color[5], color[6], color[7], color[8], color[9], color[10], color[11], color[12])
        setVehiclePaintjob(self.previews[#self.previews].element, self.vehicleData[self.vehiclePreview].paintjob or 3)
        setElementCollisionsEnabled(self.previews[#self.previews].element, false)

        if self.vehicleData[self.vehiclePreview].tuning then
            local upgrades = fromJSON(self.vehicleData[self.vehiclePreview].tuning)
            if upgrades then
                for i, v in pairs(upgrades) do
                    addVehicleUpgrade(self.previews[#self.previews].element, v)
                end
            end
        end

        self.previews[#self.previews].preview = exports.TR_preview:createObjectPreview(self.previews[#self.previews].element, 0, 6, 220, guiInfo.bg.x + 150/zoom, guiInfo.bg.y + (guiInfo.bg.h - 600/zoom)/2, 600/zoom, 600/zoom, false, true)
    end
end

function Dashboard:selectVehiclePreview(...)
    if arg[1] then
        exports.TR_dx:setResponseEnabled(true)
        self.vehicleToInspect = arg[1]
        triggerServerEvent("getLastVehicleDrivers", resourceRoot, self.vehicleData[self.vehicleToInspect].ID)
    else
        self.vehiclePreview = nil
        self.revealData = nil
        self.drivers = nil

        self:createPreview()
        self:switchButtons()
    end
end

function Dashboard:loadVehicleDashboardInspect(...)
    self.drivers = {}
    self.vehiclePreview = self.vehicleToInspect
    self.vehicleToInspect = nil

    if #arg[1] > 0 then
        for i, v in pairs(arg[1]) do
            local time = split(v.driveDate, " ")
            local date = split(time[1], "-")
            local hour = split(time[2], ":")
            table.insert(self.drivers, string.format("- %s (%02d:%02d %02d.%02d.%dr.)", v.username, hour[1], hour[2], date[3], date[2], date[1]))
        end
    else
        table.insert(self.drivers, "Yeni sürücü yok")
    end

    self:createPreview()
    self:switchButtons()

    exports.TR_dx:setResponseEnabled(false)
end

function Dashboard:selectHouse(...)
    self.houseSelected = arg[1]

    self:switchButtons()
end

function Dashboard:selectLog(...)
    self.logSelected = arg[1]
    self.revealData = nil

    self:switchButtons()
end

function Dashboard:selectPenalty(...)
    self.penaltySelected = arg[1]
    self.revealData = nil

    self:switchButtons()
end

function Dashboard:createButtons()
    self.buttons = {}
    self.buttons.revealHidden = exports.TR_dx:createButton(guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2 + 50/zoom, 250/zoom, 40/zoom, "Hassas verileri göster")
    self.buttons.localizeVehicle = exports.TR_dx:createButton(guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2 - 20/zoom, 250/zoom, 40/zoom, "Aracı takip et")
    self.buttons.backPreview = exports.TR_dx:createButton(guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2 + 30/zoom, 250/zoom, 40/zoom, "Listeye geri dön")
    self.buttons.showLogs = exports.TR_dx:createButton(guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2 - 140/zoom, 250/zoom, 40/zoom, "Hassas verileri göster")
    self.buttons.backLogs = exports.TR_dx:createButton(guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2 - 90/zoom, 250/zoom, 40/zoom, "Listeye geri dön")
    self.buttons.showPenalty = exports.TR_dx:createButton(guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2 - 140/zoom, 250/zoom, 40/zoom, "Hassas verileri göster")
    self.buttons.backPenalty = exports.TR_dx:createButton(guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2 - 90/zoom, 250/zoom, 40/zoom, "Listeye geri dön")
    self.buttons.backHouse = exports.TR_dx:createButton(guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2 - 50/zoom, 250/zoom, 40/zoom, "Listeye geri dön")
    self.buttons.playCards = exports.TR_dx:createButton(guiInfo.bg.x + (guiInfo.bg.w - guiInfo.card.w)/2 - guiInfo.card.w + 450/zoom, guiInfo.bg.y + (guiInfo.bg.h + guiInfo.card.h)/2 - 50/zoom, 250/zoom, 40/zoom, string.format("Oyna (%d)", self.playerData.cardPlays))
    self.buttons.changePassword = exports.TR_dx:createButton(guiInfo.bg.x + (guiInfo.bg.w - 250/zoom)/2, guiInfo.bg.y + (guiInfo.bg.h - 300/zoom)/2 + 195/zoom, 250/zoom, 40/zoom, "Değiştir")
    self.buttons.changeMail = exports.TR_dx:createButton(guiInfo.bg.x + 1150/zoom, guiInfo.bg.y + (guiInfo.bg.h - 300/zoom)/2 + 190/zoom, 250/zoom, 40/zoom, "Değiştir")
    self.buttons.getReferences = exports.TR_dx:createButton(guiInfo.bg.x + (guiInfo.bg.w - 250/zoom)/2, guiInfo.bg.y + guiInfo.bg.h/2 + 130/zoom, 250/zoom, 40/zoom, "Ödülünü Al")
    self.buttons.useReferences = exports.TR_dx:createButton(guiInfo.bg.x + (guiInfo.bg.w - 250/zoom)/2, guiInfo.bg.y + guiInfo.bg.h/2 + 350/zoom, 250/zoom, 40/zoom, "Kodu Kullan")

    self.buttons.descSave = exports.TR_dx:createButton(guiInfo.bg.x + guiInfo.bg.w - guiInfo.bg.x - 250/zoom, guiInfo.bg.y + 715/zoom, 250/zoom, 40/zoom, "Durumu Kaydet", "green")
    self.buttons.descDefaultColor = exports.TR_dx:createButton(guiInfo.bg.x + 300/zoom, guiInfo.bg.y + 715/zoom, 250/zoom, 40/zoom, "Varsayılan rengi ekle")

    self.buttons.addFriend = exports.TR_dx:createButton(sx/2 + 130/zoom, sy/2 + 370/zoom, 250/zoom, 40/zoom, "Arkadaş Ekle")
    exports.TR_dx:setButtonVisible(self.buttons, false)

    self:createEdits()
    self:createSwitches()
end

function Dashboard:createEdits()
    self.edits = {}
    self.edits.currPassword = exports.TR_dx:createEdit(guiInfo.bg.x + (guiInfo.bg.w - 250/zoom)/2, guiInfo.bg.y + (guiInfo.bg.h - 300/zoom)/2 + 35/zoom, 250/zoom, 40/zoom, "Mevut şifre", true)
    self.edits.newPassword = exports.TR_dx:createEdit(guiInfo.bg.x + (guiInfo.bg.w - 250/zoom)/2, guiInfo.bg.y + (guiInfo.bg.h - 300/zoom)/2 + 85/zoom, 250/zoom, 40/zoom, "Yeni şifre", true)
    self.edits.newPasswordRe = exports.TR_dx:createEdit(guiInfo.bg.x + (guiInfo.bg.w - 250/zoom)/2, guiInfo.bg.y + (guiInfo.bg.h - 300/zoom)/2 + 135/zoom, 250/zoom, 40/zoom, "Yeni şifre tekrar", true)

    self.edits.currEmail = exports.TR_dx:createEdit(guiInfo.bg.x + 1150/zoom, guiInfo.bg.y + (guiInfo.bg.h - 300/zoom)/2 + 40/zoom, 250/zoom, 40/zoom, "Mevcut email")
    self.edits.newEmail = exports.TR_dx:createEdit(guiInfo.bg.x + 1150/zoom, guiInfo.bg.y + (guiInfo.bg.h - 300/zoom)/2 + 90/zoom, 250/zoom, 40/zoom, "Yeni email")
    self.edits.newEmailRe = exports.TR_dx:createEdit(guiInfo.bg.x + 1150/zoom, guiInfo.bg.y + (guiInfo.bg.h - 300/zoom)/2 + 140/zoom, 250/zoom, 40/zoom, "Yeni email tekrar")

    self.edits.charDesc = exports.TR_dx:createEdit(guiInfo.bg.x + 300/zoom, guiInfo.bg.y + 660/zoom, guiInfo.bg.w - guiInfo.bg.x - 300/zoom, 45/zoom, "Yeni bir durum giriniz")

    self.edits.referenceCode = exports.TR_dx:createEdit(guiInfo.bg.x + (guiInfo.bg.w - 250/zoom)/2, guiInfo.bg.y + guiInfo.bg.h/2 + 300/zoom, 250/zoom, 40/zoom, "Referans kodunu giriniz")

    self.edits.addFriend = exports.TR_dx:createEdit(sx/2 - 230/zoom, sy/2 + 370/zoom, 350/zoom, 40/zoom, "Nick giriniz")
    exports.TR_dx:setEditLimit(self.edits.charDesc, guiInfo.descriptionLimit)

    exports.TR_dx:setEditVisible(self.edits, false)
end

function Dashboard:createSwitches()
    self.switches = {}
    self.previewEnabledSwitch = exports.TR_dx:createSwitch(guiInfo.bg.x + guiInfo.bg.w/2, guiInfo.bg.y + (guiInfo.bg.h + 400/zoom)/2 + 100/zoom, 50/zoom, 30/zoom)
    exports.TR_dx:setSwitchSelected(self.previewEnabledSwitch, self.enabledPreviews)

    -- Game
    local y = (sy - (#guiInfo.settingsList["game"] * 40/zoom))/2
    for i, v in pairs(guiInfo.settingsList["game"]) do
        if v.switch then
            self.switches[v.switch] = exports.TR_dx:createSwitch(guiInfo.bg.x + 440/zoom, y, 50/zoom, 30/zoom)
        end

        y = y + 40/zoom
    end

    -- Graphics
    local y = (sy - (#guiInfo.settingsList["graphic"] * 40/zoom))/2
    for i, v in pairs(guiInfo.settingsList["graphic"]) do
        if v.switch then
            self.switches[v.switch] = exports.TR_dx:createSwitch(guiInfo.bg.x + 900/zoom, y, 50/zoom, 30/zoom)
        end

        y = y + 40/zoom
    end

    exports.TR_dx:setSwitchVisible(self.switches, false)
    exports.TR_dx:setSwitchVisible(self.previewEnabledSwitch, false)

    self:getSettings()
end

function Dashboard:changePassword()
    local currPas = guiGetText(self.edits.currPassword)
    local newPass = guiGetText(self.edits.newPassword)
    local newPassRe = guiGetText(self.edits.newPasswordRe)
    if string.len(currPas) < 1 or string.len(newPass) < 1 or string.len(newPassRe) < 1 then
        exports.TR_noti:create("Lütfen boşlukları doldur", "error")
        return
    end
    if not string.checkLen(newPass, 3, 40) or not string.checkLen(newPassRe, 3, 40) then
        exports.TR_noti:create("Parola 3 ila 40 karakter içermelidir.", "error")
        return
    end
    if newPass ~= newPassRe then
        exports.TR_noti:create("Şifreler uyuşmuyor.", "error")
        return
    end
    if calculateStrength(newPass) <= 50 then
        exports.TR_noti:create("Yeni parola yeterince güvenli değil.", "error")
        return
    end
    if currPas == newPass then
        exports.TR_noti:create("Yeni şifre mevcut şifre ile aynı olamaz.", "error")
        return
    end

    exports.TR_dx:setResponseEnabled(true)
    triggerServerEvent("changePlayerPassword", resourceRoot, currPas, newPass)
end

function Dashboard:changeMail()
    local currMail = guiGetText(self.edits.currEmail)
    local newMail = guiGetText(self.edits.newEmail)
    local newMailRe = guiGetText(self.edits.newEmailRe)
    if string.len(currMail) < 1 or string.len(newMail) < 1 or string.len(newMailRe) < 1 then
        exports.TR_noti:create("Lütfen boşlukları doldur.", "error")
        return
    end
    if not isValidMail(newMail) then
        exports.TR_noti:create("E-posta adresi geçerli değil.", "error")
        return
    end
    if newMail ~= newMailRe then
        exports.TR_noti:create("E-posta adresleri eşleşmiyor.", "error")
        return
    end
    if currMail == newMail then
        exports.TR_noti:create("Yeni e-posta adresi mevcut olanla aynı olamaz.", "error")
        return
    end

    exports.TR_dx:setResponseEnabled(true)
    triggerServerEvent("changePlayerEmail", resourceRoot, currMail, newMail)
end

function Dashboard:removePreview()
    if self.previews then
        for _, v in pairs(self.previews) do
            exports.TR_preview:destroyObjectPreview(v.preview)
            if isElement(v.element) then destroyElement(v.element) end
        end
        self.previews = nil
    end
end

function Dashboard:calculateMaxHouse(houseLimit)
    local limit = houseLimit

    if self.playerData.premium == "gold" then
      limit = limit + 3

    elseif self.playerData.premium == "diamond" then
      limit = limit + 5
    end

    return limit
end

function Dashboard:calculateMaxVehicle(vehicleLimit)
    local limit = vehicleLimit

    if self.playerData.premium == "gold" then
      limit = limit + 10

    elseif self.playerData.premium == "diamond" then
      limit = limit + 30
    end

    return limit
end

function Dashboard:response(...)
    exports.TR_dx:setResponseEnabled(false)

    if arg[1] == "reference" then
        self.playerData.referenced = self.playerData.referenced + 1

    elseif arg[1] == "referenceAdded" then
        self.playerData.hasReferenceUsed = true
        exports.TR_dx:setButtonVisible(self.buttons.useReferences, false)
        exports.TR_dx:setEditVisible(self.edits.referenceCode, false)

    elseif arg[1] then
        exports.TR_noti:create(arg[1], arg[2])
    end
    if arg[3] then
        local title, img = self:getLogsData(arg[3].type)
        local time = getRealTime()

        table.insert(self.logs, 1, {
            title = title,
            img = img,
            text = arg[3].text,
            serial = arg[3].serial,
            ip = arg[3].ip,
            date = string.format("%02d:%02d:%02d %02d.%02d.%04dr.", time.hour, time.minute, time.second, time.monthday, time.month, time.year),
        })
    end
end

function Dashboard:responseShader(...)
    setTimer(function()
        exports.TR_dx:setResponseEnabled(false)
    end, 1000, 1)
end

function Dashboard:getVehicleName(model)
    if model == 471 then return "Snowmobile" end
    if model == 604 then return "Christmas Manana" end
    return getVehicleNameFromModel(model)
end

function Dashboard:isMouseInPosition(x, y, width, height)
    if (not isCursorShowing()) then
          return false
      end
    local cx, cy = getCursorPosition()
    local cx, cy = (cx*sx), (cy*sy)
    if (cx >= x and cx <= x + width) and (cy >= y and cy <= y + height) then
      return true
    else
      return false
    end
end

function Dashboard:getTimeInSeconds(seconds)
    local seconds = tonumber(seconds)

    if seconds <= 0 then
      return "00:00:00";
    else
      hours = string.format("%02.f", math.floor(seconds/3600));
      mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
      secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
      return hours..":"..mins..":"..secs
    end
end

function Dashboard:getSettings()
    local xml = xmlLoadFile("settings.xml")
    if not xml then return end

    for i, _ in pairs(self.switches) do
        if not xmlFindChild(xml, i, 0) then
            fileDelete("settings.xml")
            self:getSettings()
            return
        end
        local node = xmlFindChild(xml, i, 0)
        local state = xmlNodeGetValue(node)
        if tonumber(state) > 0 then
            exports.TR_dx:setSwitchSelected(self.switches[i], true)
        else
            exports.TR_dx:setSwitchSelected(self.switches[i], false)
        end
    end
    return
end

function Dashboard:saveSettings()
    local xml = xmlLoadFile("settings.xml")
    if not xml then return end

    for i, _ in pairs(self.switches) do
        local node = xmlFindChild(xml, i, 0)
        local selected = exports.TR_dx:isSwitchSelected(self.switches[i])

        xmlNodeSetValue(node, selected and 1 or 0)
    end

    xmlSaveFile(xml)
    xmlUnloadFile(xml)
end


function Dashboard:loadSettings()
    local xml = xmlLoadFile("settings.xml")
    if not xml then
        xml = xmlCreateFile("settings.xml", "settings")

        for i, v in pairs(guiInfo.defaultSettings) do
            local node = xmlCreateChild(xml, i)
            xmlNodeSetValue(node, v)
        end

        xmlSaveFile(xml)
    end

    for i, _ in pairs(guiInfo.defaultSettings) do
        local node = xmlFindChild(xml, i, 0)
        if not node then
            fileDelete("settings.xml")
            self:loadSettings()
            return
        end

        local state = tonumber(xmlNodeGetValue(node))
        if not state then state = defaultSettings[i] end

        if i == "hud" and state < 1 then
            exports.TR_hud:setHudBlocked(true)

        elseif i == "nicks" and state < 1 then
            exports.TR_hud:setNamesBlocked(true)

        elseif i == "fps" and state < 1 then
            exports.TR_hud:setFpsBlocked(true)

        elseif i == "chat" and state < 1 then
            exports.TR_chat:setChatBlockVisible(true)

        elseif i == "water" and state > 0 then
            exports.TR_shaders:setWaterTexture(true)

        elseif i == "sky" and state > 0 then
            exports.TR_shaders:setDynamicSky(true)

        elseif i == "colors" and state > 0 then
            exports.TR_shaders:setPalette(true)

        elseif i == "textures" and state > 0 then
            exports.TR_shaders:setTextures(true)

        elseif i == "vehicles" and state > 0 then
            exports.TR_shaders:setVehicleReflexes(true)

        elseif i == "snow" and state < 1 then
            exports.TR_weather:setSnowBlocked(true)

        elseif i == "rain" and state > 0 then
            exports.TR_shaders:setRainTexture(false)
            -- exports.TR_shaders:setRainTexture(false)

        elseif i == "advertisement" and state > 0 then
            exports.TR_advertisements:block(false)

        elseif i == "premium" and state > 0 then
            exports.TR_chat:blockPremium(false)

        elseif i == "vehicleEngine" and state < 1 then
            exports.TR_vehicleEngine:toggleEngines(false)

        elseif i == "realisticNight" and state > 0 then
            exports.TR_weather:setRealisticNight(true)

        elseif i == "wantRP" and state > 0 then
            setElementData(localPlayer, "wantRP", true)

        elseif i == "characterDesc" and state < 1 then
            exports.TR_hud:setCharacterDescVisible(false)

        elseif i == "firstPerson" and state > 0 then
            exports.TR_firstperson:setFirspersonEnabled(true)

        elseif i == "smsOff" and state < 1 then
            setElementData(localPlayer, "smsOff", true)

        elseif i == "farClipDistance" and state > 0 then
            setFarClipDistance(3000)

        elseif i == "gpsSound" and state > 0 then
            exports.TR_hud:setGpsVoice(true)

        elseif i == "blipsMapOrder" and state < 1 then
            exports.TR_hud:setBlipsMapOrder(false)

        elseif i == "hoseSmooth" and state > 0 then
            exports.TR_objectManager:setHoseSmooth(true)

        elseif i == "chatMinified" and state > 0 then
            exports.TR_chat:setMinified(true)

        elseif i == "windRose" and state < 1 then
            exports.TR_hud:setWindRoseVisible(false)

        elseif i == "blurLevel" and state < 1 then
            setBlurLevel(0)

        end
    end

    xmlUnloadFile(xml)
end


function Dashboard:getCharacterDescriptions()
    local xml = xmlLoadFile("descriptions.xml", true)
    if not xml then return end

    for _, node in pairs(xmlNodeGetChildren(xml)) do
        local text = xmlNodeGetValue(node)
        table.insert(self.descList, utf8.sub(text, 1, math.min(utf8.len(text), guiInfo.descriptionLimit)))
    end

    xmlUnloadFile(xml)
    return
end

function Dashboard:saveCharacterDescriptions()
    if fileExists("descriptions.xml") then fileDelete("descriptions.xml") end
    local xml = xmlCreateFile("descriptions.xml", "descriptions")

    for _, text in pairs(self.descList) do
        local node = xmlCreateChild(xml, "description")
        xmlNodeSetValue(node, text)
    end

    xmlSaveFile(xml)
    xmlUnloadFile(xml)
    return
end

function createDashboard()
    if guiInfo.dashboard then return end
    guiInfo.dashboard = Dashboard:create()
end

function setDashboardData(...)
    if not guiInfo.dashboard then return end
    guiInfo.dashboard:setData(...)
end
addEvent("setDashboardData", true)
addEventHandler("setDashboardData", root, setDashboardData)

function loadPlayerFriends(...)
    guiInfo.dashboard:loadFriends(...)
end
addEvent("loadPlayerFriends", true)
addEventHandler("loadPlayerFriends", root, loadPlayerFriends)

function setDashboardResponse(...)
    if not guiInfo.dashboard then return end
    guiInfo.dashboard:response(...)
end
addEvent("setDashboardResponse", true)
addEventHandler("setDashboardResponse", root, setDashboardResponse)

function onFriendLogin(...)
    if not guiInfo.dashboard then return end
    guiInfo.dashboard:onFriendLogin(...)
end
addEvent("onFriendLogin", true)
addEventHandler("onFriendLogin", root, onFriendLogin)

function updateCardPlays(amount)
    if amount == 1 then
        exports.TR_noti:create("Fazladan bir oyun kağıdını başarıyla satın aldınız.", "success", 5)
    else
        exports.TR_noti:create("Ek 10 kart oyununu başarıyla satın aldınız.", "success", 5)
    end

    if not guiInfo.dashboard then return end
    guiInfo.dashboard:updateCardPlays(amount)
end
addEvent("updateCardPlays", true)
addEventHandler("updateCardPlays", root, updateCardPlays)

function loadVehicleDashboardInspect(drivers)
    guiInfo.dashboard:loadVehicleDashboardInspect(drivers)
end
addEvent("loadVehicleDashboardInspect", true)
addEventHandler("loadVehicleDashboardInspect", root, loadVehicleDashboardInspect)

function setDashboardResponseShader(...)
    if not guiInfo.dashboard then return end
    guiInfo.dashboard:responseShader(...)
end

function canSeePreview(...)
    if not guiInfo.dashboard then return false end
    return guiInfo.dashboard.enabledPreviews
end

function setDashboardTutorial(...)
    if not guiInfo.dashboard then return end
    if arg[1] then
        guiInfo.dashboard:open(true)
    else
        guiInfo.dashboard:close()
    end
end




function string.wrap(text, maxwidth, scale, font, colorcoded)
    local lines = {}
    local words = split(text, " ") -- this unfortunately will collapse 2+ spaces in a row into a single space
    local line = 1 -- begin with 1st line
    local word = 1 -- begin on 1st word
    local endlinecolor
    while (words[word]) do -- while there are still words to read
        repeat
            if colorcoded and (not lines[line]) and endlinecolor and (not string.find(words[word], "^#%x%x%x%x%x%x")) then -- if on a new line, and endline color is set and the upcoming word isn't beginning with a colorcode
                lines[line] = endlinecolor -- define this line as beginning with the color code
            end
            lines[line] = lines[line] or "" -- define the line if it doesnt exist

            if colorcoded then
                local rw = string.reverse(words[word]) -- reverse the string
                local x, y = string.find(rw, "%x%x%x%x%x%x#") -- and search for the first (last) occurance of a color code
                if x and y then
                    endlinecolor = string.reverse(string.sub(rw, x, y)) -- stores it for the beginning of the next line
                end
            end

            lines[line] = lines[line]..words[word] -- append a new word to the this line
            lines[line] = lines[line] .. " " -- append space to the line

            word = word + 1 -- moves onto the next word (in preparation for checking whether to start a new line (that is, if next word won't fit)
        until ((not words[word]) or dxGetTextWidth(lines[line].." "..words[word], scale, font, colorcoded) > maxwidth) -- jumps back to 'repeat' as soon as the code is out of words, or with a new word, it would overflow the maxwidth

        lines[line] = string.sub(lines[line], 1, -2) -- removes the final space from this line
        if colorcoded then
            lines[line] = string.gsub(lines[line], "#%x%x%x%x%x%x$", "") -- removes trailing colorcodes
        end
        line = line + 1 -- moves onto the next line
    end -- jumps back to 'while' the a next word exists
    return table.concat(lines, "\n")
end

function string.checkLen(text, minLen, maxLen)
    if string.len(text) >= minLen and string.len(text) <= maxLen then return true else return false end
end

function isValidMail(mail)
    assert(type(mail) == "string", "Bad argument @ isValidMail [string expected, got "..tostring(mail) .."]")
    return mail:match("[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?") ~= nil
  end

function calculateStrength(password)
    local length = string.len(password)
    if length < 3 then return 0, "bad" end

    local score = 10
    local scoreText = "bad"
    if string.find(password, "%l") then -- lower
      score = score + 15
    end
    if string.find(password, "%u") then -- upper
      score = score + 20
    end
    if string.find(password, "%d") then -- digits
      score = score + 25
    end
    if string.find(password, "%W") then -- symbols
      score = score + 30
    end

    if score >= 20 and score <= 50 then
      scoreText = "medium"
    elseif score > 50 and score <= 70 then
      scoreText = "strong"
    elseif score > 70 then
      scoreText = "excellent"
    end

    return score, scoreText
end

function getSettings(settings)
    local xml = xmlLoadFile("settings.xml")
    if not xml then return false end

    local node = xmlFindChild(xml, settings, 0)
    if not node then return false end
    if tonumber(xmlNodeGetValue(node)) > 0 then return true end
    return false
end

function teaEncodeBinary(data, key)
    return teaEncode(base64Encode(data), key)
end

if getElementData(localPlayer, "characterUID") then
    createDashboard()
end
exports.TR_dx:setOpenGUI(false)