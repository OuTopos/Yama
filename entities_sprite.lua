entities_sprite = {}

function entities_sprite.new(map, x, y, z)
	local public = {}
	local private = {}

	private.x, private.y, private.z = x, y, z
	private.r = 0
	private.width, private.height = 0, 0
	private.sx, private.sy = 1, 1
	private.ox, private.oy = 0, 0

	private.tileset = nil
	private.sprite = nil

          name = "Plant",
          type = "monster",
          shape = "rectangle",
          x = 288,
          y = 224,
          width = 0,
          height = 0,
          gid = 11,
          visible = true,
          properties = {
            ["z"] = "1"
          }

	

	-- SPRITE
	private.tileset = "eyeball"
	images.quads.add(public.tileset, public.width, public.height)
	local public.sprite = yama.buffers.newSprite(images.load(tileset), images.quads.data[tileset][1], public.x, public.y, public.z, public.r, public.sx, public.sy, public.ox, public.oy)

	-- Standard functions
	function public.update(dt)
	end

	function public.addToBuffer(vp)
		vp.buffer.add(sprite)
	end

	-- Common functions
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
		return private.x - (private.ox + private.width / 2) * private.sx
	end
	function public.getCY()
		return private.y - (private.oy + private.height / 2) * private.sx
	end
	function public.getRadius()
		return yama.g.getDistance(private.cx, private.cy, private.x - private.ox, private.y - private.oy)
	end
	
	function public.destroy()
		self.destroyed = true
	end

	return public
end