# CC-Survival-Scripts

Stuff made for the [CC:Tweaked](https://www.curseforge.com/minecraft/mc-mods/cc-tweaked) mod

## Apis

Files in the folder **apis**

| File Name | Description |
| ----------- | ----------- |
| dataAPI.lua | Data manipulation |
| toolsAPI.lua | Dig, place and item manipulation |
| storageAPI.lua | External storage stuff|
| digAPI.lua | stack and vein mine |
| moveAPI.lua | Basic movement helper funtions |
| init.lua = apis | Uses all the files in apis folder |

## Scripts With Dependencies 

| File Name | Dependencies |
| ----------- | ----------- |
| digRoom.lua | apis |
| mineCuboid.lua | apis |
| mineVert.lua | moveAPI.lua |
| mineTunnel.lua | moveAPI.lua, dataAPI.lua, storageAPI.lua, toolsAPI.lua |
| staircaseDown.lua | moveAPI.lua |
| staircaseUp.lua | moveAPI.lua |
| stripMine.lua | apis |
| stripTunnel.lua | apis |

## Standalone Scripts

Files in the folder **standalone**

| File Name | Description | Usage |
| ----------- | ----------- | ----------- |
| mineCuboid.lua | Mines a Cuboid of minimum `3 x 3 x 1` and the width needs to be an odd # | `mineCuboid <w> <h> <d>` |
| stripMine.lua | Digs in a strait line til it finds ore then vein mines it | `stripMine <dist>` |
| tunnel.lua | A tweaked version of the CC:T tunnel script. Places torches and deposits stuff in a chest | `tunnel <dist>` |
