ModUtils_Dummy = {
	Name = "",
	Image = nil,
	Health = 100,
	MoveSpeed = 0,
	Pushable = false,
	Corpse = false,
	IgnoreFire = true,
	IgnoreSmoke = true,
	IgnoreFlip = true,
	Neutral = true,
	Corporate = false,
	IsPortrait = false,
	DefaultTeam = TEAM_PLAYER,
	GetDangerScore = function() return 0 end
}
AddPawn("ModUtils_Dummy")

--------------------------------------------------------------------------

--[[
	Sets the pawn on fire if true, or removes the Fire status from it if false.
]]--
function SetFire(pawn, fire)
	local d = SpaceDamage()
	if fire then d.iFire = EFFECT_CREATE else d.iFire = EFFECT_REMOVE end
	DamagePawn(pawn, d)
end

--[[
	Damages the specified pawn using the specified SpaceDamage instance, without
	causing any side effects to the board (unless setting the Pawn on fire, and
	it is standing in a forest -- Pawns on fire set forests ablaze as soon as they
	move onto them.)
	The SpaceDamage's loc attribute is overwritten by this function.

	pawn
		The pawn to damage
	spaceDamage
		SpaceDamage instance to deal to the pawn.
]]--
function DamagePawn(pawn, spaceDamage)
	local wasOnBoard = IsPawnOnBoard(pawn)

	local pawnSpace = pawn:GetSpace()
	local safeSpace = GetUnoccupiedRestorableSpace()

	local terrainData = GetRestorableTerrainData(safeSpace)

	if not wasOnBoard then
		Board:AddPawn(pawn, safeSpace)
	end
	pawn:SetSpace(safeSpace)

	spaceDamage.loc = safeSpace
	Board:DamageSpace(spaceDamage)

	pawn:SetSpace(pawnSpace)
	RestoreTerrain(safeSpace, terrainData)

	if not wasOnBoard then Board:RemovePawn(pawn) end
end

--[[
	Attempts to copy state from source pawn to the target pawn.
]]--
function CopyPawnState(sourcePawn, targetPawn)
	local spaceDamage = SpaceDamage()
	spaceDamage.iDamage = targetPawn:GetHealth() - sourcePawn:GetHealth()

	DamagePawn(targetPawn, spaceDamage)

	if sourcePawn:IsFire() then SetFire(targetPawn, true) end
	if sourcePawn:IsFrozen() then targetPawn:SetFrozen(true) end
	if sourcePawn:IsAcid() then targetPawn:SetAcid(true) end
	if sourcePawn:IsShield() then targetPawn:SetShield(true) end
end
