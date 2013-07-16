local viewports = {}
viewports.list = {}

function viewports.new(x, y, r, width, height, sx, sy, zoom)
	local public = {}
	local private = {}

	private.x = x or 0
	private.y = y or 0
	private.r = r or 0

	private.width = width or screen.width
	private.height = height or screen.height
	private.sx = sx or private
	private.sy = sy or 1
	private.zoom = zoom or false


	-- Create the camera
	private.camera = yama.cameras.new(private)

	-- Create the buffer
	private.buffer = yama.buffers.new(private)

	-- Create table to store visible entities
	private.swarm = yama.swarms.add(public)

	-- Create the map
	private.map = yama.maps.new(public)

	--private.map = yama.maps.add(public)


	public.entities = {}

	function public.reSize()
		private.camera.setSize(private.width/private.sx, private.height/private.sy)

		-- Create a canvas
		if private.zoom then
			-- If zoom then scaling is done with the camera.
			private.camera.setScale(private.sx, private.sy)

			private.canvas = love.graphics.newCanvas(private.width, private.height)
			private.sx = 1
			private.sy = 1

		else
			-- Scaling is done with the canvas.
			private.canvas = love.graphics.newCanvas(private.width/private.sx, private.height/private.sy)
		end

		private.canvas:setFilter("nearest", "nearest")
	end

	function public.setSize(width, height, sx, sy, zoom)
		private.width = width or screen.width
		private.height = height or screen.height
		private.sx = sx or private.sx
		private.sy = sy or private.sy
		private.zoom = zoom or private.zoom
		public.reSize()
	end

	function public.setScale(sx, sy, zoom)
		private.sx = sx or private.sx
		private.sy = sy or sx or private.sy
		private.zoom = zoom or private.zoom
		public.reSize()
	end

	function public.update(dt)
		--if private.map.data then
			--if not private.map.data.updated then
				--private.map.data.world:update(dt)
				--private.map.data.updated = true
			--end
		private.swarm.update(dt, public)
		private.swarm.setUpdated(true)
			--entities.update(dt, private)
		--end
		--update swarm (incl phys)
		--private.swarm.update(dt, vp)
		--update maps
		--update 
		private.camera.update(dt, public)
		private.map.update(dt, public)
	end

	function public.updated()
		if private.map.data then
			private.swarm.setUpdated(false)
			private.map.data.updated = false
		end
	end


	function public.draw()
		private.camera.set()
		love.graphics.setCanvas(private.canvas)


		-- Check if the buffer has been reset 
		if next(private.buffer.data) == nil then
			if private.map.data then
				private.swarm.addToBuffer(public)
				private.map.addToBuffer(public)
			end
		end

		-- Draw the buffer
		private.buffer.draw()

		yama.hud.drawR(public)

		-- Draw the GUI
		--yama.gui.draw()

		private.camera.unset()
		yama.hud.draw(public)
		love.graphics.setCanvas()

		-- Draw the HUD
		--yama.hud.draw(private)

		love.graphics.draw(private.canvas, private.x, private.y, private.r, private.sx, private.sy)
		private.buffer.reset()
	end

	function public.getCamera()
		return private.camera
	end

	function public.getBuffer()
		return private.buffer
	end

	function public.getMap()
		return private.map
	end

	function public.getSwarm()
		return private.swarm
	end

	function public.getWidth()
		return private.width
	end

	function public.getHeight()
		return private.height
	end

	function public.getSx()
		return private.sx
	end

	function public.getSy()
		return private.sy
	end

	public.reSize()

	return public

end

function viewports.add(name, x, y, r, width, height, sx, sy, zoom)
	viewports.list[name] = yama.viewports.new(x, y, r, width, height, sx, sy, zoom)
end

function viewports.remove(name)
	table.remove(viewports.list, name)
end

function viewports.update(dt)
	for i, vp in next, viewports.list do
		vp.update(dt)
		vp.updated()
	end
end

function viewports.draw()
	for i, vp in next, viewports.list do
		vp.draw()
	end
end

return viewports