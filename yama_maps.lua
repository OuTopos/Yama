local maps = {}
maps.list = {}

function maps.load(path)
	print("[Maps] Loading "..path)
	-- This will create a map object and store it in the maps.list.
	if maps.list[path] then
		-- Except if that map is already loaded.
		print("[Maps] "..path.." already loaded.")
		return maps.list[path]
	else
		local public = {}
		local private = {}
		public.start_time = os.clock()


		-- MAP DATA
		private.data = require("/maps/"..path)


		-- PHYSICS WORLD
		private.world = love.physics.newWorld()

		function private.beginContact(a, b, contact)
			if a:getUserData() then
				if a:getUserData().callback then
					if a:getUserData().callback.beginContact then
						a:getUserData().callback.beginContact(a, b, contact)
					end
				end
			end
			if b:getUserData() then
				if b:getUserData().callback then
					if b:getUserData().callback.beginContact then
						b:getUserData().callback.beginContact(b, a, contact)
					end
				end
			end
		end

		function private.endContact(a, b, contact)
			if a:getUserData() then
				if a:getUserData().callback then
					if a:getUserData().callback.endContact then
						a:getUserData().callback.endContact(a, b, contact)
					end
				end
			end
			if b:getUserData() then
				if b:getUserData().callback then
					if b:getUserData().callback.endContact then
						b:getUserData().callback.endContact(b, a, contact)
					end
				end
			end
		end

		function private.preSolve(a, b, contact)
			if a:getUserData() then
				if a:getUserData().entity then
					if a:getUserData().entity.preSolve then
						a:getUserData().entity.preSolve(a, b, contact)
					end
				end
			end
			if b:getUserData() then
				if b:getUserData().entity then
					if b:getUserData().entity.preSolve then
						b:getUserData().entity.preSolve(b, a, contact)
					end
				end
			end
		end

		function private.postSolve(a, b, contact)
			if a:getUserData() then
				if a:getUserData().entity then
					if a:getUserData().entity.postSolve then
						a:getUserData().entity.postSolve(a, b, contact)
					end
				end
			end
			if b:getUserData() then
				if b:getUserData().entity then
					if b:getUserData().entity.postSolve then
						b:getUserData().entity.postSolve(b, a, contact)
					end
				end
			end
		end


		-- ENTITIES
		private.entities = {}
		private.entities.list = {}

		function private.entities.insert(entity)
			entity.visible = {}
			table.insert(private.entities.list, entity)
		end

		function private.entities.update(dt)
			for key=#private.entities.list, 1, -1 do
				local entity = private.entities.list[key]

				if entity.destroyed then
					table.remove(private.entities.list, key)
					--public.resetViewports()
				else
					entity.update(dt)
					for i=1, #private.viewports do
						--[[
						local vp = private.viewports[i]
						local wasVisible = entity.visible[vp] or false
						local isVisible = vp.isEntityInside(entity)
						
						if wasVisible and isVisible then
							table.insert(private.entities.visible[vp], entity)
						elseif not wasVisible and isVisible then
							table.insert(private.entities.visible[vp], entity)
							entity.visible[vp] = true
							vp.reset()
						elseif wasVisible and not isVisible then
							entity.visible[vp] = false
							vp.reset()
						end
						--]]
						local vp = private.viewports[i]
						if vp.isEntityInside(entity) then
							entity.addToBuffer(vp)
						end
					end
				end
			end
			--public.updated = true
		end

		function public.getEntities()
			return private.entities
		end

		function public.spawn(type, spawn, object)
			if private.spawns[spawn] then
				local entity = yama.entities.new(public, type, private.spawns[spawn].x, private.spawns[spawn].y, private.spawns[spawn].z)
				if entity.initialize then
					entity.initialize(object)
				end
				private.entities.insert(entity)	
				return entity
			else
				print("Spawn ["..spawn.."] not found. Nothing spawned.")
				return nil
			end
		end

		function public.spawnXYZ(type, x, y, z, object)
			local entity = yama.entities.new(public, type, x, y, z)
			if entity.initialize then
				entity.initialize(object)
			end
			private.entities.insert(entity)	
			return entity
		end


		-- VIEWPORTS
		private.viewports = {}

		function public.addViewport(vp)
			-- Set the sort mode.
			vp.setSortMode(private.sortmode)

			-- Set camera boundaries for the viewport.
			if private.data.properties.boundaries == "false" then
				vp.setBoundaries(0, 0, 0, 0)
			else
				vp.setBoundaries(0, 0, private.data.width * private.data.tilewidth, private.data.height * private.data.tileheight)
			end

			-- Make the camera follow the player.
			vp.getCamera().follow = private.player

			-- Create a visible entities table for the viewport.
			--private.entities.visible[vp] = {}

			-- Insert the viewport in the viewports table.
			table.insert(private.viewports, vp)
		end

		function public.removeViewport(vp)
			for i=#private.viewports, 1, -1 do
				if private.viewports[i] == vp then
					--private.entities.visible[private.viewports[i]] = nil
					table.remove(private.viewports, i)
				end
			end
		end

		function public.resetViewports()
			print("Don't resetViewports")
			--for i=1, #private.viewports do
			--	private.viewports[i].reset()
			--end
		end


		-- PATROLS
		function public.getPatrol(i)
			return private.patrols[i]
		end


		-- SPAWNS

		-- MISC
		private.cooldown = 0


		-- LOAD - Physics
		function private.loadPhysics()
			private.data.properties.xg = private.data.properties.xg or 0
			private.data.properties.yg = private.data.properties.yg or 0
			--private.data.properties.sleep = private.data.properties.sleep or true
			private.data.properties.meter = private.data.properties.meter or private.data.tileheight

			private.world:setGravity(private.data.properties.xg*private.data.properties.meter, private.data.properties.yg*private.data.properties.meter)
			private.world:setCallbacks(private.beginContact, private.endContact, private.preSolve, private.postSolve)
			love.physics.setMeter(private.data.properties.meter)
			--physics.setWorld(private.world)
		end


		-- LOAD - Tilesets
		function private.loadTilesets()
			for i,tileset in ipairs(private.data.tilesets) do
				tileset.image = string.match(tileset.image, "../../images/(.*).png")
				yama.assets.tileset(tileset.name, tileset.image, tileset.tilewidth, tileset.tileheight, tileset.spacing, tileset.margin)
			end
		end


		-- LOAD - Layers
		function private.loadLayers()
			private.spritebatches = {}
			private.tiles = {}

			private.spawns = {}
			private.patrols = {}


			-- Itirate over.
			for i = 1, #private.data.layers do

				local layer = private.data.layers[i]

				if layer.type == "tilelayer" then
					

					-- TILE LAYERS
					if layer.properties.type == "spritebatch" then


						-- SPRITE BATCH
						local i = 1
						while layer.data[i] < 1 do
							i = i + 1
						end
						local tileset = public.getTileset(layer.data[i])
						local spritebatch = love.graphics.newSpriteBatch(yama.assets.image(tileset.image), #layer.data)
						
						spritebatch:bind()

						local z = tonumber(layer.properties.z) or 0

						for i, gid in ipairs(layer.data) do
							if gid > 0 then
								local x, y = public.index2xy(i)

								x, y, z = private.getSpritePosition(x, y, z)

								spritebatch:addq(public.getQuad(gid), x, y)
							end
						end
						spritebatch:unbind()

						table.insert(private.spritebatches, yama.buffers.newDrawable(spritebatch, 0, 0, z))


					else


						-- TILES
						local z = tonumber(layer.properties.z) or 0
						for i, gid in ipairs(layer.data) do
							if not private.tiles[i] then
								private.tiles[i] = {}
							end

							if gid > 0 then
								local x, y = public.index2xy(i)
								table.insert(private.tiles[i], public.getTileSprite(layer.data[i], x, y, z))
							end
						end


					end


				elseif layer.type == "objectgroup" then


					-- OBJECT GROUPS
					if layer.properties.type == "collision" then


						--COLLISION
						-- Block add to physics.
						for i, object in ipairs(layer.objects) do
							-- Creating a fixture from the object.
							local fixture = public.createFixture(object, "static")

							-- And setting the userdata from the object.
							fixture:setUserData({name = object.name, type = object.type, properties = object.properties})

							-- Setting filter data from object properties. (category, mask, groupindex)
							if object.properties.category then
								local category = {}
								for x in string.gmatch(object.properties.category, "%P+") do
									x = tonumber(string.match(x, "%S+"))
									if x then
										table.insert(category, x)
									end
								end
								fixture:setCategory(unpack(category))
							end
							if object.properties.mask then
								local mask = {}
								for x in string.gmatch(object.properties.mask, "%P+") do
									x = tonumber(string.match(x, "%S+"))
									if x then
										table.insert(mask, x)
									end
								end
								fixture:setMask(unpack(mask))
							end
							if object.properties.groupindex then
								fixture:setGroupIndex(tonumber(object.properties.groupindex))
							end
						end


					elseif layer.properties.type == "entities" then


						-- ENTITIES
						-- Spawning entities.
						for i, object in ipairs(layer.objects) do
							if object.type and object.type ~= "" then
								object.z = tonumber(object.properties.z) or 1
								object.z = object.z * private.data.tileheight
								object.properties.z = nil
								public.spawnXYZ(object.type, object.x + object.width / 2, object.y + object.height / 2, object.z, object)
							end
						end


					elseif layer.properties.type == "patrols" then


						-- PATROLS
						-- Adding patrols to the patrols table.
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


						-- PORTALS
						-- Creating portal fixtures.
						for i, object in ipairs(layer.objects) do
							local fixture = public.createFixture(object, static)
							fixture:setUserData({name = object.name, type = "portal", properties = object.properties})
							fixture:setSensor(true)
						end


					elseif layer.properties.type == "spawns" then


						-- SPAWNS
						-- Adding spawns to the spawns list
						for i, object in ipairs(layer.objects) do
							local spawn = {}
							spawn.name = object.name
							spawn.type = object.type
							spawn.properties = object.properties

							spawn.x = object.x + object.width / 2
							spawn.y = object.y + object.height / 2
							spawn.z = tonumber(object.properties.z) or 1
							spawn.z = spawn.z * private.data.tileheight
							private.spawns[spawn.name] = spawn
						end
					end


				end
			end
			private.data.layercount = #private.data.layers

			-- Debug vars
			public.tilesInMap = 0
			public.tilesInView = 0
		end

		function private.load()
			--if private.data.orientation == "orthogonal" then
				-- PROPERTIES
				if private.data.properties.sortmode then
					private.sortmode = private.data.properties.sortmode
				else
					private.sortmode = "z"
				end

				private.sx = tonumber(private.data.properties.sx) or 1
				private.sy = tonumber(private.data.properties.sy) or 1

				private.loadPhysics()
				private.loadTilesets()
				private.loadLayers()
				
				-- Create Boundaries
				if private.data.properties.boundaries ~= "false" then
					private.data.boundaries = love.physics.newFixture(love.physics.newBody(private.world, 0, 0, "static"), love.physics.newChainShape(true, -1, -1, private.data.width * private.data.tilewidth + 1, -1, private.data.width * private.data.tilewidth + 1, private.data.height * private.data.tileheight + 1, -1, private.data.height * private.data.tileheight))
				end
				
			--else
			--	print("Map is not orthogonal. Gaaah boom crash or something!")
			--end

			-- Scale the screen
			--private.optimize()
			print("[Maps] Optimized tiles: "..public.tilesInMap.." from "..private.data.width * private.data.height * private.data.layercount)
		end

		--[[
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
		--]]
		function public.getQuad(gid)
			local tileset = public.getTileset(gid)
			local quad = yama.assets.tilesets[tileset.name].tiles[gid - (tileset.firstgid - 1)]
			return quad
		end

		function public.getTileSprite(gid, x, y, z)
			x, y, z = private.getSpritePosition(x, y, z)
			local sprite, width, height = public.getSprite(gid, x, y, z, true)
			sprite.y = sprite.y + private.data.tileheight
			sprite.oy = height
			return sprite
		end

		function public.getSprite(gid, x, y, z, returnsize)
			local tileset = public.getTileset(gid)
			local image = yama.assets.tilesets[tileset.name].image
			local quad = yama.assets.tilesets[tileset.name].tiles[gid - (tileset.firstgid - 1)]
			local sprite = yama.buffers.newSprite(image, quad, x, y, z)
			if returnsize then
				return sprite, tileset.tilewidth, tileset.tileheight
			else
				return sprite
			end

		end
		function public.getTileset(gid)
			i = #private.data.tilesets
			while private.data.tilesets[i] and gid < private.data.tilesets[i].firstgid do
				i = i - 1
			end
			return private.data.tilesets[i]
		end


		--[[
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
		--]]

		function public.update(dt)
			if #private.viewports > 0 then
				private.cooldown = 10
			end
			if private.cooldown > 0 then
				private.cooldown = private.cooldown - dt

				-- Update physics world
				private.world:update(dt)

				-- Update swarm
				private.entities.update(dt)

				-- Update viewports
				for i=1, #private.viewports do
					private.viewports[i].update(dt)
					public.addToBuffer(private.viewports[i])
				end
			end
		end

		function public.draw()
			for i=1, #private.viewports do
				--[[
				-- Check if the buffer has been reset. 
				if next(private.viewports[i].getBuffer()) == nil then
					-- Add tiles and entities to buffer.
					public.addToBuffer(private.viewports[i])
				end
				--]]

				-- Draw the viewport.
				private.viewports[i].draw()

				--[[
				-- Reset the visible entities list.
				private.entities.visible[private.viewports[i]]-- = {}
				--]]
			end
		end

		--[[ OPTIMIZE
		function private.optimize()
			if private.data then
				private.data.optimized = {}
				public.tilesInMap = 0
				private.tilelayers = {} -- For odd size tiles maybe

				private.tiles = {}

				for i=1, private.data.width*private.data.height do
					local x, y = public.index2xy(i)
					private.tiles[i] = nil
					for li=1, #private.data.layers do
						local layer = private.data.layers[li]
						z = tonumber(layer.properties.z) or 0
						if layer.type == "tilelayer" and layer.data[i] > 0 then
							if not private.tiles[i] then
								private.tiles[i] = {}
							end
							--local image, quad = public.getQuad(layer.data[i])
							--local tiledata = private.getTileData(layer.data[i], x, y, z)
							--local rx, ry, rz = private.getSpritePosition(x, y, z)
							table.insert(private.tiles[i], public.getTileSprite(layer.data[i], x, y, z))
							public.tilesInMap = public.tilesInMap + 1
						end
					end
				end
			end
		end
		--]]

		function public.addToBuffer(vp)
			for i = 1, #private.spritebatches do
				vp.addToBuffer(private.spritebatches[i])
			end
			--for i = 1, #private.entities.visible[vp] do
			--	private.entities.visible[vp][i].addToBuffer(vp)
			--end

			public.tilesInView = 0

			local batchkey = {}

			function batchkey.z(x, y, z)
				return z
			end
			function batchkey.y(x, y, z)
				return y
			end
			function batchkey.yz(x, y, z)
				return y + z
			end

			local batches = {}
			local mapview = vp.getMapview()
			local xmin = mapview.x
			local xmax = mapview.x + mapview.width - 1
			local ymin = mapview.y
			local ymax = mapview.y + mapview.height - 1

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
			---[[
			-- Iterate the y-axis.
			for y=ymin, ymax do

				-- Iterate the x-axis.
				for x=xmin, xmax do

					-- Set the tile
					local tile = private.tiles[public.xy2index(x, y)]

					-- Check so tile is not empty
					if tile then

						-- Iterate the layers
						for i=1, #tile do
							local sprite = tile[i]
							local key = batchkey[private.sortmode](sprite.x, sprite.y, sprite.z)
							if not batches[key] then
								batches[key] = yama.buffers.newBatch(sprite.x, sprite.y, sprite.z)
								vp.addToBuffer(batches[key])
							end
							table.insert(batches[key].data, sprite)
							public.tilesInView = public.tilesInView +1
						end
					end
				end
			end
			--]]
		end

		function public.xy2index(x, y)
			return y*private.data.width+x+1
		end

		function public.index2xy(index)
			local x = (index-1) % private.data.width
			local y = math.floor((index-1) / private.data.width)
			return x, y
		end

		function private.getSpritePosition(x, y, z)
			-- This function gives you a pixel position from a tile position.
			if private.data.orientation == "orthogonal" then
				return x * private.data.tilewidth, y * private.data.tileheight, z * private.data.tileheight
			elseif private.data.orientation == "isometric" then
				x, y = public.translatePosition(x * private.data.tileheight, y * private.data.tileheight)
				return x, y, z
			end
		end

		function public.translatePosition(x, y)
			if private.data.orientation == "orthogonal" then
				return x, y
			elseif private.data.orientation == "isometric" then
				return x - y, (y + x) * private.data.tileheight / private.data.tilewidth
			end
		end

		function public.getXYZ(x, y, z)
			if private.data.orientation == "orthogonal" then
				return public.getX(x), public.getY(y), public.getZ(z)
			elseif private.data.orientation == "isometric" then
				nx = (x - y) * (private.data.tilewidth / 2)
				ny = (y + x) * (private.data.tileheight / 2)
				nz = z

				return nx, ny, nz
			end
		end
		--[[
		private.getPosition = {}

		function private.getPosition.orthogonal(x, y, z)
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

		function private.getPosition.isometric(x, y, z)
			nx = (x - y) * (private.data.tilewidth / 2)
			ny = (y + x) * (private.data.tileheight / 2)
			nz = z

			return nx, ny, nz

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
		--]]

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

		function public.createFixture(object, bodyType)
			if object.shape == "rectangle" then
				--Rectangle or Tile
				if object.gid then
					--Tile
					local body = love.physics.newBody(private.world, object.x, object.y-private.data.tileheight, bodyType)
					local shape = love.physics.newRectangleShape(private.data.tilewidth/2, private.data.tileheight/2, private.data.tilewidth, private.data.tileheight)
					return love.physics.newFixture(body, shape)
				else
					--Rectangle
					local body = love.physics.newBody(private.world, object.x, object.y, bodyType)
					local shape = love.physics.newRectangleShape(object.width/2, object.height/2, object.width, object.height)
					return love.physics.newFixture(body, shape)
				end
			elseif object.shape == "ellipse" then
				--Ellipse
				local body = love.physics.newBody(private.world, object.x+object.width/2, object.y+object.height/2, bodyType)
				local shape = love.physics.newCircleShape( (object.width + object.height) / 4 )
				return love.physics.newFixture(body, shape)
			elseif object.shape == "polygon" then
				--Polygon
				local vertices = {}
				for i,vertix in ipairs(object.polygon) do
					table.insert(vertices, vertix.x)
					table.insert(vertices, vertix.y)
				end
				local body = love.physics.newBody(private.world, object.x, object.y, bodyType)
				local shape = love.physics.newPolygonShape(unpack(vertices))
				return love.physics.newFixture(body, shape)
			elseif object.shape == "polyline" then
				--Polyline
				local vertices = {}
				for i,vertix in ipairs(object.polyline) do
					table.insert(vertices, vertix.x)
					table.insert(vertices, vertix.y)
				end
				local body = love.physics.newBody(private.world, object.x, object.y, bodyType)
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

		public.end_time = os.clock()
		public.load_time = public.end_time - public.start_time
		print("[Maps] "..path.." loaded in "..public.load_time.." seconds.")
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