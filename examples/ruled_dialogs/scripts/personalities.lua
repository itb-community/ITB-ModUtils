-- All dialogs need to be defined in each pilot's Personality table.
-- These entries are later referenced in the dialogs proper.
Personality["Warrior"]["MoveNextTo"] = "Pilot #target_last, I am calculating optimal path to reach the Vek threat. Refrain from introducing changes in your current location."
Personality["Archive"]["MoveNextTo_Response"] = "I gotchu, fam. #self_mech, standing by."
Personality["Rust"]["MoveNextTo_Response"] = "I gotchu, fam. #self_mech, standing by."
Personality["Detritus"]["MoveNextTo_Response"] = "I gotchu, fam. #self_mech, standing by."
Personality["Pinnacle"]["MoveNextTo_Response"] = "[ Positional delta has been logged. Suppressing #self_mech motors. ]"

for k, v in pairs(Personality) do
	v["PrimePunch_Falcon"] = "FALCOOOOON PUNCH!"
	v["PrimePunch_Falcon_Response"] = "...Please stop saying that."
end

--[[
	{id} is either main, self, target, or other
	self always refers to the Personality speaking

	#{id}_mech    -- inserts name of the mech
	#{id}_reverse -- reverse name of the pilot?
	#{id}_first   -- first name of the pilot
	#{id}_second  -- second (last) name of the pilot
	#{id}_last    -- same as _second
	#{id}_full    -- both first and last name of the pilot
	#squad        -- name of the squad
	#ceo_full     -- full name of the CEO
	#ceo_first    -- first name of the CEO
	#ceo_last     -- last name of the CEO
	#ceo_second   -- last name of the CEO
	#corporation  -- name of the corp
	#corp         -- name of the corp
	#saved_corp   -- ??
--]]
