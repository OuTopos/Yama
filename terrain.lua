terrain = {}

local grass = love.graphics.newImage( "images/grass.png" )
grass:setWrap("repeat", "repeat")
local grassquad = love.graphics.newQuad(0, 0, worldWidth, worldHeight, 64, 64)

function terrain.draw()

	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.drawq(grass, grassquad, 0, 0)
end