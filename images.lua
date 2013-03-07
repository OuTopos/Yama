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

function images.get(name)
	return images.data[name] or images.fetch(name)
end

function images.fetch(name)
	print("Fetching image: "..name)
	images.data[name] = love.graphics.newImage("images/"..name..".png")
	return images.data[name]
end

