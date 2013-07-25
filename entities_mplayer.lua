entities_mplayer = {}


function entities_mplayer.new( map, x, y, z )
	local self = {}

	local userdata = {}
	userdata.name = "Unnamed"
	userdata.type = "mplayer"
	userdata.properties = {}
	userdata.entity = self

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
	local doLeg = 1

	-- BUTTONS --

	buttonShoulderR = 6
	buttunFaceA = 1
	buttunTriggerR = 3


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
	local spawntimer = 0
	local bullet = nil
	local bullets = {}
	local bulletImpulse = 900
	local nAllowedBullets = 60

	local wallContact = 0
	local latestCol = nil
	-- BUFFER BATCH
	local bufferBatch = yama.buffers.newBatch(x, y, z)
	
	-- SPRITE (PLAYER)
	images.quads.add( "jumper", width, height )
	images.load( "jumper" ):setFilter( "linear", "linear" )
	local sprite = yama.buffers.newSprite( images.load( "jumper" ), images.quads.data[ "jumper" ] [ 1 ], x, y, z, r, sx, sy, ox, oy )
	
	tilesetArrow = images.load( "directionarrowshootah" )
	tilesetArrow:setFilter( "linear", "linear" )
	local spriteArrow = yama.buffers.newDrawable( tilesetArrow, x, y, 1000, 1, sx, sy, 3, 3 )

	table.insert( bufferBatch.data, sprite )
	table.insert( bufferBatch.data, spriteArrow )
	
	-- Physics
	local anchor = love.physics.newFixture( love.physics.newBody( world, x, y, "dynamic"), love.physics.newRectangleShape( width, height ) )
	anchor:setGroupIndex( -2 )
	anchor:setUserData( userdata )
	anchor:setRestitution( 0 )	
	anchor:getBody( ):setFixedRotation( true )
	anchor:getBody( ):setLinearDamping( 1 )
	anchor:getBody( ):setMass( 1 )
	anchor:getBody( ):setInertia( 1 )
	anchor:getBody( ):setGravityScale( 9 )
	anchor:getBody( ):setBullet( true )

	
	local canon = love.physics.newFixture(love.physics.newBody( world, x+14, y+3, "dynamic"), love.physics.newRectangleShape( 32, 6 ) )
	canon:setGroupIndex( -1 )
	canonJoint = love.physics.newRevoluteJoint( canon:getBody(), anchor:getBody(), x, y, false )
	canonJoint:enableMotor( true )
	--canonJoint = love.physics.newWheelJoint( canon:getBody(), anchor:getBody(), x, y, x, y )
	canon:getBody( ):setLinearDamping( 1 )
	canon:getBody( ):setMass( 0.0001 )
	canon:getBody( ):setInertia( 0.01 )
	canon:getBody( ):setGravityScale( 0.9 )

	function self.update( dt )
		self.updateInput( dt )
		self.updatePosition( )
		
		self.cx, self.cy = x - ox + width / 2, y - oy + height / 2
		self.radius = yama.g.getDistance( self.cx, self.cy, x - ox, y - oy )


		
	end

	local allowjump = true
	local jumping = false

	function self.updateInput( dt )

		movement( dt )
		bulletSpawn( dt )
		jumping( dt )
		--legJump( dt )
	end

	function movement( dt )
		fx, fy = 0, 0
		relativeDirection = ""
		
		if yama.g.getDistance( 0, 0, love.joystick.getAxis( 1, 1 ), love.joystick.getAxis( 1, 2 ) ) > 0.25 then
			xv, yv = anchor:getBody():getLinearVelocity()
			if pContact then
				pContact:setFriction( friction )
			end
			nx = love.joystick.getAxis( 1, 1 )
			ny = love.joystick.getAxis( 1, 2 )
			relativeDirection = yama.g.getRelativeDirection( math.atan2( ny, nx ))
		else
			if pContact then
				pContact:setFriction( stopFriction )
			end
		end
		
		if love.keyboard.isDown( "right" ) or relativeDirection == "right" then
			direction = 1.570796327
			if onGround then				
				fx = xForce
			else
				fx = xJumpForce
			end
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
	end


	function bulletSpawn(dt)
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
				--print( xPosBulletSpawn, xPosBulletSpawn )
				bullet = map.spawnXYZ( "bullet", xPosBulletSpawn, yPosBulletSpawn, 0 )
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
	end

	function jumping(dt)

		-- JUMPING --
		xv, yv = anchor:getBody():getLinearVelocity()
		if allowjump and ( love.keyboard.isDown( " " ) or love.joystick.isDown( 1, buttonShoulderR ) ) then
			anchor:getBody():applyLinearImpulse( 0, -jumpForce )
			allowjump = false
		end
		

		jumpAccelerator( dt, buttonShoulderR, jumpMaxTimer, jumpIncreaser )

		if not love.keyboard.isDown(" ") and not love.joystick.isDown( 1, buttonShoulderR ) and yv == 0 then
			allowjump = true
		end
	end



	function legJump( dt )
		--print( "legJump")

		if doLeg == 1 then
			print( "doLeg")
			--legSetup()
		end
		
		if allowjump and yama.g.getDistance( 0, 0, love.joystick.getAxis( 1, 3 ), love.joystick.getAxis( 1, 3 ) ) > 0.25 then
			print( "JUMP!")
			--distance = math.abs(love.joystick.getAxis( 1, 3 ))
			--leg1:getBody():applyLinearImpulse( 0, -(jumpForce*distance) )
			--allowjump = false
		end


		if love.joystick.isDown( 1, buttunFaceA ) then
			print( "pressssaaaaaa")
			--leg1:getBody():applyLinearImpulse( 0, 200000 )
			--allowjump = false
		end
		
		--jumpAccelerator( dt, 3, jumpMaxTimer, jumpIncreaser )


	end

	function legSetup( )
		doLeg = 0

		leg1 = love.physics.newFixture(love.physics.newBody( world, anchor:getBody():getX(), anchor:getBody():getY()+60, "dynamic"), love.physics.newRectangleShape(10, 55), 1 )
		--leg1:setGroupIndex( -1 )
		leg1:getBody( ):setFixedRotation( true )
		--joint = love.physics.newPrismaticJoint( anchor:getBody(), leg1:getBody(), 0, 0, 0, 1 )
		--joint = love.physics.newDistanceJoint( anchor:getBody(), leg1:getBody(),  anchor:getBody():getX(),  anchor:getBody():getY(), anchor:getBody():getX(), anchor:getBody():getX()+32 )
		joint = love.physics.newRevoluteJoint( leg1:getBody( ), anchor:getBody( ), anchor:getBody():getX( ), anchor:getBody( ):getY( ), 1 )
		
		--joint:enableMotor(true)
		--joint:setMaxMotorForce(100000)
		--joint:setUpperLimit(0)	
		--joint:setLowerLimit(0)
		--joint:setLimits( 0, 1 )

		--local leg2 = love.physics.newFixture(love.physics.newBody( world, x, y, "dynamic"), love.physics.newCircleShape(32), 1 )
		--leg2:setGroupIndex( -1 )
		--joint2 = love.physics.newRevoluteJoint( leg2:getBody(), anchor:getBody(), x, y, false )
	end

	function jumpAccelerator( dt, button, jMaxTimer, jIncreaser )

		if jumpTimer < jMaxTimer and ( love.keyboard.isDown( " " ) or love.joystick.isDown( 1, button ) ) then
			applyForce( 0, -jIncreaser )
			jumpTimer = jumpTimer + dt
			if jumpTimer > jMaxTimer and OnGround then
				print( "jumptiner reset!")
				jumpTimer = 0
			end
		end
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

	-- CONTACT --
	function self.beginContact( a, b, contact )
		--print( "beginContact!" )
		

		xc1, yc1, xc2, yc2 = contact:getPositions( )
		--[[
		print( "contactPos xc1", xc1 )
		--print( "contactPos yc1", yc1 )
		print( "contactPos xc2", xc2 )
		--print( "contactPos yc2", yc2 )
		--print( "body x", anchor:getBody( ):getX() )
		--print( "body y", anchor:getBody( ):getY() )
		--print( "delta y", yc1 - anchor:getBody( ):getY()  )
		--print( "a x", a:getBody( ):getX() )
		--print( "a y", a:getBody( ):getY() )
		--print( "b x", b:getBody( ):getX() )
		--print( "b y", b:getBody( ):getY() )
		--print( "delta Y", b:getBody( ):getY() - anchor:getBody( ):getY()  )
		--print( "delta X", b:getBody( ):getX() - anchor:getBody( ):getX()  )
		
		if a:getBody( ) == anchor:getBody( ) then
			--print( 'a = anchor' )
			if xc1 and xc2 then
			--	print( xc1-xc2 )
			end
			if xc1 and xc2 then 
				if xc1 - xc2 < 0.1 and xc1 - xc2 > - 0.1 then
					latestCol = 'wall'
				else
					--contact:setRestitution( 0 )
					latestCol = 'ground'
					jumpTimer = 0
					onGround = true					
					yposContact = anchor:getBody( ):getY( )
				end
			end
		end
		--]]
		-- JUMP STUFF --
		---[[
		if a:getBody() == anchor:getBody() then
			contact:setRestitution( 0 )
			if b:getUserData() then
				if b:getUserData().type == 'floor' then
					pContact = contact
					print( 'On floor!')
					jumpTimer = 0
			 		onGround = true
				end
			end
		end
		--]]
	end

	function self.endContact(a, b, contact)

		--print( "endContact!" )
		--[[
		endxc1, endyc1, endxc2, endyc2 = contact:getPositions( )
		--print( "contactPos xc1", xc1 )
		--print( "contactPos yc1", yc1 )
		--print( "contactPos xc2", xc2 )
		--print( "contactPos yc2", yc2 )
		--print( "anchorx:", anchor:getBody( ):getX() )
		--print( "ay:", anchor:getBody( ):getY() )
		--print( "ax:", a:getBody( ):getX() )
		--print( "a y", a:getBody( ):getY() )
		--print( "bx:", b:getBody( ):getX() )
		--print( "by:", b:getBody( ):getY() )


		if a:getBody( ) == anchor:getBody( ) then
			--print( 'a = anchor' )
			if xc1 and xc2 then
				--print( xc1-xc2 )
			end
			if xc1 and xc2 then 
				if xc1 - xc2 < 0.1 and xc1 - xc2 > - 0.1 then
				--	print( 'ENDsame' )
				else
					onGround = false
					allowjump = false
				end
			end
		end
		--]]
	
		---[[
		-- JUMP STUFF --
		if a:getBody() == anchor:getBody() then
			contact:setRestitution( 0 )
			if b:getUserData() then
				if a:getUserData().type == 'floor' or b:getUserData().type == 'floor' then
					print( 'Endcontact floor!')
					onGround = false
				end
			end
		end
		--]]
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
		return x
	end
	function self.getY()
		return y
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
	function self.getCX()
		return x - ox + width / 2
	end
	function self.getCY()
		return y - oy + height / 2
	end
	function self.getRadius()
		return yama.g.getDistance(self.getCX(), self.getCY(), x - ox * sx, y - oy * sy)
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