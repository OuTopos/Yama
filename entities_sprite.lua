entities_sprite = {}

function entities_sprite.new(map, x, y, z)
	local public = {}
	local private = {}

	private.name = "Unnamed"
	private.type = "sprite"
	private.properties = {}

	-- SPRITE VARIABLES
	private.x, private.y, private.z = x, y, z
	private.r = 0
	private.width, private.height = 0, 0
	private.sx, private.sy = 1, 1
	private.ox, private.oy = 0, 0
	private.oex, private.oey = 0, 0

	private.sprite = nil

	function public.setGID(gid)
		if gid then
			local tileset = map.getTileset(gid)
			local imagename = string.match(tileset.image, "../../images/(.*).png")
			local image = images.load(imagename)
			local quad = images.quads.data[imagename][gid-tileset.firstgid+1]

			--private.y = private.y - tileset.tileheight
			private.width, private.height = tileset.tilewidth, tileset.tileheight
			private.oy = tileset.tileheight

			private.sprite = yama.buffers.newSprite(image, quad, private.x, private.y, private.z, private.r, private.sx, private.sy, private.ox, private.oy)
		end
	end

	-- DEFAULT FUNCTIONS
	function public.update(dt)
	end

	function public.addToBuffer(vp)
		if private.sprite then
			vp.getBuffer().add(private.sprite)
		end
	end

	function public.destroy()
		self.destroyed = true
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
	function public.getX()
		return private.x
	end
	function public.getY()
		return private.y
	end
	function public.getZ()
		return private.z
	end
	function public.getOX()
		return private.x - private.ox * private.sx
	end
	function public.getOY()
		return private.y - private.oy * private.sy
	end
	function public.getWidth()
		return private.width * private.sx
	end
	function public.getHeight()
		return private.height * private.sy
	end
	function public.getCX()
		return private.x - private.ox + private.width / 2
	end
	function public.getCY()
		return private.y - private.oy + private.height / 2
	end
	function public.getRadius()
		return yama.g.getDistance(public.getCX(), public.getCY(), private.x - private.ox * private.sx, private.y - private.oy * private.sy)
	end

	public.setGID(public.gid)

	return public
end