local patrol = {}

patrol.current = nil

patrol.k, patrol.v = nil, nil
patrol.loop = true
patrol.radius = 32
patrol.order = nil

patrol.goal = nil
patrol.speed = 0

function patrol.set(name)
	if yama.map.loaded.patrols[name] then
		patrol.current = yama.map.loaded.patrols[name]
		patrol.k = 0
		patrol.next()
	end
end

function patrol.setLoop(loop)
	patrol.loop = loop
end

function patrol.setRadius(radius)
	patrol.radius = radius
end

function patrol.update(x, y)
	if patrol.v then
		if yama.g.getDistance(x, y, patrol.v.x, patrol.v.y) < patrol.radius then
			patrol.next()
		end

		if patrol.v then
			patrol.goal = {patrol.v.x, patrol.v.y}
			patrol.speed = 1
		else
			patrol.goal = nil
			patrol.speed = 0
		end
	end
end

function patrol.next()
	if patrol.order == "random" then
		patrol.k = math.random(1, #patrol.current)
		patrol.v = patrol.current[patrol.k]
	elseif patrol.order == "reverse" then
		patrol.k = patrol.k - 1
	else
		patrol.k = patrol.k + 1
	end

	if patrol.current[patrol.k] then
		patrol.v = patrol.current[patrol.k]
	elseif patrol.loop and patrol.order == "reverse" then
		patrol.k = #patrol.current
		patrol.v = patrol.current[patrol.k]
	elseif patrol.loop then
		patrol.k = 1
		patrol.v = patrol.current[patrol.k]
	else
		patrol.v = nil

	end
end

function patrol.getPoint()
	return patrol.v.x, patrol.v.y
end

function patrol.isActive()
	if patrol.v then
		return true
	else
		return false
	end
end

return patrol