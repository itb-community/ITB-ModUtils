local modApiExtHooks = {}

function modApiExtHooks:trackAndUpdatePawns(mission)
	if Board then
		if not GAME.trackedPawns then GAME.trackedPawns = {} end
		-- pawn userdata cannot be serialized, so store them in a separate
		-- table that is rebuilt at runtime.
		if not modApiExt_internal.pawns then modApiExt_internal.pawns = {} end

		local tbl = extract_table(Board:GetPawns(TEAM_ANY))

		-- Store information about pawns which should remain on the board,
		-- we can use this data later.
		local onBoard = {}

		-- If any of the tracked pawns were removed from the board, reinsert
		-- them into the table, to process them correctly.
		for id, pd in pairs(GAME.trackedPawns) do
			if not list_contains(tbl, id) then
				onBoard[id] = false
				table.insert(tbl, id)
			end
		end

		for i, id in pairs(tbl) do
			local pd = GAME.trackedPawns[id]
			local pawn = Board:GetPawn(id)

			if pawn and not modApiExt_internal.pawns[id] then
				-- regenerate pawn userdata table
				modApiExt_internal.pawns[id] = pawn
			elseif not pawn and modApiExt_internal.pawns[id] then
				pawn = modApiExt_internal.pawns[id]
			end

			if not pd and pawn then
				-- Pawn is not tracked yet
				-- Create a pawnData table for it
				GAME.trackedPawns[id] = {
					loc = pawn:GetSpace(),
					maxHealth = _G[pawn:GetType()].Health,
					curHealth = pawn:GetHealth(),
					dead = (pawn:GetHealth() == 0),
					selected = false,
					undoPossible = pawn:IsUndoPossible()
				}

				for i, hook in ipairs(self.pawnTrackedHooks) do
					hook(mission, pawn)
				end
			elseif pd and pawn then
				-- Already tracked, update its data
				local p = pawn:GetSpace()
				local undo = pawn:IsUndoPossible()

				if pd.undoPossible ~= undo then
					-- Undo was possible in previous game update, but no longer is.
					-- The pawn is also active, which means that the player did not
					-- just attack with this pawn.
					-- And positions are not the same, which means that the player
					-- did not attack with another pawn. Swap weapons are not instant,
					-- so it should be fine.
					-- TODO: Maybe update when we have pawnAttackStart/EndHook
					if pd.undoPossible and not undo and pawn:IsActive() and pd.loc ~= p then
						for i, hook in ipairs(self.pawnUndoMoveHooks) do
							hook(mission, pawn, pd.loc)
						end
					end

					pd.undoPossible = undo
				end

				if pd.loc ~= p then
					for i, hook in ipairs(self.pawnPositionChangedHooks) do
						hook(mission, pawn, pd.loc)
					end
					pd.loc = p
				end

				local oldHealth = pd.curHealth
				pd.curHealth = pawn:GetHealth()
				local diff = pd.curHealth - oldHealth

				if diff < 0 then
					-- took damage
					for i, hook in ipairs(self.pawnDamagedHooks) do
						hook(mission, pawn, -diff)
					end
				elseif diff > 0 then
					-- healed
					for i, hook in ipairs(self.pawnHealedHooks) do
						hook(mission, pawn, diff)
					end
				end

				-- Deselection
				if pd.selected and not pawn:IsSelected() then
					pd.selected = false
					for i, hook in ipairs(self.pawnDeselectedHooks) do
						hook(mission, pawn)
					end
				end
			else
				-- Not tracked yet, but pawn was nil? Some bizarre edge case.
				-- Can't do anything with this, ignore.
			end
		end

		for id, pd in pairs(GAME.trackedPawns) do
			-- Process selection in separate loop, so that callbacks always go
			-- Deselection -> Selection, instead of relying on pawn order in table
			local pawn = Board:GetPawn(id) or modApiExt_internal.pawns[id]
			if pawn then
				if pawn:IsSelected() and not pd.selected then
					pd.selected = true
					for i, hook in ipairs(self.pawnSelectedHooks) do
						hook(mission, pawn)
					end
				end
			end

			if not pd.dead and pd.curHealth == 0 then
				pd.dead = true
				for i, hook in ipairs(self.pawnKilledHooks) do
					hook(mission, pawn)
				end
			end

			-- Treat pawns not registered in the onBoard table as on board.
			local wasOnBoard = onBoard[id] or onBoard[id] == nil
			if not wasOnBoard then
				-- Dead non-player pawns are removed from the board, so we can
				-- just remove them from tracking since they're not going to
				-- come back to life.
				-- However, player pawns (mechs) stay on the board when
				-- dead. Don't remove them from the tracking table, since if we
				-- do that, they're going to get reinserted.
				GAME.trackedPawns[id] = nil
				modApiExt_internal.pawns[id] = nil

				for i, hook in ipairs(self.pawnUntrackedHooks) do
					hook(mission, pawn)
				end
			end
		end
	end
