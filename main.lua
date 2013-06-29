yama = require("yama")

require "images"
--require "buffer"
require "physics"
require "entities"
require "game"

require "shaders"

function love.load()
	--buffer = yama.buffers.new()
	--camera = yama.cameras.new()
	--yama.screen.load()
	yama.gui.load()

	--music = love.audio.newSource("sound/music.ogg", "static")
	--music:setLooping(true) x, y, r, width, height, sx, sy, zoom
	--love.audio.play(music) 
	vp1 = yama.viewports.new("vp1", 0, 0, 0, yama.screen.width/2, yama.screen.height, 2, 2, true)
	vp2 = yama.viewports.new("vp2", yama.screen.width/2, 0, 0, yama.screen.width/2, yama.screen.height, 2, 2, true)
	--vp3 = yama.viewports.new("vp3", yama.screen.width/2-100, 100, 0, 200, 200, 1, 1, true)
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
		camera.follow = entities.new("turret", player.getX(), player.getY())
	end
	if key == "b" then
		if buffer.enabled then
			buffer.enabled = false
		else
			buffer.enabled = true
		end

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
			--entities.new("coin", math.random(1, camera.width), math.random(1, camera.height), 0)
			--entities.new("monster", math.random(100, 300), math.random(100, 300), 0)
		end

		entities.new("monster", math.random(100, 300), math.random(100, 300), 0)
		entities.new("humanoid", math.random(100, 300), math.random(100, 300), 0)
	end

	if key == "1" then
		vp1.camera.setPosition(100, 100)
	end
	if key == "2" then
		vp1.camera.follow = entities.data[math.random(1, #entities.data)]
		--vp3.camera.follow = entities.data[math.random(1, #entities.data)]
	end
	if key == "0" then
		yama.screen.scaleToggle()
	end
end

function love.update(dt)
	if not yama.g.paused then
		physics.update(dt)
		--entities.update(dt)
		--camera.update(dt)
		--yama.map.update(dt)
		vp1.update(dt)
		vp2.update(dt)
		--vp3.update(dt)

		--vp3.r = vp3.r + (1 * dt)

		entities.updated = false
	end
end

function love.draw()
	--camera.set()
	--love.graphics.setCanvas(yama.screen.canvas)

	-- Check if the buffer has been reset 
	--if next(buffer.data) == nil then
		--entities.addToBuffer()
		--yama.map.addToBuffer()
	--end

	-- Draw the buffer
	--buffer.draw()

	-- Draw the GUI
	--yama.gui.draw()

	-- Draw the HUD
	--yama.hud.draw()

	--camera.unset()
	--love.graphics.setCanvas()

	--love.graphics.draw(yama.screen.canvas, 0, 0, 0, yama.screen.sx, yama.screen.sy)

	vp1.draw()
	vp2.draw()
	--vp3.draw()
end