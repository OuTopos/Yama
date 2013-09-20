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
		local self = {}
		local private = {}
		self.start_time = os.clock()

		-- DEBUG
		self.debug = {}
		self.debug.numberOfTilesets = 0
		self.debug.numberOfTileLayers = 0
		self.debug.numberOfTiles = 0


		-- MAP DATA
		self.data = require("/maps/"..path)


		-- PHYSICS WORLD
		self.world = love.physics.newWorld()

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
				if a:getUserData().callback then
					if a:getUserData().callback.preSolve then
						a:getUserData().callback.preSolve(a, b, contact)
					end
				end
			end
			if b:getUserData() then
				if b:getUserData().callback then
					if b:getUserData().callback.preSolve then
						b:getUserData().callback.preSolve(b, a, contact)
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
		self.entities = {}
		self.entities.list = {}

		function self.entities.insert(entity)
			entity.visible = {}
			table.insert(self.entities.list, entity)
		end

		function self.entities.update(dt)
			for key=#self.entities.list, 1, -1 do
				local entity = self.entities.list[key]

				if entity.destroyed then
					table.remove(self.entities.list, key)
				else
					entity.update(dt)
					for i=1, #self.viewports do
						local vp = self.viewports[i]
						if vp.isEntityInside(entity) then
							entity.addToBuffer(vp)
						end
					end
				end
			end
		end

		function self.spawn(type, spawn, data)
			if self.spawns[spawn] then
				local entity = yama.entities.new(self, type, self.spawns[spawn].x, self.spawns[spawn].y, self.spawns[spawn].z)
				if entity.initialize then
					entity.initialize(data)
				end
				self.entities.insert(entity)	
				return entity
			else
				print("Spawn ["..spawn.."] not found. Nothing spawned.")
				return nil
			end
		end

		function self.spawnXYZ(type, x, y, z, data)
			local entity = yama.entities.new(self, type, x, y, z)
			if entity.initialize then
				entity.initialize(data)
			end
			self.entities.insert(entity)	
			return entity
		end


		-- VIEWPORTS
		self.viewports = {}

		function self.addViewport(vp)
			-- Set the map sort mode on the viewport.
			vp.setSortMode(private.sortmode)

			-- Set camera boundaries for the viewport.
			if self.data.properties.boundaries == "false" then
				vp.setBoundaries(0, 0, 0, 0)
			else
				vp.setBoundaries(0, 0, self.data.width * self.data.tilewidth, self.data.height * self.data.tileheight)
			end

			-- Make the camera follow the player.
			vp.getCamera().follow = private.player

			-- Create a visible entities table for the viewport.
			--self.entities.visible[vp] = {}

			-- Reset and create new spritebatches.
			vp.spritebatches = {}

			for i, spritebatch in pairs(private.spritebatches) do
				vp.spritebatches[i] = yama.buffers.newDrawable(love.graphics.newSpriteBatch(spritebatch.image, spritebatch.size), 0, 0, spritebatch.z * self.data.tileheight)
			end

			-- Insert the viewport in the viewports table.
			table.insert(self.viewports, vp)
		end

		function self.removeViewport(vp)
			for i=#self.viewports, 1, -1 do
				if self.viewports[i] == vp then
					--self.entities.visible[self.viewports[i]] = nil
					table.remove(self.viewports, i)
				end
			end
		end

		function self.resetViewports()
			print("Don't resetViewports")
			--for i=1, #self.viewports do
			--	self.viewports[i].reset()
			--end
		end

		-- MISC
		private.cooldown = 0


		-- LOAD - Physics
		function private.loadPhysics()
			self.data.properties.xg = self.data.properties.xg or 0
			self.data.properties.yg = self.data.properties.yg or 0
			--self.data.properties.sleep = self.data.properties.sleep or true
			self.data.properties.meter = self.data.properties.meter or self.data.tileheight

			self.world:setGravity(self.data.properties.xg*self.data.properties.meter, self.data.properties.yg*self.data.properties.meter)
			self.world:setCallbacks(private.beginContact, private.endContact, private.preSolve, private.postSolve)
			love.physics.setMeter(self.data.properties.meter)
			--physics.setWorld(self.world)
		end


		-- LOAD - Tilesets
		function private.loadTilesets()
			for i,tileset in ipairs(self.data.tilesets) do
				tileset.image = string.match(tileset.image, "../../images/(.*).png")
				yama.assets.tileset(tileset.name, tileset.image, tileset.tilewidth, tileset.tileheight, tileset.spacing, tileset.margin)
			end
		end


		-- LOAD - Layers
		function private.loadLayers()
			private.tiles = {}
			private.spritebatches = {}

			self.spawns = {}
			self.patrols = {}


			-- Itirate over.
			for i = 1, #self.data.layers do

				local layer = self.data.layers[i]

				if layer.type == "tilelayer" then
					

					-- TILE LAYERS
					local z = tonumber(layer.properties.z) or 0

					if layer.properties.type == "spritebatch" then
						local i = 1
						-- Look for the first tile and pick it's tileset for the spritebatch.
						while layer.data[i] < 1 do
							i = i + 1
						end
						local tileset = self.getTileset(layer.data[i])
						local spritebatch = {image = yama.assets.image(tileset.image), size = 10000, z = z}

						private.spritebatches[layer.name] = spritebatch
					end

					for i, gid in ipairs(layer.data) do
						if not private.tiles[i] then
							private.tiles[i] = {}
						end

						if gid > 0 then
							local x, y = self.index2xy(i)
							local sprite = self.getTileSprite(layer.data[i], x, y, z)
							if layer.properties.type == "spritebatch" then
								sprite.spritebatch = layer.name
							end
							table.insert(private.tiles[i], sprite)
						end
					end


				elseif layer.type == "objectgroup" then


					-- OBJECT GROUPS
					if layer.properties.type == "collision" then


						--COLLISION
						-- Block add to physics.
						for i, object in ipairs(layer.objects) do
							-- Creating a fixture from the object.
							local fixture = self.createFixture(object, "static")

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
								object.z = object.z * self.data.tileheight
								object.properties.z = nil
								self.spawnXYZ(object.type, object.x + object.width / 2, object.y + object.height / 2, object.z, object)
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
								self.patrols[patrol.name] = patrol
							end
						end


					elseif layer.properties.type == "portals" then


						-- PORTALS
						-- Creating portal fixtures.
						for i, object in ipairs(layer.objects) do
							local fixture = self.createFixture(object, static)
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
							spawn.z = spawn.z * self.data.tileheight
							self.spawns[spawn.name] = spawn
						end
					end


				end
			end
			self.data.layercount = #self.data.layers

			-- Debug vars
			self.tilesInMap = 0
			self.tilesInView = 0
		end

		function private.load()
			--if self.data.orientation == "orthogonal" then
				-- PROPERTIES
				if self.data.properties.sortmode then
					private.sortmode = self.data.properties.sortmode
				else
					private.sortmode = "z"
				end

				private.sx = tonumber(self.data.properties.sx) or 1
				private.sy = tonumber(self.data.properties.sy) or 1

				private.loadPhysics()
				private.loadTilesets()
				private.loadLayers()
				
				-- Create Boundaries
				if self.data.properties.boundaries ~= "false" then
					self.data.boundaries = love.physics.newFixture(love.physics.newBody(self.world, 0, 0, "static"), love.physics.newChainShape(true, -1, -1, self.data.width * self.data.tilewidth + 1, -1, self.data.width * self.data.tilewidth + 1, self.data.height * self.data.tileheight + 1, -1, self.data.height * self.data.tileheight))
				end
				
			--else
			--	print("Map is not orthogonal. Gaaah boom crash or something!")
			--end

			-- Scale the screen
			--private.optimize()
			print("[Maps] Optimized tiles: "..self.tilesInMap.." from "..self.data.width * self.data.height * self.data.layercount)
		end

		--[[
		function self.getQuad(quad)
			i = #self.data.tilesets
			while self.data.tilesets[i] and quad < self.data.tilesets[i].firstgid do
				i = i - 1
			end
			local imagename = string.match(self.data.tilesets[i].image, "../../images/(.*).png")
			local quadnumber = quad-(self.data.tilesets[i].firstgid-1)
			local image = images.load(imagename)
			local quad = images.quads.data[imagename][quadnumber]
			return image, quad
		end
		--]]
		function self.getQuad(gid)
			local tileset = self.getTileset(gid)
			local quad = yama.assets.tilesets[tileset.name].tiles[gid - (tileset.firstgid - 1)]
			return quad
		end

		function self.getTileSprite(gid, x, y, z)
			x, y, z = private.getSpritePosition(x, y, z)
			local sprite, width, height = self.getSprite(gid, x, y, z, true)
			sprite.y = sprite.y + self.data.tileheight
			sprite.oy = height
			return sprite
		end

		function self.getSprite(gid, x, y, z, returnsize)
			local tileset = self.getTileset(gid)
			local image = yama.assets.tilesets[tileset.name].image
			local quad = yama.assets.tilesets[tileset.name].tiles[gid - (tileset.firstgid - 1)]
			local sprite = yama.buffers.newSprite(image, quad, x, y, z)
			if returnsize then
				return sprite, tileset.tilewidth, tileset.tileheight
			else
				return sprite
			end

		end
		function self.getTileset(gid)
			i = #self.data.tilesets
			while self.data.tilesets[i] and gid < self.data.tilesets[i].firstgid do
				i = i - 1
			end
			return self.data.tilesets[i]
		end


		--[[
		function self.getSprite(gid, x, y, z, r, sx, sy, ox, oy, kx, ky)
			i = #self.data.tilesets
			while self.data.tilesets[i] and quad < self.data.tilesets[i].firstgid do
				i = i - 1
			end
			local imagename = string.match(self.data.tilesets[i].image, "../../images/(.*).png")
			local quadnumber = quad-(self.data.tilesets[i].firstgid-1)
			local image = images.load(imagename)
			local quad = images.quads.data[imagename][quadnumber]
			return yama.buffers.newSprite(image, quad, x, y, z, r, sx, sy, ox, oy, kx, ky)
		end
		--]]
		-- Fog of War

		function self.setFow()
			self.fow = {}
			for i = 1, map.data.width * map.data.height do
				self.fow[i] = 2
			end
		end

		function self.defog(x, y, radius)
			
		end

		function self.update(dt)
			if #self.viewports > 0 then
				private.cooldown = 10
			end
			if private.cooldown > 0 then
				private.cooldown = private.cooldown - dt

				-- Update physics world
				self.world:update(dt)

				-- Update entities.
				self.entities.update(dt)

				-- Update viewports
				for i=1, #self.viewports do
					self.viewports[i].update(dt)
					self.addToBuffer(self.viewports[i])
				end
			end
		end

		function self.draw()
			for i=1, #self.viewports do
				--[[
				-- Check if the buffer has been reset. 
				if next(self.viewports[i].getBuffer()) == nil then
					-- Add tiles and entities to buffer.
					self.addToBuffer(self.viewports[i])
				end
				--]]

				-- Draw the viewport.
				self.viewports[i].draw()

				--[[
				-- Reset the visible entities list.
				self.entities.visible[self.viewports[i]]-- = {}
				--]]
			end
		end

		--[[ OPTIMIZE
		function private.optimize()
			if self.data then
				self.data.optimized = {}
				self.tilesInMap = 0
				private.tilelayers = {} -- For odd size tiles maybe

				private.tiles = {}

				for i=1, self.data.width*self.data.height do
					local x, y = self.index2xy(i)
					private.tiles[i] = nil
					for li=1, #self.data.layers do
						local layer = self.data.layers[li]
						z = tonumber(layer.properties.z) or 0
						if layer.type == "tilelayer" and layer.data[i] > 0 then
							if not private.tiles[i] then
								private.tiles[i] = {}
							end
							--local image, quad = self.getQuad(layer.data[i])
							--local tiledata = private.getTileData(layer.data[i], x, y, z)
							--local rx, ry, rz = private.getSpritePosition(x, y, z)
							table.insert(private.tiles[i], self.getTileSprite(layer.data[i], x, y, z))
							self.tilesInMap = self.tilesInMap + 1
						end
					end
				end
			end
		end
		--]]

		function self.addToBuffer(vp)
			for i = 1, #vp.spritebatches do
				vp.spritebatches[i]:clear()
			end
			--for i = 1, #self.entities.visible[vp] do
			--	self.entities.visible[vp][i].addToBuffer(vp)
			--end

			self.tilesInView = 0

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
			if xmax > self.data.width-1 then
				xmax = self.data.width-1
			end

			if ymin < 0 then
				ymin = 0
			end
			if ymax > self.data.height-1 then
				ymax = self.data.height-1
			end
			---[[
			-- Iterate the y-axis.
			for y=ymin, ymax do

				-- Iterate the x-axis.
				for x=xmin, xmax do

					-- Set the tile
					local tile = private.tiles[self.xy2index(x, y)]

					-- Check so tile is not empty
					if tile then

						-- Iterate the layers
						for i=1, #tile do
							local sprite = tile[i]
							if sprite.spritebatch then
								--print("adding sprite to batch "..sprite.spritebatch)
								--print(vp.spritebatches[sprite.spritebatch])
								vp.spritebatches[sprite.spritebatch].drawable:addq(sprite.quad, sprite.x - sprite.ox, sprite.y - sprite.oy)
								--sprite.spritebatch:addq(sprite.quad, sprite.x - sprite.ox, sprite.y - sprite.oy)
							else
								local key = batchkey[private.sortmode](sprite.x, sprite.y, sprite.z)
								if not batches[key] then
									batches[key] = yama.buffers.newBatch(sprite.x, sprite.y, sprite.z)
									table.insert(vp.buffer, batches[key])
								end
								table.insert(batches[key].data, sprite)
								self.tilesInView = self.tilesInView +1
							end
						end
					end
				end
			end



			--for i = 1, #private.spritebatches do
			--	table.insert(vp.buffer, yama.buffers.newDrawable(private.spritebatches[i], 0, 0, 0))
			--end
			--]]
		end

		function self.xy2index(x, y)
			return y*self.data.width+x+1
		end

		function self.index2xy(index)
			local x = (index-1) % self.data.width
			local y = math.floor((index-1) / self.data.width)
			return x, y
		end

		function private.getSpritePosition(x, y, z)
			-- This function gives you a pixel position from a tile position.
			if self.data.orientation == "orthogonal" then
				return x * self.data.tilewidth, y * self.data.tileheight, z * self.data.tileheight
			elseif self.data.orientation == "isometric" then
				x, y = self.translatePosition(x * self.data.tileheight, y * self.data.tileheight)
				return x, y, z
			end
		end

		function self.translatePosition(x, y)
			if self.data.orientation == "orthogonal" then
				return x, y
			elseif self.data.orientation == "isometric" then
				return x - y, (y + x) * self.data.tileheight / self.data.tilewidth
			end
		end

		function self.getXYZ(x, y, z)
			if self.data.orientation == "orthogonal" then
				return self.getX(x), self.getY(y), self.getZ(z)
			elseif self.data.orientation == "isometric" then
				nx = (x - y) * (self.data.tilewidth / 2)
				ny = (y + x) * (self.data.tileheight / 2)
				nz = z

				return nx, ny, nz
			end
		end
		--[[
		private.getPosition = {}

		function private.getPosition.orthogonal(x, y, z)
			return self.getX(x), self.getY(y), self.getZ(z)
			--if self.data.orientation == "orthogonal" then
			--	nx = 
			--	ny = 
			--	nz = 
			--elseif self.data.orientation == "isometric" then
			--	nx = (x - y) * (self.data.tilewidth / 2)
			--	ny = (y + x) * (self.data.tileheight / 2)
			--	nz = z
			--end

			--return nx, ny, nz
		end

		function private.getPosition.isometric(x, y, z)
			nx = (x - y) * (self.data.tilewidth / 2)
			ny = (y + x) * (self.data.tileheight / 2)
			nz = z

			return nx, ny, nz

		end

		function self.getX(x)
			return x * self.data.tilewidth
		end
		function self.getY(y)
			return y * self.data.tileheight
		end
		function self.getZ(z)
			return z * self.data.tileheight
		end
		--]]

		function self.index2X(x)
			return x * self.data.tilewidth
		end
		function self.index2Y(y)
			return y * self.data.tileheight
		end





		function self.shape(object)
			if object.shape == "rectangle" then
				--Rectangle or Tile
				if object.gid then
					--Tile
					local body = love.physics.newBody(self.world, object.x, object.y-self.data.tileheight, "static")
					local shape = love.physics.newRectangleShape(self.data.tilewidth/2, self.data.tileheight/2, self.data.tilewidth, self.data.tileheight)
					return love.physics.newFixture(body, shape)
				else
					--Rectangle
					local body = love.physics.newBody(self.world, object.x, object.y, "static")
					local shape = love.physics.newRectangleShape(object.width/2, object.height/2, object.width, object.height)
					return love.physics.newFixture(body, shape)
				end
			elseif object.shape == "ellipse" then
				--Ellipse
				local body = love.physics.newBody(self.world, object.x+object.width/2, object.y+object.height/2, "static")
				local shape = love.physics.newCircleShape( (object.width + object.height) / 4 )
				return love.physics.newFixture(body, shape)
			elseif object.shape == "polygon" then
				--Polygon
				local vertices = {}
				for i,vertix in ipairs(object.polygon) do
					table.insert(vertices, vertix.x)
					table.insert(vertices, vertix.y)
				end
				local body = love.physics.newBody(self.world, object.x, object.y, "static")
				local shape = love.physics.newPolygonShape(unpack(vertices))
				return love.physics.newFixture(body, shape)
			elseif object.shape == "polyline" then
				--Polyline
				local vertices = {}
				for i,vertix in ipairs(object.polyline) do
					table.insert(vertices, vertix.x)
					table.insert(vertices, vertix.y)
				end
				local body = love.physics.newBody(self.world, object.x, object.y, "static")
				local shape = love.physics.newChainShape(false, unpack(vertices))
				return love.physics.newFixture(body, shape)
			else
				return nil
			end
		end

		function self.createFixture(object, bodyType)
			if object.shape == "rectangle" then
				--Rectangle or Tile
				if object.gid then
					--Tile
					local body = love.physics.newBody(self.world, object.x, object.y-self.data.tileheight, bodyType)
					local shape = love.physics.newRectangleShape(self.data.tilewidth/2, self.data.tileheight/2, self.data.tilewidth, self.data.tileheight)
					return love.physics.newFixture(body, shape)
				else
					--Rectangle
					local body = love.physics.newBody(self.world, object.x, object.y, bodyType)
					local shape = love.physics.newRectangleShape(object.width/2, object.height/2, object.width, object.height)
					return love.physics.newFixture(body, shape)
				end
			elseif object.shape == "ellipse" then
				--Ellipse
				local body = love.physics.newBody(self.world, object.x+object.width/2, object.y+object.height/2, bodyType)
				local shape = love.physics.newCircleShape( (object.width + object.height) / 4 )
				return love.physics.newFixture(body, shape)
			elseif object.shape == "polygon" then
				--Polygon
				local vertices = {}
				for i,vertix in ipairs(object.polygon) do
					table.insert(vertices, vertix.x)
					table.insert(vertices, vertix.y)
				end
				local body = love.physics.newBody(self.world, object.x, object.y, bodyType)
				local shape = love.physics.newPolygonShape(unpack(vertices))
				return love.physics.newFixture(body, shape)
			elseif object.shape == "polyline" then
				--Polyline
				local vertices = {}
				for i,vertix in ipairs(object.polyline) do
					table.insert(vertices, vertix.x)
					table.insert(vertices, vertix.y)
				end
				local body = love.physics.newBody(self.world, object.x, object.y, bodyType)
				local shape = love.physics.newChainShape(false, unpack(vertices))
				return love.physics.newFixture(body, shape)
			else
				return nil
			end
		end

		-- function self.getTilewidth()
		-- 	return self.data.tilewidth
		-- end

		-- function self.getTileheight()
		-- 	return self.data.tileheight
		-- end

		-- function self.getData()
		-- 	return self.data
		-- end

		-- function self.getWorld()
		-- 	return self.world
		-- end

		-- function self.getSwarm()
		-- 	return private.swarm
		-- end

		-- function self.getViewports()
		-- 	return self.viewports
		-- end

		private.load()

		maps.list[path] = self

		self.end_time = os.clock()
		self.load_time = self.end_time - self.start_time
		print("[Maps] "..path.." loaded in "..self.load_time.." seconds.")
		return self
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