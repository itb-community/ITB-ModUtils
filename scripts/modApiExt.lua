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

function modApiExt:loadModuleIfAvailable(path)
	if self:isModuleAvailable(path) then
		return self:loadModule(path)
	else
		return nil
	end
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

	modApiExt.vector   = modApiExt.loadModuleIfAvailable(mod.scriptPath.."vector")
	modApiExt.string   = modApiExt.loadModuleIfAvailable(mod.scriptPath.."string")
	modApiExt.board    = modApiExt.loadModuleIfAvailable(mod.scriptPath.."board")
	modApiExt.weapon   = modApiExt.loadModuleIfAvailable(mod.scriptPath.."weapon")
	modApiExt.pawn     = modApiExt.loadModuleIfAvailable(mod.scriptPath.."pawn")

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
