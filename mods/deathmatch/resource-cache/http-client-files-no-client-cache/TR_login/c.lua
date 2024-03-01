sx, sy = guiGetScreenSize()

zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
  logo = {
    x = (sx - 200/zoom)/2,
    y = 220/zoom - 130/zoom,
    defY = 220/zoom - 130/zoom,
    w = 200/zoom,
    h = 200/zoom,

    state = "staying",

    time_move = 500,
  },

  form = {
    x = (sx - 300/zoom)/2,
    y = 220/zoom,
    w = 300/zoom,
    h = 0,

    buttons = {},
    edits = {},
    checks = {},
    scrolls = {},
  },

  bg = {
    alpha = 1,
    alphaMain = 1,
    img = 1,
  },

  characterSpawn = {
    anim = "hidden",
    alpha = 0,
  },

  selectedTab = "main",

  fonts = {},
  textures = {},

  username = {
    x = (sx - 420/zoom)/2,
    y = (sy - 100/zoom)/2,
    w = 420/zoom,
    h = 150/zoom
  },

  tooSmall = {
    x = (sx - 500/zoom)/2,
    y = (sy - 200/zoom)/2,
    w = 500/zoom,
    h = 200/zoom,
  },

  news = {
    x = sx/2 - 783/zoom,
    y = sy - 400/zoom,

    alpha = 1,
    state = "showed",
    selectedNews = 1,
  },

  newses = {
    {
      number = 11,
      desc = "Bu güncellemede size yeni bir iş sunmak istiyoruz - taş ocağı işi. Bu iş diğerlerinden farklıdır çünkü bir depo gibi herhangi bir araca ihtiyaç duymaz. Ayrıca patlayıcılarla temas ettiğimiz ilk iş bu.",
      img = "files/images/news/1.png",
    },
    {
      number = 10,
      desc = "Uzun bir bekleyişin ardından nihayet burada! suç güncellemesi! Bu güncellemede, çete üyeleri birkaç yeni mekanik ve silah veya uyuşturucu üretmek için kaynak elde etmenin bir yolunu aldı.",
      img = "files/images/news/4.png",
    },
    {
      number = 9,
      desc = "Hiç okyanusun derinliklerine dalmak istemediniz mi? Muhtemelen herkes bir zamanlar dalgıç olmak ve mercan resiflerinin güzel dünyasını keşfetmek istemiştir. Gölde çok fazla resif bulamasanız da, eser aramada yardımcı olabilirsiniz!",
      img = "files/images/news/3.png",
    },
    {
      number = 8,
      desc = "Yeni ses ekipmanları artık beyaz eşya mağazalarında! Artık arkadaşlarınızı evinizde uygun bir ev partisine davet edebilirsiniz. Ayrıca deneyim sistemi ve yeni işler eklenmiştir.",
      img = "files/images/news/2.png",
    },
  },
}

