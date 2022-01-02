local data = require("dataAPI")
local tools = require("toolsAPI")
local move = require("moveAPI")
local storage = require("storageAPI")
local dig = require("digAPI")
local tArgs = {...}

function mineSquence(amount)
	for i=1, amount do
		move.forward()
		dig.checkForOre()
		turtle.digUp()
		if data.loadData("/.save", "/chest")[1] == true then
			storage.emptyInv()
		elseif data.loadData("/.save", "/chest")[1] == false then
			storage.waitforemptyInv()
		end
	end
end

function returnSquence(amount)
	local moves = amount
	if turtle.getItemCount(16) ~= 0 then
		if turtle.getItemDetail(16).name ~= "minecraft:torch" then
			return false
			elseif turtle.getItemDetail(16).name == "minecraft:torch" and amount >= 4 then
			turtle.select(16)
			move.up()
			move.backward()
			turtle.place()
			moves = moves - 1
			while moves >= 12 and turtle.getItemCount(16) ~= 0 do
				move.turnAround()
				move.forward(12)
				move.turnAround()
				turtle.place()
				moves = moves - 12
			end
		end
	else
		term.clear()
		print("No torches in slot 16.")
	end
end

if type(tonumber(tArgs[1])) ~= "number" then
	error(("Usage: %s 10"):format(fs.getName(shell.getRunningProgram())))
end

local start = data.copyTable(data.coords)
data.saveData("/.save", "/start_pos", start)
storage.avoidChest()
mineSquence(tonumber(tArgs[1]))
returnSquence(tonumber(tArgs[1])-1)
move.moveTo(start.x, start.y, start.z)
storage.drop(data.coords)
fs.delete("/.save")