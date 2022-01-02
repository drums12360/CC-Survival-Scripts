# CC-Survival-Scripts

Stuff made for the [CC:Tweaked](https://www.curseforge.com/minecraft/mc-mods/cc-tweaked) mod

## Scripts With Dependencies 

| File Name | Dependencies |
| ----------- | ----------- |
| digRoom.lua | customAPI.lua |
| mineCuboid.lua | customAPI.lua |
| mineVert.lua | movement.lua |
| staircaseDown.lua | movement.lua |
| staircaseUp.lua | movement.lua |
| stripMine.lua | customAPI.lua |

## Apis

Files in the folder **apis**

| File Name | Description |
| ----------- | ----------- |
|  |  |
| move.lua | Basic movement helper funtions |

## Standalone Scripts

Files in the folder **standalone**

| File Name | Description | Usage |
| ----------- | ----------- | ----------- |
| mineCuboid.lua | Mines a Cuboid of minimum `3 x 3 x 1` and the width needs to be an odd # | `mineCuboid <w> <h> <d>` |
| stripMine.lua | Digs in a strait line til it finds ore then vein mines it | `stripMine <dist>` |
| tunnel.lua | A tweaked version of the CC:T tunnel script. Places torches and deposits stuff in a chest | `tunnel <dist>` |