function createLoginButtons(noTime)
  if not noTime then
    if sx < 1280 and sy < 720 then
      guiInfo.tooSmall.accept = exports.TR_dx:createButton(guiInfo.tooSmall.x + guiInfo.tooSmall.w/2 - 150/zoom, guiInfo.tooSmall.y + guiInfo.tooSmall.h - 55/zoom, 300/zoom, 45/zoom, "Anlıyorum. Hala gidiyorum!", "green")
      guiInfo.blockLogin = "Çok düşük bir oyun çözünürlüğü tespit ettik! Tüm pencereler planladığımız gibi görünmeyebilir ve bazı seçeneklere erişilemez hale gelebilir."

    elseif sy/sx ~= 0.5625 then
      guiInfo.tooSmall.accept = exports.TR_dx:createButton(guiInfo.tooSmall.x + guiInfo.tooSmall.w/2 - 150/zoom, guiInfo.tooSmall.y + guiInfo.tooSmall.h - 55/zoom, 300/zoom, 45/zoom, "Anlıyorum. Hala gidiyorum!", "green")
      guiInfo.blockLogin = "16:9'dan farklı ekran oranları tespit ettik! Tüm pencereler planladığımız gibi görünmeyebilir."
    end
  end

  if guiInfo.blockLogin and not noTime then
    setTimer(function()
      guiInfo.music = playSound("files/sound/login.mp3", true)
      exports.TR_dx:hideLoading()
      addEventHandler("guiButtonClick", root, buttonClick)
    end, 5000, 1)

  else
    guiInfo.form.buttons.goto_login = exports.TR_dx:createButton(guiInfo.form.x, guiInfo.form.y + guiInfo.form.h + 110/zoom, guiInfo.form.w, 50/zoom, "Giriş Yap")
    guiInfo.form.buttons.goto_register = exports.TR_dx:createButton(guiInfo.form.x, guiInfo.form.y + guiInfo.form.h + 170/zoom, guiInfo.form.w, 50/zoom, "Kayıt Ol")
    guiInfo.form.buttons.goto_rules = exports.TR_dx:createButton(guiInfo.form.x, guiInfo.form.y + guiInfo.form.h + 230/zoom, guiInfo.form.w, 50/zoom, "Kurallar")
    guiInfo.form.buttons.goto_creators = exports.TR_dx:createButton(guiInfo.form.x, guiInfo.form.y + guiInfo.form.h + 290/zoom, guiInfo.form.w, 50/zoom, "Developer Ekibi")


    --- LOGIN PANEL ---
    local top = (sy - 300/zoom)/2 + 50/zoom
    -- guiInfo.form.edits.login_login = exports.TR_dx:createEdit(guiInfo.form.x, top, guiInfo.form.w, 50/zoom, "Wpisz login", false)
    guiInfo.form.edits.login_login = exports.TR_dx:createEdit(guiInfo.form.x, top, guiInfo.form.w, 50/zoom, "Kullanıcı Adı", false, false, sLogin)
    -- guiInfo.form.edits.login_password = exports.TR_dx:createEdit(guiInfo.form.x, top + 60/zoom, guiInfo.form.w, 50/zoom, "Hasło", true, guiInfo.textures.key, sPassword)
    guiInfo.form.edits.login_password = exports.TR_dx:createEdit(guiInfo.form.x, top + 60/zoom, guiInfo.form.w, 50/zoom, "Şifre", true, false, sPassword)
    guiInfo.form.checks.login_remember = exports.TR_dx:createCheck(guiInfo.form.x, top + 120/zoom, 40/zoom, 40/zoom, false, "Beni Hatırla")
    guiInfo.form.buttons.perform_login = exports.TR_dx:createButton(guiInfo.form.x, top + 180/zoom, guiInfo.form.w, 50/zoom, "Giriş Yap", "green")
    guiInfo.form.buttons.back_login = exports.TR_dx:createButton(guiInfo.form.x, top + 300/zoom, guiInfo.form.w, 50/zoom, "Geri Dön", "red")

    local sLogin, sPassword, sChecked = getSavedLoginData()
    if sLogin and sPassword and sChecked then
      exports.TR_dx:setEditText(guiInfo.form.edits.login_login, sLogin)
      exports.TR_dx:setEditText(guiInfo.form.edits.login_password, sPassword)
      exports.TR_dx:setCheckSelected(guiInfo.form.checks.login_remember, sChecked)
    end

    exports.TR_dx:setButtonVisible({guiInfo.form.buttons.back_login, guiInfo.form.buttons.perform_login}, false)
    exports.TR_dx:setEditVisible({guiInfo.form.edits.login_login, guiInfo.form.edits.login_password}, false)
    exports.TR_dx:setCheckVisible({guiInfo.form.checks.login_remember}, false)


    --- REGISTER PANEL ---
    local top = (sy - 590/zoom)/2 + 130/zoom
    guiInfo.form.edits.register_login = exports.TR_dx:createEdit(guiInfo.form.x, top, guiInfo.form.w, 50/zoom, "Kullanıcı Adı")
    guiInfo.form.edits.register_password = exports.TR_dx:createEdit(guiInfo.form.x, top + 60/zoom, guiInfo.form.w, 50/zoom, "Şifre", true)
    guiInfo.form.edits.register_repeatPassword = exports.TR_dx:createEdit(guiInfo.form.x, top + 120/zoom, guiInfo.form.w, 50/zoom, "Şifre Tekrar", true)
    guiInfo.form.edits.register_mail = exports.TR_dx:createEdit(guiInfo.form.x, top + 180/zoom, guiInfo.form.w, 50/zoom, "Email", false)
    guiInfo.form.edits.register_referenced = exports.TR_dx:createEdit(guiInfo.form.x, top + 240/zoom, guiInfo.form.w, 50/zoom, "Referans Kodu", false)
    guiInfo.form.checks.register_rules = exports.TR_dx:createCheck(guiInfo.form.x, top + 300/zoom, 40/zoom, 40/zoom, false, "Kuralları okudum, kabul ediyorum.")
    guiInfo.form.buttons.perform_register = exports.TR_dx:createButton(guiInfo.form.x, top + 360/zoom, guiInfo.form.w, 50/zoom, "Kayıt Ol", "green")
    guiInfo.form.buttons.back_register = exports.TR_dx:createButton(guiInfo.form.x, top + 480/zoom, guiInfo.form.w, 50/zoom, "Geri Dön", "red")

    exports.TR_dx:setButtonVisible({guiInfo.form.buttons.perform_register, guiInfo.form.buttons.back_register}, false)
    exports.TR_dx:setEditVisible({guiInfo.form.edits.register_login, guiInfo.form.edits.register_password, guiInfo.form.edits.register_repeatPassword, guiInfo.form.edits.register_mail, guiInfo.form.edits.register_referenced}, false)
    exports.TR_dx:setCheckVisible({guiInfo.form.checks.register_rules}, false)


    --- RULES PANEL ---
    local top = (sy - 570/zoom)/2 + 50/zoom
    guiInfo.form.scrolls.rules = exports.TR_dx:createScroll((sx - 750/zoom)/2, top, 750/zoom, 500/zoom, 13, false, getRules())
    guiInfo.form.buttons.back_rules = exports.TR_dx:createButton(guiInfo.form.x, top + 570/zoom, guiInfo.form.w, 50/zoom, "Geri dön", "red")

    exports.TR_dx:setButtonVisible(guiInfo.form.buttons.back_rules, false)
    exports.TR_dx:setScrollVisible(guiInfo.form.scrolls.rules, false)


    --- CREATORS PANEL ---
    local top = (sy - 470/zoom)/2 + 50/zoom
    guiInfo.form.scrolls.authors = exports.TR_dx:createScroll((sx - 370/zoom)/2, top, 370/zoom, 400/zoom, 12, false, getCreators())
    guiInfo.form.buttons.back_authors = exports.TR_dx:createButton(guiInfo.form.x, top + 470/zoom, guiInfo.form.w, 50/zoom, "Geri dön", "red")

    exports.TR_dx:setButtonVisible(guiInfo.form.buttons.back_authors, false)
    exports.TR_dx:setScrollVisible(guiInfo.form.scrolls.authors, false)


    --- CREATE CHARACTER ---
    guiInfo.form.edits.character_name = exports.TR_dx:createEdit(guiInfo.form.x, guiInfo.form.y + guiInfo.form.h - 50/zoom, guiInfo.form.w, 50/zoom, "character_name", false) --, guiInfo.textures.person)
    guiInfo.form.edits.character_lastname = exports.TR_dx:createEdit(guiInfo.form.x, guiInfo.form.y + guiInfo.form.h + 10/zoom, guiInfo.form.w, 50/zoom, "character_lastname", false) --, guiInfo.textures.person)
    guiInfo.form.edits.character_tall = exports.TR_dx:createEdit(guiInfo.form.x, guiInfo.form.y + guiInfo.form.h + 70/zoom, guiInfo.form.w, 50/zoom, "character_tall", false) --, guiInfo.textures.tall)
    guiInfo.form.edits.character_weight = exports.TR_dx:createEdit(guiInfo.form.x, guiInfo.form.y + guiInfo.form.h + 130/zoom, guiInfo.form.w, 50/zoom, "character_weight", false) --, guiInfo.textures.weight)

    guiInfo.form.buttons.character_skin_prev = exports.TR_dx:createButton(guiInfo.form.x, guiInfo.form.y + guiInfo.form.h + 360/zoom, guiInfo.form.w, 50/zoom, "İleri")
    guiInfo.form.buttons.character_skin_next = exports.TR_dx:createButton(guiInfo.form.x, guiInfo.form.y + guiInfo.form.h + 420/zoom, guiInfo.form.w, 50/zoom, "Geri")

    guiInfo.form.buttons.character_create = exports.TR_dx:createButton(guiInfo.form.x, guiInfo.form.y + guiInfo.form.h + 535/zoom, guiInfo.form.w, 50/zoom, "Oluştur")
    guiInfo.form.buttons.character_back = exports.TR_dx:createButton(guiInfo.form.x, guiInfo.form.y + guiInfo.form.h + 595/zoom, guiInfo.form.w, 50/zoom, "Geri Dön")

    guiInfo.form.checks.character_male = exports.TR_dx:createCheck(guiInfo.form.x, guiInfo.form.y + guiInfo.form.h + 220/zoom, 40/zoom, 40/zoom, false, "Erkek")
    guiInfo.form.checks.character_female = exports.TR_dx:createCheck(guiInfo.form.x + 180/zoom, guiInfo.form.y + guiInfo.form.h + 220/zoom, 40/zoom, 40/zoom, false, "Kadın")
    guiInfo.form.checks.character_white = exports.TR_dx:createCheck(guiInfo.form.x, guiInfo.form.y + guiInfo.form.h + 300/zoom, 40/zoom, 40/zoom, false, "Beyaz")
    guiInfo.form.checks.character_black = exports.TR_dx:createCheck(guiInfo.form.x + 180/zoom, guiInfo.form.y + guiInfo.form.h + 300/zoom, 40/zoom, 40/zoom, false, "Siyahi")
    exports.TR_dx:setCheckGroup({guiInfo.form.checks.character_male, guiInfo.form.checks.character_female})
    exports.TR_dx:setCheckGroup({guiInfo.form.checks.character_white, guiInfo.form.checks.character_black})
    exports.TR_dx:setCheckSelected({guiInfo.form.checks.character_male, guiInfo.form.checks.character_white}, true)

    guiInfo.form.buttons.character_play = exports.TR_dx:createButton(guiInfo.form.x, guiInfo.form.y + guiInfo.form.h + 320/zoom, guiInfo.form.w, 50/zoom, "Oynat")
    guiInfo.form.buttons.character_cancle = exports.TR_dx:createButton(guiInfo.form.x, guiInfo.form.y + guiInfo.form.h + 380/zoom, guiInfo.form.w, 50/zoom, "İptal")

    exports.TR_dx:setButtonVisible({guiInfo.form.buttons.character_play, guiInfo.form.buttons.character_cancle, guiInfo.form.buttons.character_create, guiInfo.form.buttons.character_back, guiInfo.form.buttons.character_skin_prev, guiInfo.form.buttons.character_skin_next}, false)
    exports.TR_dx:setEditVisible({guiInfo.form.edits.character_name, guiInfo.form.edits.character_lastname, guiInfo.form.edits.character_tall, guiInfo.form.edits.character_weight}, false)
    exports.TR_dx:setCheckVisible({guiInfo.form.checks.character_male, guiInfo.form.checks.character_female, guiInfo.form.checks.character_white, guiInfo.form.checks.character_black}, false)

    if not noTime then
      setTimer(function()
        guiInfo.music = playSound("files/sound/login.mp3", true)
        exports.TR_dx:hideLoading()
        addEventHandler("guiButtonClick", root, buttonClick)
      end, 5000, 1)
    end

    toggleControl("forwards", false)
    toggleControl("backwards", false)
    toggleControl("left", false)
    toggleControl("right", false)
    toggleControl("jump", false)
    toggleControl("action", false)
    toggleControl("sprint", false)
    toggleControl("crouch", false)
    toggleControl("walk", false)
    toggleControl("enter_exit", false)
  end
end


function setPlayerBanData(haveBan, banData)
  if haveBan then
    setTimer(createBanWindow, 3000, 1)
    guiInfo.banData = formatBanData(banData)
  else
    setTimer(createLogin, 3000, 1)
  end
end
addEvent("setPlayerBanData", true)
addEventHandler("setPlayerBanData", root, setPlayerBanData)


function destroyLoginElements(blocker)
  if not blocker then
    guiInfo.fonts.remember = nil
    guiInfo.fonts.edits = nil
    guiInfo.fonts.loading = nil
    guiInfo.fonts.small = nil

    setElementFrozen(localPlayer, false)
    setCameraTarget(localPlayer)
    showCursor(false)
  end

  if not isElement(guiInfo.textures.person) then return end
  destroyElement(guiInfo.textures.person)
  destroyElement(guiInfo.textures.key)
  destroyElement(guiInfo.textures.mail)
  destroyElement(guiInfo.textures.code)
  exports.TR_dx:destroyButton(guiInfo.form.buttons)
  exports.TR_dx:destroyEdit(guiInfo.form.edits)
  exports.TR_dx:destroyCheck(guiInfo.form.checks)
  exports.TR_dx:destroyScroll(guiInfo.form.scrolls)

  removeEventHandler("onClientRender", root, renderLogin)
  removeEventHandler("guiButtonClick", root, buttonClick)
  removeEventHandler("onClientClick", root, onMouseLoginClick)

  collectgarbage()
