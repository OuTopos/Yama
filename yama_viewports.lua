local viewports = {}

function viewports.new()
	local public = {}
	local private = {}

	-- DEBUG
	public.debug = {}
	public.debug.drawcalls = 0
	public.debug.redraws = 0


	private.buffer = {}


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

	function private.camera.setPosition(x, y, center)
		if center then
			private.camera.x = x - private.camera.width / 2
			private.camera.y = y - private.camera.height / 2
		else
			private.camera.x = x
			private.camera.y = y
		end
		private.boundaries.apply()
	end

	-- BOUNDARIES
	private.boundaries = {}
	private.boundaries.x = 0
	private.boundaries.y = 0
	private.boundaries.width = 0
	private.boundaries.height = 0

	function private.boundaries.apply()
		if not (private.boundaries.x == 0 and private.boundaries.y == 0 and private.boundaries.width == 0 and private.boundaries.height == 0) then
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
	end

	function public.setBoundaries(x, y, width, height)
		private.boundaries.x = x
		private.boundaries.y = y
		private.boundaries.width = width
		private.boundaries.height = height
	end


	-- MAP VIEW
	private.mapview = {}
	private.mapview.x = 0
	private.mapview.y = 0
	private.mapview.width = 0
	private.mapview.height = 0
	private.mapview.tilewidth = 1
	private.mapview.tilewidth = 1

	-- RESET
	function public.reset()
		print("Hy reset?")
		-- Set buffer to empty table.
		--private.buffer = {}

		public.debug.redraws = 0
	end

	function public.addToBuffer(object)
		table.insert(private.buffer, object)
	end

	-- SORTING
	private.sortmode = "z"
	private.sortmodes = {}

	function public.setSortMode(mode)
		if private.sortmodes[mode] then
			private.sortmode = mode
		else
			private.sortmode = "z"
		end
	end

	function private.sortmodes.z(a, b)
		if a.z < b.z then
			return true
		end
		return false
	end

	function private.sortmodes.y(a, b)
		if a.y < b.y then
			return true
		end
		return false
	end

	function private.sortmodes.yz(a, b)
		if a.y+a.z < b.y+b.z then
			return true
		end
		if a.z == b.z then
			if a.y < b.y then
				return true
			end
			if a.y == b.y then
				if a.x < b.x then
					return true
				end
			end
		end
		return false
	end


	-- RESIZE
	function private.resize()
		if private.zoom then
			-- This means that scaling will be done by scaling the camera.
			private.canvas = love.graphics.newCanvas(private.width, private.height)
			private.csx, private.csy = 1, 1
		else
			-- This means scaling will be done by scaling the canvas.
			private.canvas = love.graphics.newCanvas(private.width / private.sx, private.height / private.sy)
			private.csx, private.csy = private.sx, private.sy
		end
		-- Setting the filtering for canvas.
		private.canvas:setFilter("nearest", "nearest")

		-- RESIZE CAMERA
		private.camera.width = private.width / private.sx
		private.camera.height = private.height / private.sy

		if private.zoom then
			private.camera.sx = private.sx
			private.camera.sy = private.sy
		else
			private.camera.sx = 1
			private.camera.sy = 1
		end

		-- RESIZE MAP VIEW
		-- Get the tilewidth and tileheight from the map.
		private.mapview.tilewidth, private.mapview.tileheight = private.map.getTilewidth(), private.map.getTileheight()
		-- Get the size of the the map view in tiles (not pixels).
		private.mapview.width = math.ceil(private.camera.width / private.mapview.tilewidth) + 1
		private.mapview.height = math.ceil(private.camera.height / private.mapview.tilewidth) + 1
	end


	-- UPDATE
	function public.update(dt)
		if private.entity then
			local x, y = private.entity.getPosition()
			private.camera.setPosition(x, y, true)
		end

		-- UPDATE CAMERA
		private.camera.cx = private.camera.x + private.camera.width / 2
		private.camera.cy = private.camera.y + private.camera.height / 2
		private.camera.radius = yama.g.getDistance(private.camera.cx, private.camera.cy, private.camera.x, private.camera.y)

		-- UPDATE MAP VIEW
		-- Get the new map view coordinates in tiles (not pixels).
		private.mapview.x = math.floor(private.camera.x / private.mapview.tilewidth)
		private.mapview.y = math.floor(private.camera.y / private.mapview.tilewidth)

		--[[
		-- Compare them to the old.
		if x ~= private.mapview.x or y ~= private.mapview.y then
			-- If the map view moved assign the new to the map view coordinates.
			private.mapview.x = x
			private.mapview.y = y
			-- And trigger a buffer reset.
			public.reset()
		end
		--]]
	end


	-- DRAW
	function public.draw()
		-- SET CAMERA
		love.graphics.push()
		love.graphics.translate(private.camera.width / 2 * private.camera.sx, private.camera.height / 2 * private.camera.sy)
 		love.graphics.rotate(- private.camera.r)
		love.graphics.translate(- private.camera.width / 2 * private.camera.sx, - private.camera.height / 2 * private.camera.sy)
		love.graphics.scale(private.camera.sx, private.camera.sy)
		love.graphics.translate(- private.camera.x, - private.camera.y)
		
		-- SET CANVAS
		love.graphics.setCanvas(private.canvas)

		-- DRAW BUFFER
		public.debug.redraws = public.debug.redraws + 1
		public.debug.drawcalls = 0
		public.debug.drawcalls = 0

		private.bufferSize = #private.buffer

		public.debug.bufferSize = private.bufferSize

		table.sort(private.buffer, private.sortmodes[private.sortmode])

		for i = 1, private.bufferSize do
			if private.buffer[i].type == "batch" then
				private.drawBatch(private.buffer[i])
			else
				private.drawObject(private.buffer[i])
			end
		end

		-- EMPTY BUFFER
		private.buffer = {}

		-- DRAW DEBUG GRAPHICS
		yama.hud.drawR(public)

		-- UNSET CAMERA
		love.graphics.pop()

		-- UNSET CANVAS
		love.graphics.setCanvas()

		-- DRAW CANVAS
		love.graphics.draw(private.canvas, private.x, private.y, private.r, private.csx, private.csy)

		-- DRAW GUI
		--yama.gui.draw()

		-- DRAW DEBUG TEXT
		yama.hud.draw(public)
	end

	function private.drawBatch(batch)
		for i = 1, #batch.data do
			private.drawObject(batch.data[i])
		end
	end

	function private.drawObject(object)
		-- SET COLOR, COLORMODE, BLENDMODE
		if object.color then
			love.graphics.setColor(object.color)
		end
		if object.colormode then
			love.graphics.setColorMode(object.colormode)
		end
		if object.blendmode then
			love.graphics.setBlendMode(object.blendmode)
		end

		-- THE ACTUAL DRAW
		if object.type == "drawable" then
			-- DRAWABLE
			love.graphics.draw(object.drawable, object.x, object.y, object.r, object.sx, object.sy, object.ox, object.oy, object.kx, object.ky)
			public.debug.drawcalls = public.debug.drawcalls + 1
		elseif object.type == "sprite" then
			-- SPRITE
			love.graphics.drawq(object.image, object.quad, object.x, object.y, object.r, object.sx, object.sy, object.ox, object.oy, object.kx, object.ky)
			public.debug.drawcalls = public.debug.drawcalls + 1
			
			--[[
			love.graphics.setColor(255, 255, 0, 255)
			love.graphics.circle("line", object.x, object.y, 2)
			love.graphics.setColor(0, 0, 0, 255)
			love.graphics.print(math.floor(object.x + 0.5), object.x + 2, object.y + 2)
			love.graphics.print(" "..math.floor(object.y + 0.5), object.x + 2, object.y + 12)
			love.graphics.print("  "..object.z, object.x + 2, object.y + 22)
			love.graphics.setColor(255, 255, 2550, 255)
			--]]
		end

		-- RESET COLOR, COLORMODE, BLENDMODE
		if object.color then
			love.graphics.setColor(255, 255, 255, 255)
		end
		if object.colormode then
			love.graphics.setColorMode("modulate")
		end
		if object.blendmode then
			love.graphics.setBlendMode("alpha")
		end
	end

	-- MISC

	function public.isEntityInside(entity)
		-- Check distance
		--[[
		if yama.g.getDistance(private.camera.cx, private.camera.cy, entity.getCX(), entity.getCY()) < private.camera.radius + entity.getRadius() then
			return true
		else
			return false
		end
		--]]

		-- Check bounding box
		local x, y, width, height = entity.getBoundingBox()

		if x + width > private.camera.x and x < private.camera.x + private.camera.width and y + height > private.camera.y and y < private.camera.y + private.camera.height then
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

	function public.getX()
		return private.x
	end

	function public.getY()
		return private.y
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

	return public

end

return viewports