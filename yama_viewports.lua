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

	-- Create the map
	private.map = nil

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

	function public.update(dt, map)
		private.camera.update(dt, public, map)
	end

	function public.draw()
		private.camera.set()
		love.graphics.setCanvas(private.canvas)

		-- Draw the buffer
		private.buffer.draw()

		yama.hud.drawR(public)

		-- Draw the GUI
		--yama.gui.draw()

		private.camera.unset()
		yama.hud.draw(public)
		love.graphics.setCanvas()

		love.graphics.draw(private.canvas, private.x, private.y, private.r, private.sx, private.sy)
		--private.buffer.reset()
	end

	function public.view(map)
		if map then
			if private.map then
				private.map.removeViewport(public)
			end
			private.map = map
			private.map.addViewport(public)
		else
			if private.map then
				private.map.removeViewport(public)
			end
			private.map = nil
		end

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

	table.insert(viewports.list, public)
	return public

end

function viewports.remove(name)
	table.remove(viewports.list, name)
end

function viewports.update(dt)
	for i = 1, #viewports.list do
		viewports.list[i].update(dt)
		viewports.list[i].updated()
	end
end

function viewports.draw()
	for i = 1, #viewports.list do
		viewports.list[i].draw()
	end
end

return viewports