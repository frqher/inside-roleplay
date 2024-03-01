local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 400/zoom)/2,
    y = (sy - 540/zoom)/2,
    w = 400/zoom,
    h = 540/zoom,

    fixPositions = {
      Vector3(2113.4899902344, -1880.2362060547, 13.546875), -- LS Small Left
      Vector3(2106.517578125, -1879.9066162109, 13.546875), -- LS Small right
    },
}

GovJobs = {}
GovJobs.__index = GovJobs

function GovJobs:create(...)
    local instance = {}
    setmetatable(instance, GovJobs)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function GovJobs:constructor(...)
    self.alpha = 0
    self.jobs = arg[1]
    self.currentJob = arg[2]
    self.licences = arg[3] and fromJSON(arg[3]) or {}

    self.fonts = {}
    self.fonts.job = exports.TR_dx:getFont(16)
    self.fonts.main = exports.TR_dx:getFont(14)
    self.fonts.list = exports.TR_dx:getFont(12)
    self.fonts.about = exports.TR_dx:getFont(11)

    self.buttons = {}
    self.buttons.exit = exports.TR_dx:createButton(guiInfo.x + (guiInfo.w - 235/zoom)/2, guiInfo.y + guiInfo.h - 50/zoom, 235/zoom, 40/zoom, "Zamknij")
    self.buttons.accept = exports.TR_dx:createButton(guiInfo.x + (guiInfo.w - 235/zoom)/2, guiInfo.y + guiInfo.h - 100/zoom, 235/zoom, 40/zoom, "Zatrudnij się")
    exports.TR_dx:setButtonVisible(self.buttons, false)

    self.func = {}
    self.func.render = function() self:render() end
    self.func.mouseClick = function(...) self:mouseClick(...) end
    self.func.buttonClick = function(...) self:buttonClick(...) end

    self:open()
    return true
end


function GovJobs:open()
    self.state = "opening"
    self.tick = getTickCount()

    exports.TR_dx:setOpenGUI(true)
    exports.TR_dx:showButton(self.buttons.exit)

    showCursor(true)
    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientClick", root, self.func.mouseClick)
    addEventHandler("guiButtonClick", root, self.func.buttonClick)
end

function GovJobs:close()
    self.state = "closing"
    self.tick = getTickCount()

    exports.TR_dx:hideButton(self.buttons)

    if isTimer(self.timer) then killTimer(self.timer) end
    showCursor(false)
    removeEventHandler("guiButtonClick", root, self.func.buttonClick)
    removeEventHandler("onClientClick", root, self.func.mouseClick)
end

function GovJobs:destroy()
    exports.TR_dx:setOpenGUI(false)
    exports.TR_dx:destroyButton(self.buttons)
    removeEventHandler("onClientRender", root, self.func.render)
    guiInfo.job = nil
    self = nil
end


function GovJobs:animate()
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

