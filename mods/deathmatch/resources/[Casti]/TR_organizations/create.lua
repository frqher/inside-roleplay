local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 500/zoom)/2,
    y = (sy - 400/zoom)/2,
    w = 500/zoom,
    h = 400/zoom,

    price = 25000,
}

CreateOrg = {}
CreateOrg.__index = CreateOrg

function CreateOrg:create(...)
    local instance = {}
    setmetatable(instance, CreateOrg)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function CreateOrg:constructor(...)
    self.alpha = 0
    self.tab = "info"
    self.pedName = arg[1]

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.parts = exports.TR_dx:getFont(11)
    self.fonts.small = exports.TR_dx:getFont(10)

    self.buttons = {}
    self.buttons.exit = exports.TR_dx:createButton(guiInfo.x + 10/zoom, guiInfo.y + guiInfo.h - 50/zoom, 235/zoom, 40/zoom, "İptal")
    self.buttons.submit = exports.TR_dx:createButton(guiInfo.x + guiInfo.w - 245/zoom, guiInfo.y + guiInfo.h - 50/zoom, 235/zoom, 40/zoom, "Anladım")
    exports.TR_dx:setButtonVisible(self.buttons, false)

    self.edits = {}
    self.edits.name = exports.TR_dx:createEdit(guiInfo.x + (guiInfo.w - 350/zoom)/2, guiInfo.y + (guiInfo.h - 60/zoom)/2, 350/zoom, 40/zoom, "Kuruluş Adı", false, self.sa)
    exports.TR_dx:setEditLimit(self.edits.name, 20)
    exports.TR_dx:setEditVisible(self.edits, false)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.buttonClick = function(...) self:buttonClick(...) end

    self:open()
    return true
end


function CreateOrg:open()
    self.state = "opening"
    self.tick = getTickCount()

    exports.TR_dx:showButton(self.buttons)
    exports.TR_dx:setOpenGUI(true)

    showCursor(true)
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("guiButtonClick", root, self.func.buttonClick)
end

function CreateOrg:close()
    self.state = "closing"
    self.tick = getTickCount()

    exports.TR_dx:hideButton(self.buttons)
    exports.TR_dx:hideEdit(self.edits)

    showCursor(false)
    removeEventHandler("guiButtonClick", root, self.func.buttonClick)
end

function CreateOrg:destroy()
    exports.TR_dx:setOpenGUI(false)
    exports.TR_dx:destroyButton(self.buttons)
    exports.TR_dx:destroyEdit(self.edits)

    removeEventHandler("onClientRender", root, self.func.render)
    guiInfo.window = nil
    self = nil
end


function CreateOrg:animate()
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

        self:destroy()
      end
    end
end


