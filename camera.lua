camera = {}

camera.sx = 1
camera.sy = 1

camera.x = 0
camera.y = 0
camera.width = canvas:getWidth() / camera.sx
camera.height = canvas:getHeight() / camera.sy

camera.boundaries = {}
camera.boundaries.x = 0
camera.boundaries.y = 0
camera.boundaries.width = 0
camera.boundaries.height = 0

camera.rotation = 0

camera.follow = nil

function camera.set()
	love.graphics.push()

	--Rotate is work in progress

	--local width = love.graphics.getWidth()
	--local height = love.graphics.getHeight()
	--love.graphics.translate(width/2, height/2)
	--love.graphics.rotate(camera.rotation)
	--love.graphics.translate(-width/2, -height/2)

	love.graphics.scale(camera.sx, camera.sy)
	love.graphics.translate(-camera.x, -camera.y)
end

function camera.unset()
	love.graphics.pop()
end

function camera.move(dx, dy)
	camera.x = camera.x + (dx or 0)
	camera.y = camera.y + (dy or 0)
end

function camera.rotate(dr)
	camera.rotation = camera.rotation + dr
end

function camera.update()
	if camera.follow then
		camera.center(camera.follow.getX(), camera.follow.getY())
	end
end

function camera.center(dx, dy)
	camera.x = math.floor( (dx - camera.width / 2) + 0.5)
	camera.y = math.floor( (dy - camera.height / 2) + 0.5)

	if camera.x < camera.boundaries.x then
		camera.x = camera.boundaries.x
	elseif camera.x > camera.boundaries.width - camera.width then
		camera.x = camera.boundaries.width - camera.width
	end

	if camera.y < camera.boundaries.y then
		camera.y = camera.boundaries.y
	elseif camera.y > camera.boundaries.height - camera.height then
		camera.y = camera.boundaries.height - camera.height
	end
end

function camera.setScale(sx, sy)
	camera.sx = sx or camera.sx
	camera.sy = sy or camera.sy
	camera.width = screen.width / camera.sx
	camera.height = screen.height / camera.sy
end

function camera.setBoundaries(x, y, width, height)
	camera.boundaries.x = x
	camera.boundaries.y = y
	camera.boundaries.width = width
	camera.boundaries.height = height
end

function camera.isInside(x, y, width, height)
	if x+width > camera.x and x < camera.x+camera.width and y+height > camera.y and y < camera.y+camera.height then
		return true
	else
		return false
	end
end