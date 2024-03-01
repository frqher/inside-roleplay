local sx, sy = guiGetScreenSize()

local zoom = 1
local baseX = 1900
local minZoom = 2

if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
	x = 0,
	y = (sy-525/zoom)/2,
	w = 600/zoom,
	h = 525/zoom,

	fonts = {
		title = exports.TR_dx:getFont(14),
		categories = exports.TR_dx:getFont(12),
		info = exports.TR_dx:getFont(9),
	},

	visibleCount = 15,
}

exports.TR_dx:setOpenGUI(false)

Animations = {}
Animations.__index = Animations

function Animations:create()
	local instance = {}
	setmetatable(instance, Animations)
	if instance:constructor() then
		return instance
	end
	return false
end

function Animations:constructor()
	self.scroll = 0
	self.alpha = 0

	self.selectedCategory = categories[1]

	self.func = {}
	self.func.render = function() self:render() end
	self.func.switch = function() self:switch() end
	self.func.click = function(...) self:click(...) end
	self.func.scroller = function(...) self:scroller(...) end
	self.func.stopAnim = function(...) self:stopAnim(...) end

	bindKey("F2", "down", self.func.switch)
	self:loadFavourites()
	return true
end

function Animations:switch()
	if self.opened then
		self:close()
	else
		self:open()
	end
end

function Animations:open()
	if not getElementData(localPlayer, "characterUID") then return end
	if not exports.TR_dx:canOpenGUI() then return end
	if self.state then return end

	self.opened = true
	self.scroll = 0

    self.tick = getTickCount()
	self.state = "show"

	exports.TR_hud:setHudVisible(false)
    exports.TR_chat:showCustomChat(false)
	exports.TR_dx:setOpenGUI(true)

	showCursor(true)
	addEventHandler("onClientRender", root, self.func.render)
	addEventHandler("onClientClick", root, self.func.click)

	bindKey("mouse_wheel_up", "down", self.func.scroller)
	bindKey("mouse_wheel_down", "down", self.func.scroller)
end

function Animations:close()
	if self.state ~= "showed" then return end
	self.tick = getTickCount()
	self.state = "hide"

	self.opened = nil
	exports.TR_hud:setHudVisible(true)
	exports.TR_chat:showCustomChat(true)

	unbindKey("mouse_wheel_up", "down", self.func.scroller)
	unbindKey("mouse_wheel_down", "down", self.func.scroller)

	showCursor(false)
	removeEventHandler("onClientClick", root, self.func.click)
end


function Animations:animate()
    if self.state == "show" then
        local progress = (getTickCount() - self.tick)/600
        self.alpha = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "InOutQuad")

        if progress >= 1 then
            self.tick = getTickCount()
            self.alpha = 1
            self.state = "showed"
        end

    elseif self.state == "hide" then
        local progress = (getTickCount() - self.tick)/400
        self.alpha = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "InOutQuad")

        if progress >= 1 then
            self.tick = nil
            self.alpha = 0
            self.state = nil

			removeEventHandler("onClientRender", root, self.func.render)
			exports.TR_dx:setOpenGUI(false)
        end
    end
end

function Animations:render()
	self:animate()
	self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255 * self.alpha), 5)
	dxDrawText("Animasyonlar", guiInfo.x + 10/zoom, guiInfo.y + 10/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + 30/zoom, tocolor(212, 175, 55, 255 * self.alpha), 1/zoom, guiInfo.fonts.title, "center", "top")

	self:drawCategories()
	self:drawAnimations()
end

