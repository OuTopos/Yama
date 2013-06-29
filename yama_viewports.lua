local viewports = {}

function viewports.new(name, x, y, r, width, height, sx, sy, zoom)
	local public = {}
	local private = {}

	function public.set(name, x, y, r, width, height, sx, sy, zoom)
		-- Setting all the variables
		private.name = name
		private.x = x or 0
		private.y = y or 0
		public.r = r or 0
		private.width = width or screen.width
		private.height = height or screen.height
		private.sx = sx or 1
		private.sy = sy or 1
		private.zoom = zoom or false


		-- Create a camera and set the size
		public.camera = yama.cameras.new(private.name)
		public.camera.setSize(private.width/private.sx, private.height/private.sy)

		-- Create a canvas
		if private.zoom then
			public.camera.setScale(private.sx, private.sy)

			public.canvas = love.graphics.newCanvas(private.width, private.height)
			private.sx = 1
			private.sy = 1

		else
			public.canvas = love.graphics.newCanvas(private.width/private.sx, private.height/private.sy)
		end

		--public.canvas:setFilter("nearest", "nearest")

		-- Create a buffer
		private.buffer = yama.buffers.new()

		private.compass = yama.map.compasses.new()
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

		love.graphics.draw(public.canvas, private.x, private.y, public.r, private.sx, private.sy)
	end

	public.set(name, x, y, r, width, height, sx, sy, zoom)

	return public

end

return viewports