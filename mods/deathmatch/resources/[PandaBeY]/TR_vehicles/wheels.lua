local settings = {
    maxDistance = 30,
    shaderDistance = 50,
    shader = [[
        float Brightness = 1;
        float4 sLightColor = float4(1,1,1,1);
        texture sTex0;

        sampler Sampler0 = sampler_state
        {
            Texture = (sTex0);
        };

        float4 PixelShaderPS(float4 TexCoord : TEXCOORD0, float4 Position : POSITION, float4 Diffuse : COLOR0) : COLOR0
        {
            float4 tex = tex2D(Sampler0, TexCoord);
            float4 output = saturate(tex * sLightColor);
            output.r *= 0.45 * Brightness;
            output.g *= 0.45 * Brightness;
            output.b *= 0.45 * Brightness;
            return output;
        }

        technique shader_tex_replace
        {
            pass P0
            {
                PixelShader = compile ps_2_0 PixelShaderPS();
                LightEnable[1] = true;
                LightEnable[2] = true;
                LightEnable[3] = true;
                LightEnable[4] = true;
            }
        }

        technique fallback
        {
            pass P0
            {
            }
        }
    ]],
}

Wheels = {}
Wheels.__index = Wheels

function Wheels:create()
    local instance = {}
    setmetatable(instance, Wheels)
    if instance:constructor() then
        return true
    end
    return false
end

function Wheels:constructor()
    self.streamed = {}
    self.createdWheels = {}

    self.shaders = {}

    self.textures = {}
    self.textures.wheelColor = dxCreateTexture("files/images/wounds.png", "dxt3", true, "clamp")
    self.textures.wounds = dxCreateTexture("files/images/wounds.png", "dxt3", true, "clamp")

    self.func = {}
    self.func.preRender = function() self:preRender() end
    self.func.loadVehicles = function() self:loadVehicles() end

    addEventHandler("onClientPreRender", root, self.func.preRender)

    -- setTimer(self.func.loadVehicles, 1000, 0)
    self:loadVehicles()
    return true
end

function Wheels:calculateVehicleWheelRotation(vehicle, wheels)
    local wheelNames = {'wheel_lf_dummy', 'wheel_rf_dummy', 'wheel_rb_dummy', 'wheel_lb_dummy'}
    local visualTune = getElementData(vehicle, "visualTuning")
    if not visualTune then self:onStreamOut(vehicle) return end

    for i = 1, #wheels do
        local wheel = wheels[i]
        if (wheel.object) then
            -- setVehicleComponentVisible(vehicle, wheelNames[i], false)

            local _, sy, sz = getVehicleComponentScale(vehicle, wheelNames[i])
            setObjectScale(wheel.object, (visualTune.wheelResize or 1), sy, sz)

            local rotation = Vector3(getVehicleComponentRotation(vehicle, wheel.name, 'world'))
            rotation.y = rotation.y + (visualTune.wheelTilt or 0)

            setElementPosition(wheel.object, Vector3(getVehicleComponentPosition(vehicle, wheel.name, 'world')))
            setElementRotation(wheel.object, rotation, "ZYX")
        end
    end
end

