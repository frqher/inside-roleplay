local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = 0,
    y = (sy - 90/zoom)/2,
    w = 260/zoom,
    h = 90/zoom,

    buttonTime = 10,

    int = 0,
    dim = 0,
}

Tutorial = {}
Tutorial.__index = Tutorial

function Tutorial:create(...)
    local instance = {}
    setmetatable(instance, Tutorial)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function Tutorial:constructor(...)
    self.alpha = 0
    self.tab = 0

    self.buttonTick = getTickCount()
    self.buttonTime = guiInfo.buttonTime

    self.fonts = {}
    self.fonts.title = exports.TR_dx:getFont(16)
    self.fonts.distance = exports.TR_dx:getFont(14)
    self.fonts.info = exports.TR_dx:getFont(12)
    self.fonts.action = exports.TR_dx:getFont(11)

    self.buttons = {}
    self.buttons.next = exports.TR_dx:createButton((sx - 200/zoom)/2, 580/zoom, 200/zoom, 40/zoom, string.format("%ss", self.buttonTime))

    self.func = {}
    self.func.renderHigh = function() self:renderHigh() end
    self.func.renderNormal = function() self:renderNormal() end
    self.func.markerEnter = function(...) self:markerEnter(...) end
    self.func.buttonClick = function(...) self:buttonClick(...) end

    self:open()
    return true
end

function Tutorial:open()
    exports.TR_dx:setOpenGUI(true)
    exports.TR_chat:setChatBlocked(true)

    exports.TR_hud:createGUI()
    exports.TR_chat:createChat(500)

    self.state = "opening"
    self.tick = getTickCount()

    self:setControl(false)

    showCursor(true)
    setCameraTarget(localPlayer)
    addEventHandler("onClientRender", root, self.func.renderHigh, false, "high+4")
    addEventHandler("onClientRender", root, self.func.renderNormal)
    addEventHandler("guiButtonClick", root, self.func.buttonClick)
    addEventHandler("onClientColShapeHit", resourceRoot, self.func.markerEnter)

    triggerServerEvent("spawnPlayerCharacter", resourceRoot, string.format("-4643.36,353.66,4.34,%d,%d", guiInfo.int, guiInfo.dim), 260)

    setTimer(function()
        exports.TR_dx:hideLoading()
    end, 4000, 1)
end

function Tutorial:close()
    self.state = "closing"
    self.tick = getTickCount()

    if isElement(self.marker) then destroyElement(self.marker) end

    showCursor(false)
    self:setControl(true)
end

function Tutorial:destroy()
    exports.TR_dx:setOpenGUI(false)
    exports.TR_chat:setChatBlocked(false)

    removeEventHandler("onClientRender", root, self.func.renderHigh)
    removeEventHandler("onClientRender", root, self.func.renderNormal)
    removeEventHandler("guiButtonClick", root, self.func.buttonClick)
    removeEventHandler("onClientColShapeHit", resourceRoot, self.func.markerEnter)
    guiInfo.tutorial = nil
    self = nil
end


function Tutorial:animate()
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
        self.state = "closed"
        self.tick = nil

        if self.tab == 28 then
            self:destroy()
            return true
        end
      end
    end
end