end

function modApiExtHooks:trackAndUpdateBuildings(mission)
	if Board then
		if not GAME.trackedBuildings then GAME.trackedBuildings = {} end

		local tbl = extract_table(Board:GetBuildings())

		local w = Board:GetSize().x
		for i, point in pairs(tbl) do
			local idx = point.y * w + point.x
			if not GAME.trackedBuildings[idx] then
				-- Building not tracked yet
				local bld = {
					loc = point,
					destroyed = false,
					--maxHealth = -1, -- NO WAY TO FIND OUT
					--curHealth = -1, -- NO WAY TO FIND OUT
					--dummy = nil,
					--lastHealth = -1
				}
--[[
				local id = Board:AddPawn("ModUtils_Dummy", point)
				bld.dummy = Board:GetPawn(id)
				bld.dummy:SetInvisible(true)
				bld.lastHealth = bld.dummy:GetHealth()
--]]
				GAME.trackedBuildings[idx] = bld
			else
				-- Already tracked, update its data...
				-- ...if there were any
			end
		end

		for idx, bld in pairs(GAME.trackedBuildings) do
			if not bld.destroyed then
--[[
				local pawnId = bld.dummy:GetId()
				local pawn = Board:GetPawn(pawnId)

				-- Putting shield on a building with an invisible dummy
				-- on top of it will put the shield on the dummy.
				-- But since the dummy is invisible, the shield is also
				-- invisible (sound shield plays, correct pop text is
				-- shown, and damage is correctly blocked)
				pawn:SetInvisible(not pawn:IsShield())

				local diff = pawn:GetHealth() - bld.lastHealth
				if diff < 0 then
					bld.lastHealth = pawn:GetHealth()
					self:scheduleHook(50, function()
						if self.gridWasDrawn then
							for i, hook in ipairs(self.buildingResistHooks) do
								hook(mission, bld, -diff)
							end
						else

							for i, hook in ipairs(self.buildingDamagedHooks) do
								hook(mission, bld, -diff)
							end
						end
					end)
				end
--]]

				if not Board:IsBuilding(bld.loc) then
					bld.destroyed = true
--[[
					bld.dummy:Kill(true)
					Board:RemovePawn(bld.dummy)
--]]
					for i, hook in ipairs(self.buildingDestroyedHooks) do
						hook(mission, bld)
					end

					--bld.dummy = nil
				end
			end
		end
	end
end

function modApiExtHooks:updateTiles()
	if Board then
		local mtile = mouseTile()
		if self.currentTile ~= mtile then
			if self.currentTile then -- could be nil
				for i, hook in ipairs(self.tileUnhighlightedHooks) do
					hook(mission, self.currentTile)
				end
			end

			self.currentTile = mtile

			if self.currentTile then -- could be nil
				for i, hook in ipairs(self.tileHighlightedHooks) do
					hook(mission, self.currentTile)
				end
			end
		end
	end
end

function modApiExtHooks:processRunLater(mission)
	if modApiExt_internal.runLaterQueue then
		local q = modApiExt_internal.runLaterQueue
		local n = #q
		for i = 1, n do
			q[i](mission)
			q[i] = nil
		end

		-- compact the table, if processed hooks also scheduled
		-- their own runLater functions (but we will process those
		-- on the next update step)
		local i = n + 1
		local j = 0
		while q[i] do
			j = j + 1
			q[j] = q[i]
			q[i] = nil
			i = i + 1
		end
	end
end

--[[
	Overrides the default Move skill to implement pawnMoveStart/End hooks.
	Can optionally provide your own Move skill as argument to this function
	in case some non-standard Move skill chaining is required.
--]]
function modApiExtHooks:overrideMoveSkill(oldMoveSkill)
	if not modApiExt_internal.oldMoveEffect or oldMoveSkill then
		modApiExt_internal.oldMoveEffect = (oldMoveSkill and oldMoveSkill.GetSkillEffect)
			or Move.GetSkillEffect

		Move.GetSkillEffect = function(slf, p1, p2)
			local tmp = SkillEffect()

			tmp:AddScript("modApiExt_internal.fireMoveStartHooks(modApiExt_internal.mission, Pawn)")

			local moveFx = modApiExt_internal.oldMoveEffect(slf, p1, p2)
			for i, e in pairs(extract_table(moveFx.effect)) do
				tmp.effect:push_back(e)
			end

			tmp:AddScript("modApiExt_internal.fireMoveEndHooks(modApiExt_internal.mission, Pawn)")

			moveFx.effect = tmp.effect
			return moveFx
		end
	end
