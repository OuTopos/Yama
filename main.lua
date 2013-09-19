yama = require("yama")

require "images"

--require "shaders"

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
	if key == "j" then
		if yama.hud.physics then
			yama.hud.physics = false
		else
			yama.hud.physics = true
		end
	end

	if key == "p" then
		if yama.g.paused then
			yama.g.paused = false
		else
			yama.g.paused = true
		end
	end

	-- ARKANOS
	if key == "1" then
		arkanos = yama.maps.load("test/start")
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
	end

	-- CUBICLES
	if key == "2" then
		arkanos = yama.maps.load("test/cubicles")
		if arkanosPlayer == 0 then
			local player1 = arkanos.spawn("player", "start")
			vp1.view(arkanos, player1)
			vp1.setScale(4, 4)
			arkanosPlayer = 1
		end
	end

	-- GRAVITYFALL
	if key == "z" then
		gravityfall = yama.maps.load("test/gravityfall")

		if gravityfallPlayer == 0 then
			player1 = gravityfall.spawn("mplayer", "start")
			vp1.view(gravityfall, player1)
			--vp1.setScale(4, 4)
			gravityfallPlayer = 1
		
		elseif gravityfallPlayer == 1 then
			player2 = gravityfall.spawn("mplayer", "start2")
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

	if key == 'v' then
		if player1.destroyed then
			player1 = gravityfall.spawn("mplayer", "start")
			vp1.view(gravityfall, player1)
		end
		if player2.destroyed then
			player2 = gravityfall.spawn("mplayer", "start2")
			vp2.view(gravityfall, player2)
			player2.joystick = 2
		end
	end

	if key == "a" then
		spaceMap = yama.maps.load("space/planets")
		vp1.view(spaceMap)
	end
	if key == "e" then
		arkanos.spawnXYZ("monster", math.random(100, 300), math.random(100, 300), 32)
		arkanos.spawnXYZ("humanoid", math.random(100, 300), math.random(100, 300), 32)
	end
	if key == "q" then
		jonasMap.getEntities().list[1].destroy()
		--entities.new("fplayer", math.random(100, 300), math.random(100, 300), 0, yama.viewports.list.a)
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
	--local start_time = os.clock()


	local timescale = 1 - love.joystick.getAxis(1, 3)
	if not yama.g.paused then
		yama.maps.update(dt * timescale)
	end


	--local end_time = os.clock()
	--print("UPDATE: "..end_time - start_time)
end

function love.draw()
	--local start_time = os.clock()


	-- DRAW MAPS
	yama.maps.draw()

	---[[ FPS TIMER
	local fps = love.timer.getFPS()
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.print("FPS: "..fps, yama.screen.width - 39, 3)

	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print("FPS: "..fps, yama.screen.width - 39, 2)
	--]]


	--local end_time = os.clock()
	--print("DRAW: "..end_time - start_time)
end