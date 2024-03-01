local wheelsModels = {1025, 1073, 1074, 1075, 1076, 1077, 1078, 1079, 1080, 1081, 1082, 1083, 1084, 1085, 1085, 1096, 1097, 1098}

function setCarModel()
  for i, v in ipairs(wheelsModels) do
    if fileExists("wheels/"..v..".dff") then
      local dff = engineLoadDFF("wheels/"..v..".dff", v)
      engineReplaceModel(dff, v)
    end
  end
end
setCarModel()
