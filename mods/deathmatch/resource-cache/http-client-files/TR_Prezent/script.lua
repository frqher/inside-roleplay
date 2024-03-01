txd = engineLoadTXD ("prezent.txd")
engineImportTXD (txd, 1276 )
dff = engineLoadDFF ("prezent.dff")
engineReplaceModel (dff, 1276 )
