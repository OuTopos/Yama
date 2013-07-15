local swarms = {}
swarms.list = {}

function swarms.new()
	local public = {}
	local private = {}

	private.entities = {}

	return public
end

function swarms.update(dt)
	for i = 1, #swarms.list do
	end
end

function swarms.add()
	local swarm = swarms.new()
	table.insert(swarms.list, swarm)
end

return swarms