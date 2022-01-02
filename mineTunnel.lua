local dataAPI = require("dataAPI")
local toolsAPI = require("toolsAPI")
local moveAPI = require("moveAPI")
local storageAPI = require("storageAPI")
local digAPI = require("digAPI")
local tArgs = {...}
local stack = {}

local inverter = {
	["forward"] = move.backward,
	["back"] = move.forward,
	["turnLeft"] = move.turnRight,
	["turnRight"] = move.turnLeft,
	["up"] = move.down,
	["down"] = move.up,
}

local converter = {
	["forward"] = move.forward,
	["back"] = move.backward,
	["turnLeft"] = move.turnLeft,
	["turnRight"] = move.turnRight,
	["up"] = move.up,
	["down"] = move.down,
}

function stackPop()
	local func = inverter[stack[#stack]]
	table.remove(stack)
	return func()
end

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
	if dig.checkOreTable({turtle.inspect()}) then
		move.forward()
		dig.veinMine(move.forward)
	end
end

function returnSquence(amount)
	local moves = amount
	if turtle.getItemCount(16) ~= 0 then
		if turtle.getItemDetail(16).name ~= "minecraft:torch" then
			return false
			elseif turtle.getItemDetail(16).name == "minecraft:torch" and amount > 4 then
			turtle.select(16)
			move.up()
			move.backward()
			turtle.place()
			moves = moves - 1
			while moves > 12 and turtle.getItemCount(16) ~= 0 do
				move.turnAround()
				move.forward(12)
				move.turnAround()
				turtle.place()
				moves = moves - 12
			end
		end
	else
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
mineSquence(tArgs[1])
move.moveTo(start.x, start.y, start.z)
storage.drop(data.coords)
fs.delete("/.save")