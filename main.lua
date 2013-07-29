yama = require("yama")

require "images"
require "physics"

require "shaders"

function love.load()
	love.graphics.setDefaultImageFilter(yama.c.imageFilter, yama.c.imageFilter)
	scaleToggle = 1

	yama.gui.load()
	vp1 = yama.viewports.new()
	arkanosPlayer = 0
	gravityfallPlayer = 0




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
		arkanos = yama.maps.load("test/arkanos")
		if arkanosPlayer == 0 then
			local player1 = arkanos.spawn("player", "start")
			vp1.view(arkanos, player1)
			vp1.setScale(4, 4)
			arkanosPlayer = 1
		elseif arkanosPlayer == 1 then
			local player2 = arkanos.spawn("player", "start")
			vp2 = yama.viewports.new()
			vp2.view(arkanos, player2)
			vp2.setScale(4, 4)


			vp1.setSize(yama.screen.width / 2, yama.screen.height)
			vp2.setSize(yama.screen.width / 2, yama.screen.height)
			vp2.setPosition(yama.screen.width / 2)
			arkanosPlayer = 2
		elseif arkanosPlayer == 2 then
			local player3 = arkanos.spawn("player", "start")
			vp3 = yama.viewports.new()
			vp3.view(arkanos, player3)
			vp3.setScale(4, 4)


			vp1.setSize(yama.screen.width / 3, yama.screen.height)
			vp2.setSize(yama.screen.width / 3, yama.screen.height)
			vp2.setPosition(yama.screen.width / 3)
			vp3.setSize(yama.screen.width / 3, yama.screen.height)
			vp3.setPosition((yama.screen.width / 3) * 2)
			arkanosPlayer = 3
		elseif arkanosPlayer == 3 then
			local player4 = arkanos.spawn("player", "start")
			vp4 = yama.viewports.new()
			vp4.view(arkanos, player4)


			vp1.setSize(yama.screen.width / 2, yama.screen.height / 2)
			
			vp2.setSize(yama.screen.width / 2, yama.screen.height / 2)
			vp2.setPosition(yama.screen.width / 2, 0)

			vp3.setSize(yama.screen.width / 2, yama.screen.height / 2)
			vp3.setPosition(0, yama.screen.height / 2)

			vp4.setSize(yama.screen.width / 2, yama.screen.height / 2)
			vp4.setPosition(yama.screen.width / 2, yama.screen.height / 2)

			vp1.setScale(2, 2)
			vp2.setScale(2, 2)
			vp3.setScale(2, 2)
			vp4.setScale(2, 2)

			arkanosPlayer = 4
		end
		--vp1.follow(player)

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
		gravityfall = yama.maps.load("test/gravityfall")

		if gravityfallPlayer == 0 then
			local player1 = gravityfall.spawn("mplayer", "start")
			vp1.view(gravityfall, player1)
			--vp1.setScale(4, 4)
			gravityfallPlayer = 1

		elseif gravityfallPlayer == 1 then
			local player2 = gravityfall.spawn("mplayer", "start2")
			vp2 = yama.viewports.new()
			vp2.view(gravityfall, player2)

			--vp2.setScale(4, 4)


			vp1.setSize(yama.screen.width / 2, yama.screen.height)
			vp2.setSize(yama.screen.width / 2, yama.screen.height)
			vp2.setPosition(yama.screen.width / 2)
			gravityfallPlayer = 2
			player2.joystick = 2
		end

	end
	if key == "a" then
		spaceMap = yama.maps.load("space/planets")
		vp1.view(spaceMap)
	end
	if key == "e" then
		arkanos.spawnXYZ("monster", math.random(100, 300), math.random(100, 300), 1)
		arkanos.spawnXYZ("humanoid", math.random(100, 300), math.random(100, 300), 1)
	end
	if key == "q" then
		jonasMap.getEntities().list[1].destroy()
		--entities.new("fplayer", math.random(100, 300), math.random(100, 300), 0, yama.viewports.list.a)
	end

	if key == "1" then
		yama.viewports.list.a.camera.setPosition(100, 100)
	end
	if key == "2" then
		jonasMap.getCamera().follow = jonasMap.getSwarm().getEntities()[math.random(1, #map1.getSwarm().getEntities())]
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
	local timescale = 1 - love.joystick.getAxis(1, 3)
	if not yama.g.paused then
		yama.maps.update(dt * timescale)
	end
end

function love.draw()
	yama.maps.draw()

	love.graphics.setColorMode("modulate")
	love.graphics.setBlendMode("additive")
	
	--love.graphics.draw(p, 0, 0)

	love.graphics.setColorMode("modulate")
	love.graphics.setBlendMode("alpha")

	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.print("FPS: "..love.timer.getFPS(), yama.screen.width - 39, 3)

	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print("FPS: "..love.timer.getFPS(), yama.screen.width - 39, 2)
end