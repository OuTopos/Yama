local entities = {}

function entities.load()
	if love.filesystem.exists(P.ENTITIES) then
		local files = love.filesystem.getDirectoryItems(P.ENTITIES)
		for k, file in ipairs(files) do
			info("Loading entity #" .. k .. ": " .. file:gsub("%.lua", ""))
			entities[file:gsub("%.lua", "")] = require(P.ENTITIES .. "/" .. file:gsub("%.lua", ""))
		end
	end
end

return entities