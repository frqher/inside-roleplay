local sx, sy = guiGetScreenSize()
local sx2, sy2 = sx/2, sy/2

local settings = {}

Snow = {}
Snow.__index = Snow

function Snow:create()
    local instance = {}
    setmetatable(instance, Snow)
    if instance:constructor() then
        return instance
    end
    return false
end

function Snow:constructor()
    self.flakes = {}

    self.density = 200
    self.box_height = 4
    self.speed = {2, 4}
    self.size = {1, 3}
    self.jitter = true
    self.wind_direction = {-0.01, 0.01}
    self.wind_speed = 0

    self.flakeImg = dxCreateTexture("files/images/flake.png", "argb", true, "clamp")

    self.func = {}
    self.func.render = function() self:render() end

    addEventHandler("onClientRender", root, self.func.render)

    self:createBox()
    return true
end

function Snow:createBox()
    local lx, ly, lz = getWorldFromScreenPosition(0, 0, 1)
    local rx, ry, rz = getWorldFromScreenPosition(sx, 0, 1)

    self.box_width = getDistanceBetweenPoints3D(lx, ly, lz, rx, ry, rz) + 3
    self.box_depth = self.box_width

    self.box_width_doubled = self.box_width * 2
    self.box_depth_doubled = self.box_depth * 2

    lx, ly, lz = getWorldFromScreenPosition(sx2, sy2, self.box_depth)
    self.position = {lx, ly, lz}

    self:createFlakes()
end

function Snow:createFlakes()
    for i=1, self.density do
        local x, y, z = self:random(0, self.box_width_doubled), self:random(0, self.box_depth_doubled), self:random(0, self.box_height * 2)
        self:createFlake(x - self.box_width, y - self.box_depth, z - self.box_height,0)
    end
end

function Snow:createFlake(x, y, z, alpha, i)
    if self.flake_removal then
        if (self.flake_removal[2] % self.flake_removal[3]) == 0 then
            self.flake_removal[1] = self.flake_removal[1] - 1
            if self.flake_removal[1] == 0 then
                self.flake_removal = nil
            end
            table.remove(self.flakes, i)
            return
        else
            self.flake_removal[2] = self.flake_removal[2] + 1
        end
    end

    local rot = math.random(0, 180)
    if i then
        self.flakes[i] = {
            x = x, y = y, z = z,
            speed = math.random(self.speed[1], self.speed[2])/100,
            size = 2^math.random(self.size[1], self.size[2]),
            rot = rot,
            alpha = alpha,
            jitter_direction = {math.cos(math.rad(rot * 2)), -math.sin(math.rad(math.random(0, 360)))},
            jitter_cycle = rot * 2,
            jitter_speed = 8
        }
    else
        table.insert(self.flakes, {
            x = x, y = y, z = z,
            speed = math.random(self.speed[1], self.speed[2])/100,
            size = 2^math.random(self.size[1], self.size[2]),
            rot = rot,
            alpha = alpha,
            jitter_direction = {math.cos(math.rad(rot * 2)), -math.sin(math.rad(math.random(0, 360)))},
            jitter_cycle = rot * 2,
            jitter_speed = 8
        })
    end
end

function Snow:destroy()
    if isElement(self.flakeImg) then destroyElement(self.flakeImg) end
    removeEventHandler("onClientRender", root, self.func.render)
    settings.snow = nil
    self = nil
end



