local function init(self)
	if modApiExt then
		error("`modApiExt` object is already defined! A mod loaded before this "
			.. "one is not following API protocol correctly.")
	else
		modApiExt = require(self.scriptPath.."modApiExt")
		modApiExt:init(self.scriptPath)
	end
end

local function load(self, options, version)
	modApiExt:load(self, options, version)
end

return {
	id = "kf_ModUtils",
	name = "Modding Utilities",
	version = "1.5.0", -- also update in modApiExt.lua
	requirements = {},
	init = init,
	load = load,
}
