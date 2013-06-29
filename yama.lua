local yama = {}

yama.screen         = require("yama_screen")
yama.buffers      	= require("yama_buffers")
yama.cameras        = require("yama_cameras")
yama.viewports      = require("yama_viewports")
yama.gui            = require("yama_gui")
yama.hud            = require("yama_hud")
yama.animations     = require("yama_animations")
yama.ai             = require("yama_ai")
yama.ai.patrols     = require("yama_ai_patrols")
yama.patrols        = require("yama_patrols")
yama.map            = require("yama_map")

yama.input          = require("yama_input")
yama.joystick       = require("yama_joystick")

yama.g              = require("yama_g")

return yama