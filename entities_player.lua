entities_player = {}

function entities_player.new(map, x, y, z)
	local public = {}
	local private = {}

	private.world = map.getWorld()

	private.name = "Jonas"
	private.type = "player"
	private.properties = {}

	-- ANCHOR/POSITION/SPRITE VARIABLES
	private.radius = 10
	private.mass = 1

	private.x, private.y, private.z = x, y, z
	private.r = 0
	private.width, private.height = 64, 64
	private.sx, private.sy = 1, 1
	private.ox, private.oy = 32, 64
	private.aox, private.aoy = 0, private.radius
	private.sprite = nil

	private.scale = (private.sx + private.sy) / 2

	-- PHYSICS OBJECTS
	private.fixtures = {}

	private.fixtures.anchor = love.physics.newFixture(love.physics.newBody(private.world, private.x, private.y, "dynamic"), love.physics.newCircleShape(private.radius * private.scale), private.mass)
	private.fixtures.anchor:setRestitution(0)
	private.fixtures.anchor:getBody():setLinearDamping(10)
	private.fixtures.anchor:getBody():setFixedRotation(true)
	private.fixtures.anchor:setUserData({type = "player", callback = public})


	public.test = {}

	function public.test.beginContact(a, b, contact)
		print("JADÅ!!!")
	end


	private.weapon = {}
	private.weapon.data = {}
	private.weapon.data.callback = public.test
	private.weapon.data.type = "damage"
	private.weapon.data.properties = {}
	private.weapon.data.properties.physical = 3

	private.fixtures.weapon = love.physics.newFixture(private.fixtures.anchor:getBody(), love.physics.newPolygonShape(0, 0, 16, -16, 32, -16, 32, 16, 16, 16), 0)
	private.fixtures.weapon:setUserData(private.weapon.data)
	private.fixtures.weapon:setSensor(true)
	private.fixtures.weapon:setMask(1)



	-- Movement variables
	private.velocity = 250 * private.scale
	private.direction = 0
	private.aim = 0
	private.move = false
	private.state = "stand"


	--function private.sprite.update()
		--yama.buffers.setBatchPosition(bufferBatch, public:getX() + private.oex, public:getY() + private.oey)
	--end


	public.joystick = 1

	local cooldown = 0

	-- BUFFER BATCH
	local bufferBatch = yama.buffers.newBatch(private.x, private.y, private.z)

	-- ANIMATION
	local animation = yama.animations.new()

	-- SPRITE
	local tileset = "LPC/body/male/light"
	images.quads.add(tileset, private.width, private.height)
	local sprite = yama.buffers.newSprite(images.load(tileset), images.quads.data[tileset][131], private.x + private.aox, private.y + private.aoy, private.z, private.r, private.sx, private.sy, private.ox, private.oy)


	tilesetArrow = "directionarrow"
	--images.load(tilesetArrow):setFilter("linear", "linear")
	local spriteArrow = yama.buffers.newDrawable(images.load(tilesetArrow), private.x, private.y-16, 640, 1, private.sx, private.sy, -24, 12)

	local fire = love.graphics.newImage("images/part2.png");

	private.p = love.graphics.newParticleSystem(fire, 1000)
	private.p:setEmissionRate(1000)
	private.p:setSpeed(300, 400)
	private.p:setSizes(2, 1)
	private.p:setColors(220, 105, 20, 255, 194, 30, 18, 0)
	private.p:setPosition(400, 300)
	private.p:setLifetime(0.1)
	private.p:setParticleLife(0.2)
	private.p:setDirection(0)
	private.p:setSpread(360)
	private.p:setTangentialAcceleration(1000)
	private.p:setRadialAcceleration(-2000)
	private.p:stop()

	private.spores = yama.buffers.newDrawable(private.p, 0, 0, 24)
	private.spores.blendmode = "additive"

	--table.insert(bufferBatch.data, private.spores)
	table.insert(bufferBatch.data, sprite)
	--table.insert(bufferBatch.data, private.fx)

	--local tilesetOversized = "tilesets/lpcfemaletest"
	--local spriteOversized = yama.buffers.newSprite(images.load(tilesetOversized), images.quads.data[tilesetOversized][1], x-64, y+radius-64, z, r, sx, sy, ox, oy)
	
	--table.insert(bufferBatch.data, spriteOversized)
	
	-- Physics
	--local hitbox = physics.newObject(love.physics.newBody(vp.map.data.world, x, y, "dynamic"), love.physics.newRectangleShape(0, -8, 28, 48), public, true)

	
	--private.fixtures.weapon:getBody():setActive(false)

	--joint = love.physics.newDistanceJoint( anchor:getBody(), private.fixtures.weapon:getBody(), -10, -10, 10, 10, false)

	--local private.fixtures.weapon2 = love.physics.newFixture(love.physics.newBody(private.world, x, y-radius, "dynamic"), love.physics.newChainShape(false, 0, 0, 64, 0), 0)

	--private.fixtures.weapon2:getBody():setActive(false)
	--hitbox:setUserData(public)
	--private.fixtures.weapon2:setSensor(true)

	-- PATROL
	--local patrol = yama.patrols.new(true, 32)
	--patrol.set("1")





	function public.updateInput(dt)
		local nx, ny = 0, 0
		local fx, fy = 0, 0
		local vmultiplier = 1
		animation.timescale = 1
		private.state = "stand"
		private.fixtures.weapon:setMask(1)

		if private.state == "stand" or private.state == "walk" then

			if love.keyboard.isDown("lctrl") or love.joystick.isDown(public.joystick, 1) then
				private.state = "sword"
				wvx = 500 * math.cos(private.direction)
				wvy = 500 * math.sin(private.direction)
				private.fixtures.weapon:setMask()
				vmultiplier = 1
				--private.fixtures.weapon:getBody():setPosition(x, y)
				--private.fixtures.weapon:getBody():setLinearVelocity(wvx, wvy)
			elseif yama.g.getDistance(0, 0, love.joystick.getAxis(public.joystick, 1), love.joystick.getAxis(public.joystick, 2)) > 0.2 then
				private.state = "walk"
				nx = love.joystick.getAxis(public.joystick, 1)
				ny = love.joystick.getAxis(public.joystick, 2)
				private.direction = math.atan2(ny, nx)
				private.aim = private.direction
				vmultiplier = yama.g.getDistance(0, 0, love.joystick.getAxis(public.joystick, 1), love.joystick.getAxis(public.joystick, 2))
				if vmultiplier >  1 then
					vmultiplier = 1
				end

			elseif love.keyboard.isDown("right") or love.keyboard.isDown("left") or love.keyboard.isDown("down") or love.keyboard.isDown("up") then
				private.state = "walk"
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
				private.direction = math.atan2(ny, nx)
				private.aim = private.direction
			elseif love.keyboard.isDown(" ") then
				patrol.update(private.fixtures.anchor:getBody():getX(), private.fixtures.anchor:getBody():getY())
				if patrol.isActive() then
					private.state = "walk"
					nx, ny = patrol.getPoint()
					private.direction = math.atan2(ny, nx)
					private.aim = private.direction
				else
					private.state = "stand"
				end
			end
		end

		

		if private.state == "walk" then
			if love.keyboard.isDown("lshift") or love.joystick.isDown(public.joystick, 5) then
				vmultiplier = vmultiplier * 3
			end
			fx = private.velocity * vmultiplier * math.cos(private.direction)
			fy = private.velocity * vmultiplier * math.sin(private.direction)
			private.fixtures.anchor:getBody():setAngle(private.direction)
			private.fixtures.anchor:getBody():applyForce(fx, fy)
			animation.timescale = vmultiplier
		end

		if private.state == "sword" then
			animation.timescale = 0.1
		end


		if yama.g.getDistance(0, 0, love.joystick.getAxis(public.joystick, 4), love.joystick.getAxis(public.joystick, 5)) > 0.2 then
			local nx = love.joystick.getAxis(public.joystick, 4)
			local ny = love.joystick.getAxis(public.joystick, 5)
			private.aim = math.atan2(ny, nx)
		end

	end

	function public.updatePosition()

		-- Position updates
		private.x = private.fixtures.anchor:getBody():getX()
		private.y = private.fixtures.anchor:getBody():getY()
		private.fixtures.anchor:getBody():setAngle(private.direction)

		yama.buffers.setBatchPosition(bufferBatch, private.x + private.aox, private.y + private.aoy)

		spriteArrow.x = private.x --math.floor(x + 0.5)
		spriteArrow.y = private.y-16 --math.floor(y-16 + 0.5)
		spriteArrow.r = private.aim


		--particle:setPosition(public.getX(), public.getY()-oy/2)
	end

	-- CONTACT
	function public.beginContact(a, b, contact)
		local userdata = b:getUserData()
		if userdata then
		--	print("Player Begin Contact: "..userdata.type)
			if userdata.type == "portal" then
				public.teleport(userdata.properties.map, userdata.properties.spawn)
			end
		end

				--if entity.isTree then
					--print("adding entity to triggers")
					--local d, x1, y1, x2, y2 = love.physics.getDistance(b, anchor.fixture)
					--d = getDistance(a:getBody():getX(), a:getBody():getY(), b:getBody():getX(), b:getBody():getY())
					--print(d)
					--triggers.add(entity)
				--end
		--end
	end

	function public.endContact(a, b, contact)
	end

	function public.attack()
	end

	-- Basic functions
	function public.setPosition(x, y)
		private.fixtures.anchor.body:setPosition(x, y)
		private.fixtures.anchor.body:setLinearVelocity(0, 0)
	end
	
	function public.getPosition()
		return x, y
	end

	function public.getXvel()
		return xvel
	end
	function public.getYvel()
		return yvel
	end
	--function public.getDirection()
	--	return private.direction
	--end




	function public.teleport(mapname, spawn)
		local newMap = yama.maps.load(mapname)
		local newEntity = newMap.spawn(private.type, spawn)
		if public.vp then
			public.vp.view(newMap, newEntity)
		end
		public.destroy()
	end

	-- DEFAULT FUNCTIONS
	function public.initialize(object)

	end

	function public.update(dt)
		cooldown = cooldown - dt
		public.updateInput(dt)
		public.updatePosition()

		if private.move then
			a = "walk"
		else
			a = "stand"
		end
		if private.state == "walk" or private.state == "stand" or private.state == "sword" then
			animation.update(dt, "humanoid_"..private.state.."_"..yama.g.getRelativeDirection(private.direction))
		else
			animation.update(dt, "humanoid_die")
		end
		sprite.quad = images.quads.data[tileset][animation.frame]

		private.spores.ox = private.x
		private.spores.oy = private.y

		private.p:setPosition(private.x, private.y - 64)
		private.p:start()
		private.p:update(dt)
	end

	function public.addToBuffer(vp)
		vp.getBuffer().add(bufferBatch)
		vp.getBuffer().add(spriteArrow)
		--vp.getBuffer().add(fx)
	end

	function public.destroy()
		print("Destroying player")
		private.fixtures.anchor:getBody():destroy()
		private.fixtures.weapon:getBody():destroy()
		public.destroyed = true
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
	
	return public
end