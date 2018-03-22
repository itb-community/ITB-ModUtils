
function p2s(point)
	return "[" .. point.x .. ", " .. point.y .. "]"
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

--[[
	Executes the function on the game's next update step.
]]--
function RunLater(f)
	local hook = nil
	hook = function(mission)
		f()
		modApi:removeMissionUpdateHook(hook)
	end
	modApi:addMissionUpdateHook(hook)
end
