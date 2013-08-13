local assets = {}
assets.images = {}
assets.tilesets = {}

function assets.image(name)
	if not assets.images[name] then
		assets.images[name] = love.graphics.newImage("images/"..name..".png")
	end
	return assets.images[name]
end


function assets.tileset(name, imagepath, tilewidth, tileheight, spacing, margin)
	if assets.tilesets[name] then
		return assets.tilesets[name]
	elseif imagepath and tilewidth and tileheight then
		local tileset = {}
		tileset.image = assets.image(imagepath)
		tileset.tilewidth = tilewidth
		tileset.tileheight = tileheight
		tileset.imagewidth = tileset.image:getWidth()
		tileset.imageheight = tileset.image:getHeight()
		tileset.spacing = spacing or 0
		tileset.margin = margin or 0
		tileset.tiles = {}

		local tiles = {}
		local i = 0
		for y=0, math.floor((tileset.imageheight - tileset.margin * 2 + tileset.spacing) / (tileset.tileheight + tileset.spacing)) - 1 do
			for x=0, math.floor((tileset.imagewidth - tileset.margin * 2 + tileset.spacing) / (tileset.tilewidth + tileset.spacing)) - 1 do
				i = i + 1
				tileset.tiles[i] = love.graphics.newQuad(tileset.margin + x * (tileset.tilewidth + tileset.spacing), tileset.margin + y * (tileset.tileheight + tileset.spacing), tileset.tilewidth, tileset.tileheight, tileset.imagewidth, tileset.imageheight)
			end
		end
		assets.tilesets[name] = tileset
		return assets.tilesets[name]
	else
		return nil
	end
end

return assets