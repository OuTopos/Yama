entities_player = {}

function entities_player.new(x, y)
	local self = {}

	-- Common variables
	local width, height = 64, 64
	local ox, oy = 32, 48
	local sx, sy = 1, 1
	local r = 0


	self.type = "player"


	local remove = false



	--local x, y, z = xn, yn, 32
	local xvel, yvel = 0, 0
	local speed = 0
	local friction = 0.99
	local direction = 0

	local width, height = 64, 64

	-- SPRITES
	local treeimage = love.graphics.newImage( "images/player.png" )
	local grid_marker = love.graphics.newImage( "images/grid_marker.png" )
	local selector = love.graphics.newImage( "images/selectorA.png" )




	local p = love.graphics.newParticleSystem(treeimage, 1000)
	p:setEmissionRate(100)
	p:setSpeed(300, 400)
	p:setGravity(0)
	p:setSizes(2, 1)
	p:setColors(255, 255, 255, 255, 58, 128, 255, 0)
	p:setPosition(400, 300)
	p:setLifetime(1)
	p:setParticleLife(1)
	p:setDirection(0)
	p:setSpread(360)
	p:setRadialAcceleration(-2000)
	p:setTangentialAcceleration(1000)
	p:stop()

	local particle = {}
	particle.trail = love.graphics.newParticleSystem(treeimage, 1000)
	particle.trail:setEmissionRate(100)
	particle.trail:setSpeed(0, 25)
	particle.trail:setGravity(0)
	particle.trail:setSizes(1, 1)
	particle.trail:setColors(200, 170, 50, 51, 255, 204, 0, 0)
	particle.trail:setPosition(0, 0)
	particle.trail:setLifetime(1)
	particle.trail:setParticleLife(0.5)
	particle.trail:setDirection(0)
	particle.trail:setSpread(360)
	particle.trail:setRadialAcceleration(0)
	particle.trail:setTangentialAcceleration(0)
	particle.trail:stop()

	--table.insert(spriteset.data, {sheet = "tilesets/LPC/lori_angela_nagel_-_jastivs_artwork/png/female_dwing_walkcycle", quad = 14} )
--	table.insert(spriteset.data, {sheet = "BODY_skeleton", quad = 14} )
--	table.insert(spriteset.data, {sheet = "HEAD_chain_armor_hood", quad = 14} )
	--table.insert(spriteset.data, {sheet = "HEAD_chain_armor_helmet", quad = 14} )
--	table.insert(spriteset.data, {sheet = "FEET_shoes_brown", quad = 14} )
	

	
	-- Physics
	--local hitbox = physics.newObject(love.physics.newBody(physics.world, x, y, "dynamic"), love.physics.newRectangleShape(0, -8, 28, 48), self, true)
	local anchor = love.physics.newFixture(love.physics.newBody(physics.world, x, y, "dynamic"), love.physics.newCircleShape(14), 5)
	anchor:setUserData(self)
	anchor:setRestitution( 0.4 )
	anchor:getBody():setLinearDamping( 8 )
	anchor:getBody():setFixedRotation( true )


	function self.update(dt)
		self.updateInput(dt)
		self.updatePosition()
		self.updateAnimation(dt)

		particle.trail:start()
		particle.trail:update(dt)

		self.triggersupdate()
	end

	function self.updateInput(dt)
		fx, fy = 0, 0

		if love.keyboard.isDown("up") then
			direction = 3.141592654
			fy = -5000
		end
		if love.keyboard.isDown("right") then
			direction = 1.570796327
			fx = 5000
		end
		if love.keyboard.isDown("down") then
			direction = 0
			fy = 5000
		end
		if love.keyboard.isDown("left") then
			direction = 4.71238898
			fx = -5000
		end

		anchor:getBody():applyForce( fx, fy )
	end

	function self.updatePosition(xn, yn)
		--hitbox.body:setX(anchor.body:getX())
		--hitbox.body:setY(anchor.body:getY())
		
		x = anchor:getBody():getX()
		y = anchor:getBody():getY()
		--x = anchor.body:getX() - 16
		--y = anchor.body:getY() - 16

		particle.trail:setPosition(x, y)
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
		--print("beginContact for player")
		if b:isSensor() then
			if b:getUserData() then
				local entity = b:getUserData()

				if entity.isTree then
					--print("adding entity to triggers")
					--local d, x1, y1, x2, y2 = love.physics.getDistance(b, anchor.fixture)
					d = getDistance(a:getBody():getX(), a:getBody():getY(), b:getBody():getX(), b:getBody():getY())
					--print(d)
					triggers.add(entity)
				end
			end
		end
	end

	function self.endContact(a, b, contact)
		--print("END")
		--print(contact:getSeparation( ))
		if b:isSensor() then
			if b:getUserData() then
				local entity = b:getUserData()

				if entity.isTree then
					triggers.remove(entity)
				end
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
		
		love.graphics.draw(particle.trail, 0, -16)

		love.graphics.setColor(255, 255, 255, 255);
		--love.graphics.setColorMode("modulate")
		love.graphics.setBlendMode("alpha")
		--love.graphics.draw(treeimage, x, y, r, sx, sy, ox, oy)

		if hud.enabled then
			physics.draw(anchor, {0, 255, 0, 102})
		end
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
		return x
	end
	function self.getY()
		return y
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
	function self.destroy()
		anchor:getBody():destroy()
	end

	return self
end