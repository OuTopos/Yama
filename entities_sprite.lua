entities_sprite = {}

function entities_sprite.new(x, y, z, vp)
	local public = {}

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

	-- Common variables
	private.x, private.y, private.z = x, y, object.properties.z
	private.width, private.height = vp.
	private.ox, private.oy = width/2, height
	private.sx, private.sy = 1, 1
	private.r = 0

	local private.cx, private.cy = private.x - private.ox + private.width / 2, private.y - private.oy + private.height / 2
	local private.radius = yama.g.getDistance(cx, cy, x - ox, y - oy)

	-- SPRITE
	public.tileset = "eyeball"
	images.quads.add(public.tileset, public.width, public.height)
	local public.sprite = yama.buffers.newSprite(images.load(tileset), images.quads.data[tileset][1], public.x, public.y, public.z, public.r, public.sx, public.sy, public.ox, public.oy)

	-- Standard functions
	function public.update(dt)
	end

	function public.addToBuffer()
		vp.buffer.add(sprite)
	end

	-- Common functions
	function public.getX()
		return x
	end
	function public.getY()
		return y
	end
	function public.getZ()
		return z
	end
	function public.getOX()
		return x - ox * sx
	end
	function public.getOY()
		return y - oy * sy + radius
	end
	function public.getWidth()
		return width * sx
	end
	function public.getHeight()
		return height * sy
	end
	function public.destroy()
	end

	return public
end