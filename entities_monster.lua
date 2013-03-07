entities_monster = {}

function entities_monster.new(x, y)
	local self = {}

	-- Common variables
	local width, height = 32, 38
	local ox, oy = 16, 16
	local sx, sy = 1, 1
	local r = 0

	-- Sprite/Quad Variables
	local coin_image = love.graphics.newImage( "images/eyeball.png" )
	local coin_quads = {}

	for i=0, 3 do
		table.insert(coin_quads, love.graphics.newQuad(i*32, 0*38, 32, 38, 96, 152))
		table.insert(coin_quads, love.graphics.newQuad(i*32, 1*38, 32, 38, 96, 152))
		table.insert(coin_quads, love.graphics.newQuad(i*32, 2*38, 32, 38, 96, 152))
		table.insert(coin_quads, love.graphics.newQuad(i*32, 3*38, 32, 38, 96, 152))
	end

	-- Animation Variables
	local animation = {}
	animation.quad = math.random(1,3)
	animation.dt = 0

	-- Anchor variables
	local anchor = love.physics.newFixture(love.physics.newBody(physics.world, x, y, "dynamic"), love.physics.newCircleShape(8))
	anchor:setUserData(self)
	anchor:setRestitution( 0.9 )
	anchor:getBody():setLinearDamping( 0.1 )

	-- Monster variables
	self.monster = true
	local hp = 0.75


	local speed = 10
	local direction = 0

	local target = {}
	target.x = 0
	target.y = 0
	target.marginal = 1
	target.active = true

	local twitch = {}
	twitch.delay = 1
	twitch.dt = 0

	-- Standard functions
	function self.update(dt)
		


	end


	function self.update(dt)
		target.x = player.getX()
		target.y = player.getY()

		if target.active then
			fx, fy = 0, 0
			target.active = false

			if anchor:getBody():getX() < target.x - target.marginal then
				fx = speed
				target.active = true
			elseif anchor:getBody():getX() > target.x  + target.marginal then
				fx = -speed
				target.active = true
			end

			if anchor:getBody():getY() < target.y - target.marginal then
				fy = speed
				target.active = true
			elseif anchor:getBody():getY() > target.y + target.marginal then
				fy = -speed
				target.active = true
			end

			anchor:getBody():applyForce( fx, fy )
		end

		--if target.active == false then
		--	target.x = target.x + 32
		--	target.active = true
		--end

		twitch.dt = twitch.dt - dt

		if twitch.dt <= 0 then
			anchor:getBody():applyLinearImpulse( math.random(-speed, speed), math.random(-speed, speed) )
			twitch.dt = twitch.dt + twitch.delay
		end


		--x = math.floor( anchor:getBody():getX() + 0.5 ) -16
		--y = math.floor( anchor:getBody():getY() + 0.5 ) -16
		--x = anchor:getBody():getX() - 16
		--y = anchor:getBody():getY() - 16
		direction = math.atan2(anchor:getBody():getLinearVelocity()) / (math.pi / 180)

		--self.updateAnimation(dt)

		x, y = anchor:getBody():getX(), anchor:getBody():getY()
		self.animate(1, 8, 0.1, dt)

		if hp <= 0 then
			self.die()
		end
	end

	function self.draw()
		love.graphics.drawq(coin_image, coin_quads[animation.quad], x, y, r, sx, sy, ox, oy)

		if hp > 0 then
			-- HP bar
			local green = math.floor(255*hp+0.5)
			local red = 255-green
			love.graphics.setColor(red, green, 0, 255)
			--love.graphics.rectangle("fill", x-16, y-24, math.floor(32*hp+0.5), 8)
			--love.graphics.rectangle("line", x-16, y-24, 32, 8)
			love.graphics.setColor(0, 0, 0, 255)
			--love.graphics.print(math.floor(hp*100+0.5).."%", x-16, y-24)
			love.graphics.setColor(255, 255, 255, 255)
		end
		
		if hud.enabled then
			physics.draw(anchor)
		end
	end

	-- Monster functions

	function self.hurt(p)
		hp = hp - p
		if hp < 0 then
			hp = 0
		end
	end

	function self.die()
		entities.destroy(self)
	end

	-- Animation functions
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

	-- Common functions
	function self.getX()
		return x
	end
	function self.getY()
		return y
	end
	function self.getOX()
		return x - ox * sx
	end
	function self.getOY()
		return y - oy * sy
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