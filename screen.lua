screen = {}
screen.width, screen.height, screen.fullscreen, screen.vsync, screen.fsaa = love.graphics.getMode()
screen.modes = love.graphics.getModes()

local scale = 1 --screen.height/1080
local toggle = 1

function screen.scaleToggle()
	toggle = toggle + 1
	if toggle > 4 then
		toggle = 1
	end

	--love.graphics.setMode(screen.width*screen.scale, screen.height*screen.scale, false, true)
	camera.setScale(scale*toggle, scale*toggle)
end
canvas = love.graphics.newCanvas(512, 288)
canvas:setFilter( "nearest", "nearest" )
print(screen.width)