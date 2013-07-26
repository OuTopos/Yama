entities_humanoid = {}

function entities_humanoid.new(map, x, y, z)
	local public = {}
	local private = {}

	private.world = map.getWorld()

	private.type = "humanoid"

	private.userdata = {}
	private.userdata.name = "Unnamed"
	private.userdata.type = "player"
	private.userdata.properties = {}
	private.userdata.entity = public

	-- ANCHOR/POSITION/SPRITE VARIABLES
	private.radius = 10
	private.mass = 1

	private.x, private.y, private.z = x, y, z
	private.r = 0
	private.width, private.height = 64, 64
	private.sx, private.sy = 1, 1
	private.ox, private.oy = 32, 64
	private.aox, private.aoy = 0, private.radius
	private.sprite = nil

	private.scale = (private.sx + private.sy) / 2

	-- PHYSICS OBJECT
	private.anchor = love.physics.newFixture(love.physics.newBody(private.world, private.x, private.y, "dynamic"), love.physics.newCircleShape(private.radius * private.scale), private.mass)
	private.anchor:setRestitution(0)
	private.anchor:getBody():setLinearDamping(10)
	private.anchor:getBody():setFixedRotation(true)
	private.anchor:setUserData(private.userdata)


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
	local bufferBatch = yama.buffers.newBatch(private.x, private.y, private.z)
	
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
	images.quads.add(tilesets.body, private.width, private.height)
	spr.body = yama.buffers.newSprite(images.load(tilesets.body), images.quads.data[tilesets.body][131], private.x + private.aox, private.y + private.aoy, private.z, private.r, private.sx, private.sy, private.ox, private.oy)
	table.insert(bufferBatch.data, spr.body)
	if character.eyes then
		tilesets.eyes = "LPC/body/"..character.gender.."/eyes/"..character.eyes
		spr.eyes = yama.buffers.newSprite(images.load(tilesets.eyes), images.quads.data[tilesets.body][131], private.x + private.aox, private.y + private.aoy, private.z, private.r, private.sx, private.sy, private.ox, private.oy)
		table.insert(bufferBatch.data, spr.eyes)
	end
	-- Hair
	if character.hair then
		if character.haircolor then
			tilesets.hair = "LPC/hair/"..character.gender.."/"..character.hair.."/"..character.haircolor
			spr.hair = yama.buffers.newSprite(images.load(tilesets.hair), images.quads.data[tilesets.body][131], private.x + private.aox, private.y + private.aoy, private.z, private.r, private.sx, private.sy, private.ox, private.oy)
			table.insert(bufferBatch.data, spr.hair)
		else
			tilesets.hair = "LPC/hair/"..character.gender.."/"..character.hair
			spr.hair = yama.buffers.newSprite(images.load(tilesets.hair), images.quads.data[tilesets.body][131], private.x + private.aox, private.y + private.aoy, private.z, private.r, private.sx, private.sy, private.ox, private.oy)
			table.insert(bufferBatch.data, spr.hair)
		end
	end
	-- Torso
	if character.gender == "male" and character.body ~= "skeleton" then
		tilesets.torso = "LPC/torso/white_shirt_male"
		spr.torso = yama.buffers.newSprite(images.load(tilesets.torso), images.quads.data[tilesets.body][131], private.x + private.aox, private.y + private.aoy, private.z, private.r, private.sx, private.sy, private.ox, private.oy)
		table.insert(bufferBatch.data, spr.torso)
	elseif character.gender == "female" then
		tilesets.torso = "LPC/torso/pirate_shirt_female"
		spr.torso = yama.buffers.newSprite(images.load(tilesets.torso), images.quads.data[tilesets.body][131], private.x + private.aox, private.y + private.aoy, private.z, private.r, private.sx, private.sy, private.ox, private.oy)
		table.insert(bufferBatch.data, spr.torso)
	end
	-- Legs
	if character.gender == "male" and character.body ~= "skeleton" then
		tilesets.legs = "LPC/legs/green_pants_male"
		spr.legs = yama.buffers.newSprite(images.load(tilesets.legs), images.quads.data[tilesets.body][131], private.x + private.aox, private.y + private.aoy, private.z, private.r, private.sx, private.sy, private.ox, private.oy)
		table.insert(bufferBatch.data, spr.legs)
	elseif character.gender == "female" then
		tilesets.legs = "LPC/legs/green_pants_female"
		spr.legs = yama.buffers.newSprite(images.load(tilesets.legs), images.quads.data[tilesets.body][131], private.x + private.aox, private.y + private.aoy, private.z, private.r, private.sx, private.sy, private.ox, private.oy)
		table.insert(bufferBatch.data, spr.legs)
	end
	-- Feet
	if character.gender == "male" and character.body ~= "skeleton" then
		tilesets.feet = "LPC/feet/brown_shoes_male"
		spr.feet = yama.buffers.newSprite(images.load(tilesets.feet), images.quads.data[tilesets.body][131], private.x + private.aox, private.y + private.aoy, private.z, private.r, private.sx, private.sy, private.ox, private.oy)
		table.insert(bufferBatch.data, spr.feet)
	elseif character.gender == "female" then
		tilesets.feet = "LPC/feet/brown_shoes_female"
		spr.feet = yama.buffers.newSprite(images.load(tilesets.feet), images.quads.data[tilesets.body][131], private.x + private.aox, private.y + private.aoy, private.z, private.r, private.sx, private.sy, private.ox, private.oy)
		table.insert(bufferBatch.data, spr.feet)
	end


	-- Monster variables
	public.monster = true
	local hp = 0.75

	local brain = yama.ai.new()
	brain.setBehaviour("patrol")
	brain.patrol.set(""..math.random(1, 3).."", map)

	-- Standard functions
	function public.update(dt)
		brain.update(private.x, private.y)

		if brain.speed > 0 or brain.speed < 0 then
			local fx = velocity * math.cos(brain.direction) * brain.speed
			local fy = velocity * math.sin(brain.direction) * brain.speed
			private.anchor:getBody():applyForce(fx, fy)
		end

		-- Position updates
		private.x = private.anchor:getBody():getX()
		private.y = private.anchor:getBody():getY()
		private.anchor:getBody():setAngle(brain.direction)
		yama.buffers.setBatchPosition(bufferBatch, private.x + private.aox, private.y + private.aoy)

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
	end

	function public.addToBuffer(vp)
		vp.getBuffer().add(bufferBatch)
	end

	-- Monster functions

	function public.hurt(p, dx, dy)
		hp = hp - p

		local d = math.atan2(y-dy, x-dx)
		wvx = 500 * math.cos(d)
		wvy = 500 * math.sin(d)
		private.anchor:getBody():setLinearVelocity(wvx, wvy)

		print("ittai!")
		if hp < 0 then
			--public.die()
		end
	end

	function public.getTeam()
		return team
	end

	function public.setName(name)
		private.name = name
	end
	function public.setProperties(properties)
		private.properties = properties
	end
	function public.getName()
		return private.name
	end
	function public.getType()
		return private.type
	end
	function public.getProperties()
		return private.name
	end

	function public.destroy()
		private.anchor:getBody():destroy()
		public.destroyed = true
	end

	-- GET
	function public.getType()
		return private.type
	end
	function public.getPosition()
		return private.x, private.y, private.z
	end
	function public.getBoundingBox()
		local x = private.x - (private.ox - private.aox) * private.sx
		local y = private.y - (private.oy - private.aoy) * private.sy
		local width = private.width * private.sx
		local height = private.height * private.sy

		return x, y, width, height
	end
	function public.getBoundingCircle()
		local x, y, width, height = public.getBoundingBox()
		local cx, cy = x + width / 2, y + height / 2
		local radius = yama.g.getDistance(x, y, cx, cy)

		return cx, cy, radius
	end

	return public
end