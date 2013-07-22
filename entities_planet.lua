entities_planet = {}

function entities_planet.new(map, x, y, z)
	local public = {}
	local private = {}

	private.name = "Unnamed"
	private.type = "planet"
	private.properties = {}

	-- SPRITE VARIABLES
	private.x, private.y, private.z = x, y, 10000
	private.r = 0
	private.width, private.height = 1000, 1000
	private.sx, private.sy = 1, 1
	private.ox, private.oy = 500, 500
	private.oex, private.oey = 0, 0

	function public.initialize(object)
		private.anchor = map.createFixture(object, "static")
		private.sx, private.sy = object.width / private.width, object.height / private.height
		print(private.sx)
		private.x = object.x + object.width / 2
		private.y = object.y + object.height / 2

		local image = images.load("planet")
		image:setFilter("linear", "linear")
		images.quads.add("planet", private.width, private.height)
		local quad = images.quads.data["planet"][1]

		private.sprite = yama.buffers.newSprite(image, quad, private.x, private.y, private.z, private.r, private.sx, private.sy, private.ox, private.oy)

	end

	-- GRAVITY PULL
	



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

	return public
end