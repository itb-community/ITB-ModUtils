local function init(self)
	modApiExt = require(self.scriptPath.."modApiExt")
	
	require(self.scriptPath.."global")
	require(self.scriptPath.."vectors")
	require(self.scriptPath.."strings")
	require(self.scriptPath.."board")
	require(self.scriptPath.."weapons")
	require(self.scriptPath.."pawns")
end

local function load(self,options,version)
	local hooks = require(self.scriptPath.."hooks")
	modApi:addPreMissionStartHook(hooks.preMissionStart)
	modApi:addMissionStartHook(hooks.missionStart)
	modApi:addMissionEndHook(hooks.missionEnd)
	modApi:addMissionUpdateHook(hooks.missionUpdate)

	if modApi.removeMissionUpdateHook == nil then
		function modApi:removeMissionUpdateHook(fn)
			assert(type(fn) == "function")
			remove_element(fn, modApi.missionUpdateHooks)
		end
	end
end

return {
	id = "kf_ModUtils",
	name = "Modding Utilities",
	version = "1.0.0",
	requirements = {},
	init = init,
	load = load,
}
