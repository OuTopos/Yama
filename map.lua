map = {}
map.data = {}
map.view = { x = 0, y = 0, z = 0}
map.view.size = { x = 0, y = 0, z = 0}
--map.view.buffer = {}

function map.load(path, spawn)
	print("Loading map: "..path)

	-- Unloading previous map.
	--map.unload()

	-- Loading map.
	if map.data[path] then
		map.loaded = map.data[path]
	else
		map.data[path] = require("/maps/"..path)
		map.loaded = map.data[path]

		if map.loaded.orientation == "orthogonal" then

			-- Creating Physics World
			map.loaded.properties.xg = map.loaded.properties.xg or 0
			map.loaded.properties.yg = map.loaded.properties.yg or 0
			map.loaded.properties.sleep = map.loaded.properties.sleep or true
			map.loaded.world =  love.physics.newWorld(map.loaded.properties.xg, map.loaded.properties.yg, map.loaded.properties.sleep)
			love.physics.setMeter(map.loaded.properties.meter or map.loaded.tileheight)
			
			-- Create Boundaries
			if map.loaded.properties.boundaries ~= "false" then
				map.loaded.boundaries = love.physics.newFixture(love.physics.newBody(map.loaded.world, 0, 0, "static"), love.physics.newChainShape(true, -1, -1, map.loaded.width * map.loaded.tilewidth + 1, -1, map.loaded.width * map.loaded.tilewidth + 1, map.loaded.height * map.loaded.tileheight + 1, -1, map.loaded.height * map.loaded.tileheight))
			end
			
			-- Creating table the spawns
			map.loaded.spawns = {}

			-- Loading objects layers.
			for i = #map.loaded.layers, 1, -1 do
				local layer = map.loaded.layers[i]
				if layer.type == "objectgroup" then
					if layer.properties.type == "collision" then
						-- Block add to physics.
						for i, object in ipairs(layer.objects) do
							local fixture = map.shape(object)
						end
					elseif layer.properties.type == "portals" then
						-- Adding portals to physics objects
						for i, object in ipairs(layer.objects) do
							local fixture = map.shape(object)
							fixture:setUserData({portal = {map = object.properties.map, spawn = object.properties.spawn}})
							fixture:setSensor(true)
						end
					elseif layer.properties.type == "spawns" then
						-- Adding spawns to the spawns list
						for i, object in ipairs(layer.objects) do
							map.loaded.spawns[object.name] = object
						end
					end
					table.remove(map.loaded.layers, layerkey)
				end
			end
			map.loaded.layercount = #map.loaded.layers

			-- Loading tilesets
			for i,tileset in ipairs(map.loaded.tilesets) do
				local name = string.match(tileset.image, "../../images/(.*).png")
				images.quads.add(name, tileset.tilewidth, tileset.tileheight)
			end

			-- Setting up map view
			map.view.size.x = math.ceil(camera.width / map.loaded.tilewidth) + 1
			map.view.size.y = math.ceil(camera.height / map.loaded.tileheight) + 1

			-- Setting camera boundaries
			camera.setBoundaries(0, 0, map.loaded.width * map.loaded.tilewidth, map.loaded.height * map.loaded.tileheight)

			-- Entities
			map.loaded.entities = {}

			-- Spawning player
			map.loaded.properties.playertype = map.loaded.properties.playertype or "player"
			if map.loaded.spawns[spawn] then
				map.loaded.player = entities.new(map.loaded.properties.playertype, map.loaded.spawns[spawn].x + map.loaded.spawns[spawn].width / 2, map.loaded.spawns[spawn].y + map.loaded.spawns[spawn].height / 2, map.loaded.spawns[spawn].properties.z or 0)
			else
				map.loaded.player = entities.new(map.loaded.properties.playertype, 200, 200, 0)
			end
			
		else
			print("Map is not orthogonal.")
			print("Unloading!")
			map.unload()
		end
	end

	-- Set physics world
	physics.setWorld(map.loaded.world)

	--Setting sortmode
	buffer.sortmode = tonumber(map.loaded.properties.sortmode) or 1

	-- Set camera to follow player
	camera.follow = map.loaded.player
end

