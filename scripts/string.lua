local mstring = {}

--[[
	Returns true if this string starts with the prefix string
--]]
function mstring:startsWith(str, prefix)
	return string.sub(str,1,string.len(prefix)) == prefix
end

--[[
	Returns true if this string ends with the suffix string
--]]
function mstring:endsWith(str, suffix)
	return suffix == "" or string.sub(str,-string.len(suffix)) == suffix
end

--[[
	Trims leading and trailing whitespace from the string.

	trim11 from: http://lua-users.org/wiki/StringTrim
--]]
function mstring:trim(str)
	local n = str:find"%S"
	return n and str:match(".*%S", n) or ""
end

return mstring