-- Math optimization
local random = math.random
local sqrt = math.sqrt
local floor = math.floor


local pixelperfect = true

love.graphics.setDefaultImageFilter( "nearest", "nearest" )

worldWidth, worldHeight = 2000, 2000
require "images"
require "screen"
require "camera"
require "buffer"
require "hud"
require "physics"
require "entities"
require "terrain"
require "gui"
require "game"
require "sprites"
require "weather"

require "shaders"

-- Move this later
function getDistance(x1, y1, x2, y2)
	return sqrt((x1-x2)^2+(y1-y2)^2)
end

function love.load()
	--initiateFarticle()
	player = nil
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

	music = love.audio.newSource("sound/music.ogg", "static")

	time = 0
	lineNb = canvas:getHeight() * 4

	love.audio.play(music)
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

	if key == "r" then
		entities.destroy(entities.data[math.random(1, #entities.data)])
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
		love.physics.newFixture(love.physics.newBody(physics.world, 0, 0, "static"), love.physics.newChainShape(true, -1, -1, worldWidth+1, -1, worldWidth+1,worldHeight+1, -1, worldHeight+1))
		
		camera.setBoundaries(0, 0, worldWidth, worldHeight)
		player = entities.new("player", 200, 200)
		camera.follow = player
	end
	if key == "a" then
		if player then
			entities.destroy(player)
			player = nil
			--collectgarbage()
		end
	end
	if key == "e" then
		for i=1,50 do
			entities.new("tree", math.random(1, worldWidth), math.random(1, worldHeight))
			entities.new("coin", math.random(1, worldWidth), math.random(1, worldHeight))
			entities.new("monster", math.random(1, worldWidth), math.random(1, worldHeight))
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
	time = time+dt
	physics.update(dt)
	entities.update(dt)
	camera.update()
	--updateFarticle(dt)

	--map.update(camera.x, camera.y)
end

function love.draw()
	camera.set()

	
	-- Draw the sprite buffer
	--if next(buffer.data) == nil then
	--	entities.draw()
	--	map.draw()
	--end



	love.graphics.setCanvas(canvas)
	terrain.draw()

	entities.draw()

	-- Draw env stuff
	--drawFarticle()

	buffer.draw()

	-- Draw the GUI
	gui.draw()

	-- Draw the HUD
	hud.draw()
	love.graphics.setCanvas()

	

	camera.unset()

	love.graphics.clear()

	effect:send("time",time)
	effect:send("nIntensity", 0.25)
	effect:send("sIntensity", 0.25)
	effect:send("sCount", lineNb)

	love.graphics.setPixelEffect(effect)
	love.graphics.draw(canvas, 0, 0, 0, 2, 2)
	love.graphics.setPixelEffect()
end