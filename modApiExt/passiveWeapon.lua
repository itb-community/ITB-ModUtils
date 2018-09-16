--set this to true if you are having issues with running passive weapons to help determine what is going wrong
local addPassiveEffectDebug = true
local PW_EFFECT_FN_NAME = "GetPassiveSkillEffect"

local passiveWeapon = {}

--creates a string for the add function corresponding to the passed hook
local function getAddFunctionForHook(hook)
	return "add"..hook:gsub("^%l", string.upper)
end

--A function that adds the passive weapon to the game. The passive weapon
--should be declared the same as other weapons but should have the additional
--Passive field set to a string of the weapon name plus the extension 
--(_A, _B, _AB) if applicable. The GetSkillEffect method that is generally used
--for weapons will only be used to construct the tool tip animation. The method
--passed to this function will be called each time the passed hook is fired if
--a mech has the weapon equiped and it is powered on. The method passed as the
--passive effect can use all the fields of the weapon via the self field and 
--will be passed the arguements of whatever hook is specified. Additionally, 
--Pawn will be set to be the pawn who owns the weapon with the passive effect 
--similar to how it is done in GetSkillEffect() If the hook is omitted it 
--defaults to addPostEnvironmentHook. This should support all hooks in the
--ModLoader and the ModUtil.
function passiveWeapon:addPassiveEffect(weapon, hook, weaponIsNotPassiveOnly)
	--ensure they are valid weapon/effect combo upfront to reduce user error	
	assert(type(weapon) == "string")
	assert(_G[weapon])
	assert(_G[weapon][PW_EFFECT_FN_NAME])
	
	--if its a passive weapon, we will auto set the Passive field
	if not weaponIsNotPassiveOnly then
		--key based on the weapon as an easy way to avoid duplicates
		modApiExt_internal.passiveWeaponData.autoPassivedWeapons[weapon] = true 
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
		local hookTable = modApiExt_internal.passiveWeaponData.possibleEffects[hook]
		if not hookTable then
			hookTable = {}
			modApiExt_internal.passiveWeaponData.possibleEffects[hook] = hookTable
		end
		
		--add the weapon to the list of possible passive effects
		table.insert(hookTable, weapon)
	end
end

--checks if the passed weapon data is in the list of potential passive weapons
--and if it is construct the data needed and add it to the active passive 
--weapons list
function passiveWeapon:checkAndAddIfPassive(weaponTable, owningPawnId)
	--for each hook that has possible passive effects
	for hook, weaponsWithPassives in pairs(modApiExt_internal.passiveWeaponData.possibleEffects) do
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
					local hookTable = modApiExt_internal.passiveWeaponData.activeEffects[hook]
					if not hookTable then
						hookTable = {}
						modApiExt_internal.passiveWeaponData.activeEffects[hook] = hookTable
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
function passiveWeapon.determineIfPassivesAreActive(mission)
	if addPassiveEffectDebug then LOG("Determining what Passive Effects are active(powered)...") end

	--clear the previous list of active effects
	modApiExt_internal.passiveWeaponData.activeEffects = {}
	
	--loop through the player mechs to see if they have one of the passive weapons equiped and powered
	local mechsData = passiveWeapon.board:getAllMechsTables()
	for _, mechData in pairs(mechsData) do
		if addPassiveEffectDebug then LOG("Checking mech: "..mechData.type) end
		
		--get the mech's weapon data
		local primary = passiveWeapon.pawn:getWeaponData(mechData, "primary")
		local secondary = passiveWeapon.pawn:getWeaponData(mechData, "secondary")
	
		--if it has a primary then check if it is in the passive effects list
		if primary.id then
			if addPassiveEffectDebug then LOG("Checking primary weapon: "..primary.id) end
			passiveWeapon:checkAndAddIfPassive(primary, mechData.id)
		end
		
		--if it has a secondary then check if it is in the passive effects list
		if secondary.id then
			if addPassiveEffectDebug then LOG("Checking secondary weapon: "..secondary.id) end
			passiveWeapon:checkAndAddIfPassive(secondary, mechData.id)
		end
	end
end

--Function that is called after the modUtils are loaded that will set the passive
--field of any passive weapons automagically so the modder doesn't have to worry 
--about remembering to do this
local function autoSetWeaponsPassiveFields()
	for weapon,_ in pairs(modApiExt_internal.passiveWeaponData.autoPassivedWeapons) do
		if addPassiveEffectDebug then LOG("Making weapon "..weapon.." passive...") end
		for _, variety in pairs(passiveWeapon.weapon:getAllExistingNamesForWeapon(weapon)) do
			_G[variety].Passive = variety
			if addPassiveEffectDebug then LOG("   Made variety "..variety.." passive!") end
		end
	end
end

--Function to generate the object to handle calling all passive effects registered 
--for a specific hook when the hook is fired which contains the function to be added
--to the hook. This should be called once per hook with possible passive effects
function generatePassiveEffectHookFn(hook)
	return function(...)
		LOG("Evaluating "..#modApiExt_internal.passiveWeaponData.activeEffects[hook].." active(powered) passive effects for hook: "..hook)
		local previousPawn = Pawn
		for _,effectWeaponTable in pairs(modApiExt_internal.passiveWeaponData.activeEffects[hook]) do
			Pawn = Board:GetPawn(effectWeaponTable.pawnId)
			effectWeaponTable.weapon.HookName = hook
			effectWeaponTable.effect(effectWeaponTable.weapon, ...)
		end
		Pawn = previousPawn
	end
end

function passiveWeapon:addHooks()
	--the hook that is fired after modUtils have loaded
	self:addMostRecentResolvedHook(autoSetWeaponsPassiveFields)

	modApi:addMissionStartHook(self.determineIfPassivesAreActive) --covers starting a new mission
	modApi:addPostLoadGameHook(self.determineIfPassivesAreActive) --covers loading into (continuing) a mission
	
	--Create the needed hook objects and add the functions that handle executing
	--the active passive effects
	for hook,_ in pairs(modApiExt_internal.passiveWeaponData.possibleEffects) do 
		local hookObj = generatePassiveEffectHookFn(hook)
		local addHook = getAddFunctionForHook(hook)
		
		--supports hooks in both the ModLoader and the ModUtils
		if self[addHook] then
			self[addHook](self, hookObj)
		else --already asserted that its in one of the two
			modApi[addHook](modApi, hookObj)
		end
	end
end
		
return passiveWeapon