end


function createLogin()
  if guiInfo.open then return end
  guiInfo.open = true
  guiInfo.bg.tick = getTickCount()

  -- Fonts etc
  guiInfo.fonts.remember = exports.TR_dx:getFont(13)
  guiInfo.fonts.edits = exports.TR_dx:getFont(14)
  guiInfo.fonts.loading = exports.TR_dx:getFont(16)
  guiInfo.fonts.small = exports.TR_dx:getFont(11)

  guiInfo.fonts.newses = exports.TR_dx:getFont(16, "myriadLight")
  guiInfo.fonts.newsesHash = exports.TR_dx:getFont(16, "myriadBold")
  guiInfo.fonts.newsesDesc = exports.TR_dx:getFont(14, "myriadLight")

  guiInfo.textures.person = dxCreateTexture("files/images/person.png", "argb", true, "clamp")
  guiInfo.textures.key = dxCreateTexture("files/images/key.png", "argb", true, "clamp")
  guiInfo.textures.mail = dxCreateTexture("files/images/email.png", "argb", true, "clamp")
  guiInfo.textures.code = dxCreateTexture("files/images/code.png", "argb", true, "clamp")

  showChat(false)
  showCursor(true)
  addEventHandler("onClientRender", root, renderLogin)
  addEventHandler("onClientClick", root, onMouseLoginClick)

  createLoginButtons()
  fadeCamera(true, 0)
  setPlayerHudComponentVisible("all", false)
  setPlayerHudComponentVisible("crosshair", true)
  setPedTargetingMarkerEnabled(false)

  setElementDimension(localPlayer, 2)
  setElementPosition(localPlayer, 1578.01171875, -685.05181884766, 26.637500762939)
  setElementFrozen(localPlayer, true)


end

function closeLogin()
  if not guiInfo.open then return end
  guiInfo.open = nil

  removeEventHandler("onClientRender", root, renderLogin)
  removeEventHandler("guiButtonClick", root, buttonClick)
end

function renderLowResolution()
  if guiInfo.blockLogin then
    drawBackground(guiInfo.tooSmall.x, guiInfo.tooSmall.y, guiInfo.tooSmall.w, guiInfo.tooSmall.h, tocolor(17, 17, 17, 255), 5)
    dxDrawText("BİLGİ!", guiInfo.tooSmall.x, guiInfo.tooSmall.y + 10/zoom, guiInfo.tooSmall.x + guiInfo.tooSmall.w, guiInfo.tooSmall.y + 30/zoom, tocolor(240, 196, 55, 255), 1/zoom, guiInfo.fonts.loading, "center", "center", true, false)
    dxDrawText(guiInfo.blockLogin, guiInfo.tooSmall.x + 10/zoom, guiInfo.tooSmall.y + 40/zoom, guiInfo.tooSmall.x + guiInfo.tooSmall.w - 10/zoom, guiInfo.tooSmall.y + guiInfo.tooSmall.h - 70/zoom, tocolor(255, 255, 255, 255), 1/zoom, guiInfo.fonts.remember, "center", "center", true, true)
  end
end

function renderLogin()
  dxDrawImage(0, 0, sx, sy, "files/images/bg.jpg", 0, 0, 0, tocolor(180, 180, 180, 255 * guiInfo.bg.alpha))
  renderLogo()
  renderNewses()

  if guiInfo.blockLogin then
    renderLowResolution()
  end

  setCameraMatrix(0, 0, -500, 0, 0, -500)

  if guiInfo.selectedTab == "login" then
    if not guiInfo.blockLogin then
      if isMouseInPosition(sx/2 - 110/zoom, (sy - 300/zoom)/2 + 286/zoom, 220/zoom, 25/zoom) then
        dxDrawText("Giriş yapamıyor musun?", sx/2 - 125/zoom, (sy - 300/zoom)/2 + 290/zoom, sx/2 + 125/zoom, (sy - 300/zoom)/2 + 330/zoom, tocolor(220, 220, 220, 255), 1/zoom, guiInfo.fonts.small, "center", "top", true, true, true)
      else
        dxDrawText("Giriş yapamıyor musun?", sx/2 - 125/zoom, (sy - 300/zoom)/2 + 290/zoom, sx/2 + 125/zoom, (sy - 300/zoom)/2 + 330/zoom, tocolor(170, 170, 170, 255), 1/zoom, guiInfo.fonts.small, "center", "top", true, true, true)
      end
    end

  elseif guiInfo.selectedTab == "register" and isMouseInPosition(guiInfo.form.x, (sy - 590/zoom)/2 + 370/zoom, guiInfo.form.w, 50/zoom) then
    local cx, cy = getCursorPosition()
    cx, cy = cx * sx, cy * sy
    cx = cx > sx - 360/zoom and sx - 360/zoom or cx
    drawBackground(cx + 8/zoom, cy + 8/zoom, 350/zoom, 75/zoom, tocolor(27, 27, 27, 255), 5, true)
    dxDrawText("Referans kodunu kullanarak başlangıç ​​için 500$ kazanabilirsiniz ve kodunu kullandığınız bir kişi harika bir ödül kazanma şansı yakalar!", cx + 13/zoom, cy + 13/zoom, cx + 345/zoom, cy + 70/zoom, tocolor(220, 220, 220, 255), 1/zoom, guiInfo.fonts.small, "left", "top", true, true, true)
  end
end

function renderLogo()
  if guiInfo.logo.state == "moving" then
    local progress = (getTickCount() - guiInfo.logo.tick)/guiInfo.logo.time_move
    guiInfo.logo.y = interpolateBetween(guiInfo.logo.sY, 0, 0, guiInfo.logo.mY, 0, 0, progress, "OutQuad")
    if progress >= 1 then
      guiInfo.logo.state = "staying"
      guiInfo.logo.tick = nil
    end
  end

  dxDrawImage(guiInfo.logo.x, guiInfo.logo.y, guiInfo.logo.w, guiInfo.logo.h, "files/images/logo.png", 0, 0, 0, tocolor(255, 255, 255, 255))
end