end

function modApiExtHooks:overrideSkill(id, skill)
	assert(skill.GetSkillEffect)
	assert(_G[id] == skill) -- no fun allowed

	if modApiExt_internal.oldSkills[id] then
		error(id .. " is already overridden!")
	end

	modApiExt_internal.oldSkills[id] = skill.GetSkillEffect

	skill.GetSkillEffect = function(slf, p1, p2)
		local skillFx = modApiExt_internal.oldSkills[id](slf, p1, p2)

		modApiExt_internal.fireSkillBuildHook(
			modApiExt_internal.mission,
			Pawn, id, p1, p2, skillFx
		)

		if not skillFx.effect:empty() then
			local tmp = SkillEffect()

			tmp:AddScript("modApiExt_internal.fireSkillStartHook("
				.."modApiExt_internal.mission, Pawn,"
				.."unpack("..save_table({id, p1, p2}).."))"
			)

			for _, e in pairs(extract_table(skillFx.effect)) do
				tmp.effect:push_back(e)
			end

			tmp:AddScript("modApiExt_internal.fireSkillEndHook("
				.."modApiExt_internal.mission, Pawn,"
				.."unpack("..save_table({id, p1, p2}).."))"
			)
			skillFx.effect = tmp.effect
		end

		if not skillFx.q_effect:empty() then
			local tmp = SkillEffect()
			tmp:AddScript("modApiExt_internal.fireQueuedSkillStartHook("
				.."modApiExt_internal.mission, Pawn,"
				.."unpack("..save_table({id, p1, p2}).."))"
			)

			for _, e in pairs(extract_table(skillFx.q_effect)) do
				tmp.effect:push_back(e)
			end

			tmp:AddScript("modApiExt_internal.fireQueuedSkillEndHook("
				.."modApiExt_internal.mission, Pawn,"
				.."unpack("..save_table({id, p1, p2}).."))"
			)
			skillFx.q_effect = tmp.effect
		end

		return skillFx
	end
end

function modApiExtHooks:overrideAllSkills()
	if not modApiExt_internal.oldSkills then
		modApiExt_internal.oldSkills = {}

		for k, v in pairs(_G) do
			if type(v) == "table" and v.GetSkillEffect then
				if not list_contains(modApiExt_internal.skillBlacklist, k) then
					self:overrideSkill(k, v)
				end
			end
		end
	end
end

function modApiExtHooks:reset()
	GAME.trackedBuildings = nil
	GAME.trackedPawns = nil
	modApiExt_internal.pawns = nil
	modApiExt_internal.mission = nil
	modApiExt_internal.runLaterQueue = nil
	GAME.elapsedTime = nil
	modApiExt_internal.elapsedTime = nil
end

---------------------------------------------

modApiExtHooks.preMissionStart = function(mission)
end

modApiExtHooks.missionStart = function(mission)
	modApiExtHooks:reset()
end

modApiExtHooks.missionEnd = function(mission, ret)
	modApiExtHooks:reset()
end

modApiExtHooks.missionUpdate = function(mission)
	-- Store the mission for use by other hooks which can't be called from
	-- the missionUpdate hook.
	-- Set it here, in case we load into a game in progress (missionStart
	-- is not executed then)
	if not modApiExt_internal.mission and mission then modApiExt_internal.mission = mission end

	if
		GAME.elapsedTime and modApiExt_internal.elapsedTime and
		GAME.elapsedTime < modApiExt_internal.elapsedTime
	then
		-- Stored time is less than the timer, so we went back into the past.

		-- Shouldn't trigger on game load, because when we load, the time saved
		-- in GAME won't be nil, but the one saved in modApiExt_internal *will*.
		-- And we synchronize them right after that, so they can't diverge.

		-- Also shouldn't trigger when drawing UI which halts the game, since
		-- both variables are updated together.

		modApiExt_internal.fireResetTurnHook(mission)
	end
	local t = modApiExt_internal.timer:elapsed()
	GAME.elapsedTime = t
	modApiExt_internal.elapsedTime = t

	modApiExtHooks:processRunLater(mission)
	modApiExtHooks:updateTiles()
	modApiExtHooks:trackAndUpdateBuildings(mission)
	modApiExtHooks:trackAndUpdatePawns(mission)
end

return modApiExtHooks
