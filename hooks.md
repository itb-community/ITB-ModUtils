# Table of Contents

* [resetTurnHook](#resetturnhook)
* [gameLoadedHook](#gameloadedhook)
* [tileHighlightedHook](#tilehighlightedhook)
* [tileUnhighlightedHook](#tileunhighlightedhook)
* [pawnTrackedHook](#pawntrackedhook)
* [pawnUntrackedHook](#pawnuntrackedhook)
* [pawnPositionChangedHook](#pawnpositionchangedhook)
* [pawnUndoMoveHook](#pawnundomovehook)
* [pawnSelectedHook](#pawnselectedhook)
* [pawnDeslectedHook](#pawndeslectedhook)
* [pawnDamagedHook](#pawndamagedhook)
* [pawnHealedHook](#pawnhealedhook)
* [pawnKilledHook](#pawnkilledhook)
* [pawnRevivedHook](#pawnrevivedhook)
* [pawnIsFireHook](#pawnisfirehook)
* [pawnIsAcidHook](#pawnisacidhook)
* [pawnIsFrozenHook](#pawnisfrozenhook)
* [pawnIsGrappledHook](#pawnisgrappledhook)
* [pawnIsShieldedHook](#pawnisshieldedhook)
* [vekMoveStartHook](#vekmovestarthook)
* [vekMoveEndHook](#vekmoveendhook)
* [buildingDestroyedHook](#buildingdestroyedhook)
* [skillStartHook](#skillstarthook)
* [skillEndHook](#skillendhook)
* [queuedSkillStartHook](#queuedskillstarthook)
* [queuedSkillEndHook](#queuedskillendhook)
* [skillBuildHook](#skillbuildhook)
* [finalEffectStartHook](#finalEffectStartHook)
* [finalEffectEndHook](#finalEffectEndHook)
* [queuedFinalEffectStartHook](#queuedFinalEffectStartHook)
* [queuedFinalEffectEndHook](#queuedFinalEffectEndHook)
* [finalEffectBuildHook](#finalEffectBuildHook)
* [targetAreaBuildHook](#targetAreaBuildHook)
* [secondTargetAreaBuildHook](#secondTargetAreaBuildHook)
* [tipImageShownHook](#tipimageshownhook)
* [tipImageHiddenHook](#tipimagehiddenhook)
* [podDetectedHook](#poddetectedhook)
* [podLandedHook](#podlandedhook)
* [podTrampledHook](#podtrampledhook)
* [podDestroyedHook](#poddestroyedhook)
* [podCollectedHook](#podcollectedhook)
* [mostRecentResolvedHook](#mostrecentresolvedhook)

Deprecated:
* [pawnMoveStartHook](#pawnmovestarthook)
* [pawnMoveEndHook](#pawnmoveendhook)


# Hooks

New hooks are added exactly the same way as in the base mod loader's `modApi`, except you have to reference the extended API object (`modApiExt`) instead, using whatever name you have decided to give it in your `init.lua`.


## `resetTurnHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |

Fired when the player uses the `Reset Turn` button.

Example:
```lua
local hook = function(mission)
	LOG("Turn was reset!")
end

modApiExt:addResetTurnHook(hook)
```


## `gameLoadedHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission. *This argument is nil if the player loads into strategy phase (island/region selection)* |

Fired when the player loads a game in progress, or starts a new one. If the loaded game state is during a mission, then the `mission` argument contains a reference to the mission instance. Otherwise it is `nil`, indicating that we loaded into the strategy phase (island/region selection).

Example:
```lua
local hook = function(mission)
	if mission then
		LOG("Game was loaded, and we're in combat!")
	else
		LOG("Game was loaded, we're selecting the next region!")
	end
end

modApiExt:addGameLoadedHook(hook)
```


## `tileHighlightedHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `point` | Point | The point / board tile that was highlighted |

Fired when the player moves their cursor over a board tile.

Example:
```lua
local hook = function(mission, point)
	LOG("Highlighted tile: " .. point:GetString())
end

modApiExt:addTileHighlightedHook(hook)
```


## `tileUnhighlightedHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `point` | Point | The point / board tile that was highlighted previously, but no longer is |

Fired when the player moves their cursor away from the previously highligthed tile.

Example:
```lua
local hook = function(mission, point)
	LOG("Unhighlighted tile: " .. point:GetString())
end

modApiExt:addTileUnhighlightedHook(hook)
```


## `pawnTrackedHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn that is being tracked |

Fired when `modApiExt` first becomes aware of the pawn and begins tracking it. This is usually at the very start of the mission (for pre-placed pawns), or as soon as the pawn is spawned on the board.

Example:
```lua
local hook = function(mission, pawn)
	LOG("Started tracking pawn: " .. pawn:GetMechName())
end

modApiExt:addPawnTrackedHook(hook)
```


## `pawnUntrackedHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn that is no longer being tracked |

Fired when `modApiExt` stops tracking a pawn (due to it being killed, or removed from the game board via `Board:RemovePawn()`). In vanilla game, player mechs are never removed from the board.

Example:
```lua
local hook = function(mission, pawn)
	LOG("Stopped tracking pawn: " .. pawn:GetMechName())
end

modApiExt:addPawnUntrackedHook(hook)
```


## `pawnMoveStartHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn that is starting to move |

Fired when a pawn begins moving. **ONLY WORKS FOR PLAYER MECHS**

**DEPRECATED**: Use `skillStartHook` instead.

Example:
```lua
local hook = function(mission, pawn)
	LOG(pawn:GetMechName() .. " is moving, start point: " .. pawn:GetSpace():GetString())
end

modApiExt:addPawnMoveStartHook(hook)
```


## `pawnMoveEndHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn that has finished moving |

Fired when a pawn finishes moving. **ONLY WORKS FOR PLAYER MECHS**

**DEPRECATED**: Use `skillEndHook` instead.

Example:
```lua
local hook = function(mission, pawn)
	LOG(pawn:GetMechName() .. " has finished moving, end point: " .. pawn:GetSpace():GetString())
end

modApiExt:addPawnMoveEndHook(hook)
```


## `pawnPositionChangedHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn whose position has changed |
| `oldPosition` | Point | The pawn's previous position |

Fired when a pawn's position is changed (either by moving, being pushed/flipped, or undoing move). For normal move or push, this is fired for every tile visibly traversed. For instantenous traversal (teleportation, leap, undo move, `pawn:SetSpace()`) this hook fires only once.

Example:
```lua
local hook = function(mission, pawn, oldPosition)
	LOG(pawn:GetMechName() .. " position changed from " .. oldPosition:GetString() .. " to " .. pawn:GetSpace():GetString())
end

modApiExt:addPawnPositionChangedHook(hook)
```


## `pawnUndoMoveHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn whose move was undone |
| `undonePosition` | Point | The pawn's position **before its move was undone** |

Fired when a pawn's move is undone.

Example:
```lua
local hook = function(mission, pawn, undonePosition)
	LOG(pawn:GetMechName() .. " move was undone! Was at: " .. undonePosition:GetString() .. ", returned to: " .. pawn:GetSpace():GetString())
end

modApiExt:addPawnUndoMoveHook(hook)
```


## `pawnSelectedHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn that was selected |

Fired when a pawn is selected by the player.

Example:
```lua
local hook = function(mission, pawn)
	LOG(pawn:GetMechName() .. " was selected!")
end

modApiExt:addPawnSelectedHook(hook)
```


## `pawnDeslectedHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn that was deselected |

Fired when a pawn is deselected by the player. Always fired before `pawnSelectedHook`.

Example:
```lua
local hook = function(mission, pawn)
	LOG(pawn:GetMechName() .. " was deselected!")
end

modApiExt:addPawnDeselectedHook(hook)
```


## `pawnDamagedHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn that was damaged |
| `damageTaken` | int | The amount of damage the pawn suffered (always greater than 0) |

Fired when a pawn's health is reduced (won't fire on shielded or completely blocked damage).

Example:
```lua
local hook = function(mission, pawn, damageTaken)
	LOG(pawn:GetMechName() .. " has taken " .. damageTaken .. " damage!")
end

modApiExt:addPawnDamagedHook(hook)
```


## `pawnHealedHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn that was healed |
| `healingTaken` | int | The amount of healing the pawn received (always greater than 0) |

Fired when a pawn's health is increased.

Example:
```lua
local hook = function(mission, pawn, healingTaken)
	LOG(pawn:GetMechName() .. " was healed for " .. healingTaken .. " damage!")
end

modApiExt:addPawnHealedHook(hook)
```


## `pawnKilledHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn that was killed |

Fired when a pawn's health is reduced to 0.

Example:
```lua
local hook = function(mission, pawn)
	LOG(pawn:GetMechName() .. " was killed!")
end

modApiExt:addPawnKilledHook(hook)
```


## `pawnRevivedHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn that was revived |

Fired when a dead pawn's health is restored to a value greater than 0.

Example:
```lua
local hook = function(mission, pawn)
	LOG(pawn:GetMechName() .. " was revived!")
end

modApiExt:addPawnRevivedHook(hook)
```


## `pawnIsFireHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn whose Fire status has changed |
| `isFire` | boolean | `true` if the Fire status was applied to the pawn, `false` if the status was removed |

Fired when a pawn is affected by or loses Fire status.

Example:
```lua
local hook = function(mission, pawn, isFire)
	if isFire then
		LOG(pawn:GetMechName() .. " has been set on fire.")
	else
		LOG(pawn:GetMechName() .. " has been extinguished.")
	end
end

modApiExt:addPawnIsFireHook(hook)
```


## `pawnIsAcidHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn whose ACID status has changed |
| `isAcid` | boolean | `true` if the ACID status was applied to the pawn, `false` if the status was removed |

Fired when a pawn is affected by or loses ACID status.

Example:
```lua
local hook = function(mission, pawn, isAcid)
	if isAcid then
		LOG(pawn:GetMechName() .. " has been affected by acid.")
	else
		LOG(pawn:GetMechName() .. " is no longer affected by acid.")
	end
end

modApiExt:addPawnIsAcidHook(hook)
```


## `pawnIsFrozenHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn whose Frozen status has changed |
| `isFrozen` | boolean | `true` if the Frozen status was applied to the pawn, `false` if the status was removed |

Fired when a pawn is affected by or loses Frozen status.

Example:
```lua
local hook = function(mission, pawn, isFrozen)
	if isFrozen then
		LOG(pawn:GetMechName() .. " has been frozen.")
	else
		LOG(pawn:GetMechName() .. " is no longer frozen.")
	end
end

modApiExt:addPawnIsFrozenHook(hook)
```


## `pawnIsGrappledHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn whose Grappled/Webbed status has changed |
| `isGrappled` | boolean | `true` if the Grappled/Webbed status was applied to the pawn, `false` if the status was removed |

Fired when a pawn is affected by or loses Grappled/Webbed status.

Example:
```lua
local hook = function(mission, pawn, isGrappled)
	if isGrappled then
		LOG(pawn:GetMechName() .. " has been grappled.")
	else
		LOG(pawn:GetMechName() .. " is no longer grappled.")
	end
end

modApiExt:addPawnIsGrappledHook(hook)
```


## `pawnIsShieldedHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn whose Shielded status has changed |
| `isShield` | boolean | `true` if the Shielded status was applied to the pawn, `false` if the status was removed |

Fired when a pawn is affected by or loses Shielded status.

Example:
```lua
local hook = function(mission, pawn, isShield)
	if isShield then
		LOG(pawn:GetMechName() .. " has been shielded.")
	else
		LOG(pawn:GetMechName() .. " is no longer shielded.")
	end
end

modApiExt:addPawnIsShieldedHook(hook)
```


## `vekMoveStartHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn whose Shielded status has changed |

Fired when a vek is selected during enemy turn and is about to start moving. Fires even if the vek decides to stay on the same tile.

Unfortunately, there's no way to predict where the vek are going to move, therefore this hook does not provide information about the vek's destination tile.

Example:
```lua
local hook = function(mission, pawn)
	LOG(pawn:GetMechName() .. " is moving, starting position: " .. pawn:GetSpace():GetString())
end

modApiExt:addVekMoveStartHook(hook)
```


## `vekMoveEndHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn whose Shielded status has changed |
| `startLoc` | Point | The tile the vek started moving from |
| `endLoc` | Point | The tile the vek stopped moving on |

Fired when a vek finishes moving and is about to queue up its attack. Fired even if the vek decides to stay on the same tile.

Example:
```lua
local hook = function(mission, pawn, startLoc, endLoc)
	LOG(pawn:GetMechName() .. " has finished moving from " .. startLoc:GetString() .. " to " .. endLoc:GetString())
end

modApiExt:addVekMoveEndHook(hook)
```


## `buildingDestroyedHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `buildingData` | table | Table holding information about the building. See [`buildingData`](#buildingdata) |

Fired when a building is destroyed, and its tile is no longer blocked.

Example:
```lua
local hook = function(mission, buildingData)
	LOG("Building at " .. buildingData.loc:GetString() .. " was destroyed!")
end

modApiExt:addBuildingDestroyedHook(hook)
```


## `skillStartHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn using the skill |
| `weaponId` | string | Id of the skill being used |
| `p1` | Point | `p1` argument to `GetSkillEffect`; position of the pawn using the skill |
| `p2` | Point | `p2` argument to `GetSkillEffect`; the targeted point on which to use the skill |

Fired when the game begins executing a weapon's `SkillEffect`, ie. before any of the skill's effects are executed (charge, push, damage, whatever).

Example:
```lua
local hook = function(mission, pawn, weaponId, p1, p2)
	LOG(string.format("%s is using %s at %s!", pawn:GetMechName(), weaponId, p2:GetString()))
end

modApiExt:addSkillStartHook(hook)
```


## `skillEndHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn using the skill |
| `weaponId` | string | Id of the skill being used |
| `p1` | Point | `p1` argument to `GetSkillEffect`; position of the pawn using the skill |
| `p2` | Point | `p2` argument to `GetSkillEffect`; the targeted point on which to use the skill |

Fired when the game finishes executing a weapon's `SkillEffect`, ie. after all of the skill's effects are executed (charge, push, damage, whatever).

Example:
```lua
local hook = function(mission, pawn, weaponId, p1, p2)
	LOG(string.format("%s has finished using %s at %s!", pawn:GetMechName(), weaponId, p2:GetString()))
end

modApiExt:addSkillEndHook(hook)
```


## `queuedSkillStartHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn using the skill |
| `weaponId` | string | Id of the skill being used |
| `p1` | Point | `p1` argument to `GetSkillEffect`; position of the pawn using the skill |
| `p2` | Point | `p2` argument to `GetSkillEffect`; the targeted point on which to use the skill |

Same as `skillStartHook`, but for the queued part of `SkillEffect`.

Example:
```lua
local hook = function(mission, pawn, weaponId, p1, p2)
	LOG(string.format("%s is using %s at %s!", pawn:GetMechName(), weaponId, p2:GetString()))
end

modApiExt:addQueuedSkillStartHook(hook)
```


## `queuedSkillEndHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn using the skill |
| `weaponId` | string | Id of the skill being used |
| `p1` | Point | `p1` argument to `GetSkillEffect`; position of the pawn using the skill |
| `p2` | Point | `p2` argument to `GetSkillEffect`; the targeted point on which to use the skill |

Same as `skillEndHook`, but for the queued part of `SkillEffect`.

Example:
```lua
local hook = function(mission, pawn, weaponId, p1, p2)
	LOG(string.format("%s has finished using %s at %s!", pawn:GetMechName(), weaponId, p2:GetString()))
end

modApiExt:addQueuedSkillEndHook(hook)
```


## `skillBuildHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn using the skill |
| `weaponId` | string | Id of the skill being used |
| `p1` | Point | `p1` argument to `GetSkillEffect`; position of the pawn using the skill |
| `p2` | Point | `p2` argument to `GetSkillEffect`; the targeted point on which to use the skill |
| `skillEffect` | userdata | Reference to the `SkillEffect` instance returned by the weapon's `GetSkillEffect` function. |

Fired right after the weapon's `GetSkillEffect` is called, but before its result is passed back to the game. You can modify `skillEffect` in this hook to eg. give the weapon additional effects.

Example:
```lua
local hook = function(mission, pawn, weaponId, p1, p2, skillEffect)
	-- Have every Brute-class weapon set its target on fire, 'cause why not
	if _G[weaponId].Class == "Brute" then
		local d = SpaceDamage(p2, 0)
		d.iFire = EFFECT_CREATE
		skillEffect:AddDamage(d)
	end
end

modApiExt:addSkillBuildHook(hook)
```


## `finalEffectStartHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn using the skill |
| `weaponId` | string | Id of the skill being used |
| `p1` | Point | `p1` argument to `GetFinalEffect`; position of the pawn using the skill |
| `p2` | Point | `p2` argument to `GetFinalEffect`; the starting point on which to use the skill |
| `p3` | Point | `p3` argument to `GetFinalEffect`; the ending point on which to use the skill |

Fired when the game begins executing a weapon's finalized `SkillEffect`, ie. before any of the skill's effects are executed (charge, push, damage, whatever).

Example:
```lua
local hook = function(mission, pawn, weaponId, p1, p2, p3)
	LOG(string.format("%s is using %s at %s and %s!", pawn:GetMechName(), weaponId, p2:GetString(), p3:GetString()))
end

modApiExt:addFinalEffectStartHook(hook)
```


## `finalEffectEndHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn using the skill |
| `weaponId` | string | Id of the skill being used |
| `p1` | Point | `p1` argument to `GetFinalEffect`; position of the pawn using the skill |
| `p2` | Point | `p2` argument to `GetFinalEffect`; the starting point on which to use the skill |
| `p3` | Point | `p3` argument to `GetFinalEffect`; the ending point on which to use the skill |

Fired when the game finishes executing a weapon's finalized `SkillEffect`, ie. after all of the skill's effects are executed (charge, push, damage, whatever).

Example:
```lua
local hook = function(mission, pawn, weaponId, p1, p2, p3)
	LOG(string.format("%s has finished using %s at %s and %s!", pawn:GetMechName(), weaponId, p2:GetString(), p3:GetString()))
end

modApiExt:addFinalEffectEndHook(hook)
```


## `queuedFinalEffectStartHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn using the skill |
| `weaponId` | string | Id of the skill being used |
| `p1` | Point | `p1` argument to `GetFinalEffect`; position of the pawn using the skill |
| `p2` | Point | `p2` argument to `GetFinalEffect`; the starting point on which to use the skill |
| `p3` | Point | `p3` argument to `GetFinalEffect`; the ending point on which to use the skill |

Same as `finalEffectStartHook`, but for the queued part of finalized `SkillEffect`.

Example:
```lua
local hook = function(mission, pawn, weaponId, p1, p2, p3)
	LOG(string.format("%s is using %s at %s and %s!", pawn:GetMechName(), weaponId, p2:GetString(), p3:GetString()))
end

modApiExt:addQueuedFinalEffectStartHook(hook)
```


## `queuedFinalEffectEndHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn using the skill |
| `weaponId` | string | Id of the skill being used |
| `p1` | Point | `p1` argument to `GetFinalEffect`; position of the pawn using the skill |
| `p2` | Point | `p2` argument to `GetFinalEffect`; the starting point on which to use the skill |
| `p3` | Point | `p3` argument to `GetFinalEffect`; the ending point on which to use the skill |

Same as `finalEffectEndHook`, but for the queued part of finalized `SkillEffect`.

Example:
```lua
local hook = function(mission, pawn, weaponId, p1, p2, p3)
	LOG(string.format("%s has finished using %s at %s and %s!", pawn:GetMechName(), weaponId, p2:GetString(), p3:GetString()))
end

modApiExt:addQueuedFinalEffectEndHook(hook)
```


## `finalEffectBuildHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn using the skill |
| `weaponId` | string | Id of the skill being used |
| `p1` | Point | `p1` argument to `GetFinalEffect`; position of the pawn using the skill |
| `p2` | Point | `p2` argument to `GetFinalEffect`; the starting point on which to use the skill |
| `p3` | Point | `p3` argument to `GetFinalEffect`; the ending point on which to use the skill |
| `skillEffect` | userdata | Reference to the `SkillEffect` instance returned by the weapon's `GetFinalEffect` function. |

Fired right after the weapon's `GetFinalEffect` is called, but before its result is passed back to the game. You can modify `skillEffect` in this hook to eg. give the weapon additional effects.

Example:
```lua
local hook = function(mission, pawn, weaponId, p1, p2, p3, skillEffect)
	-- Have every Brute-class weapon set its main target on fire, 'cause why not
	if _G[weaponId].Class == "Brute" then
		local d = SpaceDamage(p2, 0)
		d.iFire = EFFECT_CREATE
		skillEffect:AddDamage(d)
	end
end

modApiExt:addFinalEffectBuildHook(hook)
```


## `targetAreaBuildHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn using the skill |
| `weaponId` | string | Id of the skill being used |
| `p1` | Point | `p1` argument to `GetTargetArea`; position of the pawn using the skill |
| `targetArea` | userdata | Reference to the `PointList` instance returned by the weapon's `GetTargetArea` function. |

Fired right after the weapon's `GetTargetArea` is called, but before its result is passed back to the game. You can modify `targetArea` in this hook to modify the tiles the weapon can target.

Example:
```lua
local hook = function(mission, pawn, weaponId, p1, targetArea)
	-- Have every Ranged-class weapon only able to target orthogonal tiles 2 points away from the pawn using the weapon
	if _G[weaponId].Class == "Ranged" then
		targetArea:empty()
		for dir = DIR_START, DIR_END do
			local point = Point(p1 + DIR_VECTORS[dir] * 2)
			if not Board:IsValid(point) then
				break
			end

			targetArea:push_back(point)
		end
	end
end

modApiExt:addTargetAreaBuildHook(hook)
```


## `secondTargetAreaBuildHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn using the skill |
| `weaponId` | string | Id of the skill being used |
| `p1` | Point | `p1` argument to `GetSecondTargetArea`; position of the pawn using the skill |
| `p2` | Point | `p2` argument to `GetSecondTargetArea`; the starting point selected in `GetTargetArea` |
| `targetArea` | userdata | Reference to the `PointList` instance returned by the weapon's `GetSecondTargetArea` function. |

Fired right after the weapon's `GetSecondTargetArea` is called, but before its result is passed back to the game. You can modify `targetArea` in this hook to modify the tiles the weapon can target.

Example:
```lua
local hook = function(mission, pawn, weaponId, p1, p2, targetArea)
	-- Have every Ranged-class weapon only able to target orthogonal tiles 2 points away from the target point
	if _G[weaponId].Class == "Ranged" then
		targetArea:empty()
		for dir = DIR_START, DIR_END do
			local point = Point(p2 + DIR_VECTORS[dir] * 2)
			if not Board:IsValid(point) then
				break
			end

			targetArea:push_back(point)
		end
	end
end

modApiExt:addSecondTargetAreaBuildHook(hook)
```


## `tipImageShownHook`

Fired when a tip image (animated weapon preview) is shown. If you're looking to detect if your weapon is in a TipImage, then just check for `Board.gameBoard`.

Example:
```lua
local hook = function()
	LOG("Tip image shown!")
end

modApiExt:addTipImageShownHook(hook)
```


## `tipImageHiddenHook`

Fired when a tip image (animated weapon preview) is hidden. If you're looking to detect if your weapon is in a TipImage, then just check for `Board.gameBoard`.

Example:
```lua
local hook = function()
	LOG("Tip image hidden!")
end

modApiExt:addTipImageHiddenHook(hook)
```


## `podDetectedHook`

Fired when a time pod enters the game board.

Example:
```lua
local hook = function()
	LOG("Time pod detected!")
end

modApiExt:addPodDetectedHook(hook)
```


## `podLandedHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `point` | Point | The location the pod landed on |

Fired when a time pod lands on the game board.

Example:
```lua
local hook = function(point)
	LOG("Time pod landed at " .. point:GetString())
end

modApiExt:addPodLandedHook(hook)
```


## `podTrampledHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `pawn` | userdata | The pawn that trampled the pod |

Fired when the time pod is trampled (destroyed by a Vek moving/being pushed on top of it).

Example:
```lua
local hook = function(pawn)
	LOG("Time pod has been trampled by " .. pawn:GetMechName())
end

modApiExt:addPodTrampledHook(hook)
```


## `podDestroyedHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `pawn` | userdata | The pawn that destroyed the pod, or nil if it was destroyed by damage not associated with any pawn (eg. environment) |

Fired when the time pod is destroyed by dealing damage to its tile.

Example:
```lua
local hook = function(pawn)
	if pawn then
		LOG("Time pod has been destroyed by " .. pawn:GetMechName())
	else
		-- could have been destroyed by the environment
		LOG("Time pod has been destroyed!")
	end
end

modApiExt:addPodDestroyedHook(hook)
```


## `podCollectedHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `pawn` | userdata | The pawn that collected the pod |

Fired when the time pod is collected.

Example:
```lua
local hook = function(pawn)
	LOG("Time pod has been collected by " .. pawn:GetMechName())
end

modApiExt:addPodCollectedHook(hook)
```


## `mostRecentResolvedHook`

Fired when the most recent version of modApiExt is resolved. This hook is fired only once at game startup.

Example: see [`modApiExt:forkMostRecent`](//github.com/kartoFlane/ITB-ModUtils/blob/master/docs.md#modapiextforkmostrecent)


# Data


## `buildingData`

| Field name | Type | Description |
|------------|------|-------------|
| loc | Point | Location of the building on the game board |
| destroyed | boolean | True if the building is destroyed, false otherwise |
