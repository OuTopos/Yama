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
	local state = "stand"

	local team = 1
	local targets = {}
	local cooldown = 0

	-- BUFFER BATCH
	local bufferBatch = buffer.newBatch(x, y, z)

	-- ANIMATION
	local animation = yama.animations.new()

	-- SPRITE
	local tileset = "tilesets/lpcfemaletest"
	images.quads.add(tileset, width, height)
	local sprite = buffer.newSprite(images.load(tileset), images.quads.data[tileset][131], x, y+radius, z, r, sx, sy, ox, oy)
	table.insert(bufferBatch.data, sprite)

	local tilesetOversized = "tilesets/lpcfemaletest"
	local spriteOversized = buffer.newSprite(images.load(tilesetOversized), images.quads.data[tilesetOversized][1], x-64, y+radius-64, z, r, sx, sy, ox, oy)
	
	--table.insert(bufferBatch.data, spriteOversized)
	
	-- Physics
	--local hitbox = physics.newObject(love.physics.newBody(yama.map.loaded.world, x, y, "dynamic"), love.physics.newRectangleShape(0, -8, 28, 48), self, true)
	local anchor = love.physics.newFixture(love.physics.newBody(yama.map.loaded.world, x, y-radius, "dynamic"), love.physics.newCircleShape(radius), mass)
	anchor:setUserData(self)
	anchor:setRestitution( 0 )
	anchor:getBody():setLinearDamping( 10 )
	anchor:getBody():setFixedRotation( true )
	anchor:setCategory(1)
	--love.physics.newBody(yama.map.loaded.world, x, y-radius, "dynamic"),
	local weapon = love.physics.newFixture(anchor:getBody(), love.physics.newPolygonShape(0, 0, 32, -32, 32, 32), 0)
	weapon:setUserData(self)
	weapon:setSensor(true)
	--weapon:getBody():setActive(false)
	weapon:setCategory(1, 2)

	--joint = love.physics.newDistanceJoint( anchor:getBody(), weapon:getBody(), -10, -10, 10, 10, false)

	local hitbox = love.physics.newFixture(anchor:getBody(), love.physics.newChainShape(false, 0, 0, 64, 0), 0)
	--hitbox:setUserData(self)
	hitbox:setSensor(true)

	-- PATROL
	local patrol = yama.patrols.new(true, 32)
	patrol.set("smooth")


	function self.update(dt)
		cooldown = cooldown - dt
		self.updateInput(dt)
		self.updatePosition()

		if move then
			a = "walk"
		else
			a = "stand"
		end
		if state == "walk" or state == "stand" then
			animation.update(dt, "humanoid_"..state.."_"..yama.g.getRelativeDirection(direction))
		else
			animation.update(dt, "humanoid_die")
		end
		sprite.quad = images.quads.data[tileset][animation.getFrame()]
	end

	function self.updateInput(dt)
		local nx, ny = 0, 0
		local fx, fy = 0, 0
		local vmultiplier = 1
		state = "stand"

		if state == "stand" or state == "walk" then

			if love.keyboard.isDown("lctrl") or love.joystick.isDown(1, 1) then
				state = "stand"
				wvx = 500 * math.cos(direction)
				wvy = 500 * math.sin(direction)
				if cooldown <= 0 then
					cooldown = 1
					self.attack()
				end
				--weapon:getBody():setPosition(x, y)
				--weapon:getBody():setLinearVelocity(wvx, wvy)

			elseif yama.g.getDistance(0, 0, love.joystick.getAxis(1, 1), love.joystick.getAxis(1, 2)) > 0.25 then
				state = "walk"
				nx = love.joystick.getAxis(1, 1)
				ny = love.joystick.getAxis(1, 2)
				direction = math.atan2(ny, nx)
				vmultiplier = yama.g.getDistance(0, 0, love.joystick.getAxis(1, 1), love.joystick.getAxis(1, 2))
				if vmultiplier >  1 then
					vmultiplier = 1
				end

			elseif love.keyboard.isDown("right") or love.keyboard.isDown("left") or love.keyboard.isDown("down") or love.keyboard.isDown("up") then
				state = "walk"
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
			elseif love.keyboard.isDown(" ") then
				patrol.update(anchor:getBody():getX(), anchor:getBody():getY())
				if patrol.isActive() then
					state = "walk"
					nx, ny = patrol.getPoint()
					direction = math.atan2(ny, nx)
				else
					state = "stand"
				end
			end
		end





		
		

		if state == "walk" then
			if love.keyboard.isDown("lshift") or love.joystick.isDown(1, 5) then
				vmultiplier = vmultiplier * 3
			end
			fx = velocity * vmultiplier * math.cos(direction)
			fy = velocity * vmultiplier * math.sin(direction)
			anchor:getBody():setAngle(direction)
			anchor:getBody():applyForce(fx, fy)
			animation.setTimescale(vmultiplier)
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
		--if b:isSensor() then
		if b:getUserData() then
			local entity = b:getUserData()

			if entity.getTeam then
				if entity.getTeam() ~= team then
					--table.insert(targets, entity)
					targets = {entity}
				end
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

	function self.endContact(a, b, contact)
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

	function self.getTeam()
		return team
	end

	function self.attack()
		for k, target in ipairs(targets) do
			target.hurt(0.3, x, y)
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