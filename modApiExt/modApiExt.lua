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

function modApiExt:scheduleHook(msTime, fn)
	modApi:scheduleHook(msTime, fn)
end

function modApiExt:runLater(f)
	modApi:runLater(f)
end

function modApiExt:clearHooks()
	local endswith = function(str, suffix)
		return suffix == "" or string.sub(str,-string.len(suffix)) == suffix
	end

	-- too lazy to update this function with new hooks every time
	for k, v in pairs(self) do
		if type(v) == "table" and endswith(k, "Hooks") then
			self[k] = {}
		end
	end
end

--[[
	Returns true if this instance of modApiExt is the most recent one
	out of all registered instances.
--]]
function modApiExt:isMostRecent()
	assert(modApiExt_internal)
	assert(modApiExt_internal.extObjects)

	local v = self.version
	for _, extObj in ipairs(modApiExt_internal.extObjects) do
		if v ~= extObj.version and modApi:isVersion(v, extObj.version) then
			return false
		end
	end

	return true
end

--[[
	Returns the most recent registered instance of modApiExt.
--]]
function modApiExt:getMostRecent()
	assert(modApiExt_internal)
	return modApiExt_internal:getMostRecent()
end

--[[
	Initializes the modApiExt object by loading available modules and setting
	up hooks.

	modulesDir - path to the directory containing all modules, with a forward
	             slash (/) at the end
--]]
function modApiExt:init(modulesDir)
	self.__index = self
	self.version = "1.10" -- also update in init.lua
	self.modulesDir = modulesDir

	local minv = "2.1.5"
	if not modApi:isVersion(minv) then
		error("modApiExt could not be loaded because version of the mod loader is out of date. "
			..string.format("Installed version: %s, required: %s", modApi.version, minv))
	end

	require(modulesDir.."internal"):init(self)
	table.insert(modApiExt_internal.extObjects, self)

	require(modulesDir.."global")
	
	if self:isModuleAvailable(modulesDir.."hooks") then
		local hooks = require(modulesDir.."hooks")
		for k, v in pairs(hooks) do
			self[k] = v
		end
	end

	self.vector =   self:loadModuleIfAvailable(modulesDir.."vector")
	self.string =   self:loadModuleIfAvailable(modulesDir.."string")
	self.board =    self:loadModuleIfAvailable(modulesDir.."board")
	self.weapon =   self:loadModuleIfAvailable(modulesDir.."weapon")
	self.pawn =     self:loadModuleIfAvailable(modulesDir.."pawn")
	self.dialog =   self:loadModuleIfAvailable(modulesDir.."dialog")
end

function modApiExt:load(mod, options, version)
	-- We're already loaded. Bail.
	if self.loaded then return end

	-- clear out previously registered hooks, since we're reloading.
	if self.clearHooks then self:clearHooks() end

	if self:isModuleAvailable(self.modulesDir.."alter") then
		local hooks = self:loadModule(self.modulesDir.."alter")

		modApi:addMissionStartHook(hooks.missionStart)
		modApi:addMissionEndHook(hooks.missionEnd)

		modApi:scheduleHook(20, function()
			-- Execute on roughly the next frame.
			-- This allows us to reset the loaded flag after all other
			-- mods are done loading.
			self.loaded = false

			table.insert(
				modApi.missionUpdateHooks,
				list_indexof(modApiExt_internal.extObjects, self),
				hooks.missionUpdate
			)

			if self:getMostRecent() == self then
				if hooks.overrideAllSkills then
					-- Make sure the most recent version overwrites all others
					dofile(self.modulesDir.."global.lua")
					hooks:overrideAllSkills()

					-- Ensure backwards compatibility
					self:addSkillStartHook(function(mission, pawn, skill, p1, p2)
						if skill == "Move" then
							self.dialog:triggerRuledDialog("MoveStart", { main = pawn:GetId() })
							modApiExt_internal.fireMoveStartHooks(mission, pawn, p1, p2)
						end
					end)
					self:addSkillEndHook(function(mission, pawn, skill, p1, p2)
						if skill == "Move" then
							self.dialog:triggerRuledDialog("MoveEnd", { main = pawn:GetId() })
							modApiExt_internal.fireMoveEndHooks(mission, pawn, p1, p2)
						end
					end)
				end
				if hooks.voiceEvent then
					modApi:addVoiceEventHook(hooks.voiceEvent)
				end
			end
		end)
	end

	self.loaded = true
end

return modApiExt
