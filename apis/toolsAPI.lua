local storage = require("storageAPI")

local tools = {
	maxSlots = 16,
	slot = tonumber(turtle.getSelectedSlot()),
}

local fuelList = {
	"minecraft:coal",
	"minecraft:coal_block",
	"minecraft:charcoal",
	"mekanism:block_charcoal",
	"minecraft:lava_bucket",
}

local junkList = {
  "minecraft:cobbled_deepslate",
  "minecraft:tuff",
  "minecraft:cobblestone",
  "minecraft:dirt",
  "minecraft:andesite",
  "minecraft:diorite",
  "minecraft:granite",
  "minecraft:gravel",
}


function tools.findItem(name)
	if type(name) ~= "string" then
		error("The type of 'name' is not a string")
		return false
	end
	local item = turtle.getItemDetail(tools.slot)
	if item ~= nil then
		if item.name == name then
		return true
		end
	end
	for i=1, tools.maxSlots do
		item = turtle.getItemDetail(i)
		if item ~= nil then
			if item.name == name then
			turtle.select(i)
			tools.slot = tonumber(i)
			return true
			end
		end
	end
	return false
end

function tools.refuel()
	for i=1, #fuelList do
		if tools.findItem(fuelList[i]) then
			turtle.refuel()
			return true
		else
			return false
		end
	end
end

function tools.place(blockName, direction)
	tools.findItem(blockName)
	if direction == nil then
		turtle.place()
	elseif direction == "up" then
		turtle.placeUp()
	elseif direction == "down" then
		turtle.placeDown()
	end
end

function tools.dig(direction)
	if direction == nil then
		turtle.dig()
	elseif direction == "up" then
		turtle.digUp()
	elseif direction == "down" then
		turtle.digDown()
	end
end

function tools.dropJunk()
	for i=1, tools.maxSlots do
		local item = turtle.getItemDetail(i)
		if item ~= nil then
		local isJunk = false
		for j=1,#junkList do
			if item.name == junkList[j] then
			isJunk = true
			break
			end
		end
		if isJunk then
			turtle.select(i)
			tools.slot = tonumber(i)
			turtle.dropUp()
		end
		end
	end
	storage.inventorySort()
end

return tools