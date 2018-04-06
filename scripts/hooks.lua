local hooks = {}

hooks.resetTurnHooks = {}
function hooks:addResetTurnHook(fn)
	assert(type(fn) == "function")
	table.insert(self.resetTurnHooks,fn)
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

hooks.pawnUndoMoveHooks = {}
function hooks:addPawnUndoMoveHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnUndoMoveHooks,fn)
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

hooks.skillStartHooks = {}
function hooks:addSkillStartHook(fn)
	assert(type(fn) == "function")
	table.insert(self.skillStartHooks,fn)
end

hooks.skillEndHooks = {}
function hooks:addSkillEndHook(fn)
	assert(type(fn) == "function")
	table.insert(self.skillEndHooks,fn)
end

hooks.queuedSkillStartHooks = {}
function hooks:addQueuedSkillStartHook(fn)
	assert(type(fn) == "function")
	table.insert(self.queuedSkillStartHooks,fn)
end

hooks.queuedSkillEndHooks = {}
function hooks:addQueuedSkillEndHook(fn)
	assert(type(fn) == "function")
	table.insert(self.queuedSkillEndHooks,fn)
end

hooks.skillBuildHooks = {}
function hooks:addSkillBuildHook(fn)
	assert(type(fn) == "function")
	table.insert(self.skillBuildHooks,fn)
end

hooks.tipImageShownHooks = {}
function hooks:addTipImageShownHook(fn)
	assert(type(fn) == "function")
	table.insert(self.tipImageShownHooks,fn)
end

hooks.tipImageHiddenHooks = {}
function hooks:addTipImageHiddenHook(fn)
	assert(type(fn) == "function")
	table.insert(self.tipImageHiddenHooks,fn)
end

--[[
	Executes the function on the game's next update step. Only works during missions.
	
	Calling this while during game loop (either in a function called from missionUpdate,
	or as a result of previous runLater) will correctly schedule the function to be
	invoked during the next update step (not the current one).
--]]
function hooks:runLater(f)
	assert(type(f) == "function")

	if not modApiExt_internal.runLaterQueue then
		modApiExt_internal.runLaterQueue = {}
	end

	table.insert(modApiExt_internal.runLaterQueue, f)
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
