
local function init(self)
	modapiext = require(self.resourcePath.."modApiExt/modApiExt"):init()
end

local function load(self, options, version)
	modapiext:load(self, options, version)
end

return {
	id = "modApiExt",
	name = "modApiExt",
	version = "1.17",
	modApiVersion = "2.8.0",
	gameVersion = "1.2.83",
	isExtension = true,
	enabled = false,
	init = init,
	load = load
}
