--[[
	This adds a ruled dialog which is executed when a mech piloted
	by Gana moves right next to another mech. This is a unique ruled dialog,
	which means it is exeucted only once during a playthrough.
--]]

-- "MoveEnd" is a dialog event we're registering to. For a complete list, see
-- somewhere around the middle of modApiExt.lua
kf_RDE_modApiExt.dialog:addRuledDialog("MoveEnd", {
	-- Odds that this dialog will be included in candidates list, ie. have
	-- a chance to appear. 100% doesn't guarantee the dialog will be shown,
	-- merely that it will be considered for display.
	-- Defaults to 100 if omitted.
	Odds = 100,
	-- Unique means that this dialog will only be shown once in a playthrough
	-- Defaults to false if omitted.
	Unique = true,
	-- Suppress means that if this dialog is triggered, it will prevent other
	-- dialogs (even the game's own) from appearing for this particular event
	-- instance.
	-- Defaults to true if omitted.
	Suppress = false,
	-- Rules for the pawn cast. The dialog will only fire if all of these match.
	-- If the cast doesn't have the role filled, then these rules act as a way to
	-- find a matching pawn among any available on the game board.
	-- These cast roles can later be referenced in the dialog entries below.
	-- Valid actor roles: main, target, other
	-- Can be omitted if no rules are desired.
	CastRules = {
		-- CastRules are just predicate functions which take a pawnId
		-- and cast table, and return true if the pawn matches the rule.
		-- Be aware that the `cast` argument is read-only and only contains
		-- entries for roles which have been evaluated thus far.
		-- Rules are evaluated in the order you specify them here.
		
		-- PersonalityRule is just syntactic sugar for a predicate
		-- function which takes a pawnId and makes sure its personality
		-- matches the one passed in argument.
		-- See end of modApiExt/dialogs.lua for more
		main = PersonalityRule("Warrior"),

		-- The rule below makes sure that the target of the dialog is a pawn
		-- next to which we finish our move.
		-- Note that we can reference `cast.main` here, because it has been
		-- evaluated above with PersonalityRule.
		target = function(pawnId, cast)
			local pawn = Game:GetPawn(pawnId)
			local p1 = pawn:GetSpace()
			local p2 = Game:GetPawn(cast.main):GetSpace()
			return pawn:IsMech() and not pawn:IsDead() and p1:Manhattan(p2) == 1
		end
	},

	-- Listed below are dialog entries in this ruled dialog.
	-- The game will pick one at random

	-- This creates an exchange between the `main` actor and the `target` actor
	Dialog(
		{ main = "MoveNextTo" },
		{ target = "MoveNextTo_Response" }
	),
	-- This creates a solo dialogue from `main` actor
	{ main = "MoveNextTo" }
})

-- Below is a simple dialog that is triggered every time a mech uses Prime Punch
kf_RDE_modApiExt.dialog:addRuledDialog("PrimePunch_Start", {
	Dialog(
		{ main = "PrimePunch_Falcon" },
		{ other = "PrimePunch_Falcon_Response" }
	)
})
