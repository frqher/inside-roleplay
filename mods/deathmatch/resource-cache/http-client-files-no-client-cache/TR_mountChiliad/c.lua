local snowZone = createColPolygon(
    -1117.8629150391, -2999.2360839844,
    -1119.4138183594, -2779.8234863281,
    -1181.2243652344, -2620.2238769531,
    -1235.8570556641, -2547.7507324219,
    -1235.7335205078, -2367.8312988281,
    -1167.5152587891, -2218.8381347656,
    -1177.0996093754, -2033.0169677734,
    -1376.1442871094, -1725.3400878906,
    -1478.2474365234, -1674.8654785156,
    -1621.4177246094, -1678.3270263672,
    -1755.0541992188, -1550.5257568359,
    -1861.9069824219, -1468.9160156224,
    -1962.2117919922, -1380.2987060547,
    -2091.1298828125, -1204.8487548828,
    -2196.2414550781, -1049.5141601563,
    -2476.7658691406, -874.11907958984,
    -2619.1918945313, -877.48168945314,
    -2967.5217285156, -1082.4569091797,
    -3008.1679687550, -1885.4948730469,
    -2768.4157714844, -2170.0004882813,
    -2857.8542480469, -2317.6906738281,
    -2859.6621093756, -2545.0917968758,
    -2693.8879394531, -2874.0056152344,
    -1993.5410156256, -2909.4738769532,
    -1740.5479736328, -2803.1982421875,
    -1541.7954101563, -2994.8566894531,
    -1113.9154052734, -2997.0651855469)

local loaded = false

function loadCustom()
    if loaded then return end
    loaded = true

    local txd = engineLoadTXD("files/snow.txd")

    for _, v in ipairs(customLoad) do
        removeWorldModel(v.lod, 0.1, v.pos.x, v.pos.y, v.pos.z)
    end

    setTimer(function()
        for _, v in ipairs(customLoad) do
            engineImportTXD(txd, v.model)
        end
    end, 1000, 1)
end

function unloadCustom()
    if not loaded then return end
    loaded = nil

    local txd = engineLoadTXD("files/grass.txd")
    for _, v in ipairs(customLoad) do
        engineImportTXD(txd, v.model)
    end
end


function loadTXD(pos, tutorial)
    local txd = engineLoadTXD("files/snow.txd")

    for _, v in ipairs(models) do
        engineImportTXD(txd, v.model)
    end

    if isElementWithinColShape(localPlayer, snowZone) then
        loadCustom()
    end
end
loadTXD()