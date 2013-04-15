images = {}
images.data = {}


function images.load(name)
	if not images.data[name] then
		images.data[name] = love.graphics.newImage("images/"..name..".png")
	end
	return images.data[name]
end

function images.inject(name, imagedata)
	if name and imagedata then
		images.data[name] = imagedata
	end
end

function images.unload(name)
	table.remove(images.data, name)
end

images.quads = {}
images.quads.data = {}

function images.quads.add(name, gx, gy, image)
	if not images.quads.data[name] then
		local image = image or images.load(name)
		local width = image:getWidth()
		local height = image:getHeight()
		local quads = {}
		local i = 0
		for y=0, math.floor(height/gy)-1 do
			for x=0, math.floor(width/gx)-1 do
				i = i + 1
				quads[i] = love.graphics.newQuad(x*gx, y*gy, gx, gy, width, height)
			end
		end
		images.quads.data[name] = quads
	end
end

function images.quads.generate(image, gx, gy)
	if not images.quads.data[name] then
		local width = image:getWidth()
		local height = image:getHeight()
		local quads = {}
		local i = 0
		for y=0, math.floor(height/gy)-1 do
			for x=0, math.floor(width/gx)-1 do
				i = i + 1
				quads[i] = love.graphics.newQuad(x*gx, y*gy, gx, gy, width, height)
			end
		end
		return quads
	end
end