screenX, screenY = guiGetScreenSize()

function reMap(x, in_min, in_max, out_min, out_max)
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

local text = ""
local font = exports["TR_dx"]:getFont(32)
local responsiveMultipler = reMap(screenX, 1024, 1920, 0.75, 1)

function resp(num, ceil)
    return math.ceil(num * responsiveMultipler)
end

 function onClientElementDataChangeOX(key, oldValue, newValue)
    if key == "text" then
    	text = newValue
    end
end

local function onClientRenderOX()
	if text and text:len() > 0 then
		local text = split(text, "\n")
		if type(text) == "table" and text[1] and text[2] then
			dxDrawText(text[1], 0, 0, screenX, screenY*0.25, nil, 1.0, font, "center", "center", false, false, false, true)
			dxDrawText("\n\n"..text[2], 0, 0, screenX, screenY*0.25, nil, 0.75, font, "center", "center", false, false, false, true)
		else
			dxDrawText(type(text) == "table" and text[1] or text, 0, 0, screenX, screenY*0.25, nil, 1.0, font, "center", "center", false, false, false, true)
		end
	end
end


function onClientPlayerJoinEvent(eventName)
	if eventName == "OX" then
		addEventHandler( "onClientElementDataChange", getElementByID("Counter (OX)"), onClientElementDataChangeOX)
		addEventHandler( "onClientRender", root, onClientRenderOX)
	end
end
addEvent("onClientPlayerJoinEvent", true)
addEventHandler("onClientPlayerJoinEvent", root, onClientPlayerJoinEvent)

function onClientPlayerQuitEventOX(eventName)
	if eventName == "OX" then
		removeEventHandler( "onClientElementDataChange", getElementByID("Counter (OX)"), onClientElementDataChangeOX)
		removeEventHandler( "onClientRender", root, onClientRenderOX)
	end
end
addEvent("onClientPlayerQuitEvent", true)
addEventHandler("onClientPlayerQuitEvent", root, onClientPlayerQuitEventOX)





local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
	zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
	x = (sx - 500/zoom)/2,
	y = (sy - 180/zoom)/2,
	w = 500/zoom,
	h = 180/zoom,

	fonts = {
		main = exports.TR_dx:getFont(14),
	},
}

local panel = false
function setAdminOXQuestion()
	if guiInfo.panel then return end
	guiInfo.panel = true

	showCursor(true)
	guiInfo.edit = exports.TR_dx:createEdit((sx - 440/zoom)/2, guiInfo.y + 60/zoom, 440/zoom, 40/zoom, "Wpisz pytanie")
	guiInfo.btn_false = exports.TR_dx:createButton(guiInfo.x + 30/zoom, guiInfo.y + guiInfo.h - 60/zoom, 200/zoom, 40/zoom, "Odpowiedź: Nie", "red")
	guiInfo.btn_true = exports.TR_dx:createButton(guiInfo.x + guiInfo.w - 230/zoom, guiInfo.y + guiInfo.h - 60/zoom, 200/zoom, 40/zoom, "Odpowiedź: Tak", "green")

	addEventHandler("onClientRender", root, renderAdminOX)
	addEventHandler("guiButtonClick", root, adminAcceptQuestion)
end
addEvent("setAdminOXQuestion", true)
addEventHandler("setAdminOXQuestion", root, setAdminOXQuestion)

function adminAcceptQuestion(btn)
	local question = guiGetText(guiInfo.edit)
	if string.len(question) < 10 then exports.TR_noti:create("Soru 10'dan fazla karakter içermelidir.", "error") return end

	if btn == guiInfo.btn_true then
		triggerServerEvent("OX:setQuestion", resourceRoot, question, true)

	elseif btn == guiInfo.btn_false then
		triggerServerEvent("OX:setQuestion", resourceRoot, question, false)
	end

	guiInfo.panel = nil
	showCursor(false)

	exports.TR_dx:destroyEdit(guiInfo.edit)
	exports.TR_dx:destroyButton({guiInfo.btn_false, guiInfo.btn_true})

	removeEventHandler("onClientRender", root, renderAdminOX)
	removeEventHandler("guiButtonClick", root, adminAcceptQuestion)
end

function renderAdminOX()
	drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255), 4)
	dxDrawText("Bir etkinlik sorusu girin", guiInfo.x, guiInfo.y, guiInfo.x + guiInfo.w, guiInfo.y + 50/zoom, tocolor(240, 196, 55, 255), 1/zoom, guiInfo.fonts.main, "center", "center")
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