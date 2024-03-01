local watchInfo = {
    shader = dxCreateShader([[
        texture gTexture;
        technique TexReplace
        {
            pass P0
            {
                Texture[0] = gTexture;
            }
        }
    ]], 0, 0, false, "object"),

    texture = dxCreateTexture("files/images/needle.png", "argb", true, "clamp"),
}
dxSetShaderValue(watchInfo.shader, "gTexture", watchInfo.texture)

Watch = {}
Watch.__index = Watch

function Watch:create(...)
    local instance = {}
    setmetatable(instance, Watch)
    if instance:constructor(...) then
        return instance
    end
    return false
end

function Watch:constructor(...)
    self.rotation = arg[2]
    self.multiplayer = arg[3]

    self.seconds = createObject(968, arg[1], 0, 0, 90)
    setObjectScale(self.seconds, 0.2)

    self.minute = createObject(968, arg[1], 0, 0, 90)
    setObjectScale(self.minute, 0.16)

    self.hour = createObject(968, arg[1], 0, 0, 90)
    setObjectScale(self.hour, 0.12)

    self.center = createObject(3106, arg[1], 0, 0, 0)
    setObjectScale(self.center, 1.6)

    engineApplyShaderToWorldTexture(watchInfo.shader, "*", self.seconds)
    engineApplyShaderToWorldTexture(watchInfo.shader, "*", self.minute)
    engineApplyShaderToWorldTexture(watchInfo.shader, "*", self.hour)
    engineApplyShaderToWorldTexture(watchInfo.shader, "*", self.center)

    self.func = {}
    self.func.updateClock = function() self:updateClock() end
    setTimer(self.func.updateClock, 1000, 0)
    return true
end

function Watch:updateClock()
    local time = getRealTime()

    local secRot = (time.second / 60) * 360
    setElementRotation(self.seconds, self.rotation.x + secRot * self.multiplayer.x, self.rotation.y + secRot * self.multiplayer.y, self.rotation.z + secRot * self.multiplayer.z)

    local minuteRot = (time.minute / 60) * 360
    setElementRotation(self.minute, self.rotation.x + minuteRot * self.multiplayer.x, self.rotation.y + minuteRot * self.multiplayer.y, self.rotation.z + minuteRot * self.multiplayer.z)

    local hourRot = ((time.hour / 12 - 2) * 360) - 150
    setElementRotation(self.hour, self.rotation.x + hourRot * self.multiplayer.x, self.rotation.y + hourRot * self.multiplayer.y, self.rotation.z + hourRot * self.multiplayer.z)
end

Watch:create(Vector3(1735.58, -1869.6, 31.64), Vector3(0, 0, 90), Vector3(0, 1, 0))
Watch:create(Vector3(1729.04, -1869.6, 31.64), Vector3(0, 0, 90), Vector3(0, -1, 0))
Watch:create(Vector3(1732.16, -1866.50, 31.64), Vector3(0, 0, 0), Vector3(0, -1, 0))
Watch:create(Vector3(1732.16, -1872.74, 31.64), Vector3(0, 0, 0), Vector3(0, 1, 0))