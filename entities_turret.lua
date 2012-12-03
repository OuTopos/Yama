entities_turret = {}

function entities_turret.new(x, y)
	local self = {}

	-- Common variables
	local width, height = 32, 64
	local ox, oy = 16, 48
	local sx, sy = 1, 1
	local r = 0

	-- Sprite variables
	local sprite = love.graphics.newImage("images/turret.png")

	-- Anchor variables
	local anchor = love.physics.newFixture(love.physics.newBody(physics.world, x, y, "static"), love.physics.newCircleShape(14))
	--anchor.fixture:setUserData(self)

	-- Sensor variables
	local sensor = love.physics.newFixture(love.physics.newBody(physics.world, x, y, "static"), love.physics.newCircleShape(200))
	sensor:setUserData(self)
	sensor:setSensor(true)

	-- Target variables
	local target = {}
	target.active = false
	target.entity = nil
	target.x = 0
	target.y = 0
	target.shoot = false
	target.dt = 0
	target.delay = 1



	-- Standard functions
	function self.update(dt)
		x, y = anchor:getBody():getX(), anchor:getBody():getY()

		target.dt = target.dt + dt

		if target.dt >= target.delay  and target.entity then
			target.dt = target.dt - target.delay
			--target.entity.hurt(0.1)
			local direction = math.atan2(target.entity.getY()-y, target.entity.getX()-x)
			local projectile = entities.new("projectile", x, y)
			print(direction)
			projectile.shoot(direction, 2000)
		end

		if target.dt > target.delay then
			target.dt = target.delay
		end
	end

	function self.draw()
		love.graphics.draw(sprite, x, y, r, sx, sy, ox, oy)
		if target.entity then
			love.graphics.setColor(255, 0, 0, 255)
			love.graphics.line(x, y, target.entity.getX(), target.entity.getY())
			love.graphics.setColor(255, 255, 255, 255)
		end
		
		if hud.enabled then
			physics.draw(sensor, {0, 255, 255, 51})
			physics.draw(anchor)
		end
	end

	-- Contact functions
	function self.beginContact(a, b, contact)
		print("beginContact for player")
		--if b:isSensor() then
			if b:getUserData() then
				local entity = b:getUserData()
				if entity.monster then
					--target.active = true
					target.entity = b:getUserData()
					--target.x = b:getBody():getX()
					--target.y = b:getBody():getY()
				
					--target.shoot = true
				end
			end
		--end
	end
	function self.endContact(a, b, contact)
		print("beginContact for player")
		--if b:isSensor() then
			if b:getUserData() then
				local entity = b:getUserData()
				if entity == target.entity then
					target.entity = nil
				end
			end
		--end
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