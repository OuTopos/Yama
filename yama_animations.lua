local animations = {}

-- Animation class
function animations.new()
	local public = {}
	local private = {}

	-- Public
	public.frame = 1
	public.finished = false
	public.timescale = 1

	-- Private
	private.time = 0
	private.animation = nil

	private.delay = 1
	private.first = 1
	private.last = 1
	private.loop = true
	private.finish = false
	private.reverse = false

	-- Public Functions
	function public.set(animation, force, loop, finish, reverse)
		if not private.finish or public.finished or force then
			private.time = 0
			private.animation = animations.list[animation]

			private.delay = private.animation.delay
			private.first = private.animation.first
			private.last = private.animation.last
			private.loop = loop or private.animation.loop
			private.finish = finish or private.animation.finish
			private.reverse = reverse or private.animation.reverse

			public.frame = private.first
			public.finished = false
		end
	end

	function public.update(dt, animation)
		if animation and animations.list[animation] ~= private.animation then
			public.set(animation)
		end
		
		private.time = private.time + dt * public.timescale

		if private.time > private.delay then
			private.time = private.time - private.delay
			
			if private.reverse then
				public.frame = public.frame - 1

				if public.frame < private.first and private.loop then
					public.frame = private.last
					public.finished = true
				elseif public.frame < private.first then
					public.frame = private.first
					public.finished = true
				elseif public.frame > private.last then
					public.frame = private.last
					public.finished = true
				end
				return true
			else
				public.frame = public.frame + 1

				if public.frame > private.last and private.loop then
					public.frame = private.first
					public.finished = true
				elseif public.frame > private.last then
					public.frame = private.last
					public.finished = true
				elseif public.frame < private.first then
					public.frame = private.first
					public.finished = true
				end
				return true

			end
		end

		return false
	end

	function public.getFrame()
		print("WARNING: Don't use getFrame() on animations!")
		return public.frame
	end

	function public.setTimescale(scale)
		print("WARNING: Don't use setTimescale() on animations!")
		public.timescale = scale
	end

	return public
end

-- List of all the animations
animations.list = {}

-- Humanoid
animations.list.humanoid_stand_left   = {delay = 0.08, first = 118, last = 118, loop = true, finish = false, reverse = false}
animations.list.humanoid_stand_right  = {delay = 0.08, first = 144, last = 144, loop = true, finish = false, reverse = false}
animations.list.humanoid_stand_up     = {delay = 0.08, first = 105, last = 105, loop = true, finish = false, reverse = false}
animations.list.humanoid_stand_down   = {delay = 0.08, first = 131, last = 131, loop = true, finish = false, reverse = false}

animations.list.humanoid_walk_left    = {delay = 0.08, first = 119, last = 126, loop = true, finish = false, reverse = false}
animations.list.humanoid_walk_right   = {delay = 0.08, first = 145, last = 152, loop = true, finish = false, reverse = false}
animations.list.humanoid_walk_up      = {delay = 0.08, first = 106, last = 113, loop = true, finish = false, reverse = false}
animations.list.humanoid_walk_down    = {delay = 0.08, first = 132, last = 139, loop = true, finish = false, reverse = false}

animations.list.humanoid_sword_left    = {delay = 0.04, first = 171, last = 175, loop = false, finish = true, reverse = false}
animations.list.humanoid_sword_right   = {delay = 0.04, first = 197, last = 201, loop = false, finish = true, reverse = false}
animations.list.humanoid_sword_up      = {delay = 0.04, first = 158, last = 162, loop = false, finish = true, reverse = false}
animations.list.humanoid_sword_down    = {delay = 0.04, first = 184, last = 188, loop = false, finish = true, reverse = false}


animations.list.humanoid_die          = {delay = 0.08, first = 261, last = 266, loop = false, finish = true, reverse = false}

-- Eyeball
animations.list.eyeball_walk_left   = {delay = 0.2, first = 4, last = 6, loop = true, finish = false, reverse = false}
animations.list.eyeball_walk_right  = {delay = 0.2, first = 10, last = 12, loop = true, finish = false, reverse = false}
animations.list.eyeball_walk_up     = {delay = 0.2, first = 1, last = 3, loop = true, finish = false, reverse = false}
animations.list.eyeball_walk_down   = {delay = 0.2, first = 7, last = 9, loop = true, finish = false, reverse = false}

return animations