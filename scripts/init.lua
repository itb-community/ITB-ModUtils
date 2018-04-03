local function init(self)
	if modApiExt then
		error("`modApiExt` object is already defined! A mod loaded before this "
			.. "one is not following API protocol correctly.")
	else
		modApiExt = require(self.scriptPath.."modApiExt")
		
		require(self.scriptPath.."global")
		modApiExt.vector   = modApiExt:loadModule(self.scriptPath.."vectors")
		modApiExt.string   = modApiExt:loadModule(self.scriptPath.."strings")
		modApiExt.board    = modApiExt:loadModule(self.scriptPath.."board")
		modApiExt.weapon   = modApiExt:loadModule(self.scriptPath.."weapons")
		modApiExt.pawn     = modApiExt:loadModule(self.scriptPath.."pawns")
		modApiExt.statusui = modApiExt:loadModule(self.scriptPath.."statusui")

		kf_ModUtils_DrawHook = sdl.drawHook(function(screen)
			modApiExt:updateScheduledHooks()
		end)


		if modApi.removeMissionUpdateHook == nil then
			function modApi:removeMissionUpdateHook(fn)
				assert(type(fn) == "function")
				remove_element(fn, modApi.missionUpdateHooks)
			end
		end
	end
end

local function load(self, options, version)
	-- clear out previously registered hooks, since we're relaoding.
	modApiExt:clearHooks()

	local hooks = require(self.scriptPath.."hooks")

	modApi:addPreMissionStartHook(hooks.preMissionStart)
	modApi:addMissionStartHook(hooks.missionStart)
	modApi:addMissionEndHook(hooks.missionEnd)
	modApi:addMissionUpdateHook(hooks.missionUpdate)
end

return {
	id = "kf_ModUtils",
	name = "Modding Utilities",
	version = "1.1.0",
	requirements = {},
	init = init,
	load = load,
}
