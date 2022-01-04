--[[local data = require("dataAPI")
local move = require("moveAPI")
local storage = require("storageAPI")
local dig = require("digAPI")
local tools = require("toolsAPI")--]]
local library = require(".library/init")
local tArgs = {...}

function mineSquence(amount)
	for i=1, amount do
		library.move.forward()
		library.dig.checkForOre()
		library.tools.dig("up")
		if library.data.loadData("/.save", "/chest")[1] == true then
			library.storage.emptyInv()
		elseif library.data.loadData("/.save", "/chest")[1] == false then
			library.storage.waitforemptyInv()
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
			library.move.up()
			library.move.backward()
			turtle.place()
			moves = moves - 1
			while moves >= 12 and turtle.getItemCount(16) ~= 0 do
				library.move.turnAround()
				library.move.forward(12)
				library.move.turnAround()
				turtle.place()
				moves = moves - 12
			end
		end
	else
		term.clear()
		print("No torches in slot 16!")
	end
end

if type(tonumber(tArgs[1])) ~= "number" then
	term.clear()
	term.setCursorPos(1,1)
	error("Define tunnel lenght! (Example: '10') [10 block long]")
end

local start = library.data.copyTable(library.data.coords)
library.data.saveData("/.save", "/start_pos", start)
library.storage.avoidChest()
mineSquence(tonumber(tArgs[1]))
returnSquence(tonumber(tArgs[1])-1)
library.move.moveTo(start.x, start.y, start.z)
library.storage.drop(library.tools.maxSlots)
fs.delete("/.save")