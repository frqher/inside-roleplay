txd = engineLoadTXD ("warsztat.txd", 3940)
engineImportTXD(txd, 3940)
dff = engineLoadDFF ("warsztat.dff", 3940)
engineReplaceModel(dff, 3940, true)
col = engineLoadCOL ("warsztat.col")
engineReplaceCOL(col,3940)


setOcclusionsEnabled( false )
