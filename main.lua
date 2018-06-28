love.math.setRandomSeed(os.time())
local sw, sh = love.graphics.getDimensions()

local c = {w=50, h=50, x0=0, y0=0, x1=sw, y1=sh, maxValue=1}
for y = 1, c.h do
	c[y] = {}
	for x = 1, c.w do
		c[y][x] = {math.sin(y/5), math.cos(x/10)}
	end
end

local fps = 1/60
function love.update(dt)
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end
	
	fps = 1/dt
end

function love.draw()
	for yi = 1, c.h do
		for xi = 1, c.w do
			local xScale = (c.x1-c.x0)/c.w
			local yScale = (c.y1-c.y0)/c.h
			local x0 = xi*xScale+c.x0
			local y0 = yi*yScale+c.y0
			local v = c[yi][xi]
			
			local length = math.sqrt(v[1]^2 + v[2]^2)
			local x1, y1 = 0, 0
			if length > 0 then
				x1 = x0 + v[1]/c.maxValue*xScale/2
				y1 = y0 + v[2]/c.maxValue*yScale/2
			end
			
			love.graphics.line(x0, y0, x1, y1)
		end
	end
	
	love.graphics.print(fps)
end