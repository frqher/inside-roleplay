local sx, sy = guiGetScreenSize()
local guiInfo = {
    x = sx - 300/zoom,
    y = (sy - 100/zoom)/2,
    w = 300/zoom,
    h = 100/zoom,
}

Info = {}
Info.__index = Info

function Info:create(...)
    local instance = {}
    setmetatable(instance, Info)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function Info:constructor(...)
    self.alpha = 0
    self.jobStart = getTickCount()
    self.addHeight = 0
    self.totalTime = 0

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(13)
    self.fonts.info = exports.TR_dx:getFont(11)
    self.fonts.infoText = exports.TR_dx:getFont(9)
    self.fontHeight = dxGetFontHeight(1/zoom, self.fonts.info)

    self.func = {}
    self.func.render = function() self:render() end

    self:setMoneyToPay()
    self:setInfo(...)
    self:open()
    return true
end

function Info:setMoneyToPay()
    local _, _, money = getPlayerJob()
    if not money then return false end
    self.jobStartPay = getTickCount()
    self.jobMoneyPay = money
    self.jobPayCount = 0
end

function Info:open()
    self.state = "opening"
    self.tick = getTickCount()

    addEventHandler("onClientRender", root, self.func.render)
end

function Info:hide()
    self.state = "hidding"
    self.tick = getTickCount()
end

function Info:close()
    self.state = "closing"
    self.tick = getTickCount()
end

function Info:destroy()
    removeEventHandler("onClientRender", root, self.func.render)
    guiInfo.info = nil
    self = nil
end


function Info:setInfo(...)
    self.jobName = arg[1] and arg[1] or self.jobName
    self.jobInfo = arg[2] and arg[2] or self.jobInfo
    self.addHeight = arg[3] and arg[3] or 0

    self:calculateSize()

    if self.state == "hidding" or self.state == "hidden" then
        self.state = "opening"
        self.tick = getTickCount()
    end
end

function Info:calculateSize()
    local height = self:calculateRows(self.jobInfo, self.fonts.info, 1/zoom, guiInfo.w - 28/zoom)
    guiInfo.h = height * self.fontHeight + 50/zoom + self.addHeight
    guiInfo.y = (sy - guiInfo.h)/2
end


function Info:animate()
    if not self.tick then return end
    local progress = (getTickCount() - self.tick)/500
    if self.state == "opening" then
      self.alpha = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "Linear")
      if progress >= 1 then
        self.alpha = 1
        self.state = "opened"
        self.tick = nil
      end

    elseif self.state == "hidding" then
      self.alpha = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "Linear")
      if progress >= 1 then
        self.alpha = 0
        self.state = "hidden"
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

