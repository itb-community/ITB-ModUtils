# ModApiExt Documentation

## Table of Contents

* [Global](#global)
	* [p2s](#p2s)
	* [list_indexof](#list_indexof)
	* [mouseTile](#mousetile)
	* [screenPointToTile](#screenpointtotile)
	* [is_prime](#is_prime)
	* [next_prime](#next_prime)
	* [hash_o](#hash_o)
	* [List](#list)
		* [List:pushLeft](#listpushleft)
		* [List:pushRight](#listpushright)
		* [List:popLeft](#listpopleft)
		* [List:popRight](#listpopright)
		* [List:peekLeft](#listpeekleft)
		* [List:peekRight](#listpeekright)
		* [List:isEmpty](#listisempty)
		* [List:size](#listsize)
* [ModApiExt](#modApiExt)
	* [Board](#board)
		* [getSpace](#boardgetspace)
		* [getUnoccupiedSpace](#boardgetunoccupiedspace)
		* [getUnoccupiedRestorableSpace](#boardgetunoccupiedrestorablespace)
		* [isRestorableTerrain](#boardisrestorableterrain)
		* [getRestorableTerrainData](#boardgetrestorableterraindata)
		* [restoreTerrain](#boardrestoreterrain)
		* [isWaterTerrain](#boardiswaterterrain)
		* [isPawnOnBoard](#boardispawnonboard)
		* [getCurrentRegion](#boardgetcurrentregion)
		* [getMapTable](#boardgetmaptable)
		* [getTileTable](#boardgettiletable)
	* [Dialog](#dialog) - TODO
	* [Pawn](#pawn)
		* [setFire](#pawnsetfire)
		* [safeDamage](#pawnsafedamage)
		* [copyState](#pawncopystate)
		* [replace](#pawnreplace)
		* [isDead](#pawnisdead)
		* [getById](#pawngetbyid)
		* [getSelected](#pawngetselected)
		* [getHighlighted](#pawngethighlighted)
		* [getSavedataTable](#pawngetsavedatatable)
		* [getWeaponData](#pawngetweapondata)
		* [getWeapons](#pawngetweapons)
		* [getPilotTable](#pawngetpilottable)
		* [getPilotId](#pawngetpilotid)
	* [Vector](#vector)
		* [Constants](#vectorconstants)
			* [VEC_DOWN_RIGHT](#vec_down_right)
			* [VEC_DOWN_LEFT](#vec_down_left)
			* [VEC_UP_RIGHT](#vec_up_right)
			* [VEC_UP_LEFT](#vec_up_left)
			* [VEC_DR](#vec_dr)
			* [VEC_DL](#vec_dl)
			* [VEC_UR](#vec_ur)
			* [VEC_UL](#vec_ul)
			* [DIR_VECTORS_8](#dir_vectors_8)
			* [AXIS_X](#axis_x)
			* [AXIS_Y](#axis_y)
			* [AXIS_ANY](#axis_any)
		* [assert_point](#vectorassert_point)
		* [isColinear](#vectoriscolinear)
		* [normal](#vectornormal)
		* [length](#vectorlength)
		* [unitI](#vectoruniti)
		* [unitF](#vectorunitf)
		* [toAxis](#vectortoaxis)
		* [getDirection8](#vectorgetdirection8)
	* [Weapon](#weapon)
		* [plusTarget](#weaponplustarget)
		* [isTipImage](#weaponistipimage)


## Global

These are functions which are loaded directly into the global lua table, and are accessible from anywhere.


### `p2s`

| Argument name | Type | Description |
|---------------|------|-------------|
| `point` | Point | The point to print |

A nullsafe shorthand for `point:GetString()`, cause I'm lazy.


### `list_indexof`

| Argument name | Type | Description |
|---------------|------|-------------|
| `list` | table | A table-array of elements |
| `element` | object | The element of the list whose index is to be returned |

Returns index of the specified element in the list, or -1 if not found. As this function relies on the `==` operator, it will fail for `userdata` types which do not have this operator defined (eg. pawns).


### `mouseTile`

Returns currently highlighted board tile -- the tile containing the mouse cursor, or nil if the mouse cursor is not hovering over any tile. Uses [screenPointToTile](#screenpointtotile).


### `screenPointToTile`

| Argument name | Type | Description |
|---------------|------|-------------|
| `screenPoint` | Point | A point on the screen, with pixel `x` and `y` values. |

Returns a board tile at the specified point on the screen, or nil.

While this function is pretty reliable, there might be some off-by-one issues at the edges of tiles.


## `is_prime`

| Argument name | Type | Description |
|---------------|------|-------------|
| `n` | number | Integer number to check |

Returns `true` if the specified number is a prime. `false` otherwise.


## `next_prime`

| Argument name | Type | Description |
|---------------|------|-------------|
| `n` | number | Integer number to start checking at |

Returns the number passed in argument if it is prime. If the number passed in argument is not a prime, this function returns the next number (greater than the argument) that is a prime.


### `hash_o`

| Argument name | Type | Description |
|---------------|------|-------------|
| `o` | object | An object for which the hash value is to be computed |

Attempts to compute a hash for the specified object -- any lua type is valid, **except for userdata, functions, and threads**, which will return arbitrary constant values.


### `List`

Double-ended queue implementation via [www.lua.org/pil/11.4.html](www.lua.org/pil/11.4.html). Modified to use the class system from ItB mod loader.

To use like a queue: use either `pushLeft()` and `popRight()` OR `pushRight()` and `popLeft()`.
To use like a stack: use either `pushLeft()` and `popLeft()` OR `pushRight()` and `popRight()`.

This class is not serializable, but provides a constructor to recreate the List from an ordered table.

Example:
```lua
local tbl = { "some", "strings" }
local dque = List(tbl)

dque:pushLeft("test")

while not dque:isEmpty() do
	LOG(dque:popRight())
end
-- Prints 'strings', then 'some', then 'test'
```


#### `List:pushLeft`

| Argument name | Type | Description |
|---------------|------|-------------|
| `value` | object | An object to add to the list |

Pushes the element onto the left side of the list (start).


#### `List:pushRight`

| Argument name | Type | Description |
|---------------|------|-------------|
| `value` | object | An object to add to the list |

Pushes the element onto the right side of the list (end).


#### `List:popLeft`

Removes and returns an element from the left side of the list (start).


#### `List:popRight`

Removes and returns an element from the right side of the list (end).


#### `List:peekLeft`

Returns an element from the left side of the list (start) without removing it.


#### `List:peekRight`

Returns an element from the right side of the list (end) without removing it.


#### `List:isEmpty`

Returns `true` if this list is empty, `false` otherwise.


#### `List:size`

Returns size of the dequeue.


## ModApiExt

### `isMostRecent`

Checks all instances of modApiExt registered by currently loaded mods, and returns `true` if this one is the most recent of them all. `false` otherwise.


### `getMostRecent`

Checks all instances of modApiExt registered by currently loaded mods, and returns the most recent one of them all.


### `scheduleHook`

**Deprecated**. Use [the mod loader's own implementation](https://github.com/kartoFlane/ITB-ModLoader/blob/master/api.md#modapischedulehook).


### `runLater`

**Deprecated**. Use [the mod loader's own implementation](https://github.com/kartoFlane/ITB-ModLoader/blob/master/api.md#modapirunlater).


## Board

Functions useful when dealing with the game board, accesible via `modApiExt.board`.


### `board:getSpace`

| Argument name | Type | Description |
|---------------|------|-------------|
| `predicate` | function | A function taking a Point as argument, and returning a boolean value. |

Returns the first point on the board that matches the specified predicate. If no matching point is found, this function returns nil.

This function checks each tile in order, first along X axis, then advancing one value on the Y axis and repeating.

Example:
```lua
-- get the first blocked point on the board
local point = modApiExt.board:getSpace(function(p) return Board:IsBlocked(p) end)
```


### `board:getUnoccupiedSpace`

Returns the first point on the board that is not blocked.


### `board:getUnoccupiedRestorableSpace`

Returns the first point on the board that is not blocked, and can be restored to its previous state without any isues (see [`board:isRestorableTerrain`](#boardisrestorableterrain)).


### `board:isRestorableTerrain`

| Argument name | Type | Description |
|---------------|------|-------------|
| `point` | Point | The point to check |

Returns true if the point is terrain that can be restored to its previous state without any issues.

Specifically, checks if the terrain at the tile is *not* a mountain, ice or building. Also checks whether the tile is a pod, frozen, a dangerous item.


### `board:getRestorableTerrainData`

| Argument name | Type | Description |
|---------------|------|-------------|
| `point` | Point | The point whose data is to be returned |

Returns a table containing information about restorable state of the terrain:
- `.type` - terrain type (`integer`, like `TERRAIN_ROAD`)
- `.smoke` - whether the tile is smoked (`boolean`)
- `.acid` - whether the tile is covered in acid (`boolean`)
- `.fire` - whether the tile is covered in fire (`boolean`)


### `board:restoreTerrain`

| Argument name | Type | Description |
|---------------|------|-------------|
| `point` | Point | The point to restore |
| `terrainData` | table | Table holding restorable terrain data, obtained from [`board.getRestorableTerrainData`](#boardgetrestorableterraindata) |

Restores the specified tile to the state described in `terrainData` table.


### `board:isWaterTerrain`

| Argument name | Type | Description |
|---------------|------|-------------|
| `point` | Point | The point to check |

Returns `true` if terrain type at the specified tile is `TERRAIN_WATER`, `TERRAIN_LAVA` or `TERRAIN_ACID`. `false` otherwise.


### `board:isPawnOnBoard`

| Argument name | Type | Description |
|---------------|------|-------------|
| `pawn` | userdata | The pawn to check |

Returns `true` if the specified pawn is placed on the Board. `false` otherwise.


### `board:getCurrentRegion`

Returns a savedata table holding information about the region the player is currently in. Returns `nil` when not in a mission.


### `board:getMapTable`

Returns a list of tile tables for all locations on the current game board.


### `board:getTileTable`

Returns a savedata table holding complete information about the specified board tile.

- `.loc` - location of the tile on the board
- `.terrain` - terrain type of this tile
- `.populated` - 1 if this tile is populated. 0 or nil (missing) if not.
- `.people1` - number of people in the first building, if this tile is populated.
- `.people2` - number of people in the second building, if this tile is populated.
- `.people3` - number of people in the third building, if this tile is populated.
- `.people4` - number of people in the fourth building, if this tile is populated.
- `.health_max` - max health of this tile
- `unique` - id of the unique structure at this tile
- `.grappled` - 1 if this tile has a grapple (web) effect on it, 0 or nil (missing) if not.
- `.grapple_targets` - a table of targets grappled from this tile. Entries are just numbers - maybe indices of `DIR_VECTORS` table?
- `.undo_state` - table holding undoable information about this tile


## Dialog

System for dialogs with pawn cast rules, accessible via `modApiExt.dialog`.

TODO


## Pawn

Functions useful when manipulating pawns, accessible via `modApiExt.pawn`.


### `pawn:setFire`

| Argument name | Type | Description |
|---------------|------|-------------|
| `pawn` | userdata | The pawn whose Fire status is to be changed |
| `fire` | boolean | Sets the pawn on fire if true, or removes the Fire status from it if false. |


### `pawn:safeDamage`

| Argument name | Type | Description |
|---------------|------|-------------|
| `pawn` | userdata | The pawn to be damaged |
| `spaceDamage` | SpaceDamage | SpaceDamage instance to deal to the pawn |

Damages the specified pawn using the specified SpaceDamage instance, without causing any side effects to the board (unless setting the Pawn on fire, and it is standing in a forest -- Pawns on fire set forests ablaze as soon as they move onto them.)

The SpaceDamage's `loc` attribute is overwritten by this function.


### `pawn:copyState`

| Argument name | Type | Description |
|---------------|------|-------------|
| `sourcePawn` | userdata | The pawn whose state is to be copied |
| `targetPawn` | userdata | The pawn that receives the copied state |

Attempts to copy state from source pawn to the target pawn (current health, Fire/Frozen/Acid/Shield status).


### `pawn:replace`

| Argument name | Type | Description |
|---------------|------|-------------|
| `targetPawn` | userdata | The pawn to be replaced |
| `newPawnType` | string | Name of the lua pawn class to create the pawn from |

Replaces the pawn with another one of the specified type. The newly created pawn retains health and Fire/Frozen/Acid/Shield status effects of the old pawn.


### `pawn:isDead`

| Argument name | Type | Description |
|---------------|------|-------------|
| `pawn` | userdata | The pawn to check |

Checks whether the pawn is dead. Works for non-mech pawns. Pawns not on the game board, but with remaining health are considered dead by this function.


### `pawn:getById`

| Argument name | Type | Description |
|---------------|------|-------------|
| `pawnId` | number | Id of the pawn to get |

Returns the pawn with the specified id. Works for pawns which may have been removed from the board.


### `pawn:getSelected`

Returns the currently selected pawn, or nil if none is selected. This is effectively the same as the `Pawn` global, except that variable remains set even after the pawn is deselected.


### `pawn:getHighlighted`

Returns the currently highlighted pawn (the one the player is hovering their mouse cursor over).


### `pawn:getSavedataTable`

| Argument name | Type | Description |
|---------------|------|-------------|
| `pawnId` | number | Id of the pawn to get the savedata table for |
| `sourceTable` | table | The parent savedata table to search for the pawn table. Used internally. Can be safely omitted if you don't know what this is. |

Returns the pawn savedata table (a ptable) for the specified pawn id.


### `pawn:getWeaponData`

| Argument name | Type | Description |
|---------------|------|-------------|
| `ptable` | table | Pawn savedata table |
| `field` | string | Id of the weapon slot to access: either `primary` or `secondary` |

Returns a table containing information about the specified weapon. All of the fields listed here are `nil` if the pawn doesn't have a weapon equipped in the specified slot.
- `.id` - id of the weapon
- `.power` - array of reactor power values. If it's all 0s, the weapon is not powered.
- `.upgrade1` - array of reactor power values for weapon's first upgrade. If it's all 0s, the upgrade is not powered.
- `.upgrade2` - array of reactor power values for weapon's second upgrade. If it's all 0s, the upgrade is not powered.


### `pawn:getWeapons`

| Argument name | Type | Description |
|---------------|------|-------------|
| `pawnId` | number | Id of the pawn |

Returns a table with the primary weapon's id at the `[1]` index, and the secondary weapon's id at the `[2]` index. Either of those can be nil if the pawn has no weapon equipped in that slot.


### `pawn:getPilotTable`

| Argument name | Type | Description |
|---------------|------|-------------|
| `pawnId` | number | Id of the pawn |

Returns a table holding information about the pilot of the pawn. Returns `nil` if the pawn is not piloted (eg. vek, mechs whose pilot is dead, etc.)


### `pawn:getPilotId`

| Argument name | Type | Description |
|---------------|------|-------------|
| `pawnId` | number | Id of the pawn |

Returns id of the pilot piloting this pawn, or `"Pilot_Artificial"` if it's not piloted.


## Vector

Functions useful for vector/point manipulation, accessible via `modApiExt.vector`.


### Vector Constants

#### VEC_DOWN_RIGHT

`vector.VEC_DOWN_RIGHT = Point(1, 1)`

A constant vector value pointing down-right on the board axis (straight down on the screen).


#### VEC_DOWN_LEFT

`vector.VEC_DOWN_RIGHT = Point(-1, 1)`

A constant vector value pointing down-left on the board axis (straight left on the screen).


#### VEC_UP_RIGHT

`vector.VEC_UP_RIGHT = Point(1, -1)`

A constant vector value pointing up-right on the board axis (straight right on the screen).


#### VEC_UP_LEFT

`vector.VEC_UP_LEFT = Point(-1, -1)`

A constant vector value pointing up-left on the board axis (straight up on the screen).


#### VEC_DR

Shorthand for [`VEC_DOWN_RIGHT`](#vec_down_right).


#### VEC_DL

Shorthand for [`VEC_DOWN_LEFT`](#vec_down_left).


#### VEC_UR

Shorthand for [`VEC_UP_RIGHT`](#vec_up_right).


#### VEC_UL

Shorthand for [`VEC_UP_LEFT`](#vec_up_left).


#### DIR_VECTORS_8

A constants table similar to `DIR_VECTORS` from vanilla game, but including the additional constant vectors defined above.

Vectors are arranged to follow clockwise order (same as vanilla table: `UP`, `RIGHT`, `DOWN`, `LEFT`, except with the additional vectors inbetween):
```lua
vector.DIR_VECTORS_8 = {
	vector.VEC_UP,
	vector.VEC_UP_RIGHT,
	vector.VEC_RIGHT,
	vector.VEC_DOWN_RIGHT,
	vector.VEC_DOWN,
	vector.VEC_DOWN_LEFT,
	vector.VEC_LEFT,
	vector.VEC_UP_LEFT
}
```


#### AXIS_X

`AXIS_X = 0`

A constant used to signify the X axis in some functions in the `vector` module.


#### AXIS_Y

`AXIS_Y = 1`

A constant used to signify the Y axis in some functions in the `vector` module.


#### AXIS_ANY

`AXIS_ANY = 2`

A constant used to signify any axis in some functions in the `vector` module.


### `vector:assert_point`

| Argument name | Type | Description |
|---------------|------|-------------|
| `o` | object | An object to assert |

Asserts that the object passed in argument is a valid point instance: a `userdata` type with `x` and `y` fields.


### `vector:isColinear`

| Argument name | Type | Description |
|---------------|------|-------------|
| `p1` | Point | First point to check |
| `p2` | Point | Second point to check |
| `axis` | number | Number signifying an axis ([`AXIS_X`](#axis_x), [`AXIS_Y`](#axis_y), [`AXIS_ANY`](#axis_any)) |

Tests whether two points form a line colinear to the specified axis (ie. have the same value for that axis' coordinate)


### `vector:normal`

| Argument name | Type | Description |
|---------------|------|-------------|
| `vec` | Point | A vector whose normal counterpart is to be returned |

Returns a vector normal to the one provided in argument. Normal in this context means perpendicular.

Example:
```lua
local vec = Point(2, 1)
LOG(modApiExt.vector:normal(vec):getString()) -- prints Point(-1, 2)
```


### `vector:length`

| Argument name | Type | Description |
|---------------|------|-------------|
| `vec` | Point | A vector whose length is to be returned |

Returns length of the vector (euclidean distance from `(0, 0)` to the point described by this vector).


### `vector:unitI`

| Argument name | Type | Description |
|---------------|------|-------------|
| `vec` | Point | A vector whose unit vector is to be returned |

Returns a unit vector constructed from the vector provided in argument. Unit vector is a vector with length of 1.

**HOWEVER** in ItB, the `Point` class can only hold integers, and by default rounds fractional values to nearest integers. 0.5 is rounded to 1, -0.5 is rounded to -1, etc.

For fractional values, use [`unitF`](#vectorunitf), which returns a custom table with x and y fields.


### `vector:unitF`

| Argument name | Type | Description |
|---------------|------|-------------|
| `vec` | Point | A vector whose unit vector is to be returned |


Returns a unit vector constructed from the vector provided in argument. Unit vector is a vector with length of 1.


### `vector:toAxis`

| Argument name | Type | Description |
|---------------|------|-------------|
| `vec` | Point | A vector |

Returns axis represented by the specified vector.

- Returns `nil` if `Point(0, 0)` is provided.
- Returns `AXIS_X` if this vector has Y = 0.
- Returns `AXIS_Y` if this vector has X = 0.
- Returns `nil` otherwise.


### `vector:getDirection8`

| Argument name | Type | Description |
|---------------|------|-------------|
| `vec` | Point | A vector |

Converts the specified vector into a unit vector (using [`unitI`](#vectoruniti)), then returns index of that vector in the `DIR_VECTORS_8` table.


## Weapon

Functions useful for weapons and targeting, accessible via `modApiExt.weapon`.


### `weapon:plusTarget`

| Argument name | Type | Description |
|---------------|------|-------------|
| `center` | Point | Center of the plus shape |
| `size` | number | Number of tiles in each of the shape's wings (excluding center) |

Returns a `PointList` containing points creating a plus-shaped targeting area.


### `weapon:isTipImage`

When called inside of a `GetSkillEffect`, returns `true` if the weapon is being called from inside of a tip image. `false` otherwise.

Always returns `false` when called outside of `GetSkillEffect`.
