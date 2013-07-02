yama = require("yama")

require "images"
require "physics"
require "entities"
require "game"

require "shaders"

function love.load()
	love.graphics.setDefaultImageFilter(yama.c.imageFilter, yama.c.imageFilter)
	scaleToggle = 1

	test = {}
	test.ettett = "jadå!!!!!"
	lala = "ett"
	print(test["ett"..lala])

	yama.gui.load()

	--music = love.audio.newSource("sound/music.ogg", "static")
	--music:setLooping(true)
	--love.audio.play(music) 
	vp1 = yama.viewports.new(0, 0, 0, yama.screen.width/2-5, yama.screen.height, 2, 2, false)
	vp2 = yama.viewports.new(yama.screen.width/2+5, 0, 0, yama.screen.width/2-5, yama.screen.height, 2, 2, true)
	--vp3 = yama.viewports.new(yama.screen.width/2-100, 100, 0, 200, 200, 1, 1, true)
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
		vp1.map.load("test/arkanos", "door1", vp1)
		vp2.map.load("test/house1_room1", "door1", vp2)
	end
	if key == "d" then
		yama.maps.load("test/house1_room1", "door1")
	end
	if key == "x" then
		yama.maps.load("test/platform", "test")	
	end
	if key == "z" then
		vp1.map.load("test/gravityfall", "test", vp1)
		vp1.setSize(yama.screen.width, yama.screen.height, 1, 1, false)
		vp2.x = yama.screen.width
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

		entities.new("monster", math.random(100, 300), math.random(100, 300), 0, vp1)
		entities.new("humanoid", math.random(100, 300), math.random(100, 300), 0, vp1)
	end

	if key == "1" then
		vp1.camera.setPosition(100, 100)
	end
	if key == "2" then
		vp1.camera.follow = entities.data[math.random(1, #entities.data)]
		--vp3.camera.follow = entities.data[math.random(1, #entities.data)]
	end
	if key == "0" then
		scaleToggle = scaleToggle + 1
		if scaleToggle > 5 then
			scaleToggle = 1
		end
		vp1.setScale(scaleToggle)
	end
end

function love.update(dt)
	if not yama.g.paused then
		--physics.update(dt)
		--entities.update(dt)
		--camera.update(dt)
		--yama.map.update(dt)
		vp1.update(dt)
		vp2.update(dt)
		--vp3.update(dt)

		--vp3.r = vp3.r + (1 * dt)

		vp1.updated()
		vp2.updated()
	end
end

function love.draw()
	vp1.draw()
	vp2.draw()
	--vp3.draw()

	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.print("FPS: "..love.timer.getFPS(), yama.screen.width - 39, 3)

	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print("FPS: "..love.timer.getFPS(), yama.screen.width - 39, 2)
end