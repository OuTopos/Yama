
local ai = {}

function ai.new()
	local self = {}
	local behaviours = {attack = false, patrol = true, guard = false}

	local behaviour = {}
	behaviour.current = nil


	local goal = nil
	local direction = 0
	local speed = 0
	local aim = 0

	-- UPDATE
	function self.update(x, y)
		if behaviour.current then
			self[behaviour.current].update(x, y)
			goal = self[behaviour.current].goal
			speed = self[behaviour.current].speed
		else
			goal = nil
		end

		--if behaviours.attack then
			--self.updateAttack()
		--elseif behaviours.patrol then
		--	self.patrol.update(x, y)
		--	goal = self.patrol.goal
		--	speed = self.patrol.speed
		--elseif behaviours.guard then
			--self.updateGuard()
		--end

		if goal then
			direction = math.atan2(goal[2]-y, goal[1]-x)
			speed = 1
		end
	end

	-- BEHAVRIOURS


	-- BEHAVIOUR: PATROL
	--dofile("yama_ai_patrol.lua")
	self.patrol = yama.ai.patrol.new()

function self.patrol.getPoint()
	return self.patrol.v.x, self.patrol.v.y
end

function self.patrol.isActive()
	if self.patrol.v then
		return truepatrol
	else
		return false
	end
end
	

	-- INPUT
	function self.setBehaviour(aBehaviour)
		if self[aBehaviour] then
			behaviour.current = aBehaviour
		end
	end

	-- OUTPUT
	function self.getDirection()
		return direction
	end
	function self.getSpeed()
		return speed
	end

	return self
end

return ai