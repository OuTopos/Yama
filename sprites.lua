spritesheets = {}
spritesheets.data = {}

function spritesheets.add(imagePath, gx, gy, auto)
	if not spritesheets.data[imagePath] then
		local image = love.graphics.newImage( "images/"..imagePath..".png" )
		local width = image:getWidth()
		local height = image:getHeight()
		local quads = {}

		auto = auto or true
		if auto then
			local i = 0
			for y=0, math.floor(height/gy)-1 do
				for x=0, math.floor(width/gx)-1 do
					i = i + 1
					quads[i] = love.graphics.newQuad(x*gx, y*gy, gx, gy, width, height)
				end
			end
		end

		spritesheets.data[imagePath] = {}
		spritesheets.data[imagePath].image = image
		spritesheets.data[imagePath].quads = quads
	end
end


sprites = {}

function sprites.draw(sprite)
	love.graphics.drawq(spritesheets.data[sprite.sheet], sprite.quad, sprite.x, sprite.y, sprite.r, sprite.sx, sprite.sy, sprite.ox, sprite.oy)
end

function sprites.new(sheet, quad, x, y, ox, oy, sx, sy, r)
	local sprite = {}
	sprite.sheet = sheet
	sprite.quad = quad
	sprite.x = x
	sprite.y = y
	sprite.ox = ox or 0
	sprite.oy = oy or 0
	sprite.sx = sx or 1
	sprite.sy = sy or 1
	sprite.r = r or 0
	return sprite
end