function map.shape(object)
	if object.shape == "rectangle" then
		--Rectangle or Tile
		if object.gid then
			--Tile
			local body = love.physics.newBody(map.loaded.world, object.x, object.y-map.loaded.tileheight, "static")
			local shape = love.physics.newRectangleShape(map.loaded.tilewidth/2, map.loaded.tileheight/2, map.loaded.tilewidth, map.loaded.tileheight)
			return love.physics.newFixture(body, shape)
		else
			--Rectangle
			local body = love.physics.newBody(map.loaded.world, object.x, object.y, "static")
			local shape = love.physics.newRectangleShape(object.width/2, object.height/2, object.width, object.height)
			return love.physics.newFixture(body, shape)
		end
	elseif object.shape == "ellipse" then
		--Ellipse
		local body = love.physics.newBody(map.loaded.world, object.x+object.width/2, object.y+object.height/2, "static")
		local shape = love.physics.newCircleShape( (object.width + object.height) / 4 )
		return love.physics.newFixture(body, shape)
	elseif object.shape == "polygon" then
		--Polygon
		local vertices = {}
		for i,vertix in ipairs(object.polygon) do
			table.insert(vertices, vertix.x)
			table.insert(vertices, vertix.y)
		end
		local body = love.physics.newBody(map.loaded.world, object.x, object.y, "static")
		local shape = love.physics.newPolygonShape(unpack(vertices))
		return love.physics.newFixture(body, shape)
	elseif object.shape == "polyline" then
		--Polyline
		local vertices = {}
		for i,vertix in ipairs(object.polyline) do
			table.insert(vertices, vertix.x)
			table.insert(vertices, vertix.y)
		end
		local body = love.physics.newBody(map.loaded.world, object.x, object.y, "static")
		local shape = love.physics.newChainShape(false, unpack(vertices))
		return love.physics.newFixture(body, shape)
	end
	return nil
end

function map.loadPhysics()
	-- body
end

function map.unload()
	game.update()
	map.loaded = nil
	player = nil
	camera.follow = nil
	entities.destroy()
	--physics.destroy()
	buffer:reset()
end

function map.getQuad(quad)
	i = #map.loaded.tilesets
	while map.loaded.tilesets[i] and quad < map.loaded.tilesets[i].firstgid do
		i = i - 1
	end
	local imagename = string.match(map.loaded.tilesets[i].image, "../../images/(.*).png")
	local quadnumber = quad-(map.loaded.tilesets[i].firstgid-1)
	local image = images.load(imagename)
	local quad = images.quads.data[imagename][quadnumber]
	return image, quad
end

function map.update()
	if map.loaded then
		-- Moving the map view to camera x,y
		local xn = math.floor( camera.x / map.loaded.tilewidth )
		local yn = math.floor( camera.y / map.loaded.tileheight )
		if xn ~= map.view.x or yn ~= map.view.y then
			-- Player moved to another tile
			map.view.x = xn
			map.view.y = yn

			-- Trigger a buffer reset.
			buffer:reset()	
		end
	end
end

function map.addToBuffer()
	if map.loaded then
		local z = 0
		local batch = nil

		-- Iterate the x-axis.
		for x=map.view.x, map.view.x+map.view.size.x-1 do
			-- Check so that x is not outside the map.
			if x > -1 and x < map.loaded.width then
				
				-- Iterate the y-axis.
				for y=map.view.y, map.view.y+map.view.size.y-1 do
					-- Check so that y is not outside the map.
					if y > -1 and y < map.loaded.height then

						-- Create a buffer batch.
						batch = buffer.newBatch(map.getXYZ(x, y, z))

						-- Iterate the map.loaded.layercount (z-axis)
						for i=1, map.loaded.layercount do
							-- Check if layer is a tilelayer.
							if map.loaded.layers[i].type == "tilelayer" then

								-- Checking so tile exists.
								if map.loaded.layers[i].data[map.tileIndex(x, y)] then
									-- Checking so tile is not empty.
									if map.loaded.layers[i].data[map.tileIndex(x, y)] > 0 then

										-- Get z from tilelayer properties.
										z = tonumber(map.loaded.layers[i].properties.z) or 0

										-- Check if z has changed.
										if map.getZ(z) ~= batch.z then
											-- Send the previous batch to buffer, unless it's empty.
											if next(batch.data) ~= nil then
												buffer.add(batch)
												batch = buffer.newBatch(map.getXYZ(x, y, z))
											end
											-- Setting batch z to new z
											batch.z = map.getZ(z)
										end

										--Getting quad and image and adding it as a quad to the batch
										image, quad = map.getQuad(map.loaded.layers[i].data[y*map.loaded.width+x+1])
										table.insert(batch.data, buffer.newQuad(image, quad, batch.x, batch.y, batch.z, 0, 1, 1, -(map.loaded.tilewidth/2), -(map.loaded.tileheight/2)))
											
									end
								end


							end

						end
						-- Check for sprites in spriteset to avoid sending empty spriteset to buffer
						if next(batch.data) ~= nil then
							buffer.add(batch)
						end

					end



				end
			end

		end
	end

end

function map.tileIndex(x, y)
	return y*map.loaded.width+x+1
end

function map.getXYZ(x, y, z)
	return map.getX(x), map.getY(y), map.getZ(z)
	--if map.loaded.orientation == "orthogonal" then
	--	nx = 
	--	ny = 
	--	nz = 
	--elseif map.loaded.orientation == "isometric" then
	--	nx = (x - y) * (map.loaded.tilewidth / 2)
	--	ny = (y + x) * (map.loaded.tileheight / 2)
	--	nz = z
	--end

	--return nx, ny, nz
end

function map.getX(x)
	return x * map.loaded.tilewidth - (map.loaded.tilewidth/2)
end
function map.getY(y)
	return y * map.loaded.tileheight - (map.loaded.tileheight/2)
end
function map.getZ(z)
	return z * map.loaded.tileheight + (map.loaded.tileheight/2)
end