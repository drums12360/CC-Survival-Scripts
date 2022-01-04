# CC-Survival-Scripts-Addon

Stuff for the [CC:Tweaked](https://www.curseforge.com/minecraft/mc-mods/cc-tweaked) mod

----

[[ Download and update custom refuel script ]]

wget https://github.com/Keigun-Spark/CC-Survival-Scripts/blob/main/standalone/refuelSA.lua

Start "refuelSA" for 120 seconds auto refueling from items placed into selected slot.
Start "refuelSA seconds (example: 'refuelSA 10') to auto refuel for that time.
To replace the standard refuel script do "refuelSA replace". to revert it just delete "refuel".

[[ Download and update functioning APIs and programms automatically with the downloader ]]

wget https://raw.githubusercontent.com/Keigun-Spark/CC-Survival-Scripts/main/downloader/downloader.lua

Start the downloader with "downloader" for default settings with autoupdate. Type "downloader auto no" if you dont want autoupdates on turtle startup.
If you want to download all standalone scripts do "downloader sa". No autoupdates available.
If you want to download all normal scripts and standalone with autoupdate do "downloader all". Type "downloader all no" if you dont want normal script autoupdates on turtle startup.

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