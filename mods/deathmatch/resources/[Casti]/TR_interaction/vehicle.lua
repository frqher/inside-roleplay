local sx, sy = guiGetScreenSize()

local dataInfo = {
	seatNames = {"tüm yolcular", "ön yolcu", "sol arka yolcu", "sağ arka yolcu"},
	seatTaxiNames = {"Ücret almayın", "Ücreti ön yolcu öder", "Ücreti sol arka yolcu öder", "Ücreti sağ arka yolcu öder"},

	blockedInteraction = {
		[512] = true,
		[449] = true,
	}
}

VehicleInteraction = {}
VehicleInteraction.__index = VehicleInteraction

function VehicleInteraction:create()
	local instance = {}
	setmetatable(instance, VehicleInteraction)
	if instance:constructor() then
		return instance
	end
	return false
end

function VehicleInteraction:constructor()
	setRadioChannel(0)

	self.alpha = 0
	self.scroll = 0
	self.popUpValue = 0
	self.VehicleInteractions = {}

	self.fonts = {}
	self.fonts.ultra = exports.TR_dx:getFont(18)
	self.fonts.big = exports.TR_dx:getFont(15)

	self.popUpSize = 10/zoom

	self.func = {}
	self.func.switcher = function(...) self:switch(...) end
	self.func.renderer = function(...) self:render(...) end
	self.func.scroller = function(...) self:scrollKey(...) end
	self.func.exitVeh = function(...) self:exit(...) end
	self.func.radio = function(...) self:blockRadio(...) end

	bindKey("lshift", "both", self.func.switcher)
	addEventHandler("onClientVehicleStartExit", root, self.func.exitVeh)
	addEventHandler("onClientPlayerRadioSwitch", root, self.func.radio)
	return true
end


function VehicleInteraction:open()
	if not exports.TR_dx:canOpenGUI() then return end
	if self.opened then return end
	self.opened = true

	local veh = getPedOccupiedVehicle(localPlayer)
	if not veh then return end

	if dataInfo.blockedInteraction[self:getModel(veh)] then return end

	self.animOpen = "opening"
	self.lastAlpha = self.alpha
	self.animTick = getTickCount()

	exports.TR_dx:setOpenGUI(true)

	self:setKeyBinded(true)
	self:getVehicleInteractions()
	if self.alpha > 0.9 then self:popUp() end

	if not self.renderHandler then
		addEventHandler("onClientRender", root, self.func.renderer)
		self.renderHandler = true
	end
end

function VehicleInteraction:close()
	if not self.opened then return end
	self.opened = nil

	self.animOpen = "closing"
	self.lastAlpha = self.alpha
	self.animTick = getTickCount()

	self:setKeyBinded(false)
	exports.TR_dx:setOpenGUI(false)
end

function VehicleInteraction:setKeyBinded(state)
	if state then
		bindKey("mouse_wheel_up", "both", self.func.scroller)
		bindKey("mouse_wheel_down", "both", self.func.scroller)
		bindKey("arrow_l", "both", self.func.scroller)
		bindKey("arrow_r", "both", self.func.scroller)
		bindKey("arrow_u", "both", self.func.scroller)
		bindKey("arrow_d", "both", self.func.scroller)
	else
		unbindKey("mouse_wheel_up", "both", self.func.scroller)
		unbindKey("mouse_wheel_down", "both", self.func.scroller)
		unbindKey("arrow_l", "both", self.func.scroller)
		unbindKey("arrow_r", "both", self.func.scroller)
		unbindKey("arrow_u", "both", self.func.scroller)
		unbindKey("arrow_d", "both", self.func.scroller)
	end
end


function VehicleInteraction:getType(veh)
	return getVehicleType(self:getModel(veh))
end

function VehicleInteraction:switch(...)
	local veh = getPedOccupiedVehicle(localPlayer)
	if not veh then return end
	if self:getType(veh) == "BMX" then return end
	if arg[2] == "down" then
		self:open()

	elseif arg[2] == "up" then
		self:use()
		self:close()
	end
