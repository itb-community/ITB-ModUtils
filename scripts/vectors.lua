VEC_DOWN_RIGHT	= Point( 1,  1)
VEC_DOWN_LEFT	= Point(-1,  1)
VEC_UP_RIGHT	= Point( 1, -1)
VEC_UP_LEFT		= Point(-1, -1)

-- shorthands
VEC_DR = VEC_DOWN_RIGHT
VEC_DL = VEC_DOWN_LEFT
VEC_UR = VEC_UP_RIGHT
VEC_UL = VEC_UP_LEFT

DIR_VECTORS_8 =
{
	VEC_RIGHT,
	VEC_DOWN,
	VEC_LEFT,
	VEC_UP,
	
	VEC_DOWN_RIGHT,
	VEC_DOWN_LEFT,
	VEC_UP_RIGHT,
	VEC_UP_LEFT
}

AXIS_X		= 0
AXIS_Y		= 1
AXIS_ANY	= 2

--------------------------------------------------------------------------

function assert_point(o)
	assert(type(o) == "userdata")
	assert(type(o.x) == "number")
	assert(type(o.y) == "number")
end

--[[
	Tests whether two points are colinear along the specified axis
	(ie. have the same value for that axis' coordinate)
]]--
function IsColinear(refPoint, testPoint, axis)
	assert_point(refPoint)
	assert_point(testPoint)

	if axis == 0 then
		return refPoint.x == testPoint.x
	elseif axis == 1 then
		return refPoint.y == testPoint.y
	elseif axis == 2 then
		return refPoint.x == testPoint.x or refPoint.y == testPoint.y
	end

	return nil
end

function Point:IsColinear(testPoint, axis)
	return IsColinear(self, testPoint, axis)
end

--[[
	Returns a vector normal to the one provided in argument.
	Normal in this context means perpendicular.
]]--
function NormalVector(vec)
	return Point(vec.y, vec.x)
end

function Point:NormalVector()
	return NormalVector(self)
end

--[[
	Returns length of the vector.
]]--
function Length(vec)
	return math.sqrt( vec.x * vec.x + vec.y * vec.y )
end

function Point:Length()
	return Length(self)
end

--[[
	Returns a unit vector constructed from the vector provided in argument.
	Unit vector is a vector with length of 1.
	HOWEVER in ItB, the Point class can only hold integers, and by default
	round fractional values to nearest integers.

	For fractional values, use UnitVectorF(), which returns a custom table
	with x and y fields.
]]--
function UnitVectorI(vec)
	local l = Length(vec)
	if l == 0 then return Point(0, 0) end
	return Point(vec.x / l, vec.y / l)
end

function Point:UnitVectorI()
	return UnitVector(self)
end

--[[
	Returns a unit vector constructed from the vector provided in argument.
	Unit vector is a vector with length of 1.
]]--
function UnitVectorF(vec)
	local l = Length(vec)

	local t = {}
	if l == 0 then t.x = 0 else t.x = vec.x / l end
	if l == 0 then t.y = 0 else t.y = vec.y / l end
	return t
end

function Point:UnitVectorF()
	return UnitVectorF(self)
end

--[[
	Returns axis represented by this vector.

	Returns nil if Point(0,0) is provided.
	Returns AXIS_X if this vector has no Y component.
	Returns AXIS_Y if this vector has no X component.
	Returns nil otherwise.
]]--
function ToAxis(vec)
	if vec == Point(0, 0) then return nil end

	if vec.y == 0 and vec:IsColinear(VEC_LEFT, AXIS_X) then
		return AXIS_X
	elseif vec.x == 0 and vec:IsColinear(VEC_UP, AXIS_Y) then
		return AXIS_Y
	end

	return nil
end

function Point:ToAxis()
	return ToAxis(self)
end

--[[
	Returns index of the direction vector built from the specified 
	vector in the DIR_VECTORS_8 table
]]--
function GetDirection8(vec)
	return list_indexof(DIR_VECTORS_8, UnitVectorI(vec))
end

function Point:GetDirection8()
	return GetDirection8(self)
end

