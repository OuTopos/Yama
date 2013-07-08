entities = {}
entities.data = {}

entities.destroyQueue = {}

require	"entitiesBase"
-- Entity types
require	"entities_player"
require	"entities_fplayer"
require	"entities_pplayer"
require	"entities_tree"
require	"entities_coin"
require	"entities_turret"
require	"entities_ball"
require	"entities_projectile"
require	"entities_monster"
require	"entities_humanoid"
require "entities_mplayer"

function entities.new(type, x, y, z, vp)
	if not entities.data[vp.map] then
		entities.data[vp.map] = {}
	end
	local entity = _G["entities_"..type].new(x, y, z, vp)
	table.insert(entities.data[vp.map], entity)
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

function entities.update(dt, vp)
	vp.entities = {}

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
	for key=1, #entities.data[vp.map] do
		local entity = entities.data[vp.map][key]
		local wasVisible = entity.visible[vp] or false
		local isVisible = vp.camera.isInside(entity.cx, entity.cy, entity.radius)
		
		if wasVisible and isVisible then
			table.insert(vp.entities, entity)
		elseif not wasVisible and isVisible then
			table.insert(vp.entities, entity)
			entity.visible[vp] = true
			vp.buffer.reset()
		elseif wasVisible and not isVisible then
			entity.visible[vp] = false
			vp.buffer.reset()
		end

		if not entities.data[vp.map].updated then
			entity.update(dt)
		end
	end
	entities.data[vp.map].updated = true
end

--function entities.addToBuffer()
	--table.sort(entities.visible.data, entities.visible.sort)
--	for i = 1, #entities.visible.data do
--		entities.visible.data[i].addToBuffer()
--	end
--end

function entities.addToBuffer(vp)
	for i = 1, #vp.entities do
		vp.entities[i].addToBuffer(vp)
	end
end