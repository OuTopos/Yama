yama = require("yama")

require "images"
require "buffer"
require "physics"
require "entities"
require "game"

require "shaders"

function love.load()
	yama.screen.load()
	yama.gui.load()

	--music = love.audio.newSource("sound/music.ogg", "static")
	--music:setLooping(true)
	--love.audio.play(music)
end

function love.keypressed(key)
	if key == "escape" then
		love.event.push("quit")
	end
	if key == "h" then
		if yama.hud.enabled then
			yama.hud.enabled = false
		else
			yama.hud.enabled = true
		end
	end
	if key == "p" then
		if yama.g.paused then
			yama.g.paused = false
		else
			yama.g.paused = true
		end
	end
	if key == "l" then
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
		yama.camera.follow = entities.new("turret", player.getX(), player.getY())
	end
	if key == "b" then
		entities.new("ball", player.getX(), player.getY())
	end
	if key == "s" then
		yama.map.load("test/arkanos", "door1")
	end
	if key == "d" then
		yama.map.load("test/house1_room1", "door1")
	end
	if key == "x" then
		yama.map.load("test/platform", "test")	
	end
	if key == "z" then
		yama.map.load("test/gravityfall", "test")	
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
			--entities.new("coin", math.random(1, yama.camera.width), math.random(1, yama.camera.height), 0)
			--entities.new("monster", math.random(100, 300), math.random(100, 300), 0)
		end

		entities.new("monster", math.random(100, 300), math.random(100, 300), 0)
		entities.new("humanoid", math.random(100, 300), math.random(100, 300), 0)
	end

	if key == "1" then
		yama.camera.follow = entities.data[1]
	end
	if key == "2" then
		yama.camera.follow = entities.data[math.random(1, #entities.data)]
	end
	if key == "0" then
		yama.screen.scaleToggle()
	end
end

function love.update(dt)
	if not yama.g.paused then
		physics.update(dt)
		entities.update(dt)
		yama.camera.update(dt)
		yama.map.update(dt)
	end
end

function love.draw()
	yama.camera.set()
	love.graphics.setCanvas(yama.screen.canvas)

	-- Check if the buffer has been reset 
	--if next(buffer.data) == nil then
		entities.addToBuffer()
		yama.map.addToBuffer()
	--end

	-- Draw the buffer
	buffer.draw()

	-- Draw the GUI
	yama.gui.draw()

	-- Draw the HUD
	yama.hud.draw()

	yama.camera.unset()
	love.graphics.setCanvas()

	love.graphics.draw(yama.screen.canvas, 1, 0, 0, yama.screen.sx, yama.screen.sy)
	buffer.reset()
end