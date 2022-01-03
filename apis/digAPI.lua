local move = require("moveAPI")

local dig = {

}

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
	"minecraft:obsidian",
}

function dig.stackPop()
	local func = inverter[stack[#stack]]
	table.remove(stack)
	return func()
end

function dig.checkOreTable(tbl)
	if type(tbl) ~= "table" then
		error("'tbl' is not of type table", 2)
	end
	if tbl[1] == true then
		for k,v in pairs(oreList) do
			if tbl[2].name == oreList[k] then
				return true
			end
		end
	else
		return false
	end
end

function dig.veinMine(lastFunc)
	if type(lastFunc) == "function" or "string" then
		if type(lastFunc) == "function" then
			for k,v in pairs(converter) do
				if v == lastFunc then
					table.insert(stack, k)
					break
				end
			end
		end
		if dig.checkOreTable({turtle.inspectUp()}) then
			move.up()
			return dig.veinMine(move.up)
		elseif dig.checkOreTable({turtle.inspectDown()}) then
			move.down()
			return dig.veinMine(move.down)
		end
		for i=1, 4 do
			if dig.checkOreTable({turtle.inspect()}) then
				if i == 1 then
					move.forward()
					return dig.veinMine(move.forward)
				elseif i == 2 then
					return dig.veinMine(move.turnLeft)
				elseif i == 3 then
					table.insert(stack, "turnLeft")
					return dig.veinMine(move.turnLeft)
				elseif i == 4 then
					return dig.veinMine(move.turnRight)
				end
			end
			move.turnLeft()
		end
		if stack[#stack] == "turnLeft" then
			if stack[#stack] == stack[#stack-1] then
				dig.stackPop()
				dig.stackPop()
				lastFunc = stack[#stack]
				if #stack > 0 then
					return dig.veinMine(lastFunc)
				end
				return
			else
				dig.stackPop()
				lastFunc = stack[#stack]
				if #stack > 0 then
					return dig.veinMine(lastFunc)
				end
				return
			end
		else
			dig.stackPop()
			lastFunc = stack[#stack]
			if #stack > 0 then
				return dig.veinMine(lastFunc)
			end
			return
		end
	else
		error("'lastFunc' is not of type function or string", 2)
	end
end

function dig.checkForOre(value)
	if dig.checkOreTable({turtle.inspectUp()}) then
		move.up()
		dig.veinMine(move.up)
	end
	if dig.checkOreTable({turtle.inspectDown()}) then
		move.down()
		dig.veinMine(move.down)
	end
	move.turnLeft()
	if dig.checkOreTable({turtle.inspect()}) then
		move.forward()
		dig.veinMine(move.forward)
	end
	move.turnAround()
	if dig.checkOreTable({turtle.inspect()}) then
		move.forward()
		dig.veinMine(move.forward)
	end
	if value == "back_true" then
		move.turnRight()
		if dig.checkOreTable({turtle.inspect()}) then
			move.forward()
			dig.veinMine(move.forward)
		end
		move.turnAround()
		if dig.checkOreTable({turtle.inspect()}) then
			move.forward()
			dig.veinMine(move.forward)
		end
	else
		move.turnLeft()
		if dig.checkOreTable({turtle.inspect()}) then
			move.forward()
			dig.veinMine(move.forward)
		end
	end
	return true
end

return dig