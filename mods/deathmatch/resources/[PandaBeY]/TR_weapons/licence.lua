local sx, sy = guiGetScreenSize()
local zoom = 1
local baseX = 1900
local minZoom = 2
if sx < baseX then
  zoom = math.min(minZoom, baseX/sx)
end

local guiInfo = {
    x = (sx - 450/zoom)/2,
    y = sy - 100/zoom,
    w = 450/zoom,
    h = 100/zoom,

    pos = Vector3(300.39471435547, -135.57006835938, 1004.0625),
    moveSpeed = 10000,

    theoryPrice = 5000,
    practicePrice = 15000,

    weapons = {
        {
            weapon = 22,
            ammo = 40,
            weaponSlot = 2,
        },
        {
            weapon = 30,
            ammo = 60,
            weaponSlot = 5,
        },
        {
            weapon = 33,
            ammo = 50,
            weaponSlot = 6,
        },
    },

    targets = {
        [1] = {
            Vector3(293.1291809082, -135.56494140625, 1004.0625),
            Vector3(295.09194946289, -134.56364440918, 1004.0625),
            Vector3(293.02841186523, -136.83145141602, 1004.0625),
            Vector3(296.02841186523, -135.83145141602, 1004.0625),
            Vector3(294.02841186523, -132.83145141602, 1004.0625),
        },
        [2] = {
            Vector3(290.1291809082, -133.56494140625, 1004.0625),
            Vector3(289.09194946289, -136.56364440918, 1004.0625),
            Vector3(288.02841186523, -138.83145141602, 1004.0625),
            Vector3(282.1291809082, -130.56494140625, 1004.0625),
            Vector3(284.09194946289, -129.56364440918, 1004.0625),
            Vector3(288.42841186523, -134.83145141602, 1004.0625),
        },
        [3] = {
            Vector3(276.09194946289, -140.56364440918, 1004.0625),
            Vector3(275.02841186523, -135.83145141602, 1004.0625),
            Vector3(274.1291809082, -132.56494140625, 1004.0625),
            Vector3(273.09194946289, -139.56364440918, 1004.0625),
            Vector3(273.52841186523, -130.83145141602, 1004.0625),
            Vector3(274.52841186523, -136.83145141602, 1004.0625),
            Vector3(275.52841186523, -137.83145141602, 1004.0625),
        },
    },
}

Licence = {}
Licence.__index = Licence

function Licence:create()
    local instance = {}
    setmetatable(instance, Licence)
    if instance:constructor() then
        return instance
    end
    return false
end

function Licence:constructor()
    self.stage = 1

    self.pos = Vector3(getElementPosition(localPlayer))
    self.int = getElementInterior(localPlayer)
    self.dim = getElementDimension(localPlayer)

    self.targets = {}

    self.fonts = {}
    self.fonts.main = exports.TR_dx:getFont(13)
    self.fonts.info = exports.TR_dx:getFont(11)

    self.func = {}
    self.func.open = function() self:open() end
    self.func.render = function() self:render() end
    self.func.destroy = function() self:destroy() end
    self.func.checkShoot = function(...) self:checkShoot(...) end

    self.targetImg = dxCreateTexture("files/images/target.png", "argb", true, "clamp")

    setTimer(self.func.open, 1000, 1)
    exports.TR_dx:setOpenGUI(true)
    exports.TR_dx:showLoading(5000, "Atış poligonu yükleniyor")
    self:createTargets()
    return true
end

function Licence:createTargets()
    self:removeTargets()

    if not guiInfo.targets[self.stage] then
        self:close(true)
        return
    end

    for i, v in pairs(guiInfo.targets[self.stage]) do
        table.insert(self.targets, {})
        local state = math.random(0, 10) < 5 and true or false
        self:createTarget(v, 3024, state)
        self:createTarget(v, 3023, state)
        self:createTarget(v, 3021, state)
        self:createTarget(v, 3020, state)
        self:createTarget(v, 3019, state)
        self:createTarget(v, 3018, state)
    end

    self.targetsToShoot = #guiInfo.targets[self.stage]
    self.targetsShooted = 0
    self.weaponSlot = guiInfo.weapons[self.stage].weaponSlot
    triggerServerEvent("addPlayerWeaponLicence", resourceRoot, guiInfo.weapons[self.stage], self.stage == 1 and {self.pos.x, self.pos.y, self.pos.z, self.int, self.dim} or false)