function renderNewses()
  if guiInfo.news.tick then
    local progress = (getTickCount() - guiInfo.news.tick)/guiInfo.logo.time_move
    guiInfo.news.alpha = interpolateBetween(guiInfo.news.oldAlpha, 0, 0, guiInfo.news.newAlpha, 0, 0, progress, "OutQuad")
    if progress >= 1 then
      guiInfo.news.alpha = guiInfo.news.newAlpha
      guiInfo.news.tick = nil
    end
  end

  dxDrawImage(guiInfo.news.x, guiInfo.news.y, 14/zoom, 18/zoom, "files/images/news/square.png", 0, 0, 0, tocolor(255, 255, 255, 180 * guiInfo.news.alpha))
  dxDrawText("Haberler", guiInfo.news.x + 20/zoom, guiInfo.news.y, guiInfo.news.x + 20/zoom, guiInfo.news.y + 18/zoom, tocolor(220, 220, 220, 255 * guiInfo.news.alpha), 1/zoom, guiInfo.fonts.newses, "left", "center")
  dxDrawText(string.format("#%03d", guiInfo.newses[guiInfo.news.selectedNews].number), guiInfo.news.x + 120/zoom, guiInfo.news.y - 1/zoom, guiInfo.news.x + 20/zoom, guiInfo.news.y + 17/zoom, tocolor(255, 255, 255, 255 * guiInfo.news.alpha), 1/zoom, guiInfo.fonts.newsesHash, "left", "center")

  if guiInfo.news.selectedNews == 1 then
    dxDrawImage(sx/2 - 783/zoom - 35/zoom, guiInfo.news.y + 35/zoom - 39/zoom, 425/zoom, 258/zoom, "files/images/news/border_light.png", 0, 0, 0, tocolor(255, 255, 255, 255 * guiInfo.news.alpha))
  elseif guiInfo.news.selectedNews == 2 then
    dxDrawImage(sx/2 - 379/zoom - 35/zoom, guiInfo.news.y + 35/zoom - 39/zoom, 425/zoom, 258/zoom, "files/images/news/border_light.png", 0, 0, 0, tocolor(255, 255, 255, 255 * guiInfo.news.alpha))
  elseif guiInfo.news.selectedNews == 3 then
    dxDrawImage(sx/2 + 25/zoom - 35/zoom, guiInfo.news.y + 35/zoom - 39/zoom, 425/zoom, 258/zoom, "files/images/news/border_light.png", 0, 0, 0, tocolor(255, 255, 255, 255 * guiInfo.news.alpha))
  elseif guiInfo.news.selectedNews == 4 then
    dxDrawImage(sx/2 + 429/zoom - 35/zoom, guiInfo.news.y + 35/zoom - 39/zoom, 425/zoom, 258/zoom, "files/images/news/border_light.png", 0, 0, 0, tocolor(255, 255, 255, 255 * guiInfo.news.alpha))
  end

  dxDrawImage(sx/2 - 783/zoom, guiInfo.news.y + 35/zoom, 354/zoom, 180/zoom, "files/images/news/border.png", 0, 0, 0, tocolor(255, 255, 255, 255 * guiInfo.news.alpha))
  dxDrawImage(sx/2 - 379/zoom, guiInfo.news.y + 35/zoom, 354/zoom, 180/zoom, "files/images/news/border.png", 0, 0, 0, tocolor(255, 255, 255, 255 * guiInfo.news.alpha))
  dxDrawImage(sx/2 + 25/zoom, guiInfo.news.y + 35/zoom, 354/zoom, 180/zoom, "files/images/news/border.png", 0, 0, 0, tocolor(255, 255, 255, 255 * guiInfo.news.alpha))
  dxDrawImage(sx/2 + 429/zoom, guiInfo.news.y + 35/zoom, 354/zoom, 180/zoom, "files/images/news/border.png", 0, 0, 0, tocolor(255, 255, 255, 255 * guiInfo.news.alpha))

  if guiInfo.news.selectedNews == 1 then
    dxDrawImage(sx/2 - 783/zoom + 10/zoom, guiInfo.news.y + 35/zoom + 8/zoom, 334/zoom, 164/zoom, guiInfo.newses[1].img, 0, 0, 0, tocolor(255, 255, 255, 255 * guiInfo.news.alpha))
  elseif isMouseInPosition(sx/2 - 783/zoom, guiInfo.news.y + 35/zoom, 354/zoom, 180/zoom) then
    dxDrawImage(sx/2 - 783/zoom + 10/zoom, guiInfo.news.y + 35/zoom + 8/zoom, 334/zoom, 164/zoom, guiInfo.newses[1].img, 0, 0, 0, tocolor(255, 255, 255, 120 * guiInfo.news.alpha))
  else
    dxDrawImage(sx/2 - 783/zoom + 10/zoom, guiInfo.news.y + 35/zoom + 8/zoom, 334/zoom, 164/zoom, guiInfo.newses[1].img, 0, 0, 0, tocolor(255, 255, 255, 75 * guiInfo.news.alpha))
  end

  if guiInfo.news.selectedNews == 2 then
    dxDrawImage(sx/2 - 379/zoom + 10/zoom, guiInfo.news.y + 35/zoom + 8/zoom, 334/zoom, 164/zoom, guiInfo.newses[2].img, 0, 0, 0, tocolor(255, 255, 255, 255 * guiInfo.news.alpha))
  elseif isMouseInPosition(sx/2 - 379/zoom, guiInfo.news.y + 35/zoom, 354/zoom, 180/zoom) then
    dxDrawImage(sx/2 - 379/zoom + 10/zoom, guiInfo.news.y + 35/zoom + 8/zoom, 334/zoom, 164/zoom, guiInfo.newses[2].img, 0, 0, 0, tocolor(255, 255, 255, 120 * guiInfo.news.alpha))
  else
    dxDrawImage(sx/2 - 379/zoom + 10/zoom, guiInfo.news.y + 35/zoom + 8/zoom, 334/zoom, 164/zoom, guiInfo.newses[2].img, 0, 0, 0, tocolor(255, 255, 255, 75 * guiInfo.news.alpha))
  end

  if guiInfo.news.selectedNews == 3 then
    dxDrawImage(sx/2 + 25/zoom + 10/zoom, guiInfo.news.y + 35/zoom + 8/zoom, 334/zoom, 164/zoom, guiInfo.newses[3].img, 0, 0, 0, tocolor(255, 255, 255, 255 * guiInfo.news.alpha))
  elseif isMouseInPosition(sx/2 + 25/zoom, guiInfo.news.y + 35/zoom, 354/zoom, 180/zoom) then
    dxDrawImage(sx/2 + 25/zoom + 10/zoom, guiInfo.news.y + 35/zoom + 8/zoom, 334/zoom, 164/zoom, guiInfo.newses[3].img, 0, 0, 0, tocolor(255, 255, 255, 120 * guiInfo.news.alpha))
  else
    dxDrawImage(sx/2 + 25/zoom + 10/zoom, guiInfo.news.y + 35/zoom + 8/zoom, 334/zoom, 164/zoom, guiInfo.newses[3].img, 0, 0, 0, tocolor(255, 255, 255, 75 * guiInfo.news.alpha))
  end

  if guiInfo.news.selectedNews == 4 then
    dxDrawImage(sx/2 + 429/zoom + 10/zoom, guiInfo.news.y + 35/zoom + 8/zoom, 334/zoom, 164/zoom, guiInfo.newses[4].img, 0, 0, 0, tocolor(255, 255, 255, 255 * guiInfo.news.alpha))
  elseif isMouseInPosition(sx/2 + 429/zoom, guiInfo.news.y + 35/zoom, 354/zoom, 180/zoom) then
    dxDrawImage(sx/2 + 429/zoom + 10/zoom, guiInfo.news.y + 35/zoom + 8/zoom, 334/zoom, 164/zoom, guiInfo.newses[4].img, 0, 0, 0, tocolor(255, 255, 255, 120 * guiInfo.news.alpha))
  else
    dxDrawImage(sx/2 + 429/zoom + 10/zoom, guiInfo.news.y + 35/zoom + 8/zoom, 334/zoom, 164/zoom, guiInfo.newses[4].img, 0, 0, 0, tocolor(255, 255, 255, 75 * guiInfo.news.alpha))
  end

  dxDrawText("Güncelleme açıklamaları", guiInfo.news.x, guiInfo.news.y + 230/zoom, guiInfo.news.x + 20/zoom, guiInfo.news.y + 18/zoom, tocolor(220, 220, 220, 255 * guiInfo.news.alpha), 1/zoom, guiInfo.fonts.newses, "left", "top")
  dxDrawImage(guiInfo.news.x - 18/zoom, guiInfo.news.y + 261/zoom, 342/zoom, 2/zoom, "files/images/news/line.png", 0, 0, 0, tocolor(255, 255, 255, 180 * guiInfo.news.alpha))

  dxDrawText(guiInfo.newses[guiInfo.news.selectedNews].desc, guiInfo.news.x, guiInfo.news.y + 270/zoom, guiInfo.news.x + 1566/zoom, guiInfo.news.y + 380/zoom, tocolor(220, 220, 220, 255 * guiInfo.news.alpha), 1/zoom, guiInfo.fonts.newsesDesc, "left", "top", true, true)
  -- selectedNews
end

function onMouseLoginClick(btn, state)
  if state ~= "down" or btn ~= "left" then return end

  if guiInfo.selectedTab == "main" then
    if isMouseInPosition(sx/2 - 783/zoom, guiInfo.news.y + 35/zoom, 354/zoom, 180/zoom) then
      guiInfo.news.selectedNews = 1

    elseif isMouseInPosition(sx/2 - 379/zoom, guiInfo.news.y + 35/zoom, 354/zoom, 180/zoom) then
      guiInfo.news.selectedNews = 2

    elseif isMouseInPosition(sx/2 + 25/zoom, guiInfo.news.y + 35/zoom, 354/zoom, 180/zoom) then
      guiInfo.news.selectedNews = 3

    elseif isMouseInPosition(sx/2 + 429/zoom, guiInfo.news.y + 35/zoom, 354/zoom, 180/zoom) then
      guiInfo.news.selectedNews = 4
    end

  elseif guiInfo.selectedTab == "login" then
    if isMouseInPosition(sx/2 - 110/zoom, (sy - 300/zoom)/2 + 286/zoom, 220/zoom, 25/zoom) then
      guiInfo.tooSmall.accept = exports.TR_dx:createButton(guiInfo.tooSmall.x + guiInfo.tooSmall.w/2 - 150/zoom, guiInfo.tooSmall.y + guiInfo.tooSmall.h - 55/zoom, 300/zoom, 45/zoom, "Bağlantıyı kopyala", "green")
      guiInfo.blockLogin = "Giriş yapmakta sorun yaşıyorsanız discord adresimizden bizlere ulaşabilirsiniz."

      exports.TR_dx:setButtonVisible({guiInfo.form.buttons.perform_login, guiInfo.form.buttons.back_login}, false)
      exports.TR_dx:setEditVisible({guiInfo.form.edits.login_login, guiInfo.form.edits.login_password}, false)
      exports.TR_dx:setCheckVisible(guiInfo.form.checks.login_remember, false)
    end
  end
