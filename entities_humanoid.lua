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

	local team = 2

	-- ANIMATION
	local animation = yama.animations.new()
	--animation.set("humanoid_stand_down")
	animation.timescale = math.random(9, 11)/10

	-- PATROL
	--local patrol = yama.patrols.new(true, 20)
	--patrol.set("fun")
	--patrol.setLoop(false)
	--patrol.setRadius(32)

	-- BUFFER BATCH
	local bufferBatch = buffer.newBatch(x, y, z)

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






	--local canvas = love.graphics.newCanvas(832, 1344)
	--love.graphics.setCanvas(canvas)
	local tilesets = {}
	local spr = {}
	-- Body
	tilesets.body = "LPC/body/"..character.gender.."/"..character.body
	images.quads.add(tilesets.body, width, height)
	spr.body = buffer.newSprite(images.load(tilesets.body), images.quads.data[tilesets.body][131], x, y+radius, z, r, sx, sy, ox, oy)
	table.insert(bufferBatch.data, spr.body)
	if character.eyes then
		tilesets.eyes = "LPC/body/"..character.gender.."/eyes/"..character.eyes
		spr.eyes = buffer.newSprite(images.load(tilesets.eyes), images.quads.data[tilesets.body][131], x, y+radius, z, r, sx, sy, ox, oy)
		table.insert(bufferBatch.data, spr.eyes)
	end
	-- Hair
	if character.hair then
		if character.haircolor then
			tilesets.hair = "LPC/hair/"..character.gender.."/"..character.hair.."/"..character.haircolor
			spr.hair = buffer.newSprite(images.load(tilesets.hair), images.quads.data[tilesets.body][131], x, y+radius, z, r, sx, sy, ox, oy)
			table.insert(bufferBatch.data, spr.hair)
		else
			tilesets.hair = "LPC/hair/"..character.gender.."/"..character.hair
			spr.hair = buffer.newSprite(images.load(tilesets.hair), images.quads.data[tilesets.body][131], x, y+radius, z, r, sx, sy, ox, oy)
			table.insert(bufferBatch.data, spr.hair)
		end
	end
	-- Torso
	if character.gender == "male" and character.body ~= "skeleton" then
		tilesets.torso = "LPC/torso/white_shirt_male"
		spr.torso = buffer.newSprite(images.load(tilesets.torso), images.quads.data[tilesets.body][131], x, y+radius, z, r, sx, sy, ox, oy)
		table.insert(bufferBatch.data, spr.torso)
	elseif character.gender == "female" then
		tilesets.torso = "LPC/torso/pirate_shirt_female"
		spr.torso = buffer.newSprite(images.load(tilesets.torso), images.quads.data[tilesets.body][131], x, y+radius, z, r, sx, sy, ox, oy)
		table.insert(bufferBatch.data, spr.torso)
	end
	-- Legs
	if character.gender == "male" and character.body ~= "skeleton" then
		tilesets.legs = "LPC/legs/green_pants_male"
		spr.legs = buffer.newSprite(images.load(tilesets.legs), images.quads.data[tilesets.body][131], x, y+radius, z, r, sx, sy, ox, oy)
		table.insert(bufferBatch.data, spr.legs)
	elseif character.gender == "female" then
		tilesets.legs = "LPC/legs/green_pants_female"
		spr.legs = buffer.newSprite(images.load(tilesets.legs), images.quads.data[tilesets.body][131], x, y+radius, z, r, sx, sy, ox, oy)
		table.insert(bufferBatch.data, spr.legs)
	end
	-- Feet
	if character.gender == "male" and character.body ~= "skeleton" then
		tilesets.feet = "LPC/feet/brown_shoes_male"
		spr.feet = buffer.newSprite(images.load(tilesets.feet), images.quads.data[tilesets.body][131], x, y+radius, z, r, sx, sy, ox, oy)
		table.insert(bufferBatch.data, spr.feet)
	elseif character.gender == "female" then
		tilesets.feet = "LPC/feet/brown_shoes_female"
		spr.feet = buffer.newSprite(images.load(tilesets.feet), images.quads.data[tilesets.body][131], x, y+radius, z, r, sx, sy, ox, oy)
		table.insert(bufferBatch.data, spr.feet)
	end
	--love.graphics.setCanvas()

	--images.inject("123456", love.graphics.newImage(canvas:getImageData()))
	-- local image = images.load("tilesets/lpcfemaletest")
	--local image = love.graphics.newImage(canvas:getImageData())

	-- Anchor variables
	local anchor = love.physics.newFixture(love.physics.newBody(physics.world, x, y-radius, "dynamic"), love.physics.newCircleShape(radius))
	anchor:setUserData(self)
	anchor:setRestitution( 0 )
	anchor:getBody():setLinearDamping( 10 )
	anchor:getBody():setFixedRotation( true )

	local hitbox = love.physics.newFixture(anchor:getBody(), love.physics.newPolygonShape(0, 0, 32, -64, 192, -96, 192, 96, 32, 64), 0)
	hitbox:setUserData(self)
	hitbox:setSensor(true)
	hitbox:setCategory(2)


	-- Monster variables
	self.monster = true
	local hp = 0.75

	local brain = yama.ai.new()
	print(brain.patrol)
	brain.setBehaviour("patrol")
	brain.patrol.set(""..math.random(1, 3).."")

	-- Standard functions
	function self.update(dt)
		brain.update(x, y)

		if brain.speed > 0 or brain.speed < 0 then
			local fx = velocity * math.cos(brain.direction) * brain.speed
			local fy = velocity * math.sin(brain.direction) * brain.speed
			anchor:getBody():applyForce(fx, fy)
		end

		-- Position updates
		x = anchor:getBody():getX()
		y = anchor:getBody():getY()
		anchor:getBody():setAngle(brain.direction)
		buffer.setBatchPosition(bufferBatch, x, y + radius)

		-- Animation updates
		animation.timescale = brain.speed
		if brain.speed > 0 then
			if animation.update(dt, "humanoid_walk_"..yama.g.getRelativeDirection(brain.direction)) then
				buffer.setBatchQuad(bufferBatch, images.quads.data[tilesets.body][animation.frame])
			end
		else
			if animation.update(dt, "humanoid_stand_"..yama.g.getRelativeDirection(brain.direction)) then
				buffer.setBatchQuad(bufferBatch, images.quads.data[tilesets.body][animation.frame])
			end
		end

	end

	function self.addToBuffer()
		buffer.add(bufferBatch)
	end

	-- Monster functions

	function self.hurt(p, dx, dy)
		hp = hp - p

		local d = math.atan2(y-dy, x-dx)
		wvx = 500 * math.cos(d)
		wvy = 500 * math.sin(d)
		anchor:getBody():setLinearVelocity(wvx, wvy)

		print("ittai!")
		if hp < 0 then
			--self.die()
		end
	end

	function self.getTeam()
		return team
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