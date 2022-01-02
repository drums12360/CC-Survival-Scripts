local data = require("dataAPI")
local tools = require("toolsAPI")
local move = require("moveAPI")
local storage = require("storageAPI")
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

local oreList = {
	"minecraft:iron_ore",
	"minecraft:coal_ore",
	"minecraft:gold_ore",
	"minecraft:diamond_ore",
	"minecraft:emerald_ore",
	"minecraft:copper_ore",
	"minecraft:lapis_ore",
	"minecraft:redstone_ore",
	"minecraft:deepslate_iron_ore",
	"minecraft:deepslate_coal_ore",
	"minecraft:deepslate_gold_ore",
	"minecraft:deepslate_diamond_ore",
	"minecraft:deepslate_emerald_ore",
	"minecraft:deepslate_copper_ore",
	"minecraft:deepslate_lapis_ore",
	"minecraft:deepslate_redstone_ore",
	"minecraft:nether_gold_ore",
	"minecraft:nether_quartz_ore",
}

function stackPop()
	local func = inverter[stack[#stack]]
	table.remove(stack)
	return func()
end

function checkFallTable(tbl)
	if type(tbl) ~= "table" then
		error("'tbl' is not of type table",2)
	end
	if tbl[1] == true then
		for k,v in pairs(fallList) do
			if tbl[2].name == fallList[k] then
			return true
		end
	end
		return false
	else
		return false
	end
end

function checkOreTable(tbl)
	if type(tbl) ~= "table" then
		error("'tbl' is not of type table",2)
	end
	if tbl[1] == true then
		for k,v in pairs(oreList) do
			if tbl[2].name == oreList[k] then
				return true
			end
		end
		return false
	else
		return false
	end
end

function veinMine(lastFunc)
	if type(lastFunc) == "function" or "string" then
		if type(lastFunc) == "function" then
			for k,v in pairs(converter) do
				if v == lastFunc then
					table.insert(stack, k)
					break
				end
			end
		end
		if checkOreTable({turtle.inspectUp()}) then
			move.up()
			return veinMine(move.up)
		elseif checkOreTable({turtle.inspectDown()}) then
			move.down()
			return veinMine(move.down)
		end
		for i=1, 4 do
			if checkOreTable({turtle.inspect()}) then
				if i == 1 then
					move.forward()
					return veinMine(move.forward)
				elseif i == 2 then
					return veinMine(move.turnLeft)
				elseif i == 3 then
					table.insert(stack, "turnLeft")
					return veinMine(move.turnLeft)
				elseif i == 4 then
					return veinMine(move.turnRight)
				end
			end
			move.turnLeft()
		end
		if stack[#stack] == "turnLeft" then
			if stack[#stack] == stack[#stack-1] then
				stackPop()
				stackPop()
				lastFunc = stack[#stack]
				if #stack > 0 then
					return veinMine(lastFunc)
				end
				return
			else
				stackPop()
				lastFunc = stack[#stack]
				if #stack > 0 then
					return veinMine(lastFunc)
				end
				return
			end
		else
			stackPop()
			lastFunc = stack[#stack]
			if #stack > 0 then
				return veinMine(lastFunc)
			end
			return
		end
	else
		error("'lastFunc' is not of type function or string", 2)
	end
end

function checkForOre()
	if checkOreTable({turtle.inspectUp()}) then
		move.up()
		veinMine(move.up)
	end
	if checkOreTable({turtle.inspectDown()}) then
		move.down()
		veinMine(move.down)
	end
	move.turnLeft()
	if checkOreTable({turtle.inspect()}) then
		move.forward()
		veinMine(move.forward)
	end
	move.turnAround()
	if checkOreTable({turtle.inspect()}) then
		move.forward()
		veinMine(move.forward)
	end
		move.turnLeft()
end

function mineSquence(Shaft_Amount, Shaft_Widht, Shaft_Distance)
	for i=1, Shaft_Amount do
		for i=1, Shaft_Distance do
			move.forward()
			checkForOre()
			turtle.digUp()
		move.turnLeft()
		for i=1, Shaft_Widht do
			move.forward()
			checkForOre()
			turtle.digUp()
		end
		move.turnAround()
		move.forward(Shaft_Widht)
		for i=1, Shaft_Widht do
			move.forward()
			checkForOre()
			turtle.digUp()
		end
		move.turnAround()
		move.forward(Shaft_Widht)
		move.turnRight()
		end
		if data.loadData("/.save", "/chest")[1] == true then
			storage.emptyInv()
		elseif data.loadData("/.save", "/chest")[1] == false then
			storage.waitforemptyInv()
		end
	end
	if checkOreTable({turtle.inspect()}) then
		move.forward()
		veinMine(move.forward)
	end
end

if type(tonumber(tArgs[1])) ~= "number" then
	error(("Usage: %s Define shaft amount, shaft width and shaft distance. (Example: '10 20 3' [10 deep, 20 to each side, and every 3 blocks]"):format(fs.getName(shell.getRunningProgram())))
end

local start = data.copyTable(data.coords)
data.saveData("/.save", "/start_pos", start)
storage.avoidChest()
mineSquence(tonumber(tArgs[1]), tonumber(tArgs[2]), tonumber(tArgs[3]))
move.moveTo(start.x, start.y, start.z)
storage.drop(data.coords)
fs.delete("/.save")