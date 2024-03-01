local settings = {
	js = [[
		let inputElement = document.createElement('input');
		let inputBack = document.createElement('input');
		let capsOn = false;

		document.body.appendChild(inputElement);
		document.body.appendChild(inputBack);
		inputElement.focus();
		inputElement.onpaste = function() {
			inputElement.value = '';
			setTimeout(function() {
				mta.triggerEvent('returnClipBoardValue', inputElement.value);
			}, 10);
		};

		inputElement.addEventListener('keyup', checkCapsLock);
		inputElement.addEventListener('blur', blockTab);
		inputElement.addEventListener('mousedown', checkCapsLock);
		function checkCapsLock(e) {
			if(e.getModifierState('CapsLock')) {
				setTimeout(function() {
					mta.triggerEvent('returnCapsStatus', true);
				}, 10);
			} else {
				setTimeout(function() {
					mta.triggerEvent('returnCapsStatus', false);
				}, 10);
			}
		}
		function blockTab(e) {
			setTimeout(function() {
				inputElement.focus();
			}, 10);
		}
	]],
}

PasteSystem = {}
PasteSystem.__index = PasteSystem

function PasteSystem:create()
	local instance = {}
	setmetatable(instance, PasteSystem)
	if instance:constructor() then
		return instance
	end
	return false
end

function PasteSystem:constructor()

	self.func = {}
	self.func.onRestore = function() self:onRestore() end
	self.func.onBrowserReady = function() self:onBrowserReady() end
	self.func.onBrowserCreate = function() self:onBrowserCreate() end
	self.func.returnCapsStatus = function(...) self:returnCapsStatus(...) end
	self.func.returnClipBoardValue = function(...) self:returnClipBoardValue(...) end

	self:createBrowser()
	addEventHandler("onClientRestore", root, self.func.onRestore)
	return true
end


function PasteSystem:createBrowser()
	self.browser = createBrowser(1, 1, true, false)

	addEventHandler("onClientBrowserCreated", self.browser, self.func.onBrowserCreate)
	addEventHandler("onClientBrowserDocumentReady", self.browser, self.func.onBrowserReady)
end

function PasteSystem:onBrowserCreate()
	loadBrowserURL(self.browser, 'http://mta/nothing')
	focusBrowser(self.browser)
end

function PasteSystem:onBrowserReady()
	executeBrowserJavascript(self.browser, settings.js);

	addEvent('returnClipBoardValue', false);
	addEventHandler('returnClipBoardValue', self.browser, self.func.returnClipBoardValue)

	addEvent('returnCapsStatus', false);
	addEventHandler('returnCapsStatus', self.browser, self.func.returnCapsStatus)
end

function PasteSystem:returnClipBoardValue(data)
	triggerEvent('returnClipBoard', resourceRoot, data);
end

function PasteSystem:returnCapsStatus(state)
	guiData.capsOn = tonumber(state) == 1 and true or false
end

function PasteSystem:onRestore()
	focusBrowser(self.browser)
end


PasteSystem:create()