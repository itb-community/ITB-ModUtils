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

local pawn = {}

--[[
	Sets the pawn on fire if true, or removes the Fire status from it if false.
--]]
function pawn:setFire(pawn, fire)
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
function pawn:damagePawn(pawn, spaceDamage)
	local wasOnBoard = self.board:isPawnOnBoard(pawn)

	local pawnSpace = pawn:GetSpace()
	local safeSpace = self.board:getUnoccupiedRestorableSpace()

	local terrainData = self.board:getRestorableTerrainData(safeSpace)

	if not wasOnBoard then
		Board:AddPawn(pawn, safeSpace)
	end
	pawn:SetSpace(safeSpace)

	spaceDamage.loc = safeSpace
	Board:DamageSpace(spaceDamage)

	pawn:SetSpace(pawnSpace)
	self.board:RestoreTerrain(safeSpace, terrainData)

	if not wasOnBoard then Board:RemovePawn(pawn) end
end

--[[
	Attempts to copy state from source pawn to the target pawn.
--]]
function pawn:copyPawnState(sourcePawn, targetPawn)
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
function pawn:replacePawn(targetPawn, newPawnType)
	local newPawn = PAWN_FACTORY:CreatePawn(newPawnType)

	newPawn:SetInvisible(true)
	newPawn:SetActive(targetPawn:IsActive())

	Board:AddPawn(newPawn, targetPawn:GetSpace())
	self:copyPawnState(targetPawn, newPawn)
	Board:RemovePawn(targetPawn)

	self:runLater(function() newPawn:SetInvisible(false) end)
end

function pawn:isPawnDead(pawn)
	if pawn:IsPlayer() and pawn:IsMech() then
		return pawn:GetHealth() == 0 or pawn:IsDead()
	elseif pawn:GetHealth() == 0 or not self.board:isPawnOnBoard(pawn) then
		return true
	end

	return false
end

--[[
	Returns the pawn with the specified id. Works for pawns which
	may have been removed from the board.
--]]
function pawn:getById(pawnId)
	return Board:GetPawn(pawnId) or self.pawnUserdata[pawnId]
end

--[[
	Returns the currently selected pawn, or nil if none is selected.
--]]
function pawn:getSelected()
	-- just Pawn works as well -- but it stays set even after it is deselected.
	for id, pawn in pairs(modApiExt.pawnUserdata) do
		if pawn:IsSelected() then return pawn end
	end

	return nil
end

--[[
	Returns the currently highlighted pawn (the one the player is hovering his
	mouse cursor over).
--]]
function pawn:getHighlighted()
	return Board:GetPawn(mouseTile())
end

return pawn