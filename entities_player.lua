entities_player = {}

function entities_player.new(x, y, z)
	local self = {}

	-- Common variables
	local width, height = 64, 64
	local ox, oy = 32, 64
	local sx, sy = 1, 1
	local r = 0


	self.type = "player"


	local remove = false



	--local x, y, z = xn, yn, 32
	local xvel, yvel = 0, 0
	local speed = 0
	local friction = 0.99
	local direction = 0

	local width, height = 64, 64

	-- BUFFER BATCH
	local bufferBatch = buffer.newBatch(x, y, z)

	-- ANIMATION
	local animation = animations.new()

	-- PARTICLE EFFECT
	local particle = {}
	particle = love.graphics.newParticleSystem(images.load("player"), 1000)
	particle:setEmissionRate(100)
	particle:setSpeed(0, 25)
	particle:setGravity(0)
	particle:setSizes(1, 1)
	particle:setColors(200, 170, 50, 51, 255, 204, 0, 0)
	particle:setPosition(0, 0)
	particle:setLifetime(0.5)
	particle:setParticleLife(0.2)
	particle:setDirection(0)
	particle:setSpread(360)
	particle:setRadialAcceleration(0)
	particle:setTangentialAcceleration(0)
	particle:stop()

	--table.insert(bufferBatch.data, buffer.newDrawable(particle))


	-- SPRITE
	local tileset = "tilesets/lpcfemaletest"
	images.quads.add(tileset, 64, 64)
	local sprite = buffer.newQuad(images.load(tileset), images.quads.data[tileset][131], x, y, z, r, sx, sy, ox, oy)
	
	table.insert(bufferBatch.data, sprite)
	
	-- Physics
	--local hitbox = physics.newObject(love.physics.newBody(map.loaded.world, x, y, "dynamic"), love.physics.newRectangleShape(0, -8, 28, 48), self, true)
	local anchor = love.physics.newFixture(love.physics.newBody(map.loaded.world, x, y, "dynamic"), love.physics.newCircleShape(9), 5)
	anchor:setUserData(self)
	anchor:setRestitution( 0 )
	anchor:getBody():setLinearDamping( 10 )
	anchor:getBody():setFixedRotation( true )

	local hitbox = love.physics.newFixture(anchor:getBody(), love.physics.newRectangleShape(0, 0, 24, 48))
	hitbox:setUserData(self)
	hitbox:setSensor(true)


	function self.update(dt)
		self.updateInput()
		self.updatePosition()
		--self.updateAnimation(dt)
		animation.update(dt)
		sprite.quad = images.quads.data[tileset][animation.getFrame()]

		--particle:start()
		--particle:update(dt)
	end

	function self.updateInput()
		fx, fy = 0, 0

		if love.keyboard.isDown("up") then
			direction = 3.141592654
			fy = -5000
			animation.set("humanoid_walk_up")
			animation.setTimescale(2)
		end
		if love.keyboard.isDown("right") then
			direction = 1.570796327
			fx = 5000
			animation.set("humanoid_walk_right")
			animation.setTimescale(20)
		end
		if love.keyboard.isDown("down") then
			direction = 0
			fy = 5000
			animation.set("humanoid_walk_down")
			animation.setTimescale(0.5)
		end
		if love.keyboard.isDown("left") then
			direction = 4.71238898
			fx = -5000
			animation.set("humanoid_walk_left")
			animation.setTimescale(1)
		end

		anchor:getBody():applyForce( fx, fy )
	end

	function self.updatePosition()
		x = anchor:getBody():getX()
		y = anchor:getBody():getY()
		sprite.x = self.getX()
		sprite.y = self.getY()
		sprite.z = z
		bufferBatch.x = self.getX()
		bufferBatch.y = self.getY()
		bufferBatch.z = z

		--particle:setPosition(self.getX(), self.getY()-oy/2)
	end

	function self.updateAnimation(dt)
		if direction > -0.785398163 and direction < 0.785398163 then
			-- Up
			if speed > 0 then
				animation.set("humanoid_walk_up")
			else
				animation.set("humanoid_stand_up")
			end
		elseif direction > 0.785398163 and direction < 2.35619449 then
			-- Right
			if speed > 0 then
				animation.set("humanoid_walk_right")
			else
				animation.set("humanoid_stand_right")
			end
		elseif direction > 2.35619449 and direction < 3.926990817 then
			-- Down
			if speed > 0 then
				animation.set("humanoid_walk_down")
			else
				animation.set("humanoid_stand_down")
			end
		elseif direction > 3.926990817 and direction < 5.497787144 then
			-- Left
			if speed > 0 then
				animation.set("humanoid_walk_left")
			else
				animation.set("humanoid_stand_left")
			end
		end
	end

	-- CONTACT
	function self.beginContact(a, b, contact)
		--print("beginContact for player")
		if b:isSensor() then
			if b:getUserData() then
				local entity = b:getUserData()

				if entity.isTree then
					--print("adding entity to triggers")
					--local d, x1, y1, x2, y2 = love.physics.getDistance(b, anchor.fixture)
					d = getDistance(a:getBody():getX(), a:getBody():getY(), b:getBody():getX(), b:getBody():getY())
					--print(d)
					triggers.add(entity)
				end
			end
		end
	end

	function self.endContact(a, b, contact)
		--print("END")
		--print(contact:getSeparation( ))
		if b:isSensor() then
			if b:getUserData() then
				local entity = b:getUserData()

				if entity.isTree then
					triggers.remove(entity)
				end
			end
		end
	end

	function self.addToBuffer()
		buffer.add(bufferBatch)
	end

	-- Basic functions
	function self.setPosition(x, y)
		anchor.body:setPosition(x, y)
		anchor.body:setLinearVelocity(0, 0)
	end
	
	function self.getPosition()
		return x, y
	end

	function self.getXvel()
		return xvel
	end
	function self.getYvel()
		return yvel
	end

	-- Common functions
	function self.getX()
		return math.floor(x + 0.5)
	end
	function self.getY()
		return math.floor(y + 0.5)
	end
	function self.getZ()
		return z
	end
	function self.getOX()
		return x - ox
	end
	function self.getOY()
		return y - oy
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