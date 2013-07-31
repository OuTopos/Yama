local buffers = {}

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