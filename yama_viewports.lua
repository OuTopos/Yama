local viewports = {}
viewports.list = {}

function viewports.new()
	local public = {}
	local private = {}

	private.map = nil
	private.entity = nil

	private.x = x or 0
	private.y = y or 0
	private.r = r or 0

	private.width = yama.screen.width
	private.height = yama.screen.height

	private.sx = 1
	private.sy = 1
	private.csx = 1
	private.csy = 1

	private.zoom = true


	-- BOUNDARIES
	private.boundaries = {}
	private.boundaries.x = 0
	private.boundaries.y = 0
	private.boundaries.width = yama.screen.width
	private.boundaries.height = yama.screen.height

	function private.boundaries.apply()
		if private.camera.width <= private.boundaries.width then
			if private.camera.x < private.boundaries.x then
				private.camera.x = private.boundaries.x
			elseif private.camera.x > private.boundaries.width - private.camera.width then
				private.camera.x = private.boundaries.width - private.camera.width
			end
		else
			private.camera.x = private.boundaries.x - (private.camera.width - private.boundaries.width) / 2
		end

		if private.camera.height <= private.boundaries.height then
			if private.camera.y < private.boundaries.y then
				private.camera.y = private.boundaries.y
			elseif private.camera.y > private.boundaries.height - private.camera.height then
				private.camera.y = private.boundaries.height - private.camera.height
			end
		else
			private.camera.y = private.boundaries.y - (private.camera.height - private.boundaries.height) / 2
		end
	end

	function public.setBoundaries(x, y, width, height)
		private.boundaries.x = x
		private.boundaries.y = y
		private.boundaries.width = width
		private.boundaries.height = height
	end


	-- CAMERA
	private.camera = {}
	private.camera.x = 0
	private.camera.y = 0
	private.camera.r = 0

	private.camera.width = yama.screen.width
	private.camera.height = yama.screen.height

	private.camera.sx = 1
	private.camera.sy = 1

	private.camera.cx = 0
	private.camera.cy = 0
	private.camera.radius = 0

	function private.camera.update()
		private.camera.cx = private.camera.x + private.camera.width / 2
		private.camera.cy = private.camera.y + private.camera.height / 2
		private.camera.radius = yama.g.getDistance(private.camera.cx, private.camera.cy, private.camera.x, private.camera.y)
	end

	function private.camera.resize()
		private.camera.width = private.width / private.sx
		private.camera.height = private.height / private.sy

		if private.zoom then
			private.camera.sx = private.sx
			private.camera.sy = private.sy
		else
			private.camera.sx = 1
			private.camera.sy = 1
		end
	end

	function private.camera.set()
		love.graphics.push()
		love.graphics.translate(private.camera.width / 2 * private.camera.sx, private.camera.height / 2 * private.camera.sy)
 		love.graphics.rotate(- private.camera.r)
		love.graphics.translate(- private.camera.width / 2 * private.camera.sx, - private.camera.height / 2 * private.camera.sy)
		love.graphics.scale(private.camera.sx, private.camera.sy)
		love.graphics.translate(- private.camera.x, - private.camera.y)
	end

	function private.camera.unset()
		love.graphics.pop()
	end

	function private.camera.position(x, y)
		private.camera.x = x
		private.camera.y = y
		private.boundaries.apply()
	end

	function private.camera.center(x, y)
		private.camera.position(x - private.camera.width / 2, y - private.camera.height / 2)
	end


	-- MAP VIEW
	private.mapview = {}
	private.mapview.x = 0
	private.mapview.y = 0
	private.mapview.width = 0
	private.mapview.height = 0
	private.mapview.tilewidth = 1
	private.mapview.tilewidth = 1

	function private.mapview.update()
		-- Get the new map view coordinates in tiles (not pixels).
		local x = math.floor(private.camera.x / private.mapview.tilewidth)
		local y = math.floor(private.camera.y / private.mapview.tilewidth)

		-- Compare them to the old.
		if x ~= private.mapview.x or y ~= private.mapview.y then
			-- If the map view moved assign the new to the map view coordinates.
			private.mapview.x = x
			private.mapview.y = y
			-- And trigger a buffer reset.
			private.buffer.reset()	
		end
	end

	function private.mapview.resize()
		-- Get the tilewidth and tileheight from the map.
		private.mapview.tilewidth, private.mapview.tileheight = private.map.getTilewidth(), private.map.getTileheight()
		-- Get the size of the the map view in tiles (not pixels).
		private.mapview.width = math.ceil(private.camera.width / private.mapview.tilewidth) + 1
		private.mapview.height = math.ceil(private.camera.height / private.mapview.tilewidth) + 1
	end


	-- Create the buffer
	private.buffer = yama.buffers.new(private)
	-- BUFFER


	--public.entities = {}


	private.camera.round = false


	private.camera.follow = nil

	function private.camera.isInside2(x, y, width, height)
		if x+width > private.camera.x and x < private.camera.x+private.camera.width and y+height > private.camera.y and y < private.camera.y+private.camera.height then
			return true
		else
			return false
		end
	end

	

	function private.camera.isInside(x, y, radius)
		if yama.g.getDistance(private.camera.cx, private.camera.cy, x, y) < private.camera.radius + radius then
			return true
		else
			return false
		end
	end



	-- VIEWPORT
	function private.resize()
		if private.zoom then
			private.canvas = love.graphics.newCanvas(private.width, private.height)
			private.csx, private.csy = 1, 1
		else
			private.canvas = love.graphics.newCanvas(private.width / private.sx, private.height / private.sy)
			private.csx, private.csy = private.sx, private.sy
		end

		private.camera.resize()
		private.mapview.resize()

		private.canvas:setFilter("nearest", "nearest")
	end




	function public.update(dt, map)
		if private.entity then
			private.camera.center(private.entity.getX(), private.entity.getY())
		end
		private.camera.update()
		private.mapview.update()
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

		love.graphics.draw(private.canvas, private.x, private.y, private.r, private.csx, private.csy)
		--private.buffer.reset()
	end






	function public.isEntityInside(entity)
		if yama.g.getDistance(private.camera.cx, private.camera.cy, entity.getCX(), entity.getCY()) < private.camera.radius + entity.getRadius() then
			return true
		else
			return false
		end
	end



	function public.setPosition(x, y)
		private.x = x or 0
		private.y = y or 0
	end

	function public.setSize(width, height, sx, sy, zoom)
		private.width = width or screen.width
		private.height = height or screen.height
		private.sx = sx or private.sx
		private.sy = sy or private.sy
		private.zoom = zoom or private.zoom
		private.resize()
	end

	function public.setScale(sx, sy, zoom)
		private.sx = sx or private.sx
		private.sy = sy or sx or private.sy
		if zoom == false then
			private.zoom = false
		else
			private.zoom = true
		end
		private.resize()
	end



	function public.view(map, entity)
		if map then
			if private.map then
				private.map.removeViewport(public)
			end
			private.map = map
			private.map.addViewport(public)

			
			private.resize()
		else
			if private.map then
				private.map.removeViewport(public)
			end
			private.map = nil
		end

		if entity then
			if private.entity then
				private.entity.vp = nil
			end
			private.entity = entity
			entity.vp = public

			private.camera.follow = entity
		else
			if private.entity then
				private.entity.vp = nil
			end
			private.entity = nil
		end
	end

	function public.getCamera()
		return private.camera
	end

	function public.getMapview()
		return private.mapview
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