end

function VehicleInteraction:scrollKey(...)
	if arg[2] == "up" then return end
	if arg[1] == "mouse_wheel_down" or arg[1] == "arrow_d" then
		local scroll = self.scroll
		self.scroll = math.min(self.scroll + 1, #self.VehicleInteractions)
		if scroll ~= self.scroll then self:popUp() end

	elseif arg[1] == "mouse_wheel_up" or arg[1] == "arrow_u" then
		local scroll = self.scroll
		self.scroll = math.max(self.scroll - 1, 1)
		if scroll ~= self.scroll then self:popUp() end

	elseif arg[1] == "arrow_r" then
		local veh = getPedOccupiedVehicle(localPlayer)
		if self.VehicleInteractions[self.scroll].action == 5 then
			if self:getType(veh) == "Bike" then return end
			local maxPassengers = getVehicleMaxPassengers(veh)
			self.VehicleInteractions[self.scroll].index = math.min(self.VehicleInteractions[self.scroll].index + 1, maxPassengers)
			local passengers = ""
			for i = 0, maxPassengers do
				passengers = passengers..(self.VehicleInteractions[self.scroll].index == i and "◉" or "○")
			end
			self.VehicleInteractions[self.scroll].text = string.format("Patladı %s", dataInfo.seatNames[self.VehicleInteractions[self.scroll].index + 1])
			self.VehicleInteractions[self.scroll].desc = string.format("%s", passengers)

		elseif self.VehicleInteractions[self.scroll].action == 8 then
			if self:getType(veh) == "Bike" then return end
			local suspensionHeight = getElementData(veh, "suspensionHeight") or 4
			local newHeight = math.max(suspensionHeight - 1, 1)
			setElementData(veh, "suspensionHeight", newHeight)

			local height = ""
			for i = 1, 7 do
				height = height..(newHeight == 8 - i and "◉" or "○")
			end
			self.VehicleInteractions[self.scroll].desc = height
			triggerServerEvent("interactionTrigger", resourceRoot, 8)

		elseif self.VehicleInteractions[self.scroll].action == 9 then
			local maxPassengers = getVehicleMaxPassengers(veh)
			local newTaxiPayer = math.min(self.VehicleInteractions[self.scroll].index + 1, maxPassengers)
			local plr = getVehicleOccupant(veh, newTaxiPayer)
			if newTaxiPayer == 0 then plr = nil end

			local payer = ""
			for i = 0, maxPassengers do
				payer = payer..(newTaxiPayer == i and "◉" or "○")
			end
			self.VehicleInteractions[self.scroll].index = newTaxiPayer
			self.VehicleInteractions[self.scroll].text = plr and string.format("Yolculuk buna değer %s", getPlayerName(plr)) or dataInfo.seatTaxiNames[newTaxiPayer + 1]
			self.VehicleInteractions[self.scroll].desc = payer
		end

	elseif arg[1] == "arrow_l" then
		local veh = getPedOccupiedVehicle(localPlayer)
		if self.VehicleInteractions[self.scroll].action == 5 then
			local maxPassengers = getVehicleMaxPassengers(veh)
			self.VehicleInteractions[self.scroll].index = math.max(self.VehicleInteractions[self.scroll].index - 1, 0)
			local passengers = ""
			for i = 0, maxPassengers do
				passengers = passengers..(self.VehicleInteractions[self.scroll].index == i and "◉" or "○")
			end
			self.VehicleInteractions[self.scroll].text = string.format("Wysadź %s", dataInfo.seatNames[self.VehicleInteractions[self.scroll].index + 1])
			self.VehicleInteractions[self.scroll].desc = string.format("%s", passengers)

		elseif self.VehicleInteractions[self.scroll].action == 8 then
			local suspensionHeight = getElementData(veh, "suspensionHeight") or 4
			local newHeight = math.min(suspensionHeight + 1, 7)
			setElementData(veh, "suspensionHeight", newHeight)

			local height = ""
			for i = 1, 7 do
				height = height..(newHeight == 8 - i and "◉" or "○")
			end
			self.VehicleInteractions[self.scroll].desc = height

			triggerServerEvent("interactionTrigger", resourceRoot, 8)

		elseif self.VehicleInteractions[self.scroll].action == 9 then
			local maxPassengers = getVehicleMaxPassengers(veh)
			local newTaxiPayer = math.max(self.VehicleInteractions[self.scroll].index - 1, 0)
			local plr = getVehicleOccupant(veh, newTaxiPayer)
			if newTaxiPayer == 0 then plr = nil end

			local payer = ""
			for i = 0, maxPassengers do
				payer = payer..(newTaxiPayer == i and "◉" or "○")
			end
			self.VehicleInteractions[self.scroll].index = newTaxiPayer
			self.VehicleInteractions[self.scroll].text = plr and string.format("Yolculuk buna değer %s", getPlayerName(plr)) or dataInfo.seatTaxiNames[newTaxiPayer + 1]
			self.VehicleInteractions[self.scroll].desc = payer
		end
	end
end

function VehicleInteraction:popUp()
	self.popUpAnim = "up"
	self.popUpTick = getTickCount()
	self.popUpValue = 0
end


function VehicleInteraction:animate()
	if self.animOpen == "opening" then
		local progress = (getTickCount() - self.animTick)/300
		self.alpha = interpolateBetween(self.lastAlpha, 0, 0, 1, 0, 0, progress, "OutQuad")
		if progress >= 1 then
			self.animOpen = "opened"
			self.animTick = nil
			self.alpha = 1
			self.lastAlpha = nil
		end

	elseif self.animOpen == "closing" then
		local progress = (getTickCount() - self.animTick)/300
		self.alpha = interpolateBetween(self.lastAlpha, 0, 0, 0, 0, 0, progress, "InOutQuad")
		if progress >= 1 then
			self.animOpen = nil
			self.animTick = nil
			self.alpha = 0
			self.lastAlpha = nil

			removeEventHandler("onClientRender", root, self.func.renderer)
			self.renderHandler = nil
		end
	end
	if self.popUpAnim == "up" then
		local progress = (getTickCount() - self.popUpTick)/100
		self.popUpValue = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "OutQuad")
		if progress >= 1 then
			self.popUpAnim = "down"
			self.popUpTick = getTickCount()
			self.popUpValue = 1
		end

	elseif self.popUpAnim == "down" then
		local progress = (getTickCount() - self.popUpTick)/100
		self.popUpValue = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "InOutQuad")
		if progress >= 1 then
			self.popUpAnim = nil
			self.popUpTick = nil
			self.popUpValue = 0
		end
	end
