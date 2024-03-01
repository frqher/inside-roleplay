
function startScript()
    local found = false

    for index, module in pairs(getLoadedModules()) do
        if module:find("ml_sockets", 1, true) then
            found = true
            break
        end
    end

    if not found then
        outputServerLog("Module 'ml_sockets' not found, please install.")
        -- cancelEvent()
    else
        -- createSocketFromConfig()
        -- outputDebugString("[Discord] Module started")
    end
end
addEventHandler("onResourceStart", resourceRoot, startScript, false, "high+9")