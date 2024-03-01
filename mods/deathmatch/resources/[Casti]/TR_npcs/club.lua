local data = {
    anims = {
        {"STRIP", "STR_Loop_A"},
        {"STRIP", "STR_Loop_B"},
        {"STRIP", "STR_Loop_C"},
    },

    animTime = 10000,
}

function makeClubDance(model, clubId, price)
    data.selected = 1
    local pos = getPedPostionByClubID(clubId)

    setElementFrozen(localPlayer, true)
    local int = getElementInterior(localPlayer)
    local dim = getElementDimension(localPlayer)

    data.ped = createPed(model, pos[1], pos[2], pos[3])
    setElementRotation(data.ped, 0, 0, pos[4])
    setElementInterior(data.ped, int)
    setElementDimension(data.ped, dim)

    data.player = createPed(getElementModel(localPlayer), pos[5], pos[6], pos[7])
    setElementRotation(data.player, 0, 0, pos[8])
    setElementInterior(data.player, int)
    setElementDimension(data.player, dim)
    setElementData(data.player, "animation", {"INT_HOUSE", "LOU_Loop"}, false)
    setPedAnimation(data.player, "INT_HOUSE", "LOU_Loop", -1, true, false, false, false)

    setPedAnimation(data.ped, data.anims[data.selected][1], data.anims[data.selected][2], -1, true, false, false, false)
    setElementData(data.ped, "animation", {data.anims[data.selected][1], data.anims[data.selected][2]}, false)

    local camera = getCameraByClubID(clubId)
    setCameraMatrix(camera[1], camera[2], camera[3], camera[4], camera[5], camera[6])
    setTimer(nextAnim, data.animTime, #data.anims)

    if price then
        exports.TR_noti:create(string.format("Özel dans için %.2f TL ödediniz.", price), "success")
    else
        exports.TR_noti:create("Sahip olduğunuz statü nedeniyle özel dans ücretsizdir.", "success")
    end
    
    exports.TR_dx:setOpenGUI(true)
    exports.TR_hud:setHudVisible(false)
    exports.TR_chat:showCustomChat(false)
end
addEvent("makeClubDance", true)
addEventHandler("makeClubDance", root, makeClubDance)

function nextAnim()
    data.selected = data.selected + 1
    if not data.anims[data.selected] then
        exports.TR_noti:create("Özel dans hakkınız doldu.", "info")
        
        setElementFrozen(localPlayer, false)
        setCameraTarget(localPlayer)

        destroyElement(data.ped)
        destroyElement(data.player)

        exports.TR_dx:setOpenGUI(false)
        exports.TR_hud:setHudVisible(true)
        exports.TR_chat:showCustomChat(true)

        exports.TR_achievements:addAchievements("privateDance")
        return
    end

    setPedAnimation(data.ped, data.anims[data.selected][1], data.anims[data.selected][2], -1, true, false, false, false)
    setElementData(data.ped, "animation", {data.anims[data.selected][1], data.anims[data.selected][2]}, false)
end

function getCameraByClubID(clubId)
    if clubId == 1 then return {1207.5274658203, 17.48046455383, 1002.277038574, 1201.0222167969, 15.917269706726, 1000.539050293} end
    if clubId == 2 then return {1209.4718017578, -44.705783843994, 1001.910949707, 1204.5035400391, -43.920757293701, 1000.3664550781} end
    if clubId == 3 then return {-2674.7495117188, 1424.5694580078, 919.42321777344, -2671.3251953125, 1431.0208740234, 917.99591064453} end
end

function getPedPostionByClubID(clubID)
    if clubID == 1 then return {1203.6772460938, 16.19895362854, 1000.921875, 326, 1204.69140625, 17.569356918335, 1000.921875, 147} end
    if clubID == 2 then return {1206.7106933594, -45.0993309021, 1000.953125, 324, 1207.6124267578, -43.749935150146, 1000.953125, 141} end
    if clubID == 3 then return {-2673.1989746094, 1428.8403320313, 918.3515625, 266, -2671.3488769531, 1429.0675048828, 918.3515625, 86} end
end