end

function buttonClick(btn)
  if btn == guiInfo.tooSmall.accept then
    if guiInfo.selectedTab == "login" then
      exports.TR_dx:destroyButton(guiInfo.tooSmall.accept)
      guiInfo.blockLogin = nil
      setClipboard("https://insidemta.pl/reset-password")
      exports.TR_noti:create("Bağlantı panoya kopyalandı. Tarayıcı penceresine yapıştırın.", "success", 10)

      exports.TR_dx:setButtonVisible({guiInfo.form.buttons.perform_login, guiInfo.form.buttons.back_login}, true)
      exports.TR_dx:setEditVisible({guiInfo.form.edits.login_login, guiInfo.form.edits.login_password}, true)
      exports.TR_dx:setCheckVisible(guiInfo.form.checks.login_remember, true)
    else
      exports.TR_dx:destroyButton(guiInfo.tooSmall.accept)
      guiInfo.blockLogin = nil
      createLoginButtons(true)
      return
    end
  end

  if guiInfo.blockLogin then exports.TR_noti:create("Önce ekrandaki bilgileri onaylamanız gerekir.", "error") return end
  if btn == guiInfo.form.buttons.goto_login then
    setLoginTab("login")

  elseif btn == guiInfo.form.buttons.goto_register then
    setLoginTab("register")

  elseif btn == guiInfo.form.buttons.goto_rules then
    setLoginTab("rules")

  elseif btn == guiInfo.form.buttons.goto_creators then
    setLoginTab("creators")

  elseif btn == guiInfo.form.buttons.back_login or btn == guiInfo.form.buttons.back_register or btn == guiInfo.form.buttons.back_rules or btn == guiInfo.form.buttons.back_authors then
    setLoginTab("main")

  elseif btn == guiInfo.form.buttons.perform_login then
    performLogin()

  elseif btn == guiInfo.form.buttons.perform_register then
    performRegister()

  end
end


function moveLogo(newY)
  if guiInfo.logo.state ~= "staying" then return end
  guiInfo.logo.state = "moving"
  guiInfo.logo.tick = getTickCount()
  guiInfo.logo.sY = guiInfo.logo.y
  guiInfo.logo.mY = newY
end

function setNewsesEnabled(enabled)
  guiInfo.news.tick = getTickCount()
  guiInfo.news.oldAlpha = guiInfo.news.alpha
  guiInfo.news.newAlpha = enabled and 1 or 0
end

function setLoginTab(tab)
  if tab == "main" then
    moveLogo(guiInfo.logo.defY)
    exports.TR_dx:showButton({guiInfo.form.buttons.goto_login, guiInfo.form.buttons.goto_register, guiInfo.form.buttons.goto_rules, guiInfo.form.buttons.goto_creators})

    exports.TR_dx:hideEdit({guiInfo.form.edits.login_login, guiInfo.form.edits.login_password})
    exports.TR_dx:hideButton({guiInfo.form.buttons.back_login, guiInfo.form.buttons.perform_login})
    exports.TR_dx:hideCheck({guiInfo.form.checks.login_remember})

    exports.TR_dx:hideButton({guiInfo.form.buttons.perform_register, guiInfo.form.buttons.back_register})
    exports.TR_dx:hideEdit({guiInfo.form.edits.register_login, guiInfo.form.edits.register_password, guiInfo.form.edits.register_repeatPassword, guiInfo.form.edits.register_mail, guiInfo.form.edits.register_referenced})
    exports.TR_dx:hideCheck({guiInfo.form.checks.register_rules})

    exports.TR_dx:hideButton(guiInfo.form.buttons.back_rules)
    exports.TR_dx:hideScroll(guiInfo.form.scrolls.rules)

    exports.TR_dx:hideButton(guiInfo.form.buttons.back_authors)
    exports.TR_dx:hideScroll(guiInfo.form.scrolls.authors)

    if isElement(guiInfo.passwordStrength) then
      killTimer(guiInfo.passwordStrengthUpdate)
      exports.TR_noti:destroy(guiInfo.passwordStrength)
      guiInfo.passwordStrength = nil
    end
    setNewsesEnabled(true)

  elseif tab == "login" then
    moveLogo((sy - 300/zoom)/2 - 180/zoom)
    exports.TR_dx:hideButton({guiInfo.form.buttons.goto_login, guiInfo.form.buttons.goto_register, guiInfo.form.buttons.goto_rules, guiInfo.form.buttons.goto_creators})

    exports.TR_dx:showEdit({guiInfo.form.edits.login_login, guiInfo.form.edits.login_password})
    exports.TR_dx:showButton({guiInfo.form.buttons.back_login, guiInfo.form.buttons.perform_login})
    exports.TR_dx:showCheck({guiInfo.form.checks.login_remember})
    setNewsesEnabled(false)

  elseif tab == "register" then
    moveLogo((sy - 590/zoom)/2 - 110/zoom)
    exports.TR_dx:hideButton({guiInfo.form.buttons.goto_login, guiInfo.form.buttons.goto_register, guiInfo.form.buttons.goto_rules, guiInfo.form.buttons.goto_creators})

    exports.TR_dx:showButton({guiInfo.form.buttons.perform_register, guiInfo.form.buttons.back_register})
    exports.TR_dx:showEdit({guiInfo.form.edits.register_login, guiInfo.form.edits.register_password, guiInfo.form.edits.register_repeatPassword, guiInfo.form.edits.register_mail, guiInfo.form.edits.register_referenced})
    exports.TR_dx:showCheck({guiInfo.form.checks.register_rules})

    guiInfo.passwordStrength = exports.TR_noti:create({"Şifre güvenlik seviyesi:", " 0%"}, "password", false, true)
    guiInfo.passwordStrengthUpdate = setTimer(updatePasswordStrength, 500, 0)
    updatePasswordStrength()
    setNewsesEnabled(false)

  elseif tab == "rules" then
    moveLogo((sy - 570/zoom)/2 - 180/zoom)
    exports.TR_dx:hideButton({guiInfo.form.buttons.goto_login, guiInfo.form.buttons.goto_register, guiInfo.form.buttons.goto_rules, guiInfo.form.buttons.goto_creators})

    exports.TR_dx:showButton(guiInfo.form.buttons.back_rules)
    exports.TR_dx:showScroll(guiInfo.form.scrolls.rules)
    setNewsesEnabled(false)

  elseif tab == "creators" then
    moveLogo((sy - 470/zoom)/2 - 180/zoom)
    exports.TR_dx:hideButton({guiInfo.form.buttons.goto_login, guiInfo.form.buttons.goto_register, guiInfo.form.buttons.goto_rules, guiInfo.form.buttons.goto_creators})

    exports.TR_dx:showButton(guiInfo.form.buttons.back_authors)
    exports.TR_dx:showScroll(guiInfo.form.scrolls.authors)
    setNewsesEnabled(false)
  end

  guiInfo.selectedTab = tab
end


function performLogin()
  local login = guiGetText(guiInfo.form.edits.login_login)
  local password = guiGetText(guiInfo.form.edits.login_password)

  if not string.checkLen(login, 3, 20) then exports.TR_noti:create("Kullanıcı adı 3 ila 20 karakter içermelidir.", "error") return end
  if not string.checkLen(password, 3, 40) then exports.TR_noti:create("Parola 3 ila 40 karakter içermelidir.", "error") return end
  saveLoginData()

  exports.TR_dx:setResponseEnabled(true)
  triggerServerEvent("loginAccount", resourceRoot, login, password)
end

