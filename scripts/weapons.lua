local weapon = {}

function weapon:plusTarget(center, size)
	local ret = PointList()

	local corner = center - Point(size, size)
	local p = Point(corner)

	local side = size * 2 + 1
	for i = 0, side * side do
		if Board:IsValid(p) and self.vector:isColinear(center, p) then
			ret:push_back(p)
		end

		p = p + VEC_RIGHT
		if math.abs(p.x - corner.x) == side then
			p.x = p.x - side
			p = p + VEC_DOWN
		end
	end
	
	return ret
end

return weapon