function CreateOrg:render()
    self:animate()
    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 5)
    dxDrawText("Organizasyon oluştur", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")

    if self.tab == "info" then
        self:renderInfo()
    else
      self:renderCreate()
    end
    --
    -- dxDrawText("Koszt założenia organizacji wynosi #d4af37$50 000#aaaaaa.", guiInfo.x + (guiInfo.w - 250/zoom)/2, guiInfo.y + 92/zoom, guiInfo.x + (guiInfo.w + 250/zoom)/2, guiInfo.y + guiInfo.h - 55/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.small, "center", "top", false, false, false, true)

end

function CreateOrg:renderInfo()
  dxDrawText("Kendi organizasyonuna sahip olmak kolay bir iş değildir. Kurmadan önce bilmeniz gereken bazı şeyler şunlardır:\n- Organizasyonu kaybetmemek için haftalık 2000$ kira ödenmelidir.\n- Çalışanlar, araçlar ve kazanç yüzdesi gibi sınırlar vardır ve bunlar arttırılabilir.\n- Organizasyon, F3 tuşuna basarak bir bilgisayar aracılığıyla yönetilir.\n- Her organizasyonun kendi iç sıralaması olabilir ve bu sıralamayı bir bilgisayar aracılığıyla yönetebilirsiniz.\n- Her organizasyonun kendi logosu vardır ve logo değişikliği organizasyon panelinde bildirilebilir.", guiInfo.x + 10/zoom, guiInfo.y + 50/zoom, guiInfo.x + guiInfo.w- 10/zoom, guiInfo.y + guiInfo.h - 55/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.parts, "left", "top", true, true)
  dxDrawText("Kurulan bir organizasyonun çalışan sayısı sınırlıdır (5 kişi), araç sayısı sınırlıdır (3 adet) ve temel kazançlar çalışanların maaşlarının %3'üdür.", guiInfo.x + 10/zoom, guiInfo.y + 50/zoom, guiInfo.x + guiInfo.w- 10/zoom, guiInfo.y + guiInfo.h - 55/zoom, tocolor(220, 110, 110, 255 * self.alpha), 1/zoom, self.fonts.parts, "center", "bottom", true, true)
end

function CreateOrg:renderCreate()
  dxDrawText("Organizasyon oluşturmayı tamamlamak için, sadece aşağıya organizasyonun adını yazmanız yeterlidir. İsimler tekrarlanamaz.", guiInfo.x + 10/zoom, guiInfo.y + 50/zoom, guiInfo.x + guiInfo.w- 10/zoom, guiInfo.y + guiInfo.h - 55/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.parts, "center", "top", true, true)

  dxDrawText("Organizasyon kurma maliyeti: $"..guiInfo.price, guiInfo.x + 10/zoom, guiInfo.y + 50/zoom, guiInfo.x + guiInfo.w- 10/zoom, guiInfo.y + guiInfo.h/2 - 35/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.parts, "center", "bottom", true, true)
  dxDrawText("Organizasyon adı ve logosunun sunucu kurallarını ihlal etmemesi gerektiğini unutmayın. Ayrıca, küfürlü isimlere, aktif olmayan üyelere veya 3'ten az çalışana sahip organizasyonlara izin verilmeyecektir.", guiInfo.x + 10/zoom, guiInfo.y + 50/zoom, guiInfo.x + guiInfo.w- 10/zoom, guiInfo.y + guiInfo.h - 55/zoom, tocolor(220, 110, 110, 255 * self.alpha), 1/zoom, self.fonts.parts, "center", "bottom", true, true)
end


function CreateOrg:buttonClick(...)
  if exports.TR_dx:isResponseEnabled() then return false end
  if arg[1] == self.buttons.exit then
      self:close()

  elseif arg[1] == self.buttons.submit then
      if self.tab == "info" then
          self.tab = "create"
          exports.TR_dx:setButtonText(self.buttons.submit, "Organizasyon Oluştur")
          exports.TR_dx:setEditVisible(self.edits, true)

      elseif self.tab == "create" then
          self.orgName = guiGetText(self.edits.name)

          if string.len(self.orgName) < 5 or string.len(self.orgName) > 20 then exports.TR_noti:create("Organizasyon adı 5 ile 20 harf arasında olmalıdır.", "error") return end
          if not self:checkString(self.orgName) then exports.TR_noti:create("Organizasyon adı uygun olmayan karakterler içeriyor.", "error") return end

          exports.TR_dx:setResponseEnabled(true)
          triggerServerEvent("checkOrgNameFree", resourceRoot, self.orgName)
      end
  end
end



function CreateOrg:checkString(text)
  if string.find(text, "%c") or string.find(text, "%p") or string.find(text, "%z") then
    return false
  else
    return true
  end
end

function CreateOrg:drawBackground(x, y, rx, ry, color, radius, post)
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

function CreateOrg:isMouseInPosition(x, y, width, height)
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

function CreateOrg:response(...)
  if arg[1] == "bought" then
      self:close()
      exports.TR_dx:setResponseEnabled(false)

  elseif arg[1] == "cantCreate" then
      exports.TR_noti:create("Bu organizasyon adı zaten alınmış.", "error")
      exports.TR_dx:setResponseEnabled(false)

  elseif arg[1] == "canCreate" then
      triggerServerEvent("createPayment", resourceRoot, guiInfo.price, "payForNewOrg", {self.pedName, self.orgName})

  elseif not arg[1] then
      exports.TR_dx:setResponseEnabled(false)
  end
end


function createOrganization(...)
    if guiInfo.window then return end
    guiInfo.window = CreateOrg:create(...)
end
addEvent("createOrganization", true)
addEventHandler("createOrganization", root, createOrganization)

function createOrganizationResponse(...)
    if not guiInfo.window then return end
    guiInfo.window:response(...)
end
addEvent("createOrganizationResponse", true)
addEventHandler("createOrganizationResponse", root, createOrganizationResponse)

-- exports.TR_dx:setOpenGUI(false)

-- if getPlayerName(localPlayer) == "Xantris" then
--   createOrganization("Test")
-- end