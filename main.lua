yama = require("yama")

require "images"
require "physics"

require "shaders"

function love.load()
	love.graphics.setDefaultImageFilter(yama.c.imageFilter, yama.c.imageFilter)
	scaleToggle = 1

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
		jonasMap.spawn("monster", math.random(100, 300), math.random(100, 300), 0)
		jonasMap.spawn("humanoid", math.random(100, 300), math.random(100, 300), 0)
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

	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.print("FPS: "..love.timer.getFPS(), yama.screen.width - 39, 3)

	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print("FPS: "..love.timer.getFPS(), yama.screen.width - 39, 2)
end