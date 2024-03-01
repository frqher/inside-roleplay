-- local NPCs = {
--     {
--         model = 194,
--         pos = {2853.0490722656, -1138.8924560547, 113.27780151367, 0},
--         int = 0,
--         dim = 50,
--         name = "Izabeth Grans",
--         govID = 1,
--     },
--     {
--         model = 194,
--         pos = {-2016.55859375, -80.968757629395, 85, 279},
--         int = 0,
--         dim = 9,
--         name = "Grace Hasko",
--         govID = 2,
--     },
-- }

-- function createNPC()
--     local dialogue = exports.TR_npc:createDialogue()
-- 	exports.TR_npc:addDialogueText(dialogue, "Dzień dobry.", {pedResponse = "Dzień dobry. Jak mogę pomóc?"})
--     exports.TR_npc:addDialogueText(dialogue, "Do widzenia.", {pedResponse = "Do widzenia."})
--     exports.TR_npc:addDialogueText(dialogue, "Chciałbym zatrudnić się w pracy.", {pedResponse = "A do jakiej konkretnie? Proszę wypełnić formularz i dać mi znać.", responseTo = "Dzień dobry.", img = "username", trigger = "openGovJobs"})

--     for i, v in pairs(NPCs) do
--         local npc = exports.TR_npc:createNPC(v.model, v.pos[1], v.pos[2], v.pos[3], v.pos[4], v.name, "Urząd pracy", "dialogue")
--         setElementInterior(npc, v.int)
--         setElementDimension(npc, v.dim)
--         setElementData(npc, "govID", v.govID, false)

--         exports.TR_npc:setNPCDialogue(npc, dialogue)

--         if v.anim then
--             setPedAnimation(npc, v.anim[1], v.anim[2])
--             setElementData(npc, "animation", v.anim)
--         end
--     end

--     createJobStarts()
-- end

function createJobStarts()
    local jobs = exports.TR_mysql:querry("SELECT ID, name, type, position, requirements, description, payment, distanceLimit, slots FROM tr_govJobs WHERE position IS NOT NULL")
    if not jobs or not jobs[1] then return end
    for i, v in pairs(jobs) do
        local pos = split(v.position, ",")
        local color = getMarkerColorForType(v.type)
        local marker = createMarker(pos[1], pos[2], pos[3] - 1, "cylinder", 1.2, color[1], color[2], color[3], 0)
        setElementInterior(marker, pos[4])
        setElementDimension(marker, pos[5])
        setElementData(marker, "markerIcon", v.type)
        setElementData(marker, "jobData", {ID = v.ID, name = v.name, desc = v.description, requirements = v.requirements, type = v.type, payment = v.payment, distanceLimit = v.distanceLimit, slots = v.slots}, false)
    end
end

function getMarkerColorForType(jobType)
    if jobType == "mechanic" then return {73, 73, 231}
    elseif jobType == "taxi" then return {255, 208, 0}
    end
    return {255, 255, 255}
end



function openGovJobs(npc)
    local uid = getElementData(source, "characterUID")
    local govID = getElementData(npc, "govID")

    exports.TR_mysql:querry("UPDATE tr_govJobsPlayers SET plrUID = NULL WHERE start <= now() - INTERVAL 1 DAY")
    local govJobs = exports.TR_mysql:querry("SELECT tr_govJobs.ID, tr_govJobs.name, tr_govJobs.type, tr_govJobs.description, tr_govJobs.place, tr_govJobs.payment, tr_govJobs.requirements, (SELECT count(*) FROM tr_govJobsPlayers WHERE jobID = tr_govJobs.ID) AS placesAvaliable, (SELECT count(*) FROM tr_govJobsPlayers WHERE jobID = tr_govJobs.ID AND plrUID IS NOT NULL) AS placesTaken FROM tr_govJobs WHERE govID = ?", govID)
    local hasJob = exports.TR_mysql:querry("SELECT jobID FROM tr_govJobsPlayers WHERE plrUID = ?", uid)
    local licences = exports.TR_mysql:querry("SELECT licence FROM tr_accounts WHERE UID = ?", uid)

    triggerClientEvent(source, "openGovJobSelect", resourceRoot, govJobs, hasJob[1] and hasJob[1].jobID or false, licences[1].licence)
end
addEvent("openGovJobs", true)
addEventHandler("openGovJobs", root, openGovJobs)


function setPlayerGovJob(jobID, newJob)
    local uid = getElementData(client, "characterUID")
    if newJob then
        local _, result = exports.TR_mysql:querry("UPDATE tr_govJobsPlayers SET plrUID = ?, start = now() WHERE plrUID IS NULL AND jobID = ? LIMIT 1", uid, jobID)
        triggerClientEvent(client, "govJobSelectResponse", resourceRoot, "get", result)
    else
        exports.TR_mysql:querry("UPDATE tr_govJobsPlayers SET plrUID = NULL WHERE plrUID = ? LIMIT 1", uid)
        triggerClientEvent(client, "govJobSelectResponse", resourceRoot, "release")
    end
end
addEvent("setPlayerGovJob", true)
addEventHandler("setPlayerGovJob", resourceRoot, setPlayerGovJob)


function startPlayerGovJob(jobID)
    -- local uid = getElementData(client, "characterUID")
    -- exports.TR_mysql:querry("UPDATE tr_govJobsPlayers SET start = now() WHERE plrUID = ? LIMIT 1", uid)

    if jobID then
        local data = getElementData(client, "characterData")
        setElementModel(client, data.skin)
        setElementData(client, "customModel", nil)
        triggerClientEvent(client, "responseGovJobStart", resourceRoot, "end")

    else
        triggerClientEvent(client, "responseGovJobStart", resourceRoot, "start")
    end
end
addEvent("startPlayerGovJob", true)
addEventHandler("startPlayerGovJob", resourceRoot, startPlayerGovJob)


function govJobMarkerEnter(el, md)
    if not md then return end
    if getElementType(el) ~= "player" then return end
    local _, _, ez = getElementPosition(el)
    local _, _, mz = getElementPosition(source)
    if ez < mz - 0.5 or ez > mz + 2 then return end

    local licences = exports.TR_mysql:querry("SELECT licence FROM tr_accounts WHERE UID = ?", getElementData(el, "characterUID"))

    triggerClientEvent(el, "openGovJobStart", resourceRoot, getElementData(source, "jobData"), licences[1].licence)
end
addEventHandler("onMarkerHit", resourceRoot, govJobMarkerEnter)
createJobStarts()