entities = {}
entities.data = {}

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

function entities.new(type, x, y, z, viewport)
	if not entities.data[viewport.map] then
		entities.data[viewport.map] = {}
	end
	local entity = _G["entities_"..type].new(x, y, z, viewport)
	table.insert(entities.data[viewport.map], entity)
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

function entities.update(dt, viewport)
	viewport.entities = {}

	-- Destroy entities
	--local i1 = 1
--	while #entities.destroyQueue > 0 do
	--	for i2=1, #entities.destroyQueue do
	--		if entities.data[i1] == entities.destroyQueue[i2] then
	--			entities.data[i1].destroy()
	--			table.remove(entities.data, i1)
	--			table.remove(entities.destroyQueue, i2)
	--		end
	--	end
	--	i1 = i1 + 1
	--end

	-- Update and add to buffer
	for key=1, #entities.data[viewport.map] do
		local entity = entities.data[viewport.map][key]
		local wasVisible = entity.visible[viewport] or false
		local isVisible = viewport.camera.isInside(entity.getOX(), entity.getOY(), entity.getWidth(), entity.getHeight())
		
		if wasVisible and isVisible then
			table.insert(viewport.entities, entity)
		elseif not wasVisible and isVisible then
			table.insert(viewport.entities, entity)
			entity.visible[viewport] = true
			viewport.buffer.reset()
		elseif wasVisible and not isVisible then
			entity.visible[viewport] = false
			viewport.buffer.reset()
		end

		if not entities.data[viewport.map].updated then
			entity.update(dt)
		end
	end
	entities.data[viewport.map].updated = true
end

--function entities.addToBuffer()
	--table.sort(entities.visible.data, entities.visible.sort)
--	for i = 1, #entities.visible.data do
--		entities.visible.data[i].addToBuffer()
--	end
--end

function entities.addToBuffer(viewport)
	for i = 1, #viewport.entities do
		viewport.entities[i].addToBuffer(viewport)
	end
end