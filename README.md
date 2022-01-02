# CC-Survival-Scripts-Addon

Stuff for the [CC:Tweaked](https://www.curseforge.com/minecraft/mc-mods/cc-tweaked) mod

----

[[ Download and update functioning APIs and programms automatically with the downloader ]]

wget https://raw.githubusercontent.com/Keigun-Spark/CC-Survival-Scripts/main/downloader/downloader.lua

----

[[ API Name = Essentials? ]]

dataAPI = No essentials

toolsAPI = No essentials

moveAPI = dataAPI and toolsAPI

storageAPI = dataAPI and moveAPI

digAPI = moveAPI

----

[[ Prog Name = Essential APIs? (Essential for another API] ]]

stripTunnel = dataAPI, moveAPI, storageAPI, digAPI, (toolsAPI)

mineTunnel = dataAPI, moveAPI, storageAPI, digAPI, (toolsAPI)

stripMine = dataAPI, moveAPI, storageAPI, digAPI, (toolsAPI)

----

[[ Functional but not reviewed ]]

digRoom

mineCuboid

mineVert

straicaseDown

staircaseUp


