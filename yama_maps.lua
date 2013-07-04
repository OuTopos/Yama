local maps = {}
maps.data = {}

function maps.new(vp)
	local public = {}
	local private = {}

	public.path = ""

	public.view = {}
	public.view.x = 0
	public.view.y = 0
	public.view.width = 0
	public.view.height = 0

	public.tilesInMap = 0
	public.tilesInView = 0

	public.data = nil

	function public.load(path, spawn)
		print("Loading map: "..path)

		-- Unloading previous maps.
		--maps.unload()

		-- Loading maps.
		if maps.data[path] then
			public.data = maps.data[path]
		else
			maps.data[path] = require("/maps/"..path)
			public.data = maps.data[path]

			if public.data.orientation == "orthogonal" then

				-- Creating Physics World
				public.data.properties.xg = public.data.properties.xg or 0
				public.data.properties.yg = public.data.properties.yg or 0
				public.data.properties.sleep = public.data.properties.sleep or true
				public.data.properties.meter = public.data.properties.meter or public.data.tileheight
				public.data.world =  love.physics.newWorld(public.data.properties.xg*public.data.properties.meter, public.data.properties.yg*public.data.properties.meter, public.data.properties.sleep)
				love.physics.setMeter(public.data.properties.meter)
				
				-- Create Boundaries
				if public.data.properties.boundaries ~= "false" then
					public.data.boundaries = love.physics.newFixture(love.physics.newBody(public.data.world, 0, 0, "static"), love.physics.newChainShape(true, -1, -1, public.data.width * public.data.tilewidth + 1, -1, public.data.width * public.data.tilewidth + 1, public.data.height * public.data.tileheight + 1, -1, public.data.height * public.data.tileheight))
				end

				-- Create table for patrols
				public.data.patrols = {}
				
				-- Creating table the spawns
				public.data.spawns = {}

				-- Loading objects layers.
				for i = #public.data.layers, 1, -1 do
					local layer = public.data.layers[i]
					if layer.type == "objectgroup" then
						if layer.properties.type == "collision" then
							-- Block add to physics.
							for i, object in ipairs(layer.objects) do
								local fixture = public.shape(object)
								fixture:setUserData({name = object.name, type = object.type, properties = object.properties})
							end
						elseif layer.properties.type == "patrols" then
							-- Adding patrols to the patrols table
							for i, object in ipairs(layer.objects) do
								if object.shape == "polyline" then
									public.data.patrols[object.name] = {}
									for k, vertice in ipairs(object.polyline) do
										table.insert(public.data.patrols[object.name], {x = object.polyline[k].x+object.x, y = object.polyline[k].y+object.y})
									end
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
								public.data.spawns[object.name] = object
							end
						end
						table.remove(public.data.layers, layerkey)
					elseif layer.properties.type == "quadmap" then
						-- spritebatch backgrounds and stuff
					end

				end
				public.data.layercount = #public.data.layers

				-- Loading tilesets
				for i,tileset in ipairs(public.data.tilesets) do
					local name = string.match(tileset.image, "../../images/(.*).png")
					images.quads.add(name, tileset.tilewidth, tileset.tileheight)
				end

				-- Setting camera boundaries
				--camera.setBoundaries(0, 0, public.data.width * public.data.tilewidth, public.data.height * public.data.tileheight)
				vp.camera.setBoundaries(0, 0, public.data.width * public.data.tilewidth, public.data.height * public.data.tileheight)
				--vp2.camera.setBoundaries(0, 0, public.data.width * public.data.tilewidth, public.data.height * public.data.tileheight)
				--vp3.camera.setBoundaries(0, 0, public.data.width * public.data.tilewidth, public.data.height * public.data.tileheight)

				-- Entities
				public.data.entities = {}

				-- Spawning player
				public.data.properties.player_entity = public.data.properties.player_entity or "player"
				print(public.data.properties.player_entity)
				if public.data.spawns[spawn] then
					public.data.player = entities.new(public.data.properties.player_entity, public.data.spawns[spawn].x + public.data.spawns[spawn].width / 2, public.data.spawns[spawn].y + public.data.spawns[spawn].height / 2, public.data.spawns[spawn].properties.z or 0, vp)
				else
					public.data.player = entities.new(public.data.properties.player_entity, 200, 200, 0, vp)
				end
				
			else
				print("Map is not orthogonal.")
				print("Unloading!")
				public.unload()
			end
		end

		-- Scale the screen
		public.data.properties.sx = tonumber(public.data.properties.sx) or 1
		public.data.properties.sy = tonumber(public.data.properties.sy) or public.data.properties.sx or 1
		--yama.screen.setScale(public.data.properties.sx, public.data.properties.sy)

		-- Set physics world
		physics.setWorld(public.data.world)

		--Setting sortmode
		--buffer.sortmode = tonumber(public.data.properties.sortmode) or 1

		-- Setting up map view
		--maps.resetView()
		-- Set camera to follow player
		--camera.follow = public.data.player
		vp.camera.follow = public.data.player
		--vp2.camera.follow = public.data.player

		--camera.follow = nil

		public.optimize()
		print("Map optimized. Tiles: "..public.data.optimized.tilecount)
	end


	function public.loadPhysics()
		-- body
	end

	function public.unload()
		game.update()
		public.data = nil
		player = nil
		camera.follow = nil
		entities.destroy()
		--physics.destroy()
		buffer.reset()
	end

	function public.getQuad(quad)
		i = #public.data.tilesets
		while public.data.tilesets[i] and quad < public.data.tilesets[i].firstgid do
			i = i - 1
		end
		local imagename = string.match(public.data.tilesets[i].image, "../../images/(.*).png")
		local quadnumber = quad-(public.data.tilesets[i].firstgid-1)
		local image = images.load(imagename)
		local quad = images.quads.data[imagename][quadnumber]
		return image, quad
	end

	function public.update(dt)
		if public.data then
			public.view.width = math.ceil(vp.camera.width / public.data.tilewidth) + 1
			public.view.height = math.ceil(vp.camera.height / public.data.tileheight) + 1

			-- Moving the map view to camera x,y
			local x = math.floor( vp.camera.x / public.data.tilewidth )
			local y = math.floor( vp.camera.y / public.data.tileheight )

			if x ~= public.view.x or y ~= public.view.y then
				-- Camera moved to another tile
				public.view.x = x
				public.view.y = y

				-- Trigger a buffer reset.
				vp.buffer.reset()	
			end
		end
	end

	function public.optimize()
		if public.data then
			public.data.optimized = {}
			public.data.optimized.tilecount = 0
			public.data.optimized.tiles = {}

			for i=1, public.data.width*public.data.height do
				local x, y = public.index2xy(i)
				public.data.optimized.tiles[i] = nil
				for li=1, #public.data.layers do
					local layer = public.data.layers[li]
					z = tonumber(layer.properties.z)
					if layer.type == "tilelayer" and layer.data[i] > 0 then
						if not public.data.optimized.tiles[i] then
							public.data.optimized.tiles[i] = {}
						end
						local image, quad = public.getQuad(layer.data[i])
						table.insert(public.data.optimized.tiles[i], yama.buffers.newSprite(image, quad, public.getX(x), public.getY(y), public.getZ(z))) --, 0, 1, 1, -(public.data.tilewidth/2), -(public.data.tileheight/2)))
						public.data.optimized.tilecount = public.data.optimized.tilecount + 1
					end
				end
			end
		end
	end

	function public.addToBuffer()
		if public.data then
			public.tilesInView = 0
			local batches = {}

			local xmin = public.view.x
			local xmax = public.view.x+public.view.width-1
			local ymin = public.view.y
			local ymax = public.view.y+public.view.height-1

			if xmin < 0 then
				xmin = 0
			end
			if xmax > public.data.width-1 then
				xmax = public.data.width-1
			end

			if ymin < 0 then
				ymin = 0
			end
			if ymax > public.data.height-1 then
				ymax = public.data.height-1
			end

			-- Iterate the y-axis.
			for y=ymin, ymax do

				-- Iterate the x-axis.
				for x=xmin, xmax do

					-- Set the tile
					local tile = public.data.optimized.tiles[public.xy2index(x, y)]

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
							public.tilesInView = public.tilesInView +1
						end
					end
				end
			end
		end
	end

	function public.xy2index(x, y)
		return y*public.data.width+x+1
	end

	function public.index2xy(index)
		local x = (index-1) % public.data.width
		local y = math.floor((index-1) / public.data.width)
		return x, y
	end

	function public.getXYZ(x, y, z)
		return public.getX(x), public.getY(y), public.getZ(z)
		--if public.data.orientation == "orthogonal" then
		--	nx = 
		--	ny = 
		--	nz = 
		--elseif public.data.orientation == "isometric" then
		--	nx = (x - y) * (public.data.tilewidth / 2)
		--	ny = (y + x) * (public.data.tileheight / 2)
		--	nz = z
		--end

		--return nx, ny, nz
	end

	function public.getX(x)
		return x * public.data.tilewidth
	end
	function public.getY(y)
		return y * public.data.tileheight
	end
	function public.getZ(z)
		return z * public.data.tileheight
	end

	function public.index2X(x)
		return x * public.data.tilewidth
	end
	function public.index2Y(y)
		return y * public.data.tileheight
	end





	function public.shape(object)
		if object.shape == "rectangle" then
			--Rectangle or Tile
			if object.gid then
				--Tile
				local body = love.physics.newBody(public.data.world, object.x, object.y-public.data.tileheight, "static")
				local shape = love.physics.newRectangleShape(public.data.tilewidth/2, public.data.tileheight/2, public.data.tilewidth, public.data.tileheight)
				return love.physics.newFixture(body, shape)
			else
				--Rectangle
				local body = love.physics.newBody(public.data.world, object.x, object.y, "static")
				local shape = love.physics.newRectangleShape(object.width/2, object.height/2, object.width, object.height)
				return love.physics.newFixture(body, shape)
			end
		elseif object.shape == "ellipse" then
			--Ellipse
			local body = love.physics.newBody(public.data.world, object.x+object.width/2, object.y+object.height/2, "static")
			local shape = love.physics.newCircleShape( (object.width + object.height) / 4 )
			return love.physics.newFixture(body, shape)
		elseif object.shape == "polygon" then
			--Polygon
			local vertices = {}
			for i,vertix in ipairs(object.polygon) do
				table.insert(vertices, vertix.x)
				table.insert(vertices, vertix.y)
			end
			local body = love.physics.newBody(public.data.world, object.x, object.y, "static")
			local shape = love.physics.newPolygonShape(unpack(vertices))
			return love.physics.newFixture(body, shape)
		elseif object.shape == "polyline" then
			--Polyline
			local vertices = {}
			for i,vertix in ipairs(object.polyline) do
				table.insert(vertices, vertix.x)
				table.insert(vertices, vertix.y)
			end
			local body = love.physics.newBody(public.data.world, object.x, object.y, "static")
			local shape = love.physics.newChainShape(false, unpack(vertices))
			return love.physics.newFixture(body, shape)
		end
		return nil
	end



	return public
end



maps.sorting = {}

maps.sorting.simple = {}


maps.compasses = {}

function maps.compasses.new()
	local public = {}
	local private = {}

	public.map = ""
	public.x = 0
	public.y = 0
	public.width = 0
	public.height = 0

	function public.update(camera, buffer)
		if public.data then
			public.width = math.ceil(camera.width / public.data.tilewidth) + 1
			public.height = math.ceil(camera.height / public.data.tileheight) + 1

			-- Moving the map view to camera x,y
			local xn = math.floor(camera.x / public.data.tilewidth)
			local yn = math.floor(camera.y / public.data.tileheight)
			if xn ~= public.x or yn ~= public.y then
				-- Camera moved to another tile
				public.x = xn
				public.y = yn

				-- Trigger a buffer reset.
				buffer.reset()	
			end
		end
	end


	return public
end

return maps