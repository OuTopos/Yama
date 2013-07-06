local maps = {}
maps.data = {}

function maps.new(vp)
	local self = {}

	self.path = ""

	self.view = {}
	self.view.x = 0
	self.view.y = 0
	self.view.width = 0
	self.view.height = 0

	self.tilesInMap = 0
	self.tilesInView = 0

	self.data = nil

	function self.load(path, spawn)
		print("Loading map: "..path)

		-- Unloading previous maps.
		--maps.unload()

		-- Loading maps.
		if maps.data[path] then
			self.data = maps.data[path]
		else
			maps.data[path] = require("/maps/"..path)
			self.data = maps.data[path]

			if self.data.orientation == "orthogonal" then

				-- Creating Physics World
				self.data.properties.xg = self.data.properties.xg or 0
				self.data.properties.yg = self.data.properties.yg or 0
				self.data.properties.sleep = self.data.properties.sleep or true
				self.data.properties.meter = self.data.properties.meter or self.data.tileheight
				self.data.world =  love.physics.newWorld(self.data.properties.xg*self.data.properties.meter, self.data.properties.yg*self.data.properties.meter, self.data.properties.sleep)
				love.physics.setMeter(self.data.properties.meter)
				
				-- Create Boundaries
				if self.data.properties.boundaries ~= "false" then
					self.data.boundaries = love.physics.newFixture(love.physics.newBody(self.data.world, 0, 0, "static"), love.physics.newChainShape(true, -1, -1, self.data.width * self.data.tilewidth + 1, -1, self.data.width * self.data.tilewidth + 1, self.data.height * self.data.tileheight + 1, -1, self.data.height * self.data.tileheight))
				end

				-- Create table for patrols
				self.data.patrols = {}
				
				-- Creating table the spawns
				self.data.spawns = {}

				-- Loading objects layers.
				for i = #self.data.layers, 1, -1 do
					local layer = self.data.layers[i]
					if layer.type == "objectgroup" then
						if layer.properties.type == "collision" then
							-- Block add to physics.
							for i, object in ipairs(layer.objects) do
								local fixture = self.shape(object)
								fixture:setUserData({name = object.name, type = object.type, properties = object.properties})
							end
						elseif layer.properties.type == "entities" then
							-- Block add to physics.
							for i, object in ipairs(layer.objects) do
								local entity = entities.new(object.type, object.x, object.y, object.properties.z, vp)
								entity.name = object.name
								entity.type = object.type
								entity.properties = object.properties
							end
						elseif layer.properties.type == "patrols" then
							-- Adding patrols to the patrols table
							for i, object in ipairs(layer.objects) do
								if object.shape == "polyline" then
									self.data.patrols[object.name] = {}
									for k, vertice in ipairs(object.polyline) do
										table.insert(self.data.patrols[object.name], {x = object.polyline[k].x+object.x, y = object.polyline[k].y+object.y})
									end
								end
							end
						elseif layer.properties.type == "portals" then
							-- Adding portals to physics objects
							for i, object in ipairs(layer.objects) do
								local fixture = self.shape(object)
								fixture:setUserData({name = object.name, type = object.type, properties = object.properties})
								fixture:setSensor(true)
							end
						elseif layer.properties.type == "spawns" then
							-- Adding spawns to the spawns list
							for i, object in ipairs(layer.objects) do
								self.data.spawns[object.name] = object
							end
						end
						table.remove(self.data.layers, layerkey)
					elseif layer.properties.type == "quadmap" then
						-- spritebatch backgrounds and stuff
					end

				end
				self.data.layercount = #self.data.layers

				-- Loading tilesets
				for i,tileset in ipairs(self.data.tilesets) do
					local name = string.match(tileset.image, "../../images/(.*).png")
					images.quads.add(name, tileset.tilewidth, tileset.tileheight)
				end

				-- Setting camera boundaries
				--camera.setBoundaries(0, 0, self.data.width * self.data.tilewidth, self.data.height * self.data.tileheight)
				vp.camera.setBoundaries(0, 0, self.data.width * self.data.tilewidth, self.data.height * self.data.tileheight)
				--vp2.camera.setBoundaries(0, 0, self.data.width * self.data.tilewidth, self.data.height * self.data.tileheight)
				--vp3.camera.setBoundaries(0, 0, self.data.width * self.data.tilewidth, self.data.height * self.data.tileheight)

				-- Entities
				self.data.entities = {}

				-- Spawning player
				self.data.properties.player_entity = self.data.properties.player_entity or "player"
				print(self.data.properties.player_entity)
				if self.data.spawns[spawn] then
					self.data.player = entities.new(self.data.properties.player_entity, self.data.spawns[spawn].x + self.data.spawns[spawn].width / 2, self.data.spawns[spawn].y + self.data.spawns[spawn].height / 2, self.data.spawns[spawn].properties.z or 0, vp)
				else
					self.data.player = entities.new(self.data.properties.player_entity, 200, 200, 0, vp)
				end
				
			else
				print("Map is not orthogonal.")
				print("Unloading!")
				self.unload()
			end
		end

		-- Scale the screen
		self.data.properties.sx = tonumber(self.data.properties.sx) or 1
		self.data.properties.sy = tonumber(self.data.properties.sy) or self.data.properties.sx or 1
		--vp.setScale(self.data.properties.sx, self.data.properties.sy, false)

		-- Set physics world
		physics.setWorld(self.data.world)

		--Setting sortmode
		--buffer.sortmode = tonumber(self.data.properties.sortmode) or 1

		-- Setting up map view
		--maps.resetView()
		-- Set camera to follow player
		--camera.follow = self.data.player
		vp.camera.follow = self.data.player
		--vp2.camera.follow = self.data.player

		--camera.follow = nil

		self.optimize()
		print("Map optimized. Tiles: "..self.data.optimized.tilecount)
	end


	function self.loadPhysics()
		-- body
	end

	function self.unload()
		game.update()
		self.data = nil
		player = nil
		camera.follow = nil
		entities.destroy()
		--physics.destroy()
		buffer.reset()
	end

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

	function self.update(dt)
		if self.data then
			self.view.width = math.ceil(vp.camera.width / self.data.tilewidth) + 1
			self.view.height = math.ceil(vp.camera.height / self.data.tileheight) + 1

			-- Moving the map view to camera x,y
			local x = math.floor( vp.camera.x / self.data.tilewidth )
			local y = math.floor( vp.camera.y / self.data.tileheight )

			if x ~= self.view.x or y ~= self.view.y then
				-- Camera moved to another tile
				self.view.x = x
				self.view.y = y

				-- Trigger a buffer reset.
				vp.buffer.reset()	
			end
		end
	end

	function self.optimize()
		if self.data then
			self.data.optimized = {}
			self.data.optimized.tilecount = 0
			self.data.optimized.tiles = {}

			for i=1, self.data.width*self.data.height do
				local x, y = self.index2xy(i)
				self.data.optimized.tiles[i] = nil
				for li=1, #self.data.layers do
					local layer = self.data.layers[li]
					z = tonumber(layer.properties.z)
					if layer.type == "tilelayer" and layer.data[i] > 0 then
						if not self.data.optimized.tiles[i] then
							self.data.optimized.tiles[i] = {}
						end
						local image, quad = self.getQuad(layer.data[i])
						table.insert(self.data.optimized.tiles[i], yama.buffers.newSprite(image, quad, self.getX(x), self.getY(y), self.getZ(z))) --, 0, 1, 1, -(self.data.tilewidth/2), -(self.data.tileheight/2)))
						self.data.optimized.tilecount = self.data.optimized.tilecount + 1
					end
				end
			end
		end
	end

	function self.addToBuffer()
		if self.data then
			self.tilesInView = 0
			local batches = {}

			local xmin = self.view.x
			local xmax = self.view.x+self.view.width-1
			local ymin = self.view.y
			local ymax = self.view.y+self.view.height-1

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

			-- Iterate the y-axis.
			for y=ymin, ymax do

				-- Iterate the x-axis.
				for x=xmin, xmax do

					-- Set the tile
					local tile = self.data.optimized.tiles[self.xy2index(x, y)]

					-- Check so tile is not empty
					if tile then

						-- Iterate the layers
						for i=1, #tile do
							local sprite = tile[i]
							local zy = sprite.z + sprite.y
							if not batches[zy] then
								batches[zy] = yama.buffers.newBatch(sprite.x, sprite.y, sprite.z)
								vp.buffer.add(batches[zy])
							end
							table.insert(batches[zy].data, sprite)
							self.tilesInView = self.tilesInView +1
						end
					end
				end
			end
		end
	end

	function self.xy2index(x, y)
		return y*self.data.width+x+1
	end

	function self.index2xy(index)
		local x = (index-1) % self.data.width
		local y = math.floor((index-1) / self.data.width)
		return x, y
	end

	function self.getXYZ(x, y, z)
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

	function self.getX(x)
		return x * self.data.tilewidth
	end
	function self.getY(y)
		return y * self.data.tileheight
	end
	function self.getZ(z)
		return z * self.data.tileheight
	end

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
				local body = love.physics.newBody(self.data.world, object.x, object.y-self.data.tileheight, "static")
				local shape = love.physics.newRectangleShape(self.data.tilewidth/2, self.data.tileheight/2, self.data.tilewidth, self.data.tileheight)
				return love.physics.newFixture(body, shape)
			else
				--Rectangle
				local body = love.physics.newBody(self.data.world, object.x, object.y, "static")
				local shape = love.physics.newRectangleShape(object.width/2, object.height/2, object.width, object.height)
				return love.physics.newFixture(body, shape)
			end
		elseif object.shape == "ellipse" then
			--Ellipse
			local body = love.physics.newBody(self.data.world, object.x+object.width/2, object.y+object.height/2, "static")
			local shape = love.physics.newCircleShape( (object.width + object.height) / 4 )
			return love.physics.newFixture(body, shape)
		elseif object.shape == "polygon" then
			--Polygon
			local vertices = {}
			for i,vertix in ipairs(object.polygon) do
				table.insert(vertices, vertix.x)
				table.insert(vertices, vertix.y)
			end
			local body = love.physics.newBody(self.data.world, object.x, object.y, "static")
			local shape = love.physics.newPolygonShape(unpack(vertices))
			return love.physics.newFixture(body, shape)
		elseif object.shape == "polyline" then
			--Polyline
			local vertices = {}
			for i,vertix in ipairs(object.polyline) do
				table.insert(vertices, vertix.x)
				table.insert(vertices, vertix.y)
			end
			local body = love.physics.newBody(self.data.world, object.x, object.y, "static")
			local shape = love.physics.newChainShape(false, unpack(vertices))
			return love.physics.newFixture(body, shape)
		end
		return nil
	end



	return self
end

maps.sorting = {}

maps.sorting.simple = {}

return maps