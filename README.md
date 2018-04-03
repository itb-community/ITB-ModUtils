# ItB Mod Utilities

This is a collection of various Lua modules useful for creators of mods for the game [Into the Breach](https://www.subsetgames.com/itb.html). This library is added in the form of a mod installed via the [mod loader](http://www.subsetgames.com/forum/viewtopic.php?f=26&t=32833).


## Usage

You can either integrate ModUtils into your mod and pick-and-choose by manually removing parts you don't need, or just include this mod as a dependency in your mod. Either way you choose, you'll need to add `"kf_ModUtils"` entry to the `requirements` table in your mod's `init.lua` file, like so:

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
	* [+] Good when you don't want to bother manually gutting ModUtils
	* [-] People playing your mod will need to download ModUtils too
	* [-] Relies on the player to have up-to-date version of ModUtils
* Integration
	* [+] If you opt not to use existing `modApiExt` object, then your mod is not likely to break with future releases of ModUtils
	* [+] You don't rely on players keeping ModUtils up-to-date
	* [+] Players don't have to download anything else
	* [-] Requires more setup and effort to maintain compatibility

Generally, the first option is good when what you're working on is a small project. The second option is better if you are willing to put in some effort to make a quality mod.


### Option 1: Dependency

To include as dependency, download the mod from the [Releases page](https://github.com/kartoFlane/ITB-ModUtils/releases/latest), and drop it into `mods` folder in Into the Breach's directory. **However, people who wish to play your mod will also need to download it.**

Then in your mod, you can use the `modApiExt` variable to access any ModUtils functions you may need, without any additional setup.


### Option 2: Integration

If you decide to integrate to pick only the parts you need, you'll need to follow several rules in order to allow compatibility with other mods.

Generally, you should put the scripts you download here in a `modApiExt` folder in your mod's `scripts` directory. Doing so keeps the structure of your mod neat and tidy, and prevents confusion. So your mod's directory should look like this:

```
+ My_Mod/
+--+ scripts/
   +--+ modApiExt/
   |  +-- modApiExt.lua
   |  +-- [other modules you need, etc]
   +-- init.lua  [your mod's init file]
```

**Important:** no matter which parts of ModUtils you need, you should copy `modApiExt.lua` as-is. It is used to initialize the whole thing. Only change it if you *really* know what you're doing.

Now, in your `init.lua` do the following:

```lua
local function init(self)
	if modApiExt then
		-- modApiExt already defined. This means that the user has the complete
		-- ModUtils package installed. Use that instead of loading our gutted one.
		myname_modApiExt = modApiExt
	else
		-- modApiExt was not found. Load our gutted version.
		local extDir = self.scriptPath.."modApiExt/"
		myname_modApiExt = require(extDir.."modApiExt")
		myname_modApiExt:init(extDir)
	end

	-- Rest of your init function
end

local function load(self, options, version)
	myname_modApiExt:load(self, options, version)

	-- Rest of your load function
end

-- Rest of your init.lua file
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
You can combine this with the `init()` code from [Integration](#option-2-integration) when checking for `modApiExt` object, to only use it when ModUtils is at or above a certain version threshold:

```lua
local v = "1.0.0"
if modApiExt and modApi:isVersion(v, modApiExt.version) then
	myname_modApiExt = modApiExt
else
	-- Load our own version
end
```


## Features

Default `modApi` object is extended with a new function, `removeMissionUpdateHook`, which in turn allows for callbacks scheduled to execute during the game's next update step (see [`Hook#RunLater()`](https://github.com/kartoFlane/ITB-ModUtils/blob/master/scripts/hooks.lua))


### Modules

At the moment, the library consists of the following modules:

- [Global](https://github.com/kartoFlane/ITB-ModUtils/blob/master/scripts/global.lua) - various assorted functions which didn't fit anywhere else
- [Vector](https://github.com/kartoFlane/ITB-ModUtils/blob/master/scripts/vector.lua) - functions useful for vector/point manipulation, accessible via `modApiExt.vector`.
- [Pawn](https://github.com/kartoFlane/ITB-ModUtils/blob/master/scripts/pawn.lua) - functions useful when manipulating pawns, accessible via `modApiExt.pawn`.
- [Board](https://github.com/kartoFlane/ITB-ModUtils/blob/master/scripts/board.lua) - functions useful when dealing with the game board, accessible via `modApiExt.board`.
- [String](https://github.com/kartoFlane/ITB-ModUtils/blob/master/scripts/string.lua) - some basic string-related operations, accessible via `modApiExt.string`.
- [Weapon](https://github.com/kartoFlane/ITB-ModUtils/blob/master/scripts/weapon.lua) - functions useful for weapons and targeting, accessible via `modApiExt.weapon`.
- [Hook](https://github.com/kartoFlane/ITB-ModUtils/blob/master/scripts/hooks.lua) - extended modApi with additional hooks, accessible via `modApiExt`.


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

* `pawnUndoMoveHook( mission, pawn, oldPosition )`

	Fired when a pawn's move is undone.

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
