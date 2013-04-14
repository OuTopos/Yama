-- Math optimization
local random = math.random
local sqrt = math.sqrt
local floor = math.floor


--local pixelperfect = true
require "images"
require "screen"
require "camera"
require "buffer"
require "hud"
require "physics"
require "entities"
require "animations"
require "patrols"
require "gui"
require "game"
require "weather"

require "shaders"
require "map"

-- Move this later
function getDistance(x1, y1, x2, y2)
	return sqrt((x1-x2)^2+(y1-y2)^2)
end

function getRelativeDirection(r)
	--if r < 0 then
	--	r = 4*math.pi/2+r
	--elseif r >= 4*math.pi/2 then
	--	while r >= 4*math.pi/2 do
	--		r = r - 4*math.pi/2
	--	end
	--end

	local i = math.floor(r / (math.pi/2) + 0.5)
	
	while i < 0 do
		i = i + 4
	end
	while i >= 4 do
		i = i - 4
	end

	if i == 0 then
		return "right"
	elseif i == 1 then
		return "down"
	elseif i == 2 then
		return "left"
	elseif i == 3 then
		return "up"
	else
		print("retard "..i..r)
	end
end

function love.load()
	screen.initiate()
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

	--music = love.audio.newSource("sound/music.ogg", "static")
	--music:setLooping(true)

	time = 0
	lineNb = screen.canvas:getHeight() * 4

	--love.audio.play(music)
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
		map.load("test/arkanos", "door1")
	end
	if key == "d" then
		map.load("test/house1_room1", "door1")
	end
	if key == "x" then
		map.load("test/platform", "test")	
	end
	if key == "z" then
		map.load("test/gravityfall", "test")	
	end
	if key == "a" then
		if player then
			entities.destroy(player)
			player = nil
			--collectgarbage()
		end
	end
	if key == "e" then
		for i=1,10 do
			--entities.new("tree", math.random(1, worldWidth), math.random(1, worldHeight))
			--entities.new("coin", math.random(1, camera.width), math.random(1, camera.height), 0)
			entities.new("humanoid", math.random(100, 300), math.random(100, 300), 0)
			entities.new("monster", math.random(100, 300), math.random(100, 300), 0)
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
	camera.update(dt)
	map.update(dt)
end

function love.draw()
	camera.set()
	love.graphics.setCanvas(screen.canvas)

	-- Check if thr buffer has been reset 
	if next(buffer.data) == nil then
		entities.addToBuffer()
		map.addToBuffer()
	end

	-- Draw the buffer
	buffer.draw()

	-- Draw the GUI
	gui.draw()

	-- Draw the HUD
	hud.draw()

	camera.unset()
	love.graphics.setCanvas()
	love.graphics.clear()

	-- Pixel shader n stuff
	--lineNb = screen.canvas:getHeight() * 4
	--effect:send("time",time)
	--effect:send("nIntensity", 0.75)
	--effect:send("sIntensity", 0.1)
	--effect:send("sCount", lineNb)

	--love.graphics.setPixelEffect(effect)
	love.graphics.draw(screen.canvas, 0, 0, 0, screen.sx, screen.sy)
	--love.graphics.setPixelEffect()
end