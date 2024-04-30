
-- Requires:
-- 	memedit


local VERSION = "0.3.0"
local EVENTS = {
	"onAcidCreated",
	"onAcidRemoved",
	"onBuildingCreated",
	"onBuildingDamaged",
	"onBuildingDestroyed",
	"onBuildingRemoved",
	"onFireCreated",
	"onFireRemoved",
	"onFrozenCreated",
	"onFrozenRemoved",
	"onItemChanged",
	"onItemCreated",
	"onItemRemoved",
	"onLavaCreated",
	"onLavaRemoved",
	"onShieldCreated",
	"onShieldRemoved",
	"onSmokeCreated",
	"onSmokeRemoved",
	"onTerrainChanged",
	"onTileDamaged",
	"onTileHealthChanged",
	"onTileHighlighted",
	"onTileMaxHealthChanged",
	"onTileUnhighlighted",
	"onUniqueBuildingDestroyed",
	"onUniqueBuildingChanged",
	"onUniqueBuildingCreated",
	"onUniqueBuildingRemoved",
}

local function initTrackedTiles()
	local trackedTiles = {}

	for index, point in ipairs(Board) do
		local trackedTile = {}
		trackedTiles[index] = trackedTile

		trackedTile.terrain = Board:GetTerrain(point)
		trackedTile.health = Board:GetHealth(point)
		trackedTile.healthMax = Board:GetMaxHealth(point)

		trackedTile.highlighted = false
		trackedTile.building = false
		trackedTile.uniqueBuilding = false
		trackedTile.uniqueBuildingName = nil
		trackedTile.item = false
		trackedTile.itemName = nil
		trackedTile.shield = false
		trackedTile.frozen = false
		trackedTile.smoke = false
		trackedTile.fire = false
		trackedTile.acid = false
		trackedTile.lava = false
	end

	return trackedTiles
end

