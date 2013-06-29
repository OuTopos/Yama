local cameras = {}

function cameras.new(name)
	local public = {}
	local private = {}
	
	public.name = name

	public.x = 0
	public.y = 0
	public.width = 0
	public.height = 0
	public.sx = 1
	public.sy = 1
	public.boundaries = {}
	public.boundaries.x = 0
	public.boundaries.y = 0
	public.boundaries.width = 0
	public.boundaries.height = 0
	public.round = false
	public.follow = nil

	function public.set()
		love.graphics.push()
		love.graphics.scale(public.sx, public.sy)
		love.graphics.translate(-public.x, -public.y)
	end

	function public.unset()
		love.graphics.pop()
	end

	function public.update(dt)
		if public.follow then
			public.center(public.follow.getX(), public.follow.getY())
		else
			local dx, dy = 0, 0
			if love.keyboard.isDown("up") then
				dy = -100 * dt
			end
			if love.keyboard.isDown("right") then
				dx = 100 * dt
			end
			if love.keyboard.isDown("down") then
				dy = 100 * dt
			end
			if love.keyboard.isDown("left") then
				dx = -100 * dt
			end
		end
		public.boundary()
	end

	function public.setPosition(x, y)
		public.x = x
		public.y = y
		if public.round then
			public.x = math.floor(public.x + 0.5)
			public.y = math.floor(public.y + 0.5)
		end
	end

	function public.center(x, y)
		public.setPosition(x - public.width / 2, y - public.height / 2)
	end

	function public.boundary()
		if public.width <= public.boundaries.width then
			if public.x < public.boundaries.x then
				public.x = public.boundaries.x
			elseif public.x > public.boundaries.width - public.width then
				public.x = public.boundaries.width - public.width
			end
		else
			public.x = public.boundaries.x - (public.width - public.boundaries.width) / 2
		end

		if public.height <= public.boundaries.height then
			if public.y < public.boundaries.y then
				public.y = public.boundaries.y
			elseif public.y > public.boundaries.height - public.height then
				public.y = public.boundaries.height - public.height
			end
		else
			public.y = public.boundaries.y - (public.height - public.boundaries.height) / 2
		end
	end

	function public.setSize(width, height, sx, sy)
		public.sx = sx or public.sx
		public.sy = sy or public.sy
		public.width = width or public.width / public.sx
		public.height = height or public.height / public.sy
	end



	function public.setScale(sx, sy)
		public.sx = sx or public.sx
		public.sy = sy or public.sy
	end

	function public.setBoundaries(x, y, width, height)
		public.boundaries.x = x
		public.boundaries.y = y
		public.boundaries.width = width
		public.boundaries.height = height
	end

	function public.isInside(x, y, width, height)
		if x+width > public.x and x < public.x+public.width and y+height > public.y and y < public.y+public.height then
			return true
		else
			return false
		end
	end

	return public
end

return cameras