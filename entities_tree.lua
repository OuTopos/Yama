entities_tree = {}

function entities_tree.new(x, y)
	local self = {}

	-- Common variables
	local width, height = 128, 192
	local ox, oy = 64, 160
	local sx, sy = 1, 1
	local r = 0

	-- Sprite variables
	local sprite = love.graphics.newImage( "images/tree"..tostring(math.random(1,2))..".png" )
	local color = {255, 255, 255, 255}

	-- Anchor variables
	local anchor = physics.newObject(love.physics.newBody(physics.world, x, y, "fixed"), love.physics.newCircleShape(32), self, false)
	anchor.fixture:setUserData(self)

	-- Standard functions
	function self.update(dt)
		x, y = anchor.body:getX(), anchor.body:getY()
	end

	function self.draw()
		love.graphics.draw(sprite, x, y, r, sx, sy, ox, oy)
	end

	-- Common functions
	function self.getX()
		return x
	end
	function self.getY()
		return y
	end
	function self.getOX()
		return x - ox * sx
	end
	function self.getOY()
		return y - oy * sy
	end
	function self.getWidth()
		return width * sx
	end
	function self.getHeight()
		return height * sy
	end

	return self
end