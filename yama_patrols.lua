local patrols = {}

function patrols.new(loop, radius)
	local self = {}

	local patrol = nil
	local k, v = nil, nil

	local loop = loop or true
	local radius = radius or 32
	local order = nil

	function self.set(name, map)
		if map.data.patrols[name] then
			patrol = map.data.patrols[name]
			k = 0
			self.next()
		end
	end

	function self.setLoop(loop)
		loop = loop
	end

	function self.setRadius(radius)
		radius = radius
	end

	function self.update(x, y)
		if v then
			if yama.g.getDistance(x, y, v.x, v.y) < radius then
				self.next()
			end
		end
	end

	function self.next()
		if order == "random" then
			k = math.random(1, #patrol)
			v = patrol[k]
		elseif order == "reverse" then
			k = k - 1
		else
			k = k + 1
		end

		if patrol[k] then
			v = patrol[k]
		elseif loop and order == "reverse" then
			k = #patrol
			v = patrol[k]
		elseif loop then
			k = 1
			v = patrol[k]
		end
	end

	function self.getPoint()
		return v.x, v.y
	end

	function self.isActive()
		if v then
			return true
		else
			return false
		end
	end

	return self
end

return patrols