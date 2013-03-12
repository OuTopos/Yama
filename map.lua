map = {}
map.view = { x = 0, y = 0, z = 0}
map.view.size = { x = 0, y = 0, z = 0}
map.view.buffer = {}

function map.load(name, spawn, world)
	name = name or "origo"
	world = world or "orthogonia"
	print(world.."/"..name)

	-- Unloading previous map.
	--map.unload()

	-- Loading map.
	map.loaded = require("/worlds/"..world.."/"..name)

	map.loaded.name = name
	map.loaded.world = world

	if map.loaded.orientation == "orthogonal" then

		-- Physics
		--map.loaded.properties.xg = map.loaded.properties.xg or 0
		--map.loaded.properties.yg = map.loaded.properties.yg or 0
		--physics.setWorld(world.."/"..name, map.loaded.properties.xg * map.loaded.tilewidth, map.loaded.properties.yg * map.loaded.tileheight, map.loaded.tileheight, false)

		-- Load gamestate
		game.load()

		-- Creating the spawn point table
		map.loaded.spawns = {}

		-- Loading objects layers.
		for i,layer in ipairs(map.loaded.layers) do
			if layer.type == "objectgroup" then
				if layer.name == "block" then
					-- Block add to physics.
					for i,object in ipairs(layer.objects) do
						if object.polygon then
							--Polygon
							local vertices = {}
							for i,vertix in ipairs(object.polygon) do
								table.insert(vertices, vertix.x)
								table.insert(vertices, vertix.y)
							end
							physics.newObject(love.physics.newBody(physics.world, object.x, object.y, "static"), love.physics.newPolygonShape(unpack(vertices)))
						elseif object.polyline then
							--Polylinelocal
							vertices = {}
							for i,vertix in ipairs(object.polyline) do
								table.insert(vertices, vertix.x)
								table.insert(vertices, vertix.y)
							end
							physics.newObject(love.physics.newBody(physics.world, object.x, object.y, "static"), love.physics.newChainShape(false, unpack(vertices)))

						elseif object.gid then
							--Tile
							physics.newObject(love.physics.newBody(physics.world, object.x, object.y-map.loaded.tileheight, "static"), love.physics.newRectangleShape(map.loaded.tilewidth/2, map.loaded.tileheight/2, map.loaded.tilewidth, map.loaded.tileheight))
						else
							--Rectangle
							physics.newObject(love.physics.newBody(physics.world, object.x, object.y, "static"), love.physics.newRectangleShape(object.width/2, object.height/2, object.width, object.height))
						end
					end
				elseif layer.name == "portals" then
					-- Adding portals to physics objects
					for i,object in ipairs(layer.objects) do
						-- Creating the body and userdata
						local body = love.physics.newBody(physics.world, object.x, object.y, "static")
						local shape
						local userdata = {portal = true, map = object.properties.map, spawn = object.properties.spawn, world = object.properties.world}

						-- Creating the shape
						if object.polygon then
							--Polygon
							local vertices = {}
							for i,vertix in ipairs(object.polygon) do
								table.insert(vertices, vertix.x)
								table.insert(vertices, vertix.y)
							end
							shape = love.physics.newPolygonShape(unpack(vertices))
						elseif object.polyline then
							--Polyline
							local vertices = {}
							for i,vertix in ipairs(object.polyline) do
								table.insert(vertices, vertix.x)
								table.insert(vertices, vertix.y)
							end
							shape = love.physics.newChainShape(false, unpack(vertices))
						elseif object.gid then
							--Tile
							shape = love.physics.newRectangleShape(map.loaded.tilewidth/2, map.loaded.tileheight/2, map.loaded.tilewidth, map.loaded.tileheight)
						else
							--Rectangle
							shape = love.physics.newRectangleShape(object.width/2, object.height/2, object.width, object.height)
						end

						physics.newObject(body, shape, userdata, true)

					end

				elseif layer.name == "spawns" then
					-- Adding spawns to the spawns list
					for i,object in ipairs(layer.objects) do
						map.loaded.spawns[object.name] = object
					end
				end
			end
		end

		-- Map bounderies
		--physics.newObject(love.physics.newBody(physics.world, 0, 0, "static"), love.physics.newChainShape(true, -1, -1, map.loaded.width * map.loaded.tilewidth + 1, -1, map.loaded.width * map.loaded.tilewidth + 1, map.loaded.height * map.loaded.tileheight + 1, -1, map.loaded.height * map.loaded.tileheight))

		-- Loading tilesets
		for i,tileset in ipairs(map.loaded.tilesets) do
			local name = string.match(tileset.image, "../../images/(.*).png")
			images.quads.add(name, tileset.tilewidth, tileset.tileheight)
		end

		-- Setting up map view
		map.view.size.x = math.floor(camera.width / map.loaded.tilewidth + 0.5 ) + 2
		map.view.size.y = math.floor(camera.height / map.loaded.tileheight + 0.5 ) + 2

		-- Setting camera boundaries
		camera.setBoundaries(0, 0, map.loaded.width * map.loaded.tilewidth, map.loaded.height * map.loaded.tileheight)

		-- Spawning player
		--map.loaded.properties.player = map.loaded.properties.player or "player"

