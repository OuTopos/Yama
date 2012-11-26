function initiateFarticle()
	rain = love.graphics.newImage("sprites/ape.png")
	rainSystem = love.graphics.newParticleSystem(rain,1000)

	rainSystem:setEmissionRate(100)
	rainSystem:setSpeed(1000, 0)
	rainSystem:setGravity(0)
	rainSystem:setSizes(0.1, 0.1)
	rainSystem:setColors(255, 255, 255, 255, 58, 128, 255, 0)
	rainSystem:setPosition(400, 300)
	rainSystem:setLifetime(10)
	rainSystem:setParticleLife(10)
	rainSystem:setDirection(math.rad(90))
	rainSystem:setSpread(0)
	--rainSystem:setRadialAcceleration(-2000)
	--rainSystem:setTangentialAcceleration(1000)
	rainSystem:stop()

end


function updateFarticle(dt)
	local x = player.RoundX + math.random(-400,400)
	rainSystem:setPosition(x, camera.y-16)
	rainSystem:start()
	rainSystem:update(dt)
end


function drawFarticle()
	love.graphics.setColor(200, 200, 200)
	--love.graphics.setColorMode("modulate")
	--love.graphics.setBlendMode("additive")
	love.graphics.draw(rainSystem, 0, 0)
end