function Snow:render()
    if settings.snowBlocked then return end
    local tick = getTickCount()
	local cx, cy, cz = getCameraMatrix()
	local lx, ly, lz = getWorldFromScreenPosition(sx2, sy2, self.box_depth)

	if (isLineOfSightClear(cx, cy, cz, cx, cy, cz + 20, true, false, false, true, false, true, false, localPlayer) or
		isLineOfSightClear(lx, ly, lz, lx, ly, lz + 20, true, false, false, true, false, true, false, localPlayer)) then

		local check = getGroundPosition
		if testLineAgainstWater(cx, cy, cz, cx, cy, cz + 20) then
			check = getWaterLevel
		end

		local gpx, gpy, gpz = lx + (-self.box_width), ly + self.box_depth, lz + 15

		local ground = {}
		for i=1, 3 do
			local it = self.box_width_doubled * (i*0.25)
			ground[i] = {
				check(gpx + it, gpy+(self.box_depth_doubled*0.25), gpz),
				check(gpx + it, gpy+(self.box_depth_doubled*0.5), gpz),
				check(gpx + it, gpy+(self.box_depth_doubled*0.75), gpz)
			}
		end

		local dx,dy,dz = self.position[1] - lx, self.position[2] - ly, self.position[3] - lz

		for i, flake in pairs(self.flakes) do
			if flake then
				if flake.z < (-self.box_height) then
					self:createFlake(self:random(0, self.box_width*2) - self.box_width, self:random(0,self.box_depth*2) - self.box_depth, self.box_height, 0, i)
				else
					local gx, gy = 2,2
					if flake.x <= (self.box_width_doubled*0.33)-self.box_width then gx = 1
					elseif flake.x >= (self.box_width_doubled*0.66)-self.box_width then gx = 3
					end

					if flake.y <= (self.box_depth_doubled*0.33)-self.box_depth then gy = 1
					elseif flake.y >= (self.box_depth_doubled*0.66)-self.box_depth then gy = 3
					end

					if ground[gx][gy] and (flake.z+lz) > ground[gx][gy] then
						local jitter_x, jitter_y = 0, 0

						if settings.jitter then
							local jitter_cycle = math.cos(flake.jitter_cycle) / flake.jitter_speed

							jitter_x = (flake.jitter_direction[1] * jitter_cycle )
							jitter_y = (flake.jitter_direction[2] * jitter_cycle )
						end

						local draw_x, draw_y = getScreenFromWorldPosition(flake.x + lx + jitter_x, flake.y + ly + jitter_y ,flake.z + lz, 15, false)

						if draw_x and draw_y then
                            dxDrawImageSection(draw_x, draw_y, flake.size, flake.size, 0, 0, 32, 32, self.flakeImg, flake.rot, 0, 0, tocolor(255,255,255,flake.alpha))

							flake.rot = flake.rot + self.wind_speed

							if flake.alpha < 255 then
								flake.alpha = flake.alpha + 10
								if flake.alpha > 255 then flake.alpha = 255 end
							end
                        end
					end


					if self.jitter then
						flake.jitter_cycle = (flake.jitter_cycle % 360) + 0.1
					end

					flake.x = flake.x + (self.wind_direction[1] * self.wind_speed)
					flake.y = flake.y + (self.wind_direction[2] * self.wind_speed)

					flake.z = flake.z - flake.speed
					flake.x = flake.x + dx
					flake.y = flake.y + dy
					flake.z = flake.z + dz

					if flake.x < -self.box_width or flake.x > self.box_width or
						flake.y < -self.box_depth or flake.y > self.box_depth or
						flake.z > self.box_height then

						flake.x = flake.x - dx
						flake.y = flake.y - dy
						local x,y,z = (flake.x > 0 and -flake.x or math.abs(flake.x)),(flake.y > 0 and -flake.y or math.abs(flake.y)), self:random(0, self.box_height*2)

						self:createFlake(x, y, z - self.box_height, 255, i)
					end
				end
			end
		end
	end
	self.position = {lx,ly,lz}
end



function Snow:random(lower, upper)
    return lower+(math.random()*(upper-lower))
end


function createSnow()
    if settings.snow then return end
    settings.snow = Snow:create()
end

function removeSnow()
    if not settings.snow then return end
    settings.snow:destroy()
end

function setSnowBlocked(state)
    settings.snowBlocked = state
    exports.TR_dashboard:setDashboardResponseShader()
end

--local random = math.random
-- function random(lower,upper)
-- 	return lower+(math.random()*(upper-lower))
-- end

