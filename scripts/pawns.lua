ModUtils_Dummy = {
	Name = "",
	Image = nil,
	Health = 100,
	MoveSpeed = 0,
	Pushable = false,
	ScoreDanger = 0, -- don't modify the tile's score.
	Corpse = false,
	IgnoreFire = true,
	IgnoreSmoke = true,
	IgnoreFlip = true,
	Neutral = true,
	Corporate = false,
	IsPortrait = false,
	SpaceColor = false,
	DefaultTeam = TEAM_PLAYER,
	GetDangerScore = function() return 0 end
}
AddPawn("ModUtils_Dummy")

--------------------------------------------------------------------------

if not modApiExt.pawn then modApiExt.pawn = {} end

--[[
	Sets the pawn on fire if true, or removes the Fire status from it if false.
--]]
function modApiExt.pawn:setFire(pawn, fire)
	local d = SpaceDamage()
	if fire then d.iFire = EFFECT_CREATE else d.iFire = EFFECT_REMOVE end
	self:damagePawn(pawn, d)
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
--]]
function modApiExt.pawn:damagePawn(pawn, spaceDamage)
	local wasOnBoard = modApiExt.board:isPawnOnBoard(pawn)

	local pawnSpace = pawn:GetSpace()
	local safeSpace = modApiExt.board:getUnoccupiedRestorableSpace()

	local terrainData = modApiExt.board:getRestorableTerrainData(safeSpace)

	if not wasOnBoard then
		Board:AddPawn(pawn, safeSpace)
	end
	pawn:SetSpace(safeSpace)

	spaceDamage.loc = safeSpace
	Board:DamageSpace(spaceDamage)

	pawn:SetSpace(pawnSpace)
	modApiExt.board:RestoreTerrain(safeSpace, terrainData)

	if not wasOnBoard then Board:RemovePawn(pawn) end
end

--[[
	Attempts to copy state from source pawn to the target pawn.
--]]
function modApiExt.pawn:copyPawnState(sourcePawn, targetPawn)
	if sourcePawn:GetHealth() < targetPawn:GetHealth() then
		local spaceDamage = SpaceDamage()
		spaceDamage.iDamage = targetPawn:GetHealth() - sourcePawn:GetHealth()

		self:damagePawn(targetPawn, spaceDamage)
	end

	if sourcePawn:IsFire() then self:setFire(targetPawn, true) end
	if sourcePawn:IsFrozen() then targetPawn:SetFrozen(true) end
	if sourcePawn:IsAcid() then targetPawn:SetAcid(true) end
	if sourcePawn:IsShield() then targetPawn:SetShield(true) end
end

--[[
	Replaces the pawn with another one of the specified type.

	targetPawn
		The Pawn instance to replace.
	newPawnType
		Name of the pawn class to create the pawn from.
--]]
function modApiExt.pawn:replacePawn(targetPawn, newPawnType)
	local newPawn = PAWN_FACTORY:CreatePawn(newPawnType)

	newPawn:SetInvisible(true)
	newPawn:SetActive(targetPawn:IsActive())

	Board:AddPawn(newPawn, targetPawn:GetSpace())
	self:copyPawnState(targetPawn, newPawn)
	Board:RemovePawn(targetPawn)

	modApiExt:runLater(function() newPawn:SetInvisible(false) end)
end

function modApiExt.pawn:isPawnDead(pawn)
	if pawn:IsPlayer() and pawn:IsMech() then
		return pawn:GetHealth() == 0 or pawn:IsDead()
	elseif pawn:GetHealth() == 0 or not modApiExt.board:isPawnOnBoard(pawn) then
		return true
	end

	return false
end
