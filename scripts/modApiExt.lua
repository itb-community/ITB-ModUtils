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

modApiExt.scheduledHooks = {}
function modApiExt:scheduleHook(msTime, fn)
	assert(type(msTime) == "number")
	assert(type(fn) == "function")

	table.insert(self.scheduledHooks, {
		triggerTime = modApiExt_internal.timer:elapsed() + msTime,
		hook = fn
	})
end

function modApiExt:updateScheduledHooks()
	local t = modApiExt_internal.timer:elapsed()

	for i, tbl in ipairs(self.scheduledHooks) do
		if tbl.triggerTime <= t then
			table.remove(self.scheduledHooks, i)
			tbl.hook()
		end
	end
end

--[[
	Ceates a broadcast function for the specified hooks field, allowing
	to trigger the hook callbacks on all registered modApiExt objects.

	The second argument is a function that provides arguments the hooks
	will be invoked with, used only if the broadcast function was invoked
	without any arguments. Can be nil to invoke argument-less hooks.
--]]
function modApiExt:buildBroadcastFunc(hooksField, argsFunc)
	local errfunc = function(e)
		return string.format( "A %s callback failed: %s, %s",
			hooksField, e, debug.traceback()
		)
	end

	return function(...)
		local args = {...}

		if #args == 0 then
			-- We didn't receive arguments directly. Fall back to
			-- the argument function.
			-- Make sure that all hooks receive the same arguments.
			args = argsFunc and {argsFunc()} or nil
		end

		for i, extObj in ipairs(modApiExt_internal.extObjects) do
			if extObj[hooksField] then -- may have opted out of that hook
				for j, hook in ipairs(extObj[hooksField]) do
					-- invoke the hook in a xpcall, since errors in SkillEffect
					-- scripts fail silently, making debugging a nightmare.
					local ok, err = xpcall(
						args and function() hook(unpack(args)) end or function() hook() end,
						errfunc
					)

					if not ok then
						LOG(err)
						--io.log(err)
					end
				end
			end
		end
	end
end

--[[
	Initializes globals used by all instances of modApiExt.
--]]
function modApiExt:internal_initGlobals()
	if not modApiExt_internal then
		modApiExt_internal = {}
		-- list of all modApiExt instances
		modApiExt_internal.extObjects = {}

		-- Hacky AF solution to detect when tip image is visible.
		-- Need something that will absolutely not get drawn during gameplay,
		-- and apparently we can't insert our own sprite, it doesn't work...
		local s = "strategy/hangar_stencil.png"
		modApiExt_internal.tipMarkerVisible = false
		modApiExt_internal.tipMarker = sdlext.surface("img/"..s)
		ANIMS.kf_ModApiExt_TipMarker = ANIMS.Animation:new({
			Image = s,
			PosY = 1000, -- make sure it's outside of the viewport
			Loop = true
		})

		-- current mission, for passing as arg to move hooks
		modApiExt_internal.mission = nil
		-- table of pawn userdata, kept only at runtime to help
		-- with pawn hooks
		modApiExt_internal.pawns = nil

		modApiExt_internal.timer = sdl.timer()
		modApiExt_internal.elapsedTime = nil

		-- reference to the original Move's GetSkillEffect, used
		-- for chaining and implementation of move hooks
		modApiExt_internal.oldMoveEffect = nil
		-- list of skills that will not be overridden to have
		-- skillStart/End etc hooks implemented
		modApiExt_internal.skillBlacklist = { "Move" }

		modApiExt_internal.fireMoveStartHooks = self:buildBroadcastFunc("pawnMoveStartHooks")
		modApiExt_internal.fireMoveEndHooks   = self:buildBroadcastFunc("pawnMoveEndHooks")

		modApiExt_internal.fireSkillStartHook       = self:buildBroadcastFunc("skillStartHooks")
		modApiExt_internal.fireSkillEndHook         = self:buildBroadcastFunc("skillEndHooks")
		modApiExt_internal.fireQueuedSkillStartHook = self:buildBroadcastFunc("queuedSkillStartHooks")
		modApiExt_internal.fireQueuedSkillEndHook   = self:buildBroadcastFunc("queuedSkillEndHooks")
		modApiExt_internal.fireSkillBuildHook       = self:buildBroadcastFunc("skillBuildHooks")

		modApiExt_internal.fireResetTurnHook = self:buildBroadcastFunc("resetTurnHooks")

		modApiExt_internal.fireTipImageShownHook = self:buildBroadcastFunc("tipImageShownHooks")
		modApiExt_internal.fireTipImageHiddenHook = self:buildBroadcastFunc("tipImageHiddenHooks")

		modApiExt_internal.drawHook = sdl.drawHook(function(screen)
			if not Game then modApiExt_internal.elapsedTime = nil end

			for i, extObj in ipairs(modApiExt_internal.extObjects) do
				extObj:updateScheduledHooks()
			end
			
			if modApiExt_internal.tipMarkerVisible ~= modApiExt_internal.tipMarker:wasDrawn() then
				if modApiExt_internal.tipMarkerVisible then
					modApiExt_internal.fireTipImageHiddenHook()
				else
					modApiExt_internal.fireTipImageShownHook()
				end
			end
			modApiExt_internal.tipMarkerVisible = modApiExt_internal.tipMarker:wasDrawn()
		end)
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
	self.modulesDir = modulesDir
	
	self:internal_initGlobals()
	table.insert(modApiExt_internal.extObjects, self)

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
end

function modApiExt:load(mod, options, version)
	-- We're already loaded. Bail.
	if self.loaded then return end

	-- clear out previously registered hooks, since we're relaoding.
	if self.clearHooks then self:clearHooks() end

	if self:isModuleAvailable(self.modulesDir.."alter") then
		local hooks = self:loadModule(self.modulesDir.."alter")

		if hooks.preMissionStart then
			modApi:addPreMissionStartHook(hooks.preMissionStart)
		end
		if hooks.missionStart then
			modApi:addMissionStartHook(hooks.missionStart)
		end
		if hooks.missionEnd then
			modApi:addMissionEndHook(hooks.missionEnd)
		end
		if hooks.missionUpdate then
			modApi:addMissionUpdateHook(hooks.missionUpdate)
		end

		self:scheduleHook(20, function()
			-- Execute on roughly the next frame.
			-- This allows us to reset the loaded flag after all other
			-- mods are done loading.
			self.loaded = false

			if hooks.overrideMoveSkill then
				-- Make sure we are the last ones to modify the Move skill.
				-- Could do that in preMissionStartHook, but then we won't
				-- override the skill when the player loads the game.
				-- And there's no preLoadGameHook() available in base modApi.
				hooks:overrideMoveSkill()
			end
			if hooks.overrideAllSkills then
				hooks:overrideAllSkills()
			end
		end)
	end

	self.loaded = true
end

return modApiExt
