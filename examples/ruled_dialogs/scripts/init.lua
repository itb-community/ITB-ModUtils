local function example_addVoice1()
	kf_RDE_modApiExt:addSkillStartHook(function(mission, pawn, weaponId, p1, p2)
		-- checking for Board.gameBoard prevents the voice event from being
		-- triggered by TipImages
		if weaponId == "Prime_Punchmech" and Board.gameBoard then
			-- Trigger the dialog event, and setup the cast information
			-- since we know the pawn that executes the skill, so we set
			-- it as `main`.
			-- The system will then only consider dialogs with rules which
			-- this pawn matches
			local id = pawn:GetId()
			local cast = { main = id }

			if Board:IsPawnSpace(p2) then
				cast.target = Board:GetPawn(p2):GetId()
			end

			kf_RDE_modApiExt.dialog:triggerRuledDialog("PrimePunch_Start", cast)
		end
	end)
end

local function example_addVoice2()
	kf_RDE_modApiExt:addSkillBuildHook(function(mission, pawn, weaponId, p1, p2, skillEffect)
		-- checking for Board.gameBoard prevents the voice event from being
		-- triggered by TipImages
		if weaponId == "Prime_Punchmech" and Board.gameBoard then
			skillEffect:AddVoice("PrimePunch_Start", pawn:GetId())
		end
	end)
end

local function init(self)
end

local function load(self, options, version)
	--[[
		This code fetches the most recent version of modApiExt available among
		currently installed mods. This is not part of the example, and generally
		you should NOT be doing this in your mod (because it assumes that there's
		another modApiExt mod which finished loading before us)
	--]]
	kf_RDE_modApiExt = modApiExt_internal.extObjects[1]
	if kf_RDE_modApiExt then
		kf_RDE_modApiExt = kf_RDE_modApiExt:getMostRecent()
		if modApi:isVersion("1.8", kf_RDE_modApiExt.version) then
			kf_RDE_modApiExt:load(self, options, version)
		else
			error("Can't load example, because the most recent version of modApiExt installed is too out of date (need version 1.8)")
		end
	else
		error("Can't load example, because no instance of modApiExt is loaded")
	end
	----------------

	-- adds new dialog lines to personalities:
	require(self.scriptPath.."personalities")
	-- registers ruled dialogs:
	require(self.scriptPath.."dialogs")

	-- The primary way to trigger voice events is shown in this function
	example_addVoice1()

	-- But you can also do it the way shown in this function, using the game's
	-- own functionality
	-- But it has the drawback of only being able to specify role for the main pawn.
	--example_addVoice2()
end

return {
	id = "kf_RuledDialogsExample",
	name = "modApiExt Ruled Dialogs Example",
	version = "1.0.0",
	requirements = { "kf_ModUtils" },
	init = init,
	load = load,
}