function Info:render()
    self:animate()
    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 5)
    dxDrawText(self.jobName, guiInfo.x + 10/zoom, guiInfo.y, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + 25/zoom, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, self.fonts.main, "center", "center")
    dxDrawText(self.jobInfo, guiInfo.x + 10/zoom, guiInfo.y + 25/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h, tocolor(170, 170, 170, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "top", true, true)
    dxDrawText("Çalışma Süresi: " .. self:getTimeInSeconds(self.totalTime), guiInfo.x + 10/zoom, guiInfo.y + 25/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h - 2/zoom, tocolor(120, 120, 120, 255 * self.alpha), 1/zoom, self.fonts.info, "center", "bottom")


    self:checkTime()
    self:checkDistance()
    self:renderTarget()
end

function Info:renderTarget()
    local pos, int, dim, text = getPlayerTargetPos()
    if not pos then return end
    if int ~= getElementInterior(localPlayer) or dim ~= getElementDimension(localPlayer) then return end

    local plrPos = Vector3(getElementPosition(localPlayer))
    local screenX, screenY = getScreenFromWorldPosition(pos)
    if screenX and screenY then
        local distance = getDistanceBetweenPoints3D(pos, plrPos)
        local scale = 1 - math.min(distance/100, 0.5)

        dxDrawImage(screenX - 16/zoom * scale, screenY - 16/zoom * scale, 32/zoom * scale, 32/zoom * scale, "files/images/target.png", 0, 0, 0, tocolor(255, 60, 60, 255))
        dxDrawText(string.format("%dm", distance), screenX - 16/zoom * scale, screenY + 16/zoom * scale, screenX + 16/zoom * scale, screenY + 16/zoom * scale, tocolor(255, 255, 255, 255), 1/zoom * scale, self.fonts.info, "center", "top")
        if text then
            dxDrawText(text, screenX - 80/zoom * scale, screenY + 35/zoom * scale, screenX + 80/zoom * scale, screenY + 16/zoom * scale, tocolor(255, 255, 255, 255), 1/zoom * scale, self.fonts.infoText, "center", "top", false, true)
        end
    end
end

function Info:checkTime()
    if getElementData(localPlayer, "afk") then return end

    if (getTickCount() - self.jobStart)/1000 >= 1 then
        self.totalTime = self.totalTime + 1
        if self.paymentTime then
            self.paymentTime = self.paymentTime + 1
        end

        self.jobStart = getTickCount()
    end

    if self.jobStartPay then
        if (getTickCount() - self.jobStartPay)/1000 > 1 then
            self.jobStartPay = getTickCount()
            self.jobPayCount = self.jobPayCount + 1
        end

        if self.jobPayCount >= 600 then
            local multiplayer = 1

            local time = getRealTime()
            if time.month == 1 and time.monthday == 14 and time.hour >= 11 and time.hour < 14 then
                multiplayer = 2
            end

            triggerServerEvent("giveJobPayment", resourceRoot, (self.jobMoneyPay/6) * multiplayer, true)
            self.jobPayCount = 0
        end
    end
end

function Info:getTimeInSeconds(seconds)
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

function Info:checkDistance()
    if self.state ~= "opened" then return end

    local distance = getPlayerJobDistance()
    if not distance then return end

    if getDistanceBetweenPoints2D(Vector2(getElementPosition(localPlayer)), distance.markerPos) > distance.limit then
        exports.TR_noti:create("İş, çok uzaklaştığınız için sona erdirildi.", "info")
        setPlayerJob(nil)
        triggerServerEvent("endJob", resourceRoot)
        self:close()
    end
end

function Info:drawBackground(x, y, w, h, color, radius, post)
    dxDrawRectangle(x, y - radius, w, h + radius * 2, color, post)
    dxDrawRectangle(x - radius, y, radius, h, color, post)
    dxDrawCircle(x, y, radius, 180, 270, color, color, 7, 1, post)
    dxDrawCircle(x, y + h, radius, 90, 180, color, color, 7, 1, post)
end

function Info:setPaymentTime()
    self.paymentTime = self.paymentTime or 0
end

function Info:resetPaymentTime()
    self.paymentTime = nil
end

function Info:getPaymentCount(min, max)
    local payment = math.ceil((math.random(min, max) * (self.paymentTime/3600))*100)/100
    self.paymentTime = nil
    return payment
end

function Info:getTextPosition()
    local rows = self:calculateRows(self.jobInfo, self.fonts.info, 1/zoom, guiInfo.w - 28/zoom)
    return guiInfo.y + rows * self.fontHeight + 30/zoom
end

function Info:calculateRows(text, font, scale, maxwidth)
    local lines = {}
    local words = split(text, " ")
    local line = 1
    local word = 1
    local endlinecolor
    while (words[word]) do
        repeat
            if colorcoded and (not lines[line]) and endlinecolor and (not string.find(words[word], "^#%x%x%x%x%x%x")) then
                lines[line] = endlinecolor
            end
            lines[line] = lines[line] or ""

            if colorcoded then
                local rw = string.reverse(words[word])
                local x, y = string.find(rw, "%x%x%x%x%x%x#")
                if x and y then
                    endlinecolor = string.reverse(string.sub(rw, x, y))
                end
            end

            lines[line] = lines[line]..words[word]
            lines[line] = lines[line] .. " "

            word = word + 1

        until ((not words[word]) or dxGetTextWidth(lines[line].." "..words[word], scale, font, colorcoded) > maxwidth or string.find(lines[line], "\n"))

        lines[line] = string.sub(lines[line], 1, -2)
        if colorcoded then
            lines[line] = string.gsub(lines[line], "#%x%x%x%x%x%x$", "")
        end
        line = line + 1
    end
    return #lines
end



function createInformation(...)
    if not guiInfo.info then
        guiInfo.info = Info:create(...)
        return guiInfo.info:getTextPosition()
    end
    guiInfo.info:setInfo(...)
    return guiInfo.info:getTextPosition()
end

function hideInformation(...)
    if not guiInfo.info then return end
    guiInfo.info:hide(...)
end

function removeInformation(...)
    if not guiInfo.info then return end
    guiInfo.info:close(...)
end

function setPaymentTime()
    if not guiInfo.info then return end
    guiInfo.info:setPaymentTime()
end

function resetPaymentTime()
    if not guiInfo.info then return end
    guiInfo.info:resetPaymentTime()
end

function getPaymentCount(...)
    if not guiInfo.info then return 0 end
    return guiInfo.info:getPaymentCount(...)
end