--[[
VIEWPORTS
To do:
 Make smooth camera movement. 
]]--
local viewports = {}

function viewports.new()
	local self = {}

	-- DEBUG
	self.debug = {}
	self.debug.drawcalls = 0

	-- CANVASES
	self.x = 0
	self.y = 0
	self.r = 0
	self.sx = 1
	self.sy = 1
	self.ox = 0
	self.oy = 0
	self.width, self.height = love.window.getDimensions()

	self.canvases = {}

	-- SHADERS
	self.shader = love.graphics.newShader("shader.glsl")
	self.shader_pre = love.graphics.newShader("shader_pre.glsl")
	self.shader_light = love.graphics.newShader("shader_light.glsl")
	self.shader_fog = love.graphics.newShader("shader_fog.glsl")

	-- CAMERA
	self.camera = {}
	self.camera.x = 0
	self.camera.y = 0
	self.camera.r = 0

	self.camera.width, self.camera.height = self.width, self.height

	self.camera.sx = 1
	self.camera.sy = 1

	self.camera.cx = 0
	self.camera.cy = 0
	self.camera.radius = 0

	self.camera.round = false

	self.camera.targets = {}

	self.camera.speed = 5
	self.camera.target = nil

	self.camera.vx = 0
	self.camera.vy = 0

	-- RESIZE & ZOOM
	function self.resize(width, height)
		print("KÖR EN RESIZE")
		self.width = width or love.window.getWidth()
		self.height = height or love.window.getHeight()

		self.canvases = {}
		for i = 1, 4 do
			table.insert(self.canvases, love.graphics.newCanvas(self.width, self.height))
		end
		self.shader:send("canvas_diffuse", self.canvases[1])
		self.shader:send("canvas_normal", self.canvases[2])
		self.shader:send("canvas_depth", self.canvases[3])
		self.shader:send("canvas_final", self.canvases[4])


		--self.shader_pre:send("canvas_diffuse", self.canvases[1])
		--self.shader_pre:send("canvas_normal", self.canvases[2])
		self.shader_pre:send("canvas_depth", self.canvases[3])

		self.shader_light:send("normalmap", self.canvases[2])
		self.shader_light:send("depthmap", self.canvases[3])
		self.shader_light:send("fogmap", yama.assets.loadImage("fog"))
		self.shader_light:send("ambientmap", yama.assets.loadImage("ambient"))


		--self.shader_fog:send("normalmap", self.canvases[2])
		self.shader_fog:send("depthmap", self.canvases[3])
		self.shader_fog:send("fogmap", yama.assets.loadImage("fog"))


		--self.shader_light:send("love_ScreenSize", {self.width, self.height})

		self.zoom(self.camera.sx, self.camera.sy)
	end

	function self.zoom(sx, sy)
		self.camera.sx = sx or 1
		self.camera.sy = sy or sx or 1

		self.camera.width = self.width / self.camera.sx
		self.camera.height = self.height / self.camera.sy
		self.camera.radius = yama.tools.getDistance(0, 0, self.camera.width / 2, self.camera.height / 2)
	end

	function self.follow(entity)
		if entity then
			if self.camera.target then
				self.camera.target.vp = nil
			end
			self.camera.target = entity
			entity.vp = self

			self.camera.target = entity
		else
			if self.camera.target then
				self.camera.target.vp = nil
			end

			warning("No entity specified for camera to follow.")
		end
	end

	function self.camera.move(x, y)
		local distance = yama.tools.getDistance(x, y, self.camera.cx, self.camera.cy)
		local direction = math.atan2(y-self.camera.cy, x-self.camera.cx)

		self.camera.vx = math.cos(direction)
		self.camera.vy = math.sin(direction)

		--print(self.camera.vx, distance, self.camera.vx * distance)
		self.camera.cx = self.camera.cx + self.camera.vx * distance/1000 * self.camera.speed
		self.camera.cy = self.camera.cy + self.camera.vy * distance/1000 * self.camera.speed
	end

	function self.camera.update()
		-- SET THE CX, CY or not.
		if self.camera.target then
			--self.camera.cx = self.camera.target.x -- self.camera.width / 2
			--self.camera.cy = self.camera.target.y -- self.camera.height / 2

			-- New smooth camera stuff
			--local x = self.camera.x
			--local y = self.camera.y
			--table.insert(self.camera.targets, 1, {x = x, y = y})
			--table.remove(self.camera.targets, 4)
			--self.camera.move(self.camera.target.x, self.camera.target.y)
			self.camera.cx = self.camera.target.x
			self.camera.cy = self.camera.target.y
			self.camera.z = self.camera.target.z
			--print(self.camera.z+self.camera.y)
			--self.camera.z = self.camera.target.z
		end
		-- GET X, Y from CX, XY
		self.camera.x = math.floor(self.camera.cx - self.camera.width / 2 + 0.5)
		self.camera.y = math.floor(self.camera.cy - self.camera.height / 2 + 0.5)
		
		self.boundaries.apply()

		if self.camera.round then
			self.ox = (self.camera.x - math.floor(self.camera.x + 0.5)) * self.camera.sx
			self.oy = (self.camera.y - math.floor(self.camera.y + 0.5))  * self.camera.sy
			self.camera.x = math.floor(self.camera.x + 0.5)
			self.camera.y = math.floor(self.camera.y + 0.5)
		else
			self.ox = 0
			self.oy = 0
		end
	end

	function self.translate()
		love.graphics.push()
		--love.graphics.translate(viewport.camera.width / 2 * viewport.camera.sx, viewport.camera.height / 2 * viewport.camera.sy)
 		----love.graphics.rotate(- viewport.camera.r)
		--love.graphics.translate(- viewport.camera.width / 2 * viewport.camera.sx, - viewport.camera.height / 2 * viewport.camera.sy)
		--love.graphics.scale(viewport.camera.sx, viewport.camera.sy)
		love.graphics.translate(- self.camera.x, - self.camera.y)
	end

	-- BOUNDARIES
	self.boundaries = {}
	self.boundaries.x = 0
	self.boundaries.y = 0
	self.boundaries.width = 0
	self.boundaries.height = 0

	function self.boundaries.apply()
		if not (self.boundaries.x == 0 and self.boundaries.y == 0 and self.boundaries.width == 0 and self.boundaries.height == 0) then
			if self.camera.width <= self.boundaries.width then
				if self.camera.x < self.boundaries.x then
					self.camera.x = self.boundaries.x
					self.camera.cx = self.camera.x + self.camera.width / 2
				elseif self.camera.x > self.boundaries.width - self.camera.width then
					self.camera.x = self.boundaries.width - self.camera.width
					self.camera.cx = self.camera.x + self.camera.width / 2
				end
			else
				self.camera.x = self.boundaries.x - (self.camera.width - self.boundaries.width) / 2
			end

			if self.camera.height <= self.boundaries.height then
				if self.camera.y < self.boundaries.y then
					self.camera.y = self.boundaries.y
					self.camera.cy = self.camera.y + self.camera.height / 2
				elseif self.camera.y > self.boundaries.height - self.camera.height then
					self.camera.y = self.boundaries.height - self.camera.height
					self.camera.cy = self.camera.y + self.camera.height / 2
				end
			else
				self.camera.y = self.boundaries.y - (self.camera.height - self.boundaries.height) / 2
			end
		end
	end

	-- CURSOR
	self.cursor = {}
	self.cursor.x = 0
	self.cursor.y = 0
	self.cursor.active = false

	function self.cursor.update()
		self.cursor.x = love.mouse.getX() + self.camera.x
		self.cursor.y = love.mouse.getY() + self.camera.y

		if self.cursor.x > self.x and self.cursor.x < self.width * self.sx and self.cursor.y > self.y and self.cursor.y < self.height * self.sy then
			self.cursor.active = true
		else
			self.cursor.active = false
		end
	end


	-- UPDATE
	function self.update(dt)
		self.camera.update()
		self.cursor.update()
	end

	-- BOUNDING VOLUME CHECK
	function self.isEntityInside(entity)
		if entity.boundingbox then
			if entity.boundingbox.x + entity.boundingbox.width > self.camera.x and entity.boundingbox.x < self.camera.x + self.camera.width and entity.boundingbox.y + entity.boundingbox.height > self.camera.y and entity.boundingbox.y < self.camera.y + self.camera.height then
				return true
			else
				return false
			end
		elseif entity.boundingcircle then
			if yama.tools.getDistance(self.camera.cx, self.camera.cy, entity.boundingcircle.x, entity.boundingcircle.y) < self.camera.radius + entity.boundingcircle.radius then
				return true
			else
				return false
			end
		else
			return true
		end
	end

	return self
end

return viewports