function updateBoard(self)

	local trackedTiles = self.trackedTiles

	if trackedTiles == nil then
		trackedTiles = initTrackedTiles()
		self.trackedTiles = trackedTiles
	end

	for index, point in ipairs(Board) do
		local trackedTile = trackedTiles[index]

		local highlighted = Board:IsHighlighted(point)
		local terrain = Board:GetTerrain(point)
		local health = Board:GetHealth(point)
		local healthMax = Board:GetMaxHealth(point)

		local building = Board:IsBuilding(point)
		local uniqueBuilding = building and Board:IsUniqueBuilding(point)
		local uniqueBuildingName = Board:GetUniqueBuilding(point)
		local item = Board:IsItem(point)
		local itemName = Board:GetItem(point)
		local shield = Board:IsShield(point)
		local frozen = Board:IsFrozen(point)
		local smoke = Board:IsSmoke(point)
		local fire = Board:IsFire(point)
		local acid = Board:IsAcid(point)
		local lava = Board:IsTerrain(point,TERRAIN_LAVA)
		
		if highlighted ~= trackedTile.highlighted then
			local mission = GetCurrentMission()

			if highlighted then
				BoardEvents.onTileHighlighted:dispatch(mission, point)
			else
				BoardEvents.onTileUnhighlighted:dispatch(mission, point)
			end

			trackedTile.highlighted = highlighted
		end

		if health ~= trackedTile.health then
			BoardEvents.onTileHealthChanged:dispatch(point, trackedTile.health, health)

			local damage = trackedTile.health - health
			if damage > 0 then
				BoardEvents.onTileDamaged:dispatch(point, damage)

				if trackedTile.terrain == TERRAIN_BUILDING then
					BoardEvents.onBuildingDamaged:dispatch(point, damage)

					if health == 0 then
						BoardEvents.onBuildingDestroyed:dispatch(point)

						if trackedTile.uniqueBuilding then
							BoardEvents.onUniqueBuildingDestroyed:dispatch(point, trackedTile.uniqueBuildingName)
						end
					end
				end
			end

			trackedTile.health = health
		end

		if healthMax ~= trackedTile.healthMax then
			BoardEvents.onTileMaxHealthChanged:dispatch(point, trackedTile.healthMax, healthMax)

			trackedTile.healthMax = healthMax
		end

		if building ~= trackedTile.building then
			if building then
				BoardEvents.onBuildingCreated:dispatch(point)
			else
				BoardEvents.onBuildingRemoved:dispatch(point)
			end

			trackedTile.building = building
		end

		if uniqueBuilding ~= trackedTile.uniqueBuilding then
			if uniqueBuilding then
				BoardEvents.onUniqueBuildingCreated:dispatch(point, uniqueBuildingName)
			else
				BoardEvents.onUniqueBuildingRemoved:dispatch(point, trackedTile.uniqueBuildingName)
			end

			trackedTile.uniqueBuilding = uniqueBuilding
		end

		if uniqueBuildingName ~= trackedTile.uniqueBuildingName then
			BoardEvents.onUniqueBuildingChanged:dispatch(point, uniqueBuildingName, trackedTile.uniqueBuildingName)

			trackedTile.uniqueBuildingName = uniqueBuildingName
		end

		if item ~= trackedTile.item then
			if item then
				BoardEvents.onItemCreated:dispatch(point, itemName)
			else
				BoardEvents.onItemRemoved:dispatch(point, trackedTile.itemName)
			end

			trackedTile.item = item
		end

		if itemName ~= trackedTile.itemName then
			BoardEvents.onItemChanged:dispatch(point, itemName, trackedTile.itemName)

			trackedTile.itemName = itemName
		end

		if terrain ~= trackedTile.terrain then
			BoardEvents.onTerrainChanged:dispatch(point, terrain, trackedTile.terrain)
			trackedTile.terrain = terrain
		end

		if shield ~= trackedTile.shield then
			if shield then
				BoardEvents.onShieldCreated:dispatch(point)
			else
				BoardEvents.onShieldRemoved:dispatch(point)
			end

			trackedTile.shield = shield
		end

		if frozen ~= trackedTile.frozen then
			if frozen then
				BoardEvents.onFrozenCreated:dispatch(point)
			else
				BoardEvents.onFrozenRemoved:dispatch(point)
			end

			trackedTile.frozen = frozen
		end

		if smoke ~= trackedTile.smoke then
			if smoke then
				BoardEvents.onSmokeCreated:dispatch(point)
			else
				BoardEvents.onSmokeRemoved:dispatch(point)
			end

			trackedTile.smoke = smoke
		end

		if fire ~= trackedTile.fire then
			if fire then
				BoardEvents.onFireCreated:dispatch(point)
			else
				BoardEvents.onFireRemoved:dispatch(point)
			end

			trackedTile.fire = fire
		end

		if acid ~= trackedTile.acid then
			if acid then
				BoardEvents.onAcidCreated:dispatch(point)
			else
				BoardEvents.onAcidRemoved:dispatch(point)
			end

			trackedTile.acid = acid
		end
		
		if lava ~= trackedTile.lava then
			if lava then
				BoardEvents.onLavaCreated:dispatch(point)
			else
				BoardEvents.onLavaRemoved:dispatch(point)
			end

			trackedTile.lava = lava
		end
		
	end
end

local function initEvents()
	for _, eventId in ipairs(EVENTS) do
		if BoardEvents[eventId] == nil then
			BoardEvents[eventId] = Event()
		end
	end
end

local function finalizeInit(self)
	modApi.events.onMissionUpdate:subscribe(updateBoard)
end

local function onModsInitialized()
	local isHighestVersion = true
		and BoardEvents.initialized ~= true
		and BoardEvents.version == VERSION

	if isHighestVersion then
		BoardEvents:finalizeInit()
		BoardEvents.initialized = true
	end
end


local isNewerVersion = false
	or BoardEvents == nil
	or VERSION > BoardEvents.version

if isNewerVersion then
	BoardEvents = BoardEvents or {}
	BoardEvents.version = VERSION
	BoardEvents.finalizeInit = finalizeInit

	modApi.events.onModsInitialized:subscribe(onModsInitialized)

	initEvents()
end

return BoardEvents
