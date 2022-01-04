# CC-Survival-Scripts-Addon

Stuff for the [CC:Tweaked](https://www.curseforge.com/minecraft/mc-mods/cc-tweaked) mod

----

[[ Download and update functioning APIs and programms automatically with the downloader ]]

wget https://raw.githubusercontent.com/Keigun-Spark/CC-Survival-Scripts/main/downloader/downloader.lua

Start the downloader with "downloader" for default settings. If you want to download all standalone scripts do "downloader sa".
If you want the downloader to autoupdate on each turtle startup do "downloader script yes"

----

[[ API Name = Essentials? ]]

init = All APIs

dataAPI = No essentials

toolsAPI = No essentials

moveAPI = dataAPI and toolsAPI

storageAPI = dataAPI and moveAPI

digAPI = moveAPI

----

[[ Prog Name = Essential APIs?] ]]

stripTunnel = All APIs via init

mineTunnel = All APIs via init

stripMine = All APIs via init

mineCuboid = All APIs via init

mineVert = All APIs via init

mineStaircase = All APIs via init