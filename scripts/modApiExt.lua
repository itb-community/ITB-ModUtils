local modApiExt = {}

modApiExt.pawnTrackedHooks = {}
function modApiExt:addPawnTrackedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnTrackedHooks,fn)
end

modApiExt.pawnUntrackedHooks = {}
function modApiExt:addPawnUntrackedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnUntrackedHooks,fn)
end

modApiExt.pawnPositionChangedHooks = {}
function modApiExt:addPawnPositionChangedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnPositionChangedHooks,fn)
end

modApiExt.pawnSelectedHooks = {}
function modApiExt:addPawnSelectedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnSelectedHooks,fn)
end

modApiExt.pawnDeselectedHooks = {}
function modApiExt:addPawnDeselectedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnDeselectedHooks,fn)
end

modApiExt.tileHighlightedHooks = {}
function modApiExt:addTileHighlightedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.tileHighlightedHooks,fn)
end

modApiExt.tileUnhighlightedHooks = {}
function modApiExt:addTileUnhighlightedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.tileUnhighlightedHooks,fn)
end

modApiExt.pawnDamagedHooks = {}
function modApiExt:addPawnDamagedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnDamagedHooks,fn)
end

modApiExt.pawnHealedHooks = {}
function modApiExt:addPawnHealedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnHealedHooks,fn)
end

modApiExt.pawnKilledHooks = {}
function modApiExt:addPawnKilledHook(fn)
	assert(type(fn) == "function")
	table.insert(self.pawnKilledHooks,fn)
end

--[[
modApiExt.buildingDamagedHooks = {}
function modApiExt:addBuildingDamagedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.buildingDamagedHooks,fn)
end
]]--

modApiExt.buildingDestroyedHooks = {}
function modApiExt:addBuildingDestroyedHook(fn)
	assert(type(fn) == "function")
	table.insert(self.buildingDestroyedHooks,fn)
end

modApiExt.timer = nil
modApiExt.scheduledHooks = {}
function modApiExt:scheduleHook(msTime, fn)
	assert(type(msTime) == "number")
	assert(type(fn) == "function")
	if not self.timer then self.timer = sdl.timer() end

	table.insert(self.scheduledHooks, {
		triggerTime = self.timer:elapsed() + msTime,
		hook = fn
	})
end

function modApiExt:updateScheduledHooks()
	if self.timer then
		local t = self.timer:elapsed()

		for i, tbl in ipairs(self.scheduledHooks) do
			if tbl.triggerTime <= t then
				table.remove(self.scheduledHooks, i)
				tbl.hook()
			end
		end
	end
end

--[[
	Returns the pawn with the specified id. Works for pawns which
	may have been removed from the board.
--]]
function modApiExt:getPawnById(pawnId)
	return Board:GetPawn(pawnId) or self.pawnUserdata[pawnId]
end

--[[
	Returns the currently selected pawn, or nil if none is selected.
--]]
function modApiExt:getSelectedPawn()
	-- just Pawn works as well -- but it stays set even after it is deselected.
	for id, pawn in pairs(modApiExt.pawnUserdata) do
		if pawn:IsSelected() then return pawn end
	end

	return nil
end

--[[
	Returns the currently highlighted pawn (the one the player is hovering his
	mouse cursor over).
--]]
function modApiExt:getHighlightedPawn()
	return Board:GetPawn(mouseTile())
end

--[[
	Executes the function on the game's next update step.
--]]
function modApiExt:runLater(f)
	local hook = nil
	hook = function(mission)
		f(mission)
		modApi:removeMissionUpdateHook(hook)
	end
	modApi:addMissionUpdateHook(hook)
end

function modApiExt:clearHooks()
	local endswith = function(str, suffix)
		return suffix == "" or string.sub(str,-string.len(suffix)) == suffix
	end

	for k, v in pairs(self) do
		if type(v) == "table" and endswith(k, "Hooks") then
			self[k] = {}
		end
	end
end

--[[
	Load the ext API's modules through this function to ensure that they can
	access other modules via self keyword.
--]]
function modApiExt:loadModule(path)
	local m = require(path)
	setmetatable(m, self)
	return m
end
modApiExt.__index = modApiExt

return modApiExt
