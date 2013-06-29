local hud = {}
hud.enabled = false

function hud.draw(camera, buffer, canvas)
	if hud.enabled then
		local lh = 10

		physics.draw()

		-- Entities
		for i = 1, #entities.visible[camera] do
			if camera.isInside(entities.visible[camera][i].getOX(), entities.visible[camera][i].getOY(), entities.visible[camera][i].getWidth(), entities.visible[camera][i].getHeight()) then
				love.graphics.setColor(0, 0, 0, 255)
				love.graphics.print(i, entities.visible[camera][i].getX(), entities.visible[camera][i].getY()+2)
				love.graphics.circle("fill", entities.visible[camera][i].getX(), entities.visible[camera][i].getY(), 1)
				love.graphics.setColor(255, 0, 0, 255)
				love.graphics.rectangle( "line", entities.visible[camera][i].getOX(), entities.visible[camera][i].getOY(), entities.visible[camera][i].getWidth(), entities.visible[camera][i].getHeight() )
			end
		end
		
		-- Debug text.
		
		-- Backgrounds
		love.graphics.setColor(0, 0, 0, 204)
		love.graphics.rectangle("fill", camera.x, camera.y, 100, camera.height)
		love.graphics.rectangle("fill", camera.x+camera.width-120, camera.y, 120, 92+#yama.screen.modes*lh)

		-- Text color
		love.graphics.setColor(0, 255, 0, 255)

		-- FPS
		love.graphics.print("FPS: "..love.timer.getFPS(), camera.x + camera.width - 39, camera.y + 2)

		-- Entities
		love.graphics.print("Entities: "..#entities.data, camera.x + 2, camera.y + 2)
		love.graphics.print("  Visible: "..#entities.visible[camera], camera.x + 2, camera.y + 12)
		-- Map
		if yama.map.loaded then
			love.graphics.print("Map: "..yama.map.loaded.width.."x"..yama.map.loaded.height.."x"..yama.map.loaded.layercount, camera.x + 2, camera.y + 22)
			love.graphics.print("  View: "..yama.map.view.size.x.."x"..yama.map.view.size.y.." ("..yama.map.view.x..":"..yama.map.view.y..")", camera.x + 2, camera.y + 32)

			love.graphics.print("  Tiles: "..yama.map.tilecount.."/"..yama.map.loaded.optimized.tilecount, camera.x + 2, camera.y + 42)
		end
		-- Physics
		if physics.world then
			love.graphics.print("Physics: "..physics.world:getBodyCount(), camera.x + 2, camera.y + 52)
		end
		-- Player
		if yama.map.loaded.player then
			local player = yama.map.loaded.player
			love.graphics.print("Player: "..player.getX()..":"..player.getY(), camera.x + 2, camera.y + 62)
			love.graphics.print("  Direction: "..player.getDirection().."   "..yama.g.getRelativeDirection(player.getDirection()), camera.x + 2, camera.y + 72)
			love.graphics.print("  Stick: "..love.joystick.getAxis(1, 1), camera.x + 2, camera.y + 82)
			love.graphics.print("  Stick: "..love.joystick.getAxis(1, 2), camera.x + 2, camera.y + 92)
			love.graphics.print("  Distance: "..yama.g.getDistance(0, 0, love.joystick.getAxis(1, 1), love.joystick.getAxis(1, 2)), camera.x + 2, camera.y + 102)
			love.graphics.print("  Button: ", camera.x + 2, camera.y + 112)
		end

		-- Buffer
		if buffer.enabled then
			love.graphics.print("Buffer: "..buffer.length, camera.x+camera.width-118, camera.y + 2)
			love.graphics.print("  Drawcalls: "..buffer.debug.drawcalls, camera.x+camera.width-118, camera.y + 12)
			love.graphics.print("  Redraws: "..buffer.debug.redraws, camera.x+camera.width-118, camera.y + 22)
		else
			love.graphics.print("Buffer: disabled", camera.x+camera.width-118, camera.y + 2)
		end

		-- Screen
		love.graphics.print("Screen: "..canvas:getWidth().."x"..canvas:getHeight(), camera.x+camera.width-118, camera.y + 32)
		love.graphics.print("  sx: "..yama.screen.sx, camera.x+camera.width-118, camera.y + 42)
		love.graphics.print("              sy: "..yama.screen.sy, camera.x+camera.width-118, camera.y + 42)

		-- Camera
		love.graphics.print("Camera: "..camera.width.."x"..camera.height, camera.x+camera.width-118, camera.y + 52)
		love.graphics.print("  sx: "..camera.sx, camera.x+camera.width-118, camera.y + 62)
		love.graphics.print("              sy: "..camera.sy, camera.x+camera.width-118, camera.y + 62)
		love.graphics.print("  x: "..camera.x, camera.x+camera.width-118, camera.y + 72)
		love.graphics.print("              y: "..camera.y, camera.x+camera.width-118, camera.y + 72)
		if yama.map.loaded then
		love.graphics.print("                          ("..math.floor( camera.x / yama.map.loaded.tilewidth)..":"..math.floor( camera.y / yama.map.loaded.tileheight)..")", camera.x+camera.width-118, camera.y + 72)

		end

		-- Modes
		love.graphics.print("Modes", camera.x+camera.width-118, camera.y + 82)
		for i = 1, #yama.screen.modes do
			love.graphics.print("  "..i..": "..yama.screen.modes[i].width.."x"..yama.screen.modes[i].height, camera.x+camera.width-118, camera.y + 2+i*lh+80)
		end

		-- 
		if player then
			love.graphics.print("Player: "..math.floor( player.getX() / yama.map.loaded.tilewidth)..":"..math.floor( player.getY() / yama.map.loaded.tileheight), camera.x + 2, camera.y + 152)
			love.graphics.print("  x = "..player.getX(), camera.x + 2, camera.y + 162)
			love.graphics.print("  y = "..player.getY(), camera.x + 2, camera.y + 172)
			love.graphics.print("  z = "..player.getZ(), camera.x + 2, camera.y + 182)
		end










		if love.joystick.getNumJoysticks() > 0  and false then
			xisDir1, axisDir2, axisDirN = love.joystick.getAxes( 1 )
			love.graphics.print(xisDir1, camera.x + 2, camera.y + 52)
			love.graphics.print(axisDir2, camera.x + 2, camera.y + 62)
			love.graphics.print(love.joystick.getNumAxes(1), camera.x + 2, camera.y + 72)
		end

		love.graphics.setColor(255, 255, 255, 255)
	end
end

return hud