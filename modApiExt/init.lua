-- Standalone support.

local function init(self)
	if modApiExt then
		error("`modApiExt` object is already defined! A mod loaded before this "
			.. "one is not following API protocol correctly.")
	else
		modApiExt = require(self.scriptPath.."modApiExt"):init()
	end
end

local function load(self, options, version)
	if modApiExt then
		modApiExt:load(self, options, version)
	else
		-- can happen if the mod was disabled, then enabled via Mod Config
		-- in that case, the mod loader does not execute the init function.
		LOG("ModApiExt: ERROR - Failed to load because modApiExt was not initialized. "
			.. "Restart the game to fix.")
	end
end

return {
	id = "kf_ModUtils",
	name = "Modding Utilities",
	version = "1.15",
	requirements = {},
	init = init,
	load = load
}
