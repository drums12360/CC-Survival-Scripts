local data = require("dataAPI")

local tools = {
	maxSlots = 16,
	slot = 1,
}

local junkList = {
	"minecraft:dirt",
	"minecraft:gravel",
	"minecraft:cobblestone",
	"minecraft:cobbled_deepslate",
	"minecraft:tuff",
	"minecraft:andesite",
	"minecraft:diorite",
	"minecraft:granite",
}

function tools.findItem(name)
	for i=1, tools.maxSlots do
		if turtle.getItemCount(i) ~= 0 then
			local item = turtle.getItemDetail(i).name
			if item == name then
				turtle.select(i)
				tools.slot = tonumber(i)
				return true
			end
		end
	end
	return false
end

function tools.inventorySort()
	local inv = {}
	for i=1, tools.maxSlots do
		inv[i] = turtle.getItemDetail(i)
	end
	for i=1, tools.maxSlots do
		if inv[i] and inv[i].count < 64 then
		for j=(i+1), tools.maxSlots do
			if inv[j] and inv[i].name == inv[j].name then
				if turtle.getItemSpace(i) == 0 then
					break
				end
				turtle.select(j)
				tools.slot = j
				local count = turtle.getItemSpace(i)
				if count > inv[j].count then
					count = inv[j].count
				end
				turtle.transferTo(i, count)
				inv[i].count = inv[i].count + count
				inv[j].count = inv[j].count - count
				if inv[j].count <= 0 then
					inv[j] = nil
			end
			end
		end
		end
	end
	for i=1, tools.maxSlots do
		if not inv[i] then
			for j=(i+1), tools.maxSlots do
				if inv[j] then
				turtle.select(j)
				tools.slot = j
				turtle.transferTo(i)
				inv[i] = data.copyTable(inv[j])
				inv[j] = nil
				break
				end
			end
		end
	end
	turtle.select(1)
	tools.slot = 1
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
		if turtle.getItemCount(i) ~= 0 then
			local item = turtle.getItemDetail(i).name
			local isJunk = false
			for index, value in ipairs(junkList) do
				if item == value then
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
	tools.inventorySort()
end

function tools.findJunk(exclude)
	if exclude == nil then
		exclude = "nothing"
	end
	for i=1, tools.maxSlots do
		if turtle.getItemCount(i) ~= 0 then
			local item = turtle.getItemDetail(i).name
			local isJunk = false
			for index, value in ipairs(junkList) do
				if item == value and item ~= exclude then
					isJunk = true
					break
				end
			end
			if isJunk then
				turtle.select(i)
				tools.slot = tonumber(i)
				return true
			end
		end
	end
	return false
end

return tools