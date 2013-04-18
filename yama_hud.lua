local hud = {}
hud.enabled = false

function hud.draw()
	if hud.enabled then
		local lh = 10

		physics.draw()

		-- Entities
		for i = 1, #entities.visible.data do
			if yama.camera.isInside(entities.visible.data[i].getOX(), entities.visible.data[i].getOY(), entities.visible.data[i].getWidth(), entities.visible.data[i].getHeight()) then
				love.graphics.setColor(0, 0, 0, 255)
				love.graphics.print(i, entities.visible.data[i].getX(), entities.visible.data[i].getY()+2)
				love.graphics.circle("fill", entities.visible.data[i].getX(), entities.visible.data[i].getY(), 1)
				love.graphics.setColor(255, 0, 0, 255)
				love.graphics.rectangle( "line", entities.visible.data[i].getOX(), entities.visible.data[i].getOY(), entities.visible.data[i].getWidth(), entities.visible.data[i].getHeight() )
			end
		end
		
		-- Debug text.
		
		-- Backgrounds
		love.graphics.setColor(0, 0, 0, 204)
		love.graphics.rectangle("fill", yama.camera.x, yama.camera.y, 100, yama.camera.height)
		love.graphics.rectangle("fill", yama.camera.x+yama.camera.width-120, yama.camera.y, 120, 92+#yama.screen.modes*lh)

		-- Text color
		love.graphics.setColor(0, 255, 0, 255)

		-- FPS
		love.graphics.print("FPS: "..love.timer.getFPS(), yama.camera.x + yama.camera.width - 39, yama.camera.y + 2)

		-- Entities
		love.graphics.print("Entities: "..#entities.data, yama.camera.x + 2, yama.camera.y + 2)
		love.graphics.print("  Visible: "..#entities.visible.data, yama.camera.x + 2, yama.camera.y + 12)
		-- Map
		if yama.map.loaded then
			love.graphics.print("Map: "..yama.map.loaded.width.."x"..yama.map.loaded.height.."x"..yama.map.loaded.layercount, yama.camera.x + 2, yama.camera.y + 22)
			love.graphics.print("  View: "..yama.map.view.size.x.."x"..yama.map.view.size.y.." ("..yama.map.view.x..":"..yama.map.view.y..")", yama.camera.x + 2, yama.camera.y + 32)

			love.graphics.print("  Tiles: "..yama.map.tilecount.."/"..yama.map.tileres, yama.camera.x + 2, yama.camera.y + 42)
		end
		-- Physics
		if physics.world then
			love.graphics.print("Physics: "..physics.world:getBodyCount(), yama.camera.x + 2, yama.camera.y + 52)
		end
		-- Player
		if yama.map.loaded.player then
			local player = yama.map.loaded.player
			love.graphics.print("Player: "..player.getX()..":"..player.getY(), yama.camera.x + 2, yama.camera.y + 62)
			love.graphics.print("  Direction: "..player.getDirection().."   "..yama.g.getRelativeDirection(player.getDirection()), yama.camera.x + 2, yama.camera.y + 72)
		--	love.graphics.print("  View: "..yama.map.view.size.x.."x"..yama.map.view.size.y.." ("..yama.map.view.x..":"..yama.map.view.y..")", yama.camera.x + 2, yama.camera.y + 32)

		--	love.graphics.print("  Tiles: "..yama.map.tilecount.."/"..yama.map.tileres, yama.camera.x + 2, yama.camera.y + 42)
		end


		-- Buffer
		if buffer.enabled then
			love.graphics.print("Buffer: "..buffer.length, yama.camera.x+yama.camera.width-118, yama.camera.y + 2)
			love.graphics.print("  Drawcalls: "..buffer.debug.drawcalls, yama.camera.x+yama.camera.width-118, yama.camera.y + 12)
			love.graphics.print("  Redraws: "..buffer.debug.redraws, yama.camera.x+yama.camera.width-118, yama.camera.y + 22)
		else
			love.graphics.print("Buffer: disabled", yama.camera.x+yama.camera.width-118, yama.camera.y + 2)
		end

		-- Screen
		love.graphics.print("Screen: "..yama.screen.canvas:getWidth().."x"..yama.screen.canvas:getHeight(), yama.camera.x+yama.camera.width-118, yama.camera.y + 32)
		love.graphics.print("  sx: "..yama.screen.sx, yama.camera.x+yama.camera.width-118, yama.camera.y + 42)
		love.graphics.print("              sy: "..yama.screen.sy, yama.camera.x+yama.camera.width-118, yama.camera.y + 42)

		-- Camera
		love.graphics.print("Camera: "..yama.camera.width.."x"..yama.camera.height, yama.camera.x+yama.camera.width-118, yama.camera.y + 52)
		love.graphics.print("  sx: "..yama.camera.sx, yama.camera.x+yama.camera.width-118, yama.camera.y + 62)
		love.graphics.print("              sy: "..yama.camera.sy, yama.camera.x+yama.camera.width-118, yama.camera.y + 62)
		love.graphics.print("  x: "..yama.camera.x, yama.camera.x+yama.camera.width-118, yama.camera.y + 72)
		love.graphics.print("              y: "..yama.camera.y, yama.camera.x+yama.camera.width-118, yama.camera.y + 72)
		if yama.map.loaded then
		love.graphics.print("                          ("..math.floor( yama.camera.x / yama.map.loaded.tilewidth)..":"..math.floor( yama.camera.y / yama.map.loaded.tileheight)..")", yama.camera.x+yama.camera.width-118, yama.camera.y + 72)

		end

		-- Modes
		love.graphics.print("Modes", yama.camera.x+yama.camera.width-118, yama.camera.y + 82)
		for i = 1, #yama.screen.modes do
			love.graphics.print("  "..i..": "..yama.screen.modes[i].width.."x"..yama.screen.modes[i].height, yama.camera.x+yama.camera.width-118, yama.camera.y + 2+i*lh+80)
		end

		-- 
		if player then
			love.graphics.print("Player: "..math.floor( player.getX() / yama.map.loaded.tilewidth)..":"..math.floor( player.getY() / yama.map.loaded.tileheight), yama.camera.x + 2, yama.camera.y + 152)
			love.graphics.print("  x = "..player.getX(), yama.camera.x + 2, yama.camera.y + 162)
			love.graphics.print("  y = "..player.getY(), yama.camera.x + 2, yama.camera.y + 172)
			love.graphics.print("  z = "..player.getZ(), yama.camera.x + 2, yama.camera.y + 182)
		end










		if love.joystick.getNumJoysticks() > 0 then
			xisDir1, axisDir2, axisDirN = love.joystick.getAxes( 1 )
			love.graphics.print(xisDir1, yama.camera.x + 2, yama.camera.y + 52)
			love.graphics.print(axisDir2, yama.camera.x + 2, yama.camera.y + 62)
			love.graphics.print(love.joystick.getNumAxes(1), yama.camera.x + 2, yama.camera.y + 72)
		end

		love.graphics.setColor(255, 255, 255, 255)
	end
end

return hud