buffer = {}
buffer.enabled = true
buffer.data = {}
buffer.sortmode = 2
buffer.counter = 0

function buffer.reset()
	buffer.data = {}
	print("Buffer reset after being drawn "..buffer.counter.." times.")
	buffer.counter = 0
end

function buffer.add(object)
	table.insert(buffer.data, object)
end

function buffer.draw()
	buffer.counter = buffer.counter + 1
	buffer.length = 0
	buffer.drawCalls = 0

	if buffer.enabled then
		buffer.length = #buffer.data
		table.sort(buffer.data, buffer.sort)
		for i = 1, buffer.length do
			if buffer.data[i].type == "batch" then
				buffer.drawBatch(buffer.data[i])
			else
				buffer.drawObject(buffer.data[i])
			end
		end
	end
end

function buffer.drawBatch(batch)
	for i = 1, #batch.data do
		buffer.drawObject(batch.data[i])
	end
end

function buffer.drawObject(object)
	if object.color then
		love.graphics.setColor(object.color)
	end

	if object.type == "drawable" then
		-- DRAWABLE
		love.graphics.draw(object.drawable, object.x, object.y, object.r, object.sx, object.sy, object.ox, object.oy, object.kx, object.ky)
		buffer.drawCalls = buffer.drawCalls + 1
	elseif object.type == "quad" then
		-- QUAD
		love.graphics.drawq(object.image, object.quad, object.x, object.y, object.r, object.sx, object.sy, object.ox, object.oy, object.kx, object.ky)
		buffer.drawCalls = buffer.drawCalls + 1
	end

	if object.color then
		love.graphics.setColor(255, 255, 255, 255)
	end
end

function buffer.sort(a, b)
	if buffer.sortmode == 1 then
		if a.y < b.y then
			return true
		end
		return false
	elseif buffer.sortmode == 2 then
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
		return false
	elseif buffer.sortmode == 3 then
		if a.z < b.z then
			return true
		end
		return false
	end
end

function buffer.newBatch(x, y, z, data)
	object = {}
	object.type = "batch"
	object.x = x or 0
	object.y = y or 0
	object.z = z or 0
	object.data = data or {}
	return object
end

function buffer.newDrawable(drawable, x, y, z, r, sx, sy, ox, oy, kx, ky, color)
	object = {}
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
	return object
end

function buffer.newQuad(image, quad, x, y, z, r, sx, sy, ox, oy, kx, ky, color)
	object = {}
	object.type = "quad"
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
	return object
end