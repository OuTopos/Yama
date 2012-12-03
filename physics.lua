physics = {}
physics.enabled = true
physics.worlds = {}


function physics.newWorld(world, xg, yg, meter, sleep)
end

function physics.setWorld(world, xg, yg, meter, sleep)
	love.physics.setMeter(meter or 32)

	if not physics.worlds[world] then
		physics.worlds[world] = love.physics.newWorld(xg, yg, sleep or false)
		physics.worlds[world]:setCallbacks(physics.beginContact, physics.endContact, nil, nil)
	end
	physics.world = physics.worlds[world]

	--physics.destroy()
	--love.physics.setMeter(meter or 32)
	--physics.world = love.physics.newWorld(xg, yg, sleep or false)
	--physics.world:setCallbacks(physics.beginContact, physics.endContact)
end

--function physics.newFixture(body, shape, density)
	--local object = {body = body, shape = shape}

	--fixture = love.physics.newFixture(body, shape, density or 5)
	--local userdata = {}
	--userdata.entity = entity
	--userdata.type = type
	--fixture:setUserData(entity)
	--if sensor then
	--	fixture:setSensor(true)
	--end
	--table.insert(physics.fixtures, fixture)
	--return love.physics.newFixture(body, shape, density or 5)
--end

--function physics.destroy(fixture)
--	for i=1, #physics.fixtures do
--		if physics.fixtures[i] == fixture then
--			fixture:destroy()
--			table.remove(physics.fixtures, i)
--		end
--	end
	--print("DESTROY WORLD NOOOO!")
	--if physics.world then
	--	physics.world:destroy()
	--	physics.world = nil
	--end
	--physics.fixtures = {}
--end


function physics.update(dt)
	if physics.enabled then
		if physics.world then
			physics.world:update(dt)
		end
	end
end

function physics.draw(fixture, color)
	--if fixture:getBody():getType() == "static" then
	--	if fixture:isSensor() then
	--		love.graphics.setColor(255, 0, 255, 102)
	--	elseif fixture:getUserData() then
	--		love.graphics.setColor(255, 255, 0, 102)
	--	else
	--		love.graphics.setColor(255, 0, 0, 102)
	--	end
	--elseif fixture:getBody():getType() == "dynamic" then
	--	if fixture:isSensor() then
	--		love.graphics.setColor(0, 255, 255, 102)
	--	elseif fixture:getUserData() then
	--		love.graphics.setColor(0, 255, 0, 102)
	--	else
	--		love.graphics.setColor(0, 0, 255, 102)
	--	end
	--end
	color = color or {255, 0, 0, 102}
	love.graphics.setColor(color)
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

function physics.drawold()
	for i = 1, #physics.fixtures do
		if physics.fixtures[i]:getBody():getType() == "static" then
			if physics.fixtures[i]:isSensor() then
				love.graphics.setColor(255, 0, 255, 102)
			elseif physics.fixtures[i]:getUserData() then
				love.graphics.setColor(255, 255, 0, 102)
			else
				love.graphics.setColor(255, 0, 0, 102)
			end
		elseif physics.fixtures[i]:getBody():getType() == "dynamic" then
			if physics.fixtures[i]:isSensor() then
				love.graphics.setColor(0, 255, 255, 102)
			elseif physics.fixtures[i]:getUserData() then
				love.graphics.setColor(0, 255, 0, 102)
			else
				love.graphics.setColor(0, 0, 255, 102)
			end
		end

		if physics.fixtures[i]:getShape():getType() == "circle" then
			love.graphics.circle("fill", physics.fixtures[i]:getBody():getX(), physics.fixtures[i]:getBody():getY(), physics.fixtures[i]:getShape():getRadius())
		elseif physics.fixtures[i]:getShape():getType() == "polygon" then
			love.graphics.polygon("fill", physics.fixtures[i]:getBody():getWorldPoints(physics.fixtures[i]:getShape():getPoints()))
		elseif physics.fixtures[i]:getShape():getType() == "edge" then
			love.graphics.line(physics.fixtures[i]:getBody():getWorldPoints(physics.fixtures[i]:getShape():getPoints()))
		elseif physics.fixtures[i]:getShape():getType() == "chain" then
			love.graphics.line(physics.fixtures[i]:getBody():getWorldPoints(physics.fixtures[i]:getShape():getPoints()))
		end
	end
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