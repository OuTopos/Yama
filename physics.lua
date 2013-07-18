physics = {}
physics.enabled = true
physics.world = nil

function physics.setWorld(world)
	--physics.world = world
	world:setCallbacks(physics.beginContact, physics.endContact, nil, nil)
end

function physics.update(dt)
	if physics.enabled then
		if physics.world then
			physics.world:update(dt)
		end
	end
end

function physics.draw(world)
	if physics.enabled then
		if world then
			for i, body in ipairs(world:getBodyList()) do
				--fixtures = body:getFixtureList()
				for i, fixture in ipairs(body:getFixtureList()) do
					physics.drawFixture(fixture)
				end
			end
		end
	end
end

function physics.drawFixture(fixture, color)
	local r, g, b, a = 0, 0, 0, 0

	if color then
		love.graphics.setColor(color)
	else
		if fixture:getBody():getType() == "static" then
			r, g = 255, 0
		else
			r, g = 0, 255
		end

		if fixture:isSensor() then
			b = 255
		else
			b = 0
		end

		if fixture:getBody():isActive() then
			a = 102
		else
			a = 51
		end

		if not fixture:getUserData() then
			a = 255
		end
		love.graphics.setColor(r, g, b, a)
	end

	if fixture:getShape():getType() == "circle" then
		love.graphics.circle("fill", fixture:getBody():getX(), fixture:getBody():getY(), fixture:getShape():getRadius())
	elseif fixture:getShape():getType() == "polygon" then
		love.graphics.polygon("fill", fixture:getBody():getWorldPoints(fixture:getShape():getPoints()))
	elseif fixture:getShape():getType() == "edge" then
		love.graphics.line(fixture:getBody():getWorldPoints(fixture:getShape():getPoints()))
	elseif fixture:getShape():getType() == "chain" then
		love.graphics.line(fixture:getBody():getWorldPoints(fixture:getShape():getPoints()))
	end
	love.graphics.setColor(255, 255, 255, 255)
end

function physics.beginContact(a, b, contact)
	if a:getUserData() then
		if a:getUserData().beginContact then
			a:getUserData().beginContact(a, b, contact)
		end
	end
	if b:getUserData() then
		if b:getUserData().beginContact then
			b:getUserData().beginContact(b, a, contact)
		end
	end
end

function physics.endContact(a, b, contact)
	if a:getUserData() then
		if a:getUserData().endContact then
			a:getUserData().endContact(a, b, contact)
		end
	end
	if b:getUserData() then
		if b:getUserData().endContact then
			b:getUserData().endContact(b, a, contact)
		end
	end
end

function physics.preSolve(a, b, contact)
	if a:getUserData() then
		if a:getUserData().preSolve then
			a:getUserData().preSolve(a, b, contact)
		end
	end
	if b:getUserData() then
		if b:getUserData().preSolve then
			b:getUserData().preSolve(b, a, contact)
		end
	end
end

function physics.postSolve(a, b, contact)
	if a:getUserData() then
		if a:getUserData().postSolve then
			a:getUserData().postSolve(a, b, contact)
		end
	end
	if b:getUserData() then
		if b:getUserData().postSolve then
			b:getUserData().postSolve(b, a, contact)
		end
	end
end

physics.catagories = {}

physics.catagories["player"] = 1
physics.catagories["sensors"] = 2
