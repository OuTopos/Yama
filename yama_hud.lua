local hud = {}
hud.enabled = false

function hud.drawR(vp)
	if hud.enabled then
		local lh = 10
		local camera = vp.getCamera()
		local map = vp.getMap()
		local buffer = vp.getBuffer()
		local entities = map.getEntities()

		--if map.getData() then
			physics.draw(map.getWorld())
		--end

		-- Entities

		for i = 1, #entities.list do
			if vp.isEntityInside(entities.list[i]) then
				local x, y, z = entities.list[i].getPosition()
				local left, top, width, height = entities.list[i].getBoundingBox()

				love.graphics.setColor(255, 0, 0, 255)
				love.graphics.rectangle( "line", left, top, width, height)
			
				love.graphics.setColor(0, 0, 255, 255)
				love.graphics.print(i, left + 2, top + 2)
				love.graphics.circle("line", x, y, 2)
			end
		end
		love.graphics.setColor(255, 255, 255, 255)
	end
end

function hud.draw(vp)
	if hud.enabled then
		local lh = 10
		local left = vp.getX()
		local right = vp.getX() + vp.getWidth()
		local top = vp.getY()
		local bottom = vp.getY() + vp.getHeight()
		
		local camera = vp.getCamera()
		local map = vp.getMap()
		local buffer = vp.getBuffer()
		local entities = map.getEntities()

		-- Debug text.
		
		-- Backgrounds
		love.graphics.setColor(0, 0, 0, 127)
		love.graphics.rectangle("fill", left, top, 100, 92+#yama.screen.modes*lh)
		love.graphics.rectangle("fill", right-120, top, 120, 92+#yama.screen.modes*lh)

		-- Text color
		love.graphics.setColor(0, 255, 0, 255)

		-- FPS
		love.graphics.print("FPS: "..love.timer.getFPS(), right - 39, top + 2)

		-- Entities
		love.graphics.print("Entities: "..#entities.list, left + 2, top + 2)
		love.graphics.print("  Visible: "..#entities.visible[vp], left + 2, top + 12)
		-- Map
		if map.getData() then
			love.graphics.print("Map: "..map.getData().width.."x"..map.getData().height.."x"..map.getData().layercount, left + 2, top + 22)
			--love.graphics.print("  View: "..map.view.width.."x"..map.view.height.." ("..map.view.x..":"..map.view.y..")", left + 2, top + 32)

			love.graphics.print("  Tiles: "..map.tilesInView.."/"..map.tilesInMap, left + 2, top + 42)
			-- Physics
			if physics.world then
				love.graphics.print("Physics: "..physics.world:getBodyCount(), left + 2, top + 52)
			end
			-- Player
			if map.getData().player then
				local player = map.getData().player
				love.graphics.print("Player: "..player.getX()..":"..player.getY(), left + 2, top + 62)
				love.graphics.print("  Direction: "..player.getDirection().."   "..yama.g.getRelativeDirection(player.getDirection()), left + 2, top + 72)
				love.graphics.print("  Stick: "..love.joystick.getAxis(1, 1), left + 2, top + 82)
				love.graphics.print("  Stick: "..love.joystick.getAxis(1, 2), left + 2, top + 92)
				love.graphics.print("  Distance: "..yama.g.getDistance(0, 0, love.joystick.getAxis(1, 1), love.joystick.getAxis(1, 2)), left + 2, top + 102)
				love.graphics.print("  Button: ", left + 2, top + 112)
			end
		end

		-- Buffer
		if buffer.enabled then
			love.graphics.print("Buffer: "..buffer.length, right-118, top + 2)
			love.graphics.print("  Drawcalls: "..buffer.debug.drawcalls, right-118, top + 12)
			love.graphics.print("  Redraws: "..buffer.debug.redraws, right-118, top + 22)
		else
			love.graphics.print("Buffer: disabled", right-118, camera.y + 2)
		end

		-- Screen
		--love.graphics.print("Screen: "..vp.canvas:getWidth().."x"..vp.canvas:getHeight(), camera.x+camera.width-118, camera.y + 32)
		--love.graphics.print("  sx: "..yama.screen.sx, camera.x+camera.width-118, camera.y + 42)
		--love.graphics.print("              sy: "..yama.screen.sy, camera.x+camera.width-118, camera.y + 42)

		-- Camera
		love.graphics.print("Camera: "..camera.width.."x"..camera.height, right-118, top + 52)
		love.graphics.print("  sx: "..camera.sx, right-118, top + 62)
		love.graphics.print("              sy: "..camera.sy, right-118, top + 62)
		love.graphics.print("  x: "..math.floor(camera.x + 0.5), right-118, top + 72)
		love.graphics.print("              y: "..math.floor(camera.y + 0.5), right-118, top + 72)
		if map.getData() then
		love.graphics.print("                          ("..math.floor( camera.x / map.getData().tilewidth)..":"..math.floor( camera.y / map.getData().tileheight)..")", right-118, top + 72)

		end

		-- Modes
		love.graphics.print("Modes", right-118, top + 82)
		for i = 1, #yama.screen.modes do
			love.graphics.print("  "..i..": "..yama.screen.modes[i].width.."x"..yama.screen.modes[i].height, right-118, top + 2+i*lh+80)
		end

		-- 
		if player then
			love.graphics.print("Player: "..math.floor( player.getX() / map.getData().tilewidth)..":"..math.floor( player.getY() / map.getData().tileheight), left + 2, top + 152)
			love.graphics.print("  x = "..player.getX(), left + 2, top + 162)
			love.graphics.print("  y = "..player.getY(), left + 2, top + 172)
			love.graphics.print("  z = "..player.getZ(), left + 2, top + 182)
		end










		if love.joystick.getNumJoysticks() > 0  and false then
			xisDir1, axisDir2, axisDirN = love.joystick.getAxes( 1 )
			love.graphics.print(xisDir1, left + 2, top + 52)
			love.graphics.print(axisDir2, left + 2, top + 62)
			love.graphics.print(love.joystick.getNumAxes(1), left + 2, top + 72)
		end

		love.graphics.setColor(255, 255, 255, 255)
	end
end

return hud