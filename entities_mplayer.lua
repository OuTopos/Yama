entities_mplayer = {}


function entities_mplayer.new(x, y, z, vp)
	local self = {}

	local camera = vp.getCamera()
	local buffer = vp.getBuffer()
	local map = vp.getMap()
	local swarm = vp.getSwarm()
	local world = swarm.getWorld()

	-- Common variables
	local width, height = 32, 32
	local ox, oy = width/2, height/2
	local sx, sy = 1, 1
	local r = 0
	self.cx, self.cy = x - ox + width / 2, y - oy + height / 2
	self.radius = yama.g.getDistance(self.cx, self.cy, x - ox, y - oy)
	self.type = "player"
	
	local aim = 0

	local remove = false

	--local x, y, z = xn, yn, 32
	local xvel, yvel = 0, 0
	local speed = 0
	local direction = 0
	local onGround = false
	local pContact = nil
	local jumpTimer = 0
	local jumpMaxTimer = 0.35
	local jumpForce = 900
	local jumpIncreaser = 1900
	local xForce = 4500
	local xJumpForce = 1900
	local maxSpeed = 600
	local friction = 0.2
	local stopFriction = 0.7
	local jumpFriction = 0.1
	local spawntimer = 0
	local bullet = nil
	local bullets = {}
	local bulletImpulse = 1400
	local nAllowedBullets = 60

	-- BUFFER BATCH
	local bufferBatch = yama.buffers.newBatch(x, y, z)
	
	-- SPRITE (PLAYER)
	images.quads.add( "jumper", 32, 32 )
	images.load( "jumper" ):setFilter( "linear", "linear" )
	local sprite = yama.buffers.newSprite( images.load( "jumper" ), images.quads.data[ "jumper" ] [ 1 ], x, y, z, r, sx, sy, ox, oy )
	
	tilesetArrow = "directionarrowshootah"
	local spriteArrow = yama.buffers.newDrawable( images.load( tilesetArrow ), x, y-8, 1000, 1, sx, sy, -12, 12)

	table.insert( bufferBatch.data, sprite )
	table.insert( bufferBatch.data, spriteArrow )
	
	-- Physics
	local anchor = love.physics.newFixture(love.physics.newBody( world, x, y, "dynamic"), love.physics.newRectangleShape(0, 0, width-1, height) )
	anchor:setGroupIndex( -1 )
	local anchor2 = love.physics.newFixture(anchor:getBody(), love.physics.newRectangleShape(0, 0, width, height-1) )
	anchor2:setGroupIndex( -1 )
	
	--local leg1 = love.physics.newFixture(love.physics.newBody( world, x, y+32, "dynamic"), love.physics.newRectangleShape(0, 0, width, height), 1 )
	--leg1:setGroupIndex( -1 )
	--leg1:getBody( ):setFixedRotation( true )
	--joint = love.physics.newPrismaticJoint( leg1:getBody(), anchor:getBody(), 0, 0, 0, 1 )
	--joint:enableMotor(true)
	--joint:setMaxMotorForce(100000)
	--joint:setLowerLimit(0)
	--joint:setUpperLimit(32)	
	--local leg2 = love.physics.newFixture(love.physics.newBody( world, x, y, "dynamic"), love.physics.newCircleShape(32), 1 )
	--leg2:setGroupIndex( -1 )
	--joint2 = love.physics.newRevoluteJoint( leg2:getBody(), anchor:getBody(), x, y, false )




	anchor:setUserData(self)
	--anchor:setRestitution( 0 )	
	anchor:getBody( ):setFixedRotation( true )
	anchor:getBody( ):setLinearDamping( 1 )
	anchor:getBody( ):setMass( 1 )
	anchor:getBody( ):setInertia( 1 )
	anchor:getBody( ):setGravityScale( 9 )

	function self.update( dt )
		self.updateInput( dt )
		self.updatePosition( )
		self.triggersupdate( )
		
		self.cx, self.cy = x - ox + width / 2, y - oy + height / 2
		self.radius = yama.g.getDistance( self.cx, self.cy, x - ox, y - oy )
		
	end

	local allowjump = true
	local jumping = false

	function self.updateInput( dt )
		fx, fy = 0, 0
		relativeDirection = ""
		if yama.g.getDistance( 0, 0, love.joystick.getAxis( 1, 1 ), love.joystick.getAxis( 1, 2 ) ) > 0.25 then
			nx = love.joystick.getAxis( 1, 1 )
			ny = love.joystick.getAxis( 1, 2 )
			relativeDirection = yama.g.getRelativeDirection( math.atan2( ny, nx ))
		end
		
		if love.keyboard.isDown( "right" ) or relativeDirection == "right" then
			direction = 1.570796327
			if onGround then				
				fx = xForce
			else
				fx = xJumpForce
			end
			xv, yv = anchor:getBody():getLinearVelocity()
			if xv <= maxSpeed then
				applyForce( fx, fy )
			end
		end
		if love.keyboard.isDown("left") or relativeDirection == "left" then
			direction = 4.71238898
			if onGround then
				fx = -xForce
			else	
				fx = -xJumpForce
			end
			if xv >= -maxSpeed then
				applyForce( fx, fy )
			end
		end

		if yama.g.getDistance( 0, 0, love.joystick.getAxis(1, 5 ), love.joystick.getAxis( 1, 4 ) ) > 0.25 then	
			spawntimer = spawntimer - dt
			if spawntimer <= 0 then
				local leftover = math.abs( spawntimer )
				spawntimer = 0.05 - leftover
				
				local nx = love.joystick.getAxis( 1, 5 )
				local ny = love.joystick.getAxis( 1, 4 )
				aim = math.atan2( ny, nx )
				--xrad = math.cos( aim )
				--yrad = math.sin( aim )
				
				xPosBulletSpawn = 34*nx + x
				yPosBulletSpawn = 34*ny + y
				bullet = yama.entities.new( "bullet", xPosBulletSpawn, yPosBulletSpawn, 0, vp )
				swarm.insert(bullet)
				fxbullet = bulletImpulse * nx
				fybullet = bulletImpulse * ny				
				
				bullet.shoot( fxbullet, fybullet )
				table.insert( bullets, bullet )
				lenBullets = #bullets				
				if lenBullets >= nAllowedBullets then
					bullets[1].destroy()
					table.remove( bullets, 1 )
				end
			end
		end

		xv, yv = anchor:getBody():getLinearVelocity()
		if allowjump and ( love.keyboard.isDown(" ") or love.joystick.isDown( 1, 1 ) ) then
			anchor:getBody():applyLinearImpulse( 0, -jumpForce )
			allowjump = false
		end
		
		if jumpTimer < jumpMaxTimer and ( love.keyboard.isDown(" ") or love.joystick.isDown( 1, 1 ) ) then
			applyForce( 0, -jumpIncreaser )
			jumpTimer = jumpTimer + dt
			if jumpTimer > jumpMaxTimer and OnGround then
				jumpTimer = 0
			end
		end


		if not love.keyboard.isDown(" ") and not love.joystick.isDown( 1, 1 ) and onGround == true then
			allowjump = true
		end

		if pContact then
			if not love.keyboard.isDown(" ") and not love.joystick.isDown( 1, 1 ) then
				pContact:setFriction( stopFriction ) 
			end
		end
		
		--print("Trigger:" .. love.joystick.getAxis(1, 3 ))
		--if love.joystick.getAxis(1, 3 ) < -0.25 then
		--	leg2:getBody():applyTorque(100000)
			--joint:setUpperLimit(32 + love.joystick.getAxis(1, 3 ) * 32)
		--end
	end
	
	function applyForce( fx, fy )
		anchor:getBody():applyForce( fx, fy )
	end

	function self.updatePosition(xn, yn)		
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
		
		spriteArrow.x = x --math.floor(x + 0.5)
		spriteArrow.y = y --math.floor(y-16 + 0.5)
		spriteArrow.r = aim

		--particle:setPosition(self.getX(), self.getY()-oy/2)
	end

	local animation = {}
	animation.quad = 1
	animation.dt = 0

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
		table.sort(triggers.data, triggers.sort)

		if triggers.data[1] then
			triggers.data[1].active = true
			for i=2, #triggers.data do
				triggers.data[i].active = false
			end
		end
	end

	function triggers.sort(a, b)
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
				jumpTimer = 0
				onGround = true
				contact:setFriction( friction )
			end
		end
	end

	function self.endContact(a, b, contact)
		if b:getUserData() then
			if b:getUserData().type == 'floor' then
				onGround = false
				allowjump = false
				contact:setFriction( stopFriction )
			end
		end
	end

	function self.draw( )
		love.graphics.setColorMode( "modulate" )
		love.graphics.setColor( 255, 255, 255, 255 );
		love.graphics.setBlendMode( "alpha" )
		if hud.enabled then
			physics.draw( anchor, { 0, 255, 0, 102 } )
		end
	end

	function self.addToBuffer( )
		buffer.add( bufferBatch )
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
		anchor:getBody():destroy()
		self.destroyed = true
	end

	return self
end