entities_monster = {}

function entities_monster.new(map, x, y, z)
	local public = {}
	local private = {}

	private.name = "Unnamed"
	private.type = "sprite"
	private.properties = {}

	local private = {}
	private.world = map.getWorld()

	-- Common variables
	local width, height = 32, 38
	local ox, oy = width/2, height
	local sx, sy = 1, 1
	local r = 0
	public.cx, public.cy = x - ox + width / 2, y - oy + height / 2
	public.radius = yama.g.getDistance(public.cx, public.cy, x - ox, y - oy)

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
	patrol.set("1", map)
	--patrol.setLoop(false)
	--patrol.setRadius(32)

	-- SPRITE
	local tileset = "eyeball"
	images.quads.add(tileset, 32, 38)
	local sprite = yama.buffers.newSprite(images.load(tileset), images.quads.data[tileset][1], x, y+radius, z, r, sx, sy, ox, oy)
	
	table.insert(bufferBatch.data, sprite)

	-- Anchor variables
	local anchor = love.physics.newFixture(love.physics.newBody(private.world, x, y, "dynamic"), love.physics.newCircleShape(radius), mass)
	anchor:setUserData(public)
	anchor:setRestitution( 0.9 )
	anchor:getBody():setLinearDamping( 1 )

	-- Monster variables
	public.monster = true
	local hp = 0.75

	-- Destination
	local dx, dy = nil, nil


	-- Standard functions
	function public.update(dt)
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
		sprite.x = public.getX()
		sprite.y = public.getY() + radius
		--sprite.z = z
		bufferBatch.x = public.getX()
		bufferBatch.y = public.getY() + radius
		--bufferBatch.z = z

		-- Animation updates
		animation.update(dt, "eyeball_walk_"..yama.g.getRelativeDirection(direction))
		sprite.quad = images.quads.data[tileset][animation.frame]
		
		public.cx, public.cy = x - ox + width / 2, y - oy + height / 2
		public.radius = yama.g.getDistance(public.cx, public.cy, x - ox, y - oy)
	end

	function public.addToBuffer(vp)
		vp.getBuffer().add(bufferBatch)
	end

	-- Monster functions

	function public.hurt(p)

	end

	function public.setName(name)
		private.name = name
	end
	function public.setProperties(properties)
		private.properties = properties
	end
	function public.getName()
		return private.name
	end
	function public.getType()
		return private.type
	end
	function public.getProperties()
		return private.name
	end

	-- Common functions
	function public.getX()
		return x
	end
	function public.getY()
		return y
	end
	function public.getZ()
		return z
	end
	function public.getOX()
		return x - ox * sx
	end
	function public.getOY()
		return y - oy * sy + radius
	end
	function public.getWidth()
		return width * sx
	end
	function public.getHeight()
		return height * sy
	end
	function public.getCX()
		return x - ox + width / 2
	end
	function public.getCY()
		return y - oy + height / 2
	end
	function public.getRadius()
		return yama.g.getDistance(public.getCX(), public.getCY(), x - ox * sx, y - oy * sy)
	end
	function public.destroy()
		print("Destroying monster")
		anchor:getBody():destroy()
		public.destroyed = true
	end

	return public
end