function Tutorial:renderNormal()
    if self.tab == 0 then
        dxDrawRectangle(0, 0, sx, sy, tocolor(7, 7, 7, 240 * self.alpha))

        dxDrawText("İlk adım", 0, 350/zoom, sx, sy, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.title, "center", "top")
        dxDrawText("Sunucumuzda oynamaya başlamadan önce size temel fonksiyonları öğretmek isteriz. Bu tür bir sunucuda yeniyseniz endişelenmeyin çünkü size tüm temel işlevleri açıklayacağız ve gerisini diğer oyunculardan öğrenebilirsiniz. Sormaktan korkma. Bu türde başka bir sunucuda oynadıysanız, bu kılavuz size oyuna nasıl başlayacağınızı, arayüzleri ve temel sistemleri öğretecektir .", (sx - 500/zoom)/2, 390/zoom, (sx + 500/zoom)/2, sy, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "top", false, true)

    elseif self.tab == 1 then
        dxDrawRectangle(0, 0, sx - 340/zoom, 250/zoom, tocolor(7, 7, 7, 240 * self.alpha))
        dxDrawRectangle(0, 250/zoom, sx, sy, tocolor(7, 7, 7, 240 * self.alpha))

        dxDrawText("Ana arayüz", sx - 700/zoom, 20/zoom, sx - 340/zoom, guiInfo.y + 25/zoom, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.title, "center", "top")
        dxDrawText("Karakterimizle ilgili en önemli bilgilerin görüntülendiği yer burasıdır.\n- Sağlık\n- Zırh\n- Oksijen\n- Üzerinizdeki para", sx - 700/zoom, 60/zoom, sx - 340/zoom, guiInfo.y + 25/zoom, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.info, "left", "top", false, true)

    elseif self.tab == 2 then
        dxDrawRectangle(0, 0, sx, sy - 250/zoom, tocolor(7, 7, 7, 240 * self.alpha))
        dxDrawRectangle(450/zoom, sy - 250/zoom, sx, 250/zoom, tocolor(7, 7, 7, 240 * self.alpha))

        dxDrawText("Mini Harita", 450/zoom, sy - 320/zoom, 800/zoom, sy, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.title, "center", "top")
        dxDrawText("İşte şu anda bulunduğunuz bölgenin haritası. \"+\" veya \"-\" tuşlarını kullanarak serbestçe yakınlaştırabilir veya uzaklaştırabilirsiniz. Kendinizi mevcut haritada bulmanıza ve ayrıca aşağıdakiler gibi en önemli yerleri bulmanıza yardımcı olacaktır:\n- Bina girişleri\n- Görevler\n- Polis karakolu, itfaiye istasyonu veya hastane. ", 450/zoom, sy - 280/zoom, 800/zoom, sy, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.info, "left", "top", false, true)

    elseif self.tab == 3 then
        dxDrawRectangle(570/zoom, 0, sx, 380/zoom, tocolor(7, 7, 7, 240 * self.alpha))
        dxDrawRectangle(0, 380/zoom, sx, sy, tocolor(7, 7, 7, 240 * self.alpha))

        dxDrawText("Sohbet", 550/zoom, 20/zoom, 1000/zoom, sy, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.title, "center", "top")
        dxDrawText("Oyuncular arasındaki ana iletişim sisteminin bulunduğu yer burasıdır. Normal bir sohbette yazdığınız her şey çevrenizdeki kişiler tarafından görülebilir. Mevcut komutlardan birini kullanmak için mesajı \"/\" ile başlatmanız yeterlidir. İlk harfi girdikten sonra, sistem bize komutun tam sözdizimini söyleyecek ve ne işe yaradığını açıklayacaktır. Komutları yazarken \"TAB\" tuşuna bastığınızda sistem otomatik olarak komutu sonuna kadar tamamlayacaktır. Komutu uygulamak istediğimiz oyuncunun takma adını girerseniz, o sizin için takma adını otomatik tamamlayacaktır.\nBirkaç sohbet modlar var:\n- T - çevrenizdeki insanlar için temel sohbet\n- O - kurumsal sohbet\n- Y - grubunuz içinde sohbet edin\n- U - arayüz sohbeti", 550/zoom, 60/zoom, 1000/zoom, sy, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.info, "left", "top", false, true)

    elseif self.tab == 4 then
        dxDrawRectangle(0, 0, sx - 360/zoom, sy, tocolor(7, 7, 7, 240 * self.alpha))
        dxDrawRectangle(sx - 360/zoom, 0, 360, sy/2 - 150/zoom, tocolor(7, 7, 7, 240 * self.alpha))
        dxDrawRectangle(sx - 360/zoom, sy/2 + 150/zoom, 360, sy/2 - 150/zoom, tocolor(7, 7, 7, 240 * self.alpha))

        dxDrawText("Hedef pencere", sx - 740/zoom, sy/2 - 120/zoom, sx - 360/zoom, sy, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.title, "center", "top")
        dxDrawText("Bu pencerede güncel hedef gösterilir, örn. çalışırken. Ne yapacağınızı bilmiyorsanız, bu yere bakın, her şeyi öğreneceksiniz. Ek olarak, belirli bir işin başlangıcından bu yana ne kadar zaman geçtiğini kontrol edebilirsiniz.", sx - 740/zoom, sy/2 - 80/zoom, sx - 360/zoom, sy, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.info, "left", "top", false, true)

    elseif self.tab == 5 then
        dxDrawRectangle(0, 0, sx, sy, tocolor(7, 7, 7, 240 * self.alpha))

        dxDrawText("Hedef belirleme", 0, sy/2 - 185/zoom, sx, sy, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.title, "center", "top")

        dxDrawImage((sx - 64/zoom)/2, sy/2 - 140/zoom, 64/zoom, 64/zoom, ":TR_jobs/files/images/target.png", 0, 0, 0, tocolor(255, 60, 60, 255 * self.alpha))
        dxDrawText("10m", (sx - 64/zoom)/2, sy/2 - 70/zoom, (sx + 64/zoom)/2, sy, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.distance, "center", "top", false, true)
        dxDrawText("Belirtilen yere git", (sx - 300/zoom)/2, sy/2 - 48/zoom, (sx + 300/zoom)/2, sy, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.action, "center", "top", false, true)

        dxDrawText("Bu sembol mevcut varış noktanızı gösterir. Ondan ne kadar uzakta olursan ol onu göreceksin. Bu sayede gideceğiniz yere giden rotayı bulmanız daha kolay olacaktır. Sembolün altında hedefe olan mesafenizi ve aktivite hakkında bilgi veren kısa bir metin göreceksiniz.", (sx - 600/zoom)/2, sy/2 - 10/zoom, (sx + 600/zoom)/2, sy, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "top", false, true)


    elseif self.tab == 6 or self.tab == 7 then
        dxDrawRectangle(0, 0, sx, sy, tocolor(7, 7, 7, 240 * self.alpha))

        dxDrawText("İnteraktif öğrenim", 0, 370/zoom, sx, sy, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.title, "center", "top")
        dxDrawText("En kolay yol, hatalarınızdan ders çıkarmaktır. Şimdi, sunucunuzdaki en önemli sistemleri nasıl kullanacağınızı gösteren etkileşimli bir eğitimde size yol göstereceğiz. Tüm sistemler siz - oyuncuları düşünerek hazırladık. Yapmak istediğiniz her şeyin tek bir yerde bulunması ve bir sürü komutla uğraşmanıza gerek kalmaması için basitliğe odaklandık.", (sx - 500/zoom)/2, 410/zoom, (sx + 500/zoom)/2, sy, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "top", false, true)

    elseif self.tab == 8 then
        local anim, block = getPedAnimation(localPlayer)
        if anim and block then
            if string.lower(anim) == "" and string.lower(anim) == "" then
                self:setNextState()
            end
        end

    elseif self.tab == 16 or self.tab == 17 then -- Phone help
        dxDrawRectangle(550/zoom, 0, sx, sy, tocolor(7, 7, 7, 240 * self.alpha))
        dxDrawRectangle(0, sy/2, 550/zoom, sy/2, tocolor(7, 7, 7, 240 * self.alpha))

        dxDrawText("Cep telefonu", sx - 740/zoom, sy - 547/zoom, sx - 360/zoom, sy, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.title, "center", "top")
        dxDrawText("Eski bir telefon modeline sahip olabilirsiniz, ancak bu onun işe yaramaz olduğu anlamına gelmez. Sohbet yoluyla kısa mesaj göndermenin yanı sıra birisini de arayabilirsiniz. Ne için? Arama sırasında dahili sesli sohbeti kullanarak konuşabilirsiniz. Ancak, diğer oyuncularla konuşmak tek seçenek değildir. Bir yangın, ateş etme veya araba kazası durumunda her zaman ilgili servisleri arayabilirsiniz. Ancak yakınınızda herhangi bir araç olmazsa taksi çağırabilirsiniz.", sx - 740/zoom, sy - 507/zoom, sx - 360/zoom, sy, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.info, "left", "top", false, true)

        dxDrawText("İnteraktif öğrenim", sx - 740/zoom, sy - 200/zoom, sx - 360/zoom, sy, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.title, "center", "top")
        dxDrawText("Öğreticiyi ilerletmek için telefonun tuş takımındaki düğmelerde LMB'ye basarak Dawn'ın kardeşinin size verdiği numarayı çevirin. Nerede bulacağınızı bilmiyorsanız, sohbete bakın.", sx - 740/zoom, sy - 160/zoom, sx - 360/zoom, sy, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.info, "left", "top", false, true)


    elseif self.tab == 21 or self.tab == 22 then -- Eq help
        dxDrawRectangle(0, 0, sx, sy, tocolor(7, 7, 7, 240 * self.alpha))

        dxDrawText("Karakterin ekipmanı", sx - 1050/zoom, (sy - 450/zoom)/2, sx - 650/zoom, sy, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.title, "center", "top")
        dxDrawText("Karakteriniz, edinilen/satın alınan tüm öğeleri envanterde tutar. İhtiyacınız olduğunda bunlardan birini kullanabilirsiniz. İlgilendiğiniz eşyayı bulmayı kolaylaştırmak için tüm öğeler 5 kategoriye ayrılmıştır. Ayrıca, sık kullandığınız öğelere daha hızlı erişmek istiyorsanız, bunları her zaman \"favoriler\" sekmesine ekleyebilirsiniz, böylece onları bulmak çok hızlı ve kolay olacaktır. Belirli bir öğenin tüm seçeneklerini görmek için, üzerindeki RMB'ye basmanız yeterlidir.", sx - 1050/zoom, (sy - 450/zoom)/2 + 40/zoom, sx - 650/zoom, sy, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.info, "left", "top", false, true)

        dxDrawText("Etkileşimli eğitim", sx - 1050/zoom, (sy - 450/zoom)/2 + 350/zoom, sx - 650/zoom, sy, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.title, "center", "top")
        dxDrawText("Çiziminizi \"Diğer\" sekmesinde bulun, üzerine sağ tıklayın ve \"Kullan\" seçeneğini seçin", sx - 1050/zoom, (sy - 450/zoom)/2 + 390/zoom, sx - 650/zoom, sy, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.info, "left", "top", false, true)


    elseif self.tab == 25 or self.tab == 26 then -- Trade help
        dxDrawRectangle(0, 0, sx, sy, tocolor(7, 7, 7, 240 * self.alpha))

        dxDrawText("Ticaret penceresi", 300/zoom, (sy - 450/zoom)/2, sx/2 - 320/zoom, sy, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.title, "center", "top")
        dxDrawText("Adından da anlaşılacağı gibi, bu bir eşya ticaret sistemidir. Benzersiz bir öğeniz varsa veya bir oyuncudan sizi öğeler için kandıracağından korkmadan bir şey satın almak istiyorsanız, bunu takas penceresinden yapabilirsiniz. Pencereyi açtıktan sonra, envanterinizde satmak istediğiniz öğeyi bulun, ardından üzerindeki RMB'ye basın ve \"Öğeyi teklif et\" seçeneğini seçin. Satılık bir ürünle ilgili ayrıntılı bilgileri görmek için üzerine sağ tıklayın.\nİşlem onayı iki aşamada gerçekleşir. İlk kez üyeler düzenleme yeteneğini kaybeder. Tüm öğeleri gözden geçirmek için mükemmel bir zaman. Her iki tarafın bir sonraki onayından sonra geri dönüş yoktur - işlem başarılı olacaktır.", 300/zoom, (sy - 450/zoom)/2 + 40/zoom, sx/2 - 320/zoom, sy, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.info, "left", "top", false, true)

        dxDrawText("Etkileşimli eğitim", sx - 600/zoom, (sy + 380/zoom)/2, sx, sy, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.title, "center", "top")
        dxDrawText("\"Diğer\" sekmesine gidin, taşıyıcıya ait paketi bulun, RMB'ye basın ve \"Teklif öğesi\" seçeneğini seçin. Şimdi geriye kalan tek şey anlaşmayı kabul etmek, Matthew'un da kabul etmesini beklemek ve anlaşmayı bitirmek!", sx - 500/zoom, (sy + 380/zoom)/2 + 40/zoom, sx - 100/zoom, sy, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.info, "left", "top", false, true)


    -- Last
    elseif self.tab == 27 or self.tab == 28 then
        dxDrawRectangle(0, 0, sx, sy, tocolor(7, 7, 7, 240 * self.alpha))

        dxDrawText("Macera zamanı", 0, 370/zoom, sx, sy, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.title, "center", "top")
        dxDrawText("Sunucuda bulacağınız temel işlevler bu kadar. Umarız bu kısa rehber ilk adımlarınızı atmanıza yardımcı olur ve bu rehber sayesinde tüm arayüzlerin ne işe yaradığını anlarsınız. Elbette sunucuda bulunan tüm sistemler burada sunulmamaktadır, ancak sizin için keşfedeceğiniz bir şey de bırakıyoruz!\n\nTek yapabileceğimiz size iyi oyunlar dilemek.\nYönetim.", (sx - 500/zoom)/2, 410/zoom, (sx + 500/zoom)/2, sy, tocolor(180, 180, 180, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "top", false, true)
    end

    self:checkButton()
end

function Tutorial:renderHigh()
    if self:animate() then return end

    if self.tab == 1 then -- HUD
        dxDrawRectangle(sx - 340/zoom, 0, 340/zoom, 250/zoom, tocolor(7, 7, 7, 240 * self.alpha))

    elseif self.tab == 2 then -- Minimap
        dxDrawRectangle(0, sy - 250/zoom, 450/zoom, 250/zoom, tocolor(7, 7, 7, 240 * self.alpha))

    elseif self.tab == 3 then -- Chat
        dxDrawRectangle(0, 0, 570/zoom, 380/zoom, tocolor(7, 7, 7, 240 * self.alpha))

    elseif self.tab == 4 then -- Work info
        dxDrawRectangle(sx - 360/zoom, sy/2 - 150/zoom, 360/zoom, 300/zoom, tocolor(7, 7, 7, 240 * self.alpha))

    elseif self.tab == 16 or self.tab == 17 then -- Phone help
        dxDrawRectangle(0, 0, 550/zoom, sy/2, tocolor(7, 7, 7, 240 * self.alpha))
    end

    -- exports.TR_dx:setOpenGUI(true)
    -- exports.TR_chat:setChatBlocked(true)
end


function Tutorial:checkButton()
    if not self.buttonTick or not isElement(self.buttons.next) then return end
    if (getTickCount() - self.buttonTick)/1000 >= 1 then
        self.buttonTime = self.buttonTime - 1
        self.buttonTick = nil

        if self.buttonTime == 0 then
            exports.TR_dx:setButtonText(self.buttons.next, self.tab == 27 and "Maceraya başla!" or "Anladım")

        else
            self.buttonTick = getTickCount()
            exports.TR_dx:setButtonText(self.buttons.next, self.tab == 27 and string.format("Maceraya başla %ss", self.buttonTime) or string.format("%ss", self.buttonTime))
        end
    end
end



function Tutorial:setNextState()
    self.tab = self.tab + 1

    self.buttonTime = guiInfo.buttonTime
    self.buttonTick = getTickCount()

    if isElement(self.marker) then destroyElement(self.marker) end
    if isElement(self.buttons.next) then exports.TR_dx:destroyButton(self.buttons.next) end
    self:createDataForState()
end

function Tutorial:createDataForState()
    if self.tab == 1 then
        self.buttons.next = exports.TR_dx:createButton(sx - 700/zoom - (sx - (sx + 700/zoom) + 200/zoom)/2, 230/zoom, 200/zoom, 40/zoom, string.format("%ss", self.buttonTime))
        exports.TR_hud:setGUITutorial(true)

    elseif self.tab == 2 then
        self.buttons.next = exports.TR_dx:createButton(450/zoom + 75/zoom, sy - 50/zoom, 200/zoom, 40/zoom, string.format("%ss", self.buttonTime))
        exports.TR_hud:setGUITutorial(false)

    elseif self.tab == 3 then
        self.buttons.next = exports.TR_dx:createButton(570/zoom + 125/zoom, 450/zoom, 200/zoom, 40/zoom, string.format("%ss", self.buttonTime))

    elseif self.tab == 4 then
        exports.TR_jobs:createInformation("Etkileşimli Eğitim", "Öğreticiyi tamamlayın.")
        self.buttons.next = exports.TR_dx:createButton(sx - (740 - 360)/2/zoom - 460/zoom, 610/zoom, 200/zoom, 40/zoom, string.format("%ss", self.buttonTime))

    elseif self.tab == 5 then
        exports.TR_jobs:removeInformation()
        self.buttons.next = exports.TR_dx:createButton((sx - 200/zoom)/2, 630/zoom, 200/zoom, 40/zoom, string.format("%ss", self.buttonTime))

    elseif self.tab == 6 then
        self.buttons.next = exports.TR_dx:createButton((sx - 200/zoom)/2, 620/zoom, 200/zoom, 40/zoom, string.format("%ss", self.buttonTime))

    elseif self.tab == 7 then
        self.state = "closing"
        self.tick = getTickCount()

        showCursor(false)
        setElementFrozen(localPlayer, false)
        self:setControl(true)

        exports.TR_jobs:setPlayerTargetPos(-4631.6708984375, 349.32421875, 3.6570091247559, guiInfo.int, guiInfo.dim, "Verandadan in")
        exports.TR_jobs:createInformation("Etkileşimli Eğitim", "Verandadan in.")

        self.marker = createColSphere(-4631.6708984375, 349.32421875, 3.6570091247559, 2)
        setElementInterior(self.marker, guiInfo.int)
        setElementDimension(self.marker, guiInfo.dim)

    elseif self.tab == 8 then
        exports.TR_jobs:setPlayerTargetPos(-4608.9873046875, 338.814453125, 5.3641490936279, guiInfo.int, guiInfo.dim, "Şenlik ateşine yaklaş")
        exports.TR_jobs:createInformation("Etkileşimli Eğitim", "Şenlik ateşine yaklaş.")

        self.marker = createColSphere(-4608.9873046875, 338.814453125, 5.3641490936279, 4)
        setElementInterior(self.marker, guiInfo.int)
        setElementDimension(self.marker, guiInfo.dim)

    elseif self.tab == 9 then
        exports.TR_jobs:setPlayerTargetPos(-4612.587890625, 340.77792358398, 5.232964515686, guiInfo.int, guiInfo.dim, "Bankta otur")
        exports.TR_jobs:createInformation("Etkileşimli Eğitim", "Klavyenizdeki \"e\" tuşuna basarak etkileşim panelini açın. Ardından oturmak istediğiniz yeri seçin \"LMB\"ye basın ve \"Otur\" seçeneğini seçin.")

    elseif self.tab == 10 then
        exports.TR_jobs:setPlayerTargetPos(false)
        exports.TR_jobs:createInformation("Etkileşimli Eğitim", "Klavyenizdeki \"F1\" tuşuna basarak yardım panelini açın. Orada en önemli sekmeleri bulacaksınız, örneğin: Kılavuz, Sunucu hakkında genel bilgiler, Düzenlemeler, Güncellemeler ve premium hesaplar hakkında bilgiler.")

    elseif self.tab == 11 then
        exports.TR_jobs:createInformation("Etkileşimli Eğitim", "Şimdi sıra hesabınız, araçlarınız veya mülklerinizle ilgili tüm bilgileri bulacağınız panele geldi. Klavyenizdeki \"F5\" tuşuna basarak açabilirsiniz.")

    elseif self.tab == 12 then
        exports.TR_jobs:createInformation("Etkileşimli Eğitim", "Tezgahtan kalkmak için etkileşimi tekrar kullanın. Oturduğunuz banka basın ve \"Kalk\" öğesini seçin.")

    elseif self.tab == 13 then
        exports.TR_jobs:createInformation("Etkileşimli Eğitim", "Şehre nasıl gidileceğini öğrenmek için binanın içine girin.")
        exports.TR_jobs:setPlayerTargetPos(-4622.4580078125, 351.3349609375, 3.4673318862915, guiInfo.int, guiInfo.dim, "Wejdź do środka")

    elseif self.tab == 14 then
        exports.TR_jobs:createInformation("Etkileşimli Eğitim", "Dawn'ın erkek kardeşinden şehre nasıl gidileceğini öğrenin.")
        exports.TR_jobs:setPlayerTargetPos(2703.6733398438, -1427.5433349609, 62.531028747559, 0, 5, "Dawn ile konuş")

    elseif self.tab == 15 then
        exports.TR_jobs:createInformation("Etkileşimli Eğitim", "Klavyedeki \"END\" tuşu veya /phone komutu ile telefonu açın..")
        exports.TR_jobs:setPlayerTargetPos(false)

    elseif self.tab == 16 then
        exports.TR_jobs:hideInformation()

        self.state = "opening"
        self.tick = getTickCount()

    elseif self.tab == 17 then
        self.state = "closing"
        self.tick = getTickCount()

        exports.TR_jobs:createInformation("Etkileşimli Eğitim", "Malları almak için masaya yaklaşın.")
        exports.TR_jobs:setPlayerTargetPos(2701.9846191406, -1420.6787109375, 62.393749237061, 0, 5, "Malları al")

        self.marker = createColSphere(2701.9846191406, -1420.6787109375, 62.393749237061, 1.2)
        setElementInterior(self.marker, 0)
        setElementDimension(self.marker, 5)

    elseif self.tab == 18 then
        setElementPosition(localPlayer, 2702.4641113281, -1421.0791015625, 62.39374923706)
        setElementRotation(localPlayer, 0, 0, 180)
        setPedAnimation(localPlayer, "BOMBER", "BOM_Plant", -1, false, false, false, false)

        exports.TR_jobs:createInformation("Etkileşimli Eğitim", "Daireyi terk et.")
        exports.TR_jobs:setPlayerTargetPos(2704.8723144531, -1431.8681640625, 62.393749237061, 0, 5, "Daireyi terk et")

    elseif self.tab == 19 then
        exports.TR_jobs:createInformation("Etkileşimli Eğitim", "Sigara yakmak için binanın arkasına geçin.")
        exports.TR_jobs:setPlayerTargetPos(-4616.5927734375, 376.880859375, 3.8513860702515, guiInfo.int, guiInfo.dim, "Binanın arkasına git")

        self.marker = createColSphere(-4616.5927734375, 376.880859375, 3.8513860702515, 1.2)
        setElementInterior(self.marker, guiInfo.int)
        setElementDimension(self.marker, guiInfo.dim)

    elseif self.tab == 20 then
        setElementPosition(localPlayer, -4616.5927734375, 376.880859375, 3.8513860702515)
        setElementRotation(localPlayer, 0, 0, 350)

        exports.TR_jobs:createInformation("Etkileşimli Eğitim", "Dawn'ın sana verdiği planını aydınlat. Bunu yapmak için klavyenizdeki \"i\" tuşuyla envanterinizi açın.")
        exports.TR_jobs:setPlayerTargetPos(false)

        self:setControl(false)

    elseif self.tab == 21 then
        self.state = "opening"
        self.tick = getTickCount()

    elseif self.tab == 22 then
        self.state = "closing"
        self.tick = getTickCount()

        exports.TR_jobs:createInformation("Etkileşimli Eğitim", "Sigara yakın.")

    elseif self.tab == 23 then
        exports.TR_jobs:createInformation("Etkileşimli Eğitim", "Şehre yelken açmak için limana gidin.")
        exports.TR_jobs:setPlayerTargetPos(-4578.083984375, 298.392578125, 1.7828483581543, guiInfo.int, guiInfo.dim, "Limana git")
        self:setControl(true)

        self.marker = createColSphere(-4578.083984375, 298.392578125, 1.7828483581543, 4)
        setElementInterior(self.marker, guiInfo.int)
        setElementDimension(self.marker, guiInfo.dim)

    elseif self.tab == 24 then
        exports.TR_jobs:createInformation("Etkileşimli Eğitim", "Kaptanla konuş.")
        exports.TR_jobs:setPlayerTargetPos(-4573.20703125, 290.2080078125, 1.418750953674, guiInfo.int, guiInfo.dim, "Kaptanla konuş")

    elseif self.tab == 25 then
        self.state = "opening"
        self.tick = getTickCount()

        exports.TR_jobs:removeInformation()
        exports.TR_jobs:setPlayerTargetPos(false)

        setTimer(function()
            exports.TR_items:openTutorialTrade()
        end, 50, 1)

    elseif self.tab == 27 then
        showCursor(true)
        self.buttons.next = exports.TR_dx:createButton((sx - 250/zoom)/2, 620/zoom, 250/zoom, 40/zoom, string.format("Macera başla %ss", self.buttonTime))

    elseif self.tab == 28 then
        local plrUID = getElementData(localPlayer, "characterUID")
        setElementData(localPlayer, "tempUID", plrUID)
        setElementData(localPlayer, "characterUID", nil)
        exports.TR_dx:showLoading(9999999, "Yükleniyor")

        self:close()
        triggerServerEvent("endTutorial", resourceRoot, plrUID)
        triggerServerEvent("openPlayerSpawnSelect", resourceRoot)
    end
end

function Tutorial:tutorialTrade()
    if self.tab ~= 24 then
        exports.TR_chat:showCustomMessage("Matthew McGort", "Beni ilgilendirecek hiçbir şeyin yok.", "files/images/npc.png")
        return
    end
    exports.TR_chat:showCustomMessage("Matthew McGort", "Bir şeyler içmişsin gibi hissediyorum. Elinizde stok varsa halledebiliriz diye düşünüyorum. Sen bana malları ver ben seni taşırım. Ayakta mı?", "files/images/npc.png")
    self:setNextState()
end

function Tutorial:markerEnter(el, md)
    if el ~= localPlayer or not md then return end
    self:setNextState()
end

function Tutorial:getTutorialState()
    return self.tab
end


function Tutorial:setControl(state)
    toggleAllControls(state)
    toggleControl("fire", false)
    toggleControl("action", false)
    toggleControl("aim_weapon", false)
    exports.TR_hud:blockPlayerSprint(not state)
end

function Tutorial:buttonClick(...)
    if arg[1] == self.buttons.next then
        if self.buttonTime ~= 0 then return end
        self:setNextState()
    end
end

function createTutorial()
    if guiInfo.tutorial then return end
    guiInfo.tutorial = Tutorial:create()
end

function isTutorialOpen()
    if guiInfo.tutorial then return guiInfo.tutorial:getTutorialState() end
    return false
end

function setNextState(noTime)
    if not guiInfo.tutorial then return end

    if noTime then
        guiInfo.tutorial:setNextState()
    else
        setTimer(function()
            guiInfo.tutorial:setNextState()
        end, 600, 1)
    end
end

function tutorialTrade()
    if not guiInfo.tutorial then return end

    guiInfo.tutorial:tutorialTrade()
end
addEvent("tutorialTrade", true)
addEventHandler("tutorialTrade", root, tutorialTrade)

-- toggleAllControls(true)
-- toggleControl("fire", false)
-- toggleControl("action", false)
-- toggleControl("aim_weapon", false)

-- if getPlayerName(localPlayer) == "Xantris" then
    -- createTutorial()
-- end

-- exports.TR_dx:setOpenGUI(false)
-- exports.TR_chat:setChatBlocked(false)
-- exports.TR_dx:hideLoading()