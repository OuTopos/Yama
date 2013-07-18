entities_mplayer = {}


function entities_mplayer.new( map, x, y, z )
	local self = {}

	--local camera = vp.getCamera()
	--local buffer = vp.getBuffer()
	--local map = vp.getMap()
	--local swarm = vp.getSwarm()
	local world = map.getWorld()

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
	local bulletImpulse = 900
	local nAllowedBullets = 60

	-- BUFFER BATCH
	local bufferBatch = yama.buffers.newBatch(x, y, z)
	
	-- SPRITE (PLAYER)
	images.quads.add( "jumper", 32, 32 )
	images.load( "jumper" ):setFilter( "linear", "linear" )
	local sprite = yama.buffers.newSprite( images.load( "jumper" ), images.quads.data[ "jumper" ] [ 1 ], x, y, z, r, sx, sy, ox, oy )
	
	tilesetArrow = images.load( "directionarrowshootah" )
	tilesetArrow:setFilter( "linear", "linear" )
	local spriteArrow = yama.buffers.newDrawable( tilesetArrow, x, y, 1000, 1, sx, sy, 3, 3 )

	table.insert( bufferBatch.data, sprite )
	table.insert( bufferBatch.data, spriteArrow )
	
	-- Physics
	local anchor = love.physics.newFixture(love.physics.newBody( world, x, y, "dynamic"), love.physics.newRectangleShape( width-2, height) )
	anchor:setGroupIndex( -1 )
	anchor:setUserData(self)
	anchor:setRestitution( 0 )	
	anchor:getBody( ):setFixedRotation( true )
	anchor:getBody( ):setLinearDamping( 1 )
	anchor:getBody( ):setMass( 1 )
	anchor:getBody( ):setInertia( 1 )
	anchor:getBody( ):setGravityScale( 9 )
	anchor:getBody( ):setBullet( true )
	local anchor2 = love.physics.newFixture(anchor:getBody(), love.physics.newRectangleShape( width, height-2 ) )
	anchor2:setGroupIndex( -1 )
	
	--local canon = love.physics.newFixture(love.physics.newBody( world, x+14, y+3, "dynamic"), love.physics.newRectangleShape( 32, 6 ) )
	--canon:setGroupIndex( -1 )
	--canonJoint = love.physics.newRevoluteJoint( canon:getBody(), anchor:getBody(), x, y, false )
	--anchor:setUserData(self)
	--anchor:setRestitution( 0 )	
	--canon:getBody( ):setLinearDamping( 1 )
	--canon:getBody( ):setMass( 0.0001 )
	--canon:getBody( ):setInertia( 1 )
	--canon:getBody( ):setGravityScale( 9 )
	
	local leg1 = love.physics.newFixture(love.physics.newBody( world, x, y+32, "dynamic"), love.physics.newRectangleShape(width, height), 1 )
	leg1:setGroupIndex( -1 )
	leg1:getBody( ):setFixedRotation( true )
	joint = love.physics.newPrismaticJoint( leg1:getBody(), anchor:getBody(), 0, 0, 0, 1 )
	--joint:enableMotor(true)
	--joint:setMaxMotorForce(100000)
	joint:setLowerLimit(0)
	joint:setUpperLimit(32)	
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

		-- BULLETS --
		local nx = love.joystick.getAxis( 1, 5 )
		local ny = love.joystick.getAxis( 1, 4 )
		if yama.g.getDistance( 0, 0, nx, ny ) > 0.25 then	
			spawntimer = spawntimer - dt
			if spawntimer <= 0 then
				local leftover = math.abs( spawntimer )
				spawntimer = 0.09 - leftover

				aim = math.atan2( ny, nx )
				xrad = math.cos( aim )
				yrad = math.sin( aim )
				
				xPosBulletSpawn = x + 28*xrad 
				yPosBulletSpawn = y + 28*yrad
				bullet = yama.entities.new( map, "bullet", xPosBulletSpawn, yPosBulletSpawn, 0 )
				map.getSwarm().insert(bullet)
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
		-- BULLETS END --

		-- JUMPING NEW --
		xv, yv = anchor:getBody():getLinearVelocity()
		if allowjump and ( love.keyboard.isDown( " " ) or love.joystick.isDown( 1, 6 ) ) then
			anchor:getBody():applyLinearImpulse( 0, -jumpForce )
			allowjump = false
		end
		
		if jumpTimer < jumpMaxTimer and ( love.keyboard.isDown( " " ) or love.joystick.isDown( 1,6 ) ) then
			applyForce( 0, -jumpIncreaser )
			jumpTimer = jumpTimer + dt
			if jumpTimer > jumpMaxTimer and OnGround then
				print( "jumptiner reset!")
				jumpTimer = 0
			end
		end

		if not love.keyboard.isDown(" ") and not love.joystick.isDown( 1, 6 ) and onGround == true then
			allowjump = true
		end

		if pContact then
			if not love.keyboard.isDown(" ") and not love.joystick.isDown( 1, 6 ) then
				pContact:setFriction( stopFriction ) 
			end
		end

		 --JUMPING LEG  A BUTTON --
		--xv, yv = anchor:getBody():getLinearVelocity()
		--if love.joystick.isDown( 1, 1 ) then
		--	leg1:getBody():applyLinearImpulse( 0, -jumpForce )
		--end
		
		--if jumpTimer < jumpMaxTimer and ( love.keyboard.isDown( " " ) or love.joystick.isDown( 1, 1 ) ) then
		--	applyForce( 0, -jumpIncreaser )
		--	jumpTimer = jumpTimer + dt
		--	if jumpTimer > jumpMaxTimer and OnGround then
		--		jumpTimer = 0
		--	end
		--end

		--if pContact then
		--	if not love.keyboard.isDown(" ") and not love.joystick.isDown( 1, 1 ) then
		--		pContact:setFriction( stopFriction ) 
		--	end
		--end
		-- JUUMPING END --

		-- JUMPING LEG  A BUTTON --
		--xv, yv = anchor:getBody():getLinearVelocity()
		--if allowjump and ( love.keyboard.isDown( " " ) or love.joystick.isDown( 1, 1 ) ) then
		--	anchor:getBody():applyLinearImpulse( 0, -jumpForce )
		--	allowjump = false
		--end
		
		--if jumpTimer < jumpMaxTimer and ( love.keyboard.isDown( " " ) or love.joystick.isDown( 1, 1 ) ) then
		--	applyForce( 0, -jumpIncreaser )
		--	jumpTimer = jumpTimer + dt
		--	if jumpTimer > jumpMaxTimer and OnGround then
		--		jumpTimer = 0
		--	end
		--end
		--if not love.keyboard.isDown(" ") and not love.joystick.isDown( 1, 1 ) and onGround == true then
		--	allowjump = true
		--end
		--if pContact then
		--	if not love.keyboard.isDown(" ") and not love.joystick.isDown( 1, 1 ) then
		--		pContact:setFriction( stopFriction ) 
		--	end
		--end
		-- JUUMPING END --
		

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

	function triggers.sort( a, b )
		if getDistance(a:getX(), a:getY(), x, y) < getDistance(b:getX(), b:getY(), x, y) then
			return true
		end
		return false
	end

	-- CONTACT --
	function self.beginContact( a, b, contact )
		print( "beginContact!", contactNormal )
		
		-- NEW JUMP --
		if a:getBody( ) == anchor:getBody( ) then
			contact:setRestitution( 0 )
			pContact = contact
			contactNormal = math.atan2( pContact:getNormal( ) )
			contactNormal = math.deg( contactNormal )
			print( "normal!", contactNormal )
			if contactNormal < 20 and contactNormal > - 20 then
				contactNormal = contactNormal + 180
			end
			if contactNormal < 200 and contactNormal > 160 then
				print( "YES", contactNormal )
				jumpTimer = 0
				onGround = true
				contact:setFriction( friction )
			end
		end
		-- JUMP STUFF --
		--if b:getUserData() then
		--	if b:getUserData().type == 'floor' then
		--		jumpTimer = 0
		--		onGround = true
		--		contact:setFriction( friction )
		--	end
		--end
	end

	function self.endContact(a, b, contact)

		if a:getBody( ) == anchor:getBody( ) then
			contact:setRestitution( 0 )

			contactNormalLeave = math.atan2( contact:getNormal( ) )
			contactNormalLeave = math.deg( contactNormalLeave )
			print( "endContact!", contactNormalLeave )
			--onGround = false
			--allowjump = false
			--if contactNormalLeave < 20 and contactNormalLeave > - 20 then
			--	contactNormalLeave = contactNormalLeave + 180
			--end
			if contactNormalLeave < 100 and contactNormalLeave > 80 then
				onGround = false
				allowjump = false
			end
		end
	
		-- JUMP STUFF --
		--if b:getUserData() then
			--if b:getUserData().type == 'floor' then
			--	onGround = false
			--	allowjump = false
			--end
		--end
	end

	function self.draw( )
		love.graphics.setColorMode( "modulate" )
		love.graphics.setColor( 255, 255, 255, 255 );
		love.graphics.setBlendMode( "alpha" )
		if hud.enabled then
			physics.draw( anchor, { 0, 255, 0, 102 } )
		end
	end

	function self.addToBuffer( vp )
		vp.getBuffer().add( bufferBatch )
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