entities_monster = {}

function entities_monster.new(x, y, z, viewport)
	local self = {}

	-- Common variables
	local width, height = 32, 38
	local ox, oy = width/2, height
	local sx, sy = 1, 1
	local r = 0
	self.cx, self.cy = x - ox + width / 2, y - oy + height / 2
	self.radius = yama.g.getDistance(self.cx, self.cy, x - ox, y - oy)

	-- Movement variables
	local scale = (sx + sy) / 2
	local radius = 8 * scale
	local mass = 1
	local velocity = 10 * scale
	local direction = math.atan2(math.random(-1, 1), math.random(-1, 1))
	local move = false

	-- BUFFER BATCH
	local bufferBatch = yama.buffers.newBatch(x, y, z)

	-- ANIMATION
	local animation = yama.animations.new()
	animation.set("eyeball_walk_down")
	animation.timescale = math.random(9, 11)/10

	-- PATROL
	local patrol = yama.patrols.new()
	patrol.set("1", viewport.getMap())
	--patrol.setLoop(false)
	--patrol.setRadius(32)

	-- SPRITE
	local tileset = "eyeball"
	images.quads.add(tileset, 32, 38)
	local sprite = yama.buffers.newSprite(images.load(tileset), images.quads.data[tileset][1], x, y+radius, z, r, sx, sy, ox, oy)
	
	table.insert(bufferBatch.data, sprite)

	-- Anchor variables
	local anchor = love.physics.newFixture(love.physics.newBody(viewport.getMap().data.world, x, y, "dynamic"), love.physics.newCircleShape(radius), mass)
	anchor:setUserData(self)
	anchor:setRestitution( 0.9 )
	anchor:getBody():setLinearDamping( 1 )

	-- Monster variables
	self.monster = true
	local hp = 0.75

	-- Destination
	local dx, dy = nil, nil


	-- Standard functions
	function self.update(dt)
		-- Patrol stuff
		patrol.update(x, y)

		if patrol.isActive() then
			dx, dy = patrol.getPoint()
			move = true
		else
			dx, dy = nil, nil
			move = false
		end

		if dx and dy then
			direction = math.atan2(dy-y, dx-x)
		end

		if move then
			fx = velocity * math.cos(direction)
			fy = velocity * math.sin(direction)
			anchor:getBody():applyForce( fx, fy )
		end

		-- Position updates
		x = anchor:getBody():getX()
		y = anchor:getBody():getY()
		sprite.x = self.getX()
		sprite.y = self.getY() + radius
		--sprite.z = z
		bufferBatch.x = self.getX()
		bufferBatch.y = self.getY() + radius
		--bufferBatch.z = z

		-- Animation updates
		animation.update(dt, "eyeball_walk_"..yama.g.getRelativeDirection(direction))
		sprite.quad = images.quads.data[tileset][animation.frame]
		
		self.cx, self.cy = x - ox + width / 2, y - oy + height / 2
		self.radius = yama.g.getDistance(self.cx, self.cy, x - ox, y - oy)
	end

	function self.addToBuffer(viewport)
		viewport.buffer.add(bufferBatch)
	end

	-- Monster functions

	function self.hurt(p)

	end

	-- Common functions
	function self.getX()
		return x
	end
	function self.getY()
		return y
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
	function self.destroy()
		anchor:getBody():destroy()
		self.destroyed = true
	end

	return self
end