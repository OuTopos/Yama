entities_sprite = {}

function entities_sprite.new(map, x, y, z)
	local public = {}
	local private = {}

	private.type = "sprite"

	-- SPRITE VARIABLES
	private.x, private.y, private.z = x, y, z
	private.r = 0
	private.width, private.height = 0, 0
	private.sx, private.sy = 1, 1
	private.ox, private.oy = 0, 0
	private.aox, private.aoy = 0, 0

	private.sprite = nil

	-- DEFAULT FUNCTIONS
	function public.initialize(object)
		if object.gid then
			local tileset = map.getTileset(object.gid)
			local imagename = string.match(tileset.image, "../../images/(.*).png")
			local image = images.load(imagename)
			local quad = images.quads.data[imagename][object.gid-tileset.firstgid+1]

			private.width, private.height = tileset.tilewidth, tileset.tileheight
			private.oy = tileset.tileheight

			private.sprite = yama.buffers.newSprite(image, quad, private.x, private.y, private.z, private.r, private.sx, private.sy, private.ox, private.oy)
		else
			print("Sprite destroying itself because the object from the map wasn't a sprite. Wasn't that stupid?")
			public.destroy()
		end
	end

	function public.update(dt)
	end

	function public.addToBuffer(vp)
		if private.sprite then
			vp.addToBuffer(private.sprite)
		end
	end

	function public.destroy()
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