love.math.setRandomSeed(os.time())

local function hslToRgb(h, s, l)
    if s == 0 then
        return 1, 1, 1--achromatic
    else
		local hue2rgb = function(p, q, t)
            if t < 0 then t = t + 1 end
            if t > 1 then t = t - 1 end
            if t < 1/6 then return p + (q - p) * 6 * t end
            if t < 1/2 then return q end
            if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
            return p
        end

		local q = (l < 0.5) and (l * (1 + s)) or (l + s - l * s)
        local p = 2 * l - q
		
		local r = hue2rgb(p, q, h + 1/3)
        local g = hue2rgb(p, q, h)
        local b = hue2rgb(p, q, h - 1/3)
		return r, g, b
    end
end

local function clamp(x, min, max)
	if x < min then return min end
	if x > max then return max end
	return x
end


local sw, sh = love.graphics.getDimensions()


local fw, fh = 10, 10
local fx0, fy0 = 0, 0
local fx1, fy1 = sw, sh
local function fToScreen(fx, fy) 
	local sx = fx*(fx1-fx0)/fw + fx0
	local sy = fy*(fy1-fy0)/fh + fy0
	return sx, sy
end
local function screenToF(sx, sy)
	local fx = (sx-fx0)*fw/(fx1-fx0)
	local fy = (sy-fy0)*fh/(fy1-fy0)
	return fx, fy
end

	
local c = {w=50, h=50, x0=0, y0=0, x1=fw, y1=fh, maxValue=1.5}
for y = 1, c.h do
	c[y] = {}
	for x = 1, c.w do
		c[y][x] = {0, 0}
	end
end
local function cToScreen(cx, cy)
	local fx = cx/c.w*(c.x1-c.x0)+c.x0
	local fy = cy/c.h*(c.y1-c.y0)+c.y0
	local sx, sy = fToScreen(fx, fy)
	return sx, sy
end


local couple = {}
couple[1] = {length=2, k=100, {x=fw/2, y=fh/2, vx=0, vy=0}, {x=fw/2+2, y=fh/2, vx=0, vy=0}}


local fps = 1/60
local t = 0
local mouse, mouseX, mouseY = 0, 0, 0
local selected = {0, 0}
function love.update(dt)
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end
	
	fps = 1/dt
	t = t + dt
	
	if love.mouse.isDown(1) then
		if mouse == 0 or mouse == 3 then
			mouse = 1
		elseif mouse == 1 then
			mouse = 2
		end
	else
		if mouse == 1 or mouse == 2 then
			mouse = 3 
		elseif mouse == 3 then
			mouse = 0
		end
	end
	mouseX, mouseY = love.mouse.getPosition()
	
	if love.keyboard.isDown("space") then
		for ic, c in ipairs(couple) do
			c[1].vx, c[1].vy = 0, 0
			c[2].vx, c[2].vy = 0, 0
		end
	end
	
	
	
	if mouse == 1 then
		for i = 1, #couple do
			for j = 1, 2 do
				local sx, sy = fToScreen(couple[i][j].x, couple[i][j].y)
				if mouseX-8 <= sx and sx <= mouseX+8 and
				   mouseY-8 <= sy and sy <= mouseY+8 then
					selected = {i, j}
					break
				end
			end
		end
	end
	
	if selected[1] > 0 then
		local mfx, mfy = screenToF(mouseX, mouseY)
		couple[selected[1]][selected[2]].x = mfx
		couple[selected[1]][selected[2]].y = mfy
	end
	
	if mouse == 3 then
		selected = {0, 0}
	end
	
	
	for ic, c in ipairs(couple) do
		local vec = {c[2].x-c[1].x, c[2].y-c[1].y}
		local distance = math.sqrt(vec[1]^2 + vec[2]^2)
		
		local acc_abs = c.k*(distance - c.length)/2
		local acc_vec = {vec[1]/distance*acc_abs, vec[2]/distance*acc_abs}
		
		c[1].vx = c[1].vx + acc_vec[1]*dt
		c[1].vy = c[1].vy + acc_vec[2]*dt
		c[2].vx = c[2].vx - acc_vec[1]*dt
		c[2].vy = c[2].vy - acc_vec[2]*dt
		
		c[1].x = c[1].x + c[1].vx*dt
		c[1].y = c[1].y + c[1].vy*dt
		c[2].x = c[2].x + c[2].vx*dt
		c[2].y = c[2].y + c[2].vy*dt
	end
end


function love.draw()
	love.graphics.setPointSize(1)
	for yi = 1, c.h do
		for xi = 1, c.w do
			local sxi, syi = cToScreen(xi, yi)
			
			local v = c[yi][xi]
			local length = math.sqrt(v[1]^2 + v[2]^2)
			
			if length > 0 then
				local arrowX = v[1]/length
				local arrowY = v[2]/length

				local x2 = xi + arrowX/2
				local y2 = yi + arrowY/2
				local sx2, sy2 = cToScreen(x2, y2)
				
				local x1 = x2 - arrowY/10 - arrowX/10
				local y1 = y2 + arrowX/10 - arrowY/10
				local sx1, sy1 = cToScreen(x1, y1)
				
				local x3 = x2 + arrowY/10 - arrowX/10
				local y3 = y2 - arrowX/10 - arrowY/10
				local sx3, sy3 = cToScreen(x3, y3)
				
				local colorScale = clamp(length/c.maxValue, 0, 1)
				local r, g, b = hslToRgb(1/3-colorScale/3,  0.2+colorScale*0.6,  0.2+colorScale*0.4)
				love.graphics.setColor(r, g, b)
				
				love.graphics.line(sxi, syi, sx2, sy2)
				love.graphics.line(sx1, sy1, sx2, sy2, sx3, sy3)
			else
				love.graphics.points(sxi, syi)
			end
		end
	end
	love.graphics.setColor(1, 1, 1)
	
	love.graphics.setPointSize(16)
	for ic, c in ipairs(couple) do
		local x1, y1 = fToScreen(c[1].x, c[1].y)
		local x2, y2 = fToScreen(c[2].x, c[2].y)
		love.graphics.points(x1, y1, x2, y2)
	end
	
	local mx, my = love.mouse.getPosition()
	love.graphics.print(fps)
end