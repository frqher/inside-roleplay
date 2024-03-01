local sx, sy = guiGetScreenSize()
local data = {
    size = 20,
}

_, data.stats = getPerformanceStats("Lua timing")
function updateStats()
    _, data.stats = getPerformanceStats("Lua timing")
end
setTimer(updateStats, 1000, 0)

function render()
    local count = #data.stats
    local height = count * data.size
    local topY = sy/2 + 150 - height/2


    local i = 0
    for _, v in pairs(data.stats) do
        -- if string.find(v[1], "hud") or string.find(v[1], "radar") then
            dxDrawText(string.format("%s  %s  %s", v[1], v[2], v[3]), sx - 495, topY + data.size * i + 2, sx - 300, topY + data.size * (i+1), tocolor(255, 255, 255, 255), 1, "default", "left", "center", false, false, true)
            i = i + 1
        -- end
    end
    dxDrawRectangle(sx - 500, topY, 200, i * data.size, tocolor(17, 17, 17, 255))

end

if getPlayerName(localPlayer) == "Xantris" then
    addEventHandler("onClientRender", root, render)
end