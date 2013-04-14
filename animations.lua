animations = {}

function animations.new()
	local self = {}

	local currentanimation = nil
	local currentframe = 1
	local time = 0
	local timescale = 1

	local delay = 1
	local first = 1
	local last = 1

	function self.set(animation)
		currentanimation = animation
		delay = animations.list[animation].delay
		first = animations.list[animation].first
		last = animations.list[animation].last

		time = 0
		currentframe = animations.list[animation].first
	end

	function self.update(dt, animation)
		if animation and animation ~= currentanimation then
			self.set(animation)
		end

		time = time + dt * timescale
		if time > delay then
			time = time - delay
			currentframe = currentframe + 1

			if currentframe > last then
					currentframe = first
			elseif currentframe < first then
					currentframe = last
			end
		end
	end

	function self.getFrame()
		return currentframe
	end

	function self.setTimescale(scale)
		timescale = scale
	end

	return self
end


animations.list = {}

-- Humanoid
animations.list.humanoid_stand_left   = {delay = 0.08, first = 118, last = 118}
animations.list.humanoid_stand_right  = {delay = 0.08, first = 144, last = 144}
animations.list.humanoid_stand_up     = {delay = 0.08, first = 105, last = 105}
animations.list.humanoid_stand_down   = {delay = 0.08, first = 131, last = 131}

animations.list.humanoid_walk_left    = {delay = 0.08, first = 119, last = 126}
animations.list.humanoid_walk_right   = {delay = 0.08, first = 145, last = 152}
animations.list.humanoid_walk_up      = {delay = 0.08, first = 106, last = 113}
animations.list.humanoid_walk_down    = {delay = 0.08, first = 132, last = 139}

-- Eyeball
animations.list.eyeball_walk_left   = {delay = 0.2, first = 4, last = 6}
animations.list.eyeball_walk_right  = {delay = 0.2, first = 10, last = 12}
animations.list.eyeball_walk_up     = {delay = 0.2, first = 1, last = 3}
animations.list.eyeball_walk_down   = {delay = 0.2, first = 7, last = 9}