# Extended ModApi

This is an extended modding Lua API for the game [Into the Breach](https://www.subsetgames.com/itb.html), added in the form of a mod installed via the [mod loader](http://www.subsetgames.com/forum/viewtopic.php?f=26&t=32833).

# Features

This mod adds a new global variable `modApiExt`. This variable then defines several new hooks that may be useful for some mods:

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

* `buildingDamagedHook( mission, buildingData )`

	DOESN'T WORK

* `buildingDestroyedHook( mission, buildingData )`

	Fired when a building is destroyed, and its tile is no longer blocked.

```lua
buildingData = {
	loc,			-- Point, stores the location of this building
	destroyed		-- boolean, whether the building is destroyed or not
}
```