function playerSitOnBench(pos)
    local plr = client
    setElementPosition(plr, pos[1], pos[2], pos[3])

    setTimer(function()
        setElementRotation(plr, 0, 0, pos[4])

        setTimer(function()
            setPedAnimation(plr, "ped", "SEAT_idle", -1, true, false, false, false)
            setElementData(plr, "animation", {"ped", "SEAT_idle"})
        end, 100, 1)
    end, 50, 1)
end
addEvent("playerSitOnBench", true)
addEventHandler("playerSitOnBench", root, playerSitOnBench)