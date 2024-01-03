
local hooks = {
	"resetTurn",
	"gameLoaded",
	"tileDirectionChanged",
	"tileHighlighted",
	"tileUnhighlighted",
	"pawnTracked",
	"pawnUntracked",
	"pawnMoveStart",
	"pawnMoveEnd",
	"vekMoveStart",
	"vekMoveEnd",
	"pawnPositionChanged",
	"pawnUndoMove",
	"pawnSelected",
	"pawnDeselected",
	"pawnDamaged",
	"pawnHealed",
	"pawnKilled",
	"pawnRevived",
	"pawnIsFire",
	"pawnIsAcid",
	"pawnIsFrozen",
	"pawnIsGrappled",
	"pawnIsShielded",
	"pawnIsBoosted",
	"buildingDamaged",
	"buildingResist",
	"buildingDestroyed",
	"buildingShield",
	"skillStart",
	"skillEnd",
	"queuedSkillStart",
	"queuedSkillEnd",
	"skillBuild",
	"finalEffectStart",
	"finalEffectEnd",
	"queuedFinalEffectStart",
	"queuedFinalEffectEnd",
	"finalEffectBuild",
	"targetAreaBuild",
	"secondTargetAreaBuild",
	"tipImageShown",
	"tipImageHidden",
	"podDetected",
	"podLanded",
	"podTrampled",
	"podDestroyed",
	"podCollected",
	"mostRecentResolved",
}

function hooks:addTo(modApiExt)
	if modApiExt.events == nil then
		modApiExt.events = {}
	end

	local events = modApiExt.events

	for _, name in ipairs(self) do
		local Name = name:gsub("^.", string.upper) -- capitalize first letter
		local name = name:gsub("^.", string.lower) -- lower case first letter

		local hookId = name.."Hooks"
		local eventId = "on"..Name
		local addHook = "add"..Name.."Hook"

		events[eventId] = Event()

		modApiExt[hookId] = {}
		modApiExt[addHook] = function(self, fn)
			assert(type(fn) == "function")
			table.insert(self[hookId], fn)
		end

		-- functions to fire the hooks are built in internal.lua
	end
end

return hooks
