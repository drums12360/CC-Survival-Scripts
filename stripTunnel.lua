local data = require("dataAPI")
local move = require("moveAPI")
local storage = require("storageAPI")
local dig = require("digAPI")
local tools = require("toolsAPI")
local tArgs = {...}

function mineSquence(Shaft_Amount, Shaft_Width, Shaft_Distance)
	for i=1, Shaft_Amount do
		for j=1, Shaft_Distance do
			move.forward()
			dig.checkForOre()
			tools.dig("up")
		end
		move.turnLeft()
		for j=1, Shaft_Width do
			move.forward()
			dig.checkForOre()
			tools.dig("up")
		end
		move.turnAround()
		move.forward(Shaft_Width)
		for j=1, Shaft_Width do
			move.forward()
			dig.checkForOre()
			tools.dig("up")
		end
		move.turnAround()
		move.forward(Shaft_Width)
		move.turnRight()
		if data.loadData("/.save", "/chest")[1] == true then
			storage.emptyInv()
		elseif data.loadData("/.save", "/chest")[1] == false then
			storage.waitforemptyInv()
		end
	end
end

if type(tonumber(tArgs[1])) and type(tonumber(tArgs[2])) and type(tonumber(tArgs[3])) ~= "number" then
	term.clear()
	term.setCursorPos(1,1)
	error("Define shaft amount, shaft width and shaft distance! (Example: '10 20 3') [10 deep, 20 to each side, and every 3 blocks]")
end

local start = data.copyTable(data.coords)
data.saveData("/.save", "/start_pos", start)
storage.avoidChest()
mineSquence(tonumber(tArgs[1]), tonumber(tArgs[2]), tonumber(tArgs[3]))
move.moveTo(start.x, start.y, start.z)
storage.drop(tools.maxSlots)
fs.delete("/.save")