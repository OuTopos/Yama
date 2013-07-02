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
	private.buffer = yama.buffers.new()

	-- Create the compass
	private.compass = yama.map.compasses.new()


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

	function public.update(dt)
		entities.update(dt, public.camera, private.buffer)
		public.camera.update(dt)
		private.compass.update(public.camera, private.buffer)
	end

	function public.draw()
		public.camera.set()
		love.graphics.setCanvas(public.canvas)

		-- Check if the buffer has been reset 
		if next(private.buffer.data) == nil then
			entities.addToBuffer(public.camera, private.buffer)
			yama.map.addToBuffer2(private.compass, private.buffer)
		end

		-- Draw the buffer
		private.buffer.draw()



		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.print("FPS: "..love.timer.getFPS(), public.camera.x + public.camera.width - 39, public.camera.y + 3)

		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.print("FPS: "..love.timer.getFPS(), public.camera.x + public.camera.width - 39, public.camera.y + 2)

		-- Draw the GUI
		--yama.gui.draw()

		-- Draw the HUD
		yama.hud.draw(public.camera, private.buffer, public.canvas)

		public.camera.unset()
		love.graphics.setCanvas()

		love.graphics.draw(public.canvas, public.x, public.y, public.r, private.sx, private.sy)
	end

	public.reSize()

	return public

end

return viewports