-- function startSnow()
-- 	if not snowing then
-- 		snowflakes = {}

-- 		local lx,ly,lz = getWorldFromScreenPosition(0,0,1)
-- 		local rx,ry,rz = getWorldFromScreenPosition(sx,0,1)
-- 		box_width = getDistanceBetweenPoints3D(lx,ly,lz,rx,ry,rz)+3 -- +1.5 each side of the screen
--         box_depth = box_width

--         settings.img = dxCreateTexture("files/images/real_tile.png", "argb", true, "clamp")

-- 		box_width_doubled = box_width*2
-- 		box_depth_doubled = box_depth*2

-- 		lx,ly,lz = getWorldFromScreenPosition(sx2,sy2,box_depth)
-- 		position = {lx,ly,lz}

-- 		-- let it snow
-- 		for i=1, settings.density do
-- 			local x,y,z = random(0,box_width*2),random(0,box_depth*2),random(0,box_height*2)
-- 			createFlake(x-box_width,y-box_depth,z-box_height,0)
-- 		end

-- 	--	outputChatBox(string.format("Width/Depth: %.1f",box_width))
-- 		addEventHandler("onClientRender",root,drawSnow)
-- 		snowing = true
-- 	--	outputChatBox("Snow started")
-- 		return true
-- 	else
-- 	--	outputChatBox("Its already snowing")
-- 		return false
-- 	end
-- 	return false
-- end




-- function updateSnowType(type)
-- 	if type then
-- 		settings.type = type
-- 	--	outputChatBox("Snow type set to "..type)
-- 		return true
-- 	end
-- 	return false
-- end


-- function updateSnowDensity(dense,blend,speed)
-- 	if dense and tonumber(dense) then
-- 		dense = tonumber(dense)
-- 		if snowing then
-- 			if blend then
-- 				-- if we are blending in more flakes
-- 				if dense > settings.density then
-- 					-- default speed
-- 					if not tonumber(speed) then
-- 						speed = 300
-- 					end
-- 					-- create 1/20 of the new amount every 'speed'ms for 20 iterations
-- 					setTimer(function(old,new)
-- 						for i=1, (new-old)/20, 1 do
-- 							local x,y = random(0,box_width*2),random(0,box_depth*2)
-- 							createFlake(x-box_width,y-box_depth,box_height,0)
-- 						end
-- 					end,tonumber(speed),20,settings.density,dense)

-- 				-- if we are blending out existing flakes, just flag that we should stop recreating them and check in createFlake()
-- 				elseif dense < settings.density then
-- 					if not tonumber(speed) then
-- 						speed = 10
-- 					end
-- 					flake_removal = {settings.density-dense,0,tonumber(speed)}
-- 				end

-- 				if not tonumber(speed) then
-- 					speed = 0
-- 				end
-- 			else
-- 				speed = 0
-- 				if dense > settings.density then
-- 					for i=settings.density+1, dense do
-- 						local x,y = random(0,box_width*2),random(0,box_depth*2)
-- 						createFlake(x-box_width,y-box_depth,box_height,0)
-- 					end
-- 				elseif dense < settings.density then
-- 					for i=density, dense+1, -1 do
-- 						table.remove(snowflakes,i)
-- 					end
-- 				end
-- 			end
-- 		else
-- 			speed = 0
-- 		end

-- 	--	outputChatBox("Snow density set to "..dense.." (b: "..((blend ~= nil) and "yes" or "no").." - "..((dense > settings.density) and "in" or "out").." at "..tonumber(speed).."ms : "..settings.density..","..dense..")")
-- 		settings.density = tonumber(dense)
-- 		return true
-- 	end
-- 	return false
-- end


-- function updateSnowWindDirection(xdir,ydir)
-- 	if xdir and tonumber(xdir) and ydir and tonumber(ydir) then
-- 		settings.wind_direction = {tonumber(xdir)/100,tonumber(ydir)/100}
-- 	--	outputChatBox("Snow winddirection set to "..xdir..","..ydir)
-- 		return true
-- 	end
-- 	return false
-- end


