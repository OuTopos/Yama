screen = {}
screen.width, screen.height, screen.fullscreen, screen.vsync, screen.fsaa = love.graphics.getMode()
screen.modes = love.graphics.getModes()
screen.scale = 2

function screen.initiate()
	screen.canvas = love.graphics.newCanvas(screen.width/screen.scale, screen.height/screen.scale)
	screen.canvas:setFilter( "nearest", "nearest" )
	love.graphics.setDefaultImageFilter( "nearest", "nearest" )
	camera.setSize(screen.canvas:getWidth(), screen.canvas:getHeight())
end

function screen.scaleToggle()
	screen.scale = screen.scale + 1
	if screen.scale > 4 then
		screen.scale = 1
	end
	screen.canvas = nil
	screen.canvas = love.graphics.newCanvas(screen.width/screen.scale, screen.height/screen.scale)
	screen.canvas:setFilter( "nearest", "nearest" )
	camera.setSize(screen.canvas:getWidth(), screen.canvas:getHeight())
	--Only do this if not using canvas
	--camera.setScale(screen.scale, screen.scale)
	map.resetView()
	buffer.reset()
end