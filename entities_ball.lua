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
	local anchor = love.physics.newFixture(love.physics.newBody(physics.world, x, y, "dynamic"), love.physics.newCircleShape(10))
	anchor:getBody():setLinearDamping(0)
	anchor:setRestitution(1)

	-- Standard functions
	function self.update(dt)
		x, y = anchor:getBody():getX(), anchor:getBody():getY()
	end

	function self.draw()
		love.graphics.draw(sprite, x, y, r, sx, sy, ox, oy)
		
		if hud.enabled then
			physics.draw(anchor)
		end
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
	function self.destroy()
		anchor:getBody():destroy()
	end

	return self
end