-- function updateSnowWindSpeed(speed)
-- 	if speed and tonumber(speed) then
-- 		settings.wind_speed = tonumber(speed)
-- 	--	outputChatBox("Snow windspeed set to "..settings.wind_speed)
-- 		return true
-- 	end
-- 	return false
-- end


-- function updateSnowflakeSize(min,max)
-- 	if min and tonumber(min) and max and tonumber(max) then
-- 		settings.snowflake_min_size = tonumber(min)
-- 		settings.snowflake_max_size = tonumber(max)
-- 	--	outputChatBox("Snowflake size set to "..min.." - "..max)
-- 		return true
-- 	end
-- 	return false
-- end


-- function updateSnowFallSpeed(min,max)
-- 	if min and tonumber(min) and max and tonumber(max) then
-- 		settings.fall_speed_min = tonumber(min)
-- 		settings.fall_speed_max = tonumber(max)
-- 		return true
-- 	end
-- 	return false
-- end


-- function updateSnowAlphaFadeIn(alpha)
-- 	if alpha and tonumber(alpha) then
-- 		snow_fadein = tonumber(alpha)
-- 	--	outputChatBox("Snow fade in alpha set to "..alpha)
-- 		return true
-- 	end
-- 	return false
-- end


-- function updateSnowJitter(jit)
-- 	settings.jitter = jit
-- end


-- function createFlake(x,y,z,alpha,i)
-- 	if flake_removal then
-- 		if (flake_removal[2] % flake_removal[3]) == 0 then
-- 			flake_removal[1] = flake_removal[1] - 1
-- 			if flake_removal[1] == 0 then
-- 				flake_removal = nil
-- 			end
-- 			table.remove(snowflakes,i)
-- 			return
-- 		else
-- 			flake_removal[2] = flake_removal[2] + 1
-- 		end
-- 	end

-- 	snow_id = (snow_id % 4) + 1

-- 	if i then
-- 		local randy = math.random(0,180)
-- 		snowflakes[i] = {x = x, y = y, z = z,
-- 						 speed = math.random(settings.fall_speed_min,settings.fall_speed_max)/100,
-- 						 size = 2^math.random(settings.snowflake_min_size,settings.snowflake_max_size),
-- 						 section = {(snow_id % 2 == 1) and 0 or 32,  (snow_id < 3) and 0 or 32},
-- 						 rot = randy,
-- 						 alpha = alpha,
-- 						 jitter_direction = {math.cos(math.rad(randy*2)), -math.sin(math.rad(math.random(0,360)))},
-- 						 jitter_cycle = randy*2,
-- 						 jitter_speed = 8
-- 						}
-- 	else
-- 		local randy = math.random(0,180)
-- 		table.insert(snowflakes,{x = x, y = y, z = z,
-- 								 speed = math.random(settings.fall_speed_min,settings.fall_speed_max)/100,
-- 								 size = 2^math.random(settings.snowflake_min_size,settings.snowflake_max_size),
-- 								 section = {(snow_id % 2 == 1) and 0 or 32,  (snow_id < 3) and 0 or 32},
-- 								 rot = randy,
-- 								 alpha = alpha,
-- 								 jitter_direction = {math.cos(math.rad(randy*2)), -math.sin(math.rad(math.random(0,360)))},
-- 								 jitter_cycle = randy*2,
-- 								 jitter_speed = 8
-- 								}
-- 					)
-- 	end
-- end



-- function drawSnow()
-- 	local tick = getTickCount()
-- 	local cx,cy,cz = getCameraMatrix()
-- 	local lx,ly,lz = getWorldFromScreenPosition(sx2,sy2,box_depth)

-- 	if (isLineOfSightClear(cx,cy,cz,cx,cy,cz+20,true,false,false,true,false,true,false,localPlayer) or
-- 		isLineOfSightClear(lx,ly,lz,lx,ly,lz+20,true,false,false,true,false,true,false,localPlayer)) then

