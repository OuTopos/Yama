local swarms = {}
swarms.list = {}

function swarms.new()
	local public = {}
	local private = {}

	-- Creating a physics world
	private.world = love.physics.newWorld()

	private.entities = {}

	private.updated = false

	private.viewports = {}

	function public.insert(entity)
		table.insert(private.entities, entity)
		entity.visible = {}
	end

	function public.update(dt, map)
		-- Update and add to buffer
		for key=1, #private.entities do
			local entity = private.entities[key]

			if entity.destroyed then
				table.remove(private.entities, key)
				key = key - 1
			else
				entity.update(dt)
				local viewports = map.getViewports()
				for i=1, #viewports do
					local vp = viewports[i]
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
				end
			end
		end
		public.updated = true
	end

	function public.setUpdated(updated)
		--private.updated = updated
		--private.viewports = {}
	end

	function public.addToBuffer(vp)
		for i = 1, #vp.entities do
			vp.entities[i].addToBuffer(vp)
		end
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

return swarms