--		if player then
--			print("Player did exist")
--			print("  Moving to "..(map.loaded.spawns[spawn].x + map.loaded.spawns[spawn].width / 2)..":"..(map.loaded.spawns[spawn].y + map.loaded.spawns[spawn].height / 2))
--			player.setPosition(map.loaded.spawns[spawn].x + map.loaded.spawns[spawn].width / 2, map.loaded.spawns[spawn].y + map.loaded.spawns[spawn].height / 2)
--		else
--			if map.loaded.spawns[spawn] then
--				player = entities.new(map.loaded.properties.player, map.loaded.spawns[spawn].x + map.loaded.spawns[spawn].width / 2, map.loaded.spawns[spawn].y + map.loaded.spawns[spawn].height / 2, 32)
--			else
--				player = entities.new(map.loaded.properties.player, 64, 64, 32)
--			end
--		end

		--Make the camera follow the player
--		camera.follow = player
	else
		print("Map is not orthogonal.")
		print("Unloading!")
		map.unload()
	end
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
		local xn = math.floor( camera.x / map.loaded.tilewidth + 0.5 ) - 1
		local yn = math.floor( camera.y / map.loaded.tileheight + 0.5 ) - 1
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
		-- Store layerdepth to speed up
		local layerdepth = #map.loaded.layers
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
						batch = buffer.newBatch(map.tilePosition(x, y, z))

						-- Iterate the layerdepth (z-axis)
						for i=1, layerdepth do
							-- Check if layer is a tilelayer.
							if map.loaded.layers[i].type == "tilelayer" then

								-- Checking so tile exists.
								if map.loaded.layers[i].data[map.tileIndex(x, y)] then
									-- Checking so tile is not empty.
									if map.loaded.layers[i].data[map.tileIndex(x, y)] > 0 then

										-- Get z from tilelayer properties.
										z = tonumber(map.loaded.layers[i].properties.z) or 0

										-- Check if z has changed.
										if z * map.loaded.tileheight + (map.loaded.tileheight/2) ~= batch.z then
											-- Send the previous batch to buffer, unless it's empty.
											if next(batch.data) ~= nil then
												buffer.add(batch)
												batch = buffer.newBatch(map.tilePosition(x, y, z))
											end
											-- Setting batch z to new z
											batch.z = z * map.loaded.tileheight + (map.loaded.tileheight/2)
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

function map.tilePosition(x, y, z)
	if map.loaded.orientation == "orthogonal" then
		nx = x * map.loaded.tilewidth - (map.loaded.tilewidth/2)
		ny = y * map.loaded.tileheight - (map.loaded.tileheight/2)
		nz = z * map.loaded.tileheight + (map.loaded.tileheight/2)
	elseif map.loaded.orientation == "isometric" then
		nx = (x - y) * (map.loaded.tilewidth / 2)
		ny = (y + x) * (map.loaded.tileheight / 2)
		nz = z
	end

	return nx, ny, nz
end