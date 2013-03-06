entities_tree = {}

function entities_tree.new(x, y, z)
	local self = {}

	-- Common variables
	x = x or 0
	y = y or 0
	z = z or 0
	local width, height = 128, 192
	local ox, oy = 64, 160
	local sx, sy = 1, 1
	local r = 0

	-- Specific variables
	self.isTree = true

	self.active = false

	-- Sprite variables
	local sprite = love.graphics.newImage( "images/tree"..tostring(math.random(1,2))..".png" )
	local sprite2 = love.graphics.newImage( "images/tree1.png" )
	local sprite3 = love.graphics.newImage( "images/tree1.png" )

	if sprite2 == sprite3 then
		print("fuck yeah")
	end
	local color = {0, 255, 255, 255}

	local bufferObject = buffer.newDrawable(sprite, x, y, 0, r, sx, sy, ox, oy)
	buffer.add(bufferObject)

	-- Anchor variables
	local anchor = love.physics.newFixture(love.physics.newBody(physics.world, x, y, "fixed"), love.physics.newCircleShape(32))
	anchor:setUserData(self)
	anchor:setSensor(true)

	-- Standard functions
	function self.update(dt)
		x, y = anchor:getBody():getX(), anchor:getBody():getY()
		if self.active then
			bufferObject.color = {255, 255, 255, 102}
		else
			bufferObject.color = nil
		end
	end

	function self.draw()
		if self.active then
			--bufferObject.color = {255, 255, 255, 102}
		else
			--bufferObject.color = nil
		end

		--love.graphics.draw(sprite, x, y, r, sx, sy, ox, oy)
		--love.graphics.setColor(255, 255, 255, 255)
		
		if hud.enabled then
			physics.draw(anchor)
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