end

function VehicleInteraction:render()
	if not getPedOccupiedVehicle(localPlayer) then self:close() end
	self:animate()
	dxDrawRectangle(0, 0, sx, sy, tocolor(7, 7, 7, 220 * self.alpha))
	dxDrawImage(-400/zoom + 370/zoom * self.alpha, (sy - 64/zoom)/2, 64/zoom, 64/zoom, "files/images/vehicle/arrow.png", 0, 0, 0, tocolor(255, 255, 255, alpha))


	for i = -3, 3 do
		local x = -400/zoom + 440/zoom * self.alpha + (i == 0 and (5/zoom * self.popUpValue) or -20/zoom)
		local y = (sy - 64/zoom)/2 + 100/zoom * i
		local alpha = (255 - math.abs(i) * 80) * self.alpha

		if self.VehicleInteractions[self.scroll + i] then
			dxDrawImage(x, y, 64/zoom, 64/zoom, string.format("files/images/vehicle/%s.png", self.VehicleInteractions[self.scroll + i].icon), 0, 0, 0, tocolor(255, 255, 255, alpha))
			dxDrawText(self.VehicleInteractions[self.scroll + i].text, x + 80/zoom, y, (sx + 64/zoom)/2 + 64/zoom, y, tocolor(255, 255, 255, alpha), 1/zoom, self.fonts.ultra, "left", "top")
			dxDrawText(self.VehicleInteractions[self.scroll + i].desc or "", x + 80/zoom, y + 5/zoom, (sx + 64/zoom)/2 + 64/zoom, y + 64/zoom - 5/zoom, tocolor(120, 120, 120, alpha), 1/zoom, self.fonts.big, "left", "bottom")
		end
	end