function performRegister()
  local login = guiGetText(guiInfo.form.edits.register_login)
  local password = guiGetText(guiInfo.form.edits.register_password)
  local password_rep = guiGetText(guiInfo.form.edits.register_repeatPassword)
  local email = guiGetText(guiInfo.form.edits.register_mail)
  local reference = guiGetText(guiInfo.form.edits.register_referenced)
  local rules = exports.TR_dx:isCheckSelected(guiInfo.form.checks.register_rules)

  if not string.checkLen(login, 3, 20) then exports.TR_noti:create("Kullanıcı adı 3 ila 20 karakter içermelidir.", "error") return end
  if not checkString(login) then exports.TR_noti:create("Kullanıcı adı, izin verilmeyen karakterler içeriyor.", "error") return end
  if not string.checkLen(password, 3, 40) then exports.TR_noti:create("Parola 3 ila 40 karakter içermelidir.", "error") return end
  local strength, strengthText = calculateStrength(login, password)
  if strength <= 50 then exports.TR_noti:create("Şifre yeterince güvenli değil.", "error") return end
  if password ~= password_rep then exports.TR_noti:create("Parolalar aynı değildir.", "error") return end
  if not string.checkLen(email, 3, 40) then exports.TR_noti:create("E-posta 3 ile 60 karakter arasında olmalıdır.", "error") return end
  if not isValidMail(email) then exports.TR_noti:create("E-postada yanlış bir sözdizimi var.", "error") return end
  if not rules then exports.TR_noti:create("Bir hesap oluşturmak için kurallara uymayı kabul etmelisiniz.", "error") return end
  if guiInfo.registerLastLogin == login then exports.TR_noti:create("Kullanıcının böyle bir hesabı zaten var.", "error") return end

  if string.len(reference) > 0 then
    reference = reference
  else
    reference = false
  end

  guiInfo.registerLastLogin = login
  exports.TR_dx:setResponseEnabled(true)
  triggerServerEvent("registerAccount", resourceRoot, login, password, email, reference)
end

function loginPlayer(username, tutorial)
  if username then
    local count = 0;
    setTimer(function()
      if count == 10 then
        destroyElement(guiInfo.music)
      else
        setSoundVolume(guiInfo.music, getSoundVolume(guiInfo.music) - 0.1)
      end
      count = count + 1
    end, 100, 11)

    exports.TR_dx:showLoading(60000, "Loading models")
    exports.TR_dx:setResponseEnabled(true)

    setTimer(function()
      closeUsernameSelect()
      destroyLoginElements()
      exports.TR_dx:setResponseEnabled(false)

      exports.TR_models:loadModels(false, tutorial)
    end, 1000, 1)

  else
    exports.TR_dx:showLoading(1000, "Loading a choice of nickname")
    exports.TR_dx:setResponseEnabled(true)

    setTimer(function()
      destroyLoginElements(true)
      exports.TR_dx:setResponseEnabled(false)
      openUsernameSelect()
    end, 500, 1)
  end
end
addEvent("loginPlayer", true)
addEventHandler("loginPlayer", root, loginPlayer)


function isOnlyString(text)
  if string.find(text, "%c") then return false end
  if string.find(text, "%d") then return false end
  if string.find(text, "%p") then return false end
  if string.find(text, "%s") then return false end
  if string.find(text, "%z") then return false end
  return true
end

function drawBackground(x, y, rx, ry, color, radius, post)
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

function checkString(text)
  if string.find(text, "%c") or string.find(text, "%p") or string.find(text, "%s") or string.find(text, "%z") then
    return false
  else
    return true
  end
end

function isValidMail(mail)
  assert(type(mail) == "string", "Bad argument @ isValidMail [string expected, got "..tostring(mail) .."]")
  return mail:match("[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?") ~= nil
end

function string.checkLen(text, minLen, maxLen)
  if string.len(text) >= minLen and string.len(text) <= maxLen then return true else return false end
end

function RGBToHex(red, green, blue, alpha)
	if( ( red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255 ) or ( alpha and ( alpha < 0 or alpha > 255 ) ) ) then
		return nil
  end

	if alpha then
		return string.format("#%.2X%.2X%.2X%.2X", red, green, blue, alpha)
	else
		return string.format("#%.2X%.2X%.2X", red, green, blue)
	end
end

function updatePasswordStrength()
  local login = guiGetText(guiInfo.form.edits.register_login)
  local password = guiGetText(guiInfo.form.edits.register_password)
  local strength, strengthText = calculateStrength(login, password)

  local r, g, b = interpolateBetween(157, 28, 28, 41, 157, 28, strength/100, "Linear")
  exports.TR_noti:setColor(guiInfo.passwordStrength, {r, g, b})
  exports.TR_noti:setText(guiInfo.passwordStrength, {"Şifre güvenlik seviyesi:", string.format("%s%s", RGBToHex(r, g, b), strengthText)}, true)
end

function calculateStrength(login, password)
  local length = string.len(password)
  if length < 3 then return 0, "Çok zayıf" end

  local score = 0
  local scoreText = "Çok zayıf"
  if string.find(password, "%l") then -- lower
    score = score + 10
  end
  if string.find(password, "%u") then -- upper
    score = score + 20
  end
  if string.find(password, "%d") then -- digits
    score = score + 30
  end
  if string.find(password, "%W") then -- symbols
    score = score + 40
  end
  if login and login ~= "" then
    local f, l = string.find(password, login)
    if f and l then
      local len = l - f
      score = score - ((len / length) * score)
    end
  end
  if login == password then score = 0 end

  if score >= 20 and score <= 50 then
    scoreText = "Zayıf"
  elseif score > 50 and score <= 70 then
    scoreText = "Güçlü"
  elseif score > 70 then
    scoreText = "Çok güçlü"
  end

  return score, scoreText
end



-- Ban data
function formatBanData(data)
  local banData = {
    admin = data.admin,
    username = data.username,
    serial = data.serial,
    reason = data.reason,
    time = formatDate(data.time),
    timeEnd = formatDate(data.timeEnd),
    timeToKick = 65,
  }
  return banData
end

function formatDate(date)
  local forms = split(date, " ")
  local date = split(forms[1], "-")

  return string.format("%s %02d.%02d.%d", forms[2], date[3], date[2], date[1])
end

function createBanWindow()
  guiInfo.banInfo = {
    x = (sx - 900/zoom)/2,
    y = (sy - 200/zoom)/2,
    w = 900/zoom,
    h = 320/zoom,

    sad = dxCreateTexture("files/images/sad.png", "argb", true, "clamp"),
    sadText = "Yetersiz davrandığınız ve ban şeklinde cezalandırılmak zorunda kaldığınız için çok üzgünüz.",
  }
  guiInfo.fonts.title = exports.TR_dx:getFont(16)
  guiInfo.fonts.text = exports.TR_dx:getFont(13)
  guiInfo.fonts.sad = exports.TR_dx:getFont(11)
  guiInfo.banTick = getTickCount()

  setTimer(function()
    guiInfo.music = playSound("files/sound/login.mp3", true)
    exports.TR_dx:hideLoading()
  end, 5000, 1)
  addEventHandler("onClientRender", root, renderBanWindow)
end

