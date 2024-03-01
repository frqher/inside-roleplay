local font = dxCreateFont("Charcoal.ttf", 15, false)


rawData = [[
texture Tex0;
technique simple
{
    pass P0
    {
        Texture[0] = Tex0;
    }
}
]]

rawDataFilter = [[
texture gTexture;
float gBrightness;
float3 gColor;
float gAlpha;

sampler TextureSampler = sampler_state
{
    Texture = <gTexture>;
};

float4 setColor(float2 TextureCoordinate : TEXCOORD0) : COLOR0
{
    float4 color = tex2D(TextureSampler, TextureCoordinate) * gBrightness;
    color = saturate(color);
    color.r *= gColor.x;
    color.g *= gColor.y;
    color.b *= gColor.z;
    color.a = gAlpha;
    return color;
}

technique TexReplace
{
    pass P0
    {
        PixelShader = compile ps_2_0 setColor();
        Texture[0] = gTexture;
        LightEnable[1] = false;
        LightEnable[2] = false;
        LightEnable[3] = false;
        LightEnable[4] = false;
        AlphaRef = gAlpha;
    }
}
]]

function dxDrawDashedLine(sX, sY, eX, eY, lengthLine, lengthSpace, color, width, postGUI)
    lengthSpace = lengthSpace or lengthLine;
    color = color or tocolor(255, 255, 255, 255);
    width = width or 1;
    postGUI = postGUI or false;
    local length = getDistanceBetweenPoints2D(sX, sY, eX, eY);
    local linePartLength = lengthLine + lengthSpace;
    local lineParts = length / linePartLength;
    local xToAdd = (eX - sX) / lineParts;
    local yToAdd = (eY - sY) / lineParts;
    local lineRatio = lengthSpace / lengthLine;
    local counter = 0
    while (length > 0) do
        if (lengthLine > length) then
            dxDrawLine(sX, sY, eX, eY, color, width, postGUI);
            length = 0;
        else
            dxDrawLine(sX, sY, sX + xToAdd - xToAdd * lineRatio, sY + yToAdd - yToAdd * lineRatio, color, width, postGUI);
            sX = sX + xToAdd;
            sY = sY + yToAdd;
            length = length - linePartLength;
        end
        counter = counter+1
    end
end

function updateBoard()
    dxSetRenderTarget(renderTarget, true)
        local fontHeight = dxGetFontHeight(1.0, font)
        local celling = 59.7
        local height = 20
        local offsetX, offsetY = 0, height
    	dxDrawImage(0, 0, 512, 512, "board.png")
        dxDrawDashedLine(0, height+fontHeight+5, 512, height+fontHeight+5, 10, 5, tocolor(255, 255, 255, 150), 2, false)
        for index,column in ipairs(schema.columns) do
            local width = dxGetTextWidth(column.name, 1, font)/2
            dxDrawText(column.name, offsetX, 0, celling+offsetX+dxGetTextWidth(column.name, 1, font), height+fontHeight+5, nil, 1, font, "center", "center")
            for i,row in pairs(column.row) do
                dxDrawText(row, offsetX, offsetY+( (fontHeight+30)*i-1), celling+offsetX+dxGetTextWidth(column.name, 1, font), offsetY, nil, 1, font, "center", "top")
                local heightDraw = height+fontHeight/2+offsetY+( (fontHeight+30)*i-1)
                if i < 8 then
                    dxDrawDashedLine(0, heightDraw, 600, heightDraw, 10, 25, tocolor(100, 100, 100, 150), 2, false)
                end
            end
            dxDrawDashedLine(celling+offsetX+dxGetTextWidth(column.name, 1, font), 0, celling+offsetX+dxGetTextWidth(column.name, 1, font), 512, 10, 5, tocolor(255, 255, 255, 150), 2, false)
            offsetX = offsetX+dxGetTextWidth(column.name, 1, font)+celling
        end
    dxSetRenderTarget(false)
    dxSetShaderValue(shaderBoard, "Tex0", renderTarget)
    engineApplyShaderToWorldTexture(shaderBoard, "nf_blackbrd", getElementByID("Rick (Board_Shader) (1)") )
    engineApplyShaderToWorldTexture(shader, "tatty_wood_1", getElementByID("Rick (Board_Shader) (1)") )
end



local data = {}

function updateBoardElement(theKey, oldValue, newValue)
    if theKey == "schema" then
        schema = newValue
        updateBoard()
    end
end

function formatMilliseconds(milliseconds)
    local totalseconds = math.floor( milliseconds / 1000 )
    milliseconds = milliseconds % 1000
    local seconds = totalseconds % 60
    local minutes = math.floor( totalseconds / 60 )
    local hours = math.floor( minutes / 60 )
    local days = math.floor( hours / 24 )
    minutes = minutes % 60
    hours = hours % 24
    return string.format( "%02d:%02d", minutes, seconds)
end

function onClientColShapeLeaveShootRange(player)
    if player == localPlayer and data.colshape == source then
        local schemaBoard = getElementData(policeBoard, "schema")
        schemaBoard.columns[2].row[data.ID] = data.shoots
        schemaBoard.columns[3].row[data.ID] = data.hits
        schemaBoard.columns[4].row[data.ID] = data.shoots > 0 and math.floor(data.hits/data.shoots*100).."%" or 0
        schemaBoard.columns[5].row[data.ID] = formatMilliseconds( ( getTickCount(  ) - data.time ) )
        setElementData(policeBoard, "schema", schemaBoard)
        setElementData(data.colshape, "use", false)
        removeEventHandler("onClientObjectBreak", resourceRoot, onClientObjectBreakShootRange)
        removeEventHandler("onClientColShapeLeave", data.colshape, onClientColShapeLeaveShootRange)
        removeEventHandler("onClientPlayerWeaponFire", localPlayer, onClientPlayerWeaponFireFuncShootRange)
    end
end

local modelObjects = {
    [3024] = true,
    [3023] = true,
    [3022] = true,
    [3021] = true,
    [3020] = true,
    [3019] = true,
    [3018] = true,
}
local weaponEnabled = {
    [22] = true,
    [23] = true,
    [24] = true,
    [25] = true,
    [26] = true,
    [28] = true,
    [29] = true,
    [30] = true,
    [31] = true,
    [32] = true,
    [34] = true,
}

function onClientObjectBreakShootRange(attacker)
    if attacker == localPlayer and modelObjects[getElementModel(source)] then
        data.hits = data.hits+1
    end
end

function onClientPlayerWeaponFireFuncShootRange(weapon)
    if weaponEnabled[weapon] then
        data.shoots = data.shoots+1
    end
end


addEvent("onClientPlayerHitShootRange", true)
addEventHandler("onClientPlayerHitShootRange", root, function(colshape)
    data = {}
    data.colshape = colshape
    data.ID = getElementData(colshape, "ID")
    data.shoots = 0
    data.hits = 0
    data.accuracity = 0
    data.time = getTickCount(  )
    addEventHandler("onClientObjectBreak", resourceRoot, onClientObjectBreakShootRange)
    addEventHandler( "onClientColShapeLeave", data.colshape, onClientColShapeLeaveShootRange)
    addEventHandler("onClientPlayerWeaponFire", localPlayer, onClientPlayerWeaponFireFuncShootRange)
end)