end


function VehicleInteraction:getVehicleInteractions()
	self.VehicleInteractions = {}

	local veh = getPedOccupiedVehicle(localPlayer)
	if not veh then return end

	local seat = getPedOccupiedVehicleSeat(localPlayer)
	if seat == 0 then
		self:buildDriver(veh, seat)
	else
		self:buildPassenger(veh, seat)
	end

	self:setStart()
end

function VehicleInteraction:setStart()
	local center = math.floor(#self.VehicleInteractions/2) + 1
	table.insert(self.VehicleInteractions, center, {
		text = "İptal et",
		icon = "cancel",
		desc = "İptal",
		action = false,
	})
	self.scroll = center
end

function VehicleInteraction:use()
	if not self.opened then return end
	local veh = getPedOccupiedVehicle(localPlayer)
	if dataInfo.blockedInteraction[self:getModel(veh)] then return end

	local action = self.VehicleInteractions[self.scroll].action
	local sound = self.VehicleInteractions[self.scroll].sound

	if not action then return end
	if self.slowdown then
		if (getTickCount() - self.slowdown)/500 < 1 then return end
	end
	if not self:canUse(action, veh) then return end

	local soundUrl = sound and string.format("files/sounds/%s", sound) or nil

	self.slowdown = getTickCount()

	if action == "dashcam" then
		exports.TR_fractions:changeDashcam()
		return
	end

	if self.VehicleInteractions[self.scroll].action == 5 or self.VehicleInteractions[self.scroll].action == 9 then
		triggerServerEvent("interactionTrigger", resourceRoot, action, soundUrl, self.VehicleInteractions[self.scroll].index)
	else
		triggerServerEvent("interactionTrigger", resourceRoot, action, soundUrl)
	end
end

function VehicleInteraction:canUse(...)
	local vehType = self:getType(arg[2])
	if arg[1] == 4 then
		if vehType == "Boat" then
			if getElementSpeedValue(arg[2], "km/h") > 1 then
				exports.TR_noti:create("Yoldayken demir atamazsınız.", "error")
				return false
			end

		elseif vehType == "Bike" then
			if getElementSpeedValue(arg[2], "km/h") > 0.1 then
				exports.TR_noti:create("Sürüş sırasında baskı ayarlayamazsınız.", "error")
				return false
			end

		elseif getElementSpeedValue(arg[2], "km/h") > 0.1 then
			exports.TR_noti:create("Sürüş sırasında el frenini çekemezsiniz.", "error")
			return false

		else
			local hoses = getElementData(arg[2], "hoses") or {}
			if hoses then
				if self:getCount(hoses) >= 1 then
					exports.TR_noti:create("Birisi yangın hortumunu kullandığı için el cihazını kullanamazsınız..", "error")
					return false
				end
			end
		end
	end
	return true
end

function VehicleInteraction:exit(plr)
	if plr == localPlayer and getElementData(localPlayer, "belt") then
		setElementData(localPlayer, "belt", false)
		playSound("files/sounds/belt_unlock.wav")
	end
end

function VehicleInteraction:getModel(veh)
	return getElementData(veh, "oryginalModel") or getElementModel(veh)
end

function VehicleInteraction:buildDriver(veh, seat)
	local vehicleFraction = self:getVehicleFraction(veh)
	local model = self:getModel(veh)
	local performanceTuning = getElementData(veh, "performanceTuning")
	local visualTuning = getElementData(veh, "visualTuning")
	local isBike = self:getType(veh) == "Bike" or self:getType(veh) == "Quad"

	if isBike then
		if getVehicleOverrideLights(veh) ~= 2 then
			table.insert(self.VehicleInteractions, {
				text = "Światła",
				icon = "lights_off",
				sound = "lights.mp3",
				desc = "Zapal światła",
				action = 1
			})
		else
			table.insert(self.VehicleInteractions, {
				text = "Far",
				icon = "lights_on",
				sound = "lights.mp3",
				desc = "Işıkları söndür",
				action = 1
			})
		end

		if not getVehicleEngineState(veh) then
			table.insert(self.VehicleInteractions, {
				text = "Motor",
				icon = "engine",
				sound = "engineStart.wav",
				desc = "Motoru çalıştır",
				action = 2
			})
		else
			table.insert(self.VehicleInteractions, {
				text = "Motor",
				icon = "engine",
				desc = "Motoru durdur",
				action = 2
			})
		end

		if not isElementFrozen(veh) then
			table.insert(self.VehicleInteractions, {
				text = "Fren",
				icon = "brake",
				action = 4,
				desc = "Baskı ayağını indirin",
			})
		else
			table.insert(self.VehicleInteractions, {
				text = "Fren",
				icon = "brake",
				action = 4,
				desc = "Baskı ayağını kaldırın",
			})
		end

		table.insert(self.VehicleInteractions, {
			text = "Yolcuyu bırakın",
			icon = "remove",
			action = 5,
			index = 0,
		})

		return

	elseif self:getType(veh) == "Plane" or self:getType(veh) == "Helicopter" then
		if getVehicleOverrideLights(veh) ~= 2 then
			table.insert(self.VehicleInteractions, {
				text = "Far",
				icon = "lights_off",
				sound = "lights.mp3",
				desc = "Farları aç",
				action = 1
			})
		else
			table.insert(self.VehicleInteractions, {
				text = "Far",
				icon = "lights_on",
				sound = "lights.mp3",
				desc = "Farları kapat",
				action = 1
			})
		end

		if not getVehicleEngineState(veh) then
			table.insert(self.VehicleInteractions, {
				text = "Motor",
				icon = "engine",
				sound = "engineStart.wav",
				desc = "Motoru çalıştır",
				action = 2
			})
		else
			table.insert(self.VehicleInteractions, {
				text = "Motor",
				icon = "engine",
				desc = "Motoru durdur",
				action = 2
			})
		end

		if not isElementFrozen(veh) then
			table.insert(self.VehicleInteractions, {
				text = "Pervane",
				desc = "Durdur",
				icon = "propeller",
				action = 4
			})
		else
			table.insert(self.VehicleInteractions, {
				text = "Pervane",
				desc = "Çalıştır",
				icon = "propeller",
				action = 4
			})
		end
		return

	elseif self:getType(veh) == "Boat" then
		if not getVehicleEngineState(veh) then
			table.insert(self.VehicleInteractions, {
				text = "Motor",
				icon = "engine",
				sound = "engineStart.wav",
				desc = "Motoru çalıştır",
				action = 2
			})
		else
			table.insert(self.VehicleInteractions, {
				text = "Motor",
				icon = "engine",
				desc = "Motoru durdur",
				action = 2
			})
		end

		if not isElementFrozen(veh) then
			table.insert(self.VehicleInteractions, {
				text = "Çapa",
				desc = "Çapayı indir",
				icon = "anchor",
				action = 4
			})
		else
			table.insert(self.VehicleInteractions, {
				text = "Çapa",
				desc = "Çapayı kaldır",
				icon = "anchor",
				action = 4
			})
		end
		return
	end

	if getVehicleOverrideLights(veh) ~= 2 then
		table.insert(self.VehicleInteractions, {
			text = "Far",
			icon = "lights_off",
			sound = "lights.mp3",
			desc = "Farları aç",
			action = 1
		})
	else
		table.insert(self.VehicleInteractions, {
			text = "Far",
			icon = "lights_on",
			sound = "lights.mp3",
			desc = "Farları kapat",
			action = 1
		})
	end

	if not getVehicleEngineState(veh) then
		table.insert(self.VehicleInteractions, {
			text = "Motor",
			desc = "Motoru çalıştır",
			icon = "engine",
			sound = "engineStart.wav",
			action = 2
		})
	else
		table.insert(self.VehicleInteractions, {
			text = "Motor",
			desc = "Motoru durdur",
			icon = "engine",
			action = 2
		})
	end

	if not isElementFrozen(veh) then
		table.insert(self.VehicleInteractions, {
			text = "Fren",
			desc = isBike and "Ayaklığı indir" or "El frenini kaldır",
			sound = "handbrake_up.mp3",
			icon = "brake",
			action = 4
		})
	else
		table.insert(self.VehicleInteractions, {
			text = "Fren",
			desc = isBike and "Ayaklığı kaldır" or "El frenini indir",
			sound = "handbrake_down.mp3",
			icon = "brake",
			action = 4
		})
	end

	if getElementData(localPlayer, "belt") then
		table.insert(self.VehicleInteractions, {
			text = "Kemer",
			desc = "Emniyet kemerini aç",
			icon = "belt_locked",
			sound = "belt_unlock.wav",
			action = 3
		})
	else
		table.insert(self.VehicleInteractions, {
			text = "Kemer",
			desc = "Emniyet kemerini bağla",
			icon = "belt_unlocked",
			sound = "belt_lock.wav",
			action = 3
		})
	end

	if not withoutRoof[model] then
		if not isVehicleWindowOpen(veh, getSeatWindow(seat)) then
			table.insert(self.VehicleInteractions, {
				text = "Cam",
				desc = "Camı aç",
				icon = "window_closed",
				sound = "window_open.mp3",
				action = 6
			})
		else
			table.insert(self.VehicleInteractions, {
				text = "Cam",
				desc = "Camı kapat",
				icon = "window_open",
				sound = "window_close.mp3",
				action = 6
			})
		end
	end

	if model ~= 420 and model ~= 438 then
		if not isVehicleLocked(veh) then
			table.insert(self.VehicleInteractions, {
				text = "Kapı",
				desc = "Kilitle",
				icon = "unlocked",
				sound = "lock.mp3",
				action = 7
			})
		else
			table.insert(self.VehicleInteractions, {
				text = "Kapı",
				desc = "Kilidi aç",
				icon = "locked",
				sound = "lock.mp3",
				action = 7
			})
		end
	end

	local maxPassengers = getVehicleMaxPassengers(self:getModel(veh))
	local passengers = ""
	for i = 0, maxPassengers do
		passengers = passengers..(i == 0 and "◉" or "○")
	end
	table.insert(self.VehicleInteractions, {
		text = "Tüm yolcuları indir",
		icon = "remove",
		desc = passengers,
		action = 5,
		index = 0,
	})

	if performanceTuning then
		if performanceTuning.suspension == true then
			local suspensionHeight = getElementData(veh, "suspensionHeight") or 4

			local height = ""
			for i = 1, 7 do
				height = height..(suspensionHeight == 8 - i and "◉" or "○")
			end

			table.insert(self.VehicleInteractions, {
				text = "Süspansiyon ayarı",
				icon = "suspension",
				desc = height,
				action = 8
			})
		end
	end
	if visualTuning then
		if visualTuning.neon then
			if getElementData(veh, "neonEnabled") then
				table.insert(self.VehicleInteractions, {
					text = "Neon ışıkları",
					desc = "Neon ışıklarını kapat",
					icon = "neon",
					action = 10
				})
			else
				table.insert(self.VehicleInteractions, {
					text = "Neon ışıkları",
					desc = "Neon ışıklarını Aç",
					icon = "neon",
					action = 10
				})
			end
		end
	end

	if vehicleFraction == "police" then
		table.insert(self.VehicleInteractions, {
			text = "Ses kayıt cihazı",
			desc = "Hız ölçümü",
			icon = "dashcam",
			action = "dashcam"
		})
	end

	if model == 438 or model == 420 then
		local maxPassengers = getVehicleMaxPassengers(veh)
		local selected = getElementData(veh, "taxiPaySeat") or 0
		local plr = getVehicleOccupant(veh, selected)
		if selected == 0 then plr = nil end

		local passengers = ""
		for i = 0, maxPassengers do
			passengers = passengers..(i == selected and "◉" or "○")
		end
		table.insert(self.VehicleInteractions, {
			text = plr and string.format("Yolculuk buna değer %s", getPlayerName(plr)) or dataInfo.seatTaxiNames[selected + 1],
			icon = "taxi",
			desc = passengers,
			action = 9,
			index = selected,
		})
	end
end

function VehicleInteraction:buildPassenger(veh, seat)
	if self:getType(veh) == "Bike" or self:getType(veh) == "Plane" or self:getType(veh) == "Helicopter" then
		return
	end

	if getElementData(localPlayer, "belt") then
		table.insert(self.VehicleInteractions, {
			text = "Kemerler",
			desc = "Kemerlerinizi bağlayın",
			icon = "belt_locked",
			sound = "belt_unlock.wav",
			action = 3
		})
	else
		table.insert(self.VehicleInteractions, {
			text = "Kemerler",
			desc = "Emniyet kemerini bağla",
			icon = "belt_unlocked",
			sound = "belt_lock.wav",
			action = 3
		})
	end

	if not withoutRoof[model] then
		if not isVehicleWindowOpen(veh, getSeatWindow(seat)) then
			table.insert(self.VehicleInteractions, {
				text = "Bardak",
				desc = "Pencereyi aç",
				icon = "window_closed",
				sound = "window_open.mp3",
				action = 6
			})
		else
			table.insert(self.VehicleInteractions, {
				text = "Bardak",
				desc = "Pencereyi kapat",
				icon = "window_open",
				sound = "window_close.mp3",
				action = 6
			})
		end
	end
end

function VehicleInteraction:getCount(tb)
	local count = 0
	for i, v in pairs(tb) do
		if isElement(v) then
			count = count + 1
		else
			tb[i] = nil
		end
	end
	return count
end

-- Block radio
function VehicleInteraction:blockRadio()
	cancelEvent()
end

function VehicleInteraction:getVehicleFraction(veh)
	local vehicleFraction = getElementData(veh, "fractionID")
	local plrFraction = getElementData(localPlayer, "characterDuty")
	if vehicleFraction then
		if plrFraction then
			if vehicleFraction == plrFraction[4] then return plrFraction[3] end
		end
		return false
	end
	return false
end



VehicleInteraction:create()


-- Utils
local seatWindows = {[0] = 4, [1] = 2, [2] = 5, [3] = 3}

function getSeatWindow(seat)
	return seatWindows[seat]
end

function getElementSpeedValue(element, typ)
    typ = typ == nil and 0 or ((not tonumber(typ)) and typ or tonumber(typ))
    local mult = (typ == 0 or typ == "m/s") and 50 or ((typ == 1 or typ == "km/h") and 180 or 111.84681456)
    return (Vector3.create(getElementVelocity(element)) * mult).length
end

-- Synced functions
function setWindowsOpen(veh, seat)
	local window = getSeatWindow(seat)
	if window then
	 	setVehicleWindowOpen(veh, window, not isVehicleWindowOpen(veh, window))
 	end
end
addEvent("changeWindowState", true)
addEventHandler("changeWindowState", root, setWindowsOpen)

function removePlayerFromVehicle(index)
	local seat = getPedOccupiedVehicleSeat(localPlayer)
	if not seat then return end

	if index == 0 then
		setPedControlState(localPlayer, "enter_exit", true)
		setTimer(setPedControlState, 150, 1, "enter_exit", false)

	elseif seat == index then
		setPedControlState(localPlayer, "enter_exit", true)
		setTimer(setPedControlState, 150, 1, "enter_exit", false)
	end
end
addEvent("removePlayerFromVehicle", true)
addEventHandler("removePlayerFromVehicle", root, removePlayerFromVehicle)