function renderBanWindow()
  dxDrawImage(0, 0, sx, sy, "files/images/banBg.png")
  dxDrawImage((sx - guiInfo.logo.w)/2, guiInfo.banInfo.y - 250/zoom, guiInfo.logo.w, guiInfo.logo.h, "files/images/logo.png", 0, 0, 0, tocolor(255, 255, 255, 255))

  drawBackground(guiInfo.banInfo.x, guiInfo.banInfo.y, guiInfo.banInfo.w, guiInfo.banInfo.h, tocolor(17, 17, 17, 255), 5)
  dxDrawImage(guiInfo.banInfo.x + guiInfo.banInfo.w - (400/zoom - 128/zoom)/2 - 128/zoom, guiInfo.banInfo.y + 60/zoom, 128/zoom, 128/zoom, guiInfo.banInfo.sad, 0, 0, 0, tocolor(100, 100, 100, 255))
  dxDrawText(guiInfo.banInfo.sadText, guiInfo.banInfo.x + guiInfo.banInfo.w - 390/zoom, guiInfo.banInfo.y + 198/zoom, guiInfo.banInfo.x + guiInfo.banInfo.w - 10/zoom, 0, tocolor(100, 100, 100, 255), 1/zoom, guiInfo.fonts.sad, "center", "top", false, true)

  dxDrawText("Sunucudan yasaklandınız.", guiInfo.banInfo.x, guiInfo.banInfo.y + 10/zoom, guiInfo.banInfo.x + guiInfo.banInfo.w, guiInfo.banInfo.y + 30/zoom, tocolor(212, 175, 55, 255), 1/zoom, guiInfo.fonts.title, "center", "center")

  dxDrawText(string.format("Oyuncuya uygulanan: #999999%s", guiInfo.banData.username), guiInfo.banInfo.x + 10/zoom, guiInfo.banInfo.y + 70/zoom, 0, guiInfo.banInfo.y + 30/zoom, tocolor(255, 255, 255, 150), 1/zoom, guiInfo.fonts.text, "left", "top", false, false, false, true)
  dxDrawText(string.format("Serial'e uygulanan: #999999%s", guiInfo.banData.serial), guiInfo.banInfo.x + 10/zoom, guiInfo.banInfo.y + 95/zoom, 0, guiInfo.banInfo.y + 30/zoom, tocolor(255, 255, 255, 150), 1/zoom, guiInfo.fonts.text, "left", "top", false, false, false, true)

  dxDrawText(string.format("Banlayan: #999999%s", guiInfo.banData.admin), guiInfo.banInfo.x + 10/zoom, guiInfo.banInfo.y + 120/zoom, 0, guiInfo.banInfo.y + 30/zoom, tocolor(255, 255, 255, 150), 1/zoom, guiInfo.fonts.text, "left", "top", false, false, false, true)
  dxDrawText(string.format("Banlandığınız süre: #999999%sr.", guiInfo.banData.time), guiInfo.banInfo.x + 10/zoom, guiInfo.banInfo.y + 145/zoom, 0, guiInfo.banInfo.y + 30/zoom, tocolor(255, 255, 255, 150), 1/zoom, guiInfo.fonts.text, "left", "top", false, false, false, true)
  dxDrawText(string.format("Bitiş Süresi: #999999%sr.", guiInfo.banData.timeEnd), guiInfo.banInfo.x + 10/zoom, guiInfo.banInfo.y + 170/zoom, 0, guiInfo.banInfo.y + 30/zoom, tocolor(255, 255, 255, 150), 1/zoom, guiInfo.fonts.text, "left", "top", false, false, false, true)
  dxDrawText("Açıklama:", guiInfo.banInfo.x + 10/zoom, guiInfo.banInfo.y + 195/zoom, guiInfo.banInfo.x + guiInfo.banInfo.w/2, guiInfo.banInfo.y + 30/zoom, tocolor(255, 255, 255, 150), 1/zoom, guiInfo.fonts.text, "left", "top", false, false, false, true)
  dxDrawText(guiInfo.banData.reason, guiInfo.banInfo.x + 10/zoom, guiInfo.banInfo.y + 220/zoom, guiInfo.banInfo.x + guiInfo.banInfo.w/2, guiInfo.banInfo.y + 30/zoom, tocolor(153, 153, 153, 150), 1/zoom, guiInfo.fonts.text, "left", "top", true, true, false, true)

  dxDrawText(string.format("Yasakla ilgili bilgileri okumak için %ds hakkınız var ve ardından otomatik olarak okuldan atılacaksınız.", guiInfo.banData.timeToKick), guiInfo.banInfo.x + 10/zoom, 0, guiInfo.banInfo.x + guiInfo.banInfo.w - 10/zoom, guiInfo.banInfo.y + guiInfo.banInfo.h - 10/zoom, tocolor(100, 100, 100, 250), 1/zoom, guiInfo.fonts.sad, "center", "bottom")
  if guiInfo.banTick then
    if (getTickCount() - guiInfo.banTick)/1000 > 1 then
      guiInfo.banTick = getTickCount()
      guiInfo.banData.timeToKick = guiInfo.banData.timeToKick - 1

      if guiInfo.banData.timeToKick == 0 then
        triggerServerEvent("kickPlayer", resourceRoot, localPlayer, "ban info", "Bilgilere alışma zamanı geçti.")
      end
    end
  end
end



-- NICK SELECT --
function openUsernameSelect()
  if guiInfo.username.open then return end
  guiInfo.username.open = true
  guiInfo.username.usernameEdit = exports.TR_dx:createEdit(guiInfo.username.x + 10/zoom, guiInfo.username.y + 50/zoom, guiInfo.username.w - 20/zoom, 40/zoom, "Enter Nick", false)
  guiInfo.username.usernameAccept = exports.TR_dx:createButton(guiInfo.username.x + guiInfo.username.w - (guiInfo.username.w - 20/zoom)/2 - 10/zoom, guiInfo.username.y + 100/zoom, (guiInfo.username.w - 20/zoom)/2, 40/zoom, "Accept", "green")
  guiInfo.username.state = "decline"

  guiInfo.username.timer = setTimer(checkUsernameSelect, 400, 0)

  addEventHandler("onClientRender", root, renderUsernameSelect)
  addEventHandler("guiButtonClick", root, checkUsernameClick)
  showCursor(true)
end

function closeUsernameSelect()
  if not guiInfo.username.open then return end
  guiInfo.username.open = nil

  if isTimer(guiInfo.username.timer) then killTimer(guiInfo.username.timer) end
  if isTimer(guiInfo.username.updateState) then killTimer(guiInfo.username.updateState) end
  removeEventHandler("onClientRender", root, renderUsernameSelect)
  exports.TR_dx:destroyEdit(guiInfo.username.usernameEdit)
  exports.TR_dx:destroyButton(guiInfo.username.usernameAccept)
  guiInfo.username = nil
end

function renderUsernameSelect()
  dxDrawImage(0, 0, sx, sy, "files/images/nickSelect.png")
  dxDrawImage((sx - guiInfo.logo.w)/2, guiInfo.username.y - 250/zoom, guiInfo.logo.w, guiInfo.logo.h, "files/images/logo.png", 0, 0, 0, tocolor(255, 255, 255, 255))

  drawBackground(guiInfo.username.x, guiInfo.username.y, guiInfo.username.w, guiInfo.username.h, tocolor(17, 17, 17, 255), 5)
  dxDrawText("Oyunda takma adınızı seçin", guiInfo.username.x, guiInfo.username.y + 10/zoom, guiInfo.username.x + guiInfo.username.w, guiInfo.username.y + 30/zoom, tocolor(255, 255, 255, 255), 1/zoom, guiInfo.fonts.remember, "center", "center")

  if guiInfo.username.state == "searching" then
    dxDrawText("Doğrulanıyor"..guiInfo.username.dots, guiInfo.username.x + 52/zoom, guiInfo.username.y + 100/zoom, guiInfo.username.x + guiInfo.username.w, guiInfo.username.y + 140/zoom, tocolor(255, 255, 255, 255), 1/zoom, guiInfo.fonts.remember, "left", "center")
    dxDrawImage(guiInfo.username.x + 15/zoom, guiInfo.username.y + 107/zoom, 26/zoom, 26/zoom, "files/images/search.png")

  elseif guiInfo.username.state == "found" then
    dxDrawText("Kullanılabilir", guiInfo.username.x + 52/zoom, guiInfo.username.y + 100/zoom, guiInfo.username.x + guiInfo.username.w, guiInfo.username.y + 140/zoom, tocolor(255, 255, 255, 255), 1/zoom, guiInfo.fonts.remember, "left", "center")
    dxDrawImage(guiInfo.username.x + 15/zoom, guiInfo.username.y + 107/zoom, 26/zoom, 26/zoom, "files/images/accept.png")

  elseif guiInfo.username.state == "invalid" then
    dxDrawText("Kullanılamaz", guiInfo.username.x + 52/zoom, guiInfo.username.y + 100/zoom, guiInfo.username.x + guiInfo.username.w, guiInfo.username.y + 140/zoom, tocolor(255, 255, 255, 255), 1/zoom, guiInfo.fonts.remember, "left", "center")
    dxDrawImage(guiInfo.username.x + 15/zoom, guiInfo.username.y + 107/zoom, 26/zoom, 26/zoom, "files/images/decline.png")

  else
    dxDrawText("Kullanılamaz", guiInfo.username.x + 52/zoom, guiInfo.username.y + 100/zoom, guiInfo.username.x + guiInfo.username.w, guiInfo.username.y + 140/zoom, tocolor(255, 255, 255, 255), 1/zoom, guiInfo.fonts.remember, "left", "center")
    dxDrawImage(guiInfo.username.x + 15/zoom, guiInfo.username.y + 107/zoom, 26/zoom, 26/zoom, "files/images/decline.png")
  end

  if guiInfo.username.tick then
    if (getTickCount() - guiInfo.username.tick)/400 > 1 then
      guiInfo.username.dots = guiInfo.username.dots .. "."
      guiInfo.username.tick = getTickCount()
      if string.len(guiInfo.username.dots) > 3 then
        guiInfo.username.dots = ""
      end
    end
  end
end

function checkUsernameSelect()
  local username = guiGetText(guiInfo.username.usernameEdit)

  if guiInfo.username.searched == username then return end
  if isTimer(guiInfo.username.updateState) then killTimer(guiInfo.username.updateState) end
  if guiInfo.username.searching then return end

  if username == guiInfo.username.lastUsername then
    if not string.checkLen(username, 3, 18) or not checkString(username) or tonumber(username) ~= nil then
      guiInfo.username.searched = nil
      guiInfo.username.state = "invalid"
      return
    end

    guiInfo.username.dots = ""
    guiInfo.username.tick = getTickCount()
    guiInfo.username.state = "searching"

    triggerServerEvent("checkUsernameFree", resourceRoot, username)
    guiInfo.username.searching = true
    return
  end
  guiInfo.username.lastUsername = username
end

