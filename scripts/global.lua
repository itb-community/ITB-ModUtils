
--[[
	Nullsafe shorthand for point:GetLuaString(), cause I'm lazy
]]--
function p2s(point)
	return point and point:GetLuaString() or "nil"
end

--[[
	Returns index of the specified element in the list, or -1 if not found.
]]--
function list_indexof(list, element)
	for i, v in ipairs(list) do
		if element == v then return i end
	end
	
	return -1
end
