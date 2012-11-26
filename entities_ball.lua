entities_ball = {}

function entities_ball.new(x, y)
	local self = {}

	-- Common variables
	local width, height = 22, 22
	local ox, oy = 11, 11
	local sx, sy = 1, 1
	local r = 0

	-- Sprite Variables
	local sprite = love.graphics.newImage("images/ballGrey.png")

	-- Anchor variables
	local anchor = physics.newObject(love.physics.newBody(physics.world, x, y, "dynamic"), love.physics.newCircleShape(10), self)
	anchor.body:setLinearDamping(0)
	anchor.fixture:setRestitution(1)

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