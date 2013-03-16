hud = {}
hud.enabled = false

function hud.draw()
	if hud.enabled then
		local lh = 10

		physics.draw()

		-- Entities
		for i = 1, #entities.buffer.data do
			if camera.isInside(entities.buffer.data[i].getOX(), entities.buffer.data[i].getOY(), entities.buffer.data[i].getWidth(), entities.buffer.data[i].getHeight()) then
				love.graphics.setColor(0, 0, 0, 255)
				love.graphics.print(i.." "..entities.buffer.data[i].getY()+entities.buffer.data[i].getZ(), entities.buffer.data[i].getX(), entities.buffer.data[i].getY()+2)
				love.graphics.circle("fill", entities.buffer.data[i].getX(), entities.buffer.data[i].getY(), 1)
				love.graphics.setColor(255, 0, 0, 255)
				love.graphics.rectangle( "line", entities.buffer.data[i].getOX(), entities.buffer.data[i].getOY(), entities.buffer.data[i].getWidth(), entities.buffer.data[i].getHeight() )
			end
		end
		
		-- Debug text.
		
		-- Backgrounds
		love.graphics.setColor(0, 0, 0, 204)
		love.graphics.rectangle("fill", camera.x, camera.y, 100, camera.height)
		love.graphics.rectangle("fill", camera.x+camera.width-120, camera.y, 120, 200)

		-- Text color
		love.graphics.setColor(0, 255, 0, 255)

		-- Text top left
		love.graphics.print("FPS: "..love.timer.getFPS(), camera.x + 2, camera.y + 2)
		love.graphics.print("Camera: "..math.floor( camera.x / map.loaded.tilewidth)..":"..math.floor( camera.y / map.loaded.tileheight), camera.x + 2, camera.y + 22)
		love.graphics.print("  x = "..camera.x.." "..camera.boundaries.x.." "..camera.boundaries.width, camera.x + 2, camera.y + 32)
		love.graphics.print("  y = "..camera.y , camera.x + 2, camera.y + 42)
		love.graphics.print("  width = "..camera.width , camera.x + 2, camera.y + 52)
		love.graphics.print("  height = "..camera.height , camera.x + 2, camera.y + 62)
		love.graphics.print("  sx = "..camera.sx , camera.x + 2, camera.y + 72)
		love.graphics.print("  sy = "..camera.sy , camera.x + 2, camera.y + 82)
		--92
		love.graphics.print("Entities:  "..#entities.data, camera.x + 2, camera.y + 102)
		love.graphics.print("  in Buffer: "..#entities.buffer.data, camera.x + 2, camera.y + 112)
		--122
		if physics.world then
			love.graphics.print("Physics:   "..physics.world:getBodyCount(), camera.x + 2, camera.y + 132)
		end
		-- 142
		if player then
			love.graphics.print("Player: "..math.floor( player.getX() / map.loaded.tilewidth)..":"..math.floor( player.getY() / map.loaded.tileheight), camera.x + 2, camera.y + 152)
			love.graphics.print("  x = "..player.getX(), camera.x + 2, camera.y + 162)
			love.graphics.print("  y = "..player.getY(), camera.x + 2, camera.y + 172)
			love.graphics.print("  z = "..player.getZ(), camera.x + 2, camera.y + 182)
		end

		-- Text top left
		love.graphics.print("Modes", camera.x+camera.width-118, camera.y + 2)
		for i = 1, #screen.modes do
			love.graphics.print("  "..i..": "..screen.modes[i].width.."x"..screen.modes[i].height, camera.x+camera.width-118, camera.y + 2+i*lh)
		end










		if love.joystick.getNumJoysticks() > 0 then
			xisDir1, axisDir2, axisDirN = love.joystick.getAxes( 1 )
			love.graphics.print(xisDir1, camera.x + 2, camera.y + 52)
			love.graphics.print(axisDir2, camera.x + 2, camera.y + 62)
			love.graphics.print(love.joystick.getNumAxes(1), camera.x + 2, camera.y + 72)
		end

		love.graphics.setColor(255, 255, 255, 255)
	end
end