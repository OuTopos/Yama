entities_monster = {}

function entities_monster.new(map, x, y, z)
	local self = {}
	self.boundingbox = {}

	self.world = map.getWorld()

	self.type = "player"

	self.userdata = {}
	self.userdata.name = "Unnamed"
	self.userdata.type = "monster"
	self.userdata.properties = {}
	self.userdata.callback = self

	-- ANCHOR/POSITION/SPRITE VARIABLES
	self.radius = 8
	self.mass = 1

	self.x, self.y, self.z = x, y, z
	self.r = 0
	self.width, self.height = 32, 38
	self.sx, self.sy = 1, 1
	self.ox, self.oy = self.width / 2, self.height
	self.aox, self.aoy = 0, self.radius
	self.sprite = nil

	self.scale = (self.sx + self.sy) / 2

	-- PHYSICS OBJECT
	self.anchor = love.physics.newFixture(love.physics.newBody(self.world, self.x, self.y, "dynamic"), love.physics.newCircleShape(self.radius * self.scale), self.mass)
	self.anchor:setRestitution(0.9)
	self.anchor:getBody():setLinearDamping(1)
	self.anchor:getBody():setFixedRotation(true)
	self.anchor:setUserData(self.userdata)

	-- Movement variables
	local mass = 1
	local velocity = 10 * self.scale
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
	yama.assets.tileset("eyeball", "eyeball", 32, 38)
	local sprite = yama.buffers.newSprite(yama.assets.tilesets["eyeball"].image, yama.assets.tilesets["eyeball"].tiles[1], self.x + self.aox, self.y + self.aoy, self.z, self.r, self.sx, self.sy, self.ox, self.oy)
	yama.assets.tileset("lifebar", "lifebar", 32, 8)
	self.lifebar = yama.buffers.newSprite(yama.assets.tilesets["lifebar"].image, yama.assets.tilesets["lifebar"].tiles[1], self.x + self.aox, self.y + self.aoy, self.z, self.r, self.sx, self.sy, self.ox, self.oy + 8)
	
	self.p = love.graphics.newParticleSystem(yama.assets.image("part1"), 1000)
	self.p:setEmissionRate(10)
	self.p:setSpeed(10, 10)
	self.p:setSizes(1, 1.5)
	self.p:setSizeVariation(0.5)
	self.p:setColors(127, 51, 0, 255, 255, 51, 0, 0)
	self.p:setPosition(400, 300)
	self.p:setLifetime(0.15)
	self.p:setParticleLife(1)
	self.p:setDirection(0)
	self.p:setSpread(1)
	--self.p:setTangentialAcceleration(0, 0)
	self.p:setRadialAcceleration(-2000)
	self.p:stop()

	self.spores = yama.buffers.newDrawable(self.p, 0, 0, 1)
	self.spores.blendmode = "additive"

	self.bufferbatch = yama.buffers.newBatch(self.x + self.aox, self.y + self.aoy, self.z)

	table.insert(self.bufferbatch.data, self.spores)
	table.insert(self.bufferbatch.data, sprite)
	table.insert(self.bufferbatch.data, self.lifebar)
	--table.insert(bufferBatch.data, sprite)


	-- Monster variables
	self.monster = true
	local hp = 10
	local hpmax = 10

	-- Destination
	local dx, dy = nil, nil


	-- Standard functions
	function self.update(dt)
		-- Patrol stuff
		patrol.update(self.x, self.y)

		if patrol.isActive() then
			dx, dy = patrol.getPoint()
			move = true
		else
			dx, dy = nil, nil
			move = false
		end

		if dx and dy then
			direction = math.atan2(dy-self.y, dx-self.x)
		end

		if move then
			fx = velocity * math.cos(direction)
			fy = velocity * math.sin(direction)
			self.anchor:getBody():applyForce( fx, fy )
		end

		-- Position updates
		self.x = self.anchor:getBody():getX()
		self.y = self.anchor:getBody():getY()
		yama.buffers.setBatchPosition(self.bufferbatch, self.x + self.aox, self.y + self.aoy)


		self.spores.ox = self.x
		self.spores.oy = self.y

		self.p:setPosition(self.x, self.y - 24)
		self.p:start()
		self.p:update(dt)
		--bufferBatch.x = self.getX()
		--bufferBatch.y = self.getY() + radius
		--bufferBatch.z = z

		-- Animation updates
		animation.update(dt, "eyeball_walk_"..yama.g.getRelativeDirection(direction))
		sprite.quad = yama.assets.tilesets["eyeball"].tiles[animation.frame]
		self.lifebar.quad = yama.assets.tilesets["lifebar"].tiles[24 - math.floor(hp / hpmax * 23 + 0.5)]

		self.setBoundingBox()
	end
	
function self.addToBuffer(vp)
		vp.addToBuffer(self.bufferbatch)
	end

	-- Monster functions

	function self.hurt(p)
		hp = hp - p
		if hp <= 0 then
			self.destroy()
		end
	end

	function self.setName(name)
		self.name = name
	end
	function self.setProperties(properties)
		self.properties = properties
	end
	function self.getName()
		return self.name
	end
	function self.getType()
		return self.type
	end
	function self.getProperties()
		return self.name
	end



	-- CONTACT FUNCTIONS
	function self.beginContact(a, b, contact)
		aData = a:getUserData()
		bData = b:getUserData()

		if bData then
			print(bData.type)
			if bData.type == "damage" then
				self.hurt(bData.properties.physical)
				local direction = math.atan2(self.anchor:getBody():getY() - b:getBody():getY(), self.anchor:getBody():getX() - b:getBody():getX())
				local x = 100 * math.cos(direction)
				local y = 100 * math.sin(direction)
				self.anchor:getBody():setLinearVelocity( x, y )
			end
		end
	end


	-- GET
	function self.setBoundingBox()
		self.boundingbox.x = self.x - (self.ox - self.aox) * self.sx
		self.boundingbox.y = self.y - (self.oy - self.aoy) * self.sy
		self.boundingbox.width = self.width * self.sx
		self.boundingbox.height = self.height * self.sy
	end
	function self.destroy()
		print("Destroying monster")
		self.anchor:getBody():destroy()
		self.destroyed = true
	end

	return self
end