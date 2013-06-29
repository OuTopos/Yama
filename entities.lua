entities = {}
entities.data = {}

entities.visible = {}

entities.destroyQueue = {}

require	"entitiesBase"
-- Entity types
require	"entities_player"
require	"entities_pplayer"
require	"entities_tree"
require	"entities_coin"
require	"entities_turret"
require	"entities_ball"
require	"entities_projectile"
require	"entities_monster"
require	"entities_humanoid"
require "entities_mplayer"

function entities.new(type, x, y, z)
	local entity = _G["entities_"..type].new(x, y, z)
	table.insert(entities.data, entity)
	entity.visible = {}
	--buffer.reset()
	return entity
end

function entities.destroy(entity)
	if not entity.destroyed then
		table.insert(entities.destroyQueue, entity)
		entity.destroyed = true
	end
end

function entities.update(dt, camera, buffer)
	entities.visible[camera] = {}

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
		if not entities.updated then
			entities.data[key].update(dt)
		end

		local wasVisible = entities.data[key].visible[camera] or false
		local isVisible = camera.isInside(entities.data[key].getOX(), entities.data[key].getOY(), entities.data[key].getWidth(), entities.data[key].getHeight())
		
		if wasVisible and isVisible then
			table.insert(entities.visible[camera], entities.data[key])
		elseif not wasVisible and isVisible then
			table.insert(entities.visible[camera], entities.data[key])
			entities.data[key].visible[camera] = true
			buffer.reset()
		elseif wasVisible and not isVisible then
			entities.data[key].visible[camera] = false
			buffer.reset()
		end
	end
	entities.updated = true
end

--function entities.addToBuffer()
	--table.sort(entities.visible.data, entities.visible.sort)
--	for i = 1, #entities.visible.data do
--		entities.visible.data[i].addToBuffer()
--	end
--end

function entities.addToBuffer(camera, buffer)
	for i = 1, #entities.visible[camera] do
		entities.visible[camera][i].addToBuffer2(buffer)
	end
end