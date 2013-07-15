entities_bullet = {}

function entities_bullet.new(x, y, z, vp)
	local self = {}

	-- Common variables
	local width, height = 4, 4
	local ox, oy = width/2, height/2
	local sx, sy = 1, 1
	local r = 0
	self.cx, self.cy = x - ox + width / 2, y - oy + height / 2
	self.radius = yama.g.getDistance(self.cx, self.cy, x - ox, y - oy)
	self.type = "brick"
	
	local aim = 0
	local direction = 0
	local remove = false
	local speed = 0


	-- BUFFER BATCH
	local bufferBatch = yama.buffers.newBatch(x, y, z)

	--table.insert(bufferBatch.data, buffer.newDrawable(particle))


	-- SPRITE (PLAYER)	
	images.quads.add("bullet", 4, 4 )
	images.load( "bullet" ):setFilter( "linear", "linear" )
	local bullet = yama.buffers.newSprite( images.load( "bullet" ), images.quads.data[ "bullet" ] [ 1 ], x, y, z, r, sx, sy, ox, oy )
	

	table.insert( bufferBatch.data, bullet )
	
	-- Physics
	local anchor = love.physics.newFixture(love.physics.newBody( vp.map.data.world, x, y, "dynamic"), love.physics.newCircleShape( 2 ) )

	anchor:setUserData(self)
	anchor:setRestitution( 0.7 )
	anchor:getBody( ):setFixedRotation( false )
	anchor:getBody( ):setLinearDamping( 0.1 )
	anchor:getBody( ):setMass( 0.2 )
	anchor:getBody( ):setInertia( 0.1 )
	anchor:getBody( ):setGravityScale( 9 )

	function self.update(dt)
		self.updateInput(dt)
		self.updatePosition()
		self.updateAnimation(dt)

		self.triggersupdate()
		self.cx, self.cy = x - ox + width / 2, y - oy + height / 2
		self.radius = yama.g.getDistance(self.cx, self.cy, x - ox, y - oy)
		
		
		
	end

	function self.updateInput(dt)
		fx, fy = 0, 0
		
		if yama.g.getDistance(0, 0, love.joystick.getAxis(1, 5), love.joystick.getAxis(1, 4)) > 0.2 then
			local nx = love.joystick.getAxis(1, 5)
			local ny = love.joystick.getAxis(1, 4)
			aim = math.atan2(ny, nx)
			fx = 100 * math.cos(aim)
			fy = 100 * math.sin(aim)
			applyImpulse( fx, fy )

		end

	end
	
	function applyImpulse( fx, fy )
		anchor:getBody():applyLinearImpulse( fx, fy )
	end

	function self.updatePosition(xn, yn)
		--hitbox.body:setX(anchor.body:getX())
		--hitbox.body:setY(anchor.body:getY())
		
		x = anchor:getBody():getX()
		y = anchor:getBody():getY()
		r = anchor:getBody():getAngle()

		bufferBatch.x = self.getX()
		bufferBatch.y = self.getY()
		bufferBatch.z = 100
		bufferBatch.r = r
		
		bullet.x = x --math.floor(x + 0.5)
		bullet.y = y --math.floor(y-16 + 0.5)
		bullet.r = aim

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

	-- CONTACT --
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

	function self.draw( )
		-- Draw
		--sprites.draw( bodySprite )

		--love.graphics.draw( selector, math.floor(x/32+0.5)*32-19, math.floor( y/32+0.5 )*32-19 )
		--love.graphics.draw( grid_marker, math.floor(x/32+0.5)*32-16, math.floor( y/32+0.5 )*32-16 )
		love.graphics.setColorMode( "modulate" )
		--love.graphics.setBlendMode( "additive" )
		
		--love.graphics.draw( particle, 0, -16 )

		love.graphics.setColor( 255, 255, 255, 255 );
		--love.graphics.setColorMode( "modulate" )
		love.graphics.setBlendMode( "alpha" )
		--love.graphics.draw( images.load( "player" ), x, y, r, sx, sy, ox, oy )

		if hud.enabled then
			physics.draw( anchor, { 0, 255, 0, 102 } )
		end
	end

	function self.addToBuffer( )
		vp.buffer.add( bufferBatch )
	end

	function self.addToBuffer2( buffer )
		buffer.add( bufferBatch )
	end

	-- Basic functions
	function self.setPosition( x, y )
		anchor.body:setPosition( x, y )
		anchor.body:setLinearVelocity( 0, 0 )
	end
	
	function self.getPosition( )
		return x, y
	end

	function self.getXvel( )
		return xvel
	end
	function self.getYvel( )
		return yvel
	end

	-- Common functions
	function self.getX( )
		return math.floor( x + 0.5 )
	end
	function self.getY()
		return math.floor( y + 0.5 )
	end
	function self.getZ( )
		return z
	end
	function self.getOX( )
		return x - ox
	end
	function self.getOY( )
		return y - oy
	end
	function self.getWidth( )
		return width * sx
	end
	function self.getHeight( )
		return height * sy
	end
	function self.getDirection( )
		return direction
	end
	function self.destroy( )
		anchor:getBody():destroy( )
	end

	return self
end