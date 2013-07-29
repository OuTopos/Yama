entities_bullet = {}

function entities_bullet.new( map, x, y, z )
	local self = {}

	local userdata = {}
	userdata.name = "Unnamed"
	userdata.type = "bullet"
	userdata.properties = {}
	userdata.callback = self

	--local camera = vp.getCamera()
	--local buffer = vp.getBuffer()
	--local map = vp.getMap()
	--local swarm = vp.getSwarm()
	local world = map.getWorld()

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
	local bulletsprite = yama.buffers.newSprite( images.load( "bullet" ), images.quads.data[ "bullet" ] [ 1 ], x, y, z, r, sx, sy, ox, oy )

	table.insert( bufferBatch.data, bulletsprite )

	-- Physics
	local bullet = love.physics.newFixture(love.physics.newBody( world, x, y, "dynamic"), love.physics.newCircleShape( 4 ) )
	--local bullet = love.physics.newFixture(love.physics.newBody( world, x, y, "dynamic"), love.physics.newRectangleShape( 8, 8 ) )
	bullet:setGroupIndex( -1 )

	bullet:setUserData( userdata )
	bullet:setRestitution( 0.70 )
	bullet:getBody( ):setFixedRotation( false )
	bullet:getBody( ):setLinearDamping( 0.3 )
	bullet:getBody( ):setMass( 0.4 )
	bullet:getBody( ):setInertia( 0.2 )
	bullet:getBody( ):setGravityScale( 1 )
	bullet:getBody( ):setBullet( true )

	function self.update( dt )
		self.updatePosition( )
		self.cx, self.cy = x - ox + width / 2, y - oy + height / 2
		self.radius = yama.g.getDistance( self.cx, self.cy, x - ox, y - oy )
	end
	
	function self.shoot( fx, fy )
		bullet:getBody( ):applyLinearImpulse( fx, fy )
	end

	function self.updatePosition( xn, yn )
		x = bullet:getBody( ):getX( )
		y = bullet:getBody( ):getY( )
		r = bullet:getBody( ):getAngle( )

		bufferBatch.x = x
		bufferBatch.y = y
		bufferBatch.z = 100
		bufferBatch.r = r
		
		bulletsprite.x = x --math.floor(x + 0.5)
		bulletsprite.y = y --math.floor(y-16 + 0.5)
		bulletsprite.r = aim

	end

	local animation = {}
	animation.quad = 1
	animation.dt = 0

	-- CONTACT --
	function self.beginContact( a, b, contact )
		--print( 'bullet: beginContact')
		--print( a:getBody( ):getMass() )
		pContact = contact
		local userdata = b:getUserData( )
		if userdata then
			--print( a:getUserData().type, userdata.type )
			if userdata.type == 'shield' or userdata.type == 'mplayer' then
				self.destroy()
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
			physics.draw( bullet, { 0, 255, 0, 102 } )
		end
	end

	function self.addToBuffer( vp )
		vp.getBuffer( ).add( bufferBatch )
	end


	-- Basic functions
	function self.setPosition( x, y )
		bullet.body:setPosition( x, y )
		bullet.body:setLinearVelocity( 0, 0 )
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

	-- GET
	function self.getType()
		return type
	end
	function self.getPosition()
		return x, y, z
	end
	function self.getBoundingBox()
		local bx = x - ox * sx
		local by = y - oy * sy

		return bx, by, width * sx, height * sy
	end
	function self.getBoundingCircle()
		local bx, by, width, height = self.getBoundingBox()
		local cx, cy = bx + width / 2, by + height / 2
		local radius = yama.g.getDistance(x, y, cx, cy)

		return cx, cy, radius
	end
	function self.destroy( )
		if not self.destroyed then
			bullet:getBody():destroy()
			self.destroyed = true
		end
	end

	return self
end