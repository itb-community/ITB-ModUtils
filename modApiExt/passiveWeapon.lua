--set this to true if you are having issues with running passive weapons to help determine what is going wrong
local addPassiveEffectDebug = false

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
		local region = self.selfModApiExt.board:getCurrentRegion()
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
	assert(self.selfModApiExt[hook] or modApi[hook])
	
	assert(type(weapon) == "string")
	assert(type(passiveEffect) == "string")
	
	--ensure they are valid weapon/effect combo
	assert(_G[weapon])
	assert(_G[weapon][passiveEffect])
	
	local hookTable = self.possibleEffectsData[hook]
	if not hookTable then
		hookTable = {}
		passiveWeapon.possibleEffectsData[hook] = hookTable
	end
	
	local data = {}
	data.weapon = weapon
	data.effect = passiveEffect
	table.insert(hookTable, data)
end

function passiveWeapon.checkAndAddIfPassive(weaponTable)
	--for each passive weapon registered, check the id and if it matched then add the effect to
	--the list of effects to execute
	for hook, possibleEffects in pairs(passiveWeapon.possibleEffectsData) do
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
					local hookTable = passiveWeapon.activeEffectsData[hook]
					if not hookTable then
						hookTable = {}
						passiveWeapon.activeEffectsData[hook] = hookTable
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

passiveWeapon.determineIfPassivesAreActive = function(mission)
	if addPassiveEffectDebug then LOG("Determining what Passive Effects are active(powered)...") end

	--clear the previous list
	passiveWeapon.activeEffectsData = {}
	
	--loop through the player mechs to see if they have one of the passive weapons equiped and powered
	local mechsData = passiveWeapon:getAllMechsTables()
	for _, mechData in pairs(mechsData) do
		if addPassiveEffectDebug then LOG("Checking mech: "..mechData.type) end
		--get the mech's weapon data
		local primary = passiveWeapon.selfModApiExt.pawn:getWeaponData(mechData, "primary")
		local secondary = passiveWeapon.selfModApiExt.pawn:getWeaponData(mechData, "secondary")
	
		--if it has a primary then check if it is in the passive effects list
		if primary.id then
			if addPassiveEffectDebug then LOG("Checking primary weapon: "..primary.id) end
			passiveWeapon.checkAndAddIfPassive(primary)
		end
		
		--if it has a secondary then check if it is in the passive effects list
		if secondary.id then
			if addPassiveEffectDebug then LOG("Checking secondary weapon: "..secondary.id) end
			passiveWeapon.checkAndAddIfPassive(secondary)
		end
	end
end

function passiveWeapon:load(modUtil)
	self.selfModApiExt = modUtil
	modApi:addMissionStartHook(self.determineIfPassivesAreActive)
	modApi:addPostLoadGameHook(self.determineIfPassivesAreActive)
	
	--Add the needed hooks
	for hook,_ in pairs(self.possibleEffectsData) do 
		local fnString = 		"return function(...)\n"
		if addPassiveEffectDebug then
			fnString = fnString..	"\tLOG(\"Evaluating \"..#passiveWeapon.activeEffectsData[\""..hook.."\"]..\" active(powered)passive effects for hook: "..hook.."\")\n"
		end
		fnString = fnString..		"\tfor _,effectWeaponTable in pairs(passiveWeapon.activeEffectsData[\""..hook.."\"]) do\n"..
										"\t\teffectWeaponTable.effect(effectWeaponTable.weapon, ...)\n"..
									"\tend\n"..
								"end"
		if addPassiveEffectDebug then 
			LOG("Creating passive effect for hook "..hook.." -\n"..fnString)
		end
		
		local hookFn = loadstring(fnString)()
		
		if self.selfModApiExt[hook] then
			self.selfModApiExt[hook](self.selfModApiExt, hookFn)
		else --already asserted that its in one of the two
			modApi[hook](modApi, hookFn)
		end
	end
end
		
return passiveWeapon