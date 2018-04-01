local modApiExt = {}

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

function modApiExt:getPawnById(pawnId)
	return Board:GetPawn(pawnId) or self.pawnUserdata[pawnId]
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

return modApiExt
