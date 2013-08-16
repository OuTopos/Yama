entities_sprite = {}

function entities_sprite.new(map, x, y, z)
	local self = {}

	self.type = "sprite"

	self.x, self.y, self.z = x, y, z
	self.r = 0
	self.width, self.height = 0, 0
	self.sx, self.sy = 1, 1
	self.ox, self.oy = 0, 0
	self.aox, self.aoy = 0, 0

	self.boundingbox = {}

	-- LOCAL VARIABLES
	local sprite = nil


	-- DEFAULT FUNCTIONS
	function self.initialize(parameters)
		if parameters.gid then
			-- Get the sprite, width and height from the gid.
			sprite, self.width, self.height = map.getSprite(parameters.gid, self.x, self.y, self.z, true)
			-- Set the scale and offset from the sprite.
			self.sx, self.sy = sprite.sx, sprite.sy
			self.ox, self.oy = sprite.ox, sprite.oy
			-- Update the bounding box.
			self.updateBoundingBox()
		else
			print("[Entity_Sprite] Destroying myself because there was no gid in the parameters. Wasn't that stupid?")
			self.destroy()
		end
	end

	function self.update(dt)
	end

	function self.updateBoundingBox()
		self.boundingbox.x = self.x - (self.ox - self.aox) * self.sx
		self.boundingbox.y = self.y - (self.oy - self.aoy) * self.sy
		self.boundingbox.width = self.width * self.sx
		self.boundingbox.height = self.height * self.sy
	end

	function self.addToBuffer(vp)
		if sprite then
			vp.addToBuffer(sprite)
		end
	end

	function self.destroy()
		self.destroyed = true
	end

	return self
end