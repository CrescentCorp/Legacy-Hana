# Hana

Hana is an execution framework intended as a temporary solution for scheduling coroutines in Lune.

Hana is built similarly to how Roblox's coroutine scheduler work as Hana acts as the main loop, so its `start` function (require("src/init")) is a yielding operation.

Hana works by searching for `.work.luau`s in a directory which returns a function that expects a `wait` function. This wait function is responsible for registering the calling coroutine as a yielding coroutine for a specific time internally- after that, Hana will resume it after the given time is passed.

## Usage

First, import the library- this purely depends on how you install the library, however, the standard way is to install the whole `src` folder- after that, require its path:
```lua
local start = require("src/init") -- we cam rename the src to Hana
```

Now, the `start` function expects a dirPath that contains `.work.luau` files.

```lua
-- workables/Printer.work.luau

return function(wait)
    while true do
        print("I am printer", wait(1))
    end
end
```
```lua
-- .lune/runner.luau
local start = require("src/init") 

start("workables")
print("Execution is stopped!") -- this won't execute
```

## Notes
* Once a coroutine yields, it will only resume again in the next frame.
* Lune V0.0.3+ is supported for running Hana.
* The Lune project might potentially implement and expose a custom `task` library similar to Roblox's, which would be used for scheduling coroutines, until then, this library is useful!
* You cam look both at the `.lune` and `test` dirs for examples. 