local gui = {}
gui.enabled = true

function gui.load()
	imagefont2 = love.graphics.newImage("images/imagefont2.png")
	font2 = love.graphics.newImageFont(imagefont2,
	" abcdefghijklmnopqrstuvwxyz" ..
	"ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
	"123456789.,!?-+/():;%&`'*#=[]\"")

	imagefont = love.graphics.newImage("images/font.png")
	font = love.graphics.newImageFont(imagefont," abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?-+/():;%&`'*#=[]\"")
	love.graphics.setFont(font)
	
	gui.images = {}
	gui.images.hp = love.graphics.newImage("images/gui/bar_hp_mp.png")
	gui.images.test = love.graphics.newImage("images/gui/confirm_bg.png")
end
function gui.draw()
	if gui.enabled then
		love.graphics.draw(gui.images.hp, yama.camera.x + 2,  yama.camera.y + 1)
		love.graphics.draw(gui.images.test, yama.camera.x + 2,  yama.camera.y + yama.camera.height - 66)

		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.print("FPS: "..love.timer.getFPS(), yama.camera.x + yama.camera.width - 39, yama.camera.y + 3)
		love.graphics.print("Skeleton: HELLO", yama.camera.x + 12 + 1, yama.camera.y + yama.camera.height - 55 +1)
		love.graphics.print("Princess: Aahh!", yama.camera.x + 12 + 1, yama.camera.y + yama.camera.height - 45 +1)

		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.print("FPS: "..love.timer.getFPS(), yama.camera.x + yama.camera.width - 39, yama.camera.y + 2)
		love.graphics.print("Skeleton: HELLO", yama.camera.x + 12, yama.camera.y + yama.camera.height - 55)
		love.graphics.print("Princess: Aahh!", yama.camera.x + 12, yama.camera.y + yama.camera.height - 45)

		if yama.g.paused then
			love.graphics.setColor(0, 0, 0, 234)
			love.graphics.rectangle("fill", yama.camera.x, yama.camera.y, yama.camera.width, yama.camera.height)
			love.graphics.setColor(0, 0, 0, 255)
			love.graphics.print("- PAUSE -", yama.camera.x + yama.camera.width/2 - 20, yama.camera.y + yama.camera.height/2 - 4)
			love.graphics.setColor(255, 255, 255, 255)
			love.graphics.print("- PAUSE -", yama.camera.x + yama.camera.width/2 - 21, yama.camera.y + yama.camera.height/2 - 5)
		end
	end
end

return gui