local addPassiveEffectDebug = false --set this to true if you are having issues with running passive weapons to help determine what is going wrong
local PW_EFFECT_FN_NAME = "GetPassiveSkillEffect" --shouldn't change this. Treat it as a constant. Changing in later version would cause incompatibility

local passiveEffect = {}

--creates a string for the add function corresponding to the passed hook.
--For now all the hook appear to follow the same format but any special cases
--can be addressed in this function as needed
local function getAddFunctionForHook(hook)
	return "add"..hook:gsub("^%l", string.upper)
end

--A function that adds the passive effect to the game. Generally these will 
--be for passive weapons only but could in theory be non passive weapons 
--as well. Passive weapons should be declared the same as other weapons. The 
--GetSkillEffect method that is generally used for weapons is only used to 
--construct the tool tip for passive only weapons. The GetPassiveSkillEffect(...)
--function of the passed in weapon will be called each time the specified hook(s) 
--are fired if a mech has the weapon equiped and it is powered on. The 
--GetPassiveSkillEffect function can use all the fields of the weapon via 
--"self" and will be passed the arguements of whatever hook is specified. 
--Additionally, "Pawn" will be set to be the pawn who owns the weapon with 
--the passive effect similar to how it is done in GetSkillEffect(). The 
--name of the hook that was fired is stored in "self.HookName" if different 
--logic is required for different hooks. If the hook is omitted it 
--defaults to postEnvironmentHook. This should support all hooks in the
--ModLoader and the ModUtil.
function passiveEffect:addPassiveEffect(weapon, hook, weaponIsNotPassiveOnly)
	--ensure they are valid weapon/effect combo upfront to reduce user error	
	assert(type(weapon) == "string")
	assert(_G[weapon])
	assert(_G[weapon][PW_EFFECT_FN_NAME])
	
	--if its a passive weapon, we will auto set the Passive field
	if not weaponIsNotPassiveOnly then
		--key based on the weapon as an easy way to avoid duplicates
		modApiExt_internal.passiveEffectData.autoPassivedWeapons[weapon] = true 
	end
		
	--if they pass a table, add it for each hook
	if type(hook) == "table" then
		for _,singleHook in pairs(hook) do
			self:addPassiveEffect(weapon, singleHook)
		end
	else
		hook = hook or "postEnvironmentHook" --default to Post environemnt since thats when most effects occur
		
		--ensure there is an add function for it
		assert(type(hook) == "string")
		--ensure the first character is lower case. This just makes things easier to have consistent format
		assert(hook:sub(1,1):lower() == hook:sub(1,1)) 
		--ensure the add function exists
		local addHook = getAddFunctionForHook(hook)
		assert(self[addHook] or modApi[addHook])
		assert(type(self[addHook]) == "function" or type(modApi[addHook]) == "function")
		
		--get the list of potential effects associated with the hook or create it
		local hookTable = modApiExt_internal.passiveEffectData.possibleEffects[hook]
		if not hookTable then
			hookTable = {}
			modApiExt_internal.passiveEffectData.possibleEffects[hook] = hookTable
		end
		
		--add the weapon to the list of possible passive effects
		table.insert(hookTable, weapon)
	end
end

--checks if the passed weapon data is in the list of potential passive weapons
--and if it is construct the data needed and add it to the active passive 
--weapons list
function passiveEffect:checkAndAddIfPassive(weaponTable, owningPawnId)
	--for each hook that has possible passive effects
	for hook, weaponsWithPassives in pairs(modApiExt_internal.passiveEffectData.possibleEffects) do
		if addPassiveEffectDebug then LOG("Checking passive weapons for hook: "..hook) end
		
		--for each passive weapon of this hook
		for i, weapon in pairs(weaponsWithPassives) do
			if addPassiveEffectDebug then LOG("Checking known passive weapon id: "..weapon) end
			
			--check the id and if it matches then add the effect to the list of effects to execute for this hook
			if weaponTable.id == weapon then
			
				--get the name with extensions so we can find the right object to call the effect function on
				local wName = self.weapon:getWeaponNameWithUpgrade(weaponTable)
				if addPassiveEffectDebug then LOG("FOUND PASSIVE WEAPON!: "..wName) end
				
				--if the weapon is powerd
				if self.weapon:isWeaponPowered(weaponTable) then
					if addPassiveEffectDebug then LOG("And it is active/powered") end
					
					--get the weapon object and the effect function to use when the hook is fired
					local wObj = _G[wName]
					local wEffect = wObj[PW_EFFECT_FN_NAME]
					
					--get the list of active effects associated with the hook or create it
					local hookTable = modApiExt_internal.passiveEffectData.activeEffects[hook]
					if not hookTable then
						hookTable = {}
						modApiExt_internal.passiveEffectData.activeEffects[hook] = hookTable
					end
					
					--add the weapon and effect to the list of active passive effects for this hook
					local data = {}
					data.weapon = wObj
					data.effect = wEffect
					data.pawnId = owningPawnId --don't use Board:getPawn() bcause Board may not exist yet
					table.insert(hookTable, data)
				elseif addPassiveEffectDebug then 
					LOG("but it is not active(powered)...")
				end
			end
		end
	end
