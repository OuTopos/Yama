yama = require("yama")

require "images"
require "physics"
--entities = require "entities"
require "game"

require "shaders"

function love.load()
	love.graphics.setDefaultImageFilter(yama.c.imageFilter, yama.c.imageFilter)
	--scaleToggle = 1

	yama.gui.load()
	vp1 = yama.viewports.new(0, 0, 0, yama.screen.width, yama.screen.height, 1, 1, false)
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
		jonasMap = yama.maps.load("test/arkanos")
		vp1.view(jonasMap)

		--vp2 = yama.viewports.new(yama.screen.width/2+5, 0, 0, yama.screen.width/2-5, yama.screen.height, 2, 2, true)
		--vp2.view(map1)
	end
	if key == "d" then
		yama.maps.load("test/house1_room1", "door1")
	end
	if key == "x" then
		yama.maps.load("test/platform", "test")	
	end
	if key == "z" then
		matMap = yama.maps.load("test/gravityfall")
		vp1.view(matMap)
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

		map1.getSwarm().insert(yama.entities.new(map1, "monster", math.random(100, 300), math.random(100, 300), 0))
		map1.getSwarm().insert(yama.entities.new(map1, "humanoid", math.random(100, 300), math.random(100, 300), 0))
	end
	if key == "q" then
		local ents = entities.data[yama.viewports.list.a.getMap()]
		ents[#ents].destroy()
		--entities.new("fplayer", math.random(100, 300), math.random(100, 300), 0, yama.viewports.list.a)
	end

	if key == "1" then
		yama.viewports.list.a.camera.setPosition(100, 100)
	end
	if key == "2" then
		vp2.getCamera().follow = map1.getSwarm().getEntities()[math.random(1, #map1.getSwarm().getEntities())]
	end
	if key == "0" then
		scaleToggle = scaleToggle + 1
		if scaleToggle > 5 then
			scaleToggle = 1
		end
		yama.viewports.list.a.setScale(scaleToggle)
	end
end

function love.update(dt)
	if not yama.g.paused then
		yama.maps.update(dt)
	end
end

function love.draw()
	yama.maps.draw()

	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.print("FPS: "..love.timer.getFPS(), yama.screen.width - 39, 3)

	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print("FPS: "..love.timer.getFPS(), yama.screen.width - 39, 2)
end