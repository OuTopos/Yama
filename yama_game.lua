local game = {}
game.swarms = {}
game.maps = {}


function game.load()
end

function game.start()
	local swarm = yama.swarms.new()
	local map = yama.maps.new()
	table.insert(game.swarms, swarm)
end

function game.update(dt)
	for i = 1, #game.swarms do
		game.swarms[i].update()
	end
end

return game