
local function init(self)
	modApiExt = require(self.resourcePath.."modApiExt/modApiExt"):init()
end

local function load(self, options, version)
	modApiExt:load(self, options, version)
end

return {
	id = "modApiExt",
	name = "modApiExt",
	version = "1.2",
	modApiVersion = "2.7.3",
	gameVersion = "1.2.83",
	isExtension = true,
	init = init,
	load = load
}