end

--function that is called on mission start or when continuing a mission to determine
--which passive effects are required
function passiveEffect.determineIfPassivesAreActive(mission)
	if addPassiveEffectDebug then LOG("Determining what Passive Effects are active(powered)...") end

	--clear the previous list of active effects
	modApiExt_internal.passiveEffectData.activeEffects = {}
	
	--loop through the player mechs to see if they have one of the passive weapons equiped and powered
	local mechsData = passiveEffect.board:getAllMechsTables()
	for _, mechData in pairs(mechsData) do
		if addPassiveEffectDebug then LOG("Checking mech: "..mechData.type) end
		
		--get the mech's weapon data
		local primary = passiveEffect.pawn:getWeaponData(mechData, "primary")
		local secondary = passiveEffect.pawn:getWeaponData(mechData, "secondary")
	
		--if it has a primary then check if it is in the passive effects list
		if primary.id then
			if addPassiveEffectDebug then LOG("Checking primary weapon: "..primary.id) end
			passiveEffect:checkAndAddIfPassive(primary, mechData.id)
		end
		
		--if it has a secondary then check if it is in the passive effects list
		if secondary.id then
			if addPassiveEffectDebug then LOG("Checking secondary weapon: "..secondary.id) end
			passiveEffect:checkAndAddIfPassive(secondary, mechData.id)
		end
	end
end

--Function that is called after the modUtils are loaded that will set the passive
--field of any passive weapons automagically so the modder doesn't have to worry 
--about remembering to do this
local function autoSetWeaponsPassiveFields()
	for weapon,_ in pairs(modApiExt_internal.passiveEffectData.autoPassivedWeapons) do
		if addPassiveEffectDebug then LOG("Making weapon "..weapon.." passive...") end
		for _, variety in pairs(passiveEffect.weapon:getAllExistingNamesForWeapon(weapon)) do
			_G[variety].Passive = variety
			if addPassiveEffectDebug then LOG("   Made variety "..variety.." passive!") end
		end
	end
end

--Generates the function that calls all passive effects registered for a specific 
--hook when the hook is fired. This should be called once per hook with possible
--passive effects
function buildPassiveEffectHookFn(hook)
	return function(...)
		LOG("Evaluating "..#modApiExt_internal.passiveEffectData.activeEffects[hook].." active(powered) passive effects for hook: "..hook)
		local previousPawn = Pawn
		for _,effectWeaponTable in pairs(modApiExt_internal.passiveEffectData.activeEffects[hook]) do
			Pawn = Board:GetPawn(effectWeaponTable.pawnId)
			effectWeaponTable.weapon.HookName = hook
			effectWeaponTable.effect(effectWeaponTable.weapon, ...)
		end
		Pawn = previousPawn
	end
end

--The function that adds the required hooks to the game for passive weapons
--This should only be called once for all instances of ModUtils!
function passiveEffect:addHooks()
	--the hook that is fired after modUtils have loaded
	self:addMostRecentResolvedHook(autoSetWeaponsPassiveFields)

	modApi:addMissionStartHook(self.determineIfPassivesAreActive) --covers starting a new mission
	modApi:addPostLoadGameHook(self.determineIfPassivesAreActive) --covers loading into (continuing) a mission
	
	--Create the needed hook objects and add the functions that handle executing
	--the active passive effects
	for hook,_ in pairs(modApiExt_internal.passiveEffectData.possibleEffects) do 
		local hookObj = buildPassiveEffectHookFn(hook)
		local addHook = getAddFunctionForHook(hook)
		
		--supports hooks in both the ModLoader and the ModUtils
		if self[addHook] then
			self[addHook](self, hookObj)
		else --already asserted that its in one of the two
			modApi[addHook](modApi, hookObj)
		end
	end
end
		
return passiveEffect