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
	assert(modApiExt_internal.extObjects)

	local result = nil
	for _, extObj in ipairs(modApiExt_internal.extObjects) do
		result = result or extObj
		if
			result.version ~= extObj.version and 
			modApi:isVersion(result.version, extObj.version)
		then
			result = extObj
		end
	end

	return result
end

--[[
	Creates a broadcast function for the specified hooks field, allowing
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
					end
				end
			end
		end
	end
end

function modApiExt:createIfMissing(object, name)
	object[name] = object[name] or {}
end

--[[
	Initializes globals used by all instances of modApiExt.
--]]
function modApiExt:internal_initGlobals()
	if not modApiExt_internal then modApiExt_internal = {} end

	-- either initialize (if no version was previously defined),
	-- or overwrite if we're more recent. Either way, we want to
	-- keep old fields around in case the older version needs them.
	local v = modApiExt_internal.version
	if not v or (v ~= self.version and modApi:isVersion(v, self.version)) then
		local m = modApiExt_internal -- for convenience and readability

		m.version = self.version
		-- list of all modApiExt instances
		-- make sure we remember the ones that have registered thus far
		m.extObjects = m.extObjects or {}

		-- Hacky AF solution to detect when tip image is visible.
		-- Need something that will absolutely not get drawn during gameplay,
		-- and apparently we can't insert our own sprite, it doesn't work...
		local s = "strategy/hangar_stencil.png"
		m.tipMarkerVisible = false
		m.tipMarker = sdlext.surface("img/"..s)
		ANIMS.kf_ModApiExt_TipMarker = ANIMS.Animation:new({
			Image = s,
			PosY = 1000, -- make sure it's outside of the viewport
			Loop = true
		})

		-- current mission, for passing as arg to hooks
		m.mission = nil
		-- table of pawn userdata, kept only at runtime to help
		-- with pawn hooks
		m.pawns = nil

		m.timer = sdl.timer()
		m.elapsedTime = nil

		m.firePawnTrackedHooks =       self:buildBroadcastFunc("pawnTrackedHooks")
		m.firePawnUntrackedHooks =     self:buildBroadcastFunc("pawnUntrackedHooks")
		m.firePawnUndoMoveHooks =      self:buildBroadcastFunc("pawnUndoMoveHooks")
		m.firePawnPosChangedHooks =    self:buildBroadcastFunc("pawnPositionChangedHooks")
		m.firePawnDamagedHooks =       self:buildBroadcastFunc("pawnDamagedHooks")
		m.firePawnHealedHooks =        self:buildBroadcastFunc("pawnHealedHooks")
		m.firePawnKilledHooks =        self:buildBroadcastFunc("pawnKilledHooks")
		m.firePawnIsFireHooks =        self:buildBroadcastFunc("pawnIsFireHooks")
		m.firePawnIsAcidHooks =        self:buildBroadcastFunc("pawnIsAcidHooks")
		m.firePawnIsFrozenHooks =      self:buildBroadcastFunc("pawnIsFrozenHooks")
		m.firePawnIsGrappledHooks =    self:buildBroadcastFunc("pawnIsGrappledHooks")
		m.firePawnIsShieldedHooks =    self:buildBroadcastFunc("pawnIsShieldedHooks")
		m.firePawnSelectedHooks =      self:buildBroadcastFunc("pawnSelectedHooks")
		m.firePawnDeselectedHooks =    self:buildBroadcastFunc("pawnDeselectedHooks")

		m.fireBuildingDamagedHooks =   self:buildBroadcastFunc("buildingDamagedHooks")
		m.fireBuildingResistHooks =    self:buildBroadcastFunc("buildingResistHooks")
		m.fireBuildingDestroyedHooks = self:buildBroadcastFunc("buildingDestroyedHooks")

		m.fireMoveStartHooks =         self:buildBroadcastFunc("pawnMoveStartHooks")
		m.fireMoveEndHooks =           self:buildBroadcastFunc("pawnMoveEndHooks")

		m.fireSkillStartHooks =        self:buildBroadcastFunc("skillStartHooks")
		m.fireSkillEndHooks =          self:buildBroadcastFunc("skillEndHooks")
		m.fireQueuedSkillStartHooks =  self:buildBroadcastFunc("queuedSkillStartHooks")
		m.fireQueuedSkillEndHooks =    self:buildBroadcastFunc("queuedSkillEndHooks")
		m.fireSkillBuildHooks =        self:buildBroadcastFunc("skillBuildHooks")

		m.fireResetTurnHooks =         self:buildBroadcastFunc("resetTurnHooks")
		m.fireGameLoadedHooks =        self:buildBroadcastFunc("gameLoadedHooks")

		m.fireTipImageShownHooks =     self:buildBroadcastFunc("tipImageShownHooks")
		m.fireTipImageHiddenHooks =    self:buildBroadcastFunc("tipImageHiddenHooks")

		m.firePodDetectedHooks =       self:buildBroadcastFunc("podDetectedHooks")
		m.firePodLandedHooks =         self:buildBroadcastFunc("podLandedHooks")
		m.firePodTrampledHooks =       self:buildBroadcastFunc("podTrampledHooks")
		m.firePodDestroyedHooks =      self:buildBroadcastFunc("podDestroyedHooks")
		m.firePodCollectedHooks =      self:buildBroadcastFunc("podCollectedHooks")

		m.drawHook = sdl.drawHook(function(screen)
			if not Game then
				modApiExt_internal.gameLoaded = false
				modApiExt_internal.elapsedTime = nil
				modApiExt_internal.mission = nil
			elseif not modApiExt_internal.gameLoaded then
				modApiExt_internal.gameLoaded = true
				if Board and not Board.gameBoard then Board.gameBoard = true end
				self.dialog:triggerRuledDialog("GameLoad")
				modApiExt_internal.fireGameLoadedHooks(modApiExt_internal.mission)
			end

			for i, extObj in ipairs(modApiExt_internal.extObjects) do
				extObj:updateScheduledHooks()
			end
			
			if modApiExt_internal.tipMarkerVisible ~= modApiExt_internal.tipMarker:wasDrawn() then
				if modApiExt_internal.tipMarkerVisible then
					modApiExt_internal.fireTipImageHiddenHooks()
				else
					modApiExt_internal.fireTipImageShownHooks()
				end
			end
			modApiExt_internal.tipMarkerVisible = modApiExt_internal.tipMarker:wasDrawn()
		end)

		-- dialogs
		m.ruledDialogs = m.ruledDialogs or {}

		-- default voiced (dialog) events
		self:createIfMissing(m.ruledDialogs, "VekKilled")
		self:createIfMissing(m.ruledDialogs, "BotKilled")
		self:createIfMissing(m.ruledDialogs, "VekKilled_Enemy")
		self:createIfMissing(m.ruledDialogs, "DoubleVekKill")
		self:createIfMissing(m.ruledDialogs, "DoubleVekKill_Enemy")
		self:createIfMissing(m.ruledDialogs, "Vek_Drown")
		self:createIfMissing(m.ruledDialogs, "Vek_Fall")
		self:createIfMissing(m.ruledDialogs, "Vek_Smoke")
		self:createIfMissing(m.ruledDialogs, "Vek_Frozen")
		self:createIfMissing(m.ruledDialogs, "Emerge_Detected")
		self:createIfMissing(m.ruledDialogs, "Emerge_FailedMech")
		self:createIfMissing(m.ruledDialogs, "Emerge_FailedVek")
		self:createIfMissing(m.ruledDialogs, "Emerge_Success")
		self:createIfMissing(m.ruledDialogs, "BldgDestroyed")
		self:createIfMissing(m.ruledDialogs, "BldgDamaged")
		self:createIfMissing(m.ruledDialogs, "BldgDamaged_Enemy")
		self:createIfMissing(m.ruledDialogs, "Bldg_Resisted")
		self:createIfMissing(m.ruledDialogs, "MntDestroyed")
		self:createIfMissing(m.ruledDialogs, "MntDestroyed_Enemy")
		self:createIfMissing(m.ruledDialogs, "PowerCritical")
		self:createIfMissing(m.ruledDialogs, "Mech_WebBlocked")
		self:createIfMissing(m.ruledDialogs, "Mech_Webbed")
		self:createIfMissing(m.ruledDialogs, "Mech_Shielded")
		self:createIfMissing(m.ruledDialogs, "Mech_Repaired")
		self:createIfMissing(m.ruledDialogs, "Mech_ShieldDown")
		self:createIfMissing(m.ruledDialogs, "Mech_LowHealth")
		self:createIfMissing(m.ruledDialogs, "Pilot_Selected")
		self:createIfMissing(m.ruledDialogs, "Pilot_Undo")
		self:createIfMissing(m.ruledDialogs, "Pilot_Moved")
		self:createIfMissing(m.ruledDialogs, "Pilot_Level")
		self:createIfMissing(m.ruledDialogs, "PilotDeath")
		self:createIfMissing(m.ruledDialogs, "PilotDeath_Hospital")
		self:createIfMissing(m.ruledDialogs, "PilotDeath_AI")
		self:createIfMissing(m.ruledDialogs, "Upgrade_PowerGeneric")
		self:createIfMissing(m.ruledDialogs, "Gamestart")
		self:createIfMissing(m.ruledDialogs, "Gamestart_Alien")
		self:createIfMissing(m.ruledDialogs, "Gameover")
		self:createIfMissing(m.ruledDialogs, "PodDetected")
		self:createIfMissing(m.ruledDialogs, "PodDestroyed")
		self:createIfMissing(m.ruledDialogs, "PodCollected")
		self:createIfMissing(m.ruledDialogs, "MissionStart")
		self:createIfMissing(m.ruledDialogs, "MissionEnd_Retreat")
		self:createIfMissing(m.ruledDialogs, "MissionEnd_Dead")
		self:createIfMissing(m.ruledDialogs, "MissionFinal_Start")
		self:createIfMissing(m.ruledDialogs, "MissionFinal_StartResponse")
		self:createIfMissing(m.ruledDialogs, "MissionFinal_Pylons")
		self:createIfMissing(m.ruledDialogs, "MissionFinal_Bomb")
		self:createIfMissing(m.ruledDialogs, "MissionFinal_BombResponse")
		self:createIfMissing(m.ruledDialogs, "MissionFinal_BombDestroyed")
		self:createIfMissing(m.ruledDialogs, "MissionFinal_BombArmed")
		self:createIfMissing(m.ruledDialogs, "MissionFinal_CaveStart")
		self:createIfMissing(m.ruledDialogs, "MissionFinal_FallStart")
		self:createIfMissing(m.ruledDialogs, "MissionFinal_FallResponse")
		self:createIfMissing(m.ruledDialogs, "Mission_Freeze_Mines_Vek")
		self:createIfMissing(m.ruledDialogs, "Mission_Mines_Vek")
		self:createIfMissing(m.ruledDialogs, "Mission_Satellite_Imminent")
		self:createIfMissing(m.ruledDialogs, "Mission_Satellite_Launch")
		self:createIfMissing(m.ruledDialogs, "Mission_Cataclysm_Falling")
		self:createIfMissing(m.ruledDialogs, "Mission_Terraform_Attacks")
		self:createIfMissing(m.ruledDialogs, "Mission_Airstrike_Incoming")
		self:createIfMissing(m.ruledDialogs, "Mission_Lightning_Strike_Vek")
		self:createIfMissing(m.ruledDialogs, "Mission_Factory_Spawning")
		self:createIfMissing(m.ruledDialogs, "Mission_Reactivation_Thawed")
		self:createIfMissing(m.ruledDialogs, "Mission_SnowStorm_FrozenVek")
		self:createIfMissing(m.ruledDialogs, "Mission_SnowStorm_FrozenMech")
		self:createIfMissing(m.ruledDialogs, "Mission_Disposal_Activated")
		self:createIfMissing(m.ruledDialogs, "Mission_Barrels_Destroyed")
		self:createIfMissing(m.ruledDialogs, "Mission_Teleporter_Mech")
		self:createIfMissing(m.ruledDialogs, "Mission_Belt_Mech")

		-- modApiExt dialog events
		self:createIfMissing(m.ruledDialogs, "GameLoad")
		self:createIfMissing(m.ruledDialogs, "MoveStart")
		self:createIfMissing(m.ruledDialogs, "MoveEnd")
		self:createIfMissing(m.ruledDialogs, "MoveUndo")
		self:createIfMissing(m.ruledDialogs, "PawnDamaged")
		self:createIfMissing(m.ruledDialogs, "PawnHealed")
		self:createIfMissing(m.ruledDialogs, "PawnKilled")
		self:createIfMissing(m.ruledDialogs, "PawnFire")
		self:createIfMissing(m.ruledDialogs, "PawnExtinguished")
		self:createIfMissing(m.ruledDialogs, "PawnAcided")
		self:createIfMissing(m.ruledDialogs, "PawnUnacided")
		self:createIfMissing(m.ruledDialogs, "PawnFrozen")
		self:createIfMissing(m.ruledDialogs, "PawnUnfrozen")
		self:createIfMissing(m.ruledDialogs, "PawnGrappled")
		self:createIfMissing(m.ruledDialogs, "PawnUngrappled")
		self:createIfMissing(m.ruledDialogs, "PawnShielded")
		self:createIfMissing(m.ruledDialogs, "PawnUnshielded")
		self:createIfMissing(m.ruledDialogs, "PawnSelected")
		self:createIfMissing(m.ruledDialogs, "PawnDeselected")
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
	self.version = "1.8" -- also update in init.lua
	self.modulesDir = modulesDir

	local minv = "2.1.3"
	if not modApi:isVersion(minv) then
		error("modApiExt could not be loaded because version of the mod loader is out of date. "
			..string.format("Installed version: %s, required: %s", modApi.version, minv))
	end
	
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

		self:scheduleHook(20, function()
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