-- 		local check = getGroundPosition
-- 		if testLineAgainstWater(cx,cy,cz,cx,cy,cz+20) then
-- 			check = getWaterLevel
-- 		end

-- 		local gpx,gpy,gpz = lx+(-box_width),ly+(-box_depth),lz+15

-- 		local ground = {}

-- 		for i=1, 3 do
-- 			local it = box_width_doubled*(i*0.25)
-- 			ground[i] = {
-- 				check(gpx+(it), gpy+(box_depth_doubled*0.25), gpz),
-- 				check(gpx+(it), gpy+(box_depth_doubled*0.5), gpz),
-- 				check(gpx+(it), gpy+(box_depth_doubled*0.75), gpz)
-- 			}
-- 		end

-- 		local dx,dy,dz = position[1]-lx,position[2]-ly,position[3]-lz

-- 		for i,flake in pairs(snowflakes) do
-- 			if flake then
-- 				if flake.z < (-box_height) then
-- 					createFlake(random(0,box_width*2) - box_width, random(0,box_depth*2) - box_depth, box_height, 0, i)
-- 				else
-- 					local gx,gy = 2,2
-- 					if flake.x <= (box_width_doubled*0.33)-box_width then gx = 1
-- 					elseif flake.x >= (box_width_doubled*0.66)-box_width then gx = 3
-- 					end

-- 					if flake.y <= (box_depth_doubled*0.33)-box_depth then gy = 1
-- 					elseif flake.y >= (box_depth_doubled*0.66)-box_depth then gy = 3
-- 					end

-- 					if ground[gx][gy] and (flake.z+lz) > ground[gx][gy] then
-- 						local draw_x, draw_y, jitter_x, jitter_y = nil,nil,0,0

-- 						if settings.jitter then
-- 							local jitter_cycle = math.cos(flake.jitter_cycle) / flake.jitter_speed

-- 							jitter_x = (flake.jitter_direction[1] * jitter_cycle )
-- 							jitter_y = (flake.jitter_direction[2] * jitter_cycle )
-- 						end

-- 						draw_x,draw_y = getScreenFromWorldPosition(flake.x + lx + jitter_x, flake.y + ly + jitter_y ,flake.z + lz, 15, false)

-- 						if draw_x and draw_y then
--                             dxDrawImageSection(draw_x, draw_y, flake.size, flake.size, 0, 0, 32, 32, settings.img, flake.rot, 0, 0, tocolor(255,255,255,flake.alpha))

-- 							flake.rot = flake.rot + settings.wind_speed

-- 							if flake.alpha < 255 then
-- 								flake.alpha = flake.alpha + snow_fadein
-- 								if flake.alpha > 255 then flake.alpha = 255 end
-- 							end
--                         end
-- 					end


-- 					if settings.jitter then
-- 						flake.jitter_cycle = (flake.jitter_cycle % 360) + 0.1
-- 					end

-- 					flake.x = flake.x + (settings.wind_direction[1] * settings.wind_speed)
-- 					flake.y = flake.y + (settings.wind_direction[2] * settings.wind_speed)

-- 					flake.z = flake.z - flake.speed
-- 					flake.x = flake.x + dx
-- 					flake.y = flake.y + dy
-- 					flake.z = flake.z + dz

-- 					if flake.x < -box_width or flake.x > box_width or
-- 						flake.y < -box_depth or flake.y > box_depth or
-- 						flake.z > box_height then

-- 						flake.x = flake.x - dx
-- 						flake.y = flake.y - dy
-- 						local x,y,z = (flake.x > 0 and -flake.x or math.abs(flake.x)),(flake.y > 0 and -flake.y or math.abs(flake.y)),random(0,box_height*2)

-- 						createFlake(x, y, z - box_height, 255, i)
-- 					end
-- 				end
-- 			end
-- 		end
-- 	end
-- 	position = {lx,ly,lz}
-- end


-- startSnow()