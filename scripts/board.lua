if not modApiExt.board then modApiExt.board = {} end

--[[
	Returns the first point on the board that matches the specified predicate.
	If no matching point is found, this function returns nil.

	predicate
		A function taking a Point as argument, and returning a boolean value.
]]--
function modApiExt.board:getSpace(predicate)
	assert(type(predicate) == "function")

	local size = Board:GetSize()
	for x = 0, size.x - 1 do
		for y = 0, size.y - 1 do
			local p = Point(x, y)
			if predicate(p) then
				return p
			end
		end
	end

	return nil
end

--[[
	Returns the first point on the board that is not blocked.
]]--
function modApiExt.board:getUnoccupiedSpace()
	return self:getSpace(function(point)
		return not Board:IsBlocked(point, PATH_GROUND)
	end)
end

function modApiExt.board:getUnoccupiedRestorableSpace()
	return self:getSpace(function(point)
		return not Board:IsBlocked(point, PATH_GROUND) and self:isRestorableTerrain(point)
	end)
end

--[[
	Returns true if the point is terrain that can be restored to its previous
	state without any issues.
]]--
function modApiExt.board:isRestorableTerrain(point)
	local terrain = Board:GetTerrain(point)

	-- Mountains and ice can be broken
	-- Buildings can be damaged or damaged
	return terrain ~= TERRAIN_MOUNTAIN  and terrain ~= TERRAIN_ICE
		and terrain ~= TERRAIN_BUILDING
end

function modApiExt.board:getRestorableTerrainData(point)
	local data = {}
	data.type = Board:GetTerrain(point)
	data.smoke = Board:IsSmoke(point)
	data.acid = Board:IsAcid(point)

	return data
end

function modApiExt.board:restoreTerrain(point, terrainData)
	Board:ClearSpace(point)
	Board:SetTerrain(point, terrainData.type)
	-- No idea what the second boolean argument does here
	Board:SetSmoke(point,terrainData.smoke, false)
	Board:SetAcid(point,terrainData.acid)
end

function modApiExt.board:isWaterTerrain(point)
	local t = Board:GetTerrain(point)
	return t == TERRAIN_WATER or t == TERRAIN_LAVA or t == TERRAIN_ACID
end

function modApiExt.board:isPawnOnBoard(pawn)
	return list_contains(extract_table(Board:GetPawns(TEAM_ANY)), pawn:GetId())
end
