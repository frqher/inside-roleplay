local animations = {
    {
        name = "dealer",
        block = "policeCuffs",
    },
}

function replaceAnim()
    for i, v in pairs(animations) do
        local added = engineLoadIFP("files/animations/dealer.ifp", v.block)
    end
end
replaceAnim()