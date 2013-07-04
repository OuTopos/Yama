entities_sprite = {}

function entities_sprite.new(x, y, z, vp)
	local self = {}

	-- Common variables
	local width, height = 32, 38
	local ox, oy = width/2, height
	local sx, sy = 1, 1
	local r = 0
	local cx, cy = x - ox + width / 2, y - oy + height / 2
	local radius = yama.g.getDistance(cx, cy, x - ox, y - oy)

	-- Movement variables
	local scale = (sx + sy) / 2
	local radius = 8 * scale
	local mass = 1
	local velocity = 10 * scale
	local direction = math.atan2(math.random(-1, 1), math.random(-1, 1))
	local move = false

	-- BUFFER BATCH
	local bufferBatch = yama.buffers.newBatch(x, y, z)

	-- ANIMATION
	local animation = yama.animations.new()
	animation.set("eyeball_walk_down")
	animation.timescale = math.random(9, 11)/10

	-- PATROL
	local patrol = yama.patrols.new()
	patrol.set("1", vp.map)
	--patrol.setLoop(false)
	--patrol.setRadius(32)

	-- SPRITE
	local tileset = "eyeball"
	images.quads.add(tileset, 32, 38)
	local sprite = yama.buffers.newSprite(images.load(tileset), images.quads.data[tileset][1], x, y+radius, z, r, sx, sy, ox, oy)
	
	table.insert(bufferBatch.data, sprite)

	-- Standard functions
	function self.update(dt)
	end

	function self.addToBuffer()
		vp.buffer.add(bufferBatch)
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