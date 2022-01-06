# CC-Survival-Scripts

Stuff for the [CC:Tweaked](https://www.curseforge.com/minecraft/mc-mods/cc-tweaked) mod

Downloader CC:T Command `wget https://raw.githubusercontent.com/drums12360/CC-Survival-Scripts/dev/downloader/downloader.lua`
| File Name | Description | Usage |
| ----------- | ----------- | ----------- |
| downloader.lua | Downloads all normal scripts and/or standalone scripts | `downloader <version> <no auto updater>` Executing without variables given will result in normal scripts and active auto updater. For standalone scripts use `sa`. For normal and standalone scripts use `all`. For normal or all scripts without auto updater write `auto no` or `all no`|

Refuel CC:T Command `wget https://raw.githubusercontent.com/drums12360/CC-Survival-Scripts/dev/standalone/refuelSA.lua`


## Libraries with description 

| File Name | Description |
| ----------- | ----------- |
| dataLib.lua | Data manipulation |
| toolsLib.lua | Dig, place and item manipulation |
| storageLib.lua | External storage stuff|
| digLib.lua | stack and vein mine |
| moveLib.lua | Basic movement helper funtions |
| init.lua = library | Uses all the files in library folder |

## Scripts with dependencies 

| File Name | Dependencies |
| ----------- | ----------- |
| mineCuboid.lua | library |
| mineStaircase.lua | library |
| mineTunnel.lua | library |
| mineVert.lua | library |
| stripMine.lua | library |
| stripTunnel.lua | library |

## Standalone scripts

| File Name | Description | Usage |
| ----------- | ----------- | ----------- |
| mineCuboidSA.lua | Mines a cuboid of minimum `3 x 3 x 1` the width needs to be an odd `#` and the side is `left` or `right` | `mineCuboidSA <w> <h> <d> <side>` cube size and which side you placed the turtle |
| mineStaircaseSA.lua | Mines a one block wide staircase `up` or `down` | `mineStaircaseSA <step_amount> <direction>` |
| mineTunnelSA.lua | Overhauled tunnel script which places torches and deposits stuff in a chest | `mineTunnelSA <distance>` Torches in slot 16 if wanted, turtle facing chest if deposit is wanted |
| mineVertSA.lua | Digs in a straight line down untill finds ore then vein mines it, block off hole while mining | `mineVertSA <depth>` |
| stripMineSA.lua | Digs in a straight line untill it finds ore then vein mines it | `stripMineSA <depth>` |
| stripTunnelSA.lua | Classical two block heigh stripmine without torches and vein mine on the lower block | `stripTunnelSA <Shaft_Amount> <Shaft_Width> <Shaft_Distance>` How far in, how long each shaft is and the distance between them, recommended `3`.|
| refuelSA.lua | Custom refuel script which lets you manually refuel for x amount of time | `refuelSA <time_inSeconds> <replace_original>` If no time is given, default is 120 seconds. If yo uwant to replace the default script write `replace` |
