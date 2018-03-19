local function init(self)
end

local function load(self,options,version)
	require(self.scriptPath.."global")
	require(self.scriptPath.."pawns")
	
	if modApiExt then
		modApiExt:clear()
	else
		-- could replace with dofile() instead, since we
		-- actually WANT to overwrite the old table?
		modApiExt = require(self.scriptPath.."modApiExt")
	end

	local hooks = require(self.scriptPath.."hooks")
	modApi:addPreMissionEndHook(hooks.preMissionStart)
	modApi:addMissionStartHook(hooks.missionStart)
	modApi:addMissionEndHook(hooks.missionEnd)
	modApi:addMissionUpdateHook(hooks.missionUpdate)

	modApiExt:addPawnDamagedHook(function(mission, pawnId, damageTaken)
		local pawn = Board:GetPawn(pawnId)
		if pawn:GetType() == "ModApi_Ext_Dummy" then
			LOG("Dummy pawn took " .. tostring(damageTaken) .. " damage!")
		end
	end)
end

return {
	id = "ModApi_Ext",
	name = "Extended ModApi",
	version = "1.0.0",
	requirements = {},
	init = init,
	load = load,
}