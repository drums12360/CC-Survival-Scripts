local library = require("library")
local tArgs = {...}

function mineSquence(Shaft_Amount, Shaft_Width, Shaft_Distance)
	for i=1, Shaft_Amount do
		for j=1, Shaft_Distance do
			library.move.forward()
			library.dig.checkForOre()
			library.tools.dig("up")
			library.storage.invCheck()
		end
		library.move.turnLeft()
		for j=1, Shaft_Width do
			library.move.forward()
			library.dig.checkForOre()
			library.tools.dig("up")
		end
		library.move.turnAround()
		library.move.forward(Shaft_Width)
		for j=1, Shaft_Width do
			library.move.forward()
			library.dig.checkForOre()
			library.tools.dig("up")
		end
		library.move.turnAround()
		library.move.forward(Shaft_Width)
		library.move.turnRight()
		library.storage.invCheck()
	end
end

if type(tonumber(tArgs[1])) ~= "number" and type(tonumber(tArgs[2])) ~= "number" and type(tonumber(tArgs[3])) ~= "number" then
	term.clear()
	term.setCursorPos(1,1)
	error("Define shaft amount, shaft width and shaft distance! (Example: '10 20 3') [10 deep, 20 to each side, and every 3 blocks]")
end

local start = library.data.copyTable(library.data.coords)
library.data.saveData("/.save", "/start_pos", start)
library.storage.avoidChest()
mineSquence(tonumber(tArgs[1]), tonumber(tArgs[2]), tonumber(tArgs[3]))
library.move.moveTo(start.x, start.y, start.z)
library.storage.drop(library.tools.maxSlots)
fs.delete("/.save")