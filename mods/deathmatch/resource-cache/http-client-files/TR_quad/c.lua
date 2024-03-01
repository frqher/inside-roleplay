function loadModel()
    local txd = engineLoadTXD("models/quad.txd")
    engineImportTXD(txd, 471)
    local dff = engineLoadDFF("models/quad.dff")
    engineReplaceModel(dff, 471)
end
loadModel()