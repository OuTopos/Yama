local base = {}

function base.new()
	local self = {}

	self.x = 0
	self.y = 0
	self.z = 0

	self.boundingbox = {}
	self.boundingbox.x = 0
	self.boundingbox.y = 0
	self.boundingbox.width = 0
	self.boundingbox.height = 0
	return self
end

return base