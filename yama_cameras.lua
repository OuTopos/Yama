local cameras = {}

function cameras.new(vp)
	local self = {}

	self.x = 0
	self.y = 0
	self.r = 0
	self.width = 0
	self.height = 0
	self.sx = 1
	self.sy = 1
	self.cx = 0
	self.cy = 0
	self.radius = 0
	self.boundaries = {}
	self.boundaries.x = 0
	self.boundaries.y = 0
	self.boundaries.width = 0
	self.boundaries.height = 0
	self.round = false
	self.follow = nil

	self.view = {}

	local poop = 0

	function self.set()
		love.graphics.push()
		love.graphics.translate(self.width/2*self.sx, self.height/2*self.sy)
 		love.graphics.rotate(-self.r)
		love.graphics.translate(-self.width/2*self.sx, -self.height/2*self.sy)
		love.graphics.scale(self.sx, self.sy)
		love.graphics.translate(-self.x, -self.y)
	end

	function self.unset()
		love.graphics.pop()
	end

	function self.update(dt, vp, map)
		if self.follow then
			self.center(self.follow.getX(), self.follow.getY())
		end
		if love.keyboard.isDown("k") then
			self.r = 0
		end
		if love.keyboard.isDown("m") then
			self.r = self.r + 1 * dt
		end
		if love.keyboard.isDown("n") then
			self.r = self.r - 1 * dt
		end

		self.view.width = math.ceil(self.width/map.getTilewidth()) + 1
		self.view.height = math.ceil(self.height/map.getTileheight()) + 1

		-- Moving the map view to camera x,y
		local x = math.floor(self.x/map.getTilewidth())
		local y = math.floor(self.y/map.getTileheight())

		if x ~= self.view.x or y ~= self.view.y then
			-- Camera moved to another tile
			self.view.x = x
			self.view.y = y

			-- Trigger a buffer reset.
			vp.getBuffer().reset()	
		end
	end

	function self.setPosition(x, y)
		self.x = x
		self.y = y
		self.boundary()
		--if self.round then
		--	self.x = math.floor(self.x + 0.5)
		--	self.y = math.floor(self.y + 0.5)
		--end
		self.cx = self.x + self.width / 2
		self.cy = self.y + self.height / 2
		self.radius = yama.g.getDistance(self.cx, self.cy, self.x, self.y)
	end

	function self.center(x, y)
		self.setPosition(x - self.width / 2, y - self.height / 2)
	end

	function self.boundary()
		if self.width <= self.boundaries.width then
			if self.x < self.boundaries.x then
				self.x = self.boundaries.x
			elseif self.x > self.boundaries.width - self.width then
				self.x = self.boundaries.width - self.width
			end
		else
			self.x = self.boundaries.x - (self.width - self.boundaries.width) / 2
		end

		if self.height <= self.boundaries.height then
			if self.y < self.boundaries.y then
				self.y = self.boundaries.y
			elseif self.y > self.boundaries.height - self.height then
				self.y = self.boundaries.height - self.height
			end
		else
			self.y = self.boundaries.y - (self.height - self.boundaries.height) / 2
		end
	end

	function self.setSize(width, height, sx, sy)
		self.sx = sx or self.sx
		self.sy = sy or self.sy
		self.width = width or self.width / self.sx
		self.height = height or self.height / self.sy
	end



	function self.setScale(sx, sy)
		self.sx = sx or self.sx
		self.sy = sy or self.sy
	end

	function self.setBoundaries(x, y, width, height)
		self.boundaries.x = x
		self.boundaries.y = y
		self.boundaries.width = width
		self.boundaries.height = height
	end

	function self.isInside2(x, y, width, height)
		if x+width > self.x and x < self.x+self.width and y+height > self.y and y < self.y+self.height then
			return true
		else
			return false
		end
	end

	function self.isEntityInside(entity)
		if yama.g.getDistance(self.cx, self.cy, entity.getCX(), entity.getCY()) < self.radius + entity.getRadius() then
			return true
		else
			return false
		end
	end

	function self.isInside(x, y, radius)
		if yama.g.getDistance(self.cx, self.cy, x, y) < self.radius + radius then
			return true
		else
			return false
		end
	end

	return self
end

return cameras