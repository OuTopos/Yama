local maps = {}
maps.list = {}

function maps.load(path)
	-- This will create a map object and store it in the maps.list.
	if maps.list[path] then
		-- Except if that map is already loaded.
		return maps.list[path]
	else
		local public = {}
		local private = {}

		-- MAP DATA
		private.data = require("/maps/"..path)

		-- PHYSICS WORLD
		private.world = love.physics.newWorld()

		-- ENTITIES
		private.entities = {}
		private.entities.list = {}
		private.entities.visible = {}

		function private.entities.insert(entity)
			entity.visible = {}
			table.insert(private.entities.list, entity)
		end

		function private.entities.update(dt)
			for key=#private.entities.list, 1, -1 do
				local entity = private.entities.list[key]

				if entity.destroyed then
					table.remove(private.entities.list, key)
					--vp.getBuffer().reset()
				else
					entity.update(dt)
					for i=1, #private.viewports do
						local vp = private.viewports[i]
						local wasVisible = entity.visible[vp] or false
						local isVisible = vp.getCamera().isEntityInside(entity)
						
						if wasVisible and isVisible then
							table.insert(private.entities.visible[vp], entity)
						elseif not wasVisible and isVisible then
							table.insert(private.entities.visible[vp], entity)
							entity.visible[vp] = true
							vp.getBuffer().reset()
						elseif wasVisible and not isVisible then
							entity.visible[vp] = false
							vp.getBuffer().reset()
						end
					end
				end
			end
			public.updated = true
		end

		function public.getEntities()
			return private.entities
		end

		function public.spawn(type, x, y ,z, player)
			local entity = yama.entities.new(public, type, x, y, z)
			if player then
				private.player = entity
			end
			private.entities.insert(entity)	
			return entity
		end


		-- VIEWPORTS
		private.viewports = {}

		function public.addViewport(vp)
			-- Set camera boundaries for the viewport.
			vp.getCamera().setBoundaries(0, 0, private.data.width * private.data.tilewidth, private.data.height * private.data.tileheight)

			-- Make the camera follow the player.
			vp.getCamera().follow = private.player

			-- Create a visible entities table for the viewport.
			private.entities.visible[vp] = {}

			-- Insert the viewport in the viewports table.
			table.insert(private.viewports, vp)
		end

		function public.removeViewport(vp)
			for i=#private.viewports, 1, -1 do
				if private.viewports[i] == vp then
					private.entities.visible[private.viewports[i]] = nil
					table.remove(private.viewports, i)
				end
			end
		end

		-- PATROLS
		private.patrols = {}
		function public.getPatrol(i)
			return private.patrols[i]
		end

		-- SPAWNS
		private.spawns = {}



		-- LOAD - Physics
		function private.loadPhysics()
			private.data.properties.xg = private.data.properties.xg or 0
			private.data.properties.yg = private.data.properties.yg or 0
			private.data.properties.sleep = private.data.properties.sleep or true
			private.data.properties.meter = private.data.properties.meter or private.data.tileheight

			private.world:setGravity(private.data.properties.xg*private.data.properties.meter, private.data.properties.yg*private.data.properties.meter)
			love.physics.setMeter(private.data.properties.meter)
			physics.setWorld(private.world)
		end


		-- LOAD - Tilesets
		function private.loadTilesets()
			for i,tileset in ipairs(private.data.tilesets) do
				local name = string.match(tileset.image, "../../images/(.*).png")
				images.quads.add(name, tileset.tilewidth, tileset.tileheight)
			end
		end


		-- LOAD - Layers
		function private.loadLayers()
			for i = #private.data.layers, 1, -1 do
				local layer = private.data.layers[i]
				if layer.type == "objectgroup" then
					if layer.properties.type == "collision" then
						-- Block add to physics.
						for i, object in ipairs(layer.objects) do
							local fixture = public.shape(object)
							fixture:setUserData({name = object.name, type = object.type, properties = object.properties})
						end
					elseif layer.properties.type == "entities" then
						-- Block add to physics.
						for i, object in ipairs(layer.objects) do
							if object.type and object.type ~= "" then
								local entity = public.spawn(object.type, object.x, object.y, object.properties.z)
								entity.setName(object.name)
								entity.setProperties(object.properties)
								if object.gid and entity.setGID then
									entity.setGID(object.gid)
								end
							end
						end
					elseif layer.properties.type == "patrols" then
						-- Adding patrols to the patrols table
						for i, object in ipairs(layer.objects) do
							if object.shape == "polyline" then
								local patrol = {}
								patrol.name = object.name
								patrol.type = object.type
								patrol.properties = object.properties
								patrol.points = {}
								for k, vertice in ipairs(object.polyline) do
									table.insert(patrol.points, {x = object.polyline[k].x+object.x, y = object.polyline[k].y+object.y})
								end
								private.patrols[patrol.name] = patrol
							end
						end
					elseif layer.properties.type == "portals" then
						-- Adding portals to physics objects
						for i, object in ipairs(layer.objects) do
							local fixture = public.shape(object)
							fixture:setUserData({name = object.name, type = object.type, properties = object.properties})
							fixture:setSensor(true)
						end
					elseif layer.properties.type == "spawns" then
						-- Adding spawns to the spawns list
						for i, object in ipairs(layer.objects) do
							private.spawns[object.name] = object
						end
					end
					table.remove(private.data.layers, layerkey)
				elseif layer.properties.type == "quadmap" then
					-- spritebatch backgrounds and stuff
				end
			end
			private.data.layercount = #private.data.layers

			-- Debug vars
			public.tilesInMap = 0
			public.tilesInView = 0
		end

		function private.load()
			if private.data.orientation == "orthogonal" then
				-- PROPERTIES
				private.sx = tonumber(private.data.properties.sx) or 1
				private.sy = tonumber(private.data.properties.sy) or 1

				private.loadPhysics()
				private.loadTilesets()
				private.loadLayers()
				
				-- Create Boundaries
				if private.data.properties.boundaries ~= "false" then
					private.data.boundaries = love.physics.newFixture(love.physics.newBody(private.world, 0, 0, "static"), love.physics.newChainShape(true, -1, -1, private.data.width * private.data.tilewidth + 1, -1, private.data.width * private.data.tilewidth + 1, private.data.height * private.data.tileheight + 1, -1, private.data.height * private.data.tileheight))
				end


				-- Spawning player
				private.data.properties.player_entity = private.data.properties.player_entity or "player"
				print(private.data.properties.player_entity)
				public.spawn(private.data.properties.player_entity, 200, 200, 0, true)
				
			else
				print("Map is not orthogonal. Gaaah boom crash or something!")
			end

			-- Scale the screen

			public.optimize()
			print("Map optimized. Tiles: "..public.tilesInMap)
		end

		function public.unload()
			game.update()
			private.data = nil
			player = nil
			camera.follow = nil
			entities.destroy()
			--physics.destroy()
			buffer.reset()
		end

		function public.getQuad(quad)
			i = #private.data.tilesets
			while private.data.tilesets[i] and quad < private.data.tilesets[i].firstgid do
				i = i - 1
			end
			local imagename = string.match(private.data.tilesets[i].image, "../../images/(.*).png")
			local quadnumber = quad-(private.data.tilesets[i].firstgid-1)
			local image = images.load(imagename)
			local quad = images.quads.data[imagename][quadnumber]
			return image, quad
		end

		function public.getTileset(gid)
			i = #private.data.tilesets
			while private.data.tilesets[i] and gid < private.data.tilesets[i].firstgid do
				i = i - 1
			end
			return private.data.tilesets[i]
		end

		function public.getSprite(gid, x, y, z, r, sx, sy, ox, oy, kx, ky)
			i = #private.data.tilesets
			while private.data.tilesets[i] and quad < private.data.tilesets[i].firstgid do
				i = i - 1
			end
			local imagename = string.match(private.data.tilesets[i].image, "../../images/(.*).png")
			local quadnumber = quad-(private.data.tilesets[i].firstgid-1)
			local image = images.load(imagename)
			local quad = images.quads.data[imagename][quadnumber]
			return yama.buffers.newSprite(image, quad, x, y, z, r, sx, sy, ox, oy, kx, ky)
		end

		function public.update(dt)
			if #private.viewports > 0 then
				-- Update physics world
				private.world:update(dt)

				-- Update swarm
				private.entities.update(dt)

				-- Update viewports
				for i=1, #private.viewports do
					private.viewports[i].update(dt, public)
				end
			end
		end

		function public.draw()
			for i=1, #private.viewports do
				-- Check if the buffer has been reset 
				if next(private.viewports[i].getBuffer().data) == nil then
					public.addToBuffer(private.viewports[i])
				end
				private.viewports[i].draw()
				private.entities.visible[private.viewports[i]] = {}
			end
		end

		function public.optimize()
			if private.data then
				private.data.optimized = {}
				public.tilesInMap = 0
				private.data.optimized.tiles = {}

				for i=1, private.data.width*private.data.height do
					local x, y = public.index2xy(i)
					private.data.optimized.tiles[i] = nil
					for li=1, #private.data.layers do
						local layer = private.data.layers[li]
						z = tonumber(layer.properties.z)
						if layer.type == "tilelayer" and layer.data[i] > 0 then
							if not private.data.optimized.tiles[i] then
								private.data.optimized.tiles[i] = {}
							end
							local image, quad = public.getQuad(layer.data[i])
							table.insert(private.data.optimized.tiles[i], yama.buffers.newSprite(image, quad, public.getX(x), public.getY(y), public.getZ(z))) --, 0, 1, 1, -(private.data.tilewidth/2), -(private.data.tileheight/2)))
							public.tilesInMap = public.tilesInMap + 1
						end
					end
				end
			end
		end

		function public.addToBuffer(vp)
			if private.data then

				for i = 1, #private.entities.visible[vp] do
					private.entities.visible[vp][i].addToBuffer(vp)
				end

				public.tilesInView = 0
				local batches = {}

				local xmin = vp.getCamera().view.x
				local xmax = vp.getCamera().view.x+vp.getCamera().view.width-1
				local ymin = vp.getCamera().view.y
				local ymax = vp.getCamera().view.y+vp.getCamera().view.height-1

				if xmin < 0 then
					xmin = 0
				end
				if xmax > private.data.width-1 then
					xmax = private.data.width-1
				end

				if ymin < 0 then
					ymin = 0
				end
				if ymax > private.data.height-1 then
					ymax = private.data.height-1
				end

				-- Iterate the y-axis.
				for y=ymin, ymax do

					-- Iterate the x-axis.
					for x=xmin, xmax do

						-- Set the tile
						local tile = private.data.optimized.tiles[public.xy2index(x, y)]

						-- Check so tile is not empty
						if tile then

							-- Iterate the layers
							for i=1, #tile do
								local sprite = tile[i]
								local zy = sprite.z + sprite.y
								if not batches[zy] then
									batches[zy] = yama.buffers.newBatch(sprite.x, sprite.y, sprite.z)
									vp.getBuffer().add(batches[zy])
								end
								table.insert(batches[zy].data, sprite)
								public.tilesInView = public.tilesInView +1
							end
						end
					end
				end
			end
		end

		function public.xy2index(x, y)
			return y*private.data.width+x+1
		end

		function public.index2xy(index)
			local x = (index-1) % private.data.width
			local y = math.floor((index-1) / private.data.width)
			return x, y
		end

		function public.getXYZ(x, y, z)
			return public.getX(x), public.getY(y), public.getZ(z)
			--if private.data.orientation == "orthogonal" then
			--	nx = 
			--	ny = 
			--	nz = 
			--elseif private.data.orientation == "isometric" then
			--	nx = (x - y) * (private.data.tilewidth / 2)
			--	ny = (y + x) * (private.data.tileheight / 2)
			--	nz = z
			--end

			--return nx, ny, nz
		end

		function public.getX(x)
			return x * private.data.tilewidth
		end
		function public.getY(y)
			return y * private.data.tileheight
		end
		function public.getZ(z)
			return z * private.data.tileheight
		end

		function public.index2X(x)
			return x * private.data.tilewidth
		end
		function public.index2Y(y)
			return y * private.data.tileheight
		end





		function public.shape(object)
			if object.shape == "rectangle" then
				--Rectangle or Tile
				if object.gid then
					--Tile
					local body = love.physics.newBody(private.world, object.x, object.y-private.data.tileheight, "static")
					local shape = love.physics.newRectangleShape(private.data.tilewidth/2, private.data.tileheight/2, private.data.tilewidth, private.data.tileheight)
					return love.physics.newFixture(body, shape)
				else
					--Rectangle
					local body = love.physics.newBody(private.world, object.x, object.y, "static")
					local shape = love.physics.newRectangleShape(object.width/2, object.height/2, object.width, object.height)
					return love.physics.newFixture(body, shape)
				end
			elseif object.shape == "ellipse" then
				--Ellipse
				local body = love.physics.newBody(private.world, object.x+object.width/2, object.y+object.height/2, "static")
				local shape = love.physics.newCircleShape( (object.width + object.height) / 4 )
				return love.physics.newFixture(body, shape)
			elseif object.shape == "polygon" then
				--Polygon
				local vertices = {}
				for i,vertix in ipairs(object.polygon) do
					table.insert(vertices, vertix.x)
					table.insert(vertices, vertix.y)
				end
				local body = love.physics.newBody(private.world, object.x, object.y, "static")
				local shape = love.physics.newPolygonShape(unpack(vertices))
				return love.physics.newFixture(body, shape)
			elseif object.shape == "polyline" then
				--Polyline
				local vertices = {}
				for i,vertix in ipairs(object.polyline) do
					table.insert(vertices, vertix.x)
					table.insert(vertices, vertix.y)
				end
				local body = love.physics.newBody(private.world, object.x, object.y, "static")
				local shape = love.physics.newChainShape(false, unpack(vertices))
				return love.physics.newFixture(body, shape)
			else
				return nil
			end
		end

		function public.getTilewidth()
			return private.data.tilewidth
		end

		function public.getTileheight()
			return private.data.tileheight
		end

		function public.getData()
			return private.data
		end

		function public.getWorld()
			return private.world
		end

		function public.getSwarm()
			return private.swarm
		end

		function public.getViewports()
			return private.viewports
		end

		private.load()

		maps.list[path] = public
		return public
	end
end

function maps.update(dt)
	for key, map in pairs(maps.list) do
		map.update(dt)
	end
end

function maps.draw()
	for key, map in pairs(maps.list) do
		map.draw()
	end
end

return maps