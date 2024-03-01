local highwayGates = {}
local settings = {
    openTime = 900,
    closeTime = 2000,
    autoClose = 1000,
}

function createTollGates()
    for i, v in pairs(positions) do
        local gate = createObject(968, unpack(v.positions.gate))

        local bx, by, bz = getPosition(gate, Vector3(-3.5, 0, 3))
        local blocker = createObject(971, bx, by, bz, 0, 0, v["positions"].gate[6])
        setElementAlpha(blocker, 0)
        setObjectScale(blocker, 0)

        highwayGates[i] = {
            gate = gate,
            blocker = blocker,
            gateStandard = Vector3(v.positions.gate[1], v.positions.gate[2], v.positions.gate[3]),
            canOpen = true,
        }

        setElementData(gate, "gateData",
        {
            model = 968,
            defPos = {x = v.positions.gate[1], y = v.positions.gate[2], z = v.positions.gate[3]},
            defRot = {x = v.positions.gate[4], y = v.positions.gate[5], z = v.positions.gate[6]},
        })
    end
end
createTollGates()


function declineTollGate(gateID)
    local pos = positions[gateID].positions.vehSpawn

    local veh = getPedOccupiedVehicle(client)
    setElementPosition(veh, pos[1], pos[2], pos[3])
    setElementRotation(veh, 0, 0, pos[4])
end
addEvent("declineTollGate", true)
addEventHandler("declineTollGate", resourceRoot, declineTollGate)

function tryOpenTollGate(gateID, isPrivate)
    if not highwayGates[gateID].canOpen then
        triggerClientEvent(client, "responseTollGate", resourceRoot, false)
        return
    end
    if not canOpenGate(client, isPrivate) then
        triggerClientEvent(client, "responseTollGate", resourceRoot, false)
        return
    end

    moveGate(gateID, "open")
    triggerClientEvent(client, "responseTollGate", resourceRoot, true)
end
addEvent("tryOpenTollGate", true)
addEventHandler("tryOpenTollGate", resourceRoot, tryOpenTollGate)

function closeTollGate(gateID)
    moveGate(gateID, "close")
end
addEvent("closeTollGate", true)
addEventHandler("closeTollGate", resourceRoot, closeTollGate)

function canOpenGate(client, isPrivate)
    if isPrivate then
        return exports.TR_core:takeMoneyFromPlayer(client, 50)
    else
        return true
    end
    return false
end

function moveGate(gateID, state)
    if state == "open" then
        local pos = highwayGates[gateID].gateStandard
        setElementData(highwayGates[gateID].gate, "open", true)

        setElementCollisionsEnabled(highwayGates[gateID].blocker, false)

        highwayGates[gateID].canOpen = false
        highwayGates[gateID].autoClose = setTimer(moveGate, settings.autoClose + settings.openTime, 1, gateID, "close")

    elseif state == "close" then
        if isTimer(highwayGates[gateID].autoClose) then killTimer(highwayGates[gateID].autoClose) end
        local _, rot = getElementRotation(highwayGates[gateID].gate)
        local pos = highwayGates[gateID].gateStandard
        setElementData(highwayGates[gateID].gate, "open", false)

        setTimer(function()
            highwayGates[gateID].canOpen = true
            setElementCollisionsEnabled(highwayGates[gateID].blocker, true)
        end, settings.closeTime + 100, 1)
    end
    return true
end