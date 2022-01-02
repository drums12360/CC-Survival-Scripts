local move = require("moveAPI")
local dig = {
	timeout = 5,
	d = 0,
	hasWireless = false,
	direction = {[0] = "north", [1] = "east", [2] = "south", [3] = "west"},
	coords = {x = 0, y = 0,z = 0}
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

return dig