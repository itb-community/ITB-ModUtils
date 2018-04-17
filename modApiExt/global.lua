
--[[
	Nullsafe shorthand for point:GetString(), cause I'm lazy
--]]
function p2s(point)
	return point and point:GetString() or "nil"
end

--[[
	Returns index of the specified element in the list, or -1 if not found.
--]]
function list_indexof(list, element)
	for i, v in ipairs(list) do
		if element == v then return i end
	end
	
	return -1
end

---------------------------------------------------------------
-- Screenpoint to tile conversion

--[[
	Returns currently highlighted board tile (Point), or nil.
--]]
function mouseTile()
	-- Use custom table instead of the existing Point class, since Point
	-- can only hold integer values and automatically rounds them.
	return screenPointToTile({ x = sdl.mouse.x(), y = sdl.mouse.y() })
end

if not screenPointToTile then
	--[[
		Returns a board tile (Point) at the specified point on the screen, or nil.
	--]]
	function screenPointToTile(screenPoint)
		if not Board then return nil end
		
		local screen = sdl.screen()
		local scale = GetBoardScale()
		
		local tw = 28
		local th = 21

		-- Top corner of the (0, 0) tile
		local tile00 = {
			x = screen:w() / 2,
			y = screen:h() / 2 - 8 * th * scale
		}

		if scale == 2 then
			tile00.y = tile00.y + 5 * scale + 0.5
		end

		-- Change screenPoint to be relative to the (0, 0) tile
		-- and move to unscaled space.
		local relPoint = {}
		relPoint.x = (screenPoint.x - tile00.x) / scale
		relPoint.y = (screenPoint.y - tile00.y) / scale

		local lineX = function(x) return x * th/tw end
		local lineY = function(x) return -lineX(x) end

		-- round to nearest integer
		local round = function(a) return math.floor(a + 0.5) end

		local isPointAboveLine = function(point, lineFn)
			return round(point.y) >= round(lineFn(point.x))
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
		for tileY = bsize.y, 0, -1 do
			for tileX = bsize.x, 0, -1 do
				if tileContains(tileX, tileY, relPoint) then
					if tileY == bsize.y or tileX == bsize.x then
						-- outside of the board
						return nil
					end
					return Point(tileX, tileY)
				end
			end
		end

		return nil
	end
end

---------------------------------------------------------------
-- Hasing functions

local function hash_table(tbl)
	local hash = 79
	local salt = 43

	for k, v in pairs(tbl) do
		hash = salt * hash + hash_o(k)
		hash = salt * hash + hash_o(v)
	end

	for i, v in ipairs(tbl) do
		hash = salt * hash + i
		hash = salt * hash + hash_o(v)
	end

	return hash
end

local function hash_string(str)
	local hash = 129
	local salt = 29

	local l = string.len(str)
	for i = 1, l do
		hash = salt * hash + string.byte(str, i)
	end

	return hash
end

function hash_o(o)
	local hash = 89
	local salt = 31
	local nullCode = 13

	if type(o) == "table" then
		hash = salt * hash + hash_table(o)
	elseif type(o) == "userdata" then
		hash = salt * hash + 8137
	elseif type(o) == "function" then
		hash = salt * hash + 7979
	elseif type(o) == "number" then
		hash = salt * hash + o
	elseif type(o) == "string" then
		hash = salt * hash + hash_string(o)
	elseif type(o) == "boolean" then
		hash = salt * hash + (o and 23 or 17)
	elseif type(o) == "nil" then
		hash = salt * hash + nullCode
	end

	return hash
end

---------------------------------------------------------------
-- Deque list object (queue/stack)

if not List then
	--[[
		Double-ended queue implementation via www.lua.org/pil/11.4.html
		Modified to use the class system from ItB mod loader.

		To use like a queue: use either pushleft() and popright() OR
		pushright() and popleft()

		To use like a stack: use either pushleft() and popleft() OR
		pushright() and popright()
	--]]
	List = Class.new()
	function List:new()
		self.first = 0
		self.last = -1
	end

	--[[
		Pushes the element onto the left side of the dequeue (beginning)
	--]]
	function List:pushleft(value)
		local first = self.first - 1
		self.first = first
		self[first] = value
	end

	--[[
		Pushes the element onto the right side of the dequeue (end)
	--]]
	function List:pushright(value)
		local last = self.last + 1
		self.last = last
		self[last] = value
	end

	--[[
		Removes and returns an element from the left side of the dequeue (beginning)
	--]]
	function List:popleft()
		local first = self.first
		if first > self.last then error("list is empty") end
		local value = self[first]
		self[first] = nil -- to allow garbage collection
		self.first = first + 1
		return value
	end

	--[[
		Removes and returns an element from the right side of the dequeue (end)
	--]]
	function List:popright()
		local last = self.last
		if self.first > last then error("list is empty") end
		local value = self[last]
		self[last] = nil -- to allow garbage collection
		self.last = last - 1
		return value
	end

	--[[
		Returns true if this dequeue is empty
	--]]
	function List:isempty()
		return self.first > self.last
	end
end