function Wheels:preRender()
    for vehicle, wheels in pairs(self.createdWheels) do
        if isElement(vehicle) then
            if (vehicle) and (isElementStreamedIn(vehicle)) and (#wheels > 0) then
                self:calculateVehicleWheelRotation(vehicle, wheels)
            end
        else
            self:onStreamOut(vehicle)
        end
    end

    self:loadVehicles()
end

function Wheels:setCustomWheels(veh, wheelModel, wheelResize, wheelTilt)
	if (tonumber(wheelModel)) then
		for _, wheel in pairs(self.createdWheels[veh] or {}) do
			destroyElement(wheel.object)
		end
        self.createdWheels[veh] = nil

        local wheels = {'wheel_lf_dummy', 'wheel_rf_dummy', 'wheel_rb_dummy', 'wheel_lb_dummy'}
        for i = 1, #wheels do
			setVehicleComponentVisible(veh, wheels[i], false)

			local wheel = {
                wheelResize = tonumber(wheelResize) or 0,
				tilt = tonumber(wheelTilt) or 0,
				name = wheels[i],
                object = createObject(wheelModel, Vector3()),
            }

            setElementParent(wheel.object, veh)
			setElementInterior(wheel.object, getElementInterior(veh))
			setElementDimension(wheel.object, getElementDimension(veh))

			setElementCollidableWith(wheel.object, veh, false)

			wheels[i] = wheel
		end
		self.createdWheels[veh] = wheels
	end
end

function Wheels:removeCustomWheels(veh)
    if not self.createdWheels[veh] then return end
    for _, wheel in pairs(self.createdWheels[veh] or {}) do
        if isElement(wheel.object) then destroyElement(wheel.object) end
    end

    if isElement(veh) then
        local wheels = {'wheel_lf_dummy', 'wheel_rf_dummy', 'wheel_rb_dummy', 'wheel_lb_dummy'}
        for i = 1, #wheels do
            setVehicleComponentVisible(veh, wheels[i], true)
        end
    end

    for i, v in pairs(self.streamed[veh]) do
        if isElement(v) then destroyElement(v) end
    end

    self.createdWheels[veh] = nil
    self.streamed[veh] = nil
end

function Wheels:updateColor(veh)
    self.streamed[veh].color = {getVehicleColor(veh, true)}
    dxSetShaderValue(self.streamed[veh].vehicle, "sLightColor", Vector4(self.streamed[veh].color[10]/255, self.streamed[veh].color[11]/255, self.streamed[veh].color[12]/255, 1))
    engineApplyShaderToWorldTexture(self.streamed[veh].vehicle, "rims", veh)

    if not self.createdWheels[veh] then return end
    local wheels = {'wheel_lf_dummy', 'wheel_rf_dummy', 'wheel_rb_dummy', 'wheel_lb_dummy'}
    for i = 1, #wheels do
        dxSetShaderValue(self.streamed[veh].wheel, "sLightColor", Vector4(self.streamed[veh].color[10]/255, self.streamed[veh].color[11]/255, self.streamed[veh].color[12]/255, 1))
        engineApplyShaderToWorldTexture(self.streamed[veh].wheel, "rims", self.createdWheels[veh][i].object)
        setVehicleComponentVisible(veh, wheels[i], false)
    end
    for i = 1, #wheels do
        dxSetShaderValue(self.streamed[veh].wounds, "sLightColor", Vector4(self.streamed[veh].color[7]/255, self.streamed[veh].color[8]/255, self.streamed[veh].color[9]/255, 1))
        engineApplyShaderToWorldTexture(self.streamed[veh].wounds, "wounds", self.createdWheels[veh][i].object)
    end

    -- local time = getTime()
    -- if time >= 23 and time <= 5 then
    --     -- Noc
    --     dxSetShaderValue(self.shaders.wheel, "Brightness", 1)
    --     dxSetShaderValue(self.shaders.vehicle, "Brightness", 1)
    -- else
    --     -- Dzień
    --     dxSetShaderValue(self.shaders.wheel, "Brightness", 1)
    --     dxSetShaderValue(self.shaders.vehicle, "Brightness", 1)
    -- end
end

function Wheels:onStreamIn(veh, details)
    if getElementType(veh) ~= "vehicle" then return end
    if not self.streamed[veh] then
        self.streamed[veh] = {
            wheel = dxCreateShader(settings.shader, 0, 0, false, "object"),
            wounds = dxCreateShader(settings.shader, 0, 0, false, "object"),
            vehicle = dxCreateShader(settings.shader, 0, settings.maxDistance * 2, false, "vehicle"),
            color = {getVehicleColor(veh, true)},
        }
        dxSetShaderValue(self.streamed[veh].wheel, "sTex0", self.textures.wheelColor)
        dxSetShaderValue(self.streamed[veh].wounds, "sTex0", self.textures.wounds)
        dxSetShaderValue(self.streamed[veh].vehicle, "sTex0", self.textures.wheelColor)
    end
    if not details then self:updateColor(veh) return end

    if self.createdWheels[veh] then
        self:updateColor(veh)

        local upgrades = getVehicleUpgrades(veh)
        local wheelModel = false
        if upgrades then
            for i, v in pairs(upgrades) do
                local type = string.lower(getVehicleUpgradeSlotName(v))
                if type == "wheels" then
                    wheelModel = v
                end
            end
        end

        if not self.createdWheels[veh][1].object or not wheelModel then self:onStreamOut(veh) return end
        if getElementModel(self.createdWheels[veh][1].object) ~= wheelModel then
            local wheels = {'wheel_lf_dummy', 'wheel_rf_dummy', 'wheel_rb_dummy', 'wheel_lb_dummy'}
            for i = 1, #wheels do
                setElementModel(self.createdWheels[veh][i].object, wheelModel)
                local _, sy, sz = getVehicleComponentScale(veh, wheels[i])
                setObjectScale(self.createdWheels[veh][i].object, self.createdWheels[veh][i].wheelResize, sy, sz)
            end
        end
        return
    end

    if getDistanceBetweenPoints2D(Vector2(getElementPosition(localPlayer)), Vector2(getElementPosition(veh))) >= settings.maxDistance then return end
    local visualTune = getElementData(veh, "visualTuning")
    if not visualTune then return self:updateColor(veh) end

    local upgrades = getVehicleUpgrades(veh)
    local wheelModel = false
    if upgrades then
        for i, v in pairs(upgrades) do
            local type = string.lower(getVehicleUpgradeSlotName(v))
            if type == "wheels" then
                wheelModel = v
            end
        end
    end
    if not wheelModel then self:updateColor(veh) return end
    if not visualTune.wheelResize and not visualTune.wheelTilt then self:updateColor(veh) return end

    self:setCustomWheels(veh, wheelModel, tonumber(visualTune.wheelResize) or 1, tonumber(visualTune.wheelTilt) or 0)
    self:updateColor(veh)
end

function Wheels:onStreamOut(veh)
    if not isElement(veh) then
        self:removeCustomWheels(veh)
        self.streamed[veh] = nil
        return
    end

    if getElementType(veh) ~= "vehicle" then return end
    if not self.streamed[veh] then return end

    self:removeCustomWheels(veh)
    self.streamed[veh] = nil
end

function Wheels:loadVehicles()
    local plrPos = Vector2(getElementPosition(localPlayer))

    -- for i, v in pairs(getElementsByType("vehicle", resourceRoot, true)) do
    for i, v in pairs(getElementsByType("vehicle")) do
        if (v) and (isElementStreamedIn(v)) then
            local vehPos = Vector2(getElementPosition(v))
            if getDistanceBetweenPoints2D(plrPos, vehPos) < settings.maxDistance then
                self:onStreamIn(v, true)
            elseif getDistanceBetweenPoints2D(plrPos, vehPos) < settings.maxDistance * 2 then
                self:onStreamIn(v)
            else
                self:onStreamOut(v)
            end
        else
            self:onStreamOut(v)
        end
    end
end


-- local veh = getPedOccupiedVehicle(localPlayer)
-- if veh then
--     setElementData(veh, "visualTuning", {
--         wheelResize = 1.4,
--         wheelTilt = -5,
--     })
-- end


Wheels:create()