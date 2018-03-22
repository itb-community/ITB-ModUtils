# ItB Mod Utilities

This is a collection of various Lua modules useful for creators of mods for the game [Into the Breach](https://www.subsetgames.com/itb.html). This library is added in the form of a mod installed via the [mod loader](http://www.subsetgames.com/forum/viewtopic.php?f=26&t=32833).


## Usage

Download the mod from the [Releases page](https://github.com/kartoFlane/ITB-ModUtils/releases/latest), and drop it into `mods` folder in Into the Breach's directory. Then in your mod's `init.lua` file, add `"ModUtils"` to the `requirements` table.


## Features

Default `modApi` object is extended with a new function, `removeMissionUpdateHook`, which in turn allows for callbacks scheduled to execute during the game's next update step (see [`Global#RunLater()`](https://github.com/kartoFlane/ITB-ModUtils/blob/master/scripts/global.lua))

### Modules

At the moment, the library consists of the following modules:

- [Global](https://github.com/kartoFlane/ITB-ModUtils/blob/master/scripts/global.lua) - various assorted functions which didn't fit anywhere else
- [Vectors](https://github.com/kartoFlane/ITB-ModUtils/blob/master/scripts/vectors.lua) - functions useful for vector/point manipulation
- [Pawns](https://github.com/kartoFlane/ITB-ModUtils/blob/master/scripts/pawns.lua) - functions useful when manipulating pawns
- [Board](https://github.com/kartoFlane/ITB-ModUtils/blob/master/scripts/board.lua) - functions useful when dealing with the game board
- [Strings](https://github.com/kartoFlane/ITB-ModUtils/blob/master/scripts/strings.lua) - some basic string-related operations
- [ModApiExt](https://github.com/kartoFlane/ITB-ModUtils/blob/master/scripts/modApiExt.lua) - extended modApi with additional hooks

### Hooks

New hooks are added via a new global variable, `modApiExt`:

* `pawnSelectedHook( mission, pawnId )`

	Fired when a pawn is selected by the player.

* `pawnDeselectedHook( mission, pawnId )`

	Fired when a pawn is deselected by the player.
	Always fired before pawnSelectedHook

* `pawnDamagedHook( mission, pawnId, damageTaken )`

	Fired when a pawn's health is reduced (won't fire on shielded
	or completely blocked damage)

* `pawnHealedHook( mission, pawnId, healingTaken )`

	Fired when a pawn's health is increased.

* `pawnKilledHook( mission, pawnId )`

	Fired when a pawn's health is reduced to 0, or it is removed
	from the game board.

* `buildingDestroyedHook( mission, buildingData )`

	Fired when a building is destroyed, and its tile is no longer blocked.

```lua
buildingData = {
	loc,			-- Point, stores the location of this building
	destroyed		-- boolean, whether the building is destroyed or not
}
```
