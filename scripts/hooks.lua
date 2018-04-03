local hooks = {}

hooks.pawnTrackedHooks = {}
function hooks:addPawnTrackedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnTrackedHooks,fn)
end

hooks.pawnUntrackedHooks = {}
function hooks:addPawnUntrackedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnUntrackedHooks,fn)
end

hooks.pawnMoveStartHooks = {}
function hooks:addPawnMoveStartHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnMoveStartHooks,fn)
end

hooks.pawnMoveEndHooks = {}
function hooks:addPawnMoveEndHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnMoveEndHooks,fn)
end

hooks.pawnPositionChangedHooks = {}
function hooks:addPawnPositionChangedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnPositionChangedHooks,fn)
end

hooks.pawnSelectedHooks = {}
function hooks:addPawnSelectedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnSelectedHooks,fn)
end

hooks.pawnDeselectedHooks = {}
function hooks:addPawnDeselectedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnDeselectedHooks,fn)
end

hooks.tileHighlightedHooks = {}
function hooks:addTileHighlightedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.tileHighlightedHooks,fn)
end

hooks.tileUnhighlightedHooks = {}
function hooks:addTileUnhighlightedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.tileUnhighlightedHooks,fn)
end

hooks.pawnDamagedHooks = {}
function hooks:addPawnDamagedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnDamagedHooks,fn)
end

hooks.pawnHealedHooks = {}
function hooks:addPawnHealedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnHealedHooks,fn)
end

hooks.pawnKilledHooks = {}
function hooks:addPawnKilledHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnKilledHooks,fn)
end

hooks.buildingDamagedHooks = {}
function hooks:addBuildingDamagedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.buildingDamagedHooks,fn)
end

hooks.buildingResistHooks = {}
function hooks:addBuildingResistHook(fn)
	assert(type(fn) == "function")
	table.insert(self.buildingResistHooks,fn)
end

hooks.buildingDestroyedHooks = {}
function hooks:addBuildingDestroyedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.buildingDestroyedHooks,fn)
end

--[[
	Executes the function on the game's next update step. Only works during missions.
--]]
function hooks:runLater(f)
	local hook = nil
	hook = function(mission)
		f(mission)
		modApi:removeMissionUpdateHook(hook)
	end
	modApi:addMissionUpdateHook(hook)
end

function hooks:clearHooks()
	local endswith = function(str, suffix)
		return suffix == "" or string.sub(str,-string.len(suffix)) == suffix
	end

	-- too lazy to update this function with new hooks every time
	for k, v in pairs(self) do
		if type(v) == "table" and endswith(k, "Hooks") then
			self[k] = {}
		end
	end
end

return hooks