function Animations:drawCategories()
	local k = 0
	for _, i in pairs(categories) do
		if i == self.selectedCategory then
			dxDrawText(i, guiInfo.x + 10/zoom, guiInfo.y + 50/zoom + 30/zoom * k, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + 80/zoom + 30/zoom * k, tocolor(220, 220, 220, 255 * self.alpha), 1/zoom, guiInfo.fonts.categories, "left", "center")
		elseif self:isMouseInPosition(guiInfo.x, guiInfo.y + 50/zoom + 30/zoom * k, 200/zoom, 30/zoom) then
			dxDrawText(i, guiInfo.x + 10/zoom, guiInfo.y + 50/zoom + 30/zoom * k, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + 80/zoom + 30/zoom * k, tocolor(170, 170, 170, 220 * self.alpha), 1/zoom, guiInfo.fonts.categories, "left", "center")
		else
			dxDrawText(i, guiInfo.x + 10/zoom, guiInfo.y + 50/zoom + 30/zoom * k, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + 80/zoom + 30/zoom * k, tocolor(170, 170, 170, 180 * self.alpha), 1/zoom, guiInfo.fonts.categories, "left", "center")
		end
		k = k + 1
	end
end

function Animations:drawAnimations()
	local animBlock, anim = getPedAnimation(localPlayer)
	local walkingStyle = getPedWalkingStyle(localPlayer)

	if self.selectedCategory == "Yürüyüş stili" then
		for i = 0, (guiInfo.visibleCount - 1) do
			local animation = animations[self.selectedCategory][i + self.scroll + 1]

			if animation then
				local color, selected = self:getWalkingStyleColor(walkingStyle, animation)
				local alpha = 180
				if selected then alpha = 255
				elseif self:isMouseInPosition(guiInfo.x + 204/zoom, guiInfo.y + 50/zoom + 30/zoom * i, 390/zoom, 30/zoom) then alpha = 220 end
				dxDrawText(string.format("%s%s%s", color, selected and color == "#aaaaaa" and "c8c8c8" or color, animation[1]), guiInfo.x + 214/zoom, guiInfo.y + 50/zoom + 30/zoom * i, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + 80/zoom + 30/zoom * i, tocolor(170, 170, 170, alpha * self.alpha), 1/zoom, guiInfo.fonts.categories, "left", "center", false, false, false, true)
			end
		end
	else
		for i = 0, (guiInfo.visibleCount - 1) do
			local animation = animations[self.selectedCategory][i + self.scroll + 1]

			if animation then
				local color, selected = self:getAnimColor(animation, animBlock, anim)
				local alpha = 180
				if selected then alpha = 255
				elseif self:isMouseInPosition(guiInfo.x + 204/zoom, guiInfo.y + 50/zoom + 30/zoom * i, 390/zoom, 30/zoom) then alpha = 220 end
				dxDrawText(string.format("%s%s%s", color, selected and color == "#aaaaaa" and "c8c8c8" or color, animation[1]), guiInfo.x + 214/zoom, guiInfo.y + 50/zoom + 30/zoom * i, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + 80/zoom + 30/zoom * i, tocolor(170, 170, 170, alpha * self.alpha), 1/zoom, guiInfo.fonts.categories, "left", "center", false, false, false, true)
			end
		end
	end

	if #animations[self.selectedCategory] > guiInfo.visibleCount - 1 then
        local b1 = 445/zoom / #animations[self.selectedCategory]
        local barY = b1 * self.scroll
        local barHeight = b1 * guiInfo.visibleCount
        dxDrawRectangle(guiInfo.x + 200/zoom, guiInfo.y + 50/zoom, 3/zoom, 445/zoom, tocolor(37, 37, 37, 255 * self.alpha))
        dxDrawRectangle(guiInfo.x + 200/zoom, guiInfo.y + 50/zoom + barY, 3/zoom, barHeight, tocolor(57, 57, 57, 255 * self.alpha))
    else
        dxDrawRectangle(guiInfo.x + 200/zoom, guiInfo.y + 50/zoom, 3/zoom, 445/zoom, tocolor(57, 57, 57, 255 * self.alpha))
    end
	dxDrawText("Bir animasyonu favorilerinize eklemek veya favorilerinizden kaldırmak için adına sağ tıklayın.", guiInfo.x, guiInfo.y + guiInfo.h - 30/zoom, guiInfo.x + guiInfo.w, guiInfo.y + guiInfo.h, tocolor(170, 170, 170, 150 * self.alpha), 1/zoom, guiInfo.fonts.info, "center", "center")
end