function checkUsernameValid(nick, state)
  if guiInfo.username.lastUsername == nick then
    guiInfo.username.updateState = setTimer(function()
      guiInfo.username.state = state and "found" or false
    end, 2000, 1)
    guiInfo.username.state = "searching"
  end
  guiInfo.username.searching = false
  guiInfo.username.searched = nick
end
addEvent("checkUsernameValid", true)
addEventHandler("checkUsernameValid", root, checkUsernameValid)

function checkUsernameClick(btn)
  if btn == guiInfo.username.usernameAccept then
    local username = guiGetText(guiInfo.username.usernameEdit)

    if guiInfo.username.searching then return end
    if guiInfo.username.searched ~= username then return end
    if guiInfo.username.state ~= "found" then return end
    triggerServerEvent("setPlayerUsername", resourceRoot, username)
    removeEventHandler("guiButtonClick", root, checkUsernameClick)
  end
end


-- UTILS --
function isMouseInPosition(x, y, width, height)
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

function drawBackground(x, y, rx, ry, color, radius, post)
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

function getRules()
  local rules = [[
    #d4af37§1. KURALLAR:
    #d4af371.1 #c8c8c8Sohbette aşırı küfür ve spam kullanımı yasaktır.
    #d4af371.2 #c8c8c8Diğer yol kullanıcılarına çarpmak yasaktır.
    #d4af371.3 #c8c8c8Havalimanı dışına iniş yapmak yasaktır.
    #d4af371.4 #c8c8c8Oyun destek programlarını kullanmak yasaktır.
    #d4af371.5 #c8c8c8Irkçı, dini veya pornografik içeriğin tanıtımını yapmak yasaktır.
    #d4af371.6 #c8c8c8İdareden maddi mal istemek yasaktır.
    #d4af371.7 #c8c8c8Sunucu ürünlerinin sunucu dışında ticareti yasaktır.
    #d4af371.8 #c8c8c8Oyunculara veya yönetime karşı her türlü hakaret yasaktır.
    #d4af371.9 #c8c8c8Inside MTA ile ilgisi olmayan başka server ve sitelerin reklamını yapmak yasaktır.
    #d4af371.10 #c8c8c8Oynanış hatalarını dağıtmak ve istismar etmek yasaktır.
    #d4af371.11 #c8c8c8Diğer oyuncuları veya yöneticileri taklit etmek yasaktır.

    #d4af37§2. Oyuncu hakları:
    #d4af372.1 #c8c8c8Her oyuncunun haksız yere verilen bir cezaya itiraz etme hakkı vardır.
    #d4af372.2 #c8c8c8Her oyuncunun yöneticiye veya başka bir oyuncuya karşı şikayette bulunma hakkı vardır.
    #d4af372.3 #c8c8c8Her oyuncunun yönetimden yardım isteme hakkı vardır.
    #d4af372.4 #c8c8c8Kurallara aykırı olmadığı sürece her oyuncunun konuşma özgürlüğü vardır.

    #d4af37§3. Oyuncu Sorumlulukları:
    #d4af373.1 #c8c8c8Herhangi bir hatayı derhal bildirmek her oyuncunun sorumluluğundadır.
    #d4af373.2 #c8c8c8Her oyuncu kişisel kültürünü korumakla yükümlüdür.
    #d4af373.3 #c8c8c8Her oyuncu yönetime uymakla yükümlüdür.
    #d4af373.4 #c8c8c8Her oyuncu kuralları çiğneyen oyuncuları yönetime bildirmekle yükümlüdür.
    #d4af373.5 #c8c8c8Her oyuncu sunucunun tüm kurallarına uymakla yükümlüdür.

    #d4af37§4. Ek bilgi:
    #d4af374.1 #c8c8c8Her oyuncu hesabından ve içeriğinden sorumludur.
    #d4af374.2 #c8c8c8Aracınıza, evinize vb. ortak sahip kaydetme riski size aittir.
    #d4af374.3 #c8c8c8Oyuncunun hatasından kaynaklanan maddi kayıplardan yönetim sorumlu değildir.
    #d4af374.4 #c8c8c8Belirli bir nokta düzenlemelerde yer almıyorsa, yönetici bunu geçici olarak kelimelerle belirleme hakkına sahiptir.
    #d4af374.5 #c8c8c8Yönetim, sohbet veya PM'de cevap vermek zorunda değildir.
    #d4af374.6 #c8c8c8Sunucu yönetimi, herhangi bir sebep göstermeden sunucuda kimlerin oynayabileceğine karar verme hakkına sahiptir.
    #d4af374.7 #c8c8c8Düzenlemelerin cehaleti, uyulmasından muaf değildir.
    #d4af374.8 #c8c8c8Yönetmelikler herhangi bir zamanda değiştirilebilir.

  ]]

  return rules
end

function getCreators()
  local creators = [[
    #d4af37Mahlukat
    #c8c8c8Developer, Founder
	
    #d4af37Casti
    #c8c8c8Developer, Founder
	
    #d4af37PandaBeY
    #c8c8c8Developer, Founder
  
     #d4af37Ne0R`
    #c8c8c8Developer, Founder
  
  ]]
  return creators
end

function loginResponseServer(text, type, specialData)
  setTimer(function()
    if text then exports.TR_noti:create(text, type) end

    if not specialData then
      exports.TR_dx:setResponseEnabled(false)

    else
      if specialData == "reference" then
        guiInfo.registerLastLogin = nil
        exports.TR_dx:setResponseEnabled(false)

      elseif specialData == "accountCreate" then
        if isElement(guiInfo.passwordStrength) then
          killTimer(guiInfo.passwordStrengthUpdate)
          exports.TR_noti:destroy(guiInfo.passwordStrength)
          guiInfo.passwordStrength = nil
        end

        exports.TR_noti:create("Hesap doğru bir şekilde oluşturuldu.\nBir an otomatik olarak oturum açılacaktır..", "success", 5)
        local login = guiGetText(guiInfo.form.edits.register_login)
        local password = guiGetText(guiInfo.form.edits.register_password)
        setTimer(function()
          triggerServerEvent("loginAccount", resourceRoot, login, password)
        end, 1000, 1)
      end

    end
  end, 500 ,1)
end
addEvent("loginResponseServer", true)
addEventHandler("loginResponseServer", root, loginResponseServer)


function posInFront(...)
  local m = getElementMatrix(arg[1])
  local x = arg[2] * m[1][1] + arg[3] * m[2][1] + arg[4] * m[3][1] + m[4][1]
  local y = arg[2] * m[1][2] + arg[3] * m[2][2] + arg[4] * m[3][2] + m[4][2]
  local z = arg[2] * m[1][3] + arg[3] * m[2][3] + arg[4] * m[3][3] + m[4][3]
  return x, y, z
end

function getSavedLoginData()
  local xml = xmlLoadFile("userdata.xml")
  if not xml then
    xml = xmlCreateFile("userdata.xml", "userdata")
    xmlCreateChild(xml, "login")
    xmlCreateChild(xml, "password")
    xmlSaveFile(xml)
    xmlUnloadFile(xml)

    return false, false, false
  end

  local loginChild = xmlFindChild(xml, "login", 0)
  local passwordChild = xmlFindChild(xml, "password", 0)
  local login = xmlNodeGetValue(loginChild)
  local password = teaDecodeBinary(xmlNodeGetValue(passwordChild), "eKXJmeNDR4cFs47q")

  xmlUnloadFile(xml)

  return login, password, string.len(login) > 0 and string.len(password) > 0 and true or false
end

function saveLoginData()
  local xml = xmlLoadFile("userdata.xml")
  if not xml then return end

  local login = guiGetText(guiInfo.form.edits.login_login)
  local password = guiGetText(guiInfo.form.edits.login_password)
  local remember = exports.TR_dx:isCheckSelected(guiInfo.form.checks.login_remember)

  local loginChild = xmlFindChild(xml, "login", 0)
  local passwordChild = xmlFindChild(xml, "password", 0)

  if remember then
    xmlNodeSetValue(loginChild, login)
    xmlNodeSetValue(passwordChild, teaEncodeBinary(password, "eKXJmeNDR4cFs47q"))
    xmlSaveFile(xml)
  else
    xmlNodeSetValue(loginChild, "")
    xmlNodeSetValue(passwordChild, "")
    xmlSaveFile(xml)
  end

  xmlUnloadFile(xml)
end
function teaEncodeBinary(data, key)
  return teaEncode(base64Encode(data), key)
end
function teaDecodeBinary(data, key)
  return base64Decode(teaDecode(data, key))
end

function openLoginPanel()
  triggerServerEvent("getBanData", resourceRoot)
end

if not getElementData(localPlayer, "characterUID") then openLoginPanel() end