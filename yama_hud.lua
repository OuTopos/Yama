local hud = {}
hud.enabled = false

function hud.drawR(vp)
	if hud.enabled then
		local lh = 10

		if vp.map.data then
			physics.draw(vp.map.data.world)
		end

		-- Entities
		for i = 1, #vp.entities do
			if vp.camera.isInside(vp.entities[i].getOX(), vp.entities[i].getOY(), vp.entities[i].getWidth(), vp.entities[i].getHeight()) then
				love.graphics.setColor(0, 0, 0, 255)
				love.graphics.print(i, vp.entities[i].getX(), vp.entities[i].getY()+2)
				love.graphics.circle("fill", vp.entities[i].getX(), vp.entities[i].getY(), 1)
				love.graphics.setColor(255, 0, 0, 255)
				love.graphics.rectangle( "line", vp.entities[i].getOX(), vp.entities[i].getOY(), vp.entities[i].getWidth(), vp.entities[i].getHeight() )
			end
		end

	end
end

function hud.draw(vp)
	if hud.enabled then
		local lh = 10
		local left = 0
		local right = vp.width / vp.sx
		local top = 0
		local bottom = vp.height / vp.sy

		-- Debug text.
		
		-- Backgrounds
		love.graphics.setColor(0, 0, 0, 204)
		love.graphics.rectangle("fill", left, top, 100, vp.height)
		love.graphics.rectangle("fill", right-120, top, 120, 92+#yama.screen.modes*lh)

		-- Text color
		love.graphics.setColor(0, 255, 0, 255)

		-- FPS
		love.graphics.print("FPS: "..love.timer.getFPS(), right - 39, top + 2)

		-- Entities
		love.graphics.print("Entities: "..#entities.data, left + 2, top + 2)
		love.graphics.print("  Visible: "..#vp.entities, left + 2, top + 12)
		-- Map
		if vp.map.data then
			love.graphics.print("Map: "..vp.map.data.width.."x"..vp.map.data.height.."x"..vp.map.data.layercount, left + 2, top + 22)
			love.graphics.print("  View: "..vp.map.view.width.."x"..vp.map.view.height.." ("..vp.map.view.x..":"..vp.map.view.y..")", left + 2, top + 32)

			love.graphics.print("  Tiles: "..vp.map.tilesInView.."/"..vp.map.tilesInMap, left + 2, top + 42)
			-- Physics
			if physics.world then
				love.graphics.print("Physics: "..physics.world:getBodyCount(), left + 2, top + 52)
			end
			-- Player
			if vp.map.data.player then
				local player = vp.map.data.player
				love.graphics.print("Player: "..player.getX()..":"..player.getY(), left + 2, top + 62)
				love.graphics.print("  Direction: "..player.getDirection().."   "..yama.g.getRelativeDirection(player.getDirection()), left + 2, top + 72)
				love.graphics.print("  Stick: "..love.joystick.getAxis(1, 1), left + 2, top + 82)
				love.graphics.print("  Stick: "..love.joystick.getAxis(1, 2), left + 2, top + 92)
				love.graphics.print("  Distance: "..yama.g.getDistance(0, 0, love.joystick.getAxis(1, 1), love.joystick.getAxis(1, 2)), left + 2, top + 102)
				love.graphics.print("  Button: ", left + 2, top + 112)
			end
		end

		-- Buffer
		if vp.buffer.enabled then
			love.graphics.print("Buffer: "..vp.buffer.length, right-118, top + 2)
			love.graphics.print("  Drawcalls: "..vp.buffer.debug.drawcalls, right-118, top + 12)
			love.graphics.print("  Redraws: "..vp.buffer.debug.redraws, right-118, top + 22)
		else
			love.graphics.print("Buffer: disabled", right-118, vp.camera.y + 2)
		end

		-- Screen
		--love.graphics.print("Screen: "..vp.canvas:getWidth().."x"..vp.canvas:getHeight(), vp.camera.x+vp.camera.width-118, vp.camera.y + 32)
		--love.graphics.print("  sx: "..yama.screen.sx, vp.camera.x+vp.camera.width-118, vp.camera.y + 42)
		--love.graphics.print("              sy: "..yama.screen.sy, vp.camera.x+vp.camera.width-118, vp.camera.y + 42)

		-- Camera
		love.graphics.print("Camera: "..vp.camera.width.."x"..vp.camera.height, right-118, top + 52)
		love.graphics.print("  sx: "..vp.camera.sx, right-118, top + 62)
		love.graphics.print("              sy: "..vp.camera.sy, right-118, top + 62)
		love.graphics.print("  x: "..vp.camera.x, right-118, top + 72)
		love.graphics.print("              y: "..vp.camera.y, right-118, top + 72)
		if vp.map.data then
		love.graphics.print("                          ("..math.floor( vp.camera.x / vp.map.data.tilewidth)..":"..math.floor( vp.camera.y / vp.map.data.tileheight)..")", right-118, top + 72)

		end

		-- Modes
		love.graphics.print("Modes", right-118, top + 82)
		for i = 1, #yama.screen.modes do
			love.graphics.print("  "..i..": "..yama.screen.modes[i].width.."x"..yama.screen.modes[i].height, right-118, top + 2+i*lh+80)
		end

		-- 
		if player then
			love.graphics.print("Player: "..math.floor( player.getX() / vp.map.data.tilewidth)..":"..math.floor( player.getY() / vp.map.data.tileheight), left + 2, top + 152)
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