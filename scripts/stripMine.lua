local library = require("library/init")
local tArgs = {...}

function mineSquence(amount)
	for i=1, amount do
		library.move.forward()
		library.dig.checkForOre()
	end
end

if type(tonumber(tArgs[1])) ~= "number" then
	term.clear()
	term.setCursorPos(1,1)
	error("Define mine lenght! (Example: '10') [10 blocks long]")
end

local start = library.data.copyTable(library.data.coords)
library.data.saveData("/.save", "/start_pos", start)
mineSquence(tonumber(tArgs[1]))
library.move.moveTo(start.x, start.y, start.z)
library.storage.drop(library.tools.maxSlots)
fs.delete("/.save")
