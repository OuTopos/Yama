local buffers = {}

function buffers.new()
	local public = {}
	local private = {}

	public.enabled = true
	public.data = {}
	public.sortmode = 1
	public.debug = {}
	public.debug.drawcalls = 0
	public.debug.redraws = 0
	public.debug.redraws = 0

	function public.reset()
		public.data = {}
		public.debug.redraws = 0
	end

	function public.add(object)
		table.insert(public.data, object)
	end

	function public.draw()
		public.debug.redraws = public.debug.redraws + 1
		public.debug.drawcalls = 0
		public.length = 0

		if public.enabled then
			public.length = #public.data
			public.sort()
			for i = 1, public.length do
				if public.data[i].type == "batch" then
					public.drawBatch(public.data[i])
				else
					public.drawObject(public.data[i])
				end
			end
		end
	end

	function public.drawBatch(batch)
		for i = 1, #batch.data do
			public.drawObject(batch.data[i])
		end
	end

	function public.drawObject(object)
		-- SET COLOR, COLORMODE, BLENDMODE
		if object.color then
			love.graphics.setColor(object.color)
		end
		if object.colormode then
			love.graphics.setColorMode(object.colormode)
		end
		if object.blendmode then
			love.graphics.setBlendMode(object.blendmode)
		end

		-- ACTUAL DRAW
		if object.type == "drawable" then
			--print("Drawing:", object.drawable.type(), "x:", object.x, "y:", object.y, "r:", object.r, "sx:", object.sx, "sy:", object.sy, "ox:", object.ox, "oy:", object.oy, "kx:", object.kx, "ky:", object.ky)
			-- DRAWABLE
			love.graphics.draw(object.drawable, object.x, object.y, object.r, object.sx, object.sy, object.ox, object.oy, object.kx, object.ky)
			public.debug.drawcalls = public.debug.drawcalls + 1
		elseif object.type == "sprite" then
			-- SPRITE
			love.graphics.drawq(object.image, object.quad, object.x, object.y, object.r, object.sx, object.sy, object.ox, object.oy, object.kx, object.ky)
			public.debug.drawcalls = public.debug.drawcalls + 1
		end

		-- RESET COLOR, COLORMODE, BLENDMODE
		if object.color then
			love.graphics.setColor(255, 255, 255, 255)
		end
		if object.colormode then
			love.graphics.setColorMode("modulate")
		end
		if object.blendmode then
			love.graphics.setBlendMode("alpha")
		end
	end

	function public.sort()
		table.sort(public.data, public.sortmethod)
	end
	function public.sortmethod(a, b)
	--	if public.sortmode == 1 then
	--		if a.z < b.z then
	--			return true
	--		end
	--		return false
	--	elseif public.sortmode == 2 then
	--		if a.y < b.y then
	--			return true
	--		end
	--		return false
	--	elseif public.sortmode == 3 then
			if a.y+a.z < b.y+b.z then
				return true
			end
			if a.z == b.z then
				if a.y < b.y then
					return true
				end
				if a.y == b.y then
					if a.x < b.x then
						return true
					end
				end
			end
	--		return false
	--	end
	end

	return public
end

function buffers.newBatch(x, y, z, data)
	local object = {}
	object.type = "batch"
	object.x = x or 0
	object.y = y or 0
	object.z = z or 0
	object.data = data or {}
	return object
end

function buffers.newDrawable(drawable, x, y, z, r, sx, sy, ox, oy, kx, ky, color, colormode, blendmode)
	local object = {}
	object.type = "drawable"
	object.drawable = drawable
	object.x = x or 0
	object.y = y or 0
	object.z = z or 0
	object.r = r or 0
	object.sx = sx or 1
	object.sy = sy or sx or 1
	object.ox = ox or 0
	object.oy = oy or 0
	object.kx = kx or 0
	object.ky = ky or 0
	object.color = color or nil
	object.colormode = colormode or nil
	object.blendmode = blendmode or nil
	return object
end

function buffers.newSprite(image, quad, x, y, z, r, sx, sy, ox, oy, kx, ky, color, colormode, blendmode)
	local object = {}
	object.type = "sprite"
	object.image = image
	object.quad = quad
	object.x = x or 0
	object.y = y or 0
	object.z = z or 0
	object.r = r or 0
	object.sx = sx or 1
	object.sy = sy or sx or 1
	object.ox = ox or 0
	object.oy = oy or 0
	object.kx = kx or 0
	object.ky = ky or 0
	object.color = color or nil
	object.colormode = colormode or nil
	object.blendmode = blendmode or nil
	return object
end



function buffers.setBatchPosition(batch, x, y, z)
	batch.x = x or batch.x
	batch.y = y or batch.y 
	batch.z = z or batch.z 
	for i = 1, #batch.data do
		batch.data[i].x = batch.x
		batch.data[i].y = batch.y
		batch.data[i].z = batch.z
	end
end
function buffers.setBatchQuad(batch, quad)
	for i = 1, #batch.data do
		batch.data[i].quad = quad
	end
end

return buffers