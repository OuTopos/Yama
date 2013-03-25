function translateDirection(r)
	if r > -0.785398163 and r < 0.785398163 then
		return "up"
	elseif r > 0.785398163 and r < 2.35619449 then
		return "right"
	elseif r > 2.35619449 and r < 3.926990817 then
		return "down"
	elseif r > 3.926990817 and r < 5.497787144 then
		return "left"
	end
end