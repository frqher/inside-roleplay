local gateTimers = {}

local gateAutoCloseTime = {
    [10184] = 5000,
    [968] = 4000,
    [976] = 8000,
}
local gatePositions = {
    -- Police SF
    {
        model = 10184,
        pos = Vector3(-1631.6999511719, 688.5, 8.6999998092651),
        rot = Vector3(0, 0, 90),
        openPos = {
            Vector4(-1631.40234375, 684.6015625, 7.1875, 5),
            Vector4(-1631.5087890625, 695.8525390625, 6.7300643920898, 5),
        },
        permission = {
            type = "fraction",
            value = 1,
        },
    },
    {
        model = 968,
        pos = Vector3(-1701.4833984375, 687.677734375, 24.6828125),
        rot = Vector3(0, 90, 270.5),
        openPos = {
            Vector4(-1704.517578125, 684.236328125, 24.890625, 3),
            Vector4(-1697.8037109375, 684.0419921875, 24.17834854126, 3),
        },
        permission = {
            type = "fraction",
            value = 1,
        },
    },
    {
        model = 968,
        pos = Vector3(-1572.1865234375, 658.7466796875, 6.878125),
        rot = Vector3(0, 90, 90),
        openPos = {
            Vector4(-1574.96484375, 662.1669921875, 7.1875, 3),
            Vector4(-1568.3427734375, 662.236328125, 7.1875, 3),
        },
        permission = {
            type = "fraction",
            value = 1,
        },
    },

    -- SAFD SF
    {
        model = 968,
        pos = Vector3(-2344.9115234375, -80.54171875, 35.0203125),
        rot = Vector3(180, -90, 0),
        openPos = {
            Vector4(-2348.359375, -83.7919921875, 35.32031255, 4),
            Vector4(-2348.435546875, -76.7841796875, 35.3203125, 4),
        },
        permission = {
            type = "fraction",
            value = 3,
        },
    },
    -- SAFD LV
    {
        model = 968,
        pos = Vector3(2478.6107421875, 1242.9967578125, 10.55),
        rot = Vector3(180, -90, 0),
        openPos = {
            Vector4(2475.0517578125, 1239.9775390625, 10.800000190735, 4),
            Vector4(2475.0986328125, 1245.728515625, 10.8203125, 4),
        },
        permission = {
            type = "fraction",
            value = 3,
        },
    },
    {
        model = 968,
        pos = Vector3(2463.1807421875, 1242.9967578125, 10.55),
        rot = Vector3(180, -90, 180),
        openPos = {
            Vector4(2466.0517578125, 1239.9775390625, 10.800000190735, 4),
            Vector4(2466.0986328125, 1245.728515625, 10.8203125, 4),
        },
        permission = {
            type = "fraction",
            value = 3,
        },
    },
    {
        model = 968,
        pos = Vector3(2502.6522460938, 1263.513046875, 10.6),
        rot = Vector3(180, -90, 0),
        openPos = {
            Vector4(2499.6522460938, 1260.513046875, 10.6, 4),
            Vector4(2499.6522460938, 1266.513046875, 10.6, 4),
        },
        permission = {
            type = "fraction",
            value = 3,
        },
    },

    -- SAMC SF
    {
        model = 976,
        pos = Vector3(-2712.0673828125, 621.4482421875, 15.6453125),
        rot = Vector3(0, 0, 180),
        openPos = {
            Vector4(-2710.15625, 621.3955078125, 14.4453125, 3),
            Vector4(-2714.916015625, 621.3046875, 14.445312, 3),
        },
        permission = {
            type = "fraction",
            value = 2,
        },
    },
    {
        model = 968,
        pos = Vector3(-2573.6115234375, 578.70973876953, 14.3),
        rot = Vector3(0, 90, 0),
        openPos = {
            Vector4(-2570.1865234375, 581.578125, 14.451530456543, 3),
        },
        permission = {
            type = "fraction",
            value = 2,
        },
    },
    {
        model = 968,
        pos = Vector3(-2559.1815234375, 578.59973876953, 14.3),
        rot = Vector3(0, 90, 180),
        openPos = {
            Vector4(-2562.7685546875, 581.775390625, 14.458492279053, 3),
        },
        permission = {
            type = "fraction",
            value = 2,
        },
    },
    {
        model = 968,
        pos = Vector3(-2600.091796875, 588.89375, 14.2),
        rot = Vector3(0, 90, 90.5),
        openPos = {
            Vector4(-2602.9111328125, 592.515625, 14.45312, 3),
        },
        permission = {
            type = "fraction",
            value = 2,
        },
    },
    {
        model = 968,
        pos = Vector3(-2599.3039550781, 681.09766845703, 27.599999237061),
        rot = Vector3(0, 90, 90.5),
        openPos = {
            Vector4(-2602.361328125, 684.6328125, 27.8125, 3),
            Vector4(-2595.5302734375, 684.5166015625, 27.8125, 3),
        },
        permission = {
            type = "fraction",
            value = 2,
        },
    },

    -- ERS
    {
        model = 968,
        pos = Vector3(-75.64124206543, -345.49992919922, 1.15),
        rot = Vector3(0, 90, 270),
        openPos = {
            Vector4(-71.55859375, -349.201171875, 1.3109995126724, 3),
        },
        permission = {
            type = "fraction",
            value = 5,
        },
    },
    {
        model = 968,
        pos = Vector3(-75.64124206543, -360.2, 1.15),
        rot = Vector3(0, 90, 90),
        openPos = {
            Vector4(-79.8369140625, -356.52734375, 1.4296875, 3),
        },
        permission = {
            type = "fraction",
            value = 5,
        },
    },


}

function createGates()
    for i, v in pairs(gatePositions) do
        local gate = createObject(v.model, v.pos, v.rot)
        setElementData(gate, "gateData",
        {
            model = v.model,
            defPos = {x = v.pos.x, y = v.pos.y, z = v.pos.z},
            defRot = {x = v.rot.x, y = v.rot.y, z = v.rot.z},
        })

        for _, openPos in pairs(v.openPos) do
            local sphere = createColSphere(openPos.x, openPos.y, openPos.z, openPos.w)

            setElementData(sphere, "gateObject", gate, false)
            setElementData(sphere, "gatePermissions", v.permission, false)


            addEventHandler("onColShapeHit", sphere, openGate)
        end
    end
end

function openGate(el, md)
    if getElementType(el) ~= "player" or not md then return end

    local permissions = getElementData(source, "gatePermissions")
    if not permissions then return end

    local gate = getElementData(source, "gateObject")
    if isTimer(gateTimers[gate]) then killTimer(gateTimers[gate]) end
    if not canOpenGate(el, permissions) then return end

    setElementData(gate, "open", true)
    gateTimers[gate] = setTimer(closeGate, gateAutoCloseTime[getElementModel(gate)], 1, gate)
end

function closeGate(gate)
    if isTimer(gateTimers[gate]) then killTimer(gateTimers[gate]) end
    gateTimers[gate] = nil

    setElementData(gate, "open", false)
end

function canOpenGate(plr, permissions)
    local plrUID = getElementData(plr, "characterUID")
    if not plrUID then return end

    if permissions.type == "fraction" then
        local isInFraction = exports.TR_mysql:querry("SELECT ID FROM tr_fractionsPlayers WHERE playerUID = ? AND fractionID = ? LIMIT 1", plrUID, permissions.value)
        if isInFraction and isInFraction[1] then return true end
    end

    return false
end

createGates()