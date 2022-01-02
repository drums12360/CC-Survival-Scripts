local data = require("dataAPI")
local move = require("moveAPI")
local storage = require("storageAPI")
local dig = require("digAPI")
local tArgs = {...}

function mineSquence(amount)
	for i=1, amount do
		move.forward()
		dig.checkForOre()
	end
end

if type(tArgs[1]) ~= "number" then
	term.clear()
	term.setCursorPos(1,1)
	error("Define mine lenght! (Example: '10') [10 block long]")
end

local start = data.copyTable(data.coords)
data.saveData("/.save", "/start_pos", start)
mineSquence(tonumber(tArgs[1]))
move.moveTo(start.x, start.y, start.z)
storage.drop(tools.maxSlots)
fs.delete("/.save")