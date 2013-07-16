entities_bullet = {}

function entities_bullet.new( x, y, z, vp )
	local self = {}

	local camera = vp.getCamera()
	local buffer = vp.getBuffer()
	local map = vp.getMap()
	local swarm = vp.getSwarm()
	local world = swarm.getWorld()

	-- Common variables
	local width, height = 8, 8
	local ox, oy = width/2, height/2
	local sx, sy = 1, 1
	local r = 0
	self.cx, self.cy = x - ox + width / 2, y - oy + height / 2
	self.radius = yama.g.getDistance( self.cx, self.cy, x - ox, y - oy )
	self.type = "brick"
	
	local aim = 0
	local direction = 0
	local remove = false
	local speed = 0
	local bulletImpulse = 2


	-- BUFFER BATCH
	local bufferBatch = yama.buffers.newBatch( x, y, z )

	-- SPRITE (PLAYER)	
	images.quads.add( "bullet", 8, 8 )
	images.load( "bullet" ):setFilter( "linear", "linear" )
	local bullet = yama.buffers.newSprite( images.load( "bullet" ), images.quads.data[ "bullet" ] [ 1 ], x, y, z, r, sx, sy, ox, oy )

	table.insert( bufferBatch.data, bullet )

	-- Physics
	local anchor = love.physics.newFixture(love.physics.newBody( world, x, y, "dynamic"), love.physics.newCircleShape( 4 ) )
	anchor:setGroupIndex( -1 )

	anchor:setUserData(self)
	anchor:setRestitution( 0.7 )
	anchor:getBody( ):setFixedRotation( false )
	anchor:getBody( ):setLinearDamping( 0.1 )
	anchor:getBody( ):setMass( 1 )
	anchor:getBody( ):setInertia( 0.1 )
	anchor:getBody( ):setGravityScale( 9 )

	function self.update( dt )
		self.updatePosition( )
		self.triggersupdate( )
		self.cx, self.cy = x - ox + width / 2, y - oy + height / 2
		self.radius = yama.g.getDistance( self.cx, self.cy, x - ox, y - oy )
	end
	
	function self.shoot( fx, fy )
		anchor:getBody( ):applyLinearImpulse( fx, fy )
	end

	function self.updatePosition( xn, yn )
		x = anchor:getBody( ):getX( )
		y = anchor:getBody( ):getY( )
		r = anchor:getBody( ):getAngle( )

		bufferBatch.x = self.getX( )
		bufferBatch.y = self.getY( )
		bufferBatch.z = 100
		bufferBatch.r = r
		
		bullet.x = x --math.floor(x + 0.5)
		bullet.y = y --math.floor(y-16 + 0.5)
		bullet.r = aim

	end

	local animation = {}
	animation.quad = 1
	animation.dt = 0

	-- TRIGGERS
	local triggers = {}
	triggers.data = {}
	function triggers.add(entity)
		table.insert( triggers.data, entity )
		print("Trigger now added, legnth is: "..#triggers.data)
	end

	function triggers.remove( entity )
		for i=1, #triggers.data do
			if triggers.data[i] == entity then
				print( "removing "..#triggers.data )
				triggers.data[ i ].active = false
				table.remove( triggers.data, i )
				print( "gone! "..#triggers.data )
			end
		end
	end

	function self.triggersupdate( )
		--print("updating")
		table.sort( triggers.data, triggers.sort )

		if triggers.data[ 1 ] then
			triggers.data[ 1 ].active = true
			for i=2, #triggers.data do
				triggers.data[ i ].active = false
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
	function self.beginContact( a, b, contact )
		pContact = contact
		if b:getUserData( ) then
			if b:getUserData( ).type == 'floor' then

			end
		end
	end

	function self.endContact( a, b, contact )
		if b:getUserData( ) then
			if b:getUserData( ).type == 'floor' then

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