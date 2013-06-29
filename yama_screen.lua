local screen = {}
screen.width, screen.height, screen.fullscreen, screen.vsync, screen.fsaa = love.graphics.getMode()
screen.modes = love.graphics.getModes()
screen.sx = 1
screen.sy = 1

love.graphics.setDefaultImageFilter( "nearest", "nearest" )

--function screen.load()
--	screen.canvas = love.graphics.newCanvas((screen.width/screen.sx)/2, screen.height/screen.sy)
--	screen.canvas:setFilter( "nearest", "nearest" )
--	love.graphics.setDefaultImageFilter( "nearest", "nearest" )
--	camera.setSize(screen.canvas:getWidth(), screen.canvas:getHeight())
--end

--function screen.setScale(sx, sy)
--	screen.sx = sx or 1
--	screen.sy = sy or sx or 1
--	screen.load()
--	if yama.map.loaded then
--		yama.map.resetView()
--	end
--	buffer.reset()
--end




-- Temporary scale toggle
--screen.toggle = 1
--function screen.scaleToggle()
--	screen.toggle = screen.toggle + 1
--	if screen.toggle > 4 then
--		screen.toggle = 1
--	end
--	screen.setScale(screen.toggle)
--end

return screen