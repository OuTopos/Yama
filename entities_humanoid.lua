entities_humanoid = {}

function entities_humanoid.new(x, y, z)
	local self = {}

	-- Sprite variables
	local width, height = 64, 64
	local ox, oy = width/2, height
	local sx, sy = 1, 1
	local r = 0

	-- Movement variables
	local radius = 10
	local mass = 1
	local velocity = 250
	local direction = math.atan2(math.random(-1, 1), math.random(-1, 1))
	local move = false

	-- BUFFER BATCH
	local bufferBatch = buffer.newBatch(x, y, z)

	-- ANIMATION
	local animation = animations.new()
	--animation.set("humanoid_stand_down")
	animation.setTimescale(math.random(9, 11)/10)

	-- PATROL
	local patrol = patrols.new(true, 16)
	patrol.set("fun")
	--patrol.setLoop(false)
	--patrol.setRadius(32)

	-- SPRITE
	local tileset = "tilesets/lpcfemaledark"
	images.quads.add(tileset, width, height)
	local sprite = buffer.newSprite(images.load(tileset), images.quads.data[tileset][1], x, y+radius, z, r, sx, sy, ox, oy)
	
	table.insert(bufferBatch.data, sprite)

	-- Anchor variables
	local anchor = love.physics.newFixture(love.physics.newBody(physics.world, x, y-radius, "dynamic"), love.physics.newCircleShape(radius))
	anchor:setUserData(self)
	anchor:setRestitution( 0 )
	anchor:getBody():setLinearDamping( 10 )
	anchor:getBody():setFixedRotation( true )

	-- Monster variables
	self.monster = true
	local hp = 0.75

	-- Destination
	local dx, dy = nil, nil


	-- Standard functions
	function self.update(dt)
		-- Patrol update
		patrol.update(x, y)

		-- Direction and move
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
		sprite.x = x
		sprite.y = y + radius
		--sprite.z = z
		bufferBatch.x = x
		bufferBatch.y = y + radius
		--bufferBatch.z = z

		-- Animation updates
		animation.update(dt, "humanoid_walk_"..getRelativeDirection(direction))
		sprite.quad = images.quads.data[tileset][animation.getFrame()]
	end

	function self.addToBuffer()
		buffer.add(bufferBatch)
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
	end

	return self
end