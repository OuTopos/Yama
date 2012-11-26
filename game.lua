game = {}
game.state = {}

function game.start()
	if gamestate then
		--game.state = gamestate
	else
		map.load("house1", "bedside")
	end
end

function game.update()
	print("Attempting to save state")
	if map.loaded then
		print("  Saving state for: "..map.loaded.name)
		if game.state[map.loaded.name] then
			print("    "..map.loaded.name.." was not nil")
			game.state[map.loaded.name].entities = entities.data
			game.state[map.loaded.name].player = player

		else
			print("    "..map.loaded.name.." was nil")
			game.state[map.loaded.name] = {}
			game.state[map.loaded.name].entities = entities.data
			game.state[map.loaded.name].player = player
		end
		print("  Save for "..map.loaded.name.." complete")
	end
	print("")
end

function game.load(state)


	-- Load map
	-- Load physics
	-- Load entities


	print("Attempting to load state")
	if state then
		game.state = state
	end

	if game.state[map.loaded.name] then
		print("  "..map.loaded.name.." was not nil")
		entities.data = game.state[map.loaded.name].entities
		player = game.state[map.loaded.name].player
	end
	print("")
end

function game.host()
	-- This should be similar to what will be in the dedicated server.lua
end