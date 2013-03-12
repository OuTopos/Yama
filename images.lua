images = {}
images.data = {}


function images.load(name)
	if not images.data[name] then
		images.data[name] = love.graphics.newImage("images/"..name..".png")
	end
	return images.data[name]
end

function images.unload(name)
	table.remove(images.data, name)
end

images.quads = {}
images.quads.data = {}

function images.quads.add(name, gx, gy)
	if not images.quads.data[name] then
		--local image = images.load(name)
		local width = images.load(name):getWidth()
		local height = images.load(name):getHeight()
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