local viewports = {}
viewports.list = {}

function viewports.new(x, y, r, width, height, sx, sy, zoom)
	local self = {}

	self.x = x or 0
	self.y = y or 0
	self.r = r or 0

	self.width = width or screen.width
	self.height = height or screen.height
	self.sx = sx or 1
	self.sy = sy or 1
	self.zoom = zoom or false


	-- Create the camera
	self.camera = yama.cameras.new(self)

	-- Create the buffer
	self.buffer = yama.buffers.new(self)

	-- Create the map
	self.map = yama.maps.new(self)

	-- Create table to store visible entities	
	self.entities = {}

	function self.reSize()
		self.camera.setSize(self.width/self.sx, self.height/self.sy)

		-- Create a canvas
		if self.zoom then
			-- If zoom then scaling is done with the camera.
			self.camera.setScale(self.sx, self.sy)

			self.canvas = love.graphics.newCanvas(self.width, self.height)
			self.sx = 1
			self.sy = 1

		else
			-- Scaling is done with the canvas.
			self.canvas = love.graphics.newCanvas(self.width/self.sx, self.height/self.sy)
		end

		self.canvas:setFilter("nearest", "nearest")
	end

	function self.setSize(width, height, sx, sy, zoom)
		self.width = width or screen.width
		self.height = height or screen.height
		self.sx = sx or self.sx
		self.sy = sy or self.sy
		self.zoom = zoom or self.zoom
		self.reSize()
	end

	function self.setScale(sx, sy, zoom)
		self.sx = sx or self.sx
		self.sy = sy or sx or self.sy
		self.zoom = zoom or self.zoom
		self.reSize()
	end

	function self.update(dt)
		if self.map.data then
			if not self.map.data.updated then
				self.map.data.world:update(dt)
				self.map.data.updated = true
			end
			entities.update(dt, self)
		end
		self.camera.update(dt)
		self.map.update(dt)
	end

	function self.updated()
		if self.map.data then
			entities.data[self.map].updated = false
			self.map.data.updated = false
		end
	end


	function self.draw()
		self.camera.set()
		love.graphics.setCanvas(self.canvas)

		-- Check if the buffer has been reset 
		if next(self.buffer.data) == nil then
			if self.map.data then
				entities.addToBuffer(self)
				self.map.addToBuffer()
			end
		end

		-- Draw the buffer
		self.buffer.draw()

		yama.hud.drawR(self)

		-- Draw the GUI
		--yama.gui.draw()

		self.camera.unset()
		yama.hud.draw(self)
		love.graphics.setCanvas()

		-- Draw the HUD
		--yama.hud.draw(self)

		love.graphics.draw(self.canvas, self.x, self.y, self.r, self.sx, self.sy)
	end

	self.reSize()

	return self

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