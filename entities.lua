entities = {}
entities.data = {}

entities.buffer = {}
entities.buffer.data = {}

-- Entity types
require	"entities_player"
require	"entities_tree"
require	"entities_coin"
require	"entities_turret"
require	"entities_ball"

function entities.new(type, x, y)
	local entity = _G["entities_"..type].new(x, y)
	table.insert(entities.data, entity)
	return entity
end

function entities.update(dt)
	entities.buffer.data = {}
	for i = 1, #entities.data do
		entities.data[i].update(dt)
		if camera.isInside(entities.data[i].getOX(), entities.data[i].getOY(), entities.data[i].getWidth(), entities.data[i].getHeight()) then
			entities.buffer.add(entities.data[i])
		end
	end
end

function entities.draw()
	table.sort(entities.buffer.data, entities.buffer.sort)
	for i = 1, #entities.buffer.data do
		entities.buffer.data[i].draw()
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