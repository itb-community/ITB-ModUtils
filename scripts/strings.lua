
--[[
	Returns true if this string starts with the prefix string
]]--
function startsWith(str, prefix)
	return string.sub(str,1,string.len(prefix)) == prefix
end

function string:startsWith(prefix)
	return startsWith(self, prefix)
end

--[[
	Returns true if this string ends with the suffix string
]]--
function endsWith(str, suffix)
	return suffix == "" or string.sub(str,-string.len(suffix)) == suffix
end

function string:endsWith(suffix)
	return endsWith(self, suffix)
end

--[[
	Trims leading and trailing whitespace from the string.

	trim11 from: http://lua-users.org/wiki/StringTrim
]]--
function trim(str)
	local n = str:find"%S"
	return n and str:match(".*%S", n) or ""
end

function string:trim()
	return trim(self)
end
