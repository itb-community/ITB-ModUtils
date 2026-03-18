
local function init(self)
	modapiext = require(self.resourcePath.."modApiExt/modApiExt"):init()
end

local function load(self, options, version)
	modapiext:load(self, options, version)
end

return {
	id = "modApiExt",
	name = "modApiExt",
	version = "1.24",
	modApiVersion = "2.9.5",
	gameVersion = "1.2.93",
	icon = "img/icon.png",
	isExtension = true,
	enabled = false,
	init = init,
	load = load
}
