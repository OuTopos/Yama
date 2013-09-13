entities_humanoid = {}

function entities_humanoid.new(map, x, y, z)
	local self = {}
	self.boundingbox = {}

	self.type = "humanoid"

	self.userdata = {}
	self.userdata.name = "Unnamed"
	self.userdata.type = "player"
	self.userdata.properties = {}
	self.userdata.entity = self

	-- ANCHOR/POSITION/SPRITE VARIABLES
	self.radius = 10
	self.mass = 1

	self.x, self.y, self.z = x, y, z
	self.r = 0
	self.width, self.height = 64, 64
	self.sx, self.sy = 1, 1
	self.ox, self.oy = 32, 64
	self.aox, self.aoy = 0, self.radius
	self.sprite = nil

	self.scale = (self.sx + self.sy) / 2

	-- PHYSICS OBJECT
	self.anchor = love.physics.newFixture(love.physics.newBody(map.world, self.x, self.y, "dynamic"), love.physics.newCircleShape(self.radius * self.scale), self.mass)
	self.anchor:setRestitution(0)
	self.anchor:getBody():setLinearDamping(10)
	self.anchor:getBody():setFixedRotation(true)
	self.anchor:setUserData(self.userdata)


	-- Movement variables
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
	local bufferBatch = yama.buffers.newBatch(self.x, self.y, self.z)
	
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
	images.quads.add(tilesets.body, self.width, self.height)
	spr.body = yama.buffers.newSprite(images.load(tilesets.body), images.quads.data[tilesets.body][131], self.x + self.aox, self.y + self.aoy, self.z, self.r, self.sx, self.sy, self.ox, self.oy)
	table.insert(bufferBatch.data, spr.body)
	if character.eyes then
		tilesets.eyes = "LPC/body/"..character.gender.."/eyes/"..character.eyes
		spr.eyes = yama.buffers.newSprite(images.load(tilesets.eyes), images.quads.data[tilesets.body][131], self.x + self.aox, self.y + self.aoy, self.z, self.r, self.sx, self.sy, self.ox, self.oy)
		table.insert(bufferBatch.data, spr.eyes)
	end
	-- Hair
	if character.hair then
		if character.haircolor then
			tilesets.hair = "LPC/hair/"..character.gender.."/"..character.hair.."/"..character.haircolor
			spr.hair = yama.buffers.newSprite(images.load(tilesets.hair), images.quads.data[tilesets.body][131], self.x + self.aox, self.y + self.aoy, self.z, self.r, self.sx, self.sy, self.ox, self.oy)
			table.insert(bufferBatch.data, spr.hair)
		else
			tilesets.hair = "LPC/hair/"..character.gender.."/"..character.hair
			spr.hair = yama.buffers.newSprite(images.load(tilesets.hair), images.quads.data[tilesets.body][131], self.x + self.aox, self.y + self.aoy, self.z, self.r, self.sx, self.sy, self.ox, self.oy)
			table.insert(bufferBatch.data, spr.hair)
		end
	end
	-- Torso
	if character.gender == "male" and character.body ~= "skeleton" then
		tilesets.torso = "LPC/torso/white_shirt_male"
		spr.torso = yama.buffers.newSprite(images.load(tilesets.torso), images.quads.data[tilesets.body][131], self.x + self.aox, self.y + self.aoy, self.z, self.r, self.sx, self.sy, self.ox, self.oy)
		table.insert(bufferBatch.data, spr.torso)
	elseif character.gender == "female" then
		tilesets.torso = "LPC/torso/pirate_shirt_female"
		spr.torso = yama.buffers.newSprite(images.load(tilesets.torso), images.quads.data[tilesets.body][131], self.x + self.aox, self.y + self.aoy, self.z, self.r, self.sx, self.sy, self.ox, self.oy)
		table.insert(bufferBatch.data, spr.torso)
	end
	-- Legs
	if character.gender == "male" and character.body ~= "skeleton" then
		tilesets.legs = "LPC/legs/green_pants_male"
		spr.legs = yama.buffers.newSprite(images.load(tilesets.legs), images.quads.data[tilesets.body][131], self.x + self.aox, self.y + self.aoy, self.z, self.r, self.sx, self.sy, self.ox, self.oy)
		table.insert(bufferBatch.data, spr.legs)
	elseif character.gender == "female" then
		tilesets.legs = "LPC/legs/green_pants_female"
		spr.legs = yama.buffers.newSprite(images.load(tilesets.legs), images.quads.data[tilesets.body][131], self.x + self.aox, self.y + self.aoy, self.z, self.r, self.sx, self.sy, self.ox, self.oy)
		table.insert(bufferBatch.data, spr.legs)
	end
	-- Feet
	if character.gender == "male" and character.body ~= "skeleton" then
		tilesets.feet = "LPC/feet/brown_shoes_male"
		spr.feet = yama.buffers.newSprite(images.load(tilesets.feet), images.quads.data[tilesets.body][131], self.x + self.aox, self.y + self.aoy, self.z, self.r, self.sx, self.sy, self.ox, self.oy)
		table.insert(bufferBatch.data, spr.feet)
	elseif character.gender == "female" then
		tilesets.feet = "LPC/feet/brown_shoes_female"
		spr.feet = yama.buffers.newSprite(images.load(tilesets.feet), images.quads.data[tilesets.body][131], self.x + self.aox, self.y + self.aoy, self.z, self.r, self.sx, self.sy, self.ox, self.oy)
		table.insert(bufferBatch.data, spr.feet)
	end


	-- Monster variables
	self.monster = true
	local hp = 0.75

	local brain = yama.ai.new()
	brain.setBehaviour("patrol")
	brain.patrol.set(""..math.random(1, 3).."", map)

	-- Standard functions
	function self.update(dt)
		brain.update(self.x, self.y)

		if brain.speed > 0 or brain.speed < 0 then
			local fx = velocity * math.cos(brain.direction) * brain.speed
			local fy = velocity * math.sin(brain.direction) * brain.speed
			self.anchor:getBody():applyForce(fx, fy)
		end

		-- Position updates
		self.x = self.anchor:getBody():getX()
		self.y = self.anchor:getBody():getY()
		self.anchor:getBody():setAngle(brain.direction)
		yama.buffers.setBatchPosition(bufferBatch, self.x + self.aox, self.y + self.aoy)

		-- Animation updates
		animation.timescale = brain.speed
		if brain.speed > 0 then
			if animation.update(dt, "humanoid_walk_"..yama.g.getRelativeDirection(brain.direction)) then
				yama.buffers.setBatchQuad(bufferBatch, images.quads.data[tilesets.body][animation.frame])
			end
		else
			if animation.update(dt, "humanoid_stand_"..yama.g.getRelativeDirection(brain.direction)) then
				yama.buffers.setBatchQuad(bufferBatch, images.quads.data[tilesets.body][animation.frame])
			end
		end

		self.setBoundingBox()
	end

	function self.addToBuffer(vp)
		vp.addToBuffer(bufferBatch)
	end

	-- Monster functions

	function self.hurt(p, dx, dy)
		hp = hp - p

		local d = math.atan2(y-dy, x-dx)
		wvx = 500 * math.cos(d)
		wvy = 500 * math.sin(d)
		self.anchor:getBody():setLinearVelocity(wvx, wvy)

		print("ittai!")
		if hp < 0 then
			--self.die()
		end
	end

	function self.getTeam()
		return team
	end
	--[[
	function self.setName(name)
		self.name = name
	end
	function self.setProperties(properties)
		self.properties = properties
	end
	function self.getName()
		return self.name
	end
	function self.getType()
		return self.type
	end
	function self.getProperties()
		return self.name
	end
	--]]

	function self.destroy()
		self.anchor:getBody():destroy()
		self.destroyed = true
	end

	-- GET
	--function self.getType()
	--	return self.type
	--end
	--function self.getPosition()
	--	return self.x, self.y, self.z
	--end
	function self.setBoundingBox()
		self.boundingbox.x = self.x - (self.ox - self.aox) * self.sx
		self.boundingbox.y = self.y - (self.oy - self.aoy) * self.sy
		self.boundingbox.width = self.width * self.sx
		self.boundingbox.height = self.height * self.sy
	end
	self.setBoundingBox()
	--function self.getBoundingCircle()
	--	local x, y, width, height = self.getBoundingBox()
	--	local cx, cy = x + width / 2, y + height / 2
	--	local radius = yama.g.getDistance(x, y, cx, cy)

	--	return cx, cy, radius
	--end

	return self
end