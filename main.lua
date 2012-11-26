-- Math optimization
local random = math.random
local sqrt = math.sqrt



worldWidth, worldHeight = 2000, 2000
require "screen"
require "camera"
require "physics"
require "entities"
require "terrain"
require "gui"
require "hud"
require "game"
require "sprites"

-- Move this later
function getDistance(x1, y1, x2, y2)
	return sqrt((x1-x2)^2+(y1-y2)^2)
end

function love.load()
	player = nil

	--love.graphics.setDefaultImageFilter( "nearest", "nearest" )
	--love.graphics.setMode(screen.width, screen.height, false, true, 0) --set the window dimensions to 650 by 650 with no fullscreen, vsync on, and no antialiasing

	imagefont2 = love.graphics.newImage("images/imagefont2.png")
	font2 = love.graphics.newImageFont(imagefont2,
	" abcdefghijklmnopqrstuvwxyz" ..
	"ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
	"123456789.,!?-+/():;%&`'*#=[]\"")

	imagefont = love.graphics.newImage("images/font.png")
	font = love.graphics.newImageFont(imagefont," abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?-+/():;%&`'*#=[]\"")
	love.graphics.setFont(font)

	gui.load()
	--camera.setScale(screen.height/1080, screen.height/1080)
end

function love.keypressed(key)
	if key == "escape" then
		love.event.push("quit")
	end
	if key == "h" then
		if hud.enabled then
			hud.enabled = false
		else
			hud.enabled = true
		end
	end
	if key == "p" then
		if physics.enabled then
			physics.enabled = false
		else
			physics.enabled = true
		end
	end

	if key == "g" then
		physics.world:setGravity(0, 90)
	end
	if key == "t" then
		camera.follow = entities.new("turret", player.getX(), player.getY())
	end
	if key == "b" then
		entities.new("ball", player.getX(), player.getY())
	end
	if key == "s" then
		physics.setWorld("world", 0, 0, 32, false)
		physics.newObject(love.physics.newBody(physics.world, 0, 0, "static"), love.physics.newChainShape(true, -1, -1,      worldWidth+1,-1,     worldWidth+1,worldHeight+1,       -1,worldHeight+1))
		camera.setBoundaries(0, 0, worldWidth, worldHeight)
		player = entities.new("player", 200, 200)
		camera.follow = player



	end
	if key == "d" then
		map.load("cubicles", "", "isometropolis")
	end
	if key == "e" then
		for i=1,50 do
			entities.new("tree", math.random(1, worldWidth), math.random(1, worldHeight))
			entities.new("coin", math.random(1, worldWidth), math.random(1, worldHeight))
		end
	end

	if key == "1" then
		camera.follow = entities.data[1]
	end
	if key == "2" then
		camera.follow = entities.data[math.random(1, #entities.data)]
	end
	if key == "0" then
		screen.scaleToggle()
	end
end

function love.update(dt)
	physics.update(dt)
	entities.update(dt)
	camera.update()
	env.update(dt)

	--map.update(camera.x, camera.y)
end

function love.draw()
	camera.set()

	
	-- Draw the sprite buffer
	--if next(buffer.data) == nil then
	--	entities.draw()
	--	map.draw()
	--end
	terrain.draw()

	entities.draw()

	-- Draw env stuff
	--env.draw()

	-- Draw the GUI
	gui.draw()

	-- Draw the HUD
	hud.draw()

	camera.unset()
end