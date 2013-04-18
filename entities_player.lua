entities_player = {}

function entities_player.new(x, y, z)
	local self = {}

	-- Sprite variables
	local width, height = 64, 64
	local ox, oy = width/2, height
	local sx, sy = 1, 1
	local r = 0

	-- Movement variables
	local scale = (sx + sy) / 2
	local radius = 10 * scale
	local mass = 1
	local velocity = 250 * scale
	local direction = 0
	local move = false

	-- BUFFER BATCH
	local bufferBatch = buffer.newBatch(x, y, z)

	-- ANIMATION
	local animation = yama.animations.new()

	-- SPRITE
	local tileset = "tilesets/lpcfemaletest"
	images.quads.add(tileset, width, height)
	local sprite = buffer.newSprite(images.load(tileset), images.quads.data[tileset][131], x, y+radius, z, r, sx, sy, ox, oy)
	
	table.insert(bufferBatch.data, sprite)
	
	-- Physics
	--local hitbox = physics.newObject(love.physics.newBody(yama.map.loaded.world, x, y, "dynamic"), love.physics.newRectangleShape(0, -8, 28, 48), self, true)
	local anchor = love.physics.newFixture(love.physics.newBody(yama.map.loaded.world, x, y, "dynamic"), love.physics.newCircleShape(radius), mass)
	anchor:setUserData(self)
	anchor:setRestitution( 0 )
	anchor:getBody():setLinearDamping( 10 )
	anchor:getBody():setFixedRotation( true )

	--local hitbox = love.physics.newFixture(anchor:getBody(), love.physics.newRectangleShape(0, 0, 24, 48))
	--hitbox:setUserData(self)
	--hitbox:setSensor(true)

	-- PATROL
	local patrol = yama.patrols.new()
	patrol.set("test1")


	function self.update(dt)
		self.updateInput(dt)
		self.updatePosition()

		if move then
			a = "walk"
		else
			a = "stand"
		end
		animation.update(dt, "humanoid_"..a.."_"..yama.g.getRelativeDirection(direction))
		sprite.quad = images.quads.data[tileset][animation.getFrame()]
	end

	function self.updateInput(dt)
		local nx, ny = 0, 0
		local fx, fy = 0, 0
		move = false

		if love.keyboard.isDown("right") or love.keyboard.isDown("left") or love.keyboard.isDown("down") or love.keyboard.isDown("up") then
			if love.keyboard.isDown("right") then
				nx = nx+1
			end
			if love.keyboard.isDown("left") then
				nx = nx-1
			end
			if love.keyboard.isDown("up") then
				ny = ny-1
			end
			if love.keyboard.isDown("down") then
				ny = ny+1
			end
			direction = math.atan2(ny, nx)
			move = true
		end

		if love.keyboard.isDown(" ") then
			patrol.update(x, y)
			if patrol.isActive() then
				local px, py = patrol.getPoint()
				direction = math.atan2(py-y, px-x)
				move = true
			else
				move = false
			end
		end



		
		if move and love.keyboard.isDown("lshift") then
			fx = velocity * 3 * math.cos(direction)
			fy = velocity * 3 * math.sin(direction)
			anchor:getBody():applyForce( fx, fy )
			animation.setTimescale(3)
		elseif move then
			fx = velocity * math.cos(direction)
			fy = velocity * math.sin(direction)
			anchor:getBody():applyForce( fx, fy )
			animation.setTimescale(1)
		end
	end

	function self.updatePosition()
		x = anchor:getBody():getX()
		y = anchor:getBody():getY()
		--r = anchor:getBody():getAngle()
		sprite.x = self.getX()
		sprite.y = self.getY() + radius
		sprite.r = r
		sprite.z = z
		bufferBatch.x = self.getX()
		bufferBatch.y = self.getY() + radius
		bufferBatch.z = z
		bufferBatch.r = r

		--particle:setPosition(self.getX(), self.getY()-oy/2)
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
		return x - ox * sx
	end
	function self.getOY()
		return y - oy * sy + radius
	end
	function self.getWidth()
		return width * sx
	end
	function self.getHeight()
		return height * sy
	end
	function self.getDirection()
		return direction
	end
	function self.destroy()
		anchor:getBody():destroy()
	end

	return self
end