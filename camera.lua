camera = {}
camera.x = 0
camera.y = 0
camera.width = 0
camera.height = 0
camera.sx = 1
camera.sy = 1
camera.boundaries = {}
camera.boundaries.x = 0
camera.boundaries.y = 0
camera.boundaries.width = 0
camera.boundaries.height = 0
camera.round = true
camera.follow = nil

function camera.set()
	love.graphics.push()
	love.graphics.scale(camera.sx, camera.sy)
	love.graphics.translate(-camera.x, -camera.y)
end

function camera.unset()
	love.graphics.pop()
end

function camera.update(dt)
	if camera.follow then
		camera.center(camera.follow.getX(), camera.follow.getY())
	else
		local dx, dy = 0, 0
		if love.keyboard.isDown("up") then
			dy = -100 * dt
		end
		if love.keyboard.isDown("right") then
			dx = 100 * dt
		end
		if love.keyboard.isDown("down") then
			dy = 100 * dt
		end
		if love.keyboard.isDown("left") then
			dx = -100 * dt
		end
	end
	camera.boundary()
end

function camera.setPosition(x, y)
	camera.x = x
	camera.y = y
	if camera.round then
		camera.x = math.floor(camera.x + 0.5)
		camera.y = math.floor(camera.y + 0.5)
	end
end

function camera.center(x, y)
	camera.setPosition(x - camera.width / 2, y - camera.height / 2)
end

function camera.boundary()
	if camera.width <= camera.boundaries.width then
		if camera.x < camera.boundaries.x then
			camera.x = camera.boundaries.x
		elseif camera.x > camera.boundaries.width - camera.width then
			camera.x = camera.boundaries.width - camera.width
		end
	else
		camera.x = camera.boundaries.x - (camera.width - camera.boundaries.width) / 2
	end

	if camera.height <= camera.boundaries.height then
		if camera.y < camera.boundaries.y then
			camera.y = camera.boundaries.y
		elseif camera.y > camera.boundaries.height - camera.height then
			camera.y = camera.boundaries.height - camera.height
		end
	else
		camera.y = camera.boundaries.y - (camera.height - camera.boundaries.height) / 2
	end
end

function camera.setSize(width, height, sx, sy)
	camera.sx = sx or camera.sx
	camera.sy = sy or camera.sy
	camera.width = width or camera.width / camera.sx
	camera.height = height or camera.height / camera.sy
end



function camera.setScale(sx, sy)
	camera.sx = sx or camera.sx
	camera.sy = sy or camera.sy
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