local function init(self)
end

local function load(self,options,version)
	if modApiExt then
		modApiExt:clear()
	else
		-- could replace with dofile() instead, since we
		-- actually WANT to overwrite the old table?
		modApiExt = require(self.scriptPath.."modApiExt")
	end
	
	require(self.scriptPath.."global")
	require(self.scriptPath.."vectors")
	require(self.scriptPath.."board")
	require(self.scriptPath.."pawns")
	
	local hooks = require(self.scriptPath.."hooks")
	modApi:addPreMissionEndHook(hooks.preMissionStart)
	modApi:addMissionStartHook(hooks.missionStart)
	modApi:addMissionEndHook(hooks.missionEnd)
	modApi:addMissionUpdateHook(hooks.missionUpdate)

	if modApi.removeMissionUpdateHook == nil then
		function modApi:removeMissionUpdateHook(fn)
			assert(type(fn) == "function")
			remove_element(fn,modApi.missionUpdateHooks)
		end
	end
end

return {
	id = "ModUtils",
	name = "Modding Utilities",
	version = "1.0.0",
	requirements = {},
	init = init,
	load = load,
}
