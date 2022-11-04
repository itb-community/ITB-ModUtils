
--[[
	Nullsafe shorthand for point:GetString(), cause I'm lazy
--]]
function p2s(point)
	return point and point:GetString() or "nil"
end

--[[
	Converts a point to an index, given Board width
--]]
function p2idx(p, w)
	if not w then w = Board:GetSize().x end
	return p.y * w + p.x
end

--[[
	Converts index to a point on the Board, given Board width
--]]
function idx2p(idx, w)
	if not w then w = Board:GetSize().x end
	return Point(idx % w, math.floor(idx / w))
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

function is_prime(n)
	if (n > 2 and n % 2 == 0) or n == 1 then
		return false
	end

	local div = 3
	local sqrt = math.sqrt(n)

	while div <= sqrt do
		if n % div == 0 then
			return false
		end

		div = div + 2
	end

	return true
end

function next_prime(n)
	while not is_prime(n) do
		n = n + 1
	end

	return n
end

local function stringify(o)
	local t = type(o)

	-- We can't use the hash value that functions and userdata objects have
	-- assigned by lua, since it's the memory address of that particular object,
	-- not a real hash, and thus it differs even between objets that hold
	-- the same data.
	
	if t == "table" then
		return save_table(o)
	elseif t == "userdaata" then
		return "u8137"
	elseif t == "function" then
		return "f7993"
	elseif t == "thread" then
		return "t7681"
	elseif t == "number" or t == "boolean" or t == "nil" then
		return tostring(o)
	end
	
	return o -- string
end

function approximateHash(o)
	-- A real hashing function like MD5 is far too slow in pure lua,
	-- so we use an approximation: turn the object to string and remove newlines.
	-- This is good enough for our needs, and fast enough not to produce
	-- noticeable hitches during gameplay.
	-- Also need to convert double quotation marks to single, otherwise it's
	-- possible for hashed object to break out of the string
	local result, _ = stringify(o)
		:gsub("\n", "")
		:gsub("\"", "'")
	return result
end

---------------------------------------------------------------
-- Deque list object (queue/stack)

--[[
	Double-ended queue implementation via www.lua.org/pil/11.4.html
	Modified to use the class system from ItB mod loader.

	To use like a queue: use either pushleft() and popright() OR
	pushright() and popleft()

	To use like a stack: use either pushleft() and popleft() OR
	pushright() and popright()
--]]
List = Class.new()
function List:new(tbl)
	self.first = 0
	self.last = -1

	if tbl then
		for _, v in ipairs(tbl) do
			self:pushRight(v)
		end
	end
end

--[[
	Pushes the element onto the left side of the dequeue (start)
--]]
function List:pushLeft(value)
	local first = self.first - 1
	self.first = first
	self[first] = value
end

--[[
	Pushes the element onto the right side of the dequeue (end)
--]]
function List:pushRight(value)
	local last = self.last + 1
	self.last = last
	self[last] = value
end

--[[
	Removes and returns an element from the left side of the dequeue (start)
--]]
function List:popLeft()
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
function List:popRight()
	local last = self.last
	if self.first > last then error("list is empty") end
	local value = self[last]
	self[last] = nil -- to allow garbage collection
	self.last = last - 1
	return value
end

--[[
	Returns an element from the left side of the dequeue (start) without removing it
--]]
function List:peekLeft()
	if self.first > self.last then error("list is empty") end
	return self[self.first]
end

--[[
	Returns an element from the right side of the dequeue (end) without removing it
--]]
function List:peekRight()
	if self.first > self.last then error("list is empty") end
	return self[self.last]
end

--[[
	Returns true if this dequeue is empty
--]]
function List:isEmpty()
	return self.first > self.last
end

--[[
	Returns size of the dequeue
--]]
function List:size()
	if self:isEmpty() then
		return 0
	else
		return self.last - self.first + 1
	end
end
