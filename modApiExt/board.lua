local board = {}

--[[
	Returns the first point on the board that matches the specified predicate.
	If no matching point is found, this function returns nil.

	predicate
		A function taking a Point as argument, and returning a boolean value.
--]]
function board:getSpace(predicate)
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
--]]
function board:getUnoccupiedSpace()
	return self:getSpace(function(point)
		return not Board:IsBlocked(point, PATH_GROUND)
	end)
end

function board:getUnoccupiedRestorableSpace()
	return self:getSpace(function(point)
		return not Board:IsBlocked(point, PATH_GROUND) and self:isRestorableTerrain(point)
	end)
end

--[[
	Returns true if the point is terrain that can be restored to its previous
	state without any issues.
--]]
function board:isRestorableTerrain(point)
	local terrain = Board:GetTerrain(point)

	-- Mountains and ice can be broken
	-- Buildings can be damaged or destroyed
	return terrain ~= TERRAIN_MOUNTAIN  and terrain ~= TERRAIN_ICE
		and terrain ~= TERRAIN_BUILDING
end

function board:getRestorableTerrainData(point)
	local data = {}
	data.type = Board:GetTerrain(point)
	data.smoke = Board:IsSmoke(point)
	data.acid = Board:IsAcid(point)

	return data
end

function board:restoreTerrain(point, terrainData)
	Board:ClearSpace(point)
	Board:SetTerrain(point, terrainData.type)
	-- No idea what the second boolean argument does here
	-- maybe normal smoke vs sand smoke?
	Board:SetSmoke(point, terrainData.smoke, false)
	Board:SetAcid(point, terrainData.acid)
end

function board:isWaterTerrain(point)
	local t = Board:GetTerrain(point)
	return t == TERRAIN_WATER or t == TERRAIN_LAVA or t == TERRAIN_ACID
end

function board:isPawnOnBoard(pawn)
	return list_contains(extract_table(Board:GetPawns(TEAM_ANY)), pawn:GetId())
end

function board:getCurrentRegion()
	if RegionData and RegionData.iBattleRegion then
		if RegionData.iBattleRegion == 20 then
			return RegionData["final_region"]
		else
			return RegionData["region"..RegionData.iBattleRegion]
		end
	end

	return nil
end

function board:getMapTable()
	local region = self:getCurrentRegion()
	assert(region, "Battle region could not be found - not in battle mode!")
	return region.player.map_data.map
end

function board:getTileTable(point)
	assert(point)
	local region = self:getCurrentRegion()
	assert(region, "Battle region could not be found - not in battle mode!")

	for i, entry in ipairs(region.player.map_data.map) do
		if entry.loc == point then
			return entry
		end
	end
end

return board