end

function Licence:createTarget(position, model, state)
    local pos = Vector3(position.x, position.y, position.z + 2.64)
    local posTable = {pos.x, pos.y, pos.z}

    local target = createObject(model, pos.x, pos.y, pos.z)
    setElementRotation(target, 0, 0, 90)
    setElementInterior(target, 7)
    setElementDimension(target, 10)
    setElementData(target, "defPos", posTable, false)
    setElementData(target, "lastPos", {pos.x, pos.y + (state and -3 or 3), pos.z}, false)
    setElementData(target, "move", state, false)
    table.insert(self.targets[#self.targets], target)
end

function Licence:removeTargets()
    for _, targets in pairs(self.targets) do
        for _, v in pairs(targets) do
            if isElement(v) then destroyElement(v) end
        end
    end
end

function Licence:open()
    blockUpdate(true)
    self:updateState(true)

    self.tick = getTickCount()

    setElementPosition(localPlayer, guiInfo.pos)
    setElementRotation(localPlayer, 0, 0, 90)
    setElementInterior(localPlayer, 7)
    setElementDimension(localPlayer, 10)
    setTimer(function()
        setElementRotation(localPlayer, 0, 0, 90)
    end, 1000, 1)

    setElementFrozen(localPlayer, true)

    addEventHandler("onClientRender", root, self.func.render)
    addEventHandler("onClientPlayerWeaponFire", localPlayer, self.func.checkShoot)
end

function Licence:close(passed)
    if self.closed then return end
    if passed then
        setTimer(function()
            exports.TR_noti:create("Atış sınavı başarıyla geçti.", "success")
        end, 5000, 1)

    else
        setTimer(function()
            exports.TR_noti:create("Çok fazla kaçırılan atış nedeniyle sınavda başarısız oldu.", "error")
        end, 5000, 1)
    end

    exports.TR_dx:showLoading(5000, "Dünya yükleniyor")

    self.closed = true
    triggerServerEvent("takePlayerWeaponLicence", resourceRoot, passed)

    setTimer(self.func.destroy, 1000, 1)
end

function Licence:destroy()
    blockUpdate(false)
    self:updateState(false)
    self:removeTargets()
    destroyElement(self.targetImg)

    exports.TR_dx:setOpenGUI(false)

    setElementFrozen(localPlayer, false)
    removeEventHandler("onClientRender", root, self.func.render)
    removeEventHandler("onClientPlayerWeaponFire", localPlayer, self.func.checkShoot)

    setElementPosition(localPlayer, self.pos)
    setElementInterior(localPlayer, self.int)
    setElementDimension(localPlayer, self.dim)

    guiInfo.licence = nil
    self = nil
end



function Licence:moveTarget()
    if not self.tick then return end

    local progress = (getTickCount() - self.tick)/5000
    for _, targets in pairs(self.targets) do
        for _, v in pairs(targets) do
            local defPos = getElementData(v, "defPos")
            local lastPos = getElementData(v, "lastPos")
            local move = getElementData(v, "move")
            local x, y = interpolateBetween(lastPos[1], lastPos[2], 0, defPos[1], move and (defPos[2] + 3) or (defPos[2] - 3), 0, progress, "InOutQuad")
            setElementPosition(v, x, y, defPos[3])
        end
    end

    if progress >= 1 then
        self.tick = getTickCount()

        for _, targets in pairs(self.targets) do
            for _, v in pairs(targets) do
                if isElement(v) then
                    local pos = {getElementPosition(v)}
                    setElementData(v, "lastPos", pos, false)
                    setElementData(v, "move", not getElementData(v, "move"), false)
                end
            end
        end
    end
end

function Licence:render()
    self:updateKeys()
    self:checkAmmo()
    self:moveTarget()

    self:drawBackground(guiInfo.x, guiInfo.y, guiInfo.w, guiInfo.h, tocolor(17, 17, 17, 255), 4)
    dxDrawText("Silah izni", guiInfo.x + 84/zoom, guiInfo.y, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + 25/zoom, tocolor(212, 175, 55, 255), 1/zoom, self.fonts.main, "center", "center")
    dxDrawText("Sınavı geçmek için atış poligondaki tüm hedefleri vurmalısınız..", guiInfo.x + 84/zoom, guiInfo.y + 25/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h, tocolor(170, 170, 170, 255), 1/zoom, self.fonts.info, "center", "top", true, true)
    dxDrawText(string.format("Hedefler vuruldu: #b89935%d#aaaaaa/#b89935%d", self.targetsShooted/6, self.targetsToShoot), guiInfo.x + 84/zoom, guiInfo.y + 25/zoom, guiInfo.x + guiInfo.w - 10/zoom, guiInfo.y + guiInfo.h - 10/zoom, tocolor(170, 170, 170, 255), 1/zoom, self.fonts.info, "center", "bottom", true, true, false, true)

    dxDrawImage(guiInfo.x + 10/zoom, guiInfo.y + (guiInfo.h - 64/zoom)/2, 64/zoom, 64/zoom, self.targetImg, tocolor(255, 255, 255, 255))
end

function Licence:updateKeys()
    local weapon = getPedWeapon(localPlayer)
    if weapon < 1 then
        toggleControl("fire", false)
        toggleControl("action", false)
        toggleControl("aim_weapon", false)

    else
        toggleControl("fire", true)
        toggleControl("action", true)
        toggleControl("aim_weapon", true)
    end
end

function Licence:checkAmmo()
    local weapon = getPedWeapon(localPlayer, self.weaponSlot)
    local ammo = getPedTotalAmmo(localPlayer, self.weaponSlot)
    if ammo <= 0 and weapon and weapon > 0 and self.targetsShooted/6 ~= self.targetsToShoot then
        self:close()
    end
end

function Licence:checkShoot(weapon, ammo, ammoClip, x, y, z, target)
    if target then
        for i, targets in pairs(self.targets) do
            for k, v in pairs(targets) do
                if v == target then
                    destroyElement(v)
                    table.remove(self.targets[i], k)
                    break
                end
            end
        end

        self.targetsShooted = self.targetsShooted + 1
    end

    if self.targetsShooted/6 == self.targetsToShoot then
        self.stage = self.stage + 1
        self:removeTargets()
        self:createTargets()
    end
end

function Licence:updateState(state)
    toggleControl("fire", state)
    toggleControl("action", state)
    toggleControl("aim_weapon", state)

    toggleControl("forwards", not state)
    toggleControl("left", not state)
    toggleControl("right", not state)
    toggleControl("backwards", not state)
end

function Licence:drawBackground(x, y, w, h, color, radius, post)
    dxDrawRectangle(x, y - radius, w, radius, color, post)
    dxDrawRectangle(x - radius, y, w + radius * 2, h, color, post)
    dxDrawCircle(x, y, radius, 180, 270, color, color, 7, 1, post)
    dxDrawCircle(x + w, y, radius, 270, 360, color, color, 7, 1, post)
end


function payWeaponLicence(licence)
    triggerServerEvent("createPayment", resourceRoot, licence[1] == "practice" and guiInfo.practicePrice or guiInfo.theoryPrice, "createWeaponLicence", licence)
end
addEvent("payWeaponLicence", true)
addEventHandler("payWeaponLicence", root, payWeaponLicence)

function createWeaponPracticeLicence(paid)
    exports.TR_dx:setResponseEnabled(false)
    if not paid then return end

    if guiInfo.licence then return end
    guiInfo.licence = Licence:create()
end
addEvent("createWeaponPracticeLicence", true)
addEventHandler("createWeaponPracticeLicence", root, createWeaponPracticeLicence)