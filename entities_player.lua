entities_player = {}

function entities_player.new(map, x, y, z)
	local public = {}
	local private = {}

	private.world = map.getWorld()

	private.type = "player"

	private.userdata = {}
	private.userdata.name = "Moe"
	private.userdata.type = "player"
	private.userdata.properties = {}
	private.userdata.entity = public

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

	-- PHYSICS OBJECT
	private.anchor = love.physics.newFixture(love.physics.newBody(private.world, private.x, private.y, "dynamic"), love.physics.newCircleShape(private.radius * private.scale), private.mass)
	private.anchor:setRestitution(0)
	private.anchor:getBody():setLinearDamping(10)
	private.anchor:getBody():setFixedRotation(true)
	private.anchor:setUserData(private.userdata)

	-- Movement variables
	private.velocity = 250 * private.scale
	private.direction = 0
	private.aim = 0
	private.move = false
	private.state = "stand"


	--function private.sprite.update()
		--yama.buffers.setBatchPosition(bufferBatch, public:getX() + private.oex, public:getY() + private.oey)
	--end



	local team = 1
	local targets = {}
	local cooldown = 0

	-- BUFFER BATCH
	local bufferBatch = yama.buffers.newBatch(private.x, private.y, private.z)

	-- ANIMATION
	local animation = yama.animations.new()

	-- SPRITE
	local tileset = "tilesets/lpcfemaletest"
	images.quads.add(tileset, private.width, private.height)
	local sprite = yama.buffers.newSprite(images.load(tileset), images.quads.data[tileset][131], private.x + private.aox, private.y + private.aoy, private.z, private.r, private.sx, private.sy, private.ox, private.oy)
	table.insert(bufferBatch.data, sprite)

	tilesetArrow = "directionarrow"
	--images.load(tilesetArrow):setFilter("linear", "linear")
	local spriteArrow = yama.buffers.newDrawable(images.load(tilesetArrow), private.x, private.y-16, 1000, 1, private.sx, private.sy, -24, 12)

	--local tilesetOversized = "tilesets/lpcfemaletest"
	--local spriteOversized = yama.buffers.newSprite(images.load(tilesetOversized), images.quads.data[tilesetOversized][1], x-64, y+radius-64, z, r, sx, sy, ox, oy)
	
	--table.insert(bufferBatch.data, spriteOversized)
	
	-- Physics
	--local hitbox = physics.newObject(love.physics.newBody(vp.map.data.world, x, y, "dynamic"), love.physics.newRectangleShape(0, -8, 28, 48), public, true)

	--anchor:setCategory(1)
	--love.physics.newBody(vp.map.data.world, x, y-radius, "dynamic"),
	private.weapon = love.physics.newFixture(love.physics.newBody(private.world, private.x, private.y, "dynamic"), love.physics.newPolygonShape(0, 0, 16, -16, 32, -16, 32, 16, 16, 16), 0)
	private.weapon:setUserData(public)
	private.weapon:setSensor(true)
	--private.weapon:getBody():setActive(false)
	--private.weapon:setCategory(1, 2)
	private.weapon:getBody():setActive(false)

	--joint = love.physics.newDistanceJoint( anchor:getBody(), private.weapon:getBody(), -10, -10, 10, 10, false)

	--local private.weapon2 = love.physics.newFixture(love.physics.newBody(private.world, x, y-radius, "dynamic"), love.physics.newChainShape(false, 0, 0, 64, 0), 0)

	--private.weapon2:getBody():setActive(false)
	--hitbox:setUserData(public)
	--private.weapon2:setSensor(true)

	-- PATROL
	--local patrol = yama.patrols.new(true, 32)
	--patrol.set("1")



	function public.updateInput(dt)
		local nx, ny = 0, 0
		local fx, fy = 0, 0
		local vmultiplier = 1
		private.state = "stand"

		if private.state == "stand" or private.state == "walk" then

			if love.keyboard.isDown("lctrl") or love.joystick.isDown(1, 1) then
				private.state = "sword"
				wvx = 500 * math.cos(private.direction)
				wvy = 500 * math.sin(private.direction)
				if cooldown <= 0 then
					cooldown = 0.1
					public.attack()
				end
				--private.weapon:getBody():setPosition(x, y)
				--private.weapon:getBody():setLinearVelocity(wvx, wvy)

			elseif yama.g.getDistance(0, 0, love.joystick.getAxis(1, 1), love.joystick.getAxis(1, 2)) > 0.2 then
				private.state = "walk"
				nx = love.joystick.getAxis(1, 1)
				ny = love.joystick.getAxis(1, 2)
				private.direction = math.atan2(ny, nx)
				private.aim = private.direction
				vmultiplier = yama.g.getDistance(0, 0, love.joystick.getAxis(1, 1), love.joystick.getAxis(1, 2))
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
				patrol.update(private.anchor:getBody():getX(), private.anchor:getBody():getY())
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
			if love.keyboard.isDown("lshift") or love.joystick.isDown(1, 5) then
				vmultiplier = vmultiplier * 3
			end
			fx = private.velocity * vmultiplier * math.cos(private.direction)
			fy = private.velocity * vmultiplier * math.sin(private.direction)
			private.anchor:getBody():setAngle(private.direction)
			private.anchor:getBody():applyForce(fx, fy)
			animation.timescale = vmultiplier
		end


		if yama.g.getDistance(0, 0, love.joystick.getAxis(1, 4), love.joystick.getAxis(1, 5)) > 0.2 then
			local nx = love.joystick.getAxis(1, 4)
			local ny = love.joystick.getAxis(1, 5)
			private.aim = math.atan2(ny, nx)
		end

	end

	function public.updatePosition()

		-- Position updates
		private.x = private.anchor:getBody():getX()
		private.y = private.anchor:getBody():getY()
		private.anchor:getBody():setAngle(private.direction)

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
		if b:getUserData() then
			local entity = b:getUserData()

			if entity.getTeam then
				if entity.getTeam() ~= team then
					--terget(targets, entity)
					-- should remove
				end
			end
		end
	end

	function public.getTeam()
		return team
	end

	function public.attack()
		private.weapon:getBody():setPosition(private.anchor:getBody():getX(), private.anchor:getBody():getY())
		private.weapon:getBody():setAngle(private.direction)
		private.weapon:getBody():setActive(true)

		for k, target in ipairs(targets) do
			target.hurt(0.3, x, y)
		end
	end

	-- Basic functions
	function public.setPosition(x, y)
		private.anchor.body:setPosition(x, y)
		private.anchor.body:setLinearVelocity(0, 0)
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
		print("["..private.userdata.name.. "] is teleporting to ["..mapname.."] and spawning at ["..spawn.."]")
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
	end

	function public.addToBuffer(vp)
		vp.getBuffer().add(bufferBatch)
		vp.getBuffer().add(spriteArrow)
	end

	function public.destroy()
		print("Destroying player")
		private.anchor:getBody():destroy()
		private.weapon:getBody():destroy()
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