function Animations:click(...)
	if arg[1] == "left" and arg[2] == "down" then
		local k = 0
		for _, i in pairs(categories) do
			if self:isMouseInPosition(guiInfo.x, guiInfo.y + 50/zoom + 30/zoom * k, 200/zoom, 30/zoom) then
				self.selectedCategory = i
				self.scroll = 0
				break
			end
			k = k + 1
		end

		for i = 0, guiInfo.visibleCount do
			local animation = animations[self.selectedCategory][i + self.scroll + 1]
			if animation then
				local alpha = 180
				if self:isMouseInPosition(guiInfo.x + 204/zoom, guiInfo.y + 50/zoom + 30/zoom * i, 390/zoom, 30/zoom) then
					self:startAnim(animation)
					break
				end
			end
		end

	elseif arg[1] == "right" and arg[2] == "down" then
		for i = 0, guiInfo.visibleCount do
			local animation = animations[self.selectedCategory][i + self.scroll + 1]
			if animation then
				local alpha = 180
				if self:isMouseInPosition(guiInfo.x + 204/zoom, guiInfo.y + 50/zoom + 30/zoom * i, 390/zoom, 30/zoom) then
					if self.selectedCategory == "Ulubione" then
						self:removeFromFavourite(animation)
					else
						self:addToFavourite(animation, false, true)
					end
					break
				end
			end
		end
	end
end


