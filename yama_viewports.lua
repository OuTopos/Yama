local viewports = {}

function viewports.new(x, y, r, width, height, sx, sy, zoom)
	local public = {}
	local private = {}

	public.x = x or 0
	public.y = y or 0
	public.r = r or 0

	private.width = width or screen.width
	private.height = height or screen.height
	private.sx = sx or 1
	private.sy = sy or 1
	private.zoom = zoom or false


	-- Create the camera
	public.camera = yama.cameras.new()

	-- Create the buffer
	public.buffer = yama.buffers.new()

	-- Create the map
	public.map = yama.maps.new()

	-- Create table to store visible entities	
	public.entities = {}

	function public.reSize()
		public.camera.setSize(private.width/private.sx, private.height/private.sy)

		-- Create a canvas
		if private.zoom then
			-- If zoom then scaling is done with the camera.
			public.camera.setScale(private.sx, private.sy)

			public.canvas = love.graphics.newCanvas(private.width, private.height)
			private.sx = 1
			private.sy = 1

		else
			-- Scaling is done with the canvas.
			public.canvas = love.graphics.newCanvas(private.width/private.sx, private.height/private.sy)
		end

		public.canvas:setFilter("nearest", "nearest")
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
		if public.map.data then
			if not public.map.data.updated then
				public.map.data.world:update(dt)
				public.map.data.updated = true
			end
			entities.update(dt, public)
		end
		public.camera.update(dt, public)
		public.map.update(dt, public)
	end

	function public.updated()
		if public.map.data then
			entities.data[public.map].updated = false
			public.map.data.updated = false
		end
	end


	function public.draw()
		public.camera.set()
		love.graphics.setCanvas(public.canvas)

		-- Check if the buffer has been reset 
		if next(public.buffer.data) == nil then
			if public.map.data then
				entities.addToBuffer(public)
				public.map.addToBuffer(public)
			end
		end

		-- Draw the buffer
		public.buffer.draw()

		-- Draw the GUI
		--yama.gui.draw()

		-- Draw the HUD
		yama.hud.draw(public.camera, public.buffer, public.canvas)

		public.camera.unset()
		love.graphics.setCanvas()

		love.graphics.draw(public.canvas, public.x, public.y, public.r, private.sx, private.sy)
	end

	public.reSize()

	return public

end

return viewports