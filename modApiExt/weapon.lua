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

--Returns the upgrade suffix of the weapon i.e. _A,_B,_AB, or empty
function weapon:getUpgradeSuffix(wtable)
	if
		wtable.upgrade1 and wtable.upgrade1[1] > 0 and
		wtable.upgrade2 and wtable.upgrade2[1] > 0
	then
		return "_AB"
	elseif wtable.upgrade1 and wtable.upgrade1[1] > 0 then
		return "_A"
	elseif wtable.upgrade2 and wtable.upgrade2[1] > 0 then
		return "_B"
	end

	return ""
end

--Returns the full name of the weapon including the suffix (_A,_B,_AB, or none)
function weapon:getWeaponNameWithUpgrade(weaponTable)
	return weaponTable.id..self:getUpgradeSuffix(weaponTable)
end

--Determines if the weapon is powered on. This will return true if the 
--weapon is on by default (i.e. requires no power) or it is fully 
--powered and false otherwise
function weapon:isWeaponPowered(weaponTable)
	--Check that all numbers are greater than 0
	--I think you really only need to check the first but just to be safe I check them all
	for _,power in pairs(weaponTable.power) do
		if power <= 0 then
			return false
		end
	end
	
	--empty means it needs no power so its always on!
	return true
end

--[[
	When called inside of GetSkillEffect(), returns true if the weapon is being
	called from inside of a tip image. False otherwise.

	Always returns false when called outside of GetSkillEffect().
--]]
function weapon:isTipImage()
	return not Board.gameBoard
end

return weapon