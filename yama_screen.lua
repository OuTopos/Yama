local screen = {}
screen.width, screen.height, screen.fullscreen, screen.vsync, screen.fsaa = love.graphics.getMode()
screen.modes = love.graphics.getModes()

return screen