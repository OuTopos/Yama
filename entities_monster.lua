entities_monster = {}

function entities_monster.new(map, x, y, z)
	local public = {}
	local private = {}

	private.world = map.getWorld()

	private.type = "player"

	private.userdata = {}
	private.userdata.name = "Unnamed"
	private.userdata.type = "monster"
	private.userdata.properties = {}
	private.userdata.entity = public

	-- ANCHOR/POSITION/SPRITE VARIABLES
	private.radius = 8
	private.mass = 1

	private.x, private.y, private.z = x, y, z
	private.r = 0
	private.width, private.height = 32, 38
	private.sx, private.sy = 1, 1
	private.ox, private.oy = private.width / 2, private.height
	private.aox, private.aoy = 0, private.radius
	private.sprite = nil

	private.scale = (private.sx + private.sy) / 2

	-- PHYSICS OBJECT
	private.anchor = love.physics.newFixture(love.physics.newBody(private.world, private.x, private.y, "dynamic"), love.physics.newCircleShape(private.radius * private.scale), private.mass)
	private.anchor:setRestitution(0.9)
	private.anchor:getBody():setLinearDamping(1)
	private.anchor:getBody():setFixedRotation(true)
	private.anchor:setUserData(private.userdata)

	-- Movement variables
	local mass = 1
	local velocity = 10 * private.scale
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
	local sprite = yama.buffers.newSprite(images.load(tileset), images.quads.data[tileset][1], private.x + private.aox, private.y + private.aoy, private.z, private.r, private.sx, private.sy, private.ox, private.oy)
	images.quads.add("lifebar", 32, 8)
	private.lifebar = yama.buffers.newSprite(images.load("lifebar"), images.quads.data["lifebar"][1], private.x + private.aox, private.y + private.aoy, private.z, private.r, private.sx, private.sy, private.ox, private.oy + 8)
	
	private.p = love.graphics.newParticleSystem(images.load("part1"), 1000)
	private.p:setEmissionRate(10)
	private.p:setSpeed(10, 10)
	private.p:setSizes(0.1, 1.5)
	private.p:setSizeVariation(0.5)
	private.p:setColors(127, 51, 0, 255, 255, 51, 0, 0)
	private.p:setPosition(400, 300)
	private.p:setLifetime(0.15)
	private.p:setParticleLife(1)
	private.p:setDirection(0)
	private.p:setSpread(1)
	--private.p:setTangentialAcceleration(0, 0)
	private.p:setRadialAcceleration(-2000)
	private.p:stop()

	private.spores = yama.buffers.newDrawable(private.p, 0, 0, 1)

	private.bufferbatch = yama.buffers.newBatch(private.x + private.aox, private.y + private.aoy, private.z)

	table.insert(private.bufferbatch.data, private.spores)
	table.insert(private.bufferbatch.data, sprite)
	table.insert(private.bufferbatch.data, private.lifebar)
	--table.insert(bufferBatch.data, sprite)


	-- Monster variables
	public.monster = true
	local hp = 10
	local hpmax = 10

	-- Destination
	local dx, dy = nil, nil


	-- Standard functions
	function public.update(dt)
		-- Patrol stuff
		patrol.update(private.x, private.y)

		if patrol.isActive() then
			dx, dy = patrol.getPoint()
			move = true
		else
			dx, dy = nil, nil
			move = false
		end

		if dx and dy then
			direction = math.atan2(dy-private.y, dx-private.x)
		end

		if move then
			fx = velocity * math.cos(direction)
			fy = velocity * math.sin(direction)
			private.anchor:getBody():applyForce( fx, fy )
		end

		-- Position updates
		private.x = private.anchor:getBody():getX()
		private.y = private.anchor:getBody():getY()
		yama.buffers.setBatchPosition(private.bufferbatch, private.x + private.aox, private.y + private.aoy)


		private.spores.ox = private.x
		private.spores.oy = private.y

		private.p:setPosition(private.x, private.y - 24)
		private.p:start()
		private.p:update(dt)
		--bufferBatch.x = public.getX()
		--bufferBatch.y = public.getY() + radius
		--bufferBatch.z = z

		-- Animation updates
		animation.update(dt, "eyeball_walk_"..yama.g.getRelativeDirection(direction))
		sprite.quad = images.quads.data[tileset][animation.frame]
		private.lifebar.quad = images.quads.data["lifebar"][24 - math.floor(hp / hpmax * 23 + 0.5)]
	end

	function public.addToBuffer(vp)
		vp.getBuffer().add(private.bufferbatch)
	end

	-- Monster functions

	function public.hurt(p)
		hp = hp - p
		if hp <= 0 then
			public.destroy()
		end
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



	-- CONTACT FUNCTIONS
	function public.beginContact(a, b, contact)
		aData = a:getUserData()
		bData = b:getUserData()

		if bData then
			print(bData.type)
			if bData.type == "damage" then
				public.hurt(bData.properties.physical)
			end
		end
	end


	-- GET
	function public.getType()
		return private.type
	end
	function public.getPosition()
		return private.x, private.y, private.z
	end
	function public.getBoundingBox()
		local x = private.x - (private.ox - private.aox) * private.sx
		local y = private.y - (private.oy - private.aoy) * private.sy
		local width = private.width * private.sx
		local height = private.height * private.sy

		return x, y, width, height
	end
	function public.getBoundingCircle()
		local x, y, width, height = public.getBoundingBox()
		local cx, cy = x + width / 2, y + height / 2
		local radius = yama.g.getDistance(x, y, cx, cy)

		return cx, cy, radius
	end
	function public.destroy()
		print("Destroying monster")
		private.anchor:getBody():destroy()
		public.destroyed = true
	end

	return public
end