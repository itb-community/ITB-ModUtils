
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

--[[
	Returns currently highlighted board tile (Point), or nil.
]]--
function mouseTile()
	return screenPointToTile({ x = sdl.mouse.x(), y = sdl.mouse.y() })
end

--[[
	Returns a board tile (Point) at the specified point on the screen, or nil.
]]--
function screenPointToTile(screenPoint)
	local screen = sdl.screen()
	local scale = GetBoardScale()
	
	local tw = 28
	local th = 21

	-- Top corner of the (0, 0) tile
	local tile00 = {
		x = screen:w() / 2,
		y = screen:h() / 2 - 8 * th * scale + 0.5
	}

	if scale == 2 then
		tile00.y = tile00.y + 5 * scale
	end

	-- Change screenPoint to be relative to the (0, 0) tile
	-- and move to unscaled space.
	local relPoint = {}
	relPoint.x = (screenPoint.x - tile00.x) / scale
	relPoint.y = (screenPoint.y - tile00.y) / scale

	local lineX = function(x) return x * th/tw end
	local lineY = function(x) return -lineX(x) end

	local isPointAboveLine = function(point, lineFn)
		return point.y >= lineFn(point.x)
	end

	local tileContains = function(tilex, tiley, point)
		local np = {
			x = point.x - tw * (tilex - tiley),
			y = point.y - th * (tilex + tiley)
		}
		return isPointAboveLine(np, lineX)
			and isPointAboveLine(np, lineY)
	end

	-- Start at the end of the board and move backwards.
	-- That way we only need to check 2 lines instead of 4.
	local bsize = Board:GetSize()
	for tileY = bsize.y - 1, 0, -1 do
		for tileX = bsize.x - 1, 0, -1 do
			if tileContains(tileX, tileY, relPoint) then
				return Point(tileX, tileY)
			end
		end
	end

	return nil
end
