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
	for y = 0, size.y - 1 do
		for x = 0, size.x - 1 do
			local p = Point(x, y)
			if predicate(p) then
				return p
			end
		end
	end

	error("Could not find a Board space satisfying the given condition.\n" .. debug.traceback())
end

--[[
	Returns the first point on the board that is not blocked.
--]]
function board:getUnoccupiedSpace()
	return self:getSpace(function(point)
		return not Board:IsBlocked(point, PATH_GROUND)
	end)
end

function board:getSafeSpace()
	return self:getSpace(function(point)
		-- We can put non-massive pawns over water, as long as we move
		-- them back to solid ground in the same game tick...
		return not Board:IsPawnSpace(point) and
		       -- ...but if we do that, then dealing safe damage to a
		       -- pawn that's about to drown will cause an additional
		       -- splash effect on the safe space tile.
		       Board:GetTerrain(point) ~= TERRAIN_WATER and
		       self:isRestorableTerrain(point)
	end)
end

function board:getUnoccupiedRestorableSpace()
	return self:getSpace(function(point)
		return not Board:IsPawnSpace(point) and self:isRestorableTerrain(point)
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
	return terrain ~= TERRAIN_MOUNTAIN  and
	       terrain ~= TERRAIN_ICE       and
	       terrain ~= TERRAIN_BUILDING  and
	       not Board:IsPod(point)       and
	       not Board:IsFrozen(point)    and
	       not Board:IsDangerous(point) and
	       not Board:IsDangerousItem(point)
end

function board:getRestorableTerrainData(point)
	local data = {}
	data.type = Board:GetTerrain(point)
	data.smoke = Board:IsSmoke(point)
	data.acid = Board:IsAcid(point)
	data.fire = Board:IsFire(point)

	return data
end

function board:restoreTerrain(point, terrainData)
	Board:SetTerrain(point, TERRAIN_WATER) -- takes care of fire

	Board:SetTerrain(point, terrainData.type)
	Board:SetSmoke(point, terrainData.smoke, false)
	Board:SetAcid(point, terrainData.acid)
	if terrainData.fire then
		local d = SpaceDamage(point)
		d.iFire = EFFECT_CREATE
		Board:DamageSpace(d)
	end
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
	if not region then return nil end
	return region.player.map_data.map
end

function board:getTileTable(point)
	local region = self:getCurrentRegion()
	if not region then return nil end

	for i, entry in ipairs(region.player.map_data.map) do
		if entry.loc == point then
			return entry
		end
	end
end

function board:getTileHealth(point)
	local tileTable = self:getTileTable(point)
	if tileTable then
		return tileTable.health_min or self:getTileMaxHealth(point)
	end

	return 0
end

function board:getTileMaxHealth(point)
	local tileTable = self:getTileTable(point)
	if tileTable then
		-- empty tiles appear to have max health of 2 by default
		return tileTable.health_max or 2
	end

	return 0
end

--Returns the type of fire that is on the tile.
--For "fire tiles" this returns 1
--For "forest fire" this returns 2
--For anything else this returns 0
function board:getTileFireType(point)
	local tileTable = self:getTileTable(point)
	return tileTable.fire or 0
end

return board
