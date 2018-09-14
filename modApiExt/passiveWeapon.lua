--set this to true if you are having issues with running passive weapons to help determine what is going wrong
local addPassiveEffectDebug = true

local passiveWeapon = {}

passiveWeapon.possibleEffectsData = {}
passiveWeapon.activeEffectsData = {}
passiveWeapon.selfModApiExt = {}

--pulled from pawn(?) modUtil - remove
local function getUpgradeSuffix(wtable)
	if
		wtable.upgrade1 and wtable.upgrade1[1] > 0 and
		wtable.upgrade2 and wtable.upgrade2[1] > 0
	then
		return "_AB"
	elseif wtable.upgrade1 and wtable.upgrade1[1] > 0 then
		return "_A"
	elseif wtable.upgrade2 and wtable.upgrade2[1] > 0 then
		return "_B"
	end

	return ""
end

--useful wrapper function put in weapon
local function getWeaponNameWithUpgrade(weaponTable)
	return weaponTable.id..getUpgradeSuffix(weaponTable)
end

--useful function put in weapon
local function isWeaponPowered(weaponTable)
	--Check that all numbers are greater than 0
	--I think you really only need to check the first but just to be safe I check them all
	for _,power in pairs(weaponTable.power) do
		if power <= 0 then
			return false
		end
	end
	
	--empty means it needs no power so its always on!
	return true
end

--Modification of the pawn:getData - put in board
function passiveWeapon:getAllMechsTables(sourceTable)
	mechsData = {}
	if sourceTable then
		for k, v in pairs(sourceTable) do
			if type(v) == "table" and v.mech and modApi:stringStartsWith(k, "pawn") then
				mechsData[#mechsData+1] = v
			end
		end	
		
		if #mechsData > 0 then
			return mechsData
		end
	else
		local region = self.board:getCurrentRegion()
		local ptable = self:getAllMechsTables(SquadData)
		if not ptable and region then
			ptable = self:getAllMechsTables(region.player.map_data)
		end

		return ptable
	end

	return nil
end

function passiveWeapon:addPassiveWeapon(weapon, passiveEffect, hook)
	hook = hook or "addPostEnvironmentHook"
	assert(type(hook) == "string")
	assert(modApi:stringStartsWith(hook, "add"))
	assert(self[hook] or modApi[hook])
	
	assert(type(weapon) == "string")
	assert(type(passiveEffect) == "string")
	
	--ensure they are valid weapon/effect combo
	assert(_G[weapon])
	assert(_G[weapon][passiveEffect])
	
	local hookTable = self.possibleEffectsData[hook]
	if not hookTable then
		hookTable = {}
		self.possibleEffectsData[hook] = hookTable
	end
	
	local data = {}
	data.weapon = weapon
	data.effect = passiveEffect
	table.insert(hookTable, data)
end

function passiveWeapon:checkAndAddIfPassive(weaponTable)
	--for each passive weapon registered, check the id and if it matched then add the effect to
	--the list of effects to execute
	for hook, possibleEffects in pairs(self.possibleEffectsData) do
		if addPassiveEffectDebug then LOG("Checking passive weapons for hook: "..hook) end
		for i, pEffectTable in pairs(possibleEffects) do
			if addPassiveEffectDebug then LOG("Checking known passive weapon id: "..pEffectTable.weapon) end
			if weaponTable.id == pEffectTable.weapon then
				local wName = getWeaponNameWithUpgrade(weaponTable)
				if addPassiveEffectDebug then LOG("FOUND PASSIVE WEAPON!: "..wName) end
				local wObj = _G[wName]
				local wEffect = wObj[pEffectTable.effect]
				
				if isWeaponPowered(weaponTable) then
					if addPassiveEffectDebug then LOG("And it is active/powered") end
					local hookTable = self.activeEffectsData[hook]
					if not hookTable then
						hookTable = {}
						self.activeEffectsData[hook] = hookTable
					end
					
					local data = {}
					data.weapon = wObj
					data.effect = wEffect
					table.insert(hookTable, data)
				elseif addPassiveEffectDebug then 
					LOG("but it is not active(powered)...")
				end
			end
		end
	end
end

function passiveWeapon.determineIfPassivesAreActive(mission)
	if addPassiveEffectDebug then LOG("Determining what Passive Effects are active(powered)...") end

	--clear the previous list
	passiveWeapon.activeEffectsData = {}
	
	--loop through the player mechs to see if they have one of the passive weapons equiped and powered
	local mechsData = passiveWeapon:getAllMechsTables()
	for _, mechData in pairs(mechsData) do
		if addPassiveEffectDebug then LOG("Checking mech: "..mechData.type) end
		--get the mech's weapon data
		local primary = passiveWeapon.pawn:getWeaponData(mechData, "primary")
		local secondary = passiveWeapon.pawn:getWeaponData(mechData, "secondary")
	
		--if it has a primary then check if it is in the passive effects list
		if primary.id then
			if addPassiveEffectDebug then LOG("Checking primary weapon: "..primary.id) end
			passiveWeapon:checkAndAddIfPassive(primary)
		end
		
		--if it has a secondary then check if it is in the passive effects list
		if secondary.id then
			if addPassiveEffectDebug then LOG("Checking secondary weapon: "..secondary.id) end
			passiveWeapon:checkAndAddIfPassive(secondary)
		end
	end
end

function generatePassiveEffectHookFn(hook)
	local genericHookObj = {}
	genericHookObj.storedHook = hook
	genericHookObj.storedPassiveWeapon = passiveWeapon
	
	genericHookObj.hookFunction = function(...)
		LOG("Evaluating "..#genericHookObj.storedPassiveWeapon.activeEffectsData[genericHookObj.storedHook].." active(powered) passive effects for hook: "..hook)
		for _,effectWeaponTable in pairs(genericHookObj.storedPassiveWeapon.activeEffectsData[genericHookObj.storedHook]) do
			effectWeaponTable.effect(effectWeaponTable.weapon, ...)
		end
	end
	
	return genericHookObj
end

function passiveWeapon:load()
	modApi:addMissionStartHook(self.determineIfPassivesAreActive) --covers starting a new mission
	modApi:addPostLoadGameHook(self.determineIfPassivesAreActive) --covers loading into (continuing) a mission
	
	--Create the needed hooks
	for hook,_ in pairs(self.possibleEffectsData) do 
		local hookObj = generatePassiveEffectHookFn(hook)
		
		if self[hook] then
			self[hook](self, hookObj.hookFunction)
		else --already asserted that its in one of the two
			modApi[hook](modApi, hookObj.hookFunction)
		end
	end
end
		
return passiveWeapon