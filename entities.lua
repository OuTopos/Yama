entities = {}
entities.data = {}

entities.buffer = {}
entities.buffer.data = {}

entities.destroyQueue = {}

-- Entity types
require	"entities_player"
require	"entities_tree"
require	"entities_coin"
require	"entities_turret"
require	"entities_ball"
require	"entities_projectile"
require	"entities_monster"

function entities.new(type, x, y, z)
	local entity = _G["entities_"..type].new(x, y, z)
	table.insert(entities.data, entity)
	return entity
end

function entities.destroy(entity)
	if not entity.destroyed then
		table.insert(entities.destroyQueue, entity)
		entity.destroyed = true
	end
end

function entities.update(dt)
	entities.buffer.data = {}

	-- Destroy entities
	local i1 = 1
	while #entities.destroyQueue > 0 do
		for i2=1, #entities.destroyQueue do
			if entities.data[i1] == entities.destroyQueue[i2] then
				entities.data[i1].destroy()
				table.remove(entities.data, i1)
				table.remove(entities.destroyQueue, i2)
			end
		end
		i1 = i1 + 1
	end

	-- Update and add to buffer
	for key=1, #entities.data do
		entities.data[key].update(dt)

		if camera.isInside(entities.data[key].getOX(), entities.data[key].getOY(), entities.data[key].getWidth(), entities.data[key].getHeight()) then
			entities.buffer.add(entities.data[key])
		end
	end	
end

function entities.addToBuffer()
	table.sort(entities.buffer.data, entities.buffer.sort)
	for i = 1, #entities.buffer.data do
		entities.buffer.data[i].addToBuffer()
	end
end

function entities.buffer.add(entity)
	table.insert(entities.buffer.data, entity)
end

function entities.buffer.sort(a, b)
	if a.getY() < b.getY() then
		return true
	end
	return false
end