function Animations:addToFavourite(animation, forceWalk, save)
	for i, v in pairs(animations["Ulubione"]) do
		if v[1] == animation[1] then return end
	end

	table.insert(animations["Ulubione"], animation)
	if self.selectedCategory == "Yürüyüş stili" or forceWalk then
		animations["Ulubione"][#animations["Ulubione"]].isWalkingStyle = true
	end

	if save then
		self:saveFavourites()
		exports.TR_noti:create("Animasyon favorilerden eklendi.", "info")
	end
end

function Animations:removeFromFavourite(animation)
	for i, v in pairs(animations["Ulubione"]) do
		if v[1] == animation[1] then
			table.remove(animations["Ulubione"], i)
			break
		end
	end
	self:saveFavourites()

	exports.TR_noti:create("Animasyon favorilerden kaldırıldı.", "info")
end

function Animations:saveFavourites()
	if fileExists("favourites.xml") then fileDelete("favourites.xml") end
    local xml = xmlCreateFile("favourites.xml", "favourites")
	if not xml then return end

	for i, v in pairs(animations["Ulubione"]) do
		local node = xmlCreateChild(xml, "animation")
		xmlNodeSetValue(node, v[1])
	end
	xmlSaveFile(xml)
	xmlUnloadFile(xml)
end

function Animations:loadFavourites()
	local xml = xmlLoadFile("favourites.xml")
	if not xml then
		self:createXml()
		return
	end

	local saved = {}
	for i, v in pairs(xmlNodeGetChildren(xml)) do
		local name = xmlNodeGetValue(v)
		saved[name] = true
	end

	for anim, _ in pairs(animations) do
		for i, v in pairs(animations[anim]) do
			if saved[v[1]] then
				self:addToFavourite(v, anim == "Yürüyüş stili")
			end
		end
	end
end

function Animations:createXml()
	local xml = xmlCreateFile("favourites.xml", "favourites")
	xmlSaveFile(xml)
	xmlUnloadFile(xml)

	self:loadFavourites()
end

function Animations:startAnim(animation)
	if not self:canUseAnimation(animation) then return end

	if self.selectedCategory == "Yürüyüş stili" or animation.isWalkingStyle then
		local style = getPedWalkingStyle(localPlayer)
		if style == animation[2] then return end

		triggerServerEvent("syncWalkingStyle", resourceRoot, animation[2])
		exports.TR_noti:create("Yürüyüş stili został zmieniony.", "animate")
		return
	else
		triggerServerEvent("syncAnim", resourceRoot, animation[2], animation[3])
	end

	if not self.canStop then
		self.canStop = true
		bindKey("enter", "down", self.func.stopAnim)
	end
	exports.TR_noti:create("Animasyonu durdurmak için ENTER tuşuna basın.", "animate")
end

function Animations:stopAnim()
	self.canStop = nil
	unbindKey("enter", "down", self.func.stopAnim)
	setElementData(localPlayer, "animation", nil)
	triggerServerEvent("syncAnim", resourceRoot, nil, nil)
end

function Animations:getAnimColor(data, animBlock, anim)
	if animBlock and anim then
		animBlock, anim = string.lower(animBlock), string.lower(anim)
	end
	local selected = string.lower(data[2]) == animBlock and string.lower(data[3]) == anim

	if data.type == "gold" then return "#d6a306", selected end
	if data.type == "diamond" then return "#2cb5e5", selected end
	return selected and "#c8c8c8" or "#aaaaaa", selected
end

function Animations:getWalkingStyleColor(walkingStyle, data)
	local selected = walkingStyle == data[2]

	if data.type == "gold" then return "#d6a306", selected end
	if data.type == "diamond" then return "#2cb5e5", selected end
	return selected and "#c8c8c8" or "#aaaaaa", selected
end

function Animations:canUseAnimation(animation)
	if getElementData(localPlayer, "blockAction") then return false end
	if getElementData(localPlayer, "tazer") then return false end
	if getElementData(localPlayer, "cuffedBy") then return false end
	if getElementData(localPlayer, "cuffed") then return false end
	if getElementData(localPlayer, "blockAnim") then exports.TR_noti:create("Şu anda animasyonu değiştiremezsiniz.", "error") return false end
	if isElementInWater(localPlayer) then exports.TR_noti:create("Animasyonu suda kullanamazsınız.", "error") return false end

	if self.animDelay then
		if (getTickCount() - self.animDelay)/5000 < 1 then
			exports.TR_noti:create("Animasyonu tekrar değiştirmeden önce 3 saniye beklemelisiniz.", "error")
			return false
		end
	end

	local animBlock, anim = getPedAnimation(localPlayer)
	if animBlock and anim then
		animBlock, anim = string.lower(animBlock), string.lower(anim)
	end
	if string.lower(animation[2]) == animBlock and string.lower(animation[3]) == anim then return false end

	local plrData = getElementData(localPlayer, "characterData")

	if animation.type then
		if animation.type == "gold" then
			if plrData.premium ~= "gold" and plrData.premium ~= "diamond" then
				exports.TR_noti:create("Bu animasyon yalnızca aktif Altın veya Elmas statüsündeki oyunculara açıktır..", "error")
				return false
			end

		elseif animation.type == "diamond" then
			if plrData.premium ~= "diamond" then
				exports.TR_noti:create("Bu animasyon yalnızca aktif Elmas statüsüne sahip oyunculara açıktır.", "error")
				return false
			end
		end
	end

	if getPedOccupiedVehicle(localPlayer) and self.selectedCategory ~= "Samochód" then
		exports.TR_noti:create("Bu animasyonu araçta kullanamazsınız.", "error")
		return false

	elseif self.selectedCategory == "Samochód" and not getPedOccupiedVehicle(localPlayer) then
		exports.TR_noti:create("Bu animasyonu yalnızca bir araçta kullanabilirsiniz.", "error")
		return false
	end

	self.animDelay = getTickCount()
	return true
end

function Animations:scroller(...)
	if arg[1] == "mouse_wheel_up" then
		if self.scroll == 0 then return end
		self.scroll = self.scroll - 1

	elseif arg[1] == "mouse_wheel_down" then
		if self.scroll + guiInfo.visibleCount >= #animations[self.selectedCategory] then return end
		self.scroll = self.scroll + 1
	end
end

function Animations:drawBackground(x, y, w, h, color, radius, post)
	dxDrawRectangle(x, y, w - radius, h, color, post)
	dxDrawRectangle(x + w - radius, y + radius, radius, h - radius * 2, color, post)
	dxDrawCircle(x + w - radius, y + radius, radius, 270, 360, color, color, 7, 1, post)
	dxDrawCircle(x + w - radius, y + h - radius, radius, 0, 90, color, color, 7, 1, post)
end

function Animations:isMouseInPosition(x, y, width, height)
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

Animations:create()
setPedWalkingStyle(localPlayer, 54)