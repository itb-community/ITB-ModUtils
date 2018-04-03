local function init(self)
	if modApiExt then
		error("`modApiExt` object is already defined! A mod loaded before this "
			.. "one is not following API protocol correctly.")
	else
		modApiExt = require(self.scriptPath.."modApiExt")
		modApiExt:init(self.scriptPath)

		-- We only set this because we're the master ModUtils, to allow client
		-- mods to check our version.
		modApiExt.version = self.version
	end
end

local function load(self, options, version)
	-- Reset the loaded flag to make sure we correctly reset hooks
	-- in case we reload the game.
	modApiExt.loaded = false
	modApiExt:load(self, options, version)
end

return {
	id = "kf_ModUtils",
	name = "Modding Utilities",
	version = "1.2.0",
	requirements = {},
	init = init,
	load = load,
}
