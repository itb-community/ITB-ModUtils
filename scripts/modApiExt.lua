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

--[[
	Initializes the modApiExt object by loading available modules and setting
	up hooks.

	modulesDir - path to the directory containing all modules, with a forward
	             slash (/) at the end
--]]
function modApiExt:init(modulesDir)
	self.__index = self

	if self:isModuleAvailable(modulesDir.."global") then
		require(modulesDir.."global")
	end
	if self:isModuleAvailable(modulesDir.."hooks") then
		local hooks = require(modulesDir.."hooks")
		for k,v in pairs(hooks) do
			self[k] = v
		end
	end

	self.vector   = self:loadModuleIfAvailable(modulesDir.."vector")
	self.string   = self:loadModuleIfAvailable(modulesDir.."string")
	self.board    = self:loadModuleIfAvailable(modulesDir.."board")
	self.weapon   = self:loadModuleIfAvailable(modulesDir.."weapon")
	self.pawn     = self:loadModuleIfAvailable(modulesDir.."pawn")

	self.drawHook = sdl.drawHook(function(screen)
		self:updateScheduledHooks()

	end)


	if modApi.removeMissionUpdateHook == nil then
		function modApi:removeMissionUpdateHook(fn)
			assert(type(fn) == "function")
			remove_element(fn, modApi.missionUpdateHooks)
		end
	end
end

return modApiExt
