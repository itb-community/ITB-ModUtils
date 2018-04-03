# ItB Mod Utilities

This is a collection of various Lua modules useful for creators of mods for the game [Into the Breach](https://www.subsetgames.com/itb.html). This library is added in the form of a mod installed via the [mod loader](http://www.subsetgames.com/forum/viewtopic.php?f=26&t=32833).


## Usage

You can either pick-and-choose parts you want by manually gutting the code I posted, or just include this mod as a dependency in your mod. Either way you choose, you'll need to include `"kf_ModUtils"` to the `requirements` table in your mod's `init.lua` file, like so:

```lua
return {
	id = "MyModId",
	name = "My Mod",
	version = "someversion",
	requirements = { "kf_ModUtils" }, -- <-- Here
	init = init,
	load = load,
}
```

Doing so makes sure `kf_ModUtils` is loaded *before* your mod, if it is available.


Now which option should you choose? Here are the benefits and drawbacks of each:

* Dependency
	* [+] Minimum amount of setup required
	* [+] Good when you're not sure which parts of ModUtils you need yet
	* [-] People playing your mod will need to download ModUtils too
	* [-] Relies on the player to have up-to-date version of ModUtils
* Picking apart
	* [+] Your has no external dependencies - you don't rely on players keeping ModUtils up-to-date
	* [+] Players don't have to download anything else
	* [-] Requires a lot more setup


### Option: Dependency

To include as dependency, download the mod from the [Releases page](https://github.com/kartoFlane/ITB-ModUtils/releases/latest), and drop it into `mods` folder in Into the Breach's directory. **However, people who wish to play your mod will also need to download it.**

Then in your mod, you can use the `modApiExt` variable to access any ModUtils functions you may need, without any additional setup.


### Option: Picking apart

If you decide to pick only the parts you need, you'll need to follow several rules in order to allow compatibility with other mods.

Generally, your `init()` function should look like so:

```lua
local function init(self)
	if modApiExt then
		-- modApiExt already defined. This means that the user has the complete ModUtils package installed. Use that instead of loading our gutted one.
		myname_modApiExt = modApiExt
	else
		-- modApiExt was not found. Load our gutted version.
		myname_modApiExt = require(self.scriptPath.."modApiExt")

		-- load modules if you need any, and your gutted version includes them.
		require(self.scriptPath.."global")
		myname_modApiExt.somemodule = myname_modApiExt:loadModule(self.scriptPath.."somemodule")
	end

	-- Rest of your init function
end
```

...Where the `myname` in `myname_modApiExt` should be changed to some unique identifier that is very unlikely to be used by other mods. A good convention is first using a short of your nickname, followed by name of the mod you're working on. For example, when I (kartoFlane) was working on a snake vek enemy mod, I named this variable `kf_snake_modApiExt`.

Now in your mod, you can use the `myname_modApiExt` variable to access any ModUtils functions you may need.

### Versioning

If you ever require a specific version of ModUtils, or need to make sure that the version the player has installed is above a certain milestone, you can check the version using the following code:

```lua
local myMinimumRequiredVersion = "1.0.0"
modApi:isVersion(myMinimumRequiredVersion, modApiExt.version)
```

This will return true if the currently installed version of ModUtils is at or above `1.0.0`.
You can combine this with the `init()` code above when checking for `modApiExt` object, to only use it when ModUtils is at or above a certain version threshold:

```lua
local function init(self)
	local v = "1.0.0"
	if modApiExt and modApi:isVersion(v, modApiExt.version) then
		myname_modApiExt = modApiExt
	else
		-- ...
```


## Features

Default `modApi` object is extended with a new function, `removeMissionUpdateHook`, which in turn allows for callbacks scheduled to execute during the game's next update step (see [`ModApiExt#RunLater()`](https://github.com/kartoFlane/ITB-ModUtils/blob/master/scripts/modApiExt.lua))

### Modules

At the moment, the library consists of the following modules:

- [Global](https://github.com/kartoFlane/ITB-ModUtils/blob/master/scripts/global.lua) - various assorted functions which didn't fit anywhere else
- [Vectors](https://github.com/kartoFlane/ITB-ModUtils/blob/master/scripts/vectors.lua) - functions useful for vector/point manipulation, accessible via `modApiExt.vector`.
- [Pawns](https://github.com/kartoFlane/ITB-ModUtils/blob/master/scripts/pawns.lua) - functions useful when manipulating pawns, accessible via `modApiExt.pawn`.
- [Board](https://github.com/kartoFlane/ITB-ModUtils/blob/master/scripts/board.lua) - functions useful when dealing with the game board, accessible via `modApiExt.board`.
- [Strings](https://github.com/kartoFlane/ITB-ModUtils/blob/master/scripts/strings.lua) - some basic string-related operations, accessible via `modApiExt.string`.
- [Weapons](https://github.com/kartoFlane/ITB-ModUtils/blob/master/scripts/weapons.lua) - functions useful for weapons and targeting, accessible via `modApiExt.weapon`.
- [ModApiExt](https://github.com/kartoFlane/ITB-ModUtils/blob/master/scripts/modApiExt.lua) - extended modApi with additional hooks, accessible via `modApiExt`.

### Hooks

New hooks are added exactly the same way as in the base mod loader's `modApi`, except you have to reference the extended API object (`modApiExt`) instead. For example:

```lua
modApiExt:addPawnDamagedHook(myHookFunction)
```

List of available hooks:

* `pawnTrackedHook( mission, pawn )`

	Fired when `modApiExt` becomes aware of the pawn and beings tracking it. This is usually at the very start of the mission (for pre-existing pawns), or as soon as the pawn is spawned on the board.

* `pawnUntrackedHook( mission, pawn )`

	Fired when `modApiExt` stops tracking a pawn (due to it being killed, or removed from the game board via `Board:RemovePawn()`)

* `tileHighlightedHook( mission, point )`

	Fired when the player moves their cursor over a board tile.

* `tileUnhighlightedHook( mission, point )`

	Fired when the player moves their cursor away from the previously highligthed tile.

* `pawnPositionChangedHook( mission, pawn, oldPosition )`

	Fired when a pawn's position is changed (either by moving, or by being pushed/flipped). Fired once for every tile.

* `pawnSelectedHook( mission, pawn )`

	Fired when a pawn is selected by the player.

* `pawnDeselectedHook( mission, pawn )`

	Fired when a pawn is deselected by the player.
	Always fired before pawnSelectedHook

* `pawnDamagedHook( mission, pawn, damageTaken )`

	Fired when a pawn's health is reduced (won't fire on shielded
	or completely blocked damage)

* `pawnHealedHook( mission, pawn, healingTaken )`

	Fired when a pawn's health is increased.

* `pawnKilledHook( mission, pawn )`

	Fired when a pawn's health is reduced to 0.

* `buildingDestroyedHook( mission, buildingData )`

	Fired when a building is destroyed, and its tile is no longer blocked.

```lua
buildingData = {
	loc,			-- Point, stores the location of this building
	destroyed		-- boolean, whether the building is destroyed or not
}
```
