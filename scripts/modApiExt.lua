local modApiExt = {}

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

function modApiExt:clear()
	for k,v in pairs(self) do
		if type(v) == "table" then
			self[k] = {}
		end
	end
end

return modApiExt
