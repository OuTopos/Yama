local entities = {}

entities.base = require("entitiesBase")
-- Entity types
require("entities_sprite")
require("entities_player")
require("entities_fplayer")
require("entities_pplayer")
require("entities_tree")
require("entities_coin")
require("entities_turret")
require("entities_ball")
require("entities_projectile")
require("entities_monster")
require("entities_humanoid")
require("entities_mplayer")
require("entities_bullet")

function entities.new(map, type, x, y, z)
	local entity = _G["entities_"..type].new(map, x, y, z)
	return entity
end

return entities