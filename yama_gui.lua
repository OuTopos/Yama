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
		love.graphics.draw(gui.images.hp, camera.x + 2,  camera.y + 1)
		--love.graphics.draw(gui.images.test, camera.x + 2,  camera.y + camera.height - 66)

		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.print("FPS: "..love.timer.getFPS(), camera.x + camera.width - 39, camera.y + 3)
		--love.graphics.print("Skeleton: HELLO", camera.x + 12 + 1, camera.y + camera.height - 55 +1)
		--love.graphics.print("Princess: Aahh!", camera.x + 12 + 1, camera.y + camera.height - 45 +1)

		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.print("FPS: "..love.timer.getFPS(), camera.x + camera.width - 39, camera.y + 2)
		--love.graphics.print("Skeleton: HELLO", camera.x + 12, camera.y + camera.height - 55)
		--love.graphics.print("Princess: Aahh!", camera.x + 12, camera.y + camera.height - 45)

		if yama.g.paused then
			love.graphics.setColor(0, 0, 0, 234)
			love.graphics.rectangle("fill", camera.x, camera.y, camera.width, camera.height)
			love.graphics.setColor(0, 0, 0, 255)
			love.graphics.print("- PAUSE -", camera.x + camera.width/2 - 20, camera.y + camera.height/2 - 4)
			love.graphics.setColor(255, 255, 255, 255)
			love.graphics.print("- PAUSE -", camera.x + camera.width/2 - 21, camera.y + camera.height/2 - 5)
		end
	end
end


function gui.newHealthBar()
	local public = {}
	local private = {}

	private.hpmax = 1000
	private.hp = 100

	private.asd = 0

	function public.draw()
		-- body
	end

	return public
end
return gui