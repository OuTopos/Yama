entities_coin = {}

function entities_coin.new(x, y)
	local self = {}

	-- Common variables
	local width, height = 32, 32
	local ox, oy = 16, 16
	local sx, sy = 1, 1
	local r = 0

	-- Sprite/Quad Variables
	local coin_image = love.graphics.newImage( "images/coin_"..tostring(math.random(1,3))..".png" )
	local coin_quads = {}

	for i=0, 7 do
		table.insert(coin_quads, love.graphics.newQuad(i*32, 0, 32, 32, 256, 32))
	end

	-- Animation Variables
	local animation = {}
	animation.quad = math.random(1,8)
	animation.dt = 0

	-- Anchor variables
	local anchor = physics.newObject(love.physics.newBody(physics.world, x, y, "dynamic"), love.physics.newCircleShape(8), self)
	anchor.body:setLinearDamping( 0.1 )
	anchor.fixture:setRestitution( 0.9 )

	-- Standard functions
	function self.update(dt)
		x, y = anchor.body:getX(), anchor.body:getY()
		self.animate(1, 8, 0.1, dt)
	end

	function self.draw()
		love.graphics.drawq(coin_image, coin_quads[animation.quad], x, y, r, sx, sy, ox, oy)
	end

	-- Animation functions
	function self.animate(first, last, delay, dt)
		if dt then
			animation.dt = animation.dt + dt

			if animation.dt > delay then
				animation.dt = animation.dt - delay
				animation.quad = animation.quad + 1
			end

			if animation.quad < first or animation.quad > last then
					animation.quad = first
			end
		else
			animation.dt = 0
			animation.quad = first
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

	return self
end