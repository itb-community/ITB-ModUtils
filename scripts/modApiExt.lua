local modApiExt = {}

function modApiExt:isModuleAvailable(name)
	if package.loaded[name] then
		return true
	else
		for _, searcher in ipairs(package.searchers or package.loaders) do
			local loader = searcher(name)
			if type(loader) == 'function' then
				package.preload[name] = loader
				return true
			end
		end

		return false
	end
end

--[[
	Load the ext API's modules through this function to ensure that they can
	access other modules via self keyword.
--]]
function modApiExt:loadModule(path)
	local m = require(path)
	setmetatable(m, self)
	return m
end

function modApiExt:init(mod)
	modApiExt.__index = modApiExt

	if self:isModuleAvailable(mod.scriptPath.."global") then
		require(mod.scriptPath.."global")
	end
	if self:isModuleAvailable(mod.scriptPath.."hooks") then
		local hooks = require(mod.scriptPath.."hooks")
		for k,v in pairs(hooks) do
			modApiExt[k] = v
		end
	end

	if self:isModuleAvailable(mod.scriptPath.."vector") then
		modApiExt.vector = modApiExt:loadModule(mod.scriptPath.."vectors")
	end
	if self:isModuleAvailable(mod.scriptPath.."string") then
		modApiExt.string = modApiExt:loadModule(mod.scriptPath.."strings")
	end
	if self:isModuleAvailable(mod.scriptPath.."board") then
		modApiExt.board = modApiExt:loadModule(mod.scriptPath.."board")
	end
	if self:isModuleAvailable(mod.scriptPath.."weapon") then
		modApiExt.weapon = modApiExt:loadModule(mod.scriptPath.."weapons")
	end
	if self:isModuleAvailable(mod.scriptPath.."pawn") then
		modApiExt.pawn = modApiExt:loadModule(mod.scriptPath.."pawns")
	end

	modApiExt.drawHook = sdl.drawHook(function(screen)
		modApiExt:updateScheduledHooks()

	end)


	if modApi.removeMissionUpdateHook == nil then
		function modApi:removeMissionUpdateHook(fn)
			assert(type(fn) == "function")
			remove_element(fn, modApi.missionUpdateHooks)
		end
	end
end

return modApiExt
