local swarms = {}
swarms.list = {}

function swarms.new()
	local public = {}
	local private = {}

	-- Creating a physics world
	private.world = love.physics.newWorld()

	private.entities = {}

	private.updated = false
	private.random = math.random(1, 1000)

	private.viewports = {}

	function public.insert(entity)
		table.insert(private.entities, entity)
		entity.visible = {}
	end

	function public.update(dt, vp)
		if not private.updated then
			private.world:update(dt)
		end
		-- Update and add to buffer
		for key=1, #private.entities do
			local entity = private.entities[key]

			if entity.destroyed then
				table.remove(private.entities, key)
				key = key - 1
			else
				local wasVisible = entity.visible[vp] or false
				local isVisible = vp.getCamera().isInside(entity.cx, entity.cy, entity.radius)
				
				if wasVisible and isVisible then
					table.insert(vp.entities, entity)
				elseif not wasVisible and isVisible then
					table.insert(vp.entities, entity)
					entity.visible[vp] = true
					vp.getBuffer().reset()
				elseif wasVisible and not isVisible then
					entity.visible[vp] = false
					vp.getBuffer().reset()
				end

				if not private.updated then
					entity.update(dt)
				end
			end
		end
		public.updated = true
	end

	function public.setUpdated(updated)
		private.updated = updated
		private.viewports = {}
	end

	function public.addToBuffer(vp)
		for i = 1, #vp.entities do
			vp.entities[i].addToBuffer(vp)
		end
		vp.entities = {}
	end

	function public.getWorld()
		return private.world
	end

	function public.getEntities()
		return private.entities
	end

	function public.addViewport(vp)
		table.insert(private.viewports, vp)
	end

	return public
end

function swarms.add()
	local swarm = swarms.new()
	table.insert(swarms.list, swarm)
	return swarm
end

function swarms.update(dt)
	for i = 1, #swarms.list do
	end
end

return swarms