function GovJobs:render()
    self:animate()
    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 5)
    dxDrawText("Resmi iş", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")

    self:renderList()
    self:renderJobData()
end

function GovJobs:renderList()
    if self.selectedData then return end
    for i, v in pairs(self.jobs) do
        if i == self.selectedJob then
            dxDrawRectangle(guiInfo.x, guiInfo.y + 50/zoom + 40/zoom * (i-1), 400/zoom, 40/zoom, tocolor(184, 153, 53, 200 * self.alpha))
        elseif self:isMouseInPosition(guiInfo.x, guiInfo.y + 50/zoom + 40/zoom * (i-1), 400/zoom, 40/zoom) then
            dxDrawRectangle(guiInfo.x, guiInfo.y + 50/zoom + 40/zoom * (i-1), 400/zoom, 40/zoom, tocolor(37, 37, 37, 255 * self.alpha))
        else
            dxDrawRectangle(guiInfo.x, guiInfo.y + 50/zoom + 40/zoom * (i-1), 400/zoom, 40/zoom, tocolor(27, 27, 27, 255 * self.alpha))
        end
        dxDrawText(v.name, guiInfo.x, guiInfo.y + 50/zoom + 40/zoom * (i-1), guiInfo.x + 400/zoom, guiInfo.y + 90/zoom + 40/zoom * (i-1), tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.list, "center", "center")
    end
end

function GovJobs:renderJobData()
    if not self.selectedData then return end

    local img = string.format("files/images/%s.png", self.selectedData.type)
    if fileExists(img) then
        dxDrawImage(guiInfo.x + (guiInfo.w - 128/zoom)/2, guiInfo.y + 50/zoom, 128/zoom, 128/zoom, img, 0, 0, 0, tocolor(255, 255, 255, 255 * self.alpha))
    end
    dxDrawText(self.selectedData.name, guiInfo.x + 50/zoom, guiInfo.y + 190/zoom, guiInfo.x + guiInfo.w - 50/zoom, guiInfo.y + 190/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.job, "center", "top")
    dxDrawText(string.format("Yer: %d/%d", self.selectedData.placesTaken, self.selectedData.placesAvaliable), guiInfo.x + 50/zoom, guiInfo.y + 220/zoom, guiInfo.x + guiInfo.w - 50/zoom, guiInfo.y + 190/zoom, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.list, "center", "top")

    dxDrawText("Bilgi:", guiInfo.x + 50/zoom, guiInfo.y + 255/zoom, guiInfo.x + guiInfo.w - 50/zoom, guiInfo.y + 190/zoom, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "top", false, false, false, true)
    dxDrawText(string.format("Konum: #cccccc%s", self.selectedData.place), guiInfo.x + 50/zoom, guiInfo.y + 280/zoom, guiInfo.x + guiInfo.w - 50/zoom, guiInfo.y + 190/zoom, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.list, "center", "top", false, false, false, true)
    dxDrawText(string.format("Ortalama kazanç: #cccccc$%s", tostring(self.selectedData.payment)), guiInfo.x + 50/zoom, guiInfo.y + 300/zoom, guiInfo.x + guiInfo.w - 50/zoom, guiInfo.y + 190/zoom, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.list, "center", "top", false, false, false, true)
    dxDrawText(string.format("Gereksinimler: #cccccc%s", self.selectedData.requirements or "Gereksinim yok"), guiInfo.x + 50/zoom, guiInfo.y + 320/zoom, guiInfo.x + guiInfo.w - 50/zoom, guiInfo.y + 190/zoom, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.list, "center", "top", false, false, false, true)
    dxDrawText(self.selectedData.description, guiInfo.x + 50/zoom, guiInfo.y + 345/zoom, guiInfo.x + guiInfo.w - 50/zoom, guiInfo.y + guiInfo.h - 110/zoom, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.about, "center", "top", true, true)
end


function GovJobs:buttonClick(...)
    if arg[1] == self.buttons.exit then
        if not self.selectedJob then
            self:close()
        else
            self:selectJob()
        end

    elseif arg[1] == self.buttons.accept and self.selectedData then
        if self.currentJob and self.currentJob ~= self.selectedData.ID then exports.TR_noti:create("Zaten bir yerde çalışıyor olduğunuz için bu iş için işe alınamazsınız.", "error") return end
        if self.selectedData.requirements then
            if string.find(self.selectedData.requirements, "kat. A") then
                if not self.licences["a"] then exports.TR_noti:create("Tüm şartları karşılamadığınız için bu işi alamıyorsunuz.", "error") return end

            elseif string.find(self.selectedData.requirements, "kat. B") then
                if not self.licences["b"] then exports.TR_noti:create("Tüm şartları karşılamadığınız için bu işi alamıyorsunuz.", "error") return end

            elseif string.find(self.selectedData.requirements, "kat. C") then
                if not self.licences["c"] then exports.TR_noti:create("Tüm şartları karşılamadığınız için bu işi alamıyorsunuz.", "error") return end

            elseif string.find(self.selectedData.requirements, "Havacılık Lisansı") then
                if not self.licences["fly"] then exports.TR_noti:create("Tüm şartları karşılamadığınız için bu işi alamıyorsunuz.", "error") return end

            end
        end

        triggerServerEvent("setPlayerGovJob", resourceRoot, self.selectedData.ID, self.currentJob ~= self.selectedData.ID)
        exports.TR_dx:setResponseEnabled(true)
    end
end

function GovJobs:mouseClick(...)
  if arg[1] == "left" and arg[2] == "down" then
    for i, v in pairs(self.jobs) do
        if self:isMouseInPosition(guiInfo.x, guiInfo.y + 50/zoom + 40/zoom * (i-1), 400/zoom, 40/zoom) and i ~= self.selectedJob then
            self:selectJob(i)
            break
        end
    end
  end
end


function GovJobs:selectJob(...)
    if not arg[1] then
        self.selectedJob = nil
        self.selectedData = nil

        exports.TR_dx:setButtonVisible(self.buttons.accept, false)
        exports.TR_dx:setButtonText(self.buttons.exit, "Kapat")
        return
    end

    self.selectedJob = arg[1]
    self.selectedData = self.jobs[self.selectedJob]

    exports.TR_dx:setButtonVisible(self.buttons.accept, true)

    if self.currentJob == self.selectedData.ID then
        exports.TR_dx:setButtonText(self.buttons.accept, "Yavaş")
    else
        exports.TR_dx:setButtonText(self.buttons.accept, "Bir işe gir")
    end
    exports.TR_dx:setButtonText(self.buttons.exit, "Geri")
end

function GovJobs:reponse(...)
  exports.TR_dx:setResponseEnabled(false)

  if arg[1] == "get" then
    if arg[2] > 0 then
        self.currentJob = self.selectedData.ID
        self:selectJob(self.selectedJob)
        self.selectedData.placesTaken = self.selectedData.placesTaken + 1
        exports.TR_noti:create("Başarıyla bir işe girdiniz.", "success")
    else
        exports.TR_noti:create("Tüm pozisyonlar zaten alınmış olduğundan iş bulmak mümkün olmadı.", "error")
    end


  elseif arg[1] == "release" then
    self.currentJob = false
    self:selectJob(self.selectedJob)
    self.selectedData.placesTaken = self.selectedData.placesTaken - 1
    exports.TR_noti:create("İşinizi başarıyla bıraktınız.", "success")
  end
end


function GovJobs:drawBackground(x, y, rx, ry, color, radius, post)
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

function GovJobs:isMouseInPosition(x, y, width, height)
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


function openGovJobSelect(...)
    if guiInfo.job then return end
    guiInfo.job = GovJobs:create(...)
end
addEvent("openGovJobSelect", true)
addEventHandler("openGovJobSelect", root, openGovJobSelect)

function govJobSelectResponse(...)
    if not guiInfo.job then return end
    guiInfo.job:reponse(...)
end
addEvent("govJobSelectResponse", true)
addEventHandler("govJobSelectResponse", root, govJobSelectResponse)