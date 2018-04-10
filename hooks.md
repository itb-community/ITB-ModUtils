# Table of Contents

* [resetTurnHook](#resetturnhook)
* [gameLoadedHook](#gameloadedhook)
* [tileHighlightedHook](#tilehighlightedhook)
* [tileUnhighlightedHook](#tileunhighlightedhook)
* [pawnTrackedHook](#pawntrackedhook)
* [pawnUntrackedHook](#pawnuntrackedhook)
* [pawnMoveStartHook](#pawnmovestarthook)
* [pawnMoveEndHook](#pawnmoveendhook)
* [pawnPositionChangedHook](#pawnpositionchangedhook)
* [pawnUndoMoveHook](#pawnundomovehook)
* [pawnSelectedHook](#pawnselectedhook)
* [pawnDeslectedHook](#pawndeslectedhook)
* [pawnDamagedHook](#pawndamagedhook)
* [pawnHealedHook](#pawnhealedhook)
* [pawnKilledHook](#pawnkilledhook)
* [buildingDestroyedHook](#buildingdestroyedhook)
* [skillStartHook](#skillstarthook)
* [skillEndHook](#skillendhook)
* [queuedSkillStartHook](#queuedskillstarthook)
* [queuedSkillEndHook](#queuedskillendhook)
* [skillBuildHook](#skillbuildhook)
* [tipImageShownHook](#tipimageshownhook)
* [tipImageHiddenHook](#tipimagehiddenhook)


# Hooks

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
	LOG(pawn:GetMechName() .. " was killed!)
end

modApiExt:addPawnKilledHook(hook)
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
	LOG("Building at " .. buildingData.loc:GetString() .. " was destroyed!)
end

modApiExt:addBuildingDestroyedHook(hook)
```


## `skillStartHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn using the skill |
| `weaponId` | string | Id of the skill being used |
| `p1` | Point | `p1` argument to `GetWeaponSkill`; position of the pawn using the skill |
| `p2` | Point | `p2` argument to `GetWeaponSkill`; the targeted point on which to use the skill |

Fired when the game begins executing a weapon's `SkillEffect`, ie. before any of the skill's effects are executed (charge, push, damage, whatever).

Example:
```lua
local hook = function(mission, pawn, weaponId, p1, p2)
	LOG(string.format("%s is using %s at %s!"), pawn:GetMechName(), weaponId, p2:GetString())
end

modApiExt:addSkillStartHook(hook)
```


## `skillEndHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn using the skill |
| `weaponId` | string | Id of the skill being used |
| `p1` | Point | `p1` argument to `GetWeaponSkill`; position of the pawn using the skill |
| `p2` | Point | `p2` argument to `GetWeaponSkill`; the targeted point on which to use the skill |

Fired when the game finishes executing a weapon's `SkillEffect`, ie. after all of the skill's effects are executed (charge, push, damage, whatever).

Example:
```lua
local hook = function(mission, pawn, weaponId, p1, p2)
	LOG(string.format("%s has finished using %s at %s!"), pawn:GetMechName(), weaponId, p2:GetString())
end

modApiExt:addSkillEndHook(hook)
```


## `queuedSkillStartHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn using the skill |
| `weaponId` | string | Id of the skill being used |
| `p1` | Point | `p1` argument to `GetWeaponSkill`; position of the pawn using the skill |
| `p2` | Point | `p2` argument to `GetWeaponSkill`; the targeted point on which to use the skill |

Same as `skillStartHook`, but for the queued part of `SkillEffect`.

Example:
```lua
local hook = function(mission, pawn, weaponId, p1, p2)
	LOG(string.format("%s is using %s at %s!"), pawn:GetMechName(), weaponId, p2:GetString())
end

modApiExt:addQueuedSkillStartHook(hook)
```


## `queuedSkillEndHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn using the skill |
| `weaponId` | string | Id of the skill being used |
| `p1` | Point | `p1` argument to `GetWeaponSkill`; position of the pawn using the skill |
| `p2` | Point | `p2` argument to `GetWeaponSkill`; the targeted point on which to use the skill |

Same as `skillEndHook`, but for the queued part of `SkillEffect`.

Example:
```lua
local hook = function(mission, pawn, weaponId, p1, p2)
	LOG(string.format("%s has finished using %s at %s!"), pawn:GetMechName(), weaponId, p2:GetString())
end

modApiExt:addQueuedSkillEndHook(hook)
```


## `skillBuildHook`

| Argument name | Type | Description |
|---------------|------|-------------|
| `mission` | table | A table holding information about the current mission |
| `pawn` | userdata | The pawn using the skill |
| `weaponId` | string | Id of the skill being used |
| `p1` | Point | `p1` argument to `GetWeaponSkill`; position of the pawn using the skill |
| `p2` | Point | `p2` argument to `GetWeaponSkill`; the targeted point on which to use the skill |
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


# Data


## `buildingData`

| Field name | Type | Description |
|------------|------|-------------|
| loc | Point | Location of the building on the game board |
| destroyed | boolean | True if the building is destroyed, false otherwise |
