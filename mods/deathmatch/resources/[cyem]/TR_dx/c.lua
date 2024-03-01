sx, sy = guiGetScreenSize()

zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

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

guiSetInputMode("no_binds_when_editing")
guiData = {
  fonts = {},

  buttonColor = {
    ["gray"] = {67, 67, 67, 255},
    ["red"] = {107, 67, 67, 255},
    ["green"] = {67, 107, 67, 255},
  },

  checkbox = {
    bg = dxCreateTexture("files/images/checkbox_bg.png", "argb", true, "clamp"),
    check = dxCreateTexture("files/images/checkbox_check.png", "argb", true, "clamp"),
  },

  switch = {
    circle = dxCreateTexture("files/images/switch_circle.png", "argb", true, "clamp"),
  },

  response = {
    spinner = dxCreateTexture("files/images/loading.png", "argb", true, "clamp"),
  },

  loading = {
    bg = {
      logo = dxCreateTexture("files/images/logo.png", "argb", true, "clamp"),
      [1] = dxCreateTexture("files/images/loadings/1.png", "argb", true, "clamp"),
      [2] = dxCreateTexture("files/images/loadings/2.png", "argb", true, "clamp"),
      [3] = dxCreateTexture("files/images/loadings/3.png", "argb", true, "clamp"),
    },
    maxImg = 3,

    tips = {
      "Duygularınızı ifade etmek için F2 butonunun altındaki animasyon panelini kullanabilirsiniz.",
      "Hesabınızla ilgili tüm verileri F5 butonu ile kontrol edebilirsiniz.",
      "Yolunuzu kaybettiyseniz F11 butonunu kullanarak haritaya erişebilirsiniz.",
      "Başka bir oyuncu, obje veya araçla etkileşime geçmek için E butonunu kullanabilirsiniz.",
      "Telefonunuzu kullanmak için END butonunu kullanabilirsiniz.\nEnvanterden telefonunuzun üzerine gelerek telefon numaranızı öğrenebilirsiniz.",
      "Haritada Sağ Tık yaparak GPS'i belirtilen noktaya ayarlayabilirsiniz.",
      "Sunucuya veya maceranıza nasıl başlayacağınız hakkında bir şeyler öğrenmek için F1 panelini kullanabilirsiniz.",
      -- "Ehliyet cümlesini kaldıramıyorsanız, sunucu forumundaki cevapları kullanın.",
      "Yeni bir araca bütçeniz yetmiyorsa bir hurdacıya gidin. Sizin için mutlaka bir şeyler bulacaktır.",
      "Oyunculardan birinin uygunsuz davranışını fark ederseniz, /report komutunu kullanarak bunu yetkili ekibimize bildirebilirsiniz.",
      "Görevli admin sayısını /admins komutu ile kontrol edebilirsiniz.",
      "Sunucu için ilginç bir öneriniz veya fikriniz varsa, discord üzerinden bizlerle paylaşabilirsiniz.",
      "Sunucuda yeniyseniz, depo gibi herhangi bir gereksinim olmayan bir işe başlamak en iyisidir.",
      "Kendinizi hızlı bir şekilde iyileştirmek için eczaneye veya ilaç pazarına gidebilirsiniz.",
      "Haritada pembe işaretli belediye binasında kendi özel factionunuzu oluşturabilirsiniz.",
      "Paranız için endişeleniyorsanız onu bir banka hesabında tutabilirsiniz.",
      "Envantere erişmek için I tuşunu kullanabilirsiniz.",
    },
  },
  capsOn = false,
}

function setOpenGUI(state)
  guiData.open = state
  toggleControl("next_weapon", not state)
  toggleControl("previous_weapon", not state)
end

function canOpenGUI()
  if isResponseEnabled() then return false end
  return not guiData.open
end

function getFontSize(size)
  return math.max(math.min(math.floor(size/zoom), 150), 5)
end

function getFont(size, family)
  -- local size = getFontSize(size)
  local font = guiData.fonts[string.format("size_%s_%d", family and family or "default", size)]
  if not font then font = createFont(size, family) end
  return font
end

function getBoldFont(size, family)
  -- local size = getFontSize(size)
  local font = guiData.fonts[string.format("size_%s_%d_bold", family and family or "default", size)]
  if not font then font = createBoldFont(size, family) end
  return font
end

function createFont(size, family)
  guiData.fonts[string.format("size_%s_%d", family and family or "default", size)] = dxCreateFont(string.format("files/fonts/%s.ttf", family and family or "default"), size, false, family and "antialiased" or "cleartype_natural")
  return guiData.fonts[string.format("size_%s_%d", family and family or "default", size)]
end

function createBoldFont(size, family)
  guiData.fonts[string.format("size_%s_%d_bold", family and family or "default", size)] = dxCreateFont(string.format("files/fonts/%s.ttf", family and family or "default"), size, true, family and "antialiased" or "cleartype_natural")
  return guiData.fonts[string.format("size_%s_%d_bold", family and family or "default", size)]
end

function getButtonColor(color)
  return guiData.buttonColor[color] and guiData.buttonColor[color] or false
end

function cursorY()
  local _, cY = getCursorPosition()
  return cY * sy
end

function removeStoppedResourceElements(res)
  local owner = getResourceName(res)

  for i, v in pairs(createdButtons) do
    if v:getOwner() == owner then
      v:destroy()
    end
  end

  for i, v in pairs(createdEdits) do
    if v:getOwner() == owner then
      v:destroy()
    end
  end

  for i, v in pairs(createdChecks) do
    if v:getOwner() == owner then
      v:destroy()
    end
  end

  for i, v in pairs(createdScrolls) do
    if v:getOwner() == owner then
      v:destroy()
    end
  end

  for i, v in pairs(createdSwitches) do
    if v:getOwner() == owner then
      v:destroy()
    end
  end
end
addEventHandler("onClientResourceStop", root, removeStoppedResourceElements)

function isEscapeOpen()
  return guiData.isEscapeOpen
end

function setEscapeOpen(state)
  guiData.isEscapeOpen = state
  return true
end
-- local fontTest = {}
-- for i, v in pairs({"default", "draft", "proof", "antialiased", "cleartype"}) do
--   fontTest[v] = dxCreateFont("files/fonts/default.ttf", 20, false, v)
-- end

-- addEventHandler("onClientRender", root, function()
--   local y = 100
--   for i, v in pairs(fontTest) do
--     dxDrawText("Testowy tekst do porównania generalnie wszystkich aspektów - "..i, 400, y, 400, y, tocolor(255, 255, 255, 255), 1, v, "left", "center", false, false, true)

--     y = y + 50
--   end
-- end)