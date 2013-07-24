local yama = {}

yama.c              = require("yama_c")
yama.screen         = require("yama_screen")
yama.cameras        = require("yama_cameras")
yama.buffers      	= require("yama_buffers")
yama.entities       = require("yama_entities")
yama.viewports      = require("yama_viewports")
yama.maps           = require("yama_maps")
yama.gui            = require("yama_gui")
yama.hud            = require("yama_hud")
yama.animations     = require("yama_animations")
yama.ai             = require("yama_ai")
yama.ai.patrols     = require("yama_ai_patrols")
yama.patrols        = require("yama_patrols")
yama.input          = require("yama_input")
yama.joystick       = require("yama_joystick")

yama.g              = require("yama_g")


function yama.distance(x1, y1, x2, y2)
	return g.sqrt((x1-x2)^2+(y1-y2)^2)
end

return yama