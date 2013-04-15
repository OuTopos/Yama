entities_humanoid = {}

function entities_humanoid.new(x, y, z)
	local self = {}

	-- Sprite variables
	local width, height = 64, 64
	local ox, oy = width/2, height
	local sx, sy = 1, 1
	local r = 0

	-- Movement variables
	local radius = 10
	local mass = 1
	local velocity = 250
	local direction = math.atan2(math.random(-1, 1), math.random(-1, 1))
	local move = false

	-- BUFFER BATCH
	local bufferBatch = buffer.newBatch(x, y, z)

	-- ANIMATION
	local animation = animations.new()
	--animation.set("humanoid_stand_down")
	animation.setTimescale(math.random(9, 11)/10)

	-- PATROL
	local patrol = patrols.new(true, 20)
	patrol.set("fun")
	--patrol.setLoop(false)
	--patrol.setRadius(32)

	-- SPRITE
	local attributes = {}
	attributes.gender = {"male", "female"}
	attributes.body = {"light", "tanned", "tanned2", "dark", "dark2", "orc", "skeleton"}
	attributes.eyes = {nil, "blue", "brown", "gray", "green", "red"}
	attributes.hairmale = {nil, "bangs", "bedhead", "long", "longhawk", "messy1", "messy2", "mohawk", "page", "parted", "shorthawk"}
	attributes.haircolormale = {nil, "blonde", "blue", "brunette", "green", "pink", "raven", "redhead", "white-blonde"}
	attributes.hairfemale = {"bangslong", "bangsshort", "loose", "pixie", "ponytail", "swoop", "unkempt"}
	attributes.haircolorfemale = {nil, "black", "blonde", "blonde2", "blue", "brown", "brunette", "brunette2" , "dark-blonde", "gray", "green", "light-blonde", "pink", "raven", "raven2", "redhead", "white", "white-blonde", "white-blonde2"}
	

	local character = {}
	-- Gender
	character.gender = attributes.gender[math.random(1, 2)]
	-- Body
	if character.gender == "male" then
		character.body = attributes.body[math.random(1, 7)]
	else
		character.body = attributes.body[math.random(1, 6)]
	end
	-- Eyes
	if character.body ~= "orc" and character.body ~= "skeleton" then
		character.eyes = attributes.eyes[math.random(1, 6)]
	end
	-- Hair
	if character.gender == "male" and character.body ~= "orc" and character.body ~= "skeleton" then
		character.hair = attributes.hairmale[math.random(1, 11)]
		character.haircolor = attributes.haircolormale[math.random(1, 9)]
	elseif character.gender == "female" and character.body ~= "orc" then
		character.hair = attributes.hairfemale[math.random(1, 7)]
		character.haircolor = attributes.haircolorfemale[math.random(1, 18)]
	end






	local canvas = love.graphics.newCanvas(832, 1344)
	love.graphics.setCanvas(canvas)
	-- Body
	love.graphics.draw(images.load("LPC/body/"..character.gender.."/"..character.body), 0, 0)
	if character.eyes then
		love.graphics.draw(images.load("LPC/body/"..character.gender.."/eyes/"..character.eyes), 0, 0)
	end
	-- Hair
	if character.hair then
		if character.haircolor then
			love.graphics.draw(images.load("LPC/hair/"..character.gender.."/"..character.hair.."/"..character.haircolor), 0, 0)
		else
			love.graphics.draw(images.load("LPC/hair/"..character.gender.."/"..character.hair), 0, 0)
		end
	end
	love.graphics.setCanvas()

	--images.inject("123456", love.graphics.newImage(canvas:getImageData()))

	local image = love.graphics.newImage(canvas:getImageData())

	local quads = images.quads.generate(image, width, height)
	local sprite = buffer.newSprite(image, quads[1], x, y+radius, z, r, sx, sy, ox, oy)
	
	table.insert(bufferBatch.data, sprite)

	-- Anchor variables
	local anchor = love.physics.newFixture(love.physics.newBody(physics.world, x, y-radius, "dynamic"), love.physics.newCircleShape(radius))
	anchor:setUserData(self)
	anchor:setRestitution( 0 )
	anchor:getBody():setLinearDamping( 10 )
	anchor:getBody():setFixedRotation( true )

	-- Monster variables
	self.monster = true
	local hp = 0.75

	-- Destination
	local dx, dy = nil, nil


	-- Standard functions
	function self.update(dt)
		-- Patrol update
		patrol.update(x, y)

		-- Direction and move
		if patrol.isActive() then
			dx, dy = patrol.getPoint()
			move = true
		else
			dx, dy = nil, nil
			move = false
		end

		if dx and dy then
			direction = math.atan2(dy-y, dx-x)
		end

		if move then
			fx = velocity * math.cos(direction)
			fy = velocity * math.sin(direction)
			anchor:getBody():applyForce( fx, fy )
		end

		-- Position updates
		x = anchor:getBody():getX()
		y = anchor:getBody():getY()
		sprite.x = x
		sprite.y = y + radius
		--sprite.z = z
		bufferBatch.x = x
		bufferBatch.y = y + radius
		--bufferBatch.z = z

		-- Animation updates
		animation.update(dt, "humanoid_walk_"..getRelativeDirection(direction))
		sprite.quad = quads[animation.getFrame()]
	end

	function self.addToBuffer()
		buffer.add(bufferBatch)
	end

	-- Monster functions

	function self.hurt(p)

	end

	-- Common functions
	function self.getX()
		return x
	end
	function self.getY()
		return y
	end
	function self.getZ()
		return z
	end
	function self.getOX()
		return x - ox * sx
	end
	function self.getOY()
		return y - oy * sy + radius
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