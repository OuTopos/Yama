local map = {}
map.data = {}
map.view = { x = 0, y = 0, z = 0}
map.view.size = { x = 0, y = 0, z = 0}

map.tileres = 0
map.tilecount = 0

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
			map.loaded.properties.meter = map.loaded.properties.meter or map.loaded.tileheight
			map.loaded.world =  love.physics.newWorld(map.loaded.properties.xg*map.loaded.properties.meter, map.loaded.properties.yg*map.loaded.properties.meter, map.loaded.properties.sleep)
			love.physics.setMeter(map.loaded.properties.meter)
			
			-- Create Boundaries
			if map.loaded.properties.boundaries ~= "false" then
				map.loaded.boundaries = love.physics.newFixture(love.physics.newBody(map.loaded.world, 0, 0, "static"), love.physics.newChainShape(true, -1, -1, map.loaded.width * map.loaded.tilewidth + 1, -1, map.loaded.width * map.loaded.tilewidth + 1, map.loaded.height * map.loaded.tileheight + 1, -1, map.loaded.height * map.loaded.tileheight))
			end

			-- Create table for patrols
			map.loaded.patrols = {}
			
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
							if object.properties.userdata then
								--set stuff acording to the object
							elseif layer.properties.userdata then
								--set stuff according to the object layer
							end
						end
					elseif layer.properties.type == "patrols" then
						-- Adding patrols to the patrols table
						for i, object in ipairs(layer.objects) do
							if object.shape == "polyline" then
								map.loaded.patrols[object.name] = {}
								for k, vertice in ipairs(object.polyline) do
									table.insert(map.loaded.patrols[object.name], {x = object.polyline[k].x+object.x, y = object.polyline[k].y+object.y})
								end
							end
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
				elseif layer.properties.type == "quadmap" then
					-- spritebatch backgrounds and stuff
				end

			end
			map.loaded.layercount = #map.loaded.layers

			-- Loading tilesets
			for i,tileset in ipairs(map.loaded.tilesets) do
				local name = string.match(tileset.image, "../../images/(.*).png")
				images.quads.add(name, tileset.tilewidth, tileset.tileheight)
			end

			-- Setting camera boundaries
			yama.camera.setBoundaries(0, 0, map.loaded.width * map.loaded.tilewidth, map.loaded.height * map.loaded.tileheight)

			-- Entities
			map.loaded.entities = {}

			-- Spawning player
			map.loaded.properties.player_entity = map.loaded.properties.player_entity or "player"
			print(map.loaded.properties.player_entity)
			if map.loaded.spawns[spawn] then
				map.loaded.player = entities.new(map.loaded.properties.player_entity, map.loaded.spawns[spawn].x + map.loaded.spawns[spawn].width / 2, map.loaded.spawns[spawn].y + map.loaded.spawns[spawn].height / 2, map.loaded.spawns[spawn].properties.z or 0)
			else
				map.loaded.player = entities.new(map.loaded.properties.player_entity, 200, 200, 0)
			end
			
		else
			print("Map is not orthogonal.")
			print("Unloading!")
			map.unload()
		end
	end

	-- Scale the screen
	map.loaded.properties.sx = tonumber(map.loaded.properties.sx) or 1
	map.loaded.properties.sy = tonumber(map.loaded.properties.sy) or map.loaded.properties.sx or 1
	yama.screen.setScale(map.loaded.properties.sx, map.loaded.properties.sy)

	-- Set physics world
	physics.setWorld(map.loaded.world)

	--Setting sortmode
	buffer.sortmode = tonumber(map.loaded.properties.sortmode) or 1

	-- Setting up map view
	map.resetView()
	-- Set camera to follow player
	yama.camera.follow = map.loaded.player
	--yama.camera.follow = nil

	map.optimize()
	print("Map optimized. Tiles: "..map.loaded.optimized.tilecount)
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

function map.resetView()
	map.view.size.x = math.ceil(yama.camera.width / map.loaded.tilewidth) + 1
	map.view.size.y = math.ceil(yama.camera.height / map.loaded.tileheight) + 1
end

function map.loadPhysics()
	-- body
end

function map.unload()
	game.update()
	map.loaded = nil
	player = nil
	yama.camera.follow = nil
	entities.destroy()
	--physics.destroy()
	buffer.reset()
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

function map.update(dt)
	if map.loaded then
		-- Moving the map view to camera x,y
		local xn = math.floor( yama.camera.x / map.loaded.tilewidth )
		local yn = math.floor( yama.camera.y / map.loaded.tileheight )
		if xn ~= map.view.x or yn ~= map.view.y then
			-- Camera moved to another tile
			map.view.x = xn
			map.view.y = yn

			-- Trigger a buffer reset.
			buffer.reset()	
		end
	end
end

function map.optimize()
	if map.loaded then
		map.loaded.optimized = {}
		map.loaded.optimized.tilecount = 0
		map.loaded.optimized.tiles = {}

		for i=1, map.loaded.width*map.loaded.height do
			local x, y = map.index2xy(i)
			map.loaded.optimized.tiles[i] = nil
			for li=1, #map.loaded.layers do
				local layer = map.loaded.layers[li]
				z = tonumber(layer.properties.z)
				if layer.type == "tilelayer" and layer.data[i] > 0 then
					if not map.loaded.optimized.tiles[i] then
						map.loaded.optimized.tiles[i] = {}
					end
					local image, quad = map.getQuad(layer.data[i])
					table.insert(map.loaded.optimized.tiles[i], buffer.newSprite(image, quad, map.getX(x), map.getY(y), map.getZ(z))) --, 0, 1, 1, -(map.loaded.tilewidth/2), -(map.loaded.tileheight/2)))
					map.loaded.optimized.tilecount = map.loaded.optimized.tilecount + 1
				end
			end
		end
	end
end

function map.addToBuffer()
	if map.loaded then
		map.tilecount = 0
		local batches = {}

		local xmin = map.view.x
		local xmax = map.view.x+map.view.size.x-1
		local ymin = map.view.y
		local ymax = map.view.y+map.view.size.y-1

		if xmin < 0 then
			xmin = 0
		end
		if xmax > map.loaded.width-1 then
			xmax = map.loaded.width-1
		end

		if ymin < 0 then
			ymin = 0
		end
		if ymax > map.loaded.height-1 then
			ymax = map.loaded.height-1
		end

		-- Iterate the y-axis.
		for y=ymin, ymax do

			-- Iterate the x-axis.
			for x=xmin, xmax do

				-- Set the tile
				local tile = map.loaded.optimized.tiles[map.xy2index(x, y)]

				-- Check so tile is not empty
				if tile then

					-- Iterate the layers
					for i=1, #tile do
						local sprite = tile[i]
						local zy = sprite.z + sprite.y
						if not batches[zy] then
							batches[zy] = buffer.newBatch(sprite.x, sprite.y, sprite.z)
							buffer.add(batches[zy])
						end
						table.insert(batches[zy].data, sprite)
						map.tilecount = map.tilecount +1
					end
				end
			end
		end
	end
end

function map.xy2index(x, y)
	return y*map.loaded.width+x+1
end

function map.index2xy(index)
	local x = (index-1) % map.loaded.width
	local y = math.floor((index-1) / map.loaded.width)
	return x, y
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
	return x * map.loaded.tilewidth
end
function map.getY(y)
	return y * map.loaded.tileheight
end
function map.getZ(z)
	return z * map.loaded.tileheight
end

function map.index2X(x)
	return x * map.loaded.tilewidth
end
function map.index2Y(y)
	return y * map.loaded.tileheight
end

return map