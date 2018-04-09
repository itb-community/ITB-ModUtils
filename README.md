# ItB Mod Utilities

This is a collection of various Lua modules useful for creators of mods for the game [Into the Breach](https://www.subsetgames.com/itb.html). This library is added in the form of a mod installed via the [mod loader](http://www.subsetgames.com/forum/viewtopic.php?f=26&t=32833).


## Usage

1. Create a folder named `modApiExt` inside of your mod's `scripts` directory, and place all of ModUtils' `.lua` files there. To illustrate, the directory structure should look like this:

```
+ My_Mod/
+--+ scripts/
   +--+ modApiExt/
   |  +-- modApiExt.lua
   |  +-- [other ModUtils .lua files]
   +-- init.lua  [your mod's init file]
```

2. In your mod's `init.lua`, add `"kf_ModUtils"` entry to the `requirements` table:

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

3. Now, in your mod's `init.lua` do the following:

```lua
local function init(self)
	local extDir = self.scriptPath.."modApiExt/"
	myname_modApiExt = require(extDir.."modApiExt")
	myname_modApiExt:init(extDir)

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

If you ever need to check whether the version you're running is the most recent one available to the player, or want to get the most recent version, you can use `myname_modApiExt:isMostRecent()` and `myname_modApiExt:getMostRecent()` respectively.


## Features

Some useful functions added by this library:

* `modApiExt:runLater( fn )`

	Schedules the specified function to be executed during the game's *next* update step. This allows for stuff like moving a pawn onto a fire tile, and moving it elsewhere in the next step -- the single tick inbetween is enough for the pawn to be affected by fire status.

* `modApiExt:scheduleHook( timeMs, fn )`

	Schedules the specified function to be executed in `timeMs` milliseconds (roughly; this is checked every frame, so the exact timing will depend on the user's framerate).

* `mouseTile()` (global function)

	Returns the Board tile currently being hovered over by the mouse cursor. Useful for debugging and testing, when placing pawns on the board -- you don't have to figure out the tile and then type it out, you just move your mouse there.

* `List` class

	A list class implemented as a double-ended queue, which allows it to act as both a queue and a stack.


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

New hooks are added exactly the same way as in the base mod loader's `modApi`, except you have to reference the extended API object (`modApiExt`) instead. [Click here](hooks.md) for an exhaustive list of hooks.
