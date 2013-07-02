entities_platform = {}


function entities_platform.new(x, y, z)
	local self = {}

	-- Common variables
	local width, height = 128, 32
	local ox, oy = width/2, height/2
	local sx, sy = 1, 1
	local r = 0


	self.type = "player"


	local remove = false


	--local x, y, z = xn, yn, 32
	local xvel, yvel = 0, 0
	local speed = 0
	local friction = 0.99
	local direction = 0

	-- BUFFER BATCH
	local bufferBatch = buffer.newBatch(x, y, z)

	--table.insert(bufferBatch.data, buffer.newDrawable(particle))


	-- SPRITE (PLAYER)
	images.quads.add("crate", 128, 32)
	images.load("crate"):setFilter("linear", "linear")
	local sprite = buffer.newSprite(images.load("crate"), images.quads.data["crate"][1], x, y, z, r, sx, sy, ox, oy)
	
	table.insert(bufferBatch.data, sprite)
	
	-- Physics
	--local hitbox = physics.newObject(love.physics.newBody(map.loaded.world, x, y, "dynamic"), love.physics.newRectangleShape(0, -8, 28, 48), self, true)
	local anchor = love.physics.newFixture(love.physics.newBody(yama.map.loaded.world, x, y, "dynamic"), love.physics.newRectangleShape(-1, 0, width-2, height) )


	anchor:setUserData(self)
	--anchor:setRestitution( 0 )
	--anchor:getBody():setLinearDamping( 1 )
	anchor:getBody():setFixedRotation( true )
	anchor:getBody():setLinearDamping( 0 )
	anchor:getBody():setMass( 0 )
	anchor:getBody():setInertia( 0 )
	anchor:getBody():setGravityScale( 0 )

	--local hitbox = love.physics.newFixture(anchor:getBody(), love.physics.newRectangleShape(0, 0, 24, 48))
	--hitbox:setUserData(self)
	--hitbox:setSensor(true)


	function self.update(dt)
		self.updateInput(dt)
		self.updatePosition()
		self.updateAnimation(dt)

		--particle:start()
		--particle:update(dt)

		self.triggersupdate()
		
	end

	local allowjump = true
	local jumping = false

	function self.updateInput(dt)
		fx, fy = 0, 0

	end

	function self.updatePosition(xn, yn)
		--hitbox.body:setX(anchor.body:getX())
		--hitbox.body:setY(anchor.body:getY())
		
		x = anchor:getBody():getX()
		y = anchor:getBody():getY()
		r = anchor:getBody():getAngle()
		sprite.x = self.getX()
		sprite.y = self.getY()
		sprite.z = 100
		sprite.r = r
		bufferBatch.x = self.getX()
		bufferBatch.y = self.getY()
		bufferBatch.z = 100
		bufferBatch.r = r

		--particle:setPosition(self.getX(), self.getY()-oy/2)
	end

	local animation = {}
	animation.quad = 1
	animation.dt = 0

	function self.updateAnimation(dt)
		if direction > -0.785398163 and direction < 0.785398163 then
			-- Up
			if speed > 0 then
				self.animate(20, 27, 0.08, dt)
			else
				self.animate(19)
			end
		elseif direction > 0.785398163 and direction < 2.35619449 then
			-- Right
			if speed > 0 then
				self.animate(29, 36, 0.08, dt)
			else
				self.animate(28)
			end
		elseif direction > 2.35619449 and direction < 3.926990817 then
			-- Down
			if speed > 0 then
				self.animate(2, 9, 0.08, dt)
			else
				self.animate(1)
			end
		elseif direction > 3.926990817 and direction < 5.497787144 then
			-- Left
			if speed > 0 then
				self.animate(11, 18, 0.08, dt)
			else
				self.animate(10)
			end
		end
	end

	function self.animate(first, last, delay, dt)
		if dt then
			animation.dt = animation.dt + dt

			if animation.dt > delay then
				animation.dt = animation.dt - delay
				animation.quad = animation.quad + 1
			end

			if animation.quad < first or animation.quad > last then
					animation.quad = first
			end
		else
			animation.dt = 0
			animation.quad = first
		end
	end

	-- TRIGGERS
	local triggers = {}
	triggers.data = {}
	function triggers.add(entity)
		table.insert(triggers.data, entity)
		print("Trigger now added, legnth is: "..#triggers.data)
	end

	function triggers.remove(entity)
		for i=1, #triggers.data do
			if triggers.data[i] == entity then
				print("removing "..#triggers.data)
				triggers.data[i].active = false
				table.remove(triggers.data, i)
				print("gone! "..#triggers.data)
			end
		end
	end

	function self.triggersupdate()
		--print("updating")
		table.sort(triggers.data, triggers.sort)

		if triggers.data[1] then
			triggers.data[1].active = true
			for i=2, #triggers.data do
				triggers.data[i].active = false
			end
		end
	end

	function triggers.sort(a, b)
		--print("a = "..getDistance(a:getX(), a:getY(), x, y))
		if getDistance(a:getX(), a:getY(), x, y) < getDistance(b:getX(), b:getY(), x, y) then
			return true
		end

		return false
	end

	-- CONTACT
	function self.beginContact(a, b, contact)
		pContact = contact
		if b:getUserData() then
			if b:getUserData().type == 'floor' then

			end
		end
	end

	function self.endContact(a, b, contact)
		if b:getUserData() then
			if b:getUserData().type == 'floor' then

			end
		end

	end

	function self.draw()
		-- Draw
		--sprites.draw(bodySprite)

		--love.graphics.draw(selector, math.floor(x/32+0.5)*32-19, math.floor(y/32+0.5)*32-19)
		--love.graphics.draw(grid_marker, math.floor(x/32+0.5)*32-16, math.floor(y/32+0.5)*32-16)
		love.graphics.setColorMode("modulate")
		--love.graphics.setBlendMode("additive")
		
		--love.graphics.draw(particle, 0, -16)

		love.graphics.setColor(255, 255, 255, 255);
		--love.graphics.setColorMode("modulate")
		love.graphics.setBlendMode("alpha")
		--love.graphics.draw(images.load("player"), x, y, r, sx, sy, ox, oy)

		if hud.enabled then
			physics.draw(anchor, {0, 255, 0, 102})
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
	function self.getDirection()
		return direction
	end
	function self.destroy()
		anchor:getBody():destroy()
	end

	return self
end