hud = {}
hud.enabled = false

function hud.draw()
	if hud.enabled then
		local lh = 10

		physics.draw()

		-- Entities
		for i = 1, #entities.visible.data do
			if camera.isInside(entities.visible.data[i].getOX(), entities.visible.data[i].getOY(), entities.visible.data[i].getWidth(), entities.visible.data[i].getHeight()) then
				love.graphics.setColor(0, 0, 0, 255)
				love.graphics.print(i.." "..entities.visible.data[i].getY()+entities.visible.data[i].getZ(), entities.visible.data[i].getX(), entities.visible.data[i].getY()+2)
				love.graphics.circle("fill", entities.visible.data[i].getX(), entities.visible.data[i].getY(), 1)
				love.graphics.setColor(255, 0, 0, 255)
				love.graphics.rectangle( "line", entities.visible.data[i].getOX(), entities.visible.data[i].getOY(), entities.visible.data[i].getWidth(), entities.visible.data[i].getHeight() )
			end
		end
		
		-- Debug text.
		
		-- Backgrounds
		love.graphics.setColor(0, 0, 0, 204)
		love.graphics.rectangle("fill", camera.x, camera.y, 100, camera.height)
		love.graphics.rectangle("fill", camera.x+camera.width-120, camera.y, 120, 92+#screen.modes*lh)

		-- Text color
		love.graphics.setColor(0, 255, 0, 255)

		-- FPS
		love.graphics.print("FPS: "..love.timer.getFPS(), camera.x + camera.width - 39, camera.y + 2)

		-- Entities
		love.graphics.print("Entities: "..#entities.data, camera.x + 2, camera.y + 2)
		love.graphics.print("  Visible: "..#entities.visible.data, camera.x + 2, camera.y + 12)
		-- Map
		if map.loaded then
			love.graphics.print("Map: "..map.loaded.width.."x"..map.loaded.height.."x"..map.loaded.layercount, camera.x + 2, camera.y + 22)
			love.graphics.print("  View: "..map.view.size.x.."x"..map.view.size.y.." ("..map.view.x..":"..map.view.y..")", camera.x + 2, camera.y + 32)

			love.graphics.print("  Tiles: "..map.tilecount.."/"..map.tileres, camera.x + 2, camera.y + 42)
		end
		-- Physics
		if physics.world then
			love.graphics.print("Physics: "..physics.world:getBodyCount(), camera.x + 2, camera.y + 52)
		end
		-- Player
		if map.loaded.player then
			local player = map.loaded.player
			love.graphics.print("Player: "..player.getX()..":"..player.getY(), camera.x + 2, camera.y + 62)
			love.graphics.print("  Direction: "..player.getDirection().."   "..getRelativeDirection(player.getDirection()), camera.x + 2, camera.y + 72)
		--	love.graphics.print("  View: "..map.view.size.x.."x"..map.view.size.y.." ("..map.view.x..":"..map.view.y..")", camera.x + 2, camera.y + 32)

		--	love.graphics.print("  Tiles: "..map.tilecount.."/"..map.tileres, camera.x + 2, camera.y + 42)
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
		love.graphics.print("Screen: "..screen.canvas:getWidth().."x"..screen.canvas:getHeight(), camera.x+camera.width-118, camera.y + 32)
		love.graphics.print("  sx: "..screen.sx, camera.x+camera.width-118, camera.y + 42)
		love.graphics.print("              sy: "..screen.sy, camera.x+camera.width-118, camera.y + 42)

		-- Camera
		love.graphics.print("Camera: "..camera.width.."x"..camera.height, camera.x+camera.width-118, camera.y + 52)
		love.graphics.print("  sx: "..camera.sx, camera.x+camera.width-118, camera.y + 62)
		love.graphics.print("              sy: "..camera.sy, camera.x+camera.width-118, camera.y + 62)
		love.graphics.print("  x: "..camera.x, camera.x+camera.width-118, camera.y + 72)
		love.graphics.print("              y: "..camera.y, camera.x+camera.width-118, camera.y + 72)
		if map.loaded then
		love.graphics.print("                          ("..math.floor( camera.x / map.loaded.tilewidth)..":"..math.floor( camera.y / map.loaded.tileheight)..")", camera.x+camera.width-118, camera.y + 72)

		end

		-- Modes
		love.graphics.print("Modes", camera.x+camera.width-118, camera.y + 82)
		for i = 1, #screen.modes do
			love.graphics.print("  "..i..": "..screen.modes[i].width.."x"..screen.modes[i].height, camera.x+camera.width-118, camera.y + 2+i*lh+80)
		end

		-- 
		if player then
			love.graphics.print("Player: "..math.floor( player.getX() / map.loaded.tilewidth)..":"..math.floor( player.getY() / map.loaded.tileheight), camera.x + 2, camera.y + 152)
			love.graphics.print("  x = "..player.getX(), camera.x + 2, camera.y + 162)
			love.graphics.print("  y = "..player.getY(), camera.x + 2, camera.y + 172)
			love.graphics.print("  z = "..player.getZ(), camera.x + 2, camera.y + 182)
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