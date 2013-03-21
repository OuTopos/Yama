gui = {}
gui.enabled = true

function gui.load()
	gui.images = {}
	gui.images.hp = love.graphics.newImage("images/gui/bar_hp_mp.png")
	gui.images.test = love.graphics.newImage("images/gui/confirm_bg.png")
end
function gui.draw()
	if gui.enabled then
		love.graphics.draw(gui.images.hp, camera.x + 2,  camera.y + 1)
		love.graphics.draw(gui.images.test, camera.x + 2,  camera.y + camera.height - 66)

		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.print("FPS: "..love.timer.getFPS(), camera.x + camera.width - 39, camera.y + 3)
		love.graphics.print("Skeleton: HELLO", camera.x + 12 + 1, camera.y + camera.height - 55 +1)
		love.graphics.print("Princess: Aahh!", camera.x + 12 + 1, camera.y + camera.height - 45 +1)

		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.print("FPS: "..love.timer.getFPS(), camera.x + camera.width - 39, camera.y + 2)
		love.graphics.print("Skeleton: HELLO", camera.x + 12, camera.y + camera.height - 55)
		love.graphics.print("Princess: Aahh!", camera.x + 12, camera.y + camera.height - 45)
	end
end