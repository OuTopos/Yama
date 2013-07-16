local game = {}
game.swarms = {}
game.maps = {}
game.players = {}


function game.load()
	-- create swarm

	-- create map
	
end

function game.update(dt)
	for i = 1, #game.swarms do
		